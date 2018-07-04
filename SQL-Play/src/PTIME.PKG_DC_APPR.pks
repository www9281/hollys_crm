CREATE OR REPLACE PACKAGE       PKG_DC_APPR AS
------------------------------------------------------------------------------
--  Package Name     : PKG_DC_APPR
--  Description      : 할인인증 
------------------------------------------------------------------------------
--  Create Date      : 2014-07-08
--  Create Programer :
--  Modify Date      :
--  Modify Programer :
------------------------------------------------------------------------------
  -- 인증번호 요청 
  PROCEDURE SP_CERT_NO_REQ
  ( 
    PS_CERT_FG      IN  STRING,     -- 인증번호 획득구분
    PS_COMP_CD      IN  STRING,     -- 회사코드
    PS_BRAND_CD     IN  STRING,     -- 영업조직
    PS_STOR_CD      IN  STRING,     -- 점포코드
    PS_SALE_DT      IN  STRING,     -- 판매일자
    PS_POS_NO       IN  STRING,     -- 포스번호
    PS_DC_DIV       IN  STRING,     -- 할인코드
    PS_CUST_ID      IN  STRING,     -- 고객ID
    PS_MOBILE       IN  STRING,     -- 핸드폰번호
    PS_LANGUAGE     IN  STRING,     -- 언어코드
    PR_RETURN_CD    OUT STRING,     -- 메세지코드
    PR_RETURN_MSG   OUT STRING,     -- 메세지
    PR_RESULT       OUT rec_set.m_refcur
  );
  
  -- 인증번호 조회
  PROCEDURE SP_CERT_NO_SEARCH
  ( 
    PS_COMP_CD      IN  STRING,     -- 회사코드
    PS_BRAND_CD     IN  STRING,     -- 영업조직
    PS_STOR_CD      IN  STRING,     -- 점포코드
    PS_CERT_NO      IN  STRING,     -- 인증번호
    PS_LANGUAGE     IN  STRING,     -- 언어코드
    PR_RETURN_CD    OUT STRING,     -- 메세지코드
    PR_RETURN_MSG   OUT STRING,     -- 메세지
    PR_RESULT       OUT rec_set.m_refcur
  );
  
  -- 인증번호 인증처리
  PROCEDURE SP_CERT_NO_APPR
  ( 
    PS_APPR_DT      IN  STRING,     -- 승인일자
    PS_APPR_TM      IN  STRING,     -- 승인시간
    PS_COMP_CD      IN  STRING,     -- 회사코드
    PS_BRAND_CD     IN  STRING,     -- 영업조직
    PS_STOR_CD      IN  STRING,     -- 점포
    PS_POS_NO       IN  STRING,     -- 포스번호
    PS_BILL_NO      IN  STRING,     -- 영수증번호
    PS_SEQ          IN  STRING,     -- 순번
    PS_DC_DIV       IN  STRING,     -- 할인코드
    PS_CERT_NO      IN  STRING,     -- 인증번호
    PS_USE_STAT     IN  STRING,     -- 사용상태
    PS_CUST_ID      IN  STRING,     -- 고객ID
    PS_MOBILE       IN  STRING,     -- 핸드폰번호
    PS_LANGUAGE     IN  STRING,     -- 언어코드
    PR_RETURN_CD    OUT STRING,     -- 메세지코드
    PR_RETURN_MSG   OUT STRING,     -- 메세지
    PR_RESULT       OUT rec_set.m_refcur
  );
  
  -- 직원할인 정보 조회
  PROCEDURE SP_USER_DC_REQ
  ( 
    PS_COMP_CD      IN  STRING,     -- 회사코드
    PS_BRAND_CD     IN  STRING,     -- 영업조직
    PS_STOR_CD      IN  STRING,     -- 점포코드
    PS_LANGUAGE     IN  STRING,     -- 언어코드
    PS_USER_ID      IN  STRING,     -- 사원번호
    PR_RETURN_CD    OUT STRING,     -- 메세지코드
    PR_RETURN_MSG   OUT STRING,     -- 메세지
    PR_RESULT       OUT rec_set.m_refcur
  );
  
  -- 직원할인 승인
  PROCEDURE SP_USER_DC_APPR
  ( 
    PS_COMP_CD      IN  STRING,     -- 회사코드
    PS_SALE_DT      IN  STRING,     -- 판매일자
    PS_BRAND_CD     IN  STRING,     -- 영업조직
    PS_STOR_CD      IN  STRING,     -- 점포코드
    PS_LANGUAGE     IN  STRING,     -- 언어코드
    PS_PROC_DIV     IN  STRING,     -- 처리구분(1:사용, 2:취소)
    PS_DC_DIV       IN  STRING,     -- 할인코드
    PS_USER_ID      IN  STRING,     -- 사원코드
    PR_RETURN_CD    OUT STRING,     -- 메세지코드
    PR_RETURN_MSG   OUT STRING,     -- 메세지
    PR_RESULT       OUT rec_set.m_refcur
  );
  
    PROCEDURE SP_GET_STORE_ETC_AMT
  (
    PSV_COMP_CD    IN   VARCHAR2, -- 회사코드
    PSV_BRAND_CD   IN   VARCHAR2, -- Brand Code
    PSV_STOR_CD    IN   VARCHAR2, -- Store Code
    PSV_LANGUAGE   IN   VARCHAR2, -- 언어타입
    PSV_STR_DT     IN   VARCHAR2, -- 조회시작일자 
    PSV_END_DT     IN   VARCHAR2, -- 조회시작일자
    PR_RTN_CD      OUT  VARCHAR2, -- 처리코드
    PR_RTN_MSG     OUT  VARCHAR2, -- 처리Message
    PR_CURSOR      OUT REC_SET.M_REFCUR
  );
  
  PROCEDURE SP_SET_STORE_ETC_AMT
  (
    PSV_COMP_CD    IN   VARCHAR2, -- 회사코드
    PSV_BRAND_CD   IN   VARCHAR2, -- Brand Code
    PSV_STOR_CD    IN   VARCHAR2, -- Store Code
    PSV_LANGUAGE   IN   VARCHAR2, -- 언어타입
    PSV_PRC_DT     IN   VARCHAR2, -- PROCESS Date
    PSV_POS_NO     IN   VARCHAR2, -- POS NO
    PSV_ETC_DIV    IN   VARCHAR2, -- 입출금구분[01:입금계정, 02:출금계정]
    PSV_SEQ        IN   VARCHAR2, -- 순번[입금 : SEQ, 출금 : 0]
    PSV_USER_ID    IN   VARCHAR2, -- 매장담당자코드
    PSV_CONFIRM_YN IN   VARCHAR2, -- 확정유무[Y/N]
    PSV_CONFIRM_DT IN   VARCHAR2, -- YYYYMMDD
    PSV_ETC_CD     IN   VARCHAR2, -- 계정코드
    PSV_RMK_SEQ    IN   VARCHAR2, -- 적요순번
    PSV_EVID_DOC   IN   VARCHAR2, -- 증빙서류[00:해당없음,01:세금계산서,02:간이영수증,03:면세품계산서,04:신용카드지출전표] 
    PSV_ETC_DESC   IN   VARCHAR2, -- 입출금내역
    PSV_ETC_AMT    IN   VARCHAR2, -- 입출금금액
    PSV_DEL_YN     IN   VARCHAR2, -- 삭제여부
    PR_RTN_CD      OUT  VARCHAR2, -- 처리코드
    PR_RTN_MSG     OUT  VARCHAR2, -- 처리Message
    PR_CURSOR      OUT REC_SET.M_REFCUR
  );
  
END PKG_DC_APPR;

/

CREATE OR REPLACE PACKAGE BODY       PKG_DC_APPR AS
------------------------------------------------------------------------------
--  Package Name     : PKG_DC_APPR
--  Description      : 할인인증 
------------------------------------------------------------------------------
--  Create Date      : 2014-07-08
--  Create Programer :
--  Modify Date      :
--  Modify Programer :
------------------------------------------------------------------------------
-- 인증번호 요청 
PROCEDURE SP_CERT_NO_REQ
( 
    PS_CERT_FG      IN  STRING,     -- 인증번호 획득구분
    PS_COMP_CD      IN  STRING,     -- 회사코드
    PS_BRAND_CD     IN  STRING,     -- 영업조직
    PS_STOR_CD      IN  STRING,     -- 점포코드
    PS_SALE_DT      IN  STRING,     -- 판매일자
    PS_POS_NO       IN  STRING,     -- 포스번호
    PS_DC_DIV       IN  STRING,     -- 할인코드
    PS_CUST_ID      IN  STRING,     -- 고객ID
    PS_MOBILE       IN  STRING,     -- 핸드폰번호
    PS_LANGUAGE     IN  STRING,     -- 언어코드
    PR_RETURN_CD    OUT STRING,     -- 메세지코드
    PR_RETURN_MSG   OUT STRING,     -- 메세지
    PR_RESULT       OUT rec_set.m_refcur
) IS

