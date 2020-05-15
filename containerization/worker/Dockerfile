from debian:9
maintainer Raziel Carvajal-Gomez <raziel.carvajal@uclouvain.be>

workdir /usr/manet_routing_benchmark

env INET_ROOT=/usr/manet_routing_benchmark/omnetpp-5.6.1/samples/inet
env PATH=/usr/manet_routing_benchmark/omnetpp-5.6.1/bin:${INET_ROOT}/bin:${PATH}
env INET_NED_PATH="$INET_ROOT/src:$INET_ROOT/tutorials:$INET_ROOT/showcases:$INET_ROOT/examples"

run apt-get update
run apt-get -y --no-install-recommends install \
  build-essential \
  gcc \
  g++ \
  bison \
  flex \
  perl \
  python \
  python3 \
  qt5-default \
  libqt5opengl5-dev \
  tcl-dev \
  tk-dev \
  libxml2-dev \
  zlib1g-dev \
  default-jre \
  doxygen \
  graphviz \
  libwebkitgtk-3.0-0 \
# INET dependencies
  libavcodec-dev \
  libavformat-dev \
# Others
  wget \
  curl

add src/omnetpp-5.6.1-src-core.tgz .
# in case the docker-compose version is lower than 3.0
run if [ ! -d omnetpp-5.6.1 ] ; then tar xof omnetpp-5.6.1-src-core.tgz ; fi

# Compilation of OMNeT++
run cd omnetpp-5.6.1 && \
  ./configure WITH_TKENV=no WITH_QTENV=no WITH_OSG=no WITH_OSGEARTH=no && \
  make MODE=release -j8

add src/inet-4.2.0-src.tgz .
# in case the docker-compose version is lower than 3.0
run if [ ! -d inet4 ] ; then tar xof inet-4.2.0-src.tgz ; fi
# Compilation of OMNeT++
run mv inet4 inet && mv inet omnetpp-5.6.1/samples/ && \
  cd omnetpp-5.6.1/samples/inet && make makefiles && make -j8
