--------------------------------------------------------
--  DDL for Procedure AAA_MIG_POINT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."AAA_MIG_POINT" AS 
BEGIN
  DECLARE 
        L_COUNT             NUMBER := 1;
        IS_END              NUMBER := 0;
        CURSOR_NEW_PK       NUMBER;
        CURSOR_CARD_ID	    VARCHAR2(100);
        CURSOR_USE_DT       VARCHAR2(8);
        CURSOR_SAV_USE_FG	  VARCHAR2(1);
        CURSOR_SAV_USE_DIV	VARCHAR2(3);
        CURSOR_SAV_PT	      NUMBER;
        CURSOR_USE_PT	      NUMBER;
        CURSOR_LOS_PT	      NUMBER;
        CURSOR_STOR_CD	    VARCHAR2(20);
        CURSOR_POS_NO	      VARCHAR2(2);
        CURSOR_BILL_NO	    VARCHAR2(5);
        CURSOR_USE_TM       VARCHAR2(6);
        CURSOR_INST_DT	    DATE;
        CURSOR_INST_USER	  VARCHAR2(30);
        CURSOR_UPD_USER	    VARCHAR2(30);
        CURSOR_LOS_PT_DT    DATE;
BEGIN
        LOOP
                DBMS_OUTPUT.PUT_LINE('커서 100개씩 ' ||L_COUNT|| '번째 오픈');
                
                IF  7416190 < (L_COUNT * 100) THEN
                    EXIT;
                END IF;
                
                DECLARE CURSOR  CURSOR_MIG IS
                SELECT  X.NEW_PK,
                        X.CARD_ID,
                        X.USE_DT,
                        X.SAV_USE_FG,
                        X.SAV_USE_DIV,
                        X.REMARKS,
                        X.SAV_PT,
                        X.USE_PT,
                        X.STOR_CD,
                        X.POS_NO,
                        X.BILL_NO,
                        X.USE_TM,
                        X.INST_DT,
                        X.UPD_USER,
                        X.LOS_PT_DT
                FROM    (
                                select  A.NEW_PK,
                                        ENCRYPT(A.CARD_ID) AS CARD_ID,
                                        TO_CHAR(CAST(TO_TIMESTAMP(A.USE_DT, 'YYYY-MM-DD HH24:MI:SS.FF3') AS DATE), 'YYYYMMDD') AS USE_DT,
                                        DECODE(A.SAV_USE_FG, '3', '3', '2', '4') AS SAV_USE_FG,
                                        CASE  WHEN  A.SAV_USE_FG = '3'  THEN '201'
                                              WHEN A.SAV_USE_FG = '2' AND A.USE_PT > 0 THEN '301'
                                              WHEN A.SAV_USE_FG = '2' AND A.USE_PT < 0 THEN '302'
                                              ELSE '' 
                                        END AS SAV_USE_DIV,
                                        CASE  WHEN A.SAV_USE_FG = '3' THEN '포인트적립'
                                              WHEN A.SAV_USE_FG = '2' AND A.USE_PT > 0 THEN '포인트사용'
                                              WHEN A.SAV_USE_FG = '2' AND A.USE_PT < 0 THEN '포인트사용취소'
                                              ELSE '' 
                                        END AS REMARKS,
                                        A.SAV_PT AS SAV_PT,
                                        A.USE_PT AS USE_PT,
                                        NVL((SELECT STOR_CD FROM STORE_CD_MAP@HPOSDB WHERE ASIS_STOR_CD = A.STOR_CD), 'OLD_' || A.STOR_CD) AS STOR_CD,
                                        A.POS_NO AS POS_NO,
                                        A.BILL_NO AS BILL_NO,
                                        TO_CHAR(CAST(TO_TIMESTAMP(A.USE_TM, 'YYYY-MM-DD HH24:MI:SS.FF3') AS DATE), 'HH24MISS') AS USE_TM,
                                        CAST(TO_TIMESTAMP(A.INST_DT, 'YYYY-MM-DD HH24:MI:SS.FF3') AS DATE) AS INST_DT,
                                        A.UPD_USER AS UPD_USER,
                                        TO_CHAR(CAST(TO_TIMESTAMP(A.LOS_PT_DT, 'YYYY-MM-DD HH24:MI:SS.FF3') AS DATE), 'YYYYMMDD') AS LOS_PT_DT
                                from    C_CARD_SAV_HIS_TEMP_ACCDB A
                                WHERE   MIG_YN = 'N'
                                ORDER   BY
                                        A.NEW_PK
                        )
                  WHERE ROWNUM <= 100;
                  
                  BEGIN
                          OPEN    CURSOR_MIG;
                          
                          LOOP
                                  FETCH CURSOR_SEARCH
                                  INTO  CURSOR_NEW_PK,
                                        CURSOR_CARD_ID,
                                        CURSOR_USE_DT,
                                        CURSOR_SAV_USE_FG,
                                        CURSOR_SAV_USE_DIV,
                                        CURSOR_SAV_PT,
                                        CURSOR_USE_PT,
                                        CURSOR_LOS_PT,
                                        CURSOR_STOR_CD,
                                        CURSOR_POS_NO,
                                        CURSOR_BILL_NO,
                                        CURSOR_USE_TM,
                                        CURSOR_INST_DT,
                                        CURSOR_INST_USER,
                                        CURSOR_UPD_USER,
                                        CURSOR_LOS_PT_DT;
                                  EXIT  WHEN  CURSOR_MIG%NOTFOUND;
                                  
                                  INSERT INTO C_CARD_SAV_HIS (
                                              COMP_CD
                                              ,CARD_ID
                                              ,USE_DT
                                              ,USE_SEQ
                                              ,SAV_USE_FG
                                              ,SAV_USE_DIV
                                              ,REMARKS
                                              ,SAV_PT
                                              ,USE_PT
                                              ,BRAND_CD
                                              ,STOR_CD
                                              ,POS_NO
                                              ,BILL_NO
                                              ,USE_TM
                                              ,USE_YN
                                              ,INST_DT
                                              ,INST_USER
                                              ,UPD_USER
                                              ,LOS_PT_YN
                                              ,LOS_PT_DT
                                  )           VALUES          (
                                               '016',
                                              CURSOR_CARD_ID,
                                              CURSOR_USE_DT,
                                              SQ_PCRM_SEQ.NEXTVAL,
                                              CURSOR_SAV_USE_FG,
                                              CURSOR_SAV_USE_DIV,
                                              CURSOR_REMARKS,
                                              CURSOR_SAV_PT,
                                              CURSOR_USE_PT,
                                              '100',
                                              CURSOR_STOR_CD,
                                              CURSOR_POS_NO,
                                              CURSOR_BILL_NO,
                                              CURSOR_USE_TM,
                                              'Y',
                                              CURSOR_INST_DT,
                                              'SYSTEM',
                                              CURSOR_UPD_USER,
                                              'N',
                                              CURSOR_LOS_PT_DT
                                  );
                                  
                                  UPDATE      C_CARD_SAV_HIS_TEMP_ACCDB
                                  SET         MIG_YN = 'Y'
                                  WHERE       NEW_PK = CURSOR_NEW_PK;
                                  
                          END LOOP;
                  END;
                  
                  L_COUNT := L_COUNT + 1;
                  DBMS_OUTPUT.PUT_LINE('커서 100개 완료');
                  COMMIT;

        END LOOP;

        DBMS_OUTPUT.PUT_LINE('데이터 입력 완료');
END;
END AAA_MIG_POINT;

/