lsv_msg_code    VARCHAR2(4) := '0000';
lsv_msg_text    VARCHAR2(400);
lsv_dc_div      NUMBER(5);
lsv_cert_no     VARCHAR2(20);
ERR_HANDLER     EXCEPTION;

BEGIN
     
    -- 할인코드 체크
    BEGIN
        SELECT  D.DC_DIV
          INTO  lsv_dc_div
          FROM  DC          D
             ,  DC_STORE    DS
         WHERE  D.COMP_CD   = DS.COMP_CD
           AND  D.BRAND_CD  = DS.BRAND_CD
           AND  D.DC_DIV    = DS.DC_DIV
           AND  D.COMP_CD   = PS_COMP_CD
           AND  D.DC_DIV    = PS_DC_DIV
           AND  D.DC_CLASS  = '2'
           AND  D.DML_FLAG  IN ('I', 'U')
           AND  DS.DML_FLAG IN ('I', 'U')
           AND  DS.COMP_CD  = PS_COMP_CD
           AND  DS.BRAND_CD = PS_BRAND_CD
           AND  DS.STOR_CD  = PS_STOR_CD;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            lsv_msg_code := '1000';
            lsv_msg_text := FC_GET_WORDPACK_MSG(PS_COMP_CD, PS_LANGUAGE, '1010001358'); -- 사용 불가능한 할인코드입니다.@$관리자에게 문의하여 주십시요.
            RAISE ERR_HANDLER;
            
        WHEN OTHERS THEN
            lsv_msg_code  := '9999';
            lsv_msg_text  := '1000 ' || SQLERRM;
            RAISE ERR_HANDLER;
    END;
    
    -- 인증코드 조회
    BEGIN
        IF PS_CERT_FG = '1' THEN
            SELECT  SUBSTR(TO_CHAR(ORA_HASH(PS_BRAND_CD, 10),  '00'),  2)                    || -- 영업조직 해쉬값 2자리 00 ~ 99
                    SUBSTR(TO_CHAR(ORA_HASH(PS_DC_DIV,   100), '000'), 2)                    || -- 할인코드 해쉬값 3자리 000 ~ 999
                    SUBSTR(TO_CHAR(SYSDATE, 'YYYY'), 3, 2)                                   || -- 년 2자리    14 ~ 99
                    CHR(TO_NUMBER(TO_CHAR(SYSDATE, 'MM')) + 64)                              || -- 월 1자리    A  ~ L
                    SUBSTR(TO_CHAR(LEVEL + CERT_CNT, '00000'), 2, 1)                         || -- 순번 1자리  0  ~ 9
                    TO_CHAR(SYSDATE, 'DD')                                                   || -- 일 2자리    01 ~ 31
                    SUBSTR(TO_CHAR(LEVEL + CERT_CNT,  '00000'),  3, 1)                       || -- 순번 1자리  0  ~ 9
                    CHR(TO_NUMBER(TO_CHAR(SYSDATE, 'HH24')) + 64)                            || -- 시간 1자리  A  ~ Y
                    SUBSTR(TO_CHAR(LEVEL + CERT_CNT, '00000'), 4, 1)                         || -- 순번 1자리  0  ~ 9
                    TO_CHAR(SYSDATE, 'MI')                                                   || -- 분   2자리  00 ~ 59
                    SUBSTR(TO_CHAR(LEVEL + CERT_CNT, '00000'), 5, 1)                         || -- 순번 1자리  0  ~ 9
                    TO_CHAR(SYSDATE, 'SS')                                                   || -- 초   2자리  00 ~ 59
                    SUBSTR(TO_CHAR(LEVEL + CERT_CNT, '00000'), 6, 1)            AS CERT_NO      -- 순번 1자리  0  ~ 9
              INTO  lsv_cert_no
              FROM  (
                        SELECT  COUNT(*)    AS CERT_CNT
                          FROM  DC_CERT
                         WHERE  COMP_CD  = PS_COMP_CD
                           AND  BRAND_CD = PS_BRAND_CD
                           AND  DC_DIV   = PS_DC_DIV
                    )
           CONNECT  BY ROWNUM <= 1
            ;
        ELSIF PS_CERT_FG = '2' THEN
            SELECT  MIN(CERT_NO)    AS CERT_NO
              INTO  lsv_cert_no
              FROM  DC_CERT
             WHERE  COMP_CD     = PS_COMP_CD
               AND  BRAND_CD    = PS_BRAND_CD
               AND  DC_DIV      = PS_DC_DIV
               AND  USE_STAT    = '00'    
            ;
        ELSE
            lsv_msg_code := '9999';
            lsv_msg_text := FC_GET_WORDPACK_MSG(PS_COMP_CD, PS_LANGUAGE, '1010001372'); -- 인증대상 할인이 아닙니다.
            RAISE ERR_HANDLER;
        END IF;
        
        INSERT  INTO DC_CERT
        (
                COMP_CD
            ,   BRAND_CD
            ,   DC_DIV
            ,   CERT_NO
            ,   CUST_ID
            ,   MOBILE
            ,   USE_STAT
            ,   INST_DT
            ,   INST_USER
            ,   UPD_DT
            ,   UPD_USER
        ) VALUES (
                PS_COMP_CD
            ,   PS_BRAND_CD
            ,   PS_DC_DIV
            ,   lsv_cert_no
            ,   PS_CUST_ID
            ,   PS_MOBILE
            ,   '01'
            ,   SYSDATE
            ,   'SYSTEM'
            ,   SYSDATE
            ,   'SYSTEM'
        );
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            lsv_msg_code := '2000';
            lsv_msg_text := FC_GET_WORDPACK_MSG(PS_COMP_CD, PS_LANGUAGE, '1010001359'); -- 사용가능한 인증번호가 존재하지 않습니다.
            RAISE ERR_HANDLER;
            
        WHEN OTHERS THEN
            lsv_msg_code  := '9999';
            lsv_msg_text  := '2000 ' || SQLERRM;
            RAISE ERR_HANDLER;
    END;
    
    PR_RETURN_CD    := lsv_msg_code;
    PR_RETURN_MSG   := lsv_msg_text;
    
    OPEN PR_RESULT FOR
        SELECT  lsv_cert_no AS CERT_NO
          FROM  DUAL;
        
EXCEPTION
    WHEN ERR_HANDLER THEN
        PR_RETURN_CD    := lsv_msg_code;
        PR_RETURN_MSG   := lsv_msg_text;
        ROLLBACK;
        
    WHEN OTHERS THEN
        PR_RETURN_CD    := '9999';
        PR_RETURN_MSG   := SQLERRM;
        ROLLBACK;
END;
  
-- 인증번호 조회
PROCEDURE SP_CERT_NO_SEARCH
( 
    PS_COMP_CD      IN  STRING,     -- 회사코드
    PS_BRAND_CD     IN  STRING,     -- 영업조직
    PS_STOR_CD      IN  STRING,     -- 점포코드
    PS_CERT_NO      IN  STRING,     -- 인증번호
    PS_LANGUAGE     IN  STRING,     -- 언어코드
    PR_RETURN_CD    OUT STRING,     -- 메세지코드
    PR_RETURN_MSG   OUT STRING,     -- 메세지
    PR_RESULT       OUT rec_set.m_refcur
) IS

lsv_msg_code    VARCHAR2(4) := '0000';
lsv_msg_text    VARCHAR2(400);
lsv_use_stat    VARCHAR2(2);
lsv_cert_fdt    VARCHAR2(8);
lsv_cert_tdt    VARCHAR2(8);
lsv_use_dt      VARCHAR2(8);
lsv_stor_cd     VARCHAR2(10);
lsv_stor_nm     VARCHAR2(60);
lsv_cert_fg     VARCHAR2(1);
lsv_dc_class    VARCHAR2(1);

ERR_HANDLER     EXCEPTION;

