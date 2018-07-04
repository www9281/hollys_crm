--------------------------------------------------------
--  DDL for Procedure API_C_CARD_SAV_HIS_POINT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."API_C_CARD_SAV_HIS_POINT" (
    P_COMP_CD      IN  VARCHAR2,
    P_CUST_ID      IN  VARCHAR2,
    N_SCH_DIV      IN  VARCHAR2,
    P_PAGE_NO      IN  VARCHAR2,
    P_PAGE_SIZE    IN  VARCHAR2,
    O_CURSOR       OUT SYS_REFCURSOR
) IS
      v_query varchar2(20000);
      sav_query VARCHAR2(20000);
      use_query VARCHAR2(20000);
--      los_query VARCHAR2(20000);
      mlos_query VARCHAR2(20000);
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2017-11-27
    -- API REQUEST   :   HLS_CRM_IF_0008
    -- Description   :   API 회원 포인트 사용내역 조회
    -- ==========================================================================================
      -- 적립포인트 조회
      sav_query := '
        SELECT
          ''적립'' AS PT_DIV                -- 구분 (적립,소멸,사용, 소멸예정)
          , ABS(HIS.SAV_PT) AS USE_PT            -- 이용포인트 갯수
          , TO_CHAR(TO_DATE(HIS.USE_DT), ''YYYY.MM.DD'') AS SAV_DT            -- 적립일
          , TO_CHAR(TO_DATE(HIS.LOS_PT_DT), ''YYYY.MM.DD'') AS USE_LOS_DT     -- 사용/소멸일
          , (SELECT STOR_NM FROM STORE WHERE STOR_CD = HIS.STOR_CD) AS STOR_NM      -- 매장명
          , HIS.USE_DT AS ORD_DT
          , HIS.INST_DT AS INST_DT
        FROM    C_CUST          CST
              , C_CARD          CRD
              , C_CARD_SAV_HIS  HIS
        WHERE   CST.COMP_CD  = CRD.COMP_CD
        AND     CST.CUST_ID  = CRD.CUST_ID
        AND     CRD.COMP_CD  = HIS.COMP_CD
        AND     CRD.CARD_ID  = HIS.CARD_ID
        AND     HIS.SAV_USE_FG = ''3''
        AND     CRD.COMP_CD  = ''' || P_COMP_CD || '''
        AND     CRD.CUST_ID  = ''' || P_CUST_ID || '''
        AND     HIS.USE_DT >= TO_CHAR(ADD_MONTHS(SYSDATE, -3), ''YYYYMMDD'')
      ';

      -- 사용포인트 조회
      use_query := '
        SELECT
          DECODE(HIS.SAV_USE_DIV, ''302'', ''사용취소'', ''사용'') AS PT_DIV                -- 구분 (적립,소멸,사용, 소멸예정)
          , ABS(HIS.USE_PT) AS USE_PT            -- 이용포인트 갯수
          , '''' AS SAV_DT            -- 적립일
          , TO_CHAR(TO_DATE(HIS.USE_DT), ''YYYY.MM.DD'') AS USE_LOS_DT     -- 사용/소멸일
          , (SELECT STOR_NM FROM STORE WHERE STOR_CD = HIS.STOR_CD) AS STOR_NM      -- 매장명
          , HIS.USE_DT AS ORD_DT
          , HIS.INST_DT AS INST_DT
        FROM    C_CUST          CST
              , C_CARD          CRD
              , C_CARD_SAV_HIS  HIS
        WHERE   CST.COMP_CD  = CRD.COMP_CD
        AND     CST.CUST_ID  = CRD.CUST_ID
        AND     CRD.COMP_CD  = HIS.COMP_CD
        AND     CRD.CARD_ID  = HIS.CARD_ID
        AND     HIS.SAV_USE_FG = ''4''
        AND     CRD.COMP_CD  = ''' || P_COMP_CD || '''
        AND     CRD.CUST_ID  = ''' || P_CUST_ID || '''
        AND     HIS.USE_DT >= TO_CHAR(ADD_MONTHS(SYSDATE, -3), ''YYYYMMDD'')
        UNION ALL
        SELECT
          ''이관'' AS PT_DIV                -- 구분 (적립,소멸,사용, 소멸예정)
          , A.SAV_PT AS USE_PT            -- 이용포인트 갯수
          , A.USE_DT AS SAV_DT            -- 적립일
          , TO_CHAR(TO_DATE(A.LOS_PT_DT), ''YYYY.MM.DD'') AS USE_LOS_DT     -- 사용/소멸일
          , (SELECT STOR_NM FROM STORE WHERE STOR_CD = A.STOR_CD) AS STOR_NM      -- 매장명
          , A.USE_DT AS ORD_DT
          , A.INST_DT AS INST_DT
        FROM C_CARD_SAV_USE_PT_HIS A
          WHERE A.CARD_ID IN (SELECT CARD.CARD_ID FROM C_CUST CUST, C_CARD CARD
                        WHERE CUST.COMP_CD = ''' || P_COMP_CD || '''
                          AND CUST.CUST_ID = ''' || P_CUST_ID || '''
                          AND CUST.CUST_ID = CARD.CUST_ID 
                          AND CUST.CUST_STAT IN (''2'',''3'',''7'',''8'')
                          AND CUST.USE_YN=''Y'')
           AND NOT EXISTS (SELECT 1 FROM C_CARD_SAV_HIS 
                           WHERE COMP_CD = A.COMP_CD
                            AND  CARD_ID = A.CARD_ID
                            AND  USE_DT = A.USE_DT
                            AND  USE_SEQ = A.USE_SEQ)
                            
      ';
      
      -- 소멸포인트 조회       
--      los_query := '
--        SELECT
--          ''소멸'' AS PT_DIV
--          , HIS.LOS_PT_UNUSE AS USE_PT
--          , TO_CHAR(TO_DATE(HIS.USE_DT), ''YYYY.MM.DD'') AS SAV_DT
--          , TO_CHAR(TO_DATE(HIS.USE_DT), ''YYYY.MM.DD'') || '' ~ '' || TO_CHAR(TO_DATE(HIS.LOS_PT_DT), ''YYYY.MM.DD'') AS USE_LOS_DT    -- 사용/소멸일
--          , (SELECT STOR_NM FROM STORE WHERE STOR_CD = HIS.STOR_CD) AS STOR_NM      -- 매장명
--          , HIS.LOS_PT_DT AS ORD_DT
--          , HIS.INST_DT AS INST_DT
--        FROM    C_CUST                 CST
--              , C_CARD                 CRD
--              , C_CARD_SAV_USE_PT_HIS  HIS
--        WHERE   CST.COMP_CD  = CRD.COMP_CD
--        AND     CST.CUST_ID  = CRD.CUST_ID
--        AND     CRD.COMP_CD  = HIS.COMP_CD
--        AND     CRD.CARD_ID  = HIS.CARD_ID
--        AND     CRD.COMP_CD  = ''' || P_COMP_CD || '''
--        AND     CRD.CUST_ID  = ''' || P_CUST_ID || '''
--        AND     HIS.SAV_PT != HIS.USE_PT
--        AND     HIS.LOS_PT_YN  = ''Y''
--        AND     HIS.LOS_PT_DT >= TO_CHAR(ADD_MONTHS(SYSDATE, -3), ''YYYYMMDD'')
--      ';
      
      -- 소멸예정포인트 조회
      mlos_query := '
        SELECT
          ''소멸예정'' AS PT_DIV
          , HIS.SAV_PT - HIS.USE_PT AS USE_PT
          , TO_CHAR(TO_DATE(HIS.USE_DT), ''YYYY.MM.DD'') AS SAV_DT
          , TO_CHAR(TO_DATE(HIS.LOS_PT_DT), ''YYYY.MM.DD'') AS USE_LOS_DT    -- 사용/소멸일
          , (SELECT STOR_NM FROM STORE WHERE STOR_CD = HIS.STOR_CD) AS STOR_NM      -- 매장명
          , HIS.LOS_PT_DT AS ORD_DT
          , HIS.INST_DT AS INST_DT
        FROM    C_CUST              CST
              , C_CARD              CRD
              , C_CARD_SAV_USE_PT_HIS  HIS
        WHERE   CST.COMP_CD  = CRD.COMP_CD
        AND     CST.CUST_ID  = CRD.CUST_ID
        AND     CRD.COMP_CD  = HIS.COMP_CD
        AND     CRD.CARD_ID  = HIS.CARD_ID
        AND     CRD.COMP_CD  = ''' || P_COMP_CD || '''
        AND     CRD.CUST_ID  = ''' || P_CUST_ID || '''
        AND     ADD_MONTHS(TO_DATE(HIS.LOS_PT_DT), -3) <= TO_CHAR(SYSDATE, ''YYYYMMDD'')
        AND     HIS.LOS_PT_YN  = ''N''
      ';
      
      v_query := 
        '
          SELECT T.* FROM(
            SELECT 
              A.PT_DIV
              ,A.USE_PT
              ,A.SAV_DT
              ,A.USE_LOS_DT
              ,A.STOR_NM
              ,ROWNUM AS RNUM 
            FROM(
              SELECT A.* FROM (
        ';
      
      IF N_SCH_DIV IS NULL THEN
      v_query := v_query || sav_query || ' UNION ALL ' || use_query;
      ELSIF N_SCH_DIV = '4' THEN
        v_query := v_query || mlos_query;
      END IF;
      
      v_query := v_query || ' ) A
            ORDER BY A.ORD_DT DESC, A.INST_DT DESC
          )A WHERE ROWNUM <=  ''' || P_PAGE_NO || ''' *  ''' || P_PAGE_SIZE || '''
      )T WHERE T.RNUM >= ( ''' || P_PAGE_NO || ''' - 1) *  ''' || P_PAGE_SIZE || ''' + 1';
        
    OPEN O_CURSOR FOR v_query;
    
END API_C_CARD_SAV_HIS_POINT;

/
