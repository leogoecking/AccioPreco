# Seeds para o Accio Preço
# Foco: Teixeira de Freitas - BA

puts "== Limpando base de dados existente... =="
Lead.destroy_all
Product.destroy_all
Service.destroy_all
Business.destroy_all
Category.destroy_all
User.destroy_all

puts "== Criando Usuários... =="
admin = User.create!(
  name: "Administrador Accio",
  email_address: "admin@acciopreco.com",
  password: "password123",
  role: "admin"
)

merchant_tech = User.create!(
  name: "Carlos Eduardo Mendes",
  email_address: "comerciante@techhouse.com",
  password: "password123",
  role: "merchant"
)

merchant_clima = User.create!(
  name: "Roberto Silva Santos",
  email_address: "roberto@climasul.com",
  password: "password123",
  role: "merchant"
)

merchant_casa = User.create!(
  name: "Mariana Costa",
  email_address: "mariana@casacia.com",
  password: "password123",
  role: "merchant"
)

merchant_auto = User.create!(
  name: "Marcos Vinicius Pereira",
  email_address: "marcos@autocentersul.com",
  password: "password123",
  role: "merchant"
)

merchant_pet = User.create!(
  name: "Dra. Ana Paula Dantas",
  email_address: "ana@petfeliz.com",
  password: "password123",
  role: "merchant"
)

merchant_estetica = User.create!(
  name: "Juliana Lima Rocha",
  email_address: "juliana@bellaestetica.com",
  password: "password123",
  role: "merchant"
)

puts "== Criando 8 Categorias Reais... =="
cat_info = Category.create!(name: "Informática & Tecnologia", category_type: "both", active: true)
cat_clima = Category.create!(name: "Ar-condicionado & Climatização", category_type: "both", active: true)
cat_eletrica = Category.create!(name: "Elétrica & Construção", category_type: "both", active: true)
cat_auto = Category.create!(name: "Automotivo & Oficinas", category_type: "both", active: true)
cat_pet = Category.create!(name: "Pet Shop & Veterinária", category_type: "both", active: true)
cat_acessorios = Category.create!(name: "Acessórios & Variedades", category_type: "product", active: true)
cat_casa = Category.create!(name: "Casa, Móveis & Iluminação", category_type: "both", active: true)
cat_beleza = Category.create!(name: "Beleza & Estética", category_type: "both", active: true)

puts "== Criando 6 Empresas de Teixeira de Freitas... =="
biz_tech = Business.create!(
  user: merchant_tech,
  name: "Tech House Informática",
  description: "Loja especializada em computadores, notebooks, acessórios gamer e assistência técnica qualificada no centro de Teixeira de Freitas.",
  business_type: "both",
  phone: "7332911020",
  whatsapp: "73999881122",
  instagram: "@techhouse_tx",
  email: "contato@techhouse.com",
  address: "Av. Getúlio Vargas",
  number: "1850",
  neighborhood: "Centro",
  city: "Teixeira de Freitas",
  state: "BA",
  postal_code: "45990-000",
  latitude: -17.536200,
  longitude: -39.734500,
  active: true,
  verified: true
)

biz_clima = Business.create!(
  user: merchant_clima,
  name: "Clima Sul Refrigeração",
  description: "Venda de aparelhos split, limpeza especializada, higienização e manutenção preventiva e corretiva residencial e comercial.",
  business_type: "both",
  phone: "7332914040",
  whatsapp: "73999773344",
  instagram: "@climasul_refrig",
  email: "atendimento@climasul.com",
  address: "Rua Lomanto Júnior",
  number: "410",
  neighborhood: "Bela Vista",
  city: "Teixeira de Freitas",
  state: "BA",
  postal_code: "45990-120",
  latitude: -17.534000,
  longitude: -39.738000,
  active: true,
  verified: true
)

