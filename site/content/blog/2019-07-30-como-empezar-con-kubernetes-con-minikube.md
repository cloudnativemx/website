---
title: "Como Empezar Con Kubernetes Usando Minikube"
date: 2019-07-25T00:12:26-07:00
featured_image: /media/2019/07/30/minikube_logo_with_background.jpg
featured_image_source: https://github.com/kubernetes/minikube/blob/master/images/logo/minikube-logo.png
author: marco
url: /como-empezar-con-kubernetes-usando-minikube/
categories:
  - Guide
tags:
  - kubernetes
  - minikube
  - getting-started
---

# Iniciando Kubernetes con [Minikube][minikube]

En respuesta a una de las preguntas que nos hicieron en nuestra comunidad acerca de 
[como aprender sobre docker y kubernetes][pregunta-comunidad] 
se nos ocurrio que en vez de contestarla en nuestro podcast, seria mas conveniente crear series de posts relacionados 
para ayudar a nuestra comunidad, esperamos les agrade y nos dejen comentarios para seguir mejorando el contenido.

---
### ¿Que es Minikube?

Minikube es una herramienta que administra maquinas virtuales en donde corre un cluster o mejor dicho una 
instancia de Kubernetes en un solo nodo. Sin embargo Minikube se apoya de un hypervisor, el cual por 
default es [VirtualBox][] pero no es la unica opcion, lo cual veremos mas adelante.

Entonces Minikube nos ayuda a correr Kubernetes en un simple nodo en nuestra maquina.

### ¿Que necesito para correr Minikube?

- Instalar `kubectl` tienes diferentes [opciones para instalarlo][kubectl-instalation], mi eleccion es 
hacerlo con [brew][homebrew].
- Verificar que tu ambiente de desarrollo soporte virtualizacion, usa esta [liga][before-you-begin] para 
verificar esto.
- Un hypervisor instalado, Minikube suporta varias opciones: 
   - - [VirtualBox][] por default
   - - [HyperKit][]
   - - [KVM2][]
   - - [None][vmdriver-none] esta opcion le especifica a Minikube que corra los componentes directamente en el host,
     osea en tu maquina, tal vez esta no sea una buena idea ya que expone tu systema a posibles vulnerabilidades 
     como por ejemplo con Docker que [permitia ejecutar contenedores sin ser root][docker-security-update]
   - - Hay otras mas opciones que puedes revisar [aqui][vmdrivers]

### ¿Como instalo Minikube?

Para instalarlo hay varias opciones, en esta [guía][minikube-instalation] podrás ver diferentes opciones de acuerdo 
a tu ambiente de desarrollo, en mi caso uso Mac y [brew][homebrew] así que use este comando:

```bash
brew cask install minikube
```

### Iniciando con Minikube

Para iniciar Minikube solo executa:

```bash
minikube start
```

Y veras algo como:

```bash
😄  minikube v1.2.0 on darwin (amd64)
💡  Tip: Use 'minikube start -p <name>' to create a new cluster, or 'minikube delete' to delete this one.
🔄  Restarting existing virtualbox VM for "minikube" ...
⌛  Waiting for SSH access ...
🐳  Configuring environment for Kubernetes v1.15.0 on Docker 18.06.3-ce
🔄  Relaunching Kubernetes v1.15.0 using kubeadm ...
⌛  Verifying: apiserver proxy etcd scheduler controller dns
🏄  Done! kubectl is now configured to use "minikube"
```
Si es la primera vez que inicias Minikube descargara su imagen para ejecutarla en el hypervisor ademas 
creara un perfil para el cluster con el nombre `minikube` por default.

---
Si deseas crear otro cluster usa el parametro `-p` cuando inicies Minikube, lo cual creara otro perfil:

```bash
minikube start -p new-world
```

Salida:
```bash
😄  minikube v1.2.0 on darwin (amd64)
🔥  Creating virtualbox VM (CPUs=2, Memory=2048MB, Disk=20000MB) ...
🐳  Configuring environment for Kubernetes v1.15.0 on Docker 18.09.6
🚜  Pulling images ...
🚀  Launching Kubernetes ...
⌛  Verifying: apiserver proxy etcd scheduler controller dns
🏄  Done! kubectl is now configured to use "new-world"
``` 

Por ahora no hay un comando en Minikube para listar los perfiles existentes, pero podemos verlos listando 
los directorios en `~/.minikube/profiles`:

```bash
ll ~/.minikube/profiles/ 
```

