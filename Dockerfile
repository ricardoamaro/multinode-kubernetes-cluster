# This is a vagrant docker image 
FROM ubuntu:20.04
MAINTAINER Ricardo Amaro <mail_at_ricardoamaro.com>
ENV container docker
ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
  apt-get install -y apt-transport-https ca-certificates sudo gnupg-agent \
  software-properties-common python3 git curl wget systemd systemd-sysv && \
  apt-get -y clean && apt -y autoremove && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN cd /lib/systemd/system/sysinit.target.wants/ && \
  ls | grep -v systemd-tmpfiles-setup | xargs rm -f $1

RUN rm -f /lib/systemd/system/multi-user.target.wants/* \
  /etc/systemd/system/*.wants/* \
  /lib/systemd/system/local-fs.target.wants/* \
  /lib/systemd/system/sockets.target.wants/*udev* \
  /lib/systemd/system/sockets.target.wants/*initctl* \
  /lib/systemd/system/basic.target.wants/* \
  /lib/systemd/system/anaconda.target.wants/* \
  /lib/systemd/system/plymouth* \
  /lib/systemd/system/systemd-update-utmp*

RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
  curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
  add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" && \
  add-apt-repository "deb https://apt.kubernetes.io/ kubernetes-xenial main" && \
  apt-get update && \
  apt-get install -y openssh-server docker-ce docker-ce-cli containerd.io kubelet kubeadm kubectl && \
  apt-get -y clean && apt -y autoremove

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

EXPOSE 22 80 443 2379 2380 6443 10250-10256 30000-32767
VOLUME [ “/sys/fs/cgroup” ]
CMD ["/usr/lib/systemd/systemd", "--system"]
