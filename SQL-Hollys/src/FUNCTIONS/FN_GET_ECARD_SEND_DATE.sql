--------------------------------------------------------
--  DDL for Function FN_GET_ECARD_SEND_DATE
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."FN_GET_ECARD_SEND_DATE" 
(              
    PSV_COMP_CD     IN  VARCHAR2 , --회사코드       
    PSV_ORD_DT      IN  VARCHAR2 , --주문일자      
    PSV_ORD_SEQ     IN  VARCHAR2 , --주문순번      
    PSV_ITEM_SEQ    IN  VARCHAR2 , --상품순번      
    PSV_GIFT_SEQ    IN  VARCHAR2  --카드순번      
) RETURN DATE IS         
--------------------------------------------------------------------------------          
--  FUNCTION Name   : FN_GET_ECARD_SEND_DATE          
--  Description      : e-gift카드별 발송일시 확인     
--------------------------------------------------------------------------------      
    vRSLT               DATE;      
    lSORD_FG            C_ORDER_HD.ORD_FG%TYPE; --주문구분[01990][1:주문, 2:반품, 3:장바구니]      
    ISGIFT_SEND_DT      C_ORDER_HD.GIFT_SEND_DT%TYPE; --전송희망일시          
    lsGIFT_METH_DIV     C_ORDER_HD.GIFT_METH_DIV%TYPE; --선물할 방법[01945][1:휴대폰 전송, 2:휴대폰 대량 전송, 3:이메일 전송]      
    ISCARD_GIFT_SEND_DT C_ORDER_CARD.GIFT_SEND_DT%TYPE; --전송일시      
    ISMSGKEY            C_ORDER_CARD.MSGKEY%TYPE; --MMS발송키      
     
     
BEGIN         
    SELECT GIFT_SEND_DT, GIFT_METH_DIV, ORD_FG         
      INTO ISGIFT_SEND_DT, lsGIFT_METH_DIV, lSORD_FG         
      FROM C_ORDER_HD      
     WHERE COMP_CD = PSV_COMP_CD      
       AND ORD_DT = PSV_ORD_DT      
       AND ORD_SEQ = PSV_ORD_SEQ;      
        
    IF lSORD_FG <> '1' THEN --주문건 아니면 안됨    
        vRSLT := '';     
        RETURN vRSLT;    
    END IF;  
      
    IF ISGIFT_SEND_DT IS NULL OR LENGTH(ISGIFT_SEND_DT) <> '12' THEN      
       vRSLT := '';     
      RETURN vRSLT;    
    END IF;  
      
    IF PSV_GIFT_SEQ IS NOT NULL THEN     
              
        SELECT GIFT_SEND_DT, MSGKEY      
          INTO ISCARD_GIFT_SEND_DT, ISMSGKEY      
          FROM C_ORDER_CARD      
         WHERE COMP_CD = PSV_COMP_CD      
           AND ORD_DT = PSV_ORD_DT      
           AND ORD_SEQ = PSV_ORD_SEQ      
           AND ITEM_SEQ = PSV_ITEM_SEQ      
           AND GIFT_SEQ = PSV_GIFT_SEQ;      
         
        IF LENGTH(ISCARD_GIFT_SEND_DT) < 14 THEN  
           ISCARD_GIFT_SEND_DT := ''; 
        END IF; 
         
        vRSLT := NVL(TO_DATE(ISCARD_GIFT_SEND_DT ,'YYYYMMDDHH24MISS'),'');  
          
    ELSE     
        SELECT MAX(GIFT_SEND_DT) 
          INTO ISCARD_GIFT_SEND_DT 
          FROM C_ORDER_CARD      
         WHERE COMP_CD = PSV_COMP_CD      
           AND ORD_DT = PSV_ORD_DT      
           AND ORD_SEQ = PSV_ORD_SEQ;      
         
        IF LENGTH(ISCARD_GIFT_SEND_DT) < 14 THEN  
           ISCARD_GIFT_SEND_DT := ''; 
        END IF; 
        vRSLT := NVL(TO_DATE(ISCARD_GIFT_SEND_DT ,'YYYYMMDDHH24MISS'),'');  
                                             
    END IF;      
          
                                         
    RETURN vRSLT;              
END ;

/
