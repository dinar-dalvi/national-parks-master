# Pull base image
#From tomcat:8-jre8

# Maintainer
#MAINTAINER "dinar dalvi"


# Pull base image.
FROM ubuntu:14.04
MAINTAINER Dinar Dalvi 

ENV TOMCAT_VERSION 8.0.48

# Set locales
RUN locale-gen en_GB.UTF-8
ENV LANG en_GB.UTF-8
ENV LC_CTYPE en_GB.UTF-8

# Fix sh
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Install dependencies
RUN apt-get update && \
apt-get install -y git build-essential curl wget software-properties-common

# Install JDK 8
RUN \
	sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
	apt-get update && \
	apt-get install -y wget curl build-essential software-properties-common python-software-properties nano && \
	add-apt-repository ppa:openjdk-r/ppa && \
	apt-get update && \ 
	apt-get -y install openjdk-8-jdk && \  
	update-alternatives --config java && \
	export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64/jre && \
	export JRE_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64/jre 

# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/jre

# Get Tomcat
RUN wget --quiet --no-cookies http://apache.rediris.es/tomcat/tomcat-8/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz -O /tmp/tomcat.tgz && \
tar xzvf /tmp/tomcat.tgz -C /opt && \
mv /opt/apache-tomcat-${TOMCAT_VERSION} /opt/tomcat && \
rm /tmp/tomcat.tgz && \
rm -rf /opt/tomcat/webapps/examples && \
rm -rf /opt/tomcat/webapps/docs && \
rm -rf /opt/tomcat/webapps/ROOT

# Add admin/admin user
ADD tomcat-users.xml /opt/tomcat/conf/

ENV CATALINA_HOME /opt/tomcat
ENV PATH $PATH:$CATALINA_HOME/bin

EXPOSE 8080
EXPOSE 8009
VOLUME "/opt/tomcat/webapps"
WORKDIR /opt/tomcat

COPY import-data.sh /home/ubuntu/import-data.sh
COPY national-parks.json /home/ubuntu/national-parks.json

RUN chmod +x /home/ubuntu/import-data.sh
RUN chmod 755 /home/ubuntu/import-data.sh
# Copy to images tomcat path
COPY national-parks.war /opt/tomcat/webapps/national-parks.war


RUN groupadd -r mongodb && useradd -r -g mongodb mongodb
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
RUN echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | tee /etc/apt/sources.list.d/10gen.list


RUN apt-get update
RUN apt-get install mongodb-10gen

VOLUME ["/data/db"]

WORKDIR /data

RUN mkdir -p /data/db

EXPOSE 27017
EXPOSE 28017


CMD ["/home/ubuntu/import-data.sh"]

ENTRYPOINT ["/bin/bash"]



# Launch Tomcat
#CMD ["/opt/tomcat/bin/catalina.sh", "run"]




#/usr/local/tomcat/webapps/

#RUN \
#  apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10 && \
#  echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' > /etc/apt/sources.list.d/mongodb.list && \
#  apt-get update && \
#  apt-get install -y mongodb-org && \
#  rm -rf /var/lib/apt/lists/*

# Define mountable directories.
#VOLUME ["/data/db"]

# Define working directory.
#WORKDIR /data

# Define default command.
#CMD ["mongod"]

# Expose ports.
#   - 27017: process
#   - 28017: http
#EXPOSE 27017
#EXPOSE 28017