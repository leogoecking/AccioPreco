# Backlog de Correções e Débitos Técnicos — Accio Preço

Este documento consolida os bugs e pontos de melhoria identificados após a conclusão da **Fase 1 (Fundação)**, organizados por gravidade e prioridade, registrando as soluções recomendadas para execução nas fases subsequentes.

---

## ✅ Bugs de Gravidade Crítica (RESOLVIDOS)

| # | Problema | Causa | Solução Aplicada | Status |
| :--- | :--- | :--- | :--- | :--- |
| **CRIT-01** | `NoMethodError: undefined method 'painel_businesses_path'` ao criar empresa no painel. | `form_with model: [:painel, business]` deduzia rota plural inexistente para recurso singular. | Especificado `url: painel_business_path` explícito no `form_with` em `_form.html.erb`. | ✅ **Resolvido** |
| **CRIT-02** | `RecordNotFound: Couldn't find Product with 'id'="slug"` ao editar/excluir no painel. | `set_product` e `set_service` usavam `find(params[:id])`, incompatível com `to_param` (slug). | Ajustado para buscar por `find_by(slug: params[:id]) \|\| find_by!(id: params[:id])`. | ✅ **Resolvido** |

---

## 🟠 Bugs de Gravidade Alta (Registrados para Próxima Fase)

### BUG-01: Erro 500 (`MissingTemplate`) nas Rotas Individuais `show` do Painel
* **Prioridade:** P2 (Alta)
* **Falha:** Requisições para `GET /painel/produtos/:id`, `GET /painel/servicos/:id` ou `GET /painel/leads/:id` disparam erro 500 por ausência dos templates de visualização.
* **Causa:** As actions `show` estão presentes nos controllers ou no mapeamento padrão de `resources` em `routes.rb`, mas os arquivos `show.html.erb` não existem.
* **Arquivos Afetados:**
  * `app/controllers/painel/products_controller.rb`
  * `app/controllers/painel/services_controller.rb`
  * `app/controllers/painel/leads_controller.rb`
  * `config/routes.rb`
* **Solução Recomendada:**
  * Para produtos e serviços: ajustar rotas no painel com `except: :show` ou redirecionar a action `show` para a action `edit`.
  * Para leads: criar `app/views/painel/leads/show.html.erb` exibindo detalhes completos do lead (telefone, mensagem, item vinculado e timestamp).

---

### BUG-02: `NoMethodError` ao Acessar Edição de Empresa sem Estabelecimento Cadastrado
* **Prioridade:** P2 (Alta)
* **Falha:** Usuário recém-criado sem empresa vinculada que acesse `/painel/empresa/edit` ou envie `PATCH /painel/empresa` recebe erro 500 (`undefined method 'update' for nil:NilClass`).
* **Causa:** `Painel::BusinessesController` não possui `before_action :require_business!` nas actions `:show`, `:edit` e `:update`.
* **Arquivos Afetados:**
  * `app/controllers/painel/businesses_controller.rb`
* **Solução Recomendada:**
  * Adicionar `before_action :require_business!, only: %i[edit update]`.
  * Na action `show`, redirecionar para `new_painel_business_path` com aviso amigável quando `@current_business` for nulo.

---

## 🟡 Bugs de Gravidade Média (Registrados para Próxima Fase)

### BUG-03: Consultas N+1 em Listagens Públicas e Tabelas do Painel
* **Prioridade:** P3 (Média)
* **Falha:** Múltiplas consultas SQL consecutivas disparadas ao iterar sobre coleções em views.
* **Causa:** Ausência de `includes` nas seguintes consultas:
  1. `HomeController#search`: Faltando `.includes(:business)`.
  2. `BusinessesController#show`: Faltando `.includes(:category)` para produtos e serviços da empresa.
  3. `Painel::ProductsController#index` e `Painel::ServicesController#index`: Faltando `.includes(:category)` para exibir o nome da categoria na tabela.
