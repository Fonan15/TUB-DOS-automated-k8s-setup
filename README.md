# Usage

  - Download git repository
  - install prerequisites
  - configure ansible host
  - use the wizard


## prerequisites


Get the necessary installs
```bash
sudo apt-get install python3 ssh
sudo apt install software-properties-common
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt-get update
sudo apt-get install ansible
ansible-galaxy collection install community.general
(apt-get install git)
```
Get the Git Repository either by cloning or via download

```bash
git clone git@git.tu-berlin.de:fonan15/bachelor.git
```

## configure ansible host

- Change the user in ''ansible/hosts'' to your user account.
- Make sure that you can access your own account via ssh (either via password or via ssh-key)

## wizard

Follow the questions of the wizard

```bash
/bin/bash wizard.sh
```



# Troubleshooting

If anything does not work those are some commands that might help

## pod does not start

Useful commands to find out more about the status of the pods

```bash
kubectl config set-context --current --namespace=experiment
kubectl desribe pods
kubectl logs mypod-name --all-containers
kubectl logs mypod-name -c mycontainer-name
```

## Pre-existing ressources (example prometheus)

### remote roles still existing

```bash
kubectl get clusterroles
kubectl get clusterrolebindings
kubectl delete clusterrolebinding $NAME
kubectl delete clusterrole $NAME
```

Especially when it comes to prometheus roles, a simple delete of the namespace for example does not completely delete the installation.
Afterwards the roles and rolebindings naming "prometheus-kube-prometheus*" are often existing.

### services still existing

Services can be existing as well if the problem of roles was present:

For example: "prometheus-kube-prometheus-coredns"
Again, delete everything naming "prometheus-kube-prometheus*"

```bash
kubectl get service -o wide
kubectl delete svc $NAME
```
alternatively:

```bash
kubectl get deployments
kubectl uninstall $DEPLOYMENT
```

### webhooks still existing

The previous mentioned is also applicable for the webhooks. If for example this error message pops up:
```bash
"Failure when executing Helm command. Exited 1.\nstdout: Release \"prometheus\" does not exist. Installing it now.
Error: Unable to continue with install: MutatingWebhookConfiguration \"prometheus-kube-prometheus-admission\" in namespace \"\" exists and cannot be imported into the current release: invalid ownership metadata; annotation validation error: key \"meta.helm.sh/release-namespace\" must equal \"experiment\": current value is \"prometheus\"
```
Do the following:


```bash
kubectl get mutatingwebhookconfigurations
kubectl delete mutatingwebhookconfigurations $NAME
kubectl get validatingwebhookconfigurations
kubectl delete validatingwebhookconfigurations $NAME
```
Repeatedly needed to use these because deleting the namespace didn't do the trick:
```bash
kubectl delete mutatingwebhookconfigurations prometheus-kube-prometheus-admission --kubeconfig remote-cluster-config
kubectl delete validatingwebhookconfigurations prometheus-kube-prometheus-admission --kubeconfig remote-cluster-config
```

## MinIO cannot initialize its storage

Depending on the remote installation, the storageclass name has to be changed.
Currently it is assumed, that locally the storage class ''standard'' is used and remotely the class ''local-path'' has to be used.
If your cluster works differently please change accordingly in the ''variables.yml'' file