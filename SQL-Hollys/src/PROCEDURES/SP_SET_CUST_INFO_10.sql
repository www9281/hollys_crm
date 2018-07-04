--------------------------------------------------------
--  DDL for Procedure SP_SET_CUST_INFO_10
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_SET_CUST_INFO_10" 
(   
    PSV_COMP_CD           IN   VARCHAR2, -- 1. 회사코드   
    PSV_LANG_TP           IN   VARCHAR2, -- 2. 언어코드   
    PSV_ISSUE_DIV         IN   VARCHAR2, -- 3. 발급구분[0:신규, 1:재발급]   
    PSV_CARD_ID           IN   VARCHAR2, -- 4. 신규 카드번호, 재발급 카드번호   
    PSV_ISSUE_DT          IN   VARCHAR2, -- 6. 발급일자   
    PSV_BRAND_CD          IN   VARCHAR2, -- 7. 영업조직   
    PSV_STOR_CD           IN   VARCHAR2, -- 8. 점포코드   
    asRetVal              OUT  VARCHAR2, -- 9. 결과코드[1:정상  그외는 오류]   
    asRetMsg              OUT  VARCHAR2  -- 10. 결과메시지   
) IS   
    lsCustId        PCRM.C_CARD.CUST_ID%TYPE;                    -- 회원 ID   
    lsCardId        PCRM.C_CARD.CARD_ID%TYPE;                    -- 카드 ID   
    lscard_div      PCRM.C_CARD.CARD_DIV%TYPE;                   -- 카드관리범위[1:회사, 2:영업조직, 3:점포]   
    lsbrand_cd      PCRM.C_CARD.BRAND_CD%TYPE;                   -- 영업조직   
    lsstor_cd       PCRM.C_CARD.STOR_CD%TYPE;                    -- 점포코드   
    lsrep_card_yn   PCRM.C_CARD.REP_CARD_YN%TYPE;                -- 대표카드여부   
    nCurPoint       PCRM.C_CARD.SAV_PT%TYPE   := 0;              -- 현재 포인트   
    nRecCnt         NUMBER(7) := 0;   
    nCheckDigit     NUMBER(7) := 0;                              -- 체크디지트   
       
    ERR_HANDLER     EXCEPTION;   
