# spire-tutorials

Example files referenced by the tutorials at https://spiffe.io

---
** NOTE **
It is temporal we will remove all steps and add link to tutorial.
---

---
** IMPORTANT **
Replace example.org for a valid trustdomain in all yamls and entries
---

# Installation steps:

## Create namespace
```
$ kubectl apply -f spire-namespace.yaml
```

## Create Server Bundle Configmap, Role & ClusterRoleBinding
```
$ kubectl apply \
    -f server-account.yaml \
    -f spire-bundle-configmap.yaml \
    -f server-cluster-role.yaml
``` 

## Create OIDC provider config map
```    
$ kubectl apply \
    -f oidc-dp-configmap.yaml
```

## Create Server Configmap, and deploy SPIRE Server with services
```
$ kubectl apply \
    -f server-configmap.yaml \
    -f server-statefulset.yaml \
    -f server-service.yaml
```

## Create oidc service and ingress
```
$ kubectl apply \
    -f server-oidc-service.yaml \
    -f ingress.yaml 
 ```

## Verify server is working 
```
$ kubectl get statefulset --namespace spire
```

## Verify service external-ip
`spire-oidc` must provide an external-ip, to be able to connect AWS with OIDC Provider, that IP be used in a dns 
```
$ kubectl get service -n spire
```

## Create agent service account and role
```
$ kubectl apply \
    -f agent-account.yaml \
    -f agent-cluster-role.yaml
```

## Create agent config map and deploy
```
$ kubectl apply \
    -f agent-configmap.yaml \
    -f agent-daemonset.yaml
```

## Verify agent is running 
```
$ kubectl get daemonset --namespace spire
```

## Registry entries

### Agent node 
---
**NOTE**
Replace `example.org` with your trust domain
---
```
$ kubectl exec -n spire spire-server-0 -c spire-server -- \
    /opt/spire/bin/spire-server entry create \
    -parentID spiffe://example.org/spire/server \
    -spiffeID spiffe://example.org/ns/spire/sa/spire-agent \
    -selector k8s_sat:agent_ns:spire \
    -selector k8s_sat:agent_sa:spire-agent \
    -registrationUDSPath /run/spire/sockets/registration.sock \
    -node
```

### Workload
```
$ kubectl exec -n spire spire-server-0 -c spire-server -- \
    /opt/spire/bin/spire-server entry create \
    -parentID spiffe://example.org/ns/spire/sa/spire-agent \
    -spiffeID spiffe://example.org/workload \
    -registrationUDSPath /run/spire/sockets/registration.sock \
    -selector k8s:ns:default \
    -selector k8s:sa:default
```

## Create Client
```
$ kubectl apply -f client-deployment.yaml
```

## Test AWS

### Connect client

Get:
$ kubectl get pods 

output:
```
$ kubectl get pods
NAME                      READY   STATUS    RESTARTS   AGE
client-74d4467b44-7nrs2   1/1     Running   0          27s
```

Go into:
```
$ kubectl exec -it client-74d4467b44-7nrs2 /bin/sh
```

### Get token
I will fetch for an jwt svid and create a `token` file that includes only token from it.
**replace `mys3` with your Authentication provider audience**
```
$ /opt/spire/bin/spire-agent api fetch jwt -audience mys3 -socketPath /run/spire/sockets/agent.sock | sed '2q' | sed 's/[[:space:]]//g' > token
```

### Access to aws
It will connect to aws s3 using token from fetched svid
***
replace:
- `${ROLE-NAME-ARN}` with your role arn on aws
- `s3://oidc-federation-test/test.txt test.txt` replace with your configured s3 bucket
***

```
$ AWS_ROLE_ARN=${ROLE-NAME-ARN} AWS_WEB_IDENTITY_TOKEN_FILE=token aws s3 cp s3://oidc-tutorial-bucket/test.txt test.txtt
```

## Clean

### Delete client namespace
```
$ kubectl delete deployment client
```

### Delete spire namespace
```
$ kubectl delete namespace spire
```