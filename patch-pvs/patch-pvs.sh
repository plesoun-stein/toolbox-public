#!/bin/bash

### some defaults
dryrun="--dry-run=client"

usage () { 
  cat <<- MYHELP
### Script  patches all PVs' RECLAIM POLICY to Retain
!!! It's first aid kit not intended for standard usage.
parameters:
    -h prints this help and exits
    -a apply script.  
    -c k8 cluster configfile name, in ~/.kube/ directory
example
    ./patch_pvs.sh -c config-stage -a 
!!!
!!! By default the script runs with --dry-run=client param. 
!!!
!!! Do you want to apply? Run it with -a param. 
!!!
MYHELP
}

k8_set_config(){
  if [ $# -eq 0 ]; then
    echo "missing parameter"
    return 1
  fi
  local myconfig=$1
  if [ -f ${myconfig} ] ; then 
    export KUBECONFIG=${myconfig}
  elif [ -f ~/.kube/${myconfig} ] ; then 
    export KUBECONFIG=~/.kube/${myconfig}
  else
    echo -e "\n###\n# Configfile: \`${myconfig}\` doesn't exist.\n"
    usage
    exit 1
  fi
  echo -e "\nconfig file: ${KUBECONFIG}\n"
}

if [ $# -eq 0 ] ; then 
  echo "missing params"
  usage
  exit 1
fi

while getopts "c:ah" OPTION; do
  case $OPTION in
    h)
      usage
      exit 0
      ;;
    a) 
      dryrun=''
      ;;
    c) 
      myconfig=${OPTARG}
      ;;
    *)
      echo "unknown option: ${OPTION}"
      usage
      exit 1
  esac
done

# setup config for cluster
k8_set_config ${myconfig}
mycluster=$(kubectl config current-context)
mycluster=${mycluster##*\/}
echo -e "###############################\nI'm working on cluster: $mycluster\n#\n"
if [ "${dryrun}" = '--dry-run=client' ]; then 
  echo -e "This si dry run, if you want to apply,\nset -a\n\n"
else
  echo -e "I'm going to patch some PVs with Retain policy\n"
fi

echo -e "Kubectl patch pv command output\n"
mypvs=$(kubectl get pv --all-namespaces --no-headers -o custom-columns=":metadata.name,:spec.persistentVolumeReclaimPolicy"| sed 's/\s\{1,\}/ /'|grep -i "delete" |cut -d' ' -f 1)

for item in ${mypvs[@]}; do
  kubectl patch pv ${dryrun} ${item} -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}'
done