biz_casa = Business.create!(
  user: merchant_casa,
  name: "Casa & Cia Materiais Elétricos",
  description: "Soluções completas em materiais elétricos residenciais, iluminação em LED, ferramentas e equipe de eletricistas qualificados.",
  business_type: "both",
  phone: "7332925566",
  whatsapp: "73999665544",
  instagram: "@casacia_eletrica",
  email: "vendas@casacia.com",
  address: "Av. Pres. Getúlio Vargas",
  number: "3200",
  neighborhood: "Monte Castelo",
  city: "Teixeira de Freitas",
  state: "BA",
  postal_code: "45995-000",
  latitude: -17.539000,
  longitude: -39.731000,
  active: true,
  verified: true
)

biz_auto = Business.create!(
  user: merchant_auto,
  name: "Auto Center Sul",
  description: "Centro automotivo completo: mecânica em geral, suspensão, freios, alinhamento 3D e troca de óleo rápida para veículos leves e utilitários.",
  business_type: "service_provider",
  phone: "7332917788",
  whatsapp: "73999554433",
  instagram: "@autocentersul_oficina",
  email: "contato@autocentersul.com",
  address: "Av. Paulo Souto",
  number: "890",
  neighborhood: "Recanto do Lago",
  city: "Teixeira de Freitas",
  state: "BA",
  postal_code: "45992-050",
  latitude: -17.545000,
  longitude: -39.742000,
  active: true,
  verified: true
)

biz_pet = Business.create!(
  user: merchant_pet,
  name: "Pet Feliz Clínica & Pet Shop",
  description: "Rações premium e super premium, farmácia veterinária, consultório com atendimento clínico e banho e tosa com serviço de busca em toda a cidade.",
  business_type: "both",
  phone: "7332918899",
  whatsapp: "73999443322",
  instagram: "@petfeliz_tx",
  email: "contato@petfeliz.com",
  address: "Rua Mauá",
  number: "245",
  neighborhood: "Centro",
  city: "Teixeira de Freitas",
  state: "BA",
  postal_code: "45990-050",
  latitude: -17.535500,
  longitude: -39.733000,
  active: true,
  verified: true
)

biz_estetica = Business.create!(
  user: merchant_estetica,
  name: "Bella Estética & Salão",
  description: "Studio de beleza, corte, coloração, tratamentos capilares, estética facial e venda de cosméticos profissionais em Teixeira de Freitas.",
  business_type: "both",
  phone: "7332921133",
  whatsapp: "73999332211",
  instagram: "@bellaestetica_tx",
  email: "contato@bellaestetica.com",
  address: "Rua da Pituba",
  number: "115",
  neighborhood: "Urbis I",
  city: "Teixeira de Freitas",
  state: "BA",
  postal_code: "45991-020",
  latitude: -17.541000,
  longitude: -39.739000,
  active: true,
  verified: true
)

puts "== Criando 18 Produtos... =="
# Tech House (5 produtos)
prod_copo = Product.create!(
  business: biz_tech,
  category: cat_acessorios,
  name: "Copo Térmico 473ml em Aço Inox com Tampa",
  description: "Copo térmico de alta resistência em aço inox com parede dupla isolada a vácuo. Mantém sua bebida gelada por até 4 horas ou quente por 1 hora.",
  price: 99.90,
  promotional_price: 79.90,
  available: true,
  featured: true
)

prod_carregador = Product.create!(
  business: biz_tech,
  category: cat_info,
  name: "Carregador Rápido USB-C 30W Power Delivery",
  description: "Carregador de parede ultra compacto e rápido com saída USB-C. Compatível com iPhone, Samsung Galaxy, Motorola e Xiaomi.",
  price: 69.90,
  promotional_price: 54.90,
  available: true,
  featured: true
)

Product.create!(
  business: biz_tech,
  category: cat_info,
  name: "Mouse Gamer RGB 12.000 DPI com Sensor Óptico",
  description: "Mouse ergonômico para jogos e trabalho de precisão com iluminação RGB personalizável, cabo reforçado e 6 botões programáveis.",
  price: 149.90,
  promotional_price: 129.90,
  available: true,
  featured: false
)

