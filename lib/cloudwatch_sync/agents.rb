module CloudwatchSync
  module Agent
    class Base

      attr_accessor :metrics, :nodes, :alarm_actions

      def initialize(metrics, nodes, alarm_actions)
        self.metrics = metrics
        self.nodes = nodes
        self.alarm_actions = alarm_actions
      end

      def available_nodes
        self.nodes
      end

      def build_alarm_name(node, alarm_name)
        "aws%s-%s-%s" % ([namespace.downcase, node['name'], alarm_name])
      end

      def fetch_metric_options(node, alarm_name)
        raise StandardError, "not found specified alarm: #{alarm_name}" unless self.metrics.key?(alarm_name)

        options =  {
          namespace: "AWS/#{namespace}",
          alarm_name: build_alarm_name(node, alarm_name),
          alarm_description: 'Created from Batch',
          actions_enabled: true,
          dimensions: build_dimensions(node)
        }.merge(self.metrics[alarm_name])

        if (alarm_actions_type = options.delete('alarm_actions_type')).present?
          Array.wrap(alarm_actions_type).each do |action_type|
            options.merge!(alarm_actions: self.alarm_actions[action_type])
          end
        end
        options
      end

      def build_alarm_options
        available_nodes.map do |node|
          puts "alarm: #{node.inspect}"
          node['metrics'].map do |alarm_name|
            fetch_metric_options(node, alarm_name)
          end
        end.flatten
      end
    end

    class Ec2 < Base
      def namespace
        'EC2'
      end

      def build_dimensions(node)
        [ { name: "InstanceId", value: node['instance_id'] } ]
      end

      def available_nodes
        self.nodes.dup.map do |node|
          node_name = node.delete('name')
          instances = ec2_client.instances.filter('tag:Name', node_name)
          live_nodes = []
          instances.each do |i|
            next if ![:running, :stopped].include?(i.status)
            live_nodes << i
          end

          live_nodes.map do |live_node|
            new_node = node.dup
            new_node['name'] = live_node.tags.Name
            new_node['instance_id'] = live_node.id
            new_node
          end
        end.flatten
      end

      private

      def ec2_client
        @ec2_client ||= AWS::EC2.new
      end
    end

    class Rds < Base
      def namespace
        'RDS'
      end

      def build_dimensions(node)
        [{ name: "DBInstanceIdentifier", value: node['name']}]
      end
    end

    class Elb < Base
      def namespace
       'ELB'
      end

      def build_dimensions(node)
        [{ name: "LoadBalancerName", value: node['name']}]
      end
    end


    class ElastiCache < Base
      def namespace
       'ElastiCache'
      end

      def build_dimensions(node)
        [{ name: 'CacheClusterId', value: node['name']}, { name: 'CacheNodeId', value: node['cluster_node_id']} ]
      end
    end
  end
end