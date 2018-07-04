--------------------------------------------------------
--  DDL for Function FN_GET_ECARD_CANCLE_YN
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."FN_GET_ECARD_CANCLE_YN" 
(                            
    PSV_COMP_CD     IN  VARCHAR2 , --회사코드                     
    PSV_ORD_DT      IN  VARCHAR2 , --주문일자                    
    PSV_ORD_SEQ     IN  VARCHAR2 , --주문순번                    
    PSV_ITEM_SEQ    IN  VARCHAR2 , --상품순번                    
    PSV_GIFT_SEQ    IN  VARCHAR2  --카드순번                    
) RETURN VARCHAR2 IS                       
--------------------------------------------------------------------------------                        
--  FUNCTION Name   : FN_GET_ECARD_CANCLE_YN                  
--  Description      : e-gift카드 결재취소 가능 여부                 
--------------------------------------------------------------------------------                    
    vRSLT               VARCHAR2(100) := 'Y';                  
    lSORD_FG            C_ORDER_HD.ORD_FG%TYPE; --주문구분[01990][1:주문, 2:반품, 3:장바구니]                 
    ISGIFT_SEND_DT      C_ORDER_HD.GIFT_SEND_DT%TYPE; --전송희망일시                        
    lsGIFT_METH_DIV     C_ORDER_HD.GIFT_METH_DIV%TYPE; --선물할 방법[01945][1:휴대폰 전송, 2:휴대폰 대량 전송, 3:이메일 전송]                    
    ISCARD_GIFT_SEND_DT C_ORDER_CARD.GIFT_SEND_DT%TYPE; --전송일시                    
    lSCARDID            C_ORDER_CARD.CARD_ID%TYPE; --카드번호                  
    ISMSGKEY            C_ORDER_CARD.MSGKEY%TYPE; --MMS발송키                  
    lSAPPR_DT           C_ORDER_ST.APPR_DT%TYPE; --결재일자                
    lSAPPR_YN           C_ORDER_ST.APPR_YN%TYPE; --결재여부              
    lSGIFTERRCD         C_ORDER_CARD.GIFT_ERR_CD%TYPE; --MMS전송결과              
                    
    nRET_CNT            NUMBER(7) := 0; --반품건수                  
    nREG_CNT            NUMBER(7) := 0; --등록건수                  
    nCHARGE_HIS         NUMBER(7) := 0; --충전이력             
    nUSE_HIS            NUMBER(7) := 0; --사용건수             
    nCHARGE_HISMAX         NUMBER(7) := 0; --충전이력             
    nCHARGE_HISMIN         NUMBER(7) := 0; --충전이력  
    
    vRETVAL         NUMBER(7)      := 0;   
    vRETMSG         VARCHAR2(2000) := NULL;   
    cREFCUR         REC_SET.M_REFCUR; 
    
    -- 쿠폰취소가능여부 확인 타입
    TYPE  TYPE_CUPN_CANC_YN IS RECORD   
       (           
          SALE_DT   VARCHAR2(100), --판매일자(ord_dt)
          BRAND_CD  VARCHAR2(100), --브랜드코드
          STOR_CD   VARCHAR2(100), --스토어코드(ord_seq)
          POS_NO    VARCHAR2(100), --포스번호
          BILL_NO   VARCHAR2(100), --빌번호
          VOID_YN   VARCHAR2(1) --취소가능여부(Y/N)
       );   

    ARR_CUPN_CANC_YN TYPE_CUPN_CANC_YN;
                       
                   
