# JMeter 5.3
## + ElasticSearchBackendListenerClient v2.0

Dockerized JMeter with ElasticsearchBackendListener for live logging.

> Travis:  [![Build Status](https://travis-ci.org/wrongkitchen/jmeter.svg?branch=master)](https://travis-ci.org/wrongkitchen/jmeter) build result of build JMeter with ElasticsearchBackendListener, run Elasticsearch and run test with live logging to Elasticsearch.


## Image based on RHEL Atomic Base Image

-   Version rhel7/rhel-atomic:7.6
-   More information <https://access.redhat.com/containers/?tab=tags&platform=docker#/registry.access.redhat.com/rhel7/rhel-atomic>
-   Documentation <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux_atomic_host/7/html/getting_started_with_containers/using_red_hat_base_container_images_standard_and_minimal#using_rhel_atomic_base_images_minimal>
-   Introducing the Red Hat Enterprise Linux Atomic Base Image <https://rhelblog.redhat.com/2017/03/13/introducing-the-red-hat-enterprise-linux-atomic-base-image/>

## Plugins

    - jpgc-dummy-0.2
    - jpgc-casutg-2.6

## Elasticsearch 6.x

<https://github.com/test-stack/elasticSearchBackendListenerClient>

    ElasticsearchBackendListener

## Notice

When you use RHEL, CentOS, or Fedora, mount volume with `Z` option.

    -v `pwd`:/jmeter:Z

[Using Volumes with Docker can Cause Problems with SELinux](http://www.projectatomic.io/blog/2015/06/using-volumes-with-docker-can-cause-problems-with-selinux/)

## How to run as NON-GUI

### Run without Docker

> jmeter --nongui --testfile testPlan.jmx

### Run with print command line options

    docker run --name jmeter -it --rm wrongkitchen/jmeter:5.3.0

### Run with help

    docker run --name jmeter -it --rm wrongkitchen/jmeter:5.3.0 --help

### Run as interactive

    docker run --name jmeter -it --rm -v `pwd`:/jmeter wrongkitchen/jmeter:5.3.0 --nongui --testfile testPlan.jmx --logfile result.jtl

### Run as detached

    docker run --name jmeter --detach --rm -v `pwd`:/jmeter wrongkitchen/jmeter:5.3.0 --nongui --testfile testPlan.jmx --logfile result.jtl

### Run as specify USER

    docker run --name jmeter -it --rm -v `pwd`:/jmeter --user $(id -u):$(id -g) wrongkitchen/jmeter:5.3.0 --nongui --testfile testPlan.jmx --logfile result.jtl

### Run with log to stdout

    docker run --name jmeter -it --rm -v `pwd`:/jmeter wrongkitchen/jmeter:5.3.0 --nongui --testfile testPlan.jmx -j /dev/stdout

### Run as server / generator

    docker run --name generator1 --detach --publish 1098:1098 --rm wrongkitchen/jmeter:5.3.0 -Jserver.rmi.ssl.disable=true -Djava.rmi.server.hostname=192.168.1.202 -Jserver.rmi.localport=1098 -Dserver_port=1098 --server

> Stopping a server after the end of the test It's possible add this option
> `-Jserver.exitaftertest=true`
>
> ### Connect to generator
>
>     docker run --name controller -it --rm --volume `pwd`:/jmeter wrongkitchen/jmeter:5.3.0 -Jserver.rmi.ssl.disable=true --nongui --testfile testPlan.jmx --remotestart 192.168.1.202:1098,192.168.1.202:1099 --logfile result.jtl

### Generate HTML report after test end

Go to [Documentation](https://jmeter.apache.org/usermanual/generating-dashboard.html)

    docker run --name controller --detach --rm --volume `pwd`:/jmeter wrongkitchen/jmeter:5.3.0 -Jserver.rmi.ssl.disable=true --nongui --testfile testPlan.jmx --logfile result.jtl --forceDeleteResultFile --reportatendofloadtests --reportoutputfolder report   -Jjmeter.reportgenerator.overall_granularity=1000

## 13. Remote Testing with JMeter

Go to [Documentation](https://jmeter.apache.org/usermanual/remote-test.html)

-   Management of multiple JMeterEngines from a single machine
-   No need to copy the test plan to each server - the client sends it to all the servers

> **Important** The same test plan is run by all the servers. JMeter does not distribute the load between servers, each runs the full test plan. So if you set 1000 Threads and have 6 JMeter server, you end up injecting 6000 Threads.
>
> **Warning** Remote mode does use more resources in client. It's reason what JMeter use Stripped mode. Check always JMeter client resources, that is not overloaded.

### Configure nodes

All nodes ( client and servers )

-   are running exactly the same version of JMeter
-   are using the same version of Java on all systems. Using different versions of Java may work but is discouraged.
-   copy of dataProvider ( e.g. csv ) with test-data must be on each JMeter server.
    Advantage is, that each generator can work with unique test-data.

### Start the servers / generators

-   On all servers run JMeter in remote node `--server`
-   Note that there can only be one JMeter server on each node unless different RMI ports are used.
-   By default, RMI uses dynamic ports for the JMeter server engine. This can cause problems for firewalls, so you can define the JMeter property `server.rmi.localport` to control this port numbers.
-   command line option for specify the remote hosts to us is `--remotestart`. Multiple servers can bbe added, comma-delimited.

### Environment variables

-   HEAP `"-JXms2g -JXmx2g -JX:MaxMetaspaceSize=500m"`
-   GC_ALGO
    JVM garbage collector options. Defaults to `-XX:+UseG1GC -XX:MaxGCPauseMillis=250 -XX:G1ReservePercent=20`

> Get the list of ip addresses `docker inspect --format '{{ .Name }} => {{ .NetworkSettings.IPAddress }}' $(docker ps -a -q)`

## VNC

Run docker image

```
docker run --name jmeter -it -v `pwd`:/tests --rm -p 5901:5901 wrongkitchen/jmeter:vnc-5.3.0
```

and connect via some VNC Viewer to `localhost:5901` and password is `secret`


# k8s

Create config object

```
kubectl -n loadtest-1 apply -f k8s/jmeter-configmap.yaml
```

Start Performance Stack

```
kubectl -n loadtest-1 create -f k8s/perf-stack.yaml
```

Port Forward for VNC Viewer

```
kubectl -n loadtest-1 port-forward controller-0 5901:5901
```
> Now, you can connect to controller via your favorite VNC Viewer `localhost:5901`

On Desktop you can use scripts

- `run-editor.sh` Start JMeter
- `run-distrib-test.sh` Start Distributed testing


# Perf Demo Web

```
docker run --name test-web --rm -p 8080:80 -d wrongkitchen/test-web:1.0
```


## Docker Compose

> Define a run multiple containers

-   For JMeter distributed load testing, we need run 1 master and N slave containers.

# Useful links

-   [Running a Docker container as a non-root user](https://medium.com/redbubble/running-a-docker-container-as-a-non-root-user-7d2e00f8ee15)
-   [Running Your Images as a Non-Root User](https://github.com/openshift-evangelists/openshift-workshops/blob/master/modules/run-as-non-root.adoc)
