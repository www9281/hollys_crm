--------------------------------------------------------
--  DDL for Procedure C_VOC_SAVE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_VOC_SAVE" (
    N_VOC_SEQ           IN    VARCHAR2,
    N_BRAND_CD          IN    VARCHAR2,
    N_RECV_DIV          IN    VARCHAR2,
    N_PRCS_STATE        IN    VARCHAR2,
    N_INQRY_TYPE        IN    VARCHAR2,
    N_VOC_HIGHCATE      IN    VARCHAR2,
    N_VOC_LOWCATE       IN    VARCHAR2,
    N_VOC_TITLE         IN    VARCHAR2,
    N_CUST_ID           IN    VARCHAR2,
    N_CUST_NM           IN    VARCHAR2,
    N_CUST_WEB_ID       IN    VARCHAR2,
    N_MOBILE            IN    VARCHAR2,
    N_EMAIL             IN    VARCHAR2,
    N_AREA_DIV          IN    VARCHAR2,
    N_NATION_CD         IN    VARCHAR2,
    N_SIDO_CD           IN    VARCHAR2,
    N_REGION            IN    VARCHAR2,
    N_STOR_NM           IN    VARCHAR2,
    N_STOR_CD           IN    VARCHAR2,
    N_VISIT_DT          IN    VARCHAR2,
    N_CONTENT           IN    VARCHAR2,
    N_REPLY_CONTENT     IN    VARCHAR2,
    N_REMARK            IN    VARCHAR2,
    N_BAD_CUST_YN       IN    VARCHAR2,
    P_MY_USER_ID        IN    VARCHAR2, 
    O_VOC_SEQ           OUT   VARCHAR2
) AS 
BEGIN
    
    IF N_VOC_SEQ IS NULL THEN
      -- 상담 신규등록
      SELECT 
         SQ_VOC_SEQ.NEXTVAL
         INTO O_VOC_SEQ
      FROM DUAL;
      
      INSERT INTO C_VOC (
        VOC_SEQ      
        ,BRAND_CD     
        ,RECV_DIV     
        ,PRCS_STATE   
        ,INQRY_TYPE   
        ,VOC_HIGHCATE 
        ,VOC_LOWCATE  
        ,TITLE    
        ,CUST_ID      
        ,CUST_NM      
        ,CUST_WEB_ID  
        ,MOBILE_NO       
        ,EMAIL        
        ,AREA_DIV     
        ,NATION_CD    
        ,SIDO_CD      
        ,GUGUN_CD       
        ,STOR_NM      
        ,STOR_CD      
        ,VISIT_DT     
        ,CONTENT      
        ,REMARK       
        ,BAD_CUST_YN
      ) VALUES (
        O_VOC_SEQ
        ,N_BRAND_CD     
        ,N_RECV_DIV     
        ,N_PRCS_STATE   
        ,N_INQRY_TYPE   
        ,N_VOC_HIGHCATE 
        ,N_VOC_LOWCATE  
        ,N_VOC_TITLE    
        ,N_CUST_ID      
        ,N_CUST_NM      
        ,N_CUST_WEB_ID  
        ,N_MOBILE       
        ,N_EMAIL        
        ,N_AREA_DIV     
        ,N_NATION_CD    
        ,N_SIDO_CD      
        ,N_REGION       
        ,N_STOR_NM      
        ,N_STOR_CD      
        ,N_VISIT_DT     
        ,N_CONTENT      
        ,N_REMARK       
        ,N_BAD_CUST_YN
      );
    ELSE
      -- 상담 내용수정
      O_VOC_SEQ := N_VOC_SEQ;
      
      UPDATE C_VOC SET
        BRAND_CD       = N_BRAND_CD
        ,RECV_DIV      = N_RECV_DIV
        ,PRCS_STATE    = N_PRCS_STATE
        ,INQRY_TYPE    = N_INQRY_TYPE
        ,VOC_HIGHCATE  = N_VOC_HIGHCATE
        ,VOC_LOWCATE   = N_VOC_LOWCATE
        ,TITLE     = N_VOC_TITLE
        ,CUST_ID       = N_CUST_ID
        ,CUST_NM       = N_CUST_NM
        ,CUST_WEB_ID   = N_CUST_WEB_ID
        ,MOBILE_NO        = N_MOBILE
        ,EMAIL         = N_EMAIL
        ,AREA_DIV      = N_AREA_DIV
        ,NATION_CD     = N_NATION_CD
        ,SIDO_CD       = N_SIDO_CD
        ,GUGUN_CD        = N_REGION
        ,STOR_NM       = N_STOR_NM
        ,STOR_CD       = N_STOR_CD
        ,VISIT_DT      = N_VISIT_DT
        ,CONTENT       = N_CONTENT
        ,REMARK        = N_REMARK
        ,BAD_CUST_YN   = N_BAD_CUST_YN
        ,UPD_DT        = SYSDATE
        ,UPD_USER      = P_MY_USER_ID
      WHERE VOC_SEQ = O_VOC_SEQ;
      
      -- 상태가 상담완료일경우 상담완료일자 갱신
      IF N_PRCS_STATE = '03' THEN
        UPDATE C_VOC SET
          PRCS_STATE    = N_PRCS_STATE
          ,UPD_DT        = SYSDATE
          ,UPD_USER      = P_MY_USER_ID
        WHERE VOC_SEQ = O_VOC_SEQ;
      END IF;
    END IF;
    
    -- 악성고객 처리
    IF N_CUST_ID IS NOT NULL AND N_BAD_CUST_YN = 'Y' THEN
      UPDATE C_CUST SET
        BAD_CUST_YN = N_BAD_CUST_YN
        ,BAD_CUST_COMPLAIN = N_CONTENT
      WHERE CUST_ID = N_CUST_ID;
    ELSIF N_CUST_ID IS NOT NULL AND N_BAD_CUST_YN != 'Y' THEN
      UPDATE C_CUST SET
        BAD_CUST_YN = 'N'
        ,BAD_CUST_COMPLAIN = ''
      WHERE CUST_ID = N_CUST_ID;
    END IF;
    
    -- 상담 답변내용 추가
    IF N_REPLY_CONTENT IS NOT NULL THEN
      INSERT INTO C_VOC_REPLY (
        VOC_REPLY_SEQ
        ,VOC_SEQ
        ,CONTENT
        ,INST_DT
        ,INST_USER
      ) VALUES (
        (SELECT NVL(MAX(VOC_REPLY_SEQ), 0) + 1 FROM C_VOC_REPLY WHERE VOC_SEQ = O_VOC_SEQ)
        ,O_VOC_SEQ
        ,N_REPLY_CONTENT
        ,SYSDATE
        ,P_MY_USER_ID
      );
    END IF;
    
END C_VOC_SAVE;

/
