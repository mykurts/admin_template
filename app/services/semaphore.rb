# https://semaphore.co/docs
class Semaphore
  APIKEY = ENV['SEMAPHORE_API_KEY'] || 'fad14f8405a284041c840348ebd53848'
  SENDERNAME = ENV['SEMAPHORE_SENDERNAME'] || 'RideHero'

  # https://api.rubyonrails.org/classes/ActiveModel/Type/Boolean.html
  ENABLED = ENV['SEMAPHORE_ENABLED'] ? ActiveModel::Type::Boolean.new.cast(ENV['SEMAPHORE_ENABLED']) : true

  GLOBE_PREFIXES = %W{0817 0905 0906 0915 0916 0917 0926 0927 0935 0936 0937 0945 0953 0954 0955 0956 0965 0966 0967 0975 0976 0977 0978 0979 0994 0995 0996 0997}
  SMART_PREFIXES = %W{0907 0909 0910 0908 0918 0919 0912 0930 0938 0920 0921 0928 0946 0948 0950 0929 0939 0946 0947 0949 0951 0961 0998 0999}
  SUN_PREFIXES = %W{0922 0923 0924 0925 0931 0932 0933 0934 0940 0941 0942 0943 0973 0974}

  # https://semaphore.co/docs#sending_messages
  # Sending Messages
  # @message: String
  # @number: String
  #
  # Example:
  #
  # Semaphore.send_message(message: 'Hello world!', number: '+639123456789')
  # => #<Net::HTTPOK 200 OK readbody=true>
  #
  def self.send_message(message: nil, number: nil)
    unless ENABLED
      Rails.logger.debug("[Semaphore] #{number}: #{message}")
    else
      uri = URI('http://semaphore.co/api/v4/messages')
      http = Net::HTTP.new(uri.host, uri.port)

      request = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
      request.body = options(message, number).to_json

      response = http.request(request)
      true
    end
  rescue StandardError => e
    Rails.logger.error "[Semaphore] #{[e.message, e.backtrace]}"
    false
  end

  # https://semaphore.co/docs#bulk_messages
  # Bulk Messages
  # @message: String
  # @numbers: Array of Strings
  #
  # Example:
  #
  # Semaphore.bulk_messages(message: 'Hello world!', numbers: ['+639123456789', '+639123456780'])
  # => #<Net::HTTPOK 200 OK readbody=true>
  #
  def self.bulk_messages(message: nil, numbers: [])
    unless ENABLED
      Rails.logger.debug("[Semaphore] #{numbers}: #{message}")
    else
      uri = URI('http://semaphore.co/api/v4/messages')
      http = Net::HTTP.new(uri.host, uri.port)

      request = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
      request.body = options(message, format_numbers(numbers)).to_json

      response = http.request(request)
    end
  rescue StandardError => e
    Rails.logger.error "[Semaphore] #{[e.message, e.backtrace]}"

    false
  end

  # https://semaphore.co/docs#priority_messages
  # Priority Messages
  # def self.priority_message(message: nil, number: nil)
  # end

  def self.options(message, number)
    {
      apikey: APIKEY,
      sendername: SENDERNAME,
      number: number,
      message: message
    }
  end

  def self.format_numbers(numbers)
    numbers.join(',')
  end
end
