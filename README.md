# Neo4j PS Kubernetes Lab

Welcome to the Neo4j Professional Services Kubernetes Lab. In this series of labs, you'll learn to deploy a 3 node cluster and perform updates to the deployment, gaining familiarty with K8s tools while performing the exercises.

## Start Lab

This lab is hosted as a Github Codespace which is self-contained not requiring anything to be run locally on your system. In order to start the lab follow the steps below. 

1. From the project page of this repository, click on the Code button, select the Codespaces tab, click the ellipsis (...), and select New with options... from the menu:

![image](images/new_codespace.png)


2. In the next page, select the Branch, Region, and Machine type as shown in the below image and then click the Create codespace button:

![image](images/create_codespace.png)


3. After a few moments, the Codespace will open up in an online VS Code IDE, as shown:

![image](images/codespace_ide.png)






## Deploy a 3 Node Neo4J Cluster

1. The first step in deploying a Neo4j cluster is to provision the Kubernetes (K8s) nodes via k3d, which is a lightweight K8s package to manage K8s environments. This can done running the following in the terminal. The script will download and install the k3d and configure a 3 node cluster:

```bash
./install.sh
```

2. Next, is to configure helm to point to the Neo4J Helm repo by running the following commands:
```bash
helm repo add neo4j https://helm.neo4j.com/neo4j
helm repo update
```

