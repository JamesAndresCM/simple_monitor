class IptrafTraffic
  include Mongoid::Document
  field :ip_destino, type: String
  field :ip_origen, type: String
  field :port_destino, type: Integer
  field :nombre_protocolo, type: String
  field :hostname_server, type: String
  field :bytes_enviados, type: Integer
  field :log_insert, type: DateTime
  field :port_origen, type: String

  scope :index_iptraf, -> { all.order('log_insert desc') }

  def self.traffic_iptraf_per_ip(ip_address_destino, hostname_server)
    collection.aggregate([{
                           '$match' => {
                             'ip_destino' => ip_address_destino.to_s,
                             'hostname_server' => hostname_server.to_s,
                             'log_insert' => {
                               '$gt' => Date.today.to_time,
                               '$lt' => Date.tomorrow.to_time
                             }
                           }
                         },
                          {
                            '$group' =>
                               {
                                 '_id' => '$_id',
                                 'ip_origen' => {
                                   '$first' => '$ip_origen'
                                 },
                                 'port_origen' => {
                                   '$first' => '$port_origen'
                                 },
                                 'ip_destino' => {
                                   '$first' => '$ip_destino'
                                 },
                                 'port_destino' => {
                                   '$first' => '$port_destino'
                                 },
                                 'protocolo' => {
                                   '$first' => '$nombre_protocolo'
                                 },
                                 'fecha_registro' => {
                                   '$first' => '$log_insert'
                                 },
                                 'hostname_server' => {
                                   '$first' => '$hostname_server'
                                 },
                                 'total_request' =>
                                   { '$sum' => 1 },
                                 'total_bytes' =>
                                     {
                                       '$sum' =>
                                          '$bytes_enviados'
                                     }
                               }
                          }])
    end
end
