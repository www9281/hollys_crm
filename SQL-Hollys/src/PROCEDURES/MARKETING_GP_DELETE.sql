--------------------------------------------------------
--  DDL for Procedure MARKETING_GP_DELETE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."MARKETING_GP_DELETE" 
(
  P_CUST_GP_ID IN VARCHAR2 
) AS 
BEGIN
        DELETE
        FROM    MARKETING_GP_CUST
        WHERE   CUST_GP_ID = P_CUST_GP_ID;
        
        DELETE
        FROM    MARKETING_GP_SEARCH
        WHERE   CUST_GP_ID = P_CUST_GP_ID;
        
        DELETE
        FROM    MARKETING_GP
        WHERE   CUST_GP_ID = P_CUST_GP_ID;
        
END MARKETING_GP_DELETE;

/
