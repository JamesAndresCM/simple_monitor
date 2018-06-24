class NethogsTraffic
  include Mongoid::Document
  field :ip_origen, type: String
  field :port_destino, type: Integer
  field :paquetes_enviados, type: Float
  field :hostname_server, type: String
  field :paquetes_recibidos, type: Float
  field :port_origen, type: Integer
  field :fecha_log_nethog, type: DateTime
  field :ip_address_destino, type: String

  scope :index_nethogs, -> { all.order('fecha_log_nethog desc') }

  def self.search_nethogs_traffic_per_ip(ip_destino, hostname_server)
    collection.aggregate([
                           { '$match' => {
                             'ip_address_destino' => ip_destino.to_s,
                             'hostname_server' => hostname_server.to_s,
                             'fecha_log_nethog' => {
                               '$gt' => Date.today.to_time,
                               '$lt' => Date.tomorrow.to_time
                             }
                           } },
                           {
                             '$group' => {
                               '_id' => '$hostname_server',
                               'ip_origen' => {
                                 '$first' => '$ip_origen'
                               },
                               'port_origen' => {
                                 '$first' => '$port_origen'
                               },
                               'ip_address_destino' => {
                                 '$first' => '$ip_address_destino'
                               },
                               'port_destino' => {
                                 '$first' => '$port_destino'
                               },
                               'fecha_log_nethog' => {
                                 '$first' => '$fecha_log_nethog'
                               },
                               'total_peticiones' => {
                                 '$sum' => 1
                               },
                               'total_paquetes_enviados' => {
                                 '$sum' => '$paquetes_enviados'
                               },
                               'total_paquetes_recibidos' => {
                                 '$sum' => '$paquetes_recibidos'
                               }
                             }
                           }
                         ])
  end
end
