module V1
  class MainController < ApplicationController
    #      def index
    #               data =  Net::Ping::External.new("10.2.51.21").ping?
    #               json_response(status: "true", message: data)
    #            end
    def index
      endpoints = [
        '*****************************************************************',
        'Endpoints :',
        'Todas las rutas comprenden solo a vistas informativas (Method GET)',
        '*****************************************************************',
        'El parametro page corresponde a la paginación y aumenta de 10 en 10',
        '*****************************************************************',
        '---Nethogs---',
        'Muestra todo el registro de datos :',
        'GET /v1/nethogs/index?page=1',
        'Busca una ip de destino x server : ',
        'GET /v1/nethogs/search_nethogs_traffic?ip_destino=IP_DESTINO&hostname_server=HOSTNAME_SERVER',
        '*****************************************************************',
        '---IpTraf---',
        'Muestra todo el registro de datos :',
        'GET v1/iptraff/index?page=1',
        'Busca una ip de destino x server : ',
        'GET v1/iptraff/search_iptraf_traffic?ip_address_destino=IP_DESTINO&hostname_server=HOSTNAME_SERVER',
        '*****************************************************************',
        '---Httpd_logs---',
        'Muestra todo el registro de datos :',
        'GET v1/httpd/index?page=1',
        'Busca un usuario x server : ',
        'GET v1/httpd/search_log_httpd?domain_name=Domainname&hostname_server=HOSTNAME_SERVER',
        '*****************************************************************'
      ]
      json_response(status: 200, message: endpoints)
    end
  end
end
