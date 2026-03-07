class PagesController < ApplicationController
  skip_before_action :authenticate_request!, only: [ :api ]

  def api
  end
end
