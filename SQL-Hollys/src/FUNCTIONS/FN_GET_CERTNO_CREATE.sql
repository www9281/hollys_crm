--------------------------------------------------------
--  DDL for Function FN_GET_CERTNO_CREATE
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."FN_GET_CERTNO_CREATE" 
(
    PSV_COMP_CD   IN VARCHAR2, -- 회사코드
    PSV_PROC_TP   IN VARCHAR2, --업무구분(D:할인, W:위메프, C:쿠팡)
    PSV_ISSUE_DT  IN VARCHAR2  -- 발행일자
) RETURN VARCHAR2 IS
    -- LOCAL 변수            
    vCOMP_CD_ABBR   VARCHAR2(01) := PSV_PROC_TP;    
    vCERT_NO        VARCHAR2(16) := NULL;   -- 인증번호
    vYm             VARCHAR2(2);
    vSeq1           VARCHAR2(1);
    vSeq2           VARCHAR2(1);
    vSeq3           VARCHAR2(1);
    vSeq4           VARCHAR2(1);
    vSeq5           VARCHAR2(1);

    nRECCNT         NUMBER       := 0;      -- 체크용

BEGIN
    BEGIN
        IF PSV_PROC_TP = 'W' THEN
            LOOP
                -- 위메프 인증번호 생성
                -- 총 8자리 =  년1자리[2016년 ~ 2039년]
                --             월1자리[짝수년도 :  A ~ M, 홀수년도 : N ~ Z]
                --             영숫자5자리[0 ~ Z] 랜덤생성
                --             Check Digit[0 ~ 9]     
                -- 영문자는 소문자 및 대문자  I, O 제외            
                SELECT  CHR((CASE 
                                    -- A ~ H(16년 ~ 23년)
                                    WHEN TO_CHAR(SYSDATE, 'YYYY') - 2016 < 8 THEN TO_CHAR(SYSDATE, 'YYYY') - 2016
                                    -- J ~ N(24년 ~ 28년)          
                                    WHEN TO_CHAR(SYSDATE, 'YYYY') - 2016 < 14 THEN TO_CHAR(SYSDATE, 'YYYY') - 2016 + 1
                                    -- P ~ Z(29년 ~ 39년)     
                                    ELSE TO_CHAR(SYSDATE, 'YYYY') - 2016 + 2                                               
                             END) + 65) ||   -- 년도
                        CHR(DECODE(MOD(TO_CHAR(SYSDATE, 'YYYY'), 2), 1, 
                            -- 홀수년 월(N:1월, P:2월, Q:3월, R:4월, S:5월, T:6월, U:7월, V:8월, W:9월, X:10월, Y:11월, Z:12월)
                            (CASE WHEN TO_NUMBER(TO_CHAR(SYSDATE, 'MM')) < 2 THEN TO_NUMBER(TO_CHAR(SYSDATE, 'MM') + 13) ELSE TO_NUMBER(TO_CHAR(SYSDATE, 'MM')) + 14 END),   
                            -- 짝수년 월(A:1월, B:2월, C:3월, D:4월, E:5월, F:6월, G:7월, H:8월, J:9월, K:10월, L:11월, M:12월)
                            (CASE WHEN TO_NUMBER(TO_CHAR(SYSDATE, 'MM')) < 9 THEN TO_NUMBER(TO_CHAR(SYSDATE, 'MM')) WHEN TO_NUMBER(TO_CHAR(SYSDATE, 'MM')) < 15 THEN TO_NUMBER(TO_CHAR(SYSDATE, 'MM')) + 1 ELSE TO_NUMBER(TO_CHAR(SYSDATE, 'MM')) + 2 END))
                        + 64)           -- 월
                  INTO  vYm
                  FROM  DUAL;


                LOOP
                    SELECT  DBMS_RANDOM.STRING('X', 1)
                      INTO  vSeq1
                      FROM  DUAL;

                    EXIT WHEN vSeq1 NOT IN ('I', 'O');
                END LOOP;

                LOOP
                    SELECT  DBMS_RANDOM.STRING('X', 1)
                      INTO  vSeq2
                      FROM  DUAL;

                    EXIT WHEN vSeq2 NOT IN ('I', 'O');
                END LOOP;

                LOOP
                    SELECT  DBMS_RANDOM.STRING('X', 1)
                      INTO  vSeq3
                      FROM  DUAL;

                    EXIT WHEN vSeq3 NOT IN ('I', 'O');
                END LOOP;

                LOOP
                    SELECT  DBMS_RANDOM.STRING('X', 1)
                      INTO  vSeq4
                      FROM  DUAL;

                    EXIT WHEN vSeq4 NOT IN ('I', 'O');
                END LOOP;

                LOOP
                    SELECT  DBMS_RANDOM.STRING('X', 1)
                      INTO  vSeq5
                      FROM  DUAL;

                    EXIT WHEN vSeq5 NOT IN ('I', 'O');
                END LOOP;

                SELECT  X.CERT_NO || MOD( ORA_HASH(SUBSTR(X.CERT_NO, 1, 1), 9, '0')*1 + ORA_HASH(SUBSTR(X.CERT_NO, 2, 1), 9, '0')*3
                                        + ORA_HASH(SUBSTR(X.CERT_NO, 3, 1), 9, '0')*1 + ORA_HASH(SUBSTR(X.CERT_NO, 4, 1), 9, '0')*3
                                        + ORA_HASH(SUBSTR(X.CERT_NO, 5, 1), 9, '0')*1 + ORA_HASH(SUBSTR(X.CERT_NO, 6, 1), 9, '0')*3
                                        + ORA_HASH(SUBSTR(X.CERT_NO, 7, 1), 9, '0')*1, 10)
                  INTO  vCERT_NO
                  FROM  (
                            SELECT  vYm || vSeq1 || vSeq2 || vSeq3 || vSeq4 || vSeq5  AS CERT_NO
                              FROM  DUAL
                        )   X;

                -- 인증번호 체크                   
                SELECT  COUNT(*) INTO nRECCNT
                  FROM  M_COUPON_CUST
                 WHERE  COMP_CD = PSV_COMP_CD
                   AND  CERT_NO = vCERT_NO;

                EXIT WHEN (nRECCNT) = 0;

                /*
                -- 등록건수에 따른 일련번호 생성(5자리)
                SELECT  CASE WHEN IDX IN(0, 1, 2, 3)    THEN 0
                             WHEN IDX > 4 THEN
                                                CASE WHEN :VAL = POWER(34, IDX) THEN 0
                                                     WHEN :VAL - ROUND(:VAL/(POWER(34, IDX)), 0) * POWER(34, IDX) BETWEEN POWER(34, 4) AND POWER(34, 5) THEN ROUND(:VAL/(POWER(34, IDX)), 0)
                                                     ELSE 0
                                                END
                             ELSE ROUND(:VAL/(POWER(34, IDX)), 0)   END V_5TH
                     ,  CASE WHEN IDX IN(0, 1, 2)       THEN 0
                             WHEN IDX > 3 THEN
                                                CASE WHEN :VAL = POWER(34, IDX) THEN 0
                                                     WHEN :VAL - ROUND(:VAL/(POWER(34, IDX)), 0) * POWER(34, IDX) BETWEEN POWER(34, 3) AND POWER(34, 4) THEN ROUND(:VAL/(POWER(34, IDX)), 0)
                                                     ELSE 0
                                                END
                             ELSE ROUND(:VAL/(POWER(34, IDX)), 0)   END V_4TH
                     ,  CASE WHEN IDX IN(0, 1)          THEN 0
                             WHEN IDX > 2 THEN
                                                CASE WHEN :VAL = POWER(34, IDX) THEN 0
                                                     WHEN :VAL - ROUND(:VAL/(POWER(34, IDX)), 0) * POWER(34, IDX) BETWEEN POWER(34, 2) AND POWER(34, 3) THEN ROUND(:VAL/(POWER(34, IDX)), 0)
                                                     ELSE 0
                                                END
                             ELSE ROUND(:VAL/(POWER(34, IDX)), 0)   END V_3RD
                     ,  CASE WHEN IDX = 0              THEN 0
                             WHEN IDX > 1 THEN
                                                CASE WHEN :VAL = POWER(34, IDX) THEN 0
                                                     WHEN :VAL - ROUND(:VAL/(POWER(34, IDX)), 0) * POWER(34, IDX) BETWEEN POWER(34, 1) AND POWER(34, 2) THEN ROUND(:VAL/(POWER(34, IDX)), 0)
                                                     ELSE 0
                                                END
                             ELSE ROUND(:VAL/(POWER(34, IDX)), 0)   END V_2ND
                     ,  MOD(:VAL, 34)                                   V_1ST
                 FROM   (
                            SELECT  CASE WHEN :VAL >= 1336336  THEN 4 -- 34의 4승
                                         WHEN :VAL >= 39304    THEN 3 -- 34의 3승
                                         WHEN :VAL >= 1156     THEN 2 -- 34의 2승
                                         WHEN :VAL >= 34       THEN 1 -- 34의 1승
                                         ELSE                       0 -- 34의 0승
                                    END     IDX
                              FROM  DUAL
                        )
                */

            END LOOP;
        ELSE
            -- 쿠팡, 할인 인증번호 생성
            -- 총 14자리 = 쿠폰구분1자리[쿠팡:C, 할인:D] + 년월4자리[YYMM] + 랜덤값 8자리[11111111 ~ 99999999] + 체크섬1자리
            LOOP
                -- 인증번호 채번
                SELECT  X.CERT_NO || MOD( SUBSTR(X.CERT_NO, 2, 1)*1 + SUBSTR(X.CERT_NO, 3, 1)*3 
                                        + SUBSTR(X.CERT_NO, 4, 1)*1 + SUBSTR(X.CERT_NO, 5, 1)*3 
                                        + SUBSTR(X.CERT_NO, 6, 1)*1 + SUBSTR(X.CERT_NO, 7, 1)*3
                                        + SUBSTR(X.CERT_NO, 8, 1)*1 + SUBSTR(X.CERT_NO, 9, 1)*3 
                                        + SUBSTR(X.CERT_NO,10, 1)*1 + SUBSTR(X.CERT_NO,11, 1)*3 
                                        + SUBSTR(X.CERT_NO,12, 1)*1 + SUBSTR(X.CERT_NO,13, 1)*3, 10)
                  INTO  vCERT_NO
                  FROM  (
                            SELECT vCOMP_CD_ABBR || SUBSTR(PSV_ISSUE_DT, 3, 4) || TO_CHAR(ROUND(dbms_random.value(11111111, 99999999)), 'FM00000000')  CERT_NO
                            FROM DUAL
                        ) X;

                IF PSV_PROC_TP = 'C' THEN
                    -- 인증번호 체크                   
                    SELECT  COUNT(*) INTO nRECCNT
                      FROM  M_COUPON_CUST
                     WHERE  COMP_CD = PSV_COMP_CD
                       AND  CERT_NO = vCERT_NO;
                ELSIF PSV_PROC_TP = 'D' THEN
                    -- 인증번호 체크                   
                    SELECT  COUNT(*) INTO nRECCNT
                      FROM  DC_CERT
                     WHERE  COMP_CD = PSV_COMP_CD
                       AND  CERT_NO = vCERT_NO;
                END IF;

                EXIT WHEN (nRECCNT) = 0;
            END LOOP;
        END IF;
    END;

    RETURN vCERT_NO;
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;    
END FN_GET_CERTNO_CREATE;

/
