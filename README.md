
# ZOO-Project WPS with Orfeo toolbox

info:  http://www.zoo-project.org/docs/kernel/orfeotoolbox.html

build script based on gist https://gist.github.com/allixender/2c7b6285efdb67c187a48bf79597170e

## side notes

could do with gdal and cgal
with and without mapserver
zoo orfeo integration test

- http://zoo-project.org/docs/kernel/mapserver.html#kernel-mapserver
```bash
# main.cfg
dataPath = /var/www/temp/
mapserverAddress=http://localhost/cgi-bin/mapserv
mapserverAddress
msOgcVersion

# main.cfg
[env]
ITK_AUTOLOAD_PATH=/usr/lib/otb/applications
```

### try using -rpath or -rpath-link or package install actually

libotbconfigfile.so.4.2, needed by /usr/lib/otb/libOTBCommon.so

libOTBCurlAdapters.so.4.2, needed by /usr/lib/otb/libOTBApplicationEngine.so

libOTBOssimAdapters.so.4.2, needed by /usr/lib/otb/libOTBApplicationEngine.so

libOTBOGRAdapters.so.4.2, needed by /usr/lib/otb/libOTBIO.so

libotbopenjpeg.so.1111.1, needed by /usr/lib/otb/libOTBIO.so

### needs OSSIM

http://www.ossim.org, yes, 1.8.20-3

### needs OpenJPEG

http://code.google.com/p/openjpeg/,

/usr/bin/ld: warning: libotbconfigfile.so.4.2, needed by /usr/lib/otb/libOTBCommon.so, not found (try using -rpath or -rpath-link)
/usr/bin/ld: warning: libOTBCurlAdapters.so.4.2, needed by /usr/lib/otb/libOTBApplicationEngine.so, not found (try using -rpath or -rpath-link)
/usr/bin/ld: warning: libOTBOssimAdapters.so.4.2, needed by /usr/lib/otb/libOTBApplicationEngine.so, not found (try using -rpath or -rpath-link)
/usr/bin/ld: warning: libOTBOGRAdapters.so.4.2, needed by /usr/lib/otb/libOTBIO.so, not found (try using -rpath or -rpath-link)
/usr/bin/ld: warning: libotbopenjpeg.so.1111.1, needed by /usr/lib/otb/libOTBIO.so, not found (try using -rpath or -rpath-link)
