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
