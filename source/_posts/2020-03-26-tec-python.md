---
title: CentOS6.5配置python3.7安装后ssl问题
date: 2020-03-26 19:58:02
categories:
- [技术广角, Python]
tags: python
---

摘要：解决Python3安装中的SSL问题

<!--more-->

## 报错明细

```bash
pip is configured with locations that require TLS/SSL, however the ssl module in Python is not available.
```

## 解决办法

由于系统是CentOS release 6.7，所有openssl的版本为 OpenSSL 1.0.1e ,而python3.7需要的openssl的版本为 1.0.2 或者 1.1.x,

* 需要对openssl进行升级
* 并重新编译python3.7.0 `export LDFLAGS="-L/usr/local/openssl/lib/"`

## 详细记录

```bash
[root@CNACLQLJMP010 install]# rpm -qa|grep openssl
openssl-devel-1.0.1e-58.el6_10.x86_64
openssl-1.0.1e-58.el6_10.x86_64
openssl-static-1.0.1e-58.el6_10.x86_64
[root@CNACLQLJMP010 install]# openssl version
OpenSSL 1.0.1e-fips 11 Feb 2013



wget https://www.openssl.org/source/openssl-1.1.1-pre8.tar.gz
tar -xf openssl-1.1.1-pre8.tar.gz
cd openssl-1.1.1-pre8
./config --prefix=/usr/local/openssl no-zlib
make
make install
mv /usr/bin/openssl /usr/bin/openssl.bak
mv /usr/include/openssl/ /usr/include/openssl.bak
ln -s /usr/local/openssl/include/openssl /usr/include/openssl
ln -s /usr/local/openssl/lib/libssl.so.1.1 /usr/local/lib64/libssl.so
ln -s /usr/local/openssl/bin/openssl /usr/bin/openssl

echo "/usr/local/openssl/lib" >> /etc/ld.so.conf
ldconfig -v

openssl version


if [[ -f "/usr/bin/python3" ]]; then
    exit
fi

# 安装系统依赖包
yum -y install zlib-devel bzip2 bzip2-devel openssl openssl-static openssl-devel \
ncurses ncurses-devel sqlite sqlite-devel readline readline-devel tk tk-devel lzma gdbm \
gdbm-devel db4-devel libpcap-devel xz xz-devel libffi-devel gcc

#检测 cloudcare 是否存在
if [[ ! -f "/alidata" ]];then
mkdir /alidata
echo "Created /alidata"
fi

# 下载安装包 python 3.7.3
if [[ ! -f "./Python-3.7.3.tgz" ]];then
curl -O https://cloud-software.oss-cn-hangzhou.aliyuncs.com/linux%20%E8%BD%AF%E4%BB%B6/Python-3.7.3.tgz
fi

# 解压文件
tar -xvf Python-3.7.3.tgz && cd Python-3.7.3/

# 编译 python 包
export LDFLAGS="-L/usr/local/openssl/lib/"

./configure --prefix=/alidata/python3 
make && make install && echo "### Python3 install success!"

# 创建软连接
ln -s /alidata/python3/bin/python3 /usr/bin/python3 && echo "### Add python3 link Done!"


ln -s /alidata/python3/bin/pip3 /usr/bin/pip3 && echo "### Add pip3 link Done!"
./configure --prefix=/alidata/python3 --with-openssl=/usr/local/openssl
make && make install && echo "### Python3 install success!"
```