BEGIN                  
               
    SELECT GIFT_SEND_DT, GIFT_METH_DIV, ORD_FG                    
      INTO ISGIFT_SEND_DT, lsGIFT_METH_DIV, lSORD_FG                    
      FROM C_ORDER_HD                    
     WHERE COMP_CD = PSV_COMP_CD                    
       AND ORD_DT = PSV_ORD_DT                    
       AND ORD_SEQ = PSV_ORD_SEQ;                    
                     
    IF lSORD_FG <> '1' THEN --주문건 아니면 안됨             
        vRSLT := 'Z';             
        RETURN vRSLT;                 
    END IF;                 
               
              
    --결재 후 7일이 지났으면                
    SELECT APPR_DT , APPR_YN               
      INTO lSAPPR_DT, lSAPPR_YN                
      FROM C_ORDER_ST                
     WHERE COMP_CD = PSV_COMP_CD                    
       AND ORD_DT = PSV_ORD_DT                    
       AND ORD_SEQ = PSV_ORD_SEQ                
       AND ORD_FG = '1';                
              
             
    IF lSAPPR_DT IS NULL                 
       OR LENGTH(lSAPPR_DT) <> '8'                 
       OR TO_CHAR(TO_DATE(lSAPPR_DT,'YYYYMMDD')+7 , 'YYYYMMDD') <= TO_CHAR(SYSDATE,'YYYYMMDD')                  
       OR lSAPPR_YN = 'N' --결재여부가 N이여야 함              
       THEN              
        vRSLT := 'N';             
        RETURN vRSLT;                 
    END IF;
    
    
    --eCard구매에 따른 쿠폰취소가능여부 확인 / PRT_BILL_NO에 'EC'가 들어가면 ECARD이다
    PKG_POS_CUST_REQ.GET_MEMB_CUPN_20(PSV_COMP_CD, 'KOR', PSV_ORD_DT, '001', TO_CHAR(PSV_ORD_SEQ, 'FM999999'), '', 'ECARD', vRETVAL, vRETMSG, cREFCUR);
    
    /* 레코드 패치 */
    FETCH cREFCUR INTO ARR_CUPN_CANC_YN;
    
    --cREFCUR에서 결과값 가져오기
    IF ARR_CUPN_CANC_YN.VOID_YN = 'N' THEN 
    vRSLT := 'N';             
        RETURN vRSLT;                 
    END IF;
              
                     
    IF PSV_GIFT_SEQ IS NOT NULL THEN  --건별 결재취소 가능 여부                 
            
            
        SELECT GIFT_SEND_DT, MSGKEY, CARD_ID , GIFT_ERR_CD                  
          INTO ISCARD_GIFT_SEND_DT, ISMSGKEY, lSCARDID,  lSGIFTERRCD                   
          FROM C_ORDER_CARD                   
         WHERE COMP_CD = PSV_COMP_CD                   
           AND ORD_DT = PSV_ORD_DT                   
           AND ORD_SEQ = PSV_ORD_SEQ                   
           AND ITEM_SEQ = PSV_ITEM_SEQ                   
           AND GIFT_SEQ = PSV_GIFT_SEQ;                 
                    
                    
        --반품있으면             
        SELECT COUNT(*)                 
          INTO nRET_CNT                 
          FROM C_ORDER_CARD             
         WHERE COMP_CD = PSV_COMP_CD                 
           AND ORG_ORD_DT = PSV_ORD_DT                 
           AND ORG_ORD_SEQ = PSV_ORD_SEQ             
           AND CARD_ID = lSCARDID;                                   
                     
        IF nRET_CNT > 0 THEN             
           vRSLT := 'N';             
           RETURN vRSLT;                            
        END IF;                
                     
        --카드등록한게 있으면             
        SELECT COUNT(*)                 
          INTO nREG_CNT                 
          FROM C_CARD                 
         WHERE CUST_ID IS NOT NULL             
           AND CARD_ID = lSCARDID;              
                       
        IF nREG_CNT > 0 THEN             
           vRSLT := 'N';             
           RETURN vRSLT;                            
        END IF;             
                     
        --카드사용건이 있으면             
        SELECT COUNT(*)             
          INTO nUSE_HIS             
          FROM C_CARD_USE_HIS             
         WHERE CARD_ID = lSCARDID             
           AND USE_YN = 'Y';              
                     
        IF nUSE_HIS > 0 THEN             
           vRSLT := 'N';             
           RETURN vRSLT;                            
        END IF;             
                    
                     
        --구매시 충전외에 다른건이 있으면  
        /*  
        SELECT COUNT(*)             
          INTO nCHARGE_HIS             
          FROM C_CARD_CHARGE_HIS             
         WHERE CARD_ID = lSCARDID             
          AND USE_YN = 'Y';  
                       
        IF nCHARGE_HIS > 1 THEN             
           vRSLT := 'N';             
           RETURN vRSLT;                            
        END IF;             
        */  
                    
                    
        --발송중이나 정상 발송이면 결재취소 불가            
        IF lSGIFTERRCD IN ('0000','1000','0001','8501','8502') THEN             
           vRSLT := 'N';             
           RETURN vRSLT;                            
        END IF;                               
                    
                      
                                                                                    
    ELSE --전체 결재취소 가능 여부                 
            
            
        --반품있으면             
        SELECT COUNT(*)                 
          INTO nRET_CNT                 
          FROM C_ORDER_HD                 
         WHERE ORD_FG = '2'                 
           AND COMP_CD = PSV_COMP_CD                 
           AND ORG_ORD_DT = PSV_ORD_DT                 
           AND ORG_ORD_SEQ = PSV_ORD_SEQ;             
                     
        IF nRET_CNT > 0 THEN             
           vRSLT := 'N';             
           RETURN vRSLT;                            
        END IF;                
                     
        DBMS_OUTPUT.PUT_LINE('nRET_CNT:'||nRET_CNT);             
                     
        --카드등록한게 있으면             
        SELECT COUNT(*)                 
          INTO nREG_CNT                 
          FROM C_CARD                 
         WHERE CUST_ID IS NOT NULL                 
           AND CARD_ID IN (SELECT CARD_ID                 
                             FROM C_ORDER_CARD CC                 
                            WHERE CC.COMP_CD = PSV_COMP_CD                 
                              AND CC.ORD_DT = PSV_ORD_DT                 
                              AND CC.ORD_SEQ = PSV_ORD_SEQ);                 
                       
        IF nREG_CNT > 0 THEN             
           vRSLT := 'N';             
           RETURN vRSLT;                            
        END IF;             
                     
        DBMS_OUTPUT.PUT_LINE('nREG_CNT:'||nREG_CNT);             
         
         
        --카드사용건이 있으면             
        SELECT COUNT(*)             
          INTO nUSE_HIS             
          FROM C_CARD_USE_HIS             
         WHERE CARD_ID IN (SELECT CARD_ID                 
                             FROM C_ORDER_CARD CC                 
                            WHERE CC.COMP_CD = PSV_COMP_CD                 
                              AND CC.ORD_DT = PSV_ORD_DT                 
                              AND CC.ORD_SEQ = PSV_ORD_SEQ)             
          AND USE_YN = 'Y';             
                     
                     
        DBMS_OUTPUT.PUT_LINE('nUSE_HIS:'||nUSE_HIS);             
                     
        IF nUSE_HIS > 0 THEN             
           vRSLT := 'N';             
           RETURN vRSLT;                            
        END IF;    
           
           
        SELECT COUNT(*)   
          INTO nRET_CNT   
          FROM C_ORDER_CARD   
         WHERE COMP_CD = PSV_COMP_CD   
           AND ORD_DT = PSV_ORD_DT   
           AND ORD_SEQ = PSV_ORD_SEQ   
           AND GIFT_ERR_CD IN ('0000','1000','0001','8501','8502');   
           
        IF nRET_CNT > 0 THEN             
           vRSLT := 'N';             
           RETURN vRSLT;                            
        END IF;   
                  
                  
    END IF;                    
                                                              
    RETURN vRSLT;                            
END ;

/
