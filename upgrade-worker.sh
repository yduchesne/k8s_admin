!#/bin/bash

function print_help()
{
    echo "Synopis: <worker> <target_version>"
}

if [ $1 == "" ]; then
    echo "Missing argument: worker"
    print_help
fi

if [ $2 == "" ]; then
    echo "Missing argument: target version."
    print_help
fi

_WORKER=$1
_TARGET_VERSION=$2
_FULL_VERSION="$_TARGET_VERSION-00"

# Drain worker node
sudo kubectl drain "$_WORKER" --ignore-daemonsets --delete-emptydir-data
upgrade_cmd="sudo apt-get update &&"
# Upgrade kubeadm
upgrade_cmd="$upgrade_cmd sudo apt-mark unhold kubeadm &&"
upgrade_cmd="$upgrade_cmd sudo apt-get install -y kubeadm=$_FULL_VERSION &&"
upgrade_cmd="$upgrade_cmd sudo apt-mark unhold kubeadm &&"
upgrade_cmd="$upgrade_cmd sudo kubeadm upgrade node &&"
# Upgrade kubelet and kubectl
upgrade_cmd="$upgrade_cmd sudo apt-mark unhold kubelet kubectl &&"
upgrade_cmd="$upgrade_cmd sudo apt-get upgrade -y kubelet=$_FULL_VERSION kubectl=$_FULL_VERSION &&"
upgrade_cmd="$upgrade_cmd sudo apt-mark hold kubelet kubectl &&"
upgrade_cmd="$upgrade_cmd sudo systemctl restart kubelet &&"
upgrade_cmd="$upgrade_cmd sudo systemctl daemon-reload"

ssh -t "$_WORKER" sudo -- "sh -c '$upgrade_cmd'"

# Uncordon worker node
sudo kubectl uncordon "$_WORKER"