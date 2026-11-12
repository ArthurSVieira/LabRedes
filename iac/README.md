# Manual de Implantação Automatizada (IaC) — Servidor OpenCloud (GPEI)

Este diretório contém todos os arquivos de **Infraestrutura como Código (IaC)** necessários para levantar, do zero e de forma 100% reproduzível, a nuvem privada do **GPEI (Sala 201 - CT-12)** em um servidor **Ubuntu Server LTS**.

A ideia aqui foi automatizar todo o trabalho braçal: em vez de instalar pacotes e editar dezenas de arquivos na mão, o script [`setup-server.sh`](./setup-server.sh) prepara o sistema operacional, configura o firewall local, gera as variáveis de ambiente e sobe todos os microsserviços no Docker Compose.

---

## 1. Estrutura dos Arquivos deste Diretório

```text
iac/
├── README.md                  # Este manual de implantação e testes
├── setup-server.sh            # Script Bash de provisionamento automatizado (Ubuntu Server)
├── docker-compose.yml         # Orquestração dos containers na rede isolada 'opencloud-net'
└── config/                    # Arquivos de configuração montados nos containers
    ├── opencloud/
    │   ├── apps.yaml                 # Configuração de extensões web do OpenCloud
    │   ├── banned-password-list.txt  # Lista básica de senhas fracas bloqueadas
    │   ├── csp.yaml                  # Políticas de Segurança de Conteúdo (CSP para o Collabora)
    │   └── proxy.yaml                # Rotas internas do proxy (/caldav, /carddav e /yjs)
    ├── radicale/
    │   └── config                    # Configuração do servidor de calendário (autenticação via proxy)
    └── traefik/
        └── docker-entrypoint-override.sh  # Inicialização do Traefik + certificado HTTPS
```

### Quais containers sobem nessa pilha?
1. **`gpei-traefik` (`traefik:v3.7.16`):** Proxy reverso de borda. É o único container exposto nas portas `80` e `443` do Ubuntu, responsável por redirecionar HTTP para HTTPS e gerenciar os certificados TLS.
2. **`gpei-opencloud` (`opencloudeu/opencloud-rolling:9.0.0`):** Núcleo em Go da plataforma (arquitetura *database-less*), que já inclui o provedor de identidade (IDP), os *Spaces* das equipes do GPEI e o serviço interno de integração `collaboration` (WOPI).
3. **`gpei-collabora` (`collabora/code:26.04.5.2.1`) + `gpei-collabora-proof-key`:** Servidor de edição colaborativa online (planilhas `.xlsx`, textos `.docx` e apresentações `.pptx`) aberto diretamente dentro do navegador.
4. **`gpei-yjs` (`opencloudeu/yjs:1.1.1`):** Servidor WebSocket auxiliar para sincronização em tempo real de documentos e notas do OpenCloud.
5. **`gpei-radicale` (`tomsquest/docker-radicale:latest`):** Servidor leve de agendas e contatos (CalDAV/CardDAV), integrado ao login do OpenCloud pela rota `/caldav/`.

---

## 2. Pré-requisitos no Servidor Ubuntu (Hardware e Armazenamento)

Para implantar a pilha completa do OpenCloud + Collabora + Radicale no Ubuntu Server, considere o seguinte dimensionamento de armazenamento e recursos:

- **Sistema Operacional:** Ubuntu Server 22.04 LTS ou 24.04 LTS (64-bit);
- **Armazenamento em Disco (Storage):**
  - **Mínimo para subir e testar o ambiente:** **`20 GB` de espaço em disco livre** (as imagens Docker do Collabora Online, OpenCloud, Traefik, Radicale e Yjs ocupam cerca de `~3,5 GB` extraídas, o arquivo de Swap criado pelo script ocupa `4 GB`, o Ubuntu ocupa `~3 GB`, sobrando `~9,5 GB` livres para arquivos de teste e logs);
  - **Em produção na Sala 201 (Servidor Físico 1U Short-Depth):** **`2 TB` úteis em RAID 1** (`2x SSD NVMe de 2 TB` espelhados), garantindo espaço para os *Spaces* das linhas de pesquisa do GPEI e para as cotas individuais dos alunos e pesquisadores sem risco de perda de dados se um SSD falhar;
