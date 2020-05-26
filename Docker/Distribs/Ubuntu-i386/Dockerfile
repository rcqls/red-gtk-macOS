FROM i386/ubuntu

MAINTAINER "Cqls Team"


RUN apt-get update && apt-get install -y wget && apt-get install -y git

RUN apt-get install -y libc6 libcurl4 

RUN apt-get install -y libgtk-3-bin librsvg2-common libcanberra-gtk-module  libcanberra-gtk3-module  at-spi2-core 

RUN apt-get install -y dbus-x11 strace

RUN apt-get autoclean && apt-get clean && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

RUN useradd -m user

RUN mkdir -p /var/run/dbus

USER user

RUN mkdir -p /home/user/rebol

WORKDIR /home/user/rebol

RUN wget http://www.rebol.com/downloads/v278/rebol-core-278-4-3.tar.gz

RUN tar xzvf rebol-core-278-4-3.tar.gz

ENV PATH /home/user/rebol/releases/rebol-core:$PATH

RUN chmod u+x /home/user/rebol/releases/rebol-core/rebol

RUN mkdir -p /home/user/red

WORKDIR /home/user/red

RUN wget  http://static.red-lang.org/dl/branch/GTK/linux/red-latest

RUN ln -s red-latest red

ADD red-compile /home/user/red/red-compile

USER root

#DEVEL# RUN chmod u+x console && chown user:user console

RUN chmod u+x red-latest && chown user:user red-latest

RUN chmod u+x red-compile && chown user:user red-compile

## cleanup package manager

RUN apt-get autoclean && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


USER user

ENV PATH /home/user/macHome/RedGTK/bin:/home/user/red:$PATH

RUN mkdir /home/user/macHome

WORKDIR /home/user/macHome

CMD ["/bin/bash"]
