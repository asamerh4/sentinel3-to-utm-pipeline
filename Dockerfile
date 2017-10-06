FROM asamerh4/mesos-batch:f7ea7a1

MAINTAINER Hubert Asamer

RUN pip install certifi

COPY tools/ /root/tools/
COPY bin/ /root/bin
COPY run.sh /root/run.sh

WORKDIR /root

CMD ["bin/in_s3_env", "./run.sh"]