* **Arquivos Afetados:**
  * `app/controllers/home_controller.rb`
  * `app/controllers/businesses_controller.rb`
  * `app/controllers/painel/products_controller.rb`
  * `app/controllers/painel/services_controller.rb`
* **Solução Recomendada:**
  * Adicionar eager loading com `.includes(...)` em cada um dos métodos mapeados.

---

### BUG-04: Ausência de Inputs de Upload nas Views de Formulário (Active Storage)
* **Prioridade:** P3 (Média)
* **Falha:** Comerciante não consegue enviar fotos de produtos, fotos de serviços, logo ou banner pela interface.
* **Causa:** Os inputs `<%= f.file_field ... %>` não foram inseridos nos templates `_form.html.erb`.
* **Arquivos Afetados:**
  * `app/views/painel/products/_form.html.erb` (`images`)
  * `app/views/painel/services/_form.html.erb` (`images`)
  * `app/views/painel/businesses/_form.html.erb` (`logo`, `banner`)
* **Solução Recomendada:**
  * Adicionar inputs modernos de upload com preview e indicação de formato aceito (JPEG, PNG, WEBP).

---

### BUG-05: Truncamento Silencioso de Centavos em Valores Preenchidos com Vírgula
* **Prioridade:** P3 (Média)
* **Falha:** Preços digitados com vírgula decimal (ex: `149,90`) têm seus centavos descartados ao salvar (`149.00`).
* **Causa:** Ausência de sanitização/normalização do input numérico antes da conversão pelo ActiveRecord.
* **Arquivos Afetados:**
  * `app/controllers/painel/products_controller.rb`
  * `app/controllers/painel/services_controller.rb`
* **Solução Recomendada:**
  * Implementar normalização no controller ou setter customizado no model substituindo `,` por `.` antes da persistência.

---

## 🟢 Bugs de Gravidade Baixa (Registrados para Próxima Fase)

### BUG-06: Normalização Incompleta de Links de WhatsApp
* **Prioridade:** P4 (Baixa)
* **Falha:** Números pertencentes a DDDs iniciados por 55 não recebem o código do país `55`; números preenchidos apenas com caracteres não numéricos geram link vazio `href=""`.
* **Causa:** Checagem por `start_with?("55")` em vez da quantidade de dígitos (10 ou 11 dígitos com DDD).
* **Arquivos Afetados:**
  * `app/models/business.rb`
* **Solução Recomendada:**
  * Ajustar `whatsapp_cleaned` para validar se a quantidade de dígitos é 10 ou 11 antes de prefixar `55` e retornar `nil` se o número higienizado for inválido.

---

### BUG-07: Falta de Escape em Consultas SQL `LIKE` na Busca Pública
* **Prioridade:** P4 (Baixa)
* **Falha:** Usuário pesquisando `%` ou `_` dispara consultas onde o caractere é tratado como curinga do SQL, retornando todos os registros.
* **Causa:** Ausência de sanitização via `sanitize_sql_like`.
* **Arquivos Afetados:**
  * `app/controllers/home_controller.rb`
* **Solução Recomendada:**
  * Aplicar `ActiveRecord::Base.sanitize_sql_like(query)` antes de montar a cláusula `LIKE`.

---

### BUG-08: Rigidez do `allow_browser versions: :modern` para Consumidores Mobile
* **Prioridade:** P4 (Baixa)
* **Falha:** Consumidores utilizando WebViews embutidas em redes sociais ou navegadores mobile mais antigos podem receber status `406 Not Acceptable`.
* **Causa:** `allow_browser versions: :modern` ativo globalmente no `ApplicationController`.
* **Arquivos Afetados:**
  * `app/controllers/application_controller.rb`
* **Solução Recomendada:**
  * Manter a restrição apenas na área administrativa/painel ou suavizar os requisitos nas rotas públicas para maximizar alcance e SEO local.
