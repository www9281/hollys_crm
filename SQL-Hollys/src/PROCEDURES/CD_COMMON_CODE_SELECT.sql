--------------------------------------------------------
--  DDL for Procedure CD_COMMON_CODE_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."CD_COMMON_CODE_SELECT" (
        P_GROUP_CODE  IN   CD_COMMON_CODE.GROUP_CODE%TYPE,
        O_CURSOR      OUT   SYS_REFCURSOR
) AS 
BEGIN
        OPEN    O_CURSOR  FOR
        SELECT  GROUP_CODE 
                ,CODE
                ,CODE_NAME
                ,SORT
                ,REMARK
                ,IS_USE
                ,CREATE_ID
                ,TO_CHAR(CREATE_DATE, 'YYYY.MM.DD') AS CREATE_DATE
                ,UPDATE_ID
                ,TO_CHAR(UPDATE_DATE, 'YYYY.MM.DD') AS UPDATE_DATE
        FROM    CD_COMMON_CODE
        WHERE   GROUP_CODE = P_GROUP_CODE
        ORDER   BY SORT;
END CD_COMMON_CODE_SELECT;

/
