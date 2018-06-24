#!/usr/bin/env ruby

require 'socket'
require 'logger'
require 'etc'
require 'open3'
require 'date'

require_relative 'system/command'
require_relative 'system/connmongo'

TIEMPO = Time.now

HORA_ACTUAL_MENOS_5_MINUTOS = TIEMPO - 5 * 60

HORA_ACTUAL = Time.now.utc.localtime

HOSTNAME = Socket.gethostname

def add_log_files(add)
  logs_network = Logger.new('/var/log/logs_network.log', 'monthly')
  logs_network.info(add)
end

def return_username(uid_user)
  Etc.getpwuid(uid_user)[0]
rescue StandardError => e
  user_not_found = "#{e} usuario #{uid_user} no existe"
  add_log_files(user_not_found)
end

def check_file_exists(archivo)
  File.delete(archivo) if File.exist?(archivo)
end

def iptraf_log
  #interfaz = ENV['interfaz_de_red']
  interfaz = "eth0"
  log_iptraf = '/var/log/iptraf_traffic.log'

  check_file_exists(log_iptraf)

  Command.execute("/bin/bash -ic \"{ /usr/sbin/iptraf-ng -f -B -i #{interfaz} -t 1 -L "+ log_iptraf +"; } | { sleep 60; }\" &> /dev/nul")
  file = File.open(log_iptraf, 'r')

  file.drop(1).each do |line|
    line = line.delete(';')
    next if line =~ /^[\s]*$\n/ && line =~ /stopped/
    next unless line =~ /TCP|ICMP$|UDP/
    lines = line.split
    protocol = lines[5]
    ip_destino = lines[12].partition(':')[0]
    ip_destino_port = lines[12].partition(':')[2]
    bytes_ip = lines[7]
    ip_origen = lines[10].partition(':')[0]
    ip_origen_port = lines[10].partition(':')[2]
    db = ConnMongo.new

    begin
      db.insert_iptraff(HOSTNAME, ip_origen,
                        ip_origen_port,
                        ip_destino,
                        ip_destino_port,
                        bytes_ip,
                        protocol, HORA_ACTUAL)
    rescue StandardError => e
      error_iptraff = "#{e} no se ha podido guardar el
                        documento iptraff_traffic"
      add_log_files(error_iptraff)
    end
  end
end

def nethogs_logs
  log_nethog = '/var/log/nethog_traffic.log'

  # check_file_exists(log_nethog)

  execute_nethog = Command.execute("/bin/bash -ic \"{ /usr/sbin/nethogs -t &> "+ log_nethog +";} | { sleep 40; pkill nethogs; }\" &> /dev/null")

  if execute_nethog.exit_status.eql?(1)
    error_nethogs_execute = 'nethogs no se ha podido ejecutar'
    add_log_files(error_nethogs_execute)
    exit(0)
  else
    file = File.open(log_nethog, 'r')
    file.each do |line|
      next if line.start_with?('unknown')
      next unless line[0] =~ /[[:digit:]]/
      lines = line.gsub('Refreshing:', '').split
      origen = lines[0].split('-')[0]
      destino = lines[0].split('-')[1]

      ip_origen = origen.partition(':')[0]
      ip_origen_port = origen.partition(':')[2]

      ip_destino = destino.partition(':')[0]
      ip_destino_port = destino.partition(':')[2].split('/')[0]
      sent = lines[1]
      received = lines[2]
      db = ConnMongo.new

      begin
        db.insert_nethogs(HOSTNAME, ip_origen,
                          ip_origen_port,
                          ip_destino,
                          ip_destino_port,
                          sent,
                          received, HORA_ACTUAL)
      rescue StandardError => e
        error_nethogs = "#{e} no se ha podido guardar el
                        documento nethogs_traffic"
        add_log_files(error_nethogs)
      end
    end
  end
end

def search_log_http
  log_apache = '/var/log/httpd/access_log'

  file = File.open(log_apache, 'r')
  file.each do |line|
    lines = line.split
    domain_or_ip = lines[0]
    date = lines[3].sub('[', '')
    fecha = date.partition(':')[0]
    fecha = Date.parse(fecha).strftime('%d/%m/%Y')
    hora = date.partition(':')[2]
    fecha_log = "#{fecha} #{hora}"
    path = lines[6]
    method_http = lines[5].sub('"', '')

    compare_date = lines[3].sub('[', '')[0..-4]
    today = HORA_ACTUAL_MENOS_5_MINUTOS.strftime('%d/%b/%Y:%H:%M')
    fecha_log = DateTime.strptime(fecha_log, '%d/%m/%Y %H:%M:%S')
    # p HORA_ACTUAL
    next unless compare_date >= today
    db = ConnMongo.new
    begin
      db.insert_httpd(HOSTNAME, domain_or_ip, path, method_http, fecha_log)
    rescue StandardError => e
      error_http = "#{e} no se ha podido guardar el documento http_traffic"
      add_log_files(error_http)
    end
  end
end


processname = __FILE__
check_count = Command.execute("pgrep -c #{processname}").stdout

if check_count.to_i > 2
  errpr_execute = 'paso una hora saliendo'
  add_log_files(errpr_execute)
  exit(0)
else
  nethogs_logs
  search_log_http
  iptraf_log
end
