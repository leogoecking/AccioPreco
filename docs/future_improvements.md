# Accio Preço — Melhorias Futuras e Roadmap Pós-MVP

Este documento registra ideias, sugestões arquiteturais e oportunidades de evolução levantadas durante as Fases 1, 2 e 3 do projeto **Accio Preço** (Teixeira de Freitas - BA), deliberadamente mantidas fora do escopo do MVP para preservar simplicidade, foco e velocidade de entrega.

---

## 1. Experiência do Comerciante (Painel)

### 1.1 Gerenciamento de Fotos & Mídia
* **Crop / Redimensionamento no Navegador**: Implementar corte assistido (1:1 para produtos, 16:9 para banners) via biblioteca leve em Stimulus (ex: Cropper.js) antes do upload.
* **Ordenação de Imagens (Drag-and-drop)**: Permitir arrastar miniaturas para redefinir qual foto é a principal da galeria.
* **Compressão Automática WebP no Servidor**: Otimização contínua de imagens via libvips para reduzir tráfego 4G/5G mobile.

### 1.2 Horário de Funcionamento & Status em Tempo Real
* **Configuração de Horários**: Tabela semanal (segunda a domingo, horário de abertura e fechamento, intervalo de almoço).
* **Tag "Aberto Agora" / "Fechado"**: Indicação dinâmica no perfil da empresa e nos cards da busca pública com base no relógio do servidor ou fuso horário local (`America/Bahia`).

### 1.3 Catálogo em Massa & Importação
* **Importação via Planilha (CSV / Excel)**: Para lojistas com inventários superiores a 100 itens (materiais de construção, autopeças, papelarias).
* **Duplicação Rápida de Produtos / Variações**: Botão para duplicar um produto existente preservando categoria e fotos, alterando apenas cor, tamanho ou voltagem.

### 1.4 Notificações em Tempo Real
* **Avisos de Novos Leads por WhatsApp/SMS/E-mail**: Notificar o comerciante imediatamente quando uma solicitação de orçamento for enviada pelo site.
* **Web Push Notifications**: Alerta nativo no smartphone do comerciante quando um cliente solicitar atendimento.

---

## 2. Experiência do Consumidor (Busca & Navegação)

### 2.1 Geolocalização & Bairros
* **Ordenação por Proximidade**: Ordenar resultados com base na localização aproximada do cliente em Teixeira de Freitas (ex: bairro Centro, Bela Vista, Monte Castelo, etc.).
* **Filtro Rápido por Bairro**: Dropdown de bairros populares da cidade para encontrar comércios vizinhos.

### 2.2 Busca Inteligente & Sugestões
* **Autosuggest / Typeahead**: Sugestões instantâneas de produtos e termos populares enquanto o usuário digita no campo de busca.
* **Correção Fonética e Sinônimos Locais**: Dicionário de termos e gírias comerciais regionais (ex: "conserto", "reparo", "ar condicionado", "split").

### 2.3 Favoritos & Compartilhamento
* **Salvar nos Favoritos**: Lista de produtos ou serviços salvos no navegador (via `localStorage`) sem necessidade de criar login de consumidor.
* **Compartilhamento 1-Clique**: Botão de compartilhar link direto no WhatsApp com miniatura Open Graph formatada.

---

## 3. Arquitetura & Infraestrutura

### 3.1 Performance & Cache
* **Cache HTTP e Fragment Cache com Hotwire**: Cache das parciais de cards de busca com invalidação automática orientada por `touch` nos models.
* **CDN para Ativos Estáticos e Imagens**: Cloudflare ou AWS CloudFront na frente do Active Storage para acelerar carregamento de mídia em redes móveis.

### 3.2 Painel Administrativo Geral (Super Admin)
* **Gestão de Comerciantes e Verificação**: Painel interno para moderadores do Accio Preço revisarem e aprovarem o selo "Verificado" de empresas locais.
* **Destaques Patrocinados**: Gestão de espaços de destaque (`featured: true`) para monetização da plataforma.
* **Auditoria de Leads e Métricas Globais**: Relatórios agregados de intenções comerciais na cidade (itens mais procurados, horários de pico, categorias com maior demanda não atendida).

---

## 4. O que o Accio Preço NÃO deve se tornar (Princípios Anti-Escopo)

Para não perder a proposta de valor ágil de busca hiperlocal, os seguintes itens devem continuar estritamente fora do sistema principal:
* **Não ser um ERP contábil ou fiscal** (sem emissão de NF-e, controle de contas a pagar, balanço ou estoque físico de galpão).
* **Não ser um gateway de pagamento fechado** (o fechamento da venda pertence ao relacionamento direto entre comerciante e consumidor via WhatsApp ou balcão).
* **Não intermediar logística ou entregadores próprios** (o comércio local já utiliza motoboys parceiros ou retirada presencial).
