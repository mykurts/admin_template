module ApplicationHelper

  def sidebar_class type, actions, is_parent_menu=false, children_controllers=[]
    if is_parent_menu
      children_controllers.include?(controller_name) ? "menu-item-active menu-item-open" : ""
    else
      type == controller_name && actions.include?(action_name) ? "menu-item-active" : ""
    end
  end

  def header_title
    title = case controller_name
    when "pages"
      "Dashboard"
    end
  end


  def association_form form, association, type='new'

    new_object = form.object.send(association).klass.new
    id = new_object.object_id
    
    # fix me, write association cases here

    fields = form.fields_for(association, new_object, child_index: id) do |builder, |
      render(partial, form: builder, action_name: action_name, index: id )
    end

    return {id: id, fields: fields.gsub("\n", "")}
  end
  

end
