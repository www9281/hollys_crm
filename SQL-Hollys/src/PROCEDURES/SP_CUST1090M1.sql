--------------------------------------------------------
--  DDL for Procedure SP_CUST1090M1
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_CUST1090M1" /* 무통장 입금 확인/취소 처리 */
(
  PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
  PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
  PSV_ORD_DT      IN  VARCHAR2 ,                -- 주문일자
  PSV_ORD_SEQ     IN  VARCHAR2 ,                -- 주문번호
  PSV_CRG_SEQ     IN  VARCHAR2 ,                -- 결제순번
  PSV_USER_ID     IN  VARCHAR2 ,                -- 사용자 ID
  PSV_APPR_YN     IN  VARCHAR2 ,                -- 입금확인 유무(Y/N) ==> (입금확인여부:Y => 입금확인 -> 입금대기, N => 입금대기 -> 입금확인)
  PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
  PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
)
IS
/******************************************************************************
   NAME:       SP_CUST1090M0      회원정보관리 MMS 재전송(e-GIFT 카드)
   PURPOSE:

   REVISIONS:
   VER        DATE        AUTHOR           DESCRIPTION
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014-07-11         1. CREATED THIS PROCEDURE.

   NOTES:

      OBJECT NAME:     SP_CUST1090M1
      SYSDATE:         2017-11-30
      USERNAME:
      TABLE NAME:
******************************************************************************/
    CURSOR  CUR_1 IS
        SELECT  CHD.COMP_CD
              , CHD.ORD_DT
              , CHD.ORD_SEQ
              , COC.ITEM_SEQ
              , COC.GIFT_SEQ
              , CST.CRG_SEQ
              , CHD.ORD_FG
              , CST.CRG_FG
              , CST.CRG_DIV
              , CST.CHANNEL
              , COC.CARD_ID
              , decrypt(COC.CARD_ID) AS DEC_CARD_ID
              , CHD.ORD_USER_NM
              , COC.GIFT_USER_NM
              , COC.GIFT_MOBILE
              , COC.GIFT_EMAIL
              , CASE WHEN CST.CRG_FG = '1' AND PSV_APPR_YN = 'N' THEN COC.GIFT_AMT
                     WHEN CST.CRG_FG = '1' AND PSV_APPR_YN = 'Y' THEN COC.GIFT_AMT * (-1)
                     WHEN CST.CRG_FG = '2' AND PSV_APPR_YN = 'N' THEN COC.GIFT_AMT
                     WHEN CST.CRG_FG = '2' AND PSV_APPR_YN = 'Y' THEN COC.GIFT_AMT * (-1)
                     ELSE COC.GIFT_AMT
                END  AS GIFT_AMT
              , SUM(
                    CASE WHEN CHD.GIFT_METH_DIV IN ('1','2') AND COC.GIFT_MOBILE IS NOT NULL THEN 1
                         WHEN CHD.GIFT_METH_DIV = '3'        AND COC.GIFT_EMAIL IS NOT NULL THEN 1
                         ELSE 0 
                    END
                   )     OVER() AS GIFT_METH_CNT
              , SUM(
                    CASE WHEN COC.MSGKEY IS NOT NULL AND COC.GIFT_ERR_CD = '000' THEN 1
                         ELSE 0 
                    END
                   )     OVER() AS GIFT_SEND_CNT     
              , COUNT(*) OVER() AS GIFT_TOT_CNT  
              , CHD.GIFT_METH_DIV
              , NVL(CHD.GIFT_SEND_DIV, '1')                                 AS GIFT_SEND_DIV
              , NVL(CHD.GIFT_SEND_DT, TO_CHAR(SYSDATE, 'YYYYMMDDHH24MI'))   AS GIFT_SEND_DT
              , CASE WHEN CST.CRG_FG = '1' AND PSV_APPR_YN = 'N' THEN CST.CRG_AMT
                     WHEN CST.CRG_FG = '1' AND PSV_APPR_YN = 'Y' THEN CST.CRG_AMT * (-1)
                     WHEN CST.CRG_FG = '2' AND PSV_APPR_YN = 'N' THEN CST.CRG_AMT
                     WHEN CST.CRG_FG = '2' AND PSV_APPR_YN = 'Y' THEN CST.CRG_AMT * (-1)
                     ELSE CST.CRG_AMT
                END  AS CRG_AMT
              , CHD.GIFT_MSG
              , CHD.CARD_TYPE
              , COC.SV_FILE_PATH
              , COC.MSGKEY
              , NVL(V02.REF_ORD_DT,  CST.ORG_ORD_DT ) AS ORG_ORD_DT
              , NVL(V02.REF_ORD_SEQ, CST.ORG_ORD_SEQ) AS ORG_ORD_SEQ
              , NVL(V02.REF_CRG_SEQ, CST.ORG_CRG_SEQ) AS ORG_CRG_SEQ
              , ROW_NUMBER() OVER(PARTITION BY CHD.COMP_CD, CHD.ORD_DT, CHD.ORD_SEQ ORDER BY CST.CRG_SEQ) R_NUM 
        FROM    C_ORDER_HD   CHD  
              , C_ORDER_ST   CST
              , C_ORDER_CARD COC
              ,(
                SELECT  HIS.COMP_CD     
                      , HIS.REF_ORD_DT
                      , HIS.REF_ORD_SEQ
                      , HIS.REF_CRG_SEQ
                      , ROW_NUMBER() OVER(PARTITION BY HIS.COMP_CD ORDER BY HIS.CRG_DT DESC, HIS.CRG_SEQ DESC) R_NUM
                FROM    C_CARD_CHARGE_HIS  HIS
                      ,(
                        SELECT  COMP_CD
                              , ORD_DT
                              , ORD_SEQ
                              , CRG_SEQ
                        FROM    C_ORDER_ST
                        WHERE   COMP_CD  = PSV_COMP_CD
                        AND     ORD_DT   = PSV_ORD_DT
                        AND     ORD_SEQ  = PSV_ORD_SEQ
                        AND     CRG_SEQ  = PSV_CRG_SEQ
                        UNION 
                        SELECT  COMP_CD
                              , ORG_ORD_DT
                              , ORG_ORD_SEQ
                              , ORG_CRG_SEQ
                        FROM    C_ORDER_ST
                        WHERE   COMP_CD  = PSV_COMP_CD
                        AND     ORD_DT   = PSV_ORD_DT
                        AND     ORD_SEQ  = PSV_ORD_SEQ
                        AND     CRG_SEQ  = PSV_CRG_SEQ
                       ) V01
                WHERE   V01.COMP_CD = HIS.COMP_CD
                AND     V01.ORD_DT  = HIS.REF_ORD_DT
                AND     V01.ORD_SEQ = HIS.REF_ORD_SEQ
                AND     V01.CRG_SEQ = HIS.REF_CRG_SEQ
               ) V02
        WHERE   CHD.COMP_CD  = CST.COMP_CD
        AND     CHD.ORD_DT   = CST.ORD_DT
        AND     CHD.ORD_SEQ  = CST.ORD_SEQ
        AND     CHD.COMP_CD  = COC.COMP_CD
        AND     CHD.ORD_DT   = COC.ORD_DT
        AND     CHD.ORD_SEQ  = COC.ORD_SEQ
        AND     CST.COMP_CD  = V02.COMP_CD    (+)
        AND     CST.ORD_DT   = V02.REF_ORD_DT (+)
        AND     CST.ORD_SEQ  = V02.REF_ORD_SEQ(+)
        AND     CST.CRG_SEQ  = V02.REF_CRG_SEQ(+)
        AND     1            = V02.R_NUM      (+)
        AND     CST.COMP_CD  = PSV_COMP_CD
        AND     CST.ORD_DT   = PSV_ORD_DT
        AND     CST.ORD_SEQ  = PSV_ORD_SEQ
        AND     CST.CRG_SEQ  = PSV_CRG_SEQ
        AND     CST.CRG_DIV  = '4'
        AND     CST.APPR_YN  = PSV_APPR_YN
        AND     CHD.ITEM_DIV = '1'
        AND     NOT EXISTS (
                            SELECT  1
                            FROM    C_ORDER_ST WK1
                            WHERE   WK1.COMP_CD     = CST.COMP_CD
                            AND     WK1.ORG_ORD_DT  = CST.ORD_DT
                            AND     WK1.ORG_ORD_SEQ = CST.ORD_SEQ
                            AND     WK1.ORG_CRG_SEQ = CST.CRG_SEQ 
                           );
  
    -- 2단계 카드      
    TYPE  TYPE_CARD_REC IS RECORD     
       (      
        COMP_CD         VARCHAR2(003), -- 회사코드
        ORD_DT          VARCHAR2(008), -- 주문일자[C_ORDER_HD] 2단계  
        ORD_SEQ         NUMBER  (007), -- 주문순번[C_ORDER_HD] 2단계  
        ITEM_SEQ        NUMBER  (002), -- 상품순번[C_ORDER_DT] 2단계  
        GIFT_SEQ        NUMBER  (005), -- 카드순번[C_ORDER_CARD] 2단계  
        CARD_ID         VARCHAR2(100), -- 카드번호(암호화)
        ORD_USER_NM     VARCHAR2(100), -- 보내는사람
        GIFT_USER_NM    VARCHAR2(100), -- 받는사람
        GIFT_MOBILE     VARCHAR2(050), -- 받는사람휴대전화
        GIFT_EMAIL      VARCHAR2(100), -- 받는사람 EMAIL
        CARD_TYPE       VARCHAR2(010), --  카드 TYPE
        MSGKEY          NUMBER  (011), -- MMS MSGKEY
        SV_FILE_PATH    VARCHAR2(100)  -- 바코드 이미지
       );     
  
    TYPE TP_CARD_REC IS TABLE OF TYPE_CARD_REC INDEX BY PLS_INTEGER;     
     
    ARR_CARD_REC     TP_CARD_REC; 
    
    ls_sql          VARCHAR2(30000) ;
    
    ERR_HANDLER     EXCEPTION;
    
    ls_err_cd       VARCHAR2(7) := '0000' ;
    ls_err_msg      VARCHAR2(500) ;
    ls_result       VARCHAR2(1024);
    
    vC_CARD_ID      VARCHAR2(32000):= NULL;  
    vC_CRG_AMT      VARCHAR2(32000):= NULL;
    vREF_ORD_DT     VARCHAR2(32000):= NULL; 
    vREF_ORD_SEQ    VARCHAR2(32000):= NULL; 
    vREF_ITEM_SEQ   VARCHAR2(32000):= NULL;
    vREF_GIFT_SEQ   VARCHAR2(32000):= NULL; 
    vREF_CRG_SEQ    VARCHAR2(32000):= NULL;
    
    vORG_ORD_DT     C_ORDER_ST.ORG_ORD_DT%TYPE;
    nORG_ORD_SEQ    C_ORDER_ST.ORG_ORD_SEQ%TYPE;
    nORG_CRG_SEQ    C_ORDER_ST.ORG_CRG_SEQ%TYPE;
    
    vCRG_FG         C_ORDER_ST.CRG_FG%TYPE;
    vCRG_DIV        C_ORDER_ST.CRG_DIV%TYPE;
    vCHANNEL        C_ORDER_ST.CHANNEL%TYPE;
    nCRG_AMT        C_ORDER_ST.CRG_AMT%TYPE;
    
    vGIFT_METH_DIV  C_ORDER_HD.GIFT_METH_DIV%TYPE;
    vGIFT_SEND_DIV  C_ORDER_HD.GIFT_SEND_DIV%TYPE;
    vGIFT_SEND_DT   C_ORDER_HD.GIFT_SEND_DT%TYPE;
    vGIFT_MSG       C_ORDER_HD.GIFT_MSG%TYPE;
    vORG_ORD_FG     C_ORDER_HD.ORD_FG%TYPE;
    
    nMSGKEY         NUMBER;
    vMMSMSG         VARCHAR2(32000) := NULL;
    vMMS_SEND_YN    VARCHAR2(1)     := 'N';
    vRSLT           VARCHAR2(10)    := NULL;
    
    vSYSDATE        VARCHAR2(8)    := TO_CHAR(SYSDATE, 'YYYYMMDD');
    vSYSTIME        VARCHAR2(8)    := TO_CHAR(SYSDATE, 'HH24MISS');
    
    ll_rec_cnt      NUMBER := 0;
    ll_prc_cnt      NUMBER := 0;
    
