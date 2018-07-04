--------------------------------------------------------
--  DDL for Procedure MARKETING_GP_RECAL
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."MARKETING_GP_RECAL" 
(
  P_CUST_GP_ID IN VARCHAR2 
, P_MY_USER_ID IN VARCHAR2 
, O_CUST_GP_ID OUT VARCHAR2 
) IS
        L_ROW               VARCHAR2(1)     := CHR(28);
        L_COLUMN            VARCHAR2(1)     := CHR(29);
        L_SEARCH            VARCHAR(20000);
        L_SQL               VARCHAR(20000);
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
                CUST_GP_NM || ' - 재계산 ' || TO_CHAR(INST_DT, 'YYYY-MM-DD'),
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
        
        SELECT  SUBSTR(XMLAGG(XMLELEMENT(A, L_ROW || DATA) ORDER BY DATA).EXTRACT('//text()'), 2)
        INTO    L_SEARCH
        FROM    (
                        SELECT  COLUMN_TYPE || L_COLUMN || SEARCH_TYPE || L_COLUMN || SEARCH_VALUE AS DATA
                        FROM    MARKETING_GP_SEARCH
                        WHERE   CUST_GP_ID = O_CUST_GP_ID
                );
        
        L_SQL  :=  'INSERT  INTO  MARKETING_GP_CUST   (
                            CUST_GP_ID,
                            CUST_ID,
                            APPEND_YN
                    )
                    SELECT  :1 AS CUST_GP_ID,
                            A.CUST_ID,
                            ''N''
                    FROM    C_CUST A
                    LEFT OUTER JOIN C_CUST_LVL B
                    ON      A.COMP_CD = B.COMP_CD
                    AND     A.LVL_CD = B.LVL_CD
                  ' || GET_CUST_WHERE(L_SEARCH);
                  
    EXECUTE IMMEDIATE L_SQL
    USING   O_CUST_GP_ID;
    
    INSERT  INTO  MARKETING_GP_CUST   (
            CUST_GP_ID,
            CUST_ID,
            APPEND_YN
    )
    SELECT  O_CUST_GP_ID,
            CUST_ID,
            'Y' AS APPEND_YN
    FROM    MARKETING_GP_CUST
    WHERE   CUST_GP_ID = P_CUST_GP_ID
    AND     APPEND_YN = 'Y'
    AND     CUST_ID NOT IN  (
                                    SELECT  CUST_ID
                                    FROM    MARKETING_GP_CUST
                                    WHERE   CUST_GP_ID = O_CUST_GP_ID
    );
    
END MARKETING_GP_RECAL;

/
