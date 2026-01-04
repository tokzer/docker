# Use an appropriate base image with a recent open JDK (JDK 27 is the latest)
FROM amazoncorretto:25-jdk

# Define environment variables for Android SDK
ENV ANDROID_HOME="/opt/android"
ENV ANDROID_SDK_ROOT="${ANDROID_HOME}"
ENV PATH="${PATH}:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools"

# Set non-interactive mode for sdkmanager to accept licenses automatically
ENV DEBIAN_FRONTEND=noninteractive

RUN uname -a

# Install necessary system dependencies
RUN dnf update && dnf install -y \
    wget \
    unzip \
    # curl \
    gcc \
    gcc-c++ \
    make \
    openssl \
    openssl-devel

SHELL ["/bin/bash", "-c"]

# Download and install Android SDK command-line tools
RUN mkdir -p ${ANDROID_HOME}/cmdline-tools && \
    cd ${ANDROID_HOME} && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-13114758_latest.zip -O cmdline-tools.zip && \
    unzip -q cmdline-tools.zip -d ${ANDROID_HOME}/cmdline-tools && \
    mv ${ANDROID_HOME}/cmdline-tools/cmdline-tools ${ANDROID_HOME}/cmdline-tools/latest && \
    rm cmdline-tools.zip

# Accept Android SDK licenses and install the latest platform, build tools, platform-tools, and NDK
# The 'yes |' command automatically accepts all licenses
RUN yes | sdkmanager --licenses

RUN sdkmanager --update && \
    sdkmanager \
    "platforms;android-35" \
    "build-tools;35.0.0" \
    "platform-tools" \
    "ndk;27.2.12479018" # Specify a recent NDK version (check for the very latest on the NDK downloads page)

RUN curl https://sh.rustup.rs -sSf | bash -s -- -y

ENV PATH="/root/.cargo/bin:${PATH}"

RUN rustup target add armv7-linux-androideabi
RUN rustup target add aarch64-linux-android
# RUN rustup target add i868-linux-android
RUN rustup target add x86_64-linux-android

RUN cargo install cargo-quad-apk

# Optional: Set the working directory
WORKDIR /app