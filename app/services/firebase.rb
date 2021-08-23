# https://github.com/spacialdb/fcm#usage
class Firebase
  ENABLED = Rails.configuration.settings[:firebase][:enabled]
  CLIENT ||= FCM.new(Rails.configuration.settings[:firebase][:server_key])

  def self.send_notification(notification, topic = nil)
    if ENABLED && topic
      topic = "#{Rails.configuration.settings[:firebase][:env]}-#{topic}"
      CLIENT.send_to_topic(topic, notification)
    else
      Rails.logger.info "[FIREBASE]: #{notification} #{topic}"
    end
  end

  def self.send_by_registration_ids registration_ids, notification
    if ENABLED
      CLIENT.send(registration_ids, notification)
    else
      Rails.logger.info "[FIREBASE]: #{notification}"
    end
  end

  def self.ping registration_ids
    CLIENT.send registration_ids, {
      notification: {
        title: "Title",
        body: "Body",
        android_channel_id: "updatesChannelId"
      }
    }
  end
end
