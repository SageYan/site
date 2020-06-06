---
title: MySQL 8.0的新增功能探索-备用锁
date: 2020-05-26T17:58:00.000Z
categories:
- [MySQL8.0]
tags:
- MySQL新特性
---

- **备用锁。** 一种新型的备份锁可以在联机备份期间允许DML，同时防止可能导致快照不一致的操作。[`LOCK INSTANCE FOR BACKUP`](https://dev.mysql.com/doc/refman/8.0/en/lock-instance-for-backup.html) 和 [`UNLOCK INSTANCE`](https://dev.mysql.com/doc/refman/8.0/en/lock-instance-for-backup.html)语法支持新的备份锁 。该 [`BACKUP_ADMIN`](https://dev.mysql.com/doc/refman/8.0/en/privileges-provided.html#priv_backup-admin)权限才能使用这些语句。
