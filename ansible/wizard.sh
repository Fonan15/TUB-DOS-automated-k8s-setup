#! /bin/bash
rm -f entrypoints.txt
echo "Welcome to the Experiment Setup Wizard"
echo "Please answer the next questions to prepare the ansible playbook"
read -p "Please choose whether you want to install a local or remote cluster [local]: " Remote_Local
Remote_Local=${Remote_Local:-local}
Remote_Local=$(echo $Remote_Local | tr '[:upper:]' '[:lower:]')
while [[ "$Remote_Local" != "remote" && "$Remote_Local" != "local" ]]; do
    echo "Value should be either 'remote' or 'local'. Please try again:"
    read Remote_Local
    Remote_Local=$(echo $Remote_Local | tr '[:upper:]' '[:lower:]')
done
sed -i "s/^Remote_Local: .*/Remote_Local: $Remote_Local/" variables.yml

if [ $Remote_Local == "remote" ]; then
    read -p "Please choose a path to your kubeconfig (ideally from the root-path): " Custom_Kubeconfig
    sed -i "s/^custom_kubeconfig: .*/custom_kubeconfig: $Custom_Kubeconfig/" variables.yml
else
    read -p "Please choose whether you want to create a new Cluster in your setup [no]: " Create_Cluster
    Create_Cluster=${Create_Cluster:-no}
    Create_Cluster=$(echo $Create_Cluster | tr '[:upper:]' '[:lower:]')
    while [[ "$Create_Cluster" != "yes" && "$Create_Cluster" != "no" ]]; do
        echo "Value should be either 'yes' or 'no'. Please try again:"
        read Create_Cluster
        Create_Cluster=$(echo $Create_Cluster | tr '[:upper:]' '[:lower:]')
    done
    sed -i "s/^Create_Cluster: .*/Create_Cluster: $Create_Cluster/" variables.yml
fi

read -p "Please choose whether you want to use Flink or Spark in your setup [flink]: " Flink_Spark
Flink_Spark=${Flink_Spark:-flink}
Flink_Spark=$(echo $Flink_Spark | tr '[:upper:]' '[:lower:]')
while [[ "$Flink_Spark" != "spark" && "$Flink_Spark" != "flink" ]]; do
    echo "Value should be either 'spark' or 'flink'. Please try again:"
    read Flink_Spark
    Flink_Spark=$(echo $Flink_Spark | tr '[:upper:]' '[:lower:]')
done
if [ $Flink_Spark == "flink" ]; then
    echo "Currently only the automatic spark setup is supported"
    read -p "Do you want to switch? Otherwise the setup will exit. [Y/n] " Break
    Break=${Break:-y}
    Break=$(echo $Break | tr '[:upper:]' '[:lower:]')
    if [ $Break == "y" ]; then
        sed -i "s/^Flink_Spark: .*/Flink_Spark: spark/" variables.yml
        Flink_Spark="spark"
    else
        exit 1
    fi
fi
sed -i "s/^Flink_Spark: .*/Flink_Spark: $Flink_Spark/" variables.yml

if [ $Flink_Spark == "spark" ]; then
    if [ $Remote_Local == "remote" ]; then
        sed -i "s%^tenant_storageClassName: .*%tenant_storageClassName: local-path # standard / local-path%" variables.yml
    else
        sed -i "s%^tenant_storageClassName: .*%tenant_storageClassName: standard # standard / local-path%" variables.yml
    fi
fi

if [ $Flink_Spark == "spark" ]; then
    read -p "Please choose whether you want to have MinIO in your setup [no]: " Minio
    Minio=${Minio:-no}
    Minio=$(echo $Minio | tr '[:upper:]' '[:lower:]')
    while [[ "$Minio" != "yes" && "$Minio" != "no" ]]; do
        echo "Value should be either 'yes' or 'no'. Please try again:"
        read Minio
        Minio=$(echo $Minio | tr '[:upper:]' '[:lower:]')
    done
    sed -i "s/^MinIO: .*/MinIO: $Minio/" variables.yml
fi

read -p "Please choose whether you want to have Prometheus with Grafana interface in your setup [no]: " Prometheus
Prometheus=${Prometheus:-no}
Prometheus=$(echo $Prometheus | tr '[:upper:]' '[:lower:]')
while [[ "$Prometheus" != "yes" && "$Prometheus" != "no" ]]; do
    echo "Value should be either 'yes' or 'no'. Please try again:"
    read Prometheus
    Prometheus=$(echo $Prometheus | tr '[:upper:]' '[:lower:]')
done
sed -i "s/^Prometheus: .*/Prometheus: $Prometheus/" variables.yml
if [ $Prometheus == "yes" ]; then
    read -p "Do you want to change the prometheus access port? [30090]: " prometheus_nodePort
    prometheus_nodePort=${prometheus_nodePort:-30090}
    sed -i "s/^prometheus_nodePort: .*/prometheus_nodePort: $prometheus_nodePort/" variables.yml
    read -p "Do you want to change the grafana access port? [31313]: " grafana_nodePort
    grafana_nodePort=${grafana_nodePort:-31313}
    sed -i "s/^grafana_nodePort: .*/grafana_nodePort: $grafana_nodePort/" variables.yml
fi

# start ansible from here
ansible-playbook experiment_setup.yml -K
cat entrypoints.txt

exit 0