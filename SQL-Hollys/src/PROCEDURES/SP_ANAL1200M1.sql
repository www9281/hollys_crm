--------------------------------------------------------
--  DDL for Procedure SP_ANAL1200M1
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_ANAL1200M1" 
/******************************************************************************
   NAME     :  SP_ANAL1200M1
   PURPOSE  : 손익추정 등록 매출/원가 실적 생성

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     SP_ANAL1200M1
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
             ,  S.BRAND_CD
             ,  S.STOR_CD
             ,  '3'         AS GOAL_DIV
             ,  '3'         AS COST_DIV
             ,  PM.ACC_CD
             ,  SUM(S.GRD_AMT - S.VAT_AMT)  AS GOAL_AMT
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
         GROUP  BY PM.COMP_CD, S.BRAND_CD, S.STOR_CD, PM.ACC_CD;

    -- 원가 실적
    CURSOR CUR_C IS
        SELECT  PM.COMP_CD
             ,  p_goal_ym   AS GOAL_YM
             ,  p_brand_cd  AS BRAND_CD
             ,  p_stor_cd   AS STOR_CD
             ,  '3'         AS GOAL_DIV
             ,  '3'         AS COST_DIV
             ,  PM.ACC_CD
             ,  ROUND(SUM(CASE WHEN I.COST_VAT_YN = 'Y' AND I.COST_VAT_RULE = '1' THEN S.STOCK_QTY * I.COST - S.STOCK_QTY * I.VAT ELSE S.STOCK_QTY * I.COST END))   AS GOAL_AMT
          FROM  PL_ACC_MST      PM
             ,  PL_ACC_MST_CLS  PC
             ,  ITEM_CLASS      IC
             ,  (
                    SELECT  I.COMP_CD
                         ,  I.ITEM_CD
                         ,  I.COST_VAT_YN
                         ,  I.COST_VAT_RULE
                         , (CASE WHEN NVL(I.ORD_UNIT_QTY, 1) = 0 THEN ICH.COST ELSE ICH.COST / NVL(I.ORD_UNIT_QTY, 1) END)  AS COST
                         ,  CASE WHEN I.COST_VAT_YN = 'Y' AND I.COST_VAT_RULE = '2' THEN (CASE WHEN NVL(I.ORD_UNIT_QTY, 1) = 0 THEN ICH.COST ELSE ICH.COST / NVL(I.ORD_UNIT_QTY, 1) END) * I.COST_VAT_RATE
                                 WHEN I.COST_VAT_YN = 'Y' AND I.COST_VAT_RULE = '1' THEN (CASE WHEN NVL(I.ORD_UNIT_QTY, 1) = 0 THEN ICH.COST ELSE ICH.COST / NVL(I.ORD_UNIT_QTY, 1) END) * I.COST_VAT_RATE / (1+I.COST_VAT_RATE)
                                 ELSE 0
                            END         AS VAT
                      FROM  ITEM_CHAIN      I
                         ,  ITEM_CHAIN_HIS  ICH
                     WHERE  I.COMP_CD       = ICH.COMP_CD
                       AND  I.BRAND_CD      = ICH.BRAND_CD
                       AND  I.STOR_TP       = ICH.STOR_TP
                       AND  I.ITEM_CD       = ICH.ITEM_CD
                       AND  I.COMP_CD       = p_comp_cd
                       AND  I.BRAND_CD      = p_brand_cd
                       AND  I.STOR_TP       = ( SELECT STOR_TP FROM STORE WHERE COMP_CD = p_comp_cd AND BRAND_CD = p_brand_cd AND STOR_CD = p_stor_cd )
                       AND  I.USE_YN        = 'Y'
                       AND  ICH.USE_YN      = 'Y'
                       AND  TO_CHAR(LAST_DAY(TO_DATE(p_goal_ym||'01', 'YYYYMMDD')), 'YYYYMMDD') BETWEEN ICH.START_DT AND NVL(ICH.CLOSE_DT, '99991213')
                )               I     
             ,  (
                    SELECT  M.COMP_CD
                         ,  M.ITEM_CD
                         ,  MAX(CASE WHEN M.PRC_YM = TO_CHAR(ADD_MONTHS(TO_DATE(p_goal_ym, 'YYYYMM'), -1), 'YYYYMM') THEN NVL(M.SURV_QTY, 0) ELSE 0 END)   -- 기초재고
                            +
                            SUM(D.ORD_QTY - D.RTN_QTY + D.MV_IN_QTY - D.MV_OUT_QTY)                     -- 당월매입
                            -
                            MAX(CASE WHEN M.PRC_YM = p_goal_ym THEN NVL(M.SURV_QTY, 0) ELSE 0 END)     -- 기말재고
                            AS  STOCK_QTY
                      FROM  MSTOCK          M
                         ,  DSTOCK          D
                     WHERE  M.COMP_CD   = D.COMP_CD
                       AND  M.PRC_YM    = SUBSTR(D.PRC_DT, 1, 6)
                       AND  M.ITEM_CD   = D.ITEM_CD
                       AND  M.PRC_YM    BETWEEN TO_CHAR(ADD_MONTHS(TO_DATE(p_goal_ym, 'YYYYMM'), -1), 'YYYYMM') AND p_goal_ym
                       AND  M.BRAND_CD  = p_brand_cd
                       AND  M.STOR_CD   = p_stor_cd
                       AND  D.PRC_DT    BETWEEN p_goal_ym||'01' AND p_goal_ym||'31'
                       AND  D.BRAND_CD  = p_brand_cd
                       AND  D.STOR_CD   = p_stor_cd
                     GROUP  BY M.COMP_CD, M.ITEM_CD
                )               S
         WHERE  PM.COMP_CD      = PC.COMP_CD
           AND  PM.ACC_CD       = PC.ACC_CD
           AND  PC.COMP_CD      = IC.COMP_CD
           AND  PC.ORG_CLASS_CD = IC.ORG_CLASS_CD
           AND  PC.L_CLASS_CD   = IC.L_CLASS_CD
           AND  PC.M_CLASS_CD   = IC.M_CLASS_CD
           AND  IC.COMP_CD      = I.COMP_CD
           AND  IC.ITEM_CD      = I.ITEM_CD
           AND  I.COMP_CD       = S.COMP_CD
           AND  I.ITEM_CD       = S.ITEM_CD
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

    MYREC1           CUR_S%ROWTYPE;
    MYREC2           CUR_C%ROWTYPE;
    MYREC3           CUR_T%ROWTYPE;
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
               SET  PGY.GOAL_AMT = MYREC1.GOAL_AMT
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
                 ,  MYREC1.GOAL_AMT
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
