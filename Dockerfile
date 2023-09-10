FROM ubuntu:22.04
RUN apt-get update && \
      apt-get -y install sudo

RUN useradd -m docker && echo "docker:docker" | chpasswd && adduser docker sudo
RUN echo 'newuser ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER root
COPY autotest.sh /home/
WORKDIR /home/results
ENTRYPOINT bash ../autotest.sh 5
