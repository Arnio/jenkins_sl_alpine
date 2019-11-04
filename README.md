Goal: run jenkins slave node in openshift cluster, connect to master node and config for deploying application in Openshift cluster.

Requirements: Configure Jenkins master.
Configure Global Security on Jenkins master node.
 section “Agent”  - Port and Protocols

In master Jenkins adding slave node with parameters 
section “Manage Jenkins” - “Manage Nodes” - “New Node” :  Add “Node name” and check “Permanent Agent”, press “OK”. Add executors, labels, check settings and push “save”.

Notice information about connection to master node. This information will be used in bash scripts.

Implementation: Start bash script with parameters.

Start bash script with parameters:

./create-ci-slave.sh -n <namespase> -a <jenkins slave name> -p <secret> -u <URL>

-a Jenkins slave node name (from master)
-d Delete configs before creating
-h Help
-n Jenkins slave namespace in Openshift
-p Jenkins secret
-u Jenkins master URL - Jenkins main page
-y Force apply (overwrite configs)

If namespace exists - script will ask you apply to overwrite configs or cancel. 

Example:
./create-ci-slave.sh -n ci -a jenkins-op-node -p 54eae4d24585da9b007b7fa03c432e1c05a18c9d98b78f6157e839a20d57c5b0 -u http://192.168.56.11:8080 -d  -y
