--------------------------------------------------------
--  DDL for Procedure SMS_SEND_SELECT_SENDER
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SMS_SEND_SELECT_SENDER" 
(
  N_START_DT IN VARCHAR2 
, N_END_DT IN VARCHAR2 
, N_SENDER IN VARCHAR2 
,  O_CURSOR    OUT SYS_REFCURSOR
) AS 
BEGIN
        OPEN O_CURSOR FOR
        SELECT  Y.SENDER_NAME,
                Y.SENDER_PHONE,
                Y.COUNT_ALL,
                Y.COUNT_S,
                Y.COUNT_L,
                Y.COUNT_M, 
                Y.COUNT_TARGET,
                Y.COUNT_S_TARGET,
                Y.COUNT_L_TARGET,
                Y.COUNT_M_TARGET,
                Y.COUNT_S_TARGET * 12 AS COST_S_TARGET,
                Y.COUNT_L_TARGET * 33 AS COST_L_TARGET,
                Y.COUNT_M_TARGET * 100 AS COST_M_TARGET,
                Y.COUNT_S_TARGET * 12 + Y.COUNT_L_TARGET * 33 + Y.COUNT_M_TARGET * 100 AS COST_TARGET
        FROM    (
                        SELECT  X.SENDER_NAME,
                                X.SENDER_PHONE,
                                SUM(CASE WHEN X.SMS_TYPE = 'S' THEN 1 ELSE 0 END) AS COUNT_S,
                                SUM(CASE WHEN X.SMS_TYPE = 'L' THEN 1 ELSE 0 END) AS COUNT_L,
                                SUM(CASE WHEN X.SMS_TYPE = 'M' THEN 1 ELSE 0 END) AS COUNT_M,
                                COUNT(*) AS COUNT_ALL,
                                SUM(CASE WHEN X.SMS_TYPE = 'S' AND X.IS_SEND = 1 THEN 1 ELSE 0 END) AS COUNT_S_TARGET,
                                SUM(CASE WHEN X.SMS_TYPE = 'L' AND X.IS_SEND = 1 THEN 1 ELSE 0 END) AS COUNT_L_TARGET,
                                SUM(CASE WHEN X.SMS_TYPE = 'M' AND X.IS_SEND = 1 THEN 1 ELSE 0 END) AS COUNT_M_TARGET,
                                SUM(CASE WHEN X.IS_SEND = 1 THEN 1 ELSE 0 END) AS COUNT_TARGET
                        FROM    (
                                        SELECT  CASE  WHEN  A.SMS_SENDER_ID IS NOT NULL
                                                      THEN  B.SENDER_NAME
                                                      ELSE  C.STOR_NM
                                                END AS SENDER_NAME,
                                                CASE  WHEN  A.SMS_SENDER_ID IS NOT NULL
                                                      THEN  B.PHONE
                                                      ELSE  C.TEL_NO
                                                END AS SENDER_PHONE,
                                                A.SMS_TYPE,
                                                --CASE  WHEN  E.TR_NUM IS NOT NULL OR F.MSGKEY IS NOT NULL
                                                CASE  WHEN  (E.TR_NUM IS NOT NULL AND E.TR_NUM <> '') OR (F.MSGKEY IS NOT NULL AND F.MSGKEY <> '')
                                                      THEN  0
                                                      ELSE  1
                                                END AS IS_SEND,
                                                D.CUST_ID
                                        FROM    SMS_SEND A
                                        LEFT    OUTER JOIN SMS_SENDER B
                                        ON      A.SMS_SENDER_ID = B.SMS_SENDER_ID
                                        LEFT    OUTER JOIN STORE C
                                        ON      A.STOR_CD = C.STOR_CD
                                        LEFT    OUTER JOIN SMS_SEND_CUST D
                                        ON      A.SMS_SEND_ID = D.SMS_SEND_ID
                                        LEFT    OUTER JOIN SC_TRAN E
                                        ON      D.TR_NUM = E.TR_NUM
                                        LEFT    OUTER JOIN MMS_MSG F
                                        ON      D.MSGKEY = F.MSGKEY
                                        WHERE   (N_START_DT IS NULL OR N_START_DT = '' OR TO_CHAR(A.INST_DT, 'YYYY-MM-DD HH24:MI') >= N_START_DT)
                                        AND     (N_END_DT IS NULL OR N_END_DT = '' OR TO_CHAR(A.INST_DT, 'YYYY-MM-DD HH24:MI') <= N_END_DT)
                                        AND     (N_SENDER IS NULL OR N_SENDER = '' OR B.SENDER_NAME LIKE '%'||N_SENDER||'%' OR C.STOR_NM LIKE '%'||N_SENDER||'%' OR B.PHONE LIKE '%'||N_SENDER||'%' OR C.TEL_NO LIKE '%'||N_SENDER||'%')
                                ) X
                        GROUP   BY
                                X.SENDER_NAME,
                                X.SENDER_PHONE
                ) Y;
END SMS_SEND_SELECT_SENDER;

/
