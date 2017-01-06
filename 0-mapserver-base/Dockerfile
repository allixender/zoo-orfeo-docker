FROM ubuntu:14.04

# that's me!
MAINTAINER Alex K, allixender@googlemail.com

ENV CGI_DIR /usr/lib/cgi-bin
ENV CGI_DATA_DIR /usr/lib/cgi-bin/data
ENV CGI_TMP_DIR /usr/lib/cgi-bin/data/tmp
ENV CGI_CACHE_DIR /usr/lib/cgi-bin/data/cache
ENV WWW_DIR /var/www/html

ADD build-script.sh /opt
RUN chmod +x /opt/build-script.sh \
  && sync \
  && /opt/build-script.sh
