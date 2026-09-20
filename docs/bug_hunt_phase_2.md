# Bug Hunt — Fase 2 (Accio Preço)

Registro detalhado dos bugs identificados durante a revisão de QA e engenharia sênior pós-Fase 2.

---

### BUG-01
- **Título:** HTTP 500 ao passar parâmetros de página inválidos na paginação (`page=-1`, `page=abc`)
- **Prioridade:** P1
- **Área:** Paginação / Controllers Públicos
- **Como reproduzir:** Acessar `/buscar?page=-1`, `/buscar?page=abc` ou `/produtos?page=xyz`.
- **Resultado atual:** `Pagy::VariableError: expected :page >= 1; got "-1"` gerando HTTP 500 não tratado.
- **Resultado esperado:** Redirecionamento para a primeira página (`page=1`) preservando os demais filtros ou tratamento gracioso sem 500.
- **Causa:** Falta de `rescue_from Pagy::VariableError` no `ApplicationController`.
- **Correção:** Adicionar `rescue_from Pagy::VariableError` com redirecionamento para a página 1 preservando os demais parâmetros de busca.
- **Teste de regressão:** `test "pagination handles invalid page parameters without 500 error"`
- **Status:** Corrigido

---

### BUG-02
- **Título:** Produtos e serviços de empresas inativas exibidos publicamente
- **Prioridade:** P1
- **Área:** Catálogo Público / Controllers & Models
- **Como reproduzir:** Desativar uma empresa (`business.update!(active: false)`). Acessar `/produtos`, `/servicos`, `/categorias/:slug` ou a busca.
- **Resultado atual:** Os itens da empresa inativa ainda aparecem nas listagens públicas e páginas de detalhe.
- **Resultado esperado:** Produtos e serviços de empresas inativas devem ser 100% omitidos da área pública e retornar 404 em acesso direto.
- **Causa:** Os escopos públicos `Product.available` e `Service.active` não faziam join com `businesses` para checar `active: true`.
- **Correção:** Criar escopo `publicly_visible` em `Product` e `Service` (`joins(:business).where(businesses: { active: true })`) e utilizá-lo nos controllers públicos.
- **Teste de regressão:** `test "inactive businesses products and services are not visible publicly"`
- **Status:** Corrigido

---

### BUG-03
- **Título:** ZeroDivisionError quando produto tem preço 0 e formatação incorreta de moedas
- **Prioridade:** P1
- **Área:** Models / Views
- **Como reproduzir:** Cadastrar produto com `price: 0`. Chamar `discount_percentage`.
- **Resultado atual:** `ZeroDivisionError: divided by 0`. Além disso, valores exibidos com ponto (`R$ 79.90`) e serviços com preço zero exibindo "A partir de R$ 0,00".
- **Resultado esperado:** Validação `price > 0`. Proteção contra divisão por zero em `discount_percentage`. Preços formatados em BRL (`R$ 79,90`). Serviços sem preço exibindo "Sob consulta".
- **Causa:** `Product` permitia `price >= 0` e `Service#formatted_price` não checava se `starting_price > 0`.
- **Correção:** Atualizar validações para `greater_than: 0`, ajustar `discount_percentage`, ajustar `Service#formatted_price` e criar helper `format_currency`.
- **Teste de regressão:** `test "validates price greater than zero"` e `test "formatted_price returns sob consulta for zero price"`
- **Status:** Corrigido

---

### BUG-04
- **Título:** WhatsApp com DDD iniciado por zero (`073...`) gera link incorreto no `wa.me`
- **Prioridade:** P1
- **Área:** Model `Business` / Integração WhatsApp
- **Como reproduzir:** Cadastrar `whatsapp: "073999999999"`. Chamar `business.whatsapp_url`.
- **Resultado atual:** Gera `https://wa.me/073999999999` (sem código de país `55` e com zero à esquerda), que falha no WhatsApp.
- **Resultado esperado:** Gera `https://wa.me/5573999999999`.
- **Causa:** `whatsapp_cleaned` não removia zeros à esquerda antes de calcular o tamanho do número.
- **Correção:** Remover zeros à esquerda com `.sub(/^0+/, "")` e validar que o número resultante possui entre 12 e 13 dígitos.
- **Teste de regressão:** `test "whatsapp_url normalizes numbers with leading zeros, ddd, and country code"`
- **Status:** Corrigido

---

### BUG-05
- **Título:** Solicitação de orçamento aceita telefones inválidos como `"123"` ou `"abcdef"`
- **Prioridade:** P1
- **Área:** Model `Lead` / Captação de Leads
- **Como reproduzir:** Submeter lead de `quote_request` com `phone: "123"` ou `phone: "abcdef"`.
- **Resultado atual:** Lead salvo no banco com telefone inválido.
- **Resultado esperado:** Erro de validação informando que o WhatsApp/telefone com DDD é inválido.
- **Causa:** Validação exigia apenas `presence: true` para o telefone.
- **Correção:** Adicionar validação de formato exigindo entre 10 e 13 dígitos numéricos.
- **Teste de regressão:** `test "validates phone format for quote requests"`
- **Status:** Corrigido

