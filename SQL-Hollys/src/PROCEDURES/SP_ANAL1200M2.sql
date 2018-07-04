--------------------------------------------------------
--  DDL for Procedure SP_ANAL1200M2
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_ANAL1200M2" 
/******************************************************************************
   NAME     :  SP_ANAL1200M2
   PURPOSE  : 손익추정 등록 매출/원가 실적 생성 - 토리돌 전용

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     SP_ANAL1200M2
      Sysdate:         
      Date and Time:   
      Username:         (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
(    
    p_comp_cd      IN   VARCHAR2,
    p_brand_cd     IN   VARCHAR2,
    p_stor_cd      IN   VARCHAR2,
    p_user_id      IN   VARCHAR2,
    p_goal_ym      IN   VARCHAR2,
    psr_return_cd  OUT  VARCHAR2,
    psr_msg        OUT  VARCHAR2
)
IS
    -- 매출 실적
    CURSOR CUR_S IS
        SELECT  PM.COMP_CD
             ,  p_goal_ym   AS GOAL_YM
             ,  PM.BRAND_CD
             ,  PM.STOR_CD
             ,  '3'         AS GOAL_DIV
             ,  '3'         AS COST_DIV
             ,  PM.ACC_CD
             ,  NVL(SC.CUST_CNT, 0)         AS CUST_CNT
             ,  NVL(PM.TAKE_OUT_F_SALE, 0)  AS TAKE_OUT_F_SALE
             ,  NVL(PM.TAKE_OUT_B_SALE, 0)  AS TAKE_OUT_B_SALE
             ,  NVL(PM.SALE_AMT, 0)         AS SALE_AMT
             ,  NVL(D.DC_AMT, 0)            AS DC_AMT
          FROM  (
                    SELECT  PM.COMP_CD
                         ,  S.BRAND_CD
                         ,  S.STOR_CD
                         ,  PM.ACC_CD
                         ,  SUM(CASE WHEN PM.ACC_CD = '900140' THEN S.GRD_O_AMT - S.VAT_O_AMT ELSE 0 END)  AS TAKE_OUT_F_SALE
                         ,  SUM(CASE WHEN PM.ACC_CD = '900150' THEN S.GRD_O_AMT - S.VAT_O_AMT ELSE 0 END)  AS TAKE_OUT_B_SALE
                         ,  SUM(S.GRD_AMT - S.VAT_AMT)      AS SALE_AMT
                      FROM  PL_ACC_MST      PM
                         ,  PL_ACC_MST_CLS  PC
                         ,  ITEM_CLASS      IC
                         ,  ITEM_CHAIN      I
                         ,  SALE_JDM        S
                     WHERE  PM.COMP_CD      = PC.COMP_CD
                       AND  PM.ACC_CD       = PC.ACC_CD
                       AND  PC.COMP_CD      = IC.COMP_CD
                       AND  PC.ORG_CLASS_CD = IC.ORG_CLASS_CD
                       AND  PC.L_CLASS_CD   = IC.L_CLASS_CD
                       AND  PC.M_CLASS_CD   = IC.M_CLASS_CD
                       AND  IC.COMP_CD      = I.COMP_CD
                       AND  IC.ITEM_CD      = I.ITEM_CD
                       AND  I.COMP_CD       = S.COMP_CD
                       AND  I.BRAND_CD      = S.BRAND_CD
                       AND  I.ITEM_CD       = S.ITEM_CD
                       AND  PM.COMP_CD      = p_comp_cd
                       AND  PM.ACC_DIV      = '4'
                       AND  PM.USE_YN       = 'Y'
                       AND  PC.USE_YN       = 'Y'
                       AND  IC.USE_YN       = 'Y'
                       AND  I.COMP_CD       = p_comp_cd
                       AND  I.BRAND_CD      = p_brand_cd
                       AND  I.STOR_TP       = ( SELECT STOR_TP FROM STORE WHERE COMP_CD = p_comp_cd AND BRAND_CD = p_brand_cd AND STOR_CD = p_stor_cd )
                       AND  I.USE_YN        = 'Y'
                       AND  S.COMP_CD       = p_comp_cd
                       AND  S.BRAND_CD      = p_brand_cd
                       AND  S.STOR_CD       = p_stor_cd
                       AND  S.SALE_DT       BETWEEN p_goal_ym||'01' AND p_goal_ym||'31'
                     GROUP  BY PM.COMP_CD, S.BRAND_CD, S.STOR_CD, PM.ACC_CD
                    UNION ALL
                    SELECT  PM.COMP_CD
                         ,  p_brand_cd         AS BRAND_CD
                         ,  p_stor_cd          AS STOR_CD
                         ,  PM.ACC_CD
                         ,  0                   AS TAKE_OUT_F_SALE
                         ,  0                   AS TAKE_OUT_B_SALE
                         ,  0                   AS SALE_AMT
                      FROM  PL_ACC_MST  PM
                     WHERE  ACC_CD  IN ('201401', '201402', '201403', '201499', '900090')
                )               PM         
             ,  (
                    SELECT  COMP_CD
                         ,  BRAND_CD
                         ,  STOR_CD
                         ,  SUM(SC.ETC_M_CNT + SC.ETC_F_CNT)    AS CUST_CNT
                      FROM  SALE_JDS        SC
                     WHERE  SC.COMP_CD      = p_comp_cd
                       AND  SC.BRAND_CD     = p_brand_cd
                       AND  SC.STOR_CD      = p_stor_cd
                       AND  SC.SALE_DT      BETWEEN p_goal_ym||'01' AND p_goal_ym||'31'
                     GROUP  BY SC.COMP_CD, SC.BRAND_CD, SC.STOR_CD
                )               SC
             ,  (
                    SELECT  D.COMP_CD
                         ,  D.BRAND_CD
                         ,  S.STOR_CD
                         ,  '201401'                AS ACC_CD
                         ,  SUM(DC_AMT + ENR_AMT)   AS DC_AMT
                      FROM  DC          D
                         ,  SALE_JDD    S
                     WHERE  D.COMP_CD   = S.COMP_CD
                       AND  D.BRAND_CD  = S.BRAND_CD
                       AND  D.DC_DIV    = S.DC_DIV
                       AND  D.COMP_CD   = p_comp_cd
                       AND  D.BRAND_CD  = p_brand_cd
                       AND  D.DC_DIV   <> 10149
                       AND  D.DC_FG     = '2'
                       AND  D.DML_FLAG  IN ('I', 'U')
                       AND  S.STOR_CD   = p_stor_cd
                       AND  S.SALE_DT   BETWEEN p_goal_ym||'01' AND p_goal_ym||'31'
                     GROUP  BY D.COMP_CD, D.BRAND_CD, S.STOR_CD
                    UNION ALL
                    SELECT  D.COMP_CD
                         ,  D.BRAND_CD
                         ,  S.STOR_CD
                         ,  '201402'                AS ACC_CD
                         ,  SUM(DC_AMT + ENR_AMT)   AS DC_AMT
                      FROM  DC          D
                         ,  SALE_JDD    S
                     WHERE  D.COMP_CD   = S.COMP_CD
                       AND  D.BRAND_CD  = S.BRAND_CD
                       AND  D.DC_DIV    = S.DC_DIV
                       AND  D.COMP_CD   = p_comp_cd
                       AND  D.BRAND_CD  = p_brand_cd
                       AND  D.DC_DIV   <> 10149
                       AND  D.DC_FG     = '1'
                       AND  D.DML_FLAG  IN ('I', 'U')
                       AND  S.STOR_CD   = p_stor_cd
                       AND  S.SALE_DT   BETWEEN p_goal_ym||'01' AND p_goal_ym||'31'
                     GROUP  BY D.COMP_CD, D.BRAND_CD, S.STOR_CD
                    UNION ALL
                    SELECT  D.COMP_CD
                         ,  D.BRAND_CD
                         ,  S.STOR_CD
                         ,  '201403'                AS ACC_CD
                         ,  SUM(DC_AMT + ENR_AMT)   AS DC_AMT
                      FROM  DC          D
                         ,  SALE_JDD    S
                     WHERE  D.COMP_CD   = S.COMP_CD
                       AND  D.BRAND_CD  = S.BRAND_CD
                       AND  D.DC_DIV    = S.DC_DIV
                       AND  D.COMP_CD   = p_comp_cd
                       AND  D.BRAND_CD  = p_brand_cd
                       AND  D.DC_DIV    = 10149
                       AND  D.DML_FLAG  IN ('I', 'U')
                       AND  S.STOR_CD   = p_stor_cd
                       AND  S.SALE_DT   BETWEEN p_goal_ym||'01' AND p_goal_ym||'31'
                     GROUP  BY D.COMP_CD, D.BRAND_CD, S.STOR_CD
                    UNION ALL
                    SELECT  D.COMP_CD
                         ,  D.BRAND_CD
                         ,  S.STOR_CD
                         ,  '201499'                AS ACC_CD
                         ,  SUM(DC_AMT + ENR_AMT)   AS DC_AMT
                      FROM  DC          D
                         ,  SALE_JDD    S
                     WHERE  D.COMP_CD   = S.COMP_CD
                       AND  D.BRAND_CD  = S.BRAND_CD
                       AND  D.DC_DIV    = S.DC_DIV
                       AND  D.COMP_CD   = p_comp_cd
                       AND  D.BRAND_CD  = p_brand_cd
                       AND  D.DC_DIV    <> 10149
                       AND  D.DC_FG     NOT IN ('1', '2')
                       AND  D.DML_FLAG  IN ('I', 'U')
                       AND  S.STOR_CD   = p_stor_cd
                       AND  S.SALE_DT   BETWEEN p_goal_ym||'01' AND p_goal_ym||'31'
                     GROUP  BY D.COMP_CD, D.BRAND_CD, S.STOR_CD
                )               D
         WHERE  PM.COMP_CD  = SC.COMP_CD
           AND  PM.BRAND_CD = SC.BRAND_CD
           AND  PM.STOR_CD  = SC.STOR_CD
           AND  PM.COMP_CD  = D.COMP_CD(+)
           AND  PM.BRAND_CD = D.BRAND_CD(+)
           AND  PM.STOR_CD  = D.STOR_CD(+)
           AND  PM.ACC_CD   = D.ACC_CD(+)
         ;

    -- 원가 실적
    CURSOR CUR_C IS
        SELECT  /*+ LEADING(PM PC) INDEX(PM PK_PL_ACC_MST) */
        PM.COMP_CD
             ,  p_goal_ym   AS GOAL_YM
             ,  p_brand_cd  AS BRAND_CD
             ,  p_stor_cd   AS STOR_CD
             ,  '3'         AS GOAL_DIV
             ,  '3'         AS COST_DIV
             ,  PM.ACC_CD
             ,  SUM(PSI.SURV_AMT + OI.ORD_AMT - CSI.SURV_AMT)   AS GOAL_AMT
          FROM  PL_ACC_MST      PM
             ,  PL_ACC_MST_CLS  PC
             ,  ITEM_CLASS      IC
             ,  (
                    -- 전월 재고실사 금액
                    SELECT  S.COMP_CD
                         ,  S.BRAND_CD
                         ,  S.STOR_CD
                         ,  S.ITEM_CD
                         ,  ROUND((NVL(S.ORD_SURV_QTY, 0) * NVL(I.ORD_UNIT_QTY, 0) + NVL(S.SURV_QTY, 0)) * (CASE WHEN NVL(S.ORD_UNIT_QTY, 1) <> 0 THEN ROUND(I.COST / NVL(S.ORD_UNIT_QTY, 1), 3) ELSE I.COST END))    AS SURV_AMT
                      FROM  SURV_STOCK_DT   S
                         ,  ( 
                                SELECT  /*+ USE_NL(I ICH) */
                                        I.COMP_CD
                                     ,  I.ITEM_CD
                                     ,  I.ORD_UNIT
                                     ,  DECODE(I.ORD_UNIT_QTY, 0, 1, I.ORD_UNIT_QTY)    AS ORD_UNIT_QTY
                                     ,  ICH.COST
                                  FROM  ITEM_CHAIN  I
                                     ,  (
                                            SELECT  COMP_CD
                                                 ,  BRAND_CD
                                                 ,  STOR_TP
                                                 ,  ITEM_CD
                                                 ,  COST
                                              FROM  ITEM_CHAIN_HIS  IC
                                             WHERE  COMP_CD     = p_comp_cd
                                               AND  BRAND_CD    = p_brand_cd
                                               AND  STOR_TP     = ( SELECT STOR_TP FROM STORE WHERE COMP_CD = p_comp_cd AND BRAND_CD = p_brand_cd AND STOR_CD = p_stor_cd)
                                               AND  TO_CHAR(ADD_MONTHS(TO_DATE(p_goal_ym, 'YYYYMM'), -1), 'YYYYMM')||'31' BETWEEN IC.START_DT AND NVL(IC.CLOSE_DT, '99991213')
                                               AND  USE_YN      = 'Y'
                                        )           ICH
                                 WHERE  I.COMP_CD   = ICH.COMP_CD
                                   AND  I.BRAND_CD  = ICH.BRAND_CD
                                   AND  I.STOR_TP   = ICH.STOR_TP
                                   AND  I.ITEM_CD   = ICH.ITEM_CD
                            )       I
                     WHERE  S.COMP_CD   = I.COMP_CD
                       AND  S.ITEM_CD   = I.ITEM_CD
                       AND  S.COMP_CD   = p_comp_cd
                       AND  S.SURV_DT   = (
                                                SELECT  MAX(SURV_DT)
                                                  FROM  SURV_STOCK_HD
                                                 WHERE  COMP_CD                 = p_comp_cd
                                                   AND  SUBSTR(SURV_DT, 1, 6)   = TO_CHAR(ADD_MONTHS(TO_DATE(p_goal_ym, 'YYYYMM'), -1), 'YYYYMM')
                                                   AND  BRAND_CD                = p_brand_cd
                                                   AND  STOR_CD                 = p_stor_cd
                                          )
                       AND  S.BRAND_CD  = p_brand_cd
                       AND  S.STOR_CD   = p_stor_cd
                )               PSI
             ,  (
                    -- 당월 재고실사 금액
                    SELECT  S.COMP_CD
                         ,  S.BRAND_CD
                         ,  S.STOR_CD
                         ,  S.ITEM_CD
                         ,  ROUND((NVL(S.ORD_SURV_QTY, 0) * NVL(I.ORD_UNIT_QTY, 0) + NVL(S.SURV_QTY, 0)) * (CASE WHEN NVL(S.ORD_UNIT_QTY, 1) <> 0 THEN ROUND(I.COST / NVL(S.ORD_UNIT_QTY, 1), 3) ELSE I.COST END))    AS SURV_AMT
                      FROM  SURV_STOCK_DT   S
                         ,  ( 
                                SELECT  /*+ USE_NL(I ICH) */
                                        I.COMP_CD
                                     ,  I.ITEM_CD
                                     ,  I.ORD_UNIT
                                     ,  DECODE(I.ORD_UNIT_QTY, 0, 1, I.ORD_UNIT_QTY)    AS ORD_UNIT_QTY
                                     ,  ICH.COST
                                  FROM  ITEM_CHAIN  I
                                     ,  (
                                            SELECT  COMP_CD
                                                 ,  BRAND_CD
                                                 ,  STOR_TP
                                                 ,  ITEM_CD
                                                 ,  COST
                                              FROM  ITEM_CHAIN_HIS  IC
                                             WHERE  COMP_CD     = p_comp_cd
                                               AND  BRAND_CD    = p_brand_cd
                                               AND  STOR_TP     = ( SELECT STOR_TP FROM STORE WHERE COMP_CD = p_comp_cd AND BRAND_CD = p_brand_cd AND STOR_CD = p_stor_cd)
                                               AND  START_DT    = (
                                                                    SELECT  MAX(START_DT)
                                                                      FROM  ITEM_CHAIN_HIS
                                                                     WHERE  COMP_CD     = IC.COMP_CD
                                                                       AND  BRAND_CD    = IC.BRAND_CD
                                                                       AND  STOR_TP     = IC.STOR_TP
                                                                       AND  ITEM_CD     = IC.ITEM_CD
                                                                       AND  START_DT   <= p_goal_ym||'31'
                                                                  )
                                               AND  USE_YN      = 'Y'
                                        )           ICH
                                 WHERE  I.COMP_CD   = ICH.COMP_CD
                                   AND  I.BRAND_CD  = ICH.BRAND_CD
                                   AND  I.STOR_TP   = ICH.STOR_TP
                                   AND  I.ITEM_CD   = ICH.ITEM_CD
                            )       I
                     WHERE  S.COMP_CD   = I.COMP_CD
                       AND  S.ITEM_CD   = I.ITEM_CD
                       AND  S.COMP_CD   = p_comp_cd
                       AND  S.SURV_DT   = (
                                                SELECT  MAX(SURV_DT)
                                                  FROM  SURV_STOCK_HD
                                                 WHERE  COMP_CD                 = p_comp_cd
                                                   AND  SUBSTR(SURV_DT, 1, 6)   = p_goal_ym
                                                   AND  BRAND_CD                = p_brand_cd
                                                   AND  STOR_CD                 = p_stor_cd
                                          )
                       AND  S.BRAND_CD  = p_brand_cd
                       AND  S.STOR_CD   = p_stor_cd
                )               CSI
             ,  (
                    -- 당월 매입금
                    SELECT  COMP_CD
                         ,  BRAND_CD
                         ,  STOR_CD
                         ,  ITEM_CD
                         ,  SUM(CASE WHEN ORD_FG = '2' THEN -1*ORD_CAMT ELSE ORD_CAMT END)       AS ORD_AMT
                      FROM  ORDER_DTV
                     WHERE  COMP_CD   = p_comp_cd
                       AND  BRAND_CD  = p_brand_cd
                       AND  STOR_CD   = p_stor_cd
                       AND  STK_DT    BETWEEN p_goal_ym||'01' AND p_goal_ym||'31'
                     GROUP  BY COMP_CD, BRAND_CD, STOR_CD, ITEM_CD
                )               OI
         WHERE  PM.COMP_CD      = PC.COMP_CD
           AND  PM.ACC_CD       = PC.ACC_CD
           AND  PC.COMP_CD      = IC.COMP_CD
           AND  PC.ORG_CLASS_CD = IC.ORG_CLASS_CD
           AND  PC.L_CLASS_CD   = IC.L_CLASS_CD
           AND  PC.M_CLASS_CD   = IC.M_CLASS_CD
           AND  IC.COMP_CD      = PSI.COMP_CD
           AND  IC.ITEM_CD      = PSI.ITEM_CD
           AND  IC.COMP_CD      = CSI.COMP_CD
           AND  IC.ITEM_CD      = CSI.ITEM_CD
           AND  IC.COMP_CD      = OI.COMP_CD
           AND  IC.ITEM_CD      = OI.ITEM_CD
           AND  PM.COMP_CD      = p_comp_cd
           AND  PM.ACC_DIV      = '5'
           AND  PM.USE_YN       = 'Y'
           AND  PC.USE_YN       = 'Y'
           AND  IC.USE_YN       = 'Y'
         GROUP  BY PM.COMP_CD, PM.ACC_CD;

    -- 실적상위레벨 집계
    CURSOR CUR_T IS
        SELECT  UNIQUE 
                COMP_CD
             ,  REF_ACC_CD
             ,  ACC_LVL
          FROM  PL_ACC_MST
         WHERE  COMP_CD     = p_comp_cd
           AND  ACC_LVL     > 1
           AND  TERM_DIV    = '2'
           AND  ACC_DIV     IN ('4', '5', '6')
         ORDER  BY ACC_LVL DESC, REF_ACC_CD DESC;

    -- 토리돌코리아(006)의 소모품비실적 상위레벨 집계
    CURSOR CUR_006 IS
        SELECT  UNIQUE 
                COMP_CD
             ,  REF_ACC_CD
             ,  ACC_LVL
          FROM  PL_ACC_MST
         WHERE  COMP_CD     = p_comp_cd
           AND  ACC_CD IN ('402000', '402001', '402002', '402003', '402004', '402005')
         ORDER  BY ACC_LVL DESC, REF_ACC_CD DESC;

    MYREC1           CUR_S%ROWTYPE;
    MYREC2           CUR_C%ROWTYPE;
    MYREC3           CUR_T%ROWTYPE;
    MYREC4           CUR_006%ROWTYPE;

    liv_rec_cnt     NUMBER(9) := 0;
    liv_msg_code    NUMBER(9) := 0;
    lsv_msg_text    VARCHAR2(200);

    ERR_HANDLER     EXCEPTION;
