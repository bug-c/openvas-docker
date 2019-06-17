FROM ubuntu:18.04

COPY config/redis.config /etc/redis/redis.config
COPY config/openvassd.conf /etc/openvas/openvassd.conf
COPY openvas-check-setup /openvas-check-setup
COPY start /start

ENV DEBIAN_FRONTEND=noninteractive \
    OV_PASSWORD=admin
	
#End version
RUN apt-get update && \
    apt-get install software-properties-common \
	openvas \
	openvas-cli \
	openvas-manager \
	openvas-scanner \
	libopenvas9 \
	libopenvas-dev \
	gnupg-agent \
	curl \
	wget \
	rsync \
	sqlite3 \
	xsltproc \
	--no-install-recommends -yq && \
	rm -rf /var/lib/apt/lists/*
	

RUN mkdir -p /var/run/redis && \
	chmod +x /start && \
    chmod +x /openvas-check-setup && \
	sed -i 's/MANAGER_ADDRESS=127.0.0.1/MANAGER_ADDRESS=0.0.0.0/' /etc/default/openvas-manager && \
    sed -i 's/SCANNER_SOCKET=.*/SCANNER_SOCKET=\/var\/run\/openvassd.sock/' /etc/default/openvas-scanner && \
    sed -i 's/GSA_ADDRESS=127.0.0.1/GSA_ADDRESS=0.0.0.0/' /etc/default/greenbone-security-assistant && \
    sed -i 's/GSA_PORT=.*/GSA_PORT=80/' /etc/default/greenbone-security-assistant && \
    sed -i '/^\[ "$MANAGER_PORT" \]/aDAEMONOPTS="$DAEMONOPTS  --http-only"' /etc/init.d/greenbone-security-assistant && \
	openvas-manage-certs -a > /dev/null && \
	greenbone-nvt-sync > /dev/null && \
	greenbone-scapdata-sync > /dev/null && \
	greenbone-certdata-sync > /dev/null && \
	BUILD=true /start && \
    service openvas-scanner stop && \
    service openvas-manager stop && \
    service greenbone-security-assistant stop && \
    service redis-server stop
	
ENV BUILD=""

CMD /start

EXPOSE 80 9390
