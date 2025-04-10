#!/bin/bash

SERVER_CA_ALIAS=serverca
SERVER_CA_PASS=generated

SERVER_CERT_ALIAS=external.net
SERVER_CERT_PASS=generated
SERVER_CERT_SAN=dns:*.external.net

SERVER_TRUST_PASS=generated

CLIENT_CA_ALIAS=clientca
CLIENT_CA_PASS=generated

CLIENT_CERT_ALIAS=client1
CLIENT_CERT_PASS=generated

CLIENT_TRUST_PASS=generated

clean()
{
  echo "Cleanup files"
  rm -rf server
  rm -rf client
}

function print_cert()
{
  openssl x509 -noout -text -in $1
}

function print_req()
{
  openssl req -noout -text -in $1
}

function print_key()
{
  openssl rsa -noout -text -in $1
}

create_server_signers()
{
  mkdir -p server

  echo ""
  echo "------------------------------------------------------------------------------"
  echo "Generate ca keypair: server/signers"
  echo "------------------------------------------------------------------------------"
  keytool -genkeypair -keystore server/signers -storepass ${SERVER_CA_PASS} -keypass ${SERVER_CA_PASS} -alias ${SERVER_CA_ALIAS} -dname "C=US, ST=California, O=Aklivity, OU=Development, CN=${SERVER_CA_ALIAS}" -validity 3650 -keyalg RSA -ext bc:c

  echo ""
  echo "------------------------------------------------------------------------------"
  echo "Export ca certificate in pem format: server/${SERVER_CA_ALIAS}.crt"
  echo "------------------------------------------------------------------------------"
  keytool -keystore server/signers -storepass ${SERVER_CA_PASS} -alias ${SERVER_CA_ALIAS} -exportcert -rfc > server/${SERVER_CA_ALIAS}.crt

  print_cert server/${SERVER_CA_ALIAS}.crt
}

create_client_signers()
{
  mkdir -p client

  echo ""
  echo "------------------------------------------------------------------------------"
  echo "Generate ca keypair: client/signers"
  echo "------------------------------------------------------------------------------"
  keytool -genkeypair -keystore client/signers -storepass ${CLIENT_CA_PASS} -keypass ${CLIENT_CA_PASS} -alias ${CLIENT_CA_ALIAS} -dname "C=US, ST=California, O=Aklivity, OU=Development, CN=${SERVER_CA_ALIAS}" -validity 3650 -keyalg RSA -ext bc:c

  echo ""
  echo "------------------------------------------------------------------------------"
  echo "Export ca certificate in pem format: client/${CLIENT_CA_ALIAS}.crt"
  echo "------------------------------------------------------------------------------"
  keytool -keystore client/signers -storepass ${CLIENT_CA_PASS} -alias ${CLIENT_CA_ALIAS} -exportcert -rfc > client/${CLIENT_CA_ALIAS}.crt

  print_cert client/${CLIENT_CA_ALIAS}.crt
}

create_server_keys()
{
  echo ""
  echo "------------------------------------------------------------------------------"
  echo "Generate certificate keypair: server/keys"
  echo "------------------------------------------------------------------------------"
  keytool -genkeypair -keystore server/keys -storepass ${SERVER_CERT_PASS} -keypass ${SERVER_CERT_PASS} -alias ${SERVER_CERT_ALIAS} -dname "C=US, ST=California, O=Aklivity, OU=Development, CN=${SERVER_CERT_ALIAS}" -validity 3650 -keyalg RSA

  echo ""
  echo "------------------------------------------------------------------------------"
  echo "Create certificate signing request: server/${SERVER_CERT_ALIAS}.csr"
  echo "------------------------------------------------------------------------------"
  keytool -keystore server/keys -storepass ${SERVER_CERT_PASS} -alias ${SERVER_CERT_ALIAS} -certreq -rfc > server/${SERVER_CERT_ALIAS}.csr

  print_req server/${SERVER_CERT_ALIAS}.csr

  echo ""
  echo "------------------------------------------------------------------------------"
  echo "Create signed certificate: server/${SERVER_CERT_ALIAS}.crt"
  echo "------------------------------------------------------------------------------"
  keytool -keystore server/signers -storepass ${SERVER_CA_PASS} -keypass ${SERVER_CA_PASS} -gencert -alias ${SERVER_CA_ALIAS} -ext ku:c=dig,keyenc -ext SAN="${SERVER_CERT_SAN}" -rfc -validity 1800 < server/${SERVER_CERT_ALIAS}.csr > server/${SERVER_CERT_ALIAS}.crt

  print_cert server/${SERVER_CERT_ALIAS}.crt

  echo ""
  echo "------------------------------------------------------------------------------"
  echo "Import signed certificate: server/${SERVER_CERT_ALIAS}.crt"
  echo "------------------------------------------------------------------------------"
  keytool -keystore server/keys -storepass ${SERVER_CERT_PASS} -keypass ${SERVER_CERT_PASS} -importcert -alias ${SERVER_CA_ALIAS} -rfc -noprompt < server/${SERVER_CA_ALIAS}.crt
  keytool -keystore server/keys -storepass ${SERVER_CERT_PASS} -keypass ${SERVER_CERT_PASS} -importcert -alias ${SERVER_CERT_ALIAS} -rfc < server/${SERVER_CERT_ALIAS}.crt
  keytool -keystore server/keys -storepass ${SERVER_CERT_PASS} -keypass ${SERVER_CERT_PASS} -delete -alias ${SERVER_CA_ALIAS} -noprompt

  echo ""
  echo "------------------------------------------------------------------------------"
  echo "Generate JKS: server/keys.jks"
  echo "------------------------------------------------------------------------------"
  keytool -importkeystore -srckeystore server/keys -srcstoretype PKCS12 -srcstorepass ${SERVER_CERT_PASS} -destkeystore server/keys.jks -deststoretype JKS -deststorepass ${SERVER_CERT_PASS}
}

