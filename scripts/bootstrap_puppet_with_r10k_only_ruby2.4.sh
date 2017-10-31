#!/bin/bash
if [ `whoami` == "root" ]; then 
    echo "i am root...";
    sudo="";
else 
    echo "i am non-root.."; 
    sudo="sudo";
fi;

# install deps pkgs
$sudo yum install which -y

# Update our packages...
if which yum &>/dev/null; then
  $sudo yum update -y -q
elif which apt-get &>/dev/null; then
  $sudo apt-get update && apt-get upgrade -y
else
  echo "update packages failed";
fi

# Install dependencies for RVM and Ruby...
if which yum &>/dev/null; then
  $sudo yum -q -y install gcc-c++ patch readline readline-devel zlib zlib-devel libxml2-devel libyaml-devel libxslt-devel libffi-devel openssl-devel make bzip2 autoconf automake libtool bison git augeas-devel
  # patch, libyaml-devel, glibc-headers, autoconf, gcc-c++, glibc-devel, patch, readline-devel, zlib-devel, libffi-devel, openssl-devel, automake, libtool, bison, sqlite-devel
elif which apt-get &>/dev/null; then
  $sudo apt-get install libaugeas-dev curl -y
else
  echo "devel packages instalation failed";
fi

# import signing key
if which gpg2 &>/dev/null; then
  $sudo gpg2 --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
elif which gpg &>/dev/null; then
  $sudo gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
else
  "add gpg failed";
fi

# Get and install RVM
$sudo curl -L https://get.rvm.io | bash -s stable

# Source rvm.sh so we have access to RVM in this shell
$sudo source /etc/profile.d/rvm.sh

# update rvm 
$sudo rvm get stable && $sudo rvm cleanup all

$sudo source /etc/profile.d/rvm.sh

# Install Ruby
$sudo rvm install ruby-2.4.2
$sudo rvm alias create default ruby-2.4.2

$sudo source /etc/profile.d/rvm.sh

if [[ `$sudo rpm -qa \*-release | grep -Ei "oracle|redhat|centos|openvz" | cut -d"-" -f3`  =~ ^7 ]]; then
  echo "CentOS/openvz 7.x detected..."; 

  # Update rubygems, and pull down facter and then puppet...
  $sudo rvm 2.4.2 do gem update --system
  $sudo rvm 2.4.2 do gem install json_pure --no-ri --no-rdoc
  $sudo rvm 2.4.2 do gem install facter --no-ri --no-rdoc
  $sudo rvm 2.4.2 do gem install puppet --no-ri --no-rdoc -v4.10.8
  $sudo rvm 2.4.2 do gem install libshadow --no-ri --no-rdoc
  $sudo rvm 2.4.2 do gem install puppet-module --no-ri --no-rdoc
  $sudo rvm 2.4.2 do gem install ruby-augeas --no-ri --no-rdoc
  $sudo rvm 2.4.2 do gem install syck --no-ri --no-rdoc

  # install r10k
  $sudo rvm 2.4.2 do gem install --no-rdoc --no-ri r10k

  if [ ! -L /etc/puppetlabs/code/modules ]; then
    rm -rf /etc/puppetlabs/code/modules;
    mkdir -p /etc/puppetlabs/code;
    ln -s /etc/puppet/modules/ /etc/puppetlabs/code/modules
  fi;

  #fix hiera
  #mkdir /etc/puppetlabs/puppet && cd /etc/puppetlabs/puppet && ln -s /etc/puppet/hiera.yaml ./

else
  echo "CentOS/openvz 6.x detected..."; 

  # Update rubygems, and pull down facter and then puppet...
  $sudo rvm 2.4.2 do gem update --system
  $sudo rvm 2.4.2 do gem install json_pure -v1.8.3 --no-ri --no-rdoc
  $sudo rvm 2.4.2 do gem install facter --no-ri --no-rdoc
  $sudo rvm 2.4.2 do gem install puppet --no-ri --no-rdoc -v3.8.7
  $sudo rvm 2.4.2 do gem install libshadow --no-ri --no-rdoc
  $sudo rvm 2.4.2 do gem install puppet-module --no-ri --no-rdoc
  $sudo rvm 2.4.2 do gem install ruby-augeas --no-ri --no-rdoc
  $sudo rvm 2.4.2 do gem install syck --no-ri --no-rdoc

  # install r10k
  $sudo rvm 2.4.2 do gem install --no-rdoc --no-ri r10k

  #fix puppet
  $sudo sed -e 's/  Syck.module_eval monkeypatch/  #Syck.module_eval monkeypatch/' -i /usr/local/rvm/gems/ruby-2.4.2/gems/puppet-3.8.7/lib/puppet/vendor/safe_yaml/lib/safe_yaml/syck_node_monkeypatch.rb

fi;

#remove old versions
$sudo rvm uninstall 2.4.1
$sudo rvm uninstall 2.4.0

# Create necessary Puppet directories...
$sudo mkdir -p /etc/puppet /var/lib /var/log /var/run /etc/puppet/manifests /etc/puppet/modules /etc/puppet/hieradata

# create hiera config
cat <<EOF > /etc/puppet/hiera.yaml
---
:backends:
  - yaml
:yaml:
  :datadir: /etc/puppet/hieradata
:hierarchy:
  - "node--%{::fqdn}"

EOF

# path puppet src files
# T.B.D.

# create custom facts for facter
$sudo mkdir -p /etc/facter/facts.d

cat <<EOF2 > /etc/facter/facts.d/puppet_module_elasticsearch_version.rb
#!/bin/env ruby

version = \`puppet module list |grep elasticsearch-elasticsearch |awk '{print \$(NF)}'\`

if version.empty? || version.nil?
    result = 'unknown' + "\n"
else
    result = version
end

print "puppet_module_elasticsearch_version=" + result
EOF2

$sudo chmod 755 /etc/facter/facts.d/puppet_module_elasticsearch_version.rb

#$sudo yum -y erase gcc-c++ readline-devel zlib-devel libxml2-devel libyaml-devel libxslt-devel libffi-devel openssl-devel augeas-devel

