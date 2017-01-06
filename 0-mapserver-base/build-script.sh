#!/bin/bash

export RUNTIME_PACKAGES="wget libxml2 libcurlpp0 curl libcurl3 openssl apache2 libfcgi0ldbl libcairo2 libgeotiff2 libtiff5 \
libgdal1h libgeos-3.4.2 libgeos-c1 libgd-dev libwxbase3.0-0 libgfortran3 libmozjs185-1.0 libproj0 \
wx-common zip libwxgtk3.0-0 libjpeg62 libpng3 libxslt1.1 python2.7 apache2 uuid-dev libkml-java libkml0 \
libmuparser2 libtinyxml2-0.0.0 libtinyxml2.6.2 libopenthreads14 libopenjpeg2 libossim1 ossim-core"

apt-get update -y \
      && apt-get install -y --no-install-recommends $RUNTIME_PACKAGES

export BUILD_PACKAGES="subversion unzip flex bison libxml2-dev autotools-dev autoconf libmozjs185-dev python-dev \
build-essential libxslt1-dev software-properties-common libgdal-dev automake libtool libcairo2-dev \
 libgd-gd2-perl libgd2-xpm-dev ibwxbase3.0-dev  libwxgtk3.0-dev wx3.0-headers wx3.0-i18n libcurl4-gnutls-dev \
libproj-dev libnetcdf-dev libfreetype6-dev libxslt1-dev libfcgi-dev libopenthreads-dev libcurlpp-dev \
libtiff5-dev libgeotiff-dev swig2.0 cmake libkml-dev libmuparser-dev libtinyxml-dev libtinyxml2-dev \
libopenjpeg-dev libboost-dev libboost1.54-dev libossim-dev"

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

mkdir -p $BUILD_ROOT \
  && mkdir -p $CGI_DIR \
  && mkdir -p $CGI_DATA_DIR \
  && mkdir -p $CGI_TMP_DIR \
  && mkdir -p $CGI_CACHE_DIR \
  && ln -s /usr/lib/x86_64-linux-gnu /usr/lib64

wget -nv -O $BUILD_ROOT/mapserver-6.0.4.tar.gz http://download.osgeo.org/mapserver/mapserver-6.0.4.tar.gz \
  && cd $BUILD_ROOT/ && tar -xzf mapserver-6.0.4.tar.gz \
  && cd $BUILD_ROOT/mapserver-6.0.4 \
  && ./configure --with-ogr=/usr/bin/gdal-config --with-gdal=/usr/bin/gdal-config \
               --with-proj --with-curl --with-sos --with-wfsclient --with-wmsclient \
               --with-wcs --with-wfs --with-kml=yes --with-geos \
               --with-xml --with-xslt --with-threads --with-cairo \
  && sed -i "s/-lgeos-3.4.2_c/-lgeos-3.4.2\ -lgeos_c/g" Makefile \
  && sed -i "s/-lm -lstdc++/-lm -lstdc++ -ldl/g" Makefile \
  && make && cp mapserv $CGI_DIR


# here are the thirds
ln -s /usr/lib/libfcgi.so.0.0.0 /usr/lib64/libfcgi.so \
  && ln -s /usr/lib/libfcgi++.so.0.0.0 /usr/lib64/libfcgi++.so

svn checkout http://svn.zoo-project.org/svn/trunk/thirds/ $BUILD_ROOT/thirds \
  && cd $BUILD_ROOT/thirds/cgic206 && make

# RUN apt-get remove --purge -y $BUILD_PACKAGES $AUTO_ADDED_PACKAGES

apt-get remove --purge -y $BUILD_PACKAGES \
  && rm -rf /var/lib/apt/lists/*

rm -rf $BUILD_ROOT/mapserver-6.0.4
rm $BUILD_ROOT/mapserver-6.0.4.tar.gz