BEGIN
    
    dbms_output.enable( 1000000 );

    SELECT  DT.USE_STAT, DT.CERT_FDT, DT.CERT_TDT, TO_CHAR(TO_DATE(DT.USE_DT, 'YYYYMMDD'), 'YYYYMMDD') AS USE_DT, DT.STOR_CD, S.STOR_NM, D.CERT_FG, D.DC_CLASS
      INTO  lsv_use_stat, lsv_cert_fdt, lsv_cert_tdt, lsv_use_dt, lsv_stor_cd, lsv_stor_nm, lsv_cert_fg, lsv_dc_class
      FROM  DC_CERT     DT
         ,  DC          D
         ,  (
                SELECT  S.COMP_CD
                     ,  S.BRAND_CD
                     ,  S.STOR_CD
                     ,  NVL(L.STOR_NM, S.STOR_NM)   AS STOR_NM
                  FROM  STORE   S
                     ,  (
                            SELECT  COMP_CD
                                 ,  BRAND_CD
                                 ,  STOR_CD
                                 ,  STOR_NM
                              FROM  LANG_STORE
                             WHERE  COMP_CD     = PS_COMP_CD
                               AND  LANGUAGE_TP = PS_LANGUAGE
                               AND  USE_YN      = 'Y'
                        )   L
                 WHERE  S.COMP_CD  = L.COMP_CD(+)
                   AND  S.BRAND_CD = L.BRAND_CD(+)
                   AND  S.STOR_CD  = L.STOR_CD(+)
                   AND  S.COMP_CD  = PS_COMP_CD
            )   S
     WHERE  DT.COMP_CD  = D.COMP_CD
       AND  DT.BRAND_CD = D.BRAND_CD
       AND  DT.DC_DIV   = D.DC_DIV
       AND  DT.COMP_CD  = S.COMP_CD(+)
       AND  DT.BRAND_CD = S.BRAND_CD(+)
       AND  DT.STOR_CD  = S.STOR_CD(+)
       AND  DT.COMP_CD  = PS_COMP_CD
       AND  DT.BRAND_CD = PS_BRAND_CD
       AND  DT.CERT_NO  = PS_CERT_NO;
    
    dbms_output.put_line(lsv_use_stat);
    dbms_output.put_line(lsv_cert_fdt);
    dbms_output.put_line(lsv_cert_tdt);
    
    IF lsv_dc_class <> '2' THEN
        lsv_msg_code := '20000';
        lsv_msg_text := FC_GET_WORDPACK_MSG(PS_COMP_CD, PS_LANGUAGE, '1010001372'); -- 인증대상 할인이 아닙니다.
        RAISE ERR_HANDLER;
    ELSIF lsv_use_stat IN ('00', '01', '30', '31', '32', '99') THEN
        lsv_msg_code := '10'||lsv_use_stat;
        lsv_msg_text := FC_GET_WORDPACK_MSG(PS_COMP_CD, PS_LANGUAGE, '1010001361'); -- 사용 가능한 상태의 인증번호가 아닙니다.
        RAISE ERR_HANDLER;
    ELSIF lsv_use_stat IN ('11') THEN
        lsv_msg_code := '10'||lsv_use_stat;
        lsv_msg_text := FC_GET_WORDPACK_MSG(PS_COMP_CD, PS_LANGUAGE, '1010001362')||'@$[ '||TO_CHAR(TO_DATE(lsv_use_dt, 'YYYYMMDD'), 'YYYY-MM-DD')||' '||lsv_stor_nm||' ]';   -- 반품상태의 인증번호입니다.
        RAISE ERR_HANDLER;
    ELSIF lsv_use_stat IN ('20') THEN
        lsv_msg_code := '10'||lsv_use_stat;
        lsv_msg_text := FC_GET_WORDPACK_MSG(PS_COMP_CD, PS_LANGUAGE, '1010001363')||'@$[ '||TO_CHAR(TO_DATE(lsv_use_dt, 'YYYYMMDD'), 'YYYY-MM-DD')||' '||lsv_stor_nm||' ]';   -- 교환상태의 인증번호입니다.
        RAISE ERR_HANDLER;
    ELSIF TO_CHAR(SYSDATE, 'YYYYMMDD') < lsv_cert_fdt OR TO_CHAR(SYSDATE, 'YYYYMMDD') > lsv_cert_tdt THEN
        lsv_msg_code := '1033';
        lsv_msg_text := FC_GET_WORDPACK_MSG(PS_COMP_CD, PS_LANGUAGE, '1010001364')||'@$[ '||TO_CHAR(TO_DATE(lsv_use_dt, 'YYYYMMDD'), 'YYYY-MM-DD')||' ]';                   -- 사용기간이 지난 인증번호입니다.
        RAISE ERR_HANDLER;
    END IF;
    
    lsv_msg_code := '0000';
    lsv_msg_text := FC_GET_WORDPACK_MSG(PS_COMP_CD, PS_LANGUAGE, '1010001365');     -- 사용 가능한 인증번호입니다.
    
    BEGIN
        OPEN PR_RESULT FOR
            SELECT  DC.CERT_NO
                 ,  DC.BRAND_CD
                 ,  DC.DC_DIV
                 ,  D.DC_NM
                 ,  DL.STOR_CD
                 ,  S.STOR_NM
                 ,  SD.ITEM_CD
                 ,  I.ITEM_NM
                 ,  SD.SALE_PRC
              FROM  DC_CERT         DC
                 ,  DC_CERT_LOG     DL
                 ,  (
                        SELECT  D.COMP_CD
                             ,  D.BRAND_CD
                             ,  D.DC_DIV
                             ,  NVL(L.LANG_NM, D.DC_POSNM) AS DC_NM
                          FROM  DC          D
                             ,  (
                                    SELECT  COMP_CD
                                         ,  PK_COL
                                         ,  LANG_NM
                                      FROM  LANG_TABLE
                                     WHERE  COMP_CD     = PS_COMP_CD
                                       AND  TABLE_NM    = 'DC'
                                       AND  COL_NM      = 'DC_POSNM'
                                       AND  LANGUAGE_TP = PS_LANGUAGE
                                       AND  USE_YN      = 'Y'
                                )           L
                         WHERE  L.COMP_CD(+)= D.COMP_CD
                           AND  L.PK_COL(+) = LPAD(D.BRAND_CD, 4, ' ')||LPAD(D.DC_DIV, 5, ' ')
                           AND  D.COMP_CD   = PS_COMP_CD
                           AND  D.BRAND_CD  = PS_BRAND_CD
                    )               D
                 ,  SALE_DT         SD
                 ,  (
                        SELECT  S.COMP_CD
                             ,  S.BRAND_CD
                             ,  S.STOR_CD
                             ,  NVL(L.STOR_NM, S.STOR_NM)   AS STOR_NM
                          FROM  STORE   S
                             ,  (
                                    SELECT  COMP_CD
                                         ,  BRAND_CD
                                         ,  STOR_CD
                                         ,  STOR_NM
                                      FROM  LANG_STORE
                                     WHERE  COMP_CD     = PS_COMP_CD
                                       AND  BRAND_CD    = PS_BRAND_CD
                                       AND  LANGUAGE_TP = PS_LANGUAGE
                                       AND  USE_YN      = 'Y'
                                )       L
                         WHERE  S.COMP_CD  = L.COMP_CD(+)
                           AND  S.BRAND_CD = L.BRAND_CD(+)
                           AND  S.STOR_CD  = L.STOR_CD(+)
                           AND  S.COMP_CD  = PS_COMP_CD
                           AND  S.BRAND_CD = PS_BRAND_CD
                    )               S
                 ,  (
                        SELECT  I.COMP_CD
                             ,  I.ITEM_CD
                             ,  NVL(L.ITEM_POS_NM, I.ITEM_POS_NM)   AS ITEM_NM
                          FROM  ITEM_CHAIN  I
                             ,  (
                                    SELECT  COMP_CD
                                         ,  ITEM_CD
                                         ,  ITEM_POS_NM
                                      FROM  LANG_ITEM
                                     WHERE  COMP_CD     = PS_COMP_CD
                                       AND  LANGUAGE_TP = PS_LANGUAGE
                                       AND  USE_YN      = 'Y'
                                )       L
                         WHERE  I.COMP_CD  = L.COMP_CD(+)
                           AND  I.ITEM_CD  = L.ITEM_CD(+)
                           AND  I.COMP_CD  = PS_COMP_CD
                           AND  I.BRAND_CD = PS_BRAND_CD
                           AND  I.STOR_TP  = ( SELECT STOR_TP FROM STORE WHERE COMP_CD = PS_COMP_CD AND BRAND_CD = PS_BRAND_CD AND STOR_CD = PS_STOR_CD AND ROWNUM = 1 )
                    )               I
             WHERE  DC.COMP_CD  = DL.COMP_CD(+)
               AND  DC.BRAND_CD = DL.BRAND_CD(+)
               AND  DC.DC_DIV   = DL.DC_DIV(+)
               AND  DC.CERT_NO  = DL.CERT_NO(+)
               AND  DL.COMP_CD  = D.COMP_CD(+)
               AND  DL.BRAND_CD = D.BRAND_CD(+)
               AND  DL.DC_DIV   = D.DC_DIV(+)
               AND  DL.COMP_CD  = SD.COMP_CD(+)
               AND  DL.SALE_DT  = SD.SALE_DT(+)
               AND  DL.BRAND_CD = SD.BRAND_CD(+)
               AND  DL.STOR_CD  = SD.STOR_CD(+)
               AND  DL.POS_NO   = SD.POS_NO(+)
               AND  DL.BILL_NO  = SD.BILL_NO(+)
               AND  DL.SEQ      = SD.SEQ(+)
               AND  DL.COMP_CD  = S.COMP_CD(+)
               AND  DL.BRAND_CD = S.BRAND_CD(+)
               AND  DL.STOR_CD  = S.STOR_CD(+)
               AND  SD.ITEM_CD  = I.ITEM_CD(+)
               AND  DC.COMP_CD  = PS_COMP_CD
               AND  DC.BRAND_CD = PS_BRAND_CD
               AND  DC.CERT_NO  = PS_CERT_NO;
        
    EXCEPTION    
        WHEN NO_DATA_FOUND THEN
            lsv_msg_code := '2000';
            lsv_msg_text := FC_GET_WORDPACK_MSG(PS_COMP_CD, PS_LANGUAGE, '1010001360'); -- 존재하지 않는 인증번호입니다.
            RAISE ERR_HANDLER;
    END;
    
    PR_RETURN_CD    := lsv_msg_code;
    PR_RETURN_MSG   := lsv_msg_text;
    
