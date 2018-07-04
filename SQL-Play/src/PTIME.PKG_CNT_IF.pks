CREATE OR REPLACE PACKAGE      PKG_CNT_IF AS

--------------------------------------------------------------------------------
--  Procedure Name   : PKG_CNT_IF
--  Description      : CNT����
--                      SP_CNT_IF_01 => ������� ����
--                      SP_CNT_IF_02 => ������� ���� ACK
--                      SP_CNT_IF_03 => ��������� ����
--                      SP_CNT_IF_04 => ������ð� ����
--                      SP_CNT_IF_05 => CNT�ֹ� �������� ����
--------------------------------------------------------------------------------
--  Create Date      : 2015-07-01
--  Modify Date      : 2015-08-11
--------------------------------------------------------------------------------

PROCEDURE SP_CNT_IF_01
                (  asCompCd        IN   VARCHAR2, -- ȸ���ڵ�
                   asSaleDt        IN   VARCHAR2, -- �Ǹ�����
                   asBrandCd       IN   VARCHAR2, -- ��������
                   asStorCd        IN   VARCHAR2, -- �����ڵ�
                   anRetVal        OUT  NUMBER  , -- ����ڵ�
                   asRetMsg        OUT  VARCHAR2, -- ���� �޽���
                   p_cursor        OUT  rec_set.m_refcur
                ) ;

PROCEDURE SP_CNT_IF_02
                (  asCompCd        IN   VARCHAR2, -- ȸ���ڵ�
                   asSaleDt        IN   VARCHAR2, -- �Ǹ�����
                   asBrandCd       IN   VARCHAR2, -- ��������
                   asStorCd        IN   VARCHAR2, -- �����ڵ�
                   asReciveNo      IN   VARCHAR2, -- ���Ź�ȣ
                   anRetVal        OUT  NUMBER  , -- ����ڵ�
                   asRetMsg        OUT  VARCHAR2, -- ���� �޽���
                   p_cursor        OUT  rec_set.m_refcur
                ) ;

PROCEDURE SP_CNT_IF_03
                (  asCompCd        IN   VARCHAR2, -- ȸ���ڵ�
                   asSaleDt        IN   VARCHAR2, -- �Ǹ�����
                   asBrandCd       IN   VARCHAR2, -- ��������
                   asStorCd        IN   VARCHAR2, -- �����ڵ�
                   anRetVal        OUT  NUMBER  , -- ����ڵ�
                   asRetMsg        OUT  VARCHAR2, -- ���� �޽���
                   p_cursor        OUT  rec_set.m_refcur
                ) ;

PROCEDURE SP_CNT_IF_04
                (  asCompCd        IN   VARCHAR2, -- ȸ���ڵ�
                   asSaleDt        IN   VARCHAR2, -- �Ǹ�����
                   asBrandCd       IN   VARCHAR2, -- ��������
                   asStorCd        IN   VARCHAR2, -- �����ڵ�
                   anRetVal        OUT  NUMBER  , -- ����ڵ�
                   asRetMsg        OUT  VARCHAR2, -- ���� �޽���
                   p_cursor        OUT  rec_set.m_refcur
                ) ;

PROCEDURE SP_CNT_IF_05
                (  asCompCd        IN   VARCHAR2, -- ȸ���ڵ�
                   asSaleDt        IN   VARCHAR2, -- �Ǹ�����
                   asBrandCd       IN   VARCHAR2, -- ��������
                   asStorCd        IN   VARCHAR2, -- �����ڵ�
                   asCntOrdNo      IN   VARCHAR2, -- CNT�ֹ���ȣ
                   asMakeYn        IN   VARCHAR2, -- ��������
                   anRetVal        OUT  NUMBER  , -- ����ڵ�
                   asRetMsg        OUT  VARCHAR2, -- ���� �޽���
                   p_cursor        OUT  rec_set.m_refcur
                ) ;
                
END PKG_CNT_IF;

/