BEGIN   
    asRetVal    := '0000';   
    asRetMsg    := 'OK'  ;   
       
    SELECT COUNT(*)   
      INTO nRecCnt   
      FROM PCRM.C_CARD -- 멤버십카드 마스터   
     WHERE COMP_CD    = PSV_COMP_CD   
       AND CARD_ID    = PSV_CARD_ID;   
       
    IF nRecCnt > 0 THEN   
       asRetVal := '1000';   
       asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001428'); -- 이미 등록된 카드번호 입니다.   
       
       RAISE ERR_HANDLER;   
    ELSE   
       BEGIN   
         SELECT CP.CARD_DIV, BM.BRAND_CD, '0000000'   
           INTO lscard_div , lsbrand_cd , lsstor_cd   
           FROM COMPANY_PARA CP   
              , BRAND_MEMB   BM   
          WHERE CP.COMP_CD  = BM.COMP_CD   
            AND BM.COMP_CD  = PSV_COMP_CD   
            AND BM.BRAND_CD = (   
                                SELECT CCT.TSMS_BRAND_CD   
                                  FROM PCRM.C_CARD_TYPE     CCT   
                                     , PCRM.C_CARD_TYPE_REP CTR   
                                 WHERE CCT.COMP_CD   = CTR.COMP_CD   
                                   AND CCT.CARD_TYPE = CTR.CARD_TYPE   
                                   AND CTR.COMP_CD   = PSV_COMP_CD   
                                   AND decrypt(PSV_CARD_ID) BETWEEN decrypt(CTR.START_CARD_CD) AND decrypt(CTR.CLOSE_CARD_CD)   
                                   AND ROWNUM        = 1   
                              )   
            AND USE_YN      = 'Y'; -- 사용여부[Y:사용, N:사용안함]   
       EXCEPTION   
         WHEN OTHERS THEN   
              asRetVal := '1002';   
              asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001394'); -- 등록하지 않은 카드번호 입니다.   
       
              RAISE ERR_HANDLER;   
       END;   
       
       CASE WHEN lscard_div = '1' THEN -- 회사   
                 lsbrand_cd := NVL(PSV_BRAND_CD, lsbrand_cd);   
                 lsstor_cd  := '0000000';   
            WHEN lscard_div = '2' THEN -- 영업조직   
                 lsbrand_cd := NVL(PSV_BRAND_CD, lsbrand_cd);   
                 lsstor_cd  := '0000000';   
            WHEN lscard_div = '3' THEN -- 점포   
                 lsbrand_cd := NVL(PSV_BRAND_CD, lsbrand_cd);   
                 lsstor_cd  := NVL(PSV_STOR_CD , lsstor_cd );   
       END CASE;   
       
       -- 체크 디지트 체크   
       lsCardId    := decrypt(PSV_CARD_ID);   
       nCheckDigit := MOD(TO_NUMBER(SUBSTR(lsCardId,1,1))*1  + TO_NUMBER(SUBSTR(lsCardId,2,1))*3  +   
                          TO_NUMBER(SUBSTR(lsCardId,3,1))*1  + TO_NUMBER(SUBSTR(lsCardId,4,1))*3  +   
                          TO_NUMBER(SUBSTR(lsCardId,5,1))*1  + TO_NUMBER(SUBSTR(lsCardId,6,1))*3  +   
                          TO_NUMBER(SUBSTR(lsCardId,7,1))*1  + TO_NUMBER(SUBSTR(lsCardId,8,1))*3  +   
                          TO_NUMBER(SUBSTR(lsCardId,9,1))*1  + TO_NUMBER(SUBSTR(lsCardId,10,1))*3 +   
                          TO_NUMBER(SUBSTR(lsCardId,11,1))*1 + TO_NUMBER(SUBSTR(lsCardId,12,1))*3 +   
                          TO_NUMBER(SUBSTR(lsCardId,13,1))*1 + TO_NUMBER(SUBSTR(lsCardId,14,1))*3 +   
                          TO_NUMBER(SUBSTR(lsCardId,15,1))*1,10);   
       
       IF SUBSTR(lsCardId, 16, 1) != TO_CHAR(nCheckDigit, 'FM0') OR LENGTH(lsCardId) != 16 THEN   
         asRetVal := '1001';   
         asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001436'); -- 카드 등록에 실패하였습니다.   
       
         ROLLBACK;   
         RAISE ERR_HANDLER;   
       END IF;   
       
       -- 멤버십 카드 등록   
       BEGIN   
         INSERT INTO PCRM.C_CARD   
         (   
             COMP_CD, CARD_ID, CUST_ID, CARD_STAT, ISSUE_DIV, ISSUE_DT, ISSUE_BRAND_CD, ISSUE_STOR_CD,   
             SAV_PT, CARD_DIV, BRAND_CD, STOR_CD, REP_CARD_YN, INST_USER, UPD_USER   
         )   
         VALUES   
         (   
             PSV_COMP_CD, PSV_CARD_ID, lsCustId, '10', '0', PSV_ISSUE_DT||TO_CHAR(SYSDATE, 'HH24MISS'), lsbrand_cd, lsstor_cd,   
             nCurPoint, lscard_div, lsbrand_cd, lsstor_cd, NVL(lsrep_card_yn, 'N'), 'SYSTEM', 'SYSTEM'   
         );   
       EXCEPTION   
         WHEN OTHERS THEN   
              asRetVal := '1003';   
              asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001401'); -- 카드 등록에 실패하였습니다.   
       
              ROLLBACK;   
              RAISE ERR_HANDLER;   
       END;   
    END IF;   
    
    asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001392'); -- 정상처리 되었습니다.   
   
    COMMIT;   
   
    RETURN;   
EXCEPTION   
    WHEN ERR_HANDLER THEN   
        ROLLBACK;   
   
        RETURN;   
    WHEN OTHERS THEN   
        asRetVal := '2001';   
        asRetMsg := SUBSTRB(SQLERRM(SQLCODE), 1, 60);   
       
        ROLLBACK;   
       
        RETURN;   
END SP_SET_CUST_INFO_10;

/
