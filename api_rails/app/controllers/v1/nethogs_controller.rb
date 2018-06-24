module V1
  class NethogsController < ApplicationController
    require 'resolv'
    before_action :nethogs_params, only: [:search_nethogs_traffic]

    # http://localhost:3000/v1/nethogs/index?page=1
    def index
      all_nethogs = NethogsTraffic.index_nethogs.paginate(page: params[:page], per_page: 10)
      if all_nethogs.blank?
        json_response(status: 404, message: 'data nethogs not found')
      else
        json_response(status: 200, data: all_nethogs)
      end
    end

    # http://localhost:3000/v1/nethogs/search_nethogs_traffic?ip_destino=foo&hostname_server=bar
    def search_nethogs_traffic
      ip_destino = params[:ip_destino]
      hostname_server = params[:hostname_server]

      nethogs = NethogsTraffic.search_nethogs_traffic_per_ip(ip_destino, hostname_server)

      if ip_destino.blank?
        json_response(status: 400, message: 'param ip_destino required')
      elsif hostname_server.blank?
        json_response(status: 400, message: 'param hostname_server required')
        return false
      elsif ip_destino !~ Resolv::IPv4::Regex
        json_response(status: 400, message: 'error not valid ip_address')
      else
        nethogs.first.blank? ? json_response(status: 404, message: 'records nethogs not found') : json_response(status: 200, data: nethogs)
      end
    end

    private

    def nethogs_params
      params.permit(:ip_destino, :hostname_server)
    end
  end
end
