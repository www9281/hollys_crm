CREATE OR REPLACE PACKAGE       PKG_POS_IF_GET AS

--------------------------------------------------------------------------------
--  Procedure Name   : SP_IF_POS_GET_MASTER
--  Description      : POS������ ���ſ�
--  asWorkDiv        : 00 => (���ν��� ȣ�� �׽�Ʈ)
--                   : 01 => ITEM_CHAIN       (��ǰ������)
--                   : 02 => ITEM_BRAND_HIS   (��ǰ�ܰ��̷�)                    > ������
--                   : 03 => FIXED_ITEM       (�����÷��̹�)                    > ������
--                   : 04 => SET_GRP_RULE     (��Ʈ��ǰ),  SET_GRP_ITEM (��Ʈ���ո�����)
--                   : 05 => BUNDLE_HD        (������ǰ HD)
--                   : 06 => BUNDLE_DT        (������ǰ DT)
--                   : 07 => STORE_ITEM_PRT   (�ֹ���� ������ ��ǰ)
--                   : 08 => BEST_ITEM        (�α��ǰ)
--                   : 09 => TOUCH_STORE_UI   (������ ���� ��ġŰ)
--                   : 10 => SUB_TOUCH_UI     (�ΰ���ǰ��ġŰ�׷�)
--                   : 11 => ITEM_EXT_GRP     (��ǰ�� �ΰ���ǰ �׷�)
--                   : 12 => BUTTON_INFO      (��ư����)
--                   : 13 => OPTION_ITEM      (�ɼǻ�ǰ)
--                   : 14 => ITEM_OPTION_RULE (�ɼǻ�ǰ RULE)
--                   : 15 => GIFT_CODE_MST    (��ǰ�� ���� ������)
--                   : 16 => ACC_MST          (��Ÿ�����)
--                   : 17 => ACC_RMK          (��Ÿ����� ���� ������)
--                   : 18 => CAMPAIGN_SAVE    (ķ���� ����/����������)          > ������
--                   : 19 => CAMPAIGN_ITEM    (ķ���� ��ǰ)                     > ������
--                   : 20 => CAMPAIGN_WEEK    (ķ���� ���� ����/�ð�)           > ������
--                   : 21 => CAMPAING_GIFT    (ķ���� ����/����ǰ ������)       > ������
--                   : 22 => CAMPAING_RULE    (ķ���� RULE)                     > ������
--                   : 23 => FLAVOR_TOUCH_STORE_UI  (������ �÷��̹� ��ġŰ)    > ������
--                   : 24 => PLU_NM_BRAND           (PLU ��ǰ��)                > ������
--                   : 25 => PLU_AMT_STORE          (PLU �ݾ� - ��������)       > ������
--                   : 26 => ITEM_L_CLASS           (��з�)
--                   : 27 => ITEM_M_CLASS           (�ߺз�)
--                   : 28 => ITEM_S_CLASS           (�Һз�)
--                   : 29 => ITEM_KITCHEN           (�ֹ��ǰ����)
--                   : 30 => CAMPAIGN_PREFIX        (�������� - CARD PREFIX)    > ������
--                   : 31 => SET_RULE               (��Ʈ ����ǰ ����)
--                   : 32 => STORE_ITEM_PRT_MULTI   (�ֹ���� ������ ��ǰ(����))
--                   : 33 => ITEM_CLASS             (��ǰ�з�(��������))
--                   : 34 => SET_GRP                (Mix Match �׷�����)        > ������
--                   : 50 => STORE_USER             (����� ������)
--                   : 51 => STORE_CHK_M            (���� ���� ������)          > ����
--                   : 52 => CARD                   (ī��� ������)
--                   : 53 => CARDMB_PREFIX          (ī��� PREFIX)
--                   : 54 => COMMON                 (�����ڵ� ������)
--                   : 55 => VAN                    (VAN ������)                > ������
--                   : 56 => CAT ID                 (CAT ID ������)             > ������
--                   : 57 => VAN, CATID,            (VAN,ī�� ����)
--                   : 58 => STORE                  (��������)
--                   : 59 => BILL_MSG_HQ            (���� ����)
--                   : 60 => BILL_MSG_STOR          (���� ����)
--                   : 61 => COMMON                 (�ۼ��� URL)
--                   : 62 => STORE_PURCHASE         (���� ����ó)               > ����
--                   : 63 => POS_PGM_AUTH           (���α׷� ����)
--                   : 64 => SATISFACTION           (������ ������)             > ������
--                   : 65 => EX_DAY, EX_CURR        (ȯ�� ������)               > ������
--                   : 66 => CUSTOMER               (�� ������)               > ������
--                   : 67 => STORE_WEEK             (���� ��ð�CNT ��ũ I/F) > ������
--                   : 68 => STORE_HOLIDAY          (���� �޹���)               > ������
--                   : 70 => REGION                 (���� ������)               > ������
--                   : 71 => LANG_ITEM              (�ٱ��� ��ǰ������)
--                   : 72 => LANG_COMMON            (�ٱ��� ���븶����)
--                   : 73 => LANG_STORE             (�ٱ��� ����������)
--                   : 74 => LANG_TABLE             (�ٱ��� ���̺�����)
--                   : 75 => RECIPE_BRAND           (PL������ �����Ǹ�����)
--                   : 80 => RESV_SALE_HD           (���� HEADER)               > ������
--                   : 81 => RESV_SALE_DT           (���� DETAIL)               > ������
--                   : 82 => RESV_SALE_ST           (���� ����)                 > ������
--                   : 83 => RESV_SALE_DESC         (���� ����)                 > ������
--                   : 84 => DC                     (���� ����)
--                   : 85 => DC_STORE               (������ ��������)
--                   : 86 => DC_ITEM                (���� ����ǰ)
--                   : 87 => DC_GIFT                (���� ����ǰ)
--                   : 88 => STORE                  (B2B)
--                   : 89 => DC_WEEK                (���δ�����)
--                   : 90 =>                        (�����ð� ����)
--                   : 91 => DC_ITEM_GRP            (���δ���ǰ�׷�)
--                   : A0 => BITEM_B2B_DC_HIS       (B2B ������ DB ���� ��å)
--                   : A1 => ITEM_STOCK_PERIOD      (����ǰ �ص��ð�����)
--                   : A2 => ITEM_CHAIN             (����ǰ, �������� ��ǰ����Ʈ(KDS��))
--                   : A3 => RECIPE_BRAND_FOOD      (BOM������ ����������)
--                   : B0 => CS_PROGRAM             ([����]���α׷� ������)
--                   : B1 => CS_PROGRAM_MATL        ([����]���α׷� ��� ����)
--                   : B2 => CS_PROGRAM_ORG         ([����]���α׷� ��ü���� ���� ������)
--                   : B3 => CS_PROGRAM_STORE       ([����]���α׷� ��������)
--                   : B4 => CS_PROGRAM_STORE_TM    ([����]���α׷� ���� ��ð�)
--                   : B5 => CS_MEMBERSHIP          ([����]ȸ���� ������)
--                   : B6 => CS_OPTION              ([����]����ɼ� ������)
--                   : B7 => CS_OPTION_STORE        ([����]����ɼ� �����Ҵ� ������)
--                   : B8 => CS_MEMBERSHIP_ITEM     ([����]ȸ���� ����ǰ ������)
--                   : B9 => CS_CONTENT             ([����]SMS ������)
--                   : C0 => M_COUPON_MST           ([����]��������� ������)
--                   : C1 => M_COUPON_STORE         ([����]���� ������ ������)
--                   : C2 => M_COUPON_ITEM          ([����]���� ����ǰ ������)
--------------------------------------------------------------------------------
--  Create Date      : 2009-12-15
--  Modify Date      : 2009-12-15
--------------------------------------------------------------------------------

P_COMP_CD        VARCHAR2(3)  := '';
P_BRAND_CD       VARCHAR2(4)  := '';
P_STOR_CD        VARCHAR2(10) := '';
P_STOR_TP        VARCHAR2(2)  := '';
P_USER_ID        VARCHAR2(10) := '';
P_DOWN_DTM       VARCHAR2(20) := '20090101000000';
P_USE_YN         VARCHAR2(1)  := 'A';

PROCEDURE GET_MASTER
                (
                   asCompCd        IN   VARCHAR2, -- ȸ���ڵ�
                   asBrandCd       IN   VARCHAR2, -- ��������
                   asStorCd        IN   VARCHAR2, -- �����ڵ�
                   asStorTp        IN   VARCHAR2, -- �����ͱ���
                   asUserId        IN   VARCHAR2, -- ����� ID
                   asWorkDiv       IN   VARCHAR2, -- �ٿ�ε� �۾� ����
                   asDownDtm       IN   VARCHAR2, -- ���Ѵٿ�ε� �ð�
                   asUseYn         IN   VARCHAR2, -- Y:���, A:��ü
                   anRetVal        OUT  NUMBER  , -- ���� �ڵ�
                   asRetMsg        OUT  VARCHAR2, -- ���� �޽���
                   p_cursor        OUT  rec_set.m_refcur
                ) ;
                
PROCEDURE GET_MASTER_00
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;
                
PROCEDURE GET_MASTER_01
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;
                
PROCEDURE GET_MASTER_04
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;
                
PROCEDURE GET_MASTER_05
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;
                
PROCEDURE GET_MASTER_06
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;
                
PROCEDURE GET_MASTER_07
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;
                
PROCEDURE GET_MASTER_08
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;
                
PROCEDURE GET_MASTER_09
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;
                
PROCEDURE GET_MASTER_10
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;
                
PROCEDURE GET_MASTER_11
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;
                
PROCEDURE GET_MASTER_12
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;
                
PROCEDURE GET_MASTER_13
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;
                
PROCEDURE GET_MASTER_14
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;
                
PROCEDURE GET_MASTER_15
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;
                
PROCEDURE GET_MASTER_16
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;

PROCEDURE GET_MASTER_17
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;
                
PROCEDURE GET_MASTER_26
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;
                
PROCEDURE GET_MASTER_27
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;
                
PROCEDURE GET_MASTER_28
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;
                
PROCEDURE GET_MASTER_29
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;
                
PROCEDURE GET_MASTER_31
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;
                
PROCEDURE GET_MASTER_32
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;
                
PROCEDURE GET_MASTER_33
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;
                
PROCEDURE GET_MASTER_50
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;
                
PROCEDURE GET_MASTER_52
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;
                
PROCEDURE GET_MASTER_53
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;
                
PROCEDURE GET_MASTER_54
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;
                
PROCEDURE GET_MASTER_57
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;
                
PROCEDURE GET_MASTER_58
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;
                
PROCEDURE GET_MASTER_59
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;
                
PROCEDURE GET_MASTER_60
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;
                
PROCEDURE GET_MASTER_61
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;
                
PROCEDURE GET_MASTER_62
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;
                
PROCEDURE GET_MASTER_63
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;
                
PROCEDURE GET_MASTER_71
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;
                
PROCEDURE GET_MASTER_72
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;
                
PROCEDURE GET_MASTER_73
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;
                
PROCEDURE GET_MASTER_74
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;
                
PROCEDURE GET_MASTER_75
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;
                
PROCEDURE GET_MASTER_84
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;
                
PROCEDURE GET_MASTER_85
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;
                
PROCEDURE GET_MASTER_86
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;
                
PROCEDURE GET_MASTER_87
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;
                
PROCEDURE GET_MASTER_88
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;
                
PROCEDURE GET_MASTER_89
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;

PROCEDURE GET_MASTER_90
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;
                
PROCEDURE GET_MASTER_91
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;

PROCEDURE GET_MASTER_92
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;
                                
PROCEDURE GET_MASTER_A0
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;
                
PROCEDURE GET_MASTER_A1
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;
                
PROCEDURE GET_MASTER_A2
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;
                
PROCEDURE GET_MASTER_A3
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;

PROCEDURE GET_MASTER_B0
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;
                
PROCEDURE GET_MASTER_B1
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;
                
PROCEDURE GET_MASTER_B2
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;
                
PROCEDURE GET_MASTER_B3
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;

PROCEDURE GET_MASTER_B4
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;

PROCEDURE GET_MASTER_B5
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;

PROCEDURE GET_MASTER_B6
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;

PROCEDURE GET_MASTER_B7
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;

PROCEDURE GET_MASTER_B8
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;

PROCEDURE GET_MASTER_B9
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;

PROCEDURE GET_MASTER_C0
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;

PROCEDURE GET_MASTER_C1
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;

PROCEDURE GET_MASTER_C2
                (  anRetVal        OUT     NUMBER  , -- ����ڵ�
                   asRetMsg        OUT     VARCHAR2, -- ���� �޽���
                   p_cursor        OUT     rec_set.m_refcur
                ) ;
                                
END PKG_POS_IF_GET;

/

