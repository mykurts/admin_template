class  AdminController < ActionController::Base
  
  layout 'admin/pages'
  protect_from_forgery prepend: true
  before_action :authenticate_administrator!
  
end