- **Memória RAM e CPU:** Mínimo de `2 vCPUs` e `2 GB de RAM` (para testes com o Swap de 4 GB ativado) ou `4 GB+ de RAM` recomendados para uso simultâneo confortável do Collabora Online;
- **Acesso e Rede:** Usuário com permissão de `sudo`, acesso à internet (para baixar as imagens Docker) e portas **`80/TCP`** e **`443/TCP`** livres no host (se houver Apache ou Nginx rodando na máquina, o próprio script para esses serviços automaticamente para evitar conflito de porta).

---

## 3. Passo a Passo de Implantação no Ubuntu Server

### Passo 1 — Clonar o repositório e entrar na pasta `iac/`
No terminal do Ubuntu Server, execute:

```bash
git clone https://github.com/DCOMP-UFS/lab-redes-turma1-2026-2-repo-ArthurSVieira.git
cd lab-redes-turma1-2026-2-repo-ArthurSVieira/iac
```
*(Ou use o link do portfólio: `git clone https://github.com/ArthurSVieira/LabRedes.git && cd LabRedes/iac`)*

### Passo 2 — Executar o script de provisionamento
Garanta a permissão de execução e rode o script com `sudo`:

```bash
chmod +x setup-server.sh
sudo ./setup-server.sh
```

### O que o `setup-server.sh` faz sozinho por baixo dos panos?
1. **`[1/5]` Memória Swap (4 GB):** Verifica se existe um `/swapfile`. Se não existir, cria e ativa 4 GB de Swap para garantir que o **Collabora Online** não sofra falta de memória em picos de uso.
2. **`[2/5]` Docker e Docker Compose:** Verifica se o Docker está instalado; caso não esteja, baixa e instala a versão oficial e ativa o serviço no `systemd`.
3. **`[3/5]` Firewall Local (`UFW`):** Ativa o firewall do Ubuntu bloqueando todas as portas de entrada por padrão (`deny incoming`) e liberando **exclusivamente** as portas `22/TCP` (SSH), `80/TCP` (HTTP) e `443/TCP` (HTTPS). Assim, as portas internas dos containers (`9200`, `9980`, `5232`, `1234`) nunca ficam expostas diretamente na rede.
4. **`[4/5]` Detecção de IP e Domínio `.nip.io`:** Detecta o IP da máquina e gera automaticamente o arquivo `.env` com os domínios `opencloud.<IP>.nip.io` e `collabora.<IP>.nip.io` (usando o serviço de DNS curinga `nip.io` para resolver o domínio sem precisar configurar um servidor DNS externo).
5. **`[5/5]` Subida dos Containers:** Libera eventuais conflitos nas portas `80/443` e executa o `docker compose up -d`.

---

## 4. Como Acessar e Testar o Software Após a Instalação

Quando o script terminar, ele exibirá no terminal a URL exata gerada para a sua máquina.

### 4.1. Credenciais Padrão de Acesso (Navegador)
- **URL do Painel OpenCloud:** `https://opencloud.<IP-DO-SERVIDOR>.nip.io`
- **URL da Agenda (CalDAV):** `https://opencloud.<IP-DO-SERVIDOR>.nip.io/caldav/`
- **Usuário Administrador:** `admin`
- **Senha Inicial:** `Gpei@Cloud2025!`

### 4.2. Comandos Básicos de Verificação no Terminal
Se quiser testar pelo terminal do Ubuntu se todos os serviços estão saudáveis:

```bash
# 1. Verificar se os 5 containers principais estão com status "Up"
sudo docker ps

# 2. Acompanhar os logs de inicialização do OpenCloud e do Traefik
sudo docker logs --tail 30 gpei-opencloud
sudo docker logs --tail 20 gpei-traefik

# 3. Testar a resposta HTTP/HTTPS do proxy reverso localmente
curl -k -I https://localhost
```

### 4.3. Como Reiniciar ou Resetar o Ambiente do Zero
- **Apenas reiniciar os containers (mantendo os arquivos e usuários salvos):**
  ```bash
  sudo docker compose restart
  ```
- **Apagar tudo (incluindo volumes/usuários) e recriar do zero:**
  ```bash
  sudo docker compose down -v
  sudo ./setup-server.sh
  ```

---

## 5. ☁️ Adendo: Rodando na AWS EC2 (Para Testes da Turma)

Como na disciplina cada aluno testa a infraestrutura dos colegas usando uma máquina virtual na **AWS EC2**, o nosso script `setup-server.sh` foi preparado com duas adaptações bem legais pensando especificamente na nuvem da AWS:

1. **Detecção Automática do IP Público da EC2 + Certificado Let's Encrypt Real:**
   - Na AWS, a placa de rede da máquina tem um IP privado (`172.31.x.x`), mas quem acessa pelo navegador usa o **IP Público** da instância.
   - O `setup-server.sh` consulta automaticamente `https://checkip.amazonaws.com` para descobrir o IP Público da sua EC2 e já ativa o **Let's Encrypt (`tls.certresolver=letsencrypt`)** no Traefik. Em cerca de **15 segundos** após o script terminar, você pode abrir `https://opencloud.<IP-PUBLICO-EC2>.nip.io` no navegador com **cadeado HTTPS válido de verdade**, sem cair naquele bloqueio de HSTS/certificado inválido do Chrome!
2. **Proteção para quando a instância EC2 é desligada e ligada de novo (Mudança de IP):**
   - Na AWS (sem Elastic IP fixo), toda vez que você dá *Stop* e *Start* na instância EC2, o IP público muda.
   - Nós colocamos uma verificação no `setup-server.sh` (usando o arquivo `.last_domain`): se você rodar `sudo ./setup-server.sh` após o IP da sua EC2 ter mudado, ele detecta que o domínio mudou, limpa os volumes antigos do IDP (`docker compose down -v`) para não dar erro `HTTP 500` de conflito de domínio, e já sobe tudo configurado para o IP novo!

### Checklist Rápido na AWS EC2 antes de rodar o script:
- **Imagem (AMI):** Ubuntu Server 22.04 LTS ou 24.04 LTS.
- **Tipo de Instância:** Funciona em `t2.micro` / `t3.micro` (graças aos 4 GB de Swap que o nosso script cria no Passo 1), mas se puder usar `t3.small` ou `t3.medium` o Collabora inicia mais rápido.
- **Armazenamento na AWS (Volume EBS — Importante!):** Ao criar a instância EC2 na AWS, altere o disco padrão de `8 GB` para pelo menos **`20 GB` (`gp3`)** (que continua dentro dos `30 GB` gratuitos do *AWS Free Tier*!). Com apenas `8 GB`, o disco enche ao somar o Ubuntu (`~3 GB`) + Swap (`4 GB`) + imagens Docker do Collabora e OpenCloud (`~3,5 GB`).
- **Security Group da AWS (Muito Importante!):** Além do `UFW` interno do Ubuntu que o script configura, lembre-se de liberar no **Security Group** do painel da AWS as 3 portas de entrada (*Inbound Rules*):
  - **`SSH` (Porta `22/TCP`)** — Origem: `0.0.0.0/0` (ou Meu IP)
  - **`HTTP` (Porta `80/TCP`)** — Origem: `0.0.0.0/0` *(Obrigatório estar aberto para o Let's Encrypt validar o certificado HTTPS!)*
  - **`HTTPS` (Porta `443/TCP`)** — Origem: `0.0.0.0/0`