Product.create!(
  business: biz_tech,
  category: cat_info,
  name: "Teclado Mecânico Compacto Switch Blue RGB",
  description: "Teclado mecânico gamer anti-ghosting com teclas switch blue táteis e sonoras, corpo reforçado em alumínio.",
  price: 249.00,
  promotional_price: 219.00,
  available: true,
  featured: false
)

Product.create!(
  business: biz_tech,
  category: cat_info,
  name: "Cabo HDMI 2.1 8K Ultra High Speed 2 metros",
  description: "Cabo HDMI de altíssima velocidade para TVs 4K/8K, monitores e videogames de última geração com conectores banhados a ouro.",
  price: 49.90,
  available: true,
  featured: false
)

# Clima Sul (3 produtos)
Product.create!(
  business: biz_clima,
  category: cat_clima,
  name: "Ar-condicionado Split Inverter LG 12.000 BTUs Dual Voice",
  description: "Tecnologia Dual Inverter com até 70% de economia de energia. Refrigeração rápida, silencioso e compatível com comando de voz e Wi-Fi.",
  price: 2890.00,
  promotional_price: 2690.00,
  available: true,
  featured: true
)

Product.create!(
  business: biz_clima,
  category: cat_clima,
  name: "Ar-condicionado Split Hi-Wall 9.000 BTUs Elgin Eco Power",
  description: "Ideal para quartos e salas pequenas, gás ecológico R410A, filtro ionizador com garantia de 3 anos no compressor.",
  price: 1890.00,
  available: true,
  featured: false
)

Product.create!(
  business: biz_clima,
  category: cat_clima,
  name: "Controle Remoto Universal para Ar-condicionado Split",
  description: "Compatível com mais de 1000 marcas e modelos de ar-condicionado. Configuração fácil e rápida.",
  price: 39.90,
  available: true,
  featured: false
)

# Casa & Cia (4 produtos)
Product.create!(
  business: biz_casa,
  category: cat_casa,
  name: "Lâmpada LED Bulbo 12W Bivolt Luz Branca 6500K",
  description: "Lâmpada econômica de alta durabilidade e baixo consumo energético. Ideal para iluminação residencial e comercial.",
  price: 12.50,
  available: true,
  featured: true
)

Product.create!(
  business: biz_casa,
  category: cat_casa,
  name: "Fita LED 5 Metros RGB com Controle e Fonte",
  description: "Fita de iluminação decorativa com múltiplas cores, intensidade ajustável e controle remoto para sancas e painéis.",
  price: 59.90,
  promotional_price: 49.90,
  available: true,
  featured: false
)

Product.create!(
  business: biz_casa,
  category: cat_eletrica,
  name: "Chuveiro Elétrico Eletrônico Blindado 7500W",
  description: "Banho com controle gradual de temperatura por haste seletora. Maior segurança com resistência blindada.",
  price: 189.00,
  available: true,
  featured: false
)

Product.create!(
  business: biz_casa,
  category: cat_eletrica,
  name: "Extensão Elétrica Profissional 10 Metros Cabo Reforçado",
  description: "Extensão com cabo de alta resistência de 10 metros e 3 tomadas padrão novo, ideal para ferramentas e jardins.",
  price: 65.00,
  available: true,
  featured: false
)

# Pet Feliz (4 produtos)
Product.create!(
  business: biz_pet,
  category: cat_pet,
  name: "Ração Premium Especial Cães Adultos Frango & Arroz 15kg",
  description: "Alimento completo e balanceado para cães adultos de médio e grande porte, com ômega 3 e 6 para pelos brilhantes e digestão equilibrada.",
  price: 189.90,
  promotional_price: 169.90,
  available: true,
  featured: true
)

Product.create!(
  business: biz_pet,
  category: cat_pet,
  name: "Ração Seca para Gatos Castrados Sabor Salmão 3kg",
  description: "Ração desenvolvida com calorias reduzidas e minerais balanceados para prevenir cálculos no trato urinário de gatos castrados.",
  price: 79.90,
  available: true,
  featured: false
)

