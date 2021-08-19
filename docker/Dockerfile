FROM archlinux/archlinux
LABEL maintainer="caolei6767@163.com"

EXPOSE 22

# WORKAROUND for glibc 2.33 and old Docker
# See https://github.com/actions/virtual-environments/issues/2658
# Thanks to https://github.com/lxqt/lxqt-panel/pull/1562
# RUN patched_glibc=glibc-linux4-2.33-4-x86_64.pkg.tar.zst && \
#    curl -LO "https://repo.archlinuxcn.org/x86_64/$patched_glibc" && \
#    bsdtar -C / -xvf "$patched_glibc"

RUN pacman -Syyu\
    && pacman -Syu sudo openssh --noconfirm --needed\
    && ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key \
    && ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key \
    && ssh-keygen -q -N "" -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key \
    && ssh-keygen -A \
    && sed -i "s/#*UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config \
    && sed -i "s/#*UsePAM.*/UsePAM no/g" /etc/ssh/sshd_config \
    && sed -i "s/#*PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config

CMD ["/usr/bin/sshd", "-D"]
