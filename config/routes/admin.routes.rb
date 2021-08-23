
root to: 'admin/pages#dashboard'

devise_for :administrators, class_name: "Account::Administrator", path: '', controllers: {
  sessions:   "admin/sessions"
}, path_names: {
  sign_in: 'admins/login',
  sign_out: 'admins/logout'
}

namespace :admin do
  # start writing routes here

end