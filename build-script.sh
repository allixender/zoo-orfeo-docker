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
export CGI_DATA_DIR=/usr/lib/cgi-bin/data

mkdir -p $BUILD_ROOT \
  && mkdir -p $CGI_DIR \
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

# get ITK
# http://www.itk.org/Wiki/ITK_Configuring_and_Building_for_Ubuntu_Linux
# ITK_USE_REVIEW to OFF/ON regarding review API and license copyright etc
# -DBUILD_EXAMPLES=ON/OFF
wget -nv -O $BUILD_ROOT/InsightToolkit-4.7.2.tar.gz https://storage.googleapis.com/smart-server/InsightToolkit-4.7.2.tar.gz \
  && cd $BUILD_ROOT/ && tar -xzf InsightToolkit-4.7.2.tar.gz \
  && cd $BUILD_ROOT/InsightToolkit-4.7.2 \
  && mkdir build \
  && cd build \
  && cmake -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_PREFIX_PATH=/usr:/usr/local \
    -DITK_USE_REVIEW=OFF \
    -DBUILD_DOXYGEN=OFF \
    -DBUILD_EXAMPLES=ON \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_TESTING=OFF \
    -DCMAKE_BACKWARDS_COMPATIBILITY=2.4 \
    -DCMAKE_BUILD_TYPE=Release \
    -DITK_USE_KWSTYLE=OFF ../ >../configure.out.txt \
  && make -j2 && make install \
  && cp -r bin/* /usr/bin/

# /usr/include/ITK-4.7
# /usr/lib/libITK...so...

# export ITK_AUTOLOAD_PATH=/usr/bin
# get otb
# https://www.orfeo-toolbox.org/SoftwareGuide/SoftwareGuidech2.html
# -DOTB_DATA_ROOT=/usr/lib/cgi-bin/data \
# -DOTB_WRAP_PYTHON=ON \
# -DOTB_WRAP_JAVA=OFF
# -DOTB_BUILD_DEFAULT_MODULES=ON
wget -nv -O $BUILD_ROOT/OTB-4.2.1.tgz https://storage.googleapis.com/smart-server/OTB-4.2.1.tgz \
  && cd $BUILD_ROOT/ && tar -xzf OTB-4.2.1.tgz \
  && cd $BUILD_ROOT/OTB-4.2.1 \
  && mkdir build \
  && cd build \
  && cmake -DCMAKE_INSTALL_PREFIX=/usr \
    -DUSE_EXTERNAL_ITK=ON \
    -DUSE_EXTERNAL_LIBKML=ON \
    -DOTB_USE_LIBKML=OFF \
    -DOTB_USE_OPENJPEG=ON \
    -DOTB_USE_OPENCV=OFF \
    -DOTB_USE_MUPARSER=ON \
    -DOTB_USE_CURL=ON \
    -DBUILD_EXAMPLES=OFF \
    -DBUILD_TESTING=OFF ../ >../configure.out.txt \
  && make -j2 && make install

export ITK_AUTOLOAD_PATH=/usr/lib/otb/applications
echo /usr/lib/otb >> /etc/ld.so.conf.d/otb.conf
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

# Add demo configs orfeo
# otb2zcfg utility
cd $BUILD_ROOT/thirds/otb2zcfg \
  && mkdir build \
  && cd build \
  && cmake .. \
  && make \
  && mkdir zcfgs \
  && cd zcfgs \
  && ../otb2zcfg
# otb2zcfg does not exit cleanly for some reason

mkdir -p $CGI_DIR/OTB \
  && cp -r *zcfg $CGI_DIR/OTB
# cp *zcfg /location/to/your/cgi-bin/

# however, auto additonal packages won't get removed
# maybe auto remove is a bit too hard
# RUN apt-get autoremove -y && rm -rf /var/lib/apt/lists/*
# ENV AUTO_ADDED_PACKAGES $(apt-mark showauto)
# RUN apt-get remove --purge -y $BUILD_PACKAGES $AUTO_ADDED_PACKAGES

apt-get remove --purge -y $BUILD_PACKAGES \
  && rm -rf /var/lib/apt/lists/*

rm -rf $BUILD_ROOT/mapserver-6.0.4
rm $BUILD_ROOT/mapserver-6.0.4.tar.gz
rm -rf $BUILD_ROOT/InsightToolkit-4.7.2
rm $BUILD_ROOT/InsightToolkit-4.7.2.tar.gz
rm -rf $BUILD_ROOT/OTB-4.2.1
rm $BUILD_ROOT/OTB-4.2.1.tgz
rm -rf $ZOO_BUILD_DIR
rm -rf $BUILD_ROOT/thirds