3. Prior to deploying Neo4j a K8s namespace needs to be created by running the following command to create and set the context of the namespace (named neo4j to your current context in kubectl:

```bash
kubectl create namespace neo4j
kubectl config set-context --current --namespace=neo4j
```

4. Now the cluster can be deployed via helm commands below. These will create a separate "release" for each node in the 3 node cluster. Each node release (e..g deployment) will follow a naming convention of "server-1, server-2, etc". Note: in an enterprise-level deployment, the values.yaml may differ for each node for various reasons - for instance, nodes could deployed to different regions/availability zones in a cloud deployment and the data contained in each nodes values yaml could differ; if that's the case, the values yaml would have a unique name (e.g. values1.yaml):

```bash
helm install server-1 neo4j/neo4j --namespace neo4j -f values.yaml
helm install server-2 neo4j/neo4j --namespace neo4j -f values.yaml
helm install server-3 neo4j/neo4j --namespace neo4j -f values.yaml
```

5. A few minutes after the deployment you can validate it's running by issuing the following command:

```bash
kubectl get pods
```

6. Once all of the nodes have a STATUS of 'Running' and are READY with 1/1, you can proceed:

```bash
NAME         READY   STATUS    RESTARTS   AGE
server-1-0   1/1     Running   0          10m
server-2-0   1/1     Running   0          10m
server-3-0   1/1     Running   0          10m
```

7. Another way to inspect a pod's deployment would be to look at the log - in this case, we can tail the neo4j log piping to the console of the pod:

```bash
kubectl logs -f server-1-0

outputs:
2024-09-18 21:19:17.241+0000 INFO  The license agreement was accepted with environment variable NEO4J_ACCEPT_LICENSE_AGREEMENT=yes when the Software was started.


2024-09-18 21:19:17.299+0000 INFO  Command expansion is explicitly enabled for configuration
2024-09-18 21:19:17.300+0000 INFO  Executing external script to retrieve value of setting server.routing.advertised_address
2024-09-18 21:19:17.300+0000 INFO  Executing external script to retrieve value of setting server.discovery.advertised_address
2024-09-18 21:19:17.300+0000 INFO  Executing external script to retrieve value of setting server.bolt.advertised_address
2024-09-18 21:19:17.300+0000 INFO  Executing external script to retrieve value of setting server.cluster.raft.advertised_address
2024-09-18 21:19:17.300+0000 INFO  Executing external script to retrieve value of setting server.cluster.advertised_address
2024-09-18 21:19:17.338+0000 INFO  Starting...
2024-09-18 21:19:25.098+0000 INFO  ======== Neo4j 5.23.0 ========
2024-09-18 21:19:25.148+0000 INFO  This instance is ServerId{5e98bcb8} (5e98bcb8-00c9-47da-bf68-c9b44107d490)
```

## Accessing Neo4j from within the pods

Outside of accessing the Kubernetes cluster via the loadbalaner, one can run the `kubectl exec` command allowing one to effectively shell into the pod and issue commands from within, or alternatively, pass commands into the exec command, as follows:

1. This command will "exec" into the pod running on server-1. Once in the pod, cypher shell can be run, as per usual (shown in the second command):
```bash
kubectl exec -it server-1-0 -- bash


One the Return button is pressed, you'll be at the bash prompt of server-1's pod container:
neo4j@server-1-0:~$
```

### cypher-shell (within the pod):

You'll be in the $NEO4J_HOME, so try cypher-shell and the output should be as shown below the command:
```bash
neo4j@server-1-0:~$ cypher-shell -u neo4j -p password123 -a bolt://localhost:7687

Connected to Neo4j using Bolt protocol version 5.6 at bolt://localhost:7687 as user neo4j.
Type :help for a list of available commands or :exit to exit the shell.
Note that Cypher queries must end with a semicolon.
neo4j@neo4j> 
```

### neo4j-admin (within the pod):

From within the pod, run the neo4j-admin command to get the database info:

```bash
neo4j@server-1-0:~$ neo4j-admin database info --expand-commands

This outputs the following:

Database name:                neo4j
Database in use:              true
Last committed transaction id:-1
Store needs recovery:         true

Database name:                system
Database in use:              true
Last committed transaction id:-1
Store needs recovery:         true


Note: select Ctrl-D to exit from the cypher-shell. This will put you back at the bash shell of the pod. Type "exit" and hit Enter to exit back to local terminal.
```

2. This will issue a command into the pod on server-1 via "exec":
```bash
kubectl exec -it server-1-0 -- cypher-shell -u neo4j -p password123 -a bolt://localhost:7687 -d system

After hitting Enter on the above command, the output will be shown as:

Connected to Neo4j using Bolt protocol version 5.6 at bolt://localhost:7687 as user neo4j.
Type :help for a list of available commands or :exit to exit the shell.
Note that Cypher queries must end with a semicolon.
neo4j@system> 

Note: select Ctrl-D to exit from the cypher-shell. This will put you back at the bash shell of the pod. Type "exit" and hit Enter to exit back to local terminal.
```
   
##Using helm

After the initial deployment, some maintenance can be done via helm. This section is to gain familarity with those proecesses.

1. One command is to do a simple listing of the current deployment. This would list all of the cluster nodes deployed as separate "releases." 

```bash
helm list

Running the above command results in the following output:

NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART           APP VERSION
server-1        neo4j           1               2024-09-19 20:02:45.05682444 +0000 UTC  deployed        neo4j-5.23      5.23       
server-2        neo4j           1               2024-09-19 20:02:46.814830904 +0000 UTC deployed        neo4j-5.23      5.23       
server-3        neo4j           2               2024-09-19 20:08:15.669412661 +0000 UTC deployed        neo4j-5.23      5.23   
```

2. Let's say we didn't want to deploy the latest version of Neo4j to the nodes (default behavior of the Neo4j helm charts). We can fix this by running an "upgrade" command passing in the version of Neo4j intended for deployment. After the commands are run for each node, then run the "kubectl get pods" command to ensure they are Running:

```bash
helm upgrade server-1 neo4j/neo4j --version 5.20.0 --namespace neo4j -f values.yaml
helm upgrade server-2 neo4j/neo4j --version 5.20.0 --namespace neo4j -f values.yaml
helm upgrade server-3 neo4j/neo4j --version 5.20.0 --namespace neo4j -f values.yaml
```
Then check to ensure pods are running:
```bash
kubectl get pods
```
Lastly, run the helm list to check that they correct version was deployed:
```bash
helm list 

Running the above command results in the following output:

NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART           APP VERSION
server-1        neo4j           2               2024-09-19 20:20:37.104601266 +0000 UTC deployed        neo4j-5.20.0    5.20.0     
server-2        neo4j           2               2024-09-19 20:20:23.134574547 +0000 UTC deployed        neo4j-5.20.0    5.20.0     
server-3        neo4j           4               2024-09-19 20:20:13.178864298 +0000 UTC deployed        neo4j-5.20.0    5.20.0   
```

3. Uninstall a deployment

The following command will uninstall a deployment (run "helm list" to get a list of deployment names):

```bash
helm uninstall server-1
helm uninstall server-2
helm uninstall server-3
```

## Enable SSL


## Upgrade Neo4j Version



