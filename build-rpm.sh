#!/usr/bin/env bash
set -ex
NODE_EXPORTER_VERSION="0.16.0"
NODE_EXPORTER_BIN_FILE_NAME="node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz"
NODE_EXPORTER_BIN_FILE_URL="https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/${NODE_EXPORTER_BIN_FILE_NAME}"
NODE_EXPORTER_INITD_FILE="./node_exporter.initd"
NODE_EXPORTER_INITD_CONFIG_FILE="./node_exporter.env"
RPMBUILDER_HOME_DIR="/home/rpmbuilder"
SPEC_FILE_NAME=`basename $@`
RPMBUILD_TOP_DIR="${RPMBUILDER_HOME_DIR}/rpmbuild"

# Prepare Build Environment
echo "Baselining/Removing ${RPMBUILD_TOP_DIR}"
rm -fr "${RPMBUILD_TOP_DIR}" || true
mkdir -p "${RPMBUILD_TOP_DIR}/"{BUILD,SPECS,SOURCES,BUILDROOT,RPMS,SRPMS,tmp}
echo "Configuring: ${RPMBUILD_TOP_DIR}/SOURCES/..."
echo "Fetch: ${NODE_EXPORTER_BIN_FILE_URL}"
wget "${NODE_EXPORTER_BIN_FILE_URL}" -O "${RPMBUILD_TOP_DIR}/SOURCES/${NODE_EXPORTER_BIN_FILE_NAME}"
echo "Fetch: ${NODE_EXPORTER_INITD_FILE}"
cp -p "${NODE_EXPORTER_INITD_FILE}" "${RPMBUILD_TOP_DIR}/SOURCES/"
echo "Fetch: ${NODE_EXPORTER_INITD_CONFIG_FILE}"
cp -p "${NODE_EXPORTER_INITD_CONFIG_FILE}" "${RPMBUILD_TOP_DIR}/SOURCES/"
echo "Fetch: ${SPEC_FILE_NAME}"
cp -p $@ "${RPMBUILD_TOP_DIR}"
echo "Set ownership: ${RPMBUILDER_HOME_DIR}"
chown -R rpmbuilder. "${RPMBUILDER_HOME_DIR}"

# Yum cleaning
sudo yum clean all
sudo rm -rf rm -rf /var/cache/yum

## Build Spec
echo "BUILDING: $@ ..."
cd ~/rpmbuild
echo "Installing YUM build dependencies...."
sudo yum-builddep -y $1
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

rpmbuild --clean -ba $@
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi


rm -f test/*.rpm
cp -p rpmbuild/RPMS/x86_64/*.rpm test/





