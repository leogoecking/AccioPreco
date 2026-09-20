# Accio Preço

Plataforma hiperlocal de busca e conexão comercial voltada inicialmente para a cidade de **Teixeira de Freitas - BA** e região.

O objetivo do projeto é ajudar pessoas a descobrir rapidamente produtos, serviços, empresas e profissionais locais, facilitando o contato direto via WhatsApp com baixíssima fricção (sem obrigatoriedade de cadastro para o consumidor).

---

## 1. Stack Tecnológica

* **Ruby on Rails 8.1.3**
* **Ruby 3.3.6**
* **PostgreSQL 16** (via Docker Compose na porta `5434` para evitar conflitos de portas locais)
* **Hotwire** (Turbo 8 + Stimulus)
* **Tailwind CSS v4** (via `tailwindcss-rails`)
* **Autenticação Nativa do Rails 8** (`has_secure_password`, sessões seguras e tokens)
* **Active Storage** (upload de logos e fotos de produtos/serviços)
* **Solid Queue / Solid Cache / Solid Cable** (soluções integradas do Rails 8)
* **Propshaft** (asset pipeline nativo moderno)
* **Docker & Docker Compose** (ambiente de banco de dados e deploy preparado)

---

## 2. Pré-requisitos

* **Docker & Docker Compose** (para o PostgreSQL e/ou ambiente conteinerizado)
* **Ruby 3.3+** (gerenciado nativamente ou via `mise` / `rbenv` / `asdf`)
* **Git**

---

## 3. Instalação e Configuração

### 3.1. Clonar o repositório e entrar no diretório

```bash
cd "Accio Preço"
```

### 3.2. Subir o banco de dados PostgreSQL via Docker

```bash
docker compose up -d db
```

O PostgreSQL estará rodando no container `accio_preco_db` e exposto na porta `5434` (usuário: `postgres`, senha: `password`).

### 3.3. Instalar as dependências (Gems)

```bash
bundle install
```

### 3.4. Preparar o banco de dados e executar as Migrations

```bash
bin/rails db:create db:migrate
```

### 3.5. Carregar os Seeds (Dados iniciais de Teixeira de Freitas)

```bash
bin/rails db:seed
```

Os seeds incluem:
* 1 Administrador e 5 Comerciantes;
* Categorias principais (Informática, Climatização, Elétrica, Automotivo, Pet Shop, etc.);
* 5 Empresas fictícias de bairros de Teixeira de Freitas (Centro, Bela Vista, Monte Castelo, Recanto do Lago);
* Produtos com fotos, preços e promoções;
* Serviços com preços estimados, atendimento a domicílio e descrições;
* Leads simulados para o painel.

---

## 4. Credenciais de Desenvolvimento (Seeds)

| Papel | E-mail | Senha | Estabelecimento Associado |
| :--- | :--- | :--- | :--- |
| **Comerciante** | `comerciante@techhouse.com` | `password123` | Tech House Informática |
| **Comerciante** | `roberto@climasul.com` | `password123` | Clima Sul Refrigeração |
| **Comerciante** | `mariana@casacia.com` | `password123` | Casa & Cia Materiais Elétricos |
| **Comerciante** | `marcos@autocentersul.com` | `password123` | Auto Center Sul |
| **Comerciante** | `ana@petfeliz.com` | `password123` | Pet Feliz Clínica & Pet Shop |
| **Administrador** | `admin@acciopreco.com` | `password123` | Painel Administrativo Geral |

---

## 5. Executando a Aplicação

Para iniciar o servidor com compilação contínua do Tailwind CSS:

```bash
bin/dev
```

Ou diretamente pelo Rails:

```bash
bin/rails server
```

Acesse no navegador:
* **Página Inicial:** `http://localhost:3000`
* **Produtos:** `http://localhost:3000/produtos`
* **Serviços:** `http://localhost:3000/servicos`
* **Empresas:** `http://localhost:3000/empresas`
* **Painel do Comerciante:** `http://localhost:3000/painel`
* **Login:** `http://localhost:3000/login`

---

## 6. Executando a Suíte de Testes

