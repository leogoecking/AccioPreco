# Pagy configuration for Accio Preço
require "pagy"
require "pagy/extras/overflow"

Pagy::DEFAULT[:limit] = 12
Pagy::DEFAULT[:items] = 12
Pagy::DEFAULT[:overflow] = :empty_page
