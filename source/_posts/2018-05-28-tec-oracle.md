---
title: Oracle数据库SQL优化_索引缺失
date: 2018-05-28 18:09:32
categories:
- [技术广角, Oracle]
tags:
- SQL优化
---

摘要：Oracle数据库做了迁移，从原来的DG迁移到新库RAC，小版本不同；老库中相同的SQL执行只需要11秒，而新库需要360秒甚至800多秒，如何进行复杂查询的SQL优化，本文提供通用的一个思路。
<!--more-->

## 问题描述

oracle数据库做了迁移，从原来的DG迁移到新库RAC，小版本不同；

老库中相同的SQL执行只需要11秒，而新库需要360秒甚至800多秒。

| 库      | 原查询时间 | 优化后的查询时间          |
| ------- | ---------- | ------------------------- |
| 老库    | 11秒       | 1.4秒 缓存后 0.4秒        |
| 新库RAC | 360秒      | 1.4秒 缓存后0.4秒排查思路 |

## 待优化SQL

```shell
SELECT
	prj.PROVINCE_AD_NAME,
	prj.CITY_AD_NAME,
	prj.AD_NAME,
	prj.CHANNEL_SYS_CAT,
	prj.EXCUTE_EL,
	prj.PRJ_CODE AS PRJ_CODE,
	prj.PRJ_NAME AS PRJ_NAME,
	prj.POS_CODE AS POS_CODE,
	prj.POS_NAME AS POS_NAME,
	prj.CUST_CHANNEL_CODE,
	prj.CUST_CHANNEL_NAME,
	prj.EMP_CODE AS EMP_CODE,
	prj.NAME AS EMP_NAME,
	prj.ATT_DATE AS APPLY_DATE,
	prj.EMP_PK AS EMP_PK,
	prj.ATT_START_TIME AS START_TIME,
	prj.ATT_END_TIME AS END_TIME,
	prj.ATT_ISWORK AS ISWORK,
	prj.ATT_UNWORK AS ATTTYPE,
	prj.START_XPOS AS ON_WORK_POSITION_LON,
	prj.START_YPOS AS ON_WORK_POSITION_LAT,
	prj.START_ISEXCEP AS ON_WORK_POSITION_STAUS,
	prj.END_XPOS AS OFF_WORK_POSITION_LAT,
	prj.END_YPOS AS OFF_WORK_POSITION_LON,
	prj.END_ISEXCEP AS OFF_WORK_POSITION_STAUS,
	ifcl1Staus.COMPARE_TYPE AS FACE_ATT_TYPE,
	ifcl1.STATUS AS FACE_ATT_STATUS,
	NVL( ifaceCount.faceCount, 0 ) AS FACE_ATT_COUNT,
	NVL( levLeave.LEAVECount, 0 ) AS LEAVE_WORK_COUNT,
	NVL( levRtn.RETURNCount, 0 ) AS RETURN_WORK_COUNT,
	wq.STATUS AS PRJ_QUESTION_TYPE,
	iface2.FACE_ATT_IMG AS FACE_ATT_IMG,
	prj.SA_TYPE
FROM
	(
		SELECT
			dpsi.ID AS ID,
			P.ID AS PRJ_ID,
			mad.AD_CODE,
			mad.PROVINCE_AD_NAME,
			mad.CITY_AD_NAME,
			mad.AD_NAME,
			mpk.POS_KIND_CODE,
			mpk.POS_KIND_NAME,
			P.CODE AS PRJ_CODE,
			P.NAME AS PRJ_NAME,
			P.START_DATE,
			p.END_DATE,
			dpsi.CUST_CHANNEL,
			dpsi.CUST_SYS,
			dpsi.CUST_CHANNEL_CODE,
			dpsi.CUST_CHANNEL_NAME,
			dcs.CHANNEL_SYS_CAT,
			dcs.CHANNEL_CAT_CODE,
			dcs.CHANNEL_AD_CODE,
			dcs.CHANNEL_PROVINCE_AD_CODE,
			dcs.CHANNEL_CITY_AD_CODE,
			dcs.ID AS POS_ID,
			dcs.CHANNEL_CODE AS POS_CODE,
			dcs.CHANNEL_NAME AS POS_NAME,
			dcs.LONGITUDE AS LONGITUDE,
			dcs.LATITUDE AS LATITUDE,
			dss.id AS SALES_ID,
			TO_CHAR( cal.sc_schedule_date, 'yyyy-mm-dd' ) AS sc_schedule_date,
			wor.SW_BEGIN_TIME AS SALES_WORK_START,
			wor.SW_END_TIME AS SALES_WORK_END,
			dss.SALES_EAT_START,
			dss.SALES_EAT_END,
			memp.EMP_PK,
			memp.EMP_CODE,
			dss.SALES_NAME AS NAME,
			dss.SALES_PHONE AS TEL,
			dss.SALES_CARD_ID AS ID_CARD,
			spp.PRJ_ATT_CHECK_TYPE,
			spp.ALLOW_LEAVE_TIME,
			e1.EMP_CODE AS EXCUTE_CODE,
			e1.emp_name AS EXCUTE_EL,
			e2.EMP_CODE AS CITY_CODE,
			e2.emp_name AS CITY_EL,
			e3.EMP_CODE AS AREA_CODE,
			e3.EMP_NAME AS AREA_NAME,
			dpsi.SCHEDULE_TYPE,
			sac.ATT_START_TIME,
			sac.ATT_END_TIME,
			sac.ATT_ISWORK,
			sac.ATT_UNWORK,
			sac.START_XPOS,
			sac.START_YPOS,
			DECODE( sac.START_ISEXCEP, 0, 2201, 1, 2202, 2, 2203, 3, 2204, 4, 2205, 2206 ) AS START_ISEXCEP,
			sac.END_XPOS,
			sac.END_YPOS,
			sac.END_ISEXCEP,
			sac.ATT_SCH_PK,
			sac.ATT_DATE,
			CASE
				WHEN sac.ATT_START_TIME IS NOT NULL
				AND sac.ATT_END_TIME IS NOT NULL THEN '1'
				WHEN sac.ATT_START_TIME IS NOT NULL
				OR sac.ATT_END_TIME IS NOT NULL THEN '2'
				ELSE '2'
			END AS SA_TYPE
		FROM
			DM_PROJECT_SELLIN_INFO dpsi
		LEFT JOIN MD_EMP e1 ON
			dpsi.EMP_CODE = e1.EMP_CODE
		LEFT JOIN MD_EMP e2 ON
			dpsi.CITY_EMP_CODE = e2.EMP_CODE
		LEFT JOIN MD_EMP e3 ON
			dpsi.AREA_MANAGER_CODE = e3.EMP_CODE,
			DM_PROJECT P,
			DM_PROJECT_SELLIN_SALES dss,
			DM_CHANNEL_SYNC dcs,
			MD_EMP memp,
			SP_PRJ_PARM spp,
			Md_Admin_Div mad,
			MD_POS_KIND mpk,
			dm_sales_schedule_calendar cal,
			dm_sales_schedule_work wor,
			SP_ATT_SCH sac
		WHERE
			dpsi.PROJECT_ID = P.ID
			AND dss.id = cal.sales_id
			AND cal.schedule_work_id = wor.id
			AND dcs.CHANNEL_CAT_CODE = mpk.POS_KIND_CODE
			AND dss.PROJECT_SELLIN_INFO_ID = dpsi.ID
			AND dss.DELETE_FLAG = '0'
			AND dpsi.CHANNEL_SYNC_ID = dcs.ID
			AND LOWER( memp.EMP_S_CODE )= LOWER( dss.SALES_CARD_ID )
			AND P.IS_DELETE IS NULL
			AND memp.IS_DEL = '0'
			AND spp.PRJ_CODE = P.CODE
			AND mad.AD_ID = dcs.CHANNEL_ADMIN_DIV_ID
			AND mad.IS_DEL = '0'
			AND memp.EMP_TYPE = '1001'
			AND TO_CHAR( cal.sc_schedule_date, 'yyyy-mm-dd' )>='2018-04-01'
			AND TO_CHAR( cal.sc_schedule_date, 'yyyy-mm-dd' )<='2018-04-30'
			AND sac.PRJ_CODE = p.CODE
			AND sac.POS_CODE = dcs.CHANNEL_CODE
			AND sac.EMP_PK = memp.EMP_PK
			AND sac.ATT_DATE = TO_CHAR( cal.sc_schedule_date, 'yyyy-mm-dd' )
			AND TO_CHAR( sac.CRT_DATE, 'yyyy-mm-dd' )>='2018-04-01'
			AND TO_CHAR( sac.CRT_DATE, 'yyyy-mm-dd' )<='2018-04-30'
	) prj,
	(
		SELECT
			ifcl.EMP_PK,
			ifcl.COMPARE_DATE,
			ifcl.STATUS
		FROM
			IPG_FACE_COMPARE_LOG ifcl
		WHERE
			ifcl.HANDLE_TYPE = 0
			AND ifcl.DELETE_FLAG = '0'
			AND ifcl.COMPARE_TYPE IN(
				'1',
				'3',
				'5'
			)
			AND ifcl.COMPARE_DATE >= TO_CHAR( TO_DATE('2018-04-01', 'yyyy-mm-dd' ), 'yyyymmdd' )
			AND ifcl.COMPARE_DATE <= TO_CHAR( TO_DATE('2018-04-30', 'yyyy-mm-dd' ), 'yyyymmdd' )
		GROUP BY
			ifcl.EMP_PK,
			ifcl.COMPARE_DATE,
			ifcl.STATUS
		HAVING
			AVG( STATUS )< 1
	) ifcl1,
	(
		SELECT
			*
		FROM
			(
				SELECT
					EMP_PK,
					COMPARE_DATE,
					COMPARE_TYPE,
					ROW_NUMBER() OVER(
						PARTITION BY EMP_PK,
						COMPARE_DATE
					ORDER BY
						CREATED DESC
					) rn
				FROM
					IPG_FACE_COMPARE_LOG
				WHERE
					COMPARE_DATE >= TO_CHAR( TO_DATE('2018-04-01', 'yyyy-mm-dd' ), 'yyyymmdd' )
					AND COMPARE_DATE <= TO_CHAR( TO_DATE('2018-04-30', 'yyyy-mm-dd' ), 'yyyymmdd' )
					AND COMPARE_TYPE IN(
						'1',
						'3',
						'5'
					)
			) t
		WHERE
			t.rn <= 1
	) ifcl1Staus,
	(
		SELECT
			SP_LEV_RPT.ATT_SCH_PK,
			COUNT(*) AS LEAVECount
		FROM
			SP_LEV_RPT
		WHERE
			SP_LEV_RPT.START_TIME IS NOT NULL
		GROUP BY
			SP_LEV_RPT.ATT_SCH_PK
	) levLeave,
	(
		SELECT
			SP_LEV_RPT.ATT_SCH_PK,
			COUNT(*) AS RETURNCount
		FROM
			SP_LEV_RPT
		WHERE
			SP_LEV_RPT.END_TIME IS NOT NULL
		GROUP BY
			SP_LEV_RPT.ATT_SCH_PK
	) levRtn,
	(
		SELECT
			WX_QUESTION.PRJ_ID,
			DM_PROJECT.CODE,
			'Y' AS STATUS
		FROM
			WX_QUESTION,
			DM_PROJECT
		WHERE
			DM_PROJECT.ID = WX_QUESTION.PRJ_ID
			AND WX_QUESTION.IS_DEL = '0'
			AND WX_QUESTION.STATUS = '0'
		GROUP BY
			WX_QUESTION.PRJ_ID,
			DM_PROJECT.CODE
	) wq,
	(
		SELECT
			ifcl.EMP_PK,
			ifcl.COMPARE_DATE,
			COUNT(*) AS faceCount
		FROM
			IPG_FACE_COMPARE_LOG ifcl
		WHERE
			ifcl.HANDLE_TYPE = 0
			AND ifcl.COMPARE_TYPE IN(
				'1',
				'3',
				'5'
			)
			AND ifcl.COMPARE_DATE >= TO_CHAR( TO_DATE('2018-04-01', 'yyyy-mm-dd' ), 'yyyymmdd' )
			AND ifcl.COMPARE_DATE <= TO_CHAR( TO_DATE('2018-04-30', 'yyyy-mm-dd' ), 'yyyymmdd' )
		GROUP BY
			ifcl.EMP_PK,
			ifcl.COMPARE_DATE
	) ifaceCount,
	(
		SELECT
			iface.EMP_PK,
			iface.COMPARE_DATE,
			wm_concat(
				(
					SELECT
						NVL( TRIM( T.PAR_VALUE ), TRIM( T.OLD_PAR_VALUE ))
					FROM
						(
							SELECT
								(
									SELECT
										PAR_VALUE
									FROM
										MD_SYS_PARM
									WHERE
										PAR_CODE = 'OLD_PIC_PATH'
								) AS OLD_PAR_VALUE,
								PAR_VALUE
							FROM
								MD_SYS_PARM
							WHERE
								PAR_CODE = 'ATT_COS_PATH'
						) T
				)|| REPLACE( SUBSTR( iface.COMPARE_MSG, INSTR( iface.COMPARE_MSG, 'compare', 1, 1 )), ']', '' )
			) AS FACE_ATT_IMG
		FROM
			(
				SELECT
					ifa.EMP_PK,
					ifa.COMPARE_DATE,
					ifa.COMPARE_MSG,
					RANK() OVER(
						PARTITION BY ifa.EMP_PK,
						ifa.COMPARE_DATE
					ORDER BY
						ifa.created DESC
					) rankno
				FROM
					IPG_FACE_COMPARE_LOG ifa
				WHERE
					ifa.HANDLE_TYPE = 0
					AND ifa.COMPARE_TYPE IN(
						'1',
						'3',
						'5'
					)
					AND INSTR( ifa.COMPARE_MSG, 'compare' )> 0
					AND ifa.COMPARE_DATE >= TO_CHAR( TO_DATE('2018-04-01', 'yyyy-mm-dd' ), 'yyyymmdd' )
					AND ifa.COMPARE_DATE <= TO_CHAR( TO_DATE('2018-04-30', 'yyyy-mm-dd' ), 'yyyymmdd' )
			) iface
		WHERE
			iface.rankno <= 3
		GROUP BY
			iface.EMP_PK,
			iface.COMPARE_DATE
	) iface2
WHERE
	prj.PRJ_NAME ='(2013)行政项目'
	AND prj.ATT_DATE >='2018-04-01'
	AND prj.ATT_DATE <='2018-04-30'
	AND prj.EMP_PK = ifcl1.EMP_PK(+)
	AND TO_CHAR( TO_DATE( prj.ATT_DATE, 'yyyy-mm-dd' ), 'yyyymmdd' )= ifcl1.COMPARE_DATE(+)
	AND prj.EMP_PK = ifcl1Staus.EMP_PK(+)
	AND TO_CHAR( TO_DATE( prj.ATT_DATE, 'yyyy-mm-dd' ), 'yyyymmdd' )= ifcl1Staus.COMPARE_DATE(+)
	AND prj.ATT_SCH_PK = levLeave.ATT_SCH_PK(+)
	AND prj.ATT_SCH_PK = levRtn.ATT_SCH_PK(+)
	AND prj.PRJ_CODE = wq.CODE(+)
	AND prj.EMP_PK = ifaceCount.EMP_PK(+)
	AND TO_CHAR( TO_DATE( prj.ATT_DATE, 'yyyy-mm-dd' ), 'yyyymmdd' )= ifaceCount.COMPARE_DATE(+)
	AND prj.EMP_PK = iface2.EMP_PK(+)
	AND TO_CHAR( TO_DATE( prj.sc_schedule_date, 'yyyy-mm-dd' ), 'yyyymmdd' )= iface2.COMPARE_DATE(+)
ORDER BY
	APPLY_DATE DESC,
	ATTTYPE DESC
```

