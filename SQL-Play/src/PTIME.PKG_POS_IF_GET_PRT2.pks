CREATE OR REPLACE PACKAGE      PKG_POS_IF_GET_PRT2 AS
--------------------------------------------------------------------------------
--  Package Name     : PKG_POS_IF_GET_PRT2
--  Description      : POS �ڷ� ��ȸ �׸�
--  Ref. Table       : 
--------------------------------------------------------------------------------
--  Create Date      : 2010-03-25 ����
--  Modify Date      : 2016-02-25 ǥ��ȭ �۾�
--------------------------------------------------------------------------------

  P_BRAND_CD       VARCHAR2(4)  := '';
  P_STOR_CD        VARCHAR2(10) := '';
  P_STOR_TP        VARCHAR2(2)  := '';
  P_FR_DT          VARCHAR2(8)  := '';
  P_TO_DT          VARCHAR2(8)  := '';
  
  PROCEDURE GET_CREDIT_BALANCE -- �ܻ� �ܾ� ��Ȳ
  ( 
    asCompCd        IN      VARCHAR2, -- ȸ���ڵ�
    asBrandCd       IN      VARCHAR2, -- ��������
    asStorCd        IN      VARCHAR2, -- �����ڵ�
    asCustId        IN      VARCHAR2, -- ȸ�� ID
    anRetVal        OUT     NUMBER  , -- ���� �ڵ�
    asRetMsg        OUT     VARCHAR2, -- ���� �޽���
    p_cursor        OUT     rec_set.m_refcur
  ) ;
  
  PROCEDURE GET_PRT
  (
    asBrandCd       IN      VARCHAR2, -- ��������
    asStorCd        IN      VARCHAR2, -- �����ڵ�
    asStorTp        IN      VARCHAR2, -- �����ͱ���
    asFrDt          IN      VARCHAR2, -- FROM ����
    asToDt          IN      VARCHAR2, -- TO   ����
    asWorkDiv       IN      VARCHAR2, -- �ٿ�ε� �۾� ����
    anRetVal        OUT     NUMBER  , -- ���� �ڵ�
    asRetMsg        OUT     VARCHAR2, -- ���� �޽���
    p_cursor        OUT     rec_set.m_refcur
  ) ;
  
  PROCEDURE GET_PRT_01 -- ������ ����
  ( 
    anRetVal        OUT     NUMBER  , -- ����ڵ�
    asRetMsg        OUT     VARCHAR2, -- ���� �޽���
    p_cursor        OUT     rec_set.m_refcur
  ) ;
  
  PROCEDURE GET_PRT_02 -- ���ǻ��ϳ���
  ( 
    anRetVal        OUT     NUMBER  , -- ����ڵ�
    asRetMsg        OUT     VARCHAR2, -- ���� �޽���
    p_cursor        OUT     rec_set.m_refcur
  ) ;
  
  PROCEDURE GET_PRT_03 -- �ֹ�����
  ( 
    anRetVal        OUT     NUMBER  , -- ����ڵ�
    asRetMsg        OUT     VARCHAR2, -- ���� �޽���
    p_cursor        OUT     rec_set.m_refcur
  ) ;
  
  PROCEDURE GET_PRT_04 -- ��ǰ ������
  ( 
    anRetVal        OUT     NUMBER  , -- ����ڵ�
    asRetMsg        OUT     VARCHAR2, -- ���� �޽���
    p_cursor        OUT     rec_set.m_refcur
  ) ;
  
  PROCEDURE GET_PRT_04_DT -- ��ǰ ������ ��
  ( 
    asBrandCd       IN      VARCHAR2, -- ��������
    asStorCd        IN      VARCHAR2, -- �����ڵ�
    asStorTp        IN      VARCHAR2, -- �����ͱ���
    asFrDt          IN      VARCHAR2, -- FROM ����
    asToDt          IN      VARCHAR2, -- TO   ����
    asRjtDiv        IN      VARCHAR2, -- ��ǰ����[01165> 1:����, 2:���, 3:�̺�Ʈ, 4:����, 5:Ŭ����, 6:��Ŭ����]
    anRetVal        OUT     NUMBER  , -- ���� �ڵ�
    asRetMsg        OUT     VARCHAR2, -- ���� �޽���
    p_cursor        OUT     rec_set.m_refcur
  ) ;
  
END PKG_POS_IF_GET_PRT2;

/

