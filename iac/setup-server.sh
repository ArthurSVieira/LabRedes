#!/usr/bin/env bash
# ==============================================================================
# Script de Provisionamento Automatizado (IaC) — Servidor OpenCloud GPEI
# Laboratório de Informática CT-12 (Sala 201) — UFES
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
ufw allow 80/tcp comment 'Traefik HTTP Redirect'
ufw allow 443/tcp comment 'Traefik HTTPS OpenCloud'
# As portas internas (9200, 9980, 5232) ficam bloqueadas no host
ufw --force enable
echo "  -> Firewall UFW ativo (Portas 22, 80 e 443 liberadas)."

# ------------------------------------------------------------------------------
# PASSO 4: Detectar IP da Máquina (AWS Público ou LAN Sala 201) e criar .env
# ------------------------------------------------------------------------------
echo "[4/5] Detectando endereço IP para configurar o domínio (.nip.io)..."
# Tenta detectar IP público (caso esteja rodando em teste na AWS EC2);
# se não houver IP público direto, usa o IP local da placa de rede (ex: 192.168.20.10)
DETECTED_IP=$(curl -s --max-time 3 https://checkip.amazonaws.com || hostname -I | awk '{print $1}')
DETECTED_IP=$(echo "$DETECTED_IP" | tr -d '[:space:]')

if [ -z "$DETECTED_IP" ]; then
  DETECTED_IP="192.168.20.10"
fi

OC_DOMAIN="opencloud.${DETECTED_IP}.nip.io"
BASE_IP_DOMAIN="${DETECTED_IP}.nip.io"
OC_ADMIN_PASSWORD="${OC_ADMIN_PASSWORD:-Gpei@Ufes2025!}"

cat > "$SCRIPT_DIR/.env" <<EOF
# Arquivo gerado automaticamente pelo setup-server.sh
DETECTED_IP=${DETECTED_IP}
BASE_IP_DOMAIN=${BASE_IP_DOMAIN}
OC_DOMAIN=${OC_DOMAIN}
OC_ADMIN_PASSWORD=${OC_ADMIN_PASSWORD}
WOPI_SECRET=GpeiWopiSecret2025
EOF

echo "  -> IP detectado: ${DETECTED_IP}"
echo "  -> Domínio configurado: https://${OC_DOMAIN}"

# ------------------------------------------------------------------------------
# PASSO 5: Subir os Containers do Ecossistema OpenCloud via Docker Compose
# ------------------------------------------------------------------------------
echo "[5/5] Baixando imagens e iniciando os containers na rede 'opencloud-net'..."
docker compose up -d

echo ""
echo "======================================================================"
echo " ✅ IMPLANTAÇÃO CONCLUÍDA COM SUCESSO!"
echo "======================================================================"
echo " 🌐 Acesse o OpenCloud no navegador: https://${OC_DOMAIN}"
echo " 📅 Rota do Calendário (Radicale):   https://${OC_DOMAIN}/caldav"
echo " 📄 Collabora Online (Edição Web):   https://collabora.${BASE_IP_DOMAIN}"
echo "----------------------------------------------------------------------"
echo " 👤 Usuário Administrador: admin"
echo " 🔑 Senha Inicial:         ${OC_ADMIN_PASSWORD}"
echo "----------------------------------------------------------------------"
echo " 💡 Nota: Como o certificado TLS inicial é autoassinado pelo Traefik,"
echo "    basta clicar em 'Avançado -> Prosseguir' no primeiro acesso pelo navegador."
echo "======================================================================"
