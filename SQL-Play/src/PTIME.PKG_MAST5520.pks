CREATE OR REPLACE PACKAGE       PKG_MAST5520 AS

    ---------------------------------------------------------------------------------------------------
    --  Package Name     : PKG_MAST5520
    --  Description      : ���������� ��� 
    -- Ref. Table        :
    ---------------------------------------------------------------------------------------------------
    
    PROCEDURE SP_MAIN_ITEM_STOR_CHG
    ( 
        PSV_COMP_CD             IN  VARCHAR2 ,              -- ȸ���ڵ�
        PSV_USER_ID             IN  VARCHAR2 ,              -- �����
        PSV_LANG_CD             IN  VARCHAR2 ,              -- Language Code
        PSV_BRAND_CD            IN  VARCHAR2 ,              -- ��������
        PSV_STOR_CD             IN  VARCHAR2 ,              -- �����ڵ�
        PSV_ITEM_CD             IN  VARCHAR2 ,              -- ��ǰ�ڵ�
        PSV_START_DT            IN  VARCHAR2 ,              -- ��������
        PSV_CLOSE_DT            IN  VARCHAR2 ,              -- ��������
        PSV_CHANGE_DIV          IN  VARCHAR2 ,              -- ���汸��(1:�Ű�����, 2:��������)
        PSV_SALE_PRC            IN  VARCHAR2 ,              -- �ǸŰ���
        PSV_STOR_SALE_PRC       IN  VARCHAR2 ,              -- �����ǸŰ���
        PSV_SALE_VAT_YN         IN  VARCHAR2 ,              -- �Ǹ� ��������[00055> Y:����, N:�鼼]
        PSV_SALE_VAT_RULE       IN  VARCHAR2 ,              -- �Ǹ� VAT����[00850> 1:�ΰ�������, 2:�ΰ���������]
        PSV_SALE_VAT_IN_RATE    IN  VARCHAR2 ,              -- �Ǹ� VAT��[EAT-IN]
        PSV_SALE_VAT_OUT_RATE   IN  VARCHAR2 ,              -- �Ǹ� VAT��[TAKE-OUT]
        PR_RTN_CD               OUT VARCHAR2 ,              -- ó���ڵ�
        PR_RTN_MSG              OUT VARCHAR2                -- ó��Message
    );

END PKG_MAST5520;

/