Product.create!(
  business: biz_pet,
  category: cat_pet,
  name: "Antipulgas e Carrapatos Comprimido Mastigável para Cães 10 a 20kg",
  description: "Proteção rápida e duradoura contra pulgas e carrapatos por até 30 dias com sabor palatável de carne.",
  price: 89.90,
  promotional_price: 79.90,
  available: true,
  featured: false
)

Product.create!(
  business: biz_pet,
  category: cat_pet,
  name: "Caminha Pet Lavável Tamanho G com Almofada Removível",
  description: "Cama macia e aconchegante para cães e gatos com zíper total para lavagem facilitada na máquina.",
  price: 119.00,
  available: true,
  featured: false
)

# Bella Estética (2 produtos)
Product.create!(
  business: biz_estetica,
  category: cat_beleza,
  name: "Kit Shampoo e Máscara Nutrição Profissional 500ml",
  description: "Tratamento intensivo para cabelos ressecados ou quimicamente tratados, enriquecido com óleo de argan e queratina.",
  price: 120.00,
  promotional_price: 99.00,
  available: true,
  featured: true
)

Product.create!(
  business: biz_estetica,
  category: cat_beleza,
  name: "Sérum Facial Anti-idade com Vitamina C Pura 30ml",
  description: "Fórmula de alta potência antioxidante para uniformizar o tom da pele, estimular o colágeno e dar luminosidade.",
  price: 85.00,
  available: true,
  featured: false
)

puts "== Criando 12 Serviços... =="
# Clima Sul (3 serviços)
serv_ar_limpeza = Service.create!(
  business: biz_clima,
  category: cat_clima,
  name: "Limpeza e Higienização de Ar-condicionado Split",
  description: "Higienização completa da unidade interna (evaporadora) e externa (condensadora) com produtos bactericidas específicos. Melhora a qualidade do ar e reduz o consumo elétrico.",
  starting_price: 150.00,
  price_description: "A partir de R$ 150,00",
  home_service: true,
  featured: true,
  active: true
)

Service.create!(
  business: biz_clima,
  category: cat_clima,
  name: "Instalação Técnica de Ar-condicionado Split até 18.000 BTUs",
  description: "Instalação profissional com teste de estanqueidade em nitrogênio, vácuo na tubulação e suporte incluso para residências e comércios.",
  starting_price: 380.00,
  price_description: "A partir de R$ 380,00",
  home_service: true,
  featured: true,
  active: true
)

Service.create!(
  business: biz_clima,
  category: cat_clima,
  name: "Carga de Gás Ecológico R410A / R32 para Ar-condicionado",
  description: "Verificação de vazamentos com manifold digital, correção de conexões e recarga completa com fluido refrigerante ecológico original.",
  starting_price: 220.00,
  price_description: "A partir de R$ 220,00",
  home_service: true,
  featured: false,
  active: true
)

# Tech House (3 serviços)
Service.create!(
  business: biz_tech,
  category: cat_info,
  name: "Manutenção e Formatação de Notebook com Limpeza Física",
  description: "Revisão geral de hardware e software, troca de pasta térmica de alto desempenho, limpeza de coolers e reinstalação de sistema operacional.",
  starting_price: 120.00,
  price_description: "A partir de R$ 120,00",
  home_service: false,
  featured: true,
  active: true
)

Service.create!(
  business: biz_tech,
  category: cat_info,
  name: "Troca de Tela e Bateria de Celular e Smartphone",
  description: "Substituição rápida de displays quebrados e baterias estufadas com peças originais e garantia de 90 dias no Centro de Teixeira.",
  starting_price: 160.00,
  price_description: "Sob consulta conforme o modelo",
  home_service: false,
  featured: false,
  active: true
)

Service.create!(
  business: biz_tech,
  category: cat_info,
  name: "Montagem de PC Gamer e Cable Management Profissional",
  description: "Montagem técnica cuidadosa com organização impecável de fios, instalação do fluxo de ar otimizado e testes de estabilidade sob carga.",
  starting_price: 200.00,
  price_description: "A partir de R$ 200,00",
  home_service: false,
  featured: false,
  active: true
)

