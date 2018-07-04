--------------------------------------------------------
--  DDL for Procedure COMMON_CODE_SAVE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."COMMON_CODE_SAVE" (
        P_CODE_TP    IN    VARCHAR2,
        P_CODE_CD    IN    VARCHAR2,
        P_CODE_NM    IN    VARCHAR2,
        P_BRAND_CD   IN    VARCHAR2,
        P_SORT_SEQ   IN    NUMBER,
        P_ACC_CD     IN    VARCHAR2,
        P_REMARKS    IN    VARCHAR2,
        P_USE_YN     IN    VARCHAR2,
        P_USER_ID    IN    VARCHAR2,
        P_VAL_D1     IN    VARCHAR2,
        P_VAL_D2     IN    VARCHAR2,
        P_VAL_C1     IN    VARCHAR2,
        P_VAL_C2     IN    VARCHAR2,
        P_VAL_C3     IN    VARCHAR2,
        P_VAL_C4     IN    VARCHAR2,
        P_VAL_C5     IN    VARCHAR2,
        P_VAL_N1     IN    NUMBER,
        P_VAL_N2     IN    NUMBER
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
              SET   CODE_NM  = P_CODE_NM
                ,   BRAND_CD = P_BRAND_CD
                ,   ACC_CD   = P_ACC_CD
                ,   SORT_SEQ = P_SORT_SEQ
                ,   VAL_D1   = P_VAL_D1
                ,   VAL_D2   = P_VAL_D2
                ,   VAL_C1   = P_VAL_C1
                ,   VAL_C2   = P_VAL_C2
                ,   VAL_C3   = P_VAL_C3
                ,   VAL_C4   = P_VAL_C4
                ,   VAL_C5   = P_VAL_C5
                ,   VAL_N1   = P_VAL_N1
                ,   VAL_N2   = P_VAL_N2
                ,   REMARKS  = P_REMARKS
                ,   USE_YN   = DECODE(P_USE_YN, 'Y', 'Y', 'N')
                ,   UPD_DT   = SYSDATE
                ,   UPD_USER = P_USER_ID
        WHEN NOT MATCHED THEN
           INSERT
           (        CODE_TP
                ,   CODE_CD
                ,   CODE_NM
                ,   BRAND_CD
                ,   SORT_SEQ
                ,   ACC_CD
                ,   VAL_D1
                ,   VAL_D2
                ,   VAL_C1
                ,   VAL_C2
                ,   VAL_C3
                ,   VAL_C4
                ,   VAL_C5
                ,   VAL_N1
                ,   VAL_N2
                ,   REMARKS
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
                ,   P_SORT_SEQ
                ,   P_ACC_CD
                ,   P_VAL_D1
                ,   P_VAL_D2
                ,   P_VAL_C1
                ,   P_VAL_C2
                ,   P_VAL_C3
                ,   P_VAL_C4
                ,   P_VAL_C5
                ,   P_VAL_N1
                ,   P_VAL_N2
                ,   P_REMARKS
                ,   DECODE(P_USE_YN, 'Y', 'Y', 'N')
                ,   SYSDATE
                ,   P_USER_ID
                ,   SYSDATE
                ,   P_USER_ID
           );
END COMMON_CODE_SAVE;

/