BEGIN
    liv_msg_code    := '0';
    lsv_msg_text    := '';

    -- 실적 삭제
    DELETE  PL_GOAL_YM
     WHERE  COMP_CD     = p_comp_cd
       AND  BRAND_CD    = p_brand_cd
       AND  STOR_CD     = p_stor_cd
       AND  GOAL_YM     = p_goal_ym
       AND  GOAL_DIV    = '3'
       AND  COST_DIV    = '3'
       AND  ACC_CD      IN (
                                SELECT  ACC_CD
                                  FROM  PL_ACC_MST
                                 WHERE  COMP_CD = p_comp_cd
                                   AND  ACC_DIV IN ('4', '5', '6')
                           );

    -- 매출계정 실적 등록
    FOR MYREC1 IN CUR_S LOOP
        MERGE INTO PL_GOAL_YM PGY
        USING DUAL
        ON  (
                    PGY.COMP_CD  = MYREC1.COMP_CD
                AND PGY.GOAL_YM  = MYREC1.GOAL_YM
                AND PGY.BRAND_CD = MYREC1.BRAND_CD
                AND PGY.STOR_CD  = MYREC1.STOR_CD
                AND PGY.GOAL_DIV = MYREC1.GOAL_DIV
                AND PGY.COST_DIV = MYREC1.COST_DIV
                AND PGY.ACC_CD   = MYREC1.ACC_CD
            )
        WHEN MATCHED  THEN
            UPDATE      
               SET  PGY.GOAL_AMT = (
                                        CASE WHEN MYREC1.ACC_CD LIKE '2014__' THEN MYREC1.DC_AMT
                                             WHEN MYREC1.ACC_CD = '900090' THEN MYREC1.CUST_CNT
                                             WHEN MYREC1.ACC_CD = '900140' THEN MYREC1.TAKE_OUT_F_SALE
                                             WHEN MYREC1.ACC_CD = '900150' THEN MYREC1.TAKE_OUT_B_SALE
                                             ELSE MYREC1.SALE_AMT
                                        END
                                   )
                 ,  PGY.UPD_DT   = SYSDATE
                 ,  PGY.UPD_USER = p_user_id
        WHEN NOT MATCHED THEN
            INSERT 
                (
                    COMP_CD
                 ,  GOAL_YM
                 ,  BRAND_CD
                 ,  STOR_CD
                 ,  GOAL_DIV
                 ,  COST_DIV
                 ,  ACC_CD
                 ,  GOAL_AMT
                 ,  INST_DT
                 ,  INST_USER
                 ,  UPD_DT
                 ,  UPD_USER
                ) 
                VALUES 
                (
                    MYREC1.COMP_CD
                 ,  MYREC1.GOAL_YM
                 ,  MYREC1.BRAND_CD
                 ,  MYREC1.STOR_CD
                 ,  MYREC1.GOAL_DIV
                 ,  MYREC1.COST_DIV
                 ,  MYREC1.ACC_CD
                 ,  CASE WHEN MYREC1.ACC_CD LIKE '2014__' THEN MYREC1.DC_AMT
                         WHEN MYREC1.ACC_CD = '900090' THEN MYREC1.CUST_CNT
                         WHEN MYREC1.ACC_CD = '900140' THEN MYREC1.TAKE_OUT_F_SALE
                         WHEN MYREC1.ACC_CD = '900150' THEN MYREC1.TAKE_OUT_B_SALE
                         ELSE MYREC1.SALE_AMT
                    END
                 ,  SYSDATE 
                 ,  p_user_id
                 ,  SYSDATE 
                 ,  p_user_id
                 );
    END LOOP;

    -- 원가계정 실적 등록
    FOR MYREC2 IN CUR_C LOOP
        MERGE INTO PL_GOAL_YM PGY
        USING DUAL
        ON  (
                    PGY.COMP_CD  = MYREC2.COMP_CD
                AND PGY.GOAL_YM  = MYREC2.GOAL_YM
                AND PGY.BRAND_CD = MYREC2.BRAND_CD
                AND PGY.STOR_CD  = MYREC2.STOR_CD
                AND PGY.GOAL_DIV = MYREC2.GOAL_DIV
                AND PGY.COST_DIV = MYREC2.COST_DIV
                AND PGY.ACC_CD   = MYREC2.ACC_CD
            )
        WHEN MATCHED  THEN
            UPDATE      
               SET  PGY.GOAL_AMT = MYREC2.GOAL_AMT
                 ,  PGY.UPD_DT   = SYSDATE
                 ,  PGY.UPD_USER = p_user_id
        WHEN NOT MATCHED THEN
            INSERT 
                (
                    COMP_CD
                 ,  GOAL_YM
                 ,  BRAND_CD
                 ,  STOR_CD
                 ,  GOAL_DIV
                 ,  COST_DIV
                 ,  ACC_CD
                 ,  GOAL_AMT
                 ,  INST_DT
                 ,  INST_USER
                 ,  UPD_DT
                 ,  UPD_USER
                ) 
                VALUES 
                (
                    MYREC2.COMP_CD
                 ,  MYREC2.GOAL_YM
                 ,  MYREC2.BRAND_CD
                 ,  MYREC2.STOR_CD
                 ,  MYREC2.GOAL_DIV
                 ,  MYREC2.COST_DIV
                 ,  MYREC2.ACC_CD
                 ,  MYREC2.GOAL_AMT
                 ,  SYSDATE 
                 ,  p_user_id
                 ,  SYSDATE 
                 ,  p_user_id
                 );
    END LOOP;

    -- 합계계정 등록
    FOR MYREC3 IN CUR_T LOOP
        MERGE INTO PL_GOAL_YM PGY
        USING (
                SELECT  GM.COMP_CD
                     ,  GM.GOAL_YM
                     ,  GM.BRAND_CD
                     ,  GM.STOR_CD
                     ,  GM.GOAL_DIV
                     ,  GM.COST_DIV
                     ,  AM.REF_ACC_CD ACC_CD
                     ,  SUM(GOAL_AMT) GOAL_AMT
                FROM    PL_GOAL_YM    GM,
                        PL_ACC_MST    AM
                WHERE   GM.COMP_CD    = AM.COMP_CD
                AND     GM.ACC_CD     = AM.ACC_CD
                AND     GM.COMP_CD    = p_comp_cd
                AND     GM.BRAND_CD   = p_brand_cd
                AND     GM.STOR_CD    = p_stor_cd
                AND     GM.GOAL_YM    = p_goal_ym
                AND     AM.REF_ACC_CD = MYREC3.REF_ACC_CD
                AND     AM.ACC_LVL    = MYREC3.ACC_LVL
                AND     AM.USE_YN     = 'Y'
                GROUP BY
                        GM.COMP_CD
                     ,  GM.GOAL_YM
                     ,  GM.BRAND_CD
                     ,  GM.STOR_CD
                     ,  GM.GOAL_DIV
                     ,  GM.COST_DIV
                     ,  AM.REF_ACC_CD
              ) V01
        ON  (
                    PGY.COMP_CD  = V01.COMP_CD
                AND PGY.GOAL_YM  = V01.GOAL_YM
                AND PGY.BRAND_CD = V01.BRAND_CD
                AND PGY.STOR_CD  = V01.STOR_CD
                AND PGY.GOAL_DIV = V01.GOAL_DIV
                AND PGY.COST_DIV = V01.COST_DIV
                AND PGY.ACC_CD   = V01.ACC_CD
            )
        WHEN MATCHED  THEN
            UPDATE      
               SET  GOAL_AMT    = V01.GOAL_AMT
                 ,  UPD_DT      = SYSDATE
                 ,  UPD_USER    = p_user_id
        WHEN NOT MATCHED THEN
            INSERT 
                (
                    COMP_CD
                 ,  GOAL_YM
                 ,  BRAND_CD
                 ,  STOR_CD
                 ,  GOAL_DIV
                 ,  COST_DIV
                 ,  ACC_CD
                 ,  GOAL_AMT
                 ,  INST_DT
                 ,  INST_USER
                 ,  UPD_DT
                 ,  UPD_USER
                ) 
                VALUES 
                (
                    V01.COMP_CD
                 ,  V01.GOAL_YM
                 ,  V01.BRAND_CD
                 ,  V01.STOR_CD
                 ,  V01.GOAL_DIV
                 ,  V01.COST_DIV
                 ,  V01.ACC_CD
                 ,  V01.GOAL_AMT
                 ,  SYSDATE 
                 ,  p_user_id
                 ,  SYSDATE 
                 ,  p_user_id
                 );
        -- 정상처리    
        liv_msg_code := '0';
    END LOOP;

    -- 토리돌코리아(006)의 유니폼실적 상위레벨 집계
    FOR MYREC4 IN CUR_006 LOOP
        MERGE INTO PL_GOAL_YM PGY
        USING (
                SELECT  GM.COMP_CD
                     ,  GM.GOAL_YM
                     ,  GM.BRAND_CD
                     ,  GM.STOR_CD
                     ,  GM.GOAL_DIV
                     ,  GM.COST_DIV
                     ,  AM.REF_ACC_CD ACC_CD
                     ,  SUM(GOAL_AMT) GOAL_AMT
                FROM    PL_GOAL_YM    GM,
                        PL_ACC_MST    AM
                WHERE   GM.COMP_CD    = AM.COMP_CD
                AND     GM.ACC_CD     = AM.ACC_CD
                AND     GM.COMP_CD    = p_comp_cd
                AND     GM.BRAND_CD   = p_brand_cd
                AND     GM.STOR_CD    = p_stor_cd
                AND     GM.GOAL_YM    = p_goal_ym
                AND     AM.REF_ACC_CD = MYREC4.REF_ACC_CD
                AND     AM.ACC_LVL    = MYREC4.ACC_LVL
                GROUP BY
                        GM.COMP_CD
                     ,  GM.GOAL_YM
                     ,  GM.BRAND_CD
                     ,  GM.STOR_CD
                     ,  GM.GOAL_DIV
                     ,  GM.COST_DIV
                     ,  AM.REF_ACC_CD
              ) V01
        ON  (
                    PGY.COMP_CD  = V01.COMP_CD
                AND PGY.GOAL_YM  = V01.GOAL_YM
                AND PGY.BRAND_CD = V01.BRAND_CD
                AND PGY.STOR_CD  = V01.STOR_CD
                AND PGY.GOAL_DIV = V01.GOAL_DIV
                AND PGY.COST_DIV = V01.COST_DIV
                AND PGY.ACC_CD   = V01.ACC_CD
            )
        WHEN MATCHED  THEN
            UPDATE      
               SET  GOAL_AMT    = V01.GOAL_AMT
                 ,  UPD_DT      = SYSDATE
                 ,  UPD_USER    = p_user_id
        WHEN NOT MATCHED THEN
            INSERT 
                (
                    COMP_CD
                 ,  GOAL_YM
                 ,  BRAND_CD
                 ,  STOR_CD
                 ,  GOAL_DIV
                 ,  COST_DIV
                 ,  ACC_CD
                 ,  GOAL_AMT
                 ,  INST_DT
                 ,  INST_USER
                 ,  UPD_DT
                 ,  UPD_USER
                ) 
                VALUES 
                (
                    V01.COMP_CD
                 ,  V01.GOAL_YM
                 ,  V01.BRAND_CD
                 ,  V01.STOR_CD
                 ,  V01.GOAL_DIV
                 ,  V01.COST_DIV
                 ,  V01.ACC_CD
                 ,  V01.GOAL_AMT
                 ,  SYSDATE 
                 ,  p_user_id
                 ,  SYSDATE 
                 ,  p_user_id
                 );
        -- 정상처리    
        liv_msg_code := '0';
    END LOOP;

    /* RETURN MESSAGE */
    psr_return_cd := liv_msg_code;
    psr_msg       := lsv_msg_text;

    COMMIT;

    RETURN;
EXCEPTION
    WHEN ERR_HANDLER THEN
        ROLLBACK;
        psr_return_cd := SQLCODE;
        psr_msg       := lsv_msg_text;
    WHEN OTHERS THEN
        ROLLBACK;
        psr_return_cd := SQLCODE;
        psr_msg       := SQLERRM;
END;

/
