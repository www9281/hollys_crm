--------------------------------------------------------
--  DDL for Procedure SP_ANAL1200M0
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_ANAL1200M0" 
/******************************************************************************
   NAME     :  SP_ANAL1200M0
   PURPOSE  : 손익추정 등록 상위레벨 집계자료 생성

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     SP_ANAL1200M0
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
    p_goal_yyyy    IN   VARCHAR2,
    psr_return_cd  OUT  VARCHAR2,
    psr_msg        OUT  VARCHAR2
)
IS
    -- 매장비용 상위 레벨 집계자료 생성
    CURSOR CUR_1 IS
        SELECT  UNIQUE 
                COMP_CD
             ,  REF_ACC_CD
             ,  ACC_LVL
          FROM  PL_ACC_MST
         WHERE  COMP_CD     = p_comp_cd
           AND  ACC_LVL     > 1
           AND  TERM_DIV    = '2'
         ORDER  BY ACC_LVL DESC, REF_ACC_CD DESC;

    MYREC           CUR_1%ROWTYPE;
    liv_rec_cnt     NUMBER(9) := 0;
    liv_msg_code    NUMBER(9) := 0;
    lsv_msg_text    VARCHAR2(200);

    ERR_HANDLER     EXCEPTION;
BEGIN
    liv_msg_code    := '0';
    lsv_msg_text    := '';

    FOR MYREC IN CUR_1 LOOP
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
                AND     GM.GOAL_YM LIKE p_goal_yyyy||'%'
                AND     AM.REF_ACC_CD = MYREC.REF_ACC_CD
                AND     AM.ACC_LVL    = MYREC.ACC_LVL
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
