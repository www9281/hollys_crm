--------------------------------------------------------
--  DDL for Procedure SP_ANAL1080L0
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_ANAL1080L0" 
/******************************************************************************
   NAME     :  SP_ITEM_CHAIN_REV_SAVE
   PURPOSE  :  레시피 아이템 버전 관리

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     SP_ITEM_CHAIN_REV_SAVE
      Sysdate:         
      Date and Time:   
      Username:         (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
(    
    p_comp_cd      IN   VARCHAR2,
    p_brand_cd     IN   VARCHAR2,
    p_user_id      IN   VARCHAR2,
    p_rev_ym       IN   VARCHAR2,
    p_rev_ver      IN   VARCHAR2,
    psr_return_cd  OUT  VARCHAR2,
    psr_msg        OUT  VARCHAR2
)
IS
    liv_rec_cnt     NUMBER(9) := 0;
    liv_msg_code    NUMBER(9) := 0;
    lsv_msg_text    VARCHAR2(200);

    ERR_HANDLER     EXCEPTION;
BEGIN
     liv_msg_code    := '0';
     lsv_msg_text    := '성공.';

    /* 레시피 버전 체크 */
    SELECT COUNT(*) INTO liv_rec_cnt
    FROM   ITEM_CHAIN_REV
    WHERE  COMP_CD  = p_comp_cd
    AND    REV_YM   = p_rev_ym
    AND    REV_VER  = p_rev_ver
    AND    BRAND_CD = p_brand_cd;

    IF( liv_rec_cnt = 0 ) THEN
        BEGIN
            INSERT INTO ITEM_CHAIN_REV (COMP_CD, REV_YM, REV_VER, BRAND_CD, STOR_TP, ITEM_CD, 
                                        B_SALE_PRC, B_COST, A_SALE_PRC, A_COST,
                                        INST_DT, INST_USER, UPD_DT, UPD_USER)
            SELECT  UNIQUE
                    IC.COMP_CD,
                    p_rev_ym,
                    p_rev_ver,
                    IC.BRAND_CD,
                    IC.STOR_TP, 
                    IC.ITEM_CD, 
                    IC.SALE_PRC, 
                    IC.COST, 
                    IC.SALE_PRC, 
                    IC.COST,
                    SYSDATE,
                    p_user_id,
                    SYSDATE,
                    p_user_id               
            FROM    ITEM_CHAIN        IC 
            WHERE   IC.COMP_CD  = p_comp_cd
            AND     IC.BRAND_CD = p_brand_cd
            AND     IC.USE_YN   = 'Y'
            AND     IC.RECIPE_DIV IN ('1', '2')
            AND     EXISTS(SELECT 1
                           FROM   RECIPE_BRAND_FOOD RBF
                           WHERE  RBF.COMP_CD   = IC.COMP_CD
                           AND    RBF.BRAND_CD  = IC.BRAND_CD
                           AND    RBF.P_ITEM_CD = IC.ITEM_CD
                           AND    RBF.USE_YN    = 'Y')
            UNION
            SELECT  UNIQUE
                    IC.COMP_CD,
                    p_rev_ym,
                    p_rev_ver,
                    IC.BRAND_CD,
                    IC.STOR_TP, 
                    IC.ITEM_CD, 
                    IC.SALE_PRC, 
                    IC.COST, 
                    IC.SALE_PRC, 
                    IC.COST,
                    SYSDATE,
                    p_user_id,
                    SYSDATE,
                    p_user_id               
            FROM    ITEM_CHAIN        IC 
            WHERE   IC.COMP_CD  = p_comp_cd
            AND     IC.BRAND_CD = p_brand_cd
            AND     IC.USE_YN   = 'Y'
            AND     IC.RECIPE_DIV IN ('1', '2')
            AND     EXISTS(SELECT 1
                           FROM   RECIPE_BRAND_FOOD RBF
                           WHERE  RBF.COMP_CD    = IC.COMP_CD
                           AND    RBF.BRAND_CD   = IC.BRAND_CD
                           AND    RBF.C_ITEM_CD  = IC.ITEM_CD
                           AND    RBF.P_ITEM_CD != ' '
                           AND    RBF.USE_YN     = 'Y');

            liv_msg_code := '0';
        EXCEPTION WHEN NO_DATA_FOUND THEN
            liv_msg_code := '-1403';
            lsv_msg_text := 'No Data Found';
        END;
    ELSE
        liv_msg_code := '-1';
        lsv_msg_text := 'Duplication';
    END IF;

    /* RETURN MESSAGE */
    psr_return_cd := liv_msg_code;
    psr_msg       := lsv_msg_text;

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
