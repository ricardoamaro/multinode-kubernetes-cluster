# This is a vagrant docker image based on ubuntu 20.04 and kind
FROM kindest/base:v20200713-95e25d21
MAINTAINER Ricardo Amaro <mail_at_ricardoamaro.com>
ENV container docker
ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
  apt-get -y upgrade && \
  apt-get install -y apt-transport-https ca-certificates sudo gnupg-agent \
  software-properties-common python3 git nano curl wget systemd systemd-sysv && \
  apt -y --purge remove apparmor && \
  apt-get -y clean && apt -y autoremove

RUN cd /lib/systemd/system/sysinit.target.wants/ && \
  ls | grep -v systemd-tmpfiles-setup | xargs rm -f $1

RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
  curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
  add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" && \
  add-apt-repository "deb https://apt.kubernetes.io/ kubernetes-xenial main" && \
  apt-get update && \
  apt-get install -y openssh-server docker-ce kubelet kubeadm kubectl && \
  apt-get -y clean && apt -y autoremove  && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN useradd -m vagrant && \
  echo 'vagrant:vagrant' | chpasswd && \
  usermod -aG docker vagrant

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

RUN rm -f /lib/systemd/system/docker.service

EXPOSE 22 80 443 2379 2380 6443 10250-10256 30000-32767
VOLUME [ "/sys/fs/cgroup", "/lib/modules", "/usr/src/", "/var/run/docker.sock" ]
CMD ["/usr/lib/systemd/systemd", "--system", "--unit=multi-user.target"]