BEGIN
    FOR MYREC IN CUR_1 LOOP
        /* 입금 확인 후 취소 처리 */
        IF (MYREC.CRG_FG = '1' AND PSV_APPR_YN = 'Y') OR (MYREC.CRG_FG = '2' AND PSV_APPR_YN = 'N') THEN
            vCRG_FG := '2'; -- 충전 취소
        ELSE
            vCRG_FG := '1'; -- 충전    
        END IF;
    
        IF (MYREC.CRG_FG = '1' AND PSV_APPR_YN = 'N') THEN
            -- MMS는 무통장 입금 확일일때만 전송 함
            vMMS_SEND_YN := 'Y';
            
            IF MYREC.GIFT_METH_CNT != MYREC.GIFT_TOT_CNT AND vCRG_FG = '1' THEN
                ls_err_cd  := '1002';
                ls_err_msg := FC_GET_WORDPACK_MSG(PSV_LANG_CD, 1010001550); -- 선물 받는분들의 휴대전화 또는 이메일 주소를 확인하세요.
                    
                RAISE ERR_HANDLER;
            END IF;
        END IF;
        
        IF MYREC.GIFT_SEND_CNT > 0 AND vCRG_FG = '2' THEN
            ls_err_cd  := '1001';
            ls_err_msg := FC_GET_WORDPACK_MSG(PSV_LANG_CD, 1010001551); -- MMS 또는 이메일 전송 중에는 입금확인 취소가 불가능합니다.
                
            RAISE ERR_HANDLER;
        END IF;
        
        -- 무통장입금 주문취소 대비
        IF MYREC.ORD_FG = '2' THEN 
            BEGIN
                UPDATE  C_CARD
                SET     CARD_STAT = '81' 
                WHERE   COMP_CD   = PSV_COMP_CD
                AND     CARD_ID   = MYREC.CARD_ID
                AND     CARD_STAT = '91';
            EXCEPTION
                WHEN OTHERS THEN
                    ROLLBACK;
                                
                    ls_err_cd  := TO_CHAR(SQLCODE);
                    ls_err_msg := SQLERRM ;
            END;
        END IF;
        
        -- 레코드 처리 건수
        ll_rec_cnt := ll_rec_cnt + 1;
        -- 전송시기/전송 일자
        vGIFT_METH_DIV := MYREC.GIFT_METH_DIV;
        vGIFT_SEND_DIV := MYREC.GIFT_SEND_DIV;
        vGIFT_SEND_DT  := MYREC.GIFT_SEND_DT;
        vGIFT_MSG      := MYREC.GIFT_MSG;
        vORG_ORD_FG    := MYREC.ORD_FG;
        
        -- C_ORDER_CARD 정보
        ARR_CARD_REC(ll_rec_cnt).COMP_CD        := MYREC.COMP_CD;
        ARR_CARD_REC(ll_rec_cnt).ORD_DT         := MYREC.ORD_DT;
        ARR_CARD_REC(ll_rec_cnt).ORD_SEQ        := MYREC.ORD_SEQ;
        ARR_CARD_REC(ll_rec_cnt).ITEM_SEQ       := MYREC.ITEM_SEQ;
        ARR_CARD_REC(ll_rec_cnt).GIFT_SEQ       := MYREC.GIFT_SEQ;
        ARR_CARD_REC(ll_rec_cnt).CARD_ID        := MYREC.DEC_CARD_ID;   -- 복호화된 카드번호
        ARR_CARD_REC(ll_rec_cnt).ORD_USER_NM    := MYREC.ORD_USER_NM;   -- 보내는사람
        ARR_CARD_REC(ll_rec_cnt).GIFT_USER_NM   := MYREC.GIFT_USER_NM;  -- 받는사람
        ARR_CARD_REC(ll_rec_cnt).GIFT_MOBILE    := MYREC.GIFT_MOBILE;   -- 받는사람휴대전화
        ARR_CARD_REC(ll_rec_cnt).GIFT_EMAIL     := MYREC.GIFT_EMAIL;    -- 받는사람 EMAIL
        ARR_CARD_REC(ll_rec_cnt).CARD_TYPE      := MYREC.CARD_TYPE;     --  카드 TYPE
        ARR_CARD_REC(ll_rec_cnt).MSGKEY         := MYREC.MSGKEY;        --  카드 TYPE
        ARR_CARD_REC(ll_rec_cnt).SV_FILE_PATH   := MYREC.SV_FILE_PATH;
        
        IF MYREC.R_NUM = 1 THEN
            vC_CARD_ID := MYREC.CARD_ID;
            vC_CRG_AMT := TO_CHAR(MYREC.GIFT_AMT);
            
            vCRG_DIV   := MYREC.CRG_DIV;
            nCRG_AMT   := MYREC.CRG_AMT;            
            
            vORG_ORD_DT   := MYREC.ORG_ORD_DT;
            nORG_ORD_SEQ  := MYREC.ORG_ORD_SEQ;
            nORG_CRG_SEQ  := MYREC.ORG_CRG_SEQ;
            
            vREF_ORD_DT   := MYREC.ORD_DT; 
            vREF_ORD_SEQ  := MYREC.ORD_SEQ; 
            vREF_ITEM_SEQ := MYREC.ITEM_SEQ;
            vREF_GIFT_SEQ := MYREC.GIFT_SEQ; 
            vREF_CRG_SEQ  := MYREC.CRG_SEQ;
    
            vCHANNEL      := MYREC.CHANNEL;
        ELSE
            vC_CARD_ID    := vC_CARD_ID    || '^' || MYREC.CARD_ID;
            vC_CRG_AMT    := vC_CRG_AMT    || '^' || TO_CHAR(MYREC.GIFT_AMT);
            vREF_ORD_DT   := vREF_ORD_DT   || '^' || MYREC.ORD_DT; 
            vREF_ORD_SEQ  := vREF_ORD_SEQ  || '^' || MYREC.ORD_SEQ; 
            vREF_ITEM_SEQ := vREF_ITEM_SEQ || '^' || MYREC.ITEM_SEQ;
            vREF_GIFT_SEQ := vREF_GIFT_SEQ || '^' || MYREC.GIFT_SEQ; 
            vREF_CRG_SEQ  := vREF_CRG_SEQ  || '^' || MYREC.CRG_SEQ;
        END IF;
    END LOOP;
    
    IF ll_rec_cnt > 0 THEN
        PKG_POS_CUST_REQ.SET_MEMB_CHG_15(PSV_COMP_CD, 'KOR', '', vSYSDATE, '001', '', '', '', '', vSYSDATE, vSYSTIME, '', '', '', '', '', '', '', '', vCRG_FG, vCRG_DIV, nCRG_AMT, vORG_ORD_DT, nORG_ORD_SEQ, nORG_CRG_SEQ, vCHANNEL, '2', 0, 'N', '1', ll_rec_cnt, vC_CARD_ID, vC_CRG_AMT, vREF_ORD_DT, vREF_ORD_SEQ, vREF_ITEM_SEQ, vREF_GIFT_SEQ, vREF_CRG_SEQ, ls_err_cd, ls_err_msg, ls_result);
    END IF;
    
    IF ls_err_cd = '0000' THEN
        FOR i IN 1 .. ll_rec_cnt LOOP
            IF vGIFT_METH_DIV IN ('1','2') AND vMMS_SEND_YN = 'Y' THEN --휴대폰 발송이고 즉시발송 일때만    
                BEGIN
                    nMSGKEY := MMS_MSG_SEQ.NEXTVAL;                                           
                                         
                    vMMSMSG := DECRYPT(ARR_CARD_REC(i).ORD_USER_NM)||'님이 보내신 Paul Bassett Society Gift Card가 도착하였습니다.<br>';                
                    vMMSMSG := vMMSMSG || '카드번호 : '||SUBSTR(ARR_CARD_REC(i).CARD_ID,1,4)||'-'||SUBSTR(ARR_CARD_REC(i).CARD_ID,5,4)||'-'||SUBSTR(ARR_CARD_REC(i).CARD_ID,9,4)||'-'||SUBSTR(ARR_CARD_REC(i).CARD_ID,13,4)||'<br>';                
                                          
                    IF vGIFT_MSG IS NOT NULL THEN              
                        vMMSMSG := vMMSMSG || '메세지 : '||vGIFT_MSG;                
                    END IF;              
                                          
                    dbms_output.put_line( vMMSMSG ) ;
                    
                    INSERT INTO MMS_MSG                 
                    (                 
                        MSGKEY, SUBJECT, PHONE, CALLBACK, STATUS,                 
                        REQDATE, MSG, FILE_CNT,                 
                        FILE_PATH1, FILE_PATH2, TYPE                 
                    )                
                    VALUES                
                    (                
                        nMSGKEY, '[WEB발신] 카드선물', DECRYPT(ARR_CARD_REC(i).GIFT_MOBILE), '0220563048', '0',                
                        NVL(TO_DATE( vGIFT_SEND_DT||'01', 'YYYYMMDDHH24MISS'),SYSDATE), vMMSMSG, '2',                 
                        ARR_CARD_REC(i).SV_FILE_PATH, (SELECT 'D:/PaulBassetHome'||SV_FILE_PATH||SV_FILE_NM FROM C_CARD_TYPE WHERE CARD_TYPE = ARR_CARD_REC(i).CARD_TYPE), '7'                
                    );              
                EXCEPTION
                    WHEN OTHERS THEN
                        ROLLBACK;
                        
                        ls_err_cd  := TO_CHAR(SQLCODE);
                        ls_err_msg := SQLERRM ;
                END;
                
                BEGIN
                    UPDATE  C_ORDER_CARD
                    SET     GIFT_SEND_DT   = vGIFT_SEND_DT||'01'
                          , GIFT_SEND_STAT = '0'
                          , MSGKEY         = nMSGKEY 
                          , GIFT_ERR_CD    = DECODE(vGIFT_SEND_DIV, '1', '0000', '0002')
                          , GIFT_ERR_MSG   = FC_GET_WORDPACK(PSV_LANG_CD, DECODE(vGIFT_SEND_DIV, '1', 'SMS_SENDING', 'SMS_SEND_PLAN'))
                    WHERE   COMP_CD  = PSV_COMP_CD
                    AND     ORD_DT   = PSV_ORD_DT
                    AND     ORD_SEQ  = PSV_ORD_SEQ
                    AND     ITEM_SEQ = ARR_CARD_REC(i).ITEM_SEQ
                    AND     GIFT_SEQ = ARR_CARD_REC(i).GIFT_SEQ;
                EXCEPTION
                    WHEN OTHERS THEN
                        ROLLBACK;
                        
                        ls_err_cd  := TO_CHAR(SQLCODE);
                        ls_err_msg := SQLERRM ;
                END;
            END IF;
            
            /* 무통장 입금 확정 취소의 경우 MMS 전소이력 삭제 */
            IF vCRG_FG = '2' AND PSV_APPR_YN = 'Y' THEN
                UPDATE  C_ORDER_CARD
                SET     GIFT_SEND_DT   = NULL
                      , GIFT_SEND_STAT = '0'
                      , MSGKEY         = NULL 
                      , GIFT_ERR_CD    = NULL
                      , GIFT_ERR_MSG   = NULL
                WHERE   COMP_CD  = PSV_COMP_CD
                AND     ORD_DT   = PSV_ORD_DT
                AND     ORD_SEQ  = PSV_ORD_SEQ
                AND     ITEM_SEQ = ARR_CARD_REC(i).ITEM_SEQ
                AND     GIFT_SEQ = ARR_CARD_REC(i).GIFT_SEQ;
                
                SELECT  RSLT INTO vRSLT
                FROM    MMS_MSG
                WHERE   MSGKEY = ARR_CARD_REC(i).MSGKEY;
                
                IF vRSLT IS NULL THEN
                    DELETE  FROM MMS_MSG
                    WHERE   MSGKEY   = ARR_CARD_REC(i).MSGKEY;
                    
                    DELETE  C_ORDER_CARD_HIS
                    WHERE   COMP_CD  = PSV_COMP_CD
                    AND     ORD_DT   = PSV_ORD_DT
                    AND     ORD_SEQ  = PSV_ORD_SEQ
                    AND     ITEM_SEQ = ARR_CARD_REC(i).ITEM_SEQ
                    AND     GIFT_SEQ = ARR_CARD_REC(i).GIFT_SEQ
                    AND     MSGKEY   = ARR_CARD_REC(i).MSGKEY;
                END IF;
            END IF;
            
            -- 주문구분이 반품 & 입출금 확정인     경우 카드 상태를 해지신청(81) --> 해지(91)로 변경
            -- 주문구분이 반품 & 입출금 확정취소인 경우 카드 상태를 해지(91) --> 해지신청(91)로 변경
            IF vORG_ORD_FG = '2' THEN
                BEGIN
                    UPDATE  C_CARD
                    SET     CARD_STAT = CASE WHEN PSV_APPR_YN = 'N' THEN '91'
                                             ELSE                        '81'
                                        END 
                    WHERE   COMP_CD   = PSV_COMP_CD
                    AND     CARD_ID   = encrypt(ARR_CARD_REC(i).CARD_ID);
                EXCEPTION
                    WHEN OTHERS THEN
                        ROLLBACK;
                                
                        ls_err_cd  := TO_CHAR(SQLCODE);
                        ls_err_msg := SQLERRM ;
                END;
            END IF;
        END LOOP;
        
        BEGIN
            UPDATE  C_ORDER_ST
            SET     APPR_YN  = CASE WHEN PSV_APPR_YN = 'Y' THEN 'N'  ELSE 'Y'         END 
                  , APPR_DT  = CASE WHEN PSV_APPR_YN = 'Y' THEN NULL ELSE vSYSDATE    END
                  , APPR_TM  = CASE WHEN PSV_APPR_YN = 'Y' THEN NULL ELSE vSYSTIME    END
                  , USER_ID  = CASE WHEN PSV_APPR_YN = 'Y' THEN NULL ELSE PSV_USER_ID END
            WHERE   COMP_CD  = PSV_COMP_CD
            AND     ORD_DT   = PSV_ORD_DT
            AND     ORD_SEQ  = PSV_ORD_SEQ
            AND     CRG_SEQ  = PSV_CRG_SEQ;
        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK;
                
                ls_err_cd  := TO_CHAR(SQLCODE);
                ls_err_msg := SQLERRM ;
        END;
            
        COMMIT;
    ELSE
        ROLLBACK;
    END IF;
    
    dbms_output.put_line( PR_RTN_CD ) ;
    dbms_output.put_line( PR_RTN_MSG ) ;
    PR_RTN_CD  := ls_err_cd;
    PR_RTN_MSG := CASE WHEN ls_err_cd = '0000' THEN NULL ELSE ls_err_msg END;

EXCEPTION
    WHEN ERR_HANDLER THEN
        PR_RTN_CD  := ls_err_cd;
        PR_RTN_MSG := ls_err_msg ;
       dbms_output.put_line( PR_RTN_MSG ) ;
    WHEN OTHERS THEN
        PR_RTN_CD  := '4999999' ;
        PR_RTN_MSG := SQLERRM ;
        dbms_output.put_line( PR_RTN_MSG ) ;
END ;

/
