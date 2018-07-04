CREATE OR REPLACE PACKAGE       PKG_GC_APPR AS
  ------------------------------------------------------------------------------
  --  Package Name     : PKG_GC_APPR
  --  Description      : GIFT CERTIFICATE PAYMENT APPROVAL
  ------------------------------------------------------------------------------
  --  Create Date      : 2013-02-14
  --  Create Programer :
  --  Modify Date      :
  --  Modify Programer :
  ------------------------------------------------------------------------------
  FUNCTION UF_GET_APP_SEQ RETURN  VARCHAR2;
  
  PROCEDURE SP_GC_APPR_LOG
  ( 
    ps_app_no        IN   STRING, -- 승인번호
    ps_in_gc_no      IN   STRING, -- 상품권번호
    ps_in_comp_cd    IN   STRING, -- 회사코드
    ps_in_brand_cd   IN   STRING, -- 브랜드코드
    ps_in_stor_cd    IN   STRING, -- 점포코드
    ps_in_sale_dt    IN   STRING, -- 판매일TR_DIVTR_DIV자
    ps_in_pos_no     IN   STRING, -- POS NO
    ps_in_bill_no    IN   STRING, -- BILL NO
    ps_in_req_user   IN   STRING, -- 요청자
    ps_in_req_proc   IN   STRING, -- 승인처리경로('1':점포, '2': 자동(SYSTEM), '3':강제처리(고객센터), '4':망취소)
    ps_in_req_div    IN   STRING, -- 요청구분 (10:승인  20:조회  40:망상취소)
    ps_in_sale_div   IN   STRING, -- 정상/반품(0200:정상, 0420:반품)
    ps_in_o_sale_dt  IN   STRING, -- 원거래일자
    ps_in_o_bill_no  IN   STRING, -- 원거래승인번호
    ps_in_fail_cd    IN   STRING, -- 승인실패 상세코드
    ps_sysdate       IN   STRING,
    ps_msg_code      IN   STRING,
    ps_msg_text      IN   STRING,
    ps_pre_app_no    IN   STRING,
    pn_price         IN   NUMBER,
    pn_return_cd     OUT  NUMBER, -- 메세지코드
    ps_return_msg    OUT  STRING  -- 메세지코드
  );
  
  PROCEDURE SP_GC_APPR_NPOS
  (
    ps_in_gc_no      IN   VARCHAR2, -- GC No.
    ps_in_comp_cd    IN   VARCHAR2, -- 회사코드
    ps_in_brand_cd   IN   VARCHAR2, -- Brand Code
    ps_in_stor_cd    IN   VARCHAR2, -- Store Code
    ps_in_sale_dt    IN   VARCHAR2, -- Sale Date
    ps_in_pos_no     IN   VARCHAR2, -- POS NO
    ps_in_bill_no    IN   VARCHAR2, -- BILL NO
    ps_in_req_user   IN   VARCHAR2, -- Request User
    ps_in_req_proc   IN   VARCHAR2, -- Procees Channel ('1':Store , '2': SYSTEM , '3': Call Center , '4':On-Line Cancel at Process Error)
    ps_in_req_div    IN   VARCHAR2, -- Request Type (10:Approval  20:Retrieval  40:On-Line Cancel at Process Error)
    ps_in_sale_div   IN   VARCHAR2, -- Sale/Return(0200:Sale, 0420:Return)
    ps_in_o_sale_dt  IN   VARCHAR2, -- Sale Date
    ps_in_o_bill_no  IN   VARCHAR2, -- Bill No.
    ps_out_rtn_cd    OUT  VARCHAR2, -- Result Message
    ps_out_msg1      OUT  VARCHAR2, -- Message1
    ps_out_msg2      OUT  VARCHAR2, -- Message1
    ps_out_msg3      OUT  VARCHAR2, -- Message1
    ps_gc_cd         OUT  VARCHAR2, -- GC Price Type
    ps_gc_nm         OUT  VARCHAR2, -- 상품권명
    ps_gc_prc        OUT  VARCHAR2, -- GC Price
    ps_out_appr_tm   OUT  VARCHAR2, -- Approval Time
    ps_out_appr_no   OUT  VARCHAR2  -- Approval No.
  );
END PKG_GC_APPR;

/

