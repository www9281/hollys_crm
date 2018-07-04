--------------------------------------------------------
--  DDL for Procedure SP_SYNC_TSMS_PCRM2
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_SYNC_TSMS_PCRM2" 
(
    PSV_TBL_DIV IN VARCHAR2
)
IS
    CURSOR CUR_1 IS
        SELECT  TBL_ID
              , TBL_NM
              , SYNC_DIV
              , COMP_COL1
              , CASE WHEN SYNC_DIV = 'L' AND LENGTHB(COMP_VAL1) = 8 THEN TO_CHAR(TO_DATE(COMP_VAL1,'YYYYMMDD')-1,'YYYYMMDD') ELSE COMP_VAL1 END COMP_VAL1
              , COMP_COL2
              , COMP_VAL2
              , COMP_COL3
              , COMP_VAL3
              , IDX_ID
        FROM    SYNC_TBL_LST STL
        WHERE   USE_YN   = 'Y'
        AND     SYNC_DIV = PSV_TBL_DIV 
        ORDER BY 
                SEQNO;
    
    CURSOR CUR_2(vTBLNAME IN VARCHAR2, vIDXNAME IN VARCHAR2) IS
        SELECT  C.TNAME
              , C.CNAME
              , C.COLNO
              , COLUMN_LENGTH
              , V.INDEX_NAME
              , V.COLUMN_POSITION    AS     CPOS
              , MAX(COLNO)           OVER() COLCNT
              , MAX(COLUMN_POSITION) OVER() IDXCNT
        FROM    COL C,
               (
                SELECT  UIC.TABLE_NAME
                      , UIC.COLUMN_NAME
                      , UIC.COLUMN_LENGTH
                      , UIC.INDEX_NAME
                      , COLUMN_POSITION
                FROM    USER_INDEXES     UIS
                      , USER_IND_COLUMNS UIC
                WHERE   UIS.INDEX_NAME = UIC.INDEX_NAME
                AND     UIS.TABLE_NAME = vTBLNAME
                AND     UIS.INDEX_NAME = vIDXNAME
               ) V
        WHERE   C.TNAME = V.TABLE_NAME (+)
        AND     C.CNAME = V.COLUMN_NAME(+)
        AND     C.TNAME = vTBLNAME
        ORDER BY 
                C.COLNO;
    
    TYPE U_CURSOR IS REF CURSOR;
    
    C_CUR           U_CURSOR;
    vSQLTXT1        VARCHAR2(32767) := NULL;
    vSQLTXT2        VARCHAR2(32767) := NULL;
    vSQLTXT3        VARCHAR2(32767) := NULL;
    vSQLTXT4        VARCHAR2(32767) := NULL;
    vIDXTXT1        VARCHAR2(32767) := NULL;
    vMIN_SALE_DT    VARCHAR2(8)     := NULL;
    vSCH_KEY_LEN    NUMBER          := 0;
    vSYSDATETIME    VARCHAR2(20)    := NULL;
