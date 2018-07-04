CREATE OR REPLACE PACKAGE       PKG_POS_CUST_ACK AS 
-------------------------------------------------------------------------------- 
--  Package Name     : PKG_POS_CUST_ACK 
--  Description      : POS ����� ��û ����(���Ϲ��)
--  Ref. Table       :  
-------------------------------------------------------------------------------- 
--  Create Date      : 2015-01-13 
--  Modify Date      : 2015-01-13  
-------------------------------------------------------------------------------- 
   
  P_COMP_CD        VARCHAR2(4)  := '';  -- DEFAULT 
  P_BRAND_CD       VARCHAR2(4)  := ''; 
  P_STOR_CD        VARCHAR2(10) := '';   
   
  PROCEDURE GET_CUST_INFO_10 
  ( 
    PSV_COMP_CD           IN   VARCHAR2, -- 1. ȸ���ڵ� 
    PSV_LANG_TP           IN   VARCHAR2, -- 2. ����ڵ� 
    PSV_REQ_DIV           IN   VARCHAR2, -- 3. ��ȸ����[1:ȸ��ID, 2:����, 3:�޴��ȣ(��4�ڸ�), 4:ī���ȣ] 
    PSV_REQ_VAL           IN   VARCHAR2, -- 4. ��ȸ�� 
    asRetVal              OUT  VARCHAR2, -- 5. ����ڵ�[1:����  �׿ܴ� ����] 
    asRetMsg              OUT  VARCHAR2, -- 6. ����޽��� 
    asResult              OUT  REC_SET.M_REFCUR 
  ); 
   
  PROCEDURE GET_CUST_INFO_20 
  ( 
    PSV_COMP_CD           IN   VARCHAR2, -- 1. ȸ���ڵ� 
    PSV_LANG_TP           IN   VARCHAR2, -- 2. ����ڵ� 
    PSV_CARD_ID           IN   VARCHAR2, -- 3. ī���ȣ 
    PSV_CHANNEL           IN   VARCHAR2, -- 4. �Է°�� 
    PSV_PAGE_NO           IN   VARCHAR2, -- 5. ��������(A:��ü, n:������) 
    PSV_STD_ROW           IN   VARCHAR2, -- 6. �������� ���ڵ� �� 
    asRetVal              OUT  VARCHAR2, -- 7. ����ڵ�[1:����  �׿ܴ� ����] 
    asRetMsg              OUT  VARCHAR2, -- 8. ����޽��� 
    asResult              OUT  REC_SET.M_REFCUR 
  ); 
 
  PROCEDURE SET_CUST_INFO_10 
  ( 
    PSV_COMP_CD           IN   VARCHAR2, -- 1. ȸ���ڵ� 
    PSV_LANG_TP           IN   VARCHAR2, -- 2. ����ڵ� 
    PSV_ISSUE_DIV         IN   VARCHAR2, -- 3. �߱ޱ���[0:�ű�, 1:��߱�] 
    PSV_CARD_ID           IN   VARCHAR2, -- 4. �ű� ī���ȣ, ��߱� ī���ȣ 
    PSV_CARD_ID_R         IN   VARCHAR2, -- 5. ���� ī���ȣ > ��߱��� ��� 
    PSV_ISSUE_DT          IN   VARCHAR2, -- 6. �߱����� 
    PSV_BRAND_CD          IN   VARCHAR2, -- 7. �������� 
    PSV_STOR_CD           IN   VARCHAR2, -- 8. �����ڵ� 
    asRetVal              OUT  VARCHAR2, -- 9. ����ڵ�[1:����  �׿ܴ� ����] 
    asRetMsg              OUT  VARCHAR2, -- 10. ����޽��� 
    asResult              OUT  REC_SET.M_REFCUR 
  ); 
   
  PROCEDURE SET_MEMB_CHG_10 
  ( 
    PSV_COMP_CD           IN   VARCHAR2, -- 1. ȸ���ڵ�
    PSV_LANG_TP           IN   VARCHAR2, -- 2. ����ڵ�
    PSV_CARD_ID           IN   VARCHAR2, -- 3. ī���ȣ
    PSV_CRG_DT            IN   VARCHAR2, -- 4. ��������
    PSV_BRAND_CD          IN   VARCHAR2, -- 5. ��������
    PSV_STOR_CD           IN   VARCHAR2, -- 6. �����ڵ�
    PSV_POS_NO            IN   VARCHAR2, -- 7. ������ȣ
    PSV_CARD_NO           IN   VARCHAR2, -- 8. ī���ȣ
    PSV_CARD_NM           IN   VARCHAR2, -- 9. ī���
    PSV_APPR_DT           IN   VARCHAR2, -- 10. ��������
    PSV_APPR_TM           IN   VARCHAR2, -- 11. ���νð�
    PSV_APPR_VD_CD        IN   VARCHAR2, -- 12. ���Ի��ڵ�
    PSV_APPR_VD_NM        IN   VARCHAR2, -- 13. ���Ի��
    PSV_APPR_IS_CD        IN   VARCHAR2, -- 14. �߱޻��ڵ�
    PSV_APPR_COM          IN   VARCHAR2, -- 15. ��������ȣ
    PSV_ALLOT_LMT         IN   VARCHAR2, -- 16. �Һΰ���
    PSV_READ_DIV          IN   VARCHAR2, -- 17. ��������
    PSV_APPR_DIV          IN   VARCHAR2, -- 18. ���α���
    PSV_APPR_NO           IN   VARCHAR2, -- 19. ���ι�ȣ
    PSV_CRG_FG            IN   VARCHAR2, -- 20. ��������[1:����, 2:���]==>O, [3:ȯ��, 4:����, 9:����] ==> X
    PSV_CRG_DIV           IN   VARCHAR2, -- 21. �������[1:����, 2:�ſ�ī��, 9:����]
    PSV_CRG_AMT           IN   VARCHAR2, -- 22. �����ݾ�
    PSV_ORG_CRG_DT        IN   VARCHAR2, -- 23. ���ŷ�����
    PSV_ORG_CRG_SEQ       IN   VARCHAR2, -- 24. ���ŷ��Ϸù�ȣ
    PSV_CHANNEL           IN   VARCHAR2, -- 25. ��α���[1:POS, 2:WEB, 3:MOBILE, 9:������]
    asRetVal              OUT  VARCHAR2, -- 26. ����ڵ�[1:����  �׿ܴ� ����]
    asRetMsg              OUT  VARCHAR2, -- 27. ����޽���
    asResult              OUT  REC_SET.M_REFCUR
  ); 
   
  PROCEDURE SET_MEMB_CHG_20 
  ( 
    PSV_COMP_CD           IN   VARCHAR2, -- 1. ȸ���ڵ� 
    PSV_LANG_TP           IN   VARCHAR2, -- 2. ����ڵ� 
    PSV_CARD_ID           IN   VARCHAR2, -- 3. ī���ȣ 
    PSV_USE_DT            IN   VARCHAR2, -- 4. ������� 
    PSV_MEMB_DIV          IN   VARCHAR2, -- 5. ����ʱ���[1: �����ݾ�, 2: ����Ʈ] 
    PSV_SALE_DIV          IN   VARCHAR2, -- 6. �Ǹű��� 
    PSV_USE_AMT           IN   VARCHAR2, -- 7. ���ݾ� 
    PSV_SAV_MLG           IN   VARCHAR2, -- 8. �������ϸ��� 
    PSV_SAV_PT            IN   VARCHAR2, -- 9. ��������Ʈ 
    PSV_USE_PT            IN   VARCHAR2, -- 10. �������Ʈ 
    PSV_BRAND_CD          IN   VARCHAR2, -- 11. �������� 
    PSV_STOR_CD           IN   VARCHAR2, -- 12. �����ڵ� 
    PSV_POS_NO            IN   VARCHAR2, -- 13. ������ȣ 
    PSV_BILL_NO           IN   VARCHAR2, -- 14. ��������ȣ 
    PSV_USE_TM            IN   VARCHAR2, -- 15. ���ð� 
    PSV_ORG_USE_DT        IN   VARCHAR2, -- 16. ���ŷ����� 
    PSV_ORG_USE_SEQ       IN   VARCHAR2, -- 17. ���ŷ��Ϸù�ȣ 
    asRetVal              OUT  VARCHAR2, -- 18. ����ڵ�[1:����  �׿ܴ� ����] 
    asRetMsg              OUT  VARCHAR2, -- 19. ����޽��� 
    asResult              OUT  REC_SET.M_REFCUR 
  ); 
   
  PROCEDURE SET_MEMB_CHG_30 
  ( 
    PSV_COMP_CD           IN   VARCHAR2, -- 1. ȸ���ڵ� 
    PSV_LANG_TP           IN   VARCHAR2, -- 2. ����ڵ� 
    PSV_CARD_ID_SEND      IN   VARCHAR2, -- 3. ī���ȣ(�絵) 
    PSV_CARD_ID_RECV      IN   VARCHAR2, -- 4. ī���ȣ(���) 
    PSV_CRG_DT            IN   VARCHAR2, -- 5. �������� 
    PSV_CRG_FG            IN   VARCHAR2, -- 6. ��������[3:ȯ��, 4:����] 
    PSV_CRG_DIV           IN   VARCHAR2, -- 7. �������[9:����] 
    PSV_CRG_AMT           IN   VARCHAR2, -- 8. �����ݾ� 
    PSV_ACC_USER_NM       IN   VARCHAR2, -- 9. �����ָ� 
    PSV_ACC_BANK          IN   VARCHAR2, -- 10.�����ڵ� 
    PSV_ACC_NUM           IN   VARCHAR2, -- 11.���¹�ȣ 
    PSV_CHANNEL           IN   VARCHAR2, -- 12.��α���[1:POS, 2:WEB, 3:MOBILE, 9:������] 
    asRetVal              OUT  VARCHAR2, -- 14.����ڵ�[1:����  �׿ܴ� ����] 
    asRetMsg              OUT  VARCHAR2, -- 15.����޽��� 
    asResult              OUT  REC_SET.M_REFCUR 
  ); 
 
  PROCEDURE SET_MEMB_CHG_40 
  ( 
    PSV_COMP_CD           IN   VARCHAR2, -- 1. ȸ���ڵ� 
    PSV_LANG_TP           IN   VARCHAR2, -- 2. ����ڵ� 
    PSV_CUST_ID           IN   VARCHAR2, -- 3. ����ȣ 
    PSV_CRG_DT            IN   VARCHAR2, -- 4. �������� 
    PSV_CRG_FG            IN   VARCHAR2, -- 5. ��������[3:ȯ��] 
    PSV_CRG_DIV           IN   VARCHAR2, -- 6. �������[9:����] 
    PSV_CRG_AMT           IN   VARCHAR2, -- 7. �����ݾ� 
    PSV_ACC_USER_NM       IN   VARCHAR2, -- 8. �����ָ� 
    PSV_ACC_BANK          IN   VARCHAR2, -- 9.�����ڵ� 
    PSV_ACC_NUM           IN   VARCHAR2, -- 10.���¹�ȣ 
    PSV_CHANNEL           IN   VARCHAR2, -- 11.��α���[1:POS, 2:WEB, 3:MOBILE, 9:������] 
    asRetVal              OUT  VARCHAR2, -- 12.����ڵ�[1:����  �׿ܴ� ����] 
    asRetMsg              OUT  VARCHAR2, -- 13.����޽��� 
    asResult              OUT  REC_SET.M_REFCUR 
  ); 
     
  PROCEDURE GET_MEMB_CUPN_10 
  ( 
    PSV_COMP_CD           IN   VARCHAR2, -- 1. ȸ���ڵ� 
    PSV_BRAND_CD          IN   VARCHAR2, -- 2. ��������
    PSV_STOR_CD           IN   VARCHAR2, -- 3. �����ڵ� 
    PSV_LANG_TP           IN   VARCHAR2, -- 4. ����ڵ�
    PSV_CERT_DIV          IN   VARCHAR2, -- 5. ��������[1:ī���ȣ, 2: ������ȣ]   
    PSV_CERT_VAL          IN   VARCHAR2, -- 6. ������ 
    asRetVal              OUT  VARCHAR2, -- 7. ����ڵ�[1:����  �׿ܴ� ����] 
    asRetMsg              OUT  VARCHAR2, -- 8. ����޽��� 
    asResult              OUT  REC_SET.M_REFCUR 
  ); 
 
  PROCEDURE SET_MEMB_CUPN_10 
  ( 
    PSV_COMP_CD           IN   VARCHAR2, -- 1. ȸ���ڵ� 
    PSV_LANG_TP           IN   VARCHAR2, -- 2. ����ڵ� 
    PSV_COUPON_CD         IN   VARCHAR2, -- 3. �����ڵ� 
    PSV_CERT_NO           IN   VARCHAR2, -- 4. ������ȣ 
    PSV_SALE_DIV          IN   VARCHAR2, -- 6. �Ǹű���[1:�Ǹ�, 2:��ǰ] 
    PSV_USE_DT            IN   VARCHAR2, -- 7. ������� 
    PSV_USE_TM            IN   VARCHAR2, -- 8. ���ð� 
    PSV_BRAND_CD          IN   VARCHAR2, -- 9. �������� 
    PSV_STOR_CD           IN   VARCHAR2, -- 10. �����ڵ� 
    PSV_POS_NO            IN   VARCHAR2, -- 11. ������ȣ 
    PSV_BILL_NO           IN   VARCHAR2, -- 12. ��������ȣ 
    asRetVal              OUT  VARCHAR2, -- 13. ����ڵ�[1:����  �׿ܴ� ����] 
    asRetMsg              OUT  VARCHAR2, -- 14. ����޽��� 
    asResult              OUT  REC_SET.M_REFCUR 
  ); 

END PKG_POS_CUST_ACK;

/

