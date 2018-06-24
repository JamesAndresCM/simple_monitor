class ApacheLogTraffic
  include Mongoid::Document
  field :domain_name_or_ip, type: String
  field :method_name, type: String
  field :fecha_log_httpd, type: DateTime
  field :hostname_server, type: String
  field :path_url, type: String


  scope :index_httpd, -> { all.order('fecha_log_httpd desc') }

  def self.search_log_apache(domain_name_or_ip, hostname_server)
    collection.find(
      'fecha_log_httpd' => {
        '$gt' => Date.today,
        '$lt' => Date.tomorrow
      },
      'domain_name_or_ip' => domain_name_or_ip.to_s,
      'hostname_server' => hostname_server.to_s,
    ).sort('fecha_log_httpd' => -1)
  end

end
