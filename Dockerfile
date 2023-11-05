FROM graalvm/graalvm-community@sha256:ccfea31d993fb9df6a59dfe2cee8f2436cc76bbb81d0ebc9f22f7beeade9489c
#FROM ghcr.io/graalvm/graalvm-community:23.0.2
#FROM ghcr.io/graalvm/graalvm-community:17.0.9

# Setup tools
RUN yum update -y && yum install wget -y && yum install unzip -y && yum install patch -y

# https://github.com/oracle/graalpython/releases/download/graal-23.1.1/graalpy-community-jvm-23.1.1-linux-aarch64.tar.gz
# https://github.com/oracle/graalpython/releases/download/graal-23.1.1/graalpy-community-23.1.1-linux-aarch64.tar.gz
# curl -fsSL -o /tmp/graalpy.tar.gz https://github.com/oracle/graalpython/releases/download/graal-23.1.1/graalpy-23.1.1-linux-aarch64.tar.gz
# tar xfz /tmp/graalpy.tar.gz -C /tmp
# Install graalpy
#RUN gu install python
RUN graalpy -m venv project_matcher_venv \
    && source project_matcher_venv/bin/activate \
    && graalpy -m pip install --upgrade pip \
    && graalpy -m ginstall install numpy

# Install maven
ARG MAVEN_VERSION=3.8.8
ARG USER_HOME_DIR="/root"
ARG BASE_URL=https://apache.osuosl.org/maven/maven-3/${MAVEN_VERSION}/binaries

RUN mkdir -p /usr/share/maven /usr/share/maven/ref \
 && curl -fsSL -o /tmp/apache-maven.tar.gz ${BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
 && tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1 \
 && rm -f /tmp/apache-maven.tar.gz \
 && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

ENV MAVEN_HOME /usr/share/maven
ENV MAVEN_CONFIG "$USER_HOME_DIR/.m2"

# Setup spring-application
RUN mkdir -p /projectmatcher
COPY . .
EXPOSE 8080
RUN mvn clean verify
CMD [ "mvn", "spring-boot:run" ]