EXCEPTION
    WHEN ERR_HANDLER THEN
        PR_RETURN_CD    := lsv_msg_code;
        PR_RETURN_MSG   := lsv_msg_text;
        ROLLBACK;
        
    WHEN OTHERS THEN
        PR_RETURN_CD    := '9999';
        PR_RETURN_MSG   := SQLERRM;
        
END;

PROCEDURE SP_CERT_NO_APPR
  ( 
    PS_APPR_DT      IN  STRING,     -- 승인일자
    PS_APPR_TM      IN  STRING,     -- 승인시간
    PS_COMP_CD      IN  STRING,     -- 회사코드
    PS_BRAND_CD     IN  STRING,     -- 영업조직
    PS_STOR_CD      IN  STRING,     -- 점포
    PS_POS_NO       IN  STRING,     -- 포스번호
    PS_BILL_NO      IN  STRING,     -- 영수증번호
    PS_SEQ          IN  STRING,     -- 순번
    PS_DC_DIV       IN  STRING,     -- 할인코드
    PS_CERT_NO      IN  STRING,     -- 인증번호
    PS_USE_STAT     IN  STRING,     -- 사용상태
    PS_CUST_ID      IN  STRING,     -- 고객ID
    PS_MOBILE       IN  STRING,     -- 핸드폰번호
    PS_LANGUAGE     IN  STRING,     -- 언어코드
    PR_RETURN_CD    OUT STRING,     -- 메세지코드
    PR_RETURN_MSG   OUT STRING,     -- 메세지
    PR_RESULT       OUT rec_set.m_refcur
  ) IS

lsv_msg_code    VARCHAR2(4) := '0000';
lsv_msg_text    VARCHAR2(400);
lsv_use_stat    VARCHAR2(2);
lsv_cert_fg     VARCHAR2(1);
lsv_dc_class    VARCHAR2(1);
lsv_dc_value    NUMBER;
lsv_brand_cd    VARCHAR2(4);
lsv_dc_div      NUMBER(5);

ERR_HANDLER     EXCEPTION;

BEGIN
    
    dbms_output.enable( 1000000 );

    SELECT  DT.USE_STAT, D.CERT_FG, D.DC_CLASS, DT.BRAND_CD, DT.DC_DIV
      INTO  lsv_use_stat, lsv_cert_fg, lsv_dc_class, lsv_brand_cd, lsv_dc_div
      FROM  DC_CERT     DT
         ,  DC          D
         ,  (
                SELECT  S.COMP_CD
                     ,  S.BRAND_CD
                     ,  S.STOR_CD
                     ,  NVL(L.STOR_NM, S.STOR_NM)   AS STOR_NM
                  FROM  STORE   S
                     ,  (
                            SELECT  COMP_CD
                                 ,  BRAND_CD
                                 ,  STOR_CD
                                 ,  STOR_NM
                              FROM  LANG_STORE
                             WHERE  COMP_CD     = PS_COMP_CD
                               AND  LANGUAGE_TP = PS_LANGUAGE
                               AND  USE_YN      = 'Y'
                        )   L
                 WHERE  S.COMP_CD  = L.COMP_CD(+)
                   AND  S.BRAND_CD = L.BRAND_CD(+)
                   AND  S.STOR_CD  = L.STOR_CD(+)
                   AND  S.COMP_CD  = PS_COMP_CD
            )   S
     WHERE  DT.COMP_CD  = D.COMP_CD
       AND  DT.BRAND_CD = D.BRAND_CD
       AND  DT.DC_DIV   = D.DC_DIV
       AND  DT.COMP_CD  = S.COMP_CD(+)
       AND  DT.BRAND_CD = S.BRAND_CD(+)
       AND  DT.STOR_CD  = S.STOR_CD(+)
       AND  DT.COMP_CD  = PS_COMP_CD
       AND  DT.BRAND_CD = PS_BRAND_CD
       AND  DT.CERT_NO  = PS_CERT_NO;
    
    IF lsv_dc_class <> '2' THEN
        lsv_msg_code := '2000';
        lsv_msg_text := FC_GET_WORDPACK_MSG(PS_COMP_CD, PS_LANGUAGE, '1010001372');     -- 인증대상 할인이 아닙니다.
        RAISE ERR_HANDLER;
    ELSIF lsv_dc_div <> PS_DC_DIV THEN
        lsv_msg_code := '3000';
        lsv_msg_text := FC_GET_WORDPACK_MSG(PS_COMP_CD, PS_LANGUAGE, '1010001372');     -- 인증대상 할인이 아닙니다.
        RAISE ERR_HANDLER;
    ELSIF lsv_use_stat = '10' AND PS_USE_STAT = '10' THEN
        lsv_msg_code := '10'||lsv_use_stat;
        lsv_msg_text := FC_GET_WORDPACK_MSG(PS_COMP_CD, PS_LANGUAGE, '1010001319');     -- 판매상태의 인증번호입니다.
        RAISE ERR_HANDLER;
    ELSIF lsv_use_stat = '20' AND PS_USE_STAT = '10' THEN
        lsv_msg_code := '10'||lsv_use_stat;
        lsv_msg_text := FC_GET_WORDPACK_MSG(PS_COMP_CD, PS_LANGUAGE, '1010001363');     -- 교환상태의 인증번호입니다.
        RAISE ERR_HANDLER;
    ELSIF lsv_use_stat = '20' AND PS_USE_STAT = '20' THEN
        lsv_msg_code := '10'||lsv_use_stat;
        lsv_msg_text := FC_GET_WORDPACK_MSG(PS_COMP_CD, PS_LANGUAGE, '1010001363');     -- 교환상태의 인증번호입니다.
        RAISE ERR_HANDLER;
    END IF;
    
    BEGIN
        SELECT  DC_VALUE
          INTO  lsv_dc_value
          FROM  DC
         WHERE  COMP_CD  = PS_COMP_CD
           AND  BRAND_CD = lsv_brand_cd
           AND  DC_DIV   = lsv_dc_div
         ;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            lsv_dc_value := 1;
    END;    
    
    IF lsv_dc_value IS NULL THEN
        lsv_dc_value := 1;
    END IF;
    
    UPDATE  DC_CERT
       SET  CUST_ID     = PS_CUST_ID
         ,  MOBILE      = PS_MOBILE
         ,  CERT_FDT    = NVL(CERT_FDT, PS_APPR_DT)
         ,  CERT_TDT    = NVL(CERT_TDT, TO_CHAR(TO_DATE(PS_APPR_DT, 'YYYYMMDD') + TO_NUMBER(lsv_dc_value) - 1, 'YYYYMMDD'))
         ,  USE_STAT    = PS_USE_STAT
         ,  USE_DT      = PS_APPR_DT
         ,  USE_TM      = PS_APPR_TM
         ,  STOR_CD     = PS_STOR_CD
         ,  POS_NO      = PS_POS_NO
         ,  BILL_NO     = PS_BILL_NO
         ,  SEQ         = PS_SEQ
         ,  SALE_DIV    = DECODE(PS_USE_STAT, '11', '2', '1')
     WHERE  COMP_CD     = PS_COMP_CD
       AND  BRAND_CD    = lsv_brand_cd
       AND  DC_DIV      = lsv_dc_div
       AND  CERT_NO     = PS_CERT_NO;
    
    lsv_msg_code := '0000';
    lsv_msg_text := FC_GET_WORDPACK_MSG(PS_COMP_CD, PS_LANGUAGE, '1001240024');         -- 정상적으로 확정처리 되었습니다.
    
    BEGIN
        OPEN PR_RESULT FOR
            SELECT  PS_CERT_NO AS CERT_NO
          FROM  DUAL;
        
    EXCEPTION    
        WHEN NO_DATA_FOUND THEN
            lsv_msg_code := '2000';
            lsv_msg_text := FC_GET_WORDPACK_MSG(PS_COMP_CD, PS_LANGUAGE, '1010001360'); -- 존재하지 않는 인증번호입니다.
            RAISE ERR_HANDLER;
    END;
    
    PR_RETURN_CD    := lsv_msg_code;
    PR_RETURN_MSG   := lsv_msg_text;
    
EXCEPTION
    WHEN ERR_HANDLER THEN
        PR_RETURN_CD    := lsv_msg_code;
        PR_RETURN_MSG   := lsv_msg_text;
        ROLLBACK;
        
    WHEN OTHERS THEN
        PR_RETURN_CD    := '9999';
        PR_RETURN_MSG   := SQLERRM;
        ROLLBACK;
        
END;

