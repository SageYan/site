title: Oracle11g常用视图
categories:
    - [技术广角, Oracle]
tags:
    - oracle11g
date: 2020-05-28 16:11:33
---

|Oracle常用视图|说明|
| ------------------------------------------------------------ |---|
| [dba_hist_snapshot](https://docs.oracle.com/cd/E11882_01/server.112/e40402/statviews_4045.htm#REFRN23442)         | 在工作负载存储库中显示有关快照的信息。 |
| [v$osstat](https://docs.oracle.com/cd/E11882_01/server.112/e40402/dynviews_2085.htm)          |显示来自操作系统的系统利用率统计信息。每个系统统计信息返回一行          * PHYSICAL_MEMORY_BYTES:Total number of bytes of physical memory     * NUM_CPUS:Number of CPUs or processors available |
| [v$database](https://docs.oracle.com/cd/E11882_01/server.112/e40402/dynviews_1097.htm#REFRN30047)          |显示控制文件中有关数据库的信息。 |
| [v$instance](https://docs.oracle.com/cd/E11882_01/server.112/e40402/dynviews_2002.htm)          |显示当前实例的状态。 |
| [DBA_REGISTRY_HISTORY](https://docs.oracle.com/cd/E11882_01/server.112/e40402/statviews_4212.htm)            |提供有关在数据库上执行的升级，降级和重要补丁更新的信息。 |
| [v$parameter](https://docs.oracle.com/cd/E11882_01/server.112/e40402/dynviews_2087.htm#REFRN30176)      [AUDIT_TRAIL](https://docs.oracle.com/cd/E11882_01/server.112/e40402/initparams017.htm#REFRN10006)     [SESSIONS](https://docs.oracle.com/cd/E11882_01/server.112/e40402/initparams234.htm)      [PROCESSES](https://docs.oracle.com/cd/E11882_01/server.112/e40402/initparams202.htm#REFRN10175)              | 显示有关该会话当前有效的初始化参数的信息。         <br/> * audit_trail:启用或禁用数据库审核     <br/>* sessions:指定系统中可以创建的最大会话数。     <br/>* processes:指定可以同时连接到Oracle的最大操作系统用户进程数。它的值应允许所有后台进程，例如锁，作业队列进程和并行执行进程。 |
| [V$ARCHIVED_LOG](https://docs.oracle.com/cd/E11882_01/server.112/e40402/dynviews_1016.htm#REFRN30011) |`V$ARCHIVED_LOG`显示控制文件中的存档日志信息，包括存档日志名称。成功归档或清除联机重做日志后，将插入归档日志记录（`NULL`如果清除了日志，则名称列）。如果日志被归档两次，就会出现带有两个相同的归档日志记录`THREAD#`，`SEQUENCE#`和`FIRST_CHANGE#`，但使用不同的名称。从备份集或副本还原存档日志时，以及使用RMAN  `COPY`命令创建日志副本时，也会插入存档日志记录。|
| [V$PGASTAT](https://docs.oracle.com/cd/E11882_01/server.112/e40402/dynviews_2096.htm#REFRN30180) ||
| [dba_users](https://docs.oracle.com/cd/E11882_01/server.112/e40402/statviews_5081.htm#REFRN23302)          |`DBA_USERS` 描述数据库的所有用户。 |
| [DBA_OBJECTS](https://docs.oracle.com/cd/E11882_01/server.112/e40402/statviews_1158.htm#i1583352)         | `DBA_OBJECTS`描述数据库中的所有对象。          `V$LOCKED_OBJECT`列出系统上每个事务获取的所有锁。它显示哪些会话在什么对象和什么模式下持有DML锁（即TM类型的队列）。 |
| [v$session](https://docs.oracle.com/cd/E11882_01/server.112/e40402/dynviews_3016.htm) |显示每个当前会话的会话信息。|
| [v$locked_object](https://docs.oracle.com/cd/E11882_01/server.112/e40402/dynviews_2030.htm#REFRN30125) | |
| [v$undostat](https://docs.oracle.com/cd/E11882_01/server.112/e40402/dynviews_3118.htm#REFRN30295)          |显示统计数据的直方图以显示系统的运行状况。可用的统计信息包括撤消空间消耗，事务并发以及在实例中执行的查询的长度。您可以使用此视图来估计当前工作负载所需的撤消空间量。Oracle使用此视图来调整系统中的撤消使用情况。如果系统处于手动撤消管理模式，则该视图返回NULL值。 |
| [v$log](https://docs.oracle.com/cd/E11882_01/server.112/e40402/dynviews_2031.htm)          |显示控制文件中的日志文件信息。          **STATUS**日志状态：          - `UNUSED`-在线重做日志从未写入过。这是刚刚添加的重做日志的状态，或者`RESETLOGS`不是当前重做日志时在之后的状态。     - `CURRENT`-当前重做日志。这意味着重做日志处于活动状态。重做日志可以打开或关闭。     - `ACTIVE`-日志处于活动状态，但不是当前日志。崩溃恢复需要它。它可能正在用于块恢复。它可能已存档，也可能未存档。     - `CLEARING`- `ALTER DATABASE CLEAR LOGFILE`语句后，日志将重新创建为空日志。清除日志后，状态变为`UNUSED`。     - `CLEARING_CURRENT`-当前日志正在清除关闭的线程。如果交换机出现故障，例如I / O错误写入新的日志头，则日志可以保持此状态。     - `INACTIVE`-实例恢复不再需要日志。它可能正在用于介质恢复。它可能已存档，也可能未存档。 |
| [v$dataguard_status](https://docs.oracle.com/cd/E11882_01/server.112/e40402/dynviews_1105.htm)          |显示最近写入警报日志或服务器进程跟踪文件的消息，这些消息与物理备用数据库或所有备用数据库类型的重做传输服务有关。 |
| [V$MANAGED_STANDBY](https://docs.oracle.com/cd/E11882_01/server.112/e40402/dynviews_2050.htm)          |显示与Data Guard环境中的物理备用数据库有关的某些Oracle Database进程的当前状态信息。实例关闭后，该视图不会继续存在。 |
| [V$ASM_DISKGROUP](https://docs.oracle.com/cd/E11882_01/server.112/e40402/dynviews_1027.htm#REFRN30171) |V$ASM_DISKGROUP 为节点上的ASM实例发现的每个ASM磁盘组显示一行。|
| [v$recovery_file_dest](https://docs.oracle.com/cd/E11882_01/server.112/e40402/dynviews_2125.htm)          |在快速恢复区域中显示有关磁盘配额和当前磁盘使用情况的信息。 |
| [DBA_FREE_SPACE](https://docs.oracle.com/cd/E11882_01/server.112/e40402/statviews_3194.htm#REFRN23076)         | 描述数据库中所有表空间的使用情况。 |
| [dba_temp_files](https://docs.oracle.com/cd/E11882_01/server.112/e40402/statviews_5061.htm)          |DBA_TEMP_FILES 描述数据库中的所有临时文件（临时文件）。 |
| [dba_tablespaces](https://docs.oracle.com/cd/E11882_01/server.112/e40402/statviews_5060.htm#REFRN23287)         | DBA_TABLESPACES 描述数据库中的所有表空间。 |
| [gv$sort_segment](https://docs.oracle.com/cd/E11882_01/server.112/e40402/dynviews_3041.htm)          |V$SORT_SEGMENT显示有关给定实例中每个排序段的信息。仅在表空间是TEMPORARY类型时更新视图。 |
| [v$transaction](https://docs.oracle.com/cd/E11882_01/server.112/e40402/dynviews_3114.htm)          |V$TRANSACTION 列出系统中的活动事务。 |
| [v$backup_set_details](https://docs.oracle.com/cd/E11882_01/server.112/e40402/dynviews_1062.htm#REFRN30371) |备份信息10g 11g 12c|
