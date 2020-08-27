FROM debian:stretch

ENV DEBIAN_FRONTEND=noninteractive \
    OV_PASSWORD=admin \
    PUBLIC_HOSTNAME=openvas

#Install Prerequisites
RUN apt-get update && \
    apt-get install --assume-yes --quiet --no-install-recommends --fix-missing \
            apt-utils locales zip bzip2 net-tools wget rsync curl cron \
            nmap \
            gcc cmake gcc-mingw-w64 clang clang-format perl-base \
            pkg-config libssh-gcrypt-dev libgnutls28-dev libglib2.0-dev uuid-dev libldap2-dev \
            libpcap-dev libgpgme-dev bison flex libksba-dev libsnmp-dev libgcrypt20-dev \
            redis-server redis-tools libhiredis-dev libmicrohttpd-dev gettext \
            doxygen xmltoman libfreeradius-dev apt-transport-https haveged libssl-dev \
            heimdal-dev libpopt-dev libxml2 libxml2-dev libxslt1.1 libxslt-dev libical-dev gnutls-bin xsltproc python3-lxml python3-wheel \
            python-impacket python3-polib python3-setuptools python3-defusedxml python3-paramiko python3-redis python3-dev \
            python3-pycparser python3-pyparsing python3-packaging python3-redis \
            libffi6 libffi-dev \
            texlive-latex-base texlive-latex-extra xmlstarlet nsis gnupg snmp smbclient \
            sqlfairy libsqlite3-dev libpq-dev fakeroot sshpass socat && \
    curl --silent --show-error https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -  && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    curl --silent --show-error https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -  && \
    echo "deb https://deb.nodesource.com/node_8.x stretch main" | tee /etc/apt/sources.list.d/nodesource.list && \
    apt-get update -y && \
    apt-get install nodejs yarn --assume-yes --quiet --no-install-recommends --fix-missing && \
    apt autoremove -y && \
    rm -rf /var/lib/apt/lists/*

    
#Build gvm-libs
RUN cd /usr/src && \
    wget -nv https://github.com/greenbone/gvm-libs/archive/v10.0.2.tar.gz && \
    tar -zxf v10.0.2.tar.gz && \
    cd gvm-libs-10.0.2 && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make && \
    make install && \
    rm /usr/src/v10.0.2.tar.gz && \
    rm -rf /usr/src/gvm-libs-10.0.2

#Build openvas-smb
RUN cd /usr/src && \
    wget -nv https://github.com/greenbone/openvas-smb/archive/v1.0.5.tar.gz && \
    tar -zxf v1.0.5.tar.gz && \
    cd openvas-smb-1.0.5 && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make && \
    make install && \
    rm /usr/src/v1.0.5.tar.gz && \
    rm -rf /usr/src/openvas-smb-1.0.5

#Build openvas
RUN cd /usr/src && \
    wget -nv https://github.com/greenbone/openvas/archive/v6.0.2.tar.gz && \
    tar -zxf v6.0.2.tar.gz && \
    cd openvas-6.0.2 && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make && \
    make install && \
    rm /usr/src/v6.0.2.tar.gz && \
    rm -rf /usr/src/openvas-6.0.2
COPY ./config/openvassd.conf /usr/local/etc/openvas/openvassd.conf
COPY ./config/redis.conf /etc/redis.conf

#Build gsa
RUN cd /usr/src && \
    wget -nv https://github.com/greenbone/gsa/archive/v8.0.2.tar.gz && \
    tar -zxf v8.0.2.tar.gz && \
    cd gsa-8.0.2 && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make && \
    make install && \
    rm /usr/src/v8.0.2.tar.gz && \
    rm -rf /usr/src/gsa-8.0.2

#Build gvmd
RUN cd /usr/src && \
    wget -nv https://github.com/greenbone/gvmd/archive/v8.0.2.tar.gz && \
    tar -zxf v8.0.2.tar.gz && \
    cd gvmd-8.0.2 && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make && \
    make install && \
    rm /usr/src/v8.0.2.tar.gz && \
    rm -rf /usr/src/gvmd-8.0.2

#Build ospd
RUN cd /usr/src && \
    wget -nv https://github.com/greenbone/ospd/archive/v1.3.2.tar.gz && \
    tar -zxf v1.3.2.tar.gz && \
    cd ospd-1.3.2 && \
    python3 setup.py install && \
    rm /usr/src/v1.3.2.tar.gz && \
    rm -rf /usr/src/ospd-1.3.2

#Build ospd-openvas
RUN cd /usr/src && \
    wget -nv https://github.com/greenbone/ospd-openvas/archive/v1.0.1.tar.gz && \
    tar -zxf v1.0.1.tar.gz && \
    cd ospd-openvas-1.0.1 && \
    python3 setup.py install && \
    rm /usr/src/v1.0.1.tar.gz && \
    rm -rf /usr/src/ospd-openvas-1.0.1

COPY ./scripts/greenbone-*.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/greenbone-*.sh

RUN /usr/local/bin/greenbone-sync.sh

COPY ./scripts/docker-entrypoint.sh /usr/local/bin
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

EXPOSE 80 443 9390 9391 9392
