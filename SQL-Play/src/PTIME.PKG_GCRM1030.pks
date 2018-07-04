CREATE OR REPLACE PACKAGE       PKG_GCRM1030 AS

    ---------------------------------------------------------------------------------------------------
    --  Package Name     : PKG_GCRM1030
    --  Description      : 문자메세지 발송 현황(점포)
    -- Ref. Table        :
    ---------------------------------------------------------------------------------------------------

    
    PROCEDURE SP_MAIN
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
        PSV_MEMBER_TXT  IN  VARCHAR2 ,                -- 회원번호/명
        PSV_MOBILE      IN  VARCHAR2 ,                -- 핸드폰
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    );

END PKG_GCRM1030;

/

CREATE OR REPLACE PACKAGE BODY       PKG_GCRM1030 AS

    PROCEDURE SP_MAIN
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
        PSV_MEMBER_TXT  IN  VARCHAR2 ,                -- 회원번호/명
        PSV_MOBILE      IN  VARCHAR2 ,                -- 핸드폰
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_MAIN         문자메세지 발송 현황(점포)
        PURPOSE:
        
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-06-22         1. CREATED THIS PROCEDURE.
        
        NOTES:
            OBJECT NAME :   SP_MAIN
            SYSDATE     :   2016-06-22
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
            ||CHR(13)||CHR(10)||Q'[   FROM  (           ]';
            IF fr_sms_tbl_cnt > 0 THEN
                ls_sql_sms := ls_sql_sms
                ||CHR(13)||CHR(10)||Q'[         SELECT  TR_NUM      ]'
                ||CHR(13)||CHR(10)||Q'[              ,  TR_SENDDATE ]'
                ||CHR(13)||CHR(10)||Q'[              ,  TR_RSLTSTAT ]'
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
            ||CHR(13)||CHR(10)||Q'[   FROM  (           ]';
            IF fr_mms_tbl_cnt > 0 THEN
                ls_sql_mms := ls_sql_mms
                ||CHR(13)||CHR(10)||Q'[         SELECT  MSGKEY      ]'
                ||CHR(13)||CHR(10)||Q'[              ,  REQDATE     ]'
                ||CHR(13)||CHR(10)||Q'[              ,  RSLT        ]'
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
            ||CHR(13)||CHR(10)||Q'[ SELECT  CS.COMP_CD      ]'
            ||CHR(13)||CHR(10)||Q'[      ,  TO_CHAR(TO_DATE(CS.SEND_DT, 'YYYYMMDDHH24MISS'), 'YYYY-MM-DD HH24:MI:SS')   AS SEND_DT_D  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  CS.SEND_DT      ]'
            ||CHR(13)||CHR(10)||Q'[      ,  CS.SEND_SEQ     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  CS.SUBJECT      ]'
            ||CHR(13)||CHR(10)||Q'[      ,  CS.CONTENT      ]'
            ||CHR(13)||CHR(10)||Q'[      ,  CS.MEMBER_NO    ]'
            ||CHR(13)||CHR(10)||Q'[      ,  DECRYPT(M.MEMBER_NM)    AS MEMBER_NM                ]'
            ||CHR(13)||CHR(10)||Q'[      ,  FN_GET_FORMAT_HP_NO(DECRYPT(CS.MOBILE)) AS MOBILE   ]'
            ||CHR(13)||CHR(10)||Q'[      ,  CS.SEND_DIV     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  TO_CHAR(TO_DATE(CS.RESV_DT, 'YYYYMMDDHH24MI'), 'YYYY-MM-DD HH24:MI')    AS RESV_DT  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  CS.SEND_MOBILE  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  CS.MSGKEY  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  NVL(SL.RSLTSTAT, ML.RSLTSTAT)   AS RSLTSTAT ]'
            ||CHR(13)||CHR(10)||Q'[      ,  NVL(GET_COMMON_CODE_NM(:PSV_COMP_CD, '01920', SL.RSLTSTAT, :PSV_LANG_CD), GET_COMMON_CODE_NM(:PSV_COMP_CD, '01925', ML.RSLTSTAT, :PSV_LANG_CD)) AS RSLTMSG  ]'
            ||CHR(13)||CHR(10)||Q'[   FROM  CS_CONTENT_SEND     CS  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  CS_MEMBER           M   ]'
            ||CHR(13)||CHR(10)||Q'[      ,  S_STORE             S   ]'
            ||CHR(13)||CHR(10)||Q'[      ,  (                       ]'
            ||CHR(13)||CHR(10)||Q'[             ]' || ls_sql_sms
            ||CHR(13)||CHR(10)||Q'[         )   SL                  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  (                       ]'
            ||CHR(13)||CHR(10)||Q'[             ]' || ls_sql_mms
            ||CHR(13)||CHR(10)||Q'[         )   ML                  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SC_TRAN             ST  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  MMS_MSG             MM  ]'
            ||CHR(13)||CHR(10)||Q'[  WHERE  CS.COMP_CD      = M.COMP_CD(+)  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.MEMBER_NO    = M.MEMBER_NO(+)]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.MSGKEY       = SL.MSGKEY(+)  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.MSGKEY       = ML.MSGKEY(+)  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.MSGKEY       = ST.TR_NUM(+)  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.MSGKEY       = MM.MSGKEY(+)  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.COMP_CD      = S.COMP_CD     ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.BRAND_CD     = S.BRAND_CD    ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.STOR_CD      = S.STOR_CD     ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.COMP_CD      = :PSV_COMP_CD  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  SUBSTR(CS.SEND_DT, 1, 8) BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
            ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_MEMBER_TXT IS NULL OR (CS.MEMBER_NO LIKE '%'||:PSV_MEMBER_TXT||'%' OR DECRYPT(M.MEMBER_NM) LIKE '%'||:PSV_MEMBER_TXT||'%'))   ]'
            ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_MOBILE IS NULL OR CS.MOBILE = ENCRYPT(REPLACE(:PSV_MOBILE, '-', '')))   ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.USE_YN       = 'Y'           ]'
            ||CHR(13)||CHR(10)||Q'[    AND  ST.TR_SENDSTAT(+) <> '0'        ]'
            ||CHR(13)||CHR(10)||Q'[    AND  MM.STATUS(+)    <> '0'          ]'
            ||CHR(13)||CHR(10)||Q'[  ORDER  BY CS.SEND_DT, CS.SEND_SEQ      ]';
            
            ls_sql := ls_sql || ls_sql_main;
            dbms_output.put_line(ls_sql);
        
            OPEN PR_RESULT FOR
                ls_sql USING PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_MEMBER_TXT, PSV_MEMBER_TXT, PSV_MEMBER_TXT, PSV_MOBILE, PSV_MOBILE;
            
        ELSIF (ls_sql_sms IS NOT NULL OR ls_sql_sms <> '') AND (ls_sql_mms IS NULL OR ls_sql_mms = '') THEN
            
            ls_sql_main := ''
            ||CHR(13)||CHR(10)||Q'[ SELECT  CS.COMP_CD      ]'
            ||CHR(13)||CHR(10)||Q'[      ,  TO_CHAR(TO_DATE(CS.SEND_DT, 'YYYYMMDDHH24MISS'), 'YYYY-MM-DD HH24:MI:SS')   AS SEND_DT_D  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  CS.SEND_DT      ]'
            ||CHR(13)||CHR(10)||Q'[      ,  CS.SEND_SEQ     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  CS.SUBJECT      ]'
            ||CHR(13)||CHR(10)||Q'[      ,  CS.CONTENT      ]'
            ||CHR(13)||CHR(10)||Q'[      ,  CS.MEMBER_NO    ]'
            ||CHR(13)||CHR(10)||Q'[      ,  DECRYPT(M.MEMBER_NM)    AS MEMBER_NM                ]'
            ||CHR(13)||CHR(10)||Q'[      ,  FN_GET_FORMAT_HP_NO(DECRYPT(CS.MOBILE)) AS MOBILE   ]'
            ||CHR(13)||CHR(10)||Q'[      ,  CS.SEND_DIV     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  TO_CHAR(TO_DATE(CS.RESV_DT, 'YYYYMMDDHH24MI'), 'YYYY-MM-DD HH24:MI')    AS RESV_DT  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  CS.SEND_MOBILE  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  CS.MSGKEY       ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SL.RSLTSTAT     AS RSLTSTAT ]'
            ||CHR(13)||CHR(10)||Q'[      ,  GET_COMMON_CODE_NM(:PSV_COMP_CD, '01920', SL.RSLTSTAT, :PSV_LANG_CD)    AS RSLTMSG  ]'
            ||CHR(13)||CHR(10)||Q'[   FROM  CS_CONTENT_SEND     CS  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  CS_MEMBER           M   ]'
            ||CHR(13)||CHR(10)||Q'[      ,  S_STORE             S   ]'
            ||CHR(13)||CHR(10)||Q'[      ,  (                       ]'
            ||CHR(13)||CHR(10)||Q'[             ]' || ls_sql_sms
            ||CHR(13)||CHR(10)||Q'[         )   SL                  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SC_TRAN             ST  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  MMS_MSG             MM  ]'
            ||CHR(13)||CHR(10)||Q'[  WHERE  CS.COMP_CD      = M.COMP_CD(+)  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.MEMBER_NO    = M.MEMBER_NO(+)]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.MSGKEY       = SL.MSGKEY(+)  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.MSGKEY       = ST.TR_NUM(+)  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.MSGKEY       = MM.MSGKEY(+)  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.COMP_CD      = S.COMP_CD     ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.BRAND_CD     = S.BRAND_CD    ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.STOR_CD      = S.STOR_CD     ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.COMP_CD      = :PSV_COMP_CD  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  SUBSTR(CS.SEND_DT, 1, 8) BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
            ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_MEMBER_TXT IS NULL OR (CS.MEMBER_NO LIKE '%'||:PSV_MEMBER_TXT||'%' OR DECRYPT(M.MEMBER_NM) LIKE '%'||:PSV_MEMBER_TXT||'%'))   ]'
            ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_MOBILE IS NULL OR CS.MOBILE = ENCRYPT(REPLACE(:PSV_MOBILE, '-', '')))   ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.USE_YN       = 'Y'           ]'
            ||CHR(13)||CHR(10)||Q'[    AND  ST.TR_SENDSTAT(+) <> '0'        ]'
            ||CHR(13)||CHR(10)||Q'[    AND  MM.STATUS(+)    <> '0'          ]'
            ||CHR(13)||CHR(10)||Q'[  ORDER  BY CS.SEND_DT, CS.SEND_SEQ      ]';
            
            ls_sql := ls_sql || ls_sql_main;
            dbms_output.put_line(ls_sql);
        
            OPEN PR_RESULT FOR
                ls_sql USING PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_MEMBER_TXT, PSV_MEMBER_TXT, PSV_MEMBER_TXT, PSV_MOBILE, PSV_MOBILE;
                
        ELSIF (ls_sql_sms IS NULL OR ls_sql_sms = '') AND (ls_sql_mms IS NOT NULL OR ls_sql_mms <> '') THEN
            
            ls_sql_main := ''
            ||CHR(13)||CHR(10)||Q'[ SELECT  CS.COMP_CD      ]'
            ||CHR(13)||CHR(10)||Q'[      ,  TO_CHAR(TO_DATE(CS.SEND_DT, 'YYYYMMDDHH24MISS'), 'YYYY-MM-DD HH24:MI:SS')   AS SEND_DT_D  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  CS.SEND_DT      ]'
            ||CHR(13)||CHR(10)||Q'[      ,  CS.SEND_SEQ     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  CS.SUBJECT      ]'
            ||CHR(13)||CHR(10)||Q'[      ,  CS.CONTENT      ]'
            ||CHR(13)||CHR(10)||Q'[      ,  CS.MEMBER_NO    ]'
            ||CHR(13)||CHR(10)||Q'[      ,  DECRYPT(M.MEMBER_NM)    AS MEMBER_NM                ]'
            ||CHR(13)||CHR(10)||Q'[      ,  FN_GET_FORMAT_HP_NO(DECRYPT(CS.MOBILE)) AS MOBILE   ]'
            ||CHR(13)||CHR(10)||Q'[      ,  CS.SEND_DIV     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  TO_CHAR(TO_DATE(CS.RESV_DT, 'YYYYMMDDHH24MI'), 'YYYY-MM-DD HH24:MI')    AS RESV_DT  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  CS.SEND_MOBILE  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  CS.MSGKEY       ]'
            ||CHR(13)||CHR(10)||Q'[      ,  ML.RSLTSTAT     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  GET_COMMON_CODE_NM(:PSV_COMP_CD, '01925', ML.RSLTSTAT, :PSV_LANG_CD)    AS RSLTMSG  ]'
            ||CHR(13)||CHR(10)||Q'[   FROM  CS_CONTENT_SEND     CS  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  CS_MEMBER           M   ]'
            ||CHR(13)||CHR(10)||Q'[      ,  S_STORE             S   ]'
            ||CHR(13)||CHR(10)||Q'[      ,  (                       ]'
            ||CHR(13)||CHR(10)||Q'[             ]' || ls_sql_mms
            ||CHR(13)||CHR(10)||Q'[         )   ML                  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SC_TRAN             ST  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  MMS_MSG             MM  ]'
            ||CHR(13)||CHR(10)||Q'[  WHERE  CS.COMP_CD      = M.COMP_CD(+)  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.MEMBER_NO    = M.MEMBER_NO(+)]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.MSGKEY       = ML.MSGKEY(+)  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.MSGKEY       = ST.TR_NUM(+)  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.MSGKEY       = MM.MSGKEY(+)  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.COMP_CD      = S.COMP_CD     ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.BRAND_CD     = S.BRAND_CD    ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.STOR_CD      = S.STOR_CD     ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.COMP_CD      = :PSV_COMP_CD  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  SUBSTR(CS.SEND_DT, 1, 8) BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
            ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_MEMBER_TXT IS NULL OR (CS.MEMBER_NO LIKE '%'||:PSV_MEMBER_TXT||'%' OR DECRYPT(M.MEMBER_NM) LIKE '%'||:PSV_MEMBER_TXT||'%'))   ]'
            ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_MOBILE IS NULL OR CS.MOBILE = ENCRYPT(REPLACE(:PSV_MOBILE, '-', '')))   ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.USE_YN       = 'Y'           ]'
            ||CHR(13)||CHR(10)||Q'[    AND  ST.TR_SENDSTAT(+) <> '0'        ]'
            ||CHR(13)||CHR(10)||Q'[    AND  MM.STATUS(+)    <> '0'          ]'
            ||CHR(13)||CHR(10)||Q'[  ORDER  BY CS.SEND_DT, CS.SEND_SEQ      ]';
            
            ls_sql := ls_sql || ls_sql_main;
            dbms_output.put_line(ls_sql);
        
            OPEN PR_RESULT FOR
                ls_sql USING PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_MEMBER_TXT, PSV_MEMBER_TXT, PSV_MEMBER_TXT, PSV_MOBILE, PSV_MOBILE;
                
        ELSIF (ls_sql_sms IS NULL OR ls_sql_sms = '') AND (ls_sql_mms IS NULL OR ls_sql_mms = '') THEN
            
            ls_sql_main := ''
            ||CHR(13)||CHR(10)||Q'[ SELECT  CS.COMP_CD      ]'
            ||CHR(13)||CHR(10)||Q'[      ,  TO_CHAR(TO_DATE(CS.SEND_DT, 'YYYYMMDDHH24MISS'), 'YYYY-MM-DD HH24:MI:SS')   AS SEND_DT_D  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  CS.SEND_DT      ]'
            ||CHR(13)||CHR(10)||Q'[      ,  CS.SEND_SEQ     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  CS.SUBJECT      ]'
            ||CHR(13)||CHR(10)||Q'[      ,  CS.CONTENT      ]'
            ||CHR(13)||CHR(10)||Q'[      ,  CS.MEMBER_NO    ]'
            ||CHR(13)||CHR(10)||Q'[      ,  DECRYPT(M.MEMBER_NM)    AS MEMBER_NM                ]'
            ||CHR(13)||CHR(10)||Q'[      ,  FN_GET_FORMAT_HP_NO(DECRYPT(CS.MOBILE)) AS MOBILE   ]'
            ||CHR(13)||CHR(10)||Q'[      ,  CS.SEND_DIV     ]'
            ||CHR(13)||CHR(10)||Q'[      ,  TO_CHAR(TO_DATE(CS.RESV_DT, 'YYYYMMDDHH24MI'), 'YYYY-MM-DD HH24:MI')    AS RESV_DT  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  CS.SEND_MOBILE  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  CS.MSGKEY       ]'
            ||CHR(13)||CHR(10)||Q'[      ,  ''  AS RSLTSTAT ]'
            ||CHR(13)||CHR(10)||Q'[      ,  ''  AS RSLTMSG  ]'
            ||CHR(13)||CHR(10)||Q'[   FROM  CS_CONTENT_SEND     CS  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  CS_MEMBER           M   ]'
            ||CHR(13)||CHR(10)||Q'[      ,  S_STORE             S   ]'
            ||CHR(13)||CHR(10)||Q'[      ,  SC_TRAN             ST  ]'
            ||CHR(13)||CHR(10)||Q'[      ,  MMS_MSG             MM  ]'
            ||CHR(13)||CHR(10)||Q'[  WHERE  CS.COMP_CD      = M.COMP_CD(+)  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.MEMBER_NO    = M.MEMBER_NO(+)]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.MSGKEY       = ST.TR_NUM(+)  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.MSGKEY       = MM.MSGKEY(+)  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.COMP_CD      = S.COMP_CD     ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.BRAND_CD     = S.BRAND_CD    ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.STOR_CD      = S.STOR_CD     ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.COMP_CD      = :PSV_COMP_CD  ]'
            ||CHR(13)||CHR(10)||Q'[    AND  SUBSTR(CS.SEND_DT, 1, 8) BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
            ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_MEMBER_TXT IS NULL OR (CS.MEMBER_NO LIKE '%'||:PSV_MEMBER_TXT||'%' OR DECRYPT(M.MEMBER_NM) LIKE '%'||:PSV_MEMBER_TXT||'%'))   ]'
            ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_MOBILE IS NULL OR CS.MOBILE = ENCRYPT(REPLACE(:PSV_MOBILE, '-', '')))   ]'
            ||CHR(13)||CHR(10)||Q'[    AND  CS.USE_YN       = 'Y'           ]'
            ||CHR(13)||CHR(10)||Q'[    AND  ST.TR_SENDSTAT(+) <> '0'        ]'
            ||CHR(13)||CHR(10)||Q'[    AND  MM.STATUS(+)    <> '0'          ]'
            ||CHR(13)||CHR(10)||Q'[  ORDER  BY CS.SEND_DT, CS.SEND_SEQ      ]';
            
            ls_sql := ls_sql || ls_sql_main;
            dbms_output.put_line(ls_sql);
        
            OPEN PR_RESULT FOR
                ls_sql USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_MEMBER_TXT, PSV_MEMBER_TXT, PSV_MEMBER_TXT, PSV_MOBILE, PSV_MOBILE;
                
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
    
END PKG_GCRM1030;

/
