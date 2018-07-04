--------------------------------------------------------
--  DDL for Procedure COMMON_GROUP_LANG_SAVE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."COMMON_GROUP_LANG_SAVE" (
        P_CODE_TP    IN    VARCHAR2,
        P_CODE_CD    IN    VARCHAR2,
        P_CODE_NM    IN    VARCHAR2,
        P_LANG_TP    IN    VARCHAR2,
        P_USE_YN     IN    CHAR,
        P_USER_ID    IN    VARCHAR2
) AS 
BEGIN
        MERGE INTO LANG_COMMON
        USING DUAL
        ON (
                    CODE_TP     = P_CODE_TP
              AND   CODE_CD     = P_CODE_CD
              AND   LANGUAGE_TP = P_LANG_TP
           )
        WHEN MATCHED THEN
           UPDATE 
              SET   CODE_NM     = P_CODE_NM
                ,   USE_YN      = DECODE(P_USE_YN, 'Y', 'Y', 'N')
                ,   UPD_DT      = SYSDATE
                ,   UPD_USER    = P_USER_ID
        WHEN NOT MATCHED THEN
           INSERT 
           (        CODE_TP
                ,   CODE_CD
                ,   LANGUAGE_TP
                ,   CODE_NM
                ,   USE_YN
                ,   INST_DT
                ,   INST_USER
                ,   UPD_DT
                ,   UPD_USER
           ) VALUES (   
                    P_CODE_TP
                ,   P_CODE_CD
                ,   P_LANG_TP
                ,   P_CODE_NM
                ,   DECODE(P_USE_YN, 'Y', 'Y', 'N')
                ,   SYSDATE
                ,   P_USER_ID
                ,   SYSDATE
                ,   P_USER_ID
           );
END COMMON_GROUP_LANG_SAVE;

/