Listado:
```bash
total 0
drwx------  3 markox  staff    96B Jul 28 16:07 minikube
drwx------  3 markox  staff    96B Jul 28 19:36 new-world
```  

---
Con este comando verificas el estado del cluster:
```bash
minikube status
```

Salida:
```bash
host: Running
kubelet: Running
apiserver: Running
kubectl: Correctly Configured: pointing to minikube-vm at 192.168.99.100
```

> NOTAS:
> 
> Si creas un cluster con otro perfil tienes que especificar el nombre del perfil cada vez que ejecutes un comando con minikube
>
> Con la creacion de diferentes perfiles Minikube te permite correr multiples clusters de Kubernetes  

---
Para parar instancias de minikube usas este comando:

```bash
minikube stop
``` 

Salida:
```bash
✋  Stopping "minikube" in virtualbox ...
🛑  "minikube" stopped.
```

---
Para borrar un perfil existente usa:

```bash
minikube delete -p new-world
``` 

Salida:
```bash
🔥  Deleting "new-world" from virtualbox ...
💔  The "new-world" cluster has been deleted.
```

---
### Usando otro hypervisor

Como lo mencionamos al principio Minikube suporta diferentes hypervisors como [HyperKit][] y para ello 
nos encargamos de instalarlo, puedes usar esta [guia para hacerlo][hyperkit-instalation]. En el caso 
de que tengas instalado [Docker Desktop][docker-desktop] ya viene con una version de [HyperKit][] 
el problema es que Minikube busca en tu PATH este binario `docker-machine-driver-hyperkit` entonces lo 
mas conveniente es instalar HyperKit usando este comando:

```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/docker-machine-driver-hyperkit \
&& sudo install -o root -g wheel -m 4755 docker-machine-driver-hyperkit /usr/local/bin/
```

En mi caso si lo intento instalar con brew obtengo este error porque el nombre colisiona con la version 
que Docker desktop instalo:

```bash
Error: The `brew link` step did not complete successfully
The formula built, but is not symlinked into /usr/local
Could not symlink bin/hyperkit
Target /usr/local/bin/hyperkit
already exists. You may want to remove it:
  rm '/usr/local/bin/hyperkit'

To force the link and overwrite all conflicting files:
  brew link --overwrite hyperkit

To list all files that would be deleted:
  brew link --overwrite --dry-run hyperkit

Possible conflicting files are:
/usr/local/bin/hyperkit -> /Applications/Docker.app/Contents/Resources/bin/com.docker.hyperkit
``` 

Asi que use el comando que especifica la [guia][hyperkit-instalation]

Una vez que HyperKit es instalado usamos el parametro `--vm-driver` cuando iniciamos Minikube:

```bash
minikube start -p new-world --vm-driver hyperkit
``` 

Salida:
```bash
😄  minikube v1.2.0 on darwin (amd64)
🔥  Creating hyperkit VM (CPUs=2, Memory=2048MB, Disk=20000MB) ...
🐳  Configuring environment for Kubernetes v1.15.0 on Docker 18.09.6
🚜  Pulling images ...
🚀  Launching Kubernetes ...
⌛  Verifying: apiserver proxy etcd scheduler controller dns
🏄  Done! kubectl is now configured to use "new-world"
```

Si quieres usar por default HyperKit executa este comando para asignarlo como tal

```bash
minikube config set vm-driver hyperkit
```  

---
### Interactuando con Kubernetes

Ya tenemos un cluster de Kubernetes (de un solo nodo) para jugar con el.

Para interactuar con Kubernetes usamos su cliente `kubectl`, mi opcion para instalarlo fue:

```bash
brew install kubernetes-cli
```

---
Primeros comandos, saber la version de nuestro Kubernetes cluster y de `kubectl`:

```bash
kubectl version
``` 

Veras 2 elementos, uno del cliente y otro del servidor 
```bash
Client Version: version.Info{Major:"1", Minor:"15", GitVersion:"v1.15.1", GitCommit:"4485c6f18cee9a5d3c3b4e523bd27972b1b53892", GitTreeState:"clean", BuildDate:"2019-07-18T14:25:20Z", GoVersion:"go1.12.7", Compiler:"gc", Platform:"darwin/amd64"}
Server Version: version.Info{Major:"1", Minor:"15", GitVersion:"v1.15.0", GitCommit:"e8462b5b5dc2584fdcd18e6bcfe9f1e4d970a529", GitTreeState:"clean", BuildDate:"2019-06-19T16:32:14Z", GoVersion:"go1.12.5", Compiler:"gc", Platform:"linux/amd64"}
```

