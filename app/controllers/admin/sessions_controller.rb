class Admin::SessionsController < Devise::SessionsController
  layout 'admin/metronic/portal.less'

  def new
  end

  protected

    def auth_options
      { scope: resource_name, recall: 'admin/sessions#new' }
    end
end
