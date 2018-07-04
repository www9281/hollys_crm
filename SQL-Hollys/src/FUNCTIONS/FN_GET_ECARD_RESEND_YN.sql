--------------------------------------------------------
--  DDL for Function FN_GET_ECARD_RESEND_YN
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."FN_GET_ECARD_RESEND_YN" 
(                   
    PSV_COMP_CD     IN  VARCHAR2 , --회사코드            
    PSV_ORD_DT      IN  VARCHAR2 , --주문일자           
    PSV_ORD_SEQ     IN  VARCHAR2 , --주문순번           
    PSV_ITEM_SEQ    IN  VARCHAR2 , --상품순번           
    PSV_GIFT_SEQ    IN  VARCHAR2  --카드순번           
) RETURN VARCHAR2 IS              
--------------------------------------------------------------------------------               
--  FUNCTION Name   : FN_GET_ECARD_RESEND_YN         
--  Description      : e-gift카드별 재전송 가능 여부         
--------------------------------------------------------------------------------           
    vRSLT               VARCHAR2(100) := 'N';         
    lSORD_FG            C_ORDER_HD.ORD_FG%TYPE; --주문구분[01990][1:주문, 2:반품, 3:장바구니]           
    ISGIFT_SEND_DT      C_ORDER_HD.GIFT_SEND_DT%TYPE; --전송희망일시               
    lsGIFT_METH_DIV     C_ORDER_HD.GIFT_METH_DIV%TYPE; --선물할 방법[01945][1:휴대폰 전송, 2:휴대폰 대량 전송, 3:이메일 전송]           
    ISCARD_GIFT_SEND_DT C_ORDER_CARD.GIFT_SEND_DT%TYPE; --전송일시           
    lSCARDID            C_ORDER_CARD.CARD_ID%TYPE; --카드번호         
    ISMSGKEY            C_ORDER_CARD.MSGKEY%TYPE; --MMS발송키       
    lSGIFTERRCD         C_ORDER_CARD.GIFT_ERR_CD%TYPE; --MMS전송결과      
    lSAPPRYN            C_ORDER_ST.APPR_YN%TYPE; --결재여부      
            
    nRET_CNT     NUMBER(7) := 0; --반품건수         
    nSEND_CNT    NUMBER(7) := 0; --전송건수         
          
          
BEGIN              
    SELECT GIFT_SEND_DT, GIFT_METH_DIV, ORD_FG              
      INTO ISGIFT_SEND_DT, lsGIFT_METH_DIV, lSORD_FG              
      FROM C_ORDER_HD           
     WHERE COMP_CD = PSV_COMP_CD           
       AND ORD_DT = PSV_ORD_DT           
       AND ORD_SEQ = PSV_ORD_SEQ;           
            
    IF lSORD_FG <> '1' THEN --주문건 아니면 안됨                
        RETURN vRSLT;        
    END IF;        
            
    SELECT MIN(APPR_YN)  
      INTO lSAPPRYN        
      FROM C_ORDER_ST         
     WHERE COMP_CD = PSV_COMP_CD           
       AND ORD_DT = PSV_ORD_DT           
       AND ORD_SEQ = PSV_ORD_SEQ        
       AND ORD_FG = '1';        
            
    IF lSAPPRYN <> 'Y' THEN --결재전이면      
        RETURN vRSLT;        
    END IF;     
            
    IF PSV_GIFT_SEQ IS NOT NULL THEN          
                   
        SELECT GIFT_SEND_DT, MSGKEY, CARD_ID, GIFT_ERR_CD           
          INTO ISCARD_GIFT_SEND_DT, ISMSGKEY, lSCARDID, lSGIFTERRCD           
          FROM C_ORDER_CARD           
         WHERE COMP_CD = PSV_COMP_CD           
           AND ORD_DT = PSV_ORD_DT           
           AND ORD_SEQ = PSV_ORD_SEQ           
           AND ITEM_SEQ = PSV_ITEM_SEQ           
           AND GIFT_SEQ = PSV_GIFT_SEQ;        
             
        --발송중, 무통장 입금 결재전, 예약발송대기     
        IF lSGIFTERRCD = '0000' OR lSGIFTERRCD = '0001' OR lSGIFTERRCD = '0002' THEN      
           vRSLT := 'N';     
           RETURN vRSLT;        
        END IF;        
                      
        IF ISCARD_GIFT_SEND_DT IS NULL OR ISGIFT_SEND_DT IS NULL         
           OR LENGTH(ISCARD_GIFT_SEND_DT) <> '14' OR LENGTH(ISGIFT_SEND_DT) <> '12'         
           THEN --시간 없으면 불가능           
            vRSLT := 'N';         
                  
                  
        ELSIF SYSDATE <= TO_DATE(ISCARD_GIFT_SEND_DT ,'YYYYMMDDHH24MISS')           
              OR SYSDATE <= TO_DATE(ISGIFT_SEND_DT,'YYYYMMDDHH24MI')      
              THEN          
            vRSLT := 'N';        
                      
        ELSE        
             SELECT COUNT(*)       
              INTO nRET_CNT       
              FROM C_ORDER_CARD       
             WHERE COMP_CD = PSV_COMP_CD       
               AND ORG_ORD_DT = PSV_ORD_DT       
               AND ORG_ORD_SEQ = PSV_ORD_SEQ       
               AND CARD_ID = lSCARDID;       
                  
                     
            SELECT COUNT(*)         
              INTO nSEND_CNT         
              FROM C_ORDER_CARD_HIS         
             WHERE COMP_CD = PSV_COMP_CD         
               AND ORD_DT = PSV_ORD_DT         
               AND ORD_SEQ = PSV_ORD_SEQ         
               AND ITEM_SEQ = PSV_ITEM_SEQ         
               AND GIFT_SEQ = PSV_GIFT_SEQ;         
                        
            IF nRET_CNT > 0 OR nSEND_CNT > 3 THEN  --반품이 있거나 전송을 3회 한경우 전송불가         
                vRSLT := 'N';         
            ELSE         
                vRSLT := 'Y';         
            END IF;         
                     
        END IF;           
                                                  
    ELSE --전체는 불가능         
        vRSLT := 'N';           
                
    END IF;           
               
                                              
    RETURN vRSLT;                   
END ;

/
