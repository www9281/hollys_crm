--------------------------------------------------------
--  DDL for Procedure SP_ORDER_SHIP_STORE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_ORDER_SHIP_STORE" 
(
  asCompCd        IN      VARCHAR2, -- 회사코드
  asShipDt        IN      VARCHAR2, -- 출고일자
  asProcFg        IN      VARCHAR2, -- 입출고 구분[0:입고, 1:출고]
  asRetVal        OUT     NUMBER  , -- 결과코드
  asRetMsg        OUT     VARCHAR2  -- 리턴 메시지
) IS
--------------------------------------------------------------------------------
-- Procedure Name   : SP_ORDER_SHIP_STORE
-- Description      : 매장 수주출고 처리
-- Ref. Table       : ORDER_HD, ORDER_DT, ORDER_TMP
--------------------------------------------------------------------------------
-- Create Date      : 2010-01-05
-- Modify Date      : 2010-01-05
--------------------------------------------------------------------------------
  cShipDt        VARCHAR2(8) := TRIM(asShipDt);
  cProcFg        VARCHAR2(1) := TRIM(asProcFg);
  cStorCd        VARCHAR2(7);
  sUserNm        VARCHAR2(20);
  nSeq           NUMBER(2)   := 1;
  nShipTot       NUMBER(4)   := 0;
  nCurStorCnt    NUMBER(4)   := 0;
  cVAL_C1        VARCHAR2(30);
  nVAL_N1        NUMBER(12,2);

  CURSOR C_STOR_LIST IS
  SELECT A.STOR_CD
    FROM ORDER_TMP   A
       , OPEN_STORE  B
   WHERE A.SHIP_DT = cShipDt
     AND A.PROC_FG = cProcFg
     AND A.STOR_CD = B.STOR_CD
     AND B.OPEN_YN = 'Y'
   GROUP BY A.STOR_CD;