BEGIN
    /**********************************************************************
    *** 순서가 중요함 T -> A -> M 순                                    ***
    ***********************************************************************/
    vSYSDATETIME := FN_GET_SYSDATE@TSMS;
    
    FOR MYREC1 IN CUR_1 LOOP
        -- 변수 초기화
        vSQLTXT1 := NULL; vSQLTXT2 := NULL;
        vSQLTXT3 := NULL; vSQLTXT4 := NULL;
        vIDXTXT1 := NULL;
        
        DBMS_OUTPUT.PUT_LINE('1'||MYREC1.TBL_ID);
        
        IF MYREC1.SYNC_DIV = 'T' THEN
            vSQLTXT1 := 'TRUNCATE TABLE '||MYREC1.TBL_ID;
            
            EXECUTE IMMEDIATE vSQLTXT1;
            
            vSQLTXT1 := 'INSERT INTO PCRM.'||MYREC1.TBL_ID||
                        '    SELECT * FROM '||MYREC1.TBL_ID||'@TSMS';
            
            --DBMS_OUTPUT.PUT_LINE('1'||vSQLTXT1);
            EXECUTE IMMEDIATE vSQLTXT1;
        END IF;
        
        -- 테이블 컬럼 취득
        IF MYREC1.SYNC_DIV != 'T' THEN
            FOR MYREC2 IN CUR_2(MYREC1.TBL_ID, MYREC1.IDX_ID) LOOP
                IF MYREC2.COLNO = 1 THEN
                    vSQLTXT2 := MYREC2.CNAME;
                ELSE 
                    vSQLTXT2 := vSQLTXT2 || ' , ' || MYREC2.CNAME;
                END IF;
                    
                IF MYREC2.CPOS IS NOT NULL THEN
                    IF vIDXTXT1 IS NULL THEN
                        vIDXTXT1 := 'LOC.'||MYREC2.CNAME||' = RMT.'||MYREC2.CNAME;
                    ELSE
                        vIDXTXT1 := vIDXTXT1||' AND '||'LOC.'||MYREC2.CNAME||' = RMT.'||MYREC2.CNAME;
                    END IF;
                END IF;
                    
                IF MYREC2.COLNO = MYREC2.COLCNT THEN
                    vSQLTXT4 := vSQLTXT4||'RMT.'||MYREC2.CNAME;
                ELSE    
                    vSQLTXT4 := vSQLTXT4||'RMT.'||MYREC2.CNAME||',';
                END IF;
                    
                --SET 절
                IF MYREC2.CPOS IS NULL THEN
                    IF MYREC2.COLNO = MYREC2.COLCNT THEN
                        vSQLTXT3 := vSQLTXT3 ||' LOC.'||MYREC2.CNAME||' = RMT.'||MYREC2.CNAME; 
                    ELSE
                        vSQLTXT3 := vSQLTXT3 ||' LOC.'||MYREC2.CNAME||' = RMT.'||MYREC2.CNAME||', ';
                    END IF;
                END IF;
                    
                -- 조회대상 키 길이 취득 
                IF MYREC1.COMP_COL1 = MYREC2.CNAME THEN
                    vSCH_KEY_LEN := MYREC2.COLUMN_LENGTH;
                END IF;
            END LOOP;
        END IF;
        
        IF vSCH_KEY_LEN IS NULL THEN
            vSCH_KEY_LEN := LENGTH(MYREC1.COMP_VAL1);
        END IF;
        
        /* SALE_HD, SALE_DT, SALE_ST 대상 그외는 소스수정 */    
        IF MYREC1.SYNC_DIV = 'A' THEN
            vSQLTXT1 := 'MERGE INTO PCRM.'||MYREC1.TBL_ID||' LOC '||
                        '   USING  ('||
                        '           SELECT '||vSQLTXT2 ||
                        '           FROM   '||MYREC1.TBL_ID||'@TSMS'||
                        '           WHERE  '||MYREC1.COMP_COL1||' >= TO_DATE('''||MYREC1.COMP_VAL1||''', ''YYYYMMDDHH24MISS'')' ||
                        '           AND    '||MYREC1.COMP_COL1||' <  TO_DATE('''||vSYSDATETIME    ||''', ''YYYYMMDDHH24MISS'')';
            vSQLTXT1 := vSQLTXT1 ||
                        '          ) RMT '||
                        '   ON     ( '    ||
                                        vIDXTXT1||
                        '          )  '   ||                             
                        '   WHEN NOT MATCHED THEN ' ||
                        '       INSERT ( '||vSQLTXT2||')'||
                        '           VALUES('||vSQLTXT4||')';
            
            DBMS_OUTPUT.PUT_LINE('2-1'||vSQLTXT1);
            EXECUTE IMMEDIATE vSQLTXT1;
            
            -- 최종 전송시각 UPDATE
            vSQLTXT1 := '   UPDATE  SYNC_TBL_LST '||
                        '   SET     COMP_VAL1 = '''||vSYSDATETIME ||''''||
                        '   WHERE   TBL_ID    = '''||MYREC1.TBL_ID||'''';
            
            DBMS_OUTPUT.PUT_LINE('2-2'||vSQLTXT1);
                
            EXECUTE IMMEDIATE vSQLTXT1;
        END IF;
        
        /* 통계자료 테이블 */
        IF MYREC1.SYNC_DIV = 'M' THEN
            vSQLTXT1 := 'MERGE INTO PCRM.'||MYREC1.TBL_ID||' LOC '||
                        '   USING  ('||
                        '           SELECT '||vSQLTXT2 ||
                        '           FROM   '||MYREC1.TBL_ID||'@TSMS'||
                        '           WHERE  '||MYREC1.COMP_COL1||' >= SUBSTR('''||MYREC1.COMP_VAL1||''', 1,'||vSCH_KEY_LEN||')';
            IF vSCH_KEY_LEN = 8 THEN
                vSQLTXT1 := vSQLTXT1 ||            
                        '           AND    '||MYREC1.COMP_COL1||' <= TO_CHAR(SYSDATE, ''YYYYMMDD'')';
            ELSE
                vSQLTXT1 := vSQLTXT1 ||             
                        '           AND    '||MYREC1.COMP_COL1||' <= TO_CHAR(SYSDATE, ''YYYYMM'')';
            END IF;
            
            vSQLTXT1 := vSQLTXT1 ||
                        '          ) RMT '||
                        '   ON     ( '    ||
                                        vIDXTXT1||
                        '          )  '   ||                             
                        '   WHEN  MATCHED THEN '||
                        '       UPDATE  ' ||
                        '           SET ' ||vSQLTXT3||
                        '   WHEN NOT MATCHED THEN ' ||
                        '       INSERT ( '||vSQLTXT2||')'||
                        '           VALUES('||vSQLTXT4||')';
            
            DBMS_OUTPUT.PUT_LINE('3-1'||vSQLTXT1);
            EXECUTE IMMEDIATE vSQLTXT1;
            
            -- 최종 전송시각 UPDATE
            vSQLTXT1 := '   UPDATE  PCRM.SYNC_TBL_LST '||
                        '   SET     COMP_VAL1 = TO_CHAR(SYSDATE, ''YYYYMMDD'')'||
                        '   WHERE   TBL_ID    = '''||MYREC1.TBL_ID||'''';
            
            DBMS_OUTPUT.PUT_LINE('3-2'||vSQLTXT1);
                
            EXECUTE IMMEDIATE vSQLTXT1;
        END IF;
        
        /* LOG 테이블 */
        IF MYREC1.SYNC_DIV = 'L' THEN
            vSQLTXT1 := 'MERGE INTO PCRM.'||MYREC1.TBL_ID||' LOC '||
                        '   USING  ('||
                        '           SELECT '||vSQLTXT2 ||
                        '           FROM   '||MYREC1.TBL_ID||'@TSMS'||
                        '           WHERE  '||MYREC1.COMP_COL1||' >= SUBSTR('''||MYREC1.COMP_VAL1||''', 1,'||vSCH_KEY_LEN||')';
            IF vSCH_KEY_LEN = 8 THEN
                vSQLTXT1 := vSQLTXT1 ||            
                        '           AND    '||MYREC1.COMP_COL1||' <= TO_CHAR(SYSDATE, ''YYYYMMDD'')';
            ELSE
                vSQLTXT1 := vSQLTXT1 ||             
                        '           AND    '||MYREC1.COMP_COL1||' <= TO_CHAR(SYSDATE, ''YYYYMM'')';
            END IF;
            
            IF MYREC1.COMP_COL2 IS NOT NULL THEN
                vSQLTXT1 := vSQLTXT1 ||            
                        '           AND    '||MYREC1.COMP_COL2||' = '''||MYREC1.COMP_VAL2||'''';
            END IF;
            
            IF MYREC1.COMP_COL3 IS NOT NULL THEN
                vSQLTXT1 := vSQLTXT1 ||            
                        '           AND    '||MYREC1.COMP_COL3||' = '''||MYREC1.COMP_VAL3||'''';
            END IF;
            
            vSQLTXT1 := vSQLTXT1 ||
                        '          ) RMT '||
                        '   ON     ( '    ||
                                        vIDXTXT1||
                        '          )  '   ||                             
                        '   WHEN NOT MATCHED THEN ' ||
                        '       INSERT ( '||vSQLTXT2||')'||
                        '           VALUES('||vSQLTXT4||')';
            
            DBMS_OUTPUT.PUT_LINE('4-1'||vSQLTXT1);
            EXECUTE IMMEDIATE vSQLTXT1;
            
            -- 최종 전송시각 UPDATE
            vSQLTXT1 := '   UPDATE  PCRM.SYNC_TBL_LST '||
                        '   SET     COMP_VAL1 = TO_CHAR(SYSDATE, ''YYYYMMDD'')'||
                        '   WHERE   TBL_ID    = '''||MYREC1.TBL_ID||'''';
            
            DBMS_OUTPUT.PUT_LINE('4-2'||vSQLTXT1);
                
            EXECUTE IMMEDIATE vSQLTXT1;
        END IF;
        
        -- 테이블 단위 COMMIT
        COMMIT; 
    END LOOP;
    
    --vRTNMSG := '0:OK';
    DBMS_OUTPUT.PUT_LINE('98'||'0:OK');
    RETURN;
EXCEPTION
    WHEN OTHERS THEN
        --vRTNMSG := SQLERRM;
        DBMS_OUTPUT.PUT_LINE('99'||SQLERRM);
        ROLLBACK;
        RETURN;
END;

/
