--------------------------------------------------------
--  DDL for Procedure API_RCH_QR_ISSUE_CHECK
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."API_RCH_QR_ISSUE_CHECK" (
    P_PRMT_ID      IN  VARCHAR2,
    P_STOR_CD      IN  VARCHAR2,
    N_CUST_ID      IN  VARCHAR2,
    P_USE_DIV      IN  VARCHAR2,
    N_COUPON_SEQ   IN  VARCHAR2,
    N_COUPON_CD    IN  VARCHAR2,
    P_POS_NO       IN  VARCHAR2,
    P_BILL_NO      IN  VARCHAR2,
    P_POS_SALE_DT  IN  VARCHAR2,
    P_USER_ID      IN  VARCHAR2,
    O_COUPON_CD    OUT VARCHAR2,
    O_COUPON_SEQ   OUT VARCHAR2,
    O_START_DT     OUT VARCHAR2,
    O_END_DT       OUT VARCHAR2,
    O_QR_NO        OUT VARCHAR2,  
    O_RTN_CD       OUT VARCHAR2 
) AS  
    v_result_cd      VARCHAR2(7) := '1'; --성공

    -- 기준 발행 정보
    v_pivot_day_stand    NUMBER; v_pivot_day_member   NUMBER;
    v_pivot_month_stand  NUMBER; v_pivot_month_member NUMBER; 
    
    -- 비교 발행 정보
    v_com_day_stand    NUMBER; v_com_day_member   NUMBER;
    v_com_month_stand  NUMBER; v_com_month_member NUMBER;
    
    -- 일반변수
    v_rch_no VARCHAR(20);
    v_qr_cnt NUMBER;
    
    -- 오류
    OVER_DAY_ISSUE EXCEPTION;
    OVER_MONTH_ISSUE EXCEPTION;
    COMPLETE_RESEARCH EXCEPTION;
    NOT_FOUND_ISSUE_DATA EXCEPTION;
    
    -- 쿠폰관련 변수
    v_sub_prmt_id VARCHAR2(5); -- 서브프로모션 아이디
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
    v_prmt_use_div VARCHAR2(10); -- 프로모션 적용구분
    v_stor_limit VARCHAR2(1); -- 매장 제한
    v_print_target VARCHAR2(10); -- 출력대상
    v_coupon_his_seq NUMBER; -- 쿠폰 히스토리시퀀스
    NOT_USABLE_PRMT_DT EXCEPTION;
    
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2018-02-06
    -- Description   :   설문조사 QR발행 갯수 체크
    -- ==========================================================================================
    
    IF P_USE_DIV = '101' THEN
      ------------------------------------------ 발행 ----------------------------------------------
      
      --기준 :  [일별 일반 발행수] [일별 멤버 발행수] [월별 일반 설문수] [월별 멤버 설문수]
      -- 1. 매장의 발행, 설문 완료 기준 정보 조회
      SELECT
        NVL(MAX(B.DAY_STAND_ISSUE), 0), NVL(MAX(B.DAY_MEM_ISSUE), 0), NVL(MAX(B.MONTH_STAND_ISSUE), 0), NVL(MAX(B.MONTH_MEM_ISSUE), 0)
        INTO v_pivot_day_stand, v_pivot_day_member, v_pivot_month_stand, v_pivot_month_member
      FROM RCH_MASTER A, RCH_QR_MASTER B
      WHERE A.PROMOTION_ID = P_PRMT_ID
        AND A.RCH_NO = B.RCH_NO
        AND B.STOR_CD = P_STOR_CD;
     
      -- 2. 월별 설문 건수 비교
      SELECT
        NVL(MAX(SUM(B.MONTH_STAND_ISSUE)),0), NVL(MAX(SUM(B.MONTH_MEM_ISSUE)),0)
        INTO v_com_month_stand, v_com_month_member
      FROM RCH_MASTER A, RCH_QR_ISSUE B
      WHERE A.PROMOTION_ID = P_PRMT_ID
        AND A.RCH_NO = B.RCH_NO
        AND B.STOR_CD = P_STOR_CD
        AND TO_CHAR(B.ISSUE_DT, 'YYYYMM') = TO_CHAR(SYSDATE, 'YYYYMM')
      GROUP BY TO_CHAR(B.ISSUE_DT, 'YYYYMM'), B.STOR_CD;
      
      -- 2-1. 월별 설문 한도 초과
      IF N_CUST_ID IS NULL THEN
        IF v_pivot_month_stand <= v_com_month_stand THEN
          RAISE OVER_MONTH_ISSUE;
        END IF;
      ELSE
        IF v_pivot_month_member <= v_com_month_member THEN
          RAISE OVER_MONTH_ISSUE;
        END IF;
      END IF;
      
      -- 3. 일별 발행 건수 비교
      SELECT
        NVL(MAX(SUM(B.DAY_STAND_ISSUE)),0), NVL(MAX(SUM(B.DAY_MEM_ISSUE)),0)
        INTO v_com_day_stand, v_com_day_member
      FROM RCH_MASTER A, RCH_QR_ISSUE B
      WHERE A.PROMOTION_ID = P_PRMT_ID
        AND A.RCH_NO = B.RCH_NO
        AND B.STOR_CD = P_STOR_CD
        AND TO_CHAR(B.ISSUE_DT, 'YYYYMMDD') = TO_CHAR(SYSDATE, 'YYYYMMDD')
      GROUP BY TO_CHAR(B.ISSUE_DT, 'YYYYMMDD'), B.STOR_CD;
      
      IF N_CUST_ID IS NULL THEN
        IF v_pivot_day_stand <= v_com_day_stand THEN
          RAISE OVER_DAY_ISSUE;
        END IF;
      ELSE
        IF v_pivot_day_member <= v_com_day_member THEN
          RAISE OVER_DAY_ISSUE;
        END IF;
      END IF;
      
      -------------------- TODO. 응모번호 채번!!!
      -- 신규발행번호
      SELECT NVL(MAX(CAST(PUBLISH_ID AS NUMBER)),0) + 1 
           INTO v_publish_id
      FROM   PROMOTION_COUPON_PUBLISH;
    
      v_publish_id := LPAD(v_publish_id, 6, '0');
    
      SELECT SUB_PRMT_ID
             INTO v_sub_prmt_id
      FROM   PROMOTION
      WHERE  PRMT_ID = P_PRMT_ID;
    
      SELECT STOR_LIMIT
            ,COUPON_DT_TYPE
            ,COUPON_EXPIRE
            ,PRMT_DT_START
            ,PRMT_DT_END
            ,PRMT_USE_DIV                  
      INTO   v_stor_limit, v_coupon_dt_type, v_coupon_expire, v_prmt_dt_start, v_prmt_dt_end, v_prmt_use_div
      FROM   PROMOTION
      WHERE  PRMT_ID = v_sub_prmt_id;
    
      IF v_coupon_dt_type = '1' THEN
           IF  v_prmt_dt_start <= TO_CHAR(SYSDATE,'YYYYMMDD') AND v_prmt_dt_end >= TO_CHAR(SYSDATE,'YYYYMMDD') THEN
               v_coupon_start_dt := TO_CHAR(SYSDATE,'YYYYMMDD');
               v_coupon_end_dt := TO_CHAR(SYSDATE + TO_NUMBER(v_coupon_expire),'YYYYMMDD');
           ELSE    
               RAISE NOT_USABLE_PRMT_DT;
           END IF;
      ELSE
           v_coupon_start_dt := v_prmt_dt_start;
           v_coupon_end_dt := v_prmt_dt_end;
      END IF;
      
      O_START_DT := v_coupon_start_dt;  
      O_END_DT := v_coupon_end_dt;    
      
      --프로모션 쿠폰생성
      -- 난수쿠폰번호 생성(Prefix(5)+랜덤번호(4자리)+년도(2자리)+랜덤번호(3자리))
      v_random_cd := '5' || TO_CHAR(ROUND(DBMS_RANDOM.VALUE(1,10)*1000)) || TO_CHAR(SYSDATE,'YY') || TO_CHAR(ROUND(DBMS_RANDOM.VALUE(1,10)*100));
   
      -- 쿠폰번호 중복 조회 
      SELECT MAX(A.COUPON_CD)
             INTO v_temp_coupon_cd
      FROM   PROMOTION_COUPON A
      JOIN   PROMOTION_COUPON_PUBLISH B
      ON     A.PUBLISH_ID = B.PUBLISH_ID
      WHERE  B.PRMT_ID = v_sub_prmt_id
      AND    A.COUPON_CD LIKE v_random_cd || '%';
      
      v_temp_coupon_cd := SUBSTR(v_temp_coupon_cd, 1, 10);
        
      -- 생성한 난수가 이미 있을 경우 
      IF v_temp_coupon_cd IS NOT NULL THEN
         v_coupon_cd := TO_NUMBER(v_temp_coupon_cd) || v_publish_id;
      ELSE -- 없을경우
         v_coupon_cd := v_random_cd || v_publish_id;
      END IF; 
      
      O_COUPON_CD := v_coupon_cd;
      
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
                   ,v_sub_prmt_id
                   ,'C6502'
                   ,(CASE WHEN N_CUST_ID IS NOT NULL THEN 'Y'
                          ELSE 'N'
                     END
                   )
                   ,(CASE WHEN N_CUST_ID IS NOT NULL THEN NULL
                          ELSE '1'
                     END
                   )
                   ,'설문조사응모번호쿠폰'                    
                   ,P_USER_ID
                   ,SYSDATE
                   ,P_USER_ID
                   ,SYSDATE
          );
          
          SELECT COUPON_SEQ.NEXTVAL
          INTO O_COUPON_SEQ
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
                  ,O_COUPON_SEQ
                  ,NULL
                  ,NULL
                  ,(
                       SELECT CASE WHEN v_stor_limit = '0' THEN NULL
                                   WHEN v_stor_limit = '1' THEN P_STOR_CD
                                   ELSE NULL
                              END 
                       FROM   PROMOTION
                       WHERE  PRMT_ID = v_sub_prmt_id
                  )
                  ,NULL
                  ,NULL
                  ,NULL
                  ,NULL
                  ,NULL
                  ,'P0303'
                  ,NULL
                  ,v_coupon_start_dt
                  ,v_coupon_end_dt
                  ,NULL
                  ,NULL
                  ,P_USER_ID
                  ,SYSDATE
                  ,P_USER_ID
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
          SELECT  v_coupon_cd  
                  ,v_coupon_his_seq
                  ,v_publish_id
                  ,A.COUPON_STATE
                  ,A.START_DT
                  ,A.END_DT
                  ,NULL
                  ,NULL
                  ,NULL
                  ,(CASE WHEN A.CUST_ID IS NOT NULL THEN A.CUST_ID
                         ELSE NULL
                    END
                   )
                  ,NULL
                  ,NULL
                  ,(CASE WHEN A.CUST_ID IS NOT NULL THEN (SELECT MOBILE FROM C_CUST WHERE CUST_ID = A.CUST_ID)
                         ELSE NULL
                    END
                   )
                  ,NULL
                  ,P_POS_NO
                  ,P_BILL_NO
                  ,NULL
                  ,P_POS_SALE_DT
                  ,NULL
                  ,P_STOR_CD
                  ,NULL
                  ,NULL
                  ,P_USER_ID
                  ,SYSDATE
           FROM	   PROMOTION_COUPON A
           JOIN    PROMOTION_COUPON_PUBLISH B
           ON      A.PUBLISH_ID = B.PUBLISH_ID
           AND     B.PRMT_ID = v_sub_prmt_id
           WHERE   A.COUPON_CD = v_coupon_cd;
           
           EXCEPTION
              WHEN OTHERS THEN 
              O_RTN_CD := '506'; -- 쿠폰정보기록 도중 문제가 생겼습니다.
              dbms_output.put_line(SQLERRM); 
      END;       
      
      -- 4. QR코드 발행처리 (응모번호 채번후 실행필요)
      SELECT
        A.RCH_NO INTO v_rch_no
      FROM RCH_MASTER A
      WHERE A.PROMOTION_ID = P_PRMT_ID
        AND ROWNUM = 1;
      
      IF N_CUST_ID IS NULL THEN
        -- 4-1. 일반 회원 발행
        INSERT INTO RCH_QR_ISSUE (
          RCH_NO, RCH_QR_SEQ, ISSUE_DT, STOR_CD, DAY_STAND_ISSUE, QR_NO, CUST_ID
        ) VALUES (
          v_rch_no, SQ_RCH_QR_SEQ.NEXTVAL, SYSDATE, P_STOR_CD, 1, v_coupon_cd, N_CUST_ID
        );
      ELSE 
        -- 4-2. 멤버 발행
        INSERT INTO RCH_QR_ISSUE (
          RCH_NO, RCH_QR_SEQ, ISSUE_DT, STOR_CD, DAY_MEM_ISSUE, QR_NO, CUST_ID
        ) VALUES (
          v_rch_no, SQ_RCH_QR_SEQ.NEXTVAL, SYSDATE, P_STOR_CD, 1, v_coupon_cd, N_CUST_ID
        );
      END IF;
      
      O_QR_NO := v_coupon_cd;
      O_RTN_CD := v_result_cd;
      
    ELSIF P_USE_DIV = '102' THEN
      ------------------------------------------ 발행취소 ----------------------------------------------
      -- 1. 해당 응모번호로 설문조사 완료된 건이 있는지 조회
      SELECT
        NVL(SUM(MONTH_STAND_ISSUE + MONTH_MEM_ISSUE), 0)
        INTO v_qr_cnt
      FROM RCH_QR_ISSUE A
      WHERE QR_NO = N_COUPON_CD;
      
      IF v_qr_cnt > 0 THEN
        RAISE COMPLETE_RESEARCH;
      END IF;
      
      -- 2. 해당 응모번호로 영수증 발행된 건이 있는지 조회
      SELECT
        NVL(SUM(DAY_STAND_ISSUE + DAY_MEM_ISSUE), 0)
        INTO v_qr_cnt
      FROM RCH_QR_ISSUE A
      WHERE QR_NO = N_COUPON_CD;
      
      IF v_qr_cnt < 1 THEN
        RAISE NOT_FOUND_ISSUE_DATA;
      END IF;
      
      -- 3. 영수증 발행 정보 삭제
      DELETE FROM RCH_QR_ISSUE
      WHERE QR_NO = N_COUPON_CD;
      
      -- 4. 쿠폰 취소처리(권대리님 추가부분)
      UPDATE PROMOTION_COUPON
      SET    DESTROY_DT    = TO_CHAR(SYSDATE,'YYYYMMDD')
             ,COUPON_STATE = 'P0309' 
             ,UPD_USER     = P_USER_ID
             ,UPD_DT       = SYSDATE
      WHERE  COUPON_CD     = N_COUPON_CD
      AND    COUPON_SEQ    = N_COUPON_SEQ;
       
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
              SELECT  v_coupon_cd  
                      ,v_coupon_his_seq
                      ,v_publish_id
                      ,A.COUPON_STATE
                      ,A.START_DT
                      ,A.END_DT
                      ,A.USE_DT
                      ,A.DESTROY_DT
                      ,NULL
                      ,(CASE WHEN A.CUST_ID IS NOT NULL THEN A.CUST_ID
                             ELSE NULL
                       END
                      )
                      ,NULL
                      ,NULL
                      ,(CASE WHEN A.CUST_ID IS NOT NULL THEN (SELECT MOBILE FROM C_CUST WHERE CUST_ID = A.CUST_ID)
                             ELSE NULL
                       END
                      )
                      ,NULL
                      ,P_POS_NO
                      ,P_BILL_NO
                      ,NULL
                      ,P_POS_SALE_DT
                      ,A.STOR_CD
                      ,P_STOR_CD
                      ,NULL
                      ,NULL
                      ,P_USER_ID
                      ,SYSDATE
               FROM	  PROMOTION_COUPON A
               JOIN   PROMOTION_COUPON_PUBLISH B
               ON     A.PUBLISH_ID = B.PUBLISH_ID
               AND    B.PRMT_ID = v_sub_prmt_id
               WHERE  A.COUPON_CD = N_COUPON_CD
               AND    A.COUPON_SEQ = N_COUPON_SEQ;
                
               EXCEPTION
                    WHEN OTHERS THEN 
                    O_RTN_CD := '506'; -- 쿠폰정보기록 도중 문제가 생겼습니다.
                    dbms_output.put_line(SQLERRM); 
        END;
        
        O_RTN_CD := v_result_cd;
      
      
    END IF;
EXCEPTION
    WHEN NOT_USABLE_PRMT_DT THEN
         O_RTN_CD  := '513'; -- 프로모션 기간이 지났습니다.
         dbms_output.put_line(SQLERRM);
    WHEN OVER_DAY_ISSUE THEN
         O_RTN_CD := '604';  -- 일별 발행 건수를 초과하였습니다.
    WHEN OVER_MONTH_ISSUE THEN
         O_RTN_CD := '605';  -- 월별 설문완료건이 초과되었습니다.
    WHEN COMPLETE_RESEARCH THEN
         O_RTN_CD := '606';  -- 이미 설문조사를 완료하였습니다.
    WHEN NOT_FOUND_ISSUE_DATA THEN
         O_RTN_CD := '607';  -- 해당응모번호로 발행된 정보가 없습니다.
END API_RCH_QR_ISSUE_CHECK;

/
