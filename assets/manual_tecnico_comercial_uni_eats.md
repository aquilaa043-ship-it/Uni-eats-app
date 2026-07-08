# UNI EATS - MANUAL TÉCNICO E COMERCIAL UNIFICADO
## Documento Oficial de Especificação Arquitetural e Comercial (SaaS & Mobile)
**Versão:** 1.0.0  
**Autor:** Equipe de Engenharia e Produto (CTO & PM Sênior)  
**Data:** Julho de 2026

---

## SUMÁRIO

1. [Sumário Executivo do Modelo de Negócios (SaaS)](#1-sumário-executivo-do-modelo-de-negócios-saas)
   - 1.1. Proposta de Valor e Atratividade de Mercado
   - 1.2. Estrutura de Receita Baseada em Split de Transação
   - 1.3. O Painel Oculto do Super Admin e Evolução da Monetização
2. [Dossiê da Logística Justa e Regionalizada](#2-dossiê-da-logística-justa-e-regionalizada)
   - 2.1. A Filosofia da Logística Justa (50/50 Split)
   - 2.2. Tabela Oficial de Taxas por Região (Porte de Cidade)
   - 2.3. Algoritmo de Combos Logísticos (Rotas de até 3 Pedidos)
   - 2.4. Trava de Segurança e Viabilidade Financeira (Valor Mínimo de R$ 15,00)
3. [Arquitetura de Software e Fluxo de Dados](#3-arquitetura-de-software-e-fluxo-de-dados)
   - 3.1. Modelagem do Banco de Dados NoSQL (Cloud Firestore)
   - 3.2. Estrutura e Árvore de Diretórios (Feature-First)
   - 3.3. Mecanismo de Autenticação Unificada e Guarda de Rotas
   - 3.4. Motor de Deep Linking para Bio de Redes Sociais

---

## 1. SUMÁRIO EXECUTIVO DO MODELO DE NEGÓCIOS (SAAS)

### 1.1. Proposta de Valor e Atratividade de Mercado
O **Uni Eats** redefine a relação comercial entre marketplaces de delivery, restaurantes parceiros e entregadores autônomos. Diferente dos players tradicionais do mercado que cobram mensalidades pesadas e comissões abusivas (chegando a 30% sobre o faturamento das lojas), o Uni Eats adota o modelo de **Barreira de Entrada Zero**.

* **Para o Lojista:** Adesão totalmente gratuita, sem taxa de configuração (*setup fee*), sem assinatura ou mensalidade fixa para iniciar as operações.
* **Para o Cliente:** Acesso a um catálogo refinado, pratos com preços equivalentes aos de balcão e uma taxa de entrega justa e transparente.
* **Para o Entregador:** Repasse integral das taxas de entrega, com incentivos e proteção financeira por região de atuação.

### 1.2. Estrutura de Receita Baseada em Split de Transação
Para sustentar e escalar a infraestrutura de forma rentável, o ecossistema monetiza através de uma taxa tecnológica fixa de **R$ 0,80 por pedido concluído**, cobrada diretamente através de split de pagamento integrado.

A liquidação financeira ocorre no momento do *checkout* através do gateway de pagamento (Mercado Pago / PIX):
1. **Valor do Produto (Faturamento do Lojista):** Repassado integralmente para a conta vinculada do lojista, descontando apenas a taxa de R$ 0,80 do software e a tarifa padrão do gateway de pagamento.
2. **Taxa de Entrega (Split de Logística):** Destinada de forma segregada e integral para a carteira digital do motoboy parceiro que executou a rota.

### 1.3. O Painel Oculto do Super Admin e Evolução da Monetização
Como estratégia de expansão comercial de médio e longo prazo, o sistema foi estruturado com um **Painel de Controle do Super Admin Oculto** (`/super_admin`), acessível unicamente por usuários com privilégios de `super_admin` definidos no Firestore. Este painel permite:

* **Gestão de Planos Recorrentes (Futuro):** Criação e ativação de modelos SaaS alternativos, tais como o *Plano Premium Pro* (comissão reduzida por volume de vendas, destaque na busca e ferramentas de marketing avançadas).
* **Gestão de Assinaturas e Status:** Ativação, suspensão ou inativação manual de lojistas inadimplentes ou em desacordo com as diretrizes de qualidade do ecossistema.
* **Parametrização de Taxas:** Controle dinâmico sobre as taxas de split tecnológico e custos operacionais de cada cidade de forma remota.

---

## 2. DOSSIÊ DA LOGÍSTICA JUSTA E REGIONALIZADA

### 2.1. A Filosofia da Logística Justa (50/50 Split)
O custo de frete do Uni Eats é guiado pelo conceito de coparticipação equilibrada. A taxa total de entrega calculada pelo sistema é **dividida igualmente (50/50)** entre o **Consumidor Final (Cliente)** e o **Estabelecimento (Lojista)**. Desta forma, o cliente não é penalizado por taxas abusivas e o restaurante compartilha o investimento na entrega para manter o preço do produto final atrativo.

### 2.2. Tabela Oficial de Taxas por Região (Porte de Cidade)
Para garantir a integridade financeira e a atratividade operacional, as taxas são geograficamente flexíveis, baseando-se no tipo de cidade cadastrada no perfil do restaurante:

| Categoria de Cidade | Valor Total do Frete | Custeio do Cliente (50%) | Custeio do Lojista (50%) | Repasse Integral ao Motoboy |
| :--- | :--- | :--- | :--- | :--- |
| **Cidades de Interior** | R$ 4,00 | R$ 2,00 | R$ 2,00 | **R$ 4,00** |
| **Capitais e Metrópoles**| R$ 6,00 | R$ 3,00 | R$ 3,00 | **R$ 6,00** |

*Nota: Toda a taxa coletada de ambas as partes (Cliente e Lojista) é convertida em repasse garantido para o motoboy autônomo, sem qualquer margem de lucro retida pela plataforma sobre o frete.*

### 2.3. Algoritmo de Combos Logísticos (Rotas de até 3 Pedidos)
Para maximizar a eficiência dos entregadores parceiros e elevar sua remuneração horária, o painel de logística do motoboy (`/rotas_logistica`) possui um algoritmo integrado de **Combos Logísticos**. 

O sistema consolida e oferta até **3 pedidos com origens próximas e destinos na mesma microrregião geográfica** para serem transportados na mesma corrida:

* **Combo de 3 Pedidos em Cidades de Interior:**  
  $$\text{Ganhos} = 3 \times R\$ 4,00 = R\$ 12,00 \text{ (na mesma viagem)}$$
* **Combo de 3 Pedidos em Capitais/Metrópoles:**  
  $$\text{Ganhos} = 3 \times R\$ 6,00 = R\$ 18,00 \text{ (na mesma viagem)}$$

Este agrupamento reduz as perdas operacionais, diminui o tempo ocioso e multiplica a lucratividade por quilômetro rodado do profissional de logística.

### 2.4. Trava de Segurança e Viabilidade Financeira (Valor Mínimo de R$ 15,00)
Para evitar o consumo insustentável de recursos do sistema e o desgaste operacional do lojista e do entregador, o aplicativo possui uma **trava de segurança estrita no lado do cliente (carrinho de compras)**:

* **Regra de Negócio:** O fechamento do pedido é bloqueado se o subtotal dos produtos for **inferior a R$ 15,00**.
* **Validação de Interface:** O botão de finalização de compra muda seu estado para desabilitado, exibindo um aviso educativo informando o valor faltante para atingir a meta de processamento mínimo.

---

## 3. ARQUITETURA DE SOFTWARE E FLUXO DE DADOS

### 3.1. Modelagem do Banco de Dados NoSQL (Cloud Firestore)
O banco de dados é modelado com 4 coleções principais projetadas para consistência mútua e sincronização reativa (Streams/Snapshots):

```
                       [ Coleção: usuarios ]
                       ├── id (UID Firebase Auth)
                       ├── nome
                       ├── email
                       ├── tipo_usuario ("cliente" | "lojista" | "motoboy" | "super_admin")
                       ├── cidade ("capital" | "interior")
                       └── status_assinatura ("ativo" | "suspenso" | "inativo")
                                   │
                                   ├── (Vínculo 1:1)
                                   ▼
                    [ Coleção: restaurantes ]
                    ├── id (rest_ + lojistaId)
                    ├── nome_lugar
                    ├── cidade (afeta taxas)
                    └── status_conexao_mercado_pago ("conectado" | "pendente" | "desconectado")
                                   │
                                   ├── (Vínculo 1:N)
                                   ▼
                       [ Coleção: pedidos ]
                       ├── id
                       ├── id_cliente
                       ├── id_restaurante
                       ├── id_motoboy (Nullable - associado após aceite)
                       ├── valor_produtos (Mínimo de R$ 15,00)
                       ├── taxa_entrega_aplicada (R$ 2 ou R$ 3)
                       ├── repasse_motoboy (R$ 4 ou R$ 6)
                       └── status_pedido ("criado" | "em_preparo" | "pronto" | "a_caminho" | "entregue")
                                   ▲
                                   │ (Leitura reativa de GPS)
                                   │
                [ Coleção: localizacao_motoboy ]
                ├── id_motoboy
                ├── latitude
                ├── longitude
                └── ultima_atualizacao
```

### 3.2. Estrutura e Árvore de Diretórios (Feature-First)
A arquitetura do projeto Flutter segue o padrão **Feature-First**, garantindo isolamento completo de responsabilidades de cada ator do ecossistema e simplificando o desenvolvimento paralelo por múltiplas equipes de engenharia.

```
lib/
├── main.dart                       # Inicialização e Splash do app
├── core/                           # Núcleo compartilhado da aplicação
│   ├── constants/                  # Constantes, cores luxuosas e estilos globais
│   ├── theme/                      # Configurações do Material Design 3 Dark Premium
│   ├── routes/                     # Gerenciador de rotas e Deep Linking
│   └── utils/                      # Extensões e formatadores comerciais
└── features/                       # Módulos encapsulados por ator
    ├── auth/                       # Fluxo Unificado de Autenticação e Registro
    ├── cliente/                    # Catálogo, Trava de R$ 15 e GPS tracking
    ├── lojista/                    # Painel de Pedidos, Split Regional e Link da Bio
    ├── motoboy/                    # Combos de Entrega e Carteira Digital de Repasses
    └── super_admin/                # Gestão central oculta de taxas e status de contas
```

### 3.3. Mecanismo de Autenticação Unificada e Guarda de Rotas
A autenticação do usuário se dá através de um fluxo seguro unificado de e-mail e senha integrado ao **Firebase Auth** em conjunto com as informações persistidas na coleção `/usuarios` do **Firestore**.

#### Segurança na Autenticação e Verificação de Status
No momento do login, o serviço (`FirebaseAuthService`) valida o e-mail, a senha e consulta imediatamente o Firestore para verificar se o perfil estendido existe. Adicionalmente, é verificada a trava administrativa:
* Se `status_assinatura` for igual a `"suspenso"` ou `"inativo"`, o usuário é deslogado do Firebase Auth imediatamente e recebe uma mensagem visual explicando que a conta está bloqueada por inconformidade contratual ou inadimplência financeira.

#### Route Guards (Proteção de Acesso Cruzado)
Para mitigar falhas de segurança onde um usuário cliente ou entregador tenta acessar caminhos confidenciais, a classe `RouteGuard` estabelece matrizes estritas de caminhos permitidos por nível de privilégio. A navegação interna e as tentativas de abertura direta de telas passam por verificação prévia automática, recusando navegações anômalas para as áreas de restaurante e administração.

### 3.4. Motor de Deep Linking para Bio de Redes Sociais
Com foco em facilidade comercial para o Lojista do Uni Eats, o aplicativo possui suporte a **Deep Linking** reativo. No painel de controle do lojista, o botão "Copiar Link para Bio" gera uma URL personalizada:

`unieats.com.br/cardapio?id=rest_lojista_123`

#### Comportamento e Redirecionamento Dinâmico
O motor do `RouteGenerator` intercepta a inicialização do app ou o clique no link externo e traduz de forma inteligente os parâmetros obtidos:
1. **Link Válido:** O app decodifica o parâmetro `id` e direciona o usuário diretamente para a `TelaCardapioCliente` com o cardápio e identidade visual do restaurante parametrizado.
2. **Link Inválido / Sem Parâmetros:** O roteador intercepta o erro de formato de forma defensiva, impede a quebra da experiência do usuário e redireciona-o silenciosamente e com segurança para a `HomeClienteScreen` para explorar o catálogo geral.

---
**Fim da Especificação.** Documento homologado para orientação do time de engenharia de software e comercial.
