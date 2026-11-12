# BOM (Bill of Materials) e Orçamento Estimado — Sala 201 (CT-12)

> 📄 **Arquivos de Planilha Anexados:**
> - **Planilha Oficial do TP-Link Omada (com colunas PNCP em laranja e abas de Cobertura/Topologia):** [`CT12- Sala201(GPEI).xlsx`](./CT12-%20Sala201(GPEI).xlsx)
> - **Planilha consolidada em CSV:** [`BOM-orcamento.csv`](../BOM-orcamento.csv)

---

## 1. Planilha de Equipamentos no Padrão Omada + Atas Vigentes (PNCP)

Seguindo o padrão de orçamentação pública baseado em **Atas de Registro de Preços Vigentes no PNCP (Portal Nacional de Contratações Públicas)** e na exportação direta do **TP-Link Omada Design Hub**, a tabela abaixo consolida os itens originais da planta física com as colunas de **Tipo de Dispositivo**, **ID de Contratação PNCP** e **Marca/Modelo de Referência**:

| Tipo Original (Omada) | Tipo Dispositivo | Ata Vigente / ID de Contratação PNCP | Descrição e Link de Conferência | Marca / Modelo Referência | Qtd | Cópia Seg. | Total | Preço Unitário | Desconto | Preço Total |
| :--- | :--- | :---: | :--- | :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| `ER7206` | **Roteador Corporativo de Borda Gigabit/SFP** | `15303600000108-1-000042/2025` | Roteador Corporativo Gigabit VPN Gateway c/ SFP ([Conferir especificação](https://www.tp-link.com/br/business-networking/omada-sdn-router/er7206/)) | **TP-LINK** — `ER7206` | `1` | `0` | `1` | R$ 850,00 | 0,00% | **R$ 850,00** |
| `SG3452XP` | **Switch Gerenciável 48 Portas PoE+ (4x SFP+)** | `32752798000114-1-000028/2025` | Switch Gerenciável L2+ 48 Portas Gigabit PoE+ e 4 Portas 10GE SFP+ — Item 2.17.18 Edital ([Conferir especificação](https://www.tp-link.com/br/business-networking/omada-sdn-switch/tl-sg3452xp/)) | **TP-LINK** — `SG3452XP` | `1` | `0` | `1` | R$ 3.500,00 | 0,00% | **R$ 3.500,00** |
| `EAP620 HD` | **Access Point Wi-Fi 6 de Teto PoE (Ponto WF01)** | `32752798000114-1-000028/2025` | AX1800 Ceiling Mount Wi-Fi 6 Access Point instalado no centro da Sala 201 ([Conferir especificação](https://www.tp-link.com/br/business-networking/omada-sdn-access-point/eap620-hd/)) | **TP-LINK** — `EAP620 HD` | `1` | `0` | `1` | R$ 950,00 | 0,00% | **R$ 950,00** |
| `EAP115-Wall` | **Kit 48 Pontos RJ-45 Cat.6 (3 Bancadas) + 2 Patch Panels 24p** | `24380571000105-1-000019/2025` | Conjunto de 48 Tomadas RJ-45 Fêmea Cat.6 (distribuídas nas 3 Bancadas da Sala 201) + 2 Patch Panels 24p Cat.6 (`900,00`) + 97 Patch Cords Cat.6 e dutos embutidos (`1.500,00`) — Itens 2.17.1 a 2.17.17 Edital | **FURUKAWA** — `GIGALAN CAT.6` | `1` | `0` | `1` | R$ 2.400,00 | 0,00% | **R$ 2.400,00** |
| `CAT.5E` *(Upgrade Cat.6)* | **Caixas de Cabo de Rede UTP Cat.6 CM (305m cada)** | `24380571000105-1-000019/2025` | Cabo Par Trançado U/UTP Cat.6 CM Anti-chama (`3 caixas de 305 m = 915 m` para atender os `689,00 m` lançados nos 49 pontos da Sala 201 — Item 2.17.12 Edital) | **FURUKAWA** — `SOHOPULSE CAT.6` | `3` *(915m)* | `0` | `3` *(915m)* | R$ 850,00 | 0,00% | **R$ 2.550,00** |
| `MMF (OM3/OM4)` | **Módulos Transceivers SFP / Fibra (SFP 1, 2 e 3)** | `32752798000114-1-000028/2025` | Módulos Transceivers SFP/SFP+ 1G/10Gbps + Cordão Óptico Multimodo OM3/OM4 (`2 m`) para interconexão Core-Distribuição-Acesso-Servidor | **TP-LINK** — `TL-SM5310-T` | `3` | `0` | `3` | R$ 350,00 | 0,00% | **R$ 1.050,00** |
| `SRV-1U-SHORT` | **Servidor Rack 1U Short-Depth (`≤ 430mm`) OpenCloud** | `00394460000141-1-000112/2025` | Servidor Físico 1U Short-Depth (`≤ 430 mm`), 2x Intel Xeon, 64GB RAM ECC, 2x SSD NVMe 2TB em RAID 1 para hospedar o OpenCloud, Collabora e Radicale (Rack `U12`) | **DELL / SUPERMICRO** — `SHORT-DEPTH 1U` | `1` | `0` | `1` | R$ 25.000,00 | 0,00% | **R$ 25.000,00** |
| `FW-BORDA-1U` | **Firewall Físico Dedicado de Borda Corporativo 1U** | `15303600000108-1-000042/2025` | Appliance de Firewall Físico Dedicado de Borda 1U (Camada de Distribuição — Rack `U21`) para inspeção stateful e controle de ACLs entre VLANs `10`, `20` e `30` | **FORTINET / NETGATE** — `RACK 1U` | `1` | `0` | `1` | R$ 4.000,00 | 0,00% | **R$ 4.000,00** |
| `UPS-3KVA-2U` | **NoBreak Senoidal Online Dupla Conversão Rack 2U** | `15303600000108-1-000051/2025` | NoBreak (UPS) Senoidal Online Dupla Conversão 3kVA Rack Mount 2U com autonomia mínima de 30 minutos (Rack `U01-U02`) | **APC / SMS** — `SMART-UPS 3000VA` | `1` | `0` | `1` | R$ 6.000,00 | 0,00% | **R$ 6.000,00** |
| `RACK-24U-570` | **Rack Fechado 19" (`24U × 570mm`) + Kit Acessórios** | `24380571000105-1-000019/2025` | Rack de Piso Fechado 19" (`24U × 570 mm` — Item 2.9.1 Edital) + `8` Guias 1U + `8` Placas Cegas 1U + `2` Bandejas 1U + Calha PDU 6T 20A + DIO 1U | **INTELBRAS** — `RACK 24U 570MM` | `1` | `0` | `1` | R$ 1.800,00 | 0,00% | **R$ 1.800,00** |
| — | **SUBTOTAL 1 (Taxas de Equipamento de Rede/Rack/Servidor)** | — | **Subtotal de Infraestrutura de Rede, Rack 24U, Servidor 1U e Cabeamento Cat.6** | — | — | — | — | — | — | **R$ 48.100,00** |

---

## 2. Equipamentos da Área de Trabalho e Sala de Aula (GPEI)

Esta segunda parte contempla os computadores das 48 posições da Sala 201 (47 alunos + 1 professor), o projetor de teto e a impressora sem fio do laboratório:

| Item | Categoria | Ata Vigente / ID PNCP | Descrição Técnica | Marca / Modelo Referência | Qtd | Valor Unitário (R$) | Valor Total (R$) |
| :---: | :--- | :---: | :--- | :--- | :---: | :---: | :---: |
| **12** | Área de Trabalho (Alunos) | `00394460000141-1-000145/2025` | **Desktop Compacto SFF (*Small Form Factor*)** (Core i5, 16GB RAM, SSD NVMe 512GB) + **Monitor 24" Full HD** + Kit Teclado ABNT2 (c/ numérico) e Mouse | **DELL / LENOVO** — `OptiPlex / ThinkCentre SFF` | `47` | R$ 4.500,00 | **R$ 211.500,00** |
| **13** | Área de Trabalho (Professor) | `00394460000141-1-000145/2025` | **Desktop do Professor (Saída Dual HDMI)** (Core i5, 16GB RAM, SSD NVMe 512GB) + **Monitor 24" Full HD** + Kit Teclado e Mouse Sem Fio (Ponto `1202`) | **DELL / LENOVO** — `SFF Dual-HDMI` | `01` | R$ 4.800,00 | **R$ 4.800,00** |
| **14** | Apresentação Coletiva | `15303600000108-1-000063/2025` | **Projetor Multimídia de Teto Full HD (`≥ 4.000 Lumens`)** + Suporte Universal de Teto e Cabo HDMI de 15m Embutido | **EPSON** — `PowerLite FH52+` | `01` | R$ 5.800,00 | **R$ 5.800,00** |
| **15** | Periféricos | `15303600000108-1-000063/2025` | **Impressora Multifuncional Laser Monocromática com Wi-Fi e Duplex** — Conectada na `VLAN 30` via `WF01` (`192.168.30.50`) | **BROTHER** — `DCP-L2540DW` | `01` | R$ 1.650,00 | **R$ 1.650,00** |
| — | **SUBTOTAL 2** | — | **Subtotal de Computadores, Projetor e Impressora da Sala 201** | — | — | — | **R$ 223.750,00** |

---

## 3. Resumo Geral do Orçamento

| Escopo Orçamentário | Valor Estimado (R$) |
| :--- | :---: |
| **1. Infraestrutura de Rede, Rack 24U, Servidor 1U OpenCloud e Cabeamento Cat.6** | **R$ 48.100,00** |
| **2. Estações de Trabalho (48 PCs + Monitores 24"), Projetor Full HD e Impressora Wi-Fi** | **R$ 223.750,00** |
| **3. Licenciamento de Software (Ubuntu + Docker + OpenCloud + Collabora + Radicale)** | **R$ 0,00 (100% Gratuito)** |
| **4. Mão de Obra de Instalação, Configuração e Certificação Cat.6** | *Sob Consulta* |
| **💰 TOTAL GERAL DE EQUIPAMENTOS E MATERIAIS** | **R$ 271.850,00** |

### Justificativas de Custo-Benefício do Projeto:
- **Economia com Software Livre (`R$ 0,00`):** Se o laboratório contratasse licenças comerciais equivalentes (ex.: Microsoft 365 / Google Workspace comercial ou Windows Server CALs para 48 máquinas e grupos de pesquisa), haveria um custo anual recorrente elevado. Com a pilha **OpenCloud + Collabora Online + Radicale** rodando no servidor local, o custo de licença é zero.
- **Economia de Switch Extra com o Uso das Portas SFP/SFP+:** A decisão de usar os **3 módulos Transceivers SFP (`R$ 1.050,00`)** nas portas de uplink do Switch de 48 portas permitiu conectar o **Link de Borda (`SFP 1`)**, o **Servidor 1U em alta velocidade (`SFP 2`)** e o **49º ponto do Access Point `WF01` (`SFP 3`)** sem precisar comprar um segundo switch gerenciável extra.
- **Dimensionamento Exato de Cabo Cat.6:** Como o projeto executivo exige **689,00 metros** de cabo UTP Cat.6, foram orçadas **3 caixas de 305 metros (`915 metros` no total)**, garantindo a metragem necessária mais uma margem técnica de reserva de `~32%` para manutenções futuras.
