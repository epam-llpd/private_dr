# Private Docker registry

This repository contains bunch of Dockerfiles and shell script to
create secure and persistent for private docker registry.

## Usage

To use it, simple clone this repository and run registry.sh script:
```bash
./registry.sh build
./registry.sh run 
```

Private registry should be listening on the 8080 port.

## Custom ssl keys

New versions of docker (>= 1.3.0) require ssl encryption of docker registry.

To use your own ssl keys, simple replace ssl/registry-docker.crt,
ssl/registry-docker.key with your signed keys.

After that you should add certificate authority to system certificates
ON ALL MACHINES, which will use your private repo.

To do this, copy ssl/CA.crt or your own certificate to
/etc/ssl/certs/registry-docker.crt,
then run update-ca-certificates and restart docker.



