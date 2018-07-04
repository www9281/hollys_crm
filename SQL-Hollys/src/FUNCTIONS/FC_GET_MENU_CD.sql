--------------------------------------------------------
--  DDL for Function FC_GET_MENU_CD
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."FC_GET_MENU_CD" (   
                                                asCompCd        IN  VARCHAR2,
                                                asMenuLv        IN  NUMBER 
                                               ) 
    RETURN  NUMBER AS
---------------------------------------------------------------------------------------------------
--  Procedure Name   : FC_GET_MENU_CD
--  Description      : 메뉴 code 가져옴
---------------------------------------------------------------------------------------------------
--  Create Date      : 
--  Create Programer : 한정일
--  Modify Date      : 
--  Modify Programer :              
--  Ref. Table       :  
---------------------------------------------------------------------------------------------------   

    lnMenuTmp   NUMBER;
    lnMenuCur   NUMBER;
    lnMenuMax   NUMBER;
BEGIN
    lnMenuCur := 0;
    lnMenuMax := 0;


    -- 메뉴 Level에 따른 메뉴 MAX값과 MIN값 설정
    IF (asMenuLv = 1 ) THEN 
        lnMenuCur := 1000;
        lnMenuMax := 1999;
    ELSIF (asMenuLv = 2 ) THEN
        lnMenuCur := 2000;
        lnMenuMax := 2999;
    ELSIF (asMenuLv = 3 ) THEN
        lnMenuCur := 3000;
        lnMenuMax := 9999;
    END IF;

    -- 없는 MENU_CD를 찾을때까지 LOOP를 돈다.
    WHILE lnMenuCur < lnMenuMax
        LOOP
            BEGIN
                SELECT  MENU_CD INTO lnMenuTmp
                FROM    W_MENU
                WHERE   MENU_CD = lnMenuCur
                  AND   ROWNUM  = 1;

                lnMenuCur := lnMenuCur + 1;

            EXCEPTION WHEN NO_DATA_FOUND THEN
                RETURN   lnMenuCur;
            END;
        END LOOP;

END FC_GET_MENU_CD;

/
