CREATE OR REPLACE PACKAGE       PKG_POS_IF_GET_PRT AS

---------------------------------------------------------------------------------------------------
--  Procedure Name   : PKG_POS_IF_GET_PRT
--  Description      : POS �ڷ� ��ȸ �׸�   (�����ڵ� 01400 �Ǹ������� �޴��� ��� ���ش�)
-- asWorkDiv         : 01
--                   : 02
---------------------------------------------------------------------------------------------------
--  Create Date      : 2010-03-25
--  Create Programer : ���μ�
--  Modify Date      : 2010-03-25
--  Modify Programer :
---------------------------------------------------------------------------------------------------
/*                              BRNAD  STORE     STOR_TP   FR_DT    TO_DT        �۾�
exec PKG_POS_IF_GET_PRT.GET_PRT('002', '0008484', '20', '20100301', '20100331', '09', :anRetVal, :asRetVal, :asRetset);
*/
P_COMP_CD        VARCHAR2(3)  := '';
P_BRAND_CD       VARCHAR2(4)  := '';
P_STOR_CD        VARCHAR2(10) := '';
P_STOR_TP        VARCHAR2(2)  := '';
P_FR_DT          VARCHAR2(8)  := '';
P_TO_DT          VARCHAR2(8)  := '';

PROCEDURE GET_PRT
                (
                   asCompCd        IN   VARCHAR2, -- ȸ���ڵ�
                   asBrandCd       IN   VARCHAR2, -- ��������
                   asStorCd        IN   VARCHAR2, -- �����ڵ�
                   asStorTp        IN   VARCHAR2, -- �����ͱ���
                   asFrDt          IN   VARCHAR2, -- FROM ����
                   asToDt          IN   VARCHAR2, -- TO   ����
                   asWorkDiv       IN   VARCHAR2, -- �ٿ�ε� �۾� ����
                   anRetVal        OUT  NUMBER  , -- ���� �ڵ�
                   asRetMsg        OUT  VARCHAR2, -- ���� �޽���
                   p_cursor        OUT  rec_set.m_refcur
                ) ;

PROCEDURE GET_PRT_01 -- ��Ŭ����
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;

PROCEDURE GET_PRT_02 -- ���������γ���
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;

PROCEDURE GET_PRT_03 -- ���������ں�����
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;

PROCEDURE GET_PRT_05 -- ��ǰ���������
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;

PROCEDURE GET_PRT_06 -- �űԻ�ǰ�����Ȳ
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;

PROCEDURE GET_PRT_07 -- ���ں���Ÿ�������
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;

PROCEDURE GET_PRT_08 -- ���ں��������
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;

PROCEDURE GET_PRT_09 -- ��ġ��ǰŰ��Ȳ
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;

PROCEDURE GET_PRT_10 -- �Ǹ�����������
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;

PROCEDURE GET_PRT_11 -- ��������Ʈ��볻��
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;

PROCEDURE GET_PRT_12 -- ��������Ʈ���ں�����
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;

PROCEDURE GET_PRT_13 -- LG���γ���
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;

PROCEDURE GET_PRT_14 -- LG���ں�����
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;

PROCEDURE GET_PRT_15 -- �ð��뺰 ����
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;

END PKG_POS_IF_GET_PRT;

/

