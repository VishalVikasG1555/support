# support

https://www.serverlab.ca/tutorials/containers/kubernetes/how-to-deploy-mysql-server-5-7-to-kubernetes/

https://kubernetes.io/docs/tasks/configure-pod-container/configure-persistent-volume-storage/

https://kubernetes.io/docs/reference/kubectl/cheatsheet/

https://docs.microsoft.com/en-us/sql/tools/mssql-cli?view=sql-server-ver15


# Import the public repository GPG keys
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc

# Register the Microsoft product feed
curl https://packages.microsoft.com/config/centos/7/prod.repo > /etc/yum.repos.d/msprod.repo

# Install dependencies and mssql-cli
sudo yum install libunwind
sudo yum install mssql-cli



https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-setup-tools?view=sql-server-ver15#SLES


Error response from daemon: manifest for ncr-passport-docker-group.jfrog.io/cpwe-capture:3.18.0.0-4.0.0 not found
Sqlcmd: Error: Microsoft ODBC Driver 17 for SQL Server : TCP Provider: Error code 0x2AF9.


https://msatechnosoft.in/blog/searching-sorting-data-structure-algorithms/

https://www.tutorialspoint.com/data_structures_algorithms/searching_algorithms.htm

https://www.geeksforgeeks.org/searching-algorithms/

https://www.google.com/amp/s/www.geeksforgeeks.org/understanding-time-complexity-simple-examples/amp/




[6:57 PM] Horrocks, Jacob
    
cat config/elasticsearch-security.yml
cluster.name: "docker-cluster"
network.host: 0.0.0.0


# minimum_master_nodes need to be explicitly set when bound on a public IP
# set to 1 to allow single node clusters
# Details: https://github.com/elastic/elasticsearch/pull/17288
discovery.zen.minimum_master_nodes: 1


xpack.license.self_generated.type: basic
xpack.security.enabled: true
xpack.ml.enabled: false
xpack.monitoring.enabled: false
xpack.watcher.enabled: false
xpack.security.authc.realms:
  realm1:
    type: native
    order: 0


# SSL
xpack.security.http.ssl.client_authentication: ${​​​​​​​ES_XPACK_SECURITY_HTTP_SSL_CLIENT_AUTHENTICATION:none}​​​​​​​
xpack.security.http.ssl.enabled: ${​​​​​​​ES_XPACK_SECURITY_HTTP_SSL_ENABLED:true}​​​​​​​
xpack.security.http.ssl.supported_protocols: ${​​​​​​​ES_XPACK_SECURITY_HTTP_SSL_SUPPORTED_PROTOCOLS:}​​​​​​​
xpack.security.http.ssl.cipher_suites: ${​​​​​​​ES_XPACK_SECURITY_HTTP_SSL_CIPHER_SUITES:}​​​​​​​
xpack.security.http.ssl.keystore.path: /usr/share/elasticsearch/config/keystore
xpack.security.http.ssl.truststore.path: /usr/share/elasticsearch/config/truststore
xpack.security.transport.ssl.enabled: true
path.data: /mnt/elasticsearch-logging/data
 



************************FROM HERE*********************************************************************************

cat config/elasticsearch-security.yml
cluster.name: "docker-cluster"
network.host: 0.0.0.0

 

# minimum_master_nodes need to be explicitly set when bound on a public IP
# set to 1 to allow single node clusters
# Details: https://github.com/elastic/elasticsearch/pull/17288
discovery.zen.minimum_master_nodes: 1

 

xpack.license.self_generated.type: basic
xpack.security.enabled: true
xpack.ml.enabled: false
xpack.monitoring.enabled: false
xpack.watcher.enabled: false
xpack.security.authc.realms:
  realm1:
    type: native
    order: 0

 

# SSL
xpack.security.http.ssl.client_authentication: ${ES_XPACK_SECURITY_HTTP_SSL_CLIENT_AUTHENTICATION:none}
xpack.security.http.ssl.enabled: ${ES_XPACK_SECURITY_HTTP_SSL_ENABLED:true}
xpack.security.http.ssl.supported_protocols: ${ES_XPACK_SECURITY_HTTP_SSL_SUPPORTED_PROTOCOLS:}
xpack.security.http.ssl.cipher_suites: ${ES_XPACK_SECURITY_HTTP_SSL_CIPHER_SUITES:}
xpack.security.http.ssl.keystore.path: /usr/share/elasticsearch/config/keystore
xpack.security.http.ssl.truststore.path: /usr/share/elasticsearch/config/truststore
xpack.security.transport.ssl.enabled: true
path.data: /mnt/elasticsearch-logging/data


cat /usr/bin/init.sh
#!/bin/bash
 
echo "ELASTICSEARCH_SECURITY_ENABLED=$ELASTICSEARCH_SECURITY_ENABLED"
if [ "$ELASTICSEARCH_SECURITY_ENABLED" == "true" ]; then
    mv /usr/share/elasticsearch/config/elasticsearch-security.yml /usr/share/elasticsearch/config/elasticsearch.yml
    keystorepassword=$(echo $ELASTICSEARCH_KEYSTORE_PASSWORD)
    truststorepassword=$(echo $ELASTICSEARCH_TRUSTSTORE_PASSWORD)
    sed -i "s/\${ELASTICSEARCH_KEYSTORE_PASSWORD}/$keystorepassword/g" "/usr/share/elasticsearch/config/elasticsearch.yml"
    sed -i "s/\${ELASTICSEARCH_TRUSTSTORE_PASSWORD}/$truststorepassword/g" "/usr/share/elasticsearch/config/elasticsearch.yml"
    bin/elasticsearch-keystore create
    printf $ELASTICSEARCH_PASSWORD | bin/elasticsearch-keystore add bootstrap.password
    printf $ELASTICSEARCH_KEYSTORE_PASSWORD | bin/elasticsearch-keystore add xpack.security.http.ssl.keystore.secure_password
    printf $ELASTICSEARCH_TRUSTSTORE_PASSWORD | bin/elasticsearch-keystore add xpack.security.http.ssl.truststore.secure_password
    setup-user.sh $ELASTICSEARCH_USERID $ELASTICSEARCH_PASSWORD &
else
    echo "WARNING: Security is disabled for Elasticsearch!"
    rm -f /usr/share/elasticsearch/config/elasticsearch-security.yml
fi
 
/usr/local/bin/docker-entrypoint.sh eswrapper
