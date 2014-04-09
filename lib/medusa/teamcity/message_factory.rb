module Rake
  module TeamCity
    module MessageFactory

      protected

      def self.create_message(msg_attrs = {})
        # message type:
        message_name = msg_attrs.delete(:message_name)

        # optional body
        message_text = msg_attrs[:message_text]

        # if diagnostic info is null - don't pass it'
        diagnostic = msg_attrs[:diagnosticInfo]
        unless diagnostic
          msg_attrs.delete(:diagnosticInfo)
        end

        if message_text.nil?
          # mock some attrs
          [:details, :errorDetails, :locationHint, :duration].each do |key|
            if msg_attrs[key].nil?
              # if key is nil - don't include in msg attrs
              msg_attrs.delete(key) if MOCK_ATTRIBUTES_VALUES[key][:remove_empty]
            else
              # if not nil & debug mode - mock it
              msg_attrs[key] = MOCK_ATTRIBUTES_VALUES[key][:value] if MOCK_ATTRIBUTES_VALUES[key][:enabled]
            end
          end

          # add auto timestamp
          msg_attrs[:timestamp] ||= convert_time_to_java_simple_date(Time.now)

          # add flowid
          msg_attrs[:flowId] ||= "pid_#{Process.pid}"

          # message args
          message_args = msg_attrs.map { |k, v| "#{k.to_s} = '#{v.nil? ? "" : replace_escaped_symbols(v.to_s)}'" }.join(" ")
        else
          message_args = "'#{message_text}'"
        end

        "##teamcity[#{message_name}#{message_args.empty? ? '' : " #{message_args}"}]"
      end
    end
  end
end
