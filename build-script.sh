#!/bin/bash

export RUNTIME_PACKAGES="wget libxml2 libcurlpp0 curl libcurl3 openssl apache2 libfcgi0ldbl libcairo2 libgeotiff2 libtiff5 \
libgdal1h libgeos-3.4.2 libgeos-c1 libgd-dev libwxbase3.0-0 libgfortran3 libmozjs185-1.0 libproj0 \
wx-common zip libwxgtk3.0-0 libjpeg62 libpng3 libxslt1.1 python2.7 apache2 uuid-dev libkml-java libkml0 \
libmuparser2 libtinyxml2-0.0.0 libtinyxml2.6.2 libopenthreads14 libopenjpeg2 libossim1 ossim-core cgal libcgal10"

apt-get update -y \
      && apt-get install -y --no-install-recommends $RUNTIME_PACKAGES

export BUILD_PACKAGES="subversion unzip flex bison libxml2-dev autotools-dev autoconf libmozjs185-dev python-dev \
build-essential libxslt1-dev software-properties-common libgdal-dev automake libtool libcairo2-dev \
 libgd-gd2-perl libgd2-xpm-dev ibwxbase3.0-dev  libwxgtk3.0-dev wx3.0-headers wx3.0-i18n libcurl4-gnutls-dev \
libproj-dev libnetcdf-dev libfreetype6-dev libxslt1-dev libfcgi-dev libopenthreads-dev libcurlpp-dev \
libtiff5-dev libgeotiff-dev swig2.0 cmake libkml-dev libmuparser-dev libtinyxml-dev libtinyxml2-dev \
libopenjpeg-dev libboost-dev libboost1.54-dev libossim-dev libcgal10 libcgal-dev"

apt-get install -y --no-install-recommends $BUILD_PACKAGES

# for mapserver
# OTB and ITK, the CMAKE_C_FLAGS and CMAKE_CXX_FLAGS must first be set to -fPIC
export CMAKE_C_FLAGS=-fPIC
export CMAKE_CXX_FLAGS=-fPIC

# useful declarations
export BUILD_ROOT=/opt/build
export ZOO_BUILD_DIR=/opt/build/zoo-project
export CGI_DIR=/usr/lib/cgi-bin
export CGI_DATA_DIR=$CGI_DIR/data
export CGI_TMP_DIR=$CGI_DATA_DIR/tmp
export CGI_CACHE_DIR=$CGI_DATA_DIR/cache
export WWW_DIR=/var/www/html

# should build already there from base
# mkdir -p $BUILD_ROOT \
#   && mkdir -p $CGI_DIR \
#   && mkdir -p $CGI_DATA_DIR \
#   && mkdir -p $CGI_TMP_DIR \
#   && mkdir -p $CGI_CACHE_DIR \
#   && ln -s /usr/lib/x86_64-linux-gnu /usr/lib64

# ENV ITK_AUTOLOAD_PATH /usr/lib/otb/applications
# echo /usr/lib/otb >> /etc/ld.so.conf.d/otb.conf

echo /usr/lib/otb/applications >> /etc/ld.so.conf.d/otb.conf
/sbin/ldconfig

svn checkout http://svn.zoo-project.org/svn/trunk/zoo-project/ $ZOO_BUILD_DIR \
  && cd $ZOO_BUILD_DIR/zoo-kernel && autoconf \
  && LDFLAGS=-L/usr/lib/otb CPPFLAGS=-I/usr/include/otb ./configure --with-cgi-dir=$CGI_DIR \
  --prefix=/usr \
  --exec-prefix=/usr \
  --with-fastcgi=/usr \
  --with-gdal-config=/usr/bin/gdal-config \
  --with-geosconfig=/usr/bin/geos-config \
  --with-python \
  --with-mapserver=$BUILD_ROOT/mapserver-6.0.4 \
  --with-xml2config=/usr/bin/xml2-config \
  --with-pyvers=2.7 \
  --with-js=/usr \
  --with-otb=/usr \
  --with-itk=/usr \
  --with-itk-version=4.7 \
  && make && make install


# however, auto additonal packages won't get removed
# maybe auto remove is a bit too hard
# RUN apt-get autoremove -y && rm -rf /var/lib/apt/lists/*
# ENV AUTO_ADDED_PACKAGES $(apt-mark showauto)
# RUN apt-get remove --purge -y $BUILD_PACKAGES $AUTO_ADDED_PACKAGES

apt-get remove --purge -y $BUILD_PACKAGES \
  && rm -rf /var/lib/apt/lists/*

# clean up from base
rm -rf $BUILD_ROOT/mapserver-6.0.4
rm -rf $ZOO_BUILD_DIR
# rm -rf $BUILD_ROOT/thirds
