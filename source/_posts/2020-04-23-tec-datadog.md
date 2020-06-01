---
title: DataDog监控数据库（一）
categories:
    - [技术广角, datadog]
tags:
    - 监控
    - datadog
date: 2020-04-22 18:47:59
---

## 官网

现代监测与分析

在任何堆栈，任何应用程序，任何规模，任何地方都可以查看。

[datadog官网](https://www.datadoghq.com/)

## 安装centos插件

```shell script
[root@NB-flexgw1:/root]# DD_AGENT_MAJOR_VERSION=7 DD_API_KEY=7911dc3b1d3c1034ba563eb2d61767f5 bash install_script.sh

* Installing YUM sources for Datadog

* Installing the Datadog Agent package

已加载插件：fastestmirror
Cleaning repos: base datadog docker-ce-stable epel extras influxdb
              : percona-release-noarch percona-release-x86_64 updates
24 metadata 文件已删除
16 sqlite 文件已删除
0 metadata 文件已删除
已加载插件：fastestmirror
设置安装进程
Determining fastest mirrors
解决依赖关系
--> 执行事务检查
---> Package datadog-agent.x86_64 1:7.18.1-1 will be 安装
--> 完成依赖关系计算

依赖关系解决

================================================================================
 软件包                架构           版本                仓库             大小
================================================================================
正在安装:
 datadog-agent         x86_64         1:7.18.1-1          datadog         130 M

事务概要
================================================================================
Install       1 Package(s)

总下载量：130 M
Installed size: 435 M
下载软件包：
warning: rpmts_HdrFromFdno: Header V4 RSA/SHA1 Signature, key ID e09422b3: NOKEY
Retrieving key from https://yum.datadoghq.com/DATADOG_RPM_KEY_E09422B3.public
Importing GPG key 0xE09422B3:
 Userid: "Datadog, Inc <package@datadoghq.com>"
 From  : https://yum.datadoghq.com/DATADOG_RPM_KEY_E09422B3.public
运行 rpm_check_debug
执行事务测试
事务测试成功
执行事务
  正在安装   : 1:datadog-agent-7.18.1-1.x86_64                              1/1
Enabling service datadog-agent
Loading SELinux policy module for datadog-agent.
Couldn’t load system-probe policy.
To be able to run system-probe on your host, please install or update the selinux-policy-targeted and
policycoreutils-python (or policycoreutils-python-utils depending on your distribution) packages.
Then run the following commands, or reinstall datadog-agent:
    semodule -i /etc/datadog-agent/selinux/system_probe_policy.pp
    semanage fcontext -a -t system_probe_t /opt/datadog-agent/embedded/bin/system-probe
    restorecon -v /opt/datadog-agent/embedded/bin/system-probe
No datadog.yaml file detected, not starting the agent
  Verifying  : 1:datadog-agent-7.18.1-1.x86_64                              1/1

已安装:
  datadog-agent.x86_64 1:7.18.1-1

完毕！

* Adding your API key to the Agent configuration: /etc/datadog-agent/datadog.yaml

* Starting the Agent...

stop: Unknown instance:
datadog-agent start/running, process 15261


Your Agent is running and functioning properly. It will continue to run in the
background and submit metrics to Datadog.

If you ever want to stop the Agent, run:

     stop datadog-agent

And to run it again run:

     start datadog-agent

[root@NB-flexgw1:/root]# pwd
/etc/datadog-agent/conf.d
[root@NB-flexgw1:/root]# ls
activemq.d            containerd.d   external_dns.d   ibm_mq.d                   kube_scheduler.d     nfsstat.d                   rabbitmq.d     tcp_check.d
activemq_xml.d        coredns.d      file_handle.d    ibm_was.d                  kyototycoon.d        nginx.d                     redisdb.d      teamcity.d
aerospike.d           couchbase.d    flink.d          io.d                       lighttpd.d           nginx_ingress_controller.d  riakcs.d       tenable.d
airflow.d             couch.d        fluentd.d        istio.d                    linkerd.d            ntp.d                       riak.d         tls.d
amazon_msk.d          cpu.d          gearmand.d       jboss_wildfly.d            linux_proc_extras.d  openldap.d                  sap_hana.d     tomcat.d
ambari.d              cri.d          gitlab.d         jmx.d                      load.d               openmetrics.d               scylla.d       twemproxy.d
apache.d              crio.d         gitlab_runner.d  kafka_consumer.d           mapr.d               openstack_controller.d      snmp.d         twistlock.d
btrfs.d               directory.d    go_expvar.d      kafka.d                    mapreduce.d          openstack.d                 solr.d         uptime.d
cacti.d               disk.d         go-metro.d       kong.d                     marathon.d           oracle.d                    spark.d        varnish.d
cassandra.d           dns_check.d    gunicorn.d       kube_apiserver_metrics.d   mcache.d             pgbouncer.d                 sqlserver.d    vault.d
cassandra_nodetool.d  docker.d       haproxy.d        kube_controller_manager.d  memory.d             php_fpm.d                   squid.d        vertica.d
ceph.d                druid.d        harbor.d         kube_dns.d                 mesos_master.d       postfix.d                   ssh_check.d    vsphere.d
cilium.d              ecs_fargate.d  hdfs_datanode.d  kubelet.d                  mesos_slave.d        postgres.d                  statsd.d       yarn.d
cisco_aci.d           eks_fargate.d  hdfs_namenode.d  kube_metrics_server.d      mongo.d              powerdns_recursor.d         supervisord.d  zk.d
clickhouse.d          elastic.d      hive.d           kube_proxy.d               mysql.d              presto.d                    system_core.d
cockroachdb.d         envoy.d        http_check.d     kubernetes_apiserver.d     nagios.d             process.d                   systemd.d
consul.d              etcd.d         ibm_db2.d        kubernetes_state.d         network.d            prometheus.d                system_swap.d
[root@NB-flexgw1:/root]#
```

<img src='https://i.loli.net/2020/04/22/pdERu9nf341wKHi.jpg' alt='pdERu9nf341wKHi'/>

## 添加MySQL监控

最简单配置

```shell script
[root@NB-flexgw1:/root]# grep -v '^      #' conf.yaml | grep -v '^#' | grep -v '    #' |grep -v '^$'
init_config:
instances:
  - server: 10.200.6.53
    user: xxx
    pass: xxx
```

<img src='https://i.loli.net/2020/04/22/32pZwyrigFLK96f.jpg' alt='32pZwyrigFLK96f'/>

## 添加pg监控

```sql
psql postgres -c \
"select * from pg_stat_database LIMIT(1);" \
&& echo -e "\e[0;32mPostgres connection - OK\e[0m" \
|| echo -e "\e[0;31mCannot connect to Postgres\e[0m"


CREATE FUNCTION pg_stat_activity() RETURNS SETOF pg_catalog.pg_stat_activity AS
$$ SELECT * from pg_catalog.pg_stat_activity; $$
LANGUAGE sql VOLATILE SECURITY DEFINER;

CREATE VIEW pg_stat_activity_dd AS SELECT * FROM pg_stat_activity();
grant SELECT ON pg_stat_activity_dd to test01;
```

<img src='https://i.loli.net/2020/04/22/Gnob6tVLOqcAdjZ.jpg' alt='Gnob6tVLOqcAdjZ'/>

<img src='https://i.loli.net/2020/04/22/OB6FixH5kfwnXvI.jpg' alt='OB6FixH5kfwnXvI'/>

<img src='https://i.loli.net/2020/04/22/6mnOXzMalJoyGTt.jpg' alt='6mnOXzMalJoyGTt'/>

<img src='https://i.loli.net/2020/04/22/aGhsDypmf1EOFJb.jpg' alt='aGhsDypmf1EOFJb'/>

## datadog agent 日志

```bash
/var/log/datadog/errors.log
/var/log/datadog/trace-errors.log
/var/log/datadog/trace-agent.log
/var/log/datadog/process-errors.log
/var/log/datadog/process-agent.log 
```

## 使用感受

1. datadog产品聚焦于IT运维场景，且方案中拓展成不通行业的运维场景，非常地有针对性。
2. 安装配置文档说明非常详细。
2. 采集器丰富，且非常强大，举例（mysql采集器比telegraf官方的强大多了！！！！已经支持自定义SQL的方式，且包含对mysql错误日志、慢查询日志的集成）--用户的角度，而不是只提供插件不提供场景
3. 默认的图表展示较一般，且全英文
4. 告警还没有使用，先不说感受了。
