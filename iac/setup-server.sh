#!/usr/bin/env bash
# ==============================================================================
# Script de Provisionamento Automatizado (IaC) — Servidor OpenCloud GPEI
# Laboratório de Informática CT-12 (Sala 201) — GPEI
# ==============================================================================
# Este script configura um servidor Ubuntu Server LTS do zero (seja o Servidor
# Físico 1U Short-Depth na Sala 201 ou uma instância EC2 na AWS para testes):
#   1. Cria 4 GB de memória Swap (permite rodar com folga em EC2 t2/t3.micro)
#   2. Instala o Docker e o plugin Docker Compose (caso não estejam instalados)
#   3. Configura o Firewall Local do Ubuntu (UFW) em Defesa em Profundidade
#   4. Detecta o IP automaticamente e gera o domínio .nip.io no arquivo .env
#   5. Sobe toda a pilha de containers do OpenCloud na rede 'opencloud-net'
# ==============================================================================

set -e

echo "======================================================================"
echo " Iniciando configuração do Servidor OpenCloud — GPEI (CT-12 Sala 201)"
echo "======================================================================"

# Verifica se está rodando como root (sudo)
if [ "$EUID" -ne 0 ]; then
  echo "[ERRO] Por favor, execute este script com sudo: sudo ./setup-server.sh"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# ------------------------------------------------------------------------------
# PASSO 1: Configurar Arquivo de Swap (4 GB) para estabilidade do Collabora
# ------------------------------------------------------------------------------
echo "[1/5] Verificando memória Swap..."
if [ ! -f /swapfile ]; then
  echo "  -> Criando arquivo de Swap de 4 GB (/swapfile)..."
  fallocate -l 4G /swapfile || dd if=/dev/zero of=/swapfile bs=1M count=4096
  chmod 600 /swapfile
  mkswap /swapfile
  swapon /swapfile
  if ! grep -q "/swapfile" /etc/fstab; then
    echo "/swapfile none swap sw 0 0" >> /etc/fstab
  fi
  echo "  -> Swap de 4 GB ativado com sucesso!"
else
  echo "  -> Arquivo de Swap já existe. Pulando..."
fi

# ------------------------------------------------------------------------------
# PASSO 2: Instalar Docker e Docker Compose (se necessário)
# ------------------------------------------------------------------------------
echo "[2/5] Verificando instalação do Docker..."
if ! command -v docker &> /dev/null; then
  echo "  -> Docker não encontrado. Instalando pacotes oficiais..."
  apt-get update -y
  apt-get install -y ca-certificates curl gnupg ufw
  curl -fsSL https://get.docker.com | sh
  systemctl enable --now docker
  echo "  -> Docker instalado com sucesso!"
else
  echo "  -> Docker já está instalado."
fi

# ------------------------------------------------------------------------------
# PASSO 3: Configurar Firewall Local do Host (UFW - Defesa em Profundidade)
# ------------------------------------------------------------------------------
echo "[3/5] Configurando Firewall do Servidor (UFW)..."
ufw default deny incoming
ufw default allow outgoing
# Libera SSH (porta 22) para administração remota (VLAN 10 / AWS SSH)
ufw allow 22/tcp comment 'SSH Gerencia'
# Libera apenas HTTP (80) e HTTPS (443) para o proxy reverso Traefik
ufw allow 80/tcp comment 'Traefik HTTP Redirect e ACME Let_s Encrypt'
ufw allow 443/tcp comment 'Traefik HTTPS OpenCloud'
# As portas internas (9200, 9980, 5232, 1234) ficam bloqueadas no host
ufw --force enable
echo "  -> Firewall UFW ativo (Portas 22, 80 e 443 liberadas)."

