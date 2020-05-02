---
title: "Segunda parte Kubernetes Usando Minikube"
date: 2019-08-27T00:00:00-07:00
feature_image: /media/2019/08/27/kubernetes_and_minikube.jpg
featured_image_source: https://github.com/kubernetes/minikube/blob/master/images/logo/minikube-logo.png, https://unsplash.com/photos/_wSP_ts1CRA
author: marco
url: /segunda-parte-kubernetes-usando-minikube/
categories:
  - Guide
tags:
  - kubernetes
  - minikube
  - getting-started
---

# Segunda parte Kubernetes usando [Minikube][minikube]

Este post es la continuación de este post [Como empezar con Kubernetes usando Minikube][como-empezar-con-kubernetes-usando-minikube], pero ahora mostraremos otras funcionalidades de [Minikube][] y empezaremos a hacer mas cosas con Kubernetes, por cierto les agradecemos por la contribución de nuestra comunidad  de esta guía para usar diferentes [Container runtimes][cambiar-container-runtime] en [Minikube][]

Veamos algunos otros comandos disponibles in [Minikube][].

---
### minikube dashboard

Este comando brinda acceso al tablero de Kubernetes que correr dentro de nuestra instancia de [Minikube][], 
el comando abrira una ventana en tu navegador para mostart el tablero de Kubernetes.

```bash
minikube dashboard
```

output:
```bash
🤔  Verifying dashboard health ...
🚀  Launching proxy ...
🤔  Verifying proxy health ...
🎉  Opening http://127.0.0.1:54775/api/v1/namespaces/kube-system/services/http:kubernetes-dashboard:/proxy/ in your default browser...
```

Si ya tienes algunos pods en tu instancia podras verlos en el tablero, sino corre este comando para crear un deployment de nginx con 2 replicas:

```bash
kubectl run mi-primer-deployment --restart=Always --image=nginx:1.17.3 --replicas=2
```

Ahora ve al tablero y veras tu deployment en la seccion de Deployments y abajo los 2 pods, explora el tablero con el 
podras ver los recursos de Kubernetes como Namespaces, Nodes, Persistenr Volumes, etc. Puedes filtrar por namespace para 
ver los objetos en tal Namespace. Esta es la forma visual con la cual puedes visualizar tus recursos en tu cluster, para clusters en la nube tambien esta disponible, algunos proveedores lo tienen disponible como Google Cloud Platform (GCP) o Azure, para AWS no es asi y solo muestran un simple dashboard sobre el estado de tu cluster. Algo a consiserar es la exposición de tu tablero al internet, siempre es bueno restringirlo como a la red de tu oficina estando conectado a ella fisicamente o usando algun service de VPN, tambien generar roles para asignarlos las personas adecuadas.

---
### minikube addons

[Minikube][] suporta addons para agregar mas funcionalidad, para mostrar los que actualmente soporta executa el siguiente comando: 

```bash
minikube addons list
```

Lista de addons:
```bash
- addon-manager: enabled
- dashboard: enabled
- default-storageclass: enabled
- efk: disabled
- freshpod: disabled
- gvisor: disabled
- heapster: enabled
- ingress: disabled
- logviewer: disabled
- metrics-server: enabled
- nvidia-driver-installer: disabled
- nvidia-gpu-device-plugin: disabled
- registry: disabled
- registry-creds: disabled
- storage-provisioner: enabled
- storage-provisioner-gluster: disabled
```

Para habilitar algun addon:

```bash 
minikube addons enable heapster
```

Output:
```bash
✅  heapster was successfully enabled
```

Para deshabilitar: 

```bash
minikube addons disable heapster
```

Output:
```bash
✅  "heapster" was successfully disabled
```

Ahora con Heapster habilitado podemos hacer uso de mas resoursos en nuestro cluster:

```bash
kubectl top pods
```

Output:
```bash
NAME                                    CPU(cores)   MEMORY(bytes)
mi-primer-deployment-7f86999b4c-bxvx6   0m           2Mi
mi-primer-deployment-7f86999b4c-qtmqn   0m           2Mi
```

Ahora revisando los nodos:

```bash
kubectl top nodes
```

Output:
```bash
NAME       CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%
minikube   125m         6%     1320Mi          69%
```

---
### minikube ip

Este comando muestra la IP de nuestro minikube cluster, entonces podemos intentar hacer llamadas al API server de Kubernetes, 
para ello tenemos que usar el certificado, la llave y la autoridad que emitio dichos certificados y llaves publicas, 
como mencionamos en nuestro pasado post [Como empezar con Kubernetes usando Minikube][como-empezar-con-kubernetes-usando-minikube], Minikube se encarga de generar y configurar dichos certificados y llaves, ahora como nos queremos comunicar con el API server tenemos que usar el ese certificado y su llave.

Ahora para saber que pods estan corriendo en el default namespace tenemos que llamar el siguiente endpoint `/api/v1/namespaces/default/pods`; entonces el comando completo es:

```bash
curl --cacert ~/.minikube/ca.crt --cert ~/.minikube/apiserver.crt --key ~/.minikube/apiserver.key https://$(minikube ip):8443/api/v1/namespaces/default/pods
```

El resultado es un json con información de tus pods, no muestro la salida porque el json es enorme, pero seguro veras la respuesta json.

Para saber otros endpoints revisa la [documentación de referencia][kubernetes-api]


---
### minikube logs

Para saber que esta pasando en nuestro Minikube cluster podemos ver los logs:

```bash
minikube logs -f
```


---
### minikube service

Con este comando [Minikube][] te muestra las URL de sus servicios de tu cluster, este comando tiene varios sub-comandos.

Para mostrar los servicios que tienes usa:

```bash
minikube service list
```

Y veras todos los servicios expuestos:

