class ApplicationController < ActionController::Base
  include Authentication
  include Pagy::Backend

  rescue_from Pagy::VariableError do
    redirect_to url_for(request.query_parameters.merge(page: 1))
  end

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes
end
