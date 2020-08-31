# Spin up a kubernetes cluster with 1 master and 2 nodes.
# Can be controled from the repo folder:
# kubectl --kubeconfig=.kube/config get nodes

if(File.exist?('config.yaml'))
  puts 'Reading configs from config.yaml'
  config = YAML.load_file('config.yaml')['config']
  NODES = config['nodes']
  MEMORY = config['memory']
  PROVIDER = config['provider']
else
  NODES = 2
  MEMORY = 1024
  PROVIDER = 'virtualbox'
  #PROVIDER = 'libvirt'
  #PROVIDER = 'docker' # not yet supported
end

if PROVIDER == 'virtualbox'
  VMACHINE_IMAGE = 'bento/ubuntu-20.04'
  NETWORK = '192.168.40'
elsif PROVIDER == 'libvirt'
  VMACHINE_IMAGE = 'abi/ubuntu2004'
  NETWORK = '192.168.60'
elsif PROVIDER == 'docker'
  DOCKER_IMAGE = 'ricardoamaro/vagrant-kubernetes-node'
  NETWORK = '192.168.80'
end

Vagrant.configure("2") do |config|
  config.ssh.insert_key = false
  config.vm.synced_folder './', '/vagrant', type: 'rsync' if PROVIDER == 'libvirt'

  config.vm.provider PROVIDER do |v|
    if PROVIDER == 'docker'
      v.image = DOCKER_IMAGE
      v.privileged = true # Required for "docker in docker"
      #v.cmd = [ "/usr/sbin/sshd", "-D" ]
      v.create_args = ["-ti", "--privileged",
                       "-v", "/sys/fs/cgroup:/sys/fs/cgroup:ro",
                       "-v", "/usr/src:/usr/src:ro",
                       "-v", "/var/run/docker.sock:/var/run/docker.sock:rw",
                       "-v", "/lib/modules:/lib/modules:ro"]
      v.has_ssh = true # Required for "docker in docker"
    else
      v.memory = MEMORY
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

  (1..NODES).each do |i|
    config.vm.define "node-#{i}" do |node|
      node.vm.box = VMACHINE_IMAGE if PROVIDER != "docker"
      node.vm.network "private_network", ip: "#{NETWORK}.#{i + 10}"
      node.vm.hostname = "node-#{i}"
      node.vm.provision "ansible" do |ansible|
        ansible.playbook = "kubernetes-setup/node-playbook.yml"
        ansible.extra_vars = {
          node_ip: "#{NETWORK}.#{i + 10}",
          master_ip: "#{NETWORK}.10"
        }
        ansible.raw_arguments = [
          '--forks=10'
        ]
      end
    end
  end
  
  config.trigger.after :up do |trigger|
    trigger.name = "Check kubernetes cluster"
    #trigger.run = {inline: 'kubectl --kubeconfig=.kube/config get nodes'}
    trigger.on_error = :continue
  end
end


