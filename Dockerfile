FROM ubuntu:18.04

ENV container docker
ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive

RUN sed -i 's/# deb/deb/g' /etc/apt/sources.list

RUN apt-get update \
    && apt-get install -y systemd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN cd /lib/systemd/system/sysinit.target.wants/ \
    && ls | grep -v systemd-tmpfiles-setup | xargs rm -f $1

RUN rm -f /lib/systemd/system/multi-user.target.wants/* \
    /etc/systemd/system/*.wants/* \
    /lib/systemd/system/local-fs.target.wants/* \
    /lib/systemd/system/sockets.target.wants/*udev* \
    /lib/systemd/system/sockets.target.wants/*initctl* \
    /lib/systemd/system/basic.target.wants/* \
    /lib/systemd/system/anaconda.target.wants/* \
    /lib/systemd/system/plymouth* \
    /lib/systemd/system/systemd-update-utmp*



RUN apt-get update && apt-get install -y openssh-server vim iputils-ping python
RUN mkdir /var/run/sshd
RUN mkdir ~/.ssh; chmod 700 ~/.ssh; touch ~/.ssh/authorized_keys; chmod 600 ~/.ssh/authorized_keys
RUN echo 'root:1234' | chpasswd
RUN sed -i 's/^#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

# Run sshd service
#RUN /usr/sbin/sshd -D &

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

VOLUME [ "/sys/fs/cgroup" ]

EXPOSE 22

RUN /lib/systemd/systemd &

CMD ["/usr/sbin/sshd", "-D"]
#CMD ["/lib/systemd/systemd"]
#CMD /usr/sbin/sshd -D & && /lib/systemd/systemd
#CMD /lib/systemd/systemd & && /usr/sbin/sshd -D &
#CMD /lib/systemd/systemd 

