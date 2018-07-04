--------------------------------------------------------
--  DDL for Procedure CD_COMMON_CODE_GROUP_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."CD_COMMON_CODE_GROUP_SELECT" (
        O_CURSOR      OUT   SYS_REFCURSOR
) AS 
BEGIN
        OPEN    O_CURSOR  FOR
        SELECT  GROUP_CODE,
                GROUP_NAME,
                REMARK
        FROM    CD_COMMON_GROUP
        ORDER   BY SORT; 
END CD_COMMON_CODE_GROUP_SELECT;

/
