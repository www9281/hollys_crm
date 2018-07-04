--------------------------------------------------------
--  DDL for Procedure C_VOC_SELECT_BACK
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_VOC_SELECT_BACK" (
        P_BRAND_CD      IN   VARCHAR2,
        N_INQRY_TYPE    IN   VARCHAR2,
        N_RECV_DIV      IN   VARCHAR2,
        N_PRCS_STATE    IN   CHAR,
        N_START_DATE    IN   VARCHAR2,
        N_END_DATE      IN   VARCHAR2,
        N_VOC_HIGHCATE  IN   VARCHAR2,
        N_VOC_LOWCATE   IN   VARCHAR2,
        N_AREA_DIV      IN   CHAR,
        N_NATION_CD     IN   VARCHAR2,
        N_SIDO_CD       IN   VARCHAR2,
        N_GUGUN_CD      IN   VARCHAR2,
        N_STOR_CD       IN   VARCHAR2,
        N_KEYWORD       IN   VARCHAR2,
        N_KEYWORD_TYPE  IN   VARCHAR2,
        O_CURSOR        OUT  SYS_REFCURSOR
) AS 
BEGIN  
        OPEN     O_CURSOR  FOR
        SELECT   A.VOC_SEQ
                ,A.BRAND_CD
                ,A.CUST_ID
                ,A.CUST_WEB_ID
                ,A.CUST_NM
                ,A.MOBILE_NO
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
                ,A.TEL_REPLY_REQ_YN
                ,(
                    SELECT B.FILE_NAME
                    FROM   SY_CONTENT_FILE B
                    WHERE  B.REF_ID = CAST(A.VOC_SEQ AS VARCHAR2(20))
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
        WHERE    '001' = P_BRAND_CD OR A.BRAND_CD = P_BRAND_CD 
        AND      (TRIM(N_RECV_DIV) IS NULL OR A.RECV_DIV = N_RECV_DIV)
        AND      (TRIM(N_PRCS_STATE) IS NULL OR A.PRCS_STATE = N_PRCS_STATE)
        AND	     (TRIM(N_START_DATE) IS NULL OR TO_CHAR(A.UPD_DT,'YYYY-MM-DD') >= N_START_DATE)
        AND	     (TRIM(N_END_DATE) IS NULL OR TO_CHAR(A.UPD_DT,'YYYY-MM-DD') <= N_END_DATE)
        AND      (TRIM(N_KEYWORD) IS NULL OR (
                                                N_KEYWORD_TYPE = '1' AND A.TITLE LIKE '%' || N_KEYWORD || '%'
                                                OR N_KEYWORD_TYPE = '2' AND A.CONTENT LIKE '%' || N_KEYWORD || '%'
                                                OR N_KEYWORD_TYPE = '3' AND A.INST_USER LIKE '%' || N_KEYWORD || '%'
                                                OR N_KEYWORD_TYPE = '4' AND A.EMAIL LIKE '%' || N_KEYWORD || '%'
                                                OR N_KEYWORD_TYPE = '5' AND A.MOBILE_NO LIKE '%' || N_KEYWORD || '%'
                                                OR N_KEYWORD_TYPE = '6' AND A.STOR_NM LIKE '%' || N_KEYWORD || '%'
                                             ))
        AND      (TRIM(N_INQRY_TYPE) IS NULL OR A.INQRY_TYPE = N_INQRY_TYPE)
        AND      (TRIM(N_VOC_HIGHCATE) IS NULL OR A.VOC_HIGHCATE = N_VOC_HIGHCATE)
        AND      (TRIM(N_VOC_LOWCATE) IS NULL OR A.VOC_LOWCATE = N_VOC_LOWCATE)
        AND      (TRIM(N_AREA_DIV) IS NULL OR A.AREA_DIV = N_AREA_DIV)
        AND      (TRIM(N_NATION_CD) IS NULL OR A.NATION_CD = N_NATION_CD)
        AND      (TRIM(N_SIDO_CD) IS NULL OR A.SIDO_CD = N_SIDO_CD)
        AND      (TRIM(N_GUGUN_CD) IS NULL OR A.GUGUN_CD = N_GUGUN_CD)
        AND      (TRIM(N_STOR_CD) IS NULL OR A.STOR_CD = N_STOR_CD)
        ORDER BY 
                  A.VOC_SEQ DESC;
END C_VOC_SELECT_BACK;

/
