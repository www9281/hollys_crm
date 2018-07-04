CREATE OR REPLACE PACKAGE       PKG_GCRM1080 AS

    ---------------------------------------------------------------------------------------------------
    --  Package Name     : PKG_GCRM1080
    --  Description      : 문자메세지 정산
    -- Ref. Table        :
    ---------------------------------------------------------------------------------------------------

    
    PROCEDURE SP_TAB01          -- 영업구분
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_GFR_DATE    IN  VARCHAR2 ,                -- 조회 시작일자
        PSV_GTO_DATE    IN  VARCHAR2 ,                -- 조회 종료일자
        PSV_DSTN_COMP   IN  VARCHAR2 ,                -- 유통사
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    );
    
    PROCEDURE SP_TAB02          -- 영업조직
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_GFR_DATE    IN  VARCHAR2 ,                -- 조회 시작일자
        PSV_GTO_DATE    IN  VARCHAR2 ,                -- 조회 종료일자
        PSV_DSTN_COMP   IN  VARCHAR2 ,                -- 유통사
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    );
    
    PROCEDURE SP_TAB03          -- 직가맹
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_GFR_DATE    IN  VARCHAR2 ,                -- 조회 시작일자
        PSV_GTO_DATE    IN  VARCHAR2 ,                -- 조회 종료일자
        PSV_DSTN_COMP   IN  VARCHAR2 ,                -- 유통사
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    );
    
    PROCEDURE SP_TAB04          -- 유통사
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_GFR_DATE    IN  VARCHAR2 ,                -- 조회 시작일자
        PSV_GTO_DATE    IN  VARCHAR2 ,                -- 조회 종료일자
        PSV_DSTN_COMP   IN  VARCHAR2 ,                -- 유통사
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    );
    
    PROCEDURE SP_TAB05          -- 점포
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_GFR_DATE    IN  VARCHAR2 ,                -- 조회 시작일자
        PSV_GTO_DATE    IN  VARCHAR2 ,                -- 조회 종료일자
        PSV_DSTN_COMP   IN  VARCHAR2 ,                -- 유통사
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    );
      
END PKG_GCRM1080;

/

