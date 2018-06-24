#!/usr/bin/env ruby
# don't forget disable selinux enable/active httpd, ruby-devel , gcc for some gems

check_root = Process.uid.zero?

def check_package(package)
  return true if system("which #{package} &> /dev/null")
end

def install_package(package)
  system("yum install -y #{package}")
end

if check_root
  install_package('httpd') unless check_package('httpd')
  install_package('nethogs') unless check_package('nethogs')
  install_package('iptraf') unless check_package('iptraf-ng')
  system('gem install mongo') unless system('gem list -i mongo &> /dev/null')
else
  puts 'debes ser root saliendo...'
  exit(0)
end