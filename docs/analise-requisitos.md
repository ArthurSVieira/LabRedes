# Análise de Requisitos — Laboratório CT-12 (Sala 201) & Solução NuvemCore

## 1. Definição Inicial do Escopo e Principais Objetivos

### 1.1 Escopo Físico e Público-Alvo
- **Cliente / Público-Alvo:** Grupo de Pesquisa e Ensino de Engenharia Industrial (**GPEI**) — atendendo professores, pesquisadores de iniciação científica/pós-graduação e alunos de graduação.
- **Prédios:** 1 prédio — **Prédio CT-12** (Centro Tecnológico da UFES, Campus Goiabeiras).
- **Andares:** 1 andar — **2º pavimento**.
- **Salas:** 1 sala — **Sala 201** (Laboratório de Informática CT-12), com área total de **72,63 m²** (`7,26 m × 10,06 m`).
- **Capacidade da Sala:** **48 posições** no total, sendo **47 computadores para alunos** (divididos entre as bancadas laterais e a ilha central dupla) e **1 computador para a mesa do professor** (ponto `1202`), além de espaço reservado para acessibilidade (**PNE**).

### 1.2 Objetivos Principais
1. **Reforma da Infraestrutura de Rede (100% Cat.6 e Embutida):** Retirar toda a instalação antiga aparente e refazer o cabeamento estruturado em padrão **100% Cat.6** totalmente embutido (forro, paredes, piso e dentro das bancadas), garantindo **49 pontos de rede certificados** (48 nas mesas + 1 no teto para Wi-Fi).
2. **Implantação da Solução NuvemCore (Baseada em Software Livre OpenCloud):** Subir um servidor local no próprio rack do laboratório rodando o serviço **NuvemCore** (plataforma de nuvem privada construída sobre o motor open-source **OpenCloud** via Docker Compose), oferecendo armazenamento em nuvem privada, edição colaborativa de documentos em tempo real (`.xlsx`, `.docx`, `.pptx`) e calendário compartilhado para as equipes.

---

## 2. Estudo de Viabilidade

### 2.1 Viabilidade Física e de Cabeamento (Conforme o TR / Edital FEST nº 011/2025)
A instalação física é viável aproveitando a reforma civil prevista no Termo de Referência da Sala 201:
- **Remoção do existente (Item 2.2.2):** Todas as canaletas e cabos aparentes antigos serão demolidos/retirados.
- **Aproveitamento no forro:** Será mantida a eletrocalha perfurada `200×100 mm` que já existe acima do forro mineral para o caminho principal dos cabos.
- **Caminhamento 100% embutido:**
  - **No forro mineral:** Eletrodutos de PVC rígido (`3/4"`, `1"` e `1½"`) ligando o Rack e o Quadro Elétrico (`QD-B`) às descidas de parede, ao projetor e ao ponto do Access Point (`WF01`).
  - **Nas paredes (alvenaria):** Abertura e fechamento de **20,00 m de rasgos em alvenaria** (Item 2.9.1) para descer os cabos até as caixas `4×4"` a `30 cm` do piso.
  - **No piso:** Eletrodutos de PVC rígido de `1"` embutidos no piso de granilite para levar rede e energia até a **ilha central dupla** sem deixar fios expostos no chão.
  - **No mobiliário:** As bancadas já contam com calhas internas próprias para passar os cabos de rede e energia até as tomadas da mesa.
- **Quantitativo de pontos e cabos (Itens 2.17.18 e 2.17.19):**
  - **48 pontos RJ-45 Cat.6 nas bancadas** (`1201` a `1248`, sendo o `1202` do professor) + **96 tomadas elétricas** (2 por computador).
  - **1 ponto RJ-45 Cat.6 PoE no teto** (`WF01`) para o Access Point Wi-Fi 6.
  - **0 pontos de telefonia (Voz) ou câmeras (CFTV)**, pois não são exigidos no escopo da sala.
  - **Total:** **49 pontos certificados** (densidade de `0,67 ponto/m²`), usando `689,00 m` de cabo UTP Cat.6 CM, `2` Patch Panels de 24 portas Cat.6 e `97` Patch Cords Cat.6 de `2,50 m`.
  - **Link de entrada (Uplink):** Chegada em **Fibra Óptica** da UFES direto no rack por um eletroduto de `1½"`.

