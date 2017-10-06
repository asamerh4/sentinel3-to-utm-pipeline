FROM asamerh4/mesos-batch:f7ea7a1

MAINTAINER Hubert Asamer

COPY tools/ /root/tools/
COPY bin/ /root/bin
COPY run.sh /root/run.sh

WORKDIR /root

