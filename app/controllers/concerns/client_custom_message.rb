# Message format recognized by mobile client to display popup messages
module ClientCustomMessage
  def compose_msg(msg_type, options = {})
    case msg_type
    when :unauthorized
      {
        custom_message: {
          title: "Unauthorized Access",
          icon: "exclamation-circle",
          icon_type: 2,
          content: "Your session has expired.\nPlease login again.",
          button: "Okay",
          is_forced_logout: true
        }
      }
    when :error
      # @options: Directly feed the message string as arg
      # Example:
      # ```
      # compose_msg(:error, "Something went wrong!")
      # ```
      {
        custom_message: {
          title: "",
          icon: "exclamation-circle",
          icon_type: 2,
          content: options,
          button: "Okay"
        }
      }
    when :custom
      {
        custom_message: {
          title: options[:title] || "",
          icon: options[:icon] || "exclamation-circle",
          icon_type: options[:icon_type] || 2,
          content: options[:content] || "",
          button: options[:button] || "Okay"
        }
      }
    when 404
      {
        custom_message: {
          title: "",
          icon: "exclamation-circle",
          icon_type: 2,
          content: "Resource not found!",
          button: "Okay"
        }
      }
    when 500
      {
        custom_message: {
          title: "",
          icon: "exclamation-circle",
          icon_type: 2,
          content: "Something went wrong! Please try again later.",
          button: "Okay"
        }
      }
    end
  end
end