> [!IMPORTANT]
> **Decisão de Engenharia: Como ligar 50 conexões em um Switch de 48 portas?**
>
> Durante a análise do projeto executivo, notamos um problema prático: a sala tem **48 pontos de bancada (`1201`–`1248`) + 1 ponto de Wi-Fi (`WF01`) + 1 Servidor Físico OpenCloud** (total de **50 conexões**, fora o link de fibra da UFES), mas o rack prevê apenas **1 Switch de 48 portas PoE** e **2 Patch Panels de 24 portas (48 portas)**.
>
> Para resolver isso sem precisar comprar um segundo switch só por causa de 2 conexões extras, usamos as **portas de Uplink SFP/SFP+ do próprio Switch**:
> - **Portas 1 a 48 (RJ-45 Gigabit PoE):** Atendem os **47 PCs dos Alunos + 1 PC do Professor** (vindos dos 2 Patch Panels de 24 portas).
> - **Porta Uplink SFP 1 (Fibra):** Recebe o **Link de Entrada em Fibra Óptica** da UFES.
> - **Porta Uplink SFP 2 (10 Gbps SFP+ ou 1 Gbps):** Liga diretamente o **Servidor Físico do OpenCloud** em alta velocidade.
> - **Porta Uplink SFP 3 (com Transceiver SFP para RJ-45):** Conecta o **49º cabo da sala (Access Point `WF01`)**.

### 2.2 Viabilidade do Servidor e de Custos (Software Livre)
- **Espaço no Rack:** O rack do projeto é fechado de parede, padrão `19" 24U × 570 mm` de profundidade. Por isso, escolhemos **1 Servidor Físico de Rack 1U *Short-Depth* (profundidade curta, `≤ 430 mm`)**, que cabe com folga dentro do rack de `570 mm`.
- **Custo de Software Zero:** Toda a solução do servidor usa ferramentas gratuitas e de código aberto (Linux, Docker Compose, Traefik, OpenCloud, Radicale e Collabora Online), eliminando gastos com licenças proprietárias.

---

## 3. Necessidades dos Usuários e da Organização

No dia a dia do laboratório de Engenharia Industrial, três grupos diferentes utilizam a rede. O **OpenCloud** organiza esses usuários através de controle de acesso por papéis (**RBAC**) no seu IDP embutido e pastas compartilhadas independentes (**Spaces**):

### 3.1 Grupos de Usuários no Sistema
| Grupo no OpenCloud | Quem faz parte | O que precisa fazer na rede e no sistema |
| :--- | :--- | :--- |
| **`professores`** | Docentes na mesa do professor (ponto `1202`, PC com Dual HDMI ligado ao monitor e ao projetor do teto) e via Wi-Fi | • Gerenciar as turmas e disciplinas.<br>• Publicar *datasets* industriais, modelos de simulação e materiais de aula.<br>• Receber e avaliar entregas dos alunos. |
| **`pesquisadores`** | Pesquisadores do GPEI (**Logística, Simulação e Manufatura** — Iniciação Científica, Mestrado/Doutorado) | • Ter *Spaces* isolados para cada área de pesquisa.<br>• Editar relatórios (`.docx`), planilhas (`.xlsx`) e apresentações (`.pptx`) ao mesmo tempo pelo navegador.<br>• Usar controle automático de versão e agenda compartilhada de reuniões. |
| **`alunos`** | Alunos de graduação nos **47 desktops compactos (SFF)** das bancadas (`1201` e `1203`–`1248`) e no Wi-Fi | • Baixar materiais de aula e *datasets*.<br>• Fazer trabalhos em grupo editando documentos juntos pelo navegador.<br>• Salvar arquivos na sua pasta individual, **sem permissão de acesso** às áreas restritas de pesquisa ou dos professores. |

