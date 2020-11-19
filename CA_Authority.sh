# Generate random password for CA private key
openssl rand -base64 48 > CA/passphrase.txt

# Generate CA private key
openssl genrsa -aes128 -passout file:CA/passphrase.txt -out CA/CA.key 4096

# Generate CA root certificate
openssl req -x509 -new -nodes -key CA/CA.key -sha256 -days 1825 -out CA/CA.pem -subj "/C=US/ST=Acme/L=Acme/O=Acme/OU=Acme/CN=CA Authority"

# Generate server private key, CSR, and certificate
openssl req -nodes -newkey rsa:4096 -keyout server/tls/server.key -out server/tls/server.csr -subj "/C=US/ST=Acme/L=Acme/O=Acme/OU=Acme/CN=server"
openssl x509 -req -days 36500 -in server/tls/server.csr -signkey server/tls/server.key -out server/tls/server.crt

# Copy CA certificate to server and client
cp CA/CA.pem server/tls/ && cp CA/CA.pem client/