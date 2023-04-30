!#/bin/bash

function print_help()
{
    echo "Synopis: <master> <target_version>"
}

if [ $1 == "" ]; then
    echo "Missing argument: master node name"
    print_help
fi

if [ $2 == "" ]; then
    echo "Missing argument: target version."
    print_help
fi

_MASTER=$1
_TARGET_VERSION=$2
_FULL_VERSION="$_TARGET_VERSION-00"

# Drain master node
sudo kubectl drain "$_MASTER" --ignore-daemonsets && \
sudo apt-get update && \
# Upgrade kubeadm
sudo apt-mark unhold kubeadm && \
sudo apt-get install -y kubeadm="$_FULL_VERSION" && \
sudo apt-mark hold kubeadm && \
sudo kubeadm upgrade plan && \
# Use 'upgrade node' rather than 'upgrade apply'
# in the case of other masters
sudo kubeadm upgrade node && \
# Upgrade kubelet and kubectl
sudo apt-mark unhold kubelet kubectl && \
sudo apt-get upgrade -y kubelet="$_FULL_VERSION" kubectl="$_FULL_VERSION" && \
sudo systemctl daemon-reload && \
sudo systemctl restart kubelet && \
# Uncordon master node
sudo kubectl uncordon "$_MASTER"