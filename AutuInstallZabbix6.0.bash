#!/bin/bash
 
# ==============================
# 欢迎信息
# ==============================
echo "==================================================="
echo "这是centos7以上系统 安装zabbix6.0的脚本1.0,请做好系统备份"
echo "脚本作者 jj"
echo “不懂请回复我 查看更多关于技术支持”
echo "==================================================="
echo ""

# ==============================
# 倒计时 5 秒
# ==============================
echo "🕒倒计时5秒后开始执行脚本..."
for i in {5..1}
do
  echo "$i..."
  sleep 1
done
echo "✅倒计时结束，开始安装。"


# ============================== 
# 提示是否同意
# ==============================

echo "==================================================="
echo "本脚本可能存在一些无法挽回的操作"
echo "同时需要保证此系统没有部署任何环境与程序"
echo “确保系统上纯净模式开始运行此脚本 否则请终止本脚本”
echo "安装不保证百分百成功 如果不同意请立即终止本脚本"
echo "如果您同意 请输入yes开始执行"
echo "==================================================="
echo ""

read -p "📦是否开始安装？请输入 'yes' 开始安装: " start_install

if [ "$start_install" != "yes" ]; then
  echo "用户拒绝同意，安装已取消，退出脚本。"
  exit 1
fi

# ============================== 
# 输出当前系统版本
# ==============================
echo "当前系统版本："
cat /etc/os-release

# ============================== 
# 提示是否开始安装
# ==============================
read -p "✅脚本准备就绪 请确认系统版本是否是Centos7以上版本 是否开始安装？请输入 'yes' 开始安装: " start_install

if [ "$start_install" != "yes" ]; then
  echo "安装已取消，退出脚本。"
  exit 1
fi

# ==============================
# 倒计时 5 秒
# ==============================
echo "🕒正在准备初始化，请稍后。。。。。。。。"
for i in {5..1}
do
  echo "$i..."
  sleep 1
done
echo "✅初始化完成，开始安装。"

 
# ==============================
# 一、替换CentOS Yum源
# ==============================
echo "🌐 正在替换CentOS Yum源..."
# 1. 删除默认的Yum源配置
rm -f /etc/yum.repos.d/CentOS-Base.repo
 
# 2. 创建新的Yum源配置文件
cat <<EOF > /etc/yum.repos.d/CentOS-Base.repo
# CentOS-Base.repo  
# 使用多个镜像源进行配置
[base]
name=CentOS-\$releasever - Base
baseurl=http://mirrors.aliyun.com/centos/\$releasever/os/\$basearch/
        http://mirrors.tuna.tsinghua.edu.cn/centos/\$releasever/os/\$basearch/
        http://mirrors.ustc.edu.cn/centos/\$releasever/os/\$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
[updates]
name=CentOS-\$releasever - Updates
baseurl=http://mirrors.aliyun.com/centos/\$releasever/updates/\$basearch/
        http://mirrors.tuna.tsinghua.edu.cn/centos/\$releasever/updates/\$basearch/
        http://mirrors.ustc.edu.cn/centos/\$releasever/updates/\$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
[extras]
name=CentOS-\$releasever - Extras
baseurl=http://mirrors.aliyun.com/centos/\$releasever/extras/\$basearch/
        http://mirrors.tuna.tsinghua.edu.cn/centos/\$releasever/extras/\$basearch/
        http://mirrors.ustc.edu.cn/centos/\$releasever/extras/\$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
[centosplus]
name=CentOS-\$releasever - Plus
baseurl=http://mirrors.aliyun.com/centos/\$releasever/centosplus/\$basearch/
        http://mirrors.tuna.tsinghua.edu.cn/centos/\$releasever/centosplus/\$basearch/
        http://mirrors.ustc.edu.cn/centos/\$releasever/centosplus/\$basearch/
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
[contrib]
name=CentOS-\$releasever - Contrib
baseurl=http://mirrors.aliyun.com/centos/\$releasever/contrib/\$basearch/
        http://mirrors.tuna.tsinghua.edu.cn/centos/\$releasever/contrib/\$basearch/
        http://mirrors.ustc.edu.cn/centos/\$releasever/contrib/\$basearch/
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
# 使用failovermethod指定优先级，设置为随机（roundrobin）
failovermethod=roundrobin
EOF
 
# 3. 清理Yum缓存并更新
echo "🧹 清理Yum缓存并更新..."
sudo yum clean all
sudo yum makecache -y
 
 
# ==============================
# 二、系统初始化
# ==============================
echo "🔧 系统初始化..."
# 1. 关闭防火墙和SELinux
echo "🚫 关闭防火墙和SELinux..."
systemctl stop firewalld
systemctl disable firewalld
setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
 
