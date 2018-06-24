module V1
  # controller iptraff
  class IptraffController < ApplicationController
    require 'resolv'
    before_action :iptraff_params, only: [:search_iptraf_traffic]

    # http://localhost:3000/v1/iptraff/index?page=1
    def index
      all_iptraf_traffic = IptrafTraffic.index_iptraf.paginate(page: params[:page], per_page: 10)
      if all_iptraf_traffic.blank?
        json_response(status: 404, message: 'data iptraff not found')
      else
        json_response(status: 200, data: all_iptraf_traffic)
      end
    end

    # http://localhost:3000/v1/iptraff/search_iptraf_traffic?ip_address_destino=foo&hostname_server=bar
    def search_iptraf_traffic
      ip_address_destino = params[:ip_address_destino]
      hostname_server = params[:hostname_server]

      iptraff = IptrafTraffic.traffic_iptraf_per_ip(ip_address_destino,
                                                    hostname_server)

      if ip_address_destino.blank?
        json_response(status: 400, message: 'ip_address_destino required')
      elsif hostname_server.blank?
        json_response(status: 400, message: 'hostname_server required')
        return false
      elsif ip_address_destino !~ Resolv::IPv4::Regex
        json_response(status: 400, message: 'error not valid ip_address')
      else
        iptraff.first.blank? ? json_response(status: 404, message: 'records iptraff not found') : json_response(status: 200, data: iptraff)
      end
    end

    private

    def iptraff_params
      params.permit(:ip_address_destino, :hostname_server)
    end
  end
end
