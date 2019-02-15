# AET standalone installation guide

## Prerequisites

* Centos 7.6 minimal dist

## Installation steps

### Update
```
yum -y update && yum -y upgrade
yum install net-tools -y
```

### Add SSH keys
```
cd ~
mkdir .ssh
chmod 700 .ssh
cd .ssh
touch authorized_keys
chmod 600 authorized_keys

put id_rsa.pub into authorized_keys
```

### Disable SELINUX
AET recipe uses symbolic links which is forbidden by SELINUX.
```
vi /etc/selinux/config
SELINUX=disabled
```

### Chef Solo
as Root
```
curl -L https://www.opscode.com/chef/install.sh | bash
chef-solo -v
```

### Ruby
```
sudo yum install git-core zlib zlib-devel gcc-c++ patch readline readline-devel libyaml-devel libffi-devel openssl-devel make bzip2 autoconf automake libtool bison curl sqlite-devel
curl -sL https://github.com/rbenv/rbenv-installer/raw/master/bin/rbenv-installer | bash
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
source ~/.bashrc
rbenv install 2.5.1
rbenv global 2.5.1
gem install berkshelf
```

### Provision
1. `git clone https://github.com/zietas/aet-solo`
2. run `./download-cookbooks.sh` from aet-solo
3. check if cookbooks are present under ./cookbooks
4. run `./provision.sh`

### Post-provision
Check services
```
systemctl status mongod.service
systemctl status xvfb.service
systemctl status activemq.service
systemctl status karaf.service
systemctl status hub.service
systemctl status node-chrome.service
```

In case of issues with Mongo DB, run below script - for some reason recipe does not want to create `/var/run/mongodb` folder.

```
mkdir /var/run/mongodb
chown mongod:mongod /var/run/mongodb
systemctl restart mongod.service
systemctl status mongod.service
```

### Firewall setup
```
firewall-cmd --zone=public --add-port=4444/tcp --permanent
firewall-cmd --zone=public --add-port=8181/tcp --permanent
firewall-cmd --zone=public --add-port=8161/tcp --permanent
firewall-cmd --zone=public --add-port=80/tcp --permanent
firewall-cmd --reload
```

Verify that you can access services on all the listed ports.

### Karaf
1. Access to Karaf Web Console under `<IP>:8181/system/console/configMgr`
2. Add new parameter `--no-sandbox` to `com.cognifide.aet.worker.drivers.chrome.ChromeWebDriverFactory`
3. Reconfigure IP address for `com.cognifide.aet.proxy.RestProxyManager`
4. Change IP address for reports `com.cognifide.aet.rest.helpers.ReportConfigurationManager`
5. unbind and bind again all AET modules - yeah... I know... we should not have to do it, but it ensures that everything will work (i.e. mongo connection)

### AET Test Run

#### Prerequisites

XML Lint
```
yum install install libxml2 -y
xmllint --version
```

JQ
```
yum install epel-release -y
yum install jq -y
jq --version
```

In order to check if everything is working fine just:

1. go to `./test` directory in aet-solo project
2. run `./aet.sh http://localhost:8181 example-suite.xml`

In case of issues just look into the logs:

`tail -f /var/log/karaf/*`
