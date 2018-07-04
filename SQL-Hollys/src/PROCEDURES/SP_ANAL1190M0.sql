--------------------------------------------------------
--  DDL for Procedure SP_ANAL1190M0
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_ANAL1190M0" 
/******************************************************************************
   NAME     :  SP_ANAL1190M0
   PURPOSE  : 손익추정 등록 상위레벨 집계자료 생성

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     SP_ANAL1190M0
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
    -- 매장비용 상위 레벨 집계자료 생성
    CURSOR CUR_1 IS
        SELECT  UNIQUE 
                COMP_CD
             ,  REF_ACC_CD
             ,  ACC_LVL
          FROM  PL_ACC_MST
         WHERE  COMP_CD  = p_comp_cd
           AND  ACC_LVL  > 1
           AND  TERM_DIV = '1'
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
        MERGE INTO PL_GOAL_DD PGD
        USING (
                SELECT  GD.COMP_CD
                     ,  GD.GOAL_YM
                     ,  GD.BRAND_CD
                     ,  GD.STOR_CD
                     ,  GD.GOAL_DIV
                     ,  AM.REF_ACC_CD   AS ACC_CD
                     ,  SUM(GD.G_D01)   AS G_D01
                     ,  SUM(GD.G_D02)   AS G_D02
                     ,  SUM(GD.G_D03)   AS G_D03
                     ,  SUM(GD.G_D04)   AS G_D04
                     ,  SUM(GD.G_D05)   AS G_D05
                     ,  SUM(GD.G_D06)   AS G_D06
                     ,  SUM(GD.G_D07)   AS G_D07
                     ,  SUM(GD.G_D08)   AS G_D08
                     ,  SUM(GD.G_D09)   AS G_D09
                     ,  SUM(GD.G_D10)   AS G_D10
                     ,  SUM(GD.G_D11)   AS G_D11
                     ,  SUM(GD.G_D12)   AS G_D12
                     ,  SUM(GD.G_D13)   AS G_D13
                     ,  SUM(GD.G_D14)   AS G_D14
                     ,  SUM(GD.G_D15)   AS G_D15
                     ,  SUM(GD.G_D16)   AS G_D16
                     ,  SUM(GD.G_D17)   AS G_D17
                     ,  SUM(GD.G_D18)   AS G_D18
                     ,  SUM(GD.G_D19)   AS G_D19
                     ,  SUM(GD.G_D20)   AS G_D20
                     ,  SUM(GD.G_D21)   AS G_D21
                     ,  SUM(GD.G_D22)   AS G_D22
                     ,  SUM(GD.G_D23)   AS G_D23
                     ,  SUM(GD.G_D24)   AS G_D24
                     ,  SUM(GD.G_D25)   AS G_D25
                     ,  SUM(GD.G_D26)   AS G_D26
                     ,  SUM(GD.G_D27)   AS G_D27
                     ,  SUM(GD.G_D28)   AS G_D28
                     ,  SUM(GD.G_D29)   AS G_D29
                     ,  SUM(GD.G_D30)   AS G_D30
                     ,  SUM(GD.G_D31)   AS G_D31
                  FROM  PL_GOAL_DD    GD
                     ,  PL_ACC_MST    AM
                 WHERE  GD.COMP_CD      = AM.COMP_CD
                   AND  GD.ACC_CD       = AM.ACC_CD
                   AND  GD.COMP_CD      = p_comp_cd
                   AND  GD.BRAND_CD     = p_brand_cd
                   AND  GD.STOR_CD      = p_stor_cd
                   AND  GD.GOAL_YM      = p_goal_ym
                   AND  AM.REF_ACC_CD   = MYREC.REF_ACC_CD
                   AND  AM.ACC_LVL      = MYREC.ACC_LVL
                 GROUP BY
                        GD.COMP_CD
                     ,  GD.GOAL_YM
                     ,  GD.BRAND_CD
                     ,  GD.STOR_CD
                     ,  GD.GOAL_DIV
                     ,  AM.REF_ACC_CD
              ) V01
        ON  (
                    PGD.COMP_CD  = V01.COMP_CD
                AND PGD.GOAL_YM  = V01.GOAL_YM
                AND PGD.BRAND_CD = V01.BRAND_CD
                AND PGD.STOR_CD  = V01.STOR_CD
                AND PGD.GOAL_DIV = V01.GOAL_DIV
                AND PGD.ACC_CD   = V01.ACC_CD
            )
        WHEN MATCHED  THEN
            UPDATE      
               SET  G_D01       = V01.G_D01
                 ,  G_D02       = V01.G_D02
                 ,  G_D03       = V01.G_D03
                 ,  G_D04       = V01.G_D04
                 ,  G_D05       = V01.G_D05
                 ,  G_D06       = V01.G_D06
                 ,  G_D07       = V01.G_D07
                 ,  G_D08       = V01.G_D08
                 ,  G_D09       = V01.G_D09
                 ,  G_D10       = V01.G_D10
                 ,  G_D11       = V01.G_D11
                 ,  G_D12       = V01.G_D12
                 ,  G_D13       = V01.G_D13
                 ,  G_D14       = V01.G_D14
                 ,  G_D15       = V01.G_D15
                 ,  G_D16       = V01.G_D16
                 ,  G_D17       = V01.G_D17
                 ,  G_D18       = V01.G_D18
                 ,  G_D19       = V01.G_D19
                 ,  G_D20       = V01.G_D20
                 ,  G_D21       = V01.G_D21
                 ,  G_D22       = V01.G_D22
                 ,  G_D23       = V01.G_D23
                 ,  G_D24       = V01.G_D24
                 ,  G_D25       = V01.G_D25
                 ,  G_D26       = V01.G_D26
                 ,  G_D27       = V01.G_D27
                 ,  G_D28       = V01.G_D28
                 ,  G_D29       = V01.G_D29
                 ,  G_D30       = V01.G_D30
                 ,  G_D31       = V01.G_D31
                 ,  G_SUM       = (
                                    V01.G_D01+V01.G_D02+V01.G_D03+V01.G_D04+V01.G_D05+V01.G_D06+V01.G_D07+V01.G_D08+V01.G_D09+V01.G_D10+
                                    V01.G_D11+V01.G_D12+V01.G_D13+V01.G_D14+V01.G_D15+V01.G_D16+V01.G_D17+V01.G_D18+V01.G_D19+V01.G_D20+
                                    V01.G_D21+V01.G_D22+V01.G_D23+V01.G_D24+V01.G_D25+V01.G_D26+V01.G_D27+V01.G_D28+V01.G_D29+V01.G_D30+V01.G_D31
                                  )
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
                 ,  ACC_CD
                 ,  G_D01
                 ,  G_D02
                 ,  G_D03
                 ,  G_D04
                 ,  G_D05
                 ,  G_D06
                 ,  G_D07
                 ,  G_D08
                 ,  G_D09
                 ,  G_D10
                 ,  G_D11
                 ,  G_D12
                 ,  G_D13
                 ,  G_D14
                 ,  G_D15
                 ,  G_D16
                 ,  G_D17
                 ,  G_D18
                 ,  G_D19
                 ,  G_D20
                 ,  G_D21
                 ,  G_D22
                 ,  G_D23
                 ,  G_D24
                 ,  G_D25
                 ,  G_D26
                 ,  G_D27
                 ,  G_D28
                 ,  G_D29
                 ,  G_D30
                 ,  G_D31
                 ,  G_SUM
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
                 ,  V01.ACC_CD
                 ,  V01.G_D01
                 ,  V01.G_D02
                 ,  V01.G_D03
                 ,  V01.G_D04
                 ,  V01.G_D05
                 ,  V01.G_D06
                 ,  V01.G_D07
                 ,  V01.G_D08
                 ,  V01.G_D09
                 ,  V01.G_D10
                 ,  V01.G_D11
                 ,  V01.G_D12
                 ,  V01.G_D13
                 ,  V01.G_D14
                 ,  V01.G_D15
                 ,  V01.G_D16
                 ,  V01.G_D17
                 ,  V01.G_D18
                 ,  V01.G_D19
                 ,  V01.G_D20
                 ,  V01.G_D21
                 ,  V01.G_D22
                 ,  V01.G_D23
                 ,  V01.G_D24
                 ,  V01.G_D25
                 ,  V01.G_D26
                 ,  V01.G_D27
                 ,  V01.G_D28
                 ,  V01.G_D29
                 ,  V01.G_D30
                 ,  V01.G_D31
                 ,  (
                        V01.G_D01+V01.G_D02+V01.G_D03+V01.G_D04+V01.G_D05+V01.G_D06+V01.G_D07+V01.G_D08+V01.G_D09+V01.G_D10+
                        V01.G_D11+V01.G_D12+V01.G_D13+V01.G_D14+V01.G_D15+V01.G_D16+V01.G_D17+V01.G_D18+V01.G_D19+V01.G_D20+
                        V01.G_D21+V01.G_D22+V01.G_D23+V01.G_D24+V01.G_D25+V01.G_D26+V01.G_D27+V01.G_D28+V01.G_D29+V01.G_D30+V01.G_D31
                    )
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