CREATE OR REPLACE PACKAGE BODY      PKG_POS_IF_GET_PRT2 AS
--------------------------------------------------------------------------------
--  Package Name     : GET_CREDIT_BALANCE
--  Description      : �ܻ� �ܾ� ��Ȳ
--  Ref. Table       : 
--------------------------------------------------------------------------------
--  Create Date      : 2010-05-31 ����
--  Modify Date      : 2016-02-25 ǥ��ȭ �۾�
--------------------------------------------------------------------------------
  PROCEDURE GET_CREDIT_BALANCE
  ( 
    asCompCd        IN      VARCHAR2, -- ȸ���ڵ�
    asBrandCd       IN      VARCHAR2, -- ��������
    asStorCd        IN      VARCHAR2, -- �����ڵ�
    asCustId        IN      VARCHAR2, -- ȸ�� ID
    anRetVal        OUT     NUMBER  , -- ���� �ڵ�
    asRetMsg        OUT     VARCHAR2, -- ���� �޽���
    p_cursor        OUT     rec_set.m_refcur
  ) IS
  BEGIN
    anRetVal := 1;
    asRetMsg := '0K';
    
    OPEN p_cursor FOR
    SELECT DECODE( LEVEL, 1, '��   ��   �� : ' || CUST_NM
                        , 2, '��   ��   ID : ' || CUST_ID
                        , 3, '��   ��   ó : ' || MOBILE
                        , 4, '�� �ܻ� �ݾ� : ' || LPAD(TRIM(TO_CHAR(CREDIT_OCCUR_AMT  , '999,999,990')), 11, ' ')
                        , 5, '�� ��  �� �� : ' || LPAD(TRIM(TO_CHAR(CREDIT_RCV_AMT    , '999,999,990')), 11, ' ')
                        , 6, '�� ��  �� �� : ' || LPAD(TRIM(TO_CHAR(CREDIT_BALANCE_AMT, '999,999,990')), 11, ' ')
                 ) CREDIT_INFO
      FROM (
            SELECT DECRYPT(A.CUST_NM)   CUST_NM
                 , A.CUST_ID            CUST_ID
                 , DECRYPT(A.MOBILE)    MOBILE
                 , B.CREDIT_OCCUR_AMT   CREDIT_OCCUR_AMT
                 , B.CREDIT_RCV_AMT     CREDIT_RCV_AMT
                 , B.CREDIT_BALANCE_AMT CREDIT_BALANCE_AMT
              FROM C_CUST     A
                 , C_CUST_EXT B
             WHERE A.COMP_CD  = B.COMP_CD
               AND A.CUST_ID  = B.CUST_ID
               AND A.CUST_DIV = '3'       -- ȸ����������[01820> 1:ȸ��, 2:��������, 3:����]
               AND A.COMP_CD  = asCompCd
               AND A.BRAND_CD = asBrandCd
               AND A.STOR_CD  = asStorCd
               AND A.CUST_ID  = asCustId
           )
     CONNECT BY LEVEL < 7
    UNION ALL
    SELECT DECODE( LEVEL, 1, '�����Ա����� : ' || SUBSTR(PRC_DT, 1, 4) || '�� ' ||  SUBSTR(PRC_DT, 5, 2) || '�� ' ||  SUBSTR(PRC_DT, 7, 2) || '��'
                        , 2, '�����Աݱݾ� : ' || LPAD(TRIM(TO_CHAR(ETC_AMT, '999,999,990')), 11, ' ')
                 ) AS CREDIT_INFO
      FROM (SELECT *
              FROM STORE_ETC_AMT
             WHERE COMP_CD  = asCompCd
               AND BRAND_CD = asBrandCd
               AND STOR_CD  = asStorCd
               AND CUST_ID  = asCustId
               AND ETC_DIV  = '01'      -- ����ݱ���[00820> 01:�Աݰ���, 02:��ݰ���]
               AND PRC_DT   = (SELECT MAX(PRC_DT)
                                 FROM STORE_ETC_AMT
                                WHERE COMP_CD  = asCompCd
                                  AND BRAND_CD = asBrandCd
                                  AND STOR_CD  = asStorCd
                                  AND CUST_ID  = asCustId
                                  AND ETC_DIV  = '01'      -- ����ݱ���[00820> 01:�Աݰ���, 02:��ݰ���]
                              )
           )
    CONNECT BY LEVEL < 3;
  EXCEPTION
    WHEN OTHERS THEN
         anRetVal := SQLCODE ;
         asRetMsg := 'WorkDiv[CR]' || SQLERRM(SQLCODE) ;
         INSERT INTO ERR_LOG_IF_POS
                ( JOB_DATE, JOB_SEQ_NO, STOR_CD, JOB_TIME, JOB_NAME, JOB_MESSAGE )
         VALUES
                ( TO_CHAR(SYSDATE, 'YYYYMMDD'), SQ_ERR_LOG_IF_POS.NEXTVAL, asStorCd, TO_CHAR(SYSDATE, 'HH24MISS'), 'CR', asRetMsg );
                   
         COMMIT;
  END GET_CREDIT_BALANCE ;
  
