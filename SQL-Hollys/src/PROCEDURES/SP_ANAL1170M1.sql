--------------------------------------------------------
--  DDL for Procedure SP_ANAL1170M1
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_ANAL1170M1" 
/******************************************************************************
   NAME     :  SP_ANAL1170M1
   PURPOSE  : 손익추정 등록 상위레벨 집계자료 생성

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     SP_ANAL1160M1
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
    -- 매장비용 홀 주방 전체 생성(전체 - 홀 = 주방)
    CURSOR CUR_1 IS
        SELECT  PGY.COMP_CD
             ,  PGY.GOAL_YM
             ,  PGY.BRAND_CD
             ,  PGY.STOR_CD
             ,  PGY.GOAL_DIV
             ,  PGY.ACC_CD
             ,  CASE WHEN V01.LAST_COST_DIV = '3' THEN '2' ELSE '3' END AS COST_DIV
             ,  SUM(CASE WHEN V01.LAST_COST_DIV ='3' THEN DECODE(PGY.COST_DIV, '3', PGY.GOAL_AMT, PGY.GOAL_AMT * (-1)) 
                         ELSE PGY.GOAL_AMT END) GOAL_AMT
        FROM    PL_GOAL_YM PGY
             , (
                SELECT  COMP_CD
                     ,  GOAL_YM
                     ,  BRAND_CD
                     ,  STOR_CD
                     ,  GOAL_DIV
                     ,  ACC_CD
                     ,  MAX(COST_DIV) LAST_COST_DIV
                FROM    PL_GOAL_YM
                WHERE   COMP_CD    = p_comp_cd
                AND     GOAL_YM    = p_goal_yyyy
                AND     BRAND_CD   = NVL(p_brand_cd, BRAND_CD)
                AND     STOR_CD    = NVL(p_stor_cd,  STOR_CD)
                AND     ACC_CD  LIKE '2%'
                GROUP BY
                        COMP_CD
                     ,  GOAL_YM
                     ,  BRAND_CD
                     ,  STOR_CD
                     ,  GOAL_DIV
                     ,  ACC_CD
            ) V01
        WHERE   PGY.COMP_CD    = V01.COMP_CD
        AND     PGY.GOAL_YM    = V01.GOAL_YM
        AND     PGY.BRAND_CD   = V01.BRAND_CD
        AND     PGY.STOR_CD    = V01.STOR_CD
        AND     PGY.GOAL_DIV   = V01.GOAL_DIV
        AND     PGY.ACC_CD     = V01.ACC_CD
        AND     PGY.COMP_CD    = p_comp_cd
        AND     PGY.GOAL_YM    = p_goal_yyyy
        AND     PGY.BRAND_CD   = NVL(p_brand_cd, PGY.BRAND_CD)
        AND     PGY.STOR_CD    = NVL(p_stor_cd,  PGY.STOR_CD)
        AND     PGY.ACC_CD  LIKE '2%'
        GROUP BY
                PGY.COMP_CD
             ,  PGY.GOAL_YM
             ,  PGY.BRAND_CD
             ,  PGY.STOR_CD
             ,  PGY.GOAL_DIV
             ,  PGY.ACC_CD
             ,  CASE WHEN V01.LAST_COST_DIV = '3' THEN '2' ELSE '3' END;

    -- 매장비용 상위 레벨 집계자료 생성
    CURSOR CUR_2 IS
        SELECT  UNIQUE 
                COMP_CD
             ,  REF_ACC_CD
             ,  ACC_LVL
        FROM    PL_ACC_MST
        WHERE   COMP_CD = p_comp_cd
        AND     ACC_LVL > 1
        ORDER BY ACC_LVL DESC, REF_ACC_CD DESC;

    MYREC1           CUR_1%ROWTYPE;
    MYREC2           CUR_2%ROWTYPE;
    liv_rec_cnt     NUMBER(9) := 0;
    liv_msg_code    NUMBER(9) := 0;
    lsv_msg_text    VARCHAR2(200);

    ERR_HANDLER     EXCEPTION;
BEGIN
    liv_msg_code    := '0';
    lsv_msg_text    := '';

    -- 주방/홀/전체 작성
    FOR MYREC1 IN CUR_1 LOOP
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

    FOR MYREC2 IN CUR_2 LOOP
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
                AND     GM.BRAND_CD   = NVL(p_brand_cd, GM.BRAND_CD)
                AND     GM.STOR_CD    = NVL(p_stor_cd,  GM.STOR_CD)
                AND     GM.GOAL_YM    LIKE p_goal_yyyy||'%'
                AND     AM.REF_ACC_CD = MYREC2.REF_ACC_CD
                AND     AM.ACC_LVL    = MYREC2.ACC_LVL
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

    -- 매장직접이익 계산
    DELETE  PL_GOAL_YM
     WHERE  COMP_CD     = p_comp_cd
       AND  BRAND_CD    = NVL(p_brand_cd, BRAND_CD)
       --AND  STOR_CD     = NVL(p_stor_cd , STOR_CD)
       AND  GOAL_YM     LIKE p_goal_yyyy||'%'
       AND  ACC_CD      = '30000';

    INSERT  INTO PL_GOAL_YM
    SELECT  COMP_CD
         ,  GOAL_YM
         ,  BRAND_CD
         ,  STOR_CD
         ,  GOAL_DIV
         ,  COST_DIV
         ,  '30000'
         ,  SUM(CASE WHEN ACC_CD = '11000' THEN GOAL_AMT ELSE -1*GOAL_AMT END)  AS GOAL_AMT
         ,  SYSDATE
         ,  p_user_id                
         ,  SYSDATE
         ,  p_user_id
      FROM  PL_GOAL_YM
     WHERE  COMP_CD     = p_comp_cd
       AND  BRAND_CD    = NVL(p_brand_cd, BRAND_CD)
       --AND  STOR_CD     = NVL(p_stor_cd , STOR_CD)
       AND  GOAL_YM     LIKE p_goal_yyyy||'%'
       AND  ACC_CD  IN ('11000', '20000')
     GROUP  BY COMP_CD
         ,  GOAL_YM
         ,  BRAND_CD
         ,  STOR_CD
         ,  GOAL_DIV
         ,  COST_DIV;

    -- 단기순이익 계산
    DELETE  PL_GOAL_YM
     WHERE  COMP_CD     = p_comp_cd
       AND  BRAND_CD    = NVL(p_brand_cd, BRAND_CD)
       --AND  STOR_CD     = NVL(p_stor_cd , STOR_CD)
       AND  GOAL_YM     LIKE p_goal_yyyy||'%'
       AND  ACC_CD      = '90000';

    INSERT  INTO PL_GOAL_YM
    SELECT  COMP_CD
         ,  GOAL_YM
         ,  BRAND_CD
         ,  STOR_CD
         ,  GOAL_DIV
         ,  COST_DIV
         ,  '90000'
         ,  SUM(CASE WHEN ACC_CD = '11000' THEN GOAL_AMT ELSE -1*GOAL_AMT END)  AS GOAL_AMT
         ,  SYSDATE
         ,  p_user_id                
         ,  SYSDATE
         ,  p_user_id
      FROM  PL_GOAL_YM
     WHERE  COMP_CD     = p_comp_cd
       AND  BRAND_CD    = NVL(p_brand_cd, BRAND_CD)
       --AND  STOR_CD     = NVL(p_stor_cd , STOR_CD)
       AND  GOAL_YM     LIKE p_goal_yyyy||'%'
       AND  ACC_CD  IN ('11000', '20000', '40000')
     GROUP  BY COMP_CD
         ,  GOAL_YM
         ,  BRAND_CD
         ,  STOR_CD
         ,  GOAL_DIV
         ,  COST_DIV;

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