# 2. 安装并配置定时时间同步
echo "🕒 安装并配置时间同步..."
yum -y install ntpdate
ntpdate ntp1.aliyun.com
echo "0 1 * * * ntpdate ntp1.aliyun.com" >> /var/spool/cron/root
crontab -l
 
# 3. 清理Yum缓存
yum makecache
 
# ==============================
# 三、部署并配置Nginx
# ==============================

# 安装wget工具
echo "🔧 安装wget..."
yum install -y wget

echo "🚀 部署并配置Nginx..."
# 1. 安装Nginx
wget -O /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo
wget -O /etc/yum.repos.d/epel.repo https://mirrors.aliyun.com/repo/epel-7.repo
yum clean all
yum -y install nginx
nginx -v
 
# 2. 添加Nginx虚拟主机配置
echo "📄 添加Nginx虚拟主机配置..."
cat <<EOF > /etc/nginx/conf.d/zabbix.conf
server {
  listen 9780;
  location / {
    root /usr/share/nginx/html/zabbix;
    index index.php index.html index.htm;
  }
  location ~ \.php$ {
    root /usr/share/nginx/html/zabbix;
    fastcgi_pass 127.0.0.1:9000;
    fastcgi_index index.php;
    fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    include fastcgi_params;
    access_log /var/log/nginx/zabbix_access.log;
    error_log /var/log/nginx/zabbix_error.log;
  }
}
EOF
 
# 3. 启动Nginx并设置开机自启动
echo "⚙️ 启动Nginx并设置开机自启动..."
nginx -t
systemctl start nginx
systemctl enable nginx
 
# ==============================
# 四、部署并配置PHP
# ==============================
echo "💻 部署并配置PHP..."
# 1. 安装PHP
yum install epel-release -y
rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm
yum -y install php72w php72w-cli php72w-common php72w-devel php72w-embedded php72w-gd php72w-mbstring php72w-pdo php72w-xml php72w-fpm php72w-mysqlnd php72w-opcache php72w-ldap php72w-bcmath
php -v
 
# 2. 修改PHP-FPM配置
echo "🛠️ 修改PHP-FPM配置..."
sed -i 's/user = apache/user = nginx/' /etc/php-fpm.d/www.conf
sed -i 's/group = apache/group = nginx/' /etc/php-fpm.d/www.conf
 
# 3. 优化PHP配置
echo "⚡ 优化PHP配置..."
sed -i 's/max_execution_time = 30/max_execution_time = 300/' /etc/php.ini
sed -i 's/max_input_time = 60/max_input_time = 600/' /etc/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 80M/' /etc/php.ini
sed -i 's/;date.timezone =/date.timezone = Asia\/Shanghai/' /etc/php.ini
 
# 4. 启动PHP-FPM并设置开机自启动
echo "🔄 启动PHP-FPM并设置开机自启动..."
systemctl start php-fpm
systemctl enable php-fpm
 
# 5. 测试Nginx与PHP环境
echo "✅ 测试Nginx与PHP环境..."
mkdir -p /usr/share/nginx/html/zabbix
cat <<EOF > /usr/share/nginx/html/zabbix/index.php
<?php
phpinfo();
?>
EOF
 
echo "请浏览器访问 http://<本机ip地址>:9780/index.php，检查PHP主页"
read -p "请确认是否能够访问php主页，继续请输入yes并回车，不能正常访问请按no或者ctrl+z中断: " confirm
if [ "$confirm" != "yes" ]; then
  echo "请检查配置后重试。"
  exit 1
fi
 
# ==============================
# 五、部署并配置MariaDB
# ==============================
echo "🛡️ 部署并配置MariaDB..."
# 1. 安装MariaDB
cat > /etc/yum.repos.d/mariadb.repo <<EOF
[mariadb]
name = MariaDB
baseurl = http://mirrors.aliyun.com/mariadb/yum/10.5/centos7-amd64/
gpgkey = http://mirrors.aliyun.com/mariadb/yum/RPM-GPG-KEY-MariaDB
gpgcheck = 1
enabled=1
EOF
 
yum install -y mariadb-server mariadb
 
# 2. 启动MariaDB并设置开机自启动
echo "🔑 启动MariaDB并设置开机自启动..."
systemctl start mariadb
systemctl enable mariadb
 
# 3. 查看MariaDB版本
echo "📈 查看MariaDB版本..."
mysql -e "SELECT VERSION();"
 
# 4. 初始化数据库
echo "⚙️ 初始化数据库..."
mysql <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY 'Networkyc@zabbix.';
CREATE DATABASE zabbix character set utf8 collate utf8_bin;
GRANT all ON zabbix.* TO 'zabbix'@'localhost' IDENTIFIED BY 'Networkyc@zabbix.';
GRANT all ON zabbix.* TO 'zabbix'@'%' IDENTIFIED BY 'Networkyc@zabbix.';
FLUSH PRIVILEGES;
EOF
 
