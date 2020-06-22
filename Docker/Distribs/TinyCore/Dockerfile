FROM tatsushid/tinycore:11.0-x86

MAINTAINER "Cqls Team"

RUN tce-load -w -i mirrors.tcz

RUN  tce-load -wic Xvesa gtk3 curl openssl-1.1.1 dbus

RUN useradd -m user

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

USER user

ENV PATH /home/user/macHome/RedGTK/bin:/home/user/red:$PATH

RUN mkdir /home/user/macHome

WORKDIR /home/user/macHome

CMD ["/bin/bash"]
