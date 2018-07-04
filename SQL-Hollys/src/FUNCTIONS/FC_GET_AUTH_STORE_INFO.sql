--------------------------------------------------------
--  DDL for Function FC_GET_AUTH_STORE_INFO
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."FC_GET_AUTH_STORE_INFO" 
( 
  asCompCd     IN  VARCHAR2,
  asUserId     IN  VARCHAR2
) RETURN TBL_STORE_INFO AS

-------------------------------------------------------------------------------
--  Function Name    : FC_GET_AUTH_STORE_INFO
--  Description      : 사용자 권한에 따른 점포 정보 리턴
--  Ref. Table       : STORE
-------------------------------------------------------------------------------
--  Create Date      : 2010-01-08
--  Modify Date      : 2010-01-08
-------------------------------------------------------------------------------

  RESULT  TBL_STORE_INFO := TBL_STORE_INFO();

BEGIN
    SELECT OT_STORE_INFO
    (  
            COMP_CD
         ,  BRAND_CD
         ,  STOR_TP
         ,  STOR_TG
         ,  STOR_CD
         ,  DEPT_CD
         ,  TEAM_CD
         ,  SV_USER_ID
         ,  SIDO_CD
         ,  TRAD_AREA
         ,  APP_DIV
    )
    BULK COLLECT INTO RESULT
     FROM   ( 
                SELECT  S.COMP_CD
                     ,  S.BRAND_CD
                     ,  S.STOR_TP
                     ,  S.STOR_TG
                     ,  S.STOR_CD
                     ,  S.DEPT_CD
                     ,  S.TEAM_CD
                     ,  S.SV_USER_ID
                     ,  S.SIDO_CD
                     ,  S.TRAD_AREA
                     ,  S.APP_DIV
                  FROM  ( 
                            SELECT  COMP_CD
                                    -- 권한레벨[00780>10:관리자, 20:부서장, 30:팀장, 40:영업사원, 90:점포]
                                 ,  DECODE(AUTH_LEVEL, '10', BRAND_CD       , '%')  AS BRAND_CD
                                 ,  DECODE(AUTH_LEVEL, '20', AUTH_DEPT_CD   , '%')  AS DEPT_CD
                                 ,  DECODE(AUTH_LEVEL, '30', AUTH_TEAM_CD   , '%')  AS TEAM_CD
                                 ,  DECODE(AUTH_LEVEL, '40', AUTH_SV_USER_ID, '%')  AS SV_USER_ID
                                 ,  DECODE(AUTH_LEVEL, '50', AUTH_STOR_CD   , '%')  AS STOR_CD
                              FROM  USER_AUTH
                             WHERE  COMP_CD = asCompCd
                               AND  USER_ID = asUserId
                               AND  USE_YN  = 'Y'
                        )     A
                     ,  STORE   S
                     ,  BRAND   B       
                 WHERE  A.COMP_CD   = S.COMP_CD
                   AND  S.COMP_CD   = B.COMP_CD(+)
                   AND  S.BRAND_CD  = B.BRAND_CD(+)
                   AND  S.COMP_CD   = asCompCd
                   AND  S.STOR_TP   IN ('10', '20', '30', '31')
                   AND  (S.BRAND_CD   IS NULL OR S.BRAND_CD   IN (DECODE(TRIM(A.BRAND_CD), '%', S.BRAND_CD  , A.BRAND_CD  ), '0000'))
                   AND  (S.DEPT_CD    IS NULL OR S.DEPT_CD    = DECODE(TRIM(A.DEPT_CD)   , '%', S.DEPT_CD   , A.DEPT_CD   ))
                   AND  (S.TEAM_CD    IS NULL OR S.TEAM_CD    = DECODE(TRIM(A.TEAM_CD)   , '%', S.TEAM_CD   , A.TEAM_CD   ))
                   AND  (S.SV_USER_ID IS NULL OR S.SV_USER_ID = DECODE(TRIM(A.SV_USER_ID), '%', S.SV_USER_ID, A.SV_USER_ID))
                   AND  (S.STOR_CD    IS NULL OR S.STOR_CD    = DECODE(TRIM(A.STOR_CD)   , '%', S.STOR_CD   , A.STOR_CD   ))
                 GROUP  BY S.COMP_CD
                     ,  S.BRAND_CD
                     ,  S.STOR_TP
                     ,  S.STOR_TG
                     ,  S.STOR_CD
                     ,  S.DEPT_CD
                     ,  S.TEAM_CD
                     ,  S.SV_USER_ID
                     ,  S.SIDO_CD
                     ,  S.TRAD_AREA
                     ,  S.APP_DIV
            );

   RETURN RESULT;

EXCEPTION
  WHEN OTHERS THEN
       NULL;
END;

/
