FROM ubuntu:17.04

LABEL author="Dimitris Garofalakis<kascrew1@gmail.com>"
# Home
ENV HOME /home/root
WORKDIR $HOME

# Environment setup
# apt-get
ENV DEBIAN_FRONTEND noninteractive
# Java
ENV JAVA_HOME "/usr/lib/jvm/java-8-oracle"
# Android
ENV ANDROID_HOME $HOME/sdktools
ENV ANDROID_AVD_HOME $HOME/.android/avd
ENV PATH ${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:$PATH
# https://stackoverflow.com/questions/26974644/no-keyboard-input-in-qt-creator-after-update-to-qt5
ENV QT_XKB_CONFIG_ROOT /usr/share/X11/xkb

# Create directories & files required by installers
# Run apt update
RUN mkdir -p $HOME && \
    mkdir -p $HOME/.android && \
    mkdir -p $ANDROID_AVD_HOME && \
    mkdir -p /root/.android/ && \
    touch /root/.android/repositories.cfg && \
    apt-get update -qq

# Install java, emulator & atom dependencies
RUN apt-get install -qq -y \
    g++ \
    libasound2 pulseaudio alsa-utils mplayer \
    libcanberra-gtk3-module \
    libcanberra-gtk-module \
    libglu1-mesa \
    libxkbfile1 \
    libgl1-mesa-glx \
    libgl1-mesa-dri \
    python-software-properties \
    qemu-system-i386 \
    qemu-kvm libvirt-bin ubuntu-vm-builder bridge-utils \
    software-properties-common \
    ttf-freefont \
    unzip

# Add Java 8 repo  (apt update required afterwards)
# Auto-accept oracle's license
# Install Java 8
# Download and unzip android sdktools
# Accept all Android licenses
# Download tools for targeting API 26
# Add downloaded libstdc++.so.6 file to /usr/lib (required by emulator)
RUN add-apt-repository -y ppa:webupd8team/java && \
    apt-get update -qq && \
    echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections && \
    apt-get install -qq -y --no-install-recommends oracle-java8-installer && \
    wget -O sdktools.zip https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip && \
    unzip -qq sdktools.zip -d sdktools && \
    rm -f sdktools.zip && \
    yes | sdkmanager --licenses && \
    sdkmanager --verbose "tools" "platform-tools" "platforms;android-26" "build-tools;26.0.2" \
                   "extras;android;m2repository" "extras;google;m2repository" && \
    ln -sf /usr/lib/libstdc++.so.6  ${ANDROID_HOME}/emulator/lib64/libstdc++/libstdc++.so.6

# Create emulators
ADD avd_conf avd_conf
ADD create_emulators.sh create_emulators.sh
RUN chmod +x create_emulators.sh
RUN ./create_emulators.sh

ENTRYPOINT ["/bin/sh", "-c"]