BEGIN
  IF ( cProcFg = '0' ) THEN
     sUserNm := 'SHIP_PLAN';
  ELSE
     sUserNm := 'SHIP';
  END IF;

  DELETE
    FROM ORDER_TMP_LOG
   WHERE COMP_CD = asCompCd
     AND SHIP_DT = cShipDt
     AND LOG_DIV = sUserNm;

  COMMIT;

  INSERT INTO ORDER_TMP_LOG (COMP_CD,  SEQ, SHIP_DT, LOG_DT, LOG_DIV, LOG_MSG)
  VALUES (asCompCd, nSeq, cShipDt, SYSDATE, sUserNm, '입고예정/수주출고 프로시져가 시작됩니다.');

  nSEQ := nSEQ + 1 ;

  SELECT VAL_C1,  VAL_N1
    INTO cVAL_C1, nVAL_N1
    FROM COMMON
   WHERE COMP_CD = asCompCd
     AND CODE_TP = '50010'
     AND CODE_CD = DECODE( cProcFg, '0', '01', '1', '02' );

  IF SQL%NOTFOUND THEN
     INSERT INTO ORDER_TMP_LOG (COMP_CD, SEQ, SHIP_DT, LOG_DT, LOG_DIV, LOG_MSG)
     VALUES   (asCompCd, nSeq, cShipDt, SYSDATE, sUserNm, '잘못된 입고/출고 구분입니다.');
     COMMIT;
     RETURN;
  END IF;

  IF ( cVAL_C1 = 'Y' AND nVAL_N1 = '1' ) THEN
     INSERT INTO ORDER_TMP_LOG (COMP_CD, SEQ, SHIP_DT, LOG_DT, LOG_DIV, LOG_MSG)
     VALUES   (asCompCd, nSeq, cShipDt, SYSDATE, sUserNm, '프로시져가 실행중입니다. 프로시져를 종료합니다.');

     COMMIT;
     RETURN;
  ELSE
     UPDATE COMMON
        SET VAL_C1 = 'Y', 
            VAL_N1 = '1'
      WHERE COMP_CD = asCompCd
        AND CODE_TP = '50010' 
        AND CODE_CD = DECODE( cProcFg , '0' , '01' , '1' , '02' );
     COMMIT;
  END IF;

  -- 대상 점포수
  SELECT COUNT(*)
    INTO nShipTot
    FROM (SELECT A.STOR_CD
            FROM ORDER_TMP  A
               , OPEN_STORE B
           WHERE A.COMP_CD = asCompCd
             AND A.SHIP_DT = cShipDt
             AND A.PROC_FG = cProcFg
             AND A.COMP_CD = B.COMP_CD
             AND A.STOR_CD = B.STOR_CD
             AND B.OPEN_YN = 'Y'
            GROUP BY A.STOR_CD
         );

  FOR Store IN C_STOR_LIST LOOP
    BEGIN
      cStorCd := TRIM(Store.STOR_CD);

      UPDATE ORDER_DT
         SET ORD_CQTY = 0
           , ORD_CAMT = 0
           , ORD_CVAT = 0
       WHERE COMP_CD  = asCompCd
         AND SHIP_DT  = cShipDt
         AND STOR_CD  = cStorCd;

      -- ORDER DT 처리
      MERGE    INTO  ORDER_DT DT
      USING    (
                  SELECT   A1.COMP_CD                          AS COMP_CD
                  ,        A1.SHIP_DT                          AS SHIP_DT
                  ,        A1.STOR_CD                          AS STOR_CD
                  ,        A2.BRAND_CD                         AS BRAND_CD
                  ,        A1.ITEM_CD                          AS ITEM_CD
                  ,        A3.ORD_UNIT                         AS ORD_UNIT
                  ,        A3.ORD_UNIT_QTY                     AS ORD_UNIT_QTY
                  ,        A3.COST                             AS ORD_COST
                  ,        DECODE(A1.ORDER_SEQ  , '1' , '2'
                                                , '2' , '3'
                                                , '1'   )      AS ORD_SEQ
                  ,        DECODE(A1.ORDER_SEQ  , '3' , '02'
                                                , '8' , '03'
                                                , '7' , '06'
                                                , '9' , '08'
                                                , '01'  )      AS ORD_FG
                  ,        NVL(A1.SHIP_QTY,0)                  AS ORD_CQTY
                  ,        NVL(A1.SHIP_AMT,0)                  AS ORD_CAMT
                  ,        NVL(A1.SHIP_VAT,0)                  AS ORD_CVAT
                  FROM     ORDER_TMP   A1
                  ,        STORE       A2
                  ,        ITEM        A3
                  WHERE    A1.COMP_CD = A2.COMP_CD
                  AND      A1.STOR_CD = A2.STOR_CD
                  AND      A1.COMP_CD = A3.COMP_CD
                  AND      A1.ITEM_CD = A3.ITEM_CD
                  AND      A1.PROC_FG = cProcFg
                  AND      A1.SHIP_DT = cShipDt
                  AND      A1.ITEM_CD IS NOT NULL
                  AND      A1.STOR_CD = cStorCd
               ) TMP
      ON       ( 
                        DT.COMP_CD     =  TMP.COMP_CD
                  AND   DT.SHIP_DT     =  TMP.SHIP_DT
                  AND   DT.BRAND_CD    =  TMP.BRAND_CD
                  AND   DT.STOR_CD     =  TMP.STOR_CD
                  AND   DT.ITEM_CD     =  TMP.ITEM_CD
                  AND   DT.ORD_SEQ     =  TMP.ORD_SEQ
                  AND   DT.ORD_FG      =  TMP.ORD_FG
               )
      WHEN     MATCHED  THEN
            UPDATE   SET   ORD_COST    =  DECODE(TMP.ORD_CQTY , 0 , ORD_COST , ROUND(TMP.ORD_CAMT/TMP.ORD_CQTY))
                     ,     ORD_AMT     =  DECODE(TMP.ORD_CQTY , 0 , ORD_AMT  , ROUND(TMP.ORD_CAMT/TMP.ORD_CQTY) * ORD_QTY)
                     ,     ORD_CQTY    =  TO_NUMBER(TMP.ORD_CQTY)
                     ,     ORD_CAMT    =  TO_NUMBER(TMP.ORD_CAMT)
                     ,     ORD_CVAT    =  TO_NUMBER(TMP.ORD_CVAT)
                     ,     UPD_DT      =  SYSDATE
                     ,     UPD_USER    =  sUserNm
      WHEN     NOT MATCHED    THEN
            INSERT(        COMP_CD                    ,  SHIP_DT                ,  BRAND_CD                    ,  STOR_CD                  ,  ORD_SEQ
                        ,  ORD_FG                     ,  ITEM_CD                ,  ERP_INF_DT                  ,  ORD_UNIT
                        ,  ORD_QTY                    ,  ORD_AMT                ,  ORD_VAT
                        ,  ORD_UNIT_QTY               ,  ORD_COST               ,  ORD_CQTY                    ,  ORD_CAMT
                        ,  ORD_CVAT                   ,  INST_DT                ,  INST_USER                   ,  UPD_DT
                        ,  UPD_USER       )
            VALUES(        TMP.COMP_CD                ,  TMP.SHIP_DT            ,  TMP.BRAND_CD                ,  TMP.STOR_CD             ,   TMP.ORD_SEQ
                        ,  TMP.ORD_FG                 ,  TMP.ITEM_CD            ,  TO_CHAR(SYSDATE, 'YYYYMMDD'),  TMP.ORD_UNIT
                        ,  0                          ,  0                      ,  0
                        ,  TO_NUMBER(TMP.ORD_UNIT_QTY),  TO_NUMBER(TMP.ORD_COST),  TO_NUMBER(TMP.ORD_CQTY)     ,  TO_NUMBER(TMP.ORD_CAMT)
                        ,  TO_NUMBER(TMP.ORD_CVAT)    ,  SYSDATE                ,  sUserNm                     ,  SYSDATE
                        ,  sUserNm   ) ;

      -- ORDER HD 처리
      MERGE    INTO  ORDER_HD HD
      USING    (
                  SELECT  
                          COMP_CD
                  ,       SHIP_DT
                  ,       BRAND_CD
                  ,       STOR_CD
                  ,       ORD_SEQ
                  ,       ORD_FG
                  ,       SUM(ORD_AMT)    AS ORD_AMT
                  ,       SUM(ORD_VAT)    AS ORD_VAT
                  ,       SUM(ORD_CAMT)   AS ORD_CAMT
                  ,       SUM(ORD_CVAT)   AS ORD_CVAT
                  FROM    ORDER_DT
                  WHERE   COMP_CD = asCompCd
                  AND     SHIP_DT = cShipDt
                  AND     STOR_CD = cStorCd
                  GROUP BY SHIP_DT
                  ,       BRAND_CD
                  ,       STOR_CD
                  ,       ORD_SEQ
                  ,       ORD_FG
               ) DT
      ON       (
                        HD.COMP_CD  = DT.COMP_CD
                  AND   HD.SHIP_DT  = DT.SHIP_DT
                  AND   HD.BRAND_CD = DT.BRAND_CD
                  AND   HD.STOR_CD  = DT.STOR_CD
                  AND   HD.ORD_SEQ  = DT.ORD_SEQ
                  AND   HD.ORD_FG   = DT.ORD_FG
               )
      WHEN     MATCHED     THEN
            UPDATE   SET   ORD_AMT  = DT.ORD_AMT
                     ,     ORD_VAT  = DT.ORD_VAT
                     ,     ORD_CAMT = DT.ORD_CAMT
                     ,     ORD_CVAT = DT.ORD_CVAT
                     ,     WRK_DIV  = DECODE(cProcFg , '0' , DECODE(
                                                               DT.ORD_SEQ || DT.ORD_FG , '1' || '01' , '9' , '0'
                                                             ) , '1' , '9')
                     ,     UPD_DT   = SYSDATE
                     ,     UPD_USER = sUserNm
       WHEN    NOT MATCHED THEN
            INSERT(        COMP_CD          , SHIP_DT              , BRAND_CD            , STOR_CD             , ORD_SEQ
                        ,  ORD_FG           , ERP_INF_DT           , ORD_AMT             , ORD_VAT
                        ,  ORD_CAMT         , ORD_CVAT             , WRK_DIV             , INST_DT
                        ,  INST_USER        , UPD_DT               , UPD_USER
                  )
            VALUES(        DT.COMP_CD       , DT.SHIP_DT           , DT.BRAND_CD         , DT.STOR_CD          , DT.ORD_SEQ
                        ,  DT.ORD_FG        , cShipDt              , DT.ORD_AMT          , DT.ORD_VAT
                        ,  DT.ORD_CAMT      , DT.ORD_CVAT          , '9'                 , SYSDATE
                        ,  sUserNm          , SYSDATE              , sUserNm
                  );

      -- DSTOCK 처리
      IF( cProcFg = '1') THEN
         MERGE    INTO DSTOCK DS
         USING    (
                     SELECT   A1.COMP_CD      AS COMP_CD
                     ,        A1.SHIP_DT      AS PRC_DT
                     ,        A2.BRAND_CD     AS BRAND_CD
                     ,        A1.STOR_CD      AS STOR_CD
                     ,        A1.ITEM_CD      AS ITEM_CD
                     ,        SUM(DECODE(A3.ORD_B_CNT , '1' , TO_NUMBER(SHIP_QTY) * A3.ORD_UNIT_QTY
                                                            , TO_NUMBER(SHIP_QTY)))   AS ORD_QTY
                     ,        A3.COST
                     ,        A3.SALE_PRC
                     FROM     (
                                 SELECT  COMP_CD
                                 ,       SHIP_DT
                                 ,       STOR_CD
                                 ,       ITEM_CD
                                 ,       SUM(SHIP_QTY) AS SHIP_QTY
                                 FROM    ORDER_TMP
                                 WHERE   SHIP_DT = cShipDt
                                 AND     STOR_CD = cStorCd
                                 AND     PROC_FG = '1'
                                 GROUP BY 
                                         COMP_CD
                                 ,       SHIP_DT
                                 ,       STOR_CD
                                 ,       ITEM_CD
                              )  A1
                     ,        STORE     A2
                     ,        ITEM      A3
                     WHERE    A1.COMP_CD = A2.COMP_CD
                     AND      A1.STOR_CD = A2.STOR_CD
                     AND      A1.COMP_CD = A3.COMP_CD
                     AND      A1.ITEM_CD = A3.ITEM_CD
                     GROUP BY A1.COMP_CD
                     ,        A1.SHIP_DT
                     ,        A2.BRAND_CD
                     ,        A1.STOR_CD
                     ,        A1.ITEM_CD
                     ,        A3.COST
                     ,        A3.SALE_PRC
                  )  TMP
         ON       (
                           DS.COMP_CD  = TMP.COMP_CD
                     AND   DS.PRC_DT   = TMP.PRC_DT
                     AND   DS.STOR_CD  = TMP.STOR_CD
                     AND   DS.ITEM_CD  = TMP.ITEM_CD
                     AND   DS.BRAND_CD = TMP.BRAND_CD
                  )
         WHEN     MATCHED        THEN
               UPDATE SET ORD_QTY = TO_NUMBER(TMP.ORD_QTY)
         WHEN     NOT MATCHED    THEN
            INSERT (    COMP_CD        ,  PRC_DT            ,  BRAND_CD          ,  STOR_CD         
                     ,  ITEM_CD        ,  ORD_QTY           ,  COST              ,  SALE_PRC       )
            VALUES (    TMP.COMP_CD    ,  TMP.PRC_DT        ,  TMP.BRAND_CD      ,  TMP.STOR_CD     
                     ,  TMP.ITEM_CD    ,  TMP.ORD_QTY       ,  TMP.COST          ,  TMP.SALE_PRC   );
      END IF;

      MERGE INTO ORDER_TMP_LOG
      USING    DUAL
      ON       (
                        COMP_CD     =  asCompCd
                  AND   SHIP_DT     =  cShipDt
                  AND   LOG_DIV     =  sUserNm
                  AND   SEQ         =  nSeq
               )
      WHEN     MATCHED  THEN
          UPDATE SET  LOG_DT  = SYSDATE
          ,    LOG_MSG = ROUND((nCurStorCnt/nShipTot)*100) || '% 점포의 주문/출하 데이터가 반영되었습니다.'
      WHEN NOT MATCHED THEN
          INSERT   (COMP_CD, SEQ , SHIP_DT , LOG_DT , LOG_DIV , LOG_MSG )
          VALUES   (asCompCd, nSeq , cShipDt , SYSDATE , sUserNm , ROUND((nCurStorCnt/nShipTot)*100) || '% 점포의 주문/출하 데이터가 반영되었습니다.');

      nCurStorCnt := nCurStorCnt + 1;

      COMMIT;
    END;
  END LOOP;

  nSeq := nSeq+1;

  INSERT INTO ORDER_TMP_LOG (COMP_CD, SEQ, SHIP_DT, LOG_DT, LOG_DIV, LOG_MSG)
  VALUES   (asCompCd, nSeq, cShipDt, SYSDATE, sUserNm, '입고예정/수주출고처리 프로시져가 완료되었습니다.' );

  UPDATE COMMON 
     SET VAL_C1  = 'N',
         VAL_N1  = '1'
   WHERE COMP_CD = asCompCd
     AND CODE_TP = '50010' 
     AND CODE_CD = DECODE( cProcFg, '0', '01', '1', '02' );

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
       asRetMsg := SQLERRM(SQLCODE);
       asRetVal := SQLCODE ;

       nSEQ := nSEQ + 1 ;

       UPDATE COMMON 
          SET VAL_C1  = 'N' , 
              VAL_N1  = '0' 
        WHERE COMP_CD = asCompCd
          AND CODE_TP = '50010' 
          AND CODE_CD = DECODE( cProcFg , '0' , '01' , '1' , '02' );

       INSERT INTO ORDER_TMP_LOG (COMP_CD, SEQ, SHIP_DT, LOG_DT, LOG_DIV, LOG_MSG)
       VALUES   (asCompCd, nSeq, cShipDt, SYSDATE, sUserNm, '입고예정/수주출고 처리 중 에러발생!!! : ['|| cStorCd  || ' ] - ' || asRetMsg );

       COMMIT;
       RETURN;
END SP_ORDER_SHIP_STORE ;

/
