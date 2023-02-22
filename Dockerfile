FROM ubuntu:18.04

RUN apt-get update && apt-get install -y openssh-server

RUN apt-get install -y sudo
COPY ./apt-sudoers /etc/sudoers.d/apt-sudoers

RUN mkdir /var/run/sshd
RUN echo 'root:sal-t3st' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
RUN service ssh restart

RUN useradd -m --shell /bin/bash sal-ansible
RUN usermod -aG sudo sal-ansible
RUN mkdir /home/sal-ansible/.ssh
COPY ./sal-ansible-key.pub /home/sal-ansible/.ssh/authorized_keys
RUN chown -R sal-ansible:sal-ansible /home/sal-ansible/.ssh
RUN chmod 700 /home/sal-ansible/.ssh
RUN chmod 644 /home/sal-ansible/.ssh/authorized_keys

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]

#   377  docker build -t sal-ansible-sandbox:1.1 .
# docker run -d -p -n ansible-target01 2223:22 sal-ansible-sandbox:1.1 
# ssh -i /home/zmk/tools/ansible/tests/sandbox/sal-ansible-key sal-ansible@localhost -p 2223
