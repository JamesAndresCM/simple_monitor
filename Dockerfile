FROM centos:latest

RUN yum install -y wget
RUN wget http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
RUN rpm -ivh epel-release-latest-7.noarch.rpm
RUN yum update && yum install -y make ruby ruby-devel gcc gcc-c++ kernel-devel net-tools vim

ENV TZ America/Santiago

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

ADD requirements.rb /usr/src/app/requirements.rb
ADD network_logs.rb /usr/src/app/network_logs.rb
ADD system /usr/src/app/system
RUN ruby /usr/src/app/requirements.rb


EXPOSE 80
CMD ["/usr/sbin/httpd","-D","FOREGROUND"]
