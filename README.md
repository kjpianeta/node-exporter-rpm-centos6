# node-exporter-rpm-centos6
RPM build of Prometheus node-exporter for Centos 6

#### Build RPM
```
export SPEC_FILE="./prometheus-node-exporter-centos6.spec"
docker-compose run rpmbuilder
```