---

### BUG-06
- **Título:** Duplo clique no botão de orçamento gera múltiplos leads duplicados
- **Prioridade:** P2
- **Área:** Views / Hotwire Turbo
- **Como reproduzir:** Clicar rapidamente duas vezes no botão de envio de orçamento.
- **Resultado atual:** Dois requests POST concorrentes são disparados gerando dois leads duplicados.
- **Resultado esperado:** Botão desabilitado automaticamente no primeiro clique com texto "Enviando...".
- **Causa:** Ausência do atributo `data: { turbo_submits_with: ... }` no botão de submit.
- **Correção:** Adicionar `data: { turbo_submits_with: "Enviando solicitação..." }` nos botões dos formulários de orçamento.
- **Teste de regressão:** Validação de markup nos templates.
- **Status:** Corrigido

---

### BUG-07
- **Título:** Envio de orçamento pelo modal não exibe feedback de sucesso no próprio modal
- **Prioridade:** P2
- **Área:** Hotwire Turbo Stream / Views
- **Como reproduzir:** Abrir o modal de solicitação de orçamento rápido e submeter os dados.
- **Resultado atual:** O Turbo Stream substituía apenas o formulário inline da página, deixando o modal aberto sem feedback.
- **Resultado esperado:** O modal também recebe a mensagem de sucesso.
- **Causa:** `app/views/leads/create.turbo_stream.erb` só substituía o target inline.
- **Correção:** Adicionar substituição para o target `quote_request_form_modal_#{@lead.service_id}` no Turbo Stream.
- **Teste de regressão:** `test "create turbo stream replaces both inline and modal forms"`
- **Status:** Corrigido

---

### BUG-08
- **Título:** Alerta de Open Redirect no Brakeman em `LeadsController#whatsapp_click`
- **Prioridade:** P2
- **Área:** Segurança / Controllers
- **Como reproduzir:** Executar análise estática com Brakeman.
- **Resultado atual:** Warning fraco em `redirect_to whatsapp_target, allow_other_host: true`.
- **Resultado esperado:** Redirecionamento com garantia estrita de que o destino pertence ao domínio `https://wa.me/`.
- **Causa:** `allow_other_host: true` sem verificação prefixada de host.
- **Correção:** Checar `whatsapp_target.start_with?("https://wa.me/")` antes do redirecionamento.
- **Teste de regressão:** `bundle exec brakeman` limpo sem avisos.
- **Status:** Corrigido

---

### BUG-09
- **Título:** Falta de validação de tamanho e formato em uploads no Active Storage
- **Prioridade:** P2
- **Área:** Models / Active Storage / Segurança
- **Como reproduzir:** Tentar anexar arquivos executáveis ou de 100MB em produtos, serviços ou empresas.
- **Resultado atual:** Arquivo anexado sem validação de tipo de mídia ou limite de bytes.
- **Resultado esperado:** Validação rejeitando arquivos não imagem e maiores que 5MB.
- **Causa:** Ausência de validações personalizadas de anexo em `Product`, `Service` e `Business`.
- **Correção:** Implementar validações de tamanho (máximo 5MB) e formato (`image/jpeg, image/png, image/webp`).
- **Teste de regressão:** `test "validates attachment content type and file size"`
- **Status:** Corrigido

---

### BUG-10
- **Título:** Formato inconsistente de Instagram pode quebrar URLs externas
- **Prioridade:** P2
- **Área:** Model `Business` / Views
- **Como reproduzir:** Cadastrar Instagram como `https://instagram.com/loja` ou `@loja`.
- **Resultado atual:** View pode gerar `https://instagram.com/https://instagram.com/loja`.
- **Resultado esperado:** Normalização consistente com `instagram_handle` e `instagram_url`.
- **Causa:** Falta de métodos de normalização no modelo.
- **Correção:** Adicionar `instagram_handle` e `instagram_url` no modelo `Business`.
- **Teste de regressão:** `test "instagram normalization handles handles and urls"`
- **Status:** Corrigido

---

### BUG-11
- **Título:** Busca com termos muito longos pode degradar desempenho do PostgreSQL
- **Prioridade:** P2
- **Área:** Services / Performance
- **Como reproduzir:** Enviar string de busca com 1000+ caracteres e centenas de palavras.
- **Resultado atual:** Todas as palavras processadas gerando queries com dezenas de `unaccent` combinados.
- **Resultado esperado:** Corte sensato do termo (máximo 100 caracteres) e limite de até 8 palavras.
- **Causa:** `SearchService` não impunha limites máximos para o comprimento da busca.
- **Correção:** Adicionar `MAX_QUERY_LENGTH = 100` e `MAX_WORDS = 8` no `SearchService`.
- **Teste de regressão:** `test "search service limits query length and word count"`
- **Status:** Corrigido