-- 직원할인 정보 조회
PROCEDURE SP_USER_DC_REQ
( 
    PS_COMP_CD      IN  STRING,     -- 회사코드
    PS_BRAND_CD     IN  STRING,     -- 영업조직
    PS_STOR_CD      IN  STRING,     -- 점포코드
    PS_LANGUAGE     IN  STRING,     -- 언어코드
    PS_USER_ID      IN  STRING,     -- 사원번호
    PR_RETURN_CD    OUT STRING,     -- 메세지코드
    PR_RETURN_MSG   OUT STRING,     -- 메세지
    PR_RESULT       OUT rec_set.m_refcur
) IS

nRecCnt         NUMBER(7) := 0;
ERR_HANDLER     EXCEPTION;
V_STOR_TP       STORE.STOR_TP%TYPE;

BEGIN
    
    EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';
    
    PR_RETURN_CD    := '0000';
    PR_RETURN_MSG   := 'OK';
    
    BEGIN
        SELECT  STOR_TP
          INTO  V_STOR_TP
          FROM  STORE
         WHERE  COMP_CD     = PS_COMP_CD
           AND  BRAND_CD    = PS_BRAND_CD
           AND  STOR_CD     = PS_STOR_CD;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                PR_RETURN_CD := '1000';
                PR_RETURN_MSG := FC_GET_WORDPACK_MSG(PS_COMP_CD, PS_LANGUAGE, '1004000002'); -- 미등록 점포입니다.
                RAISE ERR_HANDLER;    
    END;
    
    IF V_STOR_TP <> '10' THEN
        PR_RETURN_CD := '1000';
        PR_RETURN_MSG := FC_GET_WORDPACK_MSG(PS_COMP_CD, PS_LANGUAGE, '1010001625'); -- 직원할인 대상 매장이 아닙니다.
        RAISE ERR_HANDLER;
    END IF;
    
    SELECT  COUNT(*)
      INTO  nRecCnt
      FROM  (
                SELECT  COMP_CD
                     ,  USER_ID
                     ,  POSITION_CD
                  FROM  HQ_USER             HU
                 WHERE  HU.COMP_CD      = PS_COMP_CD
                   AND  HU.USER_ID      = DECRYPT(PS_USER_ID)
                   AND  HU.USE_YN       = 'Y'
                UNION ALL
                SELECT  COMP_CD
                     ,  USER_ID
                     ,  ROLE_DIV        AS POSITION_CD
                  FROM  STORE_USER          SU
                 WHERE  SU.COMP_CD      = PS_COMP_CD
                   AND  SU.USER_ID      = DECRYPT(PS_USER_ID)
                   AND  SU.USE_YN       = 'Y'
            )   U
         ,  (
                SELECT  UDP.COMP_CD
                     ,  UDP.POSITION_CD
                     ,  UDP.FREE_CNT_M
                     ,  UDP.FREE_CNT_D
                     ,  UDP.FREE_DIV
                     ,  FD.DC_VALUE         AS FREE_VALUE
                     ,  UDP.DC_CNT_M
                     ,  UDP.DC_CNT_D
                     ,  UDP.DC_CNT_B
                     ,  UDP.DC_DIV
                     ,  DD.DC_VALUE
                  FROM  USER_DC_POSITION    UDP
                     ,  DC                  FD
                     ,  DC                  DD
                 WHERE  UDP.COMP_CD     = FD.COMP_CD
                   AND  UDP.FREE_DIV    = FD.DC_DIV
                   AND  UDP.COMP_CD     = DD.COMP_CD
                   AND  UDP.DC_DIV      = DD.DC_DIV
                   AND  UDP.COMP_CD     = PS_COMP_CD
                   AND  UDP.DC_YYYYMM   = (
                                                SELECT  MAX(DC_YYYYMM)
                                                  FROM  USER_DC_POSITION
                                                 WHERE  COMP_CD     = UDP.COMP_CD
                                                   AND  POSITION_CD = UDP.POSITION_CD
                                                   AND  DC_YYYYMM   <= TO_CHAR(SYSDATE, 'YYYYMM')
                                                   AND  USE_YN      = 'Y'
                                          )
                   AND  UDP.USE_YN      = 'Y'
                   AND  FD.BRAND_CD     = '0000'
                   AND  FD.DML_FLAG     IN ('I', 'U')
                   AND  DD.BRAND_CD     = '0000'
                   AND  DD.DML_FLAG     IN ('I', 'U')        
            )                   UDP
     WHERE  U.COMP_CD      = UDP.COMP_CD
       AND  U.POSITION_CD  = UDP.POSITION_CD
    ;
    
    IF nRecCnt = 0 THEN
        PR_RETURN_CD  := '1001'; 
        PR_RETURN_MSG := FC_GET_WORDPACK_MSG(PS_COMP_CD, PS_LANGUAGE, '1010001565');  -- 직원할인정보가 존재하지 않습니다. 
        RAISE ERR_HANDLER;
    END IF;
           
    OPEN PR_RESULT FOR
    SELECT  U.USER_ID
         ,  U.USER_NM
         ,  NVL(UDM.FREE_CNT_M, UDP.FREE_CNT_M)     AS FREE_CNT_M
         ,  NVL(UDM.FREE_USE_M, 0)                  AS FREE_USE_M
         ,  NVL(UDD.FREE_CNT_D, UDP.FREE_CNT_D)     AS FREE_CNT_D
         ,  NVL(UDD.FREE_USE_D, 0)                  AS FREE_USE_D
         ,  UDP.FREE_DIV
         ,  UDP.FREE_VALUE
         ,  NVL(UDM.DC_CNT_M  , UDP.DC_CNT_M)       AS DC_CNT_M
         ,  NVL(UDM.DC_USE_M  , 0)                  AS DC_USE_M
         ,  NVL(UDD.DC_CNT_D  , UDP.DC_CNT_D)       AS DC_CNT_D
         ,  NVL(UDD.DC_USE_D  , 0)                  AS DC_USE_D
         ,  UDP.DC_CNT_B
         ,  UDP.DC_DIV
         ,  UDP.DC_VALUE
      FROM  (
                SELECT  COMP_CD
                     ,  USER_ID
                     ,  USER_NM
                     ,  POSITION_CD
                  FROM  HQ_USER             HU
                 WHERE  HU.COMP_CD      = PS_COMP_CD
                   AND  HU.USER_ID      = DECRYPT(PS_USER_ID)
                   AND  HU.USE_YN       = 'Y'
                UNION ALL
                SELECT  COMP_CD
                     ,  USER_ID
                     ,  USER_NM
                     ,  ROLE_DIV        AS POSITION_CD
                  FROM  STORE_USER          SU
                 WHERE  SU.COMP_CD      = PS_COMP_CD
                   AND  SU.USER_ID      = DECRYPT(PS_USER_ID)
                   AND  SU.USE_YN       = 'Y'
            )   U
         ,  (
                SELECT  UDP.COMP_CD
                     ,  UDP.POSITION_CD
                     ,  UDP.FREE_CNT_M
                     ,  UDP.FREE_CNT_D
                     ,  UDP.FREE_DIV
                     ,  FD.DC_VALUE         AS FREE_VALUE
                     ,  UDP.DC_CNT_M
                     ,  UDP.DC_CNT_D
                     ,  UDP.DC_CNT_B
                     ,  UDP.DC_DIV
                     ,  DD.DC_VALUE
                  FROM  USER_DC_POSITION    UDP
                     ,  DC                  FD
                     ,  DC                  DD
                 WHERE  UDP.COMP_CD     = FD.COMP_CD
                   AND  UDP.FREE_DIV    = FD.DC_DIV
                   AND  UDP.COMP_CD     = DD.COMP_CD
                   AND  UDP.DC_DIV      = DD.DC_DIV
                   AND  UDP.COMP_CD     = PS_COMP_CD
                   AND  UDP.DC_YYYYMM   = (
                                                SELECT  MAX(DC_YYYYMM)
                                                  FROM  USER_DC_POSITION
                                                 WHERE  COMP_CD     = UDP.COMP_CD
                                                   AND  POSITION_CD = UDP.POSITION_CD
                                                   AND  DC_YYYYMM   <= TO_CHAR(SYSDATE, 'YYYYMM')
                                                   AND  USE_YN      = 'Y'
                                          )
                   AND  UDP.USE_YN      = 'Y'
                   AND  FD.BRAND_CD     = '0000'
                   AND  FD.DML_FLAG     IN ('I', 'U')
                   AND  DD.BRAND_CD     = '0000'
                   AND  DD.DML_FLAG     IN ('I', 'U')        
            )                   UDP
         ,  USER_DC             UDM
         ,  USER_DC             UDD
     WHERE  U.COMP_CD       = UDP.COMP_CD
       AND  U.POSITION_CD   = UDP.POSITION_CD
       AND  U.COMP_CD       = UDM.COMP_CD(+)
       AND  U.USER_ID       = UDM.USER_ID(+)
       AND  U.COMP_CD       = UDD.COMP_CD(+)
       AND  U.USER_ID       = UDD.USER_ID(+)
       AND  UDM.DC_DT(+)    = TO_CHAR(SYSDATE, 'YYYYMM')||'00'
       AND  UDD.DC_DT(+)    = TO_CHAR(SYSDATE, 'YYYYMMDD')
    ;
    
    PR_RETURN_MSG   := FC_GET_WORDPACK_MSG(PS_COMP_CD, PS_LANGUAGE, '1010001392'); -- 정상처리 되었습니다.
    
    EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
    
    RETURN;
    
