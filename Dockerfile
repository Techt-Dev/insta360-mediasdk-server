# Simplified Dockerfile for native x86 EC2 testing
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install essential tools + virtual display
RUN apt-get update && apt-get install -y \
    build-essential \
    g++ \
    cmake \
    ffmpeg \
    file \
    wget \
    xvfb \
    mesa-utils \
    libgl1-mesa-dri \
    libglx-mesa0 \
    libgl1-mesa-glx \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy MediaSDK from local mediasdk folder
COPY mediasdk/ /app/mediasdk/

# Install MediaSDK
RUN dpkg -i /app/mediasdk/*.deb || true
RUN apt-get update && apt-get install -f -y

# Build demo (should work perfectly on x86)
RUN cd /app/mediasdk/example && \
    g++ -o /app/stitcher_demo main.cc \
        -I/usr/include \
        -L/usr/lib \
        -lMediaSDK \
        -std=c++11 \
        -O2

# Create directories
RUN mkdir -p /app/insp-files /app/panoramas

# Set up virtual display environment
ENV DISPLAY=:99
ENV LIBGL_ALWAYS_SOFTWARE=1
ENV MESA_GL_VERSION_OVERRIDE=3.3

# Create startup script with virtual display
RUN echo '#!/bin/bash\n\
Xvfb :99 -screen 0 1024x768x24 -ac +extension GLX +render -noreset &\n\
export DISPLAY=:99\n\
sleep 2\n\
exec "$@"' > /app/start.sh && chmod +x /app/start.sh

ENTRYPOINT ["/app/start.sh"]
CMD ["bash"]