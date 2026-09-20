class SearchService
  MAX_QUERY_LENGTH = 100
  MAX_WORDS = 8

  attr_reader :query, :type, :category_slug, :category, :available_only, :home_service_only

  def initialize(params = {})
    @query = params[:q].to_s.strip.slice(0, MAX_QUERY_LENGTH)
    @type = params[:type].presence || "todos"
    @category_slug = params[:category].presence
    @category = Category.find_by(slug: @category_slug) if @category_slug.present?
    @available_only = params[:available].present? ? (params[:available] == "1" || params[:available] == "true") : true
    @home_service_only = params[:home_service] == "1" || params[:home_service] == "true"
  end

  def call
    {
      query: query,
      type: type,
      category: category,
      products: products_scope,
      services: services_scope,
      businesses: businesses_scope,
      counts: {
        products: products_count,
        services: services_count,
        businesses: businesses_count,
        total: total_count
      }
    }
  end

  def products_scope
    @products_scope ||= build_products_scope
  end

  def services_scope
    @services_scope ||= build_services_scope
  end

  def businesses_scope
    @businesses_scope ||= build_businesses_scope
  end

  def products_count
    @products_count ||= products_scope.count
  end

  def services_count
    @services_count ||= services_scope.count
  end

  def businesses_count
    @businesses_count ||= businesses_scope.count
  end

  def total_count
    products_count + services_count + businesses_count
  end

  def empty?
    total_count.zero?
  end

  private

  def words
    @words ||= query.gsub(/[^\p{Alnum}]+/, " ").split.first(MAX_WORDS)
  end

  def build_products_scope
    scope = Product.publicly_visible.includes(:business, :category, images_attachments: :blob)
    scope = scope.where(category_id: category.id) if category.present?

    if words.any?
      words.each do |word|
        pat = "%#{ActiveRecord::Base.sanitize_sql_like(word)}%"
        scope = scope.where(
          "unaccent(LOWER(products.name)) LIKE unaccent(LOWER(:pat)) OR " \
          "unaccent(LOWER(COALESCE(products.description, ''))) LIKE unaccent(LOWER(:pat))",
          pat: pat
        )
      end

      exact_prefix = "#{ActiveRecord::Base.sanitize_sql_like(query)}%"
      scope = scope.order(
        Arel.sql(
          ActiveRecord::Base.sanitize_sql_array([
            "CASE WHEN unaccent(LOWER(products.name)) LIKE unaccent(LOWER(?)) THEN 0 ELSE 1 END ASC",
            exact_prefix
          ])
        ),
        featured: :desc,
        created_at: :desc
      )
    else
      scope = scope.order(featured: :desc, created_at: :desc)
    end

    scope
  end

  def build_services_scope
    scope = Service.publicly_visible.includes(:business, :category, images_attachments: :blob)
    scope = scope.where(category_id: category.id) if category.present?
    scope = scope.where(home_service: true) if home_service_only

    if words.any?
      words.each do |word|
        pat = "%#{ActiveRecord::Base.sanitize_sql_like(word)}%"
        scope = scope.where(
          "unaccent(LOWER(services.name)) LIKE unaccent(LOWER(:pat)) OR " \
          "unaccent(LOWER(COALESCE(services.description, ''))) LIKE unaccent(LOWER(:pat))",
          pat: pat
        )
      end

      exact_prefix = "#{ActiveRecord::Base.sanitize_sql_like(query)}%"
      scope = scope.order(
        Arel.sql(
          ActiveRecord::Base.sanitize_sql_array([
            "CASE WHEN unaccent(LOWER(services.name)) LIKE unaccent(LOWER(?)) THEN 0 ELSE 1 END ASC",
            exact_prefix
          ])
        ),
        featured: :desc,
        created_at: :desc
      )
    else
      scope = scope.order(featured: :desc, created_at: :desc)
    end

    scope
  end

  def build_businesses_scope
    scope = Business.where(active: true).includes(:user, logo_attachment: :blob)

    if category.present?
      biz_ids = (category.products.pluck(:business_id) + category.services.pluck(:business_id)).uniq
      scope = scope.where(id: biz_ids)
    end

    if words.any?
      words.each do |word|
        pat = "%#{ActiveRecord::Base.sanitize_sql_like(word)}%"
        scope = scope.where(
          "unaccent(LOWER(businesses.name)) LIKE unaccent(LOWER(:pat)) OR " \
          "unaccent(LOWER(COALESCE(businesses.description, ''))) LIKE unaccent(LOWER(:pat)) OR " \
          "unaccent(LOWER(COALESCE(businesses.neighborhood, ''))) LIKE unaccent(LOWER(:pat))",
          pat: pat
        )
      end

      exact_prefix = "#{ActiveRecord::Base.sanitize_sql_like(query)}%"
      scope = scope.order(
        Arel.sql(
          ActiveRecord::Base.sanitize_sql_array([
            "CASE WHEN unaccent(LOWER(businesses.name)) LIKE unaccent(LOWER(?)) THEN 0 ELSE 1 END ASC",
            exact_prefix
          ])
        ),
        verified: :desc,
        name: :asc
      )
    else
      scope = scope.order(verified: :desc, name: :asc)
    end

    scope
  end
end
