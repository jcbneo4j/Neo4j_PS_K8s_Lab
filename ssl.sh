openssl req -newkey rsa:2048 -nodes -keyout private.key -x509 -days 365 -out public.crt -subj "/C=GB/ST=London/L=London/O=Neo4j/OU=IT Department"

kubectl create secret tls neo4j-tls --cert=public.crt --key=private.key