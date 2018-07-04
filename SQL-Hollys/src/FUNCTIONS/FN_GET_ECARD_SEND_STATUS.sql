--------------------------------------------------------
--  DDL for Function FN_GET_ECARD_SEND_STATUS
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."FN_GET_ECARD_SEND_STATUS" 
(                    
    PSV_COMP_CD     IN  VARCHAR2 , --회사코드             
    PSV_ORD_DT      IN  VARCHAR2 , --주문일자            
    PSV_ORD_SEQ     IN  VARCHAR2 , --주문순번            
    PSV_ITEM_SEQ    IN  VARCHAR2 , --상품순번            
    PSV_GIFT_SEQ    IN  VARCHAR2  --카드순번            
) RETURN VARCHAR2 IS               
--------------------------------------------------------------------------------                
--  FUNCTION Name   : FN_ECARD_SEND_TIME                
--  Description      : e-gift카드 발송상태 확인            
--------------------------------------------------------------------------------            
    vRSLT               VARCHAR2(100) := '발송완료';                   
    lSORD_FG            C_ORDER_HD.ORD_FG%TYPE; --주문구분[01990][1:주문, 2:반품, 3:장바구니]            
    ISGIFT_SEND_DT      C_ORDER_HD.GIFT_SEND_DT%TYPE; --전송희망일시                
    lsGIFT_METH_DIV     C_ORDER_HD.GIFT_METH_DIV%TYPE; --선물할 방법[01945][1:휴대폰 전송, 2:휴대폰 대량 전송, 3:이메일 전송]            
    ISCARD_GIFT_SEND_DT C_ORDER_CARD.GIFT_SEND_DT%TYPE; --전송일시            
    ISCARD_GIFT_SEND_STAT C_ORDER_CARD.GIFT_SEND_STAT%TYPE; --전송상태         
    ISGIFT_ERR_CD       C_ORDER_CARD.GIFT_ERR_CD%TYPE; --전송상태코드         
    ISGIFT_ERR_MSG      C_ORDER_CARD.GIFT_ERR_MSG%TYPE; --전송상태메세지         
    ISMSGKEY            C_ORDER_CARD.MSGKEY%TYPE; --MMS발송키            
    lSAPPRDT            C_ORDER_ST.APPR_DT%TYPE; --결재 승인일자         
    lSAPPRYN            C_ORDER_ST.APPR_YN%TYPE; --결재 완료여부       
           
    lSSENDING_CNT       NUMBER(7); --발송중 건수       
    lSSEND_CNT          NUMBER(7); --발송 건수       
    lSSENDWAIT_CNT      NUMBER(7); --발송 대기중 건수       
    lSSENDFAIL_CNT      NUMBER(7); --발송실패 건수       
          
    nRecCnt         NUMBER(7) := 0;       
    nCanRecCnt         NUMBER(7) := 0;       
                
