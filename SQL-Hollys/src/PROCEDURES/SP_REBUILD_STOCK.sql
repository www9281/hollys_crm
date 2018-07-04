--------------------------------------------------------
--  DDL for Procedure SP_REBUILD_STOCK
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_REBUILD_STOCK" 
                ( PSV_COMP_CD       IN  VARCHAR2, -- 회사코드
                  PSV_BRAND_CD      IN  VARCHAR2, -- 영업조직
                  PSV_STOR_CD       IN  VARCHAR2, -- 점포코드
                  PSV_YM            IN  VARCHAR2  -- 처리년월
                ) IS

---------------------------------------------------------------------------------------------------
--  Procedure Name   : SP_REBUILD_STOCK
--  Description      : 수불데이터 보정 프로시져
--  Ref. Table       : 
---------------------------------------------------------------------------------------------------
--  Create Date      : 2015-06-01
--  Create Programer : 최세원
--  Modify Date      : 2015-06-01
--  Modify Programer :
---------------------------------------------------------------------------------------------------

lsStorTp          STORE.STOR_TP%TYPE;
lnConfirmCnt      Number := 0 ; -- 재고실사 확정 건수
lsLine            varchar2(3) := '000';

PR_RTN_CD  NUMBER           := 1 ;
PR_RTN_MSG VARCHAR2(3000)   := 'OK';

CURSOR C_CAL IS
    SELECT  SUBSTR(YMD, 1, 6)   AS YM
      FROM  CALENDAR
     WHERE  YMD BETWEEN PSV_YM||'01' AND TO_CHAR(SYSDATE, 'YYYYMMDD')
     GROUP  BY SUBSTR(YMD, 1, 6)
     ORDER  BY SUBSTR(YMD, 1, 6);

CURSOR C_SURV(PRC_YM VARCHAR2) IS
    SELECT  COMP_CD
         ,  SURV_DT
         ,  BRAND_CD
         ,  STOR_CD
         ,  SURV_GRP
      FROM  SURV_STOCK_DT
     WHERE  COMP_CD     = PSV_COMP_CD
       AND  BRAND_CD    = PSV_BRAND_CD
       AND  SURV_DT     BETWEEN PRC_YM||'01' AND PRC_YM||'31'
       AND  (PSV_STOR_CD IS NULL OR STOR_CD = PSV_STOR_CD)
     GROUP  BY COMP_CD, SURV_DT, BRAND_CD, STOR_CD, SURV_GRP
     ORDER  BY COMP_CD, SURV_DT, BRAND_CD, STOR_CD, SURV_GRP;

BEGIN
    FOR C IN C_CAL LOOP
        -- 일수불 초기화
        UPDATE  DSTOCK
           SET  SURV_QTY    = 0
             ,  ADJ_QTY     = 0
         WHERE  COMP_CD     = PSV_COMP_CD
           AND  PRC_DT      BETWEEN C.YM||'01' AND C.YM||'31'
           AND  BRAND_CD    = PSV_BRAND_CD
           AND  (PSV_STOR_CD IS NULL OR STOR_CD = PSV_STOR_CD);

        lsLine := '010';
        FOR R IN C_SURV(C.YM) LOOP
            Begin
                UPDATE  SURV_STOCK_DT
                   SET  BASE_QTY    = 0
                     ,  ADJ_QTY     = 0
                     ,  S_CONFIRM_YN= 'N'
                 WHERE  COMP_CD     = R.COMP_CD
                   AND  SURV_DT     = R.SURV_DT
                   AND  BRAND_CD    = R.BRAND_CD
                   AND  STOR_CD     = R.STOR_CD
                   AND  SURV_GRP    = R.SURV_GRP;

                -- 재고실사 기초재고 및 조정수량 집계
                SP_SURV_REBUILD_CDR(R.COMP_CD, R.BRAND_CD, R.STOR_CD, R.SURV_DT, R.SURV_GRP, CASE WHEN R.SURV_GRP = '01' THEN '1' ELSE '2' END, 'SYSTEM', 'KOR', PR_RTN_CD, PR_RTN_MSG);

                Exception When OTHERS Then
                    PR_RTN_MSG := SQLERRM(SQLCODE);
                    ROLLBACK;
                    GoTo ErrRtn;
            End ;
        END LOOP;

        -- 당월 점포 재고 집계
        SP_MSTOCK(PSV_COMP_CD, C.YM);

        -- 월수불에 각 금액 컬럼 계산
        SP_MSTOCK_CALC_AMOUNT(PSV_COMP_CD, C.YM); 

        IF C.YM < TO_CHAR(SYSDATE, 'YYYYMM') THEN
            -- 당월 기말재고수량을 이월 기초재고수량으로 생성
            SP_END_MSTOCK(PSV_COMP_CD, C.YM, '', '', '0');
        END IF; 

        FOR R IN (SELECT PB.BRAND_CD, NVL(PB.PARA_VAL, PM.PARA_DEFAULT) AS COST_DIV
                    FROM PARA_MST   PM
                       , (
                            SELECT  B.COMP_CD
                                 ,  B.BRAND_CD
                                 ,  NVL(PB.PARA_CD, '1005') AS PARA_CD
                                 ,  PB.PARA_VAL
                              FROM  BRAND   B
                                 ,  PARA_BRAND PB
                             WHERE  B.COMP_CD   = PB.COMP_CD(+)
                               AND  B.BRAND_CD  = PB.BRAND_CD(+)
                               AND  B.COMP_CD   = PSV_COMP_CD
                               AND  B.USE_YN    = 'Y'
                               AND  PB.PARA_CD(+) = '1005'
                               AND  PB.USE_YN(+)= 'Y'
                         )  PB
                   WHERE PM.PARA_CD     = PB.PARA_CD(+)
                     AND PM.PARA_TABLE  = 'PARA_BRAND'
                     AND PM.PARA_CD     = '1005'
                 )
        LOOP
          IF R.COST_DIV = 'P' THEN -- 총평균법
             -- 당월 집계
             SP_MSTOCK_HQ(PSV_COMP_CD, R.BRAND_CD, C.YM);                 

             -- 당월 월수불에 각 금액 컬럼 계산
             SP_MSTOCK_HQ_CALC_AMOUNT(PSV_COMP_CD, R.BRAND_CD, C.YM); 

             IF C.YM < TO_CHAR(SYSDATE, 'YYYYMM') THEN
                -- 당월 기말재고수량을 이월 기초재고수량으로 생성
                SP_END_MSTOCK_HQ(PSV_COMP_CD, C.YM, R.BRAND_CD, '0');
             END IF;

          END IF;
        END LOOP;

    END LOOP;

    COMMIT;

    PR_RTN_CD  := 1 ;
    PR_RTN_MSG := 'OK';
    Commit;

    <<ErrRtn>>
    NULL;

Exception When OTHERS Then
   PR_RTN_MSG := '[' || lsLine || '] ' || SQLERRM(SQLCODE);
   PR_RTN_CD  := SQLCODE ;
   ROLLBACK;
END  ;

/
