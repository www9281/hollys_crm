--------------------------------------------------------
--  DDL for Procedure PRMT_ITEM_POP_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."PRMT_ITEM_POP_SELECT" (
-- ==========================================================================================
-- Author		:	권혁민
-- Create date	:	2017-11-16
-- Description	:	프로모션 상품목록 조회(팝업)
-- Test			:	exec PRMT_ITEM_POP_SELECT '002'
-- ==========================================================================================
        N_BRAND_CD      IN   VARCHAR2,
        N_L_CLASS_CD    IN   VARCHAR2,
		N_M_CLASS_CD    IN   VARCHAR2,
		N_S_CLASS_CD    IN   VARCHAR2,
		N_D_CLASS_CD    IN   VARCHAR2,
		N_SET_DIV       IN   VARCHAR2,
		N_ITEM_NM       IN   VARCHAR2,
		N_ITEM_CD       IN   VARCHAR2,
		N_DC_YN         IN   VARCHAR2,
        O_CURSOR        OUT  SYS_REFCURSOR
) AS 
BEGIN  
        OPEN        O_CURSOR  FOR
        SELECT A.* 
        FROM (
                SELECT      A.ITEM_CD  AS ITEM_CD
                            , A.ITEM_NM AS ITEM_NM
                            , A.SALE_PRC AS REGULAR_PRC
                            , (CASE WHEN A.SALE_VAT_YN IS NULL THEN ''
                                    WHEN A.SALE_VAT_YN = 'Y' THEN '과세'
                                    ELSE '면세'
                               END
                            ) AS SALE_VAT_YN
                            , (CASE WHEN A.ORD_SALE_DIV = '2' THEN '주문/판매용'
                                    ELSE '판매용'
                               END
                            ) AS ORD_SALE_DIV
                            , (CASE WHEN A.HOLLYS_CON_YN IS NULL THEN ''
                                    WHEN A.HOLLYS_CON_YN = 'Y' THEN 'Y'
                                    ELSE 'N'
                               END
                            ) AS HOLLYS_CON_YN
                            , (CASE WHEN A.SET_DIV IS NULL THEN ''
                                    WHEN A.SET_DIV = '1' THEN '세트상품'
                                    ELSE '일반상품'
                               END
                            ) AS SET_DIV
                            ,ROW_NUMBER() OVER(PARTITION BY A.ITEM_CD ORDER BY A.ORD_SALE_DIV) AS ITEM_SEQ_R
                FROM        ITEM A
                JOIN        ITEM_CHAIN B
                ON          A.ITEM_CD = B.ITEM_CD
                WHERE       (A.ORD_SALE_DIV = '2' OR A.ORD_SALE_DIV = '3')
                AND         (TRIM(N_BRAND_CD) IS NULL OR B.BRAND_CD = N_BRAND_CD)
                AND         A.USE_YN = 'Y'
                AND         (TRIM(N_L_CLASS_CD) IS NULL OR A.L_CLASS_CD = N_L_CLASS_CD)
                AND         (TRIM(N_M_CLASS_CD) IS NULL OR A.M_CLASS_CD = N_M_CLASS_CD)
                AND         (TRIM(N_S_CLASS_CD) IS NULL OR A.S_CLASS_CD = N_S_CLASS_CD)
                AND         (TRIM(N_D_CLASS_CD) IS NULL OR A.D_CLASS_CD = N_D_CLASS_CD)
                AND         (N_SET_DIV = '' OR N_SET_DIV IS NULL OR N_SET_DIV = A.SET_DIV)
                AND         (TRIM(N_ITEM_NM) IS NULL OR A.ITEM_NM LIKE '%' || N_ITEM_NM || '%')
                AND         (TRIM(N_ITEM_CD) IS NULL OR A.ITEM_CD = N_ITEM_CD)
                AND         (N_DC_YN = '' OR N_DC_YN IS NULL OR N_DC_YN = A.DC_YN)     
        ) A
        WHERE ITEM_SEQ_R = '1'
        ORDER BY 
                    A.ITEM_NM ASC;
END PRMT_ITEM_POP_SELECT;

/
