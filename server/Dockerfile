FROM cloudflare/quiche

COPY tls /srv/tls
COPY www /srv/www

CMD ["quiche-server", "--cert", "/srv/tls/server.crt", "--key", "/srv/tls/server.key", "--root", "/srv/www/", "--listen", "0.0.0.0:4433"]
