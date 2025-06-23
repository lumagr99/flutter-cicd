FROM jenkins/inbound-agent:3309.v27b_9314fd1a_4-4-jdk17

USER root

# System-Tools installieren
RUN apt-get update && apt-get install -y \
    curl git unzip xz-utils zip libglu1-mesa \
    && apt-get clean

# Verzeichnisse definieren
ENV JENKINS_HOME=/home/jenkins
ENV FLUTTER_HOME=${JENKINS_HOME}/flutter
ENV ANDROID_SDK_ROOT=${JENKINS_HOME}/android-sdk

# Dynamischer PATH
ENV PATH="\
${FLUTTER_HOME}/bin:\
${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:\
${ANDROID_SDK_ROOT}/platform-tools:\
${PATH}"

# --- Flutter installieren ---
RUN git clone https://github.com/flutter/flutter.git -b 3.29 ${FLUTTER_HOME} \
    && chown -R jenkins:jenkins ${FLUTTER_HOME}

# --- Android SDK command-line tools installieren ---
RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools \
    && curl -sSL https://dl.google.com/android/repository/commandlinetools-linux-10406996_latest.zip -o cmdline-tools.zip \
    && unzip cmdline-tools.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools \
    && mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/latest \
    && rm cmdline-tools.zip

# Fallback: platform-tools direkt installieren (für adb)
RUN curl -sSL https://dl.google.com/android/repository/platform-tools-latest-linux.zip -o platform-tools.zip && \
    unzip -o platform-tools.zip -d ${ANDROID_SDK_ROOT} && \
    rm platform-tools.zip

# Rechte für Jenkins-User
RUN chown -R jenkins:jenkins ${ANDROID_SDK_ROOT}

# --- Wechsel zum Jenkins-User ---
USER jenkins

# Android SDK Komponenten installieren
RUN yes | sdkmanager --sdk_root=${ANDROID_SDK_ROOT} --licenses && \
    sdkmanager --sdk_root=${ANDROID_SDK_ROOT} \
      "platform-tools" \
      "platforms;android-33" \
      "build-tools;33.0.2" \
      "ndk;25.2.9519653" \
      "cmdline-tools;latest"


# Setze HOME damit Pub-Cache ins richtige Verzeichnis schreibt
ENV HOME=/home/jenkins

# Pub-Cache executables in den PATH aufnehmen
ENV PATH="/home/jenkins/.pub-cache/bin:${PATH}"

# JUnit-Report-Converter installieren (schreibt dann unter $HOME/.pub-cache/bin)
RUN flutter pub global activate junitreport

# Nach Installation aller Komponenten – nochmal explizit alle Lizenzen akzeptieren
RUN yes | sdkmanager --sdk_root=${ANDROID_SDK_ROOT} --licenses

# aapt global verlinken – falls vorhanden
RUN if [ -d "${ANDROID_SDK_ROOT}/build-tools" ]; then \
      find ${ANDROID_SDK_ROOT}/build-tools -name "aapt" -exec sudo ln -sf {} /usr/local/bin/aapt \;; \
    else \
      echo "uild-tools-Verzeichnis fehlt. aapt wird nicht verlinkt."; \
    fi

# Zurück zu root für adb-Verlinkung
USER root
RUN ln -sf ${ANDROID_SDK_ROOT}/platform-tools/adb /usr/local/bin/adb
USER jenkins

# Verfügbarkeit prüfen
RUN which adb && adb version
RUN which aapt && aapt version || echo "apt nicht gefunden!"

# Flutter vorbereiten
RUN flutter precache && flutter doctor -v