--------------------------------------------------------
--  DDL for Procedure C_VOC_VIEW
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_VOC_VIEW" (
        P_VOC_SEQ       IN  VARCHAR2,
        P_BRAND_CD      IN  VARCHAR2,
        O_CURSOR        OUT  SYS_REFCURSOR
) AS 
BEGIN
        OPEN     O_CURSOR  FOR
        SELECT   A.VOC_SEQ
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
                ,TO_CHAR(A.VISIT_DT, 'YYYY.MM.DD') AS VISIT_DT
                ,A.AREA_DIV
                ,A.NATION_CD
                ,A.SIDO_CD
                ,A.GUGUN_CD
                ,A.STOR_CD
                ,A.STOR_NM
                ,A.MOBILE_NO
                ,A.TEL_REPLY_REQ_YN
                ,(
                    SELECT B.FILE_NAME
                    FROM   SY_CONTENT_FILE B
                    WHERE  B.REF_ID = A.VOC_SEQ
                ) AS FILE_NAME
                ,A.CONTENT
                ,A.BAD_CUST_YN
                ,A.PRCS_STATE
                ,TO_CHAR(A.PRCS_DT, 'YYYY.MM.DD') AS PRCS_DT
                ,A.DEL_YN
                ,TO_CHAR(A.INST_DT, 'YYYY.MM.DD') AS INST_DT
                ,A.INST_USER
                ,TO_CHAR(A.UPD_DT, 'YYYY.MM.DD') AS UPD_DT
                ,A.UPD_USER
        FROM     C_VOC A
        WHERE    A.VOC_SEQ = P_VOC_SEQ
        AND      '001' = P_BRAND_CD OR A.BRAND_CD = P_BRAND_CD;
END C_VOC_VIEW;

/
