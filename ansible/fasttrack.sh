#! /bin/bash

rm -f entrypoints.txt

# start ansible from here
ansible-playbook experiment_setup.yml -K
cat entrypoints.txt

exit 0