CREATE OR REPLACE PACKAGE BODY       PKG_POS_IF_GET_PRT AS


   PROCEDURE GET_PRT
                      (
                         asCompCd        IN   VARCHAR2, -- ȸ���ڵ�
                         asBrandCd       IN   VARCHAR2, -- ��������
                         asStorCd        IN   VARCHAR2, -- �����ڵ�
                         asStorTp        IN   VARCHAR2, -- �����ͱ���
                         asFrDt          IN   VARCHAR2, -- FROM ����
                         asToDt          IN   VARCHAR2, -- TO   ����
                         asWorkDiv       IN   VARCHAR2, -- �ٿ�ε� �۾� ����
                         anRetVal        OUT  NUMBER  , -- ���� �ڵ�
                         asRetMsg        OUT  VARCHAR2, -- ���� �޽���
                         p_cursor        OUT  rec_set.m_refcur
                      ) IS

   BEGIN
      anRetVal := 1;
      asRetMsg := '0K';
      
      P_COMP_CD   := asCompCd;
      P_BRAND_CD  := asBrandCd;
      P_STOR_CD   := asStorCd ;
      P_STOR_TP   := asStorTp ;
      P_FR_DT     := asFrDt ;
      P_TO_DT     := asToDt ;

      /*
      INSERT INTO ERR_LOG_IF_POS
                ( JOB_DATE, JOB_SEQ_NO, STOR_CD, JOB_TIME, JOB_NAME, JOB_MESSAGE )
           VALUES
                ( TO_CHAR(SYSDATE, 'YYYYMMDD'), SQ_ERR_LOG_IF_POS.NEXTVAL, asStorCd, TO_CHAR(SYSDATE, 'HH24MISS'), 'PRT_' || asWorkDiv, asRetMsg );

      Commit;
      */

      If ( asWorkDiv = '01' ) Then    -- ��Ŭ����
         GET_PRT_01(anRetVal, asRetMsg, p_cursor  );

      ElsIf ( asWorkDiv = '02' ) Then -- ���������γ���
         GET_PRT_02(anRetVal, asRetMsg, p_cursor  );

      ElsIf ( asWorkDiv = '03' ) Then -- ���������ں�����
         GET_PRT_03(anRetVal, asRetMsg, p_cursor  );

      ElsIf ( asWorkDiv = '05' ) Then -- ��ǰ���������
         GET_PRT_05(anRetVal, asRetMsg, p_cursor  );

      ElsIf ( asWorkDiv = '06' ) Then -- �űԻ�ǰ�����Ȳ
         GET_PRT_06(anRetVal, asRetMsg, p_cursor  );

      ElsIf ( asWorkDiv = '07' ) Then -- ���ں���Ÿ�������
         GET_PRT_07(anRetVal, asRetMsg, p_cursor  );

      ElsIf ( asWorkDiv = '08' ) Then -- ���ں��������
         GET_PRT_08(anRetVal, asRetMsg, p_cursor  );

      ElsIf ( asWorkDiv = '09' ) Then -- �Ǹ�����������
         GET_PRT_09(anRetVal, asRetMsg, p_cursor  );

      ElsIf ( asWorkDiv = '10' ) Then -- ��ġ��ǰŰ��Ȳ
         GET_PRT_10(anRetVal, asRetMsg, p_cursor  );

      ElsIf ( asWorkDiv = '11' ) Then -- ��������Ʈ��볻��
         GET_PRT_11(anRetVal, asRetMsg, p_cursor  );

      ElsIf ( asWorkDiv = '12' ) Then -- ��������Ʈ���ں�����
         GET_PRT_12(anRetVal, asRetMsg, p_cursor  );

      ElsIf ( asWorkDiv = '13' ) Then -- LG���γ���
         GET_PRT_13(anRetVal, asRetMsg, p_cursor  );

      ElsIf ( asWorkDiv = '14' ) Then -- LG���ں�����
         GET_PRT_14(anRetVal, asRetMsg, p_cursor  );

      ElsIf ( asWorkDiv = '15' ) Then -- �ð��뺰 ����
         GET_PRT_15(anRetVal, asRetMsg, p_cursor  );

      Else
         anRetVal := -100;
         asRetMsg := '�� ���ǵ� �ٿ�ε� �۾� ����[' || asWorkDiv || '] �Դϴ�.' ;
      End If;


   Exception When OTHERS Then
      anRetVal := SQLCODE ;
      asRetMsg := 'WorkDiv[' || asWorkDiv || ']' || SQLERRM(SQLCODE) ;
      INSERT INTO ERR_LOG_IF_POS
                ( JOB_DATE, JOB_SEQ_NO, STOR_CD, JOB_TIME, JOB_NAME, JOB_MESSAGE )
           VALUES
                ( TO_CHAR(SYSDATE, 'YYYYMMDD'), SQ_ERR_LOG_IF_POS.NEXTVAL, asStorCd, TO_CHAR(SYSDATE, 'HH24MISS'), asWorkDiv, asRetMsg );

      Commit;
   END GET_PRT;


   ---------------------------------------------------------------------------------------------------
   --  Procedure Name   : GET_PRT_01
   --  Description      : ��Ŭ����
   -- Ref. Table        :
   ---------------------------------------------------------------------------------------------------
   --  Create Date      : 2010-03-25
   --  Create Programer : ���μ�
   --  Modify Date      : 2020-03-25
   --  Modify Programer :
   ---------------------------------------------------------------------------------------------------
   PROCEDURE GET_PRT_01
                   ( anRetVal        OUT     NUMBER  , -- ����ڵ�
                     asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                     p_cursor        OUT     rec_set.m_refcur
                   ) IS

   BEGIN
      OPEN p_cursor FOR
         SELECT  I.ITEM_POS_NM       -- ��ǰ�ڵ�
               , R.RJT_CQTY          -- ��ǰȮ�����U
               , R.RJT_CAMT          -- ��ǰȮ���ݾ� (�ΰ��� ����)
           FROM REJECT_DT R,
                ITEM      I
          WHERE R.ITEM_CD        = I.ITEM_CD
            AND R.RJT_DT   BETWEEN P_FR_DT AND P_TO_DT
            AND R.COMP_CD        = P_COMP_CD
            AND R.BRAND_CD       = P_BRAND_CD
            AND R.STOR_CD        = P_STOR_CD
            AND R.RJT_DIV        = '6'  ;


      anRetVal := 1 ;
      asRetMsg := 'OK';
   Exception When OTHERS Then
      asRetMsg := SQLERRM(SQLCODE);
      anRetVal := SQLCODE ;
   END GET_PRT_01 ;

   ---------------------------------------------------------------------------------------------------
   --  Procedure Name   : GET_PRT_02
   --  Description      : ���������γ���
   -- Ref. Table        :
   ---------------------------------------------------------------------------------------------------
   --  Create Date      : 2010-03-25
   --  Create Programer : ���μ�
   --  Modify Date      : 2020-03-25
   --  Modify Programer :
   ---------------------------------------------------------------------------------------------------
   PROCEDURE GET_PRT_02
                   ( anRetVal        OUT     NUMBER  , -- ����ڵ�
                     asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                     p_cursor        OUT     rec_set.m_refcur
                   ) IS

   BEGIN
      OPEN p_cursor FOR
         SELECT  APPR_DT || APPR_TM                       AS APPR_DTM -- �Ͻ�
               , CARD_NO                                  AS CARD_NO  -- ī���ȣ
               , APPR_NO                                  AS APPR_NO  -- ���ι�ȣ
               , APPR_AMT * DECODE(SALE_DIV, '1', 1, -1)  AS APPR_AMT -- ���αݾ�
           FROM POINT_LOG
          WHERE SALE_DT    BETWEEN P_FR_DT AND P_TO_DT
            AND COMP_CD          = P_COMP_CD
            AND BRAND_CD         = P_BRAND_CD
            AND STOR_CD          = P_STOR_CD
            AND PAY_DIV          = '63'     -- SK (������)