# ------------------------------------------------------------------------------
# PASSO 4: Detectar IP da Máquina (AWS Público ou LAN Sala 201) e criar .env
# ------------------------------------------------------------------------------
echo "[4/5] Detectando endereço IP para configurar o domínio (.nip.io)..."
PUBLIC_IP=$(curl -s --max-time 3 https://checkip.amazonaws.com | tr -d '[:space:]' || true)
LOCAL_IP=$(hostname -I | awk '{print $1}' | tr -d '[:space:]')

if [ -n "$PUBLIC_IP" ]; then
  DETECTED_IP="$PUBLIC_IP"
  TRAEFIK_SERVICES_TLS_CONFIG="tls.certresolver=letsencrypt"
  echo "  -> IP Público detectado: ${DETECTED_IP} (Certificado Let's Encrypt ativado)"
else
  DETECTED_IP="${LOCAL_IP:-192.168.20.10}"
  TRAEFIK_SERVICES_TLS_CONFIG="tls=true"
  echo "  -> IP Local detectado: ${DETECTED_IP} (Modo LAN interna)"
fi

OC_DOMAIN="opencloud.${DETECTED_IP}.nip.io"
COLLABORA_DOMAIN="collabora.${DETECTED_IP}.nip.io"
INITIAL_ADMIN_PASSWORD="${INITIAL_ADMIN_PASSWORD:-Gpei@Cloud2025!}"

cat > "$SCRIPT_DIR/.env" <<EOF
# Arquivo gerado automaticamente pelo setup-server.sh
DETECTED_IP=${DETECTED_IP}
OC_DOMAIN=${OC_DOMAIN}
COLLABORA_DOMAIN=${COLLABORA_DOMAIN}
INITIAL_ADMIN_PASSWORD=${INITIAL_ADMIN_PASSWORD}
INSECURE=true
TRAEFIK_SERVICES_TLS_CONFIG=${TRAEFIK_SERVICES_TLS_CONFIG}
TRAEFIK_ACME_MAIL=arthurssivieira@gmail.com
EOF

chmod +x "$SCRIPT_DIR/config/traefik/docker-entrypoint-override.sh"

echo "  -> Domínio OpenCloud: https://${OC_DOMAIN}"
echo "  -> Domínio Collabora: https://${COLLABORA_DOMAIN}"

# ------------------------------------------------------------------------------
# PASSO 5: Liberar Portas 80/443, Atualizar Domínio e Subir os Containers
# ------------------------------------------------------------------------------
echo "[5/5] Preparando ambiente Docker e liberando portas 80/443..."

# Para eventuais servidores web locais (Apache/Nginx) que estejam ocupando a porta 80/443
systemctl stop apache2 nginx caddy 2>/dev/null || true

# Para containers anteriores (inclusive de outros projetos na máquina) e remove
# o volume antigo de config do OpenCloud caso o IP da AWS tenha mudado
RUNNING_CONTAINERS=$(docker ps -q)
if [ -n "$RUNNING_CONTAINERS" ]; then
  echo "  -> Parando containers em execução para liberar as portas 80 e 443..."
  docker stop $RUNNING_CONTAINERS >/dev/null 2>&1 || true
fi

# Verifica se o domínio mudou em relação à execução anterior
PREV_DOMAIN=""
if [ -f "$SCRIPT_DIR/.last_domain" ]; then
  PREV_DOMAIN=$(cat "$SCRIPT_DIR/.last_domain")
fi

if [ -n "$PREV_DOMAIN" ] && [ "$PREV_DOMAIN" != "$OC_DOMAIN" ]; then
  echo "  -> Mudança de IP/Domínio detectada ($PREV_DOMAIN -> $OC_DOMAIN). Reinicializando volumes do IDP..."
  docker compose down -v >/dev/null 2>&1 || true
else
  docker compose down >/dev/null 2>&1 || true
fi
echo "$OC_DOMAIN" > "$SCRIPT_DIR/.last_domain"

echo "  -> Subindo a pilha OpenCloud 9 + Collabora + Radicale + Yjs + Traefik..."
docker compose up -d

echo ""
echo "======================================================================"
echo " ✅ IMPLANTAÇÃO CONCLUÍDA COM SUCESSO!"
echo "======================================================================"
echo " 🌐 Acesse o OpenCloud no navegador: https://${OC_DOMAIN}"
echo " 📅 Rota do Calendário (Radicale):   https://${OC_DOMAIN}/caldav/"
echo " 📄 Collabora Online (Edição Web):   https://${COLLABORA_DOMAIN}"
echo "----------------------------------------------------------------------"
echo " 👤 Usuário Administrador: admin"
echo " 🔑 Senha Inicial:         ${INITIAL_ADMIN_PASSWORD}"
echo "----------------------------------------------------------------------"
echo " 💡 Aguarde cerca de 15 segundos no primeiro acesso para o Traefik"
echo "    emitir o certificado HTTPS válido junto ao Let's Encrypt!"
echo "======================================================================"
