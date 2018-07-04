--------------------------------------------------------
--  DDL for Procedure MARKETING_GP_COMBINE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."MARKETING_GP_COMBINE" 
(
  P_CUST_GP_IDS IN VARCHAR2,
  P_MY_USER_ID  IN VARCHAR2
, O_CUST_GP_ID OUT VARCHAR2 
) IS
        L_COLUMN      VARCHAR2(1)     := CHR(29);
        L_COMP_CD     VARCHAR2(3);
        L_BRAND_CD    VARCHAR2(4);
        L_CUST_GP_NM  VARCHAR2(100);
BEGIN
        SELECT  SQ_CUST_GP_ID.NEXTVAL
        INTO    O_CUST_GP_ID
        FROM    DUAL;
        
        SELECT  SUBSTR(XMLAGG(XMLELEMENT(A, ',' || CUST_GP_NM) ORDER BY CUST_GP_NM).EXTRACT('//text()'), 2)
        INTO    L_CUST_GP_NM
        FROM    MARKETING_GP
        WHERE   CUST_GP_ID IN (
                                      SELECT  TRIM(REGEXP_SUBSTR(DATA, '[^' || L_COLUMN || ']+', 1, LEVEL))
                                      FROM    (SELECT P_CUST_GP_IDS AS DATA FROM DUAL)
                                      CONNECT BY  INSTR(DATA, L_COLUMN, 1, LEVEL - 1) > 0
        );
        
        SELECT  COMP_CD,
                BRAND_CD
        INTO    L_COMP_CD,
                L_BRAND_CD
        FROM    MARKETING_GP
        WHERE   CUST_GP_ID IN (
                                      SELECT  TRIM(REGEXP_SUBSTR(DATA, '[^' || L_COLUMN || ']+', 1, LEVEL))
                                      FROM    (SELECT P_CUST_GP_IDS AS DATA FROM DUAL)
                                      CONNECT BY  INSTR(DATA, L_COLUMN, 1, LEVEL - 1) > 0
        )
        AND     ROWNUM = 1;
        
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
                '병합 - ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD'),
                'N',
                'Y',
                L_CUST_GP_NM || ' - 병합',
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
        WHERE   CUST_GP_ID    IN  (
                                      SELECT  TRIM(REGEXP_SUBSTR(DATA, '[^' || L_COLUMN || ']+', 1, LEVEL))
                                      FROM    (SELECT P_CUST_GP_IDS AS DATA FROM DUAL)
                                      CONNECT BY  INSTR(DATA, L_COLUMN, 1, LEVEL - 1) > 0
        );
        
END MARKETING_GP_COMBINE;

/
