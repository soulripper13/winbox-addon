#!/bin/bash

CONFIG_PATH=/data/options.json

USER=$(jq --raw-output ".user" $CONFIG_PATH)
ADDRESS=$(jq --raw-output ".address" $CONFIG_PATH)
PASSWORD=$(jq --raw-output ".password" $CONFIG_PATH)

export DISPLAY=:0
export WINBOX_USER=$USER
export WINBOX_ADDRESS=$ADDRESS
export WINBOX_PASSWORD=$PASSWORD

supervisord -c /etc/supervisor/conf.d/supervisord.conf