CREATE OR REPLACE PACKAGE BODY       PKG_POS_CUST_ACK AS
--------------------------------------------------------------------------------
--  Procedure Name   : GET_CUST_INFO_10
--  Description      : POS���� ȸ��/ī������ ��ȸ
--  Ref. Table       : C_CUST ȸ�� ������
--                     C_CARD �����ī�� ������
--------------------------------------------------------------------------------
--  Create Date      : 2015-01-13 ����� CRM PJT
--  Modify Date      : 2015-01-13 
--------------------------------------------------------------------------------
  PROCEDURE GET_CUST_INFO_10
  (
    PSV_COMP_CD           IN   VARCHAR2, -- 1. ȸ���ڵ�
    PSV_LANG_TP           IN   VARCHAR2, -- 2. ����ڵ�
    PSV_REQ_DIV           IN   VARCHAR2, -- 3. ��ȸ����[1:ȸ��ID, 2:����, 3:�޴��ȣ(��4�ڸ�), 4:ī���ȣ, 5:�޴��ȣFULL]
    PSV_REQ_VAL           IN   VARCHAR2, -- 4. ��ȸ��
    asRetVal              OUT  VARCHAR2, -- 5. ����ڵ�[1:����  �׿ܴ� ����]
    asRetMsg              OUT  VARCHAR2, -- 6. ����޽���
    asResult              OUT  REC_SET.M_REFCUR
  ) IS
  
    lsCardId        C_CARD.CARD_ID%TYPE;                    -- ī�� ID
    lsCustId        C_CARD.CUST_ID%TYPE;                    -- ȸ�� ID
    ls_Sql_Main     VARCHAR2(32000) := NULL;
    nRecCnt         NUMBER(7) := 0;
    
    ERR_HANDLER     EXCEPTION;
    
  BEGIN
    asRetVal    := '0000';
    asRetMsg    := 'OK';
    
    -- ȸ��: ȸ�� ID, ȸ����, �ڵ���, ȸ�����, ���� ���ϸ���, �Ҹ� ���ϸ���, ���� ����Ʈ, ��� ����Ʈ, �Ҹ� ����Ʈ, �����ݾ�, ���ݾ�, ���ϸ��� ����������, ȸ������
    -- ī��: ī���ȣ, �����ݾ�, ���ݾ�, ī�����, �߱ޱ���
    ls_Sql_Main :=          '    SELECT CRD.CUST_ID                     '
        ||chr(13)||chr(10)||'         , CST.CUST_NM   AS CUST_NM        '
        ||chr(13)||chr(10)||'         , CST.MOBILE    AS MOBILE         '
        ||chr(13)||chr(10)||'         , CST.LVL_CD                      '
        ||chr(13)||chr(10)||'         , LVL.LVL_NM                      '
        ||chr(13)||chr(10)||'         , CST.SAV_MLG                     '
        ||chr(13)||chr(10)||'         , CST.LOS_MLG                     '
        ||chr(13)||chr(10)||'         , CST.SAV_PT                      '
        ||chr(13)||chr(10)||'         , CST.USE_PT                      '
        ||chr(13)||chr(10)||'         , CST.LOS_PT                      '
        ||chr(13)||chr(10)||'         , CST.SAV_CASH                    '
        ||chr(13)||chr(10)||'         , CST.USE_CASH                    '
        ||chr(13)||chr(10)||'         , CST.MLG_DIV                     '
        ||chr(13)||chr(10)||'         , CST.CUST_STAT                   '
        ||chr(13)||chr(10)||'         , CRD.CARD_ID     AS CARD_ID      '
        ||chr(13)||chr(10)||'         , CRD.SAV_CASH    AS CARD_SAV_CASH'
        ||chr(13)||chr(10)||'         , CRD.USE_CASH    AS CARD_USE_CASH'
        ||chr(13)||chr(10)||'         , CRD.CARD_STAT   AS CARD_STAT    '
        ||chr(13)||chr(10)||'         , GET_COMMON_CODE_NM(''01725'', CRD.CARD_STAT, '''||PSV_LANG_TP||''') AS CARD_STAT_NM   '
        ||chr(13)||chr(10)||'         , CRD.ISSUE_DIV   AS ISSUE_DIV    '
        ||chr(13)||chr(10)||'         , CRD.SAV_PT      AS CARD_SAV_PT  '
        ||chr(13)||chr(10)||'         , CRD.USE_PT      AS CARD_USE_PT  '
        ||chr(13)||chr(10)||'         , CRD.LOS_PT      AS CARD_LOS_PT  '
        ||chr(13)||chr(10)||'         , LVL.SAV_PT_RATE                 '
        ||chr(13)||chr(10)||'      FROM C_CUST     CST             '   -- ȸ�� ������
        ||chr(13)||chr(10)||'         , C_CARD     CRD             '   -- �����ī�� ������
        ||chr(13)||chr(10)||'         , C_CUST_LVL LVL             '
        ||chr(13)||chr(10)||'     WHERE CST.COMP_CD     = LVL.COMP_CD   '
        ||chr(13)||chr(10)||'       AND CST.LVL_CD      = LVL.LVL_CD    '
        ||chr(13)||chr(10)||'       AND CRD.COMP_CD     = CST.COMP_CD   '
        ||chr(13)||chr(10)||'       AND CRD.CUST_ID     = CST.CUST_ID   '
        ||chr(13)||chr(10)||'       AND CRD.COMP_CD     = ''' || PSV_COMP_CD ||''''
        ||chr(13)||chr(10)||'       AND CRD.USE_YN      = ''Y'''            -- ��뿩��[Y:���, N:������]
        ||chr(13)||chr(10)||'       AND CST.CUST_STAT   = ''2'''            -- ȸ������[1:����, 2:�����, 9:Ż��]
        ||chr(13)||chr(10)||'       AND CST.USE_YN      = ''Y'''            -- ��뿩��[Y:���, N:������]
        ;
        
    -- ������
    CASE WHEN PSV_REQ_DIV = '1' THEN 
              ls_Sql_Main := ls_Sql_Main ||chr(13)||chr(10)||'   AND CRD.CUST_ID     =  '''||PSV_REQ_VAL||''' AND CRD.REP_CARD_YN = ''Y''';
         WHEN PSV_REQ_DIV = '2' THEN    
              ls_Sql_Main := ls_Sql_Main ||chr(13)||chr(10)||'   AND CST.CUST_NM     =  '''||PSV_REQ_VAL||''' AND CRD.REP_CARD_YN = ''Y''';
         WHEN PSV_REQ_DIV = '3' THEN    
              ls_Sql_Main := ls_Sql_Main ||chr(13)||chr(10)||'   AND CST.MOBILE_N3   =  '''||PSV_REQ_VAL||''' AND CRD.REP_CARD_YN = ''Y''';
         WHEN PSV_REQ_DIV = '4' THEN    
              ls_Sql_Main := ls_Sql_Main ||chr(13)||chr(10)||'   AND CRD.CARD_ID     =  '''||PSV_REQ_VAL||'''';
         WHEN PSV_REQ_DIV = '5' THEN    
              ls_Sql_Main := ls_Sql_Main ||chr(13)||chr(10)||'   AND CST.MOBILE      =  '''||PSV_REQ_VAL||''' AND CRD.REP_CARD_YN = ''Y''';
         ELSE
              ls_Sql_Main := ls_Sql_Main;
    END CASE;
    
    ls_Sql_Main := ls_Sql_Main
        ||chr(13)||chr(10)||'    UNION ALL                          '
        ||chr(13)||chr(10)||'    SELECT CST.CUST_ID                 '
        ||chr(13)||chr(10)||'         , CST.CUST_NM  AS CUST_NM     '
        ||chr(13)||chr(10)||'         , CST.MOBILE   AS MOBILE      '
        ||chr(13)||chr(10)||'         , CST.LVL_CD                  '
        ||chr(13)||chr(10)||'         , LVL.LVL_NM                  '
        ||chr(13)||chr(10)||'         , CST.SAV_MLG                 '
        ||chr(13)||chr(10)||'         , CST.LOS_MLG                 '
        ||chr(13)||chr(10)||'         , CST.SAV_PT                  '
        ||chr(13)||chr(10)||'         , CST.USE_PT                  '
        ||chr(13)||chr(10)||'         , CST.LOS_PT                  '
        ||chr(13)||chr(10)||'         , CST.SAV_CASH                '
        ||chr(13)||chr(10)||'         , CST.USE_CASH                '
        ||chr(13)||chr(10)||'         , CST.MLG_DIV                 '
        ||chr(13)||chr(10)||'         , CST.CUST_STAT               '
        ||chr(13)||chr(10)||'         , NULL AS CARD_ID             '
        ||chr(13)||chr(10)||'         , NULL AS CARD_SAV_CASH       '
        ||chr(13)||chr(10)||'         , NULL AS CARD_USE_CASH       '
        ||chr(13)||chr(10)||'         , NULL AS CARD_STAT           '
        ||chr(13)||chr(10)||'         , NULL AS CARD_STAT_NM        '
        ||chr(13)||chr(10)||'         , NULL AS ISSUE_DIV           '
        ||chr(13)||chr(10)||'         , NULL AS CARD_SAV_PT         '
        ||chr(13)||chr(10)||'         , NULL AS CARD_USE_PT         '
        ||chr(13)||chr(10)||'         , NULL AS CARD_LOS_PT         '
        ||chr(13)||chr(10)||'         , LVL.SAV_PT_RATE             '
        ||chr(13)||chr(10)||'      FROM C_CUST     CST         '   -- ȸ�� ������
        ||chr(13)||chr(10)||'         , C_CUST_LVL LVL         '
        ||chr(13)||chr(10)||'     WHERE CST.COMP_CD   = LVL.COMP_CD '
        ||chr(13)||chr(10)||'       AND CST.LVL_CD    = LVL.LVL_CD  '
        ||chr(13)||chr(10)||'       AND CST.COMP_CD   = ''' || PSV_COMP_CD ||''''
        ||chr(13)||chr(10)||'       AND CST.CUST_STAT = ''2'''          -- ȸ������[1:����, 2:�����, 9:Ż��]
        ||chr(13)||chr(10)||'       AND CST.USE_YN    = ''Y'''          -- ��뿩��[Y:���, N:������]
        ||chr(13)||chr(10)||'       AND NOT EXISTS(SELECT 1         '
        ||chr(13)||chr(10)||'                        FROM C_CARD CRD           '
        ||chr(13)||chr(10)||'                       WHERE CRD.COMP_CD = CST.COMP_CD '
        ||chr(13)||chr(10)||'                         AND CRD.CUST_ID = CST.CUST_ID '
        ||chr(13)||chr(10)||'                         AND CRD.USE_YN  = ''Y'''      -- ��뿩��[Y:���, N:������]
        ||chr(13)||chr(10)||'                      )                '
        ;
        
    --������
    CASE 
        WHEN PSV_REQ_DIV = '1' THEN 
            ls_Sql_Main := ls_Sql_Main ||chr(13)||chr(10)||'   AND CST.CUST_ID     =  '''||PSV_REQ_VAL||'''';
        WHEN PSV_REQ_DIV = '2' THEN    
            ls_Sql_Main := ls_Sql_Main ||chr(13)||chr(10)||'   AND CST.CUST_NM     =  '''||PSV_REQ_VAL||'''';
        WHEN PSV_REQ_DIV = '3' THEN    
            ls_Sql_Main := ls_Sql_Main ||chr(13)||chr(10)||'   AND CST.MOBILE_N3   =  '''||PSV_REQ_VAL||'''';
        WHEN PSV_REQ_DIV = '5' THEN    
            ls_Sql_Main := ls_Sql_Main ||chr(13)||chr(10)||'   AND CST.MOBILE      =  '''||PSV_REQ_VAL||'''';    
        ELSE
            ls_Sql_Main := ls_Sql_Main||chr(13)||chr(10)||'   AND 1 = 2 ';
    END CASE;
    
    ls_Sql_Main := ls_Sql_Main
        ||chr(13)||chr(10)||'    UNION ALL                          '
        ||chr(13)||chr(10)||'    SELECT NULL AS CUST_ID             '
        ||chr(13)||chr(10)||'         , NULL AS CUST_NM             '
        ||chr(13)||chr(10)||'         , NULL AS MOBILE              '
        ||chr(13)||chr(10)||'         , NULL AS LVL_CD              '
        ||chr(13)||chr(10)||'         , NULL AS LVL_NM              '
        ||chr(13)||chr(10)||'         , NULL AS SAV_MLG             '
        ||chr(13)||chr(10)||'         , NULL AS LOS_MLG             '
        ||chr(13)||chr(10)||'         , NULL AS SAV_PT              '
        ||chr(13)||chr(10)||'         , NULL AS USE_PT              '
        ||chr(13)||chr(10)||'         , NULL AS LOS_PT              '
        ||chr(13)||chr(10)||'         , NULL AS SAV_CASH            '
        ||chr(13)||chr(10)||'         , NULL AS USE_CASH            '
        ||chr(13)||chr(10)||'         , NULL AS MLG_DIV             '
        ||chr(13)||chr(10)||'         , NULL AS CUST_STAT           '
        ||chr(13)||chr(10)||'         , CRD.CARD_ID   AS CARD_ID    '
        ||chr(13)||chr(10)||'         , CRD.SAV_CASH  AS CARD_SAV_CASH  '
        ||chr(13)||chr(10)||'         , CRD.USE_CASH  AS CARD_USE_CASH  '
        ||chr(13)||chr(10)||'         , CRD.CARD_STAT AS CARD_STAT  '
        ||chr(13)||chr(10)||'         , GET_COMMON_CODE_NM(''01725'', CRD.CARD_STAT, '''||PSV_LANG_TP||''') AS CARD_STAT_NM   '
        ||chr(13)||chr(10)||'         , CRD.ISSUE_DIV AS ISSUE_DIV  '
        ||chr(13)||chr(10)||'         , CRD.SAV_PT    AS CARD_SAV_PT'
        ||chr(13)||chr(10)||'         , CRD.USE_PT    AS CARD_USE_PT'
        ||chr(13)||chr(10)||'         , CRD.LOS_PT    AS CARD_LOS_PT'
        ||chr(13)||chr(10)||'         ,(                            '
        ||chr(13)||chr(10)||'           SELECT  LVL.SAV_PT_RATE     '
        ||chr(13)||chr(10)||'           FROM    C_CUST_LVL LVL '
        ||chr(13)||chr(10)||'           WHERE   LVL.COMP_CD  = CRD.COMP_CD              '
        ||chr(13)||chr(10)||'           AND     LVL.LVL_RANK = (                        '
        ||chr(13)||chr(10)||'                                   SELECT  MIN(LVL_RANK)   '
        ||chr(13)||chr(10)||'                                   FROM    C_CUST_LVL '
        ||chr(13)||chr(10)||'                                   WHERE   USE_YN = ''Y''  '
        ||chr(13)||chr(10)||'                                  )                        '
        ||chr(13)||chr(10)||'           AND     ROWNUM = 1                              '
        ||chr(13)||chr(10)||'          ) SAV_PT_RATE                '
        ||chr(13)||chr(10)||'      FROM C_CARD CRD             '   -- �����ī�� ������
        ||chr(13)||chr(10)||'     WHERE CRD.COMP_CD = ''' || PSV_COMP_CD ||''''
        ||chr(13)||chr(10)||'       AND CRD.USE_YN  = ''Y'''            -- ��뿩��[Y:���, N:������]
        ||chr(13)||chr(10)||'       AND NOT EXISTS(SELECT 1         '
        ||chr(13)||chr(10)||'                        FROM C_CUST CST '             -- ȸ�� ������
        ||chr(13)||chr(10)||'                       WHERE CST.COMP_CD   = CRD.COMP_CD '  
        ||chr(13)||chr(10)||'                         AND CST.CUST_ID   = CRD.CUST_ID '
        ||chr(13)||chr(10)||'                         AND CST.CUST_STAT = ''2'''        -- ȸ������[1:����, 2:�����, 9:Ż��]
        ||chr(13)||chr(10)||'                         AND CST.USE_YN    = ''Y'''        -- ��뿩��[Y:���, N:������]
        ||chr(13)||chr(10)||'                    )                  '
        ;
    -- ������
    CASE WHEN PSV_REQ_DIV = '1' THEN 
              ls_Sql_Main := ls_Sql_Main ||chr(13)||chr(10)||'   AND CRD.CUST_ID     =  '''||PSV_REQ_VAL||'''';
         WHEN PSV_REQ_DIV = '4' THEN    
              ls_Sql_Main := ls_Sql_Main ||chr(13)||chr(10)||'   AND CRD.CARD_ID     =  '''||PSV_REQ_VAL||'''';
         ELSE 
              ls_Sql_Main := ls_Sql_Main||chr(13)||chr(10)||'   AND 1 = 2 ';
    END CASE;
    
    DBMS_OUTPUT.PUT_LINE(ls_Sql_Main);
    
    OPEN asResult FOR   ls_Sql_Main;
    
    asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001392'); -- ����ó�� �Ǿ����ϴ�.
    
    RETURN;
  EXCEPTION
    WHEN ERR_HANDLER THEN
         RETURN;
    WHEN OTHERS THEN
         asRetVal := '1003';
         IF PSV_REQ_DIV = '4' THEN
            asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001393');  -- ī���ȣ�� Ȯ�� �ϼ���.
         ELSE
            asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001385');  -- ȸ�������� Ȯ�� �ϼ���.
         END IF;
         
         RETURN;
  END GET_CUST_INFO_10;
  
  ------------------------------------------------------------------------------
  --  Package Name     : GET_CUST_INFO_20
  --  Description      : POS���� �����̷� �� ��� ���ɿ��� ��ȸ
  --  Ref. Table       : C_CARD            �����ī�� ������
  --                     C_CARD_CHARGE_HIS �����ī�� �����̷�
  ------------------------------------------------------------------------------
  --  Create Date      : 2015-01-13 ����� CRM PJT
  --  Modify Date      : 
  ------------------------------------------------------------------------------
  PROCEDURE GET_CUST_INFO_20
  (
    PSV_COMP_CD           IN   VARCHAR2, -- 1. ȸ���ڵ�
    PSV_LANG_TP           IN   VARCHAR2, -- 2. ����ڵ�
    PSV_CARD_ID           IN   VARCHAR2, -- 3. ī���ȣ
    PSV_CHANNEL           IN   VARCHAR2, -- 4. �Է°��
    PSV_PAGE_NO           IN   VARCHAR2, -- 5. ��������(A:��ü, n:������)
    PSV_STD_ROW           IN   VARCHAR2, -- 6. �������� ���ڵ� ��
    asRetVal              OUT  VARCHAR2, -- 7. ����ڵ�[1:����  �׿ܴ� ����]
    asRetMsg              OUT  VARCHAR2, -- 8. ����޽���
    asResult              OUT  REC_SET.M_REFCUR
  ) IS
  
    lsCardId        C_CARD.CARD_ID%TYPE;                    -- ī�� ID
    lsCustId        C_CARD.CUST_ID%TYPE;                    -- ȸ�� ID
    nRecCnt         NUMBER(7) := 0;
    
    ERR_HANDLER     EXCEPTION;
    
  BEGIN
    asRetVal    := '0000';
    asRetMsg    := 'OK';
    
    OPEN asResult FOR
        SELECT  CRG_DT
             ,  CRG_SEQ
             ,  CRG_FG
             ,  CRG_DIV
             ,  CRG_AMT
             ,  APPR_DT
             ,  APPR_TM
             ,  APPR_NO
             ,  CHANNEL
             ,  STOR_CD
             ,  STOR_NM
             ,  POS_NO
             ,  CNC_DIV
             ,  ORG_CNC_DIV
             ,  CASE WHEN MOD(ROW_CNT, TO_NUMBER(PSV_STD_ROW)) = 0 THEN TRUNC(ROW_CNT / TO_NUMBER(PSV_STD_ROW))
                     ELSE TRUNC(ROW_CNT / TO_NUMBER(PSV_STD_ROW)) + 1 
                END CUR_PAGE
             ,  CASE WHEN MOD(MAX_CNT, TO_NUMBER(PSV_STD_ROW)) = 0 THEN TRUNC(MAX_CNT / TO_NUMBER(PSV_STD_ROW))
                     ELSE TRUNC(MAX_CNT / TO_NUMBER(PSV_STD_ROW)) + 1 
                END MAX_PAGE
        FROM   (     
                SELECT CRG_DT
                     , CRG_SEQ
                     , CRG_FG
                     , CRG_DIV
                     , CRG_AMT
                     , APPR_DT
                     , APPR_TM
                     , APPR_NO
                     , CHANNEL
                     , STOR_CD
                     , STOR_NM
                     , POS_NO
                     , CASE WHEN PSV_CHANNEL = '1' AND CRG_DT BETWEEN TO_CHAR(SYSDATE - 13, 'YYYYMMDD') AND TO_CHAR(SYSDATE, 'YYYYMMDD') THEN -- POS �ֱ� 14�� �̳� �ڷḸ ��� ���� 
                               CASE WHEN CANCEL_DIV = 'N' AND CHARGE_DIV = 'N' AND CHANNEL_DIV = 'Y' AND -- ��� DATA �������, ȯ��/����/���� DATA �������, ��α���
                                         RES_CASH - SUM(CRG_AMT) OVER (PARTITION BY CARD_ID ORDER BY CANCEL_DIV, CHARGE_DIV, CRG_DT DESC, CRG_SEQ DESC) >= 0 THEN 'Y'
                                     ELSE 'N'
                               END
                            WHEN PSV_CHANNEL IN ('2', '3') AND CRG_DT BETWEEN TO_CHAR(SYSDATE - 6, 'YYYYMMDD') AND TO_CHAR(SYSDATE, 'YYYYMMDD') THEN -- WEB, APP �ֱ� 7�� �̳� �ڷḸ ��� ���� 
                               CASE WHEN CANCEL_DIV = 'N' AND CHARGE_DIV = 'N' AND CHANNEL_DIV = 'Y' AND -- ��� DATA �������, ȯ��/����/���� DATA �������, ��α���
                                         RES_CASH - SUM(CRG_AMT) OVER (PARTITION BY CARD_ID ORDER BY CANCEL_DIV, CHARGE_DIV, CRG_DT DESC, CRG_SEQ DESC) >= 0 THEN 'Y'
                                     ELSE 'N'
                               END    
                            ELSE 'N'  
                       END AS CNC_DIV
                     , CANCEL_DIV AS ORG_CNC_DIV
                     , ROW_NUMBER() OVER(PARTITION BY CARD_ID ORDER BY CRG_DT DESC, CRG_SEQ DESC, CANCEL_DIV) AS ROW_CNT
                     , COUNT    (*) OVER()                                                                    AS MAX_CNT
                  FROM (SELECT CRG.CARD_ID
                             , CRG.CRG_DT
                             , CRG.CRG_SEQ
                             , CRG.CRG_FG
                             , CRG.CRG_DIV
                             , CRG.APPR_DT
                             , CRG.APPR_TM
                             , CRG.APPR_NO
                             , CRG.CRG_AMT
                             , CRG.CHANNEL
                             , CRG.STOR_CD
                             , STR.STOR_NM
                             , CRG.POS_NO
                             , CC.SAV_CASH - CC.USE_CASH RES_CASH
                             , CASE WHEN CRG.CHANNEL = PSV_CHANNEL THEN 'Y' ELSE 'N' END CHANNEL_DIV
                             , NVL((SELECT CASE WHEN COUNT(*) = 0 THEN 'N' ELSE 'Y' END CHARGE_DIV
                                      FROM C_CARD_CHARGE_HIS CCH
                                     WHERE CCH.COMP_CD     = CRG.COMP_CD
                                       AND CCH.CARD_ID     = CRG.CARD_ID
                                       AND CCH.CRG_FG      IN('3', '4', '9') -- ��������[1:����, 2:���, 3:ȯ��, 4:����, 9:����]
                                       AND CCH.USE_YN      = 'Y'             -- ��뿩��[Y:���, N:������]
                                       AND CCH.CRG_DT || CCH.APPR_TM > CRG.CRG_DT || CRG.APPR_TM
                                   ), 'N')  CHARGE_DIV  -- ������ ���� ȯ�� DATA ���翩��
                             , NVL((SELECT CASE WHEN COUNT(*) = 0 THEN 'N' ELSE 'Y' END CANCEL_DIV
                                      FROM C_CARD_CHARGE_HIS CCH
                                     WHERE CCH.COMP_CD     = CRG.COMP_CD
                                       AND CCH.CARD_ID     = CRG.CARD_ID
                                       AND CCH.ORG_CRG_DT  = CRG.CRG_DT 
                                       AND CCH.ORG_CRG_SEQ = CRG.CRG_SEQ
                                       AND CCH.USE_YN      = 'Y'  -- ��뿩��[Y:���, N:������]
                                   ), 'N')  CANCEL_DIV  -- ���ŷ� ��� ����
                          FROM C_CARD_CHARGE_HIS CRG
                             , C_CARD            CC
                             , STORE             STR
                         WHERE CRG.COMP_CD  = PSV_COMP_CD
                           AND CRG.CARD_ID  = PSV_CARD_ID
                           AND CRG.COMP_CD  = CC.COMP_CD
                           AND CRG.CARD_ID  = CC.CARD_ID
                           AND CRG.BRAND_CD = STR.BRAND_CD(+)
                           AND CRG.STOR_CD  = STR.STOR_CD (+)
                           AND CC.CARD_STAT = '10'       -- ī�����[00:���, 10:����, 90:�нǽŰ�, 91:����, 99:���]
                           AND CC.USE_YN    = 'Y'        -- ��뿩��[Y:���, N:������]
                           AND CRG.CRG_FG   = '1'        -- ��������[1:����]
                           AND CRG.CRG_DIV IN ('1', '2') -- �������[1:����, 2:�ſ�ī��]
                           AND CRG.USE_YN   = 'Y'        -- ��뿩��[Y:���, N:������]
                       ) CRG
               ) NVL
        WHERE   PSV_PAGE_NO = (
                                CASE WHEN PSV_PAGE_NO = 'A' THEN 'A' 
                                     ELSE (
                                           CASE WHEN MOD(ROW_CNT, TO_NUMBER(PSV_STD_ROW)) = 0 THEN TO_CHAR(TRUNC(ROW_CNT / TO_NUMBER(PSV_STD_ROW)), 'FM999999')
                                                ELSE TO_CHAR(TRUNC(ROW_CNT / TO_NUMBER(PSV_STD_ROW)) + 1, 'FM999999')
                                           END
                                          ) 
                                END
                               );
     
    asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001392'); -- ����ó�� �Ǿ����ϴ�.
    
    RETURN;
  EXCEPTION
    WHEN ERR_HANDLER THEN
         RETURN;
    WHEN OTHERS THEN
         asRetVal := '1003';
         asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001393');  -- ī���ȣ�� Ȯ�� �ϼ���.
         
         RETURN;
  END GET_CUST_INFO_20;
  
--------------------------------------------------------------------------------
--  Package Name     : SET_CUST_INFO_10
--  Description      : POS���� ī�� �߱�(���߱�)/��߱�
--  Ref. Table       : C_CUST ȸ�� ������
--                     C_CARD �����ī�� ������
--------------------------------------------------------------------------------
--  Create Date      : 2015-02-25 �𽺹��� PJT
--  Modify Date      : 2015-02-25 
--------------------------------------------------------------------------------
  PROCEDURE SET_CUST_INFO_10
  (
    PSV_COMP_CD           IN   VARCHAR2, -- 1. ȸ���ڵ�
    PSV_LANG_TP           IN   VARCHAR2, -- 2. ����ڵ�
    PSV_ISSUE_DIV         IN   VARCHAR2, -- 3. �߱ޱ���[0:�ű�, 1:��߱�]
    PSV_CARD_ID           IN   VARCHAR2, -- 4. �ű� ī���ȣ, ��߱� ī���ȣ
    PSV_CARD_ID_R         IN   VARCHAR2, -- 5. ���� ī���ȣ > ��߱��� ���
    PSV_ISSUE_DT          IN   VARCHAR2, -- 6. �߱�����
    PSV_BRAND_CD          IN   VARCHAR2, -- 7. ��������
    PSV_STOR_CD           IN   VARCHAR2, -- 8. �����ڵ�
    asRetVal              OUT  VARCHAR2, -- 9. ����ڵ�[1:����  �׿ܴ� ����]
    asRetMsg              OUT  VARCHAR2, -- 10. ����޽���
    asResult              OUT  REC_SET.M_REFCUR
  ) IS
  
    lsCustId        C_CARD.CUST_ID%TYPE;                    -- ȸ�� ID
    lscard_div      C_CARD.CARD_DIV%TYPE;                   -- ī���������[1:ȸ��, 2:��������, 3:����]
    lsbrand_cd      C_CARD.BRAND_CD%TYPE;                   -- ��������
    lsstor_cd       C_CARD.STOR_CD%TYPE;                    -- �����ڵ�
    lsrep_card_yn   C_CARD.REP_CARD_YN%TYPE;                -- ��ǥī�忩��
    nCurPoint       C_CARD.SAV_PT%TYPE   := 0;              -- ���� ����Ʈ
    nRecCnt         NUMBER(7) := 0;
    
    ERR_HANDLER     EXCEPTION;
    
  BEGIN
    asRetVal    := '0000';
    asRetMsg    := 'OK'  ;
    
    SELECT COUNT(*)
      INTO nRecCnt
      FROM C_CARD -- �����ī�� ������
     WHERE COMP_CD    = PSV_COMP_CD
       AND CARD_ID    = PSV_CARD_ID;
       
    IF nRecCnt > 0 THEN
       asRetVal := '1000';
       asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001428'); -- �̹� ��ϵ� ī���ȣ �Դϴ�.
       
       RAISE ERR_HANDLER;
    ELSE
       IF PSV_ISSUE_DIV = '1' THEN -- �߱ޱ���[1:��߱�]
          SELECT COUNT(*), MAX(CUST_ID),  MAX(SAV_PT - USE_PT - LOS_PT), MAX(REP_CARD_YN)
            INTO nRecCnt,  lsCustId, nCurPoint, lsrep_card_yn
            FROM C_CARD -- �����ī�� ������
           WHERE COMP_CD    = PSV_COMP_CD
             AND CARD_ID    = PSV_CARD_ID_R;
             
          IF nRecCnt = 0 THEN
             asRetVal := '1001';
             asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001393');  -- ī���ȣ�� Ȯ�� �ϼ���.
             
             RAISE ERR_HANDLER;
          ELSE
             -- ���� ī�� ���� ó��
             UPDATE C_CARD
                SET CARD_STAT   = '91'           -- ī�����[91:����]
                  , CANCEL_DT   = PSV_ISSUE_DT
                  , REF_CARD_ID = PSV_CARD_ID
                  , USE_PT      = USE_PT + nCurPoint
                  , REP_CARD_YN = 'N'
                  , UPD_DT      = SYSDATE
                  , UPD_USER    = 'SYSTEM'
              WHERE COMP_CD     = PSV_COMP_CD
                AND CARD_ID     = PSV_CARD_ID_R;
          END IF;
       END IF;
       
       BEGIN
         SELECT NVL(PC.PARA_VAL, PM.PARA_DEFAULT), BM.BRAND_CD, '0000000' 
           INTO lscard_div , lsbrand_cd , lsstor_cd
           FROM PARA_MST     PM
              , PARA_COMPANY PC
              , BRAND_MEMB   BM
          WHERE PM.PARA_CD      = PC.PARA_CD(+)
            AND PM.PARA_TABLE   = 'PARA_COMPANY'
            AND PM.PARA_CD      = '2003'
            AND PC.COMP_CD(+)   = PSV_COMP_CD
            AND BM.COMP_CD      = PSV_COMP_CD
            AND BM.BRAND_CD     = (
                                    SELECT CCT.TSMS_BRAND_CD
                                      FROM C_CARD_TYPE     CCT
                                         , C_CARD_TYPE_REP CTR 
                                     WHERE CCT.COMP_CD   = CTR.COMP_CD
                                       AND CCT.CARD_TYPE = CTR.CARD_TYPE
                                       AND CTR.COMP_CD   = PSV_COMP_CD
                                       AND decrypt(PSV_CARD_ID) BETWEEN decrypt(CTR.START_CARD_CD) AND decrypt(CTR.CLOSE_CARD_CD)
                                       AND ROWNUM        = 1
                                  )
            AND PM.USE_YN       = 'Y'
            AND PC.USE_YN(+)    = 'Y'    -- ��뿩��[Y:���, N:������]
            AND BM.USE_YN       = 'Y';
       EXCEPTION
         WHEN OTHERS THEN 
              asRetVal := '1002';
              asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001394'); -- ������� ���� ī���ȣ �Դϴ�.
              
              RAISE ERR_HANDLER;
       END;
       
       CASE WHEN lscard_div = '1' THEN -- ȸ��
                 lsbrand_cd := NVL(PSV_BRAND_CD, lsbrand_cd);
                 lsstor_cd  := '0000000';
            WHEN lscard_div = '2' THEN -- ��������
                 lsbrand_cd := NVL(PSV_BRAND_CD, lsbrand_cd);
                 lsstor_cd  := '0000000';
            WHEN lscard_div = '3' THEN -- ����
                 lsbrand_cd := NVL(PSV_BRAND_CD, lsbrand_cd);
                 lsstor_cd  := NVL(PSV_STOR_CD , lsstor_cd );
       END CASE;
       
       -- ����� ī�� ���
       BEGIN
         EXECUTE IMMEDIATE 'ALTER TRIGGER TG_C_CARD_02 DISABLE';
         
         INSERT INTO C_CARD
         (
             COMP_CD, CARD_ID, CUST_ID, CARD_STAT, ISSUE_DIV, ISSUE_DT, ISSUE_BRAND_CD, ISSUE_STOR_CD,
             SAV_PT, CARD_DIV, BRAND_CD, STOR_CD, REP_CARD_YN, INST_USER, UPD_USER
         )
         VALUES
         (
             PSV_COMP_CD, PSV_CARD_ID, lsCustId, '10', '0', PSV_ISSUE_DT||TO_CHAR(SYSDATE, 'HH24MISS'), PSV_BRAND_CD, PSV_STOR_CD,
             nCurPoint, lscard_div, lsbrand_cd, lsstor_cd, NVL(lsrep_card_yn, 'N'), 'SYSTEM', 'SYSTEM'
         );
         
         EXECUTE IMMEDIATE 'ALTER TRIGGER TG_C_CARD_02 ENABLE';
       EXCEPTION
         WHEN OTHERS THEN 
              asRetVal := '1003';
              asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001401'); -- ī�� ��Ͽ� �����Ͽ����ϴ�.
              
              ROLLBACK;
              EXECUTE IMMEDIATE 'ALTER TRIGGER TG_C_CARD_02 ENABLE';
              RAISE ERR_HANDLER;
       END;
    END IF;
    
    OPEN asResult FOR
    SELECT PSV_CARD_ID, nCurPoint
      FROM DUAL;
      
    asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001392'); -- ����ó�� �Ǿ����ϴ�.
    
    RETURN;
  EXCEPTION
    WHEN ERR_HANDLER THEN
        ROLLBACK;
        
        RETURN;
    WHEN OTHERS THEN
        asRetVal := '2001';
        asRetMsg := SUBSTRB(SQLERRM(SQLCODE), 1, 60);
        
        ROLLBACK;
         
        RETURN;
  END SET_CUST_INFO_10;
  
  ------------------------------------------------------------------------------
  --  Package Name     : SET_MEMB_CHG_10
  --  Description      : ����� ����/���/ȯ��/����/����
  --  Ref. Table       : C_CARD            �����ī�� ������
  --                     C_CUST            ȸ�� ������
  --                     C_CARD_CHARGE_HIS �����ī�� �����̷�
  ------------------------------------------------------------------------------
  --  Create Date      : 2015-01-13 ����� CRM PJT
  --  Modify Date      : 
  ------------------------------------------------------------------------------
  PROCEDURE SET_MEMB_CHG_10
  (
    PSV_COMP_CD           IN   VARCHAR2, -- 1. ȸ���ڵ�
    PSV_LANG_TP           IN   VARCHAR2, -- 2. ����ڵ�
    PSV_CARD_ID           IN   VARCHAR2, -- 3. ī���ȣ
    PSV_CRG_DT            IN   VARCHAR2, -- 4. ��������
    PSV_BRAND_CD          IN   VARCHAR2, -- 5. ��������
    PSV_STOR_CD           IN   VARCHAR2, -- 6. �����ڵ�
    PSV_POS_NO            IN   VARCHAR2, -- 7. ������ȣ
    PSV_CARD_NO           IN   VARCHAR2, -- 8. ī���ȣ
    PSV_CARD_NM           IN   VARCHAR2, -- 9. ī���
    PSV_APPR_DT           IN   VARCHAR2, -- 10. ��������
    PSV_APPR_TM           IN   VARCHAR2, -- 11. ���νð�
    PSV_APPR_VD_CD        IN   VARCHAR2, -- 12. ���Ի��ڵ�
    PSV_APPR_VD_NM        IN   VARCHAR2, -- 13. ���Ի��
    PSV_APPR_IS_CD        IN   VARCHAR2, -- 14. �߱޻��ڵ�
    PSV_APPR_COM          IN   VARCHAR2, -- 15. ��������ȣ
    PSV_ALLOT_LMT         IN   VARCHAR2, -- 16. �Һΰ���
    PSV_READ_DIV          IN   VARCHAR2, -- 17. ��������
    PSV_APPR_DIV          IN   VARCHAR2, -- 18. ���α���
    PSV_APPR_NO           IN   VARCHAR2, -- 19. ���ι�ȣ
    PSV_CRG_FG            IN   VARCHAR2, -- 20. ��������[1:����, 2:���]==>O, [3:ȯ��, 4:����, 9:����] ==> X
    PSV_CRG_DIV           IN   VARCHAR2, -- 21. �������[1:����, 2:�ſ�ī��, 9:����]
    PSV_CRG_AMT           IN   VARCHAR2, -- 22. �����ݾ�
    PSV_ORG_CRG_DT        IN   VARCHAR2, -- 23. ���ŷ�����
    PSV_ORG_CRG_SEQ       IN   VARCHAR2, -- 24. ���ŷ��Ϸù�ȣ
    PSV_CHANNEL           IN   VARCHAR2, -- 25. ��α���[1:POS, 2:WEB, 3:MOBILE, 9:������]
    asRetVal              OUT  VARCHAR2, -- 26. ����ڵ�[1:����  �׿ܴ� ����]
    asRetMsg              OUT  VARCHAR2, -- 27. ����޽���
    asResult              OUT  REC_SET.M_REFCUR
  ) IS
      
    lsCardId        C_CARD.CARD_ID%TYPE;                    -- ī�� ID
    lsissue_div     C_CARD.ISSUE_DIV%TYPE;                  -- �߱ޱ���[0:�ű�, 1:��߱�]
    lscard_div      C_CARD.CARD_DIV%TYPE;                   -- ī���������[1:ȸ��, 2:��������, 3:����]
    lsbrand_cd      C_CARD.BRAND_CD%TYPE;                   -- ��������
    lsstor_cd       C_CARD.STOR_CD%TYPE;                    -- �����ڵ�
    lsCustId        C_CARD.CUST_ID%TYPE;                    -- ȸ�� ID
    lscard_stat     C_CARD.CARD_STAT%TYPE;                  -- ī�����[00:���, 10:����, 90:�нǽŰ�, 91:����, 99:���]
    llCrgAmt        C_CARD_CHARGE_HIS.CRG_AMT%TYPE := 0;    -- �����ݾ�
    llstamp_tax     C_CARD_CHARGE_HIS.STAMP_TAX%TYPE := 0;  -- ������
    llsav_cash      C_CARD.SAV_CASH%TYPE;                   -- �����ݾ�
    lluse_cash      C_CARD.USE_CASH%TYPE;                   -- ���ݾ�
    nRecCnt         NUMBER(7) := 0;
    
    ERR_HANDLER     EXCEPTION;
    
  BEGIN
    asRetVal    := '0000' ;
    asRetMsg    := 'OK'   ;
    
    SELECT COUNT(*), MAX(CARD_STAT), MAX(CUST_ID), MAX(SAV_CASH), MAX(USE_CASH), MAX(ISSUE_DIV)
      INTO nRecCnt,  lscard_stat,    lsCustId,     llsav_cash,    lluse_cash,    lsissue_div
      FROM C_CARD -- �����ī�� ������
     WHERE COMP_CD    = PSV_COMP_CD
       AND CARD_ID    = PSV_CARD_ID
       AND USE_YN     = 'Y'; -- ��뿩��[Y:���, N:������]
       
    IF nRecCnt = 0 THEN
       IF PSV_CRG_FG = '1' THEN -- ��������[1:����]
          BEGIN
            SELECT NVL(PC.PARA_VAL, PM.PARA_DEFAULT), BM.BRAND_CD, '0000000' 
              INTO lscard_div , lsbrand_cd , lsstor_cd
              FROM PARA_MST     PM
                 , PARA_COMPANY PC
                 , BRAND_MEMB   BM
             WHERE PM.PARA_CD      = PC.PARA_CD(+)
               AND PM.PARA_TABLE   = 'PARA_COMPANY'
               AND PM.PARA_CD      = '2003'
               AND PC.COMP_CD(+)   = PSV_COMP_CD
               AND BM.COMP_CD      = PSV_COMP_CD
               AND BM.BRAND_CD     = (
                                        SELECT CCT.TSMS_BRAND_CD
                                          FROM C_CARD_TYPE     CCT
                                             , C_CARD_TYPE_REP CTR 
                                         WHERE CCT.COMP_CD   = CTR.COMP_CD
                                           AND CCT.CARD_TYPE = CTR.CARD_TYPE
                                           AND CTR.COMP_CD   = PSV_COMP_CD
                                           AND decrypt(PSV_CARD_ID) BETWEEN decrypt(CTR.START_CARD_CD) AND decrypt(CTR.CLOSE_CARD_CD)
                                           AND ROWNUM        = 1
                                     )
               AND PM.USE_YN       = 'Y'
               AND PC.USE_YN(+)    = 'Y'    -- ��뿩��[Y:���, N:������]
               AND BM.USE_YN       = 'Y';
               
          EXCEPTION
            WHEN OTHERS THEN 
                 asRetVal := '1000';
                 asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001394'); -- ������� ���� ī���ȣ �Դϴ�.
                 
                 RAISE ERR_HANDLER;
          END;
          
          CASE WHEN lscard_div = '1' THEN -- ȸ��
                    lsbrand_cd := NVL(PSV_BRAND_CD, lsbrand_cd);
                    lsstor_cd  := '0000000';
               WHEN lscard_div = '2' THEN -- ��������
                    lsbrand_cd := NVL(PSV_BRAND_CD, lsbrand_cd);
                    lsstor_cd  := '0000000';
               WHEN lscard_div = '3' THEN -- ����
                    lsbrand_cd := NVL(PSV_BRAND_CD, lsbrand_cd);
                    lsstor_cd  := NVL(PSV_STOR_CD , lsstor_cd );
          END CASE;
          
          -- ���� �Ǵ� ���� �� ����� ī�尡 ���� ��� ��� ó��
          BEGIN
            INSERT INTO C_CARD
            (
                COMP_CD, CARD_ID, CARD_STAT, ISSUE_DIV, ISSUE_DT, ISSUE_BRAND_CD, ISSUE_STOR_CD,
                CARD_DIV, BRAND_CD, STOR_CD, INST_USER, UPD_USER
            )
            VALUES
            (
                PSV_COMP_CD, PSV_CARD_ID, '10', '0', PSV_CRG_DT||PSV_APPR_TM, PSV_BRAND_CD, PSV_STOR_CD,
                lscard_div, lsbrand_cd, lsstor_cd, 'SYSTEM', 'SYSTEM'
            );
            
          EXCEPTION
            WHEN OTHERS THEN 
                 asRetVal := '1001';
                 asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001401'); -- ī�� ��Ͽ� �����Ͽ����ϴ�.
                 
                 ROLLBACK;
                 RAISE ERR_HANDLER;
          END;
          
          nRecCnt     := 1;
          lscard_stat := '10'; -- ī�����[00:���, 10:����, 20:�����ϱ�, 90:�нǽŰ�, 91:����, 99:���]
          lsCustId    := '';
          llsav_cash  := 0;
          lluse_cash  := 0;
          lsissue_div := '0'; -- �߱ޱ���[0:�ű�, 1:��߱�]
       ELSE
          asRetVal := '1002';
          asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001394'); -- ������� ���� ī���ȣ �Դϴ�.
          
          RAISE ERR_HANDLER;
       END IF;
    ELSE
       BEGIN
         SELECT NVL(PC.PARA_VAL, PM.PARA_DEFAULT), BM.BRAND_CD, '0000000' 
           INTO lscard_div , lsbrand_cd , lsstor_cd
           FROM PARA_MST     PM
              , PARA_COMPANY PC
              , BRAND_MEMB   BM
          WHERE PM.PARA_CD      = PC.PARA_CD(+)
            AND PM.PARA_TABLE   = 'PARA_COMPANY'
            AND PM.PARA_CD      = '2003'
            AND PC.COMP_CD(+)   = PSV_COMP_CD
            AND BM.COMP_CD      = PSV_COMP_CD
            AND BM.BRAND_CD     = (
                                        SELECT CCT.TSMS_BRAND_CD
                                          FROM C_CARD_TYPE     CCT
                                             , C_CARD_TYPE_REP CTR 
                                         WHERE CCT.COMP_CD   = CTR.COMP_CD
                                           AND CCT.CARD_TYPE = CTR.CARD_TYPE
                                           AND CTR.COMP_CD   = PSV_COMP_CD
                                           AND decrypt(PSV_CARD_ID) BETWEEN decrypt(CTR.START_CARD_CD) AND decrypt(CTR.CLOSE_CARD_CD)
                                           AND ROWNUM        = 1
                                     )
            AND PM.USE_YN       = 'Y'
            AND PC.USE_YN(+)    = 'Y'    -- ��뿩��[Y:���, N:������]
            AND BM.USE_YN       = 'Y';
       EXCEPTION
         WHEN OTHERS THEN 
              asRetVal := '1000';
              asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001394'); -- ������� ���� ī���ȣ �Դϴ�.
              
              RAISE ERR_HANDLER;
       END;
    END IF;
    
    -- 2015/02/10 �нǵ� ī��� ����, ���, ���� �Ұ�
    CASE WHEN PSV_CRG_FG IN ('1', '2', '9') AND lscard_stat = '90' THEN -- �нǽŰ�
              asRetVal := '1003';
              asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001396'); -- �нǽŰ�� ī���ȣ �Դϴ�.
              
              RAISE ERR_HANDLER;
         WHEN lscard_stat = '91' THEN -- ����
              asRetVal := '1004';
              asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001397'); -- ������ ī���ȣ �Դϴ�.
              
              RAISE ERR_HANDLER;
         WHEN lscard_stat = '99' THEN -- ���
              asRetVal := '1005';
              asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001398'); -- ���� ī���ȣ �Դϴ�.
              
              RAISE ERR_HANDLER;
         ELSE
              asRetVal := '0000';
    END CASE;
    
    IF PSV_CRG_FG IN('1', '4', '9') THEN -- ��������[1:����, 2:���, 3:ȯ��, 4:����, 9:����]
       IF (NVL(lsCustId, ' ') = ' ') AND (500000 < TO_NUMBER(PSV_CRG_AMT) + llsav_cash - lluse_cash) THEN -- �����ܾ��� 50������ ������
          asRetVal := '1006';
          asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001399'); -- �������� �ѵ��� �ʰ��Ͽ����ϴ�.
          
          RAISE ERR_HANDLER;
       END IF;
       
       IF llsav_cash = 0 AND lluse_cash = 0 THEN -- �����ݾװ� ���ݾ��� 0�̸�
          SELECT COUNT(*)
              INTO nRecCnt
              FROM C_CARD_CHARGE_HIS A -- �����ī�� �����̷�
             WHERE COMP_CD      = PSV_COMP_CD
               AND CARD_ID      = PSV_CARD_ID
               AND CRG_FG       IN('1', '4', '9')  -- ��������[1:����, 2:���, 3:ȯ��, 4:����, 9:����]
               AND USE_YN       = 'Y'              -- ��뿩��[Y:���, N:������]
               AND NOT EXISTS (
                               SELECT CARD_ID   -- ��ҳ����� ���� ��� ����
                                 FROM C_CARD_CHARGE_HIS B
                                WHERE B.COMP_CD     = A.COMP_CD
                                  AND B.CARD_ID     = A.CARD_ID
                                  AND B.ORG_CRG_DT  = A.CRG_DT
                                  AND B.ORG_CRG_SEQ = A.ORG_CRG_SEQ
                                  AND B.CRG_FG      = '2' -- ��������[1:����, 2:���, 3:ȯ��, 4:����, 9:����]
                                  AND B.USE_YN      = 'Y' -- ��뿩��[Y:���, N:������]
                               );
                               
          IF nRecCnt = 0 THEN -- ī������� �������� ��
             IF PSV_CRG_FG = '1' AND PSV_CHANNEL = '9' THEN -- ��������[1:����], ��α���[1:POS, 2:WEB, 3:MOBILE, 9:������]
                asRetVal := '1007';
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001400'); -- ���� ������ ���忡���� �����մϴ�.
                
                RAISE ERR_HANDLER;
             END IF;
             
             BEGIN
               SELECT TO_NUMBER(VAL_C1)
                 INTO llstamp_tax
                 FROM COMMON
                WHERE CODE_TP     = '01711' -- ����ī�� ������ �ݾױ���
                  AND TO_NUMBER(PSV_CRG_AMT) BETWEEN VAL_N1 AND VAL_N2
                  AND USE_YN      = 'Y';    -- ��뿩��[Y:���, N:������]
             EXCEPTION
               WHEN OTHERS THEN 
                    llstamp_tax := 0;
             END;
          END IF;
       END IF;
       
       IF NVL(lsCustId, ' ') <> ' ' THEN -- ȸ�� ID ���� ��
          SELECT COUNT(*), MAX(SAV_CASH), MAX(USE_CASH)
            INTO nRecCnt,  llsav_cash,    lluse_cash
            FROM C_CUST -- ȸ�� ������
           WHERE COMP_CD   = PSV_COMP_CD
             AND CUST_ID   = lsCustId
             AND CUST_STAT = '2'  -- ȸ������[1:����, 2:�����, 9:Ż��]
             AND USE_YN    = 'Y'; -- ��뿩��[Y:���, N:������]
               
          IF nRecCnt > 0 THEN
             IF 500000 < TO_NUMBER(PSV_CRG_AMT) + llsav_cash - lluse_cash THEN -- �����ܾ��� 50������ ������
                asRetVal := '1008';
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001399'); -- �������� �ѵ��� �ʰ��Ͽ����ϴ�.
                
                RAISE ERR_HANDLER;
             END IF;
          END IF; 
       END IF;
    END IF;
    
    IF PSV_CRG_FG = '1' AND MOD(TO_NUMBER(PSV_CRG_AMT), 10000) <> 0 THEN -- ��������[1:����]
       asRetVal := '1009';
       asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001409'); -- �����ݾ��� ���� ������ �����մϴ�
       
       RAISE ERR_HANDLER;
    END IF;
    
    IF PSV_CRG_FG = '2' THEN -- �������� 2:���
       -- ���ŷ� ��� ���� 
       SELECT COUNT(*) INTO nRecCnt
         FROM C_CARD_CHARGE_HIS -- �����ī�� �����̷�
        WHERE COMP_CD     = PSV_COMP_CD
          AND CARD_ID     = PSV_CARD_ID
          AND ORG_CRG_DT  = PSV_ORG_CRG_DT
          AND ORG_CRG_SEQ = TO_NUMBER(PSV_ORG_CRG_SEQ)
          AND USE_YN      = 'Y';     -- ��뿩��[Y:���, N:������]
         
       IF nRecCnt > 0 THEN
          asRetVal := '1020';
          asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1001343008'); -- �̹� ��ǰ Ȯ���� DATA�Դϴ�.
          
          RAISE ERR_HANDLER;
       END IF;
       
       -- ���ŷ� ������ ���
       SELECT COUNT(*), NVL(MAX(STAMP_TAX), 0) * (-1), NVL(MAX(CRG_AMT), 0) * (-1)
         INTO nRecCnt, llstamp_tax, llCrgAmt
         FROM C_CARD_CHARGE_HIS -- �����ī�� �����̷�
        WHERE COMP_CD     = PSV_COMP_CD
          AND CARD_ID     = PSV_CARD_ID
          AND CRG_DT      = PSV_ORG_CRG_DT
          AND CRG_SEQ     = TO_NUMBER(PSV_ORG_CRG_SEQ)
          AND USE_YN      = 'Y';     -- ��뿩��[Y:���, N:������]
          
       IF nRecCnt = 0 THEN
          asRetVal := '1101';
          asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001389'); -- ���ŷ� ������ �������� �ݽ��ϴ�.
          
          RAISE ERR_HANDLER;
       END IF;
       
       IF llCrgAmt !=  TO_NUMBER(PSV_CRG_AMT) THEN
          asRetVal := '1102';
          asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001451'); -- ���ŷ� ������ �������� �ݽ��ϴ�.
          
          RAISE ERR_HANDLER;
       END IF;
    END IF;
    
    -- �����̷� �ۼ�(ī������ ����)
    IF TO_NUMBER(PSV_CRG_AMT) != 0 THEN 
        INSERT INTO C_CARD_CHARGE_HIS
        (
            COMP_CD     ,       CARD_ID     ,
            CRG_DT      ,
            CRG_SEQ     ,
            CRG_FG      ,       CRG_DIV     ,
            CRG_AMT     ,       CHANNEL     ,
            BRAND_CD    ,       STOR_CD     ,
            REMARKS     ,
            TRN_CARD_ID ,
            POS_NO      ,
            CARD_NO     ,       CARD_NM     ,
            APPR_DT     ,       APPR_TM     ,
            APPR_VD_CD  ,       APPR_VD_NM  ,
            APPR_IS_CD  ,       APPR_COM    ,
            ALLOT_LMT   ,
            READ_DIV    ,       APPR_DIV    ,
            APPR_NO     ,
            ORG_CRG_DT  ,       ORG_CRG_SEQ ,
            STAMP_TAX   ,       USE_YN      ,
            SAP_IF_YN   ,       SAP_IF_DT   ,
            INST_DT     ,       INST_USER   ,
            UPD_DT      ,       UPD_USER
        )
        VALUES
        (
            PSV_COMP_CD ,       PSV_CARD_ID,
            PSV_CRG_DT  ,
            (
             SELECT NVL(MAX(CRG_SEQ), 0) + 1
               FROM C_CARD_CHARGE_HIS
              WHERE COMP_CD = PSV_COMP_CD
                AND CARD_ID = PSV_CARD_ID
                AND CRG_DT  = PSV_CRG_DT
            )           ,
            PSV_CRG_FG  ,       PSV_CRG_DIV ,
            TO_NUMBER(PSV_CRG_AMT) ,       PSV_CHANNEL ,
            lsbrand_cd  ,       NVL(PSV_STOR_CD, lsstor_cd),
            GET_COMMON_CODE_NM('01735', PSV_CRG_FG, PSV_LANG_TP),
            NULL            ,
            PSV_POS_NO      ,
            PSV_CARD_NO     ,     PSV_CARD_NM ,
            PSV_APPR_DT     ,     PSV_APPR_TM ,
            PSV_APPR_VD_CD  ,     PSV_APPR_VD_NM,
            PSV_APPR_IS_CD  ,     PSV_APPR_COM,
            PSV_ALLOT_LMT   ,
            PSV_READ_DIV    ,     PSV_APPR_DIV,
            PSV_APPR_NO     ,
            PSV_ORG_CRG_DT  ,     CASE WHEN PSV_ORG_CRG_SEQ = '0' THEN NULL ELSE TO_NUMBER(PSV_ORG_CRG_SEQ) END,
            llstamp_tax     ,     'Y'         ,
            'N'             ,     NULL      ,
            SYSDATE         ,     'SYS'       ,
            SYSDATE         ,     'SYS'
        );
    END IF;
    
    OPEN asResult FOR  -- ����� ī�� ���� ���
    SELECT SAV_CASH - USE_CASH as  CUR_CASH_PNT
      FROM C_CARD
     WHERE COMP_CD = PSV_COMP_CD
       AND CARD_ID = PSV_CARD_ID
       AND USE_YN  = 'Y'; -- ��뿩��[Y:���, N:������]
     
    asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001392'); -- ����ó�� �Ǿ����ϴ�.
    
    RETURN;
  EXCEPTION
    WHEN ERR_HANDLER THEN
         OPEN asResult FOR
            SELECT 0
            FROM   DUAL;
             
         ROLLBACK;
         RETURN;
    WHEN OTHERS THEN
         OPEN asResult FOR
            SELECT 0
            FROM   DUAL;
         
         asRetVal := '2001';
         asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001187')||'['||SQLERRM||']'; -- ������ �߻��Ͽ����ϴ�.
         
         ROLLBACK;
         RETURN;
  END SET_MEMB_CHG_10;
  
  ------------------------------------------------------------------------------
  --  Package Name     : SET_MEMB_CHG_20
  --  Description      : POS ����� ���/���� > POS������ ����
  --  Ref. Table       : C_CARD            �����ī�� ������
  --                     C_CUST            ȸ�� ������
  --                     C_CARD_USE_HIS    �����ī�� ����̷�
  --                     C_CARD_SAV_HIS    �����ī�� �����̷�
  ------------------------------------------------------------------------------
  --  Create Date      : 2015-01-13 ����� CRM PJT
  --  Modify Date      : 
  ------------------------------------------------------------------------------
  PROCEDURE SET_MEMB_CHG_20
  (
    PSV_COMP_CD           IN   VARCHAR2, -- 1. ȸ���ڵ�
    PSV_LANG_TP           IN   VARCHAR2, -- 2. ����ڵ�
    PSV_CARD_ID           IN   VARCHAR2, -- 3. ī���ȣ
    PSV_USE_DT            IN   VARCHAR2, -- 4. �������
    PSV_MEMB_DIV          IN   VARCHAR2, -- 5. ����ʱ���[1: �����ݾ�, 2: ����Ʈ]
    PSV_SALE_DIV          IN   VARCHAR2, -- 6. �Ǹű���
    PSV_USE_AMT           IN   VARCHAR2, -- 7. ���ݾ�
    PSV_SAV_MLG           IN   VARCHAR2, -- 8. �������ϸ���
    PSV_SAV_PT            IN   VARCHAR2, -- 9. ��������Ʈ
    PSV_USE_PT            IN   VARCHAR2, -- 10. �������Ʈ
    PSV_BRAND_CD          IN   VARCHAR2, -- 11. ��������
    PSV_STOR_CD           IN   VARCHAR2, -- 12. �����ڵ�
    PSV_POS_NO            IN   VARCHAR2, -- 13. ������ȣ
    PSV_BILL_NO           IN   VARCHAR2, -- 14. ��������ȣ
    PSV_USE_TM            IN   VARCHAR2, -- 15. ���ð�
    PSV_ORG_USE_DT        IN   VARCHAR2, -- 16. ���ŷ�����
    PSV_ORG_USE_SEQ       IN   VARCHAR2, -- 17. ���ŷ��Ϸù�ȣ
    asRetVal              OUT  VARCHAR2, -- 18. ����ڵ�[1:����  �׿ܴ� ����]
    asRetMsg              OUT  VARCHAR2, -- 19. ����޽���
    asResult              OUT  REC_SET.M_REFCUR
  ) IS
  
    lsCardId        C_CARD.CARD_ID%TYPE;               -- ī�� ID
    lsCustId        C_CARD.CUST_ID%TYPE;               -- ȸ�� ID
    lsMlgSavDt      C_CUST.MLG_SAV_DT%TYPE;            -- ���ϸ��� ���� ���� 
    nRecSeq         VARCHAR2(7);                            -- �Ϸù�ȣ
    nRecCnt         NUMBER(7) := 0;                         -- ���ڵ� ��
    nCurCash        C_CARD.SAV_CASH%TYPE := 0;         -- ���� �ܾ�
    nCurPoint       C_CARD.SAV_PT%TYPE   := 0;         -- ���� ����Ʈ
    
    ERR_HANDLER     EXCEPTION;
    
  BEGIN
  
    asRetVal    := '0000';
    asRetMsg    := 'OK'  ;
    
    BEGIN
      SELECT COUNT(*), MAX(SAV_CASH - USE_CASH), MAX(SAV_PT - USE_PT - LOS_PT), MAX(CUST_ID)
        INTO nRecCnt,  nCurCash,                 nCurPoint,                     lsCustId
        FROM C_CARD
       WHERE COMP_CD   = PSV_COMP_CD
         AND CARD_ID   = PSV_CARD_ID
         AND CARD_STAT = '10' -- ī�����[00:���, 10:����, 90:�нǽŰ�, 91:����, 99:���]
         AND USE_YN    = 'Y'; -- ��뿩��[Y:���, N:������]
         
      IF nRecCnt = 0 THEN
         asRetVal := '1001';
         asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001394'); -- ������� ���� ī���ȣ �Դϴ�.
         
         RETURN;
      END IF;
      
      IF    PSV_MEMB_DIV = '1' AND PSV_SALE_DIV = '1' THEN   -- �����ݾ�, ���
         IF nCurCash < TO_NUMBER(PSV_USE_AMT) THEN
            asRetVal := '1010';
            asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001395'); -- �����ܾ��� �����մϴ�.
            
            RETURN;
         END IF;
      ELSIF PSV_MEMB_DIV = '2' AND PSV_SALE_DIV = '301' THEN -- ����Ʈ, ���
         IF nCurPoint < TO_NUMBER(PSV_USE_PT) THEN
            asRetVal := '1010';
            asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001386'); -- �� ����Ʈ �ܾ��� �����մϴ�.
            
            RETURN;
         END IF;
      END IF;
    END;
    
    -- ���ŷ� ���翩�� / �� ��ҿ��� üũ
    IF PSV_SALE_DIV IN ('2', '202', '302') THEN -- 2: ��ǰ, 202: ������ǰ, 302: ����ǰ
        -- ���ŷ� ���翩��
        IF PSV_SALE_DIV =  '2' THEN
            SELECT COUNT(*)
              INTO nRecCnt
              FROM C_CARD_USE_HIS
             WHERE COMP_CD = PSV_COMP_CD
               AND CARD_ID = PSV_CARD_ID
               AND USE_DT  = PSV_ORG_USE_DT
               AND USE_SEQ = TO_NUMBER(PSV_ORG_USE_SEQ)
               AND USE_YN  = 'Y'; -- ��뿩��[Y:���, N:������]
        ELSIF PSV_SALE_DIV IN ('202', '302') THEN
            SELECT COUNT(*)
              INTO nRecCnt
              FROM C_CARD_SAV_HIS
             WHERE COMP_CD = PSV_COMP_CD
               AND CARD_ID = PSV_CARD_ID
               AND USE_DT  = PSV_ORG_USE_DT
               AND USE_SEQ = TO_NUMBER(PSV_ORG_USE_SEQ);
        END IF;
            
        IF nRecCnt = 0 THEN
            asRetVal := '1020';
            asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001389'); -- ���ŷ� ������ �������� �ʽ��ϴ�.
            
            RETURN;
        END IF;
        
        -- �� ��ҿ��� üũ
        IF    PSV_SALE_DIV = '2' THEN 
            SELECT COUNT(*)
              INTO nRecCnt
              FROM C_CARD_USE_HIS
             WHERE COMP_CD     = PSV_COMP_CD
               AND CARD_ID     = PSV_CARD_ID
               AND ORG_USE_DT  = PSV_ORG_USE_DT
               AND ORG_USE_SEQ = TO_NUMBER(PSV_ORG_USE_SEQ)
               AND USE_YN      = 'Y'; -- ��뿩��[Y:���, N:������]
        ELSIF PSV_SALE_DIV IN ('202', '302') THEN
            SELECT COUNT(*)
              INTO nRecCnt
              FROM C_CARD_SAV_HIS
             WHERE COMP_CD     = PSV_COMP_CD
               AND CARD_ID     = PSV_CARD_ID
               AND ORG_USE_DT  = PSV_ORG_USE_DT
               AND ORG_USE_SEQ = TO_NUMBER(PSV_ORG_USE_SEQ);
        END IF;
       
        IF nRecCnt > 0 THEN
            asRetVal := '1030';
            asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1001343008'); -- �̹� ��ǰ Ȯ���� DATA�Դϴ�.
          
            RETURN;
        END IF;
    END IF;
    
    IF PSV_MEMB_DIV = '1' THEN -- 
       -- �Ϸù�ȣ ���
       SELECT SQ_PCRM_SEQ.NEXTVAL
         INTO nRecSeq
         FROM DUAL;
          
       INSERT INTO C_CARD_USE_HIS
       (
           COMP_CD     ,       CARD_ID     ,
           USE_DT      ,       USE_SEQ     ,
           USE_AMT     ,       SALE_DIV    ,
           USE_DIV     ,
           REMARKS     ,
           BRAND_CD    ,       STOR_CD     ,
           POS_NO      ,       BILL_NO     ,
           USE_TM      ,       
           ORG_USE_DT  ,       ORG_USE_SEQ ,
           USE_YN      ,
           INST_DT     ,       INST_USER   ,
           UPD_DT      ,       UPD_USER
       )
       VALUES
       (
           PSV_COMP_CD ,       PSV_CARD_ID ,
           PSV_USE_DT  ,       nRecSeq     ,
           TO_NUMBER(PSV_USE_AMT) ,       PSV_SALE_DIV,
           CASE WHEN PSV_SALE_DIV = '1' THEN '301'             ELSE '302'             END ,
           CASE WHEN PSV_SALE_DIV = '1' THEN '�����ī�� ���' ELSE '�����ī�� ���' END ,
           PSV_BRAND_CD,       PSV_STOR_CD ,
           PSV_POS_NO  ,       PSV_BILL_NO ,
           PSV_USE_TM  ,
           PSV_ORG_USE_DT,     CASE WHEN PSV_ORG_USE_SEQ = '0' THEN NULL ELSE TO_NUMBER(PSV_ORG_USE_SEQ) END,
           'Y'         ,
           SYSDATE     ,       'SYS'       ,
           SYSDATE     ,       'SYS'
       );
       
       IF NVL(lsCustId, ' ') <> ' ' THEN -- ȸ�� ID ���� ��
          IF PSV_SALE_DIV IN('301', '303', '901') AND TO_NUMBER(PSV_USE_AMT) > 0 THEN -- �����������[301:���, 302:����ǰ, 303:��봩��, 901:����]
             UPDATE C_CUST
                SET CASH_USE_DT = PSV_USE_DT
              WHERE COMP_CD     = PSV_COMP_CD
                AND CUST_ID     = lsCustId;
          END IF;
       END IF;
    ELSE -- 
       -- �Ϸù�ȣ ���
       SELECT SQ_PCRM_SEQ.NEXTVAL
         INTO nRecSeq
         FROM DUAL;
           
       INSERT INTO C_CARD_SAV_HIS
       (
           COMP_CD     ,       CARD_ID     ,
           USE_DT      ,       USE_SEQ     ,
           SAV_USE_FG  ,
           SAV_USE_DIV ,
           REMARKS     ,
           SAV_MLG     ,
           LOS_MLG     ,       LOS_MLG_YN  ,
           LOS_MLG_DT  ,       SAV_PT      ,
           USE_PT      ,       LOS_PT      ,
           BRAND_CD    ,       STOR_CD     ,
           POS_NO      ,       BILL_NO     ,
           ORG_USE_DT  ,       ORG_USE_SEQ ,
           USE_TM      ,       USE_YN      ,
           INST_DT     ,       INST_USER   ,
           UPD_DT      ,       UPD_USER
       )
       VALUES
       (
           PSV_COMP_CD ,       PSV_CARD_ID ,
           PSV_USE_DT  ,       nRecSeq     ,
           CASE WHEN PSV_SALE_DIV LIKE '2%' THEN '1'             ELSE '2'             END,
           PSV_SALE_DIV ,
           CASE WHEN PSV_SALE_DIV LIKE '2%' THEN '����Ʈ ����' ELSE '����Ʈ ���' END ||
           CASE WHEN PSV_SALE_DIV LIKE '%2' THEN '���'          ELSE NULL            END,
           CASE WHEN PSV_SALE_DIV IN ('201', '301') THEN TO_NUMBER(PSV_SAV_MLG) ELSE TO_NUMBER(PSV_SAV_MLG) END,
           0           ,       'N'         ,
           TO_CHAR(ADD_MONTHS(TO_DATE(PSV_USE_DT, 'YYYYMMDD'), 12) - 1, 'YYYYMMDD') ,
           CASE WHEN PSV_SALE_DIV IN ('201', '301') THEN TO_NUMBER(PSV_SAV_PT)  ELSE TO_NUMBER(PSV_SAV_PT) END,
           CASE WHEN PSV_SALE_DIV IN ('201', '301') THEN TO_NUMBER(PSV_USE_PT)  ELSE TO_NUMBER(PSV_USE_PT) END,
           0           ,
           PSV_BRAND_CD,       PSV_STOR_CD ,
           PSV_POS_NO  ,       PSV_BILL_NO ,
           PSV_ORG_USE_DT,     CASE WHEN PSV_ORG_USE_SEQ = '0' THEN NULL ELSE TO_NUMBER(PSV_ORG_USE_SEQ) END,
           PSV_USE_TM  ,       'Y'         ,
           SYSDATE    ,        'SYS'       ,
           SYSDATE    ,        'SYS'
       );
       
       IF NVL(lsCustId, ' ') <> ' ' THEN -- ȸ�� ID ���� ��
          IF (PSV_SALE_DIV IN(       '201', '203', '901', '902', '903') AND TO_NUMBER(PSV_SAV_MLG) > 0) OR
             (PSV_SALE_DIV IN('101', '201', '203', '901', '902', '903') AND TO_NUMBER(PSV_SAV_PT)  > 0) THEN -- �����������[101:ȸ������, 102:ȸ��Ż�� �Ҹ�, 201:����, 202:������ǰ, 203:��������, 301:���, 302:����ǰ, 303:��봩��, 901:����, 902:����, 903:��Ÿ]
             
             -- ���� ���� DATA ����
             IF PSV_SALE_DIV IN('201', '203', '901', '902', '903') AND TO_NUMBER(PSV_SAV_MLG) > 0 THEN
                 -- ���ʱ��� ���� ���� ���� ���� 
                 SELECT COUNT(*) INTO nRecCnt
                 FROM   C_COUPON_MST      MST
                      , C_COUPON_ITEM_GRP GRP
                 WHERE  MST.COMP_CD   = GRP.COMP_CD
                 AND    MST.COUPON_CD = GRP.COUPON_CD
                 AND    MST.CLOSE_DT >= TO_CHAR(SYSDATE, 'YYYYMMDD')
                 AND    GRP.PRT_DIV   = '07';  -- ���� ���౸��[07:ù����]
                 
                 -- ���� ���ϸ��� ���� ����
                 SELECT MLG_SAV_DT INTO lsMlgSavDt
                 FROM   C_CUST CST
                 WHERE  CST.COMP_CD   = PSV_COMP_CD
                 AND    CST.CUST_ID   = lsCustId;
                 
                 IF nRecCnt > 0 AND lsMlgSavDt IS NULL THEN
                    -- ���� ���� �̷� �ۼ�
                    MERGE   INTO C_CUST_FBD
                    USING   DUAL
                    ON     (
                                COMP_CD = PSV_COMP_CD
                            AND CUST_ID = lsCustId
                           )
                    WHEN NOT MATCHED THEN
                        INSERT (
                                COMP_CD    ,    CUST_ID     ,
                                SALE_DT    ,    BRAND_CD    ,
                                STOR_CD    ,    POS_NO      ,
                                BILL_NO    ,    SALE_DIV    ,
                                SAV_MLG    ,    COUPON_PRT  ,
                                INST_DT    ,    INST_USER   ,
                                UPD_DT     ,    UPD_USER
                               )
                        VALUES (
                                PSV_COMP_CD ,   lsCustId    ,
                                PSV_USE_DT  ,   PSV_BRAND_CD,
                                PSV_STOR_CD ,   PSV_POS_NO  ,
                                PSV_BILL_NO ,   PSV_SALE_DIV,
                                TO_NUMBER(PSV_SAV_MLG) ,   'N'         ,
                                SYSDATE     ,   'PKG'       ,
                                SYSDATE     ,   'PKG'       
                               );
                 END IF;
             END IF;
             
             -- �ֱ� ���ϸ��� �������� 
             UPDATE C_CUST
                SET MLG_SAV_DT  = PSV_USE_DT
              WHERE COMP_CD     = PSV_COMP_CD
                AND CUST_ID     = lsCustId;
          END IF;
       END IF;
    END IF;
    
    OPEN asResult FOR
    SELECT  REC_SEQ, CUR_SAV_CASH, CUR_SAV_MLG, CUR_SAV_PNT, REM_MLG_CNT
      FROM (-- ���ϸ���
            SELECT nRecSeq AS REC_SEQ, SAV_CASH - USE_CASH AS CUR_SAV_CASH
                 , 0 AS CUR_SAV_MLG, 0  AS CUR_SAV_PNT
                 , 0 AS REM_MLG_CNT
              FROM C_CARD
             WHERE COMP_CD   = PSV_COMP_CD
               AND CARD_ID   = PSV_CARD_ID
               AND CARD_STAT = '10' -- ī�����[00:���, 10:����, 90:�нǽŰ�, 91:����, 99:���]
               AND USE_YN    = 'Y' -- ��뿩��[Y:���, N:������]
               AND 1         = (CASE WHEN PSV_SALE_DIV IN ('1', '2') THEN 1 ELSE 0 END)
            UNION ALL -- ����Ʈ(�����) ����/���
            SELECT nRecSeq AS RECSEQ, 0 AS CUR_SAV_CASH, SAV_MLG - LOS_MLG  AS CUR_SAV_MLG
                 , SAV_PT - USE_PT - LOS_PT  AS CUR_SAV_PNT
                 ,(
                   SELECT CASE WHEN MIN(LVL.LVL_STD_STR) IS NULL THEN 0 ELSE MIN(LVL.LVL_STD_STR) - (CST.SAV_MLG - CST.LOS_MLG) END 
                   FROM   C_CUST_LVL LVL
                   WHERE  LVL.COMP_CD     = CST.COMP_CD
                   AND    LVL.LVL_STD_STR > (CST.SAV_MLG - CST.LOS_MLG) 
                   AND    LVL.USE_YN      = 'Y'
                  ) AS REM_MLG_CNT
              FROM C_CUST CST
             WHERE CUST_STAT = '2'  -- ȸ������[1:����, 2:�����, 9:Ż��]
               AND USE_YN    = 'Y'  -- ��뿩��[Y:���, N:������]
               AND CUST_ID   = (SELECT CUST_ID
                                  FROM C_CARD
                                 WHERE COMP_CD   = PSV_COMP_CD
                                   AND CARD_ID   = PSV_CARD_ID
                                   AND CARD_STAT = '10' -- ī�����[00:���, 10:����, 90:�нǽŰ�, 91:����, 99:���]
                                   AND USE_YN    = 'Y' -- ��뿩��[Y:���, N:������]
                               )
               AND 1         = (CASE WHEN PSV_SALE_DIV IN ('201', '202') AND lsCustId IS NOT NULL THEN 1 ELSE 0 END)
            UNION ALL  -- ����Ʈ(���߱�) ī�� ����/���
            SELECT nRecSeq AS RECSEQ, 0 AS CUR_SAV_CASH
                 , SAV_MLG - LOS_MLG  AS CUR_SAV_MLG, SAV_PT - USE_PT - LOS_PT  AS CUR_SAV_PNT
                 , 0 AS REM_MLG_CNT
              FROM C_CARD
             WHERE COMP_CD   = PSV_COMP_CD
               AND CARD_ID   = PSV_CARD_ID
               AND CARD_STAT = '10' -- ī�����[00:���, 10:����, 90:�нǽŰ�, 91:����, 99:���]
               AND USE_YN    = 'Y' -- ��뿩��[Y:���, N:������]
               AND 1         = (CASE WHEN PSV_SALE_DIV IN ('201', '202') AND lsCustId IS NULL THEN 1 ELSE 0 END)   
            UNION ALL
            SELECT nRecSeq AS RECSEQ, 0 AS CUR_SAV_CASH
                 , 0 AS CUR_SAV_MLG, SAV_PT - USE_PT - LOS_PT AS CUR_SAV_PNT
                 , 0 AS REM_MLG_CNT 
              FROM C_CARD
             WHERE COMP_CD   = PSV_COMP_CD
               AND CARD_ID   = PSV_CARD_ID
               AND CARD_STAT = '10' -- ī�����[00:���, 10:����, 90:�нǽŰ�, 91:����, 99:���]
               AND USE_YN    = 'Y' -- ��뿩��[Y:���, N:������]
               AND 1         = (CASE WHEN PSV_SALE_DIV IN ('301', '302') THEN 1 ELSE 0 END)
           );
           
    asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001392'); -- ���� ó���Ǿ����ϴ�.
    
    RETURN;
  EXCEPTION
    WHEN ERR_HANDLER THEN
         OPEN asResult FOR
            SELECT 0
            FROM   DUAL;
             
         ROLLBACK;
         RETURN;
    WHEN OTHERS THEN
         OPEN asResult FOR
            SELECT 0
            FROM   DUAL;
             
         asRetVal := '1003';
         asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001187')||'['||SQLERRM||']'; -- ������ �߻��Ͽ����ϴ�.
         
         ROLLBACK;
         RETURN;
  END SET_MEMB_CHG_20;

  ------------------------------------------------------------------------------
  --  Package Name     : SET_MEMB_CHG_30
  --  Description      : ����� ȯ��/����
  --  Ref. Table       : C_CARD            �����ī�� ������
  --                     C_CUST            ȸ�� ������
  --                     C_CARD_CHARGE_HIS �����ī�� �����̷�
  ------------------------------------------------------------------------------
  --  Create Date      : 2015-01-13 ����� CRM PJT
  --  Modify Date      : 
  ------------------------------------------------------------------------------
  PROCEDURE SET_MEMB_CHG_30
  (
    PSV_COMP_CD           IN   VARCHAR2, -- 1. ȸ���ڵ�
    PSV_LANG_TP           IN   VARCHAR2, -- 2. ����ڵ�
    PSV_CARD_ID_SEND      IN   VARCHAR2, -- 3. ī���ȣ(�絵)
    PSV_CARD_ID_RECV      IN   VARCHAR2, -- 4. ī���ȣ(���)
    PSV_CRG_DT            IN   VARCHAR2, -- 5. ��������
    PSV_CRG_FG            IN   VARCHAR2, -- 6. ��������[3:ȯ��, 4:����]
    PSV_CRG_DIV           IN   VARCHAR2, -- 7. �������[9:����]
    PSV_CRG_AMT           IN   VARCHAR2, -- 8. �����ݾ�
    PSV_ACC_USER_NM       IN   VARCHAR2, -- 9. �����ָ�
    PSV_ACC_BANK          IN   VARCHAR2, -- 10.�����ڵ�
    PSV_ACC_NUM           IN   VARCHAR2, -- 11.���¹�ȣ
    PSV_CHANNEL           IN   VARCHAR2, -- 12.��α���[2:WEB, 3:MOBILE]
    asRetVal              OUT  VARCHAR2, -- 13.����ڵ�[1:����  �׿ܴ� ����]
    asRetMsg              OUT  VARCHAR2, -- 14.����޽���
    asResult              OUT  REC_SET.M_REFCUR
  ) IS
      
    lsCardId        C_CARD.CARD_ID%TYPE;                    -- ī�� ID
    lsissue_div     C_CARD.ISSUE_DIV%TYPE;                  -- �߱ޱ���[0:�ű�, 1:��߱�]
    lscard_div      C_CARD.CARD_DIV%TYPE;                   -- ī���������[1:ȸ��, 2:��������, 3:����]
    lsbrand_cd      C_CARD.BRAND_CD%TYPE;                   -- ��������
    lsstor_cd       C_CARD.STOR_CD%TYPE;                    -- �����ڵ�
    lsCustId        C_CARD.CUST_ID%TYPE;                    -- ȸ�� ID
    lsCard_stat     C_CARD.CARD_STAT%TYPE;                  -- ī�����[00:���, 10:����, 90:�нǽŰ�, 91:����, 99:���]
    lsRepCardYn     C_CARD.REP_CARD_YN%TYPE;                -- ȸ�� ID
    llstamp_tax     C_CARD_CHARGE_HIS.STAMP_TAX%TYPE := 0;  -- ������
    llsav_cash      C_CARD.SAV_CASH%TYPE;                   -- �����ݾ�
    lluse_cash      C_CARD.USE_CASH%TYPE;                   -- ���ݾ�
    nRecCnt         NUMBER(7) := 0;
    
    ERR_HANDLER     EXCEPTION;
    
  BEGIN
    asRetVal    := '0000' ;
    asRetMsg    := 'OK'   ;
    
    IF PSV_CRG_FG NOT IN ('3', '4') THEN -- ��������[3:ȯ��, 4:����]
       asRetVal := '1000';
       asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001411'); -- �������� �Է� ���� �Դϴ�.
       
       RAISE ERR_HANDLER;
    END IF;
    
    IF PSV_CRG_FG =  '3' THEN -- ��������[3:ȯ��]
       IF PSV_ACC_USER_NM IS NULL OR PSV_ACC_BANK IS NULL OR PSV_ACC_NUM IS NULL THEN
          asRetVal := '1001';
          asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001413'); -- ȯ�ҽ� �����ڵ�. ������, ���¹�ȣ�� �ʼ� �Է��׸��Դϴ�.
          
          RAISE ERR_HANDLER;
       END IF;
    ELSE
       SELECT COUNT(DISTINCT CRD.CUST_ID)
         INTO nRecCnt
         FROM C_CARD CRD
        WHERE CRD.COMP_CD  = PSV_COMP_CD
          AND CRD.CARD_ID IN (PSV_CARD_ID_SEND, PSV_CARD_ID_RECV);
          
       IF nRecCnt != 1 THEN
          asRetVal := '1002';
          asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001417'); -- ���, �絵���� ����ȣ�� ��ġ���� �ʽ��ϴ�.
          
          RAISE ERR_HANDLER;
       END IF;
    END IF;
     
    -- �絵ī�� üũ
    SELECT COUNT(*), MAX(CARD_STAT), MAX(CUST_ID), MAX(SAV_CASH), MAX(USE_CASH), MAX(ISSUE_DIV)
      INTO nRecCnt,  lscard_stat,    lsCustId,     llsav_cash,    lluse_cash,    lsissue_div
      FROM C_CARD -- �����ī�� ������
     WHERE COMP_CD    = PSV_COMP_CD
       AND CARD_ID    = PSV_CARD_ID_SEND
       AND USE_YN     = 'Y'; -- ��뿩��[Y:���, N:������]
       
    IF nRecCnt = 0 THEN
       asRetVal := '1003';
       asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001394'); -- ������� ���� ī���ȣ �Դϴ�.
       
       RAISE ERR_HANDLER;
    ELSE
        IF PSV_CRG_FG =  '3' THEN
            IF (ABS(TO_NUMBER(PSV_CRG_AMT)) != (llsav_cash - lluse_cash)) THEN
                asRetVal := '1004';
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001426'); -- ȯ�ұݾ��� �ܾװ� ��ġ���� �ʽ��ϴ�.
                
                RAISE ERR_HANDLER;
            END IF;
            
            IF ((lluse_cash / llsav_cash * 100) < 60 ) THEN
                asRetVal := '1005';
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001427'); -- �����ݾ��� 60%�̻� ��� �� ȯ���� �����մϴ�.
                
                RAISE ERR_HANDLER;
            END IF;
        ELSE
            IF (TO_NUMBER(PSV_CRG_AMT) > (llsav_cash - lluse_cash)) THEN
                asRetVal := '1006';
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001416'); -- �ܾ��� �����ݾ׺��� �۽��ϴ�.
                
                RAISE ERR_HANDLER;
            END IF;
       END IF;
       
       -- 2015/02/10 �нŵ� ī��� ����, ���, ���� �Ұ�
       CASE WHEN lscard_stat = '92' THEN -- ȯ��
                 asRetVal := '1007';
                 asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001414'); -- ȯ�ҵ� ī���ȣ �Դϴ�.
                 
                 RAISE ERR_HANDLER;
            WHEN lscard_stat = '91' THEN -- ����
                 asRetVal := '1008';
                 asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001397'); -- ������ ī���ȣ �Դϴ�.
                 
                 RAISE ERR_HANDLER;
            WHEN lscard_stat = '99' THEN -- ���
                 asRetVal := '1009';
                 asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001398'); -- ���� ī���ȣ �Դϴ�.
                 
                 RAISE ERR_HANDLER;
            ELSE
                 asRetVal := '0000';
       END CASE;
       
       BEGIN
         SELECT NVL(PC.PARA_VAL, PM.PARA_DEFAULT), BM.BRAND_CD, '0000000' 
           INTO lscard_div , lsbrand_cd , lsstor_cd
           FROM PARA_MST     PM
              , PARA_COMPANY PC
              , BRAND_MEMB   BM
          WHERE PM.PARA_CD      = PC.PARA_CD(+)
            AND PM.PARA_TABLE   = 'PARA_COMPANY'
            AND PM.PARA_CD      = '2003'
            AND PC.COMP_CD(+)   = PSV_COMP_CD
            AND BM.COMP_CD      = PSV_COMP_CD
            AND BM.BRAND_CD     = (
                                    SELECT CCT.TSMS_BRAND_CD
                                      FROM C_CARD_TYPE     CCT
                                         , C_CARD_TYPE_REP CTR 
                                     WHERE CCT.COMP_CD   = CTR.COMP_CD
                                       AND CCT.CARD_TYPE = CTR.CARD_TYPE
                                       AND CTR.COMP_CD   = PSV_COMP_CD
                                       AND decrypt(PSV_CARD_ID_SEND) BETWEEN decrypt(CTR.START_CARD_CD) AND decrypt(CTR.CLOSE_CARD_CD)
                                       AND ROWNUM        = 1
                                 )
            AND PM.USE_YN       = 'Y'
            AND PC.USE_YN(+)    = 'Y'    -- ��뿩��[Y:���, N:������]
            AND BM.USE_YN       = 'Y';
       EXCEPTION
         WHEN OTHERS THEN 
              lscard_div := '1';
              lsbrand_cd := '0000';
              lsstor_cd  := '0000000';
       END;
    END IF;
    
    -- ���ī�� üũ
    IF PSV_CRG_FG = '4' THEN
       SELECT COUNT(*), MAX(CARD_STAT), MAX(CUST_ID), MAX(SAV_CASH), MAX(USE_CASH), MAX(ISSUE_DIV)
         INTO nRecCnt,  lscard_stat,    lsCustId,     llsav_cash,    lluse_cash,    lsissue_div
         FROM C_CARD -- �����ī�� ������
        WHERE COMP_CD    = PSV_COMP_CD
          AND CARD_ID    = PSV_CARD_ID_RECV
          AND USE_YN     = 'Y'; -- ��뿩��[Y:���, N:������]
          
       IF nRecCnt = 0 THEN
          asRetVal := '1020';
          asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001394'); -- ������� ���� ī���ȣ �Դϴ�.
          
          RAISE ERR_HANDLER;
       END IF;
       
       -- 2015/02/10 �нŵ� ī��� ����, ���, ���� �Ұ�
       CASE WHEN lscard_stat = '90' THEN -- �нǽŰ�
                 asRetVal := '1021';
                 asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001396'); -- �нǽŰ�� ī���ȣ �Դϴ�.
                 
                 RAISE ERR_HANDLER;
            WHEN lscard_stat = '91' THEN -- ����
                 asRetVal := '1022';
                 asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001397'); -- ������ ī���ȣ �Դϴ�.
                 
                 RAISE ERR_HANDLER;
            WHEN lscard_stat = '92' THEN -- ȯ��
                 asRetVal := '1023';
                 asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001414'); -- ȯ�ҵ� ī���ȣ �Դϴ�.
                 
                 RAISE ERR_HANDLER;
            WHEN lscard_stat = '99' THEN -- ���
                 asRetVal := '1024';
                 asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001398'); -- ���� ī���ȣ �Դϴ�.
                 
                 RAISE ERR_HANDLER;
            ELSE
                 asRetVal := '0000';
       END CASE;
       
       IF llsav_cash = 0 AND lluse_cash = 0 THEN       -- �����ݾװ� ���ݾ��� 0�̸�
          SELECT COUNT(*)
            INTO nRecCnt
            FROM C_CARD_CHARGE_HIS A           -- �����ī�� �����̷�
           WHERE COMP_CD      = PSV_COMP_CD
             AND CARD_ID      = PSV_CARD_ID_RECV
             AND CRG_FG       IN('1', '4', '9')     -- ��������[1:����, 2:���, 3:ȯ��, 4:����, 9:����]
             AND USE_YN       = 'Y'                 -- ��뿩��[Y:���, N:������]
             AND NOT EXISTS (                       -- ��ҳ����� ���� ��� ����
                             SELECT 1   
                               FROM C_CARD_CHARGE_HIS B
                              WHERE B.COMP_CD     = A.COMP_CD
                                AND B.CARD_ID     = A.CARD_ID
                                AND B.ORG_CRG_DT  = A.CRG_DT
                                AND B.ORG_CRG_SEQ = A.ORG_CRG_SEQ
                                AND B.CRG_FG      = '2' -- ��������[1:����, 2:���, 3:ȯ��, 4:����, 9:����]
                                AND B.USE_YN      = 'Y' -- ��뿩��[Y:���, N:������]
                             );
                                     
          IF nRecCnt = 0 THEN -- ī������� �������� ��
             BEGIN
               SELECT TO_NUMBER(VAL_C1)
                 INTO llstamp_tax
                 FROM COMMON
                WHERE CODE_TP     = '01711' -- ����ī�� ������ �ݾױ���
                  AND TO_NUMBER(PSV_CRG_AMT) BETWEEN VAL_N1 AND VAL_N2
                  AND USE_YN      = 'Y';    -- ��뿩��[Y:���, N:������]
             EXCEPTION
               WHEN OTHERS THEN 
                    llstamp_tax := 0;
             END;
          END IF;
       END IF;
    END IF;
    
    -- �絵/ȯ�� �̷� �ۼ�
    INSERT INTO C_CARD_CHARGE_HIS
    (
        COMP_CD     ,       CARD_ID     ,
        CRG_DT      ,
        CRG_SEQ     ,
        CRG_FG      ,       CRG_DIV     ,
        CRG_AMT     ,       
        CHANNEL     ,
        BRAND_CD    ,       STOR_CD     ,
        REMARKS     ,
        TRN_CARD_ID ,
        POS_NO      ,
        CARD_NO     ,       CARD_NM     ,
        APPR_DT     ,       APPR_TM     ,
        APPR_VD_CD  ,       APPR_VD_NM  ,
        APPR_IS_CD  ,       APPR_COM    ,
        ALLOT_LMT   ,
        READ_DIV    ,       APPR_DIV    ,
        APPR_NO     ,
        ORG_CRG_DT  ,       ORG_CRG_SEQ ,
        STAMP_TAX   ,       USE_YN      ,
        SAP_IF_YN   ,       SAP_IF_DT   ,   
        INST_DT     ,       INST_USER   ,
        UPD_DT      ,       UPD_USER
    )
    VALUES
    (
        PSV_COMP_CD ,       PSV_CARD_ID_SEND,
        PSV_CRG_DT  ,
        (
         SELECT NVL(MAX(CRG_SEQ), 0) + 1
           FROM C_CARD_CHARGE_HIS
          WHERE COMP_CD = PSV_COMP_CD
            AND CARD_ID = PSV_CARD_ID_SEND
            AND CRG_DT  = PSV_CRG_DT
        )           ,
        PSV_CRG_FG  ,       PSV_CRG_DIV ,
        CASE WHEN PSV_CRG_FG = '3' THEN TO_NUMBER(PSV_CRG_AMT) ELSE TO_NUMBER(PSV_CRG_AMT) * (-1) END, 
        PSV_CHANNEL ,
        lsbrand_cd  ,       lsstor_cd   ,
        GET_COMMON_CODE_NM('01735', PSV_CRG_FG, PSV_LANG_TP),
        PSV_CARD_ID_RECV,
        NULL        ,
        NULL        ,     NULL  ,
        NULL        ,     NULL  ,
        NULL        ,     NULL  ,
        NULL        ,     NULL  ,
        NULL        ,
        NULL        ,     NULL  ,
        NULL        ,
        NULL        ,     NULL  ,
        0           ,     'Y'   ,  -- ����� ������ NG
        'N'         ,     NULL  ,
        SYSDATE     ,     'SYS' ,
        SYSDATE     ,     'SYS'
    );
    
    -- ����̷� �ۼ�(��������[3:ȯ��, 4:����]�� 4:���� �϶���)
    IF PSV_CRG_FG = '4' THEN
       INSERT INTO C_CARD_CHARGE_HIS
       (
           COMP_CD     ,       CARD_ID     ,
           CRG_DT      ,
           CRG_SEQ     ,
           CRG_FG      ,       CRG_DIV     ,
           CRG_AMT     ,       
           CHANNEL     ,
           BRAND_CD    ,       STOR_CD     ,
           REMARKS     ,
           TRN_CARD_ID ,
           POS_NO      ,
           CARD_NO     ,       CARD_NM     ,
           APPR_DT     ,       APPR_TM     ,
           APPR_VD_CD  ,       APPR_VD_NM  ,
           APPR_IS_CD  ,       APPR_COM    ,
           ALLOT_LMT   ,
           READ_DIV    ,       APPR_DIV    ,
           APPR_NO     ,
           ORG_CRG_DT  ,       ORG_CRG_SEQ ,
           STAMP_TAX   ,       USE_YN      ,
           SAP_IF_YN   ,       SAP_IF_DT   ,
           INST_DT     ,       INST_USER   ,
           UPD_DT      ,       UPD_USER
       )
       VALUES
       (
           PSV_COMP_CD ,       PSV_CARD_ID_RECV,
           PSV_CRG_DT  ,
           (
            SELECT NVL(MAX(CRG_SEQ), 0) + 1
              FROM C_CARD_CHARGE_HIS
             WHERE COMP_CD = PSV_COMP_CD
               AND CARD_ID = PSV_CARD_ID_RECV
               AND CRG_DT  = PSV_CRG_DT
           )           ,
           PSV_CRG_FG  ,       PSV_CRG_DIV ,
           TO_NUMBER(PSV_CRG_AMT) ,       
           PSV_CHANNEL ,
           lsbrand_cd  ,       lsstor_cd   ,
           GET_COMMON_CODE_NM('01735', PSV_CRG_FG, PSV_LANG_TP),
           PSV_CARD_ID_SEND,
           NULL        ,
           NULL        ,     NULL  ,
           NULL        ,     NULL  ,
           NULL        ,     NULL  ,
           NULL        ,     NULL  ,
           NULL        ,
           NULL        ,     NULL  ,
           NULL        ,
           NULL        ,     NULL  ,
           llstamp_tax ,     'Y'   ,         -- ����� ���� ������ ��� ������ OK
           'N'          ,    NULL  ,
           SYSDATE     ,     'SYS' ,
           SYSDATE     ,     'SYS'
       );
    END IF;
    
    -- ȯ�� �� ī���ȣ �������� SET
    IF PSV_CRG_FG = '3' THEN
        -- ȸ�� ���� ���� ��� 
        SELECT  CUST_ID    , 
                CARD_STAT  , 
                REP_CARD_YN 
        INTO    lsCustId, lsCard_stat, lsRepCardYn
        FROM    C_CARD
        WHERE   COMP_CD = PSV_COMP_CD
        AND     CARD_ID = PSV_CARD_ID_SEND;
        
        IF lsCustId IS NOT NULL THEN
            SELECT  COUNT(*) INTO nRecCnt
            FROM    C_CARD
            WHERE   COMP_CD  = PSV_COMP_CD
            AND     CUST_ID  = lsCustId
            AND     CARD_ID != PSV_CARD_ID_SEND
            AND     CARD_STAT IN ('00', '10')
            AND     USE_YN   = 'Y';
        END IF;
    
        UPDATE C_CARD
           SET CARD_STAT     = '92'
            ,  REFUND_REQ_DT = PSV_CRG_DT||TO_CHAR(SYSDATE, 'HH24MISS')
            ,  BANK_CD       = PSV_ACC_BANK
            ,  ACC_NO        = PSV_ACC_NUM
            ,  BANK_USER_NM  = PSV_ACC_USER_NM
            ,  REFUND_STAT   = '01'
            ,  REFUND_CASH   = TO_NUMBER(PSV_CRG_AMT)
            ,  REFUND_CD     = NULL
            ,  REFUND_MSG    = NULL
            ,  REP_CARD_YN   = CASE WHEN lsRepCardYn = 'Y' THEN 'N' ELSE 'N' END
            ,  UPD_DT        = SYSDATE
            ,  UPD_USER      = CASE WHEN PSV_CHANNEL = '1' THEN 'POS USER'
                                    WHEN PSV_CHANNEL = '2' THEN 'WEB USER'
                                    WHEN PSV_CHANNEL = '3' THEN 'APP USER'
                                    ELSE                        'ADMIN'
                               END     
       WHERE   COMP_CD       = PSV_COMP_CD
         AND   CARD_ID       = PSV_CARD_ID_SEND;
         
       
       IF nRecCnt > 0 AND lsRepCardYn = 'Y' THEN 
            UPDATE  C_CARD
            SET     REP_CARD_YN = 'Y'
            WHERE   COMP_CD = PSV_COMP_CD
            AND     CARD_ID = (
                                SELECT  CARD_ID
                                FROM   (
                                        SELECT  CARD_ID
                                             ,  ROW_NUMBER() OVER(PARTITION BY CUST_ID ORDER BY ISSUE_DT DESC) R_NUM
                                        FROM    C_CARD
                                        WHERE   COMP_CD  = PSV_COMP_CD
                                        AND     CUST_ID  = lsCustId
                                        AND     CARD_ID != PSV_CARD_ID_SEND
                                        AND     CARD_STAT IN ('00', '10')
                                        AND     USE_YN   = 'Y'
                                       )
                               WHERE    R_NUM = 1
                              );
        END IF; 
    END IF;
    
    OPEN asResult FOR  -- ����� ī�� ���� ���
    SELECT SAV_CASH - USE_CASH AS CUR_CASH_PNT
      FROM C_CARD
     WHERE COMP_CD = PSV_COMP_CD
       AND CARD_ID = CASE WHEN PSV_CRG_FG = '3' THEN PSV_CARD_ID_SEND ELSE PSV_CARD_ID_RECV END
       AND USE_YN  = 'Y'; -- ��뿩��[Y:���, N:������]
       
    asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001392'); -- ����ó�� �Ǿ����ϴ�.
    
    RETURN;
  EXCEPTION
    WHEN ERR_HANDLER THEN
        OPEN asResult FOR
            SELECT  0 
            FROM    DUAL;
            
        ROLLBACK;
        RETURN;
    WHEN OTHERS THEN
        OPEN asResult FOR
            SELECT 0
            FROM   DUAL;
             
        asRetVal := '2001';
        asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001187')||'['||SQLERRM||']'; -- ������ �߻��Ͽ����ϴ�.
        
        ROLLBACK; 
        RETURN;
  END SET_MEMB_CHG_30;

  ------------------------------------------------------------------------------
  --  Package Name     : SET_MEMB_CHG_40
  --  Description      : ����� ȯ�� - ��ü
  --  Ref. Table       : C_CARD            �����ī�� ������
  --                     C_CUST            ȸ�� ������
  --                     C_CARD_CHARGE_HIS �����ī�� �����̷�
  ------------------------------------------------------------------------------
  --  Create Date      : 2015-01-13 ����� CRM PJT
  --  Modify Date      : 
  ------------------------------------------------------------------------------
  PROCEDURE SET_MEMB_CHG_40
  (
    PSV_COMP_CD           IN   VARCHAR2, -- 1. ȸ���ڵ�
    PSV_LANG_TP           IN   VARCHAR2, -- 2. ����ڵ�
    PSV_CUST_ID           IN   VARCHAR2, -- 3. ����ȣ
    PSV_CRG_DT            IN   VARCHAR2, -- 4. ��������
    PSV_CRG_FG            IN   VARCHAR2, -- 5. ��������[3:ȯ��]
    PSV_CRG_DIV           IN   VARCHAR2, -- 6. �������[9:����]
    PSV_CRG_AMT           IN   VARCHAR2, -- 7. �����ݾ�
    PSV_ACC_USER_NM       IN   VARCHAR2, -- 8. �����ָ�
    PSV_ACC_BANK          IN   VARCHAR2, -- 9.�����ڵ�
    PSV_ACC_NUM           IN   VARCHAR2, -- 10.���¹�ȣ
    PSV_CHANNEL           IN   VARCHAR2, -- 11.��α���[1:POS, 2:WEB, 3:MOBILE, 9:������]
    asRetVal              OUT  VARCHAR2, -- 12.����ڵ�[1:����  �׿ܴ� ����]
    asRetMsg              OUT  VARCHAR2, -- 13.����޽���
    asResult              OUT  REC_SET.M_REFCUR
  ) IS
    CURSOR CUR_1 IS
        SELECT  CST.COMP_CD
              , CST.CUST_ID
              , CST.CUST_STAT
              , CST.SAV_CASH AS CUST_SAV_CASH
              , CST.USE_CASH AS CUST_USE_CASH
              , CRD.CARD_ID
              , CRD.CARD_STAT
              , CRD.SAV_CASH AS CARD_SAV_CASH
              , CRD.USE_CASH AS CARD_USE_CASH
              , CRD.ISSUE_DIV
          FROM  C_CARD CRD-- �����ī�� ������
              , C_CUST CST-- ����ʰ� ������
         WHERE  CRD.COMP_CD = CST.COMP_CD
           AND  CRD.CUST_ID = CST.CUST_ID
           AND  CST.COMP_CD = PSV_COMP_CD
           AND  CST.CUST_ID = PSV_CUST_ID
           AND  CST.USE_YN  = 'Y'    -- ����뿩��[Y:���, N:������]
           AND  CRD.USE_YN  = 'Y'    -- ī���뿩��[Y:���, N:������]
           AND  CRD.CARD_STAT NOT IN ('91', '92', '99');  
    
    lscard_div      C_CARD.CARD_DIV%TYPE;                   -- ī���������[1:ȸ��, 2:��������, 3:����]
    lsbrand_cd      C_CARD.BRAND_CD%TYPE;                   -- ��������
    lsstor_cd       C_CARD.STOR_CD%TYPE;                    -- �����ڵ�
    nRecCnt         NUMBER(7) := 0;
    
    ERR_HANDLER     EXCEPTION;
    
  BEGIN
    asRetVal    := '0000' ;
    asRetMsg    := 'OK'   ;
    
    IF PSV_CRG_FG != '3' THEN -- ��������[3:ȯ��, 4:����]
       asRetVal := '1000';
       asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001411'); -- �������� �Է� ���� �Դϴ�.
       
       RAISE ERR_HANDLER;
    END IF;
    
    IF PSV_CRG_FG =  '3' THEN -- ��������[3:ȯ��]
       IF PSV_ACC_USER_NM IS NULL OR PSV_ACC_BANK IS NULL OR PSV_ACC_NUM IS NULL THEN
          asRetVal := '1001';
          asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001413'); -- ȯ�ҽ� �����ڵ�. ������, ���¹�ȣ�� �ʼ� �Է��׸��Դϴ�.
          
          RAISE ERR_HANDLER;
       END IF;
    END IF;
     
    -- ī�庰 üũ üũ
    FOR MYREC IN CUR_1 LOOP
        -- ó���Ǽ� üũ
        nRecCnt := nRecCnt + 1;
        
        --ȯ�� �ݾ� üũ
        IF ((MYREC.CUST_SAV_CASH / MYREC.CUST_SAV_CASH * 100) < 60 ) THEN
            asRetVal := '1004';
            asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001427'); -- �����ݾ��� 60%�̻� ��� �� ȯ���� �����մϴ�.
                
            RAISE ERR_HANDLER;
        END IF;
        
        -- �ܾ� üũ
        IF (ABS(TO_NUMBER(PSV_CRG_AMT)) != (MYREC.CUST_SAV_CASH - MYREC.CUST_USE_CASH)) THEN
            asRetVal := '1005';
            asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001426'); -- ȯ�ұݾ��� �ܾװ� ��ġ���� �ʽ��ϴ�.
              
            RAISE ERR_HANDLER;
        END IF;
       
        -- 2015/02/10 �нŵ� ī��� ����, ���, ���� �Ұ�
        CASE WHEN MYREC.CARD_STAT = '92' THEN -- ȯ��
                 asRetVal := '1006';
                 asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001414'); -- ȯ�ҵ� ī���ȣ �Դϴ�.
                 
                 RAISE ERR_HANDLER;
            WHEN MYREC.CARD_STAT = '91' THEN -- ����
                 asRetVal := '1007';
                 asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001397'); -- ������ ī���ȣ �Դϴ�.
                 
                 RAISE ERR_HANDLER;
            WHEN MYREC.CARD_STAT = '99' THEN -- ���
                 asRetVal := '1008';
                 asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001398'); -- ���� ī���ȣ �Դϴ�.
                 
                 RAISE ERR_HANDLER;
            ELSE
                 asRetVal := '0000';
        END CASE;
       
        BEGIN
            SELECT NVL(PC.PARA_VAL, PM.PARA_DEFAULT), BM.BRAND_CD, '0000000' 
              INTO lscard_div , lsbrand_cd , lsstor_cd
              FROM PARA_MST     PM
                 , PARA_COMPANY PC
                 , BRAND_MEMB   BM
             WHERE PM.PARA_CD      = PC.PARA_CD(+)
               AND PM.PARA_TABLE   = 'PARA_COMPANY'
               AND PM.PARA_CD      = '2003'
               AND PC.COMP_CD(+)   = PSV_COMP_CD
               AND BM.COMP_CD      = PSV_COMP_CD
               AND BM.BRAND_CD     = (
                                        SELECT CCT.TSMS_BRAND_CD
                                          FROM C_CARD_TYPE     CCT
                                             , C_CARD_TYPE_REP CTR 
                                         WHERE CCT.COMP_CD   = CTR.COMP_CD
                                           AND CCT.CARD_TYPE = CTR.CARD_TYPE
                                           AND CTR.COMP_CD   = PSV_COMP_CD
                                           AND decrypt(MYREC.CARD_ID) BETWEEN decrypt(CTR.START_CARD_CD) AND decrypt(CTR.CLOSE_CARD_CD)
                                           AND ROWNUM        = 1
                                     )
               AND PM.USE_YN       = 'Y'
               AND PC.USE_YN(+)    = 'Y'    -- ��뿩��[Y:���, N:������]
               AND BM.USE_YN       = 'Y';
        EXCEPTION
            WHEN OTHERS THEN 
                lscard_div := '1';
                lsbrand_cd := '0000';
                lsstor_cd  := '0000000';
        END;
       
        -- ȯ�� �̷� �ۼ�
        INSERT INTO C_CARD_CHARGE_HIS
        (
            COMP_CD     ,       CARD_ID     ,
            CRG_DT      ,
            CRG_SEQ     ,
            CRG_FG      ,       CRG_DIV     ,
            CRG_AMT     ,       
            CHANNEL     ,
            BRAND_CD    ,       STOR_CD     ,
            REMARKS     ,
            TRN_CARD_ID ,
            POS_NO      ,
            CARD_NO     ,       CARD_NM     ,
            APPR_DT     ,       APPR_TM     ,
            APPR_VD_CD  ,       APPR_VD_NM  ,
            APPR_IS_CD  ,       APPR_COM    ,
            ALLOT_LMT   ,
            READ_DIV    ,       APPR_DIV    ,
            APPR_NO     ,
            ORG_CRG_DT  ,       ORG_CRG_SEQ ,
            STAMP_TAX   ,       USE_YN      ,
            SAP_IF_YN   ,       SAP_IF_DT   ,
            INST_DT     ,       INST_USER   ,
            UPD_DT      ,       UPD_USER
        )
        VALUES
        (
            PSV_COMP_CD ,       MYREC.CARD_ID,
            PSV_CRG_DT  ,
            (
             SELECT NVL(MAX(CRG_SEQ), 0) + 1
               FROM C_CARD_CHARGE_HIS
              WHERE COMP_CD = PSV_COMP_CD
                AND CARD_ID = MYREC.CARD_ID
                AND CRG_DT  = PSV_CRG_DT
            )           ,
            PSV_CRG_FG  ,       PSV_CRG_DIV ,
            (MYREC.CARD_SAV_CASH - MYREC.CARD_USE_CASH) * (-1), 
            PSV_CHANNEL ,
            lsbrand_cd  ,       lsstor_cd   ,
            GET_COMMON_CODE_NM('01735', PSV_CRG_FG, PSV_LANG_TP),
            NULL        ,
            NULL        ,
            NULL        ,     NULL  ,
            NULL        ,     NULL  ,
            NULL        ,     NULL  ,
            NULL        ,     NULL  ,
            NULL        ,
            NULL        ,     NULL  ,
            NULL        ,
            NULL        ,     NULL  ,
            0           ,     'Y'   ,
            'N'         ,     NULL  ,
            SYSDATE     ,     'SYS' ,
            SYSDATE     ,     'SYS'
        );
        
        -- �������� SET
        UPDATE C_CARD
           SET CARD_STAT     = '92'
             , REFUND_REQ_DT = PSV_CRG_DT
             , BANK_CD       = PSV_ACC_BANK
             , ACC_NO        = PSV_ACC_NUM
             , BANK_USER_NM  = PSV_ACC_USER_NM
             , REFUND_STAT   = '01'
             , REFUND_CASH   = TO_NUMBER(PSV_CRG_AMT)
             , REFUND_CD     = NULL
             , REFUND_MSG    = NULL  
        WHERE COMP_CD        = PSV_COMP_CD
          AND CARD_ID        = MYREC.CARD_ID;
    END LOOP;
    
    --ó���Ǽ� üũ
    IF nRecCnt = 0 THEN
       asRetVal := '1020';
       asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1001000269'); -- ó���� ����Ÿ�� �����ϴ�.
        
       RAISE ERR_HANDLER;
    END IF;
    
    OPEN asResult FOR  -- ����� ī�� ȯ�� ���
    SELECT SAV_CASH - USE_CASH AS CUR_CASH_PNT
      FROM C_CUST
     WHERE COMP_CD = PSV_COMP_CD
       AND CUST_ID = PSV_CUST_ID
       AND USE_YN  = 'Y'; -- ��뿩��[Y:���, N:������]
       
    asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001392'); -- ����ó�� �Ǿ����ϴ�.
    
    RETURN;
  EXCEPTION
    WHEN ERR_HANDLER THEN
        OPEN asResult FOR
            SELECT 0
            FROM   DUAL;
            
        ROLLBACK;
        RETURN;
    WHEN OTHERS THEN
        OPEN asResult FOR
            SELECT 0
            FROM   DUAL;
            
        asRetVal := '2001';
        asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001187')||'['||SQLERRM||']'; -- ������ �߻��Ͽ����ϴ�.
        
        ROLLBACK; 
        RETURN;
  END SET_MEMB_CHG_40;
      
  ------------------------------------------------------------------------------
  --  Package Name     : GET_MEMB_CUPN_10
  --  Description      : POS ����� �������� ��ȸ > POS������ ����
  --  Ref. Table       : C_COUPON_MST  ��������� ������
  --                     C_COUPON_CUST ��������� ���ȸ��
  --                     C_CARD        �����ī�� ������
  ------------------------------------------------------------------------------
  --  Create Date      : 2015-01-13 ����� CRM PJT
  --  Modify Date      : 
  ------------------------------------------------------------------------------
  PROCEDURE GET_MEMB_CUPN_10
  (
    PSV_COMP_CD           IN   VARCHAR2, -- 1. ȸ���ڵ� 
    PSV_BRAND_CD          IN   VARCHAR2, -- 2. ��������
    PSV_STOR_CD           IN   VARCHAR2, -- 3. �����ڵ� 
    PSV_LANG_TP           IN   VARCHAR2, -- 4. ����ڵ�
    PSV_CERT_DIV          IN   VARCHAR2, -- 5. ��������[1:ī���ȣ, 2: ������ȣ]   
    PSV_CERT_VAL          IN   VARCHAR2, -- 6. ������ 
    asRetVal              OUT  VARCHAR2, -- 7. ����ڵ�[1:����  �׿ܴ� ����] 
    asRetMsg              OUT  VARCHAR2, -- 8. ����޽��� 
    asResult              OUT  REC_SET.M_REFCUR
  ) IS
  
    lsCouponCd      C_COUPON_CUST.COUPON_CD%TYPE := NULL;   -- ������ȣ
    lsStat          VARCHAR2(  1)   := NULL;
    lsUseStat       C_COUPON_CUST.USE_STAT%TYPE  := NULL;   -- ������[00:���, 01:��û, 10:�Ǹ�, 11:��ǰ, 30:�н�, 31:����, 32:���, 33:��ȿ�Ⱓ����, 99:����]
    lsUseStatNm     VARCHAR2(200)   := NULL;
    lsCertYn        VARCHAR2(  1)   := NULL;
    lsCertFdt       VARCHAR2(  8)   := NULL;
    lsCertTdt       VARCHAR2(  8)   := NULL;
    
    nRecCnt         NUMBER(7)       := 0;
    
    ERR_HANDLER     EXCEPTION;
    
    BEGIN
        asRetVal    := '0000';
        asRetMsg    := 'OK';
    
        IF PSV_CERT_DIV = '2' THEN -- ������ȣ
            BEGIN
                SELECT  CCM.COUPON_CD
                     ,  CCM.COUPON_STAT
                     ,  CCC.USE_STAT
                     ,  CCM.CERT_YN
                     ,  CCC.CERT_FDT
                     ,  CCC.CERT_TDT
                     ,  GET_COMMON_CODE_NM('01615', CCC.USE_STAT, PSV_LANG_TP) USE_STAT_NM
                INTO    lsCouponCd, lsStat, lsUseStat, lsCertYn, lsCertFdt, lsCertTdt, lsUseStatNm
                FROM    C_COUPON_MST   CCM -- ��������� ������
                     ,  C_COUPON_CUST  CCC -- ��������� ���ȸ��
                WHERE   CCM.COMP_CD     = CCC.COMP_CD
                AND     CCM.COUPON_CD   = CCC.COUPON_CD
                AND     CCC.COMP_CD     = PSV_COMP_CD
                AND     CCC.BRAND_CD   IN ('0000', PSV_BRAND_CD)
                AND     CCM.COUPON_STAT = '2'    -- ��������[1:��ȹ, 2:Ȯ��, 3:Ȯ�����]
                AND     CCM.USE_YN      = 'Y'    -- ��뿩��[Y:���, N:������]
                AND     CCC.CERT_NO     = PSV_CERT_VAL;
            
                IF lsCertYn = 'N' THEN -- ��������[Y:����, N:��������]
                    asRetVal := '1001';
                    asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001372'); -- ������� ������ �ƴմϴ�.
            
                    OPEN asResult FOR
                        SELECT 1024 AS RTNCODE
                        FROM DUAL;
              
                    RETURN;
                ELSE
                    IF lsUseStat IN ('10', '30', '31', '32', '33', '99') THEN -- 10:�Ǹ�, 30:�н�, 31:����, 32:���, 33:��ȿ�Ⱓ ����, 99:����
                       asRetVal := '10'||lsUseStat;
                       asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001361')||' ['||lsUseStatNm||']'; -- ��� ������ ������ ������ȣ�� �ƴմϴ�.
                       
                       OPEN asResult FOR
                       SELECT 1024 AS RTNCODE
                         FROM DUAL;
                         
                       RETURN;
                    END IF;
                    
                    IF (TO_CHAR(SYSDATE, 'YYYYMMDD') >= lsCertFdt AND TO_CHAR(SYSDATE, 'YYYYMMDD') <= lsCertTdt) THEN -- ��ȿ�Ⱓ üũ
                        asRetVal := '0000';
                    ELSE
                        asRetVal := '1033';
                        asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001364')||'[ '||TO_CHAR(TO_DATE(lsCertTdt, 'YYYYMMDD'), 'YYYY-MM-DD')||' ]'; -- ���Ⱓ�� ���� ������ȣ�Դϴ�.
                       
                        -- ��ȿ�Ⱓ�� ����� ���� ���º���
                        BEGIN
                            UPDATE  C_COUPON_CUST
                            SET     USE_STAT  = '33' -- ��ȿ�Ⱓ����
                            WHERE   COMP_CD   = PSV_COMP_CD
                            AND     CERT_NO   = PSV_CERT_VAL;
                            
                        EXCEPTION
                            WHEN OTHERS THEN 
                                ROLLBACK;
                        END;
                       
                        OPEN asResult FOR
                            SELECT  1024 AS RTNCODE
                            FROM    DUAL;
                         
                        RETURN;
                    END IF;
                END IF;
            EXCEPTION
                WHEN OTHERS THEN
                    asRetVal := '2000';
                    asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001359'); -- �������� �ʴ� ������ȣ�Դϴ�.
                  
                    OPEN asResult FOR
                        SELECT  1024 AS RTNCODE
                        FROM    DUAL; 
                    
                    RETURN;
            END;
       
            OPEN asResult FOR
                SELECT  CCC.CUST_ID
                     ,  CCM.COUPON_CD 
                     ,  CCM.COUPON_NM
                     ,  CCC.CERT_NO
                     ,  CCM.DC_DIV
                     ,  CCC.GRP_SEQ
                     ,  CCC.PRT_LVL_CD
                     ,  CCM.CERT_YN
                     ,  CCM.START_DT
                     ,  CCM.CLOSE_DT
                     ,  CCM.COUPON_MSG
                     ,  CCC.CERT_TDT
                FROM    C_COUPON_MST   CCM -- ��������� ������
                     ,  C_COUPON_CUST  CCC -- ��������� ���ȸ��
                WHERE   CCM.COMP_CD     = CCC.COMP_CD
                AND     CCM.COUPON_CD   = CCC.COUPON_CD
                AND     CCC.COMP_CD     = PSV_COMP_CD
                AND     CCC.BRAND_CD   IN ('0000', PSV_BRAND_CD)
                AND     CCM.COUPON_STAT = '2'   -- ��������[1:��ȹ, 2:Ȯ��, 3:Ȯ�����]
                AND     CCM.USE_YN      = 'Y'   -- ��뿩��[Y:���, N:������]
                AND     CCC.CERT_NO     = PSV_CERT_VAL;
        ELSE -- ī���ȣ
            BEGIN
                SELECT  COUNT(*) INTO nRecCnt
                FROM   (
                        SELECT  CCC.CUST_ID
                              , CCM.COUPON_CD 
                              , CCM.COUPON_NM
                              , CCC.CERT_NO
                              , CCM.DC_DIV
                              , CCC.GRP_SEQ
                              , CCC.PRT_LVL_CD
                              , CCM.CERT_YN
                              , CCM.START_DT
                              , CCM.CLOSE_DT
                              , CCM.COUPON_MSG
                              , CCC.CERT_TDT
                        FROM    C_COUPON_MST   CCM
                              , C_COUPON_CUST  CCC
                              , C_CARD         CRD
                        WHERE   CCM.COMP_CD     = CCC.COMP_CD
                        AND     CCM.COUPON_CD   = CCC.COUPON_CD
                        AND     CRD.COMP_CD     = CCC.COMP_CD
                        AND     CRD.CUST_ID     = CCC.CUST_ID
                        AND     CRD.COMP_CD     = PSV_COMP_CD
                        AND     CRD.CARD_ID     = PSV_CERT_VAL
                        AND     CCM.BRAND_CD   IN ('0000', PSV_BRAND_CD)
                        AND     CRD.USE_YN      = 'Y' -- ��뿩��[Y:���, N:������]
                        AND     CCM.COUPON_STAT = '2' -- ��������[1:��ȹ, 2:Ȯ��, 3:Ȯ�����]
                        AND     CCM.USE_YN      = 'Y' -- ��뿩��[Y:���, N:������]
                        AND     CCC.USE_STAT NOT IN ('10', '30', '31', '32', '33', '99') -- 10:�Ǹ�, 30:�н�, 31:����, 32:���, 33:��ȿ�Ⱓ ����, 99:����
                        AND     TO_CHAR(SYSDATE, 'YYYYMMDD') BETWEEN CCC.CERT_FDT AND CCC.CERT_TDT
                        UNION ALL
                        SELECT  CST.CUST_ID
                              , CCM.COUPON_CD 
                              , CCM.COUPON_NM
                              , NULL CERT_NO
                              , CCM.DC_DIV
                              , CCI.GRP_SEQ
                              , CCI.LVL_CD
                              , CCM.CERT_YN
                              , CCM.START_DT
                              , CCM.CLOSE_DT
                              , CCM.COUPON_MSG
                              , CCM.CLOSE_DT
                        FROM    C_COUPON_MST       CCM
                              , C_COUPON_ITEM_GRP  CCI
                              , C_CARD             CRD
                              , C_CUST             CST
                        WHERE   CRD.COMP_CD     = CST.COMP_CD
                        AND     CRD.CUST_ID     = CST.CUST_ID
                        AND     CST.COMP_CD     = CCI.COMP_CD
                        AND     CST.LVL_CD      = CCI.LVL_CD
                        AND     CCI.COMP_CD     = CCM.COMP_CD
                        AND     CCI.COUPON_CD   = CCM.COUPON_CD
                        AND     CRD.COMP_CD     = PSV_COMP_CD
                        AND     CRD.CARD_ID     = PSV_CERT_VAL
                        AND     CCM.BRAND_CD   IN ('0000', PSV_BRAND_CD)
                        AND     CRD.USE_YN      = 'Y' -- ��뿩��[Y:���, N:������]
                        AND     CCM.COUPON_STAT = '2' -- ��������[1:��ȹ, 2:Ȯ��, 3:Ȯ�����]
                        AND     CCM.USE_YN      = 'Y' -- ��뿩��[Y:���, N:������]
                        AND     CCM.CERT_YN     = 'N'
                       );
            
                IF nRecCnt = 0 THEN
                    asRetVal := '3001';
                    asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001359'); -- ��� ������ ������ȣ�� �������� �ʽ��ϴ�.
            
                    OPEN asResult FOR
                        SELECT  1024 AS RTNCODE
                        FROM    DUAL; 
              
                    RETURN;
                END IF;
         
                OPEN asResult FOR
                    SELECT  CCC.CUST_ID
                         ,  CCM.COUPON_CD 
                         ,  CCM.COUPON_NM
                         ,  CCC.CERT_NO
                         ,  CCM.DC_DIV
                         ,  CCC.GRP_SEQ
                         ,  CCC.PRT_LVL_CD
                         ,  CCM.CERT_YN
                         ,  CCM.START_DT
                         ,  CCM.CLOSE_DT
                         ,  CCM.COUPON_MSG
                         ,  CCC.CERT_TDT
                    FROM    C_COUPON_MST   CCM
                         ,  C_COUPON_CUST  CCC
                         ,  C_CARD         CRD
                    WHERE   CCM.COMP_CD     = CCC.COMP_CD
                    AND     CCM.COUPON_CD   = CCC.COUPON_CD
                    AND     CRD.COMP_CD     = CCC.COMP_CD
                    AND     CRD.CUST_ID     = CCC.CUST_ID
                    AND     CRD.COMP_CD     = PSV_COMP_CD
                    AND     CRD.CARD_ID     = PSV_CERT_VAL
                    AND     CCM.BRAND_CD   IN ('0000', PSV_BRAND_CD)
                    AND     CRD.USE_YN      = 'Y' -- ��뿩��[Y:���, N:������]
                    AND     CCM.COUPON_STAT = '2' -- ��������[1:��ȹ, 2:Ȯ��, 3:Ȯ�����]
                    AND     CCM.USE_YN      = 'Y' -- ��뿩��[Y:���, N:������]
                    AND     CCC.USE_STAT NOT IN ('10', '30', '31', '32', '33', '99') -- 10:�Ǹ�, 30:�н�, 31:����, 32:���, 33:��ȿ�Ⱓ ����, 99:����
                    AND     TO_CHAR(SYSDATE, 'YYYYMMDD') BETWEEN CCC.CERT_FDT AND CCC.CERT_TDT
                    UNION ALL
                    SELECT  CST.CUST_ID
                         ,  CCM.COUPON_CD 
                         ,  CCM.COUPON_NM
                         ,  NULL CERT_NO
                         ,  CCM.DC_DIV
                         ,  CCI.GRP_SEQ
                         ,  CCI.LVL_CD
                         ,  CCM.CERT_YN
                         ,  CCM.START_DT
                         ,  CCM.CLOSE_DT
                         ,  CCM.COUPON_MSG
                         ,  CCM.CLOSE_DT
                    FROM    C_COUPON_MST       CCM
                         ,  C_COUPON_ITEM_GRP  CCI
                         ,  C_CARD             CRD
                         ,  C_CUST             CST
                    WHERE   CRD.COMP_CD     = CST.COMP_CD
                    AND     CRD.CUST_ID     = CST.CUST_ID
                    AND     CST.COMP_CD     = CCI.COMP_CD
                    AND     CST.LVL_CD      = CCI.LVL_CD
                    AND     CCI.COMP_CD     = CCM.COMP_CD
                    AND     CCI.COUPON_CD   = CCM.COUPON_CD
                    AND     CRD.COMP_CD     = PSV_COMP_CD
                    AND     CRD.CARD_ID     = PSV_CERT_VAL
                    AND     CCM.BRAND_CD   IN ('0000', PSV_BRAND_CD)
                    AND     CRD.USE_YN      = 'Y' -- ��뿩��[Y:���, N:������]
                    AND     CCM.COUPON_STAT = '2' -- ��������[1:��ȹ, 2:Ȯ��, 3:Ȯ�����]
                    AND     CCM.USE_YN      = 'Y' -- ��뿩��[Y:���, N:������]
                    AND     CCM.CERT_YN     = 'N';
            EXCEPTION
                WHEN OTHERS THEN
                    asRetVal := '4000';
                    asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001359'); -- ��� ������ ������ȣ�� �������� �ʽ��ϴ�.
              
                    OPEN asResult FOR
                        SELECT  1024 AS RTNCODE
                        FROM    DUAL; 
                
                    RETURN;
            END;
        END IF;
    
        asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001392'); -- ���� ó���Ǿ����ϴ�.
    
        RETURN;
    EXCEPTION
        WHEN OTHERS THEN
            asRetVal := '3001';
            asRetMsg := SQLERRM;
         
            OPEN asResult FOR
                SELECT  1024 AS RTNCODE
            FROM DUAL;
           
            RETURN;
    END GET_MEMB_CUPN_10;
  
    ------------------------------------------------------------------------------
    --  Package Name     : SET_MEMB_CUPN_10
    --  Description      : POS ����� ���� ���/��� > POS������ ����
    --  Ref. Table       : C_COUPON_MST  ��������� ������
    --                     C_COUPON_CUST ��������� ���ȸ��
    ------------------------------------------------------------------------------
    --  Create Date      : 2015-01-13 ����� CRM PJT
    --  Modify Date      : 
    ------------------------------------------------------------------------------
    PROCEDURE SET_MEMB_CUPN_10
  (
    PSV_COMP_CD           IN   VARCHAR2, -- 1. ȸ���ڵ�
    PSV_LANG_TP           IN   VARCHAR2, -- 2. ����ڵ�
    PSV_COUPON_CD         IN   VARCHAR2, -- 3. ������ȣ
    PSV_CERT_NO           IN   VARCHAR2, -- 4. ������ȣ
    PSV_SALE_DIV          IN   VARCHAR2, -- 6. �Ǹű���[1:�Ǹ�, 2:��ǰ]
    PSV_USE_DT            IN   VARCHAR2, -- 7. �������
    PSV_USE_TM            IN   VARCHAR2, -- 8. ���ð�
    PSV_BRAND_CD          IN   VARCHAR2, -- 9. ��������
    PSV_STOR_CD           IN   VARCHAR2, -- 10. �����ڵ�
    PSV_POS_NO            IN   VARCHAR2, -- 11. ������ȣ
    PSV_BILL_NO           IN   VARCHAR2, -- 12. ��������ȣ
    asRetVal              OUT  VARCHAR2, -- 14. ����ڵ�[1:����  �׿ܴ� ����]
    asRetMsg              OUT  VARCHAR2, -- 15. ����޽���
    asResult              OUT  REC_SET.M_REFCUR
  ) IS
  
    lsCouponCd      C_COUPON_CUST.COUPON_CD%TYPE := NULL;   -- ������ȣ
    lsStat          VARCHAR2(  1)   := NULL;
    lsUseStat       C_COUPON_CUST.USE_STAT%TYPE  := NULL;   -- ������[00:���, 01:��û, 10:�Ǹ�, 11:��ǰ, 30:�н�, 31:����, 32:���, 33:��ȿ�Ⱓ����, 99:����]
    lsUseStatNm     VARCHAR2(200)   := NULL;
    lsCertYn        VARCHAR2(  1)   := NULL;
    lsCertFdt       VARCHAR2(  8)   := NULL;
    lsCertTdt       VARCHAR2(  8)   := NULL;
    
    nRecCnt         NUMBER(7)       := 0;
    
    ERR_HANDLER     EXCEPTION;
    
    BEGIN
        asRetVal    := '0000' ;
        asRetMsg    := 'OK'   ;
    
        BEGIN
            SELECT  CCM.COUPON_CD 
                 ,  CCM.COUPON_STAT
                 ,  CCC.USE_STAT
                 ,  CCM.CERT_YN
                 ,  CCC.CERT_FDT
                 ,  CCC.CERT_TDT
                 ,  GET_COMMON_CODE_NM('01615', CCC.USE_STAT, PSV_LANG_TP) USE_STAT_NM
            INTO    lsCouponCd, lsStat, lsUseStat, lsCertYn, lsCertFdt, lsCertTdt, lsUseStatNm
            FROM    C_COUPON_MST    CCM -- ��������� ������
                  , C_COUPON_CUST   CCC -- ��������� ���ȸ��
            WHERE   CCM.COMP_CD     = CCC.COMP_CD
            AND     CCM.COUPON_CD   = CCC.COUPON_CD
            AND     CCC.COMP_CD     = PSV_COMP_CD
            AND     CCM.COUPON_STAT = '2'    -- ��������[1:��ȹ, 2:Ȯ��, 3:Ȯ�����]
            AND     CCM.USE_YN      = 'Y'    -- ��뿩��[Y:���, N:������]
            AND     CCC.CERT_NO     = PSV_CERT_NO;
             
            IF lsCertYn = 'N' THEN -- ��������[Y:����, N:��������]
                asRetVal := '1001';
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001372'); -- ������� ������ �ƴմϴ�.
             
                OPEN asResult FOR
                    SELECT  1024 AS RTNCODE
                    FROM    DUAL;
               
                RETURN;
            ELSE
                IF PSV_SALE_DIV = '1' THEN -- �Ǹ�
                    IF lsUseStat IN ('10', '30', '31', '32', '33', '99') THEN -- 10:�Ǹ�, 30:�н�, 31:����, 32:���, 33:��ȿ�Ⱓ ����, 99:����
                       asRetVal := '10'||lsUseStat;
                       asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001361')||' ['||lsUseStatNm||']'; -- ��� ������ ������ ������ȣ�� �ƴմϴ�.
                   
                        OPEN asResult FOR
                            SELECT  1024 AS RTNCODE
                            FROM DUAL;
                     
                        RETURN;
                    END IF;
                
                    IF (TO_CHAR(SYSDATE, 'YYYYMMDD') >= lsCertFdt AND TO_CHAR(SYSDATE, 'YYYYMMDD') <= lsCertTdt) THEN -- ��ȿ�Ⱓ üũ
                        asRetVal := '0000';
                    ELSE
                        asRetVal := '1033';
                        asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001364')||'[ '||TO_CHAR(TO_DATE(lsCertTdt, 'YYYYMMDD'), 'YYYY-MM-DD')||' ]'; -- ���Ⱓ�� ���� ������ȣ�Դϴ�.
                       
                        -- ��ȿ�Ⱓ�� ����� ���� ���º���
                        BEGIN
                            UPDATE  C_COUPON_CUST
                            SET     USE_STAT  = '33' -- ��ȿ�Ⱓ����
                                 ,  USE_DT    = TO_CHAR(SYSDATE, 'YYYYMMDD')
                                 ,  UPD_DT    = SYSDATE
                                 ,  UPD_USER  = 'S_CUPN_10'
                            WHERE   COMP_CD   = PSV_COMP_CD
                            AND     COUPON_CD = PSV_COUPON_CD
                            AND     CERT_NO   = PSV_CERT_NO;
                        EXCEPTION
                            WHEN OTHERS THEN 
                                ROLLBACK;
                        END;
                       
                        OPEN asResult FOR
                            SELECT  1024 AS RTNCODE
                            FROM    DUAL;
                         
                        RETURN;
                    END IF;
                ELSE -- ��ǰ
                    IF lsUseStat NOT IN ('10') THEN -- 10:�Ǹ�
                        asRetVal := '10'||lsUseStat;
                        asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001391')||' ['||lsUseStatNm||']'; -- ��ǰ ������ ������ ������ȣ�� �ƴմϴ�.
                       
                        OPEN asResult FOR
                            SELECT  1024 AS RTNCODE
                            FROM    DUAL;
                         
                        RETURN;
                    END IF;
                 END IF;
            END IF;
        EXCEPTION
            WHEN ERR_HANDLER THEN
                RETURN;
            WHEN OTHERS THEN
                asRetVal := '2000';
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001359'); -- �������� �ʴ� ������ȣ�Դϴ�.
               
                OPEN asResult FOR
                    SELECT  1024 AS RTNCODE
                    FROM    DUAL;
                 
               RETURN;
        END;
    
        -- ���� �÷��� üũ(����/��ǰ/��ȿ�Ⱓ���)
        UPDATE  C_COUPON_CUST -- ��������� ���ȸ��
        SET     USE_STAT = CASE WHEN PSV_SALE_DIV = '1' THEN '10' 
                                ELSE (CASE WHEN CERT_TDT < TO_CHAR(SYSDATE, 'YYYYMMDD') THEN '33' ELSE '11' END)  
                           END
              , USE_DT   = PSV_USE_DT
              , USE_TM   = PSV_USE_TM
              , BRAND_CD = PSV_BRAND_CD
              , STOR_CD  = PSV_STOR_CD
              , POS_NO   = PSV_POS_NO
              , BILL_NO  = PSV_BILL_NO
              , UPD_DT   = SYSDATE
              , UPD_USER = 'SYSTEM'
        WHERE   COMP_CD  = PSV_COMP_CD
        AND     COUPON_CD= PSV_COUPON_CD
        AND     CERT_NO  = PSV_CERT_NO;
       
        OPEN asResult FOR
            SELECT  0 AS RTNCODE
            FROM    DUAL;
      
        asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001392'); -- ���� ó���Ǿ����ϴ�.
    
        RETURN;
    EXCEPTION
        WHEN OTHERS THEN
            asRetVal := '3001';
            asRetMsg := '���ó�� �� ������ �߻��Ͽ����ϴ�.['||SQLERRM||']';
         
            OPEN asResult FOR
                SELECT  0 AS RTNCODE
                FROM    DUAL;
           
            RETURN;
    END SET_MEMB_CUPN_10;
  
END PKG_POS_CUST_ACK;

/
