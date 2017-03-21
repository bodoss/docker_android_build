FROM openjdk:8

MAINTAINER Bohdan Trofymchuk "bohdan.trofymchuk@gmail.com"

ENV VERSION_SDK_TOOLS "25.2.4"
ENV VERSION_BUILD_TOOLS "25.0.2"
ENV VERSION_TARGET_SDK "25"
ENV SDK_PACKAGES "build-tools-${VERSION_BUILD_TOOLS},android-${VERSION_TARGET_SDK},addon-google_apis-google-${VERSION_TARGET_SDK},platform-tools,extra-android-m2repository,extra-android-support,extra-google-google_play_services,extra-google-m2repository"

# Install Deps
RUN apt-get --quiet update --yes
#RUN echo deb http://http.debian.net/debian jessie-backports main >> /etc/apt/sources.list
RUN apt-get --quiet install --yes wget tar git unzip lib32stdc++6 lib32z1

# Install Android SDK
RUN cd /opt && \
    wget --output-document=android-sdk.zip --quiet http://dl.google.com/android/repository/tools_r${VERSION_SDK_TOOLS}-linux.zip && \
    unzip android-sdk.zip -d android-sdk-linux && \
    rm -f android-sdk.zip && chown -R root.root android-sdk-linux

# Setup environment
ENV ANDROID_HOME /opt/android-sdk-linux
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools
RUN mkdir -p $ANDROID_HOME/licenses/ \
  && echo "8933bad161af4178b1185d1a37fbf41ea5269c55" > $ANDROID_HOME/licenses/android-sdk-license \
  && echo "84831b9409646a918e30573bab4c9c91346d8abd" > $ANDROID_HOME/licenses/android-sdk-preview-license

# Install sdk elements
RUN (while [ 1 ]; do sleep 5; echo y; done) | ${ANDROID_HOME}/tools/android update sdk -u -a -t ${SDK_PACKAGES}

#install gradle
RUN cd /opt && wget --quiet --output-document=gradle.zip https://services.gradle.org/distributions/gradle-3.4.1-bin.zip && unzip -q gradle.zip && rm -f gradle.zip && chown -R root.root /opt/gradle-3.4.1/bin
ENV PATH ${PATH}:/opt/gradle-3.4.1/bin
ENV HOME /root

# Set up and run emulator
#RUN echo y | android --silent update sdk --no-ui --all --filter sys-img-armeabi-v7a-android-22
#RUN echo no | android create avd --force -n test -c 30M -t android-22
#ADD wait-for-emulator /usr/local/bin/
#ADD start-emulator /usr/local/bin/

RUN which java
RUN which android
RUN which git
RUN which gradle
RUN which adb

# Cleaning
RUN apt-get clean

# GO to workspace
RUN mkdir -p /opt/workspace
VOLUME /root/.gradle
WORKDIR /opt/workspace