BEGIN               
    SELECT GIFT_SEND_DT, GIFT_METH_DIV, ORD_FG               
      INTO ISGIFT_SEND_DT, lsGIFT_METH_DIV, lSORD_FG               
      FROM C_ORDER_HD            
     WHERE COMP_CD = PSV_COMP_CD            
       AND ORD_DT = PSV_ORD_DT            
       AND ORD_SEQ = PSV_ORD_SEQ;            
               
    IF lSORD_FG <> '1' THEN --주문건 아니면 안됨           
        vRSLT := '주문건아님';            
        RETURN vRSLT;           
    END IF;           
               
    SELECT MIN(APPR_YN)           
      INTO lSAPPRYN           
      FROM C_ORDER_ST            
     WHERE COMP_CD = PSV_COMP_CD              
       AND ORD_DT = PSV_ORD_DT              
       AND ORD_SEQ = PSV_ORD_SEQ           
       AND ORD_FG = '1';           
               
    IF lSAPPRYN <> 'Y' THEN --결재여부 체크         
        vRSLT := '결제전';            
        RETURN vRSLT;           
    END IF;        
           
    IF ISGIFT_SEND_DT IS NULL OR LENGTH(ISGIFT_SEND_DT) <> '12' THEN         
        vRSLT := '발송희망일자확인';         
        RETURN vRSLT;            
    END IF;       
             
             
    IF PSV_GIFT_SEQ IS NOT NULL THEN --건별 발송여부                   
              
        SELECT COUNT(*)      
          INTO nRecCnt      
          FROM C_ORDER_CARD      
         WHERE COMP_CD = PSV_COMP_CD            
           AND ORG_ORD_DT = PSV_ORD_DT            
           AND ORG_ORD_SEQ = PSV_ORD_SEQ            
           AND ORG_ITEM_SEQ = PSV_ITEM_SEQ            
           AND ORG_GIFT_SEQ = PSV_GIFT_SEQ;      
                 
              
        IF nRecCnt > 0 THEN      
           vRSLT := '결제 취소';      
           RETURN vRSLT;          
        END IF;         
              
        SELECT GIFT_SEND_DT, GIFT_SEND_STAT, MSGKEY, GIFT_ERR_CD, GIFT_ERR_MSG         
          INTO ISCARD_GIFT_SEND_DT, ISCARD_GIFT_SEND_STAT, ISMSGKEY, ISGIFT_ERR_CD, ISGIFT_ERR_MSG         
          FROM C_ORDER_CARD            
         WHERE COMP_CD = PSV_COMP_CD            
           AND ORD_DT = PSV_ORD_DT            
           AND ORD_SEQ = PSV_ORD_SEQ            
           AND ITEM_SEQ = PSV_ITEM_SEQ            
           AND GIFT_SEQ = PSV_GIFT_SEQ;                      
      
               
        IF ISGIFT_ERR_CD IS NULL OR ISGIFT_ERR_CD = '0001' OR ISGIFT_ERR_CD = '0002' THEN       
           vRSLT := '발송 대기중';         
           RETURN vRSLT;            
        ELSIF ISGIFT_ERR_CD = '0000' THEN       
           vRSLT := '발송 중';         
           RETURN vRSLT;            
        ELSIF ISGIFT_ERR_CD IN ('8501','8502') THEN       
           vRSLT := '주문취소';         
           RETURN vRSLT;               
        ELSIF ISGIFT_ERR_CD = '1000' THEN       
           vRSLT := '발송 완료';         
           RETURN vRSLT;            
        ELSE       
           vRSLT := '발송 실패';         
           RETURN vRSLT;            
        END IF;       
               
                                                   
    ELSE --전체 발송여부            
               
        SELECT        
            SUM(DECODE(GIFT_ERR_CD,'0000',1,0)) AS SENDING_YN --발송중건수    
            ,SUM(DECODE(GIFT_ERR_CD,'1000',1,0)) AS SEND_YN --발송완료건수       
            ,SUM(DECODE(GIFT_ERR_CD,'0001',1,'0002',1,'',1,0)) AS SENDWAIT_YN --발송 대기중 건수      
            ,SUM(CASE WHEN GIFT_ERR_CD = '0000' OR GIFT_ERR_CD = '1000' OR GIFT_ERR_CD = '0001' OR GIFT_ERR_CD = '0002' OR GIFT_ERR_CD IS NULL THEN '0'       
             ELSE '1' END) AS SENDFAIL_YN --발송실패건수                  
        INTO lSSENDING_CNT, lSSEND_CNT, lSSENDWAIT_CNT, lSSENDFAIL_CNT  
        FROM C_ORDER_CARD A       
        WHERE COMP_CD = PSV_COMP_CD      
        AND ORD_DT = PSV_ORD_DT      
        AND ORD_SEQ = PSV_ORD_SEQ      
        AND NOT EXISTS (SELECT * --결재취소건 제외  
                          FROM C_ORDER_CARD B  
                         WHERE B.COMP_CD = A.COMP_CD  
                           AND B.ORG_ORD_DT = A.ORD_DT  
                           AND B.ORG_ORD_SEQ = A.ORD_SEQ  
                           AND B.ORG_ITEM_SEQ = A.ITEM_SEQ  
                           AND B.ORG_GIFT_SEQ = A.GIFT_SEQ  
                        )   
        ;   
          
        SELECT COUNT(*)       
          INTO nCanRecCnt --결재취소건수     
          FROM C_ORDER_CARD      
         WHERE COMP_CD = PSV_COMP_CD      
           AND ORG_ORD_DT = PSV_ORD_DT      
           AND ORG_ORD_SEQ = PSV_ORD_SEQ;  
          
        SELECT COUNT(*)       
        INTO nRecCnt --전체건수       
          FROM C_ORDER_CARD      
         WHERE COMP_CD = PSV_COMP_CD      
           AND ORD_DT = PSV_ORD_DT      
           AND ORD_SEQ = PSV_ORD_SEQ;  
           
  
        IF nRecCnt = nCanRecCnt THEN      
          vRSLT := '결제취소';      
          RETURN vRSLT;   
        END IF;       
          
        IF lSSENDWAIT_CNT > 0 THEN       
           vRSLT := '발송 대기중';         
           RETURN vRSLT;       
        END IF;       
               
        IF lSSENDING_CNT > 0 THEN       
           vRSLT := '발송 중';         
           RETURN vRSLT;       
        END IF;       
                              
        IF lSSENDFAIL_CNT > 0 THEN       
           vRSLT := '발송 실패';         
           RETURN vRSLT;       
        END IF;       
               
        IF lSSEND_CNT > 0 THEN       
           vRSLT := '발송 완료';         
           RETURN vRSLT;       
        END IF;       
               
      
               
    END IF;            
                
                                               
    RETURN vRSLT;                    
END ;

/
