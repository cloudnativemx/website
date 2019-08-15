---
title: "Como cambiar de Container Runtime"
date: 2019-08-12T16:31:31-05:00
featured_image: /media/2019/08/15/minikube_cri-o_containerd_logo.png
featured_image_source: https://github.com/kubernetes/minikube/blob/master/images/logo/minikube-logo.png
author: angelo
url: /como-cambiar-de-container-runtime/
categories:
  - Guide
tags:
  - kubernetes
  - minikube
  - cri-o
  - containerd
  - docker
  - getting-started
---

# Cambiando de Container Runtime

Cuando hablamos de contenedores comúnmente se hace referencia a [Docker][docker] pero esta no es la única opción disponible,
si bien [Docker Inc][docker] fue la compañia que ayudó a popularizar el término de Contenedores 
no es la única herramienta en prestar el servicio de Container Runtime. 

La idea de esta entrada en el blog es conocer las diferentes opciones de Container Runtime 
que existen en el mercado y como configurarlas en nuestro ambiente de Minikube.

Si quieren saber más sobre el tema, sigan la cuenta de Twitter de la Cloud Native para más noticias, guías y meetups.

---
### [Open Containers Iniciative][OCI]

La [Open Containers Iniciative][OCI] (OCI) es una fundación establecida en Junio del 2015 por [Docker Inc][docker], 
[CoreOS][coreOS] y otros líderes de la industria, cuyo objectivo principal es estandarizar el uso de contenedores 
a partir de ciertas especificaciones. La [OCI][OCI] mantiene 2 especificaciones super importantes para la industria: 
**Runtime Specification (runtime-spec)** y **Image Specification (image-spec)**. 

De esta forma se estandaríza el runtime de tu contenedor y el formato de imágenes de los mismos, dando como resultado 
una sana competencia en el mercado. 

Para la plataforma de Kubernetes esta implementación ayuda a poder cambiar de Container Runtime 
sin tener que cambiar tu implementación como veremos a continuación...

### Minikube + [Containerd][containerd]

Por default [minikube][minikube] configura Docker como Container Runtime para levantar minikube con [Containerd][containerd] 
como Container Runtime, debemos de levantar una instancia nueva de minikube con los siguientes parametros:

Nota: Como las pruebas las estoy generando en un equipo con Ubuntu la recomendación es usar KVM2 como Driver 
para las Maquinas Vituales, pero no es necesario para las pruebas. 

```bash
minikube start -p kube-containerd --network-plugin=cni --enable-default-cni --container-runtime=containerd --bootstrapper=kubeadm --vm-driver kvm2
```

Nos regresará la creación de la instancia:

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

Para navegar entre los contextos puedes usar el siguiente comando:

```bash
kubectl config use-context kube-containerd
```

Vamos a generar un sencillo deployment para validar nuestra correcta instalación:

```bash
kubectl run kubernetes-bootcamp --image=gcr.io/google-samples/kubernetes-bootcamp:v1 --port=8080
```

```bash
deployment.apps/kubernetes-bootcamp created
```

A continuación revisamos que todo este OK con nuestro deployment:

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

Aquí podemos observar que en la parte del Container ID nos indica el Container Runtime con el que está corriendo la imagen, 
aunque esta fue construida con Docker 

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

### Minikube + [CRI-O][cri-o]

Para no dejar tambien podemos levantar con [CRI-O][cri-o] que es otro sabor de Container Runtime:

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

### Minikube + [rkt][rkt]

[rkt][rkt] es un Application Container Engine desarrollado por [CoreOS][coreOS] el cual soporta la especificación de 
Container Networking Interface (CNI) y puede correr imagenes de Docker y OCI.

**Lamentablemente el soporte a rkt fue removido de Kubernetes y Minikube en la versión v1.10.0 😿**

---
### Concluciones

Esperamos que esta breve guia les sea de utilidad, recuerden dejar sus comentarios para seguir mejorando.

[docker]: https://www.docker.com/
[coreOS]: https://coreos.com/
[OCI]: https://www.opencontainers.org/
[minikube]: https://github.com/kubernetes/minikube
[containerd]: https://containerd.io/
[cri-o]: https://cri-o.io/
[rkt]: https://coreos.com/rkt/