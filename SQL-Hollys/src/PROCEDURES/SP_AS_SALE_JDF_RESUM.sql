--------------------------------------------------------
--  DDL for Procedure SP_AS_SALE_JDF_RESUM
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_AS_SALE_JDF_RESUM" 
(
  prv_comp_cd      IN  VARCHAR2,    -- 회사코드
  prv_fr_sale_dt   IN  VARCHAR2,
  prv_to_sale_dt   IN  VARCHAR2,
  psr_return_cd   OUT  NUMBER,      -- 메세지코드
  psr_msg         OUT  STRING       -- 메세지
) IS
--------------------------------------------------------------------------------
--  Procedure Name   : SP_AS_SALE_JDF_RESUM
--  Description      : SALE_JDF 테이블 재집계 처리
--  Ref. Table       : SALE_DT, SALE_JDF
--------------------------------------------------------------------------------
--  Create Date      : 2013-06-14
--  Modify Date      : 2013-06-14 신규 생성
--------------------------------------------------------------------------------
    liv_msg_code    NUMBER(9)  := 0;
    lsv_msg_text    VARCHAR2(500);

    lnv_sale_qty    DSTOCK.SALE_QTY%TYPE ;
    lnv_sale_amt    NUMBER(12,2)  ;

    ERR_HANDLER     EXCEPTION;
