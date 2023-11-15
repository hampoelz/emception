# This is the last tested version of emscripten.
# Feel free to try with a newer version
FROM emscripten/emsdk:3.1.24

RUN DEBIAN_FRONTEND=noninteractive apt -qy update && \
    DEBIAN_FRONTEND=noninteractive apt -qy install \
    pkg-config \
    ninja-build \
    jq \
    brotli \
    autoconf \
    autoconf-archive \
    automake \
    zlib1g-dev \
    libssl-dev \
    build-essential \
    ca-certificates \
    curl \
    gnupg

# install latest cmake
RUN DEBIAN_FRONTEND=noninteractive apt -qy install software-properties-common lsb-release wget
RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | sudo tee /etc/apt/trusted.gpg.d/kitware.gpg >/dev/null
RUN apt-add-repository "deb https://apt.kitware.com/ubuntu/ $(lsb_release -cs) main"
RUN apt update && DEBIAN_FRONTEND=noninteractive apt -qy install kitware-archive-keyring dirmngr && rm /etc/apt/trusted.gpg.d/kitware.gpg
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 6AF7F09730B3F0A4 && apt update && DEBIAN_FRONTEND=noninteractive apt -qy install cmake

# Add to PATH the clang version that ships with emsdk
# hack to make tho path persists
RUN echo "export PATH=${EMSDK}/upstream/bin:${PATH}" >> /root/.bashrc

# When running the contianer with a custom user/group, we need to provide that user with
# access to ~/.npm (in this case, /.npm).
# The easiest is to give access to everyone.
RUN mkdir -p /.npm && chmod a+rwx /.npm

