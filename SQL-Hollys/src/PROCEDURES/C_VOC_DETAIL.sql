--------------------------------------------------------
--  DDL for Procedure C_VOC_DETAIL
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_VOC_DETAIL" (
      P_VOC_SEQ        IN  VARCHAR2,
      O_CURSOR         OUT SYS_REFCURSOR
) AS 
BEGIN  
      OPEN O_CURSOR FOR
      SELECT
        A.VOC_SEQ
        ,A.BRAND_CD
        ,A.CUST_ID
        ,A.CUST_WEB_ID
        ,A.CUST_NM
        ,A.EMAIL
        ,A.RECV_DIV
        ,A.INQRY_TYPE
        ,A.VOC_HIGHCATE
        ,A.VOC_LOWCATE
        ,A.TITLE
        ,TO_CHAR(A.VISIT_DT, 'YYYY-MM-DD') AS VISIT_DT
        ,A.AREA_DIV
        ,A.NATION_CD
        ,A.SIDO_CD
        ,A.GUGUN_CD
        ,A.STOR_CD
        ,STO.STOR_NM
        ,A.MOBILE_NO
        ,A.CONTENT
        ,(SELECT BAD_CUST_YN FROM C_CUST WHERE CUST_ID = A.CUST_ID) AS BAD_CUST_YN
        ,A.PRCS_STATE
        ,A.DEL_YN
        ,A.REMARK
        ,A.SEND_YN
        ,A.FILE_URL
        ,NVL(B.FILE_ID, '') || '' AS FILE_ID
      FROM C_VOC A, SY_CONTENT_FILE B
         , STORE STO
      WHERE A.VOC_SEQ = P_VOC_SEQ
        AND  A.VOC_SEQ = B.REF_ID(+)
        AND  B.TABLE_NAME(+) = 'C_VOC'
        AND  A.BRAND_CD = STO.BRAND_CD(+)
        AND  A.STOR_CD  = STO.STOR_CD(+)
      ;
      
END C_VOC_DETAIL;

/
