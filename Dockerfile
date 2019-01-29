FROM alpine:latest

# Setup demo environment variables
ENV HOME=/root \
  DEBIAN_FRONTEND=noninteractive \
  LANG=en_US.UTF-8 \
  LANGUAGE=en_US.UTF-8 \
  LC_ALL=C.UTF-8 \
  DISPLAY=:0.0 \
  DISPLAY_WIDTH=1024 \
  DISPLAY_HEIGHT=768

# x11vnc is in comunity repo
RUN echo "http://dl-cdn.alpinelinux.org/alpine/latest-stable/community" >> /etc/apk/repositories

# Install git, supervisor, VNC, & X11 packages
RUN apk --update --upgrade add \
  bash \
  i3wm \
  git \
  socat \
  supervisor \
  x11vnc \
  xterm \
  xvfb

# Clone noVNC from github
RUN git clone https://github.com/novnc/noVNC.git /root/noVNC \
  && git clone https://github.com/novnc/websockify /root/noVNC/utils/websockify \
  && rm -rf /root/noVNC/.git \
  && rm -rf /root/noVNC/utils/websockify/.git \
  && apk del git

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Modify the launch script 'ps -p'
RUN sed -i -- "s/ps -p/ps -o pid | grep/g" /root/noVNC/utils/launch.sh

# Configure i3 window manager
RUN sed -i '/exec i3-config-wizard/d' /etc/i3/config

EXPOSE 8080

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
