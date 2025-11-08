ARG BUILD_FROM
FROM $BUILD_FROM

# Install dependencies (Alpine-native noVNC, VNC server, desktop, Wine)
RUN apk add --no-cache novnc tigervnc fluxbox wine cabextract wget ca-certificates

# Download Winbox executable
RUN mkdir -p /opt && \
    curl -fL --retry 3 --retry-delay 5 --connect-timeout 30 -o /opt/winbox64.exe https://download.mikrotik.com/routeros/winbox64.exe && \
    ls -la /opt/winbox64.exe  # Debug: Confirm ~3MB file exists

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
#!/usr/bin/with-contenv bashio

# Set log level from config
bashio::log.level "$(bashio::config 'log_level')"

bashio::log.info "Setting up VNC"

# Handle VNC password from add-on options
PASSWORD=$(bashio::config 'vnc_password')
if bashio::config.has_value 'vnc_password'; then
    echo "$PASSWORD" | vncpasswd -f > /root/.vnc/passwd
    chmod 600 /root/.vnc/passwd
    SECURITY="-rfbauth /root/.vnc/passwd"
else
    SECURITY="-SecurityTypes None"
fi

bashio::log.info "Starting VNC server"
vncserver :0 -geometry 1280x800 -depth 24 $SECURITY

bashio::log.info "Starting noVNC proxy"
novnc_proxy --listen 80 --vnc 127.0.0.1:5900
EOF

# Make service script executable
RUN chmod +x /etc/services.d/winbox/run
