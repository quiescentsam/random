#!/bin/bash -ex
#centos 7 compatible
# Java Versions
# CD Versions

function log {
    echo $@
}
function err {
    printf "\n\x1b[31mError:\x1b[0m $@\n"
}

function installJdk {
  #We remove any natively installed JDKs, as both Cloudera Manager and Cloudera Director only support Oracle JDKs
  sudo yum remove --assumeyes *openjdk*
  sudo rpm -ivh "http://archive.cloudera.com/director/redhat/7/x86_64/director/2.5.0/RPMS/x86_64/oracle-j2sdk1.8-1.8.0+update121-1.x86_64.rpm"
  sudo ln -s /usr/java/jdk1.8.0_121-cloudera /usr/java/default
  sudo ln -s /usr/java/default/bin/java /usr/bin/java
  sudo ln -s /usr/java/default /usr/java/latest
  log "java installed"
}

function installJce {
  # java 8 JCE files
  export JAVA_HOME=/usr/java/latest
  sudo wget -O /tmp/jce_policy-8.zip --no-cookies --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jce/8/jce_policy-8.zip"
  sudo unzip -j -o /tmp/jce_policy-8.zip "UnlimitedJCEPolicyJDK8/*.jar" -d ${JAVA_HOME}/jre/lib/security
  sudo rm -f  /tmp/jce_policy-8.zip
  sudo chmod a+r ${JAVA_HOME}/jre/lib/security/local_policy.jar ${JAVA_HOME}/jre/lib/security/US_export_policy.jar
  log "jce installed"
}

function installPackages {
  #statements
  sudo yum install wget git unzip -y
  #sudo yum install java -y
}

function installClouderaDirector {
  #statements
  sudo wget -O /etc/yum.repos.d/cloudera-director.repo "https://archive.cloudera.com/director/redhat/7/x86_64/director/cloudera-director.repo"
  sudo yum install cloudera-director-server cloudera-director-client -y
  sleep 60
  sudo service cloudera-director-server start
  sudo service cloudera-director-server status
}

function main() {
  installPackages
  installJdk
  installJce
  installClouderaDirector
}

main
exit 0