## SQL优化思路

SQL语句较复杂，8个子查询的left outer join，每个子查询中又有连接。思路如下：

1. 从外往内拆分子查询
2. 老旧对比子查询执行计划和执行效率
3. 子查询连接从1到2到3一直到8个联查对比，寻找瓶颈

### 拆分子查询

| 子查询     | 老库 （秒） | 新库（秒） |
| ---------- | ----------- | ---------- |
| prj        | 1.182       | 0.318      |
| ifcl1      | 14.229      | 13.168     |
| ifclStatus | 15.739      | 16.769     |
| levLeave   | 10.147      | 9.813      |
| levRtn     | 9.148       | 8.3        |
| wq         | 0.141       | 0.165      |
| ifcl1Count | 3.498       | 1.966      |
| iface2     | 49.255      | 50.897     |



### 寻找瓶颈

| 连接        | 老库（秒） | 新库（秒） |
| ----------- | ---------- | ---------- |
| prj+ifcl1   | 1.522      | 1.129      |
| +ifclStatus | 2.343      | 1.957      |
| +levLeave   | 2.525      | 1.955      |
| +levRtn     | 2.658      | 1.653      |
| +wq         | 2.561      | 1.999      |
| +ifcl1Count | 3.498      | 1.966      |
| +iface2     | 11.124     | 383        |

发现瓶颈出现在`iface2`

## 优化iface2

```shell
SELECT
			iface.EMP_PK,
			iface.COMPARE_DATE,
			wm_concat(
				(
					SELECT
						NVL( TRIM( T.PAR_VALUE ), TRIM( T.OLD_PAR_VALUE ))
					FROM
						(
							SELECT
								(
									SELECT
										PAR_VALUE
									FROM
										MD_SYS_PARM
									WHERE
										PAR_CODE = 'OLD_PIC_PATH'
								) AS OLD_PAR_VALUE,
								PAR_VALUE
							FROM
								MD_SYS_PARM
							WHERE
								PAR_CODE = 'ATT_COS_PATH'
						) T
				)|| REPLACE( SUBSTR( iface.COMPARE_MSG, INSTR( iface.COMPARE_MSG, 'compare', 1, 1 )), ']', '' )
			) AS FACE_ATT_IMG
		FROM
			(
				SELECT
					ifa.EMP_PK,
					ifa.COMPARE_DATE,
					ifa.COMPARE_MSG,
					RANK() OVER(
						PARTITION BY ifa.EMP_PK,
						ifa.COMPARE_DATE
					ORDER BY
						ifa.created DESC
					) rankno
				FROM
					IPG_FACE_COMPARE_LOG ifa
				WHERE
					ifa.HANDLE_TYPE = 0
					AND ifa.COMPARE_TYPE IN(
						'1',
						'3',
						'5'
					)
					AND INSTR( ifa.COMPARE_MSG, 'compare' )> 0
					AND ifa.COMPARE_DATE >= TO_CHAR( TO_DATE('2018-04-01', 'yyyy-mm-dd' ), 'yyyymmdd' )
					AND ifa.COMPARE_DATE <= TO_CHAR( TO_DATE('2018-04-30', 'yyyy-mm-dd' ), 'yyyymmdd' )
			) iface
		WHERE
			iface.rankno <= 3
		GROUP BY
			iface.EMP_PK,
			iface.COMPARE_DATE
```

`IPG_FACE_COMPARE_LOG`表中`COMPARE_DATE列`需要新增索引。

## 总结

1. oracle小版本不同引起优化器无法获取相同的执行计划
2. 索引缺失是本次的慢查询的主要原因