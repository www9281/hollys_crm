--------------------------------------------------------
--  DDL for Procedure API_RCH_QUE_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."API_RCH_QUE_SELECT" (
    P_QR_NO     IN   VARCHAR2,
    O_RCH_NO    OUT  VARCHAR2,
    O_CUST_ID   OUT  VARCHAR2,
    O_CUST_NM   OUT  VARCHAR2,
    O_MOBILE    OUT  VARCHAR2,
    O_STOR_NM   OUT  VARCHAR2,
    O_USE_DT    OUT  VARCHAR2,
    O_RTN_CD    OUT  VARCHAR2,
    O_CURSOR    OUT  SYS_REFCURSOR
)IS 
    -- 일반변수
    v_rch_cnt     NUMBER;       -- 설문조사 갯수 체크
    v_rch_no      VARCHAR(20);  -- 설문조사번호
    v_com_rch_cnt NUMBER;       -- 완료 설문 갯수 체크
    v_rch_date_chk  VARCHAR(2); -- 설문조사 기간 체크
    
    -- 기준 발행 정보
    v_pivot_month_stand  NUMBER; v_pivot_month_member NUMBER; 
    
    -- 비교 발행 정보
    v_com_month_stand  NUMBER; v_com_month_member NUMBER;

    v_cust_id VARCHAR(20);
    -- 오류
    OVER_MONTH_ISSUE EXCEPTION; 

    -- 오류
    ALREADY_ENDED_COUPON EXCEPTION;
    NOT_FOUND_RESEARCH   EXCEPTION;
    ALREADY_FIN_RESEARCH EXCEPTION;
    OVER_RESEARCH_DATE   EXCEPTION;
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2018-02-06
    -- Description   :   홈페이지 설문조사 질의항목 목록 조회
    -- ==========================================================================================
    
    ---------- 1. 해당응모번호로 설문조사완료한 이력이 있는지 조회
    
    SELECT NVL(MAX(LENGTH( DESTROY_DT )),0) INTO v_rch_cnt
    FROM PROMOTION_COUPON
    WHERE COUPON_CD = P_QR_NO
    ;
    -- 1.0 해당 응모번호가 폐기된것인지 확인
    IF v_rch_cnt > 0 THEN 
      RAISE ALREADY_ENDED_COUPON;
    END IF;
    
    
    
    SELECT
      COUNT(*) INTO v_rch_cnt
    FROM RCH_QR_ISSUE A
    WHERE QR_NO = P_QR_NO
      AND EXISTS (SELECT 1 FROM RCH_MASTER WHERE RCH_NO = A.RCH_NO);
    
    -- 1.1 해당 응모번호에 대한 발행정보 또는 설문조사가 없음
    IF v_rch_cnt < 1 THEN 
      RAISE NOT_FOUND_RESEARCH;
    END IF;
    
    SELECT
      A.RCH_NO, SUM(A.MONTH_STAND_ISSUE) + SUM(A.MONTH_MEM_ISSUE)
      INTO v_rch_no, v_com_rch_cnt
    FROM RCH_QR_ISSUE A
    WHERE A.QR_NO = P_QR_NO
      AND EXISTS (SELECT 1 FROM RCH_MASTER WHERE RCH_NO = A.RCH_NO)
    GROUP BY A.RCH_NO;
    
    -- 1.1 해당 응모번호에 대한 설문조사 정보가없음
    IF v_rch_no IS NULL THEN 
      RAISE NOT_FOUND_RESEARCH;
    END IF;
    
    -- 1.2 이미 해당 응모번호로 완료된 설문이 존재
    IF v_com_rch_cnt > 0 THEN
      RAISE ALREADY_FIN_RESEARCH;
    END IF;
    
    ---------- 2. 이미종료된 설문조사인지 조회
    SELECT
      (CASE WHEN TO_CHAR(SYSDATE, 'YYYYMMDD') >= A.RCH_START_DT AND TO_CHAR(SYSDATE, 'YYYYMMDD') <= A.RCH_END_DT THEN 'Y'
            ELSE 'N'
       END) INTO v_rch_date_chk
    FROM RCH_MASTER A
    WHERE RCH_NO = v_rch_no;
    
    IF v_rch_date_chk = 'N' THEN
      RAISE OVER_RESEARCH_DATE;
    END IF;
    
    
    
    
    
    
    
    -- 20180514 최인태 HCS쿠폰 제한수량보다 더 발행되는 이슈 수정
        --기준 : [월별 일반 설문수] [월별 멤버 설문수]
        -- 1. 매장의 발행, 설문 완료 기준 정보 조회
        SELECT
            NVL(MAX(MONTH_STAND_ISSUE), 0), NVL(MAX(MONTH_MEM_ISSUE), 0)
        INTO v_pivot_month_stand, v_pivot_month_member
        FROM RCH_QR_MASTER 
        WHERE STOR_CD = (SELECT PUB_STOR_CD FROM PROMOTION_COUPON_HIS WHERE COUPON_CD = P_QR_NO);
     
      -- 2. 월별 설문 건수 비교
      SELECT
        NVL(MAX(SUM(MONTH_STAND_ISSUE)),0), NVL(MAX(SUM(MONTH_MEM_ISSUE)),0)
        INTO v_com_month_stand, v_com_month_member
      FROM RCH_QR_ISSUE
      WHERE STOR_CD = (SELECT PUB_STOR_CD FROM PROMOTION_COUPON_HIS WHERE COUPON_CD = P_QR_NO)
        AND TO_CHAR(ISSUE_DT, 'YYYYMM') = TO_CHAR(SYSDATE, 'YYYYMM')
      GROUP BY TO_CHAR(ISSUE_DT, 'YYYYMM'), STOR_CD;
      
      -- 2-1. 월별 설문 한도 초과
      SELECT B.CUST_ID
      INTO v_cust_id
   FROM RCH_QR_ISSUE A, C_CUST B
   WHERE A.CUST_ID = B.CUST_ID (+)
     AND A.QR_NO = P_QR_NO AND ROWNUM=1;
      
      
      IF v_cust_id IS NULL THEN
        IF v_pivot_month_stand <= v_com_month_stand THEN
          RAISE OVER_MONTH_ISSUE;
        END IF;
      ELSE
        IF v_pivot_month_member <= v_com_month_member THEN
          RAISE OVER_MONTH_ISSUE;
        END IF;
      END IF;
    
    
    
    
    
    
    
    
    
    ---------- 3. 질의문항 목록 조회
    OPEN O_CURSOR FOR
    SELECT 
      RCH_LV
      ,RCH_LV_CD
      ,RCH_LV_TITLE
      ,RCH_LV_CONT
      ,RCH_LV_DIV
      ,RCH_LV_RPLY_TYPE
      ,RCH_LV_RPLY_PT
      ,RCH_LV_RPLY_TEXT
      ,RCH_LV_RPLY_CNT
    FROM RCH_LEVEL_INFO A
    WHERE A.RCH_NO = v_rch_no
    ORDER BY RCH_LV, RCH_LV_NO, RCH_LV_CD;
    
   ----------4. 설문번호  매장정보  설문의경우 이름 RETURN
   O_RCH_NO := v_rch_no;
   
   SELECT
     (SELECT STOR_NM FROM STORE WHERE STOR_CD = A.STOR_CD)
     , TO_CHAR(A.ISSUE_DT, 'YYYY-MM-DD')
     , B.CUST_ID
     , CASE WHEN B.CUST_ID IS NOT NULL THEN (SELECT DECRYPT(CUST_NM) FROM C_CUST WHERE CUST_ID = A.CUST_ID)
            ELSE ''
       END
     , CASE WHEN B.CUST_ID IS NOT NULL THEN (SELECT DECRYPT(MOBILE) FROM C_CUST WHERE CUST_ID = A.CUST_ID)
            ELSE ''
        END
     INTO O_STOR_NM, O_USE_DT, O_CUST_ID, O_CUST_NM, O_MOBILE
   FROM RCH_QR_ISSUE A, C_CUST B
   WHERE A.CUST_ID = B.CUST_ID (+)
     AND A.QR_NO = P_QR_NO;
   
EXCEPTION


  WHEN ALREADY_ENDED_COUPON THEN
    O_RTN_CD := '502';
    
  WHEN NOT_FOUND_RESEARCH THEN
    O_RTN_CD := '601';
  WHEN ALREADY_FIN_RESEARCH THEN
    O_RTN_CD := '602';
  WHEN OVER_RESEARCH_DATE THEN  
    O_RTN_CD := '603';
    WHEN OVER_MONTH_ISSUE THEN
         O_RTN_CD := '605';  -- 월별 설문완료건이 초과되었습니다.
         dbms_output.put_line(SQLERRM); 
END API_RCH_QUE_SELECT;

/
