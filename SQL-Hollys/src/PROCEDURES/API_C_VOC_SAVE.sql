--------------------------------------------------------
--  DDL for Procedure API_C_VOC_SAVE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."API_C_VOC_SAVE" (
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
    N_REMARK            IN    VARCHAR2,
    N_FILE_URL          IN    VARCHAR2
) AS 
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2018-01-16
    -- Description   :   HOMEPAGE 고객문의등록 API
    -- ==========================================================================================
    
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
      ,FILE_URL
    ) VALUES (
      SQ_VOC_SEQ.NEXTVAL
      ,'100'            -- 할리스커피
      ,'C1002'          -- 홈페이지접수
      ,'00'             -- 상담접수
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
      ,N_FILE_URL
    );
    
END API_C_VOC_SAVE;

/
