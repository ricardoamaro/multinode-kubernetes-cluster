# This is a vagrant docker image 
FROM ubuntu:20.04
MAINTAINER Ricardo Amaro <mail_at_ricardoamaro.com>
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
  apt-get install -y sudo openssh-server python git curl wget && \
  apt-get clean

RUN useradd -m vagrant && \
  echo 'vagrant:vagrant' | chpasswd

RUN echo "vagrant ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/vagrant && \
  chmod 440 /etc/sudoers.d/vagrant && \
  mkdir /home/vagrant/.ssh/ && \
  curl https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant.pub > /home/vagrant/.ssh/authorized_keys && \
  chown -fR vagrant:vagrant /home/vagrant 

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd; \
  echo 'PermitRootLogin yes ' >> /etc/ssh/sshd_config; \
  echo 'UseDNS no' >> /etc/ssh/sshd_config; \
  mkdir -p /var/run/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22 80 443 2379 2380 6443 10250-10256 30000-32767
CMD ["/usr/sbin/sshd", "-D"]
