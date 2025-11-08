ARG BUILD_FROM
FROM $BUILD_FROM

# Base noVNC image for GUI (Debian variant)
USER root
RUN apk add --no-cache wget ca-certificates && \
    wget -q -O /tmp/docker-novnc.tar.gz https://github.com/tiredofit/docker-novnc/releases/download/v0.3.0/docker-novnc_0.3.0_debian.tar.gz && \
    tar xzf /tmp/docker-novnc.tar.gz -C / && \
    rm /tmp/docker-novnc.tar.gz

# Install Wine and dependencies for Winbox
RUN apk add --no-cache wine cabextract && \
    # Download and extract Winbox (latest stable 64-bit)
    wget -q https://download.mikrotik.com/routeros/winbox64.exe -O /opt/winbox64.exe && \
    # Create startup script for Winbox
    echo '#!/bin/bash\nDISPLAY=:1 wine /opt/winbox64.exe' > /opt/start-winbox.sh && \
    chmod +x /opt/start-winbox.sh && \
    # Create .desktop file for easy launch in Fluxbox menu
    mkdir -p /home/abc/.local/share/applications && \
    cat > /home/abc/.local/share/applications/winbox.desktop << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Winbox
Comment=MikroTik Router Management
Exec=/opt/start-winbox.sh
Icon=/opt/winbox.png
Terminal=false
Categories=Network;
EOF && \
    # Extract icon (simple fallback)
    wget -q https://wiki.mikrotik.com/images/thumb/0/0d/Winbox_icon.png/180px-Winbox_icon.png -O /opt/winbox.png && \
    chown -R abc:abc /home/abc

# Set environment for noVNC (listen on port 80 for HA ingress, start Fluxbox desktop)
ENV NOVNC_LISTEN_PORT=80 \
    VNC_LISTEN_PORT=5900 \
    DISPLAY_MODE=scale \
    RESOLUTION=1280x800 \
    STARTUP_APP="/usr/bin/fluxbox" \
    USER=abc

# Expose ports
EXPOSE 80 5900

# Use base image's entrypoint (starts VNC, noVNC, and desktop)
CMD ["/init"]
