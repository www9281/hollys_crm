--------------------------------------------------------
--  DDL for Function FC_GET_AUTH_STORE_INFO_M
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."FC_GET_AUTH_STORE_INFO_M" 
          ( 
            asCompCd     IN  VARCHAR2,
            asUserId     IN  VARCHAR2
          )  RETURN TBL_STORE_INFO_M AS

---------------------------------------------------------------------------------------------------
--  Function Name    : FC_GET_AUTH_STORE_INFO_M
--  Description      : 사용자 권한에 따른 점포 정보를 리턴해 준다.
--                     기존 함수에서 변경한 내용
--                     SELECT시 STOR_NM, APP_DIV, USE_YN 함목을 추가하고
--                     WHERE절에 USE_YN = 'Y' 인 조건을 제외함
--                     WHERE절에 APP_DIV = '01' 인 조건을 제외함
--                     점포등록시 폐점인 점포를 조회 할 수가 없어서 기존 함수를 수정하면 기존 리포트에 영향을
--                     너무 많이 받아서 새로 이 함수를 추가함.
-- Ref. Table        : STORE
---------------------------------------------------------------------------------------------------
--  Create Date      : 2013-01-17
--  Create Programer : 정수환
--  Modify Date      :
--  Modify Programer :
---------------------------------------------------------------------------------------------------

RESULT  TBL_STORE_INFO_M := TBL_STORE_INFO_M();

BEGIN

   SELECT OT_STORE_INFO_M
          (  COMP_CD
           , BRAND_CD
           , DEPT_CD
           , TEAM_CD
           , SV_USER_ID
           , STOR_TP
           , STOR_CD
           , STOR_NM
           , APP_DIV
           , USE_YN
          )
     BULK COLLECT INTO RESULT
     FROM ( SELECT S.COMP_CD
                , S.BRAND_CD
                , S.DEPT_CD
                , S.TEAM_CD
                , S.SV_USER_ID
                , S.STOR_TP
                , S.STOR_CD
                , MAX(S.STOR_NM)    AS STOR_NM
                , MAX(S.APP_DIV)    AS APP_DIV
                , MAX(S.USE_YN)     AS USE_YN
             FROM ( SELECT  COMP_CD
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
                  )     A,
                  STORE S
            WHERE  S.COMP_CD    = A.COMP_CD
              AND  S.COMP_CD    = asCompCd
              AND  (S.BRAND_CD   IS NULL OR S.BRAND_CD   IN (DECODE(TRIM(A.BRAND_CD), '%', S.BRAND_CD  , A.BRAND_CD  ), '0000'))
              AND  (S.DEPT_CD    IS NULL OR S.DEPT_CD    = DECODE(TRIM(A.DEPT_CD)   , '%', S.DEPT_CD   , A.DEPT_CD   ))
              AND  (S.TEAM_CD    IS NULL OR S.TEAM_CD    = DECODE(TRIM(A.TEAM_CD)   , '%', S.TEAM_CD   , A.TEAM_CD   ))
              AND  (S.SV_USER_ID IS NULL OR S.SV_USER_ID = DECODE(TRIM(A.SV_USER_ID), '%', S.SV_USER_ID, A.SV_USER_ID))
              AND  (S.STOR_CD    IS NULL OR S.STOR_CD    = DECODE(TRIM(A.STOR_CD)   , '%', S.STOR_CD   , A.STOR_CD   ))
            GROUP  BY S.COMP_CD
                ,  S.BRAND_CD
                ,  S.DEPT_CD
                ,  S.TEAM_CD
                ,  S.SV_USER_ID
                ,  S.STOR_TP
                ,  S.STOR_CD
          ) ;

   RETURN RESULT;

EXCEPTION  WHEN OTHERS THEN
   Null;

END  ;

/
