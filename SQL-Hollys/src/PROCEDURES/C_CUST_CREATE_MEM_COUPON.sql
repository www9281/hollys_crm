--------------------------------------------------------
--  DDL for Procedure C_CUST_CREATE_MEM_COUPON
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CUST_CREATE_MEM_COUPON" (
  P_CUST_ID IN VARCHAR2,
  O_RTN_CD  OUT  VARCHAR2
) IS
    v_sav_cnt NUMBER;
    v_sav_mlg NUMBER;
    v_tot_sav_mlg NUMBER;
    v_lvl_cd VARCHAR2(10);    
    
    v_result_cd VARCHAR2(7) := '1'; --성공
    v_prmt_id VARCHAR2(5); -- 프로모션 아이디(하드코딩,2(실버,골드),3(레드))
    v_publish_id VARCHAR2(10); -- 쿠폰발행번호
    v_random_cd VARCHAR2(20); -- 임시쿠폰난수(연번제외)
    v_temp_coupon_cd VARCHAR2(20); -- 임시쿠폰번호(연번제외) 
    v_coupon_cd VARCHAR2(20); -- 쿠폰번호 
    v_coupon_dt_type VARCHAR2(1); -- 쿠폰날짜 타입
    v_coupon_expire VARCHAR2(4); -- 발행일로부터 쿠폰사용기간
    v_prmt_dt_start VARCHAR2(8); -- 프로모션시작일자
    v_prmt_dt_end VARCHAR2(8); -- 프로모션종료일자
    v_coupon_start_dt VARCHAR2(8); -- 쿠폰유효기간시작일자 
    v_coupon_end_dt VARCHAR2(8); -- 쿠폰유효기간종료일자
    v_coupon_seq VARCHAR2(11); -- 쿠폰 시퀀스 
    v_coupon_his_seq NUMBER; -- 쿠폰 히스토리시퀀스
    v_cust_lvl_cd VARCHAR2(10); -- 고객등급
    
    NOT_USABLE_PRMT_DT EXCEPTION;       -- 프로모션 기간이 지났습니다.
    
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2018-01-23
    -- Description   :   회원 왕관 적립에 따른 쿠폰발행 
    -- ==========================================================================================
    
    ----------------------- 현재 가용왕관 계산하여 왕관 갯수 체크하여 쿠폰발행 ---------------------------
    BEGIN
      -- 현재 가용포인트 체크 
      SELECT  SUM(HIS.SAV_MLG - HIS.USE_MLG - HIS.LOS_MLG_UNUSE) INTO v_sav_cnt
      FROM    C_CUST              CST
            , C_CARD              CRD
            , C_CARD_SAV_USE_HIS  HIS
      WHERE   CST.COMP_CD  = CRD.COMP_CD
      AND     CST.CUST_ID  = CRD.CUST_ID
      AND     CRD.COMP_CD  = HIS.COMP_CD
      AND     CRD.CARD_ID  = HIS.CARD_ID
      AND     CRD.COMP_CD  = '016'
      AND     CRD.CUST_ID  = P_CUST_ID
      AND     HIS.SAV_MLG != HIS.USE_MLG
      AND     HIS.LOS_MLG_YN  = 'N';
      
      -- 현재 가용포인트가 12개 이상일 경우 12+1 쿠폰 발행
      IF v_sav_cnt >= 12 THEN
        
        -- TODO 쿠폰발행 (COUPON_CD 항목 검색하여 변경필요!!!!)
        SELECT LVL_CD
               INTO v_cust_lvl_cd
        FROM   C_CUST
        WHERE  CUST_ID = P_CUST_ID;    
        
        
        IF v_cust_lvl_cd = '103' THEN -- 레드일경우
            v_prmt_id := '3';
        ELSE                          -- 실버,골드일경우
            v_prmt_id := '2';
        END IF;
        
        -- 신규발행번호
        SELECT NVL(MAX(TO_NUMBER(PUBLISH_ID)),0) + 1 
               INTO v_publish_id
        FROM   PROMOTION_COUPON_PUBLISH;
        
        v_publish_id := LPAD(v_publish_id, 6, '0');
        
        SELECT COUPON_DT_TYPE
              ,COUPON_EXPIRE
              ,PRMT_DT_START
              ,PRMT_DT_END
        INTO   v_coupon_dt_type, v_coupon_expire, v_prmt_dt_start, v_prmt_dt_end
        FROM   PROMOTION
        WHERE  PRMT_ID = v_prmt_id;   -- 하드코딩 추후 확정필요.
        
        IF v_coupon_dt_type = '1' THEN
             IF v_prmt_dt_start <= TO_CHAR(SYSDATE,'YYYYMMDD') AND v_prmt_dt_end >= TO_CHAR(SYSDATE,'YYYYMMDD') THEN
                 v_coupon_start_dt := TO_CHAR(SYSDATE,'YYYYMMDD');
                 v_coupon_end_dt := TO_CHAR(SYSDATE + TO_NUMBER(v_coupon_expire),'YYYYMMDD');
             ELSE    
                 RAISE NOT_USABLE_PRMT_DT;
             END IF;
        ELSE
             v_coupon_start_dt := v_prmt_dt_start;
             v_coupon_end_dt := v_prmt_dt_end;
        END IF;
        
        -- 난수쿠폰번호 생성(Prefix(3)+랜덤번호(4자리)+년도(2자리)+월(2자리)+일(2자리)+랜덤번호(3자리)+발행번호(6자리))
        v_random_cd := '3' || TO_CHAR(ROUND(DBMS_RANDOM.VALUE(1,10)*1000)) || TO_CHAR(SYSDATE,'YY') || TO_CHAR(SYSDATE,'MM') || TO_CHAR(SYSDATE,'DD') || TO_CHAR(ROUND(DBMS_RANDOM.VALUE(1,10)*100));
       
        -- 쿠폰번호 중복 조회 
        SELECT MAX(A.COUPON_CD)
               INTO v_temp_coupon_cd
        FROM   PROMOTION_COUPON A
        JOIN   PROMOTION_COUPON_PUBLISH B
        ON     A.PUBLISH_ID = B.PUBLISH_ID
        WHERE  B.PRMT_ID = v_prmt_id
        AND    A.COUPON_CD LIKE v_random_cd || '%'
        AND    B.OWN_YN = 'Y'
        AND    B.PUBLISH_TYPE = 'C6501';
        
        v_temp_coupon_cd := SUBSTR(v_temp_coupon_cd, 1, 14);
        
        -- 생성한 난수가 이미 있을 경우 
        IF v_temp_coupon_cd IS NOT NULL THEN
           v_coupon_cd := TO_NUMBER(v_temp_coupon_cd) || v_publish_id;
        ELSE -- 없을경우
            v_coupon_cd := v_random_cd || v_publish_id;
        END IF;
        
        BEGIN
            -- 쿠폰 발행정보 생성
            INSERT INTO PROMOTION_COUPON_PUBLISH
            (       
                    PUBLISH_ID
                    ,PRMT_ID
                    ,PUBLISH_TYPE
                    ,OWN_YN
                    ,PUBLISH_COUNT
                    ,NOTES
                    ,INST_USER
                    ,INST_DT
                    ,UPD_USER
                    ,UPD_DT
           ) VALUES (
                    v_publish_id
                    ,v_prmt_id
                    ,'C6501'
                    ,'Y' 
                    ,NULL
                    ,'멤버십쿠폰12+1' || '_' || v_cust_lvl_cd               
                    ,'CRM'
                    ,SYSDATE
                    ,'CRM'
                    ,SYSDATE
           );
           
           SELECT COUPON_SEQ.NEXTVAL
           INTO v_coupon_seq
           FROM DUAL;
        
           INSERT INTO PROMOTION_COUPON
           (       COUPON_CD                           
                   ,PUBLISH_ID
                   ,COUPON_SEQ
                   ,CUST_ID
                   ,CARD_ID
                   ,TG_STOR_CD
                   ,STOR_CD
                   ,POS_NO
                   ,BILL_NO
                   ,POS_SEQ
                   ,POS_SALE_DT
                   ,COUPON_STATE
                   ,COUPON_IMG
                   ,START_DT
                   ,END_DT
                   ,USE_DT
                   ,DESTROY_DT
                   ,INST_USER
                   ,INST_DT
                   ,UPD_USER
                   ,UPD_DT
           ) VALUES (   
                   v_coupon_cd
                   ,v_publish_id
                   ,v_coupon_seq
                   ,P_CUST_ID
                   ,(
                        SELECT ENCRYPT(CARD_ID) 
                        FROM   C_CARD
                        WHERE  CUST_ID = P_CUST_ID
                        AND    USE_YN = 'Y'
                        AND    REP_CARD_YN = 'Y'
                    )
                   ,NULL
                   ,NULL
                   ,NULL
                   ,NULL
                   ,NULL
                   ,NULL
                   ,'P0303'
                   ,'P0405' || '_' || v_cust_lvl_cd
                   ,v_coupon_start_dt
                   ,v_coupon_end_dt
                   ,NULL
                   ,NULL
                   ,'CRM'
                   ,SYSDATE
                   ,'CRM'
                   ,SYSDATE
           );
           
           EXCEPTION
                WHEN OTHERS THEN 
                O_RTN_CD := '504'; -- 쿠폰발급 도중 문제가 생겼습니다.
                dbms_output.put_line(SQLERRM);
           
       END;
       
       BEGIN
            -- 쿠폰히스토리 기록
            SELECT COUPON_HIS_SEQ.NEXTVAL
            INTO v_coupon_his_seq
            FROM DUAL;

            -- 쿠폰 발행 기록 히스토리 적용
            INSERT INTO PROMOTION_COUPON_HIS
            (       
                    COUPON_CD
                    ,COUPON_HIS_SEQ
                    ,PUBLISH_ID
                    ,COUPON_STATE
                    ,START_DT
                    ,END_DT
                    ,USE_DT
                    ,DESTROY_DT
                    ,GROUP_ID_HIS
                    ,CUST_ID
                    ,TO_CUST_ID
                    ,FROM_CUST_ID
                    ,MOBILE
                    ,RECEPTION_MOBILE
                    ,POS_NO
                    ,BILL_NO
                    ,POS_SEQ
                    ,POS_SALE_DT
                    ,STOR_CD
                    ,PUB_STOR_CD
                    ,ITEM_CD
                    ,COUPON_IMG
                    ,INST_USER
                    ,INST_DT
            ) 
            SELECT	A.COUPON_CD  
                    ,v_coupon_his_seq
                    ,A.PUBLISH_ID
                    ,A.COUPON_STATE
                    ,A.START_DT
                    ,A.END_DT
                    ,A.USE_DT
                    ,A.DESTROY_DT
                    ,NULL
                    ,A.CUST_ID
                    ,NULL
                    ,NULL
                    ,(CASE WHEN A.CUST_ID IS NOT NULL THEN (SELECT MOBILE FROM C_CUST WHERE CUST_ID = A.CUST_ID)
                           ELSE NULL
                      END
                    )
                    ,NULL
                    ,NULL
                    ,NULL
                    ,NULL
                    ,NULL
                    ,NULL
                    ,NULL
                    ,NULL
                    ,A.COUPON_IMG
                    ,'CRM'
                    ,SYSDATE
             FROM	PROMOTION_COUPON A
             JOIN   PROMOTION_COUPON_PUBLISH B
             ON     A.PUBLISH_ID = B.PUBLISH_ID
             WHERE	A.COUPON_CD = v_coupon_cd;

             EXCEPTION
                WHEN OTHERS THEN 
                O_RTN_CD := '506'; -- 쿠폰정보기록 도중 문제가 생겼습니다.
                dbms_output.put_line(SQLERRM); 
        END;
        
        -- 왕관 12개당 1개씩 발행
        FOR MYREC IN (
                        SELECT  HIS.COMP_CD
                              , HIS.CARD_ID
                              , HIS.USE_DT
                              , HIS.USE_SEQ
                              , HIS.SAV_MLG - HIS.USE_MLG - HIS.LOS_MLG_UNUSE AS REM_MLG
                              , SUM(HIS.SAV_MLG - HIS.USE_MLG - HIS.LOS_MLG_UNUSE) OVER(ORDER BY USE_SEQ) AS REM_MLG_ACC
                              , SUM(HIS.SAV_MLG - HIS.USE_MLG - HIS.LOS_MLG_UNUSE) OVER() AS REM_MLG_TOT
                              , CRD.MEMB_DIV
                        FROM    C_CUST              CST
                              , C_CARD              CRD
                              , C_CARD_SAV_USE_HIS  HIS
                        WHERE   CST.COMP_CD  = CRD.COMP_CD
                        AND     CST.CUST_ID  = CRD.CUST_ID
                        AND     CRD.COMP_CD  = HIS.COMP_CD
                        AND     CRD.CARD_ID  = HIS.CARD_ID
                        AND     CRD.COMP_CD  = '016'
                        AND     CRD.CUST_ID  = P_CUST_ID
                        AND     HIS.SAV_MLG != HIS.USE_MLG
                        AND     HIS.LOS_MLG_YN  = 'N'
                        ORDER BY USE_SEQ
                      )
         LOOP
            UPDATE  C_CARD_SAV_USE_HIS
            SET     USE_MLG     = USE_MLG + CASE WHEN MYREC.REM_MLG_ACC > 12 THEN 12 - (MYREC.REM_MLG_ACC - MYREC.REM_MLG) ELSE MYREC.REM_MLG END
                  , UPD_DT      = SYSDATE
                  , UPD_USER    = 'CRM BATCH'
                  , COUPON_CD   = v_coupon_cd
            WHERE   COMP_CD = MYREC.COMP_CD
            AND     CARD_ID = MYREC.CARD_ID
            AND     USE_DT  = MYREC.USE_DT
            AND     USE_SEQ = MYREC.USE_SEQ;
            
            -- 12개 단위로 사용처리
            EXIT WHEN MYREC.REM_MLG_ACC >= 12;
         END LOOP;
         
        -- 쿠폰 발행 이력 추가
        INSERT INTO C_CARD_SAV_COUPON_HIS (
          COMP_CD, CUST_ID, COUPON_SEQ, CRE_DT, USE_MLG
        ) VALUES (
          '016', P_CUST_ID, v_coupon_cd, TO_CHAR(SYSDATE, 'YYYYMMDD'), 12
        );
      END IF;
    END;
    ----------------------- 등급 변경일로부터 적립왕관 갯수 체크하여 등급 조정 ---------------------------
