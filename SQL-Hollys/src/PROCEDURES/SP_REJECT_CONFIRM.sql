--------------------------------------------------------
--  DDL for Procedure SP_REJECT_CONFIRM
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_REJECT_CONFIRM" 
( 
  asCompCd     IN  VARCHAR2, -- 회사코드
  asRjtDt      IN  VARCHAR2, -- 반품일자
  asBrandCd    IN  VARCHAR2, -- 영업조직
  asStorCd     IN  VARCHAR2, -- 점포코드
  asRjtDiv     IN  VARCHAR2, -- 반품구분[01165>1:정기, 2:행사, 3:이벤트, 4:제도, 5:클레임, 6:고객클레임]
  asSlipNo     IN  VARCHAR2, -- 담당자 ID
  asFlag       IN  VARCHAR2, -- 수불 반영 구분[0:반품 처리, 1:반품취소 처리]
  asRetVal     OUT VARCHAR2,
  asRetMsg     OUT VARCHAR2
) IS
--------------------------------------------------------------------------------
--  Procedure Name   : SP_REJECT_CONFIRM
--  Description      : 반품자료를 점포에서 확정시 수불에 반영.
--  Ref. Table       : REJECT_HD
--                     REJECT_DT
--------------------------------------------------------------------------------
--  Create Date      : 2010-05-24
--  Modify Date      : 2010-05-24
--------------------------------------------------------------------------------
  
  ldCost            ITEM.COST%TYPE;
  ldPric            ITEM.SALE_PRC%TYPE;
  lsStorTp          STORE.STOR_TP%TYPE;
  liRjtQty          NUMBER(10);
  lsLine            VARCHAR2(3) := '000';

  ERR_HANDLER       EXCEPTION;

  CURSOR C_Item IS
  SELECT *
    FROM REJECT_DT
   WHERE COMP_CD  = asCompCd
     AND RJT_DT   = asRjtDt
     AND BRAND_CD = asBrandCd
     AND STOR_CD  = asStorCd
     AND RJT_DIV  = asRjtDiv
     AND SLIP_NO  = asSlipNo;

BEGIN

  dbms_output.enable( 1000000 );

  BEGIN
     SELECT STOR_TP
       INTO lsStorTp
       FROM STORE
      WHERE COMP_CD  = asCompCd
        AND BRAND_CD = asBrandCd
        AND STOR_CD  = asStorCd
        AND USE_YN   = 'Y';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
         asRetMsg := '미등록된 점포 코드 입니다.';
         asRetVal := '0';
         dbms_output.put_line(asRetVal);
         RAISE ERR_HANDLER;
  END;

  lsLine := '010';

  FOR R IN C_Item LOOP
      lsLine := '020';
      SP_GET_ITEM_COST(asCompCd, asBrandCd, asStorCd, R.ITEM_CD, R.RJT_DT, ldCost, ldPric);

      lsLine := '040';
      IF ( asFlag = '0' ) THEN
         liRjtQty := R.RJT_QTY * R.UNIT_QTY;
      ELSE
         liRjtQty := R.RJT_QTY * R.UNIT_QTY * -1;
      END IF;

      lsLine := '050';
      UPDATE DSTOCK
         SET RTN_QTY  = RTN_QTY + liRjtQty
       WHERE COMP_CD  = asCompCd
         AND PRC_DT   = R.RJT_DT
         AND BRAND_CD = R.BRAND_CD
         AND STOR_CD  = R.STOR_CD
         AND ITEM_CD  = R.ITEM_CD ;

      lsLine := '060';
      IF ( SQL%NOTFOUND ) THEN
         INSERT INTO DSTOCK
                (  COMP_CD
                 , PRC_DT
                 , BRAND_CD
                 , STOR_CD
                 , ITEM_CD
                 , COST
                 , SALE_PRC
                 , RTN_QTY
                 )
          VALUES
               (   asCompCd
                 , R.RJT_DT
                 , R.BRAND_CD
                 , R.STOR_CD
                 , R.ITEM_CD
                 , ldCost
                 , ldPric
                 , liRjtQty
                );
      END IF;
  END LOOP;

  lsLine := '100';

  asRetVal := '1' ;
  asRetMsg := 'OK';

  dbms_output.put_line(asRetVal);

EXCEPTION
  WHEN ERR_HANDLER THEN
       NULL;
  WHEN OTHERS THEN
       asRetMsg := '[' || lsLine || '] ' || SQLERRM(SQLCODE);
       asRetVal := TO_CHAR(SQLCODE);
       dbms_output.put_line(asRetVal);
END SP_REJECT_CONFIRM;

/
