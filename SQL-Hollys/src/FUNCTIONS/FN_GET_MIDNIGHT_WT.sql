--------------------------------------------------------
--  DDL for Function FN_GET_MIDNIGHT_WT
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."FN_GET_MIDNIGHT_WT" (
                                                    vSTART_DTM IN VARCHAR2,
                                                    vCLOSE_DTM IN VARCHAR2
                                                   ) 
    RETURN NUMBER IS
    /* 심야 근무를 초로 RETURN */
    nRTNSECOND      NUMBER(9)    := 0;
BEGIN
    /* 심야 근무 시간 취득(22시 ~ 06시) */
    SELECT SUM(
                CASE WHEN CMP_DTM BETWEEN SUBSTR(MID_START_DTM1, 1, 8)||'2200' AND SUBSTR(MID_CLOSE_DTM1, 1, 8)||'0600' THEN
                       (
                        CASE WHEN CMP_DTM_ATF <= vCLOSE_DTM AND CMP_DTM_ATF <= SUBSTR(MID_CLOSE_DTM1, 1, 8)||'0600' THEN 
                               (CASE WHEN R_NUM = 1 THEN 60 - TO_NUMBER(SUBSTR(CMP_DTM, 11, 2)) ELSE 60 END)
                             WHEN vCLOSE_DTM BETWEEN CMP_DTM_BEF AND CMP_DTM_ATF THEN TO_NUMBER(SUBSTR(vCLOSE_DTM, 11, 2)) 
                             ELSE 0 END
                       )
                     WHEN CMP_DTM BETWEEN SUBSTR(MID_START_DTM2, 1, 8)||'2200' AND SUBSTR(MID_CLOSE_DTM2, 1, 8)||'0600' THEN
                       (
                        CASE WHEN CMP_DTM_ATF <= vCLOSE_DTM THEN 
                               (CASE WHEN R_NUM = 1 THEN 60 - TO_NUMBER(SUBSTR(CMP_DTM, 11, 2)) ELSE 60 END)
                             WHEN vCLOSE_DTM BETWEEN CMP_DTM_BEF AND CMP_DTM_ATF THEN TO_NUMBER(SUBSTR(vCLOSE_DTM, 11, 2)) 
                             ELSE 0 END
                       )       
                     ELSE 0 END) * 60 MID_NIGHT_TIME
    INTO    nRTNSECOND              
    FROM   (             
            SELECT  CMP_DTM,
                    CMP_DTM_BEF,
                    CMP_DTM_ATF,
                    TO_CHAR(TO_DATE(vSTART_DTM, 'YYYYMMDDHH24MI') - 1 + DAY_NUM, 'YYYYMMDD')||'2200'         MID_START_DTM1,
                    TO_CHAR(TO_DATE(vSTART_DTM, 'YYYYMMDDHH24MI') - 0 + DAY_NUM, 'YYYYMMDD')||'0600'         MID_CLOSE_DTM1,
                    TO_CHAR(TO_DATE(vSTART_DTM, 'YYYYMMDDHH24MI') + 0 + DAY_NUM, 'YYYYMMDD')||'2200'         MID_START_DTM2,
                    TO_CHAR(TO_DATE(vSTART_DTM, 'YYYYMMDDHH24MI') + 1 + DAY_NUM, 'YYYYMMDD')||'0600'         MID_CLOSE_DTM2,
                    R_NUM
            FROM  (
                    SELECT  TO_CHAR(TO_DATE(vSTART_DTM, 'YYYYMMDDHH24MI') + (ROWNUM - 1) / 24, 'YYYYMMDDHH24MI')     CMP_DTM,
                            TO_CHAR(TO_DATE(vSTART_DTM, 'YYYYMMDDHH24MI') + (ROWNUM - 1) / 24, 'YYYYMMDDHH24')||'00' CMP_DTM_BEF,
                            TO_CHAR(TO_DATE(vSTART_DTM, 'YYYYMMDDHH24MI') + (ROWNUM)     / 24, 'YYYYMMDDHH24')||'00' CMP_DTM_ATF,
                            TRUNC((TO_DATE(vSTART_DTM, 'YYYYMMDDHH24MI')  + (ROWNUM - 1) / 24) - TO_DATE(SUBSTR(vSTART_DTM, 1, 8), 'YYYYMMDDHH24MI')) AS DAY_NUM,
                            ROWNUM R_NUM
                    FROM    TAB
                    WHERE  ROWNUM <= CEIL((TO_DATE(vCLOSE_DTM, 'YYYYMMDDHH24MI') - TO_DATE(vSTART_DTM, 'YYYYMMDDHH24MI')) * 24) + 3
                   ) 
                    ORDER BY R_NUM
           );


    RETURN NVL(nRTNSECOND, 0);              
END FN_GET_MIDNIGHT_WT;

/
