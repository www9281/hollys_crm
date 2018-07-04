--------------------------------------------------------
--  DDL for Procedure SP_CLEAR_DAILY_SALES
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_CLEAR_DAILY_SALES" 
    (
        p_comp_cd      IN SALE_HD.BRAND_CD % TYPE,
        p_brand_cd     IN SALE_HD.BRAND_CD % TYPE,
        p_stor_cd      IN SALE_HD.STOR_CD  % TYPE,
        p_sale_dt      IN SALE_HD.SALE_DT  % TYPE,
        psr_return_cd OUT NUMBER,
        -- 메세지코드
        psr_msg OUT STRING -- 메세지
    )
    /*=======================================================================*/
    --  Project Name    :  EnZIN POS Global
    --  Procedure Name  :  SP_CLEAR_DAILY_SALES
    --  Author          :  JRLIM
    --  DATE            :  2012/04/19
    --  Remark          :  특정 점포,일자의 영수증 데이터 일괄 삭제 및 관련 집계 테이블 수정
    /*=======================================================================*/
    IS
        liv_msg_code NUMBER (9) := 0;
        lsv_msg_text VARCHAR2 (500);
        --
        ERR_HANDLER EXCEPTION;
        --
        BEGIN
            liv_msg_code := 0;
            lsv_msg_text := ' ';
            -- BEGIN 일별 데이터 삭제 ************
            -- 점포 일 시간대별
            DELETE
              FROM SALE_JTO
             WHERE COMP_CD  = p_comp_cd  AND
                   BRAND_CD = p_brand_cd AND
                   STOR_CD  = p_stor_cd  AND
                   SALE_DT  = p_sale_dt;
            -- 점포 일 고객(내외국인,성별,연령대) 매출
            DELETE
              FROM SALE_JDO
             WHERE COMP_CD  = p_comp_cd  AND
                   BRAND_CD = p_brand_cd AND
                   STOR_CD  = p_stor_cd  AND
                   SALE_DT  = p_sale_dt;
            -- 점포 일 매출 집계
            DELETE
              FROM SALE_JDS
             WHERE COMP_CD  = p_comp_cd  AND
                   BRAND_CD = p_brand_cd AND
                   STOR_CD  = p_stor_cd  AND
                   SALE_DT  = p_sale_dt;
            -- 점포 일 시간대, 고객 유형별 매출
            DELETE
              FROM SALE_JTS
             WHERE COMP_CD  = p_comp_cd  AND
                   BRAND_CD = p_brand_cd AND
                   STOR_CD  = p_stor_cd  AND
                   SALE_DT  = p_sale_dt;
            -- 점포 일 금액대별 매출
            DELETE
              FROM SALE_JDA
             WHERE COMP_CD  = p_comp_cd  AND
                   BRAND_CD = p_brand_cd AND
                   STOR_CD  = p_stor_cd  AND
                   SALE_DT  = p_sale_dt;
            -- 일 상품별 수불
            DELETE
              FROM DSTOCK
             WHERE COMP_CD  = p_comp_cd  AND
                   BRAND_CD = p_brand_cd AND
                   STOR_CD  = p_stor_cd  AND
                   PRC_DT   = p_sale_dt;
            -- 점포 일 상품별 무료/비매/시식 집계
            DELETE
              FROM SALE_JDF
             WHERE COMP_CD  = p_comp_cd  AND 
                   BRAND_CD = p_brand_cd AND
                   STOR_CD  = p_stor_cd  AND
                   SALE_DT  = p_sale_dt;
            -- 점포 일 상품별 매출(시간대 분할 집계)
            DELETE
              FROM SALE_ATM
             WHERE COMP_CD  = p_comp_cd  AND
                   BRAND_CD = p_brand_cd AND
                   STOR_CD  = p_stor_cd  AND
                   SALE_DT  = p_sale_dt;
            -- 점포 일 시간대,상품별 매출 집계
            DELETE
              FROM SALE_JTM
             WHERE COMP_CD  = p_comp_cd  AND
                   BRAND_CD = p_brand_cd AND
                   STOR_CD  = p_stor_cd  AND
                   SALE_DT  = p_sale_dt;
            -- 점포 일 상품별 매출 집계
            DELETE
              FROM SALE_JDM
             WHERE COMP_CD  = p_comp_cd  AND
                   BRAND_CD = p_brand_cd AND
                   STOR_CD  = p_stor_cd  AND
                   SALE_DT  = p_sale_dt;
            -- 점포 일 부가상품 일 매출 집계
            DELETE
              FROM SALE_JDI
             WHERE COMP_CD  = p_comp_cd  AND
                   BRAND_CD = p_brand_cd AND
                   STOR_CD  = p_stor_cd  AND
                   SALE_DT  = p_sale_dt;
            -- 점포 일 부가상품 일별 시간대별 매출 집계
            DELETE
              FROM SALE_JIM
             WHERE COMP_CD  = p_comp_cd  AND
                   BRAND_CD = p_brand_cd AND
                   STOR_CD  = p_stor_cd  AND
                   SALE_DT  = p_sale_dt;
            -- 점포 일 상품별 할인 집계
            DELETE
              FROM SALE_JDD
             WHERE COMP_CD  = p_comp_cd  AND
                   BRAND_CD = p_brand_cd AND
                   STOR_CD  = p_stor_cd  AND
                   SALE_DT  = p_sale_dt;
            -- 점포 일 할인 집계
            DELETE
              FROM SALE_SDC
             WHERE COMP_CD  = p_comp_cd  AND
                   BRAND_CD = p_brand_cd AND
                   STOR_CD  = p_stor_cd  AND
                   SALE_DT  = p_sale_dt;
            -- 점포 일 상품권 판매 집계
            DELETE
              FROM SALE_JDG
             WHERE COMP_CD  = p_comp_cd  AND
                   BRAND_CD = p_brand_cd AND
                   STOR_CD  = p_stor_cd  AND
                   SALE_DT  = p_sale_dt;
            -- 점포 일 결제수단별 매출
            DELETE
              FROM SALE_JDP
             WHERE COMP_CD  = p_comp_cd  AND
                   BRAND_CD = p_brand_cd AND
                   STOR_CD  = p_stor_cd  AND
                   SALE_DT  = p_sale_dt;
            -- 고객별 선불/후불 거래내역
            DELETE
              FROM C_CUST_TRAN_LIST
             WHERE COMP_CD  = p_comp_cd  AND
                   BRAND_CD = p_brand_cd AND
                   STOR_CD  = p_stor_cd  AND
                   SALE_DT  = p_sale_dt;
            -- 상품권 판매에 대한 결제 수단별 집계
            DELETE
              FROM SALE_JDP_GC
             WHERE COMP_CD  = p_comp_cd  AND
                   BRAND_CD = p_brand_cd AND
                   STOR_CD  = p_stor_cd  AND
                   SALE_DT  = p_sale_dt;
            -- 점포 일 카드 결제 집계
            DELETE
              FROM SALE_JDC
             WHERE COMP_CD  = p_comp_cd  AND
                   BRAND_CD = p_brand_cd AND
                   STOR_CD = p_stor_cd   AND
                   SALE_DT = p_sale_dt;
            -- 점포 일 포인트 결제 집계??
            DELETE
              FROM POINT_SUM
             WHERE COMP_CD  = p_comp_cd  AND
                   BRAND_CD = p_brand_cd AND
                   STOR_CD  = p_stor_cd  AND
                   SALE_DT  = p_sale_dt;
            -- 모바일 쿠폰 결제 TR
            DELETE
              FROM SALE_ST_MC
             WHERE COMP_CD  = p_comp_cd  AND
                   BRAND_CD = p_brand_cd AND
                   STOR_CD  = p_stor_cd  AND
                   SALE_DT  = p_sale_dt;
            -- 상품권 결제 집계 : 결제구분=40
            DELETE
              FROM SALE_JDH
             WHERE COMP_CD  = p_comp_cd  AND
                   BRAND_CD = p_brand_cd AND
                   STOR_CD  = p_stor_cd  AND
                   SALE_DT  = p_sale_dt;
            -- END 일별 데이터 삭제 ******
            -- BEGIN 월별 데이터 수정
                -- MSTOCK  : DSTOCK을 집계하여 갱신 -- 이월 항목 확인할 것.
                SP_REBUILDMSTOCK_BYSTORE(p_comp_cd, p_brand_cd, p_stor_cd, substr(p_sale_dt,1,6));
                -- SALE_JMI : SALE_JDI를 집계하여 갱신
                MERGE
                INTO SALE_JMI A
                    USING (SELECT
                               SUBSTR (SALE_DT, 1, 6) SALE_YM,
                               COMP_CD,
                               BRAND_CD,
                               STOR_CD,
                               ITEM_CD,
                               SUB_FG,
                               SUB_ITEM_CD,
                               SUM (SALE_QTY) SALE_QTY,
                               SUM (SALE_AMT) SALE_AMT,
                               SUM (DC_AMT) DC_AMT,
                               SUM (ENR_AMT) ENR_AMT,
                               SUM (GRD_AMT) GRD_AMT,
                               SUM (GRD_I_AMT) GRD_I_AMT,
                               SUM (VAT_I_AMT) VAT_I_AMT,
                               SUM (GRD_O_AMT) GRD_O_AMT,
                               SUM (VAT_O_AMT) VAT_O_AMT,
                               SUM (VAT_AMT) VAT_AMT,
                               SUM (SVC_AMT) SVC_AMT,
                               SUM (SVC_VAT_AMT) SVC_VAT_AMT
                          FROM SALE_JDI
                         WHERE SALE_DT BETWEEN SUBSTR (p_sale_dt, 1, 6) || '01' AND SUBSTR (p_sale_dt, 1, 6) || '31' AND
                               COMP_CD  = p_comp_cd  AND 
                               BRAND_CD = P_BRAND_CD AND
                               STOR_CD  = P_STOR_CD
                           GROUP BY
                               SUBSTR (SALE_DT, 1, 6),
                               COMP_CD,
                               BRAND_CD,
                               STOR_CD,
                               ITEM_CD,
                               SUB_FG,
                               SUB_ITEM_CD) B
                    ON
                    (
                        A.COMP_CD  = B.COMP_CD  AND
                        A.BRAND_CD = B.BRAND_CD AND
                        A.STOR_CD  = B.STOR_CD  AND
                        A.SALE_YM  = B.SALE_YM  AND
                        A.SALE_YM  = SUBSTR (p_sale_dt, 1, 6) AND
                        A.ITEM_CD  = B.ITEM_CD  AND
                        A.SUB_FG   = B.SUB_FG   AND
                        A.SUB_ITEM_CD = B.SUB_ITEM_CD
                    )
                    WHEN MATCHED THEN
                        UPDATE SET
                                A.SALE_QTY  = B.SALE_QTY,
                                A.SALE_AMT  = B.SALE_AMT,
                                A.DC_AMT    = B.DC_AMT,
                                A.ENR_AMT   = B.ENR_AMT,
                                A.GRD_AMT   = B.GRD_AMT,
                                A.GRD_I_AMT = B.GRD_I_AMT,
                                A.VAT_I_AMT = B.VAT_I_AMT,
                                A.GRD_O_AMT = B.GRD_O_AMT,
                                A.VAT_O_AMT = B.VAT_O_AMT,
                                A.VAT_AMT   = B.VAT_AMT,
                                A.SVC_AMT   = B.SVC_AMT,
                                A.SVC_VAT_AMT = B.SVC_VAT_AMT 
                     WHEN NOT MATCHED THEN 
                         INSERT
                        (
                            COMP_CD,
                            SALE_YM,
                            BRAND_CD,
                            STOR_CD,
                            ITEM_CD,
                            SUB_FG,
                            SUB_ITEM_CD,
                            SALE_QTY,
                            SALE_AMT,
                            DC_AMT,
                            ENR_AMT,
                            GRD_AMT,
                            GRD_I_AMT,
                            VAT_I_AMT,
                            GRD_O_AMT,
                            VAT_O_AMT,
                            VAT_AMT,
                            SVC_AMT,
                            SVC_VAT_AMT
                        )
                        VALUES
                        (
                            B.COMP_CD, 
                            SUBSTR (p_sale_dt, 1, 6),
                            B.BRAND_CD,
                            B.STOR_CD,
                            B.ITEM_CD,
                            B.SUB_FG,
                            B.SUB_ITEM_CD,
                            B.SALE_QTY,
                            B.SALE_AMT,
                            B.DC_AMT,
                            B.ENR_AMT,
                            B.GRD_AMT,
                            B.GRD_I_AMT,
                            B.VAT_I_AMT,
                            B.GRD_O_AMT,
                            B.VAT_O_AMT,
                            B.VAT_AMT,
                            B.SVC_AMT,
                            B.SVC_VAT_AMT
                        );
                -- SALE_JMM : SALE_JDM을 집계하여 갱신
                MERGE
                INTO SALE_JMM A
                    USING (SELECT
                               SUBSTR (SALE_DT, 1, 6) SALE_YM,
                               COMP_CD,
                               BRAND_CD,
                               STOR_CD,
                               ITEM_CD,
                               SUM (SALE_QTY) SALE_QTY,
                               SUM (SALE_AMT) SALE_AMT,
                               SUM (DC_AMT) DC_AMT,
                               SUM (ENR_AMT) ENR_AMT,
                               SUM (GRD_AMT) GRD_AMT,
                               SUM (GRD_I_AMT) GRD_I_AMT,
                               SUM (VAT_I_AMT) VAT_I_AMT,
                               SUM (GRD_O_AMT) GRD_O_AMT,
                               SUM (VAT_O_AMT) VAT_O_AMT,
                               SUM (VAT_AMT) VAT_AMT,
                               SUM (SVC_AMT) SVC_AMT,
                               SUM (SVC_VAT_AMT) SVC_VAT_AMT
                           FROM SALE_JDM
                           WHERE
                               SALE_DT BETWEEN SUBSTR (p_sale_dt, 1, 6) || '01' AND SUBSTR (p_sale_dt, 1, 6) || '31' AND
                               COMP_CD  = p_comp_cd  AND 
                               BRAND_CD = P_BRAND_CD AND
                               STOR_CD  = P_STOR_CD
                           GROUP BY
                               SUBSTR (SALE_DT, 1, 6),
                               COMP_CD,
                               BRAND_CD,
                               STOR_CD,
                               ITEM_CD
                               ) B
                    ON
                    (
                        A.COMP_CD  = B.COMP_CD  AND 
                        A.BRAND_CD = B.BRAND_CD AND
                        A.STOR_CD  = B.STOR_CD  AND
                        A.SALE_YM  = B.SALE_YM  AND
                        A.SALE_YM  = SUBSTR (p_sale_dt, 1, 6) AND
                        A.ITEM_CD  = B.ITEM_CD 
                    )
                    WHEN MATCHED THEN
                        UPDATE SET
                                A.SALE_QTY  = B.SALE_QTY,
                                A.SALE_AMT  = B.SALE_AMT,
                                A.DC_AMT    = B.DC_AMT,
                                A.ENR_AMT   = B.ENR_AMT,
                                A.GRD_AMT   = B.GRD_AMT,
                                A.GRD_I_AMT = B.GRD_I_AMT,
                                A.VAT_I_AMT = B.VAT_I_AMT,
                                A.GRD_O_AMT = B.GRD_O_AMT,
                                A.VAT_O_AMT = B.VAT_O_AMT,
                                A.VAT_AMT   = B.VAT_AMT,
                                A.SVC_AMT   = B.SVC_AMT,
                                A.SVC_VAT_AMT = B.SVC_VAT_AMT 
                     WHEN NOT MATCHED THEN 
                         INSERT
                        (
                            COMP_CD,
                            SALE_YM,
                            BRAND_CD,
                            STOR_CD,
                            ITEM_CD,
                            SALE_QTY,
                            SALE_AMT,
                            DC_AMT,
                            ENR_AMT,
                            GRD_AMT,
                            GRD_I_AMT,
                            VAT_I_AMT,
                            GRD_O_AMT,
                            VAT_O_AMT,
                            VAT_AMT,
                            SVC_AMT,
                            SVC_VAT_AMT
                        )
                        VALUES
                        (
                            B.COMP_CD,
                            SUBSTR (p_sale_dt, 1, 6),
                            B.BRAND_CD,
                            B.STOR_CD,
                            B.ITEM_CD,
                            B.SALE_QTY,
                            B.SALE_AMT,
                            B.DC_AMT,
                            B.ENR_AMT,
                            B.GRD_AMT,
                            B.GRD_I_AMT,
                            B.VAT_I_AMT,
                            B.GRD_O_AMT,
                            B.VAT_O_AMT,
                            B.VAT_AMT,
                            B.SVC_AMT,
                            B.SVC_VAT_AMT
                        );
                -- SALE_JMO: SALE_JDO를 집계하여 갱신

            -- END 월별 데이터 수정
            -- BEGIN 일일 TR 데이터 삭제
            DELETE FROM SALE_HD
            WHERE  COMP_CD  = p_comp_cd  AND 
                   BRAND_CD = p_brand_cd AND
                   STOR_CD = p_stor_cd   AND
                   SALE_DT = p_sale_dt;
            DELETE FROM SALE_DT
            WHERE  COMP_CD  = p_comp_cd  AND 
                   BRAND_CD = p_brand_cd AND
                   STOR_CD = p_stor_cd   AND
                   SALE_DT = p_sale_dt;
            DELETE FROM SALE_ST
            WHERE  COMP_CD  = p_comp_cd  AND 
                   BRAND_CD = p_brand_cd AND
                   STOR_CD = p_stor_cd   AND
                   SALE_DT = p_sale_dt;
            DELETE FROM SALE_CL
            WHERE  COMP_CD  = p_comp_cd  AND 
                   BRAND_CD = p_brand_cd AND
                   STOR_CD = p_stor_cd   AND
                   SALE_DT = p_sale_dt;

            -- END 일일 TR 데이터 삭제
            --
            psr_return_cd := liv_msg_code;
            psr_msg := lsv_msg_text;
        EXCEPTION WHEN ERR_HANDLER THEN
            psr_return_cd := liv_msg_code;
            psr_msg := lsv_msg_text;
        WHEN OTHERS THEN
            psr_return_cd := SQLCODE;
            psr_msg := SQLERRM;
        END;

/