# ==============================
# 六、Zabbix-Server部署步骤
# ==============================
echo "🔧 部署Zabbix-Server..."
# 1. 安装编译环境依赖
echo "📦 安装编译环境依赖..."
yum install -y mysql-devel pcre-devel openssl-devel zlib-devel libxml2-devel net-snmp-devel net-snmp libssh2-devel OpenIPMI-devel libevent-devel openldap-devel libcurl-devel fping gcc gcc-c++ make
 
# 2. 下载Zabbix源代码
echo "📥 下载Zabbix源代码..."
tar -xvf zabbix-6.0.31.tar -C /opt/
 
# 3. 编译与安装Zabbix
echo "⚙️ 编译与安装Zabbix..."
cd /opt/zabbix-6.0.31/
./configure \
--sysconfdir=/etc/zabbix/ \
--bindir=/etc/zabbix/bin/ \
--sbindir=/etc/zabbix/bin/ \
--libexecdir=/etc/zabbix/libexec \
--sharedstatedir=/etc/zabbix/sharedstatedir \
--localstatedir=/etc/zabbix/statedir \
--runstatedir=/etc/zabbix/run \
--libdir=/etc/zabbix/lib \
--includedir=/etc/zabbix/include \
--oldincludedir=/etc/zabbix/oldinclude\
--datarootdir=/etc/zabbix/share \
--datadir=/etc/zabbix/data \
--enable-server \
--with-mysql \
--with-net-snmp \
--with-libxml2 \
--with-ssh2 \
--with-openipmi \
--with-zlib \
--with-libpthread \
--with-libevent \
--with-openssl \
--with-ldap \
--with-libcurl \
--with-libpcre
 
make install
 
# 4. 导入Zabbix初始化库
echo "🗄️ 导入Zabbix初始化库..."
cd /opt/zabbix-6.0.31/database/mysql
mysql -uzabbix -pNetworkyc@zabbix. zabbix < schema.sql
mysql -uzabbix -pNetworkyc@zabbix. zabbix < images.sql
mysql -uzabbix -pNetworkyc@zabbix. zabbix < data.sql
mysql -uzabbix -pNetworkyc@zabbix. zabbix < double.sql
mysql -uzabbix -pNetworkyc@zabbix. zabbix < history_pk_prepare.sql
 
# 5. 配置Zabbix前端UI
echo "🌐 配置Zabbix前端UI..."
cp -rp /opt/zabbix-6.0.31/ui/* /usr/share/nginx/html/zabbix/
 
# 6. 启动Zabbix-Server
echo "🚀 启动Zabbix-Server..."
# 1) 修改Zabbix配置
sed -i 's/^# DBHost=localhost/DBHost=localhost/' /etc/zabbix/zabbix_server.conf
sed -i 's/^# DBName=zabbix/DBName=zabbix/' /etc/zabbix/zabbix_server.conf
sed -i 's/^# DBUser=zabbix/DBUser=zabbix/' /etc/zabbix/zabbix_server.conf
sed -i 's/^# DBPassword=/DBPassword=Networkyc@Zabbix./' /etc/zabbix/zabbix_server.conf
 
# 2) 创建用户用于启动Zabbix
echo "👤 创建用户用于启动Zabbix..."
useradd -r -s /sbin/nologin zabbix6
chown -R zabbix6:zabbix6 /etc/zabbix/
 
# 3) 添加systemd服务管理
echo "⚙️ 添加systemd服务管理..."
cat > /usr/lib/systemd/system/zabbix-server.service <<EOF
[Unit]
Description=Zabbix Server with MySQL DB
After=syslog.target network.target mysqld.service
[Service]
Type=simple
ExecStart=/etc/zabbix/bin/zabbix_server -f
User=zabbix6
Restart=on-failure
RestartSec=30s
KillMode=control-group
KillSignal=SIGTERM
TimeoutStopSec=30s
[Install]
WantedBy=multi-user.target
EOF
 
# 4) 启动Zabbix-Server
echo "🚀 启动Zabbix-Server..."
systemctl start zabbix-server
systemctl enable zabbix-server
 
echo "✅ Zabbix-Server安装完成！"
echo "请浏览器访问 http://<本机ip地址>:9780，检查能否访问zabbix安装主页."

echo "==================================================="
echo "数据库相关信息 请注意稍后配置需要用到"
echo "数据库类型：MySQl"
echo "数据库主机：localhost"
echo "数据库端口：0"
echo "数据库名：zabbix"
echo "数据库用户名：zabbix"
echo "数据库密码：Networkyc@zabbix."
echo "---------------------------------------------------"
echo "ZABBIX默认登陆信息"
echo "账号：Admin"
echo "密码：zabbix"
echo "==================================================="
