# Build the container with
# docker build -t netdata .
#
# Run the container with
# docker run -d -v /proc:/host/proc:ro -v /sys:/host/sys:ro --cap-add SYS_PTRACE -h $(hostname) -p 19999:19999 netdata
#
FROM library/centos:7

RUN yum install -y \
    autoconf \
    autogen \
    automake \
    gcc \
    git \
    iproute \
    make \
    pkgconfig \
    which \
    zlib-devel && \
    yum clean all

RUN git clone https://github.com/firehol/netdata.git /tmp/netdata.git --depth=1

WORKDIR /tmp/netdata.git

RUN ./netdata-installer.sh --dont-wait --install /opt

WORKDIR /opt

RUN rm -rf /tmp/*

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /opt/netdata/var/log/netdata/access.log \
  && ln -sf /dev/stderr /opt/netdata/var/log/netdata/error.log

EXPOSE 19999
VOLUME ["/host"]

CMD ["/opt/netdata/usr/sbin/netdata","-nd","-ch","/host"]
