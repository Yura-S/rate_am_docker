#!/bin/bash

################################################building image with packer
cd ./packer/

#packer init .
#if [[ $? != 0 ]]
#  then
#    echo "Something wrong while packer init"
#    exit 1
#fi

#packer build aws-ubuntu.pkr.hcl
#if [[ $? != 0 ]]
#  then
#    echo "Something wrong while executing packer build"
#    exit 1
#fi

################################################creating infrastructure with terraform
cd ../terraform/

terraform init

if [[ $? != 0 ]]; then
        echo "Something wrong while executing terraform init"
        exit 1
fi

terraform plan

if [[ $? != 0 ]]; then
        echo "Something wrong while executing terraform plan"
        exit 1
fi

terraform apply -auto-approve

if [[ $? != 0 ]]; then
        echo "Something wrong while executing terraform apply"
        exit 1
fi

################################################getting url and instance id of created instance

URL=$(aws ec2 describe-instances --filters Name=tag:Name,Values=Website --region us-east-1 --query 'Reservations[].Instances[].PublicIpAddress' --output text)

INSTANCE_ID=$(aws ec2 describe-instances --filters Name=tag:Name,Values=Website --region us-east-1 --query 'Reservations[].Instances[?!contains(State.Name, `terminated`)].InstanceId' --output text)

if [[ $? != 0 ]]
  then
    echo "Something wrong while getting website IP"
    exit 1
fi

################################################waiting for all instance checks to start ansible
echo CHECKING INSTANCE STATES BEFORE CONTINUE

CHECK=`aws ec2 describe-instance-status --instance-id $INSTANCE_ID --query InstanceStatuses[].SystemStatus[].Details[].Status --output text`
while [ ! "$CHECK" = "passed" ]
do
  echo $CHECK `date`
  CHECK=`aws ec2 describe-instance-status --instance-id $INSTANCE_ID --query InstanceStatuses[].SystemStatus[].Details[].Status --output text`
  sleep 5
done

echo CREATED INSTANCE - $INSTANCE_ID

################################################generating ssh key and sending to created instance

cd ../ansible/

yes | sudo ssh-keygen -t rsa -b 4096 -f ./id_rsa -N "" -q

chmod 600 ./id_rsa

aws ec2-instance-connect send-ssh-public-key --instance-id $INSTANCE_ID  --instance-os-user ubuntu --ssh-public-key file://./id_rsa.pub

################################################creating containers using ansible

echo "server1 ansible_host=${URL} ansible_user=ubuntu ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'" > inventory.ini

ansible-playbook -i inventory.ini --private-key=./id_rsa create-container.yml

rm inventory.ini id_rsa id_rsa.pub

################################################showing instance public ip

echo "instance public ip is ${URL}"
