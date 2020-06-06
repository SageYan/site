---
title: MySQL 8.0的新增功能探索-原子数据定义语句（Atomic DDL）
date: 2020-05-26T17:58:00.000Z
categories:
- [MySQL8.0]
tags:
- MySQL新特性
---

- **原子数据定义语句（Atomic DDL）。** 原子DDL语句将数据字典更新，存储引擎操作以及与DDL操作关联的二进制日志写入操作组合到单个原子事务中。有关更多信息，请参见 [第13.1.1节"原子数据定义语句支持"](https://dev.mysql.com/doc/refman/8.0/en/atomic-ddl.html)。- **升级程序。** 以前，在安装新版本的MySQL之后，MySQL服务器会在下次启动时自动升级数据字典表，此后，DBA有望 手动调用[**mysql_upgrade**](https://dev.mysql.com/doc/refman/8.0/en/mysql-upgrade.html)来升级`mysql`架构中的系统表 以及其他模型中的对象。架构，例如`sys`架构和用户架构。从MySQL 8.0.16开始，服务器执行以前由[**mysql_upgrade**](https://dev.mysql.com/doc/refman/8.0/en/mysql-upgrade.html)处理的任务。在安装新的MySQL版本之后，服务器现在将在下次启动时自动执行所有必要的升级任务，而不依赖于DBA调用 [**mysql_upgrade**](https://dev.mysql.com/doc/refman/8.0/en/mysql-upgrade.html)。另外，服务器更新帮助表的内容（ [**mysql_upgrade**](https://dev.mysql.com/doc/refman/8.0/en/mysql-upgrade.html)没做的事情）。新的 [`--upgrade`](https://dev.mysql.com/doc/refman/8.0/en/server-options.html#option_mysqld_upgrade)服务器选项可控制服务器如何执行自动数据字典和服务器升级操作。有关更多信息，请参见 [第2.11.3节" MySQL升级过程将升级什么"](https://dev.mysql.com/doc/refman/8.0/en/upgrading-what-is-upgraded.html)。
