--------------------------------------------------------
--  DDL for Procedure SP_ANAL1220M0
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_ANAL1220M0" 
/******************************************************************************
   NAME     :  SP_ANAL1220M0
   PURPOSE  : 손익추정 등록(기타입출금내역 집계 및 상위레벨 집계자료 생성)

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     SP_ANAL1220M0
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
    -- 기타입출금 실적
    CURSOR CUR_E IS
        SELECT  PS.COMP_CD
             ,  SUBSTR(PS.PRC_DT, 1, 6) AS GOAL_YM
             ,  PS.BRAND_CD
             ,  PS.STOR_CD
             ,  '3'                     AS GOAL_DIV
             ,  '3'                     AS COST_DIV
             ,  PS.ETC_CD               AS ACC_CD
             ,  SUM(PS.ETC_AMT)         AS GOAL_AMT
          FROM  PL_ACC_MST          PA
             ,  PL_STORE_ETC_AMT    PS
         WHERE  PA.COMP_CD  = PS.COMP_CD
           AND  PA.ACC_CD   = PS.ETC_CD
           AND  PA.COMP_CD  = p_comp_cd
           AND  PA.USE_YN   = 'Y'
           AND  PA.TERM_DIV = '3'
           AND  PS.BRAND_CD = p_brand_cd
           AND  PS.STOR_CD  = p_stor_cd
           AND  PS.PRC_DT   BETWEEN p_goal_ym||'01' AND p_goal_ym||'31'
         GROUP  BY PS.COMP_CD, SUBSTR(PS.PRC_DT, 1, 6), PS.BRAND_CD, PS.STOR_CD, PS.ETC_CD;

    -- 기타입출금 상위 레벨 집계자료 생성
    CURSOR CUR_T IS
        SELECT  UNIQUE 
                COMP_CD
             ,  REF_ACC_CD
             ,  ACC_LVL
          FROM  PL_ACC_MST
         WHERE  COMP_CD     = p_comp_cd
           AND  ACC_LVL     > 1
           AND  TERM_DIV    = '3'
         ORDER  BY ACC_LVL DESC, REF_ACC_CD DESC;

    MYREC1           CUR_E%ROWTYPE;
    MYREC2           CUR_T%ROWTYPE;
    liv_rec_cnt     NUMBER(9) := 0;
    liv_msg_code    NUMBER(9) := 0;
    lsv_msg_text    VARCHAR2(200);

    ERR_HANDLER     EXCEPTION;
BEGIN
    dbms_output.enable( 1000000 );

    liv_msg_code    := '0';
    lsv_msg_text    := '';

    -- 기타입출금 실적 집계
    FOR MYREC1 IN CUR_E LOOP
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

    -- 삭제계정 처리
    DELETE  PL_GOAL_YM
     WHERE  COMP_CD  = p_comp_cd
       AND  GOAL_YM  = p_goal_ym
       AND  BRAND_CD = p_brand_cd
       AND  STOR_CD  = p_stor_cd
       AND  GOAL_DIV = '3'
       AND  COST_DIV = '3'
       AND  ACC_CD IN (
                        SELECT  PG.ACC_CD
                          FROM  PL_ACC_MST  PA
                             ,  PL_GOAL_YM  PG
                         WHERE  PA.COMP_CD  = PG.COMP_CD
                           AND  PA.ACC_CD   = PG.ACC_CD
                           AND  PA.COMP_CD  = p_comp_cd
                           AND  PA.TERM_DIV = '3'
                           AND  PA.ACC_DIV  = '1'
                           AND  PG.GOAL_YM  = p_goal_ym
                           AND  PG.BRAND_CD = p_brand_cd
                           AND  PG.STOR_CD  = p_stor_cd
                           AND  (PG.COMP_CD, PG.GOAL_YM, PG.BRAND_CD, PG.STOR_CD, PG.GOAL_DIV, PG.COST_DIV, PG.ACC_CD) NOT IN (
                                    SELECT  COMP_CD
                                         ,  SUBSTR(PRC_DT, 1, 6)    AS GOAL_YM
                                         ,  BRAND_CD
                                         ,  STOR_CD
                                         ,  '3'                     AS GOAL_DIV
                                         ,  '3'                     AS COST_DIV
                                         ,  ETC_CD                  AS ACC_CD
                                      FROM  PL_STORE_ETC_AMT
                                     WHERE  COMP_CD  = p_comp_cd
                                       AND  PRC_DT   BETWEEN p_goal_ym||'01' AND p_goal_ym||'31'
                                       AND  BRAND_CD = p_brand_cd
                                       AND  STOR_CD  = p_stor_cd
                                     GROUP  BY COMP_CD, SUBSTR(PRC_DT, 1, 6), BRAND_CD, STOR_CD, ETC_CD
                               )
                      );  

    -- 합계계정 등록
    FOR MYREC2 IN CUR_T LOOP
        MERGE INTO PL_GOAL_YM PGY
        USING (
                SELECT  NVL(GM.COMP_CD,  p_comp_cd)     AS COMP_CD
                     ,  NVL(GM.GOAL_YM,  p_goal_ym)     AS GOAL_YM
                     ,  NVL(GM.BRAND_CD, p_brand_cd)    AS BRAND_CD
                     ,  NVL(GM.STOR_CD,  p_stor_cd)     AS STOR_CD
                     ,  NVL(GM.GOAL_DIV, '3')           AS GOAL_DIV
                     ,  NVL(GM.COST_DIV, '3')           AS COST_DIV
                     ,  AM.REF_ACC_CD                   AS ACC_CD
                     ,  SUM(NVL(GOAL_AMT, 0))           AS GOAL_AMT
                  FROM  PL_ACC_MST    AM
                     ,  PL_GOAL_YM    GM
                 WHERE  AM.COMP_CD    = GM.COMP_CD(+)
                   AND  AM.ACC_CD     = GM.ACC_CD(+)
                   AND  GM.COMP_CD(+) = p_comp_cd
                   AND  GM.BRAND_CD(+)= p_brand_cd
                   AND  GM.STOR_CD(+) = p_stor_cd
                   AND  GM.GOAL_YM(+) = p_goal_ym
                   AND  AM.REF_ACC_CD = MYREC2.REF_ACC_CD
                   AND  AM.ACC_LVL    = MYREC2.ACC_LVL
                   AND  AM.USE_YN     = 'Y'
                 GROUP  BY
                        NVL(GM.COMP_CD,  p_comp_cd)
                     ,  NVL(GM.GOAL_YM,  p_goal_ym)
                     ,  NVL(GM.BRAND_CD, p_brand_cd)
                     ,  NVL(GM.STOR_CD,  p_stor_cd)
                     ,  NVL(GM.GOAL_DIV, '3')
                     ,  NVL(GM.COST_DIV, '3')
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
        dbms_output.put_line('2 => ' || psr_msg);
END;

/