Version corta:

```bash
kubectl version --short
```

Salida:
```bash
Client Version: v1.15.1
Server Version: v1.15.0
```

---
`kubectl` puede acceder a diferentes clusters, para ellos tiene un concepto llamado *context* con lo cual 
`kubectl` a donde conectarse, profundizaremos en esto en otro post, por ahora para saber los contextos que 
`kubectl` tiene executamos este comando:

```bash
kubectl config get-contexts
``` 

Lista de contextos:
```bash
CURRENT   NAME                                       CLUSTER                   AUTHINFO                         NAMESPACE
          kubernetes-the-hard-way                    kubernetes-the-hard-way   admin
          minikube                                   minikube                  minikube
*         new-world                                  new-world                 new-world
```

Ademas de ver el contexto actual en el listado anterior, tambien lo podemos saber en concreto con este comando: 
```bash
kubectl config current-context
```

Salida:
```bash
new-world
```

> NOTA: Cabe señalar que cuando iniciamos minikube, se encarga de configurar `kubectl` automaticamente, 
> por esa razón veras *minikube* y cualquier otro contexto que hayas creado usando los perfiles de *minikube*

--- 
Para obtener información de nuestro cluster:

```bash
kubectl cluster-info
``` 

Salida:
```bash
Kubernetes master is running at https://192.168.64.3:8443
KubeDNS is running at https://192.168.64.3:8443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
```

--- 
Para saber el estado de nuestro cluster de Kubernetes en general:

```bash
kubectl get componentstatuses
```

Salida:
```bash
NAME                 STATUS    MESSAGE             ERROR
controller-manager   Healthy   ok
scheduler            Healthy   ok
etcd-0               Healthy   {"health":"true"}
```

--- 
Para conocer el estado de los pods de los componentes de Kubernetes:

```bash
kubectl get pods -n kube-system
```

Salida:
```bash
NAME                               READY   STATUS    RESTARTS   AGE
coredns-5c98db65d4-ss2g7           1/1     Running   0          68m
coredns-5c98db65d4-x2jsb           1/1     Running   0          68m
etcd-minikube                      1/1     Running   0          67m
heapster-r4wmb                     1/1     Running   0          68m
influxdb-grafana-4ssfs             2/2     Running   0          68m
kube-addon-manager-minikube        1/1     Running   0          67m
kube-apiserver-minikube            1/1     Running   0          68m
kube-controller-manager-minikube   1/1     Running   0          67m
kube-proxy-xlxdp                   1/1     Running   0          68m
kube-scheduler-minikube            1/1     Running   0          68m
metrics-server-84bb785897-hv8gk    1/1     Running   0          68m
storage-provisioner                1/1     Running   0          68m
```

---
### Finalmente

Por ahora lo dejamos hasta aqui para no hacer el post largo, creare mas posts para trabajar 
cosas un poco mas complejas en kubernetes usando Minikube.

Espero les haya agradado y dejen sus comentarios para mejorar el contenido.


[minikube]: https://github.com/kubernetes/minikube
[pregunta-comunidad]: https://www.facebook.com/domix/posts/10157208622688815?comment_id=10157208975498815&comment_tracking=%7B%22tn%22%3A%22R%22%7D
[virtualbox]: https://www.virtualbox.org
[before-you-begin]: https://kubernetes.io/docs/tasks/tools/install-minikube/#before-you-begin
[hyperkit]: https://github.com/moby/hyperkit
[kvm2]: https://github.com/kubernetes/minikube/blob/master/docs/drivers.md#kvm2-driver
[vmdriver-none]: https://github.com/kubernetes/minikube/blob/master/docs/vmdriver-none.md
[docker-security-update]: https://blog.docker.com/2019/02/docker-security-update-cve-2018-5736-and-container-security-best-practices/
[vmdrivers]: https://github.com/kubernetes/minikube/blob/master/docs/drivers.md
[minikube-instalation]: https://kubernetes.io/docs/tasks/tools/install-minikube/
[homebrew]: https://brew.sh
[hyperkit-instalation]: https://github.com/kubernetes/minikube/blob/master/docs/drivers.md#hyperkit-driver
[docker-desktop]: https://www.docker.com/products/docker-desktop
[kubectl-instalation]: https://kubernetes.io/docs/tasks/tools/install-kubectl/