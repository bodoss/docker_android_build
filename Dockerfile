# docker run --rm -v "{PROJ_PATH}":/proj/ --workdir="/proj/" andbuild /bin/sh -c "./gradlew clean assembleDebug"
# docker run -it --rm -v {GRADLE_CACHE}:/root/.gradle/  -v "{PROJ_PATH}":/proj/ --workdir="/proj/" --entrypoint /bin/bash andbuild

FROM openjdk:8

MAINTAINER Bohdan Trofymchuk "bohdan.trofymchuk@gmail.com"

ENV VERSION_BUILD_TOOLS "27.0.3"
ENV VERSION_TARGET_SDK "27"

# Install Deps
RUN apt-get --quiet update --yes
#RUN echo deb http://http.debian.net/debian jessie-backports main >> /etc/apt/sources.list
RUN apt-get --quiet install --yes wget tar git unzip lib32stdc++6 lib32z1 rsync nano

# Install Android SDK
RUN cd /opt && \
    wget --output-document=android-sdk.zip --quiet https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip && \
    unzip android-sdk.zip -d android-sdk-linux && \
    rm -f android-sdk.zip && chown -R root.root android-sdk-linux

# Setup environment
ENV ANDROID_HOME /opt/android-sdk-linux
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools
RUN mkdir -p $ANDROID_HOME/licenses/ \
  && echo "8933bad161af4178b1185d1a37fbf41ea5269c55" > $ANDROID_HOME/licenses/android-sdk-license \
  && echo "84831b9409646a918e30573bab4c9c91346d8abd" > $ANDROID_HOME/licenses/android-sdk-preview-license

RUN mkdir /root/.android
RUN touch /root/.android/repositories.cfg

# Install sdk elements
RUN (while [ 1 ]; do sleep 5; echo y; done) | ${ANDROID_HOME}/tools/bin/sdkmanager "platform-tools" "platforms;android-${VERSION_TARGET_SDK}" "build-tools;${VERSION_BUILD_TOOLS}" "extras;google;m2repository" "extras;google;google_play_services" "patcher;v4" --verbose

ENV HOME /root

RUN which java
RUN which android
RUN which git
RUN which adb

# Cleaning
RUN apt-get clean

# GO to workspace
RUN mkdir -p /opt/workspace
VOLUME /root/.gradle
WORKDIR /opt/workspace