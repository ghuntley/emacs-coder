FROM ubuntu:22.10
MAINTAINER Hippie Hacker <hh@ii.coop>
RUN apt-get update && \
  DEBIAN_FRONTEND="noninteractive" apt-get install --yes \
  software-properties-common \
  ripgrep \
  fasd \
  libtool-bin \
  sudo
# Created a ppa for emacs + broadway&nativecomp (build/Dockerfile has some of the process documented)
# We need a custom build to run against broadwayd
RUN add-apt-repository ppa:hippiehacker/emacs-broadway --yes && \
  DEBIAN_FRONTEND="noninteractive" apt-get install --yes emacs-snapshot emacs-snapshot-el
# Use upstream stable git
RUN add-apt-repository ppa:git-core/ppa --yes && \
  DEBIAN_FRONTEND="noninteractive" apt-get install --yes git

# Add a user `coder` so that you're not developing as the `root` user
RUN useradd coder \
    --create-home \
    --shell=/bin/bash \
    --uid=1000 \
    --user-group && \
    echo "coder ALL=(ALL) NOPASSWD:ALL" >>/etc/sudoers.d/nopasswd

USER coder

WORKDIR /home/coder

# # COPY fonts/* /home/gitpod/.local/share/fonts/
# # RUN mkdir -p /home/gitpod/.local/share/fonts/
RUN git clone --depth 1 https://github.com/hlissner/doom-emacs ~/.emacs.d
RUN git clone --depth 1 https://github.com/humacs/.doom.d ~/.doom.d
# Will need to update the shell if we want these in the path
# ENV PATH=$HOME/.doom.d/bin:$HOME/.emacs.d/bin:$PATH
# yes answers 'y' to any questions from doom install
# Would prefer not to, as the output get buffered.
# Possibly a doom install bug, that we can't provide answeres via cli args
RUN yes y | $HOME/.emacs.d/bin/doom install && $HOME/.emacs.d/bin/doom sync