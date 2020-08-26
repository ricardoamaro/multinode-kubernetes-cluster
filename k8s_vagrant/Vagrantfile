# Spin up a kubernetes cluster with 1 master and 2 nodes.
# Can be controled from the repo folder:
# kubectl --kubeconfig=.kube/config get nodes

IMAGE_NAME = "bento/ubuntu-20.04"
N = 2

provider = "virtualbox"
#provider = "libvirtd"

Vagrant.configure("2") do |config|
  config.ssh.insert_key = false

  config.vm.provider "#{provider}" do |v|
    v.memory = 1024
    v.cpus = 2
  end
  
  config.vm.define "k8s-master" do |master|
    master.vm.box = IMAGE_NAME
    master.vm.network "private_network", ip: "192.168.50.10"
    master.vm.hostname = "k8s-master"
    master.vm.provision "ansible" do |ansible|
      ansible.playbook = "kubernetes-setup/master-playbook.yml"
      ansible.extra_vars = {
        node_ip: "192.168.50.10",
      }
      ansible.raw_arguments = [
        "--forks=10"
      ]
    end
  end

  (1..N).each do |i|
    config.vm.define "node-#{i}" do |node|
      node.vm.box = IMAGE_NAME
      node.vm.network "private_network", ip: "192.168.50.#{i + 10}"
      node.vm.hostname = "node-#{i}"
      node.vm.provision "ansible" do |ansible|
        ansible.playbook = "kubernetes-setup/node-playbook.yml"
        ansible.extra_vars = {
          node_ip: "192.168.50.#{i + 10}",
        }
      end
    end
  end
  
  config.trigger.after :up do |trigger|
    trigger.name = "Check kubernetes cluster"
    # trigger.info = "kubectl --kubeconfig=.kube/config get nodes"
    trigger.run = {inline: "kubectl --kubeconfig=.kube/config get nodes"}
  end
end


