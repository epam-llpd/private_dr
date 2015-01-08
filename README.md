# Private Docker registry

This repository contains bunch of Dockerfiles and shell script to
create secure and persistent for private docker registry.

## Usage

To use it, simple clone this repository and run registry.sh script:
```bash
./registry.sh build # build docker containers for Redis, Docker and Nginx
./registry.sh run   # run registry on 8080 port
```

After starting registry, you should assign symbolic name to
ip address of machine, which runs it, for example, by editing
/etc/hosts of client machines, or setup appropriate DNS records.

This name should match with symbolic name, stored in ssl certificate.
Default value is: private_registry. 

After that, you should be able to work with your registry: 
search, push and pull images. For example:

```bash
docker search private_registry:8080/some_container
docker pull private_registry:8080/another_container
```

Docker images, served by registry, stored in data/ directory.
Docker system database, used for indexing, stored in db/ directory.

## Custom ssl keys

To use your own ssl keys, simple replace ssl/registry-docker.crt,
ssl/registry-docker.key with your signed keys.

After that you should add certificate authority to system certificates
ON ALL MACHINES, which will use your private repo.

To do this, copy ssl/CA.crt or your own certificate to
/etc/ssl/certs/registry-docker.crt,
then run update-ca-certificates and restart docker.
