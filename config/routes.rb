Rails.application.routes.draw do
  
  if ENV["RAILS_APP_TYPE"].present?
    draw ENV["RAILS_APP_TYPE"]
  else
    draw "API"
  end
end