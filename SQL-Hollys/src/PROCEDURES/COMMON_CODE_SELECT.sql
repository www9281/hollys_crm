--------------------------------------------------------
--  DDL for Procedure COMMON_CODE_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."COMMON_CODE_SELECT" (
        P_CODE_TP  IN    VARCHAR2,
        P_LANG_TP  IN    VARCHAR2,
        N_USE_YN   IN    CHAR,
        O_CURSOR   OUT   SYS_REFCURSOR
) AS 
BEGIN
        OPEN    O_CURSOR  FOR
        SELECT  *
        FROM (
               SELECT  C.CODE_TP                           AS CODE_TP
                     , C.CODE_CD                           AS CODE_CD
                     , C.CODE_NM                           AS CODE_NM
                     , L.CODE_NM                           AS LANG_NM 
                     , C.BRAND_CD                          AS BRAND_CD
                     , C.ACC_CD                            AS ACC_CD
                     , C.REMARKS                           AS REMARKS
                     , DECODE(C.POS_IF_YN, 'Y', 1, 0)      AS POS_IF_YN
                     , C.USE_YN                            AS USE_YN
                     , C.SORT_SEQ                          AS SORT_SEQ
                     , NVL(U1.USER_NM, C.INST_USER)        AS INST_USER
                     , TO_CHAR(C.INST_DT, 'YYYY-MM-DD')    AS INST_DT
                     , NVL(U2.USER_NM, C.UPD_USER )        AS UPD_USER
                     , TO_CHAR(C.UPD_DT, 'YYYY-MM-DD')     AS UPD_DT
                     , DECODE(L.CODE_CD, NULL, 'I', 'S')   AS MULT_PRC
                 FROM COMMON      C,
                      ( SELECT CODE_TP, CODE_CD, CODE_NM
                          FROM LANG_COMMON
                         WHERE CODE_TP = P_CODE_TP
                           AND LANGUAGE_TP = DECODE(P_LANG_TP, NULL, ' ', P_LANG_TP)   
                      )   L,
                      HQ_USER  U1,
                      HQ_USER  U2 
                WHERE C.CODE_TP   = L.CODE_TP(+)
                  AND C.CODE_CD   = L.CODE_CD(+)
                  AND C.CODE_TP   = P_CODE_TP
                  AND C.INST_USER = U1.USER_ID(+)
                  AND C.UPD_USER  = U2.USER_ID(+)
                  AND (N_USE_YN IS NULL OR C.USE_YN = N_USE_YN)
             )
        WHERE CODE_TP = P_CODE_TP
        ORDER BY 
                SORT_SEQ;
END COMMON_CODE_SELECT;

/
