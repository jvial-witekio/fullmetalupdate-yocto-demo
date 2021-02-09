#!/bin/sh

# This script is made to configure the build for the demo.
# In this scenario, the Cloud part (Hawkbit and Ostree server) is played
# by the fullmetalupdate-cloud-demo, have a look to:
# https://github.com/FullMetalUpdate/fullmetalupdate-cloud-demo

# Fullmetalupdate is build using a docker container. This container uses the
# fmu_network. So it can access hawkbit and ostree servers thanks to there
# hostname. It won't be the case of the target. Using the IP address of the
# computer where the target can get the information from the Cloud is the
# easiest way. So you can call this script like this:
# FMU_DEMO_IP=<your IP address> ./ConfigureBuild.sh

sed_escape() {
  sed -e 's/[]\/$*.^[]/\\&/g'
}

cfg_delete() { # path, key
  test -f "$1" && sed -i "/^$(echo $2 | sed_escape).*$/d" "$1"
}

cfg_replace() { # path, key , value
  sed -i "s|^$2.*|$2 = $3|" "$1"
}

if [ -e ./config.cfg ]; then
	echo 'config.cfg already exits. Do you really want to overwrite it? Please type yes to confirm.'
    read -n 3 -p "> " ans;

    case $ans in
        'yes')
        ;;
        *)
            exit;;
    esac
fi

cp ./config.cfg.sample ./config.cfg

if [ -n "$FMU_DEMO_IP" ]; then
    cfg_replace config.cfg hawkbit_url_host $FMU_DEMO_IP
    cfg_replace config.cfg ostree_url_host $FMU_DEMO_IP
else
    cfg_replace config.cfg hawkbit_url_host hawkbit
    cfg_replace config.cfg ostree_url_host ostree
fi

cfg_replace config.cfg ostreepush_ssh_host ostree
cfg_delete config.cfg ostree_url_path
cfg_replace config.cfg ostreepush_ssh_path "/ostree/repo"
