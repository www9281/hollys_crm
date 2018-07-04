--------------------------------------------------------
--  DDL for Procedure CD_COMMON_CODE_INSERT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."CD_COMMON_CODE_INSERT" (
        P_GROUP_CODE	  IN  CHAR,
        P_CODE          IN  VARCHAR2,
        P_CODE_NAME	    IN  VARCHAR2,
        P_SORT	        IN  NUMBER,
        P_REMARK	      IN  VARCHAR2,
        P_IS_USE	      IN  CHAR,
        P_MY_USER_ID	  IN  VARCHAR2
) AS 
BEGIN
      INSERT    INTO    CD_COMMON_CODE (
                GROUP_CODE,
                CODE,
                CODE_NAME,
                SORT,
                REMARK,
                IS_USE,
                CREATE_ID,
                CREATE_DATE,
                UPDATE_ID,
                UPDATE_DATE
      )         VALUES  (
                P_GROUP_CODE,
                P_CODE,
                P_CODE_NAME,
                P_SORT,
                P_REMARK,
                P_IS_USE,
                P_MY_USER_ID,
                SYSDATE,
                NULL,
                NULL
      );
END CD_COMMON_CODE_INSERT;

/
