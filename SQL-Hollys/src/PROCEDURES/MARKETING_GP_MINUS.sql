--------------------------------------------------------
--  DDL for Procedure MARKETING_GP_MINUS
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."MARKETING_GP_MINUS" 
(
  P_CUST_GP_ID IN VARCHAR2   
, P_CUST_GP_ID_MINUS IN VARCHAR2 
, P_MY_USER_ID  IN VARCHAR2
, O_CUST_GP_ID OUT VARCHAR2
) IS
        L_COLUMN      VARCHAR2(1)     := CHR(29);
        L_COMP_CD     VARCHAR2(3);
        L_BRAND_CD    VARCHAR2(4);
        L_CUST_GP_NM  VARCHAR2(100);
        L_CUST_GP_NM2  VARCHAR2(100);
BEGIN
  SELECT  SQ_CUST_GP_ID.NEXTVAL
        INTO    O_CUST_GP_ID
        FROM    DUAL;
        
        SELECT  SUBSTR(XMLAGG(XMLELEMENT(A, ',' || CUST_GP_NM) ORDER BY CUST_GP_NM).EXTRACT('//text()'), 2)
        INTO    L_CUST_GP_NM2
        FROM    MARKETING_GP
        WHERE   CUST_GP_ID IN (
                                      SELECT  TRIM(REGEXP_SUBSTR(DATA, '[^' || L_COLUMN || ']+', 1, LEVEL))
                                      FROM    (SELECT P_CUST_GP_ID_MINUS AS DATA FROM DUAL)
                                      CONNECT BY  INSTR(DATA, L_COLUMN, 1, LEVEL - 1) > 0
        );
        
        SELECT  COMP_CD,
                BRAND_CD,
                CUST_GP_NM
        INTO    L_COMP_CD,
                L_BRAND_CD,
                L_CUST_GP_NM
        FROM    MARKETING_GP
        WHERE   CUST_GP_ID = P_CUST_GP_ID;
        
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
        )       VALUES                (
                L_COMP_CD,
                L_BRAND_CD,
                O_CUST_GP_ID,
                L_CUST_GP_NM || ' - 제거',
                'N',
                'Y',
                L_CUST_GP_NM || '에서 ' || L_CUST_GP_NM || '그룹을 제거',
                P_MY_USER_ID,
                SYSDATE,
                NULL,
                NULL
        );
        
        INSERT  INTO  MARKETING_GP_CUST   (
                CUST_GP_ID,
                CUST_ID,
                APPEND_YN
        )
        SELECT  O_CUST_GP_ID,
                CUST_ID,
                'N' AS APPEND_YN
        FROM    MARKETING_GP_CUST
        WHERE   CUST_GP_ID = P_CUST_GP_ID
        AND     CUST_ID NOT IN  (
                                        SELECT  CUST_ID
                                        FROM    MARKETING_GP_CUST
                                        WHERE   CUST_GP_ID IN (
                                                                      SELECT  TRIM(REGEXP_SUBSTR(DATA, '[^' || L_COLUMN || ']+', 1, LEVEL))
                                                                      FROM    (SELECT P_CUST_GP_ID_MINUS AS DATA FROM DUAL)
                                                                      CONNECT BY  INSTR(DATA, L_COLUMN, 1, LEVEL - 1) > 0
                                        )
        );
        
END MARKETING_GP_MINUS;

/