CREATE OR REPLACE PACKAGE BODY      PKG_CNT_IF AS
 
  --------------------------------------------------------------------------------
  --  Procedure Name   : SP_CNT_IF_01
  --  Description      : ������� ����
  -- Ref. Table        : CNT_SALE_HD, CNT_SALE_DT, CNT_SALE_ST
  --------------------------------------------------------------------------------
  --  Create Date      : 2015-07-01
  --  Modify Date      : 2015-08-11
  --------------------------------------------------------------------------------
  PROCEDURE SP_CNT_IF_01
  (  
    asCompCd        IN   VARCHAR2, -- ȸ���ڵ�
    asSaleDt        IN   VARCHAR2, -- �Ǹ�����
    asBrandCd       IN   VARCHAR2, -- ��������
    asStorCd        IN   VARCHAR2, -- �����ڵ�
    anRetVal        OUT  NUMBER  , -- ����ڵ�
    asRetMsg        OUT  VARCHAR2, -- ���� �޽���
    p_cursor        OUT  rec_set.m_refcur
  ) IS
  
  LS_RECIVE_NO  NUMBER(10);
  
  BEGIN
    -- ��� �����Ϸù�ȣ ��ȸ
    SELECT  SQ_CNT_SALE_RECIVE_NO.NEXTVAL
      INTO  LS_RECIVE_NO
      FROM  DUAL;
    
    -- ��� �̼��� ������ ���� ������Ʈ
    UPDATE  CNT_SALE_HD SH
       SET  RECIVE_YN = 'A'
         ,  RECIVE_NO = LS_RECIVE_NO
     WHERE  SALE_DT   = asSaleDt
       AND  STOR_CD   = asStorCd
       AND  RECIVE_YN IN ('A', 'N')
       AND  EXISTS  (
                        SELECT  '1'
                          FROM  CNT_SALE_DT
                         WHERE  SALE_DT     = SH.SALE_DT
                           AND  STOR_CD     = SH.STOR_CD
                           AND  CNT_ORD_NO  = SH.CNT_ORD_NO
                    )
       AND  EXISTS  (
                        SELECT  '1'
                          FROM  CNT_SALE_ST
                         WHERE  SALE_DT     = SH.SALE_DT
                           AND  STOR_CD     = SH.STOR_CD
                           AND  CNT_ORD_NO  = SH.CNT_ORD_NO
                    )
       AND  ROWNUM   <= 50;
    
    UPDATE  CNT_SALE_DT
       SET  RECIVE_YN = 'A'
         ,  RECIVE_NO = LS_RECIVE_NO
     WHERE  SALE_DT   = asSaleDt
       AND  STOR_CD   = asStorCd
       AND  CNT_ORD_NO IN   (
                                SELECT  CNT_ORD_NO
                                  FROM  CNT_SALE_HD
                                 WHERE  SALE_DT   = asSaleDt
                                   AND  STOR_CD   = asStorCd
                                   AND  RECIVE_NO = LS_RECIVE_NO
                            );
    UPDATE  CNT_SALE_ST
       SET  RECIVE_YN = 'A'
         ,  RECIVE_NO = LS_RECIVE_NO
     WHERE  SALE_DT   = asSaleDt
       AND  STOR_CD   = asStorCd
       AND  CNT_ORD_NO IN   (
                                SELECT  CNT_ORD_NO
                                  FROM  CNT_SALE_HD
                                 WHERE  SALE_DT   = asSaleDt
                                   AND  STOR_CD   = asStorCd
                                   AND  RECIVE_NO = LS_RECIVE_NO
                            );
                            
    OPEN p_cursor FOR
    SELECT  *
      FROM  (
                SELECT  LS_RECIVE_NO    AS RECIVE_NO        -- 01 : �����Ϸù�ȣ(����)
                     ,  'H'             AS TABLE_DIV        -- 02 : ��� ���̺� ����(H : �������, D : ��ǰ����, S : ��������)
                     ,  (
                            SELECT  COUNT(*)
                              FROM  CNT_SALE_HD
                             WHERE  SALE_DT     = asSaleDt
                               AND  STOR_CD     = asStorCd
                               AND  RECIVE_YN   IN ('A', 'N')
                               AND  RECIVE_NO   = LS_RECIVE_NO
                        )               AS SALE_HD_CNT      -- 03 : ��� ���ŰǼ�(���)
                     ,  SALE_DT                             -- 04 : �Ǹ�����(����)
                     ,  STOR_CD                             -- 05 : �����ڵ�(����)
                     ,  CNT_ORD_NO                          -- 06 : CNT��ũ �ֹ���ȣ(����)
                     ,  SALE_DIV                            -- 07 : �Ǹű���[1:����, 2:��ǰ](����)
                     ,  SORD_TM                             -- 08 : �ֹ��ð�(���)
                     ,  SALE_TM                             -- 09 : �����ð�(���)
                     ,  CUST_AGE                            -- 10 : ������(���)
                     ,  CUST_M_CNT                          -- 11 : ���ڰ���(���)
                     ,  CUST_F_CNT                          -- 12 : ���ڰ���(���)
                     ,  CUST_NO                             -- 13 : ��ID(���)
                     ,  VOID_BEFORE_DT                      -- 14 : ��ǰ�� �� �Ǹ�����(���)
                     ,  VOID_BEFORE_NO                      -- 15 : ��ǰ�� �� �ֹ���ȣ(���)
                     ,  RTN_MEMO                            -- 16 : ��ǰ����(���)
                     ,  SALE_QTY        AS HD_SALE_QTY      -- 17 : �Ǹż���(���)
                     ,  SALE_AMT        AS HD_SALE_AMT      -- 18 : �Ǹűݾ�(���)
                     ,  GRD_AMT         AS HD_GRID_AMT      -- 19 : TAKE OUT ���Ǹűݾ�(���)
                     ,  VAT_AMT         AS HD_VAT_AMT       -- 20 : TAKE OUT �ΰ���(���)
                     ,  SALE_TYPE                           -- 21 : �Ǹ����� [1:�Ϲ�, 2:���](���)
                     ,  CUST_CARD                           -- 22 : ����� ī���ȣ(���)
                     ,  APPR_NO         AS HD_APPR_NO       -- 23 : ����Ʈ���� ���ι�ȣ(���)
                     ,  CPOINT                              -- 24 : ������ ��������Ʈ(���)
                     ,  APOINT                              -- 25 : �߻�����Ʈ(���)
                     ,  TPOINT                              -- 26 : ���� ��������Ʈ(���)
                     ,  APPR_MSG1                           -- 27 : ��ǰ�� �� ���ι�ȣ(���)
                     ,  APPR_MSG2                           -- 28 : ���� ���� �ڵ�(���)
                     ,  APPR_MSG3                           -- 29 : ���� ���� �޼���(���)
                     ,  CUST_NM                             -- 30 : ����Ʈ ���� ��� ����(���)
                     ,  CUST_TEL                            -- 31 : ����Ʈ ���� �� �ڵ��� ��ȣ
                     ,  POINT_S                             -- 32 : ����Ʈ ������(���)
                     ,  DLV_CUST_NM                         -- 33 : �ֹ�����(���)
                     ,  DLV_CUST_TEL                        -- 34 : �ֹ��� ����ó(���)
                     ,  DLV_CUST_ADDR                       -- 35 : �ֹ��� �⺻�ּ�(���)
                     ,  DLV_CUST_ADDR2                      -- 36 : �ֹ��� ���ּ�(���)
                     ,  DLV_MEMO                            -- 37 : ��޸޸�(���)
                     ,  RESV_YN                             -- 38 : �����ֹ�����
                     ,  DLV_TM                              -- 39 : ��۹��� �ð�
                     ,  CHANNEL_TP                          -- 40 : ä�α���(1:CALL, 2:WEB, 3:APP)
                     ,  0               AS DT_SEQ           -- 41 : ��ǰ����(��ǰ)
                     ,  ''              AS DT_SORD_TM       -- 42 : �ֹ��ð�(��ǰ)
                     ,  ''              AS DT_SALE_TM       -- 43 : �ǸŽð�(��ǰ)
                     ,  0               AS T_SEQ            -- 44 : �ָ޴��� ���� ����(��ǰ)
                     ,  ''              AS ITEM_CD          -- 45 : �޴��ڵ�(��ǰ)
                     ,  ''              AS MAIN_ITEM_CD     -- 46 : �ָ޴��ڵ�(��ǰ)
                     ,  ''              AS SUB_TOUCH_GR_CD  -- 47 : �ɼ�/�ΰ� �׷��ڵ�(��ǰ)
                     ,  ''              AS SUB_TOUCH_CD     -- 48 : �ɼ�/�ΰ� �ڵ�(��ǰ)
                     ,  ''              AS ITEM_SET_DIV     -- 49 : SET����(��ǰ)
                     ,  0               AS SALE_PRC         -- 50 : �ǸŴܰ�(��ǰ)
                     ,  0               AS DT_SALE_QTY      -- 51 : �Ǹż���(��ǰ)
                     ,  0               AS DT_SALE_AMT      -- 52 : �Ǹűݾ�(��ǰ)
                     ,  0               AS DT_GRD_AMT       -- 53 : �������[������](��ǰ)
                     ,  0               AS DT_NET_AMT       -- 54 : �������[������](��ǰ)
                     ,  0               AS VAT_RATE         -- 55 : �ΰ�����(��ǰ)
                     ,  0               AS DT_VAT_AMT       -- 56 : �ΰ���(��ǰ)
                     ,  0               AS TR_GR_NO         -- 57 : �Ǹű׷��ȣ(��ǰ)
                     ,  ''              AS SALE_VAT_YN      -- 58 : �ǸŰ�������[Y:����, N:�鼼](��ǰ)
                     ,  ''              AS SALE_VAT_RULE    -- 59 : �Ǹ�VAT������[1:�ΰ�������, 2:�ΰ���������](��ǰ)
                     ,  ''              AS CUST_ID          -- 60 : ȸ��ID(��ǰ)
                     ,  0               AS SAV_PT           -- 61 : ��������Ʈ(��ǰ)
                     ,  0               AS ST_SEQ           -- 62 : ��������(����)
                     ,  ''              AS PAY_DIV          -- 63 : ��������(����)
                     ,  ''              AS APPR_MAEIP_CD    -- 64 : ���Ի��ڵ�(����)
                     ,  ''              AS APPR_MAEIP_NM    -- 65 : ���Ի��(����)
                     ,  ''              AS APPR_VAL_CD      -- 66 : �߱޻��ڵ�(����)
                     ,  ''              AS CARD_NO          -- 67 : ī���ȣ(����)
                     ,  ''              AS CARD_NM          -- 68 : ī���(����)
                     ,  ''              AS ALLOT_LMT        -- 69 : �Һΰ���(����)
                     ,  ''              AS ST_APPR_NO       -- 70 : ���ι�ȣ(����)
                     ,  ''              AS APPR_DT          -- 71 : ��������(����)
                     ,  ''              AS APPR_TM          -- 72 : ���νð�(����)
                     ,  0               AS APPR_AMT         -- 73 : ���αݾ�(����)
                     ,  0               AS PAY_AMT          -- 74 : �����ݾ�(����)
                     ,  ''              AS SALER_DT         -- 75 : �����ð�(����)
                  FROM  CNT_SALE_HD
                 WHERE  SALE_DT   = asSaleDt
                   AND  STOR_CD   = asStorCd
                   AND  RECIVE_YN IN ('A', 'N')
                   AND  RECIVE_NO   = LS_RECIVE_NO
                UNION ALL
                SELECT  LS_RECIVE_NO    AS RECIVE_NO        -- 01 : �����Ϸù�ȣ(����)
                     ,  'D'             AS TABLE_DIV        -- 02 : ��� ���̺� ����(H : �������, D : ��ǰ����, S : ��������)
                     ,  0               AS SALE_HD_CNT      -- 03 : ��� ���ŰǼ�(���)
                     ,  SALE_DT                             -- 04 : �Ǹ�����(����)
                     ,  STOR_CD                             -- 05 : �����ڵ�(����)
                     ,  CNT_ORD_NO                          -- 06 : CNT��ũ �ֹ���ȣ(����)
                     ,  SALE_DIV                            -- 07 : �Ǹű���[1:����, 2:��ǰ](����)
                     ,  ''              AS SORD_TM          -- 08 : �ֹ��ð�(���)
                     ,  ''              AS SALE_TM          -- 09 : �����ð�(���)
                     ,  0               AS CUST_AGE         -- 10 : ������(���)
                     ,  0               AS CUST_M_CNT       -- 11 : ���ڰ���(���)
                     ,  0               AS CUST_F_CNT       -- 12 : ���ڰ���(���)
                     ,  ''              AS CUST_NO          -- 13 : ��ID(���)
                     ,  ''              AS VOID_BEFORE_DT   -- 14 : ��ǰ�� �� �Ǹ�����(���)
                     ,  ''              AS VOID_BEFORE_NO   -- 15 : ��ǰ�� �� �ֹ���ȣ(���)
                     ,  ''              AS RTN_MEMO         -- 16 : ��ǰ����(���)
                     ,  0               AS HD_SALE_QTY      -- 17 : �Ǹż���(���)
                     ,  0               AS HD_SALE_AMT      -- 18 : �Ǹűݾ�(���)
                     ,  0               AS HD_GRD_AMT       -- 19 : TAKE OUT ���Ǹűݾ�(���)
                     ,  0               AS HD_VAT_AMT       -- 20 : TAKE OUT �ΰ���(���)
                     ,  SALE_TYPE                           -- 21 : �Ǹ����� [1:�Ϲ�, 2:���](����)
                     ,  ''              AS CUST_CARD        -- 22 : ����� ī���ȣ(���)
                     ,  ''              AS APPR_NO          -- 23 : ����Ʈ���� ���ι�ȣ(���)
                     ,  0               AS CPOINT           -- 24 : ������ ��������Ʈ(���)
                     ,  0               AS APOINT           -- 25 : �߻�����Ʈ(���)
                     ,  0               AS TPOINT           -- 26 : ���� ��������Ʈ(���)
                     ,  ''              AS APPR_MSG1        -- 27 : ��ǰ�� �� ���ι�ȣ(���)
                     ,  ''              AS APPR_MSG2        -- 28 : ���� ���� �ڵ�(���)
                     ,  ''              AS APPR_MSG3        -- 29 : ���� ���� �޼���(���)
                     ,  ''              AS CUST_NM          -- 30 : ����Ʈ ���� ��� ����(���)
                     ,  ''              AS CUST_TEL         -- 31 : ����Ʈ ���� �� �ڵ��� ��ȣ(���)
                     ,  0               AS POINT_S          -- 32 : ����Ʈ ������(���)
                     ,  ''              AS DLV_CUST_NM      -- 33 : �ֹ�����(���)
                     ,  ''              AS DLV_CUST_TEL     -- 34 : �ֹ��� ����ó(���)
                     ,  ''              AS DLV_CUST_ADDR    -- 35 : �ֹ��� �⺻�ּ�(���)
                     ,  ''              AS DLV_CUST_ADDR2   -- 36 : �ֹ��� ���ּ�(���)
                     ,  ''              AS DLV_MEMO         -- 37 : ��޸޸�(���)
                     ,  ''              AS RESV_YN          -- 38 : �����ֹ�����
                     ,  ''              AS DLV_TM           -- 39 : ��۹��� �ð�
                     ,  ''              AS CHANNEL_TP       -- 40 : ä�α���(1:CALL, 2:WEB, 3:APP)
                     ,  SEQ             AS DT_SEQ           -- 41 : ��ǰ����(��ǰ)
                     ,  SORD_TM         AS DT_SORD_TM       -- 42 : �ֹ��ð�(��ǰ)
                     ,  SALE_TM         AS DT_SALE_TM       -- 43 : �ǸŽð�(��ǰ)
                     ,  T_SEQ                               -- 44 : �ָ޴��� ���� ����(��ǰ)
                     ,  ITEM_CD                             -- 45 : �޴��ڵ�(��ǰ)
                     ,  MAIN_ITEM_CD                        -- 46 : �ָ޴��ڵ�(��ǰ)
                     ,  SUB_TOUCH_GR_CD                     -- 47 : �ɼ�/�ΰ� �׷��ڵ�(��ǰ)
                     ,  SUB_TOUCH_CD                        -- 48 : �ɼ�/�ΰ� �ڵ�(��ǰ)
                     ,  ITEM_SET_DIV                        -- 49 : SET����(��ǰ)
                     ,  SALE_PRC                            -- 50 : �ǸŴܰ�(��ǰ)
                     ,  SALE_QTY        AS DT_SALE_QTY      -- 51 : �Ǹż���(��ǰ)
                     ,  SALE_AMT        AS DT_SALE_AMT      -- 52 : �Ǹűݾ�(��ǰ)
                     ,  GRD_AMT         AS DT_GRD_AMT       -- 53 : �������[������](��ǰ)
                     ,  NET_AMT         AS DT_NET_AMT       -- 54 : �������[������](��ǰ)
                     ,  VAT_RATE                            -- 55 : �ΰ�����(��ǰ)
                     ,  VAT_AMT         AS DT_VAT_AMT       -- 56 : �ΰ���(��ǰ)
                     ,  TR_GR_NO                            -- 57 : �Ǹű׷��ȣ(��ǰ)
                     ,  SALE_VAT_YN                         -- 58 : �ǸŰ�������[Y:����, N:�鼼](��ǰ)
                     ,  SALE_VAT_RULE                       -- 59 : �Ǹ�VAT������[1:�ΰ�������, 2:�ΰ���������](��ǰ)
                     ,  CUST_ID                             -- 60 : ȸ��ID(��ǰ)
                     ,  SAV_PT                              -- 61 : ��������Ʈ(��ǰ)
                     ,  0               AS ST_SEQ           -- 62 : ��������(����)
                     ,  ''              AS PAY_DIV          -- 63 : ��������(����)
                     ,  ''              AS APPR_MAEIP_CD    -- 64 : ���Ի��ڵ�(����)
                     ,  ''              AS APPR_MAEIP_NM    -- 65 : ���Ի��(����)
                     ,  ''              AS APPR_VAL_CD      -- 66 : �߱޻��ڵ�(����)
                     ,  ''              AS CARD_NO          -- 67 : ī���ȣ(����)
                     ,  ''              AS CARD_NM          -- 68 : ī���(����)
                     ,  ''              AS ALLOT_LMT        -- 69 : �Һΰ���(����)
                     ,  ''              AS ST_APPR_NO       -- 70 : ���ι�ȣ(����)
                     ,  ''              AS APPR_DT          -- 71 : ��������(����)
                     ,  ''              AS APPR_TM          -- 72 : ���νð�(����)
                     ,  0               AS APPR_AMT         -- 73 : ���αݾ�(����)
                     ,  0               AS PAY_AMT          -- 74 : �����ݾ�(����)
                     ,  ''              AS SALER_DT         -- 75 : �����ð�(����)
                  FROM  CNT_SALE_DT
                 WHERE  SALE_DT   = asSaleDt
                   AND  STOR_CD   = asStorCd
                   AND  RECIVE_YN IN ('A', 'N')
                   AND  RECIVE_NO = LS_RECIVE_NO
                UNION ALL
                SELECT  LS_RECIVE_NO    AS RECIVE_NO        -- 01 : �����Ϸù�ȣ(����)
                     ,  'S'             AS TABLE_DIV        -- 02 : ��� ���̺� ����(H : �������, D : ��ǰ����, S : ��������)
                     ,  0               AS SALE_HD_CNT      -- 03 : ��� ���ŰǼ�(���)
                     ,  SALE_DT                             -- 04 : �Ǹ�����(����)
                     ,  STOR_CD                             -- 05 : �����ڵ�(����)
                     ,  CNT_ORD_NO                          -- 06 : CNT��ũ �ֹ���ȣ(����)
                     ,  SALE_DIV                            -- 07 : �Ǹű���[1:����, 2:��ǰ](����)
                     ,  ''              AS SORD_TM          -- 08 : �ֹ��ð�(���)
                     ,  ''              AS SALE_TM          -- 09 : �����ð�(���)
                     ,  0               AS CUST_AGE         -- 10 : ������(���)
                     ,  0               AS CUST_M_CNT       -- 11 : ���ڰ���(���)
                     ,  0               AS CUST_F_CNT       -- 12 : ���ڰ���(���)
                     ,  ''              AS CUST_NO          -- 13 : ��ID(���)
                     ,  ''              AS VOID_BEFORE_DT   -- 14 : ��ǰ�� �� �Ǹ�����(���)
                     ,  ''              AS VOID_BEFORE_NO   -- 15 : ��ǰ�� �� �ֹ���ȣ(���)
                     ,  ''              AS RTN_MEMO         -- 16 : ��ǰ����(���)
                     ,  0               AS HD_SALE_QTY      -- 17 : �Ǹż���(���)
                     ,  0               AS HD_SALE_AMT      -- 18 : �Ǹűݾ�(���)
                     ,  0               AS HD_GRD_AMT       -- 19 : TAKE OUT ���Ǹűݾ�(���)
                     ,  0               AS HD_VAT_AMT       -- 20 : TAKE OUT �ΰ���(���)
                     ,  SALE_TYPE                           -- 21 : �Ǹ����� [1:�Ϲ�, 2:���](����)
                     ,  ''              AS CUST_CARD        -- 22 : ����� ī���ȣ(���)
                     ,  ''              AS HD_APPR_NO       -- 23 : ����Ʈ���� ���ι�ȣ(���)
                     ,  0               AS CPOINT           -- 24 : ������ ��������Ʈ(���)
                     ,  0               AS APOINT           -- 25 : �߻�����Ʈ(���)
                     ,  0               AS TPOINT           -- 26 : ���� ��������Ʈ(���)
                     ,  ''              AS APPR_MSG1        -- 27 : ��ǰ�� �� ���ι�ȣ(���)
                     ,  ''              AS APPR_MSG2        -- 28 : ���� ���� �ڵ�(���)
                     ,  ''              AS APPR_MSG3        -- 29 : ���� ���� �޼���(���)
                     ,  ''              AS CUST_NM          -- 30 : ����Ʈ ���� ��� ����(���)
                     ,  ''              AS CUST_TEL         -- 31 : ����Ʈ ���� �� �ڵ��� ��ȣ(���)
                     ,  0               AS POINT_S          -- 32 : ����Ʈ ������(���)
                     ,  ''              AS DLV_CUST_NM      -- 33 : �ֹ�����(���)
                     ,  ''              AS DLV_CUST_TEL     -- 34 : �ֹ��� ����ó(���)
                     ,  ''              AS DLV_CUST_ADDR    -- 35 : �ֹ��� �⺻�ּ�(���)
                     ,  ''              AS DLV_CUST_ADDR2   -- 36 : �ֹ��� ���ּ�(���)
                     ,  ''              AS DLV_MEMO         -- 37 : ��޸޸�(���)
                     ,  ''              AS RESV_YN          -- 38 : �����ֹ�����
                     ,  ''              AS DLV_TM           -- 39 : ��۹��� �ð�
                     ,  ''              AS CHANNEL_TP       -- 40 : ä�α���(1:CALL, 2:WEB, 3:APP)
                     ,  0               AS DT_SEQ           -- 41 : ��ǰ����(��ǰ)
                     ,  ''              AS DT_SORD_TM       -- 42 : �ֹ��ð�(��ǰ)
                     ,  ''              AS DT_SALE_TM       -- 43 : �ǸŽð�(��ǰ)
                     ,  0               AS T_SEQ            -- 44 : �ָ޴��� ���� ����(��ǰ)
                     ,  ''              AS ITEM_CD          -- 45 : �޴��ڵ�(��ǰ)
                     ,  ''              AS MAIN_ITEM_CD     -- 46 : �ָ޴��ڵ�(��ǰ)
                     ,  ''              AS SUB_TOUCH_GR_CD  -- 47 : �ɼ�/�ΰ� �׷��ڵ�(��ǰ)
                     ,  ''              AS SUB_TOUCH_CD     -- 48 : �ɼ�/�ΰ� �ڵ�(��ǰ)
                     ,  ''              AS ITEM_SET_DIV     -- 49 : SET����(��ǰ)
                     ,  0               AS SALE_PRC         -- 50 : �ǸŴܰ�(��ǰ)
                     ,  0               AS DT_SALE_QTY      -- 51 : �Ǹż���(��ǰ)
                     ,  0               AS DT_SALE_AMT      -- 52 : �Ǹűݾ�(��ǰ)
                     ,  0               AS DT_GRD_AMT       -- 53 : �������[������](��ǰ)
                     ,  0               AS DT_NET_AMT       -- 54 : �������[������](��ǰ)
                     ,  0               AS VAT_RATE         -- 55 : �ΰ�����(��ǰ)
                     ,  0               AS DT_VAT_AMT       -- 56 : �ΰ���(��ǰ)
                     ,  0               AS TR_GR_NO         -- 57 : �Ǹű׷��ȣ(��ǰ)
                     ,  ''              AS SALE_VAT_YN      -- 58 : �ǸŰ�������[Y:����, N:�鼼](��ǰ)
                     ,  ''              AS SALE_VAT_RULE    -- 59 : �Ǹ�VAT������[1:�ΰ�������, 2:�ΰ���������](��ǰ)
                     ,  ''              AS CUST_ID          -- 60 : ȸ��ID(��ǰ)
                     ,  0               AS SAV_PT           -- 61 : ��������Ʈ(��ǰ)
                     ,  SEQ             AS ST_SEQ           -- 62 : ��������(����)
                     ,  PAY_DIV                             -- 63 : ��������(����)
                     ,  APPR_MAEIP_CD                       -- 64 : ���Ի��ڵ�(����)
                     ,  APPR_MAEIP_NM                       -- 65 : ���Ի��(����)
                     ,  APPR_VAL_CD                         -- 66 : �߱޻��ڵ�(����)
                     ,  CARD_NO                             -- 67 : ī���ȣ(����)
                     ,  CARD_NM                             -- 68 : ī���(����)
                     ,  ALLOT_LMT                           -- 69 : �Һΰ���(����)
                     ,  APPR_NO         AS ST_APPR_NO       -- 70 : ���ι�ȣ(����)
                     ,  APPR_DT                             -- 71 : ��������(����)
                     ,  APPR_TM                             -- 72 : ���νð�(����)
                     ,  APPR_AMT                            -- 73 : ���αݾ�(����)
                     ,  PAY_AMT                             -- 74 : �����ݾ�(����)
                     ,  SALER_DT                            -- 75 : �����ð�(����)
                  FROM  CNT_SALE_ST
                 WHERE  SALE_DT   = asSaleDt
                   AND  STOR_CD   = asStorCd
                   AND  RECIVE_YN IN ('A', 'N')
                   AND  RECIVE_NO = LS_RECIVE_NO
            )
     ORDER  BY CNT_ORD_NO, TABLE_DIV, DT_SEQ, ST_SEQ
    ;

    COMMIT;
    
    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END SP_CNT_IF_01;
  
  --------------------------------------------------------------------------------
  --  Procedure Name   : SP_CNT_IF_02
  --  Description      : ������� ���� ACK
  -- Ref. Table        : CNT_SALE_HD, CNT_SALE_DT, CNT_SALE_ST
  --------------------------------------------------------------------------------
  --  Create Date      : 2015-07-01
  --  Modify Date      : 2015-08-11
  --------------------------------------------------------------------------------
  PROCEDURE SP_CNT_IF_02 
  (
    asCompCd        IN   VARCHAR2, -- ȸ���ڵ�
    asSaleDt        IN   VARCHAR2, -- �Ǹ�����
    asBrandCd       IN   VARCHAR2, -- ��������
    asStorCd        IN   VARCHAR2, -- �����ڵ�
    asReciveNo      IN   VARCHAR2, -- ���Ź�ȣ
    anRetVal        OUT  NUMBER  , -- ����ڵ�
    asRetMsg        OUT  VARCHAR2, -- ���� �޽���
    p_cursor        OUT  rec_set.m_refcur
  ) IS
  
  BEGIN
    UPDATE  CNT_SALE_HD
       SET  RECIVE_YN = 'Y'
         ,  RECIVE_TM = TO_CHAR(SYSDATE, 'HH24MISS')
     WHERE  SALE_DT   = asSaleDt
       AND  STOR_CD   = asStorCd
       AND  RECIVE_NO = asReciveNo;
    
    UPDATE  CNT_SALE_DT
       SET  RECIVE_YN = 'Y'
         ,  RECIVE_TM = TO_CHAR(SYSDATE, 'HH24MISS')
     WHERE  SALE_DT   = asSaleDt
       AND  STOR_CD   = asStorCd
       AND  RECIVE_NO = asReciveNo;
       
    UPDATE  CNT_SALE_ST
       SET  RECIVE_YN = 'Y'
         ,  RECIVE_TM = TO_CHAR(SYSDATE, 'HH24MISS')
     WHERE  SALE_DT   = asSaleDt
       AND  STOR_CD   = asStorCd
       AND  RECIVE_NO = asReciveNo;
    
    COMMIT;
    
    anRetVal := 1;
    asRetMsg := 'OK';
    
    OPEN p_cursor FOR
    SELECT  'OK'
      FROM  DUAL;
      
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END SP_CNT_IF_02;
  
  --------------------------------------------------------------------------------
  --  Procedure Name   : SP_CNT_IF_03
  --  Description      : ��������� ����
  -- Ref. Table        : STORE_CNT
  --------------------------------------------------------------------------------
  --  Create Date      : 2015-07-01
  --  Modify Date      : 2015-08-11
  --------------------------------------------------------------------------------
  PROCEDURE SP_CNT_IF_03
  (  
    asCompCd        IN   VARCHAR2, -- ȸ���ڵ�
    asSaleDt        IN   VARCHAR2, -- �Ǹ�����
    asBrandCd       IN   VARCHAR2, -- ��������
    asStorCd        IN   VARCHAR2, -- �����ڵ�
    anRetVal        OUT  NUMBER  , -- ����ڵ�
    asRetMsg        OUT  VARCHAR2, -- ���� �޽���
    p_cursor        OUT  rec_set.m_refcur
  ) IS
  
  BEGIN
                                
    OPEN p_cursor FOR
    SELECT  SC.BRAND_CD
         ,  SC.STOR_CD
         ,  SC.CALL_ORD_YN
         ,  SC.ONLINE_ORD_YN
         ,  SC.TAKE_OUT_ORD_YN
         ,  SC.DELIVERY_ORD_YN
         ,  SC.DELIVERY_HM
         ,  SC.RESERVE_HM
         ,  CASE WHEN SH.START_DT IS NULL THEN 'N'
                 ELSE 'Y'
            END                 AS HOLIDAY_YN
      FROM  STORE_CNT       SC
         ,  STORE_HOLIDAY   SH
     WHERE  SC.COMP_CD  = SH.COMP_CD(+)
       AND  SC.BRAND_CD = SH.BRAND_CD(+)
       AND  SC.STOR_CD  = SH.STOR_CD(+)
       AND  SC.COMP_CD  = asCompCd
       AND  SC.BRAND_CD = asBrandCd
       AND  SC.STOR_CD  = asStorCd
       AND  SH.START_DT(+) = TO_CHAR(SYSDATE, 'YYYYMMDD')
    ;

    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END SP_CNT_IF_03;
  
  --------------------------------------------------------------------------------
  --  Procedure Name   : SP_CNT_IF_04
  --  Description      : ������ð� ����
  -- Ref. Table        : STORE_WEEK
  --------------------------------------------------------------------------------
  --  Create Date      : 2015-07-01
  --  Modify Date      : 2015-08-11
  --------------------------------------------------------------------------------
  PROCEDURE SP_CNT_IF_04
  (  
    asCompCd        IN   VARCHAR2, -- ȸ���ڵ�
    asSaleDt        IN   VARCHAR2, -- �Ǹ�����
    asBrandCd       IN   VARCHAR2, -- ��������
    asStorCd        IN   VARCHAR2, -- �����ڵ�
    anRetVal        OUT  NUMBER  , -- ����ڵ�
    asRetMsg        OUT  VARCHAR2, -- ���� �޽���
    p_cursor        OUT  rec_set.m_refcur
  ) IS
  
  BEGIN
                                
    OPEN p_cursor FOR
    SELECT  BRAND_CD
         ,  STOR_CD
         ,  WEEK_DAY
         ,  START_HM
         ,  CLOSE_HM
      FROM  STORE_WEEK
     WHERE  COMP_CD     = asCompCd
       AND  BRAND_CD    = asBrandCd
       AND  STOR_CD     = asStorCd
    ;

    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END SP_CNT_IF_04;
  
  --------------------------------------------------------------------------------
  --  Procedure Name   : SP_CNT_IF_02
  --  Description      : ������� ���� ACK
  -- Ref. Table        : CNT_SALE_HD, CNT_SALE_DT, CNT_SALE_ST
  --------------------------------------------------------------------------------
  --  Create Date      : 2015-07-01
  --  Modify Date      : 2015-08-11
  --------------------------------------------------------------------------------
  PROCEDURE SP_CNT_IF_05
  (  asCompCd        IN   VARCHAR2, -- ȸ���ڵ�
     asSaleDt        IN   VARCHAR2, -- �Ǹ�����
     asBrandCd       IN   VARCHAR2, -- ��������
     asStorCd        IN   VARCHAR2, -- �����ڵ�
     asCntOrdNo      IN   VARCHAR2, -- CNT�ֹ���ȣ
     asMakeYn        IN   VARCHAR2, -- ��������
     anRetVal        OUT  NUMBER  , -- ����ڵ�
     asRetMsg        OUT  VARCHAR2, -- ���� �޽���
     p_cursor        OUT  rec_set.m_refcur
  ) IS
  
  BEGIN
    UPDATE  CNT_SALE_HD
       SET  MAKE_YN   = asMakeYn
         ,  MAKE_TM   = TO_CHAR(SYSDATE, 'HH24MISS')
     WHERE  SALE_DT   = asSaleDt
       AND  STOR_CD   = asStorCd
       AND  CNT_ORD_NO= asCntOrdNo;
    
    COMMIT;
    
    anRetVal := 1;
    asRetMsg := 'OK';
    
    OPEN p_cursor FOR
    SELECT  'OK'
      FROM  DUAL;
      
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END SP_CNT_IF_05;
  
END PKG_CNT_IF;

/