--------------------------------------------------------------------------------
--  Package Name     : GET_PRT
--  Description      : 
--  Ref. Table       : 
--------------------------------------------------------------------------------
--  Create Date      : 2010-05-31 ����
--  Modify Date      : 2016-02-25 ǥ��ȭ �۾�
--------------------------------------------------------------------------------
  PROCEDURE GET_PRT
  (
    asBrandCd       IN      VARCHAR2, -- ��������
    asStorCd        IN      VARCHAR2, -- �����ڵ�
    asStorTp        IN      VARCHAR2, -- �����ͱ���
    asFrDt          IN      VARCHAR2, -- FROM ����
    asToDt          IN      VARCHAR2, -- TO   ����
    asWorkDiv       IN      VARCHAR2, -- �ٿ�ε� �۾� ����
    anRetVal        OUT     NUMBER  , -- ���� �ڵ�
    asRetMsg        OUT     VARCHAR2, -- ���� �޽���
    p_cursor        OUT     rec_set.m_refcur
  ) IS
  BEGIN
    anRetVal := 1;
    asRetMsg := '0K';
    
    P_BRAND_CD  := asBrandCd;
    P_STOR_CD   := asStorCd ;
    P_STOR_TP   := asStorTp ;
    P_FR_DT     := asFrDt   ;
    P_TO_DT     := asToDt   ;
    
    IF    ( asWorkDiv = '01' ) THEN -- ������ ����
       GET_PRT_01(anRetVal, asRetMsg, p_cursor );
    ELSIF ( asWorkDiv = '02' ) THEN -- ������� ����
       GET_PRT_02(anRetVal, asRetMsg, p_cursor );
    ELSIF ( asWorkDiv = '03' ) THEN -- �ֹ� ����
       GET_PRT_03(anRetVal, asRetMsg, p_cursor );
    ELSIF ( asWorkDiv = '04' ) THEN -- ��ǰ ����
       GET_PRT_04(anRetVal, asRetMsg, p_cursor );
    ELSE
       anRetVal := -100;
       asRetMsg := '�� ���ǵ� �ٿ�ε� �۾� ����[' || asWorkDiv || '] �Դϴ�.';
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
         anRetVal := SQLCODE ;
         asRetMsg := 'WorkDiv[' || asWorkDiv || ']' || SQLERRM(SQLCODE) ;
         INSERT INTO ERR_LOG_IF_POS
                ( JOB_DATE, JOB_SEQ_NO, STOR_CD, JOB_TIME, JOB_NAME, JOB_MESSAGE )
         VALUES
                ( TO_CHAR(SYSDATE, 'YYYYMMDD'), SQ_ERR_LOG_IF_POS.NEXTVAL, asStorCd, TO_CHAR(SYSDATE, 'HH24MISS'), asWorkDiv, asRetMsg );
                   
         COMMIT;
  END GET_PRT;
  
