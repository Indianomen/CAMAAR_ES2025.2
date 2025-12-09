module Admin
  class BaseController < Admin::ApplicationController
    layout "admin"

    before_action :authenticate_administrador!
  end
end
