---
title: "Como cambiar de Container Runtime"
date: 2019-08-12T16:31:31-05:00
author: angelo
url: /como-cambiar-de-container-runtime/
categories:
  - Guide
tags:
  - kubernetes
  - minikube
  - rkt
  - containerd
  - docker
  - getting-started
---

# Cambiando de Container Runtime

Cuando hablamos de contenedores siempre hacemos referencia a Docker pero no es la única opción disponible,
si bien Docker Inc como compañia ha contribuido a generar un estandar Open Containers Iniciative (OCI)
no es la única herramienta en prestar el servicio de Container Runtime. 

La idea de esta entrada en el blog es conocer las diferentes opciones de Container Runtime 
que existen en el mercado y como configurarlas en nuestro ambiente de Minikube

Si quieren saber más sobre el tema, sigan la cuenta de Twitter de la Cloud Native para más noticias, guías y meetups.

---
### ¿Que es la Open Containers Iniciative ?

Es una fundación establecida en Junio del 2015 por Docker Inc, CoreOS y otros lideres de la industria de contenedores, 
la OCI mantiene 2 especificaciones super importantes para la industria de contenedores: **Runtime Specification (runtime-spec)** 
y **Image Specification (image-spec)**. 

El primero estandariza la implementación del Container Runtime de esta forma tu puedes elegir tu Vendor de contenedores 
sin tener que cambiar tu implementación y el segundo estandariza el formato de imagenes.

### Minikube + Docker

Para la instalación de minikube puedes seguir los pasos detallados en este post.

Por default minikube configura Docker como Container Runtime:

```bash
minikube start
```

```bash
😄  minikube v1.3.1 on Ubuntu 18.04
👍  Upgrading from Kubernetes 1.15.0 to 1.15.2
💡  Tip: Use 'minikube start -p <name>' to create a new cluster, or 'minikube delete' to delete this one.
🔄  Starting existing kvm2 VM for "minikube" ...
⌛  Waiting for the host to be provisioned ...
🐳  Preparing Kubernetes v1.15.2 on Docker 18.09.6 ...
🚜  Pulling images ...
🔄  Relaunching Kubernetes using kubeadm ... 
⌛  Waiting for: apiserver proxy etcd scheduler controller dns
🏄  Done! kubectl is now configured to use "minikube"
```

### Minikube + Containerd

Para levantar minikube con Containerd como Container Runtime debemos de correr el siguiente comando:

```bash
minikube start -p kube-containerd --network-plugin=cni --enable-default-cni --container-runtime=containerd --bootstrapper=kubeadm --vm-driver kvm2
```

Nos regresará algo así:

```bash
😄  [kube-containerd] minikube v1.3.1 on Ubuntu 18.04
🔥  Creating kvm2 VM (CPUs=2, Memory=2000MB, Disk=20000MB) ...
📦  Preparing Kubernetes v1.15.2 on containerd 1.2.6 ...
💾  Downloading kubeadm v1.15.2
💾  Downloading kubelet v1.15.2
🚜  Pulling images ...
🚀  Launching Kubernetes ... 
⌛  Waiting for: apiserver etcd scheduler controller
🏄  Done! kubectl is now configured to use "kube-containerd"
```

Para ver los diferentes contextos de minikube puedes listarlos con el siguiente comando:

```bash
kubectl config get-contexts
```

```bash
CURRENT   NAME              CLUSTER           AUTHINFO          NAMESPACE
          kube-containerd   kube-containerd   kube-containerd   
*         minikube          minikube          minikube          
          new-world         new-world         new-world         
```

Con el siguiente comando podrás cambiar de contexto:

```bash
kubectl config use-context CONTEXT_NAME
```

Para poder corroborar que nuestro Container runtime vamos a levantar un deployment muy sencillo:

```bash
kubectl run kubernetes-bootcamp --image=gcr.io/google-samples/kubernetes-bootcamp:v1 --port=8080
```

```bash
deployment.apps/kubernetes-bootcamp created
```

Para comprobar que nuestro deployment se genero correctamente lo revisamos:

```bash
kubectl get deployments,pods
```

```bash
NAME                                        READY   UP-TO-DATE   AVAILABLE   AGE
deployment.extensions/kubernetes-bootcamp   1/1     1            1           101s

NAME                                       READY   STATUS    RESTARTS   AGE
pod/kubernetes-bootcamp-5b48cfdcbd-6w7pp   1/1     Running   0          101s
```

Para comprobar que el Container Runtime es el indicado hacemos un describe sobre el pod:

```bash
kubectl describe pods 
```

