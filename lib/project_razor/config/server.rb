require "socket"
require "logger"

# This class represents the ProjectRazor configuration. It is stored persistently in
# './conf/razor_server.conf' and editing by the user
module ProjectRazor
  module Config
    class Server

      include(ProjectRazor::Utility)

      # (Symbol) representing the database plugin mode to use defaults to (:mongo)

      attr_accessor :image_svc_host

      attr_accessor :persist_mode
      attr_accessor :persist_host
      attr_accessor :persist_port
      attr_accessor :persist_timeout

      attr_accessor :admin_port
      attr_accessor :api_port
      attr_accessor :image_svc_port
      attr_accessor :mk_tce_mirror_port

      attr_accessor :mk_checkin_interval
      attr_accessor :mk_checkin_skew
      attr_accessor :mk_uri
      attr_accessor :mk_fact_excl_pattern
      attr_accessor :mk_register_path # : /project_razor/api/node/register
      attr_accessor :mk_checkin_path # checkin: /project_razor/api/node/checkin

      # mk_log_level should be 'Logger::FATAL', 'Logger::ERROR', 'Logger::WARN',
      # 'Logger::INFO', or 'Logger::DEBUG' (default is 'Logger::ERROR')
      attr_accessor :mk_log_level
      attr_accessor :mk_tce_mirror_uri
      attr_accessor :mk_tce_install_list_uri
      attr_accessor :mk_kmod_install_list_uri

      attr_accessor :image_svc_path

      attr_accessor :register_timeout
      attr_accessor :force_mk_uuid

      attr_accessor :default_ipmi_power_state
      attr_accessor :default_ipmi_username
      attr_accessor :default_ipmi_password

      attr_accessor :daemon_min_cycle_time

      attr_accessor :node_expire_timeout

      # init
      def initialize
        use_defaults
      end

      # Set defaults
      def use_defaults
        @image_svc_host = get_an_ip
        @persist_mode = :mongo
        @persist_host = "127.0.0.1"
        @persist_port = 27017
        @persist_timeout = 10

        @admin_port = 8025
        @api_port = 8026
        @image_svc_port = 8027
        @mk_tce_mirror_port = 2157

        @mk_checkin_interval = 60
        @mk_checkin_skew = 5
        @mk_uri = "http://#{get_an_ip}:#{@api_port}"
        @mk_register_path = "/razor/api/node/register"
        @mk_checkin_path = "/razor/api/node/checkin"
        fact_excl_pattern_array = ["(^facter.*$)", "(^id$)", "(^kernel.*$)", "(^memoryfree$)",
                                   "(^operating.*$)", "(^osfamily$)", "(^path$)", "(^ps$)",
                                   "(^ruby.*$)", "(^selinux$)", "(^ssh.*$)", "(^swap.*$)",
                                   "(^timezone$)", "(^uniqueid$)", "(^uptime.*$)","(.*json_str$)"]
        @mk_fact_excl_pattern = fact_excl_pattern_array.join("|")
        @mk_log_level = "Logger::ERROR"
        @mk_tce_mirror_uri = "http://localhost:#{@mk_tce_mirror_port}/tinycorelinux"
        @mk_tce_install_list_uri = @mk_tce_mirror_uri + "/tce-install-list"
        @mk_kmod_install_list_uri = @mk_tce_mirror_uri + "/kmod-install-list"

        @image_svc_path = $img_svc_path

        @register_timeout = 120
        @force_mk_uuid = ""

        @default_ipmi_power_state = 'off'
        @default_ipmi_username = 'ipmi_user'
        @default_ipmi_password = 'ipmi_password'

        @daemon_min_cycle_time = 30

        # this is the default value for the amount of time (in seconds) that
        # is allowed to pass before a node is removed from the system.  If the
        # node has not checked in for this long, it'll be removed
        @node_expire_timeout = 300

      end

      def get_client_config_hash
        config_hash = self.to_hash
        client_config_hash = {}
        config_hash.each_pair do
        |k,v|
          if k.start_with?("@mk_")
            client_config_hash[k.sub("@","")] = v
          end
        end
        client_config_hash
      end

      def get_an_ip
        # look for the first private IP address on the Razor server
        # to use in the configuration file
        ip = Socket.ip_address_list.detect { |intf| intf.ipv4_private? }
        # if the previous request returned nil, then the Razor server
        # has no private IP addresses, so look for a public IP address
        # to use instead
        ip = Socket.ip_address_list.detect { |intf| intf.ipv4? } unless ip
        # if the "ip" value is still nil, default to the localhost
        ip = '127.0.0.1' unless ip
        ip.ip_address.force_encoding("UTF-8")
      end

    end
  end
end