create_client_keys()
{
  echo ""
  echo "------------------------------------------------------------------------------"
  echo "Generate certificate keypair: client/keys"
  echo "------------------------------------------------------------------------------"
  keytool -genkeypair -keystore client/keys -storepass ${CLIENT_CERT_PASS} -keypass ${CLIENT_CERT_PASS} -alias ${CLIENT_CERT_ALIAS} -dname "C=US, ST=California, O=Aklivity, OU=Development, CN=${SERVER_CERT_ALIAS}" -validity 3650 -keyalg RSA

  echo ""
  echo "------------------------------------------------------------------------------"
  echo "Create certificate signing request: client/${CLIENT_CERT_ALIAS}.csr"
  echo "------------------------------------------------------------------------------"
  keytool -keystore client/keys -storepass ${CLIENT_CERT_PASS} -alias ${CLIENT_CERT_ALIAS} -certreq -rfc > client/${CLIENT_CERT_ALIAS}.csr

  print_req client/${CLIENT_CERT_ALIAS}.csr

  echo ""
  echo "------------------------------------------------------------------------------"
  echo "Create signed certificate: client/${CLIENT_CERT_ALIAS}.crt"
  echo "------------------------------------------------------------------------------"
  keytool -keystore client/signers -storepass ${CLIENT_CA_PASS} -keypass ${CLIENT_CA_PASS} -gencert -alias ${CLIENT_CA_ALIAS} -ext ku:c=dig,keyenc -dname "CN=${CLIENT_CERT_ALIAS}" -rfc -validity 1800 < client/${CLIENT_CERT_ALIAS}.csr > client/${CLIENT_CERT_ALIAS}.crt

  print_cert client/${CLIENT_CERT_ALIAS}.crt

  echo ""
  echo "------------------------------------------------------------------------------"
  echo "Import signed certificate: client/${CLIENT_CERT_ALIAS}.crt"
  echo "------------------------------------------------------------------------------"
  keytool -keystore client/keys -storepass ${CLIENT_CERT_PASS} -keypass ${CLIENT_CERT_PASS} -importcert -alias ${CLIENT_CA_ALIAS} -rfc -noprompt < client/${CLIENT_CA_ALIAS}.crt
  keytool -keystore client/keys -storepass ${CLIENT_CERT_PASS} -keypass ${CLIENT_CERT_PASS} -importcert -alias ${CLIENT_CERT_ALIAS} -rfc < client/${CLIENT_CERT_ALIAS}.crt
  keytool -keystore client/keys -storepass ${CLIENT_CERT_PASS} -keypass ${CLIENT_CERT_PASS} -delete -alias ${CLIENT_CA_ALIAS} -noprompt

  echo ""
  echo "------------------------------------------------------------------------------"
  echo "Generate JKS: client/keys.jks"
  echo "------------------------------------------------------------------------------"
  keytool -importkeystore -srckeystore client/keys -srcstoretype PKCS12 -srcstorepass ${CLIENT_CERT_PASS} -destkeystore client/keys.jks -deststoretype JKS -deststorepass ${CLIENT_CERT_PASS}
}

create_server_trust()
{
  echo ""
  echo "------------------------------------------------------------------------------"
  echo "Import the client ca certificate: server/trust"
  echo "------------------------------------------------------------------------------"
  keytool -keystore server/trust -storepass ${SERVER_TRUST_PASS} -keypass ${SERVER_TRUST_PASS} -importcert -alias ${CLIENT_CA_ALIAS} -rfc -noprompt < client/${CLIENT_CA_ALIAS}.crt

  print_cert client/${CLIENT_CA_ALIAS}.crt

  echo ""
  echo "------------------------------------------------------------------------------"
  echo "Generate JKS: server/trust.jks"
  echo "------------------------------------------------------------------------------"
  keytool -importkeystore -srckeystore server/trust -srcstoretype PKCS12 -srcstorepass ${SERVER_TRUST_PASS} -destkeystore server/trust.jks -deststoretype JKS -deststorepass ${SERVER_TRUST_PASS}
}

create_client_trust()
{
  echo ""
  echo "------------------------------------------------------------------------------"
  echo "Import the server ca certificate: client/trust"
  echo "------------------------------------------------------------------------------"
  keytool -keystore client/trust -storepass ${CLIENT_TRUST_PASS} -keypass ${CLIENT_TRUST_PASS} -importcert -alias ${SERVER_CA_ALIAS} -rfc -noprompt < server/${SERVER_CA_ALIAS}.crt

  print_cert server/${SERVER_CA_ALIAS}.crt

  echo ""
  echo "------------------------------------------------------------------------------"
  echo "Generate JKS: client/trust.jks"
  echo "------------------------------------------------------------------------------"
  keytool -importkeystore -srckeystore client/trust -srcstoretype PKCS12 -srcstorepass ${CLIENT_TRUST_PASS} -destkeystore client/trust.jks -deststoretype JKS -deststorepass ${CLIENT_TRUST_PASS}
}

clean
create_server_signers
create_client_signers
create_server_keys
create_client_keys
create_server_trust
create_client_trust
