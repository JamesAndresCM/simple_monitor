#!/usr/bin/env ruby

require 'mongo'
Mongo::Logger.logger.level = Logger::INFO
# class connect mongodb
class ConnMongo
  def self.connect_mongo
    ip = ENV['MONGO_HOST']
    database_mongo = ENV['MONGO_DB']
    pass_mongo = ENV['PASSWD_MONGO']
    user_mongo = ENV['USER_MONGO']
    Mongo::Client.new([ip], database: database_mongo, user: user_mongo,
                            password: pass_mongo)
  rescue Mongo::Error::NoServerAvailable => e
    puts "#{e} Error de conexion..."
    exit(0)
  end

  DB_CONNECT = connect_mongo

  def insert_nethogs(hostname, ip_origen, ip_origen_port, ip_destino, ip_destino_port, sent, received, hora_actual)
    nethogs_traficc_db = DB_CONNECT[:nethogs_traffic]
    data = {
      hostname_server: hostname,
      ip_origen: ip_origen,
      port_origen: ip_origen_port,
      ip_address_destino: ip_destino,
      port_destino: ip_destino_port,
      paquetes_enviados: sent.to_f,
      paquetes_recibidos: received.to_f,
      fecha_log_nethog: hora_actual
    }
    nethogs_traficc_db.insert_one(data)
    DB_CONNECT.close
  end

  def insert_iptraff(hostname, ip_origen, ip_origen_port, ip_destino, ip_destino_port, bytes_ip, protocol, hora_actual)
    iptraf_traficc_db = DB_CONNECT[:iptraf_traffic]
    data = {
      hostname_server: hostname,
      ip_origen: ip_origen,
      port_origen: ip_origen_port,
      ip_destino: ip_destino,
      port_destino: ip_destino_port,
      bytes_enviados: bytes_ip.to_i,
      nombre_protocolo: protocol,
      log_insert: hora_actual
    }
    iptraf_traficc_db.insert_one(data)
    DB_CONNECT.close
  end

  def insert_httpd(hostname, domain_name, path, method_http, parse_date)
    apache_log_info_db = DB_CONNECT[:apache_log_traffic]
    data = {
      hostname_server: hostname,
      domain_name_or_ip: domain_name,
      path_url: path,
      method_name: method_http,
      fecha_log_httpd: parse_date
    }
    apache_log_info_db.insert_one(data)
    DB_CONNECT.close
  end
end