```bash
Name:           kubernetes-bootcamp-5b48cfdcbd-6w7pp
Namespace:      default
Priority:       0
Node:           minikube/192.168.122.98
Start Time:     Wed, 14 Aug 2019 11:20:00 -0500
Labels:         pod-template-hash=5b48cfdcbd
                run=kubernetes-bootcamp
Annotations:    <none>
Status:         Running
IP:             10.1.0.5
Controlled By:  ReplicaSet/kubernetes-bootcamp-5b48cfdcbd
Containers:
  kubernetes-bootcamp:
    Container ID:   containerd://e118253a2b7a5bb040700e3018022d673cbd0b5db23e9c4be2b41e43f12fabf0
    Image:          gcr.io/google-samples/kubernetes-bootcamp:v1
    Image ID:       docker.io/jocatalin/kubernetes-bootcamp@sha256:0d6b8ee63bb57c5f5b6156f446b3bc3b3c143d233037f3a2f00e279c8fcc64af
    Port:           8080/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Wed, 14 Aug 2019 11:20:03 -0500
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-zn68f (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  default-token-zn68f:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  default-token-zn68f
    Optional:    false
QoS Class:       BestEffort
Node-Selectors:  <none>
Tolerations:     node.kubernetes.io/not-ready:NoExecute for 300s
                 node.kubernetes.io/unreachable:NoExecute for 300s
Events:
  Type    Reason     Age    From               Message
  ----    ------     ----   ----               -------
  Normal  Scheduled  2m51s  default-scheduler  Successfully assigned default/kubernetes-bootcamp-5b48cfdcbd-6w7pp to minikube
  Normal  Pulling    2m49s  kubelet, minikube  Pulling image "gcr.io/google-samples/kubernetes-bootcamp:v1"
  Normal  Pulled     2m48s  kubelet, minikube  Successfully pulled image "gcr.io/google-samples/kubernetes-bootcamp:v1"
  Normal  Created    2m48s  kubelet, minikube  Created container kubernetes-bootcamp
  Normal  Started    2m48s  kubelet, minikube  Started container kubernetes-bootcamp

```

### Minikube + CRI-O

Para no dejar tambien podemos levantar con CRI-O que es otro sabor de Container Runtime:

```bash
minikube start -p kube-cri-o --network-plugin=cni --enable-default-cni --container-runtime=cri-o --bootstrapper=kubeadm --vm-driver kvm2
```

Nos regresará algo así:

```bash
😄  [kube-cri-o] minikube v1.3.1 on Ubuntu 18.04
⚠️  Error checking driver version: exit status 1
🔥  Creating kvm2 VM (CPUs=2, Memory=2000MB, Disk=20000MB) ...
🎁  Preparing Kubernetes v1.15.2 on CRI-O 1.15.0 ...
🚜  Pulling images ...
🚀  Launching Kubernetes ... 
⌛  Waiting for: apiserver etcd scheduler controller
🏄  Done! kubectl is now configured to use "kube-cri-o"
```

Levantamos el Deployment

```bash
kubectl run kubernetes-bootcamp --image=gcr.io/google-samples/kubernetes-bootcamp:v1 --port=8080
```

Y comprobamos el Container Runtime:

```bash
kubectl describe pods 
```

```bash
Name:           kubernetes-bootcamp-5b48cfdcbd-zxzjd
Namespace:      default
Priority:       0
Node:           minikube/192.168.122.33
Start Time:     Wed, 14 Aug 2019 11:53:29 -0500
Labels:         pod-template-hash=5b48cfdcbd
                run=kubernetes-bootcamp
Annotations:    <none>
Status:         Running
IP:             10.1.0.4
Controlled By:  ReplicaSet/kubernetes-bootcamp-5b48cfdcbd
Containers:
  kubernetes-bootcamp:
    Container ID:   cri-o://84708f7b15deb0c2022b873ca5e084806f8eddc55072dcc1daad2786e91a5b36
    Image:          gcr.io/google-samples/kubernetes-bootcamp:v1
    Image ID:       gcr.io/google-samples/kubernetes-bootcamp@sha256:0d6b8ee63bb57c5f5b6156f446b3bc3b3c143d233037f3a2f00e279c8fcc64af
    Port:           8080/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Wed, 14 Aug 2019 11:53:42 -0500
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-vw2dp (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  default-token-vw2dp:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  default-token-vw2dp
    Optional:    false
QoS Class:       BestEffort
Node-Selectors:  <none>
Tolerations:     node.kubernetes.io/not-ready:NoExecute for 300s
                 node.kubernetes.io/unreachable:NoExecute for 300s
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  76s   default-scheduler  Successfully assigned default/kubernetes-bootcamp-5b48cfdcbd-zxzjd to minikube
  Normal  Pulling    74s   kubelet, minikube  Pulling image "gcr.io/google-samples/kubernetes-bootcamp:v1"
  Normal  Pulled     63s   kubelet, minikube  Successfully pulled image "gcr.io/google-samples/kubernetes-bootcamp:v1"
  Normal  Created    63s   kubelet, minikube  Created container kubernetes-bootcamp
  Normal  Started    63s   kubelet, minikube  Started container kubernetes-bootcamp
```

### Minikube + rkt

rkt es un Application Container Engine desarrollado por CoreOS el cual soporta la especificación de 
Container Networking Interface (CNI) y puede correr imagenes de Docker y OCI.

**Lamentablemente el soporte a rkt fue removido de Kubernetes y Minikube en la versión v1.10.0 😿**

---
### Concluciones

Esperamos que esta breve guia les sea de utilidad, recuerden dejar sus comentarios para seguir mejorando.

[minikube]: https://github.com/kubernetes/minikube