BEGIN
    liv_msg_code    := 0;
    lsv_msg_text    := ' ';

    BEGIN
        DELETE
        FROM    SALE_JDF
        WHERE   COMP_CD = prv_comp_cd
        AND     SALE_DT BETWEEN prv_fr_sale_dt AND prv_to_sale_dt;

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
             NULL;
    END;

    FOR S IN   (
                SELECT  A.COMP_CD, A.BRAND_CD, A.SALE_DT, B.STOR_TP, A.STOR_CD, 
                        A.FREE_DIV, A.ITEM_CD, A.SALE_PRC, A.SALE_QTY
                FROM    SALE_DT A
                       ,STORE   B
                WHERE   A.COMP_CD   = B.COMP_CD
                AND     A.BRAND_CD  = B.BRAND_CD
                AND     A.STOR_CD   = B.STOR_CD
                AND     A.GIFT_DIV  = '0'
                AND     A.COMP_CD   = prv_comp_cd
                AND     A.SALE_DT   BETWEEN prv_fr_sale_dt AND prv_to_sale_dt
                AND    (A.SALE_QTY <> 0 OR A.SALE_AMT <> 0)
               )
    LOOP
        FOR R IN   
           (
            SELECT  ITEM_CHK,
                    ITEM_CD,
                    ROW_NUMBER() OVER (ORDER BY ITEM_CHK, ITEM_CD) SEQ,
                    RCP_QTY,
                    SALE_UNIT_QTY,
                    SALE_PRC,
                    COST
            FROM   (
                    WITH S_RECIPE AS
                       (
                        SELECT  A.RCP_ITEM_CD          ITEM_CD,
                                NVL(A.RCP_QTY,0)       RCP_QTY,
                                NVL(B.SALE_UNIT_QTY,1) SALE_UNIT_QTY,
                                B.SALE_PRC,
                                B.COST
                        FROM    RECIPE_BRAND A,
                                ITEM_CHAIN   B
                        WHERE   B.COMP_CD   = S.COMP_CD
                        AND     B.BRAND_CD  = S.BRAND_CD
                        AND     B.STOR_TP   = S.STOR_TP
                        AND     A.COMP_CD   = B.COMP_CD
                        AND     A.BRAND_CD  = B.BRAND_CD
                        AND     A.ITEM_CD   = B.ITEM_CD
                        AND     A.RCP_DIV   = '1'
                       )
                        SELECT  '1' ITEM_CHK,
                                A.ITEM_CD,
                                NVL(A.RCP_QTY,0) RCP_QTY,
                                NVL(A.SALE_UNIT_QTY,1) SALE_UNIT_QTY,
                                CASE WHEN B.SALE_PRC IS NULL THEN A.SALE_PRC ELSE B.SALE_PRC END SALE_PRC,
                                CASE WHEN B.COST IS NULL     THEN A.COST     ELSE B.COST     END COST
                        FROM    S_RECIPE A,
                               (
                                SELECT  ITEM_CD,
                                        MAX(SALE_PRC) KEEP (DENSE_RANK LAST ORDER BY START_DT) SALE_PRC,
                                        MAX(COST) KEEP (DENSE_RANK LAST ORDER BY START_DT) COST
                                FROM    ITEM_CHAIN_HIS H
                                WHERE   COMP_CD   = S.COMP_CD
                                AND     BRAND_CD  = S.BRAND_CD
                                AND     STOR_TP   = S.STOR_TP
                                AND     START_DT <= S.SALE_DT
                                AND     ITEM_CD  IN(SELECT ITEM_CD FROM S_RECIPE)
                                AND     USE_YN    = 'Y'
                                GROUP BY 
                                        ITEM_CD
                               ) B
                        WHERE   A.ITEM_CD = B.ITEM_CD (+)
                        UNION ALL
                        SELECT  '2' ITEM_CHK,
                                B.ITEM_CD,
                                1 RCP_QTY,
                                NVL(B.SALE_UNIT_QTY,1) SALE_UNIT_QTY,
                                S.SALE_PRC SALE_PRC,
                                CASE WHEN C.COST IS NULL THEN B.COST ELSE C.COST END COST
                        FROM    ITEM_CHAIN B,
                               (SELECT  ITEM_CD,
                                        MAX(SALE_PRC) KEEP (DENSE_RANK LAST ORDER BY START_DT) SALE_PRC,
                                        MAX(COST)     KEEP (DENSE_RANK LAST ORDER BY START_DT) COST
                                FROM    ITEM_CHAIN_HIS H
                                WHERE   COMP_CD   = S.COMP_CD
                                AND     BRAND_CD  = S.BRAND_CD
                                AND     STOR_TP   = S.STOR_TP
                                AND     START_DT <= S.SALE_DT
                                AND     ITEM_CD   = S.ITEM_CD
                                AND     USE_YN    = 'Y'
                                GROUP BY 
                                        ITEM_CD
                               ) C
                        WHERE   B.COMP_CD    = S.COMP_CD
                        AND     B.BRAND_CD   = S.BRAND_CD
                        AND     B.STOR_TP    = S.STOR_TP
                        AND     B.ITEM_CD    = S.ITEM_CD
                        AND     C.ITEM_CD(+) = B.ITEM_CD
           ) A
       )
        LOOP
            IF R.ITEM_CHK = '1' OR (R.ITEM_CHK = '2' AND R.SEQ = 1) THEN
                lnv_sale_qty  := R.RCP_QTY  * R.SALE_UNIT_QTY * NVL(S.SALE_QTY, 0);
                lnv_sale_amt  := R.SALE_PRC * NVL(S.SALE_QTY, 0);

                IF S.FREE_DIV NOT IN('0', '1') THEN
                    BEGIN
                        UPDATE  SALE_JDF
                        SET     SALE_QTY = SALE_QTY + S.sale_qty
                        WHERE   COMP_CD  = S.COMP_CD
                        AND     SALE_DT  = S.SALE_DT
                        AND     BRAND_CD = S.BRAND_CD
                        AND     STOR_CD  = S.STOR_CD
                        AND     ITEM_CD  = R.ITEM_CD
                        AND     FREE_DIV = S.FREE_DIV;

                        IF SQL%NOTFOUND THEN
                            INSERT INTO SALE_JDF
                               (
                                COMP_CD,
                                SALE_DT,
                                BRAND_CD,
                                STOR_CD,
                                ITEM_CD,
                                FREE_DIV,
                                SALE_QTY
                               )
                            VALUES 
                               (
                                S.COMP_CD,
                                S.SALE_DT,
                                S.BRAND_CD,
                                S.STOR_CD,
                                R.ITEM_CD,
                                S.FREE_DIV,
                                S.SALE_QTY
                               );
                        END IF;
                    EXCEPTION
                        WHEN OTHERS THEN
                            liv_msg_code := SQLCODE;
                            lsv_msg_text := 'SALE_JDF:' || SQLERRM;

                            RAISE ERR_HANDLER;
                    END;
                END IF;
            END IF;
        END LOOP;
    END LOOP;

    psr_return_cd  := liv_msg_code;
    psr_msg        := lsv_msg_text;

EXCEPTION
    WHEN ERR_HANDLER THEN
        psr_return_cd := liv_msg_code;
        psr_msg       := lsv_msg_text;
    WHEN OTHERS THEN
        psr_return_cd := SQLCODE;
        psr_msg       := SQLERRM;
END;

/