EXCEPTION
    WHEN ERR_HANDLER THEN
        OPEN PR_RESULT FOR
            SELECT  PR_RETURN_CD
              FROM  DUAL;
        
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
            
        RETURN;
        
    WHEN OTHERS THEN
        PR_RETURN_CD  := '9999';
        PR_RETURN_MSG := FC_GET_WORDPACK_MSG(PS_COMP_CD, PS_LANGUAGE, '1004999999');  -- 자료처리중 오류가 발생했습니다. 관리자에게 문의하여 주십시오.
        --PR_RETURN_MSG := SQLERRM;
        
        OPEN PR_RESULT FOR
            SELECT  PR_RETURN_CD
              FROM  DUAL;
              
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
            
        RETURN;
        
END;

PROCEDURE SP_USER_DC_APPR
( 
    PS_COMP_CD      IN  STRING,     -- 회사코드
    PS_SALE_DT      IN  STRING,     -- 판매일자
    PS_BRAND_CD     IN  STRING,     -- 영업조직
    PS_STOR_CD      IN  STRING,     -- 점포코드
    PS_LANGUAGE     IN  STRING,     -- 언어코드
    PS_PROC_DIV     IN  STRING,     -- 처리구분(1:사용, 2:취소)
    PS_DC_DIV       IN  STRING,     -- 할인코드
    PS_USER_ID      IN  STRING,     -- 사원코드
    PR_RETURN_CD    OUT STRING,     -- 메세지코드
    PR_RETURN_MSG   OUT STRING,     -- 메세지
    PR_RESULT       OUT rec_set.m_refcur
) IS

lsv_position_cd USER_DC.POSITION_CD%TYPE := NULL;
lsv_free_div    NUMBER(5);
lsv_dc_div      NUMBER(5);
lsv_free_cnt_m  NUMBER(5);
lsv_free_cnt_d  NUMBER(5);
lsv_dc_cnt_m    NUMBER(5);
lsv_dc_cnt_d    NUMBER(5);
lsv_dc_cnt_b    NUMBER(5);
lsv_dc_value    NUMBER;
V_STOR_TP       STORE.STOR_TP%TYPE;

ERR_HANDLER     EXCEPTION;

BEGIN
    
    EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';
    
    PR_RETURN_CD    := '0000';
    PR_RETURN_MSG   := 'OK';
    
    BEGIN
        SELECT  STOR_TP
          INTO  V_STOR_TP
          FROM  STORE
         WHERE  COMP_CD     = PS_COMP_CD
           AND  BRAND_CD    = PS_BRAND_CD
           AND  STOR_CD     = PS_STOR_CD;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                PR_RETURN_CD := '1000';
                PR_RETURN_MSG := FC_GET_WORDPACK_MSG(PS_COMP_CD, PS_LANGUAGE, '1004000002'); -- 미등록 점포입니다.
                RAISE ERR_HANDLER;    
    END;
    
    IF V_STOR_TP <> '10' THEN
        PR_RETURN_CD := '1000';
        PR_RETURN_MSG := FC_GET_WORDPACK_MSG(PS_COMP_CD, PS_LANGUAGE, '1010001625'); -- 직원할인 대상 매장이 아닙니다.
        RAISE ERR_HANDLER;
    END IF;
    
    SELECT  U.POSITION_CD,  UDP.FREE_DIV, UDP.FREE_CNT_M, UDP.FREE_CNT_D, UDP.DC_DIV, UDP.DC_CNT_M, UDP.DC_CNT_D, UDP.DC_VALUE, UDP.DC_CNT_B
      INTO  lsv_position_cd, lsv_free_div, lsv_free_cnt_m, lsv_free_cnt_d, lsv_dc_div, lsv_dc_cnt_m, lsv_dc_cnt_d, lsv_dc_value, lsv_dc_cnt_b
      FROM  (
                SELECT  COMP_CD
                     ,  USER_ID
                     ,  POSITION_CD
                  FROM  HQ_USER             HU
                 WHERE  HU.COMP_CD      = PS_COMP_CD
                   AND  HU.USER_ID      = PS_USER_ID
                   AND  HU.USE_YN       = 'Y'
                UNION ALL
                SELECT  COMP_CD
                     ,  USER_ID
                     ,  ROLE_DIV        AS POSITION_CD
                  FROM  STORE_USER          SU
                 WHERE  SU.COMP_CD      = PS_COMP_CD
                   AND  SU.USER_ID      = PS_USER_ID
                   AND  SU.USE_YN       = 'Y'
            )   U
         ,  (
                SELECT  UDP.COMP_CD
                     ,  UDP.POSITION_CD
                     ,  UDP.FREE_DIV
                     ,  UDP.FREE_CNT_M
                     ,  UDP.FREE_CNT_D
                     ,  UDP.DC_DIV
                     ,  UDP.DC_CNT_M
                     ,  UDP.DC_CNT_D
                     ,  UDP.DC_CNT_B
                     ,  DD.DC_VALUE
                  FROM  USER_DC_POSITION    UDP
                     ,  DC                  DD
                 WHERE  UDP.COMP_CD     = DD.COMP_CD
                   AND  UDP.DC_DIV      = DD.DC_DIV
                   AND  UDP.COMP_CD     = PS_COMP_CD
                   AND  UDP.DC_YYYYMM   = (
                                                SELECT  MAX(DC_YYYYMM)
                                                  FROM  USER_DC_POSITION
                                                 WHERE  COMP_CD     = UDP.COMP_CD
                                                   AND  POSITION_CD = UDP.POSITION_CD
                                                   AND  DC_YYYYMM   <= SUBSTR(PS_SALE_DT, 1, 6)
                                                   AND  USE_YN      = 'Y'
                                          )
                   AND  UDP.USE_YN      = 'Y'
                   AND  DD.BRAND_CD     = '0000'
                   AND  DD.DML_FLAG     IN ('I', 'U')
            )                   UDP
     WHERE  U.COMP_CD       = UDP.COMP_CD
       AND  U.POSITION_CD   = UDP.POSITION_CD
    ;
    
    -- 월집계
    MERGE   INTO USER_DC
    USING   DUAL
       ON   (
                    COMP_CD     = PS_COMP_CD
                AND DC_DT       = SUBSTR(PS_SALE_DT, 1, 6)||'00'
                AND USER_ID     = PS_USER_ID
            )
    WHEN MATCHED  THEN
        UPDATE      
           SET  FREE_USE_M      = (
                                    CASE WHEN PS_DC_DIV = lsv_free_div AND PS_PROC_DIV = '1' THEN FREE_USE_M + 1
                                         WHEN PS_DC_DIV = lsv_free_div AND PS_PROC_DIV = '2' THEN FREE_USE_M - 1       
                                         ELSE FREE_USE_M 
                                    END
                                  )
             ,  DC_USE_M        = (
                                    CASE WHEN PS_DC_DIV = lsv_dc_div   AND PS_PROC_DIV = '1' THEN DC_USE_M + 1
                                         WHEN PS_DC_DIV = lsv_dc_div   AND PS_PROC_DIV = '2' THEN DC_USE_M - 1       
                                         ELSE DC_USE_M 
                                    END
                                  )
             ,  UPD_DT          = SYSDATE
             ,  UPD_USER        = 'SYSTEM'
    WHEN NOT MATCHED THEN
        INSERT 
        (
                COMP_CD
             ,  DC_DT
             ,  USER_ID
             ,  POSITION_CD
             ,  FREE_CNT_M
             ,  FREE_USE_M
             ,  FREE_CNT_D
             ,  FREE_DIV
             ,  DC_CNT_M
             ,  DC_USE_M
             ,  DC_CNT_D
             ,  DC_CNT_B
             ,  DC_DIV
             ,  DC_VALUE
             ,  INST_DT
             ,  INST_USER
             ,  UPD_DT
             ,  UPD_USER  
        ) VALUES (
                PS_COMP_CD
             ,  SUBSTR(PS_SALE_DT, 1, 6)||'00'
             ,  PS_USER_ID
             ,  lsv_position_cd
             ,  lsv_free_cnt_m
             ,  (
                    CASE WHEN PS_DC_DIV = lsv_free_div AND PS_PROC_DIV = '1' THEN  1
                         WHEN PS_DC_DIV = lsv_free_div AND PS_PROC_DIV = '2' THEN -1       
                         ELSE 0 
                    END
                )
             ,  lsv_free_cnt_d
             ,  lsv_free_div
             ,  lsv_dc_cnt_m
             ,  (
                    CASE WHEN PS_DC_DIV = lsv_dc_div   AND PS_PROC_DIV = '1' THEN  1
                         WHEN PS_DC_DIV = lsv_dc_div   AND PS_PROC_DIV = '2' THEN -1       
                         ELSE 0 
                    END
                )
             ,  lsv_dc_cnt_d
             ,  lsv_dc_cnt_b
             ,  lsv_dc_div
             ,  lsv_dc_value
             ,  SYSDATE
             ,  'SYSTEM'
             ,  SYSDATE
             ,  'SYSTEM'
    );
         
    -- 일집계
    MERGE   INTO USER_DC
    USING   DUAL
       ON   (
                    COMP_CD     = PS_COMP_CD
                AND DC_DT       = PS_SALE_DT
                AND USER_ID     = PS_USER_ID
            )
    WHEN MATCHED  THEN
        UPDATE      
           SET  FREE_USE_D      = (
                                    CASE WHEN PS_DC_DIV = lsv_free_div AND PS_PROC_DIV = '1' THEN FREE_USE_D + 1
                                         WHEN PS_DC_DIV = lsv_free_div AND PS_PROC_DIV = '2' THEN FREE_USE_D - 1       
                                         ELSE FREE_USE_D 
                                    END
                                  )
             ,  DC_USE_D        = (
                                    CASE WHEN PS_DC_DIV = lsv_dc_div   AND PS_PROC_DIV = '1' THEN DC_USE_D + 1
                                         WHEN PS_DC_DIV = lsv_dc_div   AND PS_PROC_DIV = '2' THEN DC_USE_D - 1       
                                         ELSE DC_USE_D 
                                    END
                                  )
             ,  UPD_DT          = SYSDATE
             ,  UPD_USER        = 'SYSTEM'
    WHEN NOT MATCHED THEN
        INSERT 
        (
                COMP_CD
             ,  DC_DT
             ,  USER_ID
             ,  POSITION_CD
             ,  FREE_CNT_M
             ,  FREE_CNT_D
             ,  FREE_USE_D
             ,  FREE_DIV
             ,  DC_CNT_M
             ,  DC_CNT_D
             ,  DC_USE_D
             ,  DC_CNT_B
             ,  DC_DIV
             ,  DC_VALUE
             ,  INST_DT
             ,  INST_USER
             ,  UPD_DT
             ,  UPD_USER  
        ) VALUES (
                PS_COMP_CD
             ,  PS_SALE_DT
             ,  PS_USER_ID
             ,  lsv_position_cd
             ,  lsv_free_cnt_m
             ,  lsv_free_cnt_d
             ,  (
                    CASE WHEN PS_DC_DIV = lsv_free_div AND PS_PROC_DIV = '1' THEN  1
                         WHEN PS_DC_DIV = lsv_free_div AND PS_PROC_DIV = '2' THEN -1       
                         ELSE 0 
                    END
                )
             ,  lsv_free_div
             ,  lsv_dc_cnt_m
             ,  lsv_dc_cnt_d
             ,  (
                    CASE WHEN PS_DC_DIV = lsv_dc_div   AND PS_PROC_DIV = '1' THEN  1
                         WHEN PS_DC_DIV = lsv_dc_div   AND PS_PROC_DIV = '2' THEN -1       
                         ELSE 0 
                    END
                )
             ,  lsv_dc_cnt_b
             ,  lsv_dc_div
             ,  lsv_dc_value
             ,  SYSDATE
             ,  'SYSTEM'
             ,  SYSDATE
             ,  'SYSTEM'
    );
    
    PR_RETURN_MSG   := FC_GET_WORDPACK_MSG(PS_COMP_CD, PS_LANGUAGE, '1010001392'); -- 정상처리 되었습니다.
    
    COMMIT;
    
    OPEN PR_RESULT FOR
        SELECT  PR_RETURN_CD
          FROM  DUAL;
              
    EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
    
    RETURN;
    
