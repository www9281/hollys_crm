--------------------------------------------------------
--  DDL for Procedure SP_SET_CNT_MASTER
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_SET_CNT_MASTER" ( PSV_COMP_CD  IN VARCHAR2) -- 회사코드
IS
    CURSOR CUR_1 IS
        SELECT  S.COMP_CD
             ,  S.BRAND_CD
             ,  S.STOR_CD
             ,  NULL                AS HOLIDAY_YN
             ,  SW.START_HM         AS SALE_START_HM
             ,  SW.CLOSE_HM         AS SALE_CLOSE_HM
             ,  TO_CHAR(TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD')||SW.CLOSE_HM, 'YYYYMMDDHH24MI') - NVL(SC.RESERVE_HM, 0)/(24*60), 'HH24MI')   AS RESV_CLOSE_HM
             ,  SC.DELIVERY_ORD_YN  AS DELIVERY_YN
             ,  SC.DELIVERY_HM      AS DELIVERY_HM
          FROM  STORE       S
             ,  COMMON      C
             ,  STORE_CNT   SC
             ,  STORE_WEEK  SW
         WHERE  S.COMP_CD   = C.COMP_CD
           AND  S.STOR_TP   = C.CODE_CD
           AND  S.COMP_CD   = SC.COMP_CD
           AND  S.BRAND_CD  = SC.BRAND_CD
           AND  S.STOR_CD   = SC.STOR_CD
           AND  SC.COMP_CD  = SW.COMP_CD
           AND  SC.BRAND_CD = SW.BRAND_CD
           AND  SC.STOR_CD  = SW.STOR_CD
           AND  S.COMP_CD   = PSV_COMP_CD
           AND  S.USE_YN    = 'Y'
           AND  S.STOR_CD   <> '1010000'        -- 본사매장 제외
           AND  C.CODE_TP   = '00565'
           AND  C.USE_YN    = 'Y'
           AND  INSTR('S', C.VAL_C1, 1) > 0
           AND  SW.WEEK_DAY = TO_CHAR(SYSDATE, 'D');
BEGIN

    FOR MYREC IN CUR_1 LOOP

        DBMS_OUTPUT.PUT_LINE('1. UPDATE CNT_STORE_MNG [STOR_CD => '||MYREC.STOR_CD||'] '||TO_CHAR(SYSDATE, 'HH24MISS'));

        BEGIN
            INSERT  INTO CNT_STORE_MNG
            (
                    COMP_CD 
                ,   BRAND_CD
                ,   STOR_CD
                ,   HOLIDAY_YN
                ,   SALE_START_HM
                ,   SALE_CLOSE_HM
                ,   RESV_CLOSE_HM
                ,   DELIVERY_YN
                ,   DELIVERY_HM
                ,   INST_DT
                ,   INST_USER
                ,   UPD_DT
                ,   UPD_USER
            ) VALUES (
                    MYREC.COMP_CD
                ,   MYREC.BRAND_CD
                ,   MYREC.STOR_CD
                ,   MYREC.HOLIDAY_YN
                ,   MYREC.SALE_START_HM
                ,   MYREC.SALE_CLOSE_HM
                ,   MYREC.RESV_CLOSE_HM
                ,   MYREC.DELIVERY_YN
                ,   MYREC.DELIVERY_HM
                ,   SYSDATE
                ,   'SYSTEM'
                ,   SYSDATE
                ,   'SYSTEM'
            );

            EXCEPTION
                WHEN DUP_VAL_ON_INDEX THEN
                    UPDATE  CNT_STORE_MNG
                       SET  HOLIDAY_YN      = MYREC.HOLIDAY_YN
                         ,  SALE_START_HM   = MYREC.SALE_START_HM
                         ,  SALE_CLOSE_HM   = MYREC.SALE_CLOSE_HM
                         ,  RESV_CLOSE_HM   = MYREC.RESV_CLOSE_HM
                         ,  DELIVERY_YN     = MYREC.DELIVERY_YN
                         ,  DELIVERY_HM     = MYREC.DELIVERY_HM
                         ,  UPD_DT          = SYSDATE
                         ,  UPD_USER        = 'SYSTEM'
                     WHERE  COMP_CD         = MYREC.COMP_CD
                       AND  BRAND_CD        = MYREC.BRAND_CD
                       AND  STOR_CD         = MYREC.STOR_CD;
             WHEN OTHERS THEN
                  DBMS_OUTPUT.PUT_LINE('EXCEPTION : ' ||SQLERRM);
        END;    

    END LOOP;

    DBMS_OUTPUT.PUT_LINE('2. DELETE CNT_SOLD_OUT '||TO_CHAR(SYSDATE, 'HH24MISS'));
    DELETE  CNT_SOLD_OUT
     WHERE  COMP_CD = PSV_COMP_CD;

    DBMS_OUTPUT.PUT_LINE('3. INSERT CNT_SOLD_OUT '||TO_CHAR(SYSDATE, 'HH24MISS')); 
    INSERT  INTO CNT_SOLD_OUT
    SELECT  S.COMP_CD
         ,  S.BRAND_CD
         ,  S.STOR_CD
         ,  I.ITEM_CD
         ,  'N'         AS SOLD_OUT_YN
         ,  SYSDATE
         ,  'SYSTEM'
         ,  SYSDATE
         ,  'SYSTEM'
      FROM  STORE       S
         ,  COMMON      C
         ,  ITEM_CHAIN  I
     WHERE  S.COMP_CD   = C.COMP_CD
       AND  S.STOR_TP   = C.CODE_CD
       AND  S.COMP_CD   = I.COMP_CD
       AND  S.BRAND_CD  = I.BRAND_CD
       AND  S.STOR_TP   = I.STOR_TP
       AND  S.COMP_CD   = PSV_COMP_CD
       AND  S.USE_YN    = 'Y'
       AND  S.STOR_CD   <> '1010000'        -- 본사매장 제외
       AND  C.CODE_TP   = '00565'
       AND  C.USE_YN    = 'Y'
       AND  INSTR('S', C.VAL_C1, 1) > 0
       AND  I.ORD_SALE_DIV IN ('2', '3');

    -- 정상처리 완료
    COMMIT;

    RETURN;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION : ' ||SQLERRM);
        -- 취소 처리
        ROLLBACK;
        RETURN;
END;

/
