module CloudwatchSync
  class Client
    class << self
      attr_accessor :source, :aws_access_key_id, :aws_secret_access_key, :aws_region

      def configure
        yield self if block_given?
        raise StandardError, "source file not found" if self.source.nil?

        @parsed_source = YAML.load_file(self.source)
      end

      def sync(srv = nil)
        alarms = @parsed_source['nodes']
        srvs = if srv.nil?
                    alarms.keys
                  else
                    [srv]
                  end

        srvs.each do |srv|
          klass = "CloudwatchSync::Agent::#{srv.camelize}".constantize
          instance = klass.new(@parsed_source['metrics'][srv], @parsed_source['nodes'][srv], @parsed_source['alarm_actions'])
          instance.build_alarm_options.each do |alarm_option|
            cloudwatch.client.put_metric_alarm(alarm_option)
          end
        end
      end

      def list(options = {})
        cloudwatch.alarms.each do |alarm|
          puts <<-ALARM
          name: #{alarm.name}
          alarm_actions: #{alarm.alarm_actions}
          namespace: #{alarm.namespace}
          comparison_operator: #{alarm.comparison_operator}
          dimensions: #{alarm.dimensions}
          evaluation_periods: #{alarm.evaluation_periods}
          period: #{alarm.period}
          threshold: #{alarm.threshold}

          ALARM
        end
      end

      def cloudwatch
        @cloudwatch ||= begin
                                      AWS.config(access_key_id: self.aws_access_key_id, secret_access_key: self.aws_secret_access_key , region: self.aws_region)
                                      AWS::CloudWatch.new
                                    end
      end
    end

  end
end