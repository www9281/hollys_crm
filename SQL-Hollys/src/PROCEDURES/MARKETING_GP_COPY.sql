--------------------------------------------------------
--  DDL for Procedure MARKETING_GP_COPY
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."MARKETING_GP_COPY" 
(
        P_CUST_GP_ID IN VARCHAR2,
        P_MY_USER_ID IN VARCHAR2,
        O_CUST_GP_ID OUT VARCHAR2
        
) AS 
BEGIN
        SELECT  SQ_CUST_GP_ID.NEXTVAL
        INTO    O_CUST_GP_ID
        FROM    DUAL;
        
        INSERT  INTO  MARKETING_GP    (
                COMP_CD,
                BRAND_CD,
                CUST_GP_ID,
                CUST_GP_NM,
                SMS_SEND_YN,
                USE_YN,
                NOTES,
                INST_USER,
                INST_DT,
                UPD_USER,
                UPD_DT
        )
        SELECT  COMP_CD,
                BRAND_CD,
                O_CUST_GP_ID,
                CUST_GP_NM || ' - 복사',
                SMS_SEND_YN,
                USE_YN,
                NOTES,
                P_MY_USER_ID AS INST_USER,
                SYSDATE,
                NULL,
                NULL
        FROM    MARKETING_GP
        WHERE   CUST_GP_ID = P_CUST_GP_ID;
        
        INSERT  INTO  MARKETING_GP_SEARCH       (
              SEARCH_ID,
              CUST_GP_ID,
              COLUMN_TYPE,
              SEARCH_TYPE,
              SEARCH_VALUE
        )
        SELECT  SQ_SEARCH_ID.NEXTVAL AS SEARCH_ID,
                O_CUST_GP_ID,
                COLUMN_TYPE,
                SEARCH_TYPE,
                SEARCH_VALUE
        FROM    MARKETING_GP_SEARCH
        WHERE   CUST_GP_ID = P_CUST_GP_ID;
        
        INSERT  INTO  MARKETING_GP_CUST   (
                CUST_GP_ID,
                CUST_ID,
                APPEND_YN
        )
        SELECT  O_CUST_GP_ID,
                CUST_ID,
                APPEND_YN
        FROM    MARKETING_GP_CUST
        WHERE   CUST_GP_ID = P_CUST_GP_ID;
        
END MARKETING_GP_COPY;

/
