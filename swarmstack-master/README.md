<img align="right" src="https://raw.githubusercontent.com/swarmstack/swarmstack/master/documentation/logos/swarmstack150x150.png"> A starting point for the installation, maintenance, operation, and monitoring of your highly-available Docker swarm-based containerized applications. Features a modern DevOps toolset (Prometheus / Alertmanager / Grafana) for monitoring and alerting. Optional: Docker swarm node management including automatic installation of Docker swarm nodes or onboarding of existing swarms, stable highly-available persistent storage for your containers, firewall management, HTTPS by default, LDAP and web-proxied network support, dynamic swarm service discovery and monitoring using swarm service labels, and other HA features that your applications can take advantage of. Installation requires only cut and paste of a few commands and editing some documented files.

 
<!-- TOC -->

- [swarmstack introduction video](https://youtu.be/3FpTcVnvfRg)
    - [FEATURES](#features)
    - [WHY?](#why)
    - [REQUIREMENTS](#requirements)
    - [INSTALLATION](#installation)
        - [Updating](#updating)
    - [MONITORING ALERTING AND LOGGING](#monitoring-alerting-and-logging)
        - [Monitoring](#monitoring)
        - [Alerting](#alerting)
        - [Logging](#logging)
    - [SCALING](#scaling)
    - [NETWORK URLs](#network-urls)
    - [SCREENSHOTS](#screenshots)
        - [Caddy Link Dashboard](#caddy-link-dashboard)
        - [Grafana Dashboards List](#grafana-dashboards-list)
        - [Grafana - Docker Swarm Nodes](#grafana---docker-swarm-nodes)
        - [Grafana - Docker Swarm Services](#grafana---docker-swarm-services)
        - [Grafana - etcd](#grafana---etcd)
        - [Grafana - Portworx Cluster Status](#grafana---portworx-cluster-status)
        - [Grafana - Portworx Volume Status](#grafana---portworx-volume-status)
        - [Grafana - Prometheus Stats](#grafana---prometheus-stats)
        - [Alertmanager](#alertmanager)
        - [Portainer - Cluster Visualizer](#portainer---cluster-visualizer)
        - [Portainer - Dashboard](#portainer---dashboard)
        - [Portainer - Stacks](#portainer---stacks)
        - [Prometheus - Graphs](#prometheus---graphs)
        - [Prometheus - Alerts](#prometheus---alerts)
        - [Prometheus - Targets](#prometheus---targets)
    - [VIDEOS](#videos)
    - [CREDITS](#credits)

<!-- /TOC -->

Easily deploy and update Docker swarm nodes as you scale up from at least (3) baremetal servers, AWS/GCE/etc instances, virtual machine(s) or just a single macOS laptop if you really need to, which will host your monitored containerized applications.

Manage one or more Docker swarm clusters via ansible playbooks that can _(optionally)_ help you install and maintain Docker swarm clusters and their nodes, automatically install [Portworx](https://portworx.com) Developer or Enterprise persistent storage for your application's HA container volumes replicated across your swarm nodes, and also automatically update firewall configurations on all of your nodes.

swarmstack includes a modern DevOps workflow for monitoring and alerting about your containerized applications running within Docker swarms, including monitoring and alerting of the cluster health itself as well as the health of your own applications. swarmstack installs and updates [Prometheus](https://github.com/prometheus/prometheus/blob/master/README.md) + [Grafana](https://grafana.com) + [Alertmanager](https://github.com/prometheus/alertmanager/blob/master/README.md). swarmstack also provides an optional installation of [Portworx](https://portworx.com) for persistent storage for containers such as databases that need storage that can move to another Docker swarm node instantly, or bring your own persistent storage layer for Docker (e.g. [RexRay](https://github.com/rexray/rexray), or use local host volumes and add placement constraints to _[docker-compose.yml](https://github.com/swarmstack/swarmstack/blob/master/docker-compose.yml)_) 

The included Grafana dashboards will help you examine the health of the cluster, and the same metrics pipeline can easily be used by your own applications and visualized in Grafana and/or alerted upon via Prometheus rules and sent to redundant Alertmanagers to perform slack/email/etc notifications.

For an overview of the flow of metrics into Prometheus, exploring metrics using the meager PromQL interface Prometheus provides, and ultimately using Grafana and other visualizers to create dashboards while using the Prometheus time-series database as a datasource, watch [Monitoring, the Prometheus way](https://www.youtube.com/watch?v=PDxcEzu62jk), read at [Prometheus: Monitoring at SoundCloud](https://developers.soundcloud.com/blog/prometheus-monitoring-at-soundcloud) and watch [How Prometheus Revolutionized Monitoring at SoundCloud](https://youtu.be/hhZrOHKIxLw).

![](https://raw.githubusercontent.com/swarmstack/swarmstack/master/documentation/screens/swarmstack-diagram.png "swarmstack architecture")

---

## FEATURES

A set of ansible playbooks and a docker-compose stack that:

- Tunes EL7 [sysctls](https://raw.githubusercontent.com/swarmstack/swarmstack/master/ansible/playbooks/includes/tasks/sysctl_el7.yml) for optimal network performance
- _(optional: Docker)_ Installs and configures a 3+ node Docker swarm cluster from minimal EL7 hosts (or use existing swarm)
- _(optional: etcd)_ Installs and configures a 3-node etcd cluster, used by Portworx for cluster metadata
- _(optional: Portworx)_ Installs and configures 1 or several 3-node Portworx high availability storage clusters across your nodes. Default: px-dev (px-developer free license) ([licensing](https://docs.portworx.com/reference/knowledge-base/px-licensing/)), 5M+ pulls and exceptionally stable
- _(DevOps: swarmstack)_ Configures and deploys the swarmstack tool chain, including Prometheus and Pushgateway, redundant Alertmanager instances, Grafana, karma, and Portainer containers, and also installs NetData under systemd on each host. All tools are secured using HTTPS by a Caddy reverse-proxy.

Optional

- [Errbot](https://github.com/swarmstack/errbot-docker) - Connect alerts to social rooms to not already natively supported by Alertmanager
- [InfluxDB](https://github.com/swarmstack/influxdb) - [deprecated] Useful for longer-term Prometheus storage/retrieval in certain workloads
- [Loki](https://github.com/swarmstack/loki) - Like Prometheus but for logs
- [TeamPass](https://github.com/swarmstack/teampass) - Secure collaborative team management for shared credentials
- [Trickster](https://github.com/swarmstack/trickster) - In-memory Prometheus data cache for frequently re-requested tsdb blocks (accelerator for Grafana if you have popular dashboards)
- [VictoriaMetrics](https://github.com/swarmstack/victoria-metrics) - Fast, cost-effective and scalable time series database, long-term remote storage for Prometheus

---

## WHY? 

A modern data-driven monitoring and alerting solution helps even the smallest of DevOps teams to develop and support containerized applications, and provides an ability to observe how applications perform over time, correlated to events occuring on the platform running them as well. Data-driven alerting makes sure the team knows when things go off-the-rails via alerts, but Prometheus also brings with it an easier way for you and your team to create alerts for applications, based on aggregated time-aware queries. For example:

```
alert: node_disk_fill_rate_6h
expr: predict_linear(node_filesystem_free{mountpoint="/"}[1h],
  6 * 3600) * on(instance) group_left(node_name) node_meta < 0
for: 1h
labels:
  severity: critical
annotations:
  description: Swarm node {{ $labels.node_name }} disk is going to fill up in 6h.
  summary: Disk fill alert for Swarm node '{{ $labels.node_name }}'
```

Learn how to add your own application metrics and alerts here: [How to Export Prometheus Metrics from Just About Anything - Matt Layher, DigitalOcean](https://www.youtube.com/watch?v=Zk09Mbu0YQk) or head straight to the existing Prometheus [client libraries](https://prometheus.io/docs/instrumenting/clientlibs/).

Grafana lets you visualize the metrics being collected into the Prometheus TSDB. You can build new chart/graph/table visualizations of your own application metrics using the same Prometheus data-source. Some default visualizations in Grafana are provided to help your team stay aware of the Docker swarm cluster health, and to dig into and explore what your containers and their volumes are doing:

![](https://raw.githubusercontent.com/swarmstack/swarmstack/master/documentation/screens/Cluster_Nodes.png)

Portworx provides a high-availability storage solution for containers that seeks to eliminate "ERROR: volume still attached to another node" situations that can be encountered with block device pooling storage solutions, [situations can arise](https://portworx.com/ebs-stuck-attaching-state-docker-containers/) such as RexRay or EBS volumes getting stuck detaching from the old node and can't be mounted to the new node that a container moved to. Portworx replicates volumes across nodes in real-time so the data is already present on the new node when the new container starts up, speeding service recovery and reconvergence times.

![](https://raw.githubusercontent.com/portworx/px-dev/master/images/mysql.png "Portworx replicating volumes")

---

## REQUIREMENTS

There is a [docker-compose-singlebox.yml](https://github.com/swarmstack/swarmstack/blob/master/docker-compose-singlebox.yml) stack that can be used to evaluate swarmstack on a single Docker swarm host without requiring etcd and Portworx or other persistent storage. Please see the INSTALLATION section for instructions on installing this _singlebox_ version of swarmstack.

3 or more Enterprise Linux 7 (RHEL 7/CentOS 7) hosts _(baremetal / VM or a combination)_, with each contributing (1) or more additional virtual or physical _unused_ block devices or partitions to the Portworx storage cluster that swarmstack will install. _More devices usually equals better performance_. If bringing your own existing Docker swarm, 17.12.0+ is required by the swarmstack compose file (version 3.5). swarmstack will install or upgrade all defined _[swarm]_ nodes to the latest stable version of Docker and will attempt to join all _[swarm]_ hosts in the cluster to the _SWARMJOIN_ defined host. You can change the Docker version installed, including using bleeding-edge repos if desired, by altering the docker.yml playbook.

Using the free [Portworx PX-Developer](https://github.com/portworx/px-dev) version by default, swarmstack will install a storage cluster for each set of (3) hosts added to the cluster, which must provide a minimum 40GB (needed by swarmstack) up to the Portworx developer version limits of 1TB of persistent storage for up to _40_ volumes across those 3 nodes. Adding 1TB drives/partitions from each node would be optimal to fill out the 1TB of replicated space. You can contribute unused block device(s) or partition(s), adding more smaller NMVe/SSDs on bare-metal or cloud-provider high-IOPS block devices would provide Portworx faster storage, but Portworx functions even across 3 VMs on the same machine each contributing storage from a single shared USB2 NAS, so scale your storage depending on your expected persistent-storage workloads. Block devices or partitions larger than 1TB can be contributed, but only 1TB of persistent storage will be available without licensing the PX-Enterprise version.

 
When deploying the default Portworx PX-Developer version, you'll add nodes in multiples of 3 and use _constraints_ such as _- node.label.storagegroup == RED_ to pin your individual services requiring persistent storage to one particular group of 3 hosts within the larger swarm cluster _(e.g. nodes 1 2 3, nodes 4 5 6,  etc)_. When choosing [Portworx PX-Enterprise](https://portworx.com/) during installation, or when bringing another storage solution, these limitations may no longer apply and a single larger storage cluster could be made available simultaneously to many more swarm nodes without regard to pinning storage to groups of 3 nodes as px-dev supports. Only a subset of your application services will generally require persistent storage and will require  a decision on which 3-node cluster to pin a service to. The remainder of the Portworx storage space is available for your applications to use. Containers not requiring persistent storage can be scheduled across the entire swarm cluster.

---
 
## INSTALLATION

- _Before proceeding, make sure your hosts have their time in sync via NTP_

- _For manual swarmstack installation instructions, see [Manual swarmstack installation.md](https://github.com/swarmstack/swarmstack/blob/master/documentation/Manual%20swarmstack%20installation.md)_

- _When installing behind a required web proxy, see [Working with swarmstack behind a web proxy.md](https://github.com/swarmstack/swarmstack/blob/master/documentation/Working%20with%20swarmstack%20behind%20a%20web%20proxy.md)_

- _Instructions for updating swarmstack are available at [Updating swarmstack.md](https://github.com/swarmstack/swarmstack/blob/master/documentation/Updating%20swarmstack.md)_

- _To deploy and monitor your own applications on the cluster, see [Adding your own applications to monitoring.md](https://github.com/swarmstack/swarmstack/blob/master/documentation/Adding%20your%20own%20applications%20to%20monitoring.md)_

- _To manually push ephemeral or batch metrics into Prometheus, see [Using Pushgateway.md](https://github.com/swarmstack/swarmstack/blob/master/documentation/Using%20Pushgateway.md)_

- _For reference on what swarmstack configures when enabling LDAP, see [Using LDAP.md](https://github.com/swarmstack/swarmstack/blob/master/documentation/Using%20LDAP.md)_

- _Some basic commands for working with swarmstack and Portworx storage are noted in [Notes.md](https://github.com/swarmstack/swarmstack/blob/master/documentation/Notes.md)_

- _Open an issue. [How do I use this project?](https://github.com/swarmstack/swarmstack/issues/1)_ 

You may want to perform installation from a host outside the cluster, as running the docker.yml playbook may reboot hosts if kernels are updated (you can re-run it in the future to keep your hosts up-to-date). You can work around this by performing a 'yum update kernel' and rebooting if updated on one of your swarm hosts first and then running the ansible playbooks from that host.
```
# yum -y install epel-release && yum install git ansible

# cd /usr/local/src/

# git clone https://github.com/swarmstack/swarmstack

# rsync -aq --exclude=.git --exclude=.gitignore swarmstack/ localswarmstack/

# cd localswarmstack/ansible
```

There is a [docker-compose-singlebox.yml](https://github.com/swarmstack/swarmstack/blob/master/docker-compose-singlebox.yml) stack that can be used to evaluate swarmstack on a single Docker swarm host without requiring etcd and Portworx or other persistent storage. This stack will save persistent named volumes to the single swarm host instead. Please see the file for installation instructions and _skip all other steps below_.

Edit these (4) files: | |
---- | - |
[clusters/swarmstack](https://github.com/swarmstack/swarmstack/blob/master/ansible/clusters/swarmstack) | _Configure all of your cluster nodes and storage devices_ |
[alertmanager/conf/alertmanager.yml](https://github.com/swarmstack/swarmstack/blob/master/alertmanager/conf/alertmanager.yml) | _Optional: Configure where the Alertmanagers send notifications_ |
[roles/swarmstack/files/etc/swarmstack_fw/rules/cluster.rules](https://github.com/swarmstack/swarmstack/blob/master/ansible/roles/swarmstack/files/etc/swarmstack_fw/rules/cluster.rules) | _Used to permit traffic to the hosts themselves_ |
[roles/swarmstack/files/etc/swarmstack_fw/rules/docker.rules](https://github.com/swarmstack/swarmstack/blob/master/ansible/roles/swarmstack/files/etc/swarmstack_fw/rules/docker.rules) | _Used to limit access to Docker service ports_ |

All of the playbooks below are idempotent, will only take actions on hosts  where necessary, and can be safely re-run as needed, such as when changing cluster parameters or adding storage or additional nodes.

After execution of the swarmstack.yml playbook, you'll log into most of the tools as 'admin' and the ADMIN_PASSWORD set in [ansible/clusters/swarmstack](https://github.com/swarmstack/swarmstack/blob/master/ansible/clusters/swarmstack). You can update the ADMIN_PASSWORD later by executing _docker stack rm swarmstack_ (persistent data volumes will be preserved) and then re-deploy the swarmstack [docker-compose.yml](https://github.com/swarmstack/swarmstack/blob/master/docker-compose.yml)

Instances such as Grafana and Portainer will save credential configuration in their respective persistent data volumes. These volumes can be manually removed if required and would be automatically re-initialized the next time the swarmstack compose file is deployed. You would lose any historical information such as metrics if you choose to initialize an application by executing _docker volume rm swarmstack_volumename_ before re-running the swarmstack.yml playbook.

---

ansible-playbook -i clusters/swarmstack [playbooks/firewall.yml](https://github.com/swarmstack/swarmstack/blob/master/ansible/playbooks/firewall.yml) -k

* _(optional but HIGHLY recommended)_ you can run and re-run this playbook to manage firewalls on all of your nodes whether they run Docker or not.

---

ansible-playbook -i clusters/swarmstack [playbooks/docker.yml](https://github.com/swarmstack/swarmstack/blob/master/ansible/playbooks/docker.yml) -k

* _(optional)_ Use this playbook if you haven't already brought up a Docker swarm, or just need to add swarm nodes to a new or existing Docker cluster. This playbook can also be used to maintain your Docker swarm nodes, and will serially work through each _[swarm]_ node in the cluster to update all packages using yum (edit /etc/yum.conf and set _'exclude='_ if you want to inhibit certain packages from being upgraded, even kernels), and will only drain then later reactivate each node if Docker or kernel updates are available and will be applied. You should develop a process to run this maintenance on your hosts regularly by simply running this playbook again.

---

ansible-playbook -i clusters/swarmstack [playbooks/etcd.yml](https://github.com/swarmstack/swarmstack/blob/master/ansible/playbooks/etcd.yml) -k

* _(optional)_ Used by Portworx to store storage cluster metadata in a highly-available manner. Only 3 nodes need to be defined to run etcd, and you'll probably just need to run this playbook once to establish the initial etcd cluster (which can be used by multiple Portworx clusters).
---

ansible-playbook -i clusters/swarmstack [playbooks/portworx.yml](https://github.com/swarmstack/swarmstack/blob/master/ansible/playbooks/portworx.yml) -k

* _(optional)_ Installs Portworx in groups of 3 nodes each. If you are instead bringing your own persistent storage, be sure to update the pxd driver in [docker-compose.yml](https://github.com/swarmstack/swarmstack/blob/master/docker-compose.yml). Add new groups of 3 hosts later as your cluster grows. You can add 1 or more additional Docker swarm hosts in the [swarm] group but not in the [portworx] group; these extra hosts can absorb load across the cluster from containers not requiring persistent storage.

---

ansible-playbook -i clusters/swarmstack [playbooks/swarmstack.yml](https://github.com/swarmstack/swarmstack/blob/master/ansible/playbooks/swarmstack.yml) -k

* _This deploys or redeploys the swarmstack DevOps monitoring stack to the Docker swarm cluster. This includes installing or updating NetData on each node in order for Prometheus to collect metrics from it._

### Updating

If you make changes to the local service configuration files in /usr/local/src/localswarmstack/, such as altering Prometheus configuation or rules, you can run the [up](https://github.com/swarmstack/swarmstack/blob/master/up) script which will cause swarm to update only the services where configuration changes are detected. There is a similar script [up-singlebox](https://github.com/swarmstack/swarmstack/blob/master/up-singlebox) for these users as well.

---

## MONITORING ALERTING AND LOGGING

### Monitoring

The included Grafana dashboards will help you pin-point issues, and provides good visual indicators if something goes off the rails, but your DevOps team will want to keep an eye on _karma_ (which watches both Alertmanager instances in one place), or your pager/email/IM channels, and you'll receive links back to the Prometheus rules being alerted on. Advanced Prometheus users might add runbook links to alert messages, possibly using a ChatOps process through a bot and attempt automatic remediation of the Prometheus condition or dimension being alerted on (reboot the host, kill the container, signal the application, etc).

#### Monitoring your applications

Various Prometheus [exporters](https://prometheus.io/docs/instrumenting/exporters/) are available for common services such as PostgreSQL. [Client libraries](https://prometheus.io/docs/instrumenting/clientlibs/) are also available to help quickly expose Prometheus-compatible metrics from your own applications.

To attach your own applications into Prometheus monitoring, you'll need to make sure you deploy your services to attach to the swarmstack monitoring network in your own docker-compose files. See [swarmstack/errbot-docker/docker-compose-swarmstack.yml](https://github.com/swarmstack/errbot-docker/blob/master/docker-compose-swarmstack.yml) for an example Docker compose service attaching to swarmstack_net to be monitored:

```
version: "3.5"

networks:
  default:
    external: true
    name: swarmstack_net
```

If you have an existing attachable encrypted Docker swarm network, replace the network stanza in docker-compose.yml with your own.

You'll need to expose your metrics in a [Prometheus-compatible](https://www.youtube.com/watch?v=Zk09Mbu0YQk) format on an HTTP port (traffic on the swarmstack_net overlay network is encrypted), and add the following labels to your service so that Prometheus will quickly start to scrape it. See [swarmstack/swarmstack/docker-compose.yml](https://github.com/swarmstack/swarmstack/blob/master/docker-compose.yml) for examples of services announcing they wish to be monitored by Prometheus:

```
    deploy:
      mode: replicated
      replicas: 1
      labels:
        prometheus.enable: "true"
        prometheus.port: "9093"
        prometheus.path: "/metrics"
```

You can use PromQL expressions within Grafana and Prometheus alike to create graphs and also Prometheus alert rules based on the same expressions, such as to alert when the availability status of some of your critical persistent volumes falls below 2. Try these:

```
px_volume_capacity_bytes
px_volume_capacity_bytes{volumename="my_volumename"}
netdata_
count(up)
```

See [Querying Prometheus](https://prometheus.io/docs/prometheus/latest/querying/basics/) for the basics of PromQL syntax. The limited video playlist in the VIDEOS section of this page is an excellent resource to understand the tools deeper.

### Alerting

You can configure the Alertmanager instances to send emails or other notifications whenever Prometheus fires an alert to them. Alerts will be sent to both Alertmanager instances, and de-duplicated using a gossip protocol between them. Please see [Alertmanager Configuration](https://prometheus.io/docs/alerting/configuration/) to understand it's built-in delivery mechanisms.

You can configure the routes and receivers for the swarmstack Alertmanager instances by editing /usr/local/src/localswarmstack/[alertmanager/conf/alertmanager.yml](https://github.com/swarmstack/swarmstack/blob/master/alertmanager/conf/alertmanager.yml)

If you need to connect to a service that isn't supported natively by Alertmanager, you have the option to configure it to fire a webhook towards a target URL, with some JSON data about the alert being sent in the payload. You can provide the receiving service yourself, or consume cloud services such as [https://www.built.io/](https://www.built.io/).

One option would be to configure a bot listening for alerts from Alertmanager instances (you could use it also as an alerting target for your code as well). Upon receiving alerts via a web server port, the bot would then relay them to an instant-message destination. swarmstack builds a Docker image of Errbot, one of many bot programs that can provide a conduit between receiving a webhook, processing the received data, and then connecting to something else (in this case, instant-messaging networks) and relaying the message to a recipient or a room's occupants. If this sounds like the option for you, please see the following project:

[https://github.com/swarmstack/errbot-docker](https://github.com/swarmstack/errbot-docker)

### Logging

There is an adjunct [https://github.com/swarmstack/loki](https://github.com/swarmstack/loki) project that can be used to quickly turn up an instance of Grafana Loki, which your swarmstack or other Grafana instance can configure as a data source. By default, this project will feed the stdout and stderr of all of your Docker swarm containers into Loki (using the loki-docker-driver Docker plugin on each node). Loki can also be fed directly by your own applications, via Fluentd / Fluent Bit, or via other logging facilities.

---

## SCALING

### Prometheus

The data retention period for Prometheus is defaulted to 48 hours within the docker compose files, and a default 10GB Prometheus data volume will be created for HA swarmstack users. Prometheus itself is not designed for long-term storage and retrieval of time-series data, but can work with several storage back-ends as remote-read and remote-write targets. If you find that you need to perform queries on metrics data older than a few days, you should explore deploying other options for long-term storage and retrieval of Prometheus data. Prometheus can optionally replicate metrics stored within it's own internal time-series database (TSDB) out to one or more external TSDB such as VictoriaMetrics, and supports efficient remote-write capabilities for replicating data into these longer-term storage sources.

VictoriaMetrics can be used to persist metrics data in a way that Prometheus-compatible applications (such as Grafana)  can consume it. Other [storage back-ends for Prometheus](https://prometheus.io/docs/operating/integrations/) are also available. The project [swarmstack/victoria-metrics](https://github.com/swarmstack/victoria-metrics) can help swarmstack users quickly bring up an optional VictoriaMetrics remote-write back-end for hosting longer-term metrics. See [Remote Write Storage Wars](https://promcon.io/2019-munich/talks/remote-write-storage-wars/) for more information.

You might instead choose to scale your Prometheus using a federated architecture across multiple Prometheus shards using [Thanos](https://github.com/improbable-eng/thanos), see [PromCon 2018: Thanos - Prometheus at Scale](https://youtu.be/Fb_lYX01IX4)

If you want to centralize your Prometheus data-sources rather than federating them, scalable designs such as [Cortex](https://github.com/cortexproject/cortex) are available for self-hosting. Commerical offerings such as [GrafanaCloud - Hosted Metrics](https://grafana.com/cloud/metrics), [InfluxDB with HA](https://docs.openstack.org/developer/performance-docs/methodologies/monitoring/influxha.html), and [Weave Cloud](https://www.weave.works/product/cloud/) are also available.

### Trickster

By default, Grafana will query the Prometheus data source directly. As you add dashboards that might require (re)querying hundreds of metrics per refresh period, per viewer, this can lead to high load on your Prometheus database. There is an adjunct project [https://github.com/swarmstack/trickster](https://github.com/swarmstack/trickster) that can act as cache for Prometheus metrics for (typically) lower-resolution dashboards or other software where caching and coalescing of metrics data may be acceptable. Useful for cases where operating a more performant storage/retrieval backend for your Prometheus data (such as VictoriaMetrics) isn't desired.

---

As your needs for this stack grow, you may find yourself replacing some of the services within this stack with your own tools. Hope this got you or your team heading in a great direction running applications at scale. Kubernetes is also your friend, and should be used where needed to scale parts that need to scale beyond [several](https://mobile.twitter.com/scaleway/status/758982324553867267) dozen swarm nodes ([story link](https://blog.scaleway.com/2016/docker-swarm-an-analysis-of-a-very-large-scale-container-system/)). You might just choose to deploy some applications (such as Cortex) on Kubernetes, and also run some of your services or development on Docker swarm. Both can be used together to solve your needs.


## NETWORK URLs

Below is mainly for documentation. After installing swarmstack, just connect to https://swarmhost of any Docker swarm node and authenticate with your ADMIN_PASSWORD to view the links:

DevOps Tool | Browser URL<br>(proxied by Caddy) | Purpose
----------- | --------------------------------- | -------
[Alertmanager](https://prometheus.io/docs/alerting/alertmanager/) | https://swarmhost:9093<br>https://swarmhost:9095 | Receives alerts from Prometheus and relays them to slack, email, etc
[karma](https://github.com/prymitive/karma/blob/master/README.md) | https://swarmhost:9094 | Alert dashboard for Prometheus Alertmanager(s)
[Grafana](https://grafana.com) | https://swarmhost:3000 | Query, visualize, alert on and understand your metrics no matter where they are stored
[NetData](https://my-netdata.io/) | https://swarmhost:19998/hostname/ | Everything happening on your systems and applications
[Portainer](https://portainer.io) | https://swarmhost:9000 | Lightweight Docker Swarm management UI
[Prometheus](https://prometheus.io/) | https://swarmhost:9090 | Open-source monitoring solution
[Prometheus Pushgateway](https://prometheus.io/docs/practices/pushing/) | https://swarmhost:9091 | Push acceptor for ephemeral and batch jobs metrics to be scraped by Prometheus

---

Security | Notes | Source / Image
-------- | ----- | --------------
[Caddy](https://caddyserver.com/) | Reverse proxy - see above for URLs | Source:[https://github.com/swarmstack/caddy](https://github.com/swarmstack/caddy)<br>Image:[https://hub.docker.com/r/swarmstack/caddy](https://hub.docker.com/r/swarmstack/caddy) no-stats
[Docker Garbage Collection](https://docs.docker.com/config/pruning/) | Removes unused and expired Docker images, containers, and volumes | Source: [https://github.com/clockworksoul/docker-gc-cron](https://github.com/clockworksoul/docker-gc-cron)<br>Image:[https://hub.docker.com/r/clockworksoul/docker-gc-cron](https://hub.docker.com/r/clockworksoul/docker-gc-cron) latest
[Fail2ban](https://www.fail2ban.org) | Brute-force prevention | [ansible/playbooks/firewall.yml](https://github.com/swarmstack/swarmstack/blob/master/ansible/playbooks/firewall.yml)
[iptables](https://en.wikipedia.org/wiki/Iptables) | Firewall management | [ansible/playbooks/firewall.yml](https://github.com/swarmstack/swarmstack/blob/master/ansible/playbooks/firewall.yml)

---

Monitoring / Telemetry | Metrics URL | Source / Image 
---------------------- | ----------- | --------------
[Alertmanager](https://prometheus.io/docs/alerting/alertmanager/) | Docker overlay network:<br>http://alertmanager[B]:9093/metrics | Source:[https://github.com/prometheus/alertmanager](https://github.com/prometheus/alertmanager)<br>Image:[https://hub.docker.com/r/prom/alertmanager](https://hub.docker.com/r/prom/alertmanager) latest
[cAdvisor](https://github.com/google/cadvisor) | Docker overlay network:<br>http://cadvisor:8080/metrics | Source:[https://github.com/google/cadvisor](https://github.com/google/cadvisor)<br>Image: gcr.io/google-containers/cadvisor v0.36.0
[Docker Swarm](https://docs.docker.com/engine/swarm/) | Docker Node IP:<br>http://swarmhost:9323/metrics | [ansible/playbooks/docker.yml](https://github.com/swarmstack/swarmstack/blob/master/ansible/playbooks/docker.yml)
[etcd3](https://github.com/etcd-io/etcd) | Docker Node IP:<br>http://swarmhost:2379/metrics | [ansible/playbooks/etcd.yml](https://github.com/swarmstack/swarmstack/blob/master/ansible/playbooks/etcd.yml)
[Grafana](https://grafana.com) | Docker overlay network:<br>http://grafana:3000/metrics | Source:[https://github.com/grafana/grafana](https://github.com/grafana/grafana)<br>Image:[https://hub.docker.com/r/grafana/grafana](https://hub.docker.com/r/grafana/grafana) latest
[karma](https://github.com/prymitive/karma/blob/master/README.md) | Docker overlay network:<br>http://karma:8080/metrics | Source:[https://github.com/prymitive/karma](https://github.com/prymitive/karma)<br>Image:[https://hub.docker.com/r/lmierzwa/karma](https://hub.docker.com/r/lmierzwa/karma) v0.74
[kthxbye](https://github.com/prymitive/kthxbye/blob/master/README.md) | Docker overlay network:<br>http://kthxbye:8080/metrics | Source:[https://github.com/prymitive/kthxbye](https://github.com/prymitive/kthxbye)<br>Image:[https://hub.docker.com/r/lmierzwa/kthxbye](https://hub.docker.com/r/lmierzwa/kthxbye) v0.9
[NetData](https://my-netdata.io/) | Docker Node IP:<br>http://swarmhost:19999/api/v1/allmetrics | [ansible/playbooks/swarmstack.yml](https://github.com/swarmstack/swarmstack/blob/master/ansible/playbooks/swarmstack.yml) latest
[node_exporter](https://github.com/prometheus/node_exporter/) | https://swarmhost:9100/metrics/ | [https://github.com/prometheus/node_exporter/](ttps://github.com/prometheus/node_exporter/) latest
[Portainer](https://portainer.io) | no Prometheus monitoring | Source:[https://github.com/portainer/portainer](https://github.com/portainer/portainer)<br>Image:[https://hub.docker.com/r/portainer/portainer](https://hub.docker.com/r/portainer/portainer) latest
[Portainer Agent](https://portainer.io) | no Prometheus monitoring, contacts Portainer | Source:[https://github.com/portainer/portainer](https://github.com/portainer/portainer)<br>Image:[https://hub.docker.com/r/portainer/agent](https://hub.docker.com/r/portainer/agent) latest
[Portworx](https://portworx.com) | Docker Node IP:<br>http://swarmhost:9001/metrics | [ansible/playbooks/portworx.yml](https://github.com/swarmstack/swarmstack/blob/master/ansible/playbooks/portworx.yml) px-dev or px-enterprise 2.4.0
[Prometheus](https://prometheus.io) | Docker overlay network:<br>http://prometheus:9090/metrics | Source:[https://github.com/prometheus/prometheus](https://github.com/prometheus/prometheus)<br>Image:[https://hub.docker.com/r/prom/prometheus](https://hub.docker.com/r/prom/prometheus) latest
[Prometheus Pushgateway](https://prometheus.io/docs/practices/pushing/) | Docker overlay network:<br>http://pushgateway:9091/metrics | Source:[https:/github.com/prometheus/pushgateway](https:/github.com/prometheus/pushgateway)<br>Image:[https://hub.docker.com/r/prom/pushgateway](https://hub.docker.com/r/prom/pushgateway) latest
[swarm-discovery-server](https://github.com/bborysenko/prometheus-swarm-discovery) | No Prometheus monitoring<br>server: http://swarm-discovery-server:8080<br>client: contacts server and also writes to a volume shared with Prometheus container | Source:[https://github.com/bborysenko/prometheus-swarm-discovery](https://github.com/bborysenko/prometheus-swarm-discovery) 0.3.0

---

## SCREENSHOTS

### Caddy Link Dashboard
![](https://raw.githubusercontent.com/swarmstack/swarmstack/master/documentation/screens/screen1.png)
### Grafana Dashboards List
![](https://raw.githubusercontent.com/swarmstack/swarmstack/master/documentation/screens/screen2.png)
### Grafana - Docker Swarm Nodes
![](https://raw.githubusercontent.com/swarmstack/swarmstack/master/documentation/screens/docker_swarm_nodes.png)
### Grafana - Docker Swarm Services
![](https://raw.githubusercontent.com/swarmstack/swarmstack/master/documentation/screens/docker_swarm_services.png)
### Grafana - etcd
![](https://raw.githubusercontent.com/swarmstack/swarmstack/master/documentation/screens/etcd.png)
### Grafana - Portworx Cluster Status
![](https://raw.githubusercontent.com/swarmstack/swarmstack/master/documentation/screens/portworx_cluster_status.png)
### Grafana - Portworx Volume Status
![](https://raw.githubusercontent.com/swarmstack/swarmstack/master/documentation/screens/portworx_volumes.png)
### Grafana - Prometheus Stats
![](https://raw.githubusercontent.com/swarmstack/swarmstack/master/documentation/screens/prometheus.png)
### Alertmanager
![](https://raw.githubusercontent.com/swarmstack/swarmstack/master/documentation/screens/screen9.png)
### Portainer - Cluster Visualizer
![](https://raw.githubusercontent.com/swarmstack/swarmstack/master/documentation/screens/portainer_cluster.png)
### Portainer - Dashboard
![](https://raw.githubusercontent.com/swarmstack/swarmstack/master/documentation/screens/portainer-dashboard.png)
### Portainer - Stacks
![](https://raw.githubusercontent.com/swarmstack/swarmstack/master/documentation/screens/portainer-stacks.png)
### Prometheus - Graphs
![](https://raw.githubusercontent.com/swarmstack/swarmstack/master/documentation/screens/screen10.png)
### Prometheus - Alerts
![](https://raw.githubusercontent.com/swarmstack/swarmstack/master/documentation/screens/prometheus_alerts.png)
### Prometheus - Targets
![](https://raw.githubusercontent.com/swarmstack/swarmstack/master/documentation/screens/prometheus_targets.png)

---

## VIDEOS

* [swarmstack introduction video](https://youtu.be/3FpTcVnvfRg)
* [How to Export Prometheus Metrics from Just About Anything - Matt Layher, DigitalOcean](https://www.youtube.com/watch?v=Zk09Mbu0YQk)
* [Monitoring, the Prometheus way](https://www.youtube.com/watch?v=PDxcEzu62jk)
* [How Prometheus Revolutionized Monitoring at SoundCloud](https://youtu.be/hhZrOHKIxLw).
* [Prometheus Monitoring for DevOps teams playlist](https://www.youtube.com/playlist?list=PLffspZ58HP-Nv8tDHGJoawAZQStkNzA7u)

---

## CREDITS

Credit is due to the excellent DevOps stack proposed and maintained by [Stefan Prodan](https://stefanprodan.com/) and his project [swarmprom](https://github.com/stefanprodan/swarmprom).

Thank you Carl Bergquist for Grafana golang updates.

Thank you Guillaume Binet and the [Errbot community](https://gitter.im/errbotio/errbot) for [assistance](https://stackoverflow.com/questions/tagged/errbot) with plugins.

Thanks Łukasz Mierzwa for [karma](https://github.com/prymitive/karma/blob/master/README.md) fixes and updates.

Thanks to Mark Sullivan at Cisco for his work on the Cisco Webex Teams backend for Errbot.

Thanks goes to the team at Portworx for their excellent storage product and support.

Thanks to Shannon Wynter for Caddy re-authentication fixes for LDAP.

Thanks to Nils Laumaillé for [TeamPass](https://teampass.net) - Managing passwords in a collaborative way - [swarmstack/teampass](https://github.com/swarmstack/teampass)
