--------------------------------------------------------
--  DDL for Procedure API_C_CARD_SAV_HIS_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."API_C_CARD_SAV_HIS_SELECT" (
    P_COMP_CD      IN  VARCHAR2,
    P_CUST_ID      IN  VARCHAR2,
    P_BRAND_CD     IN  VARCHAR2,
    N_SCH_DIV      IN  VARCHAR2,
    P_PAGE_NO      IN  VARCHAR2,
    P_PAGE_SIZE    IN  VARCHAR2,
    O_CURSOR       OUT SYS_REFCURSOR
) IS
      v_query varchar2(20000);
      sav_query VARCHAR2(20000);
      use_query VARCHAR2(20000);
      los_query VARCHAR2(20000);
      mlos_query VARCHAR2(20000);
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2017-10-01
    -- API REQUEST   :   HLS_CRM_IF_0006		
    -- Description   :   API 회원 왕관 사용내역 조회
    -- ==========================================================================================
    
    -- 적립왕관조회
    sav_query := '
      SELECT
        ''적립'' AS MLG_DIV              -- 구분 (적립,소멸,사용, 소멸예정)
        , HIS.SAV_MLG AS USE_MLG          -- 이용 CROWN 갯수
        , TO_CHAR(TO_DATE(HIS.USE_DT), ''YYYY.MM.DD'') AS SAV_DT            -- 적립일
        , TO_CHAR(TO_DATE(HIS.USE_DT), ''YYYY.MM.DD'') || '' ~ '' || TO_CHAR(TO_DATE(HIS.LOS_MLG_DT), ''YYYY.MM.DD'') AS USE_LOS_DT    -- 사용/소멸일
        , (SELECT STOR_NM FROM STORE WHERE STOR_CD = HIS.STOR_CD) AS STOR_NM      -- 매장명
        , DECODE(REP_CARD_YN, ''Y'', ''멤버십카드'', ''기프트카드'' || ''('' || SUBSTR(DECRYPT(CRD.CARD_ID),LENGTH(DECRYPT(CRD.CARD_ID))-3) || '')'') AS CARD_NM    -- 카드명
        , HIS.USE_DT AS ORD_DT
      FROM    C_CUST              CST
            , C_CARD              CRD
            , C_CARD_SAV_USE_HIS  HIS
      WHERE   CST.COMP_CD  = CRD.COMP_CD
      AND     CST.CUST_ID  = CRD.CUST_ID
      AND     CRD.COMP_CD  = HIS.COMP_CD
      AND     CRD.CARD_ID  = HIS.CARD_ID
      AND     HIS.SAV_USE_FG = ''1''
      AND     CRD.COMP_CD  = ''' || P_COMP_CD || '''
      AND     CRD.CUST_ID  = ''' || P_CUST_ID || '''
      AND     HIS.USE_DT >= TO_CHAR(ADD_MONTHS(SYSDATE, -3), ''YYYYMMDD'')
    ';
    
    -- 사용왕관조회
    use_query := '
      SELECT
        ''사용'' AS MLG_DIV
        , HIS.USE_MLG AS USE_MLG
        , '''' AS SAV_DT
        , TO_CHAR(TO_DATE(HIS.CRE_DT), ''YYYY.MM.DD'') AS USE_LOS_DT    -- 사용/소멸일
        , '''' AS STOR_NM
        , '''' AS CARD_NM
        , HIS.CRE_DT AS ORD_DT
      FROM    C_CUST              CST
            , C_CARD_SAV_COUPON_HIS HIS
      WHERE   CST.COMP_CD  = HIS.COMP_CD
      AND     CST.CUST_ID  = HIS.CUST_ID
      AND     CST.COMP_CD  = ''' || P_COMP_CD || '''
      AND     CST.CUST_ID  = ''' || P_CUST_ID || '''
      AND     HIS.CRE_DT >= TO_CHAR(ADD_MONTHS(SYSDATE, -3), ''YYYYMMDD'')
      AND     HIS.USE_YN = ''Y''
    ';
    
    -- 소멸왕관조회
    los_query := '
      SELECT
        ''소멸'' AS MLG_DIV
        , HIS.LOS_MLG_UNUSE AS USE_MLG
        , TO_CHAR(TO_DATE(HIS.USE_DT), ''YYYY.MM.DD'') AS SAV_DT
        , TO_CHAR(TO_DATE(HIS.USE_DT), ''YYYY.MM.DD'') || '' ~ '' || TO_CHAR(TO_DATE(HIS.LOS_MLG_DT), ''YYYY.MM.DD'') AS USE_LOS_DT    -- 사용/소멸일
        , (SELECT STOR_NM FROM STORE WHERE STOR_CD = HIS.STOR_CD) AS STOR_NM      -- 매장명
        , DECODE(REP_CARD_YN, ''Y'', ''멤버십카드'', ''기프트카드'' || ''('' || SUBSTR(DECRYPT(CRD.CARD_ID),LENGTH(DECRYPT(CRD.CARD_ID))-3) || '')'') AS CARD_NM    -- 카드명
        , HIS.LOS_MLG_DT AS ORD_DT
      FROM    C_CUST              CST
            , C_CARD              CRD
            , C_CARD_SAV_USE_HIS  HIS
      WHERE   CST.COMP_CD  = CRD.COMP_CD
      AND     CST.CUST_ID  = CRD.CUST_ID
      AND     CRD.COMP_CD  = HIS.COMP_CD
      AND     CRD.CARD_ID  = HIS.CARD_ID
      AND     CRD.COMP_CD  = ''' || P_COMP_CD || '''
      AND     CRD.CUST_ID  = ''' || P_CUST_ID || '''
      AND     HIS.SAV_MLG != HIS.USE_MLG
      AND     HIS.LOS_MLG_YN  = ''Y''
      AND     HIS.LOS_MLG_DT >= TO_CHAR(ADD_MONTHS(SYSDATE, -3), ''YYYYMMDD'')
      ';
    
    
    -- 소멸예정왕관조회
    mlos_query := '
      SELECT
        ''소멸예정'' AS MLG_DIV
        , HIS.SAV_MLG - HIS.USE_MLG AS USE_MLG
        , TO_CHAR(TO_DATE(HIS.USE_DT), ''YYYY.MM.DD'') AS SAV_DT
        , TO_CHAR(TO_DATE(HIS.USE_DT), ''YYYY.MM.DD'') || '' ~ '' || TO_CHAR(TO_DATE(HIS.LOS_MLG_DT), ''YYYY.MM.DD'') AS USE_LOS_DT    -- 사용/소멸일
        , (SELECT STOR_NM FROM STORE WHERE STOR_CD = HIS.STOR_CD) AS STOR_NM      -- 매장명
        , DECODE(REP_CARD_YN, ''Y'', ''멤버십카드'', ''기프트카드'' || ''('' || SUBSTR(DECRYPT(CRD.CARD_ID),LENGTH(DECRYPT(CRD.CARD_ID))-3) || '')'') AS CARD_NM    -- 카드명
        , HIS.LOS_MLG_DT AS ORD_DT
      FROM    C_CUST              CST
            , C_CARD              CRD
            , C_CARD_SAV_USE_HIS  HIS
      WHERE   CST.COMP_CD  = CRD.COMP_CD
      AND     CST.CUST_ID  = CRD.CUST_ID
      AND     CRD.COMP_CD  = HIS.COMP_CD
      AND     CRD.CARD_ID  = HIS.CARD_ID
      AND     CRD.COMP_CD  = ''' || P_COMP_CD || '''
      AND     CRD.CUST_ID  = ''' || P_CUST_ID || '''
      AND     ADD_MONTHS(TO_DATE(HIS.LOS_MLG_DT), -3) <= TO_CHAR(SYSDATE, ''YYYYMMDD'')
      AND     HIS.LOS_MLG_YN  = ''N''
      ';
    
    
    
    v_query :=
                '
        SELECT T.* FROM(
            SELECT 
              A.MLG_DIV
              ,A.USE_MLG
              ,A.SAV_DT
              ,A.USE_LOS_DT
              ,A.STOR_NM
              ,A.CARD_NM
              ,ROWNUM AS RNUM 
            FROM( 
              SELECT A.* FROM (';
      
    IF N_SCH_DIV IS NULL THEN
      v_query := v_query ||
      sav_query  || ' UNION ALL ' ||
      use_query  || ' UNION ALL ' ||
      los_query  ;
    ELSIF N_SCH_DIV = '1' THEN
      v_query := v_query || sav_query;
    ELSIF N_SCH_DIV = '2' THEN
      v_query := v_query || use_query;
    ELSIF N_SCH_DIV = '3' THEN
      v_query := v_query || los_query;
    ELSIF N_SCH_DIV = '4' THEN
      v_query := v_query || mlos_query;
    END IF;
      
    v_query := v_query || '  ) A        
               ORDER BY A.ORD_DT DESC
            )A WHERE ROWNUM <=  ''' || P_PAGE_NO || ''' *  ''' || P_PAGE_SIZE || '''
        )T WHERE T.RNUM >= ( ''' || P_PAGE_NO || ''' - 1) *  ''' || P_PAGE_SIZE || ''' + 1';
    
    dbms_output.put_line(v_query) ;
    OPEN O_CURSOR FOR v_query;
    
END API_C_CARD_SAV_HIS_SELECT;

/
