require 'slack-notifier'

# Exposes slack notifier with defaults config to easily
# configure the slack notifier among application environments.
# When slacker is disabled, it'll fallback to `Rails.logger.debug`
#
# How to use:
# ```
#   SlackNotifier = Slacker.new(notifications: <settings>)
#   SlackNotifier.ping(:notifications, 'Hello world!')
# ```
class Slacker
  attr_reader :enabled, :tag

  def initialize(settings)
    @notifiers = {}

    settings.each do |name, config|
      @notifiers[name.to_sym] = {}
      @notifiers[name.to_sym][:enabled] = config[:enabled]
      @notifiers[name.to_sym][:tag] = "[`#{Rails.env}`][`#{Rails.configuration.settings[:slack_notifier][:id]}`]\n\n"
      @notifiers[name.to_sym][:notifier] = build_notifier(config[:channel], config[:webhook_url]) if config[:enabled]
    end
  end

  def ping(name, content)
    _ping(name, content)
  end

  private

  def _ping(name, content)
    notifier = @notifiers[name.to_sym]

    if notifier[:enabled]
      notifier[:notifier].ping("#{notifier[:tag]}#{content}")
    else
      Rails.logger.debug("#{name}: #{content.to_s.gsub("\n", ' ')}")
    end
  end

  def build_notifier(channel, webhook_url)
    # https://github.com/stevenosloan/slack-notifier#setting-defaults
    Slack::Notifier.new webhook_url do
      defaults channel: channel
    end
  end
end

# Constant for usage
SlackNotifier = Slacker.new(sms: Rails.configuration.settings[:slack_notifier][:sms])
