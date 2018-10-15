FROM centos:6

LABEL Maintainer="Kenneth Pianeta <kjpianeta@gmail.com>"

ENV SPEC_FILE="./prometheus-node-exporter-centos6.spec"
# Yum
RUN set -ex \
    && yum -y update \
    && yum -y install epel-release \
    && yum -y install rpmdevtools mock rpmlint git wget curl kernel-devel rpmdevtools rpmlint rpm-build sudo gcc-c++ make automake autoconf expect \
    && yum clean all \
    && rm -rf /tmp/* /var/tmp/* /var/lib/yum/* /var/cache/yum/*

COPY ./build-rpm.sh /bin/
RUN set -ex \
    && chmod 755 /bin/build-rpm.sh

# Sudo
RUN echo "%wheel  ALL=(ALL)       NOPASSWD: ALL" > /etc/sudoers.d/wheel
RUN chown root:root /etc/sudoers.d/*

# Remove requiretty from sudoers main file
RUN sed -i '/Defaults    requiretty/c\#Defaults    requiretty' /etc/sudoers

# Rpm User
RUN set -ex \
    && adduser -G wheel rpmbuilder \
    && mkdir -p /home/rpmbuilder/rpmbuild/{BUILD,SPECS,SOURCES,BUILDROOT,RPMS,SRPMS,tmp} \
    && chmod -R 777 /home/rpmbuilder/rpmbuild

USER rpmbuilder

WORKDIR /home/rpmbuilder

ENTRYPOINT "./build-rpm.sh" ${SPEC_FILE}