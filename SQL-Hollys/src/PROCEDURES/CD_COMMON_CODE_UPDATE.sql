--------------------------------------------------------
--  DDL for Procedure CD_COMMON_CODE_UPDATE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."CD_COMMON_CODE_UPDATE" (
        P_GROUP_CODE	  IN  CHAR,
        P_CODE      	  IN  CHAR,
        P_CODE_NAME 	  IN  VARCHAR2,
        P_SORT	        IN  NUMBER,
        P_REMARK	      IN  VARCHAR2,
        P_IS_USE	      IN  CHAR,
        P_MY_USER_ID	  IN  VARCHAR2
) AS 
BEGIN
      UPDATE    CD_COMMON_CODE
      SET       CODE_NAME       = P_CODE_NAME,
                SORT            = P_SORT,
                REMARK          = P_REMARK,
                IS_USE          = P_IS_USE,
                UPDATE_ID       = P_MY_USER_ID,
                UPDATE_DATE     = SYSDATE
      WHERE     GROUP_CODE      = P_GROUP_CODE
        AND     CODE            = P_CODE;
END CD_COMMON_CODE_UPDATE;

/