CREATE OR REPLACE PACKAGE BODY       PKG_GC_APPR AS
  
  FUNCTION UF_GET_APP_SEQ
  RETURN  VARCHAR2
  IS
    ls_app_seq   VARCHAR2(12);
  BEGIN
    --------------------------------------------------------------------------
    --  GET SEQUENCE NUMBER
    --  TRANSACTION LOG DATA
    --------------------------------------------------------------------------
    SELECT  TO_CHAR(SEQ_APP_SEQ.NEXTVAL,'FM099999999999')
        INTO ls_app_seq
        FROM DUAL;
        
      RETURN ls_app_seq;
      
    END;
  
  PROCEDURE SP_GC_APPR_LOG
  (
    ps_app_no        IN   STRING, -- 승인번호
    ps_in_gc_no      IN   STRING, -- 상품권번호
    ps_in_comp_cd    IN   STRING, -- 회사코드
    ps_in_brand_cd   IN   STRING, -- 브랜드코드
    ps_in_stor_cd    IN   STRING, -- 점포코드
    ps_in_sale_dt    IN   STRING, -- 판매일자
    ps_in_pos_no     IN   STRING, -- POS NO
    ps_in_bill_no    IN   STRING, -- BILL NO
    ps_in_req_user   IN   STRING, -- 요청자
    ps_in_req_proc   IN   STRING, -- 승인처리경로('1':점포, '2': 자동(SYSTEM), '3':강제처리(고객센터), '4':망취소)
    ps_in_req_div    IN   STRING, -- 요청구분 (10:승인  20:조회  40:망상취소)
    ps_in_sale_div   IN   STRING, -- 정상/반품(0200:정상, 0420:반품)
    ps_in_o_sale_dt  IN   STRING, -- 원거래일자
    ps_in_o_bill_no  IN   STRING, -- 원거래승인번호
    ps_in_fail_cd    IN   STRING, -- 승인실패 상세코드
    ps_sysdate       IN   STRING,
    ps_msg_code      IN   STRING,
    ps_msg_text      IN   STRING,
    ps_pre_app_no    IN   STRING,
    pn_price         IN   NUMBER,
    pn_return_cd     OUT  NUMBER, -- 메세지코드
    ps_return_msg    OUT  STRING  -- 메세지코드
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    li_cnt1     PLS_INTEGER := 0 ;
    li_cnt2     PLS_INTEGER := 0 ;
    li_cnt3     PLS_INTEGER := 0 ;
    lnv_return_cd   PLS_INTEGER := 0 ;
    lsv_return_msg   VARCHAR2(400);
    ERR_HANDLER     EXCEPTION;
  BEGIN
    pn_return_cd  := 0;
    
    BEGIN
      SELECT NVL(SAME_FAIL_CNT,0) + 1,  NVL(OTHER_FAIL_CNT,0) + 1
        INTO li_cnt1 , li_cnt2
        FROM GIFT_SVR_LOG  A
       WHERE COMP_CD = ps_in_comp_cd
         AND APPR_NO = (SELECT MAX(APPR_NO)
                          FROM GIFT_SVR_LOG B
                         WHERE B.GIFT_NO = ps_in_gc_no
                           AND B.RTN_CD  = '0003'
                           AND  B.TR_DIV = '0200'
                       );
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
           li_cnt3 := 1;
      WHEN OTHERS THEN
           lnv_return_cd    := -1;
           lsv_return_msg   := SQLERRM;
           RAISE ERR_HANDLER;
    END;
    IF ps_msg_code = '0003' AND ps_in_sale_div = '0200' THEN
       BEGIN
         SELECT NVL(SAME_FAIL_CNT,0) + 1,  NVL(OTHER_FAIL_CNT,0) + 1
           INTO li_cnt1 , li_cnt2
           FROM GIFT_SVR_LOG  A
          WHERE COMP_CD = ps_in_comp_cd
            AND APPR_NO = (SELECT MAX(APPR_NO)
                             FROM GIFT_SVR_LOG B
                            WHERE B.GIFT_NO = ps_in_gc_no
                              AND B.RTN_CD  = '0003'
                              AND B.TR_DIV  = '0200' );
       EXCEPTION
          WHEN NO_DATA_FOUND THEN
               IF ps_in_fail_cd = '01' THEN
                  li_cnt1 := 1;
                  li_cnt2 := 0;
               ELSE
                  li_cnt1 := 0;
                  li_cnt2 := 1;
               END IF;
          WHEN OTHERS THEN
               lnv_return_cd    := -1;
               lsv_return_msg   := SQLERRM;
               RAISE ERR_HANDLER;
       END ;
    END IF;
    
    INSERT INTO GIFT_SVR_LOG
           (COMP_CD         ,
            APPR_NO         ,
            APPR_PATH       ,
            TR_DIR          ,
            TR_DIV          ,
            TR_TP           ,
            BRAND_CD        ,
            STOR_CD         ,
            SALE_DT         ,
            POS_NO          ,
            BILL_NO         ,
            WCC             ,
            APPR_DT_BF      ,
            APPR_NO_BF      ,
            APPR_TM         ,
            REQ_PRICE       ,
            MSG1            ,
            GIFT_NO         ,
            PRC_STAT        ,
            RTN_CD          ,
            FAIL_CD         ,
            SAME_FAIL_CNT   ,
            OTHER_FAIL_CNT  ,
            TOTAL_FAIL_CNT  ,
            USE_YN          ,
            INST_DT         ,
            INST_USER       ,
            UPD_DT          ,
            UPD_USER
            )
    VALUES
           (ps_in_comp_cd   ,
            ps_app_no       ,
            ps_in_req_proc  ,
            '3'             ,
            ps_in_sale_div  ,
            ps_in_req_div   ,
            ps_in_brand_cd  ,
            ps_in_stor_cd   ,
            ps_in_sale_dt   ,
            ps_in_pos_no    ,
            ps_in_bill_no   ,
             'A'            ,
            ps_in_o_sale_dt ,
            ps_in_o_bill_no ,
            ps_sysdate      ,
            pn_price        ,
            ps_msg_text     ,
            ps_in_gc_no     ,
            'N'             ,
            ps_msg_code     ,
            ps_in_fail_cd   ,
            li_cnt1         ,
            li_cnt2         ,
            li_cnt3         ,
            'Y'             ,
            SYSDATE         ,
            ps_in_req_user  ,
            SYSDATE         ,
            ps_in_req_user
            );
            
    COMMIT;
    
  EXCEPTION
    WHEN ERR_HANDLER THEN
         pn_return_cd    := lnv_return_cd;
         ps_return_msg   := lsv_return_msg;
    WHEN OTHERS THEN
         pn_return_cd    := -1;
         ps_return_msg   := SUBSTR(SQLERRM, 1, 400);
  END;
  
  PROCEDURE SP_GC_APPR_POS
  (
    ps_in_gc_no      IN   VARCHAR2, -- GC No.
    ps_in_comp_cd    IN   VARCHAR2, -- 회사코드
    ps_in_brand_cd   IN   VARCHAR2, -- Brand Code
    ps_in_stor_cd    IN   VARCHAR2, -- Store Code
    ps_in_sale_dt    IN   VARCHAR2, -- Sale Date
    ps_in_pos_no     IN   VARCHAR2, -- POS NO
    ps_in_bill_no    IN   VARCHAR2, -- BILL NO
    ps_in_req_user   IN   VARCHAR2, -- Request User
    ps_in_req_proc   IN   VARCHAR2, -- Procees Channel ('1':Store , '2': SYSTEM , '3': Call Center , '4':On-Line Cancel at Process Error , '5':HQ)
    ps_in_req_div    IN   VARCHAR2, -- Request Type (10:Approval  20:Retrieval  40:On-Line Cancel at Process Error)
    ps_in_sale_div   IN   VARCHAR2, -- Sale/Return(0200:Sale, 0420:Return)
    ps_in_o_sale_dt  IN   VARCHAR2, -- Sale Date
    ps_in_o_bill_no  IN   VARCHAR2, -- Bill No.
    ps_out_rtn_cd    IN OUT  VARCHAR2, -- Result Message
    ps_out_msg1      OUT  VARCHAR2, -- Message1
    ps_out_msg2      OUT  VARCHAR2, -- Message1
    ps_out_msg3      OUT  VARCHAR2, -- Message1
    ps_gc_cd         OUT  VARCHAR2, -- GC Price Type
    ps_gc_nm         OUT  VARCHAR2, -- 상품권명
    ps_gc_prc        OUT  VARCHAR2, -- GC Price
    ps_out_appr_tm   OUT  VARCHAR2, -- Approval Time
    ps_out_appr_no   OUT  VARCHAR2  -- Approval No.
  ) IS
    lsv_language    VARCHAR2(3);
    lsv_msg_code    VARCHAR2(4) := '0000';
    lsv_msg_text    VARCHAR2(400);
    lsv_msg0        VARCHAR2(90);
    lsv_msg1        VARCHAR2(90);
    lsv_msg2        VARCHAR2(90);
    lsv_msg3        VARCHAR2(90);
    lsv_msg4        VARCHAR2(90);
    lsv_msg5        VARCHAR2(90);
    lsv_msg6        VARCHAR2(90);
    lsv_msg7        VARCHAR2(90);
    lsv_msg8        VARCHAR2(90);
    lsv_msg9        VARCHAR2(90);
    lsv_msg10       VARCHAR2(90);
    lsv_msg11       VARCHAR2(90);
    lsv_msg12       VARCHAR2(90);
    lsv_msg20       VARCHAR2(90);
    lsv_msg21       VARCHAR2(90);
    lsv_msg22       VARCHAR2(90);
    lsv_msg23       VARCHAR2(90);
    lsv_msg31       VARCHAR2(90);
    lsv_msg32       VARCHAR2(90);
    lsv_msg33       VARCHAR2(90);
    lsv_msg34       VARCHAR2(90);
    lsv_out_msg2    VARCHAR2(90);
    lsv_out_msg3    VARCHAR2(90);
    lsv_stor_nm     VARCHAR2(80);
    lsv_gift_stat   GIFT_MST.GIFT_STAT_CD%TYPE;
    lsv_gift_stat2  GIFT_MST.GIFT_STAT_CD%TYPE;
    prev_gift_stat  GIFT_MST.GIFT_STAT_CD%TYPE;
    lsv_exp_dt      GIFT_MST.EXP_DT%TYPE;
    lsv_gv_cd       GIFT_MST.GIFT_CD%TYPE;
    lsv_app_seq     GIFT_SVR_LOG.APPR_NO%TYPE;
    lsv_pre_app_no  GIFT_SVR_LOG.APPR_NO%TYPE;
    lnv_price       GIFT_SVR_LOG.REQ_PRICE%TYPE;
    lsv_brand_cd    GIFT_MST.BRAND_CD%TYPE;
    lsv_issue_brand GIFT_MST.BRAND_CD%TYPE;
    lsv_code_cd     COMMON.CODE_CD%TYPE;
    lsv_code_nm     COMMON.CODE_NM%TYPE;
    lsv_proc_st     GIFT_SVR_LOG.PRC_STAT%TYPE;
    lsv_o_comp_cd   GIFT_MST.COMP_CD%TYPE;
    lsv_o_brand_cd  GIFT_MST.S_BRAND_CD%TYPE;
    lsv_o_stor_cd   GIFT_MST.S_STOR_CD%TYPE;
    lsv_o_sale_dt   GIFT_MST.S_SALE_DT%TYPE;
    lsv_o_pos_no    GIFT_MST.S_POS_NO%TYPE;
    lsv_o_bill_no   GIFT_MST.S_BILL_NO%TYPE;
    ls_fail_cd      GIFT_SVR_LOG.FAIL_CD%TYPE;
    lsv_sysdate     VARCHAR2(14);
    lnv_return_cd   PLS_INTEGER;
    lsv_return_msg  VARCHAR2(400);
    
    ERR_HANDLER     EXCEPTION;
  BEGIN
  
    lsv_msg_text    := '정상 처리';
    
    BEGIN
      SELECT A.LANGUAGE_TP
        INTO lsv_language
        FROM BRAND A
           , (SELECT  COMP_CD
                   ,  COMP_NM
                FROM  COMPANY
               WHERE  COMP_CD = ps_in_comp_cd
             ) B
       WHERE A.COMP_CD  = B.COMP_CD
         AND A.COMP_CD  = ps_in_comp_cd
         AND A.BRAND_CD = ps_in_brand_cd
         AND A.USE_YN   = 'Y';
    EXCEPTION
      WHEN OTHERS THEN
           lsv_msg_code   := '9999';
           lsv_msg_text   := '10 ' || SQLERRM;
           RAISE ERR_HANDLER;
    END;
    
    BEGIN
      --ㅡ처리 Message 조회
      SELECT MAX(CASE WHEN C.CODE_CD = '0000' THEN NVL(L.CODE_NM, C.CODE_NM) ELSE NULL END)  MSG0,
             MAX(CASE WHEN C.CODE_CD = '0001' THEN NVL(L.CODE_NM, C.CODE_NM) ELSE NULL END)  MSG1,
             MAX(CASE WHEN C.CODE_CD = '0002' THEN NVL(L.CODE_NM, C.CODE_NM) ELSE NULL END)  MSG2,
             MAX(CASE WHEN C.CODE_CD = '0003' THEN NVL(L.CODE_NM, C.CODE_NM) ELSE NULL END)  MSG3,
             MAX(CASE WHEN C.CODE_CD = '0004' THEN NVL(L.CODE_NM, C.CODE_NM) ELSE NULL END)  MSG4,
             MAX(CASE WHEN C.CODE_CD = '0005' THEN NVL(L.CODE_NM, C.CODE_NM) ELSE NULL END)  MSG5,
             MAX(CASE WHEN C.CODE_CD = '0006' THEN NVL(L.CODE_NM, C.CODE_NM) ELSE NULL END)  MSG6,
             MAX(CASE WHEN C.CODE_CD = '0007' THEN NVL(L.CODE_NM, C.CODE_NM) ELSE NULL END)  MSG7,
             MAX(CASE WHEN C.CODE_CD = '0008' THEN NVL(L.CODE_NM, C.CODE_NM) ELSE NULL END)  MSG8,
             MAX(CASE WHEN C.CODE_CD = '0009' THEN NVL(L.CODE_NM, C.CODE_NM) ELSE NULL END)  MSG9,
             MAX(CASE WHEN C.CODE_CD = '0010' THEN NVL(L.CODE_NM, C.CODE_NM) ELSE NULL END)  MSG10,
             MAX(CASE WHEN C.CODE_CD = '0011' THEN NVL(L.CODE_NM, C.CODE_NM) ELSE NULL END)  MSG11,
             MAX(CASE WHEN C.CODE_CD = '0012' THEN NVL(L.CODE_NM, C.CODE_NM) ELSE NULL END)  MSG12,
             MAX(CASE WHEN C.CODE_CD = '0020' THEN NVL(L.CODE_NM, C.CODE_NM) ELSE NULL END)  MSG20,
             MAX(CASE WHEN C.CODE_CD = '0021' THEN NVL(L.CODE_NM, C.CODE_NM) ELSE NULL END)  MSG21,
             MAX(CASE WHEN C.CODE_CD = '0022' THEN NVL(L.CODE_NM, C.CODE_NM) ELSE NULL END)  MSG22,
             MAX(CASE WHEN C.CODE_CD = '0023' THEN NVL(L.CODE_NM, C.CODE_NM) ELSE NULL END)  MSG23,
             MAX(CASE WHEN C.CODE_CD = '0031' THEN NVL(L.CODE_NM, C.CODE_NM) ELSE NULL END)  MSG31,
             MAX(CASE WHEN C.CODE_CD = '0032' THEN NVL(L.CODE_NM, C.CODE_NM) ELSE NULL END)  MSG32,
             MAX(CASE WHEN C.CODE_CD = '0033' THEN NVL(L.CODE_NM, C.CODE_NM) ELSE NULL END)  MSG33,
             MAX(CASE WHEN C.CODE_CD = '0034' THEN NVL(L.CODE_NM, C.CODE_NM) ELSE NULL END)  MSG34
        INTO lsv_msg0,  lsv_msg1,  lsv_msg2,  lsv_msg3,  lsv_msg4,
             lsv_msg5,  lsv_msg6,  lsv_msg7,  lsv_msg8,  lsv_msg9,
             lsv_msg10, lsv_msg11, lsv_msg12, lsv_msg20, lsv_msg21, lsv_msg22,
             lsv_msg23, lsv_msg31, lsv_msg32, lsv_msg33, lsv_msg34
        FROM COMMON C
           , (SELECT COMP_CD
                   , CODE_CD
                   , CODE_NM
                FROM LANG_COMMON
               WHERE COMP_CD     = ps_in_comp_cd
                 AND CODE_TP     = '17570'
                 AND LANGUAGE_TP = lsv_language
                 AND USE_YN      = 'Y'
             ) L
       WHERE C.COMP_CD = L.COMP_CD(+)
         AND C.CODE_CD = L.CODE_CD(+)
         AND C.COMP_CD = ps_in_comp_cd
         AND C.CODE_TP = '17570'
         AND C.USE_YN  = 'Y';
    EXCEPTION
      WHEN OTHERS THEN
           lsv_msg_code   := '9999';
           lsv_msg_text   := '20 ' || SQLERRM;
           RAISE ERR_HANDLER;
    END;
    
    BEGIN
      BEGIN
         SELECT A.GIFT_STAT_CD, A.S_APPR_NO   , A.GIFT_CD    , A.PRICE      , A.BRAND_CD  , B.CODE_CD    , NVL(LC.CODE_NM, B.CODE_NM), A.EXP_DT,
                A.COMP_CD     , A.S_BRAND_CD  , A.S_STOR_CD  , A.S_SALE_DT  , A.S_POS_NO  , A.S_BILL_NO  , NVL(LS.STOR_NM, D.STOR_NM), E.BRAND_CD,
                GL.GIFT_STAT_CD
           INTO lsv_gift_stat , lsv_app_seq   , lsv_gv_cd    , lnv_price    , lsv_brand_cd, lsv_code_cd  , lsv_CODE_NM               , lsv_exp_dt,
                lsv_o_comp_cd , lsv_o_brand_cd, lsv_o_stor_cd, lsv_o_sale_dt, lsv_o_pos_no, lsv_o_bill_no, lsv_stor_nm               , lsv_issue_brand,
                prev_gift_stat
           FROM GIFT_MST A
              , (SELECT COMP_CD
                      , GIFT_NO
                      , GIFT_STAT_CD
                   FROM GIFT_MST_LOG    A
                  WHERE COMP_CD = ps_in_comp_cd
                    AND GIFT_NO = ps_in_gc_no
                    AND CHG_NO  = (SELECT MAX(CHG_NO)
                                     FROM GIFT_MST_LOG
                                    WHERE COMP_CD = A.COMP_CD
                                      AND GIFT_NO = A.GIFT_NO
                                  )
                )     GL
              , COMMON B
              , (SELECT COMP_CD
                      , CODE_CD
                      , CODE_NM
                   FROM LANG_COMMON
                  WHERE COMP_CD     = ps_in_comp_cd
                    AND CODE_TP     = '17570'
                    AND LANGUAGE_TP = lsv_language
                    AND USE_YN      = 'Y'
                ) LC
              , GIFT_CODE_MST C
              , STORE D
              , (SELECT COMP_CD
                      , BRAND_CD
                      , STOR_CD
                      , STOR_NM
                   FROM LANG_STORE
                  WHERE COMP_CD     = ps_in_comp_cd
                    AND BRAND_CD    = ps_in_brand_cd
                    AND STOR_CD     = ps_in_stor_cd
                    AND LANGUAGE_TP = lsv_language
                    AND USE_YN      = 'Y'
                ) LS
              , GIFT_IN_HD E
              , GIFT_IN_DT F
          WHERE A.COMP_CD  = ps_in_comp_cd
            AND A.GIFT_NO  = ps_in_gc_no
            AND B.CODE_TP  = '17570'
            AND B.CODE_CD  = '90' ||
                             CASE WHEN LENGTH(A.EXP_DT) = 8 AND A.EXP_DT < TO_CHAR(SYSDATE,'YYYYMMDD') AND  A.GIFT_STAT_CD IN ('20', '30') THEN '00'
                                  ELSE A.GIFT_STAT_CD 
                             END
            AND A.COMP_CD  = GL.COMP_CD(+)
            AND A.GIFT_NO  = GL.GIFT_NO(+)
            AND A.COMP_CD  = B.COMP_CD
            AND A.COMP_CD  = C.COMP_CD
            AND A.GIFT_CD  = C.GIFT_CD
            AND A.COMP_CD  = E.COMP_CD
            AND A.GIFT_CD  = E.GIFT_CD
            AND E.COMP_CD  = F.COMP_CD
            AND E.IN_DT    = F.IN_DT
            AND E.IN_SEQ   = F.IN_SEQ
            AND A.GIFT_NO  = F.GIFT_NO
            AND B.COMP_CD  = LC.COMP_CD (+)
            AND B.CODE_CD  = LC.CODE_CD (+)
            AND A.COMP_CD  = D.COMP_CD  (+)
            AND A.BRAND_CD = D.BRAND_CD (+)
            AND A.STOR_CD  = D.STOR_CD  (+)
            AND A.COMP_CD  = LS.COMP_CD (+)
            AND A.BRAND_CD = LS.BRAND_CD(+)
            AND A.STOR_CD  = LS.STOR_CD (+)
            AND B.USE_YN   = 'Y';
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
             lsv_gift_stat := NULL ;
        WHEN OTHERS THEN
             lsv_msg_code  := '9999';
             lsv_msg_text  := '30 ' || SQLERRM;
             RAISE ERR_HANDLER;
      END;
      
      ps_gc_cd  := lsv_gv_cd;
      ps_gc_prc := TO_CHAR(lnv_price, 'FM000000000');
      
      IF ps_in_req_div = '20' THEN -- 상품권 조회
         IF  lsv_gift_stat IS NULL THEN
            lsv_msg_code   := '0001';
            lsv_msg_text   := lsv_msg1;
         ELSE
            IF lsv_issue_brand <> '0000' AND ps_in_brand_cd <> lsv_issue_brand THEN
               lsv_msg_code   := '0020';
               lsv_msg_text   := lsv_msg20;
            ELSE
               lsv_msg_code   := lsv_code_cd;
               lsv_msg_text   := lsv_CODE_NM;
               
               IF lsv_msg_code IN('9040', '9041') THEN    -- 사용완료
                  lsv_out_msg2 := SUBSTR(lsv_o_sale_dt,1,4) || '/' || SUBSTR(lsv_o_sale_dt,5,2) || '/' || SUBSTR(lsv_o_sale_dt,7,2) ||
                                  FC_GET_WORDPACK(ps_in_comp_cd, lsv_language, 'DAY_1') || ' '  || lsv_stor_nm || FC_GET_WORDPACK(ps_in_comp_cd, lsv_language, 'FROM');
                  IF lsv_out_msg2 IS NOT NULL THEN
                     lsv_out_msg3 := FC_GET_WORDPACK(ps_in_comp_cd, lsv_language, 'GIFT_MSG_01');
                  END IF;
               END IF;
            END IF;
         END IF;
         RAISE ERR_HANDLER;
      ELSIF ps_in_req_div = '40' THEN -- 망상취소
         BEGIN
             SELECT PRC_STAT
               INTO lsv_proc_st
               FROM GIFT_SVR_LOG
              WHERE COMP_CD = ps_in_comp_cd
                AND appr_no = ps_in_o_bill_no ;
             IF lsv_gift_stat IS NULL  THEN
                lsv_msg_code   := '0001';
                lsv_msg_text   := lsv_msg1;
             ELSIF lsv_proc_st <> 'C' THEN
                lsv_msg_code   := '0032';
                lsv_msg_text   := lsv_msg32;
             ELSIF ps_in_sale_div = '0200' AND lsv_gift_stat NOT IN ('40', '41')  THEN  -- 사용 취소 오류
                lsv_msg_code   := '0033';
                lsv_msg_text   := lsv_msg33;
             ELSIF ps_in_sale_div = '0420' AND lsv_gift_stat NOT IN ('20', '30')  THEN  -- 반품 취소 오류
                lsv_msg_code   := '0034';
                lsv_msg_text   := lsv_msg34;
             ELSIF ps_in_sale_div = '0200' AND lsv_gift_stat IN ('40', '41') THEN
                lsv_msg_code   := '0000';
                lsv_msg_text   := lsv_msg0;
                lsv_gift_stat2 := prev_gift_stat;
             ELSIF ps_in_sale_div = '0400' AND lsv_gift_stat IN ('20', '30') THEN
                lsv_msg_code   := '0000';
                lsv_msg_text   := lsv_msg0;
                lsv_gift_stat2 := prev_gift_stat;
             END IF;
         EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                  lsv_msg_code   := '0031';
                  lsv_msg_text   := lsv_msg31;
              WHEN OTHERS THEN
                  lsv_msg_code   := '9999';
                  lsv_msg_text   := '40 ' || SQLERRM;
         END;
      ELSIF ps_in_req_div = '10' THEN -- 승인
         CASE WHEN lsv_gift_stat IS NULL  THEN
                lsv_msg_code   := '0001';
                lsv_msg_text   := lsv_msg1;
              WHEN lsv_issue_brand <> '0000' AND ps_in_brand_cd <> lsv_issue_brand THEN
                lsv_msg_code   := '0020';
                lsv_msg_text   := lsv_msg20;
              WHEN lsv_gift_stat = '10' THEN                        -- 입고
                lsv_msg_code   := '0020';
                lsv_msg_text   := lsv_msg20;
              WHEN lsv_gift_stat IN ('11', '12', '21', '31') THEN     -- 고객판매대기
                   lsv_msg_code := '0020';
                   lsv_msg_text   := lsv_msg20;
              WHEN lsv_gift_stat IN ('20', '30') THEN             -- 유통중
                IF ps_in_sale_div = '0200' THEN     -- 정상 사용
                   IF  LENGTH(lsv_exp_dt) = 8 AND TO_CHAR(SYSDATE, 'YYYYMMDD') > lsv_exp_dt THEN --유효기간 Check
                       lsv_msg_code := '0004';
                       lsv_msg_text := lsv_msg4;
                    ELSE
                       lsv_msg_code := '0000';
                       lsv_msg_text := lsv_msg0;
                       lsv_gift_stat2 :=  '40';
                    END IF;
                ELSE
                   lsv_msg_code := '0021';
                   lsv_msg_text   := lsv_msg21;
                END IF;
              WHEN lsv_gift_stat = '42' THEN   -- 타사사용
                lsv_msg_code := '0012';
                lsv_msg_text   := lsv_msg12;
                
              WHEN lsv_gift_stat IN ('50', '51', '99') THEN   -- 사고등록
                lsv_msg_code := '0007';
                lsv_msg_text   := lsv_msg7;
              WHEN lsv_gift_stat IN ('40', '41') THEN                  -- 사용완료
                IF ps_in_sale_div = '0200' THEN
                   IF  ( ps_in_brand_cd = lsv_o_brand_cd AND ps_in_stor_cd = lsv_o_stor_cd ) THEN
                        ls_fail_cd := '01';
                   ELSE
                        ls_fail_cd := '02';
                   END IF;
                   lsv_msg_code := '0003';
                   lsv_msg_text := lsv_msg3;
                   lsv_out_msg2 := substr(lsv_o_sale_dt,1,4) || '/' || substr(lsv_o_sale_dt,5,2) || '/' || substr(lsv_o_sale_dt,7,2) ||
                                   FC_GET_WORDPACK(ps_in_comp_cd, lsv_language, 'DAY_1') || ' '  || lsv_stor_nm || FC_GET_WORDPACK(ps_in_comp_cd, lsv_language, 'FROM');
                   IF lsv_out_msg2 IS NOT NULL THEN
                      lsv_out_msg3 := FC_GET_WORDPACK(ps_in_comp_cd, lsv_language, 'GIFT_MSG_01');
                   END IF;
                ELSIF
                  ( ps_in_brand_cd = lsv_o_brand_cd AND ps_in_stor_cd = lsv_o_stor_cd  AND ps_in_req_proc = '2'   ) OR lsv_app_seq = ps_in_o_bill_no
                  THEN                              -- 정상 취소
                   lsv_msg_code   := '0000';
                   lsv_msg_text   := lsv_msg0;
                   lsv_gift_stat2 := prev_gift_stat;
                ELSE
                   lsv_msg_code   := '0010';
                   lsv_msg_text   := lsv_msg10;
                END IF;
              WHEN lsv_gift_stat IN ('12', '21', '31') THEN             -- 회수
                lsv_msg_code   := '0022';
                lsv_msg_text   := lsv_msg22;
                lsv_out_msg2 := substr(lsv_o_sale_dt,1,4) || '/' || substr(lsv_o_sale_dt,5,2) || '/' || substr(lsv_o_sale_dt,7,2) ||
                                   FC_GET_WORDPACK(ps_in_comp_cd, lsv_language, 'DAY_1') || ' '  || lsv_stor_nm || FC_GET_WORDPACK(ps_in_comp_cd, lsv_language, 'FROM');
                IF lsv_out_msg2 IS NOT NULL THEN
                   lsv_out_msg3 := FC_GET_WORDPACK(ps_in_comp_cd, lsv_language, 'GIFT_MSG_01');
                END IF;
              WHEN lsv_gift_stat IN ('50', '51', '99') THEN             -- 폐기
                lsv_msg_code := '0023';
                lsv_msg_text   := lsv_msg23;
         END CASE;
      END IF;
      
      lsv_app_seq := Uf_Get_App_Seq();
      lsv_sysdate := TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS');
      
      ps_out_appr_tm :=  lsv_sysdate;
      ps_out_appr_no :=  lsv_app_seq;
      
      SP_GC_APPR_LOG (lsv_app_seq   , ps_in_gc_no  , ps_in_comp_cd , ps_in_brand_cd , ps_in_stor_cd  , ps_in_sale_dt, ps_in_pos_no, ps_in_bill_no, ps_in_req_user,
                      ps_in_req_proc, ps_in_req_div, ps_in_sale_div, ps_in_o_sale_dt, ps_in_o_bill_no, ls_fail_cd   , lsv_sysdate , lsv_msg_code , lsv_msg_text  ,
                      lsv_pre_app_no, lnv_price    , lnv_return_cd , lsv_return_msg);
                      
      IF lnv_return_cd <> 0 THEN
         lsv_msg_code   := '9999';
         lsv_msg_text   := lsv_return_msg;
         RAISE ERR_HANDLER;
      END IF;
      
      IF lsv_msg_code <> '0000' THEN
        RAISE ERR_HANDLER;
      END IF;
    EXCEPTION
      WHEN ERR_HANDLER THEN
           RAISE ERR_HANDLER;
      WHEN OTHERS THEN
           lsv_msg_code   := '9999';
           lsv_msg_text   := SQLERRM;
           RAISE ERR_HANDLER;
    END;
    BEGIN
      UPDATE GIFT_SVR_LOG
         SET PRC_STAT = 'C',
             BRAND_CD = ps_in_brand_cd,
             STOR_CD  = ps_in_stor_cd,
             SALE_DT  = ps_in_sale_dt,
             POS_NO   = ps_in_pos_no,
             BILL_NO  = ps_in_bill_no
          WHERE COMP_CD = ps_in_comp_cd
            AND APPR_NO = lsv_app_seq;
            
      UPDATE GIFT_MST
         SET UPD_DT        = SYSDATE,
             UPD_USER      = ps_in_req_user,
             S_APPR_NO     = lsv_app_seq,
             GIFT_STAT_CD  = lsv_gift_stat2,
             S_BRAND_CD    = ps_in_brand_cd,
             S_STOR_CD     = ps_in_stor_cd,
             S_SALE_DT     = ps_in_sale_dt,
             S_POS_NO      = ps_in_pos_no,
             S_BILL_NO     = ps_in_bill_no,
             S_APPR_DT     = SUBSTR(lsv_sysdate,1,8),
             S_APPR_TM     = SUBSTR(lsv_sysdate,9,6)
       WHERE COMP_CD       = ps_in_comp_cd
         AND GIFT_NO       = ps_in_gc_no ;
    EXCEPTION
        WHEN OTHERS THEN
            lsv_msg_code   := '9999';
            lsv_msg_text   := SQLERRM;
            RAISE ERR_HANDLER;
    END;
    
    ps_out_rtn_cd  :=  lsv_msg_code ;
    ps_out_msg1    :=  lsv_msg_text ;
    ps_out_msg2    :=  lsv_out_msg2 ;
    ps_out_msg3    :=  lsv_out_msg3 ;
    
  EXCEPTION
    WHEN ERR_HANDLER THEN
         ps_out_rtn_cd := lsv_msg_code;
         ps_out_msg1     := lsv_msg_text;
         ps_out_msg2     := lsv_out_msg2;
         ps_out_msg3     := lsv_out_msg3;
    WHEN OTHERS THEN
         ps_out_rtn_cd := '9999';
         ps_out_msg1     := SQLERRM;
  END;
  
  PROCEDURE SP_GC_APPR_NPOS
  (
    ps_in_gc_no      IN   VARCHAR2, -- GC No.
    ps_in_comp_cd    IN   VARCHAR2, -- 회사코드
    ps_in_brand_cd   IN   VARCHAR2, -- Brand Code
    ps_in_stor_cd    IN   VARCHAR2, -- Store Code
    ps_in_sale_dt    IN   VARCHAR2, -- Sale Date
    ps_in_pos_no     IN   VARCHAR2, -- POS NO
    ps_in_bill_no    IN   VARCHAR2, -- BILL NO
    ps_in_req_user   IN   VARCHAR2, -- Request User
    ps_in_req_proc   IN   VARCHAR2, -- Procees Channel ('1':Store , '2': SYSTEM , '3': Call Center , '4':On-Line Cancel at Process Error)
    ps_in_req_div    IN   VARCHAR2, -- Request Type (10:Approval  20:Retrieval  40:On-Line Cancel at Process Error)
    ps_in_sale_div   IN   VARCHAR2, -- Sale/Return(0200:Sale, 0420:Return)
    ps_in_o_sale_dt  IN   VARCHAR2, -- Sale Date
    ps_in_o_bill_no  IN   VARCHAR2, -- Bill No.
    ps_out_rtn_cd    OUT  VARCHAR2, -- Result Message
    ps_out_msg1      OUT  VARCHAR2, -- Message1
    ps_out_msg2      OUT  VARCHAR2, -- Message1
    ps_out_msg3      OUT  VARCHAR2, -- Message1
    ps_gc_cd         OUT  VARCHAR2, -- GC Price Type
    ps_gc_nm         OUT  VARCHAR2, -- 상품권명
    ps_gc_prc        OUT  VARCHAR2, -- GC Price
    ps_out_appr_tm   OUT  VARCHAR2, -- Approval Time
    ps_out_appr_no   OUT  VARCHAR2  -- Approval No.
  ) IS
    lsv_msg_code    VARCHAR2(4) := '0000';
    lsv_msg_text    VARCHAR2(400);
    lsv_stor_snm    VARCHAR2(50);
    lsv_gc_cd          varchar2(20);
    ERR_HANDLER        EXCEPTION;
  BEGIN
    lsv_msg_text    := '정상 처리';
    
    SP_GC_APPR_POS
    ( ps_in_gc_no      , -- 01 상품권번호
      ps_in_comp_cd    , 
      ps_in_brand_cd   , -- 02 브랜드코드
      TRIM(ps_in_stor_cd), -- 03 점포코드
      ps_in_sale_dt    , -- 04 판매일자
      ps_in_pos_no     , -- 05 POS NO
      ps_in_bill_no    , -- 06 BILL NO
      ps_in_req_user   , -- 07 요청자
      ps_in_req_proc   , -- 08 승인처리경로('1':점포, '2': 자동(SYSTEM), '3':강제처리(고객센터), '4':망취소)
      ps_in_req_div    , -- 09 요청구분 (10:승인  20:조회  40:망상취소)
      ps_in_sale_div   , -- 10 정상/반품(0200:정상, 0420:반품)
      ps_in_o_sale_dt  , -- 11 원거래일자
      trim(ps_in_o_bill_no), -- 12 원거래승인번호
      lsv_msg_code     , -- 13 메세지코드
      ps_out_msg1      , -- 14 메세지1
      ps_out_msg2      , -- 15 메세지2
      ps_out_msg3      , -- 16 메세지3
      lsv_gc_cd        , -- 17 상품권 권종(상품권 코드)
      ps_gc_nm         , -- 18 상품권명
      ps_gc_prc        , -- 19 상품권 금액
      ps_out_appr_tm   , -- 20 승인시간
      ps_out_appr_no
    );
    
    /*
      0020 거래거절-유통중인 상품권이 아닙니다.
      0022 거래불가-회수처리된 상품권입니다.
      0023 거래불가-폐기처리된 상품권입니다.
      9000 사용가능한 상품권이 아닙니다.(등록대기)
      9001 사용가능한 상품권이 아닙니다.(등록-미유통)
      9002 사용가능한 상품권입니다.(유통중)
      9006 사용가능한 상품권이 아닙니다.(사고등록)
      9007 사용가능한 상품권이 아닙니다.(사용완료)
      9008 사용가능한 상품권이 아닙니다.(회수)
      9009 사용가능한 상품권이 아닙니다.(폐기)
      0021 취소불가-사용 처리된 상품권이 아닙니다.
      9010 사용가능한 상품권이 아닙니다.(유효기간 경과)
      0000 정상
      0001 거래거절-미등록 상품권
      0002 거래거절-상품권번호 중복
      0003 거래거절-이미 사용된 상품권
      0004 거래거절-유효기간 경과 상품권
      0005 거래거절-점포코드오류
      0006 거래거절-상품권금액이 다름
      0007 사고상품권-고객명, 전화번호, 구매처, 구매일시, 구매장수 기록요망
      0008 통신장애
      0009 취소불가-이미 취소된 거래
      0010 취소불가-원거래번호 없음
      0011 거래불가-상담실로 전화하세요
      0031 망상취소 실패 - 승인 완료된 작업이 아닙니다.
      0032 망상취소 실패 - 존재하지 않은 승인 작업입니다.
      0033 망상취소 실패 - 사용 완료된 상품권이 아닙니다.
      0034 망상취소 실패 - 반품 취소 처리된 상품권이 아닙니다.
    */
    
    /*
      If ( lsv_gc_cd = '13' ) Then
         lsv_gc_cd := '14';
      ElsIf ( lsv_gc_cd = '21' ) Then
         lsv_gc_cd := '22';
      End If;
    */
    ps_out_rtn_cd := lsv_msg_code ;
    ps_gc_cd      := lsv_gc_cd;
    IF ( lsv_msg_code <> '0000' ) THEN
       If ( ps_in_sale_div = '0200' AND ps_in_req_div = '20' ) THEN -- 정상, 조회 요청시
           IF ( lsv_msg_code IN ( '9020', '9030' ) ) THEN
              ps_out_rtn_cd := '0000';
           END IF;
       END IF;
    END IF;
    
    BEGIN
        SELECT GIFT_NM INTO ps_gc_nm
          FROM GIFT_CODE_MST
         WHERE COMP_CD = ps_in_comp_cd
           AND GIFT_CD = lsv_gc_cd ;
    END ;
  EXCEPTION
    WHEN OTHERS THEN
         ps_out_rtn_cd := '9999';
         ps_out_msg1   := SQLERRM;
  END;
END PKG_GC_APPR;

/
