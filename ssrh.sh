#!/bin/bash
#ssrpanel后端快速部署工具
rm -rf $0
#mysqla为mysql地址
#mysqlu为mysql用户名
#mysqlp为mysql密码
#mysqld为mysql数据库名
echo -e "感谢使用 “\033[35m ssrpanel后端快速部署工具 \033[0m”"
echo "----------------------------------------------------------------------------"
echo "请注意这个要求：务必安装好前端，添加好节点，记住节点id，在使用此脚本！"
echo "请再注意这个要求：脚本仅适用于Centos7！"
echo "----------------------------------------------------------------------------"
echo "请输入前端的MySQL地址(最好输入ip)："
read mysqla
echo "请输入前端的MySQL用户名："
read mysqlu
echo "请输入前端的MySQL数据库名："
read mysqld
echo "请输入前端的MySQL密码："
read mysqlp
echo "请输入前端添加的节点ID："
read node
sleep 1
	echo "请等待自动操作..."
	#判断操作系统
		if [[ -f /etc/redhat-release ]]; then
			release="centos"
		elif cat /etc/issue | grep -q -E -i "debian"; then
			release="debian"
		elif cat /etc/issue | grep -q -E -i "ubuntu"; then
			release="ubuntu"
		elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
			release="centos"
		elif cat /proc/version | grep -q -E -i "debian"; then
			release="debian"
		elif cat /proc/version | grep -q -E -i "ubuntu"; then
			release="ubuntu"
		elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
			release="centos"
	  fi
	sleep 3
	clear
		echo "正在安装libsodium..."

if [[ ${release} = "centos" ]]; then
	yum -y install epel-release
	yum update -y nss curl libcurl  net-tools 
	yum install  libsodium  -y
	echo /usr/local/lib > /etc/ld.so.conf.d/usr_local_lib.conf
	ldconfig
	if [ -s /usr/bin/python3 ]; then
		Version=`/usr/bin/python3 -c 'import platform; print(platform.linux_distribution()[1][0])'`
	elif [ -s /usr/bin/python2 ]; then
		Version=`/usr/bin/python2 -c 'import platform; print platform.linux_distribution()[1][0]'`
	fi
	rm -rf *.rpm
	yum install python-pip git -y
	yum install iptables git -y
	yum -y install git gcc python-setuptools lsof lrzsz python-devel libffi-devel openssl-devel iptables
	yum -y groupinstall "Development Tools" 
    easy_install supervisor
	pip install --upgrade pip
else
	apt-get update -y
	apt-get install libsodium-dev net-tools  -y
	apt-get install supervisor  python-pip lsof -y
	apt-get install build-essential wget -y
	apt-get install iptables git -y
	apt-get install python-pip git -y
	pip install cymysql
	fi
yum -y install libsodium  
cd /home
git clone -b manyuser https://github.com/shadowsocksrr/shadowsocksr.git
cd shadowsocksr
./setup_cymysql.sh
./initcfg.sh
sed -i 's/sspanelv2/glzjinmod/g' userapiconfig.py #更改接口
sed -i "s/127.0.0.1/$mysqla/g" usermysql.json
sed -i "s/\"user\": \"ss\"/\"user\": \"$mysqlu\"/g" usermysql.json
sed -i "s/\"password\": \"pass\"/\"password\": \"$mysqlp\"/g" usermysql.json
sed -i "s/\"node_id\": 0/\"node_id\": $node/g" usermysql.json
sed -i "s/\"db\": \"sspanel\"/\"db\": \"$mysqld\"/g" usermysql.json
# 启用supervisord
	supervisorctl shutdown
	#某些机器没有echo_supervisord_conf 
	wget -N -P  /etc/ --no-check-certificate  https://raw.githubusercontent.com/gxz2018/ss/main/supervisord.conf
	sed -i "s/\/root\/shadowsocks\/server.py/\/home\/shadowsocksr\/server.py/g" /etc/supervisord.conf
	supervisord
	#iptables
	iptables -F
	iptables -X  
iptables -I INPUT -p tcp -m tcp --dport 22:65535 -j ACCEPT
iptables -I INPUT -p udp -m udp --dport 22:65535 -j ACCEPT
iptables-save
service iptables save
service iptables restart
chmod +x /etc/rc.local
supervisord -c /etc/supervisord.conf
echo 'iptables-restore /etc/sysconfig/iptables' >> /etc/rc.local
echo "/usr/bin/supervisord -c /etc/supervisord.conf" >> /etc/rc.local
chmod +x /etc/rc.local 
#echo "nohup python /home/shadowsocksr/server.py &" >>/etc/rc.local
echo "后端部署完成，默认加密为：aes-128-ctr,协议为：auth_aes128_md5,obfs为：tls1.2_ticket_auth_compatible，请和前端一致，如果需要修改，请编辑/home/shadowsocksr/user-config.py文件。";
#nohup python /home/shadowsocksr/server.py &