```bash
|---------------|-----------------------|-----------------------------|
|   NAMESPACE   |         NAME          |             URL             |
|---------------|-----------------------|-----------------------------|
| default       | kubernetes            | No node port                |
| kube-system   | heapster              | No node port                |
| kube-system   | kube-dns              | No node port                |
| kube-system   | kubernetes-dashboard  | No node port                |
| kube-system   | monitoring-grafana    | http://192.168.99.100:30002 |
| kube-system   | monitoring-influxdb   | No node port                |
|---------------|-----------------------|-----------------------------|
```

Para exponer nuestro deployment creado anteriormente:

```bash
kubectl expose deployment mi-primer-deployment --type=NodePort --port=80
```

Verificamos nuestro service:

```bash
kubectl get services
```

Output:
```bash
NAME                  TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
kubernetes            ClusterIP   10.96.0.1      <none>        443/TCP        118d
mi-primer-deployment  NodePort    10.103.32.75   <none>        80:31268/TCP   19m
```

Ahora para saber cual es la URL de nuestro service:

```bash
minikube service mi-primer-deployment
```

Output:
```bash
|-----------|----------------------|-----------------------------|
| NAMESPACE |         NAME         |             URL             |
|-----------|----------------------|-----------------------------|
| default   | mi-primer-deployment | http://192.168.99.100:31268 |
|-----------|----------------------|-----------------------------|
🎉  Opening kubernetes service  default/mi-primer-deployment in default browser...
```

Y como lo mentiona la salida, abrira tu navegador con la pagina por default de Ngixn.

Si observas la IP es exactamente igual a la que obtenemos con *minikube ip* pero 
diferente a la que vemos de nuestro service (10.103.32.75) esto es porque la IP 
de nuestro service pertenece a la red interna de nuestro cluster.

Por ahora no iremos a los detalles sobre la exposición de nuestro deployment y 
porque cuando lo hicimos especificamos que el tipo sea un NodePort ya que lo haremos 
en otro post totalmente dedicado a services


---
### minikube docker-env

Este comando nos permitira tener acceso al Docker deamon que esta corriendo dentro de 
[Minikube][], si lo corremos generará unas variables de ambiente de Docker

```bash
minikube docker-env
```

Output:
```bash
export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="tcp://192.168.99.100:2376"
export DOCKER_CERT_PATH="/Users/markox/.minikube/certs"
# Run this command to configure your shell:
# eval $(minikube docker-env)
```

Como lo menciona la salida puedes evaluar la salida del comando para configurar automaticamente 
las variables, asegurate de tener instalado el cliente de Docker y no tener 
corriendo el servidor Docker en tu maquina.

Entonces:

```bash
eval $(minikube docker-env)
```

Y con ellos puedes ejecutar cualquier comando de Docker y tendras acceso al 
Docker que corre dentro de Minikube

```bash
docker image ls
```

Output:
```
EPOSITORY                                   TAG                 IMAGE ID            CREATED             SIZE
nginx                                        1.17.3              5a3221f0137b        11 days ago         126MB
k8s.gcr.io/kube-proxy                        v1.15.2             167bbf6c9338        3 weeks ago         82.4MB
k8s.gcr.io/kube-scheduler                    v1.15.2             88fa9cb27bd2        3 weeks ago         81.1MB
k8s.gcr.io/kube-apiserver                    v1.15.2             34a53be6c9a7        3 weeks ago         207MB
k8s.gcr.io/kube-controller-manager           v1.15.2             9f5df470155d        3 weeks ago         159MB
k8s.gcr.io/kube-proxy                        v1.15.0             d235b23c3570        2 months ago        82.4MB
k8s.gcr.io/kube-apiserver                    v1.15.0             201c7a840312        2 months ago        207MB
k8s.gcr.io/kube-controller-manager           v1.15.0             8328bb49b652        2 months ago        159MB
```

La salida es solo una version muy pequeña de lo que obtuve en mi consola, veras diferentes versiones 
de los componentes si haz actualizado tu Minikube.

Ahora intenta correr este comando para ver los contenedores corriendo en tu cluster Minikube:

```bash
docker ps
```


---
### minikube ssh

Por ultimo este comando nos permite log in dentro de nuestro cluster de Minikube 

```bash
minikube ssh
```

Output:
```bash
                         _             _
            _         _ ( )           ( )
  ___ ___  (_)  ___  (_)| |/')  _   _ | |_      __
/' _ ` _ `\| |/' _ `\| || , <  ( ) ( )| '_`\  /'__`\
| ( ) ( ) || || ( ) || || |\`\ | (_) || |_) )(  ___/
(_) (_) (_)(_)(_) (_)(_)(_) (_)`\___/'(_,__/'`\____)

$
```

Puedes probar los comandos anteriores de Docker y funcionaran sin problema, 
otra prueba es intentar llamar a nuestro Nginx de **mi-primer-deployment**, 
en este caso porque estamos dentro de nuestro cluster le podemos pegar directo
a la IP de nuestro service, en mi caso es `10.103.32.75`:

```bash
wget -O - 10.103.32.75
```

Y veras la pagina por default de Nginx


---
### Finalmente

Espero les haya agradado esta mini guía, si les interesa algo mas sobre [Minikube][]
dejenos sus comentarios en nuestras redes.

Por ahora nos enfocaremos a Kubernetes en nuestros siguientes posts, espero no 
tardarme tanto para el siguiente.


[minikube]: https://github.com/kubernetes/minikube
[como-empezar-con-kubernetes-usando-minikube]: https://cloudnative.mx/como-empezar-con-kubernetes-usando-minikube/
[cambiar-container-runtime]: https://cloudnative.mx/como-cambiar-de-container-runtime/
[kubernetes-api]: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.15/