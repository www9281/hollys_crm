--------------------------------------------------------
--  DDL for Procedure COMMON_GROUP_SAVE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."COMMON_GROUP_SAVE" (
        P_CODE_TP    IN    VARCHAR2,
        P_CODE_CD    IN    VARCHAR2,
        P_CODE_NM    IN    VARCHAR2,
        P_BRAND_CD   IN    VARCHAR2,
        P_ACC_CD     IN    VARCHAR2,
        P_REMARKS    IN    VARCHAR2,
        P_POS_IF_YN  IN    CHAR,
        P_USE_YN     IN    CHAR,
        P_MY_USER_ID IN    VARCHAR2
) AS 
BEGIN
        MERGE INTO COMMON
        USING DUAL
        ON (
                    CODE_TP = P_CODE_TP
              AND   CODE_CD = P_CODE_CD
           )
        WHEN MATCHED THEN 
           UPDATE 
              SET   CODE_NM     = P_CODE_NM
                ,   BRAND_CD    = P_BRAND_CD
                ,   ACC_CD      = P_ACC_CD
                ,   REMARKS     = P_REMARKS
                ,   POS_IF_YN   = DECODE(P_POS_IF_YN, 'Y', 'Y', 'N')
                ,   USE_YN      = DECODE(P_USE_YN   , 'Y', 'Y', 'N')
                ,   UPD_DT      = SYSDATE
                ,   UPD_USER    = P_MY_USER_ID
        WHEN NOT MATCHED THEN
           INSERT
           (        CODE_TP
                ,   CODE_CD
                ,   CODE_NM
                ,   BRAND_CD
                ,   ACC_CD
                ,   REMARKS
                ,   POS_IF_YN
                ,   USE_YN
                ,   INST_DT
                ,   INST_USER
                ,   UPD_DT
                ,   UPD_USER
           ) VALUES (   
                    P_CODE_TP
                ,   P_CODE_CD
                ,   P_CODE_NM
                ,   P_BRAND_CD
                ,   P_ACC_CD
                ,   P_REMARKS
                ,   DECODE(P_POS_IF_YN, 'Y', 'Y', 'N')
                ,   DECODE(P_USE_YN   , 'Y', 'Y', 'N')
                ,   SYSDATE
                ,   P_MY_USER_ID
                ,   SYSDATE
                ,   P_MY_USER_ID
           );
END COMMON_GROUP_SAVE;

/
