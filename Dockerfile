FROM ghcr.io/linuxserver/baseimage-ubuntu:jammy

# set version label
ARG BUILD_DATE
ARG VERSION
ARG OPENVPNAS_VERSION 
LABEL build_version="${VERSION} Build-date:- ${BUILD_DATE}"


# environment settings
ARG DEBIAN_FRONTEND="noninteractive"

RUN \
 echo "**** install dependencies ****" && \
 apt update && \
 apt upgrade -y && \
 apt install -y \
	systemd \
	bridge-utils \
	file \
	gnupg \
	iproute2 \
	iptables \
	libatm1 \
	libelf1 \
	libexpat1 \
	libiptc0 \
	liblzo2-2 \
	libmagic-mgc \
	libmagic1 \
	libmariadb3 \
	libmnl0 \
	libmysqlclient21 \
	libnetfilter-conntrack3 \
	libnfnetlink0 \
	libpcap0.8 \
	libpython3-stdlib \
	libxtables12 \
	mime-support \
	mysql-common \
	net-tools \
	python3-minimal \
	python3-decorator \
	python3-ldap3 \
	python3-migrate \
	python3-minimal \
	python3-mysqldb \
	python3-pbr \
	python3-pkg-resources \
	python3-pyasn1 \
	python3-six \
	python3-sqlalchemy \
	python3-sqlparse \
	python3-tempita \
	sqlite3 \
	xz-utils \
	# openvps-as dependencies:
	dmidecode \
	ieee-data \
	libnl-3-200 \
	libnl-genl-3-200 \
	libxmlsec1 \
	libxmlsec1-openssl \
	libxslt1.1 \
	python3-arrow \
	python3-attr \
	python3-automat \
	python3-bcrypt \
	python3-bs4 \
	python3-cffi \
	python3-cffi-backend \
	python3-chardet \
	python3-click \
	python3-colorama \
	python3-constantly \
	python3-cryptography \
	python3-dateutil \
	python3-defusedxml \
	python3-hamcrest \
	python3-html5lib \
	python3-hyperlink \
	python3-idna \
	python3-incremental \
	python3-lxml \
	python3-netaddr \
	python3-openssl \
	python3-ply \
	python3-pyasn1-modules \
	python3-pycparser \
	python3-service-identity \
	python3-soupsieve \
	python3-twisted \
	python3-webencodings \
	python3-zope.interface && \
	rm -rf /var/cache/apt /var/lib/apt/lists


RUN	echo "**** add openvpn-as repo ****" && \
	# save gpg key in in /usr/share/keyrings/
	curl https://as-repository.openvpn.net/as-repo-public.gpg | gpg --dearmor | tee /usr/share/keyrings/openvpn-as_repo-public.gpg && \
	echo "deb [signed-by=/usr/share/keyrings/openvpn-as_repo-public.gpg] http://as-repository.openvpn.net/as/debian jammy main">/etc/apt/sources.list.d/openvpn-as-repo.list && \
	if [ -z ${OPENVPNAS_VERSION+x} ]; then \
		OPENVPNAS_VERSION=$(curl -sX GET http://as-repository.openvpn.net/as/debian/dists/jammy/main/binary-amd64/Packages.gz | gunzip -c \
		|grep -A 7 -m 1 "Package: openvpn-as" | awk -F ": " '/Version/{print $2;exit}');\
	fi && \
	echo "$OPENVPNAS_VERSION" > /version.txt && \
	echo "**** ensure home folder for abc user set to /config ****" && \
	usermod -d /config abc && \
	echo "**** create admin user and set default password for it ****" && \
	useradd -s /sbin/nologin admin && \
	echo "admin:passwOrd+2" | chpasswd && \
	rm -rf /tmp/*

# add local files
COPY /root /

# ports and volumes
EXPOSE 943/tcp 1194/udp 9443/tcp
VOLUME /config

