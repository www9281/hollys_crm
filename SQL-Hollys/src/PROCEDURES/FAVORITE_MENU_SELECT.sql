--------------------------------------------------------
--  DDL for Procedure FAVORITE_MENU_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."FAVORITE_MENU_SELECT" (
    P_MY_USER_ID  IN  VARCHAR2,
    P_LANGUAGE    IN  VARCHAR2,
    O_CURSOR      OUT SYS_REFCURSOR
)IS
BEGIN 
    ----------------------- 즐겨찾기 목록 조회 -----------------------
    OPEN O_CURSOR FOR
    SELECT   A.MENU_CD
       ,   NVL(L.LANG_NM, A.MENU_NM_KOR)      AS MENU_NM
       ,   A.MENU_IDX     AS MENU_IX
       ,   '0'            AS MENU_RF
       ,   'F'            AS MENU_TP
       ,   A.MENU_DIV     AS MENU_DIV
       ,   A.USE_YN       AS USE_YN
       ,   A.PROG_NM      AS PROG_NM
       ,   'W'            AS AUTH_TP
    FROM   W_MENU A
       ,   W_MENU_FAVORITE B
       ,   (
              SELECT  PK_COL
                   ,  LANG_NM
                FROM  LANG_TABLE
               WHERE  TABLE_NM = 'W_MENU'
                 AND  COL_NM   = 'MENU_NM_KOR'
                 AND  LANGUAGE_TP = P_LANGUAGE
           ) L
    WHERE   A.MENU_CD  = B.MENU_CD
      AND   A.MENU_CD  = L.PK_COL(+)
      AND   B.USER_ID  = P_MY_USER_ID
    ORDER BY MENU_NM;

END FAVORITE_MENU_SELECT;

/
