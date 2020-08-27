# Spin up a kubernetes cluster with 1 master and 2 nodes.
# Can be controled from the repo folder:
# kubectl --kubeconfig=.kube/config get nodes

N = 2
NETWORK = '192.168.50' 

PROVIDER = 'virtualbox'
#PROVIDER = 'libvirt'
#PROVIDER = 'docker'

if PROVIDER == 'virtualbox'
  VMACHINE_IMAGE = 'geerlingguy/ubuntu2004'
elsif PROVIDER == 'libvirt'
  VMACHINE_IMAGE = 'abi/ubuntu2004'
elsif PROVIDER == 'docker'
  DOCKER_IMAGE = 'ubuntu:20.04'  
end

Vagrant.configure("2") do |config|
  config.ssh.insert_key = false
  config.vm.synced_folder './', '/vagrant', type: 'rsync' if PROVIDER == 'libvirt'

  config.vm.provider PROVIDER do |v|
    if PROVIDER == 'docker'
      v.image = DOCKER_IMAGE
    else
      v.memory = 1024
      v.cpus = 2
    end
  end
  
  config.vm.define "k8s-master" do |master|
    master.vm.box = VMACHINE_IMAGE if PROVIDER != "docker"
    master.vm.network "private_network", ip: "#{NETWORK}.10"
    master.vm.hostname = "k8s-master"
    master.vm.provision "ansible" do |ansible|
      ansible.playbook = "kubernetes-setup/master-playbook.yml"
      ansible.extra_vars = {
        node_ip: "#{NETWORK}.10"
      }
      ansible.raw_arguments = [
        '--forks=10'
      ]
    end
  end

  (1..N).each do |i|
    config.vm.define "node-#{i}" do |node|
      node.vm.box = VMACHINE_IMAGE if PROVIDER != "docker"
      node.vm.network "private_network", ip: "#{NETWORK}.#{i + 10}"
      node.vm.hostname = "node-#{i}"
      node.vm.provision "ansible" do |ansible|
        ansible.playbook = "kubernetes-setup/node-playbook.yml"
        ansible.extra_vars = {
          node_ip: "#{NETWORK}.#{i + 10}",
          master_ip: "#{NETWORK}.10",
        }
        ansible.raw_arguments = [
          '--forks=10'
        ]
      end
    end
  end
  
  config.trigger.after :up do |trigger|
    trigger.name = "Check kubernetes cluster"
    # trigger.info = "kubectl --kubeconfig=.kube/config get nodes"
    trigger.run = {inline: "kubectl --kubeconfig=.kube/config get nodes"}
  end
end


