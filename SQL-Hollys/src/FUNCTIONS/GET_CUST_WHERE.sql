--------------------------------------------------------
--  DDL for Function GET_CUST_WHERE
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."GET_CUST_WHERE" 
(
    SEARCH IN VARCHAR2 
) RETURN VARCHAR2 IS 
    L_ROW               VARCHAR2(1)     := CHR(28);
    L_COLUMN            VARCHAR2(1)     := CHR(29);
    -- L_ROW               VARCHAR2(1)     := ';';
    -- L_COLUMN            VARCHAR2(1)     := ':';
    CUST_WHERE          VARCHAR2(32767) := 'WHERE A.USE_YN = ''Y'' ';    
    CURSOR_COLUMN_TYPE  VARCHAR2(20);
    CURSOR_SEARCH_TYPE  VARCHAR2(10);   -- 1:=, 2:!=, 3:IN, 4:NOT IN, 5:LIKE, 6:NOT LIKE, 7:>, 8:>= 9:<, 10<=
    CURSOR_SEARCH_VALUE VARCHAR2(200);
    ORDER_STOR_CD       VARCHAR(40);    -- 구매횟수를 구할 때 구매매장이 있을 경우 구매매장 조건을 추가
    SEARCH_TYPE         VARCHAR2(10);   -- 검색 기호
    IS_NUMERIC          VARCHAR2(1);    -- 숫자여부
