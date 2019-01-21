# Jenkins/Artifactory/Xray Docker Compose

This directory provides a Compose file to run Jenkins, Artifactory and Xray with Docker Compose.
To learn more about Docker and how to set it up, please refer to the [Docker](https://docs.docker.com) and [Docker Compose](https://docs.docker.com/compose/overview/) documentation.

Jenkins consists of a single Docker image available for download at [Docker Hub](https://hub.docker.com/r/jenkins/jenkins/).

Artifactory Pro consists of a single Docker image available for download at [JFrog Binatry](https://bintray.com/jfrog/reg2/jfrog%3Aartifactory-pro).

Xray consists of different Docker images available for download from [JFrog Bintray](https://bintray.com/jfrog):

* [xray-server](https://bintray.com/jfrog/reg2/jfrog%3Axray-server): Responsible for generating violations, hosting API / UI endpoints and running scheduled jobs
* [xray-indexer](https://bintray.com/jfrog/reg2/jfrog%3Axray-indexer): Responsible for the indexing process
* [xray-analysis](https://bintray.com/jfrog/reg2/jfrog%3Axray-analysis): Responsible for enriching component metadata
* [xray-persist](https://bintray.com/jfrog/reg2/jfrog%3Axray-persist): Responsible for matching the given components graph, completing component naming and storing the data in the relevant databases
* [xray-rabbitmq](https://bintray.com/jfrog/reg2/jfrog%3Axray-rabbitmq): Used for communication and messaging between the Xray microservice
* [xray-postgres](https://bintray.com/jfrog/reg2/jfrog%3Axray-postgres): Used to persist the components graph database
* [xray-mongo](https://bintray.com/jfrog/reg2/jfrog%3Axray-mongo): Used to persist components metadata and configuration

---
## Configuration

The initial configuration of the Jenkins, Artifactory and Xray is controlled via the values of the variables in the Compose [environment file](https://docs.docker.com/compose/env-file/) `.env`. To access the different applications via the NGINX reverse proxy you have to create DNS entries or edit your local `/etc/hosts` file.

### Environment variables

#### General environment variables

* DOCKER_DATA: Absolute path to the base directory used to store the application data (e.g. `/opt/docker-data`)

#### NGINX specific environment variables

* PROXY_VERSION: Version of the Docker image [jwilder/nginx](https://hub.docker.com/r/jwilder/nginx-proxy/)

#### Jenkins specific environment variables

* JENKINS_VERSION: Version of the Docker image [jenkins/jenkins](https://hub.docker.com/r/jenkins/jenkins/)
* JENKINS_HOSTNAME: Host name of the Jenkins server (accessible via the NGINX reverse proxy)

#### Artifactory specific environment variables

* ARTIFACTORY_VERSION: Version of the Docker image [jfrog/artifactory](https://bintray.com/jfrog/reg2/jfrog%3Aartifactory-pro)
* ARTIFACTORY_HOSTNAME: Host name of the Artifactory server (accessible via the NGINX reverse proxy)
* ARTIFACTORY_WILDCARD_HOSTNAME: Additional wildcard subdomain of the Artifactory server necessary for Docker repositories

#### Xray specific environment variables

* XRAY_VERSION: Version of the different Xray specific Docker images
* XRAY_HOSTNAME: Host name of the Xray server (accessible via the NGINX reverse proxy)
* XRAY_RABBITMQ_VERSION: Version of the Docker image [jfrog/xray-rabbitmq](https://bintray.com/jfrog/reg2/jfrog%3Axray-rabbitmq)
* XRAY_RABBITMQ_HOSTNAME: Host name of the Xray RabbitMQ server (accessible via the NGINX reverse proxy)
* XRAY_POSTGRES_VERSION: Version of the Docker image [jfrog/xray-postgres](https://bintray.com/jfrog/reg2/jfrog%3Axray-postgres)
* XRAY_POSTGRES_HOSTNAME: Host name of the Xray PostgreSQL server (**not** accessible via the NGINX reverse proxy)
* XRAY_MONGODB_VERSION: Version of the Docker image [jfrog/xray-mongo](https://bintray.com/jfrog/reg2/jfrog%3Axray-mongo)
* XRAY_MONGODB_HOSTNAME: Host name of the Xray MongoDB server (**not** accessible via the NGINX reverse proxy)

### Persistent Storage

All directories of the Docker containers, that will contain application specific data, are persisted by using a [bind mount](https://docs.docker.com/storage/bind-mounts/). The base directory is specified via the `DOCKER_DATA` environment variable, which will contain a subdirectory for each Docker container.

The first two levels of the `DOCKER_DATA` directory should look like this:
```
--+ ${DOCKER_DATA}
  |--+ artifactory
  |  \-- home
  |--+ jenkins
  |  \-- home
  |--+ proxy
  |  |-- conf.d
  |  \-- vhost.d
  \--+ xray
     |-- home
     |-- mongodb
     |-- postgres
     \-- rabbitmq
```

### DNS configuration

In order to make the Docker containers accessible via the NGINX proxy you have to create DNS records for the configured `*_HOSTNAME` variables either by create A records pointing to the public IP address of the server or by manually adding the entries to your `/etc/hosts` file.

If you want to access the Docker containers only from your local machine it is sufficient to execute the following command:
```bash
$ sudo su -
$ export $(grep -v '^#' .env | xargs)
$ echo "# Docker Compose specific entries" >> /etc/hosts
$ echo "${ARTIFACTORY_HOSTNAME} 127.0.0.1" >> /etc/hosts
$ echo "${XRAY_HOSTNAME} 127.0.0.1" >> /etc/hosts
$ echo "${XRAY_RABBITMQ_HOSTNAME} 127.0.0.1" >> /etc/hosts
```

---

## Installation

To install Jenkins, Artifactory and Xray you first have to create the necessary data directories used as persistent storage.

```bash
$ setup/setup.sh
```

This script will create the data directories for each application, if necessary bootstraps them with configuration files and set the correct file system permissions.


## Run Jenkins, Artifactory and Xray

To start Jenkins, Artifactory and Xray issue the following command:

```bash
$ sudo docker-compose up -d
```

This will start all services - Jenkins, Artifactory and Xray - defined in the Compose file in the correct order. To view the log output of the services, use `sudo docker-compose logs -f`.

## Access Jenkins, Artifactory and Xray

After you started all services, you can access them via the following URLs (given you didn't change any of the `*_HOSTNAME` variables):

* Jenkins: http://jenkins.datev.local
* Artifactory: http://artifactory.datev.local
* Xray: http://xray.datev.local
* RabbitMQ: http://xray-rabbitmq.datev.local

The initial password of the administrative user of Jenkins can be found in the file `${DOCKER_DATA}/jenkins/home/secrets/initialAdminPassword`.

The default user name and password of the built-in administrator user accounts for Artifactory and Xray are `admin/password`.

The default user name and password for the RabbitMQ Management console are `guest/guest`.

## Stop Jenkins, Artifactory and Xray

To stop Jenkins, Artifactory and Xray issue the following command:

```bash
$ sudo docker-compose stop
```

## Remove Jenkins, Artifactory and Xray

To remove all resources (services and networks) created by this Compose file issue the following command:

```bash
$ sudo docker-compose down
```

Note that all application data is persisted in the local file system. You don't loose any data, if you execute the above command.