# Casa & Cia (2 serviços)
serv_eletricista = Service.create!(
  business: biz_casa,
  category: cat_eletrica,
  name: "Eletricista Residencial e Comercial em Geral",
  description: "Instalação de tomadas, disjuntores, chuveiros, ventiladores de teto, luminárias LED e adequação de quadros de distribuição em Teixeira de Freitas.",
  starting_price: 90.00,
  price_description: "Visita técnica a partir de R$ 90,00",
  home_service: true,
  featured: true,
  active: true
)

Service.create!(
  business: biz_casa,
  category: cat_eletrica,
  name: "Instalação de Padrão de Entrada de Energia Coelba",
  description: "Montagem e instalação de poste e caixa de medição monofásica ou trifásica dentro das normas técnicas da concessionária de energia da Bahia.",
  starting_price: 450.00,
  price_description: "A partir de R$ 450,00",
  home_service: true,
  featured: false,
  active: true
)

# Auto Center Sul (3 serviços)
Service.create!(
  business: biz_auto,
  category: cat_auto,
  name: "Troca de Óleo e Filtros com Revisão de 20 Itens",
  description: "Troca de óleo de motor conforme especificação da montadora (sintético/semissintético), troca de filtros de ar/óleo e checklist de segurança.",
  starting_price: 180.00,
  price_description: "Kits a partir de R$ 180,00",
  home_service: false,
  featured: true,
  active: true
)

Service.create!(
  business: biz_auto,
  category: cat_auto,
  name: "Alinhamento 3D e Balanceamento Computadorizado de Rodas",
  description: "Ajuste preciso da geometria de suspensão com câmeras 3D e balanceamento de 4 rodas para maior segurança e durabilidade dos pneus.",
  starting_price: 100.00,
  price_description: "A partir de R$ 100,00",
  home_service: false,
  featured: false,
  active: true
)

Service.create!(
  business: biz_auto,
  category: cat_auto,
  name: "Higienização de Ar-condicionado Automotivo com Oxi-sanitização",
  description: "Eliminação profunda de ácaros, fungos, vírus e odores desagradáveis no sistema de ventilação do veículo com gerador de ozônio.",
  starting_price: 80.00,
  price_description: "R$ 80,00",
  home_service: false,
  featured: false,
  active: true
)

# Pet Feliz (1 serviço)
Service.create!(
  business: biz_pet,
  category: cat_pet,
  name: "Banho e Tosa com Hidratação e Leva-e-Traz",
  description: "Banho quentinho com produtos hipoalergênicos, tosa na máquina ou tesoura, corte de unhas, limpeza de ouvidos e táxi dog em toda a cidade.",
  starting_price: 65.00,
  price_description: "A partir de R$ 65,00",
  home_service: true,
  featured: true,
  active: true
)

puts "== Criando Leads / Contatos Simulados... =="
Lead.create!(
  business: biz_tech,
  product: prod_copo,
  lead_type: "whatsapp_click",
  name: "Juliana Santos",
  phone: "73988776655",
  message: "Olá, tem o copo térmico na cor preta a pronta entrega?"
)

Lead.create!(
  business: biz_clima,
  service: serv_ar_limpeza,
  lead_type: "whatsapp_click",
  name: "Marcelo Albuquerque",
  phone: "73988112233",
  message: "Gostaria de agendar a limpeza de 2 splits no bairro Centro."
)

Lead.create!(
  business: biz_casa,
  service: serv_eletricista,
  lead_type: "quote_request",
  name: "Fernando Lima",
  phone: "73981234567",
  message: "Preciso trocar a fiação do meu chuveiro e instalar 4 tomadas novas."
)

puts "== Seeds concluídos com sucesso! =="
puts "Total Usuários: #{User.count}"
puts "Total Categorias: #{Category.count}"
puts "Total Empresas: #{Business.count}"
puts "Total Produtos: #{Product.count}"
puts "Total Serviços: #{Service.count}"
puts "Total Leads: #{Lead.count}"