BEGIN
    
    DECLARE CURSOR  CURSOR_SEARCH IS
    SELECT  TRIM(REGEXP_SUBSTR(D, '[^' || L_COLUMN || ']+', 1, 1)) AS COLUMN_TYPE,
            TRIM(REGEXP_SUBSTR(D, '[^' || L_COLUMN || ']+', 1, 2)) AS SEARCH_TYPE,
            TRIM(REGEXP_SUBSTR(D, '[^' || L_COLUMN || ']+', 1, 3)) AS SEARCH_VALUE
    FROM    (
                SELECT  TRIM(REGEXP_SUBSTR(DATA, '[^' || L_ROW || ']+', 1, LEVEL)) AS D
                FROM    (SELECT SEARCH AS DATA FROM DUAL)
                CONNECT BY  INSTR(DATA, L_ROW, 1, LEVEL - 1) > 0
            );
    
    BEGIN
        OPEN    CURSOR_SEARCH;
        
        LOOP
            FETCH CURSOR_SEARCH
            INTO  CURSOR_COLUMN_TYPE,
                  CURSOR_SEARCH_TYPE,
                  CURSOR_SEARCH_VALUE;
            EXIT  WHEN  CURSOR_SEARCH%NOTFOUND;
            
            SEARCH_TYPE := CASE   CURSOR_SEARCH_TYPE
                                  WHEN    '1'   THEN  '='
                                  WHEN    '2'   THEN  '!='
                                  WHEN    '3'   THEN  'IN'
                                  WHEN    '4'   THEN  'NOT IN'
                                  WHEN    '5'   THEN  'LIKE'
                                  WHEN    '6'   THEN  'NOT LIKE'
                                  WHEN    '7'   THEN  '>'
                                  WHEN    '8'   THEN  '>='
                                  WHEN    '9'   THEN  '<'
                                  WHEN    '10'  THEN  '<=' 
                                  ELSE    ''
                            END;
            
            IF    CURSOR_COLUMN_TYPE = 'ORDER_STOR_CD'  THEN        -- 구매매장
                  CUST_WHERE := CUST_WHERE || 'AND ';
                  IF  CURSOR_SEARCH_TYPE = '2' OR CURSOR_SEARCH_TYPE = '4'  THEN
                      CUST_WHERE := CUST_WHERE || 'NOT ';
                  ELSE
                      ORDER_STOR_CD := CURSOR_SEARCH_VALUE;
                  END IF;
                  CUST_WHERE := CUST_WHERE || 'EXISTS ( ';
                  CUST_WHERE := CUST_WHERE || 'SELECT 1 ';
                  CUST_WHERE := CUST_WHERE || 'FROM   C_CUST_DSS ';
                  CUST_WHERE := CUST_WHERE || 'WHERE  COMP_CD = A.COMP_CD ';
                  CUST_WHERE := CUST_WHERE || 'AND    CUST_ID = A.CUST_ID ';
                  CUST_WHERE := CUST_WHERE || 'AND    STOR_CD IN ('''|| REPLACE(CURSOR_SEARCH_VALUE, ',', ''',''') ||''') ';
                  CUST_WHERE := CUST_WHERE || ') ';
            ELSIF CURSOR_COLUMN_TYPE = 'ORDER_COUNT'  THEN    -- 구매횟수
                  CUST_WHERE := CUST_WHERE || 'AND  ( ';
                  CUST_WHERE := CUST_WHERE || 'SELECT SUM(BILL_CNT) ';
                  CUST_WHERE := CUST_WHERE || 'FROM   C_CUST_DSS ';
                  CUST_WHERE := CUST_WHERE || 'WHERE  COMP_CD = A.COMP_CD ';
                  CUST_WHERE := CUST_WHERE || 'AND    CUST_ID = A.CUST_ID ';
                  IF  ORDER_STOR_CD IS NOT NULL THEN                -- 구매매장 조건이 있을 경우 함께 적용
                      CUST_WHERE := CUST_WHERE || 'AND    STOR_CD IN ('''|| REPLACE(ORDER_STOR_CD, ',', ''',''') ||''') ';
                  END IF;
                  CUST_WHERE := CUST_WHERE || ') ';
                  CUST_WHERE := CUST_WHERE || SEARCH_TYPE || ' ';
                  IF  CURSOR_SEARCH_TYPE = '3' OR CURSOR_SEARCH_TYPE = '4'  THEN
                      CUST_WHERE := CUST_WHERE || '(' || CURSOR_SEARCH_VALUE || ') ';
                  ELSE
                      CUST_WHERE := CUST_WHERE || CURSOR_SEARCH_VALUE;
                  END IF;
                  
            ELSIF CURSOR_COLUMN_TYPE = 'ORDER_DT'  THEN    -- 구매일자
                  CUST_WHERE := CUST_WHERE || 'AND ';
                  IF  CURSOR_SEARCH_TYPE = '2' OR CURSOR_SEARCH_TYPE = '4'  THEN
                      CUST_WHERE := CUST_WHERE || 'NOT ';
                  END IF;
                  CUST_WHERE := CUST_WHERE || 'EXISTS ( ';
                  CUST_WHERE := CUST_WHERE || 'SELECT 1 ';
                  CUST_WHERE := CUST_WHERE || 'FROM   C_CUST_DSS ';
                  CUST_WHERE := CUST_WHERE || 'WHERE  COMP_CD = A.COMP_CD ';
                  CUST_WHERE := CUST_WHERE || 'AND    CUST_ID = A.CUST_ID ';
                  CUST_WHERE := CUST_WHERE || 'AND    SALE_DT IN ('''|| REPLACE(CURSOR_SEARCH_VALUE, '-', '') ||''') ';
                  CUST_WHERE := CUST_WHERE || ') ';
                  
            ELSIF CURSOR_COLUMN_TYPE = 'D_CLASS_CD'  THEN    -- 메뉴군 구매
                  CUST_WHERE := CUST_WHERE || 'AND ';
                  IF  CURSOR_SEARCH_TYPE = '2' OR CURSOR_SEARCH_TYPE = '4'  THEN
                      CUST_WHERE := CUST_WHERE || 'NOT ';
                  END IF;
                  CUST_WHERE := CUST_WHERE || 'EXISTS ( ';
                  CUST_WHERE := CUST_WHERE || 'SELECT 1 ';
                  CUST_WHERE := CUST_WHERE || 'FROM   C_CUST_MMS X ';
                  CUST_WHERE := CUST_WHERE || 'JOIN   ITEM Y ';
                  CUST_WHERE := CUST_WHERE || 'ON     X.COMP_CD = Y.COMP_CD ';
                  CUST_WHERE := CUST_WHERE || 'AND    X.ITEM_CD = Y.ITEM_CD ';
                  CUST_WHERE := CUST_WHERE || 'WHERE  X.COMP_CD = A.COMP_CD ';
                  CUST_WHERE := CUST_WHERE || 'AND    X.CUST_ID = A.CUST_ID ';
                  CUST_WHERE := CUST_WHERE || 'AND    Y.D_CLASS_CD IN ('''|| REPLACE(CURSOR_SEARCH_VALUE, ',', ''',''') ||''') ';
                  CUST_WHERE := CUST_WHERE || ') ';
            ELSIF CURSOR_COLUMN_TYPE = 'ITEM_CD'  THEN    -- 메뉴 구매
                  CUST_WHERE := CUST_WHERE || 'AND ';
                  IF  CURSOR_SEARCH_TYPE = '2' OR CURSOR_SEARCH_TYPE = '4'  THEN
                      CUST_WHERE := CUST_WHERE || 'NOT ';
                  END IF;
                  CUST_WHERE := CUST_WHERE || 'EXISTS ( ';
                  CUST_WHERE := CUST_WHERE || 'SELECT 1 ';
                  CUST_WHERE := CUST_WHERE || 'FROM   C_CUST_MMS ';
                  CUST_WHERE := CUST_WHERE || 'WHERE  COMP_CD = A.COMP_CD ';
                  CUST_WHERE := CUST_WHERE || 'AND    CUST_ID = A.CUST_ID ';
                  CUST_WHERE := CUST_WHERE || 'AND    ITEM_CD IN ('''|| REPLACE(CURSOR_SEARCH_VALUE, ',', ''',''') ||''') ';
                  CUST_WHERE := CUST_WHERE || ') ';
            ELSIF CURSOR_COLUMN_TYPE = 'PRMT_ID_COUPON' OR    -- 쿠폰사용고객
                  CURSOR_COLUMN_TYPE = 'PRMT_ID_EVENT' OR     -- 응모권이벤트 참여 고객
                  CURSOR_COLUMN_TYPE = 'PRMT_ID_CON' OR       -- 할리스콘 구매고객
                  CURSOR_COLUMN_TYPE = 'PRMT_ID_GIFT' OR      -- 기프트카드 충전 고객
                  CURSOR_COLUMN_TYPE = 'PRMT_ID_RCH' OR       -- 설문조사 완료자
                  CURSOR_COLUMN_TYPE = 'PRMT_ID_FRQ' OR       -- 프리퀀시 완료자
                  CURSOR_COLUMN_TYPE = 'PRMT_ID_LSM'          -- LSM 이벤트 참여 고객
            THEN
                  CUST_WHERE := CUST_WHERE || 'AND ';
                  IF  CURSOR_SEARCH_TYPE = '2' OR CURSOR_SEARCH_TYPE = '4'  THEN
                      CUST_WHERE := CUST_WHERE || 'NOT ';
                  END IF;
                  CUST_WHERE := CUST_WHERE || 'EXISTS ( ';
                  CUST_WHERE := CUST_WHERE || 'SELECT 1 ';
                  CUST_WHERE := CUST_WHERE || 'FROM   PROMOTION_COUPON_PUBLISH X ';
                  CUST_WHERE := CUST_WHERE || 'JOIN   PROMOTION_COUPON Y ';
                  CUST_WHERE := CUST_WHERE || 'ON     X.PUBLISH_ID = Y.PUBLISH_ID ';
                  CUST_WHERE := CUST_WHERE || 'WHERE  Y.CUST_ID = A.CUST_ID ';
                  CUST_WHERE := CUST_WHERE || 'AND    Y.COUPON_STATE = ''P0301'' ';
                  CUST_WHERE := CUST_WHERE || 'AND    X.PRMT_ID IN ('''|| REPLACE(CURSOR_SEARCH_VALUE, ',', ''',''') ||''') ';
                  CUST_WHERE := CUST_WHERE || ') ';
            ELSIF CURSOR_COLUMN_TYPE = 'PRMT_ID_DC'  THEN     -- 프로모션 할인 고객 - 아직 데이터 마이그레이션이 안되서 처리 안됨
                  CUST_WHERE := CUST_WHERE || 'AND 1=1';
            ELSE                                              -- 나머지는 C_CUST자체 필드 임
                  IF    CURSOR_COLUMN_TYPE IN ('SAV_MLG', 'LOS_MLG', 'SAV_PT', 'USE_PT', 'LOS_PT', 'SAV_CASH', 'USE_CASH')  THEN
                        IS_NUMERIC  :=  '1';
                  ELSE  IS_NUMERIC  :=  '0';
                  END   IF;
                  CUST_WHERE := CUST_WHERE || 'AND ';
                  IF    CURSOR_COLUMN_TYPE IN ('CUST_NM', 'MOBILE', 'ISSUE_MOBILE') THEN      -- 복호화가 필요한 필드
                        CUST_WHERE := CUST_WHERE || 'decrypt(A.' || CURSOR_COLUMN_TYPE || ') ';
                        
                  ELSIF CURSOR_COLUMN_TYPE = 'BIRTH_DT' THEN
                          SEARCH_TYPE := 'LIKE';
                          CURSOR_SEARCH_TYPE := '5';
                          --CUST_WHERE := CUST_WHERE || 'LIKE ';
                          CUST_WHERE := CUST_WHERE || 'A.' || CURSOR_COLUMN_TYPE || ' ';
                  ELSE
                        CUST_WHERE := CUST_WHERE || 'A.' || CURSOR_COLUMN_TYPE || ' ';
                  END   IF;
                
                  CUST_WHERE := CUST_WHERE || SEARCH_TYPE || ' ';
                  
                  IF    CURSOR_SEARCH_TYPE IN ('5', '6')  THEN                                -- LIKE, NOT LIKE
                        CUST_WHERE := CUST_WHERE || '''%' || CURSOR_SEARCH_VALUE || '%''' || ' ';
                  ELSIF CURSOR_SEARCH_TYPE IN ('3', '4')  THEN                                -- IN, NOT IN
                        IF    IS_NUMERIC = '1'  THEN
                              CUST_WHERE := CUST_WHERE || '(' || CURSOR_SEARCH_VALUE || ')' || ' ';
                        ELSE  
                              CUST_WHERE := CUST_WHERE || '('''|| REPLACE(CURSOR_SEARCH_VALUE, ',', ''',''') ||''') ';
                        END   IF;
                  ELSE  
          
                        IF    IS_NUMERIC = '1'  THEN
                              CUST_WHERE := CUST_WHERE || CURSOR_SEARCH_VALUE || ' ';
                        ELSE  
                              CUST_WHERE := CUST_WHERE || '''' || CURSOR_SEARCH_VALUE || ''' ';
                        END  IF;
            
                  END   IF;
            END   IF ;
        END LOOP;
    END;
    RETURN CUST_WHERE;
END GET_CUST_WHERE;

/
