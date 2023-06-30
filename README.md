# k8s-local-installer

This project allows you to install a Kubernetes cluster on your local machine following the "Infrastructure as a Code" approach.

## Prerequisites

Before you start, make sure you have the following dependencies installed:

- qemu (qemu-kvm on Ubuntu)
- libvirt (libvirt-daemon-system on Ubuntu)
- Virsh
- virt-viewer
- terraform
- mkisofs (genisoimage on Ubuntu)
- python3, python3-pip, python3-virtualenv
- SSH key pair (id_rsa, id_rsa.pub)

## Getting Started

### Configure qemu for correct working:

Add the following lines to the file `/etc/libvirt/qemu.conf`:

```
user = root
group = root
security_driver = "none"
```

Then restart libvirtd service (on Ubuntu, use `sudo systemctl restart libvirtd`).

### Configure terraform:

1. Create a directory for the disk pool and specify the path in the `libvirt_pool` resource.
2. Add the path to your SSH public key in the `ssh_public_key_path` environment variable.

These steps complete the mandatory terraform settings. However, you can also customize the following:

- Increase the number of created instances for master and worker nodes by changing the value of the `count` variable.
- Modify the amount of RAM and the number of cores for each node using the `domain_memory` and `domain_vcpu` variables.
- Change the link to the operating system image in the `source_image` variable. Only images with "cloud-init" pre-installed can be used.
- Increase the disk space for the system image by downloading it and running the command: `qemu-img resize /qemu/images/name +8G` (replace `name` with the actual image name).

### Create virtual machines

1. Open a terminal and navigate to the `k8s-local-installer/terraform/` directory.
2. Initialize the Terraform configuration: `terraform init`
3. Apply the configuration and create the virtual machines: `terraform apply -parallelism=1`

To check if the virtual machines have been created, use the command: `virsh list --all`

### Kubespray

1. Open a terminal and navigate to the `k8s-local-installer/` directory.
2. Clone the Kubespray repository: `git clone https://github.com/kubernetes-sigs/kubespray.git`
3. Navigate to the Kubespray directory: `cd kubespray`
4. Append the contents of `../ansible/ansible.cfg` to `~/.ansible.cfg`
5. Create a virtual environment: `virtualenv ./.venv`
6. Activate the virtual environment: `source ./.venv/bin/activate`
7. Install the required dependencies: `pip install -r ./requirements.txt`

8. Check if all nodes are ready by pinging them: `ansible --private-key=~/.ssh/id_rsa -i ../terraform/inventory.ini all --user cloud --become -m ping`
9. Start the Kubernetes cluster installation using Kubespray: `ansible-playbook --user cloud --become -i ../terraform/inventory.ini ./cluster.yml -b -v --private-key=~/.ssh/id_rsa`

10. Download the `admin.conf` file from the master node: `ssh -i ~/.ssh/id_rsa cloud@10.9.8.10 sudo cat /etc/kubernetes/admin.conf > ./admin.conf`

11. Verify the cluster by checking the nodes: `KUBECONFIG=./admin.conf kubectl get nodes`

Now you have successfully installed a Kubernetes cluster on your local machine using the k8s-local-installer and Kubespray. You can proceed with managing and using the cluster for your development or testing purposes.
