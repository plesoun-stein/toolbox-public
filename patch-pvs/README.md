# Change all PVs Reclaim policy from Delete to Retain

* Script  patches all PVs' RECLAIM POLICY to Retain
* !!! It's first aid kit not intended for standard usage.
* !!! By default the script runs with `--dry-run=client` param. 
* Do you want to apply? Run it with `-a` param. 

# parameters
* `-h` prints this help and exits
* `-a` apply script.
* `-c` k8 cluster config file 
  * file name in ~/.kube/ directory  
  * relative path  
  * full path 

# example
```
./patch_pvs.sh -c config-stage -a 
```