CREATE OR REPLACE PACKAGE BODY       PKG_GCRM1080 AS

    PROCEDURE SP_TAB01
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_GFR_DATE    IN  VARCHAR2 ,                -- 조회 시작일자
        PSV_GTO_DATE    IN  VARCHAR2 ,                -- 조회 종료일자
        PSV_DSTN_COMP   IN  VARCHAR2 ,                -- 유통사
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB01         문자메세지 정산(영업구분)
        PURPOSE:
        
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-10-17         1. CREATED THIS PROCEDURE.
        
        NOTES:
            OBJECT NAME :   SP_TAB01
            SYSDATE     :   2016-10-17
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000);
    ls_sql_with     VARCHAR2(30000);
    ls_sql_main     VARCHAR2(30000);
    ls_sql_date     VARCHAR2(1000);
    ls_sql_store    VARCHAR2(20000);    -- 점포 WITH  S_STORE
    ls_sql_item     VARCHAR2(20000);    -- 제품 WITH  S_ITEM
    ls_sql_sms      VARCHAR2(20000);    -- SMS로그
    ls_sql_mms      VARCHAR2(20000);    -- MMS로그
    ls_date1        VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2        VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1     VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2     VARCHAR2(2000);     -- 조회일자 제외 (대비)
    fr_sms_tbl_nm   VARCHAR2(2000) := NULL; -- 조회 시작일자의 SMS전송로그 테이블명
    to_sms_tbl_nm   VARCHAR2(2000) := NULL; -- 조회 종료일자의 SMS전송로그 테이블명
    fr_mms_tbl_nm   VARCHAR2(2000) := NULL; -- 조회 시작일자의 MMS전송로그 테이블명
    to_mms_tbl_nm   VARCHAR2(2000) := NULL; -- 조회 종료일자의 MMS전송로그 테이블명
    fr_sms_tbl_cnt  NUMBER := 0;
    to_sms_tbl_cnt  NUMBER := 0;
    fr_mms_tbl_cnt  NUMBER := 0;
    to_mms_tbl_cnt  NUMBER := 0;
    ERR_HANDLER     EXCEPTION;
        
    ls_err_cd     VARCHAR2(7) := '0';
    ls_err_msg    VARCHAR2(500);
        
    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';
        
        -- SMS, MMS 로그 테이블 존재 체크 및 쿼리작성
        
        -- 1. SMS 로그 테이블
        fr_sms_tbl_nm := 'SC_LOG_' || SUBSTR(PSV_GFR_DATE, 1, 6);
        
        SELECT COUNT(*) INTO fr_sms_tbl_cnt
          FROM TAB
         WHERE TABTYPE  = 'TABLE'
           AND TNAME    = fr_sms_tbl_nm;
        
        to_sms_tbl_nm := 'SC_LOG_' || SUBSTR(PSV_GTO_DATE, 1, 6);
        IF fr_sms_tbl_nm <> to_sms_tbl_nm THEN
            SELECT COUNT(*) INTO to_sms_tbl_cnt
              FROM TAB
             WHERE TABTYPE  = 'TABLE'
               AND TNAME    = to_sms_tbl_nm;
        ELSE
            to_sms_tbl_cnt := 0;
        END IF;
        
        IF fr_sms_tbl_cnt > 0 OR to_sms_tbl_cnt  > 0 THEN
            ls_sql_sms := ''
            ||CHR(13)||CHR(10)||Q'[ SELECT  TR_NUM      AS MSGKEY   ]'
            ||CHR(13)||CHR(10)||Q'[      ,  TR_SENDDATE AS SENDDATE ]'
            ||CHR(13)||CHR(10)||Q'[      ,  TR_RSLTSTAT AS RSLTSTAT ]'
            ||CHR(13)||CHR(10)||Q'[      ,  TR_PHONE    AS PHONE    ]'
            ||CHR(13)||CHR(10)||Q'[   FROM  (           ]';
            IF fr_sms_tbl_cnt > 0 THEN
                ls_sql_sms := ls_sql_sms
                ||CHR(13)||CHR(10)||Q'[         SELECT  TR_NUM      ]'
                ||CHR(13)||CHR(10)||Q'[              ,  TR_SENDDATE ]'
                ||CHR(13)||CHR(10)||Q'[              ,  TR_RSLTSTAT ]'
                ||CHR(13)||CHR(10)||Q'[              ,  TR_PHONE    ]'
                ||CHR(13)||CHR(10)||Q'[           FROM  ]' || fr_sms_tbl_nm;
            END IF;
            
            IF fr_sms_tbl_cnt > 0 AND to_sms_tbl_cnt > 0 THEN
                ls_sql_sms := ls_sql_sms
                ||CHR(13)||CHR(10)||Q'[         UNION ALL           ]';
            END IF;
            
            IF to_sms_tbl_cnt > 0 THEN
                ls_sql_sms := ls_sql_sms
                ||CHR(13)||CHR(10)||Q'[         SELECT  TR_NUM      ]'
                ||CHR(13)||CHR(10)||Q'[              ,  TR_SENDDATE ]'
                ||CHR(13)||CHR(10)||Q'[              ,  TR_RSLTSTAT ]'
                ||CHR(13)||CHR(10)||Q'[              ,  TR_PHONE    ]'
                ||CHR(13)||CHR(10)||Q'[           FROM  ]' || to_sms_tbl_nm;
            END IF;
            
            ls_sql_sms := ls_sql_sms
            ||CHR(13)||CHR(10)||Q'[         )           ]';
            
        ELSE
            ls_sql_sms := '';
        END IF;
        
        dbms_output.put_line(ls_sql_sms);
        
        -- 1. MMS 로그 테이블
        fr_mms_tbl_nm := 'MMS_LOG_' || SUBSTR(PSV_GFR_DATE, 1, 6);
        
        SELECT COUNT(*) INTO fr_mms_tbl_cnt
          FROM TAB
         WHERE TABTYPE  = 'TABLE'
           AND TNAME    = fr_mms_tbl_nm;
        
        to_mms_tbl_nm := 'MMS_LOG_' || SUBSTR(PSV_GTO_DATE, 1, 6);
        IF fr_mms_tbl_nm <> to_mms_tbl_nm THEN
            SELECT COUNT(*) INTO to_mms_tbl_cnt
              FROM TAB
             WHERE TABTYPE  = 'TABLE'
               AND TNAME    = to_mms_tbl_nm;
        ELSE
            to_mms_tbl_cnt := 0;
        END IF;
        
        IF fr_mms_tbl_cnt > 0 OR to_mms_tbl_cnt  > 0 THEN
            ls_sql_mms := ''
            ||CHR(13)||CHR(10)||Q'[ SELECT  MSGKEY                  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  REQDATE     AS SENDDATE ]'
            ||CHR(13)||CHR(10)||Q'[      ,  RSLT        AS RSLTSTAT ]'
            ||CHR(13)||CHR(10)||Q'[      ,  PHONE                   ]'
            ||CHR(13)||CHR(10)||Q'[   FROM  (           ]';
            IF fr_mms_tbl_cnt > 0 THEN
                ls_sql_mms := ls_sql_mms
                ||CHR(13)||CHR(10)||Q'[         SELECT  MSGKEY      ]'
                ||CHR(13)||CHR(10)||Q'[              ,  REQDATE     ]'
                ||CHR(13)||CHR(10)||Q'[              ,  RSLT        ]'
                ||CHR(13)||CHR(10)||Q'[              ,  PHONE       ]'
                ||CHR(13)||CHR(10)||Q'[           FROM  ]' || fr_mms_tbl_nm;
            END IF;
            
            IF fr_mms_tbl_cnt > 0 AND to_mms_tbl_cnt > 0 THEN
                ls_sql_mms := ls_sql_mms
                ||CHR(13)||CHR(10)||Q'[         UNION ALL           ]';
            END IF;
            
            IF to_mms_tbl_cnt > 0 THEN
                ls_sql_mms := ls_sql_mms
                ||CHR(13)||CHR(10)||Q'[         SELECT  MSGKEY      ]'
                ||CHR(13)||CHR(10)||Q'[              ,  REQDATE     ]'
                ||CHR(13)||CHR(10)||Q'[              ,  RSLT        ]'
                ||CHR(13)||CHR(10)||Q'[              ,  PHONE       ]'
                ||CHR(13)||CHR(10)||Q'[           FROM  ]' || to_mms_tbl_nm;
            END IF;
            
            ls_sql_mms := ls_sql_mms
            ||CHR(13)||CHR(10)||Q'[         )           ]';
            
        ELSE
            ls_sql_mms := '';
        END IF;
        
        dbms_output.put_line(ls_sql_mms);
        
        PKG_REPORT.RPT_PARA(PSV_COMP_CD,  PSV_USER,    PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
        ;
        
        IF (ls_sql_sms IS NOT NULL OR ls_sql_sms <> '') AND (ls_sql_mms IS NOT NULL OR ls_sql_mms <> '') THEN
            ls_sql_main := ''
            ||CHR(13)||CHR(10)||Q'[ SELECT  S.BRAND_CLASS                               ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (SL.MSGKEY IS NOT NULL                                    ) THEN 1 ELSE 0 END) AS SMS_SEND_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (SL.MSGKEY IS NOT NULL AND SL.RSLTSTAT = '00'             ) THEN 1 ELSE 0 END) AS SMS_WAIT_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (SL.MSGKEY IS NOT NULL AND SL.RSLTSTAT NOT IN ('00', '06')) THEN 1 ELSE 0 END) AS SMS_FAIL_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (SL.MSGKEY IS NOT NULL AND SL.RSLTSTAT = '06'             ) THEN 1 ELSE 0 END) AS SMS_SUCCESS_CNT  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (ML.MSGKEY IS NOT NULL                                    ) THEN 1 ELSE 0 END) AS MMS_SEND_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (ML.MSGKEY IS NOT NULL AND ML.RSLTSTAT IS NULL            ) THEN 1 ELSE 0 END) AS MMS_WAIT_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (ML.MSGKEY IS NOT NULL AND ML.RSLTSTAT <> '1000'          ) THEN 1 ELSE 0 END) AS MMS_FAIL_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (ML.MSGKEY IS NOT NULL AND ML.RSLTSTAT =  '1000'          ) THEN 1 ELSE 0 END) AS MMS_SUCCESS_CNT  ]'
            ||CHR(13)||CHR(10)||Q'[   FROM  CS_CONTENT_SEND     CS  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  S_STORE             S   ]'
            ||CHR(13)||CHR(10)||Q'[      ,  (                       ]'
            ||CHR(13)||CHR(10)||Q'[             ]' || ls_sql_sms
            ||CHR(13)||CHR(10)||Q'[         )   SL                  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  (                       ]'
            ||CHR(13)||CHR(10)||Q'[             ]' || ls_sql_mms
            ||CHR(13)||CHR(10)||Q'[         )   ML                  ]'
            ||CHR(13)||CHR(10)||Q'[  WHERE  SUBSTR(CS.SEND_DT, 1, 8) = TO_CHAR(SL.SENDDATE(+), 'YYYYMMDD')  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.MSGKEY       = SL.MSGKEY(+)  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  REPLACE(DECRYPT(CS.MOBILE), '-', '') = SL.PHONE(+)  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  SUBSTR(CS.SEND_DT, 1, 8) = TO_CHAR(ML.SENDDATE(+), 'YYYYMMDD')  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.MSGKEY       = ML.MSGKEY(+)  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  REPLACE(DECRYPT(CS.MOBILE), '-', '') = ML.PHONE(+)  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.COMP_CD      = S.COMP_CD     ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.BRAND_CD     = S.BRAND_CD    ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.STOR_CD      = S.STOR_CD     ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.COMP_CD      = :PSV_COMP_CD  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  SUBSTR(CS.SEND_DT, 1, 8) BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
            ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_DSTN_COMP IS NULL OR S.DSTN_COMP  = :PSV_DSTN_COMP)   ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.USE_YN       = 'Y'           ]'
            ||CHR(13)||CHR(10)||Q'[  GROUP  BY S.BRAND_CLASS    ]'
            ||CHR(13)||CHR(10)||Q'[  ORDER  BY S.BRAND_CLASS    ]';
            
            ls_sql := ls_sql || ls_sql_main;
            dbms_output.put_line(ls_sql);
        
            OPEN PR_RESULT FOR
                ls_sql USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_DSTN_COMP, PSV_DSTN_COMP;
            
        ELSIF (ls_sql_sms IS NOT NULL OR ls_sql_sms <> '') AND (ls_sql_mms IS NULL OR ls_sql_mms = '') THEN
            
            ls_sql_main := ''
            ||CHR(13)||CHR(10)||Q'[ SELECT  S.BRAND_CLASS                           ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (SL.MSGKEY IS NOT NULL                                    ) THEN 1 ELSE 0 END) AS SMS_SEND_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (SL.MSGKEY IS NOT NULL AND SL.RSLTSTAT = '00'             ) THEN 1 ELSE 0 END) AS SMS_WAIT_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (SL.MSGKEY IS NOT NULL AND SL.RSLTSTAT NOT IN ('00', '06')) THEN 1 ELSE 0 END) AS SMS_FAIL_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (SL.MSGKEY IS NOT NULL AND SL.RSLTSTAT = '06'             ) THEN 1 ELSE 0 END) AS SMS_SUCCESS_CNT  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS MMS_SEND_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS MMS_WAIT_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS MMS_FAIL_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS MMS_SUCCESS_CNT  ]'
            ||CHR(13)||CHR(10)||Q'[   FROM  CS_CONTENT_SEND     CS  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  S_STORE             S   ]'
            ||CHR(13)||CHR(10)||Q'[      ,  (                       ]'
            ||CHR(13)||CHR(10)||Q'[             ]' || ls_sql_sms
            ||CHR(13)||CHR(10)||Q'[         )   SL                  ]'
            ||CHR(13)||CHR(10)||Q'[  WHERE  SUBSTR(CS.SEND_DT, 1, 8) = TO_CHAR(SL.SENDDATE(+), 'YYYYMMDD')  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.MSGKEY       = SL.MSGKEY(+)  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  REPLACE(DECRYPT(CS.MOBILE), '-', '') = SL.PHONE(+)  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.COMP_CD      = S.COMP_CD     ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.BRAND_CD     = S.BRAND_CD    ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.STOR_CD      = S.STOR_CD     ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.COMP_CD      = :PSV_COMP_CD  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  SUBSTR(CS.SEND_DT, 1, 8) BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
            ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_DSTN_COMP IS NULL OR S.DSTN_COMP  = :PSV_DSTN_COMP)   ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.USE_YN       = 'Y'           ]'
            ||CHR(13)||CHR(10)||Q'[  GROUP  BY S.BRAND_CLASS    ]'
            ||CHR(13)||CHR(10)||Q'[  ORDER  BY S.BRAND_CLASS    ]';
            
            ls_sql := ls_sql || ls_sql_main;
            dbms_output.put_line(ls_sql);
        
            OPEN PR_RESULT FOR
                ls_sql USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_DSTN_COMP, PSV_DSTN_COMP;
                
        ELSIF (ls_sql_sms IS NULL OR ls_sql_sms = '') AND (ls_sql_mms IS NOT NULL OR ls_sql_mms <> '') THEN
            
            ls_sql_main := ''
            ||CHR(13)||CHR(10)||Q'[ SELECT  S.BRAND_CLASS                           ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS SMS_SEND_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS SMS_WAIT_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS SMS_FAIL_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS SMS_SUCCESS_CNT  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (ML.MSGKEY IS NOT NULL                                    ) THEN 1 ELSE 0 END) AS MMS_SEND_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (ML.MSGKEY IS NOT NULL AND ML.RSLTSTAT IS NULL            ) THEN 1 ELSE 0 END) AS MMS_WAIT_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (ML.MSGKEY IS NOT NULL AND ML.RSLTSTAT <> '1000'          ) THEN 1 ELSE 0 END) AS MMS_FAIL_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (ML.MSGKEY IS NOT NULL AND ML.RSLTSTAT =  '1000'          ) THEN 1 ELSE 0 END) AS MMS_SUCCESS_CNT  ]'
            ||CHR(13)||CHR(10)||Q'[   FROM  CS_CONTENT_SEND     CS  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  S_STORE             S   ]'
            ||CHR(13)||CHR(10)||Q'[      ,  (                       ]'
            ||CHR(13)||CHR(10)||Q'[             ]' || ls_sql_mms
            ||CHR(13)||CHR(10)||Q'[         )   ML                  ]'
            ||CHR(13)||CHR(10)||Q'[  WHERE  SUBSTR(CS.SEND_DT, 1, 8) = TO_CHAR(ML.SENDDATE(+), 'YYYYMMDD')  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.MSGKEY       = ML.MSGKEY(+)  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  REPLACE(DECRYPT(CS.MOBILE), '-', '') = ML.PHONE(+)  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.COMP_CD      = S.COMP_CD     ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.BRAND_CD     = S.BRAND_CD    ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.STOR_CD      = S.STOR_CD     ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.COMP_CD      = :PSV_COMP_CD  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  SUBSTR(CS.SEND_DT, 1, 8) BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
            ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_DSTN_COMP IS NULL OR S.DSTN_COMP  = :PSV_DSTN_COMP)   ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.USE_YN       = 'Y'           ]'
            ||CHR(13)||CHR(10)||Q'[  GROUP  BY S.BRAND_CLASS    ]'
            ||CHR(13)||CHR(10)||Q'[  ORDER  BY S.BRAND_CLASS    ]';
            
            ls_sql := ls_sql || ls_sql_main;
            dbms_output.put_line(ls_sql);
        
            OPEN PR_RESULT FOR
                ls_sql USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_DSTN_COMP, PSV_DSTN_COMP;
                
        ELSIF (ls_sql_sms IS NULL OR ls_sql_sms = '') AND (ls_sql_mms IS NULL OR ls_sql_mms = '') THEN
            
            ls_sql_main := ''
            ||CHR(13)||CHR(10)||Q'[ SELECT  S.BRAND_CLASS                           ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS SMS_SEND_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS SMS_WAIT_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS SMS_FAIL_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS SMS_SUCCESS_CNT  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS MMS_SEND_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS MMS_WAIT_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS MMS_FAIL_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS MMS_SUCCESS_CNT  ]'
            ||CHR(13)||CHR(10)||Q'[   FROM  CS_CONTENT_SEND     CS  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  S_STORE             S   ]'
            ||CHR(13)||CHR(10)||Q'[  WHERE  CS.COMP_CD      = S.COMP_CD     ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.BRAND_CD     = S.BRAND_CD    ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.STOR_CD      = S.STOR_CD     ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.COMP_CD      = :PSV_COMP_CD  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  SUBSTR(CS.SEND_DT, 1, 8) BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
            ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_DSTN_COMP IS NULL OR S.DSTN_COMP  = :PSV_DSTN_COMP)   ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.USE_YN       = 'Y'           ]'
            ||CHR(13)||CHR(10)||Q'[  GROUP  BY S.BRAND_CLASS    ]'
            ||CHR(13)||CHR(10)||Q'[  ORDER  BY S.BRAND_CLASS    ]';
            
            ls_sql := ls_sql || ls_sql_main;
            dbms_output.put_line(ls_sql);
        
            OPEN PR_RESULT FOR
                ls_sql USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_DSTN_COMP, PSV_DSTN_COMP;
                
        END IF;
        
        PR_RTN_CD  := ls_err_cd;
        PR_RTN_MSG := ls_err_msg;
        
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';

    EXCEPTION
        WHEN ERR_HANDLER THEN
            PR_RTN_CD  := ls_err_cd;
            PR_RTN_MSG := ls_err_msg;
            dbms_output.put_line( PR_RTN_MSG );
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
           
        WHEN OTHERS THEN
            PR_RTN_CD  := '4999999';
            PR_RTN_MSG := SQLERRM;
            dbms_output.put_line( PR_RTN_MSG );
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
    END;
    
    PROCEDURE SP_TAB02
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_GFR_DATE    IN  VARCHAR2 ,                -- 조회 시작일자
        PSV_GTO_DATE    IN  VARCHAR2 ,                -- 조회 종료일자
        PSV_DSTN_COMP   IN  VARCHAR2 ,                -- 유통사
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB02         문자메세지 정산(영업조직)
        PURPOSE:
        
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-10-17         1. CREATED THIS PROCEDURE.
        
        NOTES:
            OBJECT NAME :   SP_TAB02
            SYSDATE     :   2016-10-17
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000);
    ls_sql_with     VARCHAR2(30000);
    ls_sql_main     VARCHAR2(30000);
    ls_sql_date     VARCHAR2(1000);
    ls_sql_store    VARCHAR2(20000);    -- 점포 WITH  S_STORE
    ls_sql_item     VARCHAR2(20000);    -- 제품 WITH  S_ITEM
    ls_sql_sms      VARCHAR2(20000);    -- SMS로그
    ls_sql_mms      VARCHAR2(20000);    -- MMS로그
    ls_date1        VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2        VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1     VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2     VARCHAR2(2000);     -- 조회일자 제외 (대비)
    fr_sms_tbl_nm   VARCHAR2(2000) := NULL; -- 조회 시작일자의 SMS전송로그 테이블명
    to_sms_tbl_nm   VARCHAR2(2000) := NULL; -- 조회 종료일자의 SMS전송로그 테이블명
    fr_mms_tbl_nm   VARCHAR2(2000) := NULL; -- 조회 시작일자의 MMS전송로그 테이블명
    to_mms_tbl_nm   VARCHAR2(2000) := NULL; -- 조회 종료일자의 MMS전송로그 테이블명
    fr_sms_tbl_cnt  NUMBER := 0;
    to_sms_tbl_cnt  NUMBER := 0;
    fr_mms_tbl_cnt  NUMBER := 0;
    to_mms_tbl_cnt  NUMBER := 0;
    ERR_HANDLER     EXCEPTION;
        
    ls_err_cd     VARCHAR2(7) := '0';
    ls_err_msg    VARCHAR2(500);
        
    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';
        
        -- SMS, MMS 로그 테이블 존재 체크 및 쿼리작성
        
        -- 1. SMS 로그 테이블
        fr_sms_tbl_nm := 'SC_LOG_' || SUBSTR(PSV_GFR_DATE, 1, 6);
        
        SELECT COUNT(*) INTO fr_sms_tbl_cnt
          FROM TAB
         WHERE TABTYPE  = 'TABLE'
           AND TNAME    = fr_sms_tbl_nm;
        
        to_sms_tbl_nm := 'SC_LOG_' || SUBSTR(PSV_GTO_DATE, 1, 6);
        IF fr_sms_tbl_nm <> to_sms_tbl_nm THEN
            SELECT COUNT(*) INTO to_sms_tbl_cnt
              FROM TAB
             WHERE TABTYPE  = 'TABLE'
               AND TNAME    = to_sms_tbl_nm;
        ELSE
            to_sms_tbl_cnt := 0;
        END IF;
        
        IF fr_sms_tbl_cnt > 0 OR to_sms_tbl_cnt  > 0 THEN
            ls_sql_sms := ''
            ||CHR(13)||CHR(10)||Q'[ SELECT  TR_NUM      AS MSGKEY   ]'
            ||CHR(13)||CHR(10)||Q'[      ,  TR_SENDDATE AS SENDDATE ]'
            ||CHR(13)||CHR(10)||Q'[      ,  TR_RSLTSTAT AS RSLTSTAT ]'
            ||CHR(13)||CHR(10)||Q'[      ,  TR_PHONE    AS PHONE    ]'
            ||CHR(13)||CHR(10)||Q'[   FROM  (           ]';
            IF fr_sms_tbl_cnt > 0 THEN
                ls_sql_sms := ls_sql_sms
                ||CHR(13)||CHR(10)||Q'[         SELECT  TR_NUM      ]'
                ||CHR(13)||CHR(10)||Q'[              ,  TR_SENDDATE ]'
                ||CHR(13)||CHR(10)||Q'[              ,  TR_RSLTSTAT ]'
                ||CHR(13)||CHR(10)||Q'[              ,  TR_PHONE    ]'
                ||CHR(13)||CHR(10)||Q'[           FROM  ]' || fr_sms_tbl_nm;
            END IF;
            
            IF fr_sms_tbl_cnt > 0 AND to_sms_tbl_cnt > 0 THEN
                ls_sql_sms := ls_sql_sms
                ||CHR(13)||CHR(10)||Q'[         UNION ALL           ]';
            END IF;
            
            IF to_sms_tbl_cnt > 0 THEN
                ls_sql_sms := ls_sql_sms
                ||CHR(13)||CHR(10)||Q'[         SELECT  TR_NUM      ]'
                ||CHR(13)||CHR(10)||Q'[              ,  TR_SENDDATE ]'
                ||CHR(13)||CHR(10)||Q'[              ,  TR_RSLTSTAT ]'
                ||CHR(13)||CHR(10)||Q'[              ,  TR_PHONE    ]'
                ||CHR(13)||CHR(10)||Q'[           FROM  ]' || to_sms_tbl_nm;
            END IF;
            
            ls_sql_sms := ls_sql_sms
            ||CHR(13)||CHR(10)||Q'[         )           ]';
            
        ELSE
            ls_sql_sms := '';
        END IF;
        
        dbms_output.put_line(ls_sql_sms);
        
        -- 1. MMS 로그 테이블
        fr_mms_tbl_nm := 'MMS_LOG_' || SUBSTR(PSV_GFR_DATE, 1, 6);
        
        SELECT COUNT(*) INTO fr_mms_tbl_cnt
          FROM TAB
         WHERE TABTYPE  = 'TABLE'
           AND TNAME    = fr_mms_tbl_nm;
        
        to_mms_tbl_nm := 'MMS_LOG_' || SUBSTR(PSV_GTO_DATE, 1, 6);
        IF fr_mms_tbl_nm <> to_mms_tbl_nm THEN
            SELECT COUNT(*) INTO to_mms_tbl_cnt
              FROM TAB
             WHERE TABTYPE  = 'TABLE'
               AND TNAME    = to_mms_tbl_nm;
        ELSE
            to_mms_tbl_cnt := 0;
        END IF;
        
        IF fr_mms_tbl_cnt > 0 OR to_mms_tbl_cnt  > 0 THEN
            ls_sql_mms := ''
            ||CHR(13)||CHR(10)||Q'[ SELECT  MSGKEY                  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  REQDATE     AS SENDDATE ]'
            ||CHR(13)||CHR(10)||Q'[      ,  RSLT        AS RSLTSTAT ]'
            ||CHR(13)||CHR(10)||Q'[      ,  PHONE                   ]'
            ||CHR(13)||CHR(10)||Q'[   FROM  (           ]';
            IF fr_mms_tbl_cnt > 0 THEN
                ls_sql_mms := ls_sql_mms
                ||CHR(13)||CHR(10)||Q'[         SELECT  MSGKEY      ]'
                ||CHR(13)||CHR(10)||Q'[              ,  REQDATE     ]'
                ||CHR(13)||CHR(10)||Q'[              ,  RSLT        ]'
                ||CHR(13)||CHR(10)||Q'[              ,  PHONE       ]'
                ||CHR(13)||CHR(10)||Q'[           FROM  ]' || fr_mms_tbl_nm;
            END IF;
            
            IF fr_mms_tbl_cnt > 0 AND to_mms_tbl_cnt > 0 THEN
                ls_sql_mms := ls_sql_mms
                ||CHR(13)||CHR(10)||Q'[         UNION ALL           ]';
            END IF;
            
            IF to_mms_tbl_cnt > 0 THEN
                ls_sql_mms := ls_sql_mms
                ||CHR(13)||CHR(10)||Q'[         SELECT  MSGKEY      ]'
                ||CHR(13)||CHR(10)||Q'[              ,  REQDATE     ]'
                ||CHR(13)||CHR(10)||Q'[              ,  RSLT        ]'
                ||CHR(13)||CHR(10)||Q'[              ,  PHONE       ]'
                ||CHR(13)||CHR(10)||Q'[           FROM  ]' || to_mms_tbl_nm;
            END IF;
            
            ls_sql_mms := ls_sql_mms
            ||CHR(13)||CHR(10)||Q'[         )           ]';
            
        ELSE
            ls_sql_mms := '';
        END IF;
        
        dbms_output.put_line(ls_sql_mms);
        
        PKG_REPORT.RPT_PARA(PSV_COMP_CD,  PSV_USER,    PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
        ;
        
        IF (ls_sql_sms IS NOT NULL OR ls_sql_sms <> '') AND (ls_sql_mms IS NOT NULL OR ls_sql_mms <> '') THEN
            
            ls_sql_main := ''
            ||CHR(13)||CHR(10)||Q'[ SELECT  S.BRAND_CLASS                           ]'
            ||CHR(13)||CHR(10)||Q'[      ,  S.BRAND_CD                              ]'
            ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.BRAND_NM)         AS BRAND_NM     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (SL.MSGKEY IS NOT NULL                                    ) THEN 1 ELSE 0 END) AS SMS_SEND_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (SL.MSGKEY IS NOT NULL AND SL.RSLTSTAT = '00'             ) THEN 1 ELSE 0 END) AS SMS_WAIT_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (SL.MSGKEY IS NOT NULL AND SL.RSLTSTAT NOT IN ('00', '06')) THEN 1 ELSE 0 END) AS SMS_FAIL_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (SL.MSGKEY IS NOT NULL AND SL.RSLTSTAT = '06'             ) THEN 1 ELSE 0 END) AS SMS_SUCCESS_CNT  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (ML.MSGKEY IS NOT NULL                                    ) THEN 1 ELSE 0 END) AS MMS_SEND_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (ML.MSGKEY IS NOT NULL AND ML.RSLTSTAT IS NULL            ) THEN 1 ELSE 0 END) AS MMS_WAIT_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (ML.MSGKEY IS NOT NULL AND ML.RSLTSTAT <> '1000'          ) THEN 1 ELSE 0 END) AS MMS_FAIL_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (ML.MSGKEY IS NOT NULL AND ML.RSLTSTAT =  '1000'          ) THEN 1 ELSE 0 END) AS MMS_SUCCESS_CNT  ]'
            ||CHR(13)||CHR(10)||Q'[   FROM  CS_CONTENT_SEND     CS  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  S_STORE             S   ]'
            ||CHR(13)||CHR(10)||Q'[      ,  (                       ]'
            ||CHR(13)||CHR(10)||Q'[             ]' || ls_sql_sms
            ||CHR(13)||CHR(10)||Q'[         )   SL                  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  (                       ]'
            ||CHR(13)||CHR(10)||Q'[             ]' || ls_sql_mms
            ||CHR(13)||CHR(10)||Q'[         )   ML                  ]'
            ||CHR(13)||CHR(10)||Q'[  WHERE  SUBSTR(CS.SEND_DT, 1, 8) = TO_CHAR(SL.SENDDATE(+), 'YYYYMMDD')  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.MSGKEY       = SL.MSGKEY(+)  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  REPLACE(DECRYPT(CS.MOBILE), '-', '') = SL.PHONE(+)  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  SUBSTR(CS.SEND_DT, 1, 8) = TO_CHAR(ML.SENDDATE(+), 'YYYYMMDD')  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.MSGKEY       = ML.MSGKEY(+)  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  REPLACE(DECRYPT(CS.MOBILE), '-', '') = ML.PHONE(+)  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.COMP_CD      = S.COMP_CD     ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.BRAND_CD     = S.BRAND_CD    ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.STOR_CD      = S.STOR_CD     ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.COMP_CD      = :PSV_COMP_CD  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  SUBSTR(CS.SEND_DT, 1, 8) BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
            ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_DSTN_COMP IS NULL OR S.DSTN_COMP  = :PSV_DSTN_COMP)   ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.USE_YN       = 'Y'           ]'
            ||CHR(13)||CHR(10)||Q'[  GROUP  BY S.BRAND_CLASS, S.BRAND_CD    ]'
            ||CHR(13)||CHR(10)||Q'[  ORDER  BY S.BRAND_CLASS, S.BRAND_CD    ]';
            
            ls_sql := ls_sql || ls_sql_main;
            dbms_output.put_line(ls_sql);
        
            OPEN PR_RESULT FOR
                ls_sql USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_DSTN_COMP, PSV_DSTN_COMP;
            
        ELSIF (ls_sql_sms IS NOT NULL OR ls_sql_sms <> '') AND (ls_sql_mms IS NULL OR ls_sql_mms = '') THEN
            ls_sql_main := ''
            ||CHR(13)||CHR(10)||Q'[ SELECT  S.BRAND_CLASS                           ]'
            ||CHR(13)||CHR(10)||Q'[      ,  S.BRAND_CD                              ]'
            ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.BRAND_NM)         AS BRAND_NM     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (SL.MSGKEY IS NOT NULL                                    ) THEN 1 ELSE 0 END) AS SMS_SEND_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (SL.MSGKEY IS NOT NULL AND SL.RSLTSTAT = '00'             ) THEN 1 ELSE 0 END) AS SMS_WAIT_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (SL.MSGKEY IS NOT NULL AND SL.RSLTSTAT NOT IN ('00', '06')) THEN 1 ELSE 0 END) AS SMS_FAIL_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (SL.MSGKEY IS NOT NULL AND SL.RSLTSTAT = '06'             ) THEN 1 ELSE 0 END) AS SMS_SUCCESS_CNT  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (0) AS MMS_SEND_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (0) AS MMS_WAIT_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (0) AS MMS_FAIL_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (0) AS MMS_SUCCESS_CNT  ]'
            ||CHR(13)||CHR(10)||Q'[   FROM  CS_CONTENT_SEND     CS  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  S_STORE             S   ]'
            ||CHR(13)||CHR(10)||Q'[      ,  (                       ]'
            ||CHR(13)||CHR(10)||Q'[             ]' || ls_sql_sms
            ||CHR(13)||CHR(10)||Q'[         )   SL                  ]'
            ||CHR(13)||CHR(10)||Q'[  WHERE  SUBSTR(CS.SEND_DT, 1, 8) = TO_CHAR(SL.SENDDATE(+), 'YYYYMMDD')  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.MSGKEY       = SL.MSGKEY(+)  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  REPLACE(DECRYPT(CS.MOBILE), '-', '') = SL.PHONE(+)  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.COMP_CD      = S.COMP_CD     ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.BRAND_CD     = S.BRAND_CD    ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.STOR_CD      = S.STOR_CD     ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.COMP_CD      = :PSV_COMP_CD  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  SUBSTR(CS.SEND_DT, 1, 8) BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
            ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_DSTN_COMP IS NULL OR S.DSTN_COMP  = :PSV_DSTN_COMP)   ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.USE_YN       = 'Y'           ]'
            ||CHR(13)||CHR(10)||Q'[  GROUP  BY S.BRAND_CLASS, S.BRAND_CD    ]'
            ||CHR(13)||CHR(10)||Q'[  ORDER  BY S.BRAND_CLASS, S.BRAND_CD    ]';
            
            ls_sql := ls_sql || ls_sql_main;
            dbms_output.put_line(ls_sql);
        
            OPEN PR_RESULT FOR
                ls_sql USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_DSTN_COMP, PSV_DSTN_COMP;
                
        ELSIF (ls_sql_sms IS NULL OR ls_sql_sms = '') AND (ls_sql_mms IS NOT NULL OR ls_sql_mms <> '') THEN
            
            ls_sql_main := ''
            ||CHR(13)||CHR(10)||Q'[ SELECT  S.BRAND_CLASS                           ]'
            ||CHR(13)||CHR(10)||Q'[      ,  S.BRAND_CD                              ]'
            ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.BRAND_NM)         AS BRAND_NM     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (0) AS SMS_SEND_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (0) AS SMS_WAIT_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (0) AS SMS_FAIL_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (0) AS SMS_SUCCESS_CNT  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (ML.MSGKEY IS NOT NULL                                    ) THEN 1 ELSE 0 END) AS MMS_SEND_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (ML.MSGKEY IS NOT NULL AND ML.RSLTSTAT IS NULL            ) THEN 1 ELSE 0 END) AS MMS_WAIT_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (ML.MSGKEY IS NOT NULL AND ML.RSLTSTAT <> '1000'          ) THEN 1 ELSE 0 END) AS MMS_FAIL_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (ML.MSGKEY IS NOT NULL AND ML.RSLTSTAT =  '1000'          ) THEN 1 ELSE 0 END) AS MMS_SUCCESS_CNT  ]'
            ||CHR(13)||CHR(10)||Q'[   FROM  CS_CONTENT_SEND     CS  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  S_STORE             S   ]'
            ||CHR(13)||CHR(10)||Q'[      ,  (                       ]'
            ||CHR(13)||CHR(10)||Q'[             ]' || ls_sql_mms
            ||CHR(13)||CHR(10)||Q'[         )   ML                  ]'
            ||CHR(13)||CHR(10)||Q'[  WHERE  SUBSTR(CS.SEND_DT, 1, 8) = TO_CHAR(ML.SENDDATE(+), 'YYYYMMDD')  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.MSGKEY       = ML.MSGKEY(+)  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  REPLACE(DECRYPT(CS.MOBILE), '-', '') = ML.PHONE(+)  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.COMP_CD      = S.COMP_CD     ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.BRAND_CD     = S.BRAND_CD    ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.STOR_CD      = S.STOR_CD     ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.COMP_CD      = :PSV_COMP_CD  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  SUBSTR(CS.SEND_DT, 1, 8) BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
            ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_DSTN_COMP IS NULL OR S.DSTN_COMP  = :PSV_DSTN_COMP)   ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.USE_YN       = 'Y'           ]'
            ||CHR(13)||CHR(10)||Q'[  GROUP  BY S.BRAND_CLASS, S.BRAND_CD    ]'
            ||CHR(13)||CHR(10)||Q'[  ORDER  BY S.BRAND_CLASS, S.BRAND_CD    ]';
            
            ls_sql := ls_sql || ls_sql_main;
            dbms_output.put_line(ls_sql);
        
            OPEN PR_RESULT FOR
                ls_sql USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_DSTN_COMP, PSV_DSTN_COMP;
                
        ELSIF (ls_sql_sms IS NULL OR ls_sql_sms = '') AND (ls_sql_mms IS NULL OR ls_sql_mms = '') THEN
            
            ls_sql_main := ''
            ||CHR(13)||CHR(10)||Q'[ SELECT  S.BRAND_CLASS                           ]'
            ||CHR(13)||CHR(10)||Q'[      ,  S.BRAND_CD                              ]'
            ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.BRAND_NM)         AS BRAND_NM     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS SMS_SEND_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS SMS_WAIT_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS SMS_FAIL_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS SMS_SUCCESS_CNT  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS MMS_SEND_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS MMS_WAIT_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS MMS_FAIL_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS MMS_SUCCESS_CNT  ]'
            ||CHR(13)||CHR(10)||Q'[   FROM  CS_CONTENT_SEND     CS  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  S_STORE             S   ]'
            ||CHR(13)||CHR(10)||Q'[  WHERE  CS.COMP_CD      = S.COMP_CD     ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.BRAND_CD     = S.BRAND_CD    ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.STOR_CD      = S.STOR_CD     ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.COMP_CD      = :PSV_COMP_CD  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  SUBSTR(CS.SEND_DT, 1, 8) BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
            ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_DSTN_COMP IS NULL OR S.DSTN_COMP  = :PSV_DSTN_COMP)   ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.USE_YN       = 'Y'           ]'
            ||CHR(13)||CHR(10)||Q'[  GROUP  BY S.BRAND_CLASS, S.BRAND_CD    ]'
            ||CHR(13)||CHR(10)||Q'[  ORDER  BY S.BRAND_CLASS, S.BRAND_CD    ]';
            
            ls_sql := ls_sql || ls_sql_main;
            dbms_output.put_line(ls_sql);
        
            OPEN PR_RESULT FOR
                ls_sql USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_DSTN_COMP, PSV_DSTN_COMP;
                
        END IF;
        
        PR_RTN_CD  := ls_err_cd;
        PR_RTN_MSG := ls_err_msg;
        
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';

    EXCEPTION
        WHEN ERR_HANDLER THEN
            PR_RTN_CD  := ls_err_cd;
            PR_RTN_MSG := ls_err_msg;
            dbms_output.put_line( PR_RTN_MSG );
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
           
        WHEN OTHERS THEN
            PR_RTN_CD  := '4999999';
            PR_RTN_MSG := SQLERRM;
            dbms_output.put_line( PR_RTN_MSG );
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
    END;
    
    PROCEDURE SP_TAB03
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_GFR_DATE    IN  VARCHAR2 ,                -- 조회 시작일자
        PSV_GTO_DATE    IN  VARCHAR2 ,                -- 조회 종료일자
        PSV_DSTN_COMP   IN  VARCHAR2 ,                -- 유통사
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB03         문자메세지 정산(직가맹)
        PURPOSE:
        
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-10-17         1. CREATED THIS PROCEDURE.
        
        NOTES:
            OBJECT NAME :   SP_TAB03
            SYSDATE     :   2016-10-17
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000);
    ls_sql_with     VARCHAR2(30000);
    ls_sql_main     VARCHAR2(30000);
    ls_sql_date     VARCHAR2(1000);
    ls_sql_store    VARCHAR2(20000);    -- 점포 WITH  S_STORE
    ls_sql_item     VARCHAR2(20000);    -- 제품 WITH  S_ITEM
    ls_sql_sms      VARCHAR2(20000);    -- SMS로그
    ls_sql_mms      VARCHAR2(20000);    -- MMS로그
    ls_date1        VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2        VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1     VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2     VARCHAR2(2000);     -- 조회일자 제외 (대비)
    fr_sms_tbl_nm   VARCHAR2(2000) := NULL; -- 조회 시작일자의 SMS전송로그 테이블명
    to_sms_tbl_nm   VARCHAR2(2000) := NULL; -- 조회 종료일자의 SMS전송로그 테이블명
    fr_mms_tbl_nm   VARCHAR2(2000) := NULL; -- 조회 시작일자의 MMS전송로그 테이블명
    to_mms_tbl_nm   VARCHAR2(2000) := NULL; -- 조회 종료일자의 MMS전송로그 테이블명
    fr_sms_tbl_cnt  NUMBER := 0;
    to_sms_tbl_cnt  NUMBER := 0;
    fr_mms_tbl_cnt  NUMBER := 0;
    to_mms_tbl_cnt  NUMBER := 0;
    ERR_HANDLER     EXCEPTION;
        
    ls_err_cd     VARCHAR2(7) := '0';
    ls_err_msg    VARCHAR2(500);
        
    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';
        
        -- SMS, MMS 로그 테이블 존재 체크 및 쿼리작성
        
        -- 1. SMS 로그 테이블
        fr_sms_tbl_nm := 'SC_LOG_' || SUBSTR(PSV_GFR_DATE, 1, 6);
        
        SELECT COUNT(*) INTO fr_sms_tbl_cnt
          FROM TAB
         WHERE TABTYPE  = 'TABLE'
           AND TNAME    = fr_sms_tbl_nm;
        
        to_sms_tbl_nm := 'SC_LOG_' || SUBSTR(PSV_GTO_DATE, 1, 6);
        IF fr_sms_tbl_nm <> to_sms_tbl_nm THEN
            SELECT COUNT(*) INTO to_sms_tbl_cnt
              FROM TAB
             WHERE TABTYPE  = 'TABLE'
               AND TNAME    = to_sms_tbl_nm;
        ELSE
            to_sms_tbl_cnt := 0;
        END IF;
        
        IF fr_sms_tbl_cnt > 0 OR to_sms_tbl_cnt  > 0 THEN
            ls_sql_sms := ''
            ||CHR(13)||CHR(10)||Q'[ SELECT  TR_NUM      AS MSGKEY   ]'
            ||CHR(13)||CHR(10)||Q'[      ,  TR_SENDDATE AS SENDDATE ]'
            ||CHR(13)||CHR(10)||Q'[      ,  TR_RSLTSTAT AS RSLTSTAT ]'
            ||CHR(13)||CHR(10)||Q'[      ,  TR_PHONE    AS PHONE    ]'
            ||CHR(13)||CHR(10)||Q'[   FROM  (           ]';
            IF fr_sms_tbl_cnt > 0 THEN
                ls_sql_sms := ls_sql_sms
                ||CHR(13)||CHR(10)||Q'[         SELECT  TR_NUM      ]'
                ||CHR(13)||CHR(10)||Q'[              ,  TR_SENDDATE ]'
                ||CHR(13)||CHR(10)||Q'[              ,  TR_RSLTSTAT ]'
                ||CHR(13)||CHR(10)||Q'[              ,  TR_PHONE    ]'
                ||CHR(13)||CHR(10)||Q'[           FROM  ]' || fr_sms_tbl_nm;
            END IF;
            
            IF fr_sms_tbl_cnt > 0 AND to_sms_tbl_cnt > 0 THEN
                ls_sql_sms := ls_sql_sms
                ||CHR(13)||CHR(10)||Q'[         UNION ALL           ]';
            END IF;
            
            IF to_sms_tbl_cnt > 0 THEN
                ls_sql_sms := ls_sql_sms
                ||CHR(13)||CHR(10)||Q'[         SELECT  TR_NUM      ]'
                ||CHR(13)||CHR(10)||Q'[              ,  TR_SENDDATE ]'
                ||CHR(13)||CHR(10)||Q'[              ,  TR_RSLTSTAT ]'
                ||CHR(13)||CHR(10)||Q'[              ,  TR_PHONE    ]'
                ||CHR(13)||CHR(10)||Q'[           FROM  ]' || to_sms_tbl_nm;
            END IF;
            
            ls_sql_sms := ls_sql_sms
            ||CHR(13)||CHR(10)||Q'[         )           ]';
            
        ELSE
            ls_sql_sms := '';
        END IF;
        
        dbms_output.put_line(ls_sql_sms);
        
        -- 1. MMS 로그 테이블
        fr_mms_tbl_nm := 'MMS_LOG_' || SUBSTR(PSV_GFR_DATE, 1, 6);
        
        SELECT COUNT(*) INTO fr_mms_tbl_cnt
          FROM TAB
         WHERE TABTYPE  = 'TABLE'
           AND TNAME    = fr_mms_tbl_nm;
        
        to_mms_tbl_nm := 'MMS_LOG_' || SUBSTR(PSV_GTO_DATE, 1, 6);
        IF fr_mms_tbl_nm <> to_mms_tbl_nm THEN
            SELECT COUNT(*) INTO to_mms_tbl_cnt
              FROM TAB
             WHERE TABTYPE  = 'TABLE'
               AND TNAME    = to_mms_tbl_nm;
        ELSE
            to_mms_tbl_cnt := 0;
        END IF;
        
        IF fr_mms_tbl_cnt > 0 OR to_mms_tbl_cnt  > 0 THEN
            ls_sql_mms := ''
            ||CHR(13)||CHR(10)||Q'[ SELECT  MSGKEY                  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  REQDATE     AS SENDDATE ]'
            ||CHR(13)||CHR(10)||Q'[      ,  RSLT        AS RSLTSTAT ]'
            ||CHR(13)||CHR(10)||Q'[      ,  PHONE                   ]'
            ||CHR(13)||CHR(10)||Q'[   FROM  (           ]';
            IF fr_mms_tbl_cnt > 0 THEN
                ls_sql_mms := ls_sql_mms
                ||CHR(13)||CHR(10)||Q'[         SELECT  MSGKEY      ]'
                ||CHR(13)||CHR(10)||Q'[              ,  REQDATE     ]'
                ||CHR(13)||CHR(10)||Q'[              ,  RSLT        ]'
                ||CHR(13)||CHR(10)||Q'[              ,  PHONE       ]'
                ||CHR(13)||CHR(10)||Q'[           FROM  ]' || fr_mms_tbl_nm;
            END IF;
            
            IF fr_mms_tbl_cnt > 0 AND to_mms_tbl_cnt > 0 THEN
                ls_sql_mms := ls_sql_mms
                ||CHR(13)||CHR(10)||Q'[         UNION ALL           ]';
            END IF;
            
            IF to_mms_tbl_cnt > 0 THEN
                ls_sql_mms := ls_sql_mms
                ||CHR(13)||CHR(10)||Q'[         SELECT  MSGKEY      ]'
                ||CHR(13)||CHR(10)||Q'[              ,  REQDATE     ]'
                ||CHR(13)||CHR(10)||Q'[              ,  RSLT        ]'
                ||CHR(13)||CHR(10)||Q'[              ,  PHONE       ]'
                ||CHR(13)||CHR(10)||Q'[           FROM  ]' || to_mms_tbl_nm;
            END IF;
            
            ls_sql_mms := ls_sql_mms
            ||CHR(13)||CHR(10)||Q'[         )           ]';
            
        ELSE
            ls_sql_mms := '';
        END IF;
        
        dbms_output.put_line(ls_sql_mms);
        
        PKG_REPORT.RPT_PARA(PSV_COMP_CD,  PSV_USER,    PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
        ;
        
        IF (ls_sql_sms IS NOT NULL OR ls_sql_sms <> '') AND (ls_sql_mms IS NOT NULL OR ls_sql_mms <> '') THEN
            ls_sql_main := ''
            ||CHR(13)||CHR(10)||Q'[ SELECT  S.BRAND_CLASS                           ]'
            ||CHR(13)||CHR(10)||Q'[      ,  S.BRAND_CD                              ]'
            ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.BRAND_NM)         AS BRAND_NM     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_TP                               ]'
            ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.STOR_TP_NM)       AS STOR_TP_NM   ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (SL.MSGKEY IS NOT NULL                                    ) THEN 1 ELSE 0 END) AS SMS_SEND_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (SL.MSGKEY IS NOT NULL AND SL.RSLTSTAT = '00'             ) THEN 1 ELSE 0 END) AS SMS_WAIT_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (SL.MSGKEY IS NOT NULL AND SL.RSLTSTAT NOT IN ('00', '06')) THEN 1 ELSE 0 END) AS SMS_FAIL_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (SL.MSGKEY IS NOT NULL AND SL.RSLTSTAT = '06'             ) THEN 1 ELSE 0 END) AS SMS_SUCCESS_CNT  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (ML.MSGKEY IS NOT NULL                                    ) THEN 1 ELSE 0 END) AS MMS_SEND_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (ML.MSGKEY IS NOT NULL AND ML.RSLTSTAT IS NULL            ) THEN 1 ELSE 0 END) AS MMS_WAIT_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (ML.MSGKEY IS NOT NULL AND ML.RSLTSTAT <> '1000'          ) THEN 1 ELSE 0 END) AS MMS_FAIL_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (ML.MSGKEY IS NOT NULL AND ML.RSLTSTAT =  '1000'          ) THEN 1 ELSE 0 END) AS MMS_SUCCESS_CNT  ]'
            ||CHR(13)||CHR(10)||Q'[   FROM  CS_CONTENT_SEND     CS  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  S_STORE             S   ]'
            ||CHR(13)||CHR(10)||Q'[      ,  (                       ]'
            ||CHR(13)||CHR(10)||Q'[             ]' || ls_sql_sms
            ||CHR(13)||CHR(10)||Q'[         )   SL                  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  (                       ]'
            ||CHR(13)||CHR(10)||Q'[             ]' || ls_sql_mms
            ||CHR(13)||CHR(10)||Q'[         )   ML                  ]'
            ||CHR(13)||CHR(10)||Q'[  WHERE  SUBSTR(CS.SEND_DT, 1, 8) = TO_CHAR(SL.SENDDATE(+), 'YYYYMMDD')  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.MSGKEY       = SL.MSGKEY(+)  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  REPLACE(DECRYPT(CS.MOBILE), '-', '') = SL.PHONE(+)  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  SUBSTR(CS.SEND_DT, 1, 8) = TO_CHAR(ML.SENDDATE(+), 'YYYYMMDD')  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.MSGKEY       = ML.MSGKEY(+)  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  REPLACE(DECRYPT(CS.MOBILE), '-', '') = ML.PHONE(+)  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.COMP_CD      = S.COMP_CD     ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.BRAND_CD     = S.BRAND_CD    ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.STOR_CD      = S.STOR_CD     ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.COMP_CD      = :PSV_COMP_CD  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  SUBSTR(CS.SEND_DT, 1, 8) BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
            ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_DSTN_COMP IS NULL OR S.DSTN_COMP  = :PSV_DSTN_COMP)   ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.USE_YN       = 'Y'           ]'
            ||CHR(13)||CHR(10)||Q'[  GROUP  BY S.BRAND_CLASS, S.BRAND_CD, S.STOR_TP ]'
            ||CHR(13)||CHR(10)||Q'[  ORDER  BY S.BRAND_CLASS, S.BRAND_CD, S.STOR_TP ]';
            
            ls_sql := ls_sql || ls_sql_main;
            dbms_output.put_line(ls_sql);
        
            OPEN PR_RESULT FOR
                ls_sql USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_DSTN_COMP, PSV_DSTN_COMP;
            
        ELSIF (ls_sql_sms IS NOT NULL OR ls_sql_sms <> '') AND (ls_sql_mms IS NULL OR ls_sql_mms = '') THEN
            ls_sql_main := ''
            ||CHR(13)||CHR(10)||Q'[ SELECT  S.BRAND_CLASS                           ]'
            ||CHR(13)||CHR(10)||Q'[      ,  S.BRAND_CD                              ]'
            ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.BRAND_NM)         AS BRAND_NM     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_TP                               ]'
            ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.STOR_TP_NM)       AS STOR_TP_NM   ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (SL.MSGKEY IS NOT NULL                                    ) THEN 1 ELSE 0 END) AS SMS_SEND_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (SL.MSGKEY IS NOT NULL AND SL.RSLTSTAT = '00'             ) THEN 1 ELSE 0 END) AS SMS_WAIT_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (SL.MSGKEY IS NOT NULL AND SL.RSLTSTAT NOT IN ('00', '06')) THEN 1 ELSE 0 END) AS SMS_FAIL_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (SL.MSGKEY IS NOT NULL AND SL.RSLTSTAT = '06'             ) THEN 1 ELSE 0 END) AS SMS_SUCCESS_CNT  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS MMS_SEND_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS MMS_WAIT_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS MMS_FAIL_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS MMS_SUCCESS_CNT  ]'
            ||CHR(13)||CHR(10)||Q'[   FROM  CS_CONTENT_SEND     CS  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  S_STORE             S   ]'
            ||CHR(13)||CHR(10)||Q'[      ,  (                       ]'
            ||CHR(13)||CHR(10)||Q'[             ]' || ls_sql_sms
            ||CHR(13)||CHR(10)||Q'[         )   SL                  ]'
            ||CHR(13)||CHR(10)||Q'[  WHERE  SUBSTR(CS.SEND_DT, 1, 8) = TO_CHAR(SL.SENDDATE(+), 'YYYYMMDD')  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.MSGKEY       = SL.MSGKEY(+)  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  REPLACE(DECRYPT(CS.MOBILE), '-', '') = SL.PHONE(+)  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.COMP_CD      = S.COMP_CD     ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.BRAND_CD     = S.BRAND_CD    ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.STOR_CD      = S.STOR_CD     ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.COMP_CD      = :PSV_COMP_CD  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  SUBSTR(CS.SEND_DT, 1, 8) BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
            ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_DSTN_COMP IS NULL OR S.DSTN_COMP  = :PSV_DSTN_COMP)   ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.USE_YN       = 'Y'           ]'
            ||CHR(13)||CHR(10)||Q'[  GROUP  BY S.BRAND_CLASS, S.BRAND_CD, S.STOR_TP ]'
            ||CHR(13)||CHR(10)||Q'[  ORDER  BY S.BRAND_CLASS, S.BRAND_CD, S.STOR_TP ]';
            
            ls_sql := ls_sql || ls_sql_main;
            dbms_output.put_line(ls_sql);
        
            OPEN PR_RESULT FOR
                ls_sql USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_DSTN_COMP, PSV_DSTN_COMP;
                
        ELSIF (ls_sql_sms IS NULL OR ls_sql_sms = '') AND (ls_sql_mms IS NOT NULL OR ls_sql_mms <> '') THEN
            
            ls_sql_main := ''
            ||CHR(13)||CHR(10)||Q'[ SELECT  S.BRAND_CLASS                           ]'
            ||CHR(13)||CHR(10)||Q'[      ,  S.BRAND_CD                              ]'
            ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.BRAND_NM)         AS BRAND_NM     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_TP                               ]'
            ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.STOR_TP_NM)       AS STOR_TP_NM   ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS SMS_SEND_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS SMS_WAIT_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS SMS_FAIL_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS SMS_SUCCESS_CNT  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (ML.MSGKEY IS NOT NULL                                    ) THEN 1 ELSE 0 END) AS MMS_SEND_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (ML.MSGKEY IS NOT NULL AND ML.RSLTSTAT IS NULL            ) THEN 1 ELSE 0 END) AS MMS_WAIT_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (ML.MSGKEY IS NOT NULL AND ML.RSLTSTAT <> '1000'          ) THEN 1 ELSE 0 END) AS MMS_FAIL_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (ML.MSGKEY IS NOT NULL AND ML.RSLTSTAT =  '1000'          ) THEN 1 ELSE 0 END) AS MMS_SUCCESS_CNT  ]'
            ||CHR(13)||CHR(10)||Q'[   FROM  CS_CONTENT_SEND     CS  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  S_STORE             S   ]'
            ||CHR(13)||CHR(10)||Q'[      ,  (                       ]'
            ||CHR(13)||CHR(10)||Q'[             ]' || ls_sql_mms
            ||CHR(13)||CHR(10)||Q'[         )   ML                  ]'
            ||CHR(13)||CHR(10)||Q'[  WHERE  SUBSTR(CS.SEND_DT, 1, 8) = TO_CHAR(ML.SENDDATE(+), 'YYYYMMDD')  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.MSGKEY       = ML.MSGKEY(+)  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  REPLACE(DECRYPT(CS.MOBILE), '-', '') = ML.PHONE(+)  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.COMP_CD      = S.COMP_CD     ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.BRAND_CD     = S.BRAND_CD    ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.STOR_CD      = S.STOR_CD     ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.COMP_CD      = :PSV_COMP_CD  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  SUBSTR(CS.SEND_DT, 1, 8) BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
            ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_DSTN_COMP IS NULL OR S.DSTN_COMP  = :PSV_DSTN_COMP)   ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.USE_YN       = 'Y'           ]'
            ||CHR(13)||CHR(10)||Q'[  GROUP  BY S.BRAND_CLASS, S.BRAND_CD, S.STOR_TP ]'
            ||CHR(13)||CHR(10)||Q'[  ORDER  BY S.BRAND_CLASS, S.BRAND_CD, S.STOR_TP ]';
            
            ls_sql := ls_sql || ls_sql_main;
            dbms_output.put_line(ls_sql);
        
            OPEN PR_RESULT FOR
                ls_sql USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_DSTN_COMP, PSV_DSTN_COMP;
                
        ELSIF (ls_sql_sms IS NULL OR ls_sql_sms = '') AND (ls_sql_mms IS NULL OR ls_sql_mms = '') THEN
            
            ls_sql_main := ''
            ||CHR(13)||CHR(10)||Q'[ SELECT  S.BRAND_CLASS                           ]'
            ||CHR(13)||CHR(10)||Q'[      ,  S.BRAND_CD                              ]'
            ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.BRAND_NM)         AS BRAND_NM     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_TP                               ]'
            ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.STOR_TP_NM)       AS STOR_TP_NM   ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS SMS_SEND_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS SMS_WAIT_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS SMS_FAIL_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS SMS_SUCCESS_CNT  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS MMS_SEND_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS MMS_WAIT_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS MMS_FAIL_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS MMS_SUCCESS_CNT  ]'
            ||CHR(13)||CHR(10)||Q'[   FROM  CS_CONTENT_SEND     CS  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  S_STORE             S   ]'
            ||CHR(13)||CHR(10)||Q'[  WHERE  CS.COMP_CD      = S.COMP_CD     ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.BRAND_CD     = S.BRAND_CD    ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.STOR_CD      = S.STOR_CD     ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.COMP_CD      = :PSV_COMP_CD  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  SUBSTR(CS.SEND_DT, 1, 8) BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
            ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_DSTN_COMP IS NULL OR S.DSTN_COMP  = :PSV_DSTN_COMP)   ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.USE_YN       = 'Y'           ]'
            ||CHR(13)||CHR(10)||Q'[  GROUP  BY S.BRAND_CLASS, S.BRAND_CD, S.STOR_TP ]'
            ||CHR(13)||CHR(10)||Q'[  ORDER  BY S.BRAND_CLASS, S.BRAND_CD, S.STOR_TP ]';
            
            ls_sql := ls_sql || ls_sql_main;
            dbms_output.put_line(ls_sql);
        
            OPEN PR_RESULT FOR
                ls_sql USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_DSTN_COMP, PSV_DSTN_COMP;
                
        END IF;
        
        PR_RTN_CD  := ls_err_cd;
        PR_RTN_MSG := ls_err_msg;
        
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';

    EXCEPTION
        WHEN ERR_HANDLER THEN
            PR_RTN_CD  := ls_err_cd;
            PR_RTN_MSG := ls_err_msg;
            dbms_output.put_line( PR_RTN_MSG );
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
           
        WHEN OTHERS THEN
            PR_RTN_CD  := '4999999';
            PR_RTN_MSG := SQLERRM;
            dbms_output.put_line( PR_RTN_MSG );
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
    END;
    
    PROCEDURE SP_TAB04
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_GFR_DATE    IN  VARCHAR2 ,                -- 조회 시작일자
        PSV_GTO_DATE    IN  VARCHAR2 ,                -- 조회 종료일자
        PSV_DSTN_COMP   IN  VARCHAR2 ,                -- 유통사
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB04         문자메세지 정산(유통사)
        PURPOSE:
        
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-10-17         1. CREATED THIS PROCEDURE.
        
        NOTES:
            OBJECT NAME :   SP_TAB04
            SYSDATE     :   2016-10-17
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000);
    ls_sql_with     VARCHAR2(30000);
    ls_sql_main     VARCHAR2(30000);
    ls_sql_date     VARCHAR2(1000);
    ls_sql_store    VARCHAR2(20000);    -- 점포 WITH  S_STORE
    ls_sql_item     VARCHAR2(20000);    -- 제품 WITH  S_ITEM
    ls_sql_sms      VARCHAR2(20000);    -- SMS로그
    ls_sql_mms      VARCHAR2(20000);    -- MMS로그
    ls_date1        VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2        VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1     VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2     VARCHAR2(2000);     -- 조회일자 제외 (대비)
    fr_sms_tbl_nm   VARCHAR2(2000) := NULL; -- 조회 시작일자의 SMS전송로그 테이블명
    to_sms_tbl_nm   VARCHAR2(2000) := NULL; -- 조회 종료일자의 SMS전송로그 테이블명
    fr_mms_tbl_nm   VARCHAR2(2000) := NULL; -- 조회 시작일자의 MMS전송로그 테이블명
    to_mms_tbl_nm   VARCHAR2(2000) := NULL; -- 조회 종료일자의 MMS전송로그 테이블명
    fr_sms_tbl_cnt  NUMBER := 0;
    to_sms_tbl_cnt  NUMBER := 0;
    fr_mms_tbl_cnt  NUMBER := 0;
    to_mms_tbl_cnt  NUMBER := 0;
    ERR_HANDLER     EXCEPTION;
        
    ls_err_cd     VARCHAR2(7) := '0';
    ls_err_msg    VARCHAR2(500);
        
    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';
        
        -- SMS, MMS 로그 테이블 존재 체크 및 쿼리작성
        
        -- 1. SMS 로그 테이블
        fr_sms_tbl_nm := 'SC_LOG_' || SUBSTR(PSV_GFR_DATE, 1, 6);
        
        SELECT COUNT(*) INTO fr_sms_tbl_cnt
          FROM TAB
         WHERE TABTYPE  = 'TABLE'
           AND TNAME    = fr_sms_tbl_nm;
        
        to_sms_tbl_nm := 'SC_LOG_' || SUBSTR(PSV_GTO_DATE, 1, 6);
        IF fr_sms_tbl_nm <> to_sms_tbl_nm THEN
            SELECT COUNT(*) INTO to_sms_tbl_cnt
              FROM TAB
             WHERE TABTYPE  = 'TABLE'
               AND TNAME    = to_sms_tbl_nm;
        ELSE
            to_sms_tbl_cnt := 0;
        END IF;
        
        IF fr_sms_tbl_cnt > 0 OR to_sms_tbl_cnt  > 0 THEN
            ls_sql_sms := ''
            ||CHR(13)||CHR(10)||Q'[ SELECT  TR_NUM      AS MSGKEY   ]'
            ||CHR(13)||CHR(10)||Q'[      ,  TR_SENDDATE AS SENDDATE ]'
            ||CHR(13)||CHR(10)||Q'[      ,  TR_RSLTSTAT AS RSLTSTAT ]'
            ||CHR(13)||CHR(10)||Q'[      ,  TR_PHONE    AS PHONE    ]'
            ||CHR(13)||CHR(10)||Q'[   FROM  (           ]';
            IF fr_sms_tbl_cnt > 0 THEN
                ls_sql_sms := ls_sql_sms
                ||CHR(13)||CHR(10)||Q'[         SELECT  TR_NUM      ]'
                ||CHR(13)||CHR(10)||Q'[              ,  TR_SENDDATE ]'
                ||CHR(13)||CHR(10)||Q'[              ,  TR_RSLTSTAT ]'
                ||CHR(13)||CHR(10)||Q'[              ,  TR_PHONE    ]'
                ||CHR(13)||CHR(10)||Q'[           FROM  ]' || fr_sms_tbl_nm;
            END IF;
            
            IF fr_sms_tbl_cnt > 0 AND to_sms_tbl_cnt > 0 THEN
                ls_sql_sms := ls_sql_sms
                ||CHR(13)||CHR(10)||Q'[         UNION ALL           ]';
            END IF;
            
            IF to_sms_tbl_cnt > 0 THEN
                ls_sql_sms := ls_sql_sms
                ||CHR(13)||CHR(10)||Q'[         SELECT  TR_NUM      ]'
                ||CHR(13)||CHR(10)||Q'[              ,  TR_SENDDATE ]'
                ||CHR(13)||CHR(10)||Q'[              ,  TR_RSLTSTAT ]'
                ||CHR(13)||CHR(10)||Q'[              ,  TR_PHONE    ]'
                ||CHR(13)||CHR(10)||Q'[           FROM  ]' || to_sms_tbl_nm;
            END IF;
            
            ls_sql_sms := ls_sql_sms
            ||CHR(13)||CHR(10)||Q'[         )           ]';
            
        ELSE
            ls_sql_sms := '';
        END IF;
        
        dbms_output.put_line(ls_sql_sms);
        
        -- 1. MMS 로그 테이블
        fr_mms_tbl_nm := 'MMS_LOG_' || SUBSTR(PSV_GFR_DATE, 1, 6);
        
        SELECT COUNT(*) INTO fr_mms_tbl_cnt
          FROM TAB
         WHERE TABTYPE  = 'TABLE'
           AND TNAME    = fr_mms_tbl_nm;
        
        to_mms_tbl_nm := 'MMS_LOG_' || SUBSTR(PSV_GTO_DATE, 1, 6);
        IF fr_mms_tbl_nm <> to_mms_tbl_nm THEN
            SELECT COUNT(*) INTO to_mms_tbl_cnt
              FROM TAB
             WHERE TABTYPE  = 'TABLE'
               AND TNAME    = to_mms_tbl_nm;
        ELSE
            to_mms_tbl_cnt := 0;
        END IF;
        
        IF fr_mms_tbl_cnt > 0 OR to_mms_tbl_cnt  > 0 THEN
            ls_sql_mms := ''
            ||CHR(13)||CHR(10)||Q'[ SELECT  MSGKEY                  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  REQDATE     AS SENDDATE ]'
            ||CHR(13)||CHR(10)||Q'[      ,  RSLT        AS RSLTSTAT ]'
            ||CHR(13)||CHR(10)||Q'[      ,  PHONE                   ]'
            ||CHR(13)||CHR(10)||Q'[   FROM  (           ]';
            IF fr_mms_tbl_cnt > 0 THEN
                ls_sql_mms := ls_sql_mms
                ||CHR(13)||CHR(10)||Q'[         SELECT  MSGKEY      ]'
                ||CHR(13)||CHR(10)||Q'[              ,  REQDATE     ]'
                ||CHR(13)||CHR(10)||Q'[              ,  RSLT        ]'
                ||CHR(13)||CHR(10)||Q'[              ,  PHONE       ]'
                ||CHR(13)||CHR(10)||Q'[           FROM  ]' || fr_mms_tbl_nm;
            END IF;
            
            IF fr_mms_tbl_cnt > 0 AND to_mms_tbl_cnt > 0 THEN
                ls_sql_mms := ls_sql_mms
                ||CHR(13)||CHR(10)||Q'[         UNION ALL           ]';
            END IF;
            
            IF to_mms_tbl_cnt > 0 THEN
                ls_sql_mms := ls_sql_mms
                ||CHR(13)||CHR(10)||Q'[         SELECT  MSGKEY      ]'
                ||CHR(13)||CHR(10)||Q'[              ,  REQDATE     ]'
                ||CHR(13)||CHR(10)||Q'[              ,  RSLT        ]'
                ||CHR(13)||CHR(10)||Q'[              ,  PHONE       ]'
                ||CHR(13)||CHR(10)||Q'[           FROM  ]' || to_mms_tbl_nm;
            END IF;
            
            ls_sql_mms := ls_sql_mms
            ||CHR(13)||CHR(10)||Q'[         )           ]';
            
        ELSE
            ls_sql_mms := '';
        END IF;
        
        dbms_output.put_line(ls_sql_mms);
        
        PKG_REPORT.RPT_PARA(PSV_COMP_CD,  PSV_USER,    PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
        ;
        
        IF (ls_sql_sms IS NOT NULL OR ls_sql_sms <> '') AND (ls_sql_mms IS NOT NULL OR ls_sql_mms <> '') THEN
            
            ls_sql_main := ''
            ||CHR(13)||CHR(10)||Q'[ SELECT  S.BRAND_CLASS                           ]'
            ||CHR(13)||CHR(10)||Q'[      ,  S.BRAND_CD                              ]'
            ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.BRAND_NM)         AS BRAND_NM     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_TP                               ]'
            ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.STOR_TP_NM)       AS STOR_TP_NM   ]'
            ||CHR(13)||CHR(10)||Q'[      ,  S.DSTN_COMP                             ]'
            ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.DSTN_COMP_NM)     AS DSTN_COMP_NM ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (SL.MSGKEY IS NOT NULL                                    ) THEN 1 ELSE 0 END) AS SMS_SEND_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (SL.MSGKEY IS NOT NULL AND SL.RSLTSTAT = '00'             ) THEN 1 ELSE 0 END) AS SMS_WAIT_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (SL.MSGKEY IS NOT NULL AND SL.RSLTSTAT NOT IN ('00', '06')) THEN 1 ELSE 0 END) AS SMS_FAIL_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (SL.MSGKEY IS NOT NULL AND SL.RSLTSTAT = '06'             ) THEN 1 ELSE 0 END) AS SMS_SUCCESS_CNT  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (ML.MSGKEY IS NOT NULL                                    ) THEN 1 ELSE 0 END) AS MMS_SEND_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (ML.MSGKEY IS NOT NULL AND ML.RSLTSTAT IS NULL            ) THEN 1 ELSE 0 END) AS MMS_WAIT_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (ML.MSGKEY IS NOT NULL AND ML.RSLTSTAT <> '1000'          ) THEN 1 ELSE 0 END) AS MMS_FAIL_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (ML.MSGKEY IS NOT NULL AND ML.RSLTSTAT =  '1000'          ) THEN 1 ELSE 0 END) AS MMS_SUCCESS_CNT  ]'
            ||CHR(13)||CHR(10)||Q'[   FROM  CS_CONTENT_SEND     CS  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  S_STORE             S   ]'
            ||CHR(13)||CHR(10)||Q'[      ,  (                       ]'
            ||CHR(13)||CHR(10)||Q'[             ]' || ls_sql_sms
            ||CHR(13)||CHR(10)||Q'[         )   SL                  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  (                       ]'
            ||CHR(13)||CHR(10)||Q'[             ]' || ls_sql_mms
            ||CHR(13)||CHR(10)||Q'[         )   ML                  ]'
            ||CHR(13)||CHR(10)||Q'[  WHERE  SUBSTR(CS.SEND_DT, 1, 8) = TO_CHAR(SL.SENDDATE(+), 'YYYYMMDD')  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.MSGKEY       = SL.MSGKEY(+)  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  REPLACE(DECRYPT(CS.MOBILE), '-', '') = SL.PHONE(+)  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  SUBSTR(CS.SEND_DT, 1, 8) = TO_CHAR(ML.SENDDATE(+), 'YYYYMMDD')  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.MSGKEY       = ML.MSGKEY(+)  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  REPLACE(DECRYPT(CS.MOBILE), '-', '') = ML.PHONE(+)  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.COMP_CD      = S.COMP_CD     ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.BRAND_CD     = S.BRAND_CD    ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.STOR_CD      = S.STOR_CD     ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.COMP_CD      = :PSV_COMP_CD  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  SUBSTR(CS.SEND_DT, 1, 8) BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
            ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_DSTN_COMP IS NULL OR S.DSTN_COMP  = :PSV_DSTN_COMP)   ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.USE_YN       = 'Y'           ]'
            ||CHR(13)||CHR(10)||Q'[  GROUP  BY S.BRAND_CLASS, S.BRAND_CD, S.STOR_TP, S.DSTN_COMP    ]'
            ||CHR(13)||CHR(10)||Q'[  ORDER  BY S.BRAND_CLASS, S.BRAND_CD, S.STOR_TP, S.DSTN_COMP    ]';
            
            ls_sql := ls_sql || ls_sql_main;
            dbms_output.put_line(ls_sql);
        
            OPEN PR_RESULT FOR
                ls_sql USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_DSTN_COMP, PSV_DSTN_COMP;
            
        ELSIF (ls_sql_sms IS NOT NULL OR ls_sql_sms <> '') AND (ls_sql_mms IS NULL OR ls_sql_mms = '') THEN
            
            ls_sql_main := ''
            ||CHR(13)||CHR(10)||Q'[ SELECT  S.BRAND_CLASS                           ]'
            ||CHR(13)||CHR(10)||Q'[      ,  S.BRAND_CD                              ]'
            ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.BRAND_NM)         AS BRAND_NM     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_TP                               ]'
            ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.STOR_TP_NM)       AS STOR_TP_NM   ]'
            ||CHR(13)||CHR(10)||Q'[      ,  S.DSTN_COMP                             ]'
            ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.DSTN_COMP_NM)     AS DSTN_COMP_NM ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (SL.MSGKEY IS NOT NULL                                    ) THEN 1 ELSE 0 END) AS SMS_SEND_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (SL.MSGKEY IS NOT NULL AND SL.RSLTSTAT = '00'             ) THEN 1 ELSE 0 END) AS SMS_WAIT_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (SL.MSGKEY IS NOT NULL AND SL.RSLTSTAT NOT IN ('00', '06')) THEN 1 ELSE 0 END) AS SMS_FAIL_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (SL.MSGKEY IS NOT NULL AND SL.RSLTSTAT = '06'             ) THEN 1 ELSE 0 END) AS SMS_SUCCESS_CNT  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS MMS_SEND_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS MMS_WAIT_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS MMS_FAIL_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS MMS_SUCCESS_CNT  ]'
            ||CHR(13)||CHR(10)||Q'[   FROM  CS_CONTENT_SEND     CS  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  S_STORE             S   ]'
            ||CHR(13)||CHR(10)||Q'[      ,  (                       ]'
            ||CHR(13)||CHR(10)||Q'[             ]' || ls_sql_sms
            ||CHR(13)||CHR(10)||Q'[         )   SL                  ]'
            ||CHR(13)||CHR(10)||Q'[  WHERE  SUBSTR(CS.SEND_DT, 1, 8) = TO_CHAR(SL.SENDDATE(+), 'YYYYMMDD')  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.MSGKEY       = SL.MSGKEY(+)  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  REPLACE(DECRYPT(CS.MOBILE), '-', '') = SL.PHONE(+)  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.COMP_CD      = S.COMP_CD     ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.BRAND_CD     = S.BRAND_CD    ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.STOR_CD      = S.STOR_CD     ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.COMP_CD      = :PSV_COMP_CD  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  SUBSTR(CS.SEND_DT, 1, 8) BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
            ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_DSTN_COMP IS NULL OR S.DSTN_COMP  = :PSV_DSTN_COMP)   ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.USE_YN       = 'Y'           ]'
            ||CHR(13)||CHR(10)||Q'[  GROUP  BY S.BRAND_CLASS, S.BRAND_CD, S.STOR_TP, S.DSTN_COMP    ]'
            ||CHR(13)||CHR(10)||Q'[  ORDER  BY S.BRAND_CLASS, S.BRAND_CD, S.STOR_TP, S.DSTN_COMP    ]';
            
            ls_sql := ls_sql || ls_sql_main;
            dbms_output.put_line(ls_sql);
        
            OPEN PR_RESULT FOR
                ls_sql USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_DSTN_COMP, PSV_DSTN_COMP;
                
        ELSIF (ls_sql_sms IS NULL OR ls_sql_sms = '') AND (ls_sql_mms IS NOT NULL OR ls_sql_mms <> '') THEN
            
            ls_sql_main := ''
            ||CHR(13)||CHR(10)||Q'[ SELECT  S.BRAND_CLASS                           ]'
            ||CHR(13)||CHR(10)||Q'[      ,  S.BRAND_CD                              ]'
            ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.BRAND_NM)         AS BRAND_NM     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_TP                               ]'
            ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.STOR_TP_NM)       AS STOR_TP_NM   ]'
            ||CHR(13)||CHR(10)||Q'[      ,  S.DSTN_COMP                             ]'
            ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.DSTN_COMP_NM)     AS DSTN_COMP_NM ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS SMS_SEND_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS SMS_WAIT_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS SMS_FAIL_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS SMS_SUCCESS_CNT  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (ML.MSGKEY IS NOT NULL                                    ) THEN 1 ELSE 0 END) AS MMS_SEND_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (ML.MSGKEY IS NOT NULL AND ML.RSLTSTAT IS NULL            ) THEN 1 ELSE 0 END) AS MMS_WAIT_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (ML.MSGKEY IS NOT NULL AND ML.RSLTSTAT <> '1000'          ) THEN 1 ELSE 0 END) AS MMS_FAIL_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (ML.MSGKEY IS NOT NULL AND ML.RSLTSTAT =  '1000'          ) THEN 1 ELSE 0 END) AS MMS_SUCCESS_CNT  ]'
            ||CHR(13)||CHR(10)||Q'[   FROM  CS_CONTENT_SEND     CS  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  S_STORE             S   ]'
            ||CHR(13)||CHR(10)||Q'[      ,  (                       ]'
            ||CHR(13)||CHR(10)||Q'[             ]' || ls_sql_mms
            ||CHR(13)||CHR(10)||Q'[         )   ML                  ]'
            ||CHR(13)||CHR(10)||Q'[  WHERE  SUBSTR(CS.SEND_DT, 1, 8) = TO_CHAR(ML.SENDDATE(+), 'YYYYMMDD')  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.MSGKEY       = ML.MSGKEY(+)  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  REPLACE(DECRYPT(CS.MOBILE), '-', '') = ML.PHONE(+)  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.COMP_CD      = S.COMP_CD     ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.BRAND_CD     = S.BRAND_CD    ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.STOR_CD      = S.STOR_CD     ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.COMP_CD      = :PSV_COMP_CD  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  SUBSTR(CS.SEND_DT, 1, 8) BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
            ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_DSTN_COMP IS NULL OR S.DSTN_COMP  = :PSV_DSTN_COMP)   ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.USE_YN       = 'Y'           ]'
            ||CHR(13)||CHR(10)||Q'[  GROUP  BY S.BRAND_CLASS, S.BRAND_CD, S.STOR_TP, S.DSTN_COMP    ]'
            ||CHR(13)||CHR(10)||Q'[  ORDER  BY S.BRAND_CLASS, S.BRAND_CD, S.STOR_TP, S.DSTN_COMP    ]';
            
            ls_sql := ls_sql || ls_sql_main;
            dbms_output.put_line(ls_sql);
        
            OPEN PR_RESULT FOR
                ls_sql USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_DSTN_COMP, PSV_DSTN_COMP;
                
        ELSIF (ls_sql_sms IS NULL OR ls_sql_sms = '') AND (ls_sql_mms IS NULL OR ls_sql_mms = '') THEN
            
            ls_sql_main := ''
            ||CHR(13)||CHR(10)||Q'[ SELECT  S.BRAND_CLASS                           ]'
            ||CHR(13)||CHR(10)||Q'[      ,  S.BRAND_CD                              ]'
            ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.BRAND_NM)         AS BRAND_NM     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_TP                               ]'
            ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.STOR_TP_NM)       AS STOR_TP_NM   ]'
            ||CHR(13)||CHR(10)||Q'[      ,  S.DSTN_COMP                             ]'
            ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.DSTN_COMP_NM)     AS DSTN_COMP_NM ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS SMS_SEND_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS SMS_WAIT_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS SMS_FAIL_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS SMS_SUCCESS_CNT  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS MMS_SEND_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS MMS_WAIT_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS MMS_FAIL_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS MMS_SUCCESS_CNT  ]'
            ||CHR(13)||CHR(10)||Q'[   FROM  CS_CONTENT_SEND     CS  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  S_STORE             S   ]'
            ||CHR(13)||CHR(10)||Q'[  WHERE  CS.COMP_CD      = S.COMP_CD     ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.BRAND_CD     = S.BRAND_CD    ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.STOR_CD      = S.STOR_CD     ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.COMP_CD      = :PSV_COMP_CD  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  SUBSTR(CS.SEND_DT, 1, 8) BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
            ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_DSTN_COMP IS NULL OR S.DSTN_COMP  = :PSV_DSTN_COMP)   ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.USE_YN       = 'Y'           ]'
            ||CHR(13)||CHR(10)||Q'[  GROUP  BY S.BRAND_CLASS, S.BRAND_CD, S.STOR_TP, S.DSTN_COMP    ]'
            ||CHR(13)||CHR(10)||Q'[  ORDER  BY S.BRAND_CLASS, S.BRAND_CD, S.STOR_TP, S.DSTN_COMP    ]';
            
            ls_sql := ls_sql || ls_sql_main;
            dbms_output.put_line(ls_sql);
        
            OPEN PR_RESULT FOR
                ls_sql USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_DSTN_COMP, PSV_DSTN_COMP;
                
        END IF;
        
        PR_RTN_CD  := ls_err_cd;
        PR_RTN_MSG := ls_err_msg;
        
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';

    EXCEPTION
        WHEN ERR_HANDLER THEN
            PR_RTN_CD  := ls_err_cd;
            PR_RTN_MSG := ls_err_msg;
            dbms_output.put_line( PR_RTN_MSG );
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
           
        WHEN OTHERS THEN
            PR_RTN_CD  := '4999999';
            PR_RTN_MSG := SQLERRM;
            dbms_output.put_line( PR_RTN_MSG );
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
    END;
    
    PROCEDURE SP_TAB05
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_GFR_DATE    IN  VARCHAR2 ,                -- 조회 시작일자
        PSV_GTO_DATE    IN  VARCHAR2 ,                -- 조회 종료일자
        PSV_DSTN_COMP   IN  VARCHAR2 ,                -- 유통사
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB05         문자메세지 정산(점포)
        PURPOSE:
        
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-10-17         1. CREATED THIS PROCEDURE.
        
        NOTES:
            OBJECT NAME :   SP_TAB05
            SYSDATE     :   2016-10-17
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000);
    ls_sql_with     VARCHAR2(30000);
    ls_sql_main     VARCHAR2(30000);
    ls_sql_date     VARCHAR2(1000);
    ls_sql_store    VARCHAR2(20000);    -- 점포 WITH  S_STORE
    ls_sql_item     VARCHAR2(20000);    -- 제품 WITH  S_ITEM
    ls_sql_sms      VARCHAR2(20000);    -- SMS로그
    ls_sql_mms      VARCHAR2(20000);    -- MMS로그
    ls_date1        VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2        VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1     VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2     VARCHAR2(2000);     -- 조회일자 제외 (대비)
    fr_sms_tbl_nm   VARCHAR2(2000) := NULL; -- 조회 시작일자의 SMS전송로그 테이블명
    to_sms_tbl_nm   VARCHAR2(2000) := NULL; -- 조회 종료일자의 SMS전송로그 테이블명
    fr_mms_tbl_nm   VARCHAR2(2000) := NULL; -- 조회 시작일자의 MMS전송로그 테이블명
    to_mms_tbl_nm   VARCHAR2(2000) := NULL; -- 조회 종료일자의 MMS전송로그 테이블명
    fr_sms_tbl_cnt  NUMBER := 0;
    to_sms_tbl_cnt  NUMBER := 0;
    fr_mms_tbl_cnt  NUMBER := 0;
    to_mms_tbl_cnt  NUMBER := 0;
    ERR_HANDLER     EXCEPTION;
        
    ls_err_cd     VARCHAR2(7) := '0';
    ls_err_msg    VARCHAR2(500);
        
    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';
        
        -- SMS, MMS 로그 테이블 존재 체크 및 쿼리작성
        
        -- 1. SMS 로그 테이블
        fr_sms_tbl_nm := 'SC_LOG_' || SUBSTR(PSV_GFR_DATE, 1, 6);
        
        SELECT COUNT(*) INTO fr_sms_tbl_cnt
          FROM TAB
         WHERE TABTYPE  = 'TABLE'
           AND TNAME    = fr_sms_tbl_nm;
        
        to_sms_tbl_nm := 'SC_LOG_' || SUBSTR(PSV_GTO_DATE, 1, 6);
        IF fr_sms_tbl_nm <> to_sms_tbl_nm THEN
            SELECT COUNT(*) INTO to_sms_tbl_cnt
              FROM TAB
             WHERE TABTYPE  = 'TABLE'
               AND TNAME    = to_sms_tbl_nm;
        ELSE
            to_sms_tbl_cnt := 0;
        END IF;
        
        IF fr_sms_tbl_cnt > 0 OR to_sms_tbl_cnt  > 0 THEN
            ls_sql_sms := ''
            ||CHR(13)||CHR(10)||Q'[ SELECT  TR_NUM      AS MSGKEY   ]'
            ||CHR(13)||CHR(10)||Q'[      ,  TR_SENDDATE AS SENDDATE ]'
            ||CHR(13)||CHR(10)||Q'[      ,  TR_RSLTSTAT AS RSLTSTAT ]'
            ||CHR(13)||CHR(10)||Q'[      ,  TR_PHONE    AS PHONE    ]'
            ||CHR(13)||CHR(10)||Q'[   FROM  (           ]';
            IF fr_sms_tbl_cnt > 0 THEN
                ls_sql_sms := ls_sql_sms
                ||CHR(13)||CHR(10)||Q'[         SELECT  TR_NUM      ]'
                ||CHR(13)||CHR(10)||Q'[              ,  TR_SENDDATE ]'
                ||CHR(13)||CHR(10)||Q'[              ,  TR_RSLTSTAT ]'
                ||CHR(13)||CHR(10)||Q'[              ,  TR_PHONE    ]'
                ||CHR(13)||CHR(10)||Q'[           FROM  ]' || fr_sms_tbl_nm;
            END IF;
            
            IF fr_sms_tbl_cnt > 0 AND to_sms_tbl_cnt > 0 THEN
                ls_sql_sms := ls_sql_sms
                ||CHR(13)||CHR(10)||Q'[         UNION ALL           ]';
            END IF;
            
            IF to_sms_tbl_cnt > 0 THEN
                ls_sql_sms := ls_sql_sms
                ||CHR(13)||CHR(10)||Q'[         SELECT  TR_NUM      ]'
                ||CHR(13)||CHR(10)||Q'[              ,  TR_SENDDATE ]'
                ||CHR(13)||CHR(10)||Q'[              ,  TR_RSLTSTAT ]'
                ||CHR(13)||CHR(10)||Q'[              ,  TR_PHONE    ]'
                ||CHR(13)||CHR(10)||Q'[           FROM  ]' || to_sms_tbl_nm;
            END IF;
            
            ls_sql_sms := ls_sql_sms
            ||CHR(13)||CHR(10)||Q'[         )           ]';
            
        ELSE
            ls_sql_sms := '';
        END IF;
        
        dbms_output.put_line(ls_sql_sms);
        
        -- 1. MMS 로그 테이블
        fr_mms_tbl_nm := 'MMS_LOG_' || SUBSTR(PSV_GFR_DATE, 1, 6);
        
        SELECT COUNT(*) INTO fr_mms_tbl_cnt
          FROM TAB
         WHERE TABTYPE  = 'TABLE'
           AND TNAME    = fr_mms_tbl_nm;
        
        to_mms_tbl_nm := 'MMS_LOG_' || SUBSTR(PSV_GTO_DATE, 1, 6);
        IF fr_mms_tbl_nm <> to_mms_tbl_nm THEN
            SELECT COUNT(*) INTO to_mms_tbl_cnt
              FROM TAB
             WHERE TABTYPE  = 'TABLE'
               AND TNAME    = to_mms_tbl_nm;
        ELSE
            to_mms_tbl_cnt := 0;
        END IF;
        
        IF fr_mms_tbl_cnt > 0 OR to_mms_tbl_cnt  > 0 THEN
            ls_sql_mms := ''
            ||CHR(13)||CHR(10)||Q'[ SELECT  MSGKEY                  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  REQDATE     AS SENDDATE ]'
            ||CHR(13)||CHR(10)||Q'[      ,  RSLT        AS RSLTSTAT ]'
            ||CHR(13)||CHR(10)||Q'[      ,  PHONE                   ]'
            ||CHR(13)||CHR(10)||Q'[   FROM  (           ]';
            IF fr_mms_tbl_cnt > 0 THEN
                ls_sql_mms := ls_sql_mms
                ||CHR(13)||CHR(10)||Q'[         SELECT  MSGKEY      ]'
                ||CHR(13)||CHR(10)||Q'[              ,  REQDATE     ]'
                ||CHR(13)||CHR(10)||Q'[              ,  RSLT        ]'
                ||CHR(13)||CHR(10)||Q'[              ,  PHONE       ]'
                ||CHR(13)||CHR(10)||Q'[           FROM  ]' || fr_mms_tbl_nm;
            END IF;
            
            IF fr_mms_tbl_cnt > 0 AND to_mms_tbl_cnt > 0 THEN
                ls_sql_mms := ls_sql_mms
                ||CHR(13)||CHR(10)||Q'[         UNION ALL           ]';
            END IF;
            
            IF to_mms_tbl_cnt > 0 THEN
                ls_sql_mms := ls_sql_mms
                ||CHR(13)||CHR(10)||Q'[         SELECT  MSGKEY      ]'
                ||CHR(13)||CHR(10)||Q'[              ,  REQDATE     ]'
                ||CHR(13)||CHR(10)||Q'[              ,  RSLT        ]'
                ||CHR(13)||CHR(10)||Q'[              ,  PHONE       ]'
                ||CHR(13)||CHR(10)||Q'[           FROM  ]' || to_mms_tbl_nm;
            END IF;
            
            ls_sql_mms := ls_sql_mms
            ||CHR(13)||CHR(10)||Q'[         )           ]';
            
        ELSE
            ls_sql_mms := '';
        END IF;
        
        dbms_output.put_line(ls_sql_mms);
        
        PKG_REPORT.RPT_PARA(PSV_COMP_CD,  PSV_USER,    PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
        ;
        
        IF (ls_sql_sms IS NOT NULL OR ls_sql_sms <> '') AND (ls_sql_mms IS NOT NULL OR ls_sql_mms <> '') THEN
            
            ls_sql_main := ''
            ||CHR(13)||CHR(10)||Q'[ SELECT  S.BRAND_CLASS                           ]'
            ||CHR(13)||CHR(10)||Q'[      ,  S.BRAND_CD                              ]'
            ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.BRAND_NM)         AS BRAND_NM     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_TP                               ]'
            ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.STOR_TP_NM)       AS STOR_TP_NM   ]'
            ||CHR(13)||CHR(10)||Q'[      ,  S.DSTN_COMP                             ]'
            ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.DSTN_COMP_NM)     AS DSTN_COMP_NM ]'
            ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_CD                               ]'
            ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.STOR_NM)          AS STOR_NM      ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (SL.MSGKEY IS NOT NULL                                    ) THEN 1 ELSE 0 END) AS SMS_SEND_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (SL.MSGKEY IS NOT NULL AND SL.RSLTSTAT = '00'             ) THEN 1 ELSE 0 END) AS SMS_WAIT_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (SL.MSGKEY IS NOT NULL AND SL.RSLTSTAT NOT IN ('00', '06')) THEN 1 ELSE 0 END) AS SMS_FAIL_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (SL.MSGKEY IS NOT NULL AND SL.RSLTSTAT = '06'             ) THEN 1 ELSE 0 END) AS SMS_SUCCESS_CNT  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (ML.MSGKEY IS NOT NULL                                    ) THEN 1 ELSE 0 END) AS MMS_SEND_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (ML.MSGKEY IS NOT NULL AND ML.RSLTSTAT IS NULL            ) THEN 1 ELSE 0 END) AS MMS_WAIT_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (ML.MSGKEY IS NOT NULL AND ML.RSLTSTAT <> '1000'          ) THEN 1 ELSE 0 END) AS MMS_FAIL_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (ML.MSGKEY IS NOT NULL AND ML.RSLTSTAT =  '1000'          ) THEN 1 ELSE 0 END) AS MMS_SUCCESS_CNT  ]'
            ||CHR(13)||CHR(10)||Q'[   FROM  CS_CONTENT_SEND     CS  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  S_STORE             S   ]'
            ||CHR(13)||CHR(10)||Q'[      ,  (                       ]'
            ||CHR(13)||CHR(10)||Q'[             ]' || ls_sql_sms
            ||CHR(13)||CHR(10)||Q'[         )   SL                  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  (                       ]'
            ||CHR(13)||CHR(10)||Q'[             ]' || ls_sql_mms
            ||CHR(13)||CHR(10)||Q'[         )   ML                  ]'
            ||CHR(13)||CHR(10)||Q'[  WHERE  SUBSTR(CS.SEND_DT, 1, 8) = TO_CHAR(SL.SENDDATE(+), 'YYYYMMDD')  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.MSGKEY       = SL.MSGKEY(+)  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  REPLACE(DECRYPT(CS.MOBILE), '-', '') = SL.PHONE(+)  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  SUBSTR(CS.SEND_DT, 1, 8) = TO_CHAR(ML.SENDDATE(+), 'YYYYMMDD')  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.MSGKEY       = ML.MSGKEY(+)  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  REPLACE(DECRYPT(CS.MOBILE), '-', '') = ML.PHONE(+)  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.COMP_CD      = S.COMP_CD     ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.BRAND_CD     = S.BRAND_CD    ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.STOR_CD      = S.STOR_CD     ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.COMP_CD      = :PSV_COMP_CD  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  SUBSTR(CS.SEND_DT, 1, 8) BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
            ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_DSTN_COMP IS NULL OR S.DSTN_COMP  = :PSV_DSTN_COMP)   ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.USE_YN       = 'Y'           ]'
            ||CHR(13)||CHR(10)||Q'[  GROUP  BY S.BRAND_CLASS, S.BRAND_CD, S.STOR_TP, S.DSTN_COMP, S.STOR_CD ]'
            ||CHR(13)||CHR(10)||Q'[  ORDER  BY S.BRAND_CLASS, S.BRAND_CD, S.STOR_TP, S.DSTN_COMP, S.STOR_CD ]';
            
            ls_sql := ls_sql || ls_sql_main;
            dbms_output.put_line(ls_sql);
        
            OPEN PR_RESULT FOR
                ls_sql USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_DSTN_COMP, PSV_DSTN_COMP;
            
        ELSIF (ls_sql_sms IS NOT NULL OR ls_sql_sms <> '') AND (ls_sql_mms IS NULL OR ls_sql_mms = '') THEN
            
            ls_sql_main := ''
            ||CHR(13)||CHR(10)||Q'[ SELECT  S.BRAND_CLASS                           ]'
            ||CHR(13)||CHR(10)||Q'[      ,  S.BRAND_CD                              ]'
            ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.BRAND_NM)         AS BRAND_NM     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_TP                               ]'
            ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.STOR_TP_NM)       AS STOR_TP_NM   ]'
            ||CHR(13)||CHR(10)||Q'[      ,  S.DSTN_COMP                             ]'
            ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.DSTN_COMP_NM)     AS DSTN_COMP_NM ]'
            ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_CD                               ]'
            ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.STOR_NM)          AS STOR_NM      ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (SL.MSGKEY IS NOT NULL                                    ) THEN 1 ELSE 0 END) AS SMS_SEND_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (SL.MSGKEY IS NOT NULL AND SL.RSLTSTAT = '00'             ) THEN 1 ELSE 0 END) AS SMS_WAIT_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (SL.MSGKEY IS NOT NULL AND SL.RSLTSTAT NOT IN ('00', '06')) THEN 1 ELSE 0 END) AS SMS_FAIL_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (SL.MSGKEY IS NOT NULL AND SL.RSLTSTAT = '06'             ) THEN 1 ELSE 0 END) AS SMS_SUCCESS_CNT  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS MMS_SEND_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS MMS_WAIT_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS MMS_FAIL_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS MMS_SUCCESS_CNT  ]'
            ||CHR(13)||CHR(10)||Q'[   FROM  CS_CONTENT_SEND     CS  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  S_STORE             S   ]'
            ||CHR(13)||CHR(10)||Q'[      ,  (                       ]'
            ||CHR(13)||CHR(10)||Q'[             ]' || ls_sql_sms
            ||CHR(13)||CHR(10)||Q'[         )   SL                  ]'
            ||CHR(13)||CHR(10)||Q'[  WHERE  SUBSTR(CS.SEND_DT, 1, 8) = TO_CHAR(SL.SENDDATE(+), 'YYYYMMDD')  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.MSGKEY       = SL.MSGKEY(+)  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  REPLACE(DECRYPT(CS.MOBILE), '-', '') = SL.PHONE(+)  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.COMP_CD      = S.COMP_CD     ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.BRAND_CD     = S.BRAND_CD    ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.STOR_CD      = S.STOR_CD     ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.COMP_CD      = :PSV_COMP_CD  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  SUBSTR(CS.SEND_DT, 1, 8) BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
            ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_DSTN_COMP IS NULL OR S.DSTN_COMP  = :PSV_DSTN_COMP)   ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.USE_YN       = 'Y'           ]'
            ||CHR(13)||CHR(10)||Q'[  GROUP  BY S.BRAND_CLASS, S.BRAND_CD, S.STOR_TP, S.DSTN_COMP, S.STOR_CD ]'
            ||CHR(13)||CHR(10)||Q'[  ORDER  BY S.BRAND_CLASS, S.BRAND_CD, S.STOR_TP, S.DSTN_COMP, S.STOR_CD ]';
            
            ls_sql := ls_sql || ls_sql_main;
            dbms_output.put_line(ls_sql);
        
            OPEN PR_RESULT FOR
                ls_sql USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_DSTN_COMP, PSV_DSTN_COMP;
                
        ELSIF (ls_sql_sms IS NULL OR ls_sql_sms = '') AND (ls_sql_mms IS NOT NULL OR ls_sql_mms <> '') THEN
            
            ls_sql_main := ''
            ||CHR(13)||CHR(10)||Q'[ SELECT  S.BRAND_CLASS                           ]'
            ||CHR(13)||CHR(10)||Q'[      ,  S.BRAND_CD                              ]'
            ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.BRAND_NM)         AS BRAND_NM     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_TP                               ]'
            ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.STOR_TP_NM)       AS STOR_TP_NM   ]'
            ||CHR(13)||CHR(10)||Q'[      ,  S.DSTN_COMP                             ]'
            ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.DSTN_COMP_NM)     AS DSTN_COMP_NM ]'
            ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_CD                               ]'
            ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.STOR_NM)          AS STOR_NM      ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS SMS_SEND_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS SMS_WAIT_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS SMS_FAIL_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS SMS_SUCCESS_CNT  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (ML.MSGKEY IS NOT NULL                                    ) THEN 1 ELSE 0 END) AS MMS_SEND_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (ML.MSGKEY IS NOT NULL AND ML.RSLTSTAT IS NULL            ) THEN 1 ELSE 0 END) AS MMS_WAIT_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (ML.MSGKEY IS NOT NULL AND ML.RSLTSTAT <> '1000'          ) THEN 1 ELSE 0 END) AS MMS_FAIL_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN (ML.MSGKEY IS NOT NULL AND ML.RSLTSTAT =  '1000'          ) THEN 1 ELSE 0 END) AS MMS_SUCCESS_CNT  ]'
            ||CHR(13)||CHR(10)||Q'[   FROM  CS_CONTENT_SEND     CS  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  S_STORE             S   ]'
            ||CHR(13)||CHR(10)||Q'[      ,  (                       ]'
            ||CHR(13)||CHR(10)||Q'[             ]' || ls_sql_mms
            ||CHR(13)||CHR(10)||Q'[         )   ML                  ]'
            ||CHR(13)||CHR(10)||Q'[  WHERE  SUBSTR(CS.SEND_DT, 1, 8) = TO_CHAR(ML.SENDDATE(+), 'YYYYMMDD')  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.MSGKEY       = ML.MSGKEY(+)  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  REPLACE(DECRYPT(CS.MOBILE), '-', '') = ML.PHONE(+)  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.COMP_CD      = S.COMP_CD     ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.BRAND_CD     = S.BRAND_CD    ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.STOR_CD      = S.STOR_CD     ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.COMP_CD      = :PSV_COMP_CD  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  SUBSTR(CS.SEND_DT, 1, 8) BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
            ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_DSTN_COMP IS NULL OR S.DSTN_COMP  = :PSV_DSTN_COMP)   ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.USE_YN       = 'Y'           ]'
            ||CHR(13)||CHR(10)||Q'[  GROUP  BY S.BRAND_CLASS, S.BRAND_CD, S.STOR_TP, S.DSTN_COMP, S.STOR_CD ]'
            ||CHR(13)||CHR(10)||Q'[  ORDER  BY S.BRAND_CLASS, S.BRAND_CD, S.STOR_TP, S.DSTN_COMP, S.STOR_CD ]';
            
            ls_sql := ls_sql || ls_sql_main;
            dbms_output.put_line(ls_sql);
        
            OPEN PR_RESULT FOR
                ls_sql USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_DSTN_COMP, PSV_DSTN_COMP;
                
        ELSIF (ls_sql_sms IS NULL OR ls_sql_sms = '') AND (ls_sql_mms IS NULL OR ls_sql_mms = '') THEN
            
            ls_sql_main := ''
            ||CHR(13)||CHR(10)||Q'[ SELECT  S.BRAND_CLASS                           ]'
            ||CHR(13)||CHR(10)||Q'[      ,  S.BRAND_CD                              ]'
            ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.BRAND_NM)         AS BRAND_NM     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_TP                               ]'
            ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.STOR_TP_NM)       AS STOR_TP_NM   ]'
            ||CHR(13)||CHR(10)||Q'[      ,  S.DSTN_COMP                             ]'
            ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.DSTN_COMP_NM)     AS DSTN_COMP_NM ]'
            ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_CD                               ]'
            ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.STOR_NM)          AS STOR_NM      ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS SMS_SEND_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS SMS_WAIT_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS SMS_FAIL_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS SMS_SUCCESS_CNT  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS MMS_SEND_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS MMS_WAIT_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS MMS_FAIL_CNT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SUM(0) AS MMS_SUCCESS_CNT  ]'
            ||CHR(13)||CHR(10)||Q'[   FROM  CS_CONTENT_SEND     CS  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  S_STORE             S   ]'
            ||CHR(13)||CHR(10)||Q'[  WHERE  CS.COMP_CD      = S.COMP_CD     ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.BRAND_CD     = S.BRAND_CD    ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.STOR_CD      = S.STOR_CD     ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.COMP_CD      = :PSV_COMP_CD  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  SUBSTR(CS.SEND_DT, 1, 8) BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
            ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_DSTN_COMP IS NULL OR S.DSTN_COMP  = :PSV_DSTN_COMP)   ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.USE_YN       = 'Y'           ]'
            ||CHR(13)||CHR(10)||Q'[  GROUP  BY S.BRAND_CLASS, S.BRAND_CD, S.STOR_TP, S.DSTN_COMP, S.STOR_CD ]'
            ||CHR(13)||CHR(10)||Q'[  ORDER  BY S.BRAND_CLASS, S.BRAND_CD, S.STOR_TP, S.DSTN_COMP, S.STOR_CD ]';
            
            ls_sql := ls_sql || ls_sql_main;
            dbms_output.put_line(ls_sql);
        
            OPEN PR_RESULT FOR
                ls_sql USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_DSTN_COMP, PSV_DSTN_COMP;
                
        END IF;
        
        PR_RTN_CD  := ls_err_cd;
        PR_RTN_MSG := ls_err_msg;
        
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';

    EXCEPTION
        WHEN ERR_HANDLER THEN
            PR_RTN_CD  := ls_err_cd;
            PR_RTN_MSG := ls_err_msg;
            dbms_output.put_line( PR_RTN_MSG );
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
           
        WHEN OTHERS THEN
            PR_RTN_CD  := '4999999';
            PR_RTN_MSG := SQLERRM;
            dbms_output.put_line( PR_RTN_MSG );
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
    END;
    
END PKG_GCRM1080;

/