CREATE OR REPLACE PACKAGE BODY       PKG_MAST5520 AS

    PROCEDURE SP_MAIN_ITEM_STOR_CHG
    ( 
        PSV_COMP_CD             IN  VARCHAR2 ,              -- ȸ���ڵ�
        PSV_USER_ID             IN  VARCHAR2 ,              -- �����
        PSV_LANG_CD             IN  VARCHAR2 ,              -- Language Code
        PSV_BRAND_CD            IN  VARCHAR2 ,              -- ��������
        PSV_STOR_CD             IN  VARCHAR2 ,              -- �����ڵ�
        PSV_ITEM_CD             IN  VARCHAR2 ,              -- ��ǰ�ڵ�
        PSV_START_DT            IN  VARCHAR2 ,              -- ��������
        PSV_CLOSE_DT            IN  VARCHAR2 ,              -- ��������
        PSV_CHANGE_DIV          IN  VARCHAR2 ,              -- ���汸��(1:�Ű�����, 2:��������)
        PSV_SALE_PRC            IN  VARCHAR2 ,              -- �ǸŰ���
        PSV_STOR_SALE_PRC       IN  VARCHAR2 ,              -- �����ǸŰ���
        PSV_SALE_VAT_YN         IN  VARCHAR2 ,              -- �Ǹ� ��������[00055> Y:����, N:�鼼]
        PSV_SALE_VAT_RULE       IN  VARCHAR2 ,              -- �Ǹ� VAT����[00850> 1:�ΰ�������, 2:�ΰ���������]
        PSV_SALE_VAT_IN_RATE    IN  VARCHAR2 ,              -- �Ǹ� VAT��[EAT-IN]
        PSV_SALE_VAT_OUT_RATE   IN  VARCHAR2 ,              -- �Ǹ� VAT��[TAKE-OUT]
        PR_RTN_CD               OUT VARCHAR2 ,              -- ó���ڵ�
        PR_RTN_MSG              OUT VARCHAR2                -- ó��Message
    )
    IS
    /******************************************************************************
        NAME:       SP_MAIN_ITEM_STOR_CHG     ����ǰ �ܰ� ����
        PURPOSE:
        
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-05-06         1. CREATED THIS PROCEDURE.
        
        NOTES:
            OBJECT NAME :   SP_MAIN_ITEM_STOR_CHG
            SYSDATE     :   2016-05-19
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
        TYPE TPY_LAST_ITEM_HIS IS RECORD
        (
            COMP_CD             ITEM_STORE.COMP_CD%TYPE,
            BRAND_CD            ITEM_STORE.BRAND_CD%TYPE,
            STOR_CD             ITEM_STORE.STOR_CD%TYPE,
            ITEM_CD             ITEM_STORE.ITEM_CD%TYPE,
            OLD_START_DT        ITEM_STORE.SALE_START_DT%TYPE,
            NEW_START_DT        ITEM_STORE.SALE_START_DT%TYPE,
            SALE_CLOSE_DT       ITEM_STORE.SALE_CLOSE_DT%TYPE,
            PRC_CHANGE_DIV      ITEM_STORE.PRC_CHANGE_DIV%TYPE,
            SALE_PRC            ITEM_STORE.SALE_PRC%TYPE,
            STOR_SALE_PRC       ITEM_STORE.STOR_SALE_PRC%TYPE,
            SALE_VAT_YN         ITEM_STORE.SALE_VAT_YN%TYPE,
            SALE_VAT_RULE       ITEM_STORE.SALE_VAT_RULE%TYPE,
            SALE_VAT_IN_RATE    ITEM_STORE.SALE_VAT_IN_RATE%TYPE,
            SALE_VAT_OUT_RATE   ITEM_STORE.SALE_VAT_OUT_RATE%TYPE,
            USE_YN              ITEM_STORE.USE_YN%TYPE
        );
                     
        CURSOR CUR_1 IS  -- �Էµ� �� �ٷ� ������ ���
            SELECT  COMP_CD
                  , BRAND_CD
                  , STOR_CD
                  , ITEM_CD
                  , SALE_START_DT
                  , SALE_CLOSE_DT
                  , PRC_CHANGE_DIV
                  , SALE_PRC
                  , STOR_SALE_PRC
                  , SALE_VAT_YN
                  , SALE_VAT_RULE
                  , SALE_VAT_IN_RATE
                  , SALE_VAT_OUT_RATE
                  , USE_YN
            FROM   (      
                    SELECT  COMP_CD
                          , BRAND_CD
                          , STOR_CD
                          , ITEM_CD
                          , SALE_START_DT
                          , SALE_CLOSE_DT
                          , PRC_CHANGE_DIV
                          , SALE_PRC
                          , STOR_SALE_PRC
                          , SALE_VAT_YN
                          , SALE_VAT_RULE
                          , SALE_VAT_IN_RATE
                          , SALE_VAT_OUT_RATE
                          , USE_YN
                          , ROW_NUMBER() OVER(ORDER BY SALE_START_DT DESC) R_NUM
                    FROM    ITEM_STORE
                    WHERE   COMP_CD       = PSV_COMP_CD
                    AND     BRAND_CD      = PSV_BRAND_CD
                    AND     STOR_CD       = PSV_STOR_CD
                    AND     ITEM_CD       = PSV_ITEM_CD
                    AND     SALE_START_DT < PSV_START_DT
                    AND     USE_YN        = 'Y'
                   )
            WHERE   R_NUM = 1;

        CURSOR CUR_2 IS  -- �Էµ� �� �ٷ� ���İ� ���
            SELECT  COMP_CD
                  , BRAND_CD
                  , STOR_CD
                  , ITEM_CD
                  , SALE_START_DT
                  , SALE_CLOSE_DT
                  , PRC_CHANGE_DIV
                  , SALE_PRC
                  , STOR_SALE_PRC
                  , SALE_VAT_YN
                  , SALE_VAT_RULE
                  , SALE_VAT_IN_RATE
                  , SALE_VAT_OUT_RATE
                  , USE_YN
            FROM   (      
                    SELECT  COMP_CD
                          , BRAND_CD
                          , STOR_CD
                          , ITEM_CD
                          , SALE_START_DT
                          , SALE_CLOSE_DT
                          , PRC_CHANGE_DIV
                          , SALE_PRC
                          , STOR_SALE_PRC
                          , SALE_VAT_YN
                          , SALE_VAT_RULE
                          , SALE_VAT_IN_RATE
                          , SALE_VAT_OUT_RATE
                          , USE_YN
                          , ROW_NUMBER() OVER(ORDER BY SALE_START_DT) R_NUM
                    FROM    ITEM_STORE
                    WHERE   COMP_CD       = PSV_COMP_CD
                    AND     BRAND_CD      = PSV_BRAND_CD
                    AND     STOR_CD       = PSV_STOR_CD
                    AND     ITEM_CD       = PSV_ITEM_CD
                    AND     SALE_START_DT > PSV_START_DT
                    AND     USE_YN        = 'Y'
                   )
            WHERE   R_NUM = 1;
        
        CURSOR CUR_3 IS  -- �Էµ� ���ڵ��� ������ ���� ū ���ڵ� �� ���� ���� ���ڵ�
            SELECT  COMP_CD
                  , BRAND_CD
                  , STOR_CD
                  , ITEM_CD
                  , SALE_START_DT                                              AS OLD_START_DT
                  , TO_CHAR(TO_DATE(PSV_CLOSE_DT, 'YYYYMMDD') + 1, 'YYYYMMDD') AS NEW_START_DT
                  , SALE_CLOSE_DT
                  , PRC_CHANGE_DIV
                  , SALE_PRC
                  , STOR_SALE_PRC
                  , SALE_VAT_YN
                  , SALE_VAT_RULE
                  , SALE_VAT_IN_RATE
                  , SALE_VAT_OUT_RATE
                  , USE_YN
            FROM   (      
                    SELECT  COMP_CD
                          , BRAND_CD
                          , STOR_CD
                          , ITEM_CD
                          , SALE_START_DT
                          , SALE_CLOSE_DT
                          , PRC_CHANGE_DIV
                          , SALE_PRC
                          , STOR_SALE_PRC
                          , SALE_VAT_YN
                          , SALE_VAT_RULE
                          , SALE_VAT_IN_RATE
                          , SALE_VAT_OUT_RATE
                          , USE_YN
                          , ROW_NUMBER() OVER(ORDER BY SALE_CLOSE_DT) R_NUM
                    FROM    ITEM_STORE
                    WHERE   COMP_CD       = PSV_COMP_CD
                    AND     BRAND_CD      = PSV_BRAND_CD
                    AND     STOR_CD       = PSV_STOR_CD
                    AND     ITEM_CD       = PSV_ITEM_CD
                    AND     SALE_CLOSE_DT > PSV_CLOSE_DT
                    AND     USE_YN        = 'Y'
                   )
            WHERE   R_NUM = 1;
        
        ls_sql_main     VARCHAR2(30000) := '';
            
        ERR_HANDLER     EXCEPTION;
        
        tLAST_ITEM_HIS  TPY_LAST_ITEM_HIS;
        vMOD_CLOSE_DT   ITEM_STORE.SALE_CLOSE_DT%TYPE;
        vCMP_START_DT   ITEM_STORE.SALE_START_DT%TYPE;
        vCMP_CLOSE_DT   ITEM_STORE.SALE_START_DT%TYPE;
        vDUP_DATA_INFO  VARCHAR2(30) := NULL;
        
        nRECCNT         NUMBER(6) := 0;
        nMAXCNT         NUMBER(6) := 0;
    BEGIN
        SELECT  COUNT(*), MIN(SALE_START_DT)||'~'||MAX(SALE_CLOSE_DT)
        INTO nRECCNT, vDUP_DATA_INFO
        FROM    ITEM_STORE
        WHERE   COMP_CD       = PSV_COMP_CD
        AND     BRAND_CD      = PSV_BRAND_CD
        AND     STOR_CD       = PSV_STOR_CD
        AND     ITEM_CD       = PSV_ITEM_CD
        AND     SALE_START_DT > PSV_START_DT
        AND     SALE_CLOSE_DT < PSV_CLOSE_DT
        AND     USE_YN        = 'Y';
        
        IF nRECCNT > 0 THEN
            PR_RTN_CD  := '1300';
            PR_RTN_MSG := '['||PSV_ITEM_CD||']['||vDUP_DATA_INFO||']'||FC_GET_WORDPACK_MSG(PSV_COMP_CD, LOWER(PSV_LANG_CD), '1010001483');
            
            RAISE ERR_HANDLER;
        END IF;
                    
        -- �ű� ���ڵ��� ���� ���ں��� ū ���ڵ��� ���� ���� ���ڵ� ���� ����
        FOR MYREC3 IN CUR_3 LOOP
            nRECCNT := nRECCNT + 1;
            tLAST_ITEM_HIS.COMP_CD           := MYREC3.COMP_CD;
            tLAST_ITEM_HIS.BRAND_CD          := MYREC3.BRAND_CD;
            tLAST_ITEM_HIS.STOR_CD           := MYREC3.STOR_CD;
            tLAST_ITEM_HIS.ITEM_CD           := MYREC3.ITEM_CD;
            tLAST_ITEM_HIS.OLD_START_DT      := MYREC3.OLD_START_DT;
            tLAST_ITEM_HIS.NEW_START_DT      := MYREC3.NEW_START_DT;
            tLAST_ITEM_HIS.SALE_CLOSE_DT     := MYREC3.SALE_CLOSE_DT;
            tLAST_ITEM_HIS.PRC_CHANGE_DIV    := MYREC3.PRC_CHANGE_DIV;
            tLAST_ITEM_HIS.SALE_PRC          := MYREC3.SALE_PRC;
            tLAST_ITEM_HIS.STOR_SALE_PRC     := MYREC3.STOR_SALE_PRC;
            tLAST_ITEM_HIS.SALE_VAT_YN       := MYREC3.SALE_VAT_YN;
            tLAST_ITEM_HIS.SALE_VAT_RULE     := MYREC3.SALE_VAT_RULE;
            tLAST_ITEM_HIS.SALE_VAT_IN_RATE  := MYREC3.SALE_VAT_IN_RATE;
            tLAST_ITEM_HIS.SALE_VAT_OUT_RATE := MYREC3.SALE_VAT_OUT_RATE;
            tLAST_ITEM_HIS.USE_YN            := MYREC3.USE_YN;
        END LOOP;
    
        IF PSV_START_DT > PSV_CLOSE_DT THEN
            PR_RTN_CD  := '1400';
            PR_RTN_MSG := FC_GET_WORDPACK_MSG(PSV_COMP_CD, LOWER(PSV_LANG_CD), '1001346021');
            
            RAISE ERR_HANDLER;
        END IF;
            
        -- ���� ���ڵ� ������/�������� ��ġ���� üũ 
        FOR MYREC1 IN CUR_1 LOOP
            IF MYREC1.SALE_CLOSE_DT >= PSV_START_DT THEN
                vCMP_START_DT := MYREC1.SALE_START_DT;
                vCMP_CLOSE_DT := MYREC1.SALE_CLOSE_DT;
                    
                UPDATE  ITEM_STORE
                SET     SALE_CLOSE_DT = TO_CHAR(TO_DATE(PSV_START_DT, 'YYYYMMDD') - 1, 'YYYYMMDD')
                      , UPD_DT        = SYSDATE
                      , UPD_USER      = PSV_USER_ID
                WHERE   COMP_CD       = MYREC1.COMP_CD
                AND     BRAND_CD      = MYREC1.BRAND_CD
                AND     STOR_CD       = MYREC1.STOR_CD
                AND     ITEM_CD       = MYREC1.ITEM_CD
                AND     SALE_START_DT = MYREC1.SALE_START_DT;
            ELSE
                vCMP_START_DT := PSV_START_DT;
                vCMP_CLOSE_DT := PSV_CLOSE_DT;
            END IF;
        END LOOP;
            
        vMOD_CLOSE_DT := PSV_CLOSE_DT;
            
        -- ���� ���ڵ� ������/�������� ��ġ���� üũ
        FOR MYREC2 IN CUR_2 LOOP
            IF MYREC2.SALE_START_DT < PSV_CLOSE_DT THEN
                IF nRECCNT = 0 THEN
                    vMOD_CLOSE_DT := TO_CHAR(TO_DATE(MYREC2.SALE_START_DT, 'YYYYMMDD') - 1, 'YYYYMMDD');
                ELSE
                    vMOD_CLOSE_DT := TO_CHAR(TO_DATE(tLAST_ITEM_HIS.NEW_START_DT, 'YYYYMMDD') - 1, 'YYYYMMDD');
                END IF;
            END IF;
        END LOOP;
        
        MERGE INTO ITEM_STORE
        USING DUAL
        ON (
                COMP_CD       = PSV_COMP_CD
            AND BRAND_CD      = PSV_BRAND_CD
            AND STOR_CD       = PSV_STOR_CD
            AND ITEM_CD       = PSV_ITEM_CD
            AND SALE_START_DT = PSV_START_DT
           )
        WHEN MATCHED THEN
            UPDATE  
            SET SALE_CLOSE_DT = vMOD_CLOSE_DT
              , SALE_PRC      = TO_NUMBER(PSV_SALE_PRC)
              , STOR_SALE_PRC = TO_NUMBER(PSV_STOR_SALE_PRC)
              , USE_YN        = 'Y'
              , UPD_DT        = SYSDATE
              , UPD_USER      = PSV_USER_ID
        WHEN NOT MATCHED THEN
            INSERT   
               (          
                COMP_CD
              , BRAND_CD
              , STOR_CD
              , ITEM_CD
              , SALE_START_DT
              , SALE_CLOSE_DT
              , PRC_CHANGE_DIV
              , SALE_PRC
              , STOR_SALE_PRC
              , SALE_DC_YN
              , SALE_DC_PRC
              , SALE_VAT_YN
              , SALE_VAT_RULE
              , SALE_VAT_IN_RATE
              , SALE_VAT_OUT_RATE
              , USE_YN 
              , INST_DT
              , INST_USER
              , UPD_DT
              , UPD_USER
               ) 
            VALUES 
               (
                PSV_COMP_CD
              , PSV_BRAND_CD
              , PSV_STOR_CD
              , PSV_ITEM_CD
              , PSV_START_DT
              , vMOD_CLOSE_DT
              , PSV_CHANGE_DIV
              , TO_NUMBER(PSV_SALE_PRC)
              , TO_NUMBER(PSV_STOR_SALE_PRC)
              , 'N'
              , 0
              , PSV_SALE_VAT_YN
              , PSV_SALE_VAT_RULE
              , TO_NUMBER(PSV_SALE_VAT_IN_RATE)
              , TO_NUMBER(PSV_SALE_VAT_OUT_RATE)
              , 'Y'
              , SYSDATE
              , PSV_USER_ID
              , SYSDATE
              , PSV_USER_ID
               );
        
        IF nRECCNT > 0 THEN
            -- ���� �ڷ��� ��ġ�� �ڷ�� ����
            UPDATE  ITEM_STORE
            SET     USE_YN    = 'N'
                  , UPD_DT    = SYSDATE
                  , UPD_USER  = PSV_USER_ID
            WHERE   COMP_CD   = tLAST_ITEM_HIS.COMP_CD
            AND     BRAND_CD  = tLAST_ITEM_HIS.BRAND_CD
            AND     STOR_CD   = tLAST_ITEM_HIS.STOR_CD
            AND     ITEM_CD   = tLAST_ITEM_HIS.ITEM_CD
            AND     tLAST_ITEM_HIS.NEW_START_DT BETWEEN SALE_START_DT AND SALE_CLOSE_DT
            AND     tLAST_ITEM_HIS.OLD_START_DT != tLAST_ITEM_HIS.NEW_START_DT
            AND     USE_YN    = 'Y';
            
            /* �ű� ��� */
            MERGE INTO ITEM_STORE
            USING DUAL
            ON (
                    COMP_CD       = tLAST_ITEM_HIS.COMP_CD
                AND BRAND_CD      = tLAST_ITEM_HIS.BRAND_CD
                AND STOR_CD       = tLAST_ITEM_HIS.STOR_CD
                AND ITEM_CD       = tLAST_ITEM_HIS.ITEM_CD
                AND SALE_START_DT = tLAST_ITEM_HIS.NEW_START_DT
               )
            WHEN MATCHED THEN
                UPDATE  
                SET SALE_CLOSE_DT = tLAST_ITEM_HIS.SALE_CLOSE_DT
                  , SALE_PRC      = tLAST_ITEM_HIS.SALE_PRC
                  , STOR_SALE_PRC = tLAST_ITEM_HIS.STOR_SALE_PRC
                  , USE_YN        = USE_YN
                  , UPD_DT        = SYSDATE
                  , UPD_USER      = PSV_USER_ID
            WHEN NOT MATCHED THEN
                INSERT   
                   (          
                    COMP_CD
                  , BRAND_CD
                  , STOR_CD
                  , ITEM_CD
                  , SALE_START_DT
                  , SALE_CLOSE_DT
                  , PRC_CHANGE_DIV
                  , SALE_PRC
                  , STOR_SALE_PRC
                  , SALE_DC_YN
                  , SALE_DC_PRC
                  , SALE_VAT_YN
                  , SALE_VAT_RULE
                  , SALE_VAT_IN_RATE
                  , SALE_VAT_OUT_RATE
                  , USE_YN 
                  , INST_DT
                  , INST_USER
                  , UPD_DT
                  , UPD_USER
                   ) 
                VALUES 
                   (
                    tLAST_ITEM_HIS.COMP_CD
                  , tLAST_ITEM_HIS.BRAND_CD
                  , tLAST_ITEM_HIS.STOR_CD
                  , tLAST_ITEM_HIS.ITEM_CD
                  , tLAST_ITEM_HIS.NEW_START_DT
                  , tLAST_ITEM_HIS.SALE_CLOSE_DT
                  , tLAST_ITEM_HIS.PRC_CHANGE_DIV
                  , tLAST_ITEM_HIS.SALE_PRC
                  , tLAST_ITEM_HIS.STOR_SALE_PRC
                  , 'N'
                  , 0
                  , tLAST_ITEM_HIS.SALE_VAT_YN
                  , tLAST_ITEM_HIS.SALE_VAT_RULE
                  , tLAST_ITEM_HIS.SALE_VAT_IN_RATE
                  , tLAST_ITEM_HIS.SALE_VAT_OUT_RATE
                  , tLAST_ITEM_HIS.USE_YN
                  , SYSDATE
                  , PSV_USER_ID
                  , SYSDATE
                  , PSV_USER_ID
                   );
        END IF;
        
        PR_RTN_CD  := '0';
        PR_RTN_MSG := '';
        
        COMMIT;
        
        RETURN;
    EXCEPTION
        WHEN ERR_HANDLER THEN
            ROLLBACK;
            RETURN;
        WHEN OTHERS THEN
            PR_RTN_CD  := SQLCODE;
            PR_RTN_MSG := SQLERRM;
        
            ROLLBACK;
            RETURN;
    END;
   
END PKG_MAST5520;

/