--            AND SALE_DIV         = '1'
            AND NVL(USE_YN, 'Y') = 'Y' ;


      anRetVal := 1 ;
      asRetMsg := 'OK';
   Exception When OTHERS Then
      asRetMsg := SQLERRM(SQLCODE);
      anRetVal := SQLCODE ;
   END GET_PRT_02 ;

   ---------------------------------------------------------------------------------------------------
   --  Procedure Name   : GET_PRT_03
   --  Description      : ���������ں�����
   -- Ref. Table        :
   ---------------------------------------------------------------------------------------------------
   --  Create Date      : 2010-03-25
   --  Create Programer : ���μ�
   --  Modify Date      : 2020-03-25
   --  Modify Programer :
   ---------------------------------------------------------------------------------------------------
   PROCEDURE GET_PRT_03
                   ( anRetVal        OUT     NUMBER  , -- ����ڵ�
                     asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                     p_cursor        OUT     rec_set.m_refcur
                   ) IS

   BEGIN
      OPEN p_cursor FOR
         SELECT  MMDD                                      AS MMDD
               , APPR_CNT                                  AS APPR_CNT
               , APPR_AMT * DECODE(SALE_DIV, '1', 1, -1)   AS APPR_AMT
               , APPR_DC  * DECODE(SALE_DIV, '1', 1, -1)   AS APPR_DC
           FROM (
                  SELECT  SUBSTR(APPR_DT, 5, 4) AS MMDD         -- ����
                        , SALE_DIV              AS SALE_DIV   -- �Ǹű��� (1:����, 2: ��ǰ)
                        , COUNT(APPR_NO)        AS APPR_CNT   -- �Ǽ�(����-���)
                        , SUM(APPR_AMT)         AS APPR_AMT   -- ���αݾ�
                        , SUM(APPR_DC )         AS APPR_DC    -- ���αݾ�
                    FROM POINT_LOG
                   WHERE SALE_DT    BETWEEN P_FR_DT AND P_TO_DT
                     AND COMP_CD          = P_COMP_CD
                     AND BRAND_CD         = P_BRAND_CD
                     AND STOR_CD          = P_STOR_CD
                     AND PAY_DIV          = '63'     -- SK (������)
                     AND NVL(USE_YN, 'Y') = 'Y'
                   GROUP BY  SUBSTR(APPR_DT, 5, 4)
                           , SALE_DIV
                )   ;


      anRetVal := 1 ;
      asRetMsg := 'OK';
   Exception When OTHERS Then
      asRetMsg := SQLERRM(SQLCODE);
      anRetVal := SQLCODE ;
   END GET_PRT_03 ;


   ---------------------------------------------------------------------------------------------------
   --  Procedure Name   : GET_PRT_05
   --  Description      : ��ǰ���������
   -- Ref. Table        :
   ---------------------------------------------------------------------------------------------------
   --  Create Date      : 2010-03-25
   --  Create Programer : ���μ�
   --  Modify Date      : 2020-03-25
   --  Modify Programer :
   ---------------------------------------------------------------------------------------------------
   PROCEDURE GET_PRT_05
                   ( anRetVal        OUT     NUMBER  , -- ����ڵ�
                     asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                     p_cursor        OUT     rec_set.m_refcur
                   ) IS

   BEGIN
      OPEN p_cursor FOR
         WITH IT AS
                   ( SELECT  I.COMP_CD, I.ITEM_CD, I.ITEM_POS_NM AS ITEM_NM
                           , I.L_CLASS_CD
                           , C.L_CLASS_NM
                       FROM (
                                SELECT  I.COMP_CD
                                     ,  I.ITEM_CD
                                     ,  I.ITEM_POS_NM
                                     ,  NVL(IC.L_CLASS_CD, I.L_CLASS_CD)    AS L_CLASS_CD
                                  FROM  ITEM_CHAIN I
                                     ,  ITEM_CLASS IC
                                 WHERE  I.COMP_CD   = IC.COMP_CD(+)
                                   AND  I.ITEM_CD   = IC.ITEM_CD(+)
                                   AND I.COMP_CD  = P_COMP_CD
                                   AND I.BRAND_CD = P_BRAND_CD
                                   AND I.STOR_TP  = P_STOR_TP
                            )           I
                          , ( SELECT * FROM ITEM_L_CLASS
                               WHERE COMP_CD      = P_COMP_CD
                                 AND ORG_CLASS_CD = '00'
                                 AND USE_YN       = 'Y'
                             )          C
                      WHERE I.COMP_CD    = C.COMP_CD
                        AND I.L_CLASS_CD = C.L_CLASS_CD
                   )
         SELECT  I.L_CLASS_CD     AS L_CLASS_CD
               , I.ITEM_CD        AS ITEM_CD
               , I.ITEM_NM        AS ITEM_NM
               , SUM(SALE_QTY)    AS SALE_QTY
               , SUM(DECODE(C.VAL_C1, 'G', T.GRD_AMT, 'T', T.SALE_AMT, T.GRD_AMT - T.VAT_AMT))    AS SALE_AMT
               , I.L_CLASS_NM     AS L_CLASS_NM
           FROM SALE_JDM   T,
                IT         I,
                (
                    SELECT  VAL_C1
                      FROM  COMMON
                     WHERE  COMP_CD = P_COMP_CD
                       AND  CODE_TP = '01435'
                       AND  CODE_CD = '200'
                ) C
          WHERE T.COMP_CD        = I.COMP_CD
            AND T.ITEM_CD        = I.ITEM_CD
            AND T.SALE_DT  BETWEEN P_FR_DT AND P_TO_DT
            AND T.COMP_CD        = P_COMP_CD
            AND T.BRAND_CD       = P_BRAND_CD
            AND T.STOR_CD        = P_STOR_CD
          GROUP BY  I.L_CLASS_CD
                  , I.ITEM_CD
                  , I.ITEM_NM
                  , I.L_CLASS_NM
          ORDER BY I.L_CLASS_CD
                  , I.ITEM_CD    ;


      anRetVal := 1 ;
      asRetMsg := 'OK';
   Exception When OTHERS Then
      asRetMsg := SQLERRM(SQLCODE);
      anRetVal := SQLCODE ;
   END GET_PRT_05 ;

   ---------------------------------------------------------------------------------------------------
   --  Procedure Name   : GET_PRT_06                      ============>>>>>>>>> ���� üũ
   --  Description      : �űԻ�ǰ�����Ȳ
   -- Ref. Table        :
   ---------------------------------------------------------------------------------------------------
   --  Create Date      : 2010-03-25
   --  Create Programer : ���μ�
   --  Modify Date      : 2020-03-25
   --  Modify Programer :
   ---------------------------------------------------------------------------------------------------
   PROCEDURE GET_PRT_06
                   ( anRetVal        OUT     NUMBER  , -- ����ڵ�
                     asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                     p_cursor        OUT     rec_set.m_refcur
                   ) IS

   BEGIN
      OPEN p_cursor FOR
         SELECT  I.ITEM_NM                       AS ITEM_NM  -- ��ǰ��
               , I.SALE_PRC                      AS SALE_PRC -- �Ű�
               , TO_CHAR(I.INST_DT, 'YYYYMMDD')  AS INST_DT  -- �����
           FROM ITEM_CHAIN  I,
                ( SELECT * FROM ITEM_FLAG
                   WHERE COMP_CD = P_COMP_CD
                     AND ITEM_FG = '01'
                     AND (    P_FR_DT  BETWEEN START_DT AND END_DT
                           OR P_TO_DT  BETWEEN START_DT AND END_DT  )
                )  F
          WHERE I.COMP_CD  = F.COMP_CD
            AND I.ITEM_CD  = F.ITEM_CD
            AND I.COMP_CD  = P_COMP_CD
            AND I.BRAND_CD = P_BRAND_CD
            AND I.STOR_TP  = P_STOR_TP    ;


      anRetVal := 1 ;
      asRetMsg := 'OK';
   Exception When OTHERS Then
      asRetMsg := SQLERRM(SQLCODE);
      anRetVal := SQLCODE ;
   END GET_PRT_06 ;

   ---------------------------------------------------------------------------------------------------
   --  Procedure Name   : GET_PRT_07
   --  Description      : ���ں���Ÿ�������
   -- Ref. Table        :
   ---------------------------------------------------------------------------------------------------
   --  Create Date      : 2010-03-25
   --  Create Programer : ���μ�
   --  Modify Date      : 2020-03-25
   --  Modify Programer :
   ---------------------------------------------------------------------------------------------------
   PROCEDURE GET_PRT_07
                   ( anRetVal        OUT     NUMBER  , -- ����ڵ�
                     asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                     p_cursor        OUT     rec_set.m_refcur
                   ) IS

   BEGIN
      OPEN p_cursor FOR
         SELECT  SALE_DT
               , SUM(SALE_AMT)  AS SALE_AMT
               , SUM(GIFT_AMT)  AS GIFT_AMT
               , SUM(CARD_AMT)  AS CARD_AMT
           FROM (
                  SELECT  SALE_DT                                                AS SALE_DT  -- �Ǹ�����
                        , SUM(GRD_AMT - VAT_AMT)                                 AS SALE_AMT -- �������
                        , SUM(0)                                                 AS GIFT_AMT -- ��ǰ�Ǹ���
                        , SUM(0)                                                 AS CARD_AMT -- �ſ�ī�����
                    FROM SALE_JDS
                   WHERE SALE_DT  BETWEEN P_FR_DT AND P_TO_DT
                     AND COMP_CD        = P_COMP_CD
                     AND BRAND_CD       = P_BRAND_CD
                     AND STOR_CD        = P_STOR_CD
                     AND GIFT_DIV       = '0'                                                -- ��ǰ�Ǹ�
                   GROUP BY SALE_DT
                  UNION ALL
                  SELECT  SALE_DT                                                AS SALE_DT  -- �Ǹ�����
                        , SUM(0)                                                 AS SALE_AMT -- �������
                        , SUM(DECODE(PAY_DIV, '40', APPR_AMT - PAY_AMT, 0))      AS GIFT_AMT -- ��ǰ�Ǹ���
                        , SUM(DECODE(PAY_DIV, '20', APPR_AMT - PAY_AMT, 0))      AS CARD_AMT -- �ſ�ī�����
                    FROM SALE_JDP
                   WHERE SALE_DT  BETWEEN P_FR_DT AND P_TO_DT
                     AND COMP_CD        = P_COMP_CD
                     AND BRAND_CD       = P_BRAND_CD
                     AND STOR_CD        = P_STOR_CD
                     AND GIFT_DIV       = '0'                                                -- ��ǰ�Ǹ�
                   GROUP BY SALE_DT
                )
          GROUP BY SALE_DT    ;


      anRetVal := 1 ;
      asRetMsg := 'OK';
   Exception When OTHERS Then
      asRetMsg := SQLERRM(SQLCODE);
      anRetVal := SQLCODE ;
   END GET_PRT_07 ;

   ---------------------------------------------------------------------------------------------------
   --  Procedure Name   : GET_PRT_08
   --  Description      : ���ں��������
   -- Ref. Table        :
   ---------------------------------------------------------------------------------------------------
   --  Create Date      : 2010-03-25
   --  Create Programer : ���μ�
   --  Modify Date      : 2020-03-25
   --  Modify Programer :
   ---------------------------------------------------------------------------------------------------
   PROCEDURE GET_PRT_08
                   ( anRetVal        OUT     NUMBER  , -- ����ڵ�
                     asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                     p_cursor        OUT     rec_set.m_refcur
                   ) IS

   BEGIN
      OPEN p_cursor FOR
         SELECT  SALE_DT                    AS SALE_DT  -- �Ǹ�����
               , SUM(SALE_AMT        )      AS SALE_AMT -- �Ѹ����
               , SUM(DC_AMT + ENR_AMT)      AS ENR_AMT  -- ������
               , SUM(GRD_AMT         )      AS GRD_AMT  -- �Ǹ����(�ΰ�������)
           FROM SALE_JDS
          WHERE SALE_DT  BETWEEN P_FR_DT AND P_TO_DT
            AND COMP_CD        = P_COMP_CD
            AND BRAND_CD       = P_BRAND_CD
            AND STOR_CD        = P_STOR_CD
          GROUP BY SALE_DT   ;


      anRetVal := 1 ;
      asRetMsg := 'OK';
   Exception When OTHERS Then
      asRetMsg := SQLERRM(SQLCODE);
      anRetVal := SQLCODE ;
   END GET_PRT_08 ;


   ---------------------------------------------------------------------------------------------------
   --  Procedure Name   : GET_PRT_09
   --  Description      : ��ġ��ǰŰ��Ȳ
   -- Ref. Table        :
   ---------------------------------------------------------------------------------------------------
   --  Create Date      : 2010-03-25
   --  Create Programer : ���μ�
   --  Modify Date      : 2020-03-25
   --  Modify Programer :
   ---------------------------------------------------------------------------------------------------
   PROCEDURE GET_PRT_09
                   ( anRetVal        OUT     NUMBER  , -- ����ڵ�
                     asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                     p_cursor        OUT     rec_set.m_refcur
                   ) IS

   BEGIN
      OPEN p_cursor FOR
         WITH IT AS
                   ( SELECT  COMP_CD
                           , ITEM_CD
                           , SALE_PRC
                       FROM ITEM_CHAIN
                      WHERE COMP_CD  = P_COMP_CD
                        AND BRAND_CD = P_BRAND_CD
                        AND STOR_TP  = P_STOR_TP
                        AND USE_YN   = 'Y'
                   )
         SELECT  T.TOUCH_DIV     -- ��ġŰ���� => 1:�Ϲ�, 2:���
               , T.POSITION      -- ��ġ
               , T.TOUCH_NM      -- ��ġ ��ǰ��
               , I.SALE_PRC      -- �Ű�
           FROM TOUCH_STORE_UI T,
                IT             I
          WHERE T.COMP_CD   = I.COMP_CD
            AND T.TOUCH_CD  = I.ITEM_CD
            AND T.COMP_CD   = P_COMP_CD
            AND T.BRAND_CD  = P_BRAND_CD
            AND T.STOR_CD   = P_STOR_CD  ;


      anRetVal := 1 ;
      asRetMsg := 'OK';
   Exception When OTHERS Then
      asRetMsg := SQLERRM(SQLCODE);
      anRetVal := SQLCODE ;
   END GET_PRT_09 ;

   ---------------------------------------------------------------------------------------------------
   --  Procedure Name   : GET_PRT_10
   --  Description      : �Ǹ�����������
   -- Ref. Table        :
   ---------------------------------------------------------------------------------------------------
   --  Create Date      : 2010-03-25
   --  Create Programer : ���μ�
   --  Modify Date      : 2020-03-25
   --  Modify Programer :
   ---------------------------------------------------------------------------------------------------
   PROCEDURE GET_PRT_10
                   ( anRetVal        OUT     NUMBER  , -- ����ڵ�
                     asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                     p_cursor        OUT     rec_set.m_refcur
                   ) IS

   BEGIN
      OPEN p_cursor FOR
         WITH S_IT AS
                   ( SELECT  I.COMP_CD, I.ITEM_CD, I.ITEM_POS_NM
                           , C.L_CLASS_CD || C.S_CLASS_CD AS S_CLASS_CD
                           , C.S_CLASS_NM AS S_CLASS_NM
                       FROM (
                                SELECT  I.COMP_CD
                                     ,  I.ITEM_CD
                                     ,  I.ITEM_POS_NM
                                     ,  NVL(IC.L_CLASS_CD, I.L_CLASS_CD)    AS L_CLASS_CD
                                     ,  NVL(IC.M_CLASS_CD, I.M_CLASS_CD)    AS M_CLASS_CD
                                     ,  NVL(IC.S_CLASS_CD, I.S_CLASS_CD)    AS S_CLASS_CD
                                  FROM  ITEM_CHAIN I
                                     ,  ITEM_CLASS IC
                                 WHERE  I.COMP_CD   = IC.COMP_CD(+)
                                   AND  I.ITEM_CD   = IC.ITEM_CD(+)
                                   AND I.COMP_CD  = P_COMP_CD
                                   AND I.BRAND_CD = P_BRAND_CD
                                   AND I.STOR_TP  = P_STOR_TP
                            )           I
                          , ( SELECT * FROM ITEM_S_CLASS
                               WHERE COMP_CD      = P_COMP_CD
                                 AND ORG_CLASS_CD = '00'
                                 AND USE_YN       = 'Y'
                             )          C
                      WHERE I.COMP_CD    = C.COMP_CD
                        AND I.L_CLASS_CD = C.L_CLASS_CD
                        AND I.M_CLASS_CD = C.M_CLASS_CD
                        AND I.S_CLASS_CD = C.S_CLASS_CD
                        
                   )
         SELECT  I.S_CLASS_CD      AS S_CLASS_CD  -- �Һз������ڵ�
               , I.S_CLASS_NM      AS S_CLASS_NM  -- �Һз�������
               , SUM(SALE_QTY)     AS SALE_QTY    -- ����
               , SUM(GRD_AMT)      AS GRD_AMT     -- �Ǹ����(�ΰ�������)
               , 0                 AS CUST_CNT    -- ����
           FROM SALE_JDM   T,
                S_IT       I
          WHERE T.COMP_CD        = I.COMP_CD
            AND T.ITEM_CD        = I.ITEM_CD
            AND T.SALE_DT  BETWEEN P_FR_DT AND P_TO_DT
            AND T.COMP_CD        = P_COMP_CD
            AND T.BRAND_CD       = P_BRAND_CD
            AND T.STOR_CD        = P_STOR_CD
          GROUP BY  I.S_CLASS_CD
                  , I.S_CLASS_NM
          ORDER BY I.S_CLASS_CD  ;


      anRetVal := 1 ;
      asRetMsg := 'OK';
   Exception When OTHERS Then
      asRetMsg := SQLERRM(SQLCODE);
      anRetVal := SQLCODE ;
   END GET_PRT_10 ;

   ---------------------------------------------------------------------------------------------------
   --  Procedure Name   : GET_PRT_11
   --  Description      : ��������Ʈ��볻��
   -- Ref. Table        :
   ---------------------------------------------------------------------------------------------------
   --  Create Date      : 2010-03-25
   --  Create Programer : ���μ�
   --  Modify Date      : 2020-03-25
   --  Modify Programer :
   ---------------------------------------------------------------------------------------------------
   PROCEDURE GET_PRT_11
                   ( anRetVal        OUT     NUMBER  , -- ����ڵ�
                     asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                     p_cursor        OUT     rec_set.m_refcur
                   ) IS

   BEGIN
      OPEN p_cursor FOR
         SELECT  SALE_DT                                 AS SALE_DT     -- �Ǹ�����
               , CARD_NO                                 AS CARD_NO     -- ī���ȣ
               , APPR_NO                                 AS APPR_NO     -- ���ι�ȣ
               , APPR_AMT * DECODE(SALE_DIV, '1', 1, -1) AS APPR_AMT    -- ���αݾ�
           FROM POINT_LOG
          WHERE SALE_DT    BETWEEN P_FR_DT AND P_TO_DT
            AND COMP_CD          = P_COMP_CD
            AND BRAND_CD         = P_BRAND_CD
            AND STOR_CD          = P_STOR_CD
            AND PAY_DIV          = '60'
            AND NVL(USE_YN, 'Y') = 'Y'  ;


      anRetVal := 1 ;
      asRetMsg := 'OK';
   Exception When OTHERS Then
      asRetMsg := SQLERRM(SQLCODE);
      anRetVal := SQLCODE ;
   END GET_PRT_11 ;

   ---------------------------------------------------------------------------------------------------
   --  Procedure Name   : GET_PRT_12
   --  Description      : ��������Ʈ���ں�����
   -- Ref. Table        :
   ---------------------------------------------------------------------------------------------------
   --  Create Date      : 2010-03-25
   --  Create Programer : ���μ�
   --  Modify Date      : 2020-03-25
   --  Modify Programer :
   ---------------------------------------------------------------------------------------------------
   PROCEDURE GET_PRT_12
                   ( anRetVal        OUT     NUMBER  , -- ����ڵ�
                     asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                     p_cursor        OUT     rec_set.m_refcur
                   ) IS

   BEGIN
      OPEN p_cursor FOR
         SELECT  SUBSTR(SALE_DT, 5, 4)                                                 AS MMDD     -- ����
               , SUM(DECODE(PAY_TP, '1', 1, 0))                                        AS CNT_1    -- ���� �Ǽ�
               , SUM(DECODE(PAY_TP, '1', APPR_AMT * DECODE(SALE_DIV, '1', 1, -1), 0))  AS AMT_1    -- �����ݾ�
               , SUM(DECODE(PAY_TP, '2', 1, 0))                                        AS CNT_2    -- �Ǽ�
               , SUM(DECODE(PAY_TP, '2', APPR_AMT * DECODE(SALE_DIV, '1', 1, -1), 0))  AS AMT_2    -- ���ݾ�
           FROM POINT_LOG
          WHERE SALE_DT    BETWEEN P_FR_DT AND P_TO_DT
            AND COMP_CD          = P_COMP_CD
            AND BRAND_CD         = P_BRAND_CD
            AND STOR_CD          = P_STOR_CD
            AND PAY_DIV          = '60'
            AND NVL(USE_YN, 'Y') = 'Y'
          GROUP BY SUBSTR(SALE_DT, 5, 4) ;



      anRetVal := 1 ;
      asRetMsg := 'OK';
   Exception When OTHERS Then
      asRetMsg := SQLERRM(SQLCODE);
      anRetVal := SQLCODE ;
   END GET_PRT_12 ;

   ---------------------------------------------------------------------------------------------------
   --  Procedure Name   : GET_PRT_13
   --  Description      : LG���γ���
   -- Ref. Table        :
   ---------------------------------------------------------------------------------------------------
   --  Create Date      : 2010-03-25
   --  Create Programer : ���μ�
   --  Modify Date      : 2020-03-25
   --  Modify Programer :
   ---------------------------------------------------------------------------------------------------
   PROCEDURE GET_PRT_13
                   ( anRetVal        OUT     NUMBER  , -- ����ڵ�
                     asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                     p_cursor        OUT     rec_set.m_refcur
                   ) IS

   BEGIN
      OPEN p_cursor FOR
         SELECT  APPR_DT || APPR_TM                       AS APPR_DTM -- �Ͻ�
               , CARD_NO                                  AS CARD_NO  -- ī���ȣ
               , APPR_NO                                  AS APPR_NO  -- ���ι�ȣ
               , APPR_AMT * DECODE(SALE_DIV, '1', 1, -1)  AS APPR_AMT -- ���αݾ�
           FROM POINT_LOG
          WHERE SALE_DT    BETWEEN P_FR_DT AND P_TO_DT
            AND COMP_CD          = P_COMP_CD
            AND BRAND_CD         = P_BRAND_CD
            AND STOR_CD          = P_STOR_CD
            AND PAY_DIV          = '64'     -- SK (������)