--    BEGIN
--      SELECT  
--        NVL(SUM(CASE WHEN CST.LVL_CHG_DT < HIS.INST_DT THEN HIS.SAV_MLG ELSE 0 END), 0)
--        INTO v_tot_sav_mlg
--      FROM    C_CUST              CST
--            , C_CARD              CRD
--            , C_CARD_SAV_USE_HIS  HIS
--      WHERE   CST.COMP_CD  = CRD.COMP_CD
--        AND   CST.CUST_ID  = CRD.CUST_ID
--        AND   CRD.COMP_CD  = HIS.COMP_CD
--        AND   CRD.CARD_ID  = HIS.CARD_ID
--        AND   CRD.COMP_CD  = '016'
--        AND   CRD.CUST_ID  = P_CUST_ID
--        AND   HIS.LOS_MLG_YN  = 'N';
--      
--      FOR CUST IN (
--                    SELECT
--                      A.LVL_CD
--                      ,A.LVL_CHG_DT
--                      ,A.DEGRADE_YN
--                      ,A.LVL_CHG_DT_BACK
--                      ,B.LVL_RANK
--                      ,B.LVL_STD_STR
--                      ,B.LVL_STD_END
--                    FROM C_CUST A, C_CUST_LVL B
--                    WHERE A.CUST_ID = P_CUST_ID
--                      AND A.USE_YN = 'Y'
--                      AND A.LVL_CD = B.LVL_CD
--                      AND A.LVL_CD <> '000'
--                  )
--      LOOP
--        IF (v_tot_sav_mlg + CUST.LVL_STD_STR ) >= CUST.LVL_STD_END THEN
--          UPDATE C_CUST SET
--            LVL_CD = (SELECT
--                        LVL_CD
--                      FROM C_CUST_LVL
--                      WHERE (v_tot_sav_mlg + CUST.LVL_STD_STR ) >= LVL_STD_STR
--                        AND (v_tot_sav_mlg + CUST.LVL_STD_STR ) < LVL_STD_END
--                        AND LVL_CD <> '000')
--            ,LVL_CHG_DT = SYSDATE
--            ,LVL_CHG_DT_BACK = LVL_CHG_DT
--            ,DEGRADE_YN = 'N'
--            ,UPD_DT = SYSDATE
--            ,UPD_USER = 'SYSTEM'
--          WHERE CUST_ID = P_CUST_ID;
--        END IF;
--      END LOOP;
--    END;
--    

    BEGIN
      SELECT  
        NVL(SUM(HIS.SAV_MLG), 0)
        INTO v_tot_sav_mlg
      FROM    C_CUST              CST
            , C_CARD              CRD
            , C_CARD_SAV_USE_HIS  HIS
      WHERE   CST.COMP_CD  = CRD.COMP_CD
        AND   CST.CUST_ID  = CRD.CUST_ID
        AND   CRD.COMP_CD  = HIS.COMP_CD
        AND   CRD.CARD_ID  = HIS.CARD_ID
        AND   CRD.COMP_CD  = '016'
        AND   CRD.CUST_ID  = P_CUST_ID
        AND   HIS.LOS_MLG_YN  = 'N';
      
      FOR CUST IN (
                    SELECT
                      A.LVL_CD
                      ,A.LVL_CHG_DT
                      ,A.DEGRADE_YN
                      ,A.LVL_CHG_DT_BACK
                      ,B.LVL_RANK
                      ,B.LVL_STD_STR
                      ,B.LVL_STD_END
                    FROM C_CUST A, C_CUST_LVL B
                    WHERE A.CUST_ID = P_CUST_ID
                      AND A.USE_YN = 'Y'
                      AND A.LVL_CD = B.LVL_CD
                  )
      LOOP
        SELECT MAX(LVL_CD) INTO v_lvl_cd FROM C_CUST_LVL
        WHERE LVL_STD_STR <= v_tot_sav_mlg
          AND LVL_STD_END > v_tot_sav_mlg
          AND LVL_CD <> '000'
          AND LVL_CD >= CUST.LVL_CD;
        
        IF v_lvl_cd IS NOT NULL AND v_lvl_cd <> CUST.LVL_CD THEN
          UPDATE C_CUST SET
            LVL_CD = v_lvl_cd
            ,LVL_CHG_DT = SYSDATE
            ,LVL_CHG_DT_BACK = LVL_CHG_DT
            ,DEGRADE_YN = 'N'
            ,UPD_DT = SYSDATE
            ,UPD_USER = 'SYSTEM'
          WHERE CUST_ID = P_CUST_ID;
        END IF;
      
      END LOOP;
    END;
    
    O_RTN_CD := v_result_cd;
    
    dbms_output.put_line('---OK');
    
EXCEPTION
         WHEN NOT_USABLE_PRMT_DT THEN
         O_RTN_CD  := '513'; -- 프로모션 기간이 지났습니다.
         dbms_output.put_line('ERROR1->'||SQLERRM);   
         WHEN OTHERS THEN
         O_RTN_CD  := '2';
         dbms_output.put_line('ERROR2->'||SQLERRM);
         
END C_CUST_CREATE_MEM_COUPON;

/
