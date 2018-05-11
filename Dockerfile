FROM jenkins/jenkins:lts

ENV DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true

USER root
RUN apt-get clean && apt-get update && apt-get install -y locales
RUN locale-gen --purge en_US.UTF-8
RUN dpkg-reconfigure locales
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

COPY locale /etc/default/locale

#RUN echo "deb http://archive.ubuntu.com/ubuntu trusty main universe" > /etc/apt/sources.list
RUN apt-get -qq update
RUN apt-get -y -q install build-essential software-properties-common wget curl git fontconfig
RUN add-apt-repository -y ppa:mozillateam/firefox-next

# Maven 3.0.5
# COPY maven /opt/maven
# RUN tar -zxf /opt/maven/apache-maven-3.0.5-bin.tar.gz -C /opt/maven
# RUN ln -s /opt/maven/apache-maven-3.0.5/bin/mvn /usr/bin

# Set Java and Maven env variables
# ENV M2_HOME /opt/maven/apache-maven-3.0.5
# ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
# ENV JAVA_OPTS -Xmx2G -Xms2G -XX:PermSize=256M -XX:MaxPermSize=256m

# Load scripts
COPY bootstrap bootstrap
RUN chmod +x -Rv bootstrap

# Add user jenkins to the image
# RUN adduser --quiet jenkins
# RUN adduser jenkins sudo
# RUN echo "jenkins:jenkins" | chpasswd

# NVM
RUN mkdir -p /opt/nvm
RUN git clone https://github.com/creationix/nvm.git /opt/nvm
RUN ./bootstrap/nvm.sh
RUN echo "source /opt/nvm/nvm.sh" >> /root/.profile

# Adjust perms for jenkins user
# RUN chown -R jenkins /opt/nvm
# RUN touch /home/jenkins/.profile
# RUN echo "source /opt/nvm/nvm.sh" >> /home/jenkins/.profile
# RUN chown jenkins /home/jenkins/.profile

# Browsers
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN echo "deb http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google.list
RUN apt-get update -y
RUN apt-get install -y -q \
  firefox \
  google-chrome-stable \
  openjdk-8-jre-headless \
  x11vnc \
  xvfb \
  xfonts-100dpi \
  xfonts-75dpi \
  xfonts-scalable \
  xfonts-cyrillic

# Shim chrome to disable sandbox
# See https://github.com/docker/docker/issues/1079
RUN mv /usr/bin/google-chrome /usr/bin/google-chrome.orig
COPY shims/google-chrome /usr/bin/google-chrome
RUN chmod +x /usr/bin/google-chrome
RUN mkdir -p /usr/share/desktop-directories

# xvfb
COPY init.d/xvfb /etc/init.d/xvfb
RUN chmod +x /etc/init.d/xvfb

COPY versions.sh /tmp/versions.sh
RUN chmod +x /tmp/versions.sh
RUN /tmp/versions.sh

USER jenkins
