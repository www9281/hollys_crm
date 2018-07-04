--------------------------------------------------------
--  DDL for Procedure MARKETING_GP_SAVE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."MARKETING_GP_SAVE" 
(
  N_COMP_CD IN VARCHAR2 
, P_BRAND_CD IN VARCHAR2 
, N_CUST_GP_ID IN VARCHAR2 
, P_CUST_GP_NM IN VARCHAR2 
, P_USE_YN IN VARCHAR2 
, N_NOTES IN VARCHAR2 
, P_MY_USER_ID IN VARCHAR2
, P_SEARCH IN VARCHAR2
, N_OTHERS IN VARCHAR2
, O_CUST_GP_ID OUT VARCHAR2
) IS 
    L_ROW               VARCHAR2(1)     := CHR(28);
    L_COLUMN            VARCHAR2(1)     := CHR(29); 
    SQL_CUST            VARCHAR2(20000);
BEGIN
    IF  N_CUST_GP_ID IS NULL OR N_CUST_GP_ID = '' THEN
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
        )       VALUES                (
                N_COMP_CD,
                P_BRAND_CD,
                O_CUST_GP_ID,
                P_CUST_GP_NM,
                'N',
                P_USE_YN,
                N_NOTES,
                P_MY_USER_ID,
                SYSDATE,
                NULL,
                NULL
        );
    ELSE
        UPDATE  MARKETING_GP
        SET     BRAND_CD    = P_BRAND_CD,
                CUST_GP_NM  = P_CUST_GP_NM,
                USE_YN      = P_USE_YN,
                NOTES       = N_NOTES,
                UPD_USER    = P_MY_USER_ID,
                UPD_DT      = SYSDATE
        WHERE   CUST_GP_ID  = N_CUST_GP_ID;
        
        DELETE  
        FROM    MARKETING_GP_SEARCH
        WHERE   CUST_GP_ID  = N_CUST_GP_ID;
        
        DELETE  
        FROM    MARKETING_GP_CUST
        WHERE   CUST_GP_ID  = N_CUST_GP_ID;
        
        O_CUST_GP_ID := N_CUST_GP_ID;
    END IF;
    
    INSERT  INTO  MARKETING_GP_SEARCH       (
            SEARCH_ID,
            CUST_GP_ID,
            COLUMN_TYPE,
            SEARCH_TYPE,
            SEARCH_VALUE
    )
    SELECT  SQ_SEARCH_ID.NEXTVAL AS SEARCH_ID,
            O_CUST_GP_ID,
            TRIM(REGEXP_SUBSTR(D, '[^' || L_COLUMN || ']+', 1, 1)) AS COLUMN_TYPE,
            TRIM(REGEXP_SUBSTR(D, '[^' || L_COLUMN || ']+', 1, 2)) AS SEARCH_TYPE,
            TRIM(REGEXP_SUBSTR(D, '[^' || L_COLUMN || ']+', 1, 3)) AS SEARCH_VALUE
    FROM    (
                SELECT  TRIM(REGEXP_SUBSTR(DATA, '[^' || L_ROW || ']+', 1, LEVEL)) AS D
                FROM    (SELECT P_SEARCH AS DATA FROM DUAL)
                CONNECT BY  INSTR(DATA, L_ROW, 1, LEVEL - 1) > 0
            );
    
    SQL_CUST  :=  ' INSERT  INTO  MARKETING_GP_CUST   (
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
                  ' || GET_CUST_WHERE(P_SEARCH);
                  
    EXECUTE IMMEDIATE SQL_CUST
    USING   O_CUST_GP_ID;
    
    IF      N_OTHERS IS NOT NULL AND N_OTHERS != '' THEN
            INSERT  INTO  MARKETING_GP_CUST   (
                    CUST_GP_ID,
                    CUST_ID,
                    APPEND_YN
            )
            SELECT  O_CUST_GP_ID,
                    TRIM(REGEXP_SUBSTR(DATA, '[^' || L_COLUMN || ']+', 1, LEVEL)) AS CUST_ID,
                    'Y'
            FROM    (SELECT N_OTHERS AS DATA FROM DUAL)
            CONNECT BY  INSTR(DATA, L_COLUMN, 1, LEVEL - 1) > 0;
    END     IF;
END MARKETING_GP_SAVE;

/
