---
title: MySQL 8.0的新增功能探索-克隆插件
date: 2020-05-26T17:58:00.000Z
categories:
- [MySQL8.0]
tags:
- MySQL新特性
---

**克隆插件。** 从MySQL 8.0.17开始，MySQL提供了一个克隆插件，允许`InnoDB`在本地或从远程MySQL服务器实例克隆数据。本地克隆操作将克隆的数据存储在运行MySQL实例的同一服务器或节点上。远程克隆操作通过网络将克隆的数据从施主MySQL服务器实例传输到发起克隆操作的接收者服务器或节点。
