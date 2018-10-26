#!/bin/bash

export BASEDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)
export LOGFILE=${BASEDIR}/bootstrap.log

export BINDIR=${BASEDIR}/bin
export TMPDIR=${BASEDIR}/tmp
export PATH=${BINDIR}:${PATH}
export VPCDIR=${BASEDIR}/global/vpc

log() {
  echo $(date +"%T") $1 >> $LOGFILE
}

log "started bootstrap"
log "BASEDIR=${BASEDIR}"

error() {
  log "$1"
  echo "$1" 1>&2
  exit 1
}

run_cmd() {
  log "run_cmd: $1"
  eval $1 >> ${LOGFILE} 2>&1
  if [ "$?" -ne "0" ]; then
    echo "An error occurred. See the ${LOGFILE} for details."
    exit 1
  fi
}

# Check for all pre-requisites
pre_req_check() {

  if [ "$1" != "skip_aws" ]; then
    if [ ! -e ~/.aws/credentials ]; then
      echo "AWS not configured. Please specify the access credentials below:"
      aws configure
    fi
  fi

  [ ! -e ${BINDIR} ] && mkdir ${BINDIR}

  [ ! -e ${TMPDIR} ] && mkdir ${TMPDIR}

  if [ ! $(which git 2>/dev/null) ]; then
    echo "Installing git..."
    run_cmd "sudo yum -y install git"
  fi

  if [ ! $(which aws 2>/dev/null) ]; then
    echo "Installing AWS CLI..."
    run_cmd "sudo -H pip install -U awscli"
  fi

  if [ ! $(which java 2>/dev/null) ]; then
    echo "Installing java..."
    run_cmd "sudo yum install java -y"
  fi

  if [ ! -e ${BINDIR}/terraform ]; then
    echo "Installing terraform..."
    run_cmd "curl -o ${TMPDIR}/terraform_0.11.8_linux_amd64.zip https://releases.hashicorp.com/terraform/0.11.8/terraform_0.11.8_linux_amd64.zip"
    run_cmd "unzip -d ${BINDIR} ${TMPDIR}/terraform_0.11.8_linux_amd64.zip"
    run_cmd "chmod a+x ${BINDIR}/terraform"
  fi

  if [ ! -e ${BINDIR}/packer ]; then
    echo "Installing packer..."
    run_cmd "curl -o ${TMPDIR}/packer_1.3.1_linux_amd64.zip https://releases.hashicorp.com/packer/1.3.1/packer_1.3.1_linux_amd64.zip"
    run_cmd "unzip -d ${BINDIR} ${TMPDIR}/packer_1.3.1_linux_amd64.zip"
    run_cmd "chmod a+x ${BINDIR}/packer"
  fi

}
pre_req_check

