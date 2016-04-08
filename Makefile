NAME = nginx
VERSION = 1.9.14
NPS_VERSION = 1.11.33.0
TARDIR = $(NAME)-$(VERSION)
TARBALL = $(TARDIR).tar.gz
DOWNLOAD = http://nginx.org/download/${NAME}-${VERSION}.tar.gz
PLUGIN = https://github.com/pagespeed/ngx_pagespeed/archive/v1.11.33.0-beta.tar.gz
#PLUGIN = https://github.com/pagespeed/ngx_pagespeed/archive/release-${NPS_VERSION}-beta.zip
#PSOL = https://dl.google.com/dl/page-speed/psol/1.9.32.10.tar.gz
PSOL = https://dl.google.com/dl/page-speed/psol/${NPS_VERSION}.tar.gz
	
PREFIX=/opt/nginx
	
PACKAGE_NAME=nginx
PACKAGE_VERSION=1.9.14-alp54
	
.PHONY: default
default: deb
package: deb
	
.PHONY: clean
clean:
	rm -rf $(NAME)-* 
	rm -fr $(TARDIR) || true
	rm -fr $(PREFIX) || true
	rm -f *.deb
	rm -f release-*
	rm -fr ngx_pagespeed*
	rm -rf pgk*
	
$(TARBALL):
	wget "$(DOWNLOAD)" && tar -zxf ${TARBALL} && wget "$(PLUGIN)" && tar -zxvf v1.11.33.0-beta.tar.gz && cd ngx_pagespeed-${NPS_VERSION}-beta && wget "$(PSOL)" && tar -xzvf ${NPS_VERSION}.tar.gz
	
$(TARDIR): $(TARBALL)
	cd $(TARDIR); ./configure  --with-cc-opt='-g -O2 -fPIE -fstack-protector --param=ssp-buffer-size=4 -Wformat -Werror=format-security -D_FORTIFY_SOURCE=2' --with-ld-opt='-Wl,-Bsymbolic-functions -fPIE -pie -Wl,-z,relro -Wl,-z,now' --prefix=/usr/share/nginx --conf-path=/etc/nginx/nginx.conf --http-log-path=/var/log/nginx/access.log --error-log-path=/var/log/nginx/error.log --lock-path=/var/lock/nginx.lock --pid-path=/run/nginx.pid --http-client-body-temp-path=/var/lib/nginx/body --http-fastcgi-temp-path=/var/lib/nginx/fastcgi --http-proxy-temp-path=/var/lib/nginx/proxy --http-scgi-temp-path=/var/lib/nginx/scgi --http-uwsgi-temp-path=/var/lib/nginx/uwsgi --with-debug --with-pcre-jit --with-ipv6 --with-http_ssl_module --with-http_stub_status_module --with-http_realip_module --with-http_auth_request_module --with-http_addition_module --with-http_dav_module --with-http_geoip_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_image_filter_module --with-http_sub_module --with-mail --with-mail_ssl_module --with-http_v2_module --sbin-path=/usr/local/sbin --add-module=/home/gtonic/ws_alp54/debian-nginx-pagespeed/ngx_pagespeed-1.11.33.0-beta; make; 
	
.PHONY: deb
deb: $(TARDIR)
	mkdir -p pkg/usr/local/sbin; mkdir -p pkg/etc; mkdir -p pkg/var/log/nginx;
	rm $(TARDIR)/conf/mime.types;
	cp $(TARDIR)/conf/* pkg/etc/;
	cp $(TARDIR)/objs/nginx pkg/usr/local/sbin/nginx;
	fpm -s dir -t deb -v $(PACKAGE_VERSION) -n $(PACKAGE_NAME) -C pkg -p ${NAME}-${PACKAGE_VERSION}.deb etc usr var