```bash
bin/rails test
```

A suíte inclui testes para:
* Validações de modelos (`User`, `Business`, `Category`, `Product`, `Service`, `Lead`);
* Geração automática e idempotente de Slugs amigáveis sem dependências externas (`Sluggable`);
* Fluxo de autenticação nativa do Rails 8;
* Proteção de rotas do `/painel`;
* Respostas das rotas públicas.

---

## 7. Estrutura Principal do Projeto

```text
app/
├── controllers/
│   ├── concerns/
│   │   └── authentication.rb      # Autenticação nativa do Rails 8
│   ├── painel/                    # Namespace da área restrita do comerciante
│   │   ├── base_controller.rb     # Controlador base com autenticação obrigatória
│   │   ├── dashboard_controller.rb# Métricas, medidor de perfil e contatos recentes
│   │   ├── businesses_controller.rb# Gestão do perfil, logo/banner e dados de contato
│   │   ├── products_controller.rb # Catálogo, toggle de estoque, exclusão de fotos e Pagy
│   │   ├── services_controller.rb # Gestão de serviços, toggle ativo/inativo e Pagy
│   │   ├── leads_controller.rb    # Histórico de leads com filtros por aba e resposta WhatsApp
│   │   └── accounts_controller.rb # Alteração de dados cadastrais e senha segura
│   ├── search_controller.rb       # Busca global hiperlocal em Teixeira de Freitas
│   ├── businesses_controller.rb   # Catálogo público de empresas
│   ├── products_controller.rb     # Catálogo público de produtos
│   ├── services_controller.rb     # Catálogo público de serviços
│   ├── sessions_controller.rb     # Login e logout
│   └── home_controller.rb         # Home com hero, categorias e busca
├── models/
│   ├── concerns/
│   │   └── sluggable.rb           # Geração de URLs amigáveis / slugs
│   ├── user.rb                    # Usuário (admin / merchant)
│   ├── business.rb                # Estabelecimento ou autônomo
│   ├── category.rb                # Categorias (produtos / serviços / ambos)
│   ├── product.rb                 # Produtos, preços e promoções
│   ├── service.rb                 # Serviços e valores estimados
│   ├── lead.rb                    # Registro de intenções (WhatsApp, orçamentos)
│   ├── session.rb                 # Sessão de autenticação (Rails 8)
│   └── current.rb                 # CurrentAttributes (user e session)
└── views/
    ├── layouts/
    │   ├── application.html.erb   # Layout público mobile-first com Tailwind
    │   └── painel.html.erb        # Layout administrativo do comerciante
    ├── home/                      # Página inicial e busca
    ├── painel/                    # Telas de gestão do comerciante
    ├── products/                  # Telas de exibição pública de produtos
    ├── services/                  # Telas de exibição pública de serviços
    ├── businesses/                # Perfil público das empresas
    └── sessions/                  # Tela de login
```

---

## 8. Decisões Arquiteturais da Fase 1

1. **Monolito Modular:** Focado em convenção do Rails 8, evitando micro-serviços ou SPAs desacopladas. O sistema já prevê futura exposição de API JSON sem refatoração da camada de domínio.
2. **URLs Amigáveis Nativas (`Sluggable`):** Implementado sem dependências de gems de terceiros (`friendly_id`), garantindo performance, previsibilidade e unicidade através de `parameterize`.
3. **Hiperlocalismo sem PostGIS Prematuro:** Inicialmente, latitude/longitude são armazenadas como colunas decimais de precisão, preservando simplicidade enquanto viabiliza futura geolocalização e cálculo de distância.
4. **Sem atrito para o consumidor:** Navegação, pesquisa e clique para WhatsApp são 100% livres de autenticação. Apenas comerciantes e administradores autenticam para gerenciar catálogo.

---

## 9. Backlog de Correções e Débitos Técnicos

O mapeamento de melhorias secundárias, débitos técnicos e otimizações identificadas para as próximas fases está documentado em:
* [`docs/BACKLOG_CORRECOES.md`](docs/BACKLOG_CORRECOES.md)
