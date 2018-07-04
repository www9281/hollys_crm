--------------------------------------------------------
--  DDL for Procedure MARKETING_GP_VIEW
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."MARKETING_GP_VIEW" 
(
        P_CUST_GP_ID    IN  VARCHAR2,
        O_BRAND_CD      OUT VARCHAR2,
        O_CUST_GP_NM    OUT VARCHAR2,
        O_SMS_SEND_YN   OUT VARCHAR2,
        O_USE_YN        OUT VARCHAR2,
        O_NOTES         OUT VARCHAR2,
        O_INST_USER     OUT VARCHAR2,
        O_INST_DT       OUT VARCHAR2,
        O_UPD_USER      OUT VARCHAR2,
        O_UPD_DT        OUT VARCHAR2,
        O_CUST_QTY      OUT VARCHAR2,
        O_CURSOR_0      OUT SYS_REFCURSOR,
        O_CURSOR_1      OUT SYS_REFCURSOR,
        O_CURSOR_2      OUT SYS_REFCURSOR
) IS
        SQL_TEMP            VARCHAR2(20000) := '';
        CURSOR_COLUMN_TYPE  VARCHAR2(20);
        CURSOR_SEARCH_TYPE  VARCHAR2(10);
        CURSOR_SEARCH_VALUE VARCHAR2(2000);
BEGIN   
        SELECT  BRAND_CD,
                CUST_GP_NM,
                SMS_SEND_YN,
                USE_YN,
                NOTES,
                INST_USER,
                TO_CHAR(INST_DT, 'YYYY-MM-DD') AS INST_DT,
                UPD_USER,
                TO_CHAR(UPD_DT, 'YYYY-MM-DD') AS UPD_DT,
                (
                    SELECT  COUNT(*)
                    FROM    MARKETING_GP_CUST
                    WHERE   CUST_GP_ID = MARKETING_GP.CUST_GP_ID
                ) AS CUST_QTY
        INTO    O_BRAND_CD,
                O_CUST_GP_NM,
                O_SMS_SEND_YN,
                O_USE_YN,
                O_NOTES,
                O_INST_USER,
                O_INST_DT,
                O_UPD_USER,
                O_UPD_DT,
                O_CUST_QTY
        FROM    MARKETING_GP
        WHERE   CUST_GP_ID = P_CUST_GP_ID;
        
        DECLARE CURSOR  CURSOR_SEARCH IS
        SELECT  COLUMN_TYPE,
                SEARCH_TYPE,
                SEARCH_VALUE
        FROM    MARKETING_GP_SEARCH
        WHERE   CUST_GP_ID = P_CUST_GP_ID;
        
        BEGIN
                OPEN    CURSOR_SEARCH;
                
                LOOP
                        FETCH CURSOR_SEARCH
                        INTO  CURSOR_COLUMN_TYPE,
                              CURSOR_SEARCH_TYPE,
                              CURSOR_SEARCH_VALUE;
                        EXIT  WHEN  CURSOR_SEARCH%NOTFOUND;
                        
                        IF    CURSOR_COLUMN_TYPE IN ('STOR_CD', 'ORDER_STOR_CD')  THEN
                              SELECT  SUBSTR(XMLAGG(XMLELEMENT(A, ',' || STOR_CD || ':' || STOR_NM) ORDER BY STOR_CD || ':' || STOR_NM).EXTRACT('//text()'), 2)
                              INTO    CURSOR_SEARCH_VALUE
                              FROM    STORE
                              WHERE   STOR_CD IN (
                                                          SELECT  TRIM(REGEXP_SUBSTR(DATA, '[^' || ',' || ']+', 1, LEVEL))
                                                          FROM    (SELECT CURSOR_SEARCH_VALUE AS DATA FROM DUAL)
                                                          CONNECT BY  INSTR(DATA, ',', 1, LEVEL - 1) > 0
                                                  );
                        ELSIF CURSOR_COLUMN_TYPE = 'ITEM_CD'                      THEN
                              SELECT  SUBSTR(XMLAGG(XMLELEMENT(A, ',' || ITEM_CD || ':' || ITEM_NM) ORDER BY ITEM_CD || ':' || ITEM_NM).EXTRACT('//text()'), 2)
                              INTO    CURSOR_SEARCH_VALUE
                              FROM    ITEM
                              WHERE   ITEM_CD IN (
                                                          SELECT  TRIM(REGEXP_SUBSTR(DATA, '[^' || ',' || ']+', 1, LEVEL))
                                                          FROM    (SELECT CURSOR_SEARCH_VALUE AS DATA FROM DUAL)
                                                          CONNECT BY  INSTR(DATA, ',', 1, LEVEL - 1) > 0
                                                  );
                        END   IF;
                        
                        IF    LENGTH(SQL_TEMP) > 0  THEN
                              SQL_TEMP := SQL_TEMP || 'UNION ALL ';
                        END   IF;
                        
                        SQL_TEMP := SQL_TEMP || '
                        SELECT  ''' || CURSOR_COLUMN_TYPE || ''' AS COLUMN_TYPE,
                                ''' || CURSOR_SEARCH_TYPE || ''' AS SEARCH_TYPE,
                                ''' || CURSOR_SEARCH_VALUE || ''' AS SEARCH_VALUE
                        FROM    DUAL
                        ';
                END LOOP;
        END;
        
        IF      SQL_TEMP IS NULL OR SQL_TEMP = '' THEN
                SQL_TEMP := '
                SELECT  NULL AS COLUMN_TYPE,
                        NULL AS SEARCH_TYPE,
                        NULL AS SEARCH_VALUE
                FROM    DUAL
                WHERE   ROWNUM = 0';
        END     IF;
        
        OPEN    O_CURSOR_0  FOR SQL_TEMP;
        
        OPEN    O_CURSOR_1  FOR
        SELECT  B.CUST_ID,
                decrypt(B.CUST_NM) AS CUST_NM,
                FN_GET_FORMAT_HP_NO(decrypt(B.MOBILE)) AS MOBILE,
                C.LVL_NM
        FROM    MARKETING_GP_CUST A
        JOIN    C_CUST B
        ON      A.CUST_ID = B.CUST_ID
        LEFT OUTER JOIN C_CUST_LVL C
        ON      B.COMP_CD = C.COMP_CD 
        AND     B.LVL_CD = C.LVL_CD
        WHERE   A.CUST_GP_ID = P_CUST_GP_ID
        AND     A.APPEND_YN = 'N'
        AND     ROWNUM <= 1000;
        
        OPEN    O_CURSOR_2  FOR
        SELECT  B.CUST_ID,
                decrypt(B.CUST_NM) AS CUST_NM,
                FN_GET_FORMAT_HP_NO(decrypt(B.MOBILE)) AS MOBILE,
                C.LVL_NM
        FROM    MARKETING_GP_CUST A
        JOIN    C_CUST B
        ON      A.CUST_ID = B.CUST_ID
        LEFT OUTER JOIN C_CUST_LVL C
        ON      B.COMP_CD = C.COMP_CD
        AND     B.LVL_CD = C.LVL_CD
        WHERE   A.CUST_GP_ID = P_CUST_GP_ID
        AND     A.APPEND_YN = 'Y';
        
END MARKETING_GP_VIEW;

/