### 3.2 Divisão de *Spaces* (Pastas Compartilhadas) e Permissões
| Space no OpenCloud | `professores` | `pesquisadores` | `alunos` | Finalidade no Laboratório |
| :--- | :---: | :---: | :---: | :--- |
| **Coordenação / Docentes** | Gerente (Total) | ❌ Sem acesso | ❌ Sem acesso | Provas, gabaritos, pautas e administração das disciplinas. |
| **Spaces de Pesquisa:**<br>• *GPEI - Logística*<br>• *GPEI - Simulação*<br>• *GPEI - Manufatura* | Gerente (Total) | Editor (Leitura/Escrita + Collabora) | ❌ Sem acesso | Artigos, planilhas de dados (`.xlsx`), modelos de simulação e calendário da equipe no Radicale. |
| **Materiais de Aula** | Editor (Publica arquivos) | Leitor | Leitor (Apenas baixa/visualiza) | Apostilas, slides e *datasets* industriais para as aulas práticas (protegido contra exclusão acidental). |
| **Trabalhos e Entregas** | Gerente (Avalia) | — | Editor (Edição colaborativa) | Espaço onde os grupos de alunos criam e editam juntos relatórios (`.docx`) e planilhas (`.xlsx`) via Collabora Online. |
| **Personal Space (Individual)** | Apenas o próprio usuário | Apenas o próprio usuário | Apenas o próprio usuário | Pasta privada de cada usuário logado para salvar seus rascunhos e arquivos pessoais. |

---

## 4. Requisitos de Aplicações e Tráfego (Metodologia Top-Down)

Para atender aos usuários sem lentidão, o servidor roda 4 serviços em containers no **Docker Compose** (conectados na rede interna `opencloud-net`):

1. **Traefik (`traefik`):** Proxy reverso que recebe os acessos em HTTPS (porta `443`) e direciona para o serviço correto.
2. **OpenCloud Core (`opencloudeu/opencloud`):** Sistema principal (feito em Go, sem precisar de banco SQL pesado). Cuida do login dos usuários (IDP embutido), divisão dos grupos e armazenamento dos arquivos nos *Spaces*.
3. **Radicale (`opencloudeu/radicale`):** Servidor leve de calendário (CalDAV), integrado ao OpenCloud pela rota `/caldav` para organizar as agendas de pesquisa e aulas.
4. **Collabora Online + WOPI (`collabora/code` + `cs3org/wopiserver`):** Permite abrir e editar planilhas, textos e slides direto no navegador de forma simultânea.

**Requisitos de Desempenho na Rede Local:**
- Cada um dos 48 computadores terá conexão de **1 Gbps** via cabo Cat.6.
- Como os **47 alunos podem abrir arquivos ou editar planilhas ao mesmo tempo** durante uma aula, o **Servidor Físico OpenCloud** fica conectado na **Porta SFP 2 (10 Gbps SFP+ ou 1 Gbps dedicado)** do switch. Isso evita gargalo na rede local e garante resposta rápida (baixa latência) na edição em tempo real.

---

## 5. Requisitos de Segurança e Gerência (Stallings)

Com base nos conceitos de segurança e governança de redes:
- **Acesso Seguro (HTTPS):** Todo o acesso ao OpenCloud, calendário e edição de documentos é criptografado via SSL/TLS pelo `Traefik` (portas `80/443`).
- **Divisão em VLANs:** O switch gerenciável separa o tráfego em redes virtuais diferentes (**VLAN de Gerência**, **VLAN do Servidor**, **VLAN de Usuários/Bancadas** e **VLAN do Wi-Fi**), impedindo que computadores de alunos tentem acessar diretamente as configurações do switch ou serviços internos do servidor.
- **Proteção dos Containers:** Os containers internos (`OpenCloud`, `Radicale` e `Collabora`) ficam isolados na rede `opencloud-net` do Docker; apenas o proxy `Traefik` fica exposto para receber conexões da rede local.
- **Disponibilidade Elétrica e de Dados:** O rack conta com um **NoBreak Senoidal Online (2U)** para manter o switch e o servidor ligados em caso de queda de energia, e o servidor possui discos SSD NVMe em **RAID 1 (espelhamento)** para não perder arquivos se um disco falhar.
