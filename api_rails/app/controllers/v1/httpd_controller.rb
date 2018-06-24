module V1
  # controller http
  class HttpdController < ApplicationController
    require 'will_paginate/array'
    before_action :http_params, only: [:search_log_httpd]
    # http://localhost:3000/v1/httpd/index?page=2

    def index
      all_log_httpd = ApacheLogTraffic.index_httpd.paginate(page: params[:page],
                                                            per_page: 10)
      if all_log_httpd.blank?
        json_response(status: 404, message: 'data httpd not found')
      else
        json_response(status: 200, data: all_log_httpd)
      end
    end

    # http://localhost:3000/v1/httpd/search_log_httpd?domain_name=foo&hostname_server=bar&page=1
    def search_log_httpd
      domain_name = params[:domain_name_or_ip]
      hostname_server = params[:hostname_server]

      httpd_log = ApacheLogTraffic.search_log_apache(domain_name,
                                                     hostname_server)
      data_apache = []
      httpd_log.each { |data| data_apache << data }

      final_data = data_apache.paginate(page: params[:page], per_page: 10)
      if domain_name.blank?
        json_response(status: 400, message: 'domain_name_or_ip required')
      elsif hostname_server.blank?
        json_response(status: 400, message: 'hostname_server required')
        return false
      else
        httpd_log.first.blank? ? json_response(status: 404, message: 'records httpd not found') : json_response(status: 200, data: final_data)
      end
    end

    private

    def http_params
      params.permit(:domain_name_or_ip, :hostname_server)
    end
  end
end
