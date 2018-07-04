--------------------------------------------------------
--  DDL for Procedure SP_ANAL1180M0
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_ANAL1180M0" 
/******************************************************************************
   NAME     :  SP_ANAL1180M0
   PURPOSE  :  본사비용 매장 배분

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     SP_ANAL1180M0
      Sysdate:         
      Date and Time:   
      Username:         (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
(    
    p_comp_cd      IN   VARCHAR2,
    p_user_id      IN   VARCHAR2,
    p_goal_ym      IN   VARCHAR2,
    psr_return_cd  OUT  VARCHAR2,
    psr_msg        OUT  VARCHAR2
)
IS
    CURSOR CUR_1 IS
        SELECT  JDS.COMP_CD,
                JDS.BRAND_CD,
                JDS.STOR_CD,
                PHQ.ACC_CD,
                PHQ.GOAL_DIV,
                PHQ.COST_DIV,
                PHQ.GOAL_AMT,
                JDS.GRD_AMT,
                JDS.TOT_GRD_AMT,
                ROUND(PHQ.GOAL_AMT * JDS.SALE_RATE, 0)    AS GOAL_DIV_AMT,
                SUM(ROUND(PHQ.GOAL_AMT * JDS.SALE_RATE, 0))  OVER(PARTITION BY JDS.COMP_CD, PHQ.ACC_CD, PHQ.GOAL_DIV, PHQ.COST_DIV  ORDER BY JDS.STOR_CD) ACC_GOAL_AMT,
                COUNT(*)     OVER(PARTITION BY JDS.COMP_CD, PHQ.ACC_CD, PHQ.GOAL_DIV, PHQ.COST_DIV) LAST_ROW,
                ROW_NUMBER() OVER(PARTITION BY JDS.COMP_CD, PHQ.ACC_CD, PHQ.GOAL_DIV, PHQ.COST_DIV  ORDER BY JDS.STOR_CD) CUR_ROW
        FROM    PL_GOAL_YM_HQ PHQ,
               (            
                SELECT  COMP_CD,
                        BRAND_CD,
                        STOR_CD,
                        GRD_AMT,
                        TOT_GRD_AMT,
                        ROUND(GRD_AMT / TOT_GRD_AMT, 3) AS SALE_RATE 
                FROM   (
                        SELECT  COMP_CD,
                                BRAND_CD,
                                STOR_CD,
                                SUM(GRD_AMT) OVER(PARTITION BY COMP_CD, BRAND_CD, STOR_CD) GRD_AMT,
                                SUM(GRD_AMT) OVER() TOT_GRD_AMT,
                                ROW_NUMBER() OVER(PARTITION BY COMP_CD, BRAND_CD, STOR_CD ORDER BY STOR_CD) R_NUM
                        FROM    SALE_JDS
                        WHERE   COMP_CD    = p_comp_cd
                        AND     BRAND_CD LIKE '1%'
                        AND     SALE_DT  LIKE p_goal_ym||'%'
                       )
                WHERE   R_NUM = 1 
               ) JDS
        WHERE   JDS.COMP_CD = PHQ.COMP_CD
        AND     PHQ.COMP_CD = p_comp_cd
        AND     PHQ.GOAL_YM = p_goal_ym;

    MYREC           CUR_1%ROWTYPE;
    liv_rec_cnt     NUMBER(9) := 0;
    liv_msg_code    NUMBER(9) := 0;
    lsv_msg_text    VARCHAR2(200);

    ERR_HANDLER     EXCEPTION;
BEGIN
    liv_msg_code    := '0';
    lsv_msg_text    := '';

    FOR MYREC IN CUR_1 LOOP
        DELETE FROM PL_GOAL_YM
        WHERE  COMP_CD  = MYREC.COMP_CD
        AND    GOAL_YM  = p_goal_ym
        AND    BRAND_CD = MYREC.BRAND_CD
        AND    STOR_CD  = MYREC.STOR_CD
        AND    GOAL_DIV = MYREC.GOAL_DIV
        AND    COST_DIV = '3'
        AND    ACC_CD   = MYREC.ACC_CD;

        IF MYREC.LAST_ROW = MYREC.CUR_ROW THEN
            INSERT INTO PL_GOAL_YM 
                   (COMP_CD,  GOAL_YM,   BRAND_CD, STOR_CD, 
                    GOAL_DIV, COST_DIV,  ACC_CD,   GOAL_AMT,
                    INST_DT,  INST_USER, UPD_DT,   UPD_USER)
            VALUES (
                    MYREC.COMP_CD,  
                    p_goal_ym,   
                    MYREC.BRAND_CD, 
                    MYREC.STOR_CD, 
                    MYREC.GOAL_DIV, 
                    MYREC.COST_DIV,  
                    MYREC.ACC_CD,   
                    MYREC.GOAL_DIV_AMT + (MYREC.GOAL_AMT - MYREC.ACC_GOAL_AMT),
                    SYSDATE,  
                    p_user_id, 
                    SYSDATE,   
                    p_user_id
                   );
        ELSE
            INSERT INTO PL_GOAL_YM 
                   (COMP_CD,  GOAL_YM,   BRAND_CD, STOR_CD, 
                    GOAL_DIV, COST_DIV,  ACC_CD,   GOAL_AMT,
                    INST_DT,  INST_USER, UPD_DT,   UPD_USER)
            VALUES (
                    MYREC.COMP_CD,  
                    p_goal_ym,   
                    MYREC.BRAND_CD, 
                    MYREC.STOR_CD, 
                    MYREC.GOAL_DIV, 
                    MYREC.COST_DIV,  
                    MYREC.ACC_CD,   
                    MYREC.GOAL_DIV_AMT,
                    SYSDATE,  
                    p_user_id, 
                    SYSDATE,   
                    p_user_id
                   );
        END IF;

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