EXCEPTION
    WHEN ERR_HANDLER THEN
        OPEN PR_RESULT FOR
            SELECT  PR_RETURN_CD
              FROM  DUAL;
        
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
            
        RETURN;
        
    WHEN OTHERS THEN
        PR_RETURN_CD  := '9999';
        PR_RETURN_MSG := FC_GET_WORDPACK_MSG(PS_COMP_CD, PS_LANGUAGE, '1004999999');  -- 자료처리중 오류가 발생했습니다. 관리자에게 문의하여 주십시오.
        --PR_RETURN_MSG := SQLERRM;
        
        OPEN PR_RESULT FOR
            SELECT  PR_RETURN_CD
              FROM  DUAL;
              
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
            
        RETURN;
        
END;

PROCEDURE SP_GET_STORE_ETC_AMT
  (
    PSV_COMP_CD    IN   VARCHAR2, -- 회사코드
    PSV_BRAND_CD   IN   VARCHAR2, -- Brand Code
    PSV_STOR_CD    IN   VARCHAR2, -- Store Code
    PSV_LANGUAGE   IN   VARCHAR2, -- 언어타입
    PSV_STR_DT     IN   VARCHAR2, -- 조회시작일자 
    PSV_END_DT     IN   VARCHAR2, -- 조회시작일자
    PR_RTN_CD      OUT  VARCHAR2, -- 처리코드
    PR_RTN_MSG     OUT  VARCHAR2, -- 처리Message
    PR_CURSOR      OUT REC_SET.M_REFCUR
  ) IS
    ERR_HANDLER        EXCEPTION;
  BEGIN
    PR_RTN_CD       := '0000';
    PR_RTN_MSG      := '정상처리';
    
    OPEN PR_CURSOR FOR
        SELECT  COMP_CD
              , PRC_DT
              , BRAND_CD
              , STOR_CD
              , POS_NO
              , ETC_DIV
              , SEQ
              , USER_ID
              , CONFIRM_YN
              , CONFIRM_DT
              , ETC_CD
              , RMK_SEQ
              , EVID_DOC
              , ETC_AMT
              , ETC_AMT_HQ
              , ETC_DESC
              , HQ_USER_ID
              , BANK_NM
              , ACC_NO
              , ACC_NM
        FROM    STORE_ETC_AMT
        WHERE   COMP_CD    = PSV_COMP_CD
        AND     BRAND_CD   = PSV_BRAND_CD
        AND     STOR_CD    = PSV_STOR_CD
        AND     PRC_DT BETWEEN PSV_STR_DT AND PSV_END_DT
        AND     DEL_YN     = 'N';
  EXCEPTION
    WHEN OTHERS THEN
        PR_RTN_CD       := '9999';
        PR_RTN_MSG      := SQLERRM;
        
        OPEN PR_CURSOR FOR
            SELECT  '9999' FAIL 
            FROM    DUAL;
  END;
  
  PROCEDURE SP_SET_STORE_ETC_AMT
  (
    PSV_COMP_CD    IN   VARCHAR2, -- 회사코드
    PSV_BRAND_CD   IN   VARCHAR2, -- Brand Code
    PSV_STOR_CD    IN   VARCHAR2, -- Store Code
    PSV_LANGUAGE   IN   VARCHAR2, -- 언어타입
    PSV_PRC_DT     IN   VARCHAR2, -- PROCESS Date
    PSV_POS_NO     IN   VARCHAR2, -- POS NO
    PSV_ETC_DIV    IN   VARCHAR2, -- 입출금구분[01:입금계정, 02:출금계정]
    PSV_SEQ        IN   VARCHAR2, -- 순번[입금 : SEQ, 출금 :(신규:0, 수정:SEQ)]
    PSV_USER_ID    IN   VARCHAR2, -- 매장담당자코드
    PSV_CONFIRM_YN IN   VARCHAR2, -- 확정유무[Y/N]
    PSV_CONFIRM_DT IN   VARCHAR2, -- YYYYMMDD
    PSV_ETC_CD     IN   VARCHAR2, -- 계정코드
    PSV_RMK_SEQ    IN   VARCHAR2, -- 적요순번
    PSV_EVID_DOC   IN   VARCHAR2, -- 증빙서류[00:해당없음,01:세금계산서,02:간이영수증,03:면세품계산서,04:신용카드지출전표] 
    PSV_ETC_DESC   IN   VARCHAR2, -- 입출금내역
    PSV_ETC_AMT    IN   VARCHAR2, -- 입출금금액
    PSV_DEL_YN     IN   VARCHAR2, -- 삭제여부
    PR_RTN_CD      OUT  VARCHAR2, -- 처리코드
    PR_RTN_MSG     OUT  VARCHAR2, -- 처리Message
    PR_CURSOR      OUT REC_SET.M_REFCUR
  ) IS
    ERR_HANDLER        EXCEPTION;
    
    nRECCNT         NUMBER;
    
    
    vUSE_YN         ACC_MST.USE_YN%TYPE;
    vCONFIRM_YN     STORE_ETC_AMT.CONFIRM_YN%TYPE;
    nMAX_SEQ        STORE_ETC_AMT.SEQ%TYPE;
  BEGIN
    PR_RTN_CD       := '0000';
    PR_RTN_MSG      := '정상처리';
    
    SELECT  COUNT(*), MAX(USE_YN) INTO nRECCNT, vUSE_YN
    FROM    ACC_MST
    WHERE   COMP_CD = PSV_COMP_CD
    AND     ETC_CD  = PSV_ETC_CD
    AND     STOR_TP =  (
                        SELECT  STOR_TP 
                        FROM    STORE 
                        WHERE   COMP_CD  = PSV_COMP_CD
                        AND     BRAND_CD = PSV_BRAND_CD
                        AND     STOR_CD  = PSV_STOR_CD
                       );
    
    IF nRECCNT = 0 THEN
        PR_RTN_CD := '1001';
        PR_RTN_MSG := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANGUAGE, '1010001615');     -- 계정코드 입력 오류입니다.
        RAISE ERR_HANDLER;
    ELSIF vUSE_YN = 'N' THEN
        PR_RTN_CD := '1002';
        PR_RTN_MSG := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANGUAGE, '1010001616');     -- 미사용된 계정코드 입니다.
        RAISE ERR_HANDLER;
    END IF;
    
    SELECT  COUNT(*), MAX(USE_YN) INTO nRECCNT, vUSE_YN
    FROM    ACC_RMK
    WHERE   COMP_CD = PSV_COMP_CD
    AND     ETC_CD  = PSV_ETC_CD
    AND     RMK_SEQ = PSV_RMK_SEQ
    AND     STOR_TP =  (
                        SELECT  STOR_TP 
                        FROM    STORE 
                        WHERE   COMP_CD  = PSV_COMP_CD
                        AND     BRAND_CD = PSV_BRAND_CD
                        AND     STOR_CD  = PSV_STOR_CD
                       );
    
    IF nRECCNT = 0 THEN
        PR_RTN_CD := '1003';
        PR_RTN_MSG := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANGUAGE, '1010001617');     -- 계정 적요코드 입력 오류입니다.
        RAISE ERR_HANDLER;
    ELSIF vUSE_YN = 'N' THEN
        PR_RTN_CD := '1004';
        PR_RTN_MSG := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANGUAGE, '1010001618');     -- 미사용된 계정 적요코드 입니다.
        RAISE ERR_HANDLER;
    END IF;
    
    SELECT  COUNT(*), MAX(CONFIRM_YN) INTO nRECCNT, vCONFIRM_YN
    FROM    STORE_ETC_AMT
    WHERE   COMP_CD     = PSV_COMP_CD
    AND     PRC_DT      = PSV_PRC_DT
    AND     BRAND_CD    = PSV_BRAND_CD
    AND     STOR_CD     = PSV_STOR_CD
    AND     POS_NO      = PSV_POS_NO
    AND     ETC_DIV     = PSV_ETC_DIV
    AND     SEQ         = PSV_SEQ;
                       
    IF PSV_ETC_DIV = '01' AND PSV_DEL_YN = 'Y' THEN
        PR_RTN_CD := '1005';
        PR_RTN_MSG := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANGUAGE, '1010001619');     -- 입금 계정은 삭제 할 수 없습니다.
        RAISE ERR_HANDLER;
    ELSIF vCONFIRM_YN = 'Y' AND PSV_DEL_YN = 'Y' THEN
        PR_RTN_CD := '1006';
        PR_RTN_MSG := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANGUAGE, '1010001620');     -- 확정된 입출금 내역은 삭제 할 수 없습니다.
        RAISE ERR_HANDLER;
    ELSIF vCONFIRM_YN = 'Y' THEN
        PR_RTN_CD := '1007';
        PR_RTN_MSG := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANGUAGE, '1010001621');     -- 확정된 입출금 내역은 수정 할 수 없습니다.
        RAISE ERR_HANDLER;
    END IF;
    
    IF PSV_ETC_DIV = '01' THEN
        IF PSV_CONFIRM_YN = 'Y' THEN
            UPDATE  STORE_ETC_AMT
            SET     CONFIRM_YN  = PSV_CONFIRM_YN
                  , CONFIRM_DT  = PSV_CONFIRM_DT
            WHERE   COMP_CD     = PSV_COMP_CD
            AND     PRC_DT      = PSV_PRC_DT
            AND     BRAND_CD    = PSV_BRAND_CD
            AND     STOR_CD     = PSV_STOR_CD
            AND     POS_NO      = PSV_POS_NO
            AND     ETC_DIV     = PSV_ETC_DIV
            AND     SEQ         = PSV_SEQ;
        END IF;
    ELSE 
        IF TO_NUMBER(PSV_SEQ) = 0 THEN
            -- 일련번호 채번
            SELECT  NVL(MAX(SEQ), 1) + 1 INTO nMAX_SEQ
            FROM    STORE_ETC_AMT
            WHERE   COMP_CD     = PSV_COMP_CD
            AND     PRC_DT      = PSV_PRC_DT
            AND     BRAND_CD    = PSV_BRAND_CD
            AND     STOR_CD     = PSV_STOR_CD
            AND     POS_NO      = PSV_POS_NO
            AND     ETC_DIV     = PSV_ETC_DIV;
        ELSE            
            nMAX_SEQ := TO_NUMBER(PSV_SEQ);
        END IF;
        
        -- 출금내역 작성
        MERGE INTO STORE_ETC_AMT SEA
        USING DUAL
        ON (
                COMP_CD     = PSV_COMP_CD
            AND PRC_DT      = PSV_PRC_DT
            AND BRAND_CD    = PSV_BRAND_CD
            AND STOR_CD     = PSV_STOR_CD
            AND POS_NO      = PSV_POS_NO
            AND ETC_DIV     = PSV_ETC_DIV
            AND SEQ         = nMAX_SEQ
           )
        WHEN MATCHED THEN
            UPDATE
            SET CONFIRM_YN  = PSV_CONFIRM_YN
              , CONFIRM_DT  = PSV_CONFIRM_DT
              , ETC_AMT     = PSV_ETC_AMT
              , ETC_AMT_HQ  = CASE WHEN CONFIRM_YN = 'R' THEN TO_NUMBER(PSV_ETC_AMT) ELSE ETC_AMT_HQ END
              , USER_ID     = PSV_USER_ID
              , ETC_TM      = TO_CHAR(SYSDATE, 'HH24MISS')
              , EVID_DOC    = PSV_EVID_DOC
              , ETC_DESC    = PSV_ETC_DESC
              , DEL_YN      = PSV_DEL_YN
              , UPD_DT      = SYSDATE
              , UPD_USER    = PSV_USER_ID
        WHEN NOT MATCHED THEN
            INSERT
           (
            COMP_CD     , PRC_DT
          , BRAND_CD    , STOR_CD
          , POS_NO      , ETC_DIV
          , SEQ         , ETC_CD
          , ETC_AMT     , ETC_AMT_HQ
          , CARD_AMT    
          , CUST_ID     , USER_ID
          , ETC_TP      , ETC_TM
          , RMK_SEQ     , EVID_DOC,     ETC_DESC
          , PURCHASE_CD , STOR_PAY_DIV    
          , APPR_NO     , APPR_DT    
          , APPR_TM
          , HQ_USER_ID
          , BANK_NM     , ACC_NO    
          , ACC_NM    
          , INPUT_TP    , SEQ_EXCEL
          , REMARKS    
          , CONFIRM_YN  , CONFIRM_DT
          , DEL_YN
          , INST_DT     , INST_USER    
          , UPD_DT      , UPD_USER
           )
            VALUES
           (
            PSV_COMP_CD     , PSV_PRC_DT
          , PSV_BRAND_CD    , PSV_STOR_CD
          , PSV_POS_NO      , PSV_ETC_DIV
          , nMAX_SEQ        , PSV_ETC_CD
          , PSV_ETC_AMT     , PSV_ETC_AMT
          , 0    
          , NULL            , PSV_USER_ID
          , NULL            , TO_CHAR(SYSDATE, 'HH24MISS')
          , PSV_RMK_SEQ     , PSV_EVID_DOC,     PSV_ETC_DESC
          , NULL            , '02'    
          , NULL            , NULL    
          , NULL
          , NULL
          , NULL            , NULL    
          , NULL    
          , '0'             , NULL
          , PSV_ETC_DESC    
          , PSV_CONFIRM_YN  , PSV_CONFIRM_DT
          , PSV_DEL_YN
          , SYSDATE         , PSV_USER_ID    
          , SYSDATE         , PSV_USER_ID
           );
        END IF;
        
        OPEN PR_CURSOR FOR
            SELECT  '0000' SUCCESS
            FROM    DUAL;
  EXCEPTION
    WHEN ERR_HANDLER THEN
        OPEN PR_CURSOR FOR
            SELECT  PR_RTN_CD FAIL
              FROM  DUAL;
            
        RETURN;
    WHEN OTHERS THEN
        PR_RTN_CD       := '9999';
        PR_RTN_MSG      := SQLERRM;
        
        OPEN PR_CURSOR FOR
            SELECT  PR_RTN_CD FAIL
            FROM    DUAL;
            
        RETURN;
  END;
      
END PKG_DC_APPR;

/