--            AND SALE_DIV         = '1'
            AND NVL(USE_YN, 'Y') = 'Y' ;

      anRetVal := 1 ;
      asRetMsg := 'OK';
   Exception When OTHERS Then
      asRetMsg := SQLERRM(SQLCODE);
      anRetVal := SQLCODE ;
   END GET_PRT_13 ;

   ---------------------------------------------------------------------------------------------------
   --  Procedure Name   : GET_PRT_14
   --  Description      : LG���ں�����
   -- Ref. Table        :
   ---------------------------------------------------------------------------------------------------
   --  Create Date      : 2010-03-25
   --  Create Programer : ���μ�
   --  Modify Date      : 2020-03-25
   --  Modify Programer :
   ---------------------------------------------------------------------------------------------------
   PROCEDURE GET_PRT_14
                   ( anRetVal        OUT     NUMBER  , -- ����ڵ�
                     asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                     p_cursor        OUT     rec_set.m_refcur
                   ) IS

   BEGIN
      OPEN p_cursor FOR
         SELECT  MMDD                                      AS MMDD
               , APPR_CNT                                  AS APPR_CNT
               , APPR_AMT * DECODE(SALE_DIV, '1', 1, -1)   AS APPR_AMT
               , APPR_DC  * DECODE(SALE_DIV, '1', 1, -1)   AS APPR_DC
           FROM (
                  SELECT  SUBSTR(APPR_DT, 5, 4) AS MMDD       -- ����
                        , SALE_DIV              AS SALE_DIV   -- �Ǹű��� (1:����, 2: ��ǰ)
                        , COUNT(APPR_NO)        AS APPR_CNT   -- �Ǽ�(����-���)
                        , SUM(APPR_AMT)         AS APPR_AMT   -- ���αݾ�
                        , SUM(APPR_DC )         AS APPR_DC    -- ���αݾ�
                    FROM POINT_LOG
                   WHERE SALE_DT    BETWEEN P_FR_DT AND P_TO_DT
                     AND COMP_CD          = P_COMP_CD
                     AND BRAND_CD         = P_BRAND_CD
                     AND STOR_CD          = P_STOR_CD
                     AND PAY_DIV          = '66'     -- LG
                     AND NVL(USE_YN, 'Y') = 'Y'
                   GROUP BY  SUBSTR(APPR_DT, 5, 4)
                           , SALE_DIV
                )   ;



      anRetVal := 1 ;
      asRetMsg := 'OK';
   Exception When OTHERS Then
      asRetMsg := SQLERRM(SQLCODE);
      anRetVal := SQLCODE ;
   END GET_PRT_14 ;


   ---------------------------------------------------------------------------------------------------
   --  Procedure Name   : GET_PRT_15
   --  Description      : �ð��뺰 ����
   -- Ref. Table        :
   ---------------------------------------------------------------------------------------------------
   --  Create Date      : 2011-01-17
   --  Create Programer : ���μ�
   --  Modify Date      : 2011-01-17
   --  Modify Programer :
   ---------------------------------------------------------------------------------------------------
   PROCEDURE GET_PRT_15
                   ( anRetVal        OUT     NUMBER  , -- ����ڵ�
                     asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                     p_cursor        OUT     rec_set.m_refcur
                   ) IS

   BEGIN
      OPEN p_cursor FOR
         SELECT  SEC_DIV
               , SALE_QTY
               , DECODE(C.VAL_C1, 'G', GRD_AMT, 'T', SALE_AMT, GRD_AMT - VAT_AMT) AS SALE_AMT
           FROM SALE_JTS S
              , (
                    SELECT  VAL_C1
                      FROM  COMMON
                     WHERE  COMP_CD = P_COMP_CD
                       AND  CODE_TP = '01435'
                       AND  CODE_CD = '200'
                ) C 
          WHERE SALE_DT    BETWEEN P_FR_DT AND P_TO_DT
            AND COMP_CD          = P_COMP_CD
            AND BRAND_CD         = P_BRAND_CD
            AND STOR_CD          = P_STOR_CD
          ORDER BY SEC_DIV ;

      anRetVal := 1 ;
      asRetMsg := 'OK';
   Exception When OTHERS Then
      asRetMsg := SQLERRM(SQLCODE);
      anRetVal := SQLCODE ;
   END GET_PRT_15 ;

END PKG_POS_IF_GET_PRT;

/