--------------------------------------------------------------------------------
--  Package Name     : GET_PRT_01
--  Description      : ������ ����
--  Ref. Table       : 
--------------------------------------------------------------------------------
--  Create Date      : 2010-06-14 ����
--  Modify Date      : 2016-02-25 ǥ��ȭ �۾�
--------------------------------------------------------------------------------
  PROCEDURE GET_PRT_01
  ( 
    anRetVal        OUT     NUMBER  , -- ����ڵ�
    asRetMsg        OUT     VARCHAR2, -- ���� �޽���
    p_cursor        OUT     rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT SUBSTRB(I.ITEM_POS_NM, 1, 14) || '[' || D.ITEM_CD || ']'    AS ITEM_NM  -- ��ǰ��
         , SUM(D.PROD_QTY)                                             AS PROD_QTY -- �������
         , SUM(D.PROD_QTY * D.SALE_PRC)                                AS PROD_AMT -- ����ݾ�
      FROM PRODUCT_DT D, -- ���� DT
           ITEM       I
     WHERE D.ITEM_CD        = I.ITEM_CD
       AND D.PRD_DT   BETWEEN P_FR_DT AND P_TO_DT
       AND D.BRAND_CD       = P_BRAND_CD
       AND D.STOR_CD        = P_STOR_CD
     GROUP BY SUBSTRB(I.ITEM_POS_NM, 1, 14) || '[' || D.ITEM_CD || ']' ;
     
    anRetVal := 1 ;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE ;
  END GET_PRT_01 ;
  
--------------------------------------------------------------------------------
--  Package Name     : GET_PRT_02
--  Description      : ������� ����
--  Ref. Table       : 
--------------------------------------------------------------------------------
--  Create Date      : 2010-06-14 ����
--  Modify Date      : 2016-02-25 ǥ��ȭ �۾�
--------------------------------------------------------------------------------
  PROCEDURE GET_PRT_02
  ( 
    anRetVal        OUT     NUMBER  , -- ����ڵ�
    asRetMsg        OUT     VARCHAR2, -- ���� �޽���
    p_cursor        OUT     rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT SUBSTRB(I.ITEM_POS_NM, 1, 14) || '[' || D.ITEM_CD || ']'    AS ITEM_NM  -- ��ǰ��
         , SUM(D.ADJ_QTY)                                              AS PROD_QTY -- ��������
         , SUM(D.ADJ_QTY * D.SALE_PRC)                                 AS PROD_AMT -- �����ݾ�
      FROM DSTOCK D, -- �� ����
           ITEM   I
     WHERE D.ITEM_CD         = I.ITEM_CD
       AND D.PRC_DT    BETWEEN P_FR_DT AND P_TO_DT
       AND D.BRAND_CD        = P_BRAND_CD
       AND D.STOR_CD         = P_STOR_CD
     GROUP BY SUBSTRB(I.ITEM_POS_NM, 1, 14) || '[' || D.ITEM_CD || ']' ;
     
    anRetVal := 1 ;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE ;
  END GET_PRT_02 ;
  
--------------------------------------------------------------------------------
--  Package Name     : GET_PRT_03
--  Description      : �ֹ� ����(01:���ֹ�, 02:Ư��, 03:Ư������, 04:���θ��)
--  Ref. Table       : 
--------------------------------------------------------------------------------
--  Create Date      : 2010-06-14 ����
--  Modify Date      : 2016-02-25 ǥ��ȭ �۾�
--------------------------------------------------------------------------------
  PROCEDURE GET_PRT_03
  ( 
    anRetVal        OUT     NUMBER  , -- ����ڵ�
    asRetMsg        OUT     VARCHAR2, -- ���� �޽���
    p_cursor        OUT     rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT SUBSTRB(I.ITEM_POS_NM, 1, 14) || '[' || D.ITEM_CD || ']'           AS ITEM_NM   -- ��ǰ��
         , NVL(SUM(CASE WHEN D.ORD_SEQ = '1' THEN D.ORD_QTY ELSE 0 END ), 0)  AS ORD_QTY_1 -- 1�����ֹ�����
         , NVL(SUM(CASE WHEN D.ORD_SEQ = '2' THEN D.ORD_QTY ELSE 0 END ), 0)  AS ORD_QTY_2 -- 2���ֹ�����
         , NVL(SUM(CASE WHEN D.ORD_SEQ = '3' THEN D.ORD_QTY ELSE 0 END ), 0)  AS ORD_QTY_3 -- 3���ֹ�����
         , SUM(D.ORD_AMT)                                                     AS ORD_AMT   -- �ֹ��ݾ�
      FROM ORDER_HD H, -- ���� �ֹ� HD
           ORDER_DT D, -- ���� �ֹ� DT
           ITEM     I
     WHERE D.ITEM_CD         = I.ITEM_CD
       AND H.SHIP_DT         = D.SHIP_DT
       AND H.BRAND_CD        = D.BRAND_CD
       AND H.STOR_CD         = D.STOR_CD
       AND H.ORD_SEQ         = D.ORD_SEQ
       AND H.ORD_FG          = D.ORD_FG
       AND H.SHIP_DT   BETWEEN P_FR_DT AND P_TO_DT
       AND H.BRAND_CD        = P_BRAND_CD
       AND H.STOR_CD         = P_STOR_CD
       AND H.ORD_FG         IN ( '01', '02', '03', '04' )
     GROUP BY SUBSTRB(I.ITEM_POS_NM, 1, 14) || '[' || D.ITEM_CD || ']' ;
     
    anRetVal := 1 ;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE ;
  END GET_PRT_03 ;
  
--------------------------------------------------------------------------------
--  Package Name     : GET_PRT_04
--  Description      : ��ǰ ����
--  Ref. Table       : 
--------------------------------------------------------------------------------
--  Create Date      : 2010-06-14 ����
--  Modify Date      : 2016-02-25 ǥ��ȭ �۾�
--------------------------------------------------------------------------------
  PROCEDURE GET_PRT_04
  ( 
    anRetVal        OUT     NUMBER  , -- ����ڵ�
    asRetMsg        OUT     VARCHAR2, -- ���� �޽���
    p_cursor        OUT     rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT R.RJT_DIV               AS RJT_DIV
         , C.CODE_NM               AS RJT_DIV_NM
         , SUM(RJT_AMT + RJT_VAT)  AS RJT_AMT
      FROM REJECT_HD  R, -- ��ǰ HD
           ( SELECT * FROM COMMON WHERE CODE_TP = '01165' AND USE_YN = 'Y' ) C -- ��ǰ����[01165> 1:����, 2:���, 3:�̺�Ʈ, 4:����, 5:Ŭ����, 6:��Ŭ����]
     WHERE R.RJT_DIV             = C.CODE_CD
       AND R.RJT_DT        BETWEEN P_FR_DT AND P_TO_DT
       AND R.BRAND_CD            = P_BRAND_CD
       AND R.STOR_CD             = P_STOR_CD
       AND R.PRC_STAT_DIV       >= '2'
     GROUP BY R.RJT_DIV, C.CODE_NM;
     
    anRetVal := 1 ;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE ;
  END GET_PRT_04 ;
  
--------------------------------------------------------------------------------
--  Package Name     : GET_PRT_04_DT
--  Description      : ��ǰ ������ ��
--  Ref. Table       : 
--------------------------------------------------------------------------------
--  Create Date      : 2010-06-14 ����
--  Modify Date      : 2016-02-25 ǥ��ȭ �۾�
--------------------------------------------------------------------------------
  PROCEDURE GET_PRT_04_DT
  ( 
    asBrandCd       IN      VARCHAR2, -- ��������
    asStorCd        IN      VARCHAR2, -- �����ڵ�
    asStorTp        IN      VARCHAR2, -- �����ͱ���
    asFrDt          IN      VARCHAR2, -- FROM ����
    asToDt          IN      VARCHAR2, -- TO   ����
    asRjtDiv        IN      VARCHAR2, -- ��ǰ����[01165> 1:����, 2:���, 3:�̺�Ʈ, 4:����, 5:Ŭ����, 6:��Ŭ����]
    anRetVal        OUT     NUMBER  , -- ���� �ڵ�
    asRetMsg        OUT     VARCHAR2, -- ���� �޽���
    p_cursor        OUT     rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT I.ITEM_NM               AS ITEM_NM
         , D.RJT_QTY               AS RJT_QTY
         , D.RJT_AMT + D.RJT_VAT   AS RJT_AMT
         , C.CODE_NM               AS CLAIM_NM
      FROM REJECT_HD  H, -- ��ǰ HD
           REJECT_DT  D, -- ��ǰ DT
           ITEM       I,
           ( SELECT * FROM COMMON WHERE CODE_TP = '00380' AND USE_YN = 'Y' ) C  -- Ŭ���ӻ���
     WHERE D.ITEM_CD             = I.ITEM_CD
       AND D.CLAIM_CD            = C.CODE_CD(+)
       AND H.RJT_DT              = D.RJT_DT
       AND H.BRAND_CD            = D.BRAND_CD
       AND H.STOR_CD             = D.STOR_CD
       AND H.RJT_DIV             = D.RJT_DIV
       AND H.SLIP_NO             = D.SLIP_NO
       AND H.RJT_DT        BETWEEN asFrDt AND asToDt
       AND H.BRAND_CD            = asBrandCd
       AND H.STOR_CD             = asStorCd
       AND H.RJT_DIV             = asRjtDiv
       AND H.PRC_STAT_DIV       >= '2';
       
    anRetVal := 1 ;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE ;
  END GET_PRT_04_DT ;
END PKG_POS_IF_GET_PRT2;

/