CREATE OR REPLACE PACKAGE BODY       PKG_POS_IF_GET AS
  PROCEDURE GET_MASTER
  (
    asCompCd        IN  VARCHAR2, -- ȸ���ڵ�
    asBrandCd       IN  VARCHAR2, -- ��������
    asStorCd        IN  VARCHAR2, -- �����ڵ�
    asStorTp        IN  VARCHAR2, -- �����ͱ���
    asUserId        IN  VARCHAR2, -- ����� ID
    asWorkDiv       IN  VARCHAR2, -- �ٿ�ε� �۾� ����
    asDownDtm       IN  VARCHAR2, -- ���Ѵٿ�ε� �ð�
    asUseYn         IN  VARCHAR2, -- Y:���, A:��ü
    anRetVal        OUT NUMBER ,  -- ���� �ڵ�
    asRetMsg        OUT VARCHAR2, -- ���� �޽���
    p_cursor        OUT rec_set.m_refcur
  ) IS
  BEGIN
    anRetVal   := 1;
    asRetMsg   := '0K';
    P_COMP_CD  := asCompCd;
    P_BRAND_CD := asBrandCd;
    P_STOR_CD  := asStorCd ;
    P_STOR_TP  := asStorTp ;
    P_USER_ID  := asUserId ;
    
    P_DOWN_DTM := asDownDtm;
    If ( asUseYn = 'Y' ) Then
       P_USE_YN := asUseYn ;
    Else
       P_USE_YN := '%' ;
    End If;
    If    ( asWorkDiv = '00' ) Then -- ITEM_CHAIN       (���ν��� ȣ�� �׽�Ʈ)
        GET_MASTER_00(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '01' ) Then -- ITEM_CHAIN       (��ǰ������)
        GET_MASTER_01(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '04' ) Then --SET_GRP_RULE      (��Ʈ��ǰ), SET_GRP_ITEM(��Ʈ���ո�����)
        GET_MASTER_04(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '05' ) Then -- BUNDLE_HD        (������ǰ HD)
        GET_MASTER_05(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '06' ) Then -- BUNDLE_DT        (������ǰ DT)
        GET_MASTER_06(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '07' ) Then -- STORE_ITEM_PRT   (�ֹ���� ������ ��ǰ)
        GET_MASTER_07(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '08' ) Then -- BEST_ITEM        (�α��ǰ)
        GET_MASTER_08(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '09' ) Then -- TOUCH_STORE_UI   (��ġŰ����)
        GET_MASTER_09(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '10' ) Then -- SUB_TOUCH_UI     (�ΰ���ǰ��ġŰ�׷�)
        GET_MASTER_10(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '11' ) Then -- ITEM_EXT_GRP     (��ǰ�� �ΰ���ǰ �׷�)
        GET_MASTER_11(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '12' ) Then -- BUTTON_INFO      (��ư����)
        GET_MASTER_12(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '13' ) Then -- OPTION_ITEM      (�ɼǻ�ǰ)
        GET_MASTER_13(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '14' ) Then -- ITEM_OPTION_RULE (�ɼǻ�ǰ RULE)
        GET_MASTER_14(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '15' ) Then -- GIFT_CODE_MST    (��ǰ�� ���� ������)
        GET_MASTER_15(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '16' ) Then --  ACC_MST         (��Ÿ�����)
        GET_MASTER_16(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '17' ) Then --  ACC_RMK         (��Ÿ����� ����)
        GET_MASTER_17(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '26' ) Then -- ITEM_L_CLASS           (��з�)
        GET_MASTER_26(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '27' ) Then -- ITEM_M_CLASS           (�ߺз�)
        GET_MASTER_27(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '28' ) Then -- ITEM_S_CLASS          (�Һз�)
        GET_MASTER_28(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '29' ) Then -- ITEM_KITCHEN           (�ֹ��ǰ����)
        GET_MASTER_29(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '31' ) Then -- SET_RULE               (��Ʈ ����ǰ ����)
        GET_MASTER_31(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '32' ) Then -- STORE_ITEM_PRT_MULTI   (�ֹ���� ������ ��ǰ(����))
        GET_MASTER_32(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '33' ) Then -- ITEM_CLASS             (��ǰ�з�(��������))
        GET_MASTER_33(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '50' ) Then -- STORE_USER       (����� ������)
        GET_MASTER_50(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '52' ) Then -- CARD             (ī��� ������)
        GET_MASTER_52(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '53' ) Then -- CARDMB_PREFIX    (ī��� PREFIX)
        GET_MASTER_53(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '54' ) Then -- COMMON           (�����ڵ�)
        GET_MASTER_54(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '57' ) Then -- COMMON           (VAN, ī�� ����)
        GET_MASTER_57(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '58' ) Then -- COMMON           (���� ����)
        GET_MASTER_58(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '59' ) Then -- COMMON           (���� ����)
        GET_MASTER_59(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '60' ) Then -- COMMON           (���� ����)
        GET_MASTER_60(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '61' ) Then -- COMMON           (�۽� URL)
        GET_MASTER_61(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '62' ) Then -- COMMON           (���� ����ó)
        GET_MASTER_62(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '63' ) Then -- COMMON           (����ں� ���α׷� ����)
        GET_MASTER_63(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '71' ) Then -- LANG_ITEM        (�ٱ��� ��ǰ)
        GET_MASTER_71(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '72' ) Then -- LANG_COMMON      (�ٱ��� ����)
        GET_MASTER_72(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '73' ) Then -- LANG_STORE       (�ٱ��� ����)
        GET_MASTER_73(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '74' ) Then -- LANG_TABLE       (�ٱ��� ���̺�)
        GET_MASTER_74(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '75' ) Then -- RECIPE_BRAND     (������)
        GET_MASTER_75(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '84' ) Then -- DC               (��������)
        GET_MASTER_84(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '85' ) Then -- DC_STORE         (������ ��������)
        GET_MASTER_85(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '86' ) Then -- DC_ITEM          (���� ����ǰ)
        GET_MASTER_86(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '87' ) Then -- DC_GIFT          (���� ����ǰ)
        GET_MASTER_87(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '88' ) Then -- STORE            (B2B)
        GET_MASTER_88(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '89' ) Then -- DC_WEEK          (���δ�����)
        GET_MASTER_89(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '90' ) Then -- (SYSDATE ���� )
        GET_MASTER_90(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '91' ) Then -- DC_ITEM_GRP      (���δ���ǰ�׷�)
        GET_MASTER_91(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = '92' ) Then -- HQ_USER          (��������)
        GET_MASTER_92(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = 'A0' ) Then -- ITEM_B2B_DC_HIS      (B2B ITEM DC)
        GET_MASTER_A0(anRetVal, asRetMsg, p_cursor );    
    ElsIf ( asWorkDiv = 'A1' ) Then -- ITEM_STOCK_PERIOD    (����ǰ �ص��ð�����)
        GET_MASTER_A1(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = 'A2' ) Then -- ITEM_CHAIN           (����ǰ, �������� ��ǰ����Ʈ(KDS��))
        GET_MASTER_A2(anRetVal, asRetMsg, p_cursor );    
    ElsIf ( asWorkDiv = 'A3' ) Then -- RECIPE_BRAND_FOOD    (BOM������ ����������)
        GET_MASTER_A3(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = 'B0' ) Then -- CS_PROGRAM           ([����]���α׷� ������)
        GET_MASTER_B0(anRetVal, asRetMsg, p_cursor );    
    ElsIf ( asWorkDiv = 'B1' ) Then -- CS_PROGRAM_MATL      ([����]���α׷� ��� ����)
        GET_MASTER_B1(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = 'B2' ) Then -- CS_PROGRAM_ORG       ([����]���α׷� ��ü���� ���� ������)
        GET_MASTER_B2(anRetVal, asRetMsg, p_cursor );    
    ElsIf ( asWorkDiv = 'B3' ) Then -- CS_PROGRAM_STORE     ([����]���α׷� ��������)
        GET_MASTER_B3(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = 'B4' ) Then -- CS_PROGRAM_STORE_TM  ([����]���α׷� ���� ��ð�)
        GET_MASTER_B4(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = 'B5' ) Then -- CS_MEMBERSHIP        ([����]ȸ���� ������)
        GET_MASTER_B5(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = 'B6' ) Then -- CS_OPTION            ([����]����ɼ� ������)
        GET_MASTER_B6(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = 'B7' ) Then -- CS_OPTION_STORE      ([����]����ɼ� �����Ҵ� ������)
        GET_MASTER_B7(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = 'B8' ) Then -- CS_MEMBERSHIP_ITEM   ([����]ȸ���� ����ǰ ������)
        GET_MASTER_B8(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = 'B9' ) Then -- CS_CONTENT           ([����]SMS ������)
        GET_MASTER_B9(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = 'C0' ) Then -- M_COUPON_MST         ([����]����������)
        GET_MASTER_C0(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = 'C1' ) Then -- M_COUPON_STORE       ([����]����������)
        GET_MASTER_C1(anRetVal, asRetMsg, p_cursor );
    ElsIf ( asWorkDiv = 'C2' ) Then -- M_COUPON_ITEM        ([����]��������ǰ)
        GET_MASTER_C2(anRetVal, asRetMsg, p_cursor );
    Else
        anRetVal := -100;
        asRetMsg := '�� ���ǵ� �ٿ�ε� �۾� ����[' || asWorkDiv || '] �Դϴ�.' ;
    End If;
    
    If ( anRetVal <> 1 ) Then
        INSERT INTO ERR_LOG_IF_POS
        (
                COMP_CD
            ,   JOB_DATE
            ,   JOB_SEQ_NO
            ,   STOR_CD
            ,   JOB_TIME
            ,   JOB_NAME
            ,   JOB_MESSAGE
        ) VALUES (
                asCompCd
            ,   TO_CHAR(SYSDATE, 'YYYYMMDD')
            ,   SQ_ERR_LOG_IF_POS.NEXTVAL
            ,   asStorCd
            ,   TO_CHAR(SYSDATE, 'HH24MISS')
            ,   asWorkDiv
            ,   asRetMsg
       );
       Commit;
    End If;
  EXCEPTION
    WHEN OTHERS THEN
         anRetVal := SQLCODE;
         asRetMsg := 'WorkDiv[' || asWorkDiv || ']' || SQLERRM(SQLCODE);
         
         INSERT INTO ERR_LOG_IF_POS
         (
                COMP_CD
            ,   JOB_DATE
            ,   JOB_SEQ_NO
            ,   STOR_CD
            ,   JOB_TIME
            ,   JOB_NAME
            ,   JOB_MESSAGE
         ) VALUES (
                asCompCd
            ,   TO_CHAR(SYSDATE, 'YYYYMMDD')
            ,   SQ_ERR_LOG_IF_POS.NEXTVAL
            ,   asStorCd
            ,   TO_CHAR(SYSDATE, 'HH24MISS')
            ,   asWorkDiv
            ,   asRetMsg
         );
         Commit;
  END GET_MASTER;
  
  --------------------------------------------------------------------------------
  --  Procedure Name   : GET_MASTER_00
  --  Description      : POS������ ���ſ� (SP�������� ���� �ѹ��� ��ĳ���� ��ȿȭ POS���� ������ ���� ��û ���ν��� ȣ�� �׽�Ʈ)
  -- Ref. Table        : ITEM_CHAIN
  --------------------------------------------------------------------------------
  --  Create Date      : 2009-12-15
  --  Modify Date      : 2009-12-15
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_00 (
    anRetVal OUT NUMBER,   -- ����ڵ�
    asRetMsg OUT VARCHAR2, -- ���� �޽���
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT 'X'
      FROM DUAL;
      
    anRetVal := 1 ;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_00;
  
  --------------------------------------------------------------------------------
  --  Procedure Name   : GET_MASTER_01
  --  Description      : POS������ ���ſ� (��ǰ������)
  -- Ref. Table        : ITEM_CHAIN
  --------------------------------------------------------------------------------
  --  Create Date      : 2009-12-15
  --  Modify Date      : 2009-12-15
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_01 (
    anRetVal OUT NUMBER,   -- ����ڵ�
    asRetMsg OUT VARCHAR2, -- ���� �޽���
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    WITH IT AS 
    (
        SELECT  COMP_CD
             ,  BRAND_CD
             ,  ITEM_CD
          FROM  ( 
                    SELECT  COMP_CD
                         ,  BRAND_CD
                         ,  ITEM_CD
                      FROM  ITEM_CHAIN -- �����ͺ� ��ǰ ������
                     WHERE  COMP_CD  = P_COMP_CD
                       AND  BRAND_CD = P_BRAND_CD
                       AND  STOR_TP  = P_STOR_TP
                       AND  ORD_SALE_DIV IN ('2', '3') -- �ֹ�/�Ǹű���[00045>1:�ֹ���, 2:�ֹ��Ǹſ�, 3:�Ǹſ�]
                       AND  UPD_DT >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
                    UNION ALL
                    SELECT  COMP_CD
                         ,  BRAND_CD
                         ,  ITEM_CD
                      FROM  STORE_ITEM_PRT -- �ֹ� ���� ��ǰ ������
                     WHERE  COMP_CD  = P_COMP_CD
                       AND  BRAND_CD = P_BRAND_CD
                       AND  STOR_CD = P_STOR_CD
                       AND  UPD_DT >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
                    UNION ALL
                    SELECT  COMP_CD
                         ,  BRAND_CD
                         ,  ITEM_CD
                      FROM  ITEM_STORE
                     WHERE  COMP_CD  = P_COMP_CD
                       AND  BRAND_CD = P_BRAND_CD
                       AND  STOR_CD  = P_STOR_CD
                       AND  USE_YN   = 'Y'
                       AND  UPD_DT  >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
                    UNION ALL
                    SELECT  COMP_CD
                         ,  BRAND_CD
                         ,  ITEM_CD
                      FROM  SUB_STORE_ITEM
                     WHERE  COMP_CD  = P_COMP_CD
                       AND  BRAND_CD = P_BRAND_CD
                       AND  STOR_CD = P_STOR_CD
                       AND  SUB_TOUCH_DIV IN ('2', '3')
                       AND  UPD_DT >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
                    UNION ALL
                    SELECT  COMP_CD
                         ,  P_BRAND_CD      AS BRAND_CD
                         ,  ITEM_CD
                      FROM  BARCODE
                     WHERE  COMP_CD  = P_COMP_CD
                       AND  UPD_DT  >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
                    UNION ALL
                    SELECT  COMP_CD
                         ,  BRAND_CD
                         ,  TOUCH_CD        AS ITEM_CD
                      FROM  TOUCH_STORE_UI
                     WHERE  COMP_CD  = P_COMP_CD
                       AND  BRAND_CD = P_BRAND_CD
                       AND STOR_CD   = P_STOR_CD
                       AND TOUCH_TP  = 'M'
                       AND USE_YN    = 'Y'
                       AND UPD_DT   >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
                    UNION
                    SELECT  COMP_CD
                         ,  BRAND_CD
                         ,  TOUCH_CD        AS ITEM_CD
                      FROM  TOUCH_UI
                     WHERE  COMP_CD  = P_COMP_CD
                       AND  BRAND_CD = P_BRAND_CD
                       AND  TOUCH_DIV = '2'
                       AND TOUCH_TP  = 'M'
                       AND USE_YN    = 'Y'
                       AND UPD_DT   >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
                    UNION
                    SELECT  COMP_CD
                         ,  BRAND_CD
                         ,  ITEM_CD         AS ITEM_CD
                      FROM  SUB_STORE_ITEM
                     WHERE  COMP_CD  = P_COMP_CD
                       AND  BRAND_CD = P_BRAND_CD
                       AND  STOR_CD  = P_STOR_CD
                       AND  SUB_TOUCH_DIV IN ('2', '3')
                       AND  USE_YN   = 'Y'
                       AND  UPD_DT  >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
                    UNION
                    SELECT  COMP_CD
                         ,  BRAND_CD
                         ,  ITEM_CD         AS ITEM_CD
                      FROM  SET_RULE
                     WHERE  COMP_CD  = P_COMP_CD
                       AND  BRAND_CD = P_BRAND_CD
                       AND  USE_YN   = 'Y'
                       AND  UPD_DT  >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
                     GROUP  BY COMP_CD, BRAND_CD, ITEM_CD
                    UNION
                    SELECT  COMP_CD
                         ,  BRAND_CD
                         ,  OPTN_ITEM_CD    AS ITEM_CD
                      FROM  SET_RULE
                     WHERE  COMP_CD  = P_COMP_CD
                       AND  BRAND_CD = P_BRAND_CD
                       AND  GRP_DIV  = '0'
                       AND  USE_YN   = 'Y'
                       AND  UPD_DT  >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
                     GROUP  BY COMP_CD, BRAND_CD, OPTN_ITEM_CD
                    UNION
                    SELECT  COMP_CD
                         ,  BRAND_CD
                         ,  ITEM_CD         AS ITEM_CD
                      FROM  OPTION_ITEM
                     WHERE  COMP_CD  = P_COMP_CD
                       AND  BRAND_CD = P_BRAND_CD
                       AND  USE_YN   = 'Y'
                       AND  UPD_DT  >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
                     GROUP  BY COMP_CD, BRAND_CD, ITEM_CD
                )
         GROUP  BY COMP_CD, BRAND_CD, ITEM_CD
    ), 
    S_TOUCH AS 
    (
        SELECT  COMP_CD
             ,  TOUCH_CD    AS ITEM_CD
          FROM  TOUCH_STORE_UI
         WHERE  COMP_CD  = P_COMP_CD
           AND  BRAND_CD = P_BRAND_CD
           AND  STOR_CD  = P_STOR_CD
           AND  TOUCH_TP = 'M'
           AND  USE_YN   = 'Y'
        UNION
        SELECT  COMP_CD
             ,  TOUCH_CD    AS ITEM_CD
          FROM  TOUCH_UI
         WHERE  COMP_CD  = P_COMP_CD
           AND  BRAND_CD = P_BRAND_CD
           AND  TOUCH_DIV= '2'
           AND  TOUCH_TP = 'M'
           AND  USE_YN   = 'Y'
        UNION
        SELECT  COMP_CD
             ,  ITEM_CD     AS ITEM_CD
          FROM  SUB_STORE_ITEM
         WHERE  COMP_CD  = P_COMP_CD
           AND  BRAND_CD = P_BRAND_CD
           AND  STOR_CD  = P_STOR_CD
           AND  SUB_TOUCH_DIV IN ('2', '3')
           AND  USE_YN   = 'Y'
        UNION
        SELECT  COMP_CD
             ,  ITEM_CD     AS ITEM_CD
          FROM  SET_RULE
         WHERE  COMP_CD  = P_COMP_CD
           AND  BRAND_CD = P_BRAND_CD
           AND  USE_YN   = 'Y'
         GROUP  BY COMP_CD, ITEM_CD
        UNION
        SELECT  COMP_CD
             ,  OPTN_ITEM_CD AS ITEM_CD
          FROM  SET_RULE
         WHERE  COMP_CD  = P_COMP_CD
           AND  BRAND_CD = P_BRAND_CD
           AND  GRP_DIV  = '0'
           AND  USE_YN   = 'Y'
         GROUP  BY COMP_CD, OPTN_ITEM_CD
        UNION
        SELECT  COMP_CD
             ,  ITEM_CD     AS ITEM_CD
          FROM  OPTION_ITEM
         WHERE  COMP_CD  = P_COMP_CD
           AND  BRAND_CD = P_BRAND_CD
           AND  USE_YN   = 'Y'
         GROUP  BY COMP_CD, ITEM_CD
    )
    SELECT I.BRAND_CD      AS BRAND_CD      -- ��������
         , I.ITEM_CD       AS ITEM_CD       -- ��ǰ�ڵ�
         , I.ITEM_POS_NM   AS ITEM_POS_NM   -- POS ��ǰ��
         , I.SALE_START_DT AS SALE_START_DT -- �ǸŰ�����
         , I.SALE_CLOSE_DT AS SALE_CLOSE_DT -- �Ǹ�������
         , I.L_CLASS_CD    AS L_CLASS_CD    -- ��з� �ڵ�
         , I.M_CLASS_CD    AS M_CLASS_CD    -- �ߺз� �ڵ�
         , I.S_CLASS_CD    AS S_CLASS_CD    -- �Һз� �ڵ�
         , ''              AS FLAVOR_DIV    -- �÷��̹��������� > ������
         , NVL( NVL(T.STOR_SALE_PRC, I.SALE_PRC), 0)    AS SALE_AMT -- �ǸŰ�
         , NVL(I.NODC_YN , 'N') AS NODC_YN -- ���� �Ұ� ǰ�񿩺� => Y : ���κҰ�,  N : ���ΰ���
         , '0' AS SALE_DC_DIV -- ���� ���� ���� > 0:����, 1:�ǸŰ� ������, 2:��������
         , 0   AS SALE_DC_PRC -- ���αݾ�       > ��Ʈ���� �� �ǸŰ� ������ �Ǹ� ���αݾ� ����
         , NVL(I.SALE_VAT_YN, 'N')   AS SALE_VAT_YN   -- �Ǹ� ��������      => ����(00055) [Y:����, N:�鼼]
         , NVL(I.SALE_VAT_RULE, 'N') AS SALE_VAT_RULE -- �Ǹ� VAT ���� ��   => ����(00850) [1:�ΰ�������, 2:�ΰ���������] -> �����
         , NVL( DECODE( I.SALE_PRC_CTRL, 'S', NVL(T.SALE_VAT_IN_RATE , I.SALE_VAT_IN_RATE ), I.SALE_VAT_IN_RATE ), 0) AS SALE_VAT_IN_RATE -- ����ũ�� �Ǹ� VAT��
         , NVL( DECODE( I.SALE_PRC_CTRL, 'S', NVL(T.SALE_VAT_OUT_RATE, I.SALE_VAT_OUT_RATE), I.SALE_VAT_OUT_RATE), 0) AS SALE_VAT_OUT_RATE -- ����ũ�ƿ� �Ǹ� VAT��
         , S.SALE_SVC_YN AS SALE_SVC_YN -- �Ǹ� ���� ���� ����
         , S.SALE_SVC_RULE AS SALE_SVC_RULE -- �Ǹ� ����� ����
         , NVL(S.SALE_SVC_RATE , 0) AS SALE_SVC_RATE -- �Ǹ� ���� ��
         , ''  AS SET_GRP         -- ��Ʈ ���� �׷� > ������
         , NVL(I.SET_DIV , '0') AS SET_DIV -- SET ���� ����     => ����(01100) [0:�������, 1:SET ��ǰ , 2:SET ���Ի�ǰ]
         , 'N' AS TODAY_COFFEE_YN -- ������ Ŀ�ǿ��� > ������
         , '0' AS SUB_ITEM_DIV    -- �ΰ�/�ɼǰ��� > ������
         , 0   AS FLAVOR_QTY      -- �÷��̹� �� �߷�
         , 0   AS STOCK_QTY       -- �÷��̹� ��ǰ ���ü�
         , 0   AS EVENT_AMT       -- [POS] ���� ���� ������ 0���� �ִ´�
         , 'N' AS EVENT_DIV       -- [POS] ���� ���� ������ 'N'���� �ִ´�
         , NVL(I.POINT_YN, 'N') AS POINT_YN -- ����Ʈ ��������    => [Y:yes, N:no]
         , ''  AS O_ITEM_CD -- ��õ���׸޴�
         , I.OPEN_ITEM_YN AS OPEN_ITEM_YN -- ���»�ǰ����
         , '1' AS DISPOSABLE_DIV -- ��ȸ��ǰ���� => ����(01325) [1:��ǰ, 2:��ȸ��ǰ(������)]
         , DECODE(P.USE_YN, 'Y', NVL(P.PRT_NO, ''), '') AS PRT_NO -- �����͹�ȣ
         , I.USE_YN AS USE_YN -- ��� ����
         , B.BAR_CODE AS BAR_CODE -- ���ڵ� (�ϴ�, �ѻ�ǰ�� ���ؼ��� ������ MAX(BAR_CODE)���� �Ѱ��ش�)
         , NP.PRT_NO                 AS ALL_PRT_NO     -- ��ǰ�� ����� ������ ��ȣ  => ex) 1^2^3^5
         , NVL(I.AUTO_POPUP_YN, 'N') AS AUTO_POPUP_YN  -- POS���� ��ǰ���ý� �˾�â �ٿ�� ���� (�ΰ���ǰ �϶�)
         , NVL(I.EXT_YN, 'N')        AS EXT_YN         -- �ΰ���ǰ ����[YN]
         , 'N'                       AS PARENT_ITEM_YN -- �θ��ǰ ���� > ������
         , I.ORD_SALE_DIV                              -- ��뱸��[00045> 1:�ֹ���, 2:�ֹ�/�Ǹſ�, 3:�Ǹſ�, 4:�����]
         , I.ITEM_KDS_NM                               -- KDS ��ǰ��
         , I.SAV_MLG_YN                                -- ���ϸ��� ��������[YN]
      FROM ITEM_CHAIN I,
           (SELECT NVL(MAX(SALE_SVC_YN ), 'N')  AS SALE_SVC_YN
                 , NVL(MAX(SALE_SVC_RULE), '1') AS SALE_SVC_RULE -- 1:�ΰ��� ������, 2:�ΰ��� �����
                 , NVL(MAX(SALE_SVC_RATE), 0 )  AS SALE_SVC_RATE
              FROM STORE_SETUP
             WHERE COMP_CD  = P_COMP_CD
               AND BRAND_CD = P_BRAND_CD
               AND STOR_CD  = P_STOR_CD
           )          S,
           (SELECT *
              FROM ITEM_STORE
             WHERE COMP_CD  = P_COMP_CD
               AND BRAND_CD = P_BRAND_CD
               AND STOR_CD  = P_STOR_CD
               AND USE_YN   = 'Y'
               AND TO_CHAR(SYSDATE, 'YYYYMMDD') BETWEEN SALE_START_DT AND NVL(SALE_CLOSE_DT, '99991231')
           )          T,
           (SELECT *
              FROM STORE_ITEM_PRT
             WHERE COMP_CD  = P_COMP_CD
               AND BRAND_CD = P_BRAND_CD
               AND STOR_CD  = P_STOR_CD
           )          P,
           (SELECT COMP_CD,
                   ITEM_CD ,
                   MAX(CASE WHEN SEQ =  1 THEN        PRT_NO ELSE '' END) ||
                   MAX(CASE WHEN SEQ =  2 THEN '^' || PRT_NO ELSE '' END) ||
                   MAX(CASE WHEN SEQ =  3 THEN '^' || PRT_NO ELSE '' END) ||
                   MAX(CASE WHEN SEQ =  4 THEN '^' || PRT_NO ELSE '' END) ||
                   MAX(CASE WHEN SEQ =  5 THEN '^' || PRT_NO ELSE '' END) ||
                   MAX(CASE WHEN SEQ =  6 THEN '^' || PRT_NO ELSE '' END) ||
                   MAX(CASE WHEN SEQ =  7 THEN '^' || PRT_NO ELSE '' END) ||
                   MAX(CASE WHEN SEQ =  8 THEN '^' || PRT_NO ELSE '' END) ||
                   MAX(CASE WHEN SEQ =  9 THEN '^' || PRT_NO ELSE '' END) ||
                   MAX(CASE WHEN SEQ = 10 THEN '^' || PRT_NO ELSE '' END) ||
                   MAX(CASE WHEN SEQ = 11 THEN '^' || PRT_NO ELSE '' END) ||
                   MAX(CASE WHEN SEQ = 12 THEN '^' || PRT_NO ELSE '' END) ||
                   MAX(CASE WHEN SEQ = 13 THEN '^' || PRT_NO ELSE '' END) ||
                   MAX(CASE WHEN SEQ = 14 THEN '^' || PRT_NO ELSE '' END) ||
                   MAX(CASE WHEN SEQ = 15 THEN '^' || PRT_NO ELSE '' END) ||
                   MAX(CASE WHEN SEQ = 16 THEN '^' || PRT_NO ELSE '' END) ||
                   MAX(CASE WHEN SEQ = 17 THEN '^' || PRT_NO ELSE '' END) ||
                   MAX(CASE WHEN SEQ = 18 THEN '^' || PRT_NO ELSE '' END) ||
                   MAX(CASE WHEN SEQ = 19 THEN '^' || PRT_NO ELSE '' END) ||
                   MAX(CASE WHEN SEQ = 20 THEN '^' || PRT_NO ELSE '' END) AS PRT_NO
              FROM (SELECT COMP_CD,
                           ITEM_CD ,
                           TO_CHAR(PRT_NO) PRT_NO ,
                           ROW_NUMBER() OVER(PARTITION BY ITEM_CD ORDER BY ITEM_CD, PRT_NO ) SEQ
                      FROM STORE_ITEM_PRT
                     WHERE COMP_CD  = P_COMP_CD
                       AND BRAND_CD = P_BRAND_CD
                       AND STOR_CD  = P_STOR_CD
                     GROUP BY COMP_CD, ITEM_CD, PRT_NO
                   )
             GROUP BY COMP_CD, ITEM_CD
           )          NP,
           (SELECT COMP_CD,
                   ITEM_CD,
                   MAX(BAR_CODE) BAR_CODE
              FROM BARCODE
             WHERE COMP_CD = P_COMP_CD
               AND USE_YN  = 'Y'
             GROUP BY COMP_CD, ITEM_CD
           )          B,
           S_TOUCH    U,
           IT         A
     WHERE I.COMP_CD   = T.COMP_CD(+)
       AND I.ITEM_CD   = T.ITEM_CD(+)
       AND I.COMP_CD   = U.COMP_CD(+)
       AND I.ITEM_CD   = U.ITEM_CD(+)
       AND I.COMP_CD   = P_COMP_CD
       AND I.BRAND_CD  = P_BRAND_CD
       AND I.STOR_TP   = P_STOR_TP
       AND I.COMP_CD   = P.COMP_CD(+)
       AND I.BRAND_CD  = P.BRAND_CD(+)
       AND I.ITEM_CD   = P.ITEM_CD(+)
       AND I.COMP_CD   = NP.COMP_CD(+)
       AND I.ITEM_CD   = NP.ITEM_CD(+)
       AND I.COMP_CD   = B.COMP_CD(+)
       AND I.ITEM_CD   = B.ITEM_CD(+)
       AND I.COMP_CD   = A.COMP_CD
       AND I.BRAND_CD  = A.BRAND_CD
       AND I.ITEM_CD   = A.ITEM_CD
       AND I.USE_YN LIKE P_USE_YN;
       
    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_01;
  
  --------------------------------------------------------------------------------
  --  Description      : POS������ ���ſ� (��Ʈ��ǰ)
  -- Ref. Table        : SET_GRP_RULE(��Ʈ��ǰ),  SET_GRP_ITEM (��Ʈ���ո�����)
  --------------------------------------------------------------------------------
  --  Create Date      : 2009-12-15
  --  Modify Date      : 2009-12-15
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_04 (
    anRetVal OUT NUMBER,   -- ����ڵ�
    asRetMsg OUT VARCHAR2, -- ���� �޽���
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
      OPEN p_cursor FOR
      SELECT T.BRAND_CD      BRAND_CD
           , P_STOR_CD       STOR_CD
           , T.SALE_START_DT SALE_START_DT
           , T.SEQ           SEQ
           , T.SET_GRP       SET_GRP
           , CASE T.SET_TP
                  WHEN '1' THEN I.ITEM_CD
                  ELSE          T.SET_GRP
             END             ITEM_CD
           , T.SET_H_RANK    SET_RANK
           , T.SALE_END_DT   SALE_END_DT
           , T.SET_TP        SET_TP
           , T.SALE_DC_FG    DC_FG
           , T.SALE_DC_RATE  DC_RATE
           , T.SALE_DC_AMT   DC_AMT
           , T.SALE_QTY      QTY
           , T.USE_D_YN      USE_YN
           , T.DC_DIV
        FROM (SELECT B.COMP_CD,
                     B.BRAND_CD AS BRAND_CD ,
                     A.SALE_START_DT AS SALE_START_DT ,
                     A.SEQ AS SEQ ,
                     B.SET_GRP AS SET_GRP ,
                     B.SET_TP AS SET_TP ,
                     A.SET_RANK AS SET_H_RANK ,
                     NVL(A.SALE_END_DT,'99999999') AS SALE_END_DT ,
                     B.DC_FG AS SALE_DC_FG ,
                     NVL(B.DC_RATE,0) AS SALE_DC_RATE ,
                     NVL(B.DC_AMT,0) AS SALE_DC_AMT ,
                     NVL(B.QTY,1) AS SALE_QTY ,
                     NVL(A.USE_YN,'N') AS USE_H_YN ,
                     NVL(B.USE_YN,'N') AS USE_D_YN ,
                     DECODE(A.STORE_APP_DIV, '0' , P_STOR_CD , '1' , S.STOR_CD , '2' , DECODE(S.STOR_CD, P_STOR_CD, '', P_STOR_CD) , '' ) AS STOR_CD ,
                     A.STORE_APP_DIV AS STORE_APP_DIV ,
                     DECODE(A.STORE_APP_DIV, '0' , 'Y' , '1' , S.USE_YN , '2' , DECODE(S.USE_YN, 'Y', 'N', 'Y') , 'N' ) AS USE_S_YN,
                     A.DC_DIV
                FROM SET_GRP_RULE A ,
                     (SELECT NVL(B.COMP_CD, A.COMP_CD)  AS COMP_CD,
                             NVL(B.BRAND_CD,A.BRAND_CD) AS BRAND_CD ,
                             NVL(B.SALE_START_DT,A.SALE_START_DT) AS SALE_START_DT ,
                             NVL(B.SEQ,A.SEQ) AS SEQ ,
                             NVL(B.SET_GRP,A.SET_GRP) AS SET_GRP ,
                             NVL(B.SET_TP,A.SET_TP) AS SET_TP ,
                             NVL(B.DC_FG,A.DC_FG) AS DC_FG ,
                             NVL(B.DC_RATE,A.DC_RATE) AS DC_RATE ,
                             NVL(B.DC_AMT,A.DC_AMT) AS DC_AMT ,
                             NVL(B.QTY,A.QTY) AS QTY ,
                             NVL(A.USE_YN,'N') AS USE_YN ,
                             NVL(B.UPD_DT,A.UPD_DT) AS UPD_DT
                        FROM SET_GRP_ITEM A ,
                             SET_GRP_ITEM_STORE B
                       WHERE A.COMP_CD  = B.COMP_CD(+)
                         AND A.BRAND_CD = B.BRAND_CD(+)
                         AND A.SALE_START_DT = B.SALE_START_DT(+)
                         AND A.SEQ = B.SEQ(+)
                         AND A.SET_GRP = B.SET_GRP(+)
                         AND A.SET_TP = B.SET_TP(+)
                         AND A.COMP_CD     = P_COMP_CD
                         AND A.BRAND_CD    = P_BRAND_CD
                         AND B.STOR_CD (+) = P_STOR_CD
                     ) B ,
                     SET_GRP_RULE_STORE S
               WHERE A.COMP_CD  = P_COMP_CD
                 AND A.BRAND_CD = P_BRAND_CD
                 AND A.COMP_CD  = B.COMP_CD
                 AND A.BRAND_CD = B.BRAND_CD
                 AND A.SALE_START_DT = B.SALE_START_DT
                 AND A.SEQ      = B.SEQ
                 AND A.COMP_CD  = S.COMP_CD(+)
                 AND A.BRAND_CD = S.BRAND_CD(+)
                 AND A.SALE_START_DT = S.SALE_START_DT(+)
                 AND A.SEQ      = S.SEQ(+)
                 AND S.COMP_CD (+) = P_COMP_CD
                 AND S.BRAND_CD(+) = P_BRAND_CD
                 AND S.STOR_CD (+) = P_STOR_CD
          ) T ,
          ITEM_SET_GRP I
    WHERE T.COMP_CD  = I.COMP_CD (+)
      AND T.SET_GRP  = I.SET_GRP (+)
      AND I.COMP_CD(+) = P_COMP_CD
      AND T.USE_H_YN = 'Y'
      AND T.USE_S_YN = 'Y'
      AND T.USE_D_YN = 'Y'
      AND ( I.USE_YN = 'Y' OR T.SET_TP = '2' );
      
    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_04;
  
  --------------------------------------------------------------------------------
  --  Description      : POS������ ���ſ� (������ǰ HD)
  -- Ref. Table        : BUNDLE_HD
  --------------------------------------------------------------------------------
  --  Create Date      : 2009-12-16
  --  Modify Date      : 2009-12-16
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_05 (
    anRetVal OUT NUMBER,   -- ����ڵ�
    asRetMsg OUT VARCHAR2, -- ���� �޽���
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT H.BRAND_CD      BRAND_CD  -- ��������
         , H.STOR_CD       STOR_CD   -- �����ڵ�
         , H.BUNDLE_CD     BUNDLE_CD -- �����ڵ�
         , H.BUNDLE_NM     BUNDLE_NM -- �����ڵ� ��
         , NVL(D.SALE_AMT, 0)       SALE_AMT -- �����Ǹűݾ�
         , NVL(H.DC_AMT , 0)        DC_AMT -- �������αݾ�
         , NVL(D.SALE_AMT - H.DC_AMT, 0) GRD_AMT -- �������Ǹűݾ�
         , H.CONTINUE_YN   CONTINUE_YN -- ���ӱ���
         , H.USE_YN        USE_YN -- �������
         , TO_CHAR(H.UPD_DT, 'YYYYMMDDHH24MISS') UPD_DT -- �����Ͻ�
      FROM BUNDLE_HD H,
           (SELECT COMP_CD,
                   BUNDLE_CD,
                   NVL(SUM(SALE_PRC * BUNDLE_QTY), 0) SALE_AMT
             FROM BUNDLE_DT
            WHERE (COMP_CD, BRAND_CD, STOR_CD, BUNDLE_CD) IN
                  (SELECT COMP_CD,
                          BRAND_CD,
                          STOR_CD,
                          BUNDLE_CD
                     FROM BUNDLE_HD
                    WHERE COMP_CD  = P_COMP_CD
                      AND BRAND_CD = P_BRAND_CD
                      AND STOR_CD  = P_STOR_CD
                      AND UPD_DT  >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
                      AND USE_YN   = 'Y'
                  )
              AND USE_YN  = 'Y'
              AND COMP_CD = P_COMP_CD
            GROUP BY COMP_CD, BUNDLE_CD
           ) D
     WHERE H.COMP_CD   = D.COMP_CD(+)
       AND H.BUNDLE_CD = D.BUNDLE_CD(+)
       AND H.COMP_CD   = P_COMP_CD
       AND H.BRAND_CD  = P_BRAND_CD
       AND H.STOR_CD   = P_STOR_CD
       AND H.UPD_DT   >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
       AND H.USE_YN LIKE P_USE_YN;
       
    anRetVal := 1 ;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_05;
  
  --------------------------------------------------------------------------------
  --  Description      : POS������ ���ſ� (������ǰ DT)
  -- Ref. Table        : BUNDLE_DT
  --------------------------------------------------------------------------------
  --  Create Date      : 2009-12-16
  --  Modify Date      : 2009-12-16
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_06 (
    anRetVal OUT NUMBER,   -- ����ڵ�
    asRetMsg OUT VARCHAR2, -- ���� �޽���
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT D.BRAND_CD      BRAND_CD    -- ��������
         , D.STOR_CD       STOR_CD     -- �����ڵ�
         , D.BUNDLE_CD     BUNDLE_CD   -- �����ڵ�
         , D.ITEM_CD       ITEM_CD     -- ��ǰ�ڵ�
         , NVL(D.SALE_PRC, 0)              SALE_PRC   -- �ǸŰ�
         , NVL(D.BUNDLE_QTY, 0)            BUNDLE_QTY -- ��������
         , NVL(D.SALE_PRC * BUNDLE_QTY, 0) SALE_AMT   -- �Ǹűݾ�
         , I.SALE_VAT_YN   SALE_VAT_YN   -- ���� ����
         , I.SALE_VAT_RULE SALE_VAT_RULE -- �ǸŰ� VAT ����  [1:�ΰ�������, 2:�ΰ���������]
         , NVL(I.SALE_VAT_IN_RATE , 0)     SALE_VAT_IN_RATE -- �Ǹ� TAKE IN VAT��
         , NVL(I.SALE_VAT_OUT_RATE, 0)     SALE_VAT_OUT_RATE -- �Ǹ� TAKE OUT VAT��
         , S.SALE_SVC_YN   SALE_SVC_DIV  -- �Ǹ� ���� ���� ����  =>[ Y/N ]
         , NVL(S.SALE_SVC_RATE , 0)        SALE_SVC_RATE -- �Ǹ� ���� ��
         , 0               SALE_SVC_PRC  -- �Ǹ� ���� �ݾ�  => ������ 0���� �ֱ����
         , NVL(H.DC_RATE , 0)              DC_RATE -- ������
         , NVL(D.DC_AMT , 0)               DC_AMT  -- ���αݾ�
         , 0               FIXED_DC_AMT  -- ���������ݾ�
         , 0               GRD_AMT       -- ���Ǹűݾ�
         , D.USE_YN        USE_YN        -- �������
         , TO_CHAR(D.UPD_DT, 'YYYYMMDDHH24MISS') UPD_DT -- �����Ͻ�
      FROM BUNDLE_DT D
         , BUNDLE_HD H
         , ITEM_CHAIN I
         , (SELECT COMP_CD,
                   BRAND_CD,
                   STOR_CD,
                   SALE_SVC_YN,
                   SALE_SVC_RATE
              FROM STORE_SETUP
             WHERE COMP_CD  = P_COMP_CD
               AND BRAND_CD = P_BRAND_CD
               AND STOR_CD  = P_STOR_CD
           ) S
       WHERE D.COMP_CD   = I.COMP_CD
         AND D.BRAND_CD  = I.BRAND_CD
         AND D.ITEM_CD   = I.ITEM_CD
         AND P_STOR_TP   = I.STOR_TP
         AND D.COMP_CD   = H.COMP_CD
         AND D.BRAND_CD  = H.BRAND_CD
         AND D.STOR_CD   = H.STOR_CD
         AND D.BUNDLE_CD = H.BUNDLE_CD
         AND D.COMP_CD   = S.COMP_CD(+)
         AND D.BRAND_CD  = S.BRAND_CD(+)
         AND D.STOR_CD   = S.STOR_CD(+)
         AND D.COMP_CD   = P_COMP_CD
         AND D.BRAND_CD  = P_BRAND_CD
         AND D.STOR_CD   = P_STOR_CD
         AND D.UPD_DT   >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
         AND D.USE_YN LIKE P_USE_YN;
         
    anRetVal := 1 ;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_06;
  
  --------------------------------------------------------------------------------
  --  Description      : POS������ ���ſ� (�ֹ���� ������ ��ǰ)
  -- Ref. Table        : STORE_ITEM_PRT
  --------------------------------------------------------------------------------
  --  Create Date      : 2009-12-16
  --  Modify Date      : 2009-12-16
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_07 (
    anRetVal OUT NUMBER,   -- ����ڵ�
    asRetMsg OUT VARCHAR2, -- ���� �޽���
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT BRAND_CD      BRAND_CD -- ��������
         , STOR_CD       STOR_CD -- �����ڵ�
         , PRT_NO        PRT_NO -- �����͹�ȣ
         , ITEM_CD       ITEM_CD -- ��ǰ�ڵ�
         , USE_YN        USE_YN -- �������
         , TO_CHAR(UPD_DT, 'YYYYMMDDHH24MISS') UPD_DT -- �����Ͻ�
      FROM STORE_ITEM_PRT
     WHERE COMP_CD   = P_COMP_CD
       AND BRAND_CD  = P_BRAND_CD
       AND STOR_CD   = P_STOR_CD
       AND UPD_DT   >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
       AND USE_YN LIKE P_USE_YN
     ORDER BY UPD_DT;
     
    anRetVal := 1 ;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_07;
  
  --------------------------------------------------------------------------------
  --  Description      : POS������ ���ſ� (�α��ǰ)
  -- Ref. Table        : BEST_ITEM
  --------------------------------------------------------------------------------
  --  Create Date      : 2009-12-15
  --  Modify Date      : 2009-12-15
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_08 (
    anRetVal OUT NUMBER,   -- ����ڵ�
    asRetMsg OUT VARCHAR2, -- ���� �޽���
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT BRAND_CD      BRAND_CD -- ��������
         , STOR_CD       STOR_CD -- �����ڵ�
         , ITEM_CD       ITEM_CD -- ��ǰ�ڵ�
         , USE_YN        USE_YN -- ��뿩��
         , TO_CHAR(UPD_DT, 'YYYYMMDDHH24MISS') UPD_DT -- �����Ͻ�
      FROM BEST_ITEM
     WHERE COMP_CD   = P_COMP_CD
       AND BRAND_CD  = P_BRAND_CD
       AND UPD_DT   >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
       AND USE_YN LIKE P_USE_YN;
       
    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_08;
  
  --------------------------------------------------------------------------------
  --  Description      : POS������ ���ſ� (��ġŰ����)
  -- Ref. Table        : TOUCH_STORE_UI
  --------------------------------------------------------------------------------
  --  Create Date      : 2009-12-17
  --  Modify Date      : 2009-12-17
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_09 (
    anRetVal OUT NUMBER,   -- ����ڵ�
    asRetMsg OUT VARCHAR2, -- ���� �޽���
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    IF P_COMP_CD <> '012' THEN
        -- �Ϲ� ��ġŰ ����
        OPEN p_cursor FOR
        SELECT  BRAND_CD      BRAND_CD    -- ��������
             ,  STOR_CD       STOR_CD     -- �����ڵ�
             ,  TOUCH_DIV     TOUCH_DIV   -- ��ġŰ ����
             ,  TOUCH_GR_CD   TOUCH_GR_CD -- ��ġŰ �׷� �ڵ�
             ,  TOUCH_CD      TOUCH_CD    -- ��ġŰ �ڵ�
             ,  TOUCH_TP      TOUCH_TP    -- ��ǰ UI �׷� ���� => [G:�޴��׷�, T:�޴�Ÿ�� ,M:�޴�]
             ,  TOUCH_NM      TOUCH_NM    -- POS ��ǰ��
             ,  BTN_COLOR1    BTN_COLOR1  -- ��ư���� 1
             ,  BTN_COLOR2    BTN_COLOR2  -- ��ư���� 2
             ,  FONT_COLOR    FONT_COLOR  -- ��Ʈ����
             ,  NVL(FONT_SIZE, 0)                    FONT_SIZE -- ��Ʈũ��
             ,  NVL(POSITION , 0)                    POSITION -- ��ǰ DISPLAY ��ġ
             ,  IMG_YN        IMG_YN -- �̹��� ����
             ,  IMG_PATH      IMG_PATH -- �̹��� ��
             ,  USE_YN        USE_YN -- ��뿩��
             ,  TO_CHAR(UPD_DT, 'YYYYMMDDHH24MISS')  UPD_DT -- �����Ͻ�
             ,  FONT_WEIGHT   FONT_WEIGHT -- ��Ʈ����
          FROM  TOUCH_STORE_UI
         WHERE  COMP_CD   = P_COMP_CD
           AND  BRAND_CD  = P_BRAND_CD
           AND  STOR_CD   = P_STOR_CD
           AND  UPD_DT   >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
           AND  USE_YN LIKE P_USE_YN;
    ELSE
        -- �𽺹��ſ�
        OPEN p_cursor FOR
        SELECT  P_BRAND_CD    BRAND_CD    -- ��������
             ,  P_STOR_CD     STOR_CD     -- �����ڵ�
             ,  TOUCH_DIV     TOUCH_DIV   -- ��ġŰ ����
             ,  TOUCH_GR_CD   TOUCH_GR_CD -- ��ġŰ �׷� �ڵ�
             ,  TOUCH_CD      TOUCH_CD    -- ��ġŰ �ڵ�
             ,  TOUCH_TP      TOUCH_TP    -- ��ǰ UI �׷� ���� => [G:�޴��׷�, T:�޴�Ÿ�� ,M:�޴�]
             ,  TOUCH_NM      TOUCH_NM    -- POS ��ǰ��
             ,  BTN_COLOR1    BTN_COLOR1  -- ��ư���� 1
             ,  BTN_COLOR2    BTN_COLOR2  -- ��ư���� 2
             ,  FONT_COLOR    FONT_COLOR  -- ��Ʈ����
             ,  NVL(FONT_SIZE, 0)                    FONT_SIZE -- ��Ʈũ��
             ,  NVL(POSITION , 0)                    POSITION -- ��ǰ DISPLAY ��ġ
             ,  IMG_YN        IMG_YN -- �̹��� ����
             ,  IMG_PATH      IMG_PATH -- �̹��� ��
             ,  USE_YN        USE_YN -- ��뿩��
             ,  TO_CHAR(UPD_DT, 'YYYYMMDDHH24MISS')  UPD_DT -- �����Ͻ�
             ,  FONT_WEIGHT   FONT_WEIGHT -- ��Ʈ����
          FROM  TOUCH_UI
         WHERE  COMP_CD   = P_COMP_CD
           AND  BRAND_CD  = P_BRAND_CD
           AND  (
                    (TOUCH_TP = 'G' AND POSITION <> '1')
                    OR
                    (
                        TOUCH_TP = 'M' AND TOUCH_GR_CD IN (
                                                            SELECT  TOUCH_GR_CD
                                                              FROM  TOUCH_UI
                                                             WHERE  COMP_CD   = P_COMP_CD
                                                               AND  BRAND_CD  = P_BRAND_CD
                                                               AND  TOUCH_TP  = 'G'
                                                               AND  POSITION  <> '1'
                                                          )
                    )
                )
           AND  UPD_DT   >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
           AND  USE_YN LIKE P_USE_YN
        UNION ALL
        SELECT  BRAND_CD      BRAND_CD    -- ��������
             ,  STOR_CD       STOR_CD     -- �����ڵ�
             ,  TOUCH_DIV     TOUCH_DIV   -- ��ġŰ ����
             ,  TOUCH_GR_CD   TOUCH_GR_CD -- ��ġŰ �׷� �ڵ�
             ,  TOUCH_CD      TOUCH_CD    -- ��ġŰ �ڵ�
             ,  TOUCH_TP      TOUCH_TP    -- ��ǰ UI �׷� ���� => [G:�޴��׷�, T:�޴�Ÿ�� ,M:�޴�]
             ,  TOUCH_NM      TOUCH_NM    -- POS ��ǰ��
             ,  BTN_COLOR1    BTN_COLOR1  -- ��ư���� 1
             ,  BTN_COLOR2    BTN_COLOR2  -- ��ư���� 2
             ,  FONT_COLOR    FONT_COLOR  -- ��Ʈ����
             ,  NVL(FONT_SIZE, 0)                    FONT_SIZE -- ��Ʈũ��
             ,  NVL(POSITION , 0)                    POSITION -- ��ǰ DISPLAY ��ġ
             ,  IMG_YN        IMG_YN -- �̹��� ����
             ,  IMG_PATH      IMG_PATH -- �̹��� ��
             ,  USE_YN        USE_YN -- ��뿩��
             ,  TO_CHAR(UPD_DT, 'YYYYMMDDHH24MISS')  UPD_DT -- �����Ͻ�
             ,  FONT_WEIGHT   FONT_WEIGHT -- ��Ʈ����
          FROM  TOUCH_STORE_UI
         WHERE  COMP_CD   = P_COMP_CD
           AND  BRAND_CD  = P_BRAND_CD
           AND  STOR_CD   = P_STOR_CD
           AND  (
                    (TOUCH_TP = 'G' AND POSITION = '1')
                    OR
                    (
                        TOUCH_TP = 'M' AND TOUCH_GR_CD = (
                                                            SELECT  TOUCH_GR_CD
                                                              FROM  TOUCH_STORE_UI
                                                             WHERE  COMP_CD   = P_COMP_CD
                                                               AND  BRAND_CD  = P_BRAND_CD
                                                               AND  STOR_CD   = P_STOR_CD
                                                               AND  TOUCH_TP  = 'G'
                                                               AND  POSITION  = '1'
                                                         )
                    )
                )
           AND  UPD_DT   >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
           AND  USE_YN LIKE P_USE_YN;
    END IF;
    
    anRetVal := 1 ;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_09;
  
  --------------------------------------------------------------------------------
  --  Description      : POS������ ���ſ� (�ΰ���ǰ��ġŰ�׷�)
  -- Ref. Table        : SUB_TOUCH_UI
  --------------------------------------------------------------------------------
  --  Create Date      : 2009-12-15
  --  Modify Date      : 2009-12-15
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_10 (
    anRetVal OUT NUMBER,   -- ����ڵ�
    asRetMsg OUT VARCHAR2, -- ���� �޽���
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    WITH GR AS (
      SELECT COMP_CD
           , BRAND_CD
           , STOR_CD
           , SUB_TOUCH_GR_CD
        FROM (
              SELECT COMP_CD,
                     BRAND_CD,
                     STOR_CD,
                     SUB_TOUCH_GR_CD
                FROM SUB_STORE_TOUCH_UI
               WHERE COMP_CD   = P_COMP_CD
                 AND BRAND_CD  = P_BRAND_CD
                 AND STOR_CD   = P_STOR_CD
                 AND UPD_DT   >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
                 AND USE_YN LIKE P_USE_YN
              UNION
              SELECT COMP_CD,
                     BRAND_CD,
                     STOR_CD,
                     SUB_TOUCH_GR_CD
                FROM SUB_STORE_ITEM
               WHERE COMP_CD   = P_COMP_CD
                 AND BRAND_CD  = P_BRAND_CD
                 AND STOR_CD   = P_STOR_CD
                 AND UPD_DT   >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
                 AND USE_YN LIKE P_USE_YN
               GROUP BY COMP_CD, BRAND_CD, STOR_CD, SUB_TOUCH_GR_CD
             )
    )
    SELECT U.BRAND_CD AS BRAND_CD -- ��������
         , P_STOR_CD  AS STOR_CD  -- �����ڵ�
         , U.SUB_TOUCH_GR_CD AS SUB_TOUCH_GR_CD -- �ΰ���ǰ ��ġŰ �׷� �ڵ�
         , U.SUB_TOUCH_GR_CD AS SUB_TOUCH_CD    -- �ΰ���ǰ�ڵ�
         , 'G' AS SUB_TOUCH_TP  -- ��ǰ UI �׷� ����  => ('G' :�޴��׷�, 'M':�޴�)���Ž� ���Ƿ� �־��ش�.���Ƿ� ������ش�.
         , '0' AS SUB_TOUCH_DIV -- �ΰ���ǰ����
         , U.SUB_TOUCH_GR_CD AS ITEM_CD -- �ΰ���ǰ�ڵ�
         , 0 AS SALE_PRC        -- ��ǰ�ݾ�
         , U.SUB_TOUCH_NM AS SUB_ITEM_NM -- ��ǰ��
         , U.BTN_COLOR1 AS BTN_COLOR1 -- ��ư���� 1
         , U.BTN_COLOR2 AS BTN_COLOR2 -- ��ư���� 2
         , U.FONT_COLOR AS FONT_COLOR -- ��Ʈ����
         , NVL(U.FONT_SIZE, 0) AS FONT_SIZE -- ��Ʈũ��
         , NVL(U.POSITION , 1) AS SUB_POSITION -- ��ǰ DISPLAY ��ġ
         , U.IMG_YN AS IMG_YN -- �̹��� ����
         , U.IMG_PATH AS IMG_PATH -- �̹��� ��
         , U.USE_YN AS USE_YN -- ��� ����
         , TO_CHAR(U.UPD_DT, 'YYYYMMDDHH24MISS') AS UPD_DT -- �����Ͻ�
      FROM SUB_STORE_TOUCH_UI U,
           GR                 G
     WHERE G.COMP_CD  = U.COMP_CD
       AND G.BRAND_CD = U.BRAND_CD
       AND G.STOR_CD = U.STOR_CD
       AND G.SUB_TOUCH_GR_CD = U.SUB_TOUCH_GR_CD
    UNION ALL
    SELECT U.BRAND_CD AS BRAND_CD -- ��������
         , P_STOR_CD AS STOR_CD -- �����ڵ�
         , I.SUB_TOUCH_GR_CD AS SUB_TOUCH_GR_CD -- �ΰ���ǰ ��ġŰ �׷� �ڵ�
         , I.SUB_TOUCH_CD AS SUB_TOUCH_CD -- �ΰ���ǰ�ڵ�
         , 'M' AS SUB_TOUCH_TP -- ��ǰ UI �׷� ����  => ('G' :�޴��׷�, 'M':�޴�)���Ž� ���Ƿ� �־��ش�.���Ƿ� ������ش�.
         , I.SUB_TOUCH_DIV AS SUB_TOUCH_DIV -- �ΰ���ǰ����
         , I.ITEM_CD AS ITEM_CD -- �ΰ���ǰ�ڵ�
         , NVL(I.SALE_PRC, 0) AS SALE_PRC -- ��ǰ�ݾ�
         , NVL(I.SUB_ITEM_NM, C.ITEM_POS_NM) AS SUB_ITEM_NM -- ��ǰ�� JSD
         , I.BTN_COLOR1 AS BTN_COLOR1 -- ��ư���� 1
         , I.BTN_COLOR2 AS BTN_COLOR2 -- ��ư���� 2
         , I.FONT_COLOR AS FONT_COLOR -- ��Ʈ����
         , NVL(I.FONT_SIZE, 0) AS FONT_SIZE -- ��Ʈũ��
         , NVL(I.POSITION , 1) AS SUB_POSITION -- ��ǰ DISPLAY ��ġ
         , I.IMG_YN AS IMG_YN -- �̹��� ����
         , I.IMG_PATH AS IMG_PATH -- �̹��� ��
         , I.USE_YN AS USE_YN -- ��� ����
         , TO_CHAR( I.UPD_DT, 'YYYYMMDDHH24MISS' ) AS UPD_DT -- �����Ͻ�
      FROM SUB_STORE_TOUCH_UI U
         , SUB_STORE_ITEM     I
         , ITEM_CHAIN         C
         , GR                 G
     WHERE G.COMP_CD  = U.COMP_CD
       AND G.BRAND_CD = U.BRAND_CD
       AND G.STOR_CD  = U.STOR_CD
       AND G.SUB_TOUCH_GR_CD = U.SUB_TOUCH_GR_CD
       AND G.COMP_CD  = I.COMP_CD
       AND G.BRAND_CD = I.BRAND_CD
       AND G.STOR_CD  = I.STOR_CD
       AND G.SUB_TOUCH_GR_CD = I.SUB_TOUCH_GR_CD
       AND I.COMP_CD  = C.COMP_CD(+)
       AND I.BRAND_CD = C.BRAND_CD(+)
       AND I.ITEM_CD  = C.ITEM_CD(+)
       AND P_STOR_TP  = C.STOR_TP(+);
       
    anRetVal := 1 ;
    asRetMsg := 'OK';
  Exception
  When OTHERS Then
      asRetMsg := SQLERRM(SQLCODE);
      anRetVal := SQLCODE ;
  END GET_MASTER_10 ;
  
  --------------------------------------------------------------------------------
  --  Description      : POS������ ���ſ� (��ǰ�� �ΰ���ǰ �׷�)
  -- Ref. Table        : ITEM_EXT_GRP
  --------------------------------------------------------------------------------
  --  Create Date      : 2012-03-12
  --  Modify Date      : 2012-03-12
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_11 (
    anRetVal OUT NUMBER,   -- ����ڵ�
    asRetMsg OUT VARCHAR2, -- ���� �޽���
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT BRAND_CD
         , STOR_CD
         , ITEM_CD
         , SUB_TOUCH_GR_CD
         , USE_YN
      FROM ITEM_EXT_GRP
     WHERE COMP_CD  = P_COMP_CD
       AND BRAND_CD = P_BRAND_CD
       AND STOR_CD  = P_STOR_CD
       AND UPD_DT  >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS');
       
    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_11;
  
  --------------------------------------------------------------------------------
  --  Description      : POS������ ���ſ� (��ư����)
  -- Ref. Table        : BUTTON_INFO
  --------------------------------------------------------------------------------
  --  Create Date      : 2012-04-09
  --  Modify Date      : 2012-04-09
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_12 (
    anRetVal OUT NUMBER,   -- ����ڵ�
    asRetMsg OUT VARCHAR2, -- ���� �޽���
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT BRAND_CD
         , STOR_CD
         , POS_NO
         , STORE_GB
         , BTN_GRP_CD
         , BTN_GRP_NM
         , BTN_SEQ
         , BTN_PG_NM
         , BTN_CD
         , BTN_TEXT
         , BTN_EVENT
         , BTN_FCOLOR
         , BTN_ECOLOR
         , FONT_COLOR
         , SIZE_H
         , SIZE_W
         , BTN_USE
      FROM BUTTON_INFO
     WHERE COMP_CD  = P_COMP_CD
       AND BRAND_CD = P_BRAND_CD
       AND STOR_CD  = P_STOR_CD;
       
    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_12;
  
  --------------------------------------------------------------------------------
  --  Description      : POS������ ���ſ� (�ɼǻ�ǰ)
  -- Ref. Table        : OPTION_ITEM
  --------------------------------------------------------------------------------
  --  Create Date      : 2009-12-15
  --  Modify Date      : 2009-12-15
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_13 (
    anRetVal OUT NUMBER,   -- ����ڵ�
    asRetMsg OUT VARCHAR2, -- ���� �޽���
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    WITH GR AS (
      SELECT COMP_CD,
             BRAND_CD,
             OPT_GRP
        FROM OPTION_GRP
       WHERE COMP_CD   = P_COMP_CD
         AND BRAND_CD  = P_BRAND_CD
         AND UPD_DT   >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
         AND USE_YN LIKE P_USE_YN
      UNION
      SELECT COMP_CD,
             BRAND_CD,
             OPT_GRP
        FROM OPTION_ITEM
       WHERE COMP_CD   = P_COMP_CD
         AND BRAND_CD  = P_BRAND_CD
         AND UPD_DT   >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
         AND USE_YN LIKE P_USE_YN
       GROUP BY COMP_CD, BRAND_CD,
             OPT_GRP
    )
    SELECT G.BRAND_CD   BRAND_CD    -- ��������
         , P_STOR_CD    STOR_CD     -- �����ڵ�
         , G.OPT_GRP    OPT_GRP     -- �ɼǱ׷�
         , G.OPT_GRP    OPT_CD      -- �ɼ��ڵ�
         , 0            OPT_SEQ     -- �ɼǼ���
         , G.OPT_GRP_NM OPT_NM      -- �ɼǻ�ǰ��
         , 'N'          REF_ITEM_YN -- �����ǰ����
         , NULL         ITEM_CD     -- �����ǰ�ڵ�
         , 'N'          STOCK_YN    -- ����������
         , G.USE_YN     USE_YN      -- ��� ����
         , 0            SET_PRC     -- ��Ʈ���Դܰ�
      FROM OPTION_GRP G,
           GR         R
     WHERE G.COMP_CD  = R.COMP_CD
       AND G.BRAND_CD = R.BRAND_CD
       AND G.OPT_GRP  = R.OPT_GRP
    UNION ALL
    SELECT I.BRAND_CD    BRAND_CD    -- ��������
         , P_STOR_CD     STOR_CD     -- �����ڵ�
         , I.OPT_GRP     OPT_GRP     -- �ɼǱ׷�
         , I.OPT_CD      OPT_CD      -- �ɼ��ڵ�
         , I.OPT_SEQ     OPT_SEQ     -- �ɼǼ���
         , I.OPT_NM      OPT_NM      -- �ɼǻ�ǰ��
         , I.REF_ITEM_YN REF_ITEM_YN -- �����ǰ����
         , I.ITEM_CD     ITEM_CD -- �����ǰ�ڵ�
         , NVL(I.STOCK_YN, 'N')  STOCK_YN -- ����������
         , I.USE_YN      USE_YN -- ��� ����
         , NVL(I.SET_PRC, 0)     SET_PRC  -- ��Ʈ���Դܰ�
      FROM OPTION_ITEM I,
           GR          R
     WHERE I.COMP_CD  = R.COMP_CD
       AND I.BRAND_CD = R.BRAND_CD
       AND I.OPT_GRP  = R.OPT_GRP;
       
    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE ;
  END GET_MASTER_13;
  
  --------------------------------------------------------------------------------
  --  Description      : POS������ ���ſ� (�ɼǻ�ǰ RULE)
  -- Ref. Table        : ITEM_OPTION_RULE
  --------------------------------------------------------------------------------
  --  Create Date      : 2009-12-15
  --  Modify Date      : 2009-12-15
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_14 (
    anRetVal OUT NUMBER,   -- ����ڵ�
    asRetMsg OUT VARCHAR2, -- ���� �޽���
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT R.BRAND_CD   BRAND_CD -- ��������
         , P_STOR_CD    STOR_CD  -- �����ڵ�
         , R.ITEM_CD    ITEM_CD  -- ��ǰ�ڵ�
         , R.OPT_GRP    OPT_GRP  -- �ɼǱ׷�
         , TO_CHAR(R.OPT_SEQ)  OPT_SEQ -- �ɼǼ���
         , G.OPT_GRP_NM OPT_GRP_NM -- �ɼǱ׷��
         , TO_CHAR(R.MIN_CNT)  MIN_CNT -- �ּҼ��ü�
         , TO_CHAR(R.MAX_CNT)  MAX_CNT -- �ִ뼱�ü�
         , R.USE_YN     USE_YN -- ��뿩��
         , TO_CHAR(R.UPD_DT, 'YYYYMMDDHH24MISS') UPD_DT -- �����Ͻ�
      FROM ITEM_OPTION_RULE R,
           OPTION_GRP       G
     WHERE R.COMP_CD   = G.COMP_CD
       AND R.BRAND_CD  = G.BRAND_CD
       AND R.OPT_GRP   = G.OPT_GRP
       AND R.COMP_CD   = P_COMP_CD
       AND R.BRAND_CD  = P_BRAND_CD
       AND R.UPD_DT   >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
       AND R.USE_YN LIKE P_USE_YN;
       
    anRetVal := 1 ;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_14 ;
  
  --------------------------------------------------------------------------------
  --  Description      : POS������ ���ſ� (��ǰ�� ���� ������)
  -- Ref. Table        : GIFT_CODE_MST
  --------------------------------------------------------------------------------
  --  Create Date      : 2009-12-15
  --  Modify Date      : 2009-12-15
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_15 (
    anRetVal OUT NUMBER,   -- ����ڵ�
    asRetMsg OUT VARCHAR2, -- ���� �޽���
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT G.GIFT_CD     GIFT_CD        -- ��ǰ�� �ڵ�
         , G.GIFT_NM     GIFT_NM        -- ��ǰ�� ��Ī
         , NVL(G.PRICE, 0) GIFT_AMT     -- ��ǰ�� �ݾ�
         , G.APPR_YN     APP_YN         -- ���� ����
         , NVL(G.MAND_YN, 'N') MAND_YN  -- �ݾ��Է¿���[YN]
         , G.BTN_BCL     BTN_BCL        -- ��ư ����
         , G.BTN_FCL     BTN_FCL        -- ��ư ���ڻ�
         , NVL(G.POINT_YN, 'N') POINT_YN -- ����Ʈ ��������[YN]
         , G.USE_YN      USE_YN         -- ��� ����
         , TO_CHAR(G.UPD_DT, 'YYYYMMDDHH24MISS') UPD_DT -- �����Ͻ�
         , G.CHANGE_STD_DIV
         , G.CHANGE_STD_VALUE
         , G.GIFT_PUB_DIV
         , G.GIFT_LCD
         , G.DC_DIV
         , G.ITEM_CD
      FROM GIFT_CODE_MST G
     WHERE COMP_CD   = P_COMP_CD
       AND UPD_DT   >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
       AND USE_YN LIKE P_USE_YN;
       
    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_15;
  
  --------------------------------------------------------------------------------
  --  Description      : POS������ ���ſ� (��Ÿ�����)
  -- Ref. Table        : ACC_MST
  --------------------------------------------------------------------------------
  --  Create Date      : 2009-12-15
  --  Modify Date      : 2009-12-15
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_16 (
    anRetVal OUT NUMBER,   -- ����ڵ�
    asRetMsg OUT VARCHAR2, -- ���� �޽���
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT A.ETC_CD    ETC_CD  -- ����ݰ����ڵ�
         , A.ETC_NM    ETC_NM  -- ����ݰ�����Ī
         , A.ETC_DIV   ETC_DIV -- ����� ����   =>  [01:�Աݰ���, 02:��ݰ���]
         , A.ACC_CD    ACC_CD  -- �����ڵ�
         , NVL(A.POS_USE_YN, 'N')   POS_USE_YN -- ������뿩��  => Y:���, N:�̻��
         , NVL(A.PURCHASE_DIV, '0') PURCHASE_DIV -- ����ó�Է±��� => ����(01475) [0:���Է�, 1:��, 2:����ó]
         , A.USE_YN    USE_YN -- ��� ����
         , TO_CHAR(A.UPD_DT, 'YYYYMMDDHH24MISS') UPD_DT -- �����Ͻ�
      FROM ACC_MST A
     WHERE A.UPD_DT   >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
       AND A.COMP_CD   = P_COMP_CD
       AND A.STOR_TP   = P_STOR_TP
       AND A.USE_YN LIKE P_USE_YN;
       
    anRetVal := 1 ;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_16;
  
  --------------------------------------------------------------------------------
  --  Description      : POS������ ���ſ� (��Ÿ����� ����)
  -- Ref. Table        : ACC_RMK
  --------------------------------------------------------------------------------
  --  Create Date      : 2016-07-13
  --  Modify Date      : 2016-07-13
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_17 (
    anRetVal OUT NUMBER,   -- ����ڵ�
    asRetMsg OUT VARCHAR2, -- ���� �޽���
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT  A.ETC_CD        -- ����ݰ����ڵ�
         ,  A.RMK_SEQ       -- �������
         ,  A.RMK_NM        -- �����
         ,  A.RMK_DESC      -- ���伳��
         ,  A.SORT_SEQ      -- ���ļ���
         ,  A.USE_YN        -- ��� ����
         ,  TO_CHAR(A.INST_DT, 'YYYYMMDDHH24MISS')  AS INST_DT  -- ����Ͻ�
         ,  A.INST_USER                                         -- �����
         ,  TO_CHAR(A.UPD_DT, 'YYYYMMDDHH24MISS')   AS UPD_DT   -- �����Ͻ�
         ,  A.UPD_USER                                          -- ������
      FROM  ACC_RMK A
     WHERE  A.COMP_CD   = P_COMP_CD
       AND  A.STOR_TP   = P_STOR_TP
       AND  A.USE_YN LIKE P_USE_YN
       AND  A.UPD_DT   >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS');
       
    anRetVal := 1 ;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_17;
  
  --------------------------------------------------------------------------------
  --  Description      : POS������ ���ſ�       (��з�)
  -- Ref. Table        : ITEM_L_CLASS
  --------------------------------------------------------------------------------
  --  Create Date      : 2009-12-30
  --  Create Programer : ���μ�
  --  Modify Date      : 2009-12-30
  --  Modify Programer :
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_26 (
    anRetVal OUT NUMBER,   -- ����ڵ�
    asRetMsg OUT VARCHAR2, -- ���� �޽���
    p_cursor OUT rec_set.m_refcur 
  ) IS
    lnCnt Number(5) := 0 ;
  BEGIN
    OPEN p_cursor FOR
    SELECT I.L_CLASS_CD
         , I.L_CLASS_NM
         , I.USE_YN
         , TO_CHAR(I.UPD_DT, 'YYYYMMDDHH24MISS') UPD_DT -- �����Ͻ�
      FROM ITEM_L_CLASS I
     WHERE I.COMP_CD      = P_COMP_CD
       AND I.ORG_CLASS_CD = '00'
       AND I.UPD_DT      >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
       AND I.USE_YN    LIKE P_USE_YN;
       
    anRetVal := 1 ;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE ;
  END GET_MASTER_26;
  
  --------------------------------------------------------------------------------
  --  Description      : POS������ ���ſ�       (�ߺз�)
  -- Ref. Table        : ITEM_M_CLASS
  --------------------------------------------------------------------------------
  --  Create Date      : 2009-12-30
  --  Modify Date      : 2009-12-30
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_27 (
    anRetVal OUT NUMBER,   -- ����ڵ�
    asRetMsg OUT VARCHAR2, -- ���� �޽���
    p_cursor OUT rec_set.m_refcur
  ) IS
    lnCnt Number(5) := 0 ;
  BEGIN
    OPEN p_cursor FOR
    SELECT I.L_CLASS_CD
         , I.M_CLASS_CD
         , I.M_CLASS_NM
         , I.USE_YN
         , TO_CHAR(I.UPD_DT, 'YYYYMMDDHH24MISS') UPD_DT -- �����Ͻ�
         , C.BTN_COLOR
      FROM ITEM_M_CLASS        I
         , ITEM_M_CLASS_COLOR  C
     WHERE I.COMP_CD      = C.COMP_CD(+)
       AND I.ORG_CLASS_CD = C.ORG_CLASS_CD(+)
       AND I.L_CLASS_CD   = C.L_CLASS_CD(+)
       AND I.M_CLASS_CD   = C.M_CLASS_CD(+)
       AND I.COMP_CD      = P_COMP_CD
       AND I.ORG_CLASS_CD = '00'
       AND I.UPD_DT   >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
       AND I.USE_YN LIKE P_USE_YN;
       
      anRetVal := 1;
      asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_27;
  
  --------------------------------------------------------------------------------
  --  Description      : POS������ ���ſ�       (�Һз�)
  -- Ref. Table        : ITEM_S_CLASS
  --------------------------------------------------------------------------------
  --  Create Date      : 2009-12-30
  --  Modify Date      : 2009-12-30
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_28 (
    anRetVal OUT NUMBER,   -- ����ڵ�
    asRetMsg OUT VARCHAR2, -- ���� �޽���
    p_cursor OUT rec_set.m_refcur
  ) IS
    lnCnt Number(5) := 0 ;
  BEGIN
    OPEN p_cursor FOR
    SELECT I.L_CLASS_CD
         , I.M_CLASS_CD
         , I.S_CLASS_CD
         , I.S_CLASS_NM
         , I.USE_YN
         , TO_CHAR(I.UPD_DT, 'YYYYMMDDHH24MISS') UPD_DT -- �����Ͻ�
      FROM ITEM_S_CLASS I
     WHERE I.COMP_CD      = P_COMP_CD
       AND I.ORG_CLASS_CD = '00'
       AND I.UPD_DT   >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
       AND I.USE_YN LIKE P_USE_YN;
       
      anRetVal := 1 ;
      asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_28;
  
  --------------------------------------------------------------------------------
  --  Description      : POS������ ���ſ�       (�ֹ��ǰ����)
  -- Ref. Table        : PLU_AMT_STORE
  --------------------------------------------------------------------------------
  --  Create Date      : 2010-12-07
  --  Modify Date      : 2010-12-07
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_29 (
    anRetVal OUT NUMBER,   -- ����ڵ�
    asRetMsg OUT VARCHAR2, -- ���� �޽���
    p_cursor OUT rec_set.m_refcur
  ) IS
    lnCnt Number(5) := 0 ;
  BEGIN
    OPEN p_cursor FOR
    SELECT ITEM_CD,
           REPLACE(REPLACE(KITCHEN_INFO, CHR(13), '@'), CHR(10), '$') KITCHEN_INFO,
           USE_YN,
           TO_CHAR(UPD_DT, 'YYYYMMDDHH24MISS') UPD_DT -- �����Ͻ�
     FROM ITEM_KITCHEN
    WHERE COMP_CD   = P_COMP_CD
      AND BRAND_CD  = P_BRAND_CD
      AND UPD_DT   >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
      AND USE_YN LIKE P_USE_YN;
      
    anRetVal := 1 ;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_29 ;
  
  --------------------------------------------------------------------------------
  --  Description      : POS������ ���ſ� (��Ʈ ����ǰ ����)
  -- Ref. Table        : SET_RULE, SET_RULE_STORE
  --------------------------------------------------------------------------------
  --  Create Date      : 2011-12-30
  --  Modify Date      : 2011-12-30
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_31 (
    anRetVal OUT NUMBER,   -- ����ڵ�
    asRetMsg OUT VARCHAR2, -- ���� �޽���
    p_cursor OUT rec_set.m_refcur
  ) IS
    lnCnt NUMBER(3) := 0;
  BEGIN
   
   OPEN p_cursor FOR
   SELECT BRAND_CD -- ��������
        , P_STOR_CD -- �����ڵ�
        , ITEM_CD -- ��ǰ�ڵ�
        , SEQ -- ����
        , GRP_DIV -- �׷�/��ǰ ���� => 0-��ǰ, 1-�׷�
        , OPTN_ITEM_CD -- �ɼǱ׷�/��ǰ�ڵ�
        , MIN_QTY -- ���ؼ���
        , SALE_PRC -- ���شܰ�
        , SALE_AMT -- ���رݾ�
        , ADJ_METHOD -- �ݾ������������
        , REPLACEABLE -- ǰ���ü��뿩�� => [N-��ü�Ұ�,Y-��ü���]
        , SORT_ORD -- �������
        , MANDT_DIV -- �ʼ����� => [0-�ɼ�, 1-�ʼ�]
        , USE_YN -- ��뿩��
        , START_DT
        , CLOSE_DT
     FROM SET_RULE
    WHERE COMP_CD = P_COMP_CD
      AND BRAND_CD = P_BRAND_CD
      AND UPD_DT >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
      AND USE_YN LIKE P_USE_YN;
    
    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_31 ;
  
  --------------------------------------------------------------------------------
  --  Description      : POS������ ���ſ� (�ֹ���� ������ ��ǰ(����))
  -- Ref. Table        : STORE_ITEM_PRT_MULTI
  --------------------------------------------------------------------------------
  --  Create Date      : 2014-04-20
  --  Modify Date      : 2014-04-20
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_32 (
    anRetVal OUT NUMBER,   -- ����ڵ�
    asRetMsg OUT VARCHAR2, -- ���� �޽���
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT  BRAND_CD
         ,  STOR_CD
         ,  PRT_NO
         ,  ITEM_CD
         ,  USE_YN
         ,  UPD_DT
      FROM  (
                SELECT  BRAND_CD                -- ��������
                     ,  P_STOR_CD   AS STOR_CD  -- �����ڵ�
                     ,  PRT_NO                  -- �����͹�ȣ
                     ,  ITEM_CD                 -- ��ǰ�ڵ�
                     ,  USE_YN                  -- �������
                     ,  TO_CHAR(UPD_DT, 'YYYYMMDDHH24MISS') UPD_DT -- �����Ͻ�
                  FROM  ITEM_PRT_MULTI
                 WHERE  COMP_CD  = P_COMP_CD
                   AND  BRAND_CD = P_BRAND_CD
                   AND  UPD_DT  >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
                   AND  USE_YN LIKE P_USE_YN
                UNION
                SELECT  BRAND_CD      BRAND_CD -- ��������
                     ,  STOR_CD       STOR_CD -- �����ڵ�
                     ,  PRT_NO        PRT_NO -- �����͹�ȣ
                     ,  ITEM_CD       ITEM_CD -- ��ǰ�ڵ�
                     ,  USE_YN        USE_YN -- �������
                     ,  TO_CHAR(UPD_DT, 'YYYYMMDDHH24MISS') UPD_DT -- �����Ͻ�
                  FROM  STORE_ITEM_PRT_MULTI
                 WHERE  COMP_CD   = P_COMP_CD
                   AND  BRAND_CD  = P_BRAND_CD
                   AND  STOR_CD   = P_STOR_CD
                   AND  UPD_DT   >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
                   AND  USE_YN LIKE P_USE_YN
            )
     ORDER  BY UPD_DT;
     
    anRetVal := 1 ;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_32;
  
  --------------------------------------------------------------------------------
  --  Description      : POS������ ���ſ� (��ǰ�з�(��������))
  -- Ref. Table        : ITEM_CLASS
  --------------------------------------------------------------------------------
  --  Create Date      : 2014-08-18
  --  Modify Date      : 2014-08-18
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_33 (
    anRetVal OUT NUMBER,   -- ����ڵ�
    asRetMsg OUT VARCHAR2, -- ���� �޽���
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT  IC.ORG_CLASS_CD
         ,  IC.ITEM_CD
         ,  IC.L_CLASS_CD
         ,  IC.M_CLASS_CD
         ,  IC.S_CLASS_CD
         ,  IC.USE_YN
         ,  TO_CHAR(IC.UPD_DT, 'YYYYMMDDHH24MISS')  UPD_DT -- �����Ͻ�
      FROM COMMON       C
         , ITEM_CLASS   IC
     WHERE C.COMP_CD    = IC.COMP_CD
       AND C.CODE_CD    = IC.ORG_CLASS_CD
       AND C.CODE_TP    = '01020'
       AND C.COMP_CD    = P_COMP_CD
       AND C.USE_YN     = 'Y'
       AND C.VAL_C1     IS NOT NULL
       AND IC.UPD_DT    >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
       AND IC.USE_YN    LIKE P_USE_YN
     ORDER BY UPD_DT;
     
    anRetVal := 1 ;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_33;
  
  --------------------------------------------------------------------------------
  --  Description      : POS������ ���ſ�       (����� ������)
  -- Ref. Table        : STORE_USER
  --------------------------------------------------------------------------------
  --  Create Date      : 2009-12-23
  --  Modify Date      : 2009-12-23
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_50 (
    anRetVal OUT NUMBER,   -- ����ڵ�
    asRetMsg OUT VARCHAR2, -- ���� �޽���
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    
  IF P_COMP_CD <> '012' THEN
        -- ��������� ����(����)
        OPEN p_cursor FOR
            SELECT  SU.BRAND_CD     BRAND_CD    -- ��������
                  , SU.STOR_CD      STOR_CD     -- �����ڵ�
                  , SU.USER_ID      USER_ID     -- ����� �ڵ�
                  , SU.ROLE_DIV     CASHIER_DIV -- ���� (����� ����)
                  , SU.USER_NM      USER_NM     -- �����
                  , SU.EMP_DIV      CASHIER_AL  -- �������� (����� ����)
                  , SU.POS_PWD      CASHIER_PD  -- POS ��й�ȣ
                  , SU.WEB_PWD      WEB_PWD     -- ����й�ȣ
                  , 'N'             NIGHT_YN    -- �߰��ٹ�����
                  , '2'             AUTH_CD     -- �������� (���� level)
                  , SU.MNG_CARD_ID  MSR_NO      -- ���� ī���ȣ
                  , SU.REJECT_PWD   REJECT_PWD  -- ��ǰ��й�ȣ
                  , CASE WHEN ST.STOR_TP IN ('10','20') THEN SU.USE_YN ELSE 'N' END AS USE_YN    -- ��� ����
                  , TO_CHAR(SU.UPD_DT, 'YYYYMMDDHH24MISS')                          AS UPD_DT    -- �����Ͻ�
                  , NVL(AP.BASIC_PAY, 0)                                            AS BASIC_PAY -- �⺻�޿�
            FROM    STORE_USER SU
                  , STORE      ST
                  ,(
                    SELECT  COMP_CD
                          , BRAND_CD
                          , STOR_CD
                          , USER_ID
                          , BASIC_PAY
                          , ROW_NUMBER() OVER(PARTITION BY COMP_CD, BRAND_CD, STOR_CD, USER_ID ORDER BY ATTD_PAY_DT DESC) R_NUM
                    FROM    STORE_PAY_MST
                    WHERE   COMP_CD      = P_COMP_CD
                    --AND     BRAND_CD     = P_BRAND_CD
                    --AND     STOR_CD      = P_STOR_CD
                    AND     ATTD_PAY_DIV = '1' -- �ñ�
                    AND     ATTD_PAY_DT <= SUBSTR(P_DOWN_DTM, 1, 8)
                   ) AP
            WHERE   SU.COMP_CD   = ST.COMP_CD
            AND     SU.BRAND_CD  = ST.BRAND_CD
            AND     SU.STOR_CD   = ST.STOR_CD
            AND     SU.COMP_CD   = AP.COMP_CD (+)
            AND     SU.BRAND_CD  = AP.BRAND_CD(+)
            AND     SU.STOR_CD   = AP.STOR_CD (+)
            AND     SU.USER_ID   = AP.USER_ID (+)
            AND     1            = AP.R_NUM   (+)
            AND     SU.COMP_CD   = P_COMP_CD
            --AND     SU.BRAND_CD  = P_BRAND_CD
            --AND     SU.STOR_CD   = P_STOR_CD
            AND     SU.UPD_DT   >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
            AND     SU.USE_YN LIKE P_USE_YN;
    ELSE
        -- �𽺹��ſ�
        OPEN p_cursor FOR
        SELECT BRAND_CD    BRAND_CD    -- ��������
             , STOR_CD     STOR_CD     -- �����ڵ�
             , USER_ID     USER_ID     -- ����� �ڵ�
             , ROLE_DIV    CASHIER_DIV -- ���� (����� ����)
             , USER_NM     USER_NM     -- �����
             , EMP_DIV     CASHIER_AL  -- �������� (����� ����)
             , POS_PWD     CASHIER_PD  -- POS ��й�ȣ
             , WEB_PWD     WEB_PWD     -- ����й�ȣ
             , 'N'         NIGHT_YN    -- �߰��ٹ�����
             , '2'         AUTH_CD     -- �������� (���� level)
             , MNG_CARD_ID MSR_NO      -- ���� ī���ȣ
             , REJECT_PWD  REJECT_PWD  -- ��ǰ��й�ȣ
             , USE_YN      USE_YN      -- ��� ����
             , TO_CHAR(UPD_DT, 'YYYYMMDDHH24MISS') UPD_DT -- �����Ͻ�
          FROM STORE_USER
         WHERE COMP_CD   = P_COMP_CD
           AND BRAND_CD  = P_BRAND_CD
           AND STOR_CD   = P_STOR_CD
           AND UPD_DT   >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
           AND USE_YN LIKE P_USE_YN
        UNION ALL
        SELECT P_BRAND_CD  BRAND_CD    -- ��������
             , P_STOR_CD   STOR_CD     -- �����ڵ�
             , USER_ID     USER_ID     -- ����� �ڵ�
             , '01'        CASHIER_DIV -- ���� (����� ����)
             , USER_NM     USER_NM     -- �����
             , '0'         CASHIER_AL  -- �������� (����� ����)
             , PWD         CASHIER_PD  -- POS ��й�ȣ
             , PWD         WEB_PWD     -- �� ��й�ȣ
             , 'N'         NIGHT_YN    -- �߰��ٹ�����
             , '2'         AUTH_CD     -- �������� (���� level)
             , NULL        MSR_NO      -- ���� ī���ȣ
             , PWD         REJECT_PWD  -- ��ǰ��й�ȣ
             , USE_YN      USE_YN      -- ��� ����
             , TO_CHAR(UPD_DT, 'YYYYMMDDHH24MISS') UPD_DT -- �����Ͻ�
          FROM HQ_USER
         WHERE COMP_CD   = P_COMP_CD
           AND BRAND_CD  = P_BRAND_CD
           AND UPD_DT   >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
           AND USE_YN LIKE P_USE_YN;
    END IF;
    
    anRetVal := 1 ;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_50 ;
  
  --------------------------------------------------------------------------------
  --  Description      : POS������ ���ſ�       (ī��� ������ )
  -- Ref. Table        : CARD
  --------------------------------------------------------------------------------
  --  Create Date      : 2009-12-24
  --  Modify Date      : 2009-12-24
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_52 (
    anRetVal OUT NUMBER,   -- ����ڵ�
    asRetMsg OUT VARCHAR2, -- ���� �޽���
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT M.CARD_DIV CARD_DIV  -- ī��� ����
         , M.CARD_CD  CARD_CD   -- ī��� �ڵ�
         , M.CARD_NM  CARD_NM   -- ī��� ��Ī
         , NVL(M.CARD_FEE, 0) CARD_FEE -- ��������
         , M.BUSI_NO  BUSI_NO   -- ����ڹ�ȣ
         , M.TEL_NO   TEL_NO    -- ī��� ��ȭ��ȣ
         , ''         VAN_CD    -- VAN�� ���� �ڵ� (���� ���� �� ��)
         , ''         V_CARD_CD -- ī��� ��Ī�ڵ� (���� ���� �� ��)
         , M.HOMEPAGE HOMEPAGE  -- ����,�Է±׷����
         , M.USE_YN   USE_YN    -- ��� ����
         , TO_CHAR(M.UPD_DT, 'YYYYMMDDHH24MISS') UPD_DT -- �����Ͻ�
      FROM CARD M
     WHERE COMP_CD   = P_COMP_CD
       AND UPD_DT   >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
       AND USE_YN LIKE P_USE_YN;
       
    anRetVal := 1 ;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE ;
  END GET_MASTER_52 ;
  
  --------------------------------------------------------------------------------
  --  Description      : POS������ ���ſ�       (ī��� PREFIX )
  -- Ref. Table        : CARDMB_PREFIX
  --------------------------------------------------------------------------------
  --  Create Date      : 2009-12-24
  --  Modify Date      : 2009-12-24
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_53 (
    anRetVal OUT NUMBER,   -- ����ڵ�
    asRetMsg OUT VARCHAR2, -- ���� �޽���
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT PFX_CD      PFX_CD -- PK.PREFIX �ڵ�
         , CARD_DIV    CARD_DIV -- ī�屸�� => ����(01095) [C:�ſ�ī��, L:LG, H:HP, S: SK]
         , PFX_NM      PFX_NM -- PREFIX��
         , NVL(POSITION, 0)      POSITION -- ��ġ
         , CHECK_VAL   CHECK_VAL -- üũ��
         , CARD_CD     CARD_CD -- ī����ڵ� => CARD ���̺� ����
         , BANK_CD     BANK_CD -- �����ڵ� => ����(00615)
         , COOP_CARD   COOP_CARD -- ����ī�屸�� => ����(00450) [CC:���ǽ���, CK:���ǽ���üũ, KC: ���Ǳ���,  KK:���Ǳ���üũ, LC:���ǷԵ�, LK:���ǷԵ�üũ, HC:�Ϲ�����ī��]
         , USE_YN      USE_YN -- ��� ����
         , TO_CHAR(UPD_DT, 'YYYYMMDDHH24MISS') UPD_DT -- �����Ͻ�
      FROM CARDMB_PREFIX
     WHERE COMP_CD   = P_COMP_CD
       AND UPD_DT   >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
       AND USE_YN LIKE P_USE_YN;
       
    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_53 ;
  
  --------------------------------------------------------------------------------
  --  Description      : POS������ ���ſ�       (�����ڵ� )
  -- Ref. Table        : COMMON
  --------------------------------------------------------------------------------
  --  Create Date      : 2009-12-24
  --  Modify Date      : 2009-12-24
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_54 (
    anRetVal OUT NUMBER,   -- ����ڵ�
    asRetMsg OUT VARCHAR2, -- ���� �޽���
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
      OPEN p_cursor FOR
      WITH TP AS (
        SELECT CODE_CD AS CODE_TP
          FROM COMMON
         WHERE COMP_CD  = P_COMP_CD
           AND CODE_TP    = '00000'
           AND POS_IF_YN  = 'Y'
           AND USE_YN  LIKE P_USE_YN
      )
      SELECT C.CODE_TP AS CODE_TP   -- PK.�����ڵ�Ÿ��
           , C.CODE_CD AS CODE_CD   -- PK.�����ڵ�
           , C.CODE_NM AS CARD_NM   -- �����Ī
           , C.BRAND_CD AS BRAND_CD -- ��������
           , C.VAL_D1 AS VAL_D1 -- ��¥1
           , C.VAL_D2 AS VAL_D2 -- ��¥2
           , C.VAL_C1 AS VAL_C1 -- ����1
           , C.VAL_C2 AS VAL_C2 -- ����2
           , C.VAL_N1 AS VAL_N1 -- ����1
           , C.VAL_N2 AS VAL_N2 -- ����2
           , C.REMARKS AS REMARKS -- ���
           , C.USE_YN AS USE_YN -- ��� ����
           , TO_CHAR(C.UPD_DT, 'YYYYMMDDHH24MISS') AS UPD_DT -- �����Ͻ�
        FROM COMMON C,
             TP     G
       WHERE C.CODE_TP = G.CODE_TP
         AND C.UPD_DT >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
         AND C.COMP_CD = P_COMP_CD;
         
    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_54;
  
  --------------------------------------------------------------------------------
  --  Description      : POS������ ���ſ�       (VAN, ī�� ���� )
  -- Ref. Table        : CAT ID, VAN, COMMON
  --------------------------------------------------------------------------------
  --  Create Date      : 2009-12-24
  --  Modify Date      : 2009-12-24
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_57 (
    anRetVal OUT  NUMBER , -- ����ڵ�
    asRetMsg OUT VARCHAR2, -- ���� �޽���
    p_cursor OUT rec_set.m_refcur
  ) IS
    lsBusiNo STORE.BUSI_NO%TYPE;
    lsKorailYn STORE_SETUP.KORAIL_APPR_YN%TYPE;
  BEGIN

    SELECT BUSI_NO
      INTO lsBusiNo
      FROM STORE
     WHERE COMP_CD  = P_COMP_CD
       AND BRAND_CD = P_BRAND_CD
       AND STOR_CD  = P_STOR_CD;
    BEGIN
      SELECT KORAIL_APPR_YN
        INTO lsKorailYn
        FROM STORE_SETUP
       WHERE COMP_CD  = P_COMP_CD
         AND BRAND_CD = P_BRAND_CD
         AND STOR_CD  = P_STOR_CD;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
           lsKorailYn := 'N';
    END;
    
    OPEN p_cursor FOR
    WITH CM AS (
      SELECT CODE_CD ,
             DECODE(USE_YN, 'Y', '1', 'N', '0') AS USE_YN ,
             ACC_CD ,
             VAL_C1 ,
             VAL_C2 ,
             VAL_C3 ,
             VAL_C4 ,
             VAL_C5 ,
             VAL_N1
        FROM COMMON
       WHERE COMP_CD  = P_COMP_CD
         AND CODE_TP = '00550'
    )
    SELECT 'INTERFACEINFO' ,
           FLAG_NM ,
           FLAG_VAL
      FROM (WITH VA AS (
              SELECT V.VAN_CD AS VAN_CD ,
                     DECODE(I.USE_YN, 'Y', '1', 'N', '0') AS USE_YN ,
                     V.IP AS IP ,
                     V.PORT AS PORT ,
                     NVL(I.CAT_ID , '') AS CAT_ID ,
                     NVL(I.CAT_PWD, '') AS CAT_PWD ,
                     C.CODE_CD AS CODE_CD
                FROM VAN V ,
                     CM  C ,
                     (SELECT *
                       FROM CATID
                      WHERE COMP_CD  = P_COMP_CD
                        AND BRAND_CD = P_BRAND_CD
                        AND STOR_CD  = P_STOR_CD
                     ) I
               WHERE V.VAN_CD = C.VAL_C1
                 AND V.VAN_CD = I.VAN_CD(+)
            )
            SELECT 'VAN_KIND' AS FLAG_NM,
                   VAL_C1     AS FLAG_VAL
              FROM CM
             WHERE CODE_CD = '01'
            UNION ALL
            SELECT 'VAN_DIV' AS FLAG_NM ,
                   VAL_C1 AS FLAG_VAL
              FROM CM
             WHERE CODE_CD = '02'
            UNION ALL
            SELECT DECODE(LEVEL, 1, 'CARD_APPR_DIV' , 2, 'CARD_IP', 3, 'CARD_PORT', 4, 'CARD_ID') AS FLAG_NM -- ������ : CARD_ID
                 , DECODE(LEVEL, 1, NVL(USE_YN, '0'), 2, IP , 3, PORT , 4, CAT_ID ) AS FLAG_VAL
              FROM (SELECT *
                      FROM VA
                     WHERE CODE_CD = '10'
                   ) CONNECT BY LEVEL < 5
            UNION ALL
            SELECT DECODE(LEVEL, 1, 'KORAIL_APPR_DIV', 2, 'KORAIL_IP', 3, 'KORAIL_PORT', 4, 'KORAIL_ID') AS FLAG_NM -- ������ : KORAIL_ID
                 , DECODE(LEVEL, 1, lsKorailYn , 2, IP , 3, PORT , 4, CAT_ID ) AS FLAG_VAL
              FROM (SELECT *
                      FROM VA
                     WHERE CODE_CD = '11'
                   ) CONNECT BY LEVEL < 5
            UNION ALL
            SELECT DECODE(LEVEL, 1, 'GIFTCON_DIV' , 2, 'GIFTCON_IP', 3, 'GIFTCON_PORT', 4, 'GIFTCON_ID') AS FLAG_NM -- ������ : GIFTCON_ID
                 , DECODE(LEVEL, 1, NVL(USE_YN, '0'), 2, IP , 3, PORT , 4, CAT_ID ) AS FLAG_VAL
              FROM (SELECT *
                      FROM VA
                     WHERE CODE_CD = '12'
                   ) CONNECT BY LEVEL < 5
            UNION ALL
            SELECT DECODE(LEVEL, 1, 'GIFTSHOW_DIV' , 2, 'GIFTSHOW_IP', 3, 'GIFTSHOW_PORT', 4, 'GIFTSHOW_ID') AS FLAG_NM -- ������ : GIFTSHOW_ID
                 , DECODE(LEVEL, 1, NVL(USE_YN, '0'), 2, IP , 3, PORT , 4, CAT_ID ) AS FLAG_VAL
              FROM (SELECT *
                      FROM VA
                     WHERE CODE_CD = '13'
                   ) CONNECT BY LEVEL < 5
            UNION ALL
            SELECT DECODE(LEVEL, 1, 'HARTCON_DIV' , 2, 'HARTCON_IP', 3, 'HARTCON_PORT', 4, 'HARTCON_ID') AS FLAG_NM -- ������ : HARTCON_ID
                 , DECODE(LEVEL, 1, NVL(USE_YN, '0'), 2, IP , 3, PORT , 4, CAT_ID ) AS FLAG_VAL
              FROM (SELECT *
                      FROM VA
                     WHERE CODE_CD = '14'
                   ) CONNECT BY LEVEL < 5
            UNION ALL
            SELECT DECODE(LEVEL, 1, 'SAMSUNCON_DIV' , 2, 'SAMSUNCON_IP', 3, 'SAMSUNCON_PORT', 4, 'SAMSUNCON_ID') AS FLAG_NM -- ������ : SAMSUNCON_ID
                 , DECODE(LEVEL, 1, NVL(USE_YN, '0'), 2, IP , 3, PORT , 4, CAT_ID ) AS FLAG_VAL
              FROM (SELECT *
                      FROM VA
                     WHERE CODE_CD = '15'
                   ) CONNECT BY LEVEL < 5
            UNION ALL
            SELECT DECODE(LEVEL, 1, 'QPCON_DIV' , 2, 'QPCON_IP', 3, 'QPCON_PORT', 4, 'QPCON_ID') AS FLAG_NM -- ������ : QPCON_ID
                 , DECODE(LEVEL, 1, NVL(USE_YN, '0'), 2, IP , 3, PORT , 4, CAT_ID ) AS FLAG_VAL
              FROM (SELECT *
                      FROM VA
                     WHERE CODE_CD = '16'
                   ) CONNECT BY LEVEL < 5
            UNION ALL
            SELECT DECODE(LEVEL, 1, 'HPYCON_DIV' , 2, 'HPYCON_IP', 3, 'HPYCON_PORT', 4, 'HPYCON_ID') AS FLAG_NM -- ������ : HPYCON_ID
                 , DECODE(LEVEL, 1, NVL(USE_YN, '0'), 2, IP , 3, PORT , 4, CAT_ID ) AS FLAG_VAL
              FROM (SELECT *
                      FROM VA
                     WHERE CODE_CD = '17'
                   ) CONNECT BY LEVEL < 5
            UNION ALL
            SELECT DECODE(LEVEL, 1, 'OCB_DIV' , 2, 'OCB_BSID', 3, 'OCB_NO', 4, 'OCB_PS' ) AS FLAG_NM -- ������ : OCB_BSID, OCB_NO, OCB_PS
                 , DECODE(LEVEL, 1, NVL(USE_YN, '0'), 2, lsBusiNo , 3, CAT_ID , 4, CAT_PWD ) AS FLAG_VAL
              FROM (SELECT *
                      FROM VA
                     WHERE CODE_CD = '18'
                   ) CONNECT BY LEVEL < 5
            UNION ALL
            SELECT DECODE(LEVEL, 1, 'HPYPP_DIV' , 2, 'HPYPP_IP', 3, 'HPYPP_PORT', 4, 'HPYPP_ID') AS FLAG_NM -- ������ : HPYPP_ID
                 , DECODE(LEVEL, 1, NVL(USE_YN, '0'), 2, IP , 3, PORT , 4, CAT_ID ) AS FLAG_VAL
              FROM (SELECT *
                      FROM VA
                     WHERE CODE_CD = '19'
                   ) CONNECT BY LEVEL < 5
            UNION ALL
            SELECT DECODE(LEVEL, 1, 'GIFT_DIV' , 2, 'GIFT_IP', 3, 'GIFT_PORT', 4, 'GIFT_ID') AS FLAG_NM -- ������ : GIFT_ID
                 , DECODE(LEVEL, 1, NVL(USE_YN, '0') , 2, VAL_C2 , 3, VAL_N1 , 4, '' ) AS FLAG_VAL
              FROM (SELECT *
                      FROM CM
                     WHERE CODE_CD = '20'
                   ) CONNECT BY LEVEL < 5
            UNION ALL
            SELECT DECODE(LEVEL, 1, 'EMPDC_DIV' , 2, 'EMPDC_IP', 3, 'EMPDC_PORT', 4, 'EMPDC_ID') AS FLAG_NM -- ������ : EMPDC_ID
                 , DECODE(LEVEL, 1, NVL(USE_YN, '0'), 2, VAL_C1 , 3, VAL_N1 , 4, '' ) AS FLAG_VAL
              FROM (SELECT *
                      FROM CM
                     WHERE CODE_CD = '21'
                   ) CONNECT BY LEVEL < 5
            UNION ALL
            SELECT DECODE(LEVEL, 1, 'PREPAY_DIV' , 2, 'PREPAY_IP', 3, 'PREPAY_PORT', 4, 'PREPAY_ID') AS FLAG_NM -- ������ : PREPAY_ID
                 , DECODE(LEVEL, 1, NVL(USE_YN, '0'), 2, VAL_C1 , 3, VAL_N1 , 4, '' ) AS FLAG_VAL
              FROM (SELECT *
                      FROM CM
                     WHERE CODE_CD = '22'
                   ) CONNECT BY LEVEL < 5
            UNION ALL
            SELECT DECODE(LEVEL, 1, 'KAKAO_DIV' , 2, 'KAKAO_IP', 3, 'KAKAO_PORT', 4, 'KAKAO_ID') AS FLAG_NM -- ������ :īī����
                 , DECODE(LEVEL, 1, NVL(USE_YN, '0'), 2, VAL_C1 , 3, VAL_N1 , 4, '' ) AS FLAG_VAL
              FROM (SELECT *
                      FROM CM
                     WHERE CODE_CD = '23'
                   ) CONNECT BY LEVEL < 5
            UNION ALL
            SELECT DECODE(LEVEL, 1, 'M12_DIV' , 2, 'M12_IP', 3, 'M12_PORT', 4, 'M12_ID') AS FLAG_NM -- ������ :M12
                 , DECODE(LEVEL, 1, NVL(USE_YN, '0'), 2, IP , 3, PORT , 4, CAT_ID ) AS FLAG_VAL
              FROM (SELECT *
                      FROM VA
                     WHERE CODE_CD = '24'
                   ) CONNECT BY LEVEL < 5
            UNION ALL
            SELECT DECODE(LEVEL, 1, 'WMP_DIV'       , 2, 'WMP_COMP_ID', 3, 'WMP_IP', 4, 'WMP_PORT') AS FLAG_NM        -- ����������
                 , DECODE(LEVEL, 1, NVL(USE_YN, '0'), 2, PARA_VAL     , 3, VAL_C2  , 4, VAL_N1    ) AS FLAG_VAL
              FROM (SELECT *
                      FROM CM   C
                         , (
                                SELECT  NVL(PC.PARA_VAL, PM.PARA_DEFAULT)   AS PARA_VAL
                                  FROM  PARA_MST        PM
                                     ,  PARA_COMPANY    PC
                                 WHERE  PM.PARA_CD      = PC.PARA_CD(+)
                                   AND  PM.PARA_TABLE   = 'PARA_COMPANY'
                                   AND  PM.PARA_CD      = '2004'
                                   AND  PM.USE_YN       = 'Y'
                                   AND  PC.COMP_CD(+)   = P_COMP_CD
                                   AND  PC.USE_YN(+)    = 'Y'
                           )    P
                     WHERE CODE_CD = '25'
                   ) CONNECT BY LEVEL < 5
            UNION ALL
            SELECT  DECODE(LEVEL, 1, 'VAN_TYPE' , 2, 'VAN_TID', 3, 'VAN_IP', 4, 'VAN_PORT') AS FLAG_NM          -- VAN(����)
                 ,  DECODE(LEVEL, 1, NVL(USE_YN, '0'), 2, CAT_ID , 3, IP , 4, PORT ) AS FLAG_VAL
              FROM  (
                        SELECT  V.*
                          FROM  STORE   S
                             ,  (
                                    SELECT  *
                                      FROM  VA
                                     WHERE  CODE_CD IN ('26', '28')
                                       AND  USE_YN  = '1'
                                       AND  ROWNUM  = 1      
                                )       V
                         WHERE  S.COMP_CD  = P_COMP_CD
                           AND  S.BRAND_CD = P_BRAND_CD
                           AND  S.STOR_CD  = P_STOR_CD
                    ) CONNECT BY LEVEL < 5
            UNION ALL
            SELECT  DECODE(LEVEL, 1, 'VAN2_TYPE' , 2, 'VAN2_TID', 3, 'VAN2_IP', 4, 'VAN2_PORT') AS FLAG_NM      -- VAN(��������)
                 ,  DECODE(LEVEL, 1, NVL(USE_YN, '0'), 2, CAT_ID , 3, IP , 4, PORT ) AS FLAG_VAL
              FROM  (
                        SELECT  V.*
                          FROM  STORE   S
                             ,  (
                                    SELECT  *
                                      FROM  VA
                                     WHERE  CODE_CD IN ('27', '29')
                                       AND  USE_YN  = '1'
                                       AND  ROWNUM  = 1      
                                )       V
                         WHERE  S.COMP_CD  = P_COMP_CD
                           AND  S.BRAND_CD = P_BRAND_CD
                           AND  S.STOR_CD  = P_STOR_CD
                    ) CONNECT BY LEVEL < 5
            UNION ALL
            SELECT DECODE(LEVEL, 1, 'CP_DIV' , 2, 'CP_COMP_ID', 3, 'CP_IP', 4, 'CP_PORT') AS FLAG_NM        -- ���ν���
                 , DECODE(LEVEL, 1, NVL(USE_YN, '0'), 2, VAL_C3 , 3, VAL_C2 ,  4, VAL_N1 ) AS FLAG_VAL
              FROM (SELECT *
                      FROM CM
                     WHERE CODE_CD = '30'
                   ) CONNECT BY LEVEL < 5
            UNION ALL
            SELECT  DECODE(LEVEL, 1, 'VAN2_TYPE' , 2, 'VAN2_TID', 3, 'VAN2_IP', 4, 'VAN2_PORT') AS FLAG_NM      -- VAN(��������)
                 ,  DECODE(LEVEL, 1, NVL(USE_YN, '0'), 2, CAT_ID , 3, IP , 4, PORT ) AS FLAG_VAL
              FROM  (
                        SELECT  V.*
                          FROM  STORE   S
                             ,  (
                                    SELECT  *
                                      FROM  VA
                                     WHERE  CODE_CD IN ('27', '29')
                                       AND  USE_YN  = '1'
                                       AND  ROWNUM  = 1      
                                )       V
                         WHERE  S.COMP_CD  = P_COMP_CD
                           AND  S.BRAND_CD = P_BRAND_CD
                           AND  S.STOR_CD  = P_STOR_CD
                    ) CONNECT BY LEVEL < 5
            UNION ALL
            SELECT DECODE(LEVEL, 1, 'PAS_DIV' , 2, 'PAS_IP', 3, 'PAS_PORT', 4, 'PAS_COMP') AS FLAG_NM -- ������(īī����ǰ��)
                 , DECODE(LEVEL, 1, NVL(USE_YN, '0'), 2, IP , 3, PORT , 4, CAT_ID ) AS FLAG_VAL
              FROM (SELECT *
                      FROM VA
                     WHERE CODE_CD = '31'
                   ) CONNECT BY LEVEL < 5
            UNION ALL
            SELECT DECODE(LEVEL, 1,  'EZWEL_DIV' , 2, 'EZWEL_IP', 3, 'EZWEL_PORT', 4, 'EZWEL_COMP') AS FLAG_NM -- ������(������)
                 , DECODE(LEVEL, 1, NVL(USE_YN, '0'), 2, IP , 3, PORT , 4, CAT_ID ) AS FLAG_VAL
              FROM (SELECT *
                      FROM VA
                     WHERE CODE_CD = '32'
                   ) CONNECT BY LEVEL < 5
           )
     ORDER BY FLAG_NM;
     
    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_57 ;
  
  ------------------------------------------------------------------------------
  --  Description      : POS������ ���ſ�       (���� ����)
  -- Ref. Table        : STORE
  ------------------------------------------------------------------------------
  --  Create Date      : 2009-12-24
  --  Modify Date      : 2009-12-24
  ------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_58 (
    anRetVal OUT NUMBER,   -- ����ڵ�
    asRetMsg OUT VARCHAR2, -- ���� �޽���
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT DECODE(LEVEL,  1, 'BRANDCD',             2, 'STORECD',         3, 'STORESNM',         4, 'STORELNM',           5, 'STORE_TP',
                          6, 'STOREAAA',
                          7, 'LICENSE',             8, 'AREP',            9, 'STORE_ADDR1',     10, 'STORE_ADDR2',       11, 'STORETELL',   12, 'ASTELL',
                         13, 'SHOPSERVICEGBPOS',
                         15, 'REGION_CD',           16, 'MULTI_LANGUAGE_YN',
                         17, 'LANGUAGE_TP',         18, 'BILL_ADDR',
                         19, 'SAV_PT_YN',           20, 'SAV_PT_RATE',    21, 'SAV_MLG_YN',
                         22, 'CALL_ORD_YN',         23, 'ONLINE_ORD_YN',  24, 'TAKE_OUT_ORD_YN', 25, 'DELIVERY_ORD_YN',   26, 'DELIVERY_HM', 27, 'RESERVE_HM',
                         28, 'SEAT'       ,         29, 'CURRENCY_CD',    30, 'LOCAL_DAYS',      31, 'FREE_ENTRY_DC_DIV',
                         32, 'SSG_PT_YN'  ,         33, 'SSG_PT_RATE',    34, 'USE_PT_MIN'  ,    35, 'USE_PT_UNIT',
                         36, 'DEF_MATL_ITEM_CD',    37, 'BRANDSNM'
                 ) FLAG_NM,
           DECODE(LEVEL,  1, BRAND_CD,              2, STOR_CD,           3, STOR_NM,            4, STOR_NM,              5, STOR_TP,
                          6, (CASE WHEN NVL(CLOSE_DT, '99991231') <= TO_CHAR(SYSDATE, 'YYYYMMDD') THEN '1' ELSE '0' END),
                          7, REPLACE(BUSI_NO, '-', ''), 8, BUSI_NM,           9, ADDR,              10, ADDR2,               11, TEL_NO,        12, '',
                         13, '0',
                         15, REGION_CD,             16, MULTI_LANGUAGE_YN,
                         17, LANGUAGE_TP,           18, BILL_ADDR,
                         19, SAV_PT_YN,             20, SAV_PT_RATE,      21, SAV_MLG_YN,
                         22, CALL_ORD_YN,           23, ONLINE_ORD_YN,    24, TAKE_OUT_ORD_YN,   25, DELIVERY_ORD_YN,     26, DELIVERY_HM,   27, RESERVE_HM,
                         28, SEAT,                  29, CURRENCY_CD,      30, LOCAL_DAYS,        31, FREE_ENTRY_DC_DIV,
                         32, SSG_PT_YN,             33, SSG_PT_RATE,      34, USE_PT_MIN,        35, USE_PT_UNIT,
                         36, DEF_MATL_ITEM_CD,      37, BRAND_SNM
                 ) FLAG_VAL
     FROM (SELECT A.* 
                , B.MULTI_LANGUAGE_YN 
                , B.LANGUAGE_TP
                , CASE WHEN C.MEMB_YN = 'Y' AND C.SAV_PT_YN  = 'Y' AND D.SAV_PT_YN  = 'Y' THEN 'Y'           ELSE 'N' END AS SAV_PT_YN
                , CASE WHEN C.MEMB_YN = 'Y' AND C.SAV_PT_YN  = 'Y' AND D.SAV_PT_YN  = 'Y' THEN C.SAV_PT_RATE ELSE 0   END AS SAV_PT_RATE
                , CASE WHEN C.MEMB_YN = 'Y' AND C.SAV_MLG_YN = 'Y' AND F.SAV_MLG_YN = 'Y' THEN 'Y'           ELSE 'N' END AS SAV_MLG_YN
                , NVL(E.CALL_ORD_YN,     'N')    CALL_ORD_YN
                , NVL(E.ONLINE_ORD_YN,   'N')    ONLINE_ORD_YN
                , NVL(E.TAKE_OUT_ORD_YN, 'N')    TAKE_OUT_ORD_YN
                , NVL(E.DELIVERY_ORD_YN, 'N')    DELIVERY_ORD_YN
                , NVL(E.DELIVERY_HM,     '0000') DELIVERY_HM
                , NVL(E.RESERVE_HM,      '0000') RESERVE_HM
                , NVL(G.LOCAL_DAYS,      '60')   LOCAL_DAYS
                , H.FREE_ENTRY_DC_DIV
                , CASE WHEN J.SSG_PT_YN    = 'Y' THEN 'Y' ELSE 'N' END AS SSG_PT_YN
                , NVL(K.SSG_PT_RATE, '0')                              AS SSG_PT_RATE
                , NVL(L.USE_PT_MIN ,  0 )     AS USE_PT_MIN
                , NVL(M.USE_PT_UNIT,  0 )     AS USE_PT_UNIT
                , N.DEF_MATL_ITEM_CD
                , Q.BRAND_SNM
             FROM STORE        A
                , COMPANY      B
                , BRAND_MEMB   C
                , BRAND        Q
                , (SELECT COMP_CD, BRAND_CD, STOR_CD, PARA_VAL SAV_PT_YN
                     FROM PARA_STORE
                    WHERE COMP_CD = P_COMP_CD
                      AND BRAND_CD= P_BRAND_CD
                      AND STOR_CD = P_STOR_CD
                      AND PARA_CD = '3001' -- ����Ʈ ��������[Y:����, N:��������]
                      AND USE_YN  = 'Y'
                  )            D
                , (SELECT COMP_CD, BRAND_CD, STOR_CD, PARA_VAL SAV_MLG_YN
                     FROM PARA_STORE
                    WHERE COMP_CD = P_COMP_CD
                      AND BRAND_CD= P_BRAND_CD
                      AND STOR_CD = P_STOR_CD
                      AND PARA_CD = '3002' -- ���ϸ��� ��������[Y:����, N:��������]
                      AND USE_YN  = 'Y'
                  )            F
               , (SELECT COMP_CD, BRAND_CD, STOR_CD, PARA_VAL SSG_PT_YN
                     FROM PARA_STORE
                    WHERE COMP_CD = P_COMP_CD
                      AND BRAND_CD= P_BRAND_CD
                      AND STOR_CD = P_STOR_CD
                      AND PARA_CD = '3003' -- �ż��� ����Ʈ ��������[Y:����, N:��������]
                      AND USE_YN  = 'Y'
                  )            J
                , (SELECT COMP_CD, BRAND_CD, STOR_CD, PARA_VAL SSG_PT_RATE
                     FROM PARA_STORE
                    WHERE COMP_CD = P_COMP_CD
                      AND BRAND_CD= P_BRAND_CD
                      AND STOR_CD = P_STOR_CD
                      AND PARA_CD = '3004' -- �ż��� ����Ʈ ������
                      AND USE_YN  = 'Y'
                  )            K
                , (SELECT COMP_CD, BRAND_CD, PARA_VAL USE_PT_MIN
                     FROM PARA_BRAND
                    WHERE COMP_CD = P_COMP_CD
                      AND BRAND_CD= P_BRAND_CD
                      AND PARA_CD = '1017' -- ����Ʈ ��� ����
                  )            L
                , (SELECT COMP_CD, BRAND_CD, PARA_VAL USE_PT_UNIT
                     FROM PARA_BRAND
                    WHERE COMP_CD = P_COMP_CD
                      AND BRAND_CD= P_BRAND_CD
                      AND PARA_CD = '1018' -- ����Ʈ ��� ����
                      AND USE_YN  = 'Y'
                  )            M
                , (SELECT COMP_CD, BRAND_CD, PARA_VAL DEF_MATL_ITEM_CD
                     FROM PARA_BRAND
                    WHERE COMP_CD = P_COMP_CD
                      AND BRAND_CD= P_BRAND_CD
                      AND PARA_CD = '1020' -- ����Ʈ����
                      AND USE_YN  = 'Y'
                  )            N
                , STORE_CNT    E
                , (
                    SELECT  COMP_CD
                         ,  MAX(CASE WHEN CODE_CD = '01' THEN VAL_C1 ELSE NULL END) AS LOCAL_DAYS
                      FROM  COMMON
                     WHERE  COMP_CD = P_COMP_CD
                       AND  CODE_TP = '90000'
                       AND  USE_YN  = 'Y'
                     GROUP  BY COMP_CD
                  ) G
                , (
                    SELECT  COMP_CD
                         ,  PARA_VAL AS FREE_ENTRY_DC_DIV
                      FROM  PARA_BRAND
                     WHERE  COMP_CD = P_COMP_CD
                       AND  BRAND_CD= P_BRAND_CD
                       AND  PARA_CD = '1019'
                       AND  USE_YN  = 'Y'
                  ) H
            WHERE A.COMP_CD  = E.COMP_CD(+)
              AND A.BRAND_CD = E.BRAND_CD(+)
              AND A.STOR_CD  = E.STOR_CD(+)
              AND A.COMP_CD  = D.COMP_CD(+)
              AND A.BRAND_CD = D.BRAND_CD(+)
              AND A.STOR_CD  = D.STOR_CD(+)
              AND A.COMP_CD  = F.COMP_CD(+)
              AND A.BRAND_CD = F.BRAND_CD(+)
              AND A.STOR_CD  = F.STOR_CD(+)
              AND A.COMP_CD  = J.COMP_CD(+)
              AND A.BRAND_CD = J.BRAND_CD(+)
              AND A.STOR_CD  = J.STOR_CD(+)
              AND A.COMP_CD  = K.COMP_CD(+)
              AND A.BRAND_CD = K.BRAND_CD(+)
              AND A.STOR_CD  = K.STOR_CD(+)
              AND A.COMP_CD  = L.COMP_CD(+)
              AND A.BRAND_CD = L.BRAND_CD(+)
              AND A.COMP_CD  = M.COMP_CD(+)
              AND A.BRAND_CD = M.BRAND_CD(+)
              AND A.COMP_CD  = N.COMP_CD(+)
              AND A.BRAND_CD = N.BRAND_CD(+)
              AND A.COMP_CD  = C.COMP_CD(+)
              AND A.BRAND_CD = C.BRAND_CD(+)
              AND A.COMP_CD  = Q.COMP_CD(+)
              AND A.BRAND_CD = Q.BRAND_CD(+)
              AND A.COMP_CD  = G.COMP_CD(+)
              AND A.COMP_CD  = H.COMP_CD(+)
              AND A.COMP_CD  = B.COMP_CD
              AND A.COMP_CD  = P_COMP_CD
              AND A.BRAND_CD = P_BRAND_CD
              AND A.STOR_CD  = P_STOR_CD
          ) CONNECT BY LEVEL <= 37
    UNION ALL
    SELECT 'COMP_CD' AS FLAG_NM ,
           COMP_CD   AS FLAG_VAL
      FROM COMPANY
     WHERE COMP_CD  = P_COMP_CD
       AND ROWNUM   = 1;
       
    anRetVal := 1 ;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_58 ;
  
  --------------------------------------------------------------------------------
  --  Description      : POS������ ���ſ�       (���� ���� -> �������� ������.)
  -- Ref. Table        : BILL_MSG_HQ
  --------------------------------------------------------------------------------
  --  Create Date      : 2009-12-24
  --  Modify Date      : 2009-12-24
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_59 (
    anRetVal OUT NUMBER,   -- ����ڵ�
    asRetMsg OUT VARCHAR2, -- ���� �޽���
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT BILL_MSG_DIV BILL_MSG_DIV -- PK.���Ǳ��� => ����(00655) [1:���, 2:�ߴ�, 3:�ϴ�]
         , REPLACE(REPLACE(BILL_MSG, CHR(13), '@'), CHR(10), '$') BILL_MSG -- ���Ǹ޼���
         , USE_YN
      FROM BILL_MSG_HQ
     WHERE COMP_CD  = P_COMP_CD
       AND BRAND_CD = P_BRAND_CD
       AND STOR_TP  = '10'
       AND UPD_DT  >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS');
       
    anRetVal := 1 ;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_59 ;
  
  --------------------------------------------------------------------------------
  --  Description      : POS������ ���ſ�       (���� ���� )
  -- Ref. Table        : BILL_MSG_STOR
  --------------------------------------------------------------------------------
  --  Create Date      : 2009-12-24
  --  Modify Date      : 2009-12-24
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_60 (
    anRetVal OUT NUMBER,   -- ����ڵ�
    asRetMsg OUT VARCHAR2, -- ���� �޽���
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT BILL_MSG_DIV   BILL_MSG_DIV                                     -- PK.���Ǳ��� => ����(00655) [1:���, 2:�ߴ�, 3:�ϴ�]
         , REPLACE(REPLACE(BILL_MSG, CHR(13), '@'), CHR(10), '$') BILL_MSG -- ���Ǹ޼���
         , USE_YN
      FROM BILL_MSG_STOR
     WHERE COMP_CD  = P_COMP_CD
       AND BRAND_CD = P_BRAND_CD
       AND STOR_CD  = P_STOR_CD
       AND UPD_DT  >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS');
       
    anRetVal := 1 ;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_60;
  
  --------------------------------------------------------------------------------
  --  Description      : POS������ ���ſ�       ( �۽� URL )
  -- Ref. Table        : COMMON
  --------------------------------------------------------------------------------
  --  Create Date      : 2010-04-16
  --  Modify Date      : 2010-04-16
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_61 (
    anRetVal OUT NUMBER,   -- ����ڵ�
    asRetMsg OUT VARCHAR2, -- ���� �޽���
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT VAL_C1  IF_FLAG,
           VAL_C2  IF_ID,
           REMARKS IF_PW
      FROM COMMON
     WHERE COMP_CD  = P_COMP_CD
       AND CODE_TP = '01440'
       AND USE_YN  = 'Y'
    UNION ALL
    SELECT DECODE(LEVEL, 1, 'FTPINFO', 'AIRINFO' )AS IF_FLAG ,
           DECODE(LEVEL, 1, 'FTP_PASSIVE' , 2, 'KORAIL_APPR_YN' , 3, 'ETC_IF_DIV' , 4, 'ETC_FTP_IP' , 5, 'ETC_FTP_PORT' , 6, 'ETC_FTP_ID' , 7, 'ETC_FTP_PW' , 8, 'ETC_FTP_PASSIVE' , 9, 'ETC_FTP_PATH' , 10, 'ETC_MAIN_CD' , 11, 'ETC_GUBUN_CD' , 12, 'ETC_STOR_CD' ) AS FLAG_NM ,
           DECODE(LEVEL, 1, ST.FTP_PASSIVE , 2, ST.KORAIL_APPR_YN , 3, ST.ETC_IF_DIV , 4, ST.ETC_FTP_IP , 5, ST.ETC_FTP_PORT , 6, ST.ETC_FTP_ID , 7, ST.ETC_FTP_PW , 8, ST.ETC_FTP_PASSIVE , 9, ST.ETC_FTP_PATH , 10, ST.ETC_MAIN_CD , 11, ST.ETC_GUBUN_CD , 12, ST.ETC_STOR_CD ) AS FLAG_VAL
      FROM (SELECT ST.FTP_PASSIVE ,
                   ST.KORAIL_APPR_YN ,
                   ST.ETC_IF_DIV ,
                   ST.ETC_FTP_IP ,
                   ST.ETC_FTP_PORT ,
                   ST.ETC_FTP_ID ,
                   ST.ETC_FTP_PW ,
                   ST.ETC_FTP_PASSIVE ,
                   ST.ETC_FTP_PATH ,
                   ST.ETC_MAIN_CD ,
                   ST.ETC_GUBUN_CD ,
                   ST.ETC_STOR_CD
              FROM STORE_SETUP ST,
                   STORE S
             WHERE S.COMP_CD  = P_COMP_CD
               AND S.BRAND_CD = P_BRAND_CD
               AND S.STOR_CD  = P_STOR_CD
               AND S.COMP_CD  = ST.COMP_CD(+)
               AND S.BRAND_CD = ST.BRAND_CD(+)
               AND S.STOR_CD  = ST.STOR_CD(+)
           ) ST CONNECT BY LEVEL < 13
          UNION ALL
      SELECT 'SHOPINFO' AS IF_FLAG ,
             'BRANDGB' AS IF_ID ,
             '' AS IF_PW
        FROM BRAND
       WHERE COMP_CD  = P_COMP_CD
         AND BRAND_CD = P_BRAND_CD ;
      anRetVal := 1 ;
      asRetMsg := 'OK';
  Exception
  When OTHERS Then
      asRetMsg := SQLERRM(SQLCODE);
      anRetVal := SQLCODE ;
  END GET_MASTER_61 ;
  
  --------------------------------------------------------------------------------
  --  Description      : POS������ ���ſ�       (���� ����ó )
  -- Ref. Table        : STORE_PURCHASE
  --------------------------------------------------------------------------------
  --  Create Date      : 2009-12-24
  --  Modify Date      : 2009-12-24
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_62 (
    anRetVal OUT NUMBER,   -- ����ڵ�
    asRetMsg OUT VARCHAR2, -- ���� �޽���
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT STOR_CD      STOR_CD     -- �����ڵ�
         , PURCHASE_CD  PURCHASE_CD -- ����ó�ڵ�
         , PURCHASE_NM  PURCHASE_NM -- ����ó��
         , BUSI_NM      BUSI_NM -- ����ڸ�
         , TEL_NO       TEL_NO  -- ��ȭ��ȣ
         , ADDR         ADDR    -- �ּ�
         , ADDR2        ADDR2   -- �ּ�2
         , USE_YN       USE_YN
      FROM STORE_PURCHASE
     WHERE COMP_CD  = P_COMP_CD
       AND STOR_CD = P_STOR_CD
       AND UPD_DT >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS');
       
    anRetVal := 1 ;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_62 ;
  
  --------------------------------------------------------------------------------
  --  Description      : POS������ ���ſ�       (����ں� ���α׷� ����)
  -- Ref. Table        : POS_PGM_AUTH
  --------------------------------------------------------------------------------
  --  Create Date      : 2009-12-24
  --  Modify Date      : 2009-12-24
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_63 (
    anRetVal OUT NUMBER,   -- ����ڵ�
    asRetMsg OUT VARCHAR2, -- ���� �޽���
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    WITH S_COMMON AS (
      SELECT CODE_CD PGM_ID,
             CODE_NM PGM_NM,
             VAL_C1  PGM_FG,
             VAL_C2  PWD_YN,
             REMARKS POS_PGM_ID,
             CODE_TP CODE_TP
        FROM COMMON
       WHERE COMP_CD  = P_COMP_CD
         AND CODE_TP  = '01402'
         AND USE_YN LIKE P_USE_YN
    )
    SELECT P.BRAND_CD
         , P.STOR_CD
         , P.USER_ID
         , P.PGM_ID
         , C.POS_PGM_ID
         , C.PGM_NM
         , C.PGM_FG
         , C.PWD_YN
         , P.USE_YN
         , P.UPD_DT
      FROM POS_PGM_AUTH P,
           S_COMMON     C
     WHERE P.PGM_ID   = C.PGM_ID
       AND P.COMP_CD  = P_COMP_CD
       AND P.BRAND_CD = P_BRAND_CD
       AND P.STOR_CD  = P_STOR_CD
       AND P.UPD_DT  >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS');
       
    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_63 ;
  
  --------------------------------------------------------------------------------
  --  Description      : POS������ ���ſ� (�ٱ��� ��ǰ)
  -- Ref. Table        : LANG_ITEM
  --------------------------------------------------------------------------------
  --  Create Date      : 2014-02-18 ASP Ver
  --  Modify Date      : 
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_71 (
    anRetVal OUT NUMBER,   -- ����ڵ�
    asRetMsg OUT VARCHAR2, -- ���� �޽���
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT ITEM_CD
         , LANGUAGE_TP
         , ITEM_NM
         , ITEM_POS_NM
         , USE_YN
         , TO_CHAR(INST_DT, 'YYYY-MM-DD HH24:MI:SS') AS INST_DT
         , INST_USER
         , TO_CHAR(UPD_DT,  'YYYY-MM-DD HH24:MI:SS') AS UPD_DT
         , UPD_USER
         ,  ITEM_KDS_NM
      FROM LANG_ITEM
     WHERE COMP_CD     = P_COMP_CD
       AND P_DOWN_DTM <= TO_CHAR(UPD_DT, 'YYYYMMDDHH24MISS');
     
    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_71;
  
  --------------------------------------------------------------------------------
  --  Description      : POS������ ���ſ� (�ٱ��� ����)
  -- Ref. Table        : LANG_COMMON
  --------------------------------------------------------------------------------
  --  Create Date      : 2014-02-18 ASP Ver
  --  Modify Date      : 
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_72 (
    anRetVal OUT NUMBER,   -- ����ڵ�
    asRetMsg OUT VARCHAR2, -- ���� �޽���
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT CODE_TP
         , CODE_CD
         , LANGUAGE_TP
         , CODE_NM
         , USE_YN
         , TO_CHAR(INST_DT, 'YYYY-MM-DD HH24:MI:SS') AS INST_DT
         , INST_USER
         , TO_CHAR(UPD_DT,  'YYYY-MM-DD HH24:MI:SS') AS UPD_DT
         , UPD_USER
      FROM LANG_COMMON
     WHERE COMP_CD     = P_COMP_CD
       AND P_DOWN_DTM <= TO_CHAR(UPD_DT, 'YYYYMMDDHH24MISS');
     
    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_72;
  
  --------------------------------------------------------------------------------
  --  Description      : POS������ ���ſ� (�ٱ��� ����)
  -- Ref. Table        : LANG_STORE
  --------------------------------------------------------------------------------
  --  Create Date      : 2014-02-18 ASP Ver
  --  Modify Date      : 
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_73 (
    anRetVal OUT NUMBER,   -- ����ڵ�
    asRetMsg OUT VARCHAR2, -- ���� �޽���
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT BRAND_CD
         , STOR_CD
         , LANGUAGE_TP
         , STOR_NM
         , USE_YN
         , TO_CHAR(INST_DT, 'YYYY-MM-DD HH24:MI:SS') AS INST_DT
         , INST_USER
         , TO_CHAR(UPD_DT,  'YYYY-MM-DD HH24:MI:SS') AS UPD_DT
         , UPD_USER
      FROM LANG_STORE
     WHERE COMP_CD     = P_COMP_CD
       AND P_DOWN_DTM <= TO_CHAR(UPD_DT, 'YYYYMMDDHH24MISS');
     
    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_73;
  
  --------------------------------------------------------------------------------
  --  Description      : POS������ ���ſ� (�ٱ��� ���̺�)
  -- Ref. Table        : LANG_TABLE
  --------------------------------------------------------------------------------
  --  Create Date      : 2014-02-18 ASP Ver
  --  Modify Date      : 
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_74 (
    anRetVal OUT NUMBER,   -- ����ڵ�
    asRetMsg OUT VARCHAR2, -- ���� �޽���
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT TABLE_NM
         , COL_NM
         , LANGUAGE_TP
         , PK_COL
         , LANG_NM
         , USE_YN
         , TO_CHAR(INST_DT, 'YYYY-MM-DD HH24:MI:SS') AS INST_DT
         , INST_USER
         , TO_CHAR(UPD_DT,  'YYYY-MM-DD HH24:MI:SS') AS UPD_DT
         , UPD_USER
      FROM LANG_TABLE
     WHERE COMP_CD     = P_COMP_CD
       AND P_DOWN_DTM <= TO_CHAR(UPD_DT, 'YYYYMMDDHH24MISS');
     
    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_74;
  
  --------------------------------------------------------------------------------
  --  Description      : POS������ ���ſ� (������)
  -- Ref. Table        : RECIPE_BRAND
  --------------------------------------------------------------------------------
  --  Create Date      : 2014-02-18 ASP Ver
  --  Modify Date      : 
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_75 (
    anRetVal OUT NUMBER,   -- ����ڵ�
    asRetMsg OUT VARCHAR2, -- ���� �޽���
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT BRAND_CD
         , ITEM_CD
         , RCP_ITEM_CD
         , RCP_DIV
         , START_DT
         , CLOSE_DT
         , DO_YN
         , DO_UNIT
         , RCP_QTY
         , LOSS_RATE
         , USE_YN
         , TO_CHAR(INST_DT, 'YYYY-MM-DD HH24:MI:SS') AS INST_DT
         , INST_USER
         , TO_CHAR(UPD_DT,  'YYYY-MM-DD HH24:MI:SS') AS UPD_DT
         , UPD_USER
      FROM RECIPE_BRAND
     WHERE COMP_CD     = P_COMP_CD
       AND P_DOWN_DTM <= TO_CHAR(UPD_DT, 'YYYYMMDDHH24MISS');
     
    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_75;
  
  --------------------------------------------------------------------------------
  --  Description      : POS������ ���ſ� (����)
  -- Ref. Table        : DC
  --------------------------------------------------------------------------------
  --  Create Date      : 2011-07-07
  --  Modify Date      : 2011-07-07
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_84 (
    anRetVal OUT NUMBER,   -- ����ڵ�
    asRetMsg OUT VARCHAR2, -- ���� �޽���
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT BRAND_CD,
           DC_DIV,
           DC_NM,
           DC_POSNM,
           DC_GRPCD,
           DC_FG,
           DC_VALUE,
           INPUT_YN,
           DC_FDATE,
           DC_TDATE,
           DC_FTIME,
           DC_TTIME,
           ORD_RANK,
           POS_DISP_YN,
           STOR_DIV,
           MEMB_DC_FG,
           DC_REMARK,
           DML_FLAG,
           DC_PURC_LMT,
           TO_CHAR(INST_DT, 'YYYY-MM-DD HH24:MI:SS') AS INST_DT,
           INST_USER,
           TO_CHAR(UPD_DT,  'YYYY-MM-DD HH24:MI:SS') AS UPD_DT,
           UPD_USER,
           CERT_FG,
           DC_CLASS,
           DC_WD_FG
      FROM DC
     WHERE COMP_CD     = P_COMP_CD
       AND BRAND_CD    IN ('0000', P_BRAND_CD)
       AND P_DOWN_DTM <= TO_CHAR(UPD_DT, 'YYYYMMDDHH24MISS');
       
    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_84 ;
  
  --------------------------------------------------------------------------------
  --  Description      : POS������ ���ſ� (������ ����)
  -- Ref. Table        : DC_STORE
  --------------------------------------------------------------------------------
  --  Create Date      : 2011-07-07
  --  Modify Date      : 2011-07-07
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_85 (
    anRetVal OUT NUMBER,   -- ����ڵ�
    asRetMsg OUT VARCHAR2, -- ���� �޽���
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT BRAND_CD,
           STOR_CD,
           DC_SEQ,
           DC_DIV,
           ORD_RANK,
           DML_FLAG,
           TO_CHAR(INST_DT, 'YYYY-MM-DD HH24:MI:SS') AS INST_DT,
           INST_USER,
           TO_CHAR(UPD_DT,  'YYYY-MM-DD HH24:MI:SS') AS UPD_DT,
           UPD_USER
      FROM DC_STORE
     WHERE COMP_CD     = P_COMP_CD
       AND BRAND_CD    IN ('0000', P_BRAND_CD)
       AND STOR_CD     = P_STOR_CD
       AND P_DOWN_DTM <= TO_CHAR(UPD_DT, 'YYYYMMDDHH24MISS')
     ORDER BY UPD_DT DESC, DML_FLAG ASC;
     
    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_85 ;
  
  --------------------------------------------------------------------------------
  --  Description      : POS������ ���ſ� (���� ����ǰ)
  -- Ref. Table        : DC_ITEM
  --------------------------------------------------------------------------------
  --  Create Date      : 2013-09-25
  --  Modify Date      : 
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_86 (
    anRetVal OUT NUMBER,   -- ����ڵ�
    asRetMsg OUT VARCHAR2, -- ���� �޽���
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT DI.BRAND_CD,
           DI.DC_DIV,
           DI.GRP_SEQ,
           DI.ITEM_SEQ,
           DI.ITEM_CD,
           DI.PURC_QTY,
           DI.VAN_ITEM_CD,
           DI.VAN_SALE_PRC,
           DI.USE_YN,
           TO_CHAR(DI.INST_DT, 'YYYY-MM-DD HH24:MI:SS') AS INST_DT,
           DI.INST_USER,
           TO_CHAR(DI.UPD_DT,  'YYYY-MM-DD HH24:MI:SS') AS UPD_DT,
           DI.UPD_USER,
           DI.DC_FG,
           DI.DC_VALUE
      FROM DC_ITEM      DI
         , (
              SELECT COMP_CD
                   , ITEM_CD
                FROM ITEM_CHAIN
               WHERE COMP_CD    = P_COMP_CD
                 AND BRAND_CD   = P_BRAND_CD
                 AND STOR_TP    = ( SELECT STOR_TP FROM STORE WHERE COMP_CD = P_COMP_CD AND BRAND_CD = P_BRAND_CD AND STOR_CD = P_STOR_CD )
               GROUP BY COMP_CD, ITEM_CD
           )            I 
     WHERE DI.COMP_CD  = I.COMP_CD
       AND DI.ITEM_CD  = I.ITEM_CD
       AND DI.COMP_CD  = P_COMP_CD
       AND DI.BRAND_CD IN ('0000', P_BRAND_CD)
       AND P_DOWN_DTM <= TO_CHAR(DI.UPD_DT, 'YYYYMMDDHH24MISS');
       
    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_86 ;
  
  --------------------------------------------------------------------------------
  --  Description      : POS������ ���ſ� (���� ����ǰ)
  -- Ref. Table        : DC_GIFT
  --------------------------------------------------------------------------------
  --  Create Date      : 2013-09-25
  --  Modify Date      : 
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_87 (
    anRetVal OUT NUMBER,   -- ����ڵ�
    asRetMsg OUT VARCHAR2, -- ���� �޽���
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT BRAND_CD,
           DC_DIV,
           GRP_SEQ,
           GIFT_SEQ,
           ITEM_CD,
           GIFT_QTY,
           USE_YN,
           TO_CHAR(INST_DT, 'YYYY-MM-DD HH24:MI:SS') AS INST_DT,
           INST_USER,
           TO_CHAR(UPD_DT,  'YYYY-MM-DD HH24:MI:SS') AS UPD_DT,
           UPD_USER
      FROM DC_GIFT
     WHERE COMP_CD     = P_COMP_CD
       AND BRAND_CD    IN ('0000', P_BRAND_CD)
       AND P_DOWN_DTM <= TO_CHAR(UPD_DT, 'YYYYMMDDHH24MISS');
     
    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_87 ;
  
  --------------------------------------------------------------------------------
  --  Description      : POS������ ���ſ� (B2B)
  -- Ref. Table        : STORE(STOR_TP='50')
  --------------------------------------------------------------------------------
  --  Create Date      : 2013-09-25
  --  Modify Date      : 
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_88 (
    anRetVal OUT NUMBER,   -- ����ڵ�
    asRetMsg OUT VARCHAR2, -- ���� �޽���
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT BRAND_CD,
           STOR_CD,
           STOR_NM,
           BUSI_NO,
           USE_YN,
           TO_CHAR(INST_DT, 'YYYY-MM-DD HH24:MI:SS') AS INST_DT,
           INST_USER,
           TO_CHAR(UPD_DT,  'YYYY-MM-DD HH24:MI:SS') AS UPD_DT,
           UPD_USER,
           NVL((SELECT B2B_DC_RATE FROM STORE_SETUP B WHERE B.BRAND_CD = A.BRAND_CD AND B.STOR_CD = A.STOR_CD), 0) B2B_DC_RATE,
           TEL_NO
      FROM STORE A
     WHERE COMP_CD     = P_COMP_CD
       AND BRAND_CD    = P_BRAND_CD
       AND STOR_TP     = '50' -- [50:B2B]
       AND P_DOWN_DTM <= TO_CHAR(UPD_DT, 'YYYYMMDDHH24MISS');
     
    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_88 ;
  
  --------------------------------------------------------------------------------
  --  Description      : POS������ ���ſ� (���δ�� ����)
  -- Ref. Table        : DC_WEEK
  --------------------------------------------------------------------------------
  --  Create Date      : 2014-01-22
  --  Modify Date      : 
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_89 (
    anRetVal OUT NUMBER,   -- ����ڵ�
    asRetMsg OUT VARCHAR2, -- ���� �޽���
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT BRAND_CD,
           DC_DIV,
           WEEK_DAY,
           START_TM,
           CLOSE_TM,
           USE_YN,
           TO_CHAR(INST_DT, 'YYYY-MM-DD HH24:MI:SS') AS INST_DT,
           INST_USER,
           TO_CHAR(UPD_DT,  'YYYY-MM-DD HH24:MI:SS') AS UPD_DT,
           UPD_USER
      FROM DC_WEEK
     WHERE COMP_CD     = P_COMP_CD
       AND BRAND_CD    IN ('0000', P_BRAND_CD)
       AND P_DOWN_DTM <= TO_CHAR(UPD_DT, 'YYYYMMDDHH24MISS');
     
    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_89 ;
  
  --------------------------------------------------------------------------------
  --  Description      : POS������ ���ſ�       ( SYSDATE ���� )
  -- Ref. Table        :
  --------------------------------------------------------------------------------
  --  Create Date      : 2011-02-21
  --  Modify Date      : 2011-02-21
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_90 (
    anRetVal OUT NUMBER,   -- ����ڵ�
    asRetMsg OUT VARCHAR2, -- ���� �޽���
    p_cursor OUT rec_set.m_refcur
  ) IS
    lsCurrDt VARCHAR2(20) := TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS');
  BEGIN
    INSERT INTO ERR_LOG_IF_POS
           ( 
             COMP_CD,
             JOB_DATE,
             JOB_SEQ_NO,
             STOR_CD,
             JOB_TIME,
             JOB_NAME,
             JOB_MESSAGE
           ) 
    VALUES
           ( 
             P_COMP_CD,
             TO_CHAR(SYSDATE, 'YYYYMMDD'),
             SQ_ERR_LOG_IF_POS.NEXTVAL,
             P_STOR_CD,
             TO_CHAR(SYSDATE, 'HH24MISS'),
             '90',
             '�Ͻ� : [' || lsCurrDt || ']'
           );
    Commit;
    
    OPEN p_cursor FOR
    SELECT lsCurrDt
      FROM DUAL;
      
    anRetVal := 1 ;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_90 ;
  
  --------------------------------------------------------------------------------
  --  Description      : POS������ ���ſ� (���δ���ǰ�׷�)
  -- Ref. Table        : DC_ITEM_GRP
  --------------------------------------------------------------------------------
  --  Create Date      : 2014-01-22
  --  Modify Date      : 
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_91 (
    anRetVal OUT NUMBER,   -- ����ڵ�
    asRetMsg OUT VARCHAR2, -- ���� �޽���
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
    SELECT BRAND_CD,
           DC_DIV,
           GRP_SEQ,
           GRP_NM,
           PURC_QTY,
           GIFT_QTY,
           USE_YN,
           TO_CHAR(INST_DT, 'YYYY-MM-DD HH24:MI:SS') AS INST_DT,
           INST_USER,
           TO_CHAR(UPD_DT,  'YYYY-MM-DD HH24:MI:SS') AS UPD_DT,
           UPD_USER,
           EMP_DIV
      FROM DC_ITEM_GRP
     WHERE COMP_CD     = P_COMP_CD
       AND BRAND_CD    IN ('0000', P_BRAND_CD)
       AND P_DOWN_DTM <= TO_CHAR(UPD_DT, 'YYYYMMDDHH24MISS');
     
    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_91 ;
  
  --------------------------------------------------------------------------------
  --  Description      : POS������ ���ſ�       (����� ������)
  -- Ref. Table        : STORE_USER
  --------------------------------------------------------------------------------
  --  Create Date      : 2009-12-23
  --  Modify Date      : 2009-12-23
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_92 (
    anRetVal OUT NUMBER,   -- ����ڵ�
    asRetMsg OUT VARCHAR2, -- ���� �޽���
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    
    OPEN p_cursor FOR
        SELECT  COMP_CD     -- ȸ���ڵ�
              , USER_ID     -- �����id
              , USER_NM     -- �����aud
              , BRAND_CD    -- �귣���ڵ�
              , DEPT_CD     -- �μ��ڵ�
              , TEAM_CD     -- ���ڵ�
              , POSITION_CD -- ����
              , USER_DIV    -- ��å
              , MNG_CARD_ID -- ����� ī���ȣ
              , LANGUAGE_TP -- ����ڵ�
              , USE_YN      -- �������
              , TO_CHAR(UPD_DT, 'YYYYMMDDHH24MISS') UPD_DT -- �����Ͻ�
        FROM    HQ_USER
        WHERE   COMP_CD   = P_COMP_CD
        AND     UPD_DT   >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
        AND     USE_YN LIKE P_USE_YN;
    
    anRetVal := 1 ;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_92 ;
  
  --------------------------------------------------------------------------------
  --  Description      : POS������ ���ſ� (B2B DC ITEM)
  -- Ref. Table        : ITEM_B2B_DC_HIS
  --------------------------------------------------------------------------------
  --  Create Date      : 2014-09-16
  --  Modify Date      : 
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_A0 (
    anRetVal OUT NUMBER,   -- ����ڵ�
    asRetMsg OUT VARCHAR2, -- ���� �޽���
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
        SELECT  BRAND_CD
              , STOR_CD
              , ITEM_CD
              , START_DT
              , CLOSE_DT
              , DC_FG
              , DC_AMT
              , DC_RATE
              , USE_YN
              , TO_CHAR(INST_DT, 'YYYY-MM-DD HH24:MI:SS') AS INST_DT
              , INST_USER
              , TO_CHAR(UPD_DT,  'YYYY-MM-DD HH24:MI:SS') AS UPD_DT
              , UPD_USER
          FROM  ITEM_B2B_DC_HIS
         WHERE  BRAND_CD    = P_BRAND_CD
           AND  P_DOWN_DTM <= TO_CHAR(UPD_DT, 'YYYYMMDDHH24MISS');
     
    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_A0;
  
  PROCEDURE GET_MASTER_A1 (
    anRetVal OUT NUMBER,   -- ����ڵ�
    asRetMsg OUT VARCHAR2, -- ���� �޽���
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
        SELECT  BRAND_CD
              , ITEM_CD
              , SEQ
              , PERIOD_DIV
              , PERIOD_DAY
              , PERIOD_HOUR
              , PERIOD_MIMUTE
              , SORT_ORDER
              , USE_YN
          FROM  ITEM_STOCK_PERIOD
         WHERE  COMP_CD     = P_COMP_CD
           AND  BRAND_CD    = P_BRAND_CD
           AND  USE_YN LIKE P_USE_YN
           AND  P_DOWN_DTM <= TO_CHAR(UPD_DT, 'YYYYMMDDHH24MISS');
     
    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_A1;
  
  PROCEDURE GET_MASTER_A2 (
    anRetVal OUT NUMBER,   -- ����ڵ�
    asRetMsg OUT VARCHAR2, -- ���� �޽���
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
            SELECT  I1.BRAND_CD                         -- ��������
                 ,  I1.ITEM_CD                          -- ��ǰ�ڵ�
                 ,  I1.ITEM_POS_NM                      -- ��ǰ��(����)
                 ,  NVL(I1.SALE_START_DT, TO_CHAR(SYSDATE, 'YYYYMMDD')) AS SALE_START_DT    -- �ǸŰ�����
                 ,  NVL(I1.SALE_CLOSE_DT, '99991231')                   AS SALE_CLOSE_DT    -- �Ǹ�������
                 ,  I1.L_CLASS_CD                       -- ��з� �ڵ�
                 ,  I1.M_CLASS_CD                       -- �ߺз� �ڵ�
                 ,  I1.S_CLASS_CD                       -- �Һз� �ڵ�
                 ,  ''          AS FLAVOR_DIV           -- �÷��̹��������� - �ϼ�, ����
                 ,  '0'         AS SALE_AMT             -- �ǸŰ�
                 ,  'Y'         AS NODC_YN              -- ���� �Ұ� ǰ�񿩺� => Y : ���κҰ�,  N : ���ΰ���
                 ,  '0'         AS SALE_DC_DIV          -- ���� ���� ����     => 0:����, 1:�ǸŰ� ������, 2:��������
                 ,  '0'         AS SALE_DC_PRC          -- ���αݾ�           => ��Ʈ���� �� �ǸŰ� ������ �Ǹ� ���αݾ� ����
                 ,  'N'         AS SALE_VAT_YN          -- �Ǹ� ��������      => ����(00055) [Y:����, N:�鼼]
                 ,  'N'         AS SALE_VAT_RULE        -- �Ǹ� VAT ���� ��   => ����(00850) [1:�ΰ�������, 2:�ΰ���������] -> �����
                 ,  0           AS SALE_VAT_IN_RATE     -- ����ũ�� �Ǹ� VAT��
                 ,  0           AS SALE_VAT_OUT_RATE    -- ����ũ�ƿ� �Ǹ� VAT��
                 ,  'N'         AS SALE_SVC_YN          -- �Ǹ� ���� ���� ����
                 ,  ''          AS SALE_SVC_RULE        -- �Ǹ� ����� ����
                 ,  0           AS SALE_SVC_RATE        -- �Ǹ� ���� ��
                 ,  ''          AS SET_GRP              -- ��Ʈ ���� �׷�    => ����(00035)
                 ,  '0'         AS SET_DIV              -- SET ���� ����     => ����(01100) [0:�������, 1:SET ��ǰ , 2:SET ���Ի�ǰ]
                 ,  'N'         AS TODAY_COFFEE_YN      -- ������ Ŀ�ǿ���(���ټ�)
                 ,  '0'         AS SUB_ITEM_DIV         -- �ΰ�/�ɼǰ���     => ����(00050) [0:��������, 1:�ΰ���ǰ, 2:�ɼǻ�ǰ, 3:�ΰ�/�ɼǻ�ǰ]
                 ,  0           AS FLAVOR_QTY           -- �÷��̹� �� �߷�
                 ,  0           AS STOCK_QTY            -- �÷��̹���ǰ ���� ��
                 ,  0           AS EVENT_AMT            -- [POS] ���� ���� ������ 0���� �ִ´�
                 ,  'N'         AS EVENT_DIV            -- [POS] ���� ���� ������ 'N'���� �ִ´�
                 ,  'N'         AS POINT_YN             -- ����Ʈ ��������[YN]
                 ,  ''          AS O_ITEM_CD            -- ��õ���׸޴�
                 ,  'N'         AS OPEN_ITEM_YN         -- ���»�ǰ����
                 ,  '1'         AS DISPOSABLE_DIV       -- ��ȸ��ǰ���� => ����(01325) [1:��ǰ, 2:��ȸ��ǰ(������)]
                 ,  ''          AS PRT_NO               -- �����͹�ȣ
                 ,  I1.USE_YN   AS USE_YN               -- ��� ����
                 ,  ''          AS BAR_CODE             -- ���ڵ� (�ϴ�, �ѻ�ǰ�� ���ؼ��� ������ MAX(BAR_CODE)���� �Ѱ��ش�)
                 ,  ''          AS ALL_PRT_NO           -- ��ǰ�� ����� ������ ��ȣ  => ex) 1^2^3^5
                 ,  'N'         AS AUTO_POPUP_YN        -- POS���� ��ǰ���ý� �˾�â �ٿ�� ���� (�ΰ���ǰ �϶�)
                 ,  'N'         AS EXT_YN               -- �ΰ���ǰ ���� => [Y:�ΰ���ǰ����, N:�λ�ǰ�ƴ�]
                 ,  'N'         AS PARENT_ITEM_YN       -- �θ��ǰ ����
                 ,  I1.ORD_SALE_DIV                     -- �ֹ�/�Ǹű���
                 ,  I1.ITEM_KDS_NM
                 ,  I1.SAV_MLG_YN
              FROM  ITEM_CHAIN      I1
                 ,  (
                        SELECT  COMP_CD
                             ,  BRAND_CD
                             ,  C_ITEM_CD   AS ITEM_CD
                          FROM  RECIPE_BRAND_FOOD
                         WHERE  COMP_CD     = P_COMP_CD
                           AND  BRAND_CD    = P_BRAND_CD
                           AND  UPD_DT >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
                        UNION ALL
                        SELECT  COMP_CD
                             ,  BRAND_CD
                             ,  ITEM_CD
                          FROM  STORE_ITEM_PRT_MULTI
                         WHERE  COMP_CD     = P_COMP_CD
                           AND  BRAND_CD    = P_BRAND_CD
                           AND  STOR_CD     = P_STOR_CD
                           AND  UPD_DT >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
                        UNION ALL
                        SELECT  COMP_CD
                             ,  BRAND_CD
                             ,  ITEM_CD
                          FROM  ITEM_STOCK_PERIOD
                         WHERE  COMP_CD     = P_COMP_CD
                           AND  BRAND_CD    = P_BRAND_CD
                           AND  UPD_DT >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
                        UNION ALL
                        SELECT  COMP_CD
                             ,  BRAND_CD
                             ,  ITEM_CD
                          FROM  ITEM_CHAIN
                         WHERE  COMP_CD     = P_COMP_CD
                           AND  BRAND_CD    = P_BRAND_CD
                           AND  STOR_TP     = (
                                                SELECT  STOR_TP
                                                  FROM  STORE
                                                 WHERE  COMP_CD     = P_COMP_CD
                                                   AND  BRAND_CD    = P_BRAND_CD
                                                   AND  STOR_CD     = P_STOR_CD
                                               )
                           AND  ORD_SALE_DIV IN ('1', '4')
                           AND  USE_YN   LIKE P_USE_YN     
                           AND  UPD_DT >= TO_DATE(P_DOWN_DTM, 'YYYYMMDDHH24MISS')
                    )               I2
             WHERE  I1.COMP_CD  = I2.COMP_CD
               AND  I1.BRAND_CD = I2.BRAND_CD
               AND  I1.ITEM_CD  = I2.ITEM_CD
               AND  I1.COMP_CD  = P_COMP_CD
               AND  I1.BRAND_CD = P_BRAND_CD
               AND  I1.STOR_TP  = (
                                    SELECT  STOR_TP
                                      FROM  STORE
                                     WHERE  COMP_CD     = P_COMP_CD
                                       AND  BRAND_CD    = P_BRAND_CD
                                       AND  STOR_CD     = P_STOR_CD
                                  )
               AND  I1.ORD_SALE_DIV IN ('1', '4')
               AND  I1.USE_YN   LIKE P_USE_YN
               AND  P_DOWN_DTM <= TO_CHAR(I1.UPD_DT, 'YYYYMMDDHH24MISS');
     
    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_A2;
  
  PROCEDURE GET_MASTER_A3 (
    anRetVal OUT NUMBER,   -- ����ڵ�
    asRetMsg OUT VARCHAR2, -- ���� �޽���
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
        SELECT  R.BRAND_CD
             ,  R.P_ITEM_CD
             ,  R.C_ITEM_CD
             ,  R.START_DT
             ,  R.CLOSE_DT
             ,  NVL(R.RCP_QTY, R.DO_QTY)  AS DO_QTY
             ,  R.SORT_SEQ
             ,  R.USE_YN
             ,  R.DISP_QTY
          FROM  RECIPE_BRAND_FOOD   R
             ,  ITEM_CHAIN          I
         WHERE  R.COMP_CD       = I.COMP_CD
           AND  R.BRAND_CD      = I.BRAND_CD
           AND  R.P_ITEM_CD     = I.ITEM_CD
           AND  I.STOR_TP       = (
                                    SELECT  STOR_TP
                                      FROM  STORE
                                     WHERE  COMP_CD     = P_COMP_CD
                                       AND  BRAND_CD    = P_BRAND_CD
                                       AND  STOR_CD     = P_STOR_CD
                                  )
           AND  R.COMP_CD       = P_COMP_CD
           AND  R.BRAND_CD      = P_BRAND_CD
           AND  I.RECIPE_DIV    = '1'
           AND  R.USE_YN        LIKE P_USE_YN
           AND  P_DOWN_DTM     <= TO_CHAR(R.UPD_DT, 'YYYYMMDDHH24MISS')
       CONNECT  BY R.P_ITEM_CD  = PRIOR R.C_ITEM_CD;
     
    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_A3;
  
  --------------------------------------------------------------------------------
  -- Description        : [����]���α׷� ������
  -- Ref. Table         : CS_PROGRAM
  --------------------------------------------------------------------------------
  --  Create Date       : 2016-05-17
  --  Modify Date       : 
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_B0 (
    anRetVal OUT NUMBER,   -- ����ڵ�
    asRetMsg OUT VARCHAR2, -- ���� �޽���
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
        SELECT  PROGRAM_ID
             ,  PROGRAM_NM
             ,  PROGRAM_DIV
             ,  PGM_ITEM_CD
             ,  BASE_USE_TM
             ,  ADD_AMT_YN
             ,  ADD_AMT_TM
             ,  ADD_EXC_TM
             ,  ADD_ITEM_CD
             ,  GDN_AMT_YN
             ,  GDN_CNT
             ,  GDN_ITEM_CD
             ,  ORG_PMN_YN
             ,  ORG_MIN_CNT
             ,  ORG_ITEM_CD
             ,  PGM_MATL_YN
             ,  DD_APP_YN
             ,  PGM_TM_YN
             ,  BRAND_CD
             ,  USE_YN
             ,  TO_CHAR(INST_DT, 'YYYY-MM-DD HH24:MI:SS') AS INST_DT
             ,  INST_USER
             ,  TO_CHAR(UPD_DT,  'YYYY-MM-DD HH24:MI:SS') AS UPD_DT
             ,  UPD_USER
             ,  REF_PROGRAM_ID
             ,  MATL_POP_YN
          FROM  CS_PROGRAM
         WHERE  COMP_CD     = P_COMP_CD
           AND  BRAND_CD    = P_BRAND_CD
           AND  TO_CHAR(UPD_DT, 'YYYYMMDDHH24MISS') >= P_DOWN_DTM 
           AND  USE_YN      LIKE P_USE_YN;
     
    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_B0;
  
  --------------------------------------------------------------------------------
  -- Description        : [����]���α׷� ��� ����
  -- Ref. Table         : CS_PROGRAM_MATL
  --------------------------------------------------------------------------------
  --  Create Date       : 2016-05-17
  --  Modify Date       : 
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_B1 (
    anRetVal OUT NUMBER,   -- ����ڵ�
    asRetMsg OUT VARCHAR2, -- ���� �޽���
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
        SELECT  PROGRAM_ID
             ,  ITEM_CD
             ,  ENTRY_DIV
             ,  CHARGE_YN
             ,  USE_YN
             ,  TO_CHAR(INST_DT, 'YYYY-MM-DD HH24:MI:SS') AS INST_DT
             ,  INST_USER
             ,  TO_CHAR(UPD_DT,  'YYYY-MM-DD HH24:MI:SS') AS UPD_DT
             ,  UPD_USER
          FROM  CS_PROGRAM_MATL
         WHERE  COMP_CD     = P_COMP_CD
           AND  TO_CHAR(UPD_DT, 'YYYYMMDDHH24MISS') >= P_DOWN_DTM 
           AND  USE_YN      LIKE P_USE_YN;
     
    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_B1;
  
  --------------------------------------------------------------------------------
  -- Description        : [����]���α׷� ��ü���� ���� ������
  -- Ref. Table         : CS_PROGRAM_ORG
  --------------------------------------------------------------------------------
  --  Create Date       : 2016-05-17
  --  Modify Date       : 
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_B2 (
    anRetVal OUT NUMBER,   -- ����ڵ�
    asRetMsg OUT VARCHAR2, -- ���� �޽���
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
        SELECT  PROGRAM_ID
             ,  BRAND_CD
             ,  STOR_CD
             ,  ORG_SEQ
             ,  START_CNT
             ,  CLOSE_CNT
             ,  DC_FG
             ,  DC_VALUE
             ,  USE_YN
             ,  TO_CHAR(INST_DT, 'YYYY-MM-DD HH24:MI:SS') AS INST_DT
             ,  INST_USER
             ,  TO_CHAR(UPD_DT,  'YYYY-MM-DD HH24:MI:SS') AS UPD_DT
             ,  UPD_USER
          FROM  CS_PROGRAM_ORG
         WHERE  COMP_CD     = P_COMP_CD
           AND  BRAND_CD    = P_BRAND_CD
           AND  STOR_CD     = P_STOR_CD
           AND  TO_CHAR(UPD_DT, 'YYYYMMDDHH24MISS') >= P_DOWN_DTM 
           AND  USE_YN      LIKE P_USE_YN;
     
    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_B2;
  
  --------------------------------------------------------------------------------
  -- Description        : [����]���α׷� ��������
  -- Ref. Table         : CS_PROGRAM_STORE
  --------------------------------------------------------------------------------
  --  Create Date       : 2016-05-17
  --  Modify Date       : 
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_B3 (
    anRetVal OUT NUMBER,   -- ����ڵ�
    asRetMsg OUT VARCHAR2, -- ���� �޽���
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
        SELECT  PROGRAM_ID
             ,  BRAND_CD
             ,  STOR_CD
             ,  BASE_USE_TM
             ,  ADD_AMT_YN
             ,  ADD_AMT_TM
             ,  ADD_EXC_TM
             ,  GDN_AMT_YN
             ,  GDN_CNT
             ,  ORG_PMN_YN
             ,  DD_APP_YN
             ,  USE_YN
             ,  TO_CHAR(INST_DT, 'YYYY-MM-DD HH24:MI:SS') AS INST_DT
             ,  INST_USER
             ,  TO_CHAR(UPD_DT,  'YYYY-MM-DD HH24:MI:SS') AS UPD_DT
             ,  UPD_USER
             ,  ENTRY_CNT
          FROM  CS_PROGRAM_STORE
         WHERE  COMP_CD     = P_COMP_CD
           AND  BRAND_CD    = P_BRAND_CD
           AND  STOR_CD     = P_STOR_CD
           AND  TO_CHAR(UPD_DT, 'YYYYMMDDHH24MISS') >= P_DOWN_DTM 
           AND  USE_YN      LIKE P_USE_YN;
     
    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_B3;
  
  --------------------------------------------------------------------------------
  -- Description        : [����]���α׷� ���� ��ð�
  -- Ref. Table         : CS_PROGRAM_STORE_TM
  --------------------------------------------------------------------------------
  --  Create Date       : 2016-05-17
  --  Modify Date       : 
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_B4 (
    anRetVal OUT NUMBER,   -- ����ڵ�
    asRetMsg OUT VARCHAR2, -- ���� �޽���
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
        SELECT  PROGRAM_ID
             ,  BRAND_CD
             ,  STOR_CD
             ,  TM_SEQ
             ,  START_TM
             ,  CLOSE_TM
             ,  USE_YN
             ,  TO_CHAR(INST_DT, 'YYYY-MM-DD HH24:MI:SS') AS INST_DT
             ,  INST_USER
             ,  TO_CHAR(UPD_DT,  'YYYY-MM-DD HH24:MI:SS') AS UPD_DT
             ,  UPD_USER
          FROM  CS_PROGRAM_STORE_TM
         WHERE  COMP_CD     = P_COMP_CD
           AND  BRAND_CD    = P_BRAND_CD
           AND  STOR_CD     = P_STOR_CD
           AND  TO_CHAR(UPD_DT, 'YYYYMMDDHH24MISS') >= P_DOWN_DTM 
           AND  USE_YN      LIKE P_USE_YN;
     
    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_B4;
  
  --------------------------------------------------------------------------------
  -- Description        : [����]ȸ���� ������
  -- Ref. Table         : CS_MEMBERSHIP
  --------------------------------------------------------------------------------
  --  Create Date       : 2016-05-17
  --  Modify Date       : 
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_B5 (
    anRetVal OUT NUMBER,   -- ����ڵ�
    asRetMsg OUT VARCHAR2, -- ���� �޽���
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
        SELECT  M.PROGRAM_ID
             ,  M.MBS_NO
             ,  M.MBS_NM
             ,  M.MBS_DIV
             ,  M.USE_DIV
             ,  M.MBS_ITEM_CD
             ,  M.CHARGE_YN
             ,  M.CERT_MONTHS
             ,  M.START_DT
             ,  M.CLOSE_DT
             ,  M.BASE_CALC_TM
             ,  M.BASE_OFFER_TM
             ,  M.BASE_OFFER_CNT
             ,  M.BASE_OFFER_AMT
             ,  M.BASE_OFFER_MCNT
             ,  M.ITEM_DIV
             ,  M.BRAND_CD
             ,  CASE WHEN M.USE_YN = 'N' OR MS.USE_YN = 'N' THEN 'N'
                     ELSE 'Y'
                END                                         AS USE_YN
             ,  TO_CHAR(M.INST_DT, 'YYYY-MM-DD HH24:MI:SS') AS INST_DT
             ,  M.INST_USER
             ,  TO_CHAR(M.UPD_DT,  'YYYY-MM-DD HH24:MI:SS') AS UPD_DT
             ,  M.UPD_USER
          FROM  CS_MEMBERSHIP           M
             ,  CS_MEMBERSHIP_STORE     MS
         WHERE  M.COMP_CD       = MS.COMP_CD
           AND  M.PROGRAM_ID    = MS.PROGRAM_ID
           AND  M.MBS_NO        = MS.MBS_NO    
           AND  M.COMP_CD       = P_COMP_CD
           AND  M.BRAND_CD      = P_BRAND_CD
           AND  MS.USE_BRAND_CD = P_BRAND_CD
           AND  MS.USE_STOR_CD  = P_STOR_CD
           AND  (
                    TO_CHAR(M.UPD_DT, 'YYYYMMDDHH24MISS') >= P_DOWN_DTM
                    OR
                    TO_CHAR(MS.UPD_DT, 'YYYYMMDDHH24MISS') >= P_DOWN_DTM
                )
           AND  MS.USE_YN       LIKE P_USE_YN;           
     
    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_B5;
  
  --------------------------------------------------------------------------------
  -- Description        : [����]����ɼ� ������
  -- Ref. Table         : CS_OPTION
  --------------------------------------------------------------------------------
  --  Create Date       : 2016-05-17
  --  Modify Date       : 
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_B6 (
    anRetVal OUT NUMBER,   -- ����ڵ�
    asRetMsg OUT VARCHAR2, -- ���� �޽���
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
        SELECT  OPTION_CD
             ,  OPTION_NM
             ,  OPT_ITEM_CD
             ,  USE_YN
             ,  TO_CHAR(INST_DT, 'YYYY-MM-DD HH24:MI:SS') AS INST_DT
             ,  INST_USER
             ,  TO_CHAR(UPD_DT,  'YYYY-MM-DD HH24:MI:SS') AS UPD_DT
             ,  UPD_USER
          FROM  CS_OPTION
         WHERE  COMP_CD     = P_COMP_CD
           AND  TO_CHAR(UPD_DT, 'YYYYMMDDHH24MISS') >= P_DOWN_DTM 
           AND  USE_YN      LIKE P_USE_YN;
     
    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_B6;
  
  --------------------------------------------------------------------------------
  -- Description        : [����]����ɼ� �����Ҵ� ������
  -- Ref. Table         : CS_OPTION_STORE
  --------------------------------------------------------------------------------
  --  Create Date       : 2016-05-17
  --  Modify Date       : 
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_B7 (
    anRetVal OUT NUMBER,   -- ����ڵ�
    asRetMsg OUT VARCHAR2, -- ���� �޽���
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
        SELECT  OPTION_CD
             ,  BRAND_CD
             ,  STOR_CD
             ,  USE_YN
             ,  TO_CHAR(INST_DT, 'YYYY-MM-DD HH24:MI:SS') AS INST_DT
             ,  INST_USER
             ,  TO_CHAR(UPD_DT,  'YYYY-MM-DD HH24:MI:SS') AS UPD_DT
             ,  UPD_USER
          FROM  CS_OPTION_STORE
         WHERE  COMP_CD     = P_COMP_CD
           AND  BRAND_CD    = P_BRAND_CD
           AND  STOR_CD     = P_STOR_CD
           AND  TO_CHAR(UPD_DT, 'YYYYMMDDHH24MISS') >= P_DOWN_DTM 
           AND  USE_YN      LIKE P_USE_YN;
     
    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_B7;
  
  --------------------------------------------------------------------------------
  -- Description        : [����]ȸ���� ����ǰ ������
  -- Ref. Table         : CS_MEMBERSHIP_ITEM
  --------------------------------------------------------------------------------
  --  Create Date       : 2016-05-17
  --  Modify Date       : 
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_B8 (
    anRetVal OUT NUMBER,   -- ����ڵ�
    asRetMsg OUT VARCHAR2, -- ���� �޽���
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
        SELECT  MI.PROGRAM_ID
             ,  MI.MBS_NO
             ,  MI.ITEM_CD
             ,  MI.USE_YN
             ,  TO_CHAR(MI.INST_DT, 'YYYY-MM-DD HH24:MI:SS') AS INST_DT
             ,  MI.INST_USER
             ,  TO_CHAR(MI.UPD_DT,  'YYYY-MM-DD HH24:MI:SS') AS UPD_DT
             ,  MI.UPD_USER
          FROM  CS_MEMBERSHIP_ITEM  MI
             ,  CS_MEMBERSHIP       M
         WHERE  MI.COMP_CD      = M.COMP_CD
           AND  MI.PROGRAM_ID   = M.PROGRAM_ID
           AND  MI.MBS_NO       = M.MBS_NO
           AND  MI.COMP_CD      = P_COMP_CD
           AND  M.BRAND_CD      = P_BRAND_CD
           AND  TO_CHAR(MI.UPD_DT, 'YYYYMMDDHH24MISS') >= P_DOWN_DTM 
           AND  MI.USE_YN       LIKE P_USE_YN;
     
    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_B8;
  
  --------------------------------------------------------------------------------
  -- Description        : [����]SMS������
  -- Ref. Table         : CS_CONTENT
  --------------------------------------------------------------------------------
  --  Create Date       : 2016-07-01
  --  Modify Date       : 
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_B9 (
    anRetVal OUT NUMBER,   -- ����ڵ�
    asRetMsg OUT VARCHAR2, -- ���� �޽���
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
        SELECT  CONTENT_SEQ
             ,  SUBJECT
             ,  CONTENT
             ,  CONTENT_DIV
             ,  CONTENT_FG
             ,  USE_YN
          FROM  CS_CONTENT
         WHERE  COMP_CD     = P_COMP_CD
           AND  BRAND_CD    = P_BRAND_CD
           AND  TO_CHAR(UPD_DT, 'YYYYMMDDHH24MISS') >= P_DOWN_DTM 
           AND  USE_YN      LIKE P_USE_YN
           AND  CONTENT_FG  IN ('10', '3');
     
    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_B9;
  
  --------------------------------------------------------------------------------
  -- Description        : [����]����������
  -- Ref. Table         : M_COUPON_MST
  --------------------------------------------------------------------------------
  --  Create Date       : 2016-11-10
  --  Modify Date       : 
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_C0 (
    anRetVal OUT NUMBER,   -- ����ڵ�
    asRetMsg OUT VARCHAR2, -- ���� �޽���
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
        SELECT  CM.COUPON_CD
             ,  CM.COUPON_NM
             ,  CM.ISSUE_DT
             ,  CM.COUPON_DIV
             ,  CM.CERT_YN
             ,  CM.DEAL_ID
             ,  CM.COUPON_MSG
             ,  CM.COUPON_RMK
             ,  CM.START_DT
             ,  CM.CLOSE_DT
             ,  CM.CUST_CNT
             ,  CM.COUPON_STAT
             ,  CM.CONF_DT
             ,  CM.USE_YN
             ,  CM.UPD_DT
             ,  CM.INST_DT
          FROM  M_COUPON_MST    CM
             ,  M_COUPON_STORE  CS
         WHERE  CM.COMP_CD  = CS.COMP_CD
           AND  CM.COUPON_CD= CS.COUPON_CD
           AND  CM.COMP_CD  = P_COMP_CD
           AND  CM.COUPON_STAT = '2'
           AND  CS.BRAND_CD = P_BRAND_CD
           AND  CS.STOR_CD  = P_STOR_CD
           AND  (
                    TO_CHAR(CM.UPD_DT, 'YYYYMMDDHH24MISS') >= P_DOWN_DTM
                    OR
                    TO_CHAR(CS.UPD_DT, 'YYYYMMDDHH24MISS') >= P_DOWN_DTM
                ) 
           AND  CM.USE_YN   LIKE P_USE_YN
           AND  CS.USE_YN   LIKE P_USE_YN;
     
    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_C0;
  
  --------------------------------------------------------------------------------
  -- Description        : [����]����������
  -- Ref. Table         : M_COUPON_STORE
  --------------------------------------------------------------------------------
  --  Create Date       : 2016-11-10
  --  Modify Date       : 
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_C1 (
    anRetVal OUT NUMBER,   -- ����ڵ�
    asRetMsg OUT VARCHAR2, -- ���� �޽���
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
        SELECT  CS.COUPON_CD
             ,  CS.BRAND_CD
             ,  CS.STOR_CD
             ,  CS.STOR_ID
             ,  CS.USE_YN
             ,  CS.UPD_DT
             ,  CS.INST_DT
          FROM  M_COUPON_MST    CM
             ,  M_COUPON_STORE  CS
         WHERE  CM.COMP_CD  = CS.COMP_CD
           AND  CM.COUPON_CD= CS.COUPON_CD
           AND  CM.COMP_CD  = P_COMP_CD
           AND  CM.COUPON_STAT = '2'
           AND  CS.BRAND_CD = P_BRAND_CD
           AND  CS.STOR_CD  = P_STOR_CD
           AND  (
                    TO_CHAR(CM.UPD_DT, 'YYYYMMDDHH24MISS') >= P_DOWN_DTM
                    OR
                    TO_CHAR(CS.UPD_DT, 'YYYYMMDDHH24MISS') >= P_DOWN_DTM
                )
           AND  CM.USE_YN   LIKE P_USE_YN
           AND  CS.USE_YN   LIKE P_USE_YN;
     
    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_C1;
  
  --------------------------------------------------------------------------------
  -- Description        : [����]��������ǰ
  -- Ref. Table         : M_COUPON_ITEM
  --------------------------------------------------------------------------------
  --  Create Date       : 2016-11-10
  --  Modify Date       : 
  --------------------------------------------------------------------------------
  PROCEDURE GET_MASTER_C2 (
    anRetVal OUT NUMBER,   -- ����ڵ�
    asRetMsg OUT VARCHAR2, -- ���� �޽���
    p_cursor OUT rec_set.m_refcur
  ) IS
  BEGIN
    OPEN p_cursor FOR
        SELECT  CI.COUPON_CD
             ,  CI.ITEM_CD
             ,  CI.ITEM_ID
             ,  CI.SALE_AMT
             ,  CI.USE_AMT
             ,  CI.USE_YN
             ,  CI.UPD_DT
             ,  CI.INST_DT
          FROM  M_COUPON_MST    CM
             ,  M_COUPON_STORE  CS
             ,  M_COUPON_ITEM   CI
         WHERE  CM.COMP_CD  = CS.COMP_CD
           AND  CM.COUPON_CD= CS.COUPON_CD
           AND  CM.COMP_CD  = CI.COMP_CD
           AND  CM.COUPON_CD= CI.COUPON_CD
           AND  CM.COMP_CD  = P_COMP_CD
           AND  CM.COUPON_STAT = '2'
           AND  CS.BRAND_CD = P_BRAND_CD
           AND  CS.STOR_CD  = P_STOR_CD
           AND  (
                    TO_CHAR(CM.UPD_DT, 'YYYYMMDDHH24MISS') >= P_DOWN_DTM
                    OR
                    TO_CHAR(CS.UPD_DT, 'YYYYMMDDHH24MISS') >= P_DOWN_DTM
                    OR
                    TO_CHAR(CI.UPD_DT, 'YYYYMMDDHH24MISS') >= P_DOWN_DTM
                ) 
           AND  CM.USE_YN   LIKE P_USE_YN
           AND  CS.USE_YN   LIKE P_USE_YN
           AND  CI.USE_YN   LIKE P_USE_YN;
     
    anRetVal := 1;
    asRetMsg := 'OK';
  EXCEPTION
    WHEN OTHERS THEN
         asRetMsg := SQLERRM(SQLCODE);
         anRetVal := SQLCODE;
  END GET_MASTER_C2;
  
END PKG_POS_IF_GET;

/
