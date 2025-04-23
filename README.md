# 3. 编译与安装Zabbix
echo "⚙ 编译与安装Zabbix..."
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
echo "🗄 导入Zabbix初始化库..."
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
echo "⚙ 添加systemd服务管理..."
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
