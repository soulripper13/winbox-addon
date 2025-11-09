ARG BUILD_FROM
FROM $BUILD_FROM

# Install dependencies (Alpine-native noVNC, VNC server, desktop, Wine)
RUN apk add --no-cache novnc x11vnc fluxbox wine cabextract wget ca-certificates supervisor Xvfb

# --- TEMPORARY: Find paths of executables ---
RUN find / -name novnc_proxy 2>/dev/null
# --- END TEMPORARY ---

# Download Winbox executable (direct stable v3.43 URL)
RUN mkdir -p /opt && \
    curl -fL --retry 3 --retry-delay 5 --connect-timeout 30 -o /opt/winbox64.exe https://download.mikrotik.com/routeros/winbox/3.43/winbox64.exe && \
    [ -f /opt/winbox64.exe ] && [ $(stat -c%s /opt/winbox64.exe) -gt 2000000 ] && echo "Winbox v3.43 downloaded successfully (~3MB)" || (echo "Download failed" && false)

# Create Winbox startup script
RUN echo '#!/bin/bash' > /opt/start-winbox.sh && \
    echo 'DISPLAY=:0 wine /opt/winbox64.exe' >> /opt/start-winbox.sh && \
    chmod +x /opt/start-winbox.sh

# Download Winbox icon
RUN curl -fL --retry 3 --retry-delay 5 --connect-timeout 30 -o /opt/winbox.png https://wiki.mikrotik.com/images/thumb/0/0d/Winbox_icon.png/180px-Winbox_icon.png

# Create .desktop entry (for potential XDG use)
RUN mkdir -p /root/.local/share/applications && \
    cat > /root/.local/share/applications/winbox.desktop << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Winbox
Comment=MikroTik Router Management
Exec=/opt/start-winbox.sh
Icon=/opt/winbox.png
Terminal=false
Categories=Network;
EOF

# Set up VNC xstartup for Fluxbox
RUN mkdir -p /root/.vnc && \
    echo '#!/bin/sh' > /root/.vnc/xstartup && \
    echo 'fluxbox &' >> /root/.vnc/xstartup && \
    chmod +x /root/.vnc/xstartup

# Add Winbox to Fluxbox menu (for easy launch via right-click)
RUN mkdir -p /root/.fluxbox && \
    cat > /root/.fluxbox/menu << 'EOF'
[begin] (Fluxbox Menu)
[exec] (Winbox) {/opt/start-winbox.sh} </opt/winbox.png>
[exec] (Terminal) {xterm}
[end]
EOF

# Create s6 service script to start VNC and noVNC (reads HA options.json)
RUN mkdir -p /etc/services.d/winbox && \
    cat > /etc/services.d/winbox/run << 'EOF'
#!/usr/bin/env bash

exec novnc_proxy --listen 80 --vnc 127.0.0.1:5900
EOF

# Make service script executable
COPY rootfs /

EXPOSE 8099

RUN chmod +x /etc/services.d/winbox/run

# Use s6-overlay entrypoint to manage services (fixes PID 1 error)
CMD ["/init"]
