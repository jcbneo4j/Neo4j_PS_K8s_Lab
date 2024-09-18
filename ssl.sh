#generate the cert and private key
openssl req -newkey rsa:2048 -nodes -keyout private.key -x509 -days 365 -out public.crt -subj "/C=GB/ST=London/L=London/O=Neo4j/OU=IT Department"

#add to a kubernetes secret named neo4j-tls
kubectl create secret tls neo4j-tls --cert=public.crt --key=private.key