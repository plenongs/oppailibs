#!/bin/bash

latest_version="$(curl -s https://api.github.com/repos/noobz-id/noobzvpns/releases | grep tag_name | sed -E 's/.*"(.*)".*/\1/' | head -n 1)"
nobz="https://github.com/noobz-id/noobzvpns/archive/refs/tags/$latest_version.zip"
MACHINE=`$(which uname) "-m"`
BINARY_ARCH=""
DOMAIN=`cat /etc/oppailibs/oppai.txt | grep 'DOMAIN ' | sed -e 's/DOMAIN //g'`

echo -e "Downloading lastest noobzvpns and installing.."

curl -sL $nobz -o noobz.zip
unzip -q noobz.zip && rm -rf noobz.zip

case $MACHINE in
    "x86_64")
        BINARY_ARCH="noobzvpns.x86_64"
        ;;
    *)
        echo "Error at installation, unsuported cpu-arch $MACHINE"
        exit 1
        ;;
esac

mkdir -p /etc/noobzvpns
cp noobzvpns*/$BINARY_ARCH /usr/bin/noobzvpns
cp noobzvpns*/noobzvpns.service /etc/systemd/system/noobzvpns.service

cat > /etc/noobzvpns/config.json << END
{
	"tcp_std": [
		1880
	],
	"tcp_ssl": [
		1843
	],
	"ssl_cert": "/usr/local/etc/oppailibs/fullchain.pem",
	"ssl_key": "/usr/local/etc/oppailibs/privkey.pem",
	"ssl_version": "AUTO",
	"conn_timeout": 60,
	"dns_resolver": "/etc/resolv.conf",
	"http_ok": "HTTP/1.1 101 Switching Protocols[crlf]Upgrade: websocket[crlf]Connection: Upgrade[crlf][crlf]"
}
END

chmod 700 /usr/bin/noobzvpns
chmod 600 /etc/noobzvpns/config.json
chmod 600 /etc/systemd/system/noobzvpns.service

echo -e "Configurasi Nginx config Noobzvpns"

cat >/etc/nginx/conf.d/noobz.conf << END
server {
  listen 80;
  listen [::]:80;
  root /var/www/html;

  index index.nginx-debian.html;

  server_name oppai.${DOMAIN};
  location / {
    if (\$http_upgrade != "websocket") {
      return 404;
    }
    proxy_redirect off;
    proxy_pass http://127.0.0.1:1880;
    proxy_http_version 1.1;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_read_timeout 52w;
  }
}

server {
  listen 443 ssl http2;
  listen [::]:443 ssl http2;
  
  ssl_certificate /etc/letsencrypt/live/oppailibs/fullchain.pem;
	ssl_certificate_key /etc/letsencrypt/live/oppailibs/privkey.pem;
  ssl_protocols TLSv1.1 TLSv1.2 TLSv1.3;
  ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;
  ssl_prefer_server_ciphers off;
  
  root /var/www/html;

  index index.nginx-debian.html;

  server_name oppai.${DOMAIN};
  location / {
    if (\$http_upgrade != "websocket") {
      return 404;
    }
    proxy_pass http://127.0.0.1:1843;
    proxy_redirect off;
    proxy_http_version 1.1;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_read_timeout 52w;
  }
}
END