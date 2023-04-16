# based on docker image by Clement Laforet <sheepkiller@cultdeadsheep.org>

FROM openjdk:11

MAINTAINER Guido Schmutz <guido.schmutz@trivadis.com>

RUN apt-get update -y && \
    apt-get install -y git wget unzip && \
    apt-get clean all

# when updating the version, make sure to also update the revision !!!
ENV ZK_HOSTS=localhost:2181 \
    CMAK_VERSION=3.0.0.7 \
    CMAK_REVISION=30abfde3d303134db171f140784c5d506885eaf8 \
    CMAK_CONFIGFILE="conf/application.conf"

RUN mkdir -p /tmp && \
    cd /tmp && \
    git clone https://github.com/yahoo/cmak && \
    cd /tmp/cmak && \
    git checkout ${CMAK_REVISION} && \
    echo 'scalacOptions ++= Seq("-Xmax-classfile-name", "200")' >> build.sbt && \
    ./sbt clean dist && \
    unzip  -d / ./target/universal/cmak-${CMAK_VERSION}.zip && \
    rm -fr /tmp/* /root/.sbt /root/.ivy2

RUN printf '#!/bin/sh\nexec ./bin/cmak -Dconfig.file=${CMAK_CONFIGFILE} "${CMAK_ARGS}" "${@}"\n' > /cmak-${CMAK_VERSION}/cmak.sh && \
    chmod +x /cmak-${CMAK_VERSION}/cmak.sh

WORKDIR /cmak-${CMAK_VERSION}

EXPOSE 9000
ENTRYPOINT ["./cmak.sh"]
