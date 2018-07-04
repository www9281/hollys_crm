--------------------------------------------------------
--  DDL for Procedure W_MENU_ADMIN_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."W_MENU_ADMIN_SELECT" (
    P_LANGUAGE_CD  IN  VARCHAR2,
    O_CURSOR    OUT SYS_REFCURSOR
)
IS
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2017-11-23
    -- Description   :   관리자 메뉴관리 리스트 조회
    -- ==========================================================================================
     
    OPEN O_CURSOR FOR 
    SELECT
      LEVEL
      ,A.MENU_CD
      ,DECODE(P_LANGUAGE_CD, 'K', A.MENU_NM_KOR, 'E', A.MENU_NM_ENG, 'C', A.MENU_NM_CHN, 'F', A.MENU_NM_FRN, A.MENU_NM_KOR) AS MENU_NM
      ,A.PROG_NM
      ,A.MENU_REF
      ,A.MENU_IDX
      ,A.MENU_DIV
      ,A.USE_YN
      ,A.DEPTH
      ,P_LANGUAGE_CD AS LANGUAGE_CD
    FROM W_MENU A
    WHERE MENU_DIV != 'T'
    START WITH DEPTH = 0
    CONNECT BY PRIOR MENU_CD = MENU_REF
    ORDER SIBLINGS BY MENU_IDX
    ;
    
END W_MENU_ADMIN_SELECT;

/
