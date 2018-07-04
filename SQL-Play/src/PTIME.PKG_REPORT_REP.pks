CREATE OR REPLACE PACKAGE       PKG_REPORT_REP AS
/******************************************************************************
   NAME:       PKG_CURSOR
   PURPOSE: ��Ű�� ����Ʈ ��ǥ��ǰ ����
   
   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2010-01-20             1. Created this package.
******************************************************************************/
  TYPE      REF_CUR IS  REF CURSOR;
  
  TYPE      ARR_DYN     IS VARRAY(6) OF VARCHAR2(10);
  TYPE      TAB_STR     IS TABLE OF VARCHAR2(10000) INDEX BY PLS_INTEGER;
  TYPE      REC_PARA    IS RECORD
            (   TABLE_CD          VARCHAR2(20),
                SEL_TP            VARCHAR2(1),
                COL_CD            VARCHAR2(2),
                WHERE_OP          VARCHAR2(1),
                FR_DATA           VARCHAR2(20000),
                TO_DATA           VARCHAR2(100),
                DTL_CD            VARCHAR2(10000)
            );
            
  TYPE      TAB_PARA  IS TABLE OF REC_PARA INDEX BY PLS_INTEGER;
  
  TYPE      REC_CHEADER IS RECORD
            (   C01               VARCHAR2(50),
                C02               VARCHAR2(50),
                C03               VARCHAR2(50),
                C04               VARCHAR2(50),
                C05               VARCHAR2(50),
                C06               VARCHAR2(50),
                C07               VARCHAR2(50),
                C08               VARCHAR2(50),
                C20               VARCHAR2(50),
                C21               VARCHAR2(50),
                C22               VARCHAR2(50),
                C23               VARCHAR2(50),
                C50               VARCHAR2(50),
                C51               VARCHAR2(50),
                C52               VARCHAR2(50)
            );
            
  TYPE      REC_VHEADER IS RECORD
            (   V01               VARCHAR2(50),
                V02               VARCHAR2(50),
                V03               VARCHAR2(50),
                V04               VARCHAR2(50),
                V05               VARCHAR2(50),
                V06               VARCHAR2(50),
                V07               VARCHAR2(50),
                V08               VARCHAR2(50),
                V09               VARCHAR2(50),
                V10               VARCHAR2(50),
                V11               VARCHAR2(50),
                V12               VARCHAR2(50)
            );
            
  TYPE      REC_CT_HD IS RECORD
            (   COL_CD1           VARCHAR2(100),
                COL_NM1           VARCHAR2(100),
                COL_CD2           VARCHAR2(100),
                COL_NM2           VARCHAR2(100)
            );
            
  TYPE      TBL_CT_HD IS TABLE OF REC_CT_HD INDEX BY PLS_INTEGER;
  
  C_FDM     CONSTANT VARCHAR2(3) := '��';
  C_RDM     CONSTANT VARCHAR2(2) := '#!';
  C_COMMA   CONSTANT VARCHAR2(2) := ',';
  C_N_FDM   CONSTANT NUMBER(1)   := LENGTHB(C_FDM);
  C_N_RDM   CONSTANT NUMBER(1)   := LENGTHB(C_RDM);
  
  P_EMP_FLAG         VARCHAR2(1) := 'H'; -- [H:����, S:����]
  P_DATE_LMT         NUMBER;
  
  FUNCTION F_PARA_PARSING
    ( PSV_PARA       IN  VARCHAR2
    ) RETURN TBL_PARA ;
    
  FUNCTION F_WHERE_OP
    ( PSV_OT_PARA    IN  OT_PARA
    ) RETURN VARCHAR2 ;
    
  FUNCTION F_COLUMN
    ( PSV_TABLE      IN VARCHAR2,
      PSV_COL_CD     IN VARCHAR2
    ) RETURN VARCHAR2;
    
  FUNCTION F_AUTH
    ( PSV_USER       IN  VARCHAR2
    ) RETURN VARCHAR2;
    
  FUNCTION F_REF_COMMON -- ASP
    ( PSV_COMP       IN  VARCHAR2
     ,PSV_LANG_CD    IN  VARCHAR2
     ,PSV_COMMON_TP  IN  VARCHAR2
    ) RETURN VARCHAR2;
    
  FUNCTION F_OLAP_HD
    ( PSV_COMP       IN  VARCHAR2
     ,PSV_LANG_CD    IN  VARCHAR2
    ) RETURN VARCHAR2 ;
    
  PROCEDURE RPT_PARA
    (PSV_COMP        IN  VARCHAR2 -- ASP
    ,PSV_USER        IN  VARCHAR2
    ,PSV_PGM_ID      IN  VARCHAR2
    ,PSV_LANG_CD     IN  VARCHAR2
    ,PSV_ORG_CLASS   IN  VARCHAR2
    ,PSV_PARA        IN  VARCHAR2
    ,PSV_FILTER      IN  VARCHAR2
    ,PSR_STORE       OUT VARCHAR2
    ,PSR_ITEM        OUT VARCHAR2
    ,PSR_DATE1       OUT VARCHAR2
    ,PSR_EX_DATE1    OUT VARCHAR2
    ,PSR_DATE2       OUT VARCHAR2
    ,PSR_EX_DATE2    OUT VARCHAR2
    );
    
  PROCEDURE RPT_OLAP
    (PSV_COMP        IN  VARCHAR2 -- ASP
    ,PSV_USER        IN  VARCHAR2
    ,PSV_PGM_ID      IN  VARCHAR2
    ,PSV_LANG_CD     IN  VARCHAR2
    ,PSV_ORG_CLASS   IN  VARCHAR2
    ,PSV_DYN         IN  VARCHAR2
    ,PSV_PARA        IN  VARCHAR2
    ,PSV_FILTER      IN  VARCHAR2
    ,PR_HEADER       IN OUT REF_CUR
    ,PR_RESULT       IN OUT REF_CUR
    ,PR_RTN_CD       OUT VARCHAR2
    ,PR_RTN_MSG      OUT VARCHAR2
    );
    
  PROCEDURE SP_DUMMY ;
  
END ;

/

CREATE OR REPLACE PACKAGE BODY       PKG_REPORT_REP AS
    PROCEDURE SP_DYN_PARSING
    ( PSV_DYN        IN  VARCHAR2,
      PSR_DYN_I      OUT TBL_DYN,
      PSR_DYN_C      OUT TBL_DYN,
      PSR_DYN_V      OUT TBL_DYN,
      PSR_DYN_S      OUT TBL_DYN
    ) IS
      li_pos         PLS_INTEGER;
      li_pre         PLS_INTEGER;
      li_next        PLS_INTEGER;
      li_array       PLS_INTEGER;

      ls_dyn         VARCHAR2(32767) ;
      ls_msg         VARCHAR2(10000) ;
      lrc_dyn        ARR_DYN := ARR_DYN('','','','','','') ;
      ltr_dyn_i      TBL_DYN := TBL_DYN() ;
      ltr_dyn_c      TBL_DYN := TBL_DYN() ;
      ltr_dyn_v      TBL_DYN := TBL_DYN() ;
      ltr_dyn_s      TBL_DYN := TBL_DYN() ;

   BEGIN
      ls_dyn  := TRIM(psv_dyn);

      LOOP
         li_pos := INSTRB(ls_dyn, C_RDM);
         EXIT WHEN li_pos IS NULL OR  li_pos < 1;

         li_pre := 1 ;
         FOR i IN 1..6
         LOOP
            li_next :=  INSTRB(ls_dyn, C_FDM, li_pre );
            lrc_dyn(i)  := SUBSTRB(ls_dyn, li_pre , li_next - li_pre ) ;
            li_pre  := li_next + C_N_FDM ;
         END LOOP;

         CASE   lrc_dyn(1)
            WHEN 'I' THEN
                ltr_dyn_i.EXTEND;
                li_array := ltr_dyn_i.LAST;
                ltr_dyn_i(li_array) := OT_DYN(lrc_dyn(2),lrc_dyn(3),lrc_dyn(4),lrc_dyn(5),lrc_dyn(6));
            WHEN 'C' THEN
                ltr_dyn_c.EXTEND;
                li_array := ltr_dyn_c.LAST;
                ltr_dyn_c(li_array) := OT_DYN(lrc_dyn(2),lrc_dyn(3),lrc_dyn(4),lrc_dyn(5),lrc_dyn(6));
            WHEN 'V' THEN
                ltr_dyn_v.EXTEND;
                li_array := ltr_dyn_v.LAST;
                ltr_dyn_v(li_array) := OT_DYN(lrc_dyn(2),lrc_dyn(3),lrc_dyn(4),lrc_dyn(5),lrc_dyn(6));
            WHEN 'S' THEN
                ltr_dyn_s.EXTEND;
                li_array := ltr_dyn_s.LAST;
                ltr_dyn_s(li_array) := OT_DYN(lrc_dyn(2),lrc_dyn(3),lrc_dyn(4),lrc_dyn(5),lrc_dyn(6));
          END CASE;

          ls_dyn := substrb( ls_dyn , li_pos + C_N_RDM);
      END LOOP;

      PSR_DYN_I := ltr_dyn_i;
      PSR_DYN_V := ltr_dyn_v;
      PSR_DYN_C := ltr_dyn_c;
      PSR_DYN_S := ltr_dyn_s;

   EXCEPTION
       WHEN OTHERS THEN
        ls_msg       := SQLERRM;
        RAISE;
   END;

    FUNCTION F_PARA_PARSING
    ( PSV_PARA        IN  VARCHAR2
    ) RETURN TBL_PARA IS
      li_pos        PLS_INTEGER;
      li_pre        PLS_INTEGER;
      li_next       PLS_INTEGER;
      li_idx        PLS_INTEGER := 0 ;
      li_same       PLS_INTEGER;
      li_mpre       PLS_INTEGER;
      li_mnext      PLS_INTEGER;
      li_split      PLS_INTEGER;
      li_array      PLS_INTEGER;

      ls_para       VARCHAR2(32767) ;
      ls_mcode      VARCHAR2(10000) ;
      ls_mdata      VARCHAR2(10000) ;
      ls_mpre       VARCHAR2(5000) ;
      ls_mnext      VARCHAR2(5000) ;

      ls_table_cd          VARCHAR2(20) ;
      ls_sel_tp            VARCHAR2(1) ;
      ls_col_cd            VARCHAR2(2) ;
      ls_where_op          VARCHAR2(1) ;
      ls_fr_data           VARCHAR2(20000) ;
      ls_to_data           VARCHAR2(100) ;
      ls_dtl_cd            VARCHAR2(10000) ;

      lrc_para      OT_PARA ;
      ltr_para      TBL_PARA := TBL_PARA() ;
   BEGIN
      ls_para  := TRIM(psv_para);

       LOOP
         li_pre := 1;
         li_pos := INSTRB(ls_para, C_RDM  );
         EXIT WHEN li_pos IS NULL OR  li_pos < 1;
         li_next :=  INSTRB(ls_para, C_FDM, li_pre );
         ls_TABLE_CD  := substrb(ls_para,li_pre , li_next - li_pre);
         li_pre := li_next + 3;
         li_next :=  INSTRB(ls_para, C_FDM, li_pre );
         ls_SEL_TP  := substrb(ls_para,li_pre , li_next - li_pre);
         li_pre := li_next + 3;
         li_next :=  INSTRB(ls_para, C_FDM, li_pre );
         ls_COL_CD  := substrb(ls_para,li_pre , li_next - li_pre);
         li_pre := li_next + 3;
         li_next :=  INSTRB(ls_para, C_FDM, li_pre );
         ls_WHERE_OP  := substrb(ls_para,li_pre , li_next - li_pre);
         li_pre := li_next + 3;
         li_next :=  INSTRB(ls_para, C_FDM, li_pre );
         ls_FR_DATA  := substrb(ls_para,li_pre , li_next - li_pre);
         li_pre := li_next + 3;
         li_next :=  INSTRB(ls_para, C_FDM, li_pre );
         ls_TO_DATA  := substrb(ls_para,li_pre , li_next - li_pre);
         li_pre := li_next + 3;
         li_next :=  INSTRB(ls_para, C_FDM, li_pre );
         ls_DTL_CD  := substrb(ls_para,li_pre , li_next - li_pre);

         ltr_para.EXTEND;
         li_array := ltr_para.LAST;
         ltr_para(li_array) := OT_PARA ( ls_table_cd, ls_sel_tp, ls_col_cd, ls_where_op , ls_fr_data, ls_to_data , ls_dtl_cd) ;

         -- STORE_FLAG, ITEM_FLAG Multi Row ó��
         IF ltr_para(li_array).TABLE_CD IN ( 'STORE_FLAG' , 'ITEM_FLAG')  THEN
            ls_mcode   := ltr_para(li_array).DTL_CD  ;
            ls_mdata   := ltr_para(li_array).FR_DATA ;
            li_mpre  := 1;
            li_mnext := 1;
            li_split := 0;
            li_idx   := 1;
            li_mpre  := INSTRB( ls_mcode , C_COMMA  ) ;

            IF li_mpre > 0 THEN
                ls_mpre := SUBSTRB ( ls_mcode , 1, li_mpre -1 ) ;
                LOOP
                  li_idx    := li_idx +  1 ;
                  li_mnext := INSTRB( ls_mcode , C_COMMA, 1, li_idx ) ;

                  IF li_mnext = 0 THEN
                     ls_mnext := SUBSTRB( ls_mcode , li_mpre  + 1 ) ;
                  ELSE
                     ls_mnext := SUBSTRB( ls_mcode ,  li_mpre  + 1 , li_mnext - li_mpre - 1 );
                  END IF;

                  IF ls_mpre <> ls_mnext THEN
                    ls_mcode := SUBSTRB(ls_mcode, li_mpre + 1);
                    li_split := li_split + 1;
                    ls_table_cd := ltr_para(li_array).TABLE_CD;
                    ls_sel_tp   := ltr_para(li_array).SEL_TP  ;
                    ls_col_cd   := ltr_para(li_array).COL_CD  ;
                    ls_where_op := ltr_para(li_array).WHERE_OP  ;
                    ls_to_data  := ltr_para(li_array).TO_DATA  ;

                    IF li_split > 1 THEN
                       ltr_para.EXTEND;
                       li_array := ltr_para.LAST ;
                       -- ltr_para(li_array) := ltr_para(li_array - 1) ;
                    END IF;
                   li_mpre := INSTRB( ls_mdata , C_COMMA , 1, li_idx - 1) ;
                   ls_dtl_cd  := ls_mpre  ;
                   ls_fr_data := SUBSTRB(ls_mdata,1, li_mpre - 1) ;

                   ltr_para(li_array) := OT_PARA ( ls_table_cd, ls_sel_tp, ls_col_cd, ls_where_op , ls_fr_data, ls_to_data , ls_dtl_cd );

                   ls_mdata := SUBSTRB(ls_mdata, li_mpre + 1);
                   li_idx := 1;
                  END IF;

                  IF li_mnext = 0 THEN
                    IF li_split > 1 THEN
                        ltr_para.EXTEND;
                        li_array := ltr_para.LAST ;
                        -- ltr_para(li_array) := ltr_para(li_array - 1) ;
                        ls_dtl_cd  := ls_mpre ;
                        ls_fr_data := SUBSTRB(ls_mdata, li_mpre - 1) ;
                        ltr_para(li_array) := OT_PARA ( ls_table_cd, ls_sel_tp, ls_col_cd, ls_where_op , ls_fr_data, ls_to_data , ls_dtl_cd );
                    END IF;
                    EXIT WHEN TRUE;
                  END IF;

                  ls_mpre := ls_mnext;
                  li_mpre := li_mnext;

                END LOOP ;
            END IF;

         END IF ; -- STORE_FLAG, ITEM_FLAG Multi Row ó��
         ls_para := substrb( ls_para , li_pos + 2) ;
       END LOOP;

       RETURN ltr_para;
   EXCEPTION
       WHEN OTHERS THEN
            RETURN NULL;
   END;

   FUNCTION F_WHERE_OP
    ( PSV_OT_PARA   IN  OT_PARA
    ) RETURN VARCHAR2 IS
      li_cnt        PLS_INTEGER := 0 ;
      li_pre        PLS_INTEGER := 0 ;
      li_next       PLS_INTEGER := 0 ;

      ls_data       VARCHAR2(20000) ;
      ls_where      VARCHAR2(20000) ;
      ls_fr_date    VARCHAR2(8) ;
      ls_to_date    VARCHAR2(8) ;
      ls_fr_data    VARCHAR2(20000) ;
      ls_to_data    VARCHAR2(100) ;
      ls_date       VARCHAR2(8) := '' ;
      ls_rdate      VARCHAR2(20000) := '' ;
      li_dcnt       PLS_INTEGER;
   BEGIN
      IF PSV_OT_PARA.COL_CD IN('50', '60')   THEN -- STORE_FLAG
         IF PSV_OT_PARA.COL_CD = '50' THEN
              ls_where := ' IN ( SELECT BRAND_CD , STOR_CD FROM STORE_FLAG '
                       || ' WHERE  STOR_FG = '''
                       || PSV_OT_PARA.DTL_CD
                       || ''' AND STOR_DT_CD IN (';
           ELSE
              ls_where := ' IN ( SELECT ITEM_CD FROM ITEM_FLAG '
                       || ' WHERE  ITEM_FG = '''
                       || PSV_OT_PARA.DTL_CD
                       || ''' AND ITEM_DT_CD IN (';
          END IF;

          ls_data := '''' || REPLACE (PSV_OT_PARA.FR_DATA,C_COMMA, ''',''' ) || '''';

          ls_where := ls_where || ls_data || ' ) ) ';
      ELSE
          ls_fr_data := PSV_OT_PARA.FR_DATA;
          ls_to_data := PSV_OT_PARA.TO_DATA;
          IF PSV_OT_PARA.TABLE_CD = 'DATE' THEN
             ls_fr_date := TO_CHAR(ADD_MONTHS(SYSDATE, -(P_DATE_LMT - 1)), 'YYYYMM') || '01';
             ls_to_date := '99991231';
          END IF;
           CASE PSV_OT_PARA.WHERE_OP
                WHEN 'M' THEN
                    IF PSV_OT_PARA.TABLE_CD = 'DATE' THEN
                       IF P_DATE_LMT > 0 THEN
                          li_dcnt := LENGTH(REPLACE(PSV_OT_PARA.FR_DATA, ',', '')) / 8;
                          FOR i IN 1.. li_dcnt LOOP
                            ls_date := SUBSTR(REPLACE(PSV_OT_PARA.FR_DATA, ',', ''), 8 * (i - 1) + 1, 8);
                            IF ls_date BETWEEN ls_fr_date AND ls_to_date THEN
                               ls_rdate := ls_rdate || ',' || ls_date;
                            ELSE
                               ls_rdate := ls_rdate || ',' || '19000101';
                            END IF;
                          END LOOP;
                       END IF;
                       ls_fr_data := ls_rdate;
                    END IF;
                    IF PSV_OT_PARA.SEL_TP = 'E' THEN
                        ls_where := ' NOT IN ( ' ;
                    ELSE
                        ls_where := ' IN ( ' ;
                    END IF;

                    ls_data := '''' || REPLACE (ls_fr_data, C_COMMA, ''',''' ) || '''';

                    ls_where := ls_where || ls_data || ' ) ';
                WHEN 'B' THEN
                    IF PSV_OT_PARA.TABLE_CD = 'DATE' THEN
                       IF P_DATE_LMT > 0 THEN
                          IF PSV_OT_PARA.TO_DATA BETWEEN ls_fr_date AND ls_to_date THEN
                             ls_to_data := PSV_OT_PARA.TO_DATA;
                          ELSE
                             ls_to_data := '19000101';
                          END IF;
                          IF PSV_OT_PARA.FR_DATA BETWEEN ls_fr_date AND ls_to_date THEN
                             ls_fr_data := PSV_OT_PARA.FR_DATA;
                          ELSE
                             IF ls_to_data = '19000101' THEN
                                ls_fr_data := '19000101';
                             ELSE
                                ls_fr_data := ls_fr_date;
                             END IF;
                          END IF;
                       END IF;
                    END IF;
                    ls_where := ' BETWEEN '
                             || '''' ||  ls_fr_data || ''''
                             || ' AND '
                             || '''' ||  ls_to_data || ''' ' ;
                WHEN 'S' THEN
                    IF PSV_OT_PARA.TABLE_CD = 'DATE' THEN -- ���������� <> �� ���ٴ� ������ �ۼ�
                       IF P_DATE_LMT > 0 THEN
                          IF PSV_OT_PARA.FR_DATA BETWEEN ls_fr_date AND ls_to_date THEN
                             ls_fr_data := PSV_OT_PARA.FR_DATA;
                          ELSE
                             ls_fr_data := '19000101';
                          END IF;
                       END IF;
                    END IF;
                    IF PSV_OT_PARA.SEL_TP = 'E' THEN
                       ls_where := ' <> ';
                    ELSE
                       ls_where := ' = ' ;
                    END IF;
                    ls_where := ls_where  || '''' ||  ls_fr_data || ''' ' ;
           END CASE;
      END IF;

      RETURN ls_where;
   END;

   FUNCTION F_OLAP_HD
    ( PSV_COMP      IN  VARCHAR2
     ,PSV_LANG_CD   IN  VARCHAR2
    ) RETURN VARCHAR2 IS
      ls_rtn       VARCHAR2(10000) ;
   BEGIN
         ls_rtn := ' WITH S_HD AS ( ';
         ls_rtn := ls_rtn
                || ' SELECT C01 || C.CODE CC01 , C02 || C.CODE CC02, C03 || C.CODE CC03, C04 || C.CODE CC04, '
                || '        C05 || C.CODE CC05 , C06 || C.CODE CC06, C07 || C.CODE CC07, C08 || C.CODE CC08, '
                || '        C20 || C.CODE CC20 , C21 || C.CODE CC21, C22 || C.CODE CC22, C23 || C.CODE CC23, '
                || '        C50  CC50 , C51  CC51, C52  CC52, '
                || '        C01 || C.NAME CN01 , C02 || C.NAME CN02, C03 || C.NAME CN03, C04 || C.NAME CN04, '
                || '        C05 || C.NAME CN05 , C06 || C.NAME CN06, C07 || C.NAME CN07, C08 || C.NAME CN08, '
                || '        C20 || C.NAME CN20 , C21 || C.NAME CN21, C22 || C.NAME CN22, C23 || C.NAME CN23, '
                || '        C50  CN50 , C51  CN51, C52  CN52, '
                || '        V01, V02, V03, V04, V05, V06, V07, V08,'
                || '        V09, V10, V11, V12 , '
                || q'[      V01 || ']'||CHR(13)||CHR(10)||q'[(' || C.S_AVR || ')' S01 , V02 || ']'||CHR(13)||CHR(10)||q'[(' || C.S_AVR || ')' S02 , V03 || ']'||CHR(13)||CHR(10)||q'[(' || C.S_AVR || ')' S03 , ]'
                || q'[      V04 || ']'||CHR(13)||CHR(10)||q'[(' || C.S_AVR || ')' S04 , V05 || ']'||CHR(13)||CHR(10)||q'[(' || C.S_AVR || ')' S05 , V06 || ']'||CHR(13)||CHR(10)||q'[(' || C.S_AVR || ')' S06 , ]'
                || q'[      V07 || ']'||CHR(13)||CHR(10)||q'[(' || C.S_AVR || ')' S07 , V08 || ']'||CHR(13)||CHR(10)||q'[(' || C.S_AVR || ')' S08 , V09 || ']'||CHR(13)||CHR(10)||q'[(' || C.S_AVR || ')' S09 , ]'
                || q'[      V10 || ']'||CHR(13)||CHR(10)||q'[(' || C.S_AVR || ')' S10 , V11 || ']'||CHR(13)||CHR(10)||q'[(' || C.S_AVR || ')' S11 , V12 || ']'||CHR(13)||CHR(10)||q'[(' || C.S_AVR || ')' S12 , ]'
                || q'[      V01 || ']'||CHR(13)||CHR(10)||q'[(' || C.RATE1 || ')' R01 , V02 || ']'||CHR(13)||CHR(10)||q'[(' || C.RATE1 || ')' R02 , V03 || ']'||CHR(13)||CHR(10)||q'[(' || C.RATE1 || ')' R03 , ]'
                || q'[      V04 || ']'||CHR(13)||CHR(10)||q'[(' || C.RATE1 || ')' R04 , V05 || ']'||CHR(13)||CHR(10)||q'[(' || C.RATE1 || ')' R05 , V06 || ']'||CHR(13)||CHR(10)||q'[(' || C.RATE1 || ')' R06 , ]'
                || q'[      V07 || ']'||CHR(13)||CHR(10)||q'[(' || C.RATE1 || ')' R07 , V08 || ']'||CHR(13)||CHR(10)||q'[(' || C.RATE1 || ')' R08 , V09 || ']'||CHR(13)||CHR(10)||q'[(' || C.RATE1 || ')' R09 , ]'
                || q'[      V10 || ']'||CHR(13)||CHR(10)||q'[(' || C.RATE1 || ')' R10 , V11 || ']'||CHR(13)||CHR(10)||q'[(' || C.RATE1 || ')' R11 , V12 || ']'||CHR(13)||CHR(10)||q'[(' || C.RATE1 || ')' R12 , ]'
                || q'[      V01 || ']'||CHR(13)||CHR(10)||q'[(' || C.RATE2 || ')' E01 , V02 || ']'||CHR(13)||CHR(10)||q'[(' || C.RATE2 || ')' E02 , V03 || ']'||CHR(13)||CHR(10)||q'[(' || C.RATE2 || ')' E03 , ]'
                || q'[      V04 || ']'||CHR(13)||CHR(10)||q'[(' || C.RATE2 || ')' E04 , V05 || ']'||CHR(13)||CHR(10)||q'[(' || C.RATE2 || ')' E05 , V06 || ']'||CHR(13)||CHR(10)||q'[(' || C.RATE2 || ')' E06 , ]'
                || q'[      V07 || ']'||CHR(13)||CHR(10)||q'[(' || C.RATE2 || ')' E07 , V08 || ']'||CHR(13)||CHR(10)||q'[(' || C.RATE2 || ')' E08 , V09 || ']'||CHR(13)||CHR(10)||q'[(' || C.RATE2 || ')' E09 , ]'
                || q'[      V10 || ']'||CHR(13)||CHR(10)||q'[(' || C.RATE2 || ')' E10 , V11 || ']'||CHR(13)||CHR(10)||q'[(' || C.RATE2 || ')' E11 , V12 || ']'||CHR(13)||CHR(10)||q'[(' || C.RATE2 || ')' E12 , ]'
                || '        C.DATE1 DATE1, C.DATE2 DATE2  '
                || ' FROM '
                || q'[  ( SELECT MAX(CASE WHEN C.CODE_CD = '01' THEN NVL(L.CODE_NM,C.CODE_NM  ) ELSE '' END) C01 , ]'
                || q'[           MAX(CASE WHEN C.CODE_CD = '02' THEN NVL(L.CODE_NM,C.CODE_NM  ) ELSE '' END) C02 , ]'
                || q'[           MAX(CASE WHEN C.CODE_CD = '03' THEN NVL(L.CODE_NM,C.CODE_NM  ) ELSE '' END) C03 , ]'
                || q'[           MAX(CASE WHEN C.CODE_CD = '04' THEN NVL(L.CODE_NM,C.CODE_NM  ) ELSE '' END) C04 , ]'
                || q'[           MAX(CASE WHEN C.CODE_CD = '05' THEN NVL(L.CODE_NM,C.CODE_NM  ) ELSE '' END) C05 , ]'
                || q'[           MAX(CASE WHEN C.CODE_CD = '06' THEN NVL(L.CODE_NM,C.CODE_NM  ) ELSE '' END) C06 , ]'
                || q'[           MAX(CASE WHEN C.CODE_CD = '07' THEN NVL(L.CODE_NM,C.CODE_NM  ) ELSE '' END) C07 , ]'
                || q'[           MAX(CASE WHEN C.CODE_CD = '08' THEN NVL(L.CODE_NM,C.CODE_NM  ) ELSE '' END) C08 , ]'
                || q'[           MAX(CASE WHEN C.CODE_CD = '20' THEN NVL(L.CODE_NM,C.CODE_NM  ) ELSE '' END) C20 , ]'
                || q'[           MAX(CASE WHEN C.CODE_CD = '21' THEN NVL(L.CODE_NM,C.CODE_NM  ) ELSE '' END) C21 , ]'
                || q'[           MAX(CASE WHEN C.CODE_CD = '22' THEN NVL(L.CODE_NM,C.CODE_NM  ) ELSE '' END) C22 , ]'
                || q'[           MAX(CASE WHEN C.CODE_CD = '23' THEN NVL(L.CODE_NM,C.CODE_NM  ) ELSE '' END) C23 , ]'
                || q'[           MAX(CASE WHEN C.CODE_CD = '50' THEN NVL(L.CODE_NM,C.CODE_NM  ) ELSE '' END) C50 , ]'
                || q'[           MAX(CASE WHEN C.CODE_CD = '51' THEN NVL(L.CODE_NM,C.CODE_NM  ) ELSE '' END) C51 , ]'
                || q'[           MAX(CASE WHEN C.CODE_CD = '52' THEN NVL(L.CODE_NM,C.CODE_NM  ) ELSE '' END) C52   ]'
                || '     FROM COMMON C, LANG_COMMON L '
                || '     WHERE C.COMP_CD = L.COMP_CD(+) '
                || '       AND C.CODE_CD = L.CODE_CD(+) '
                || q'[     AND C.CODE_TP = '01290' ]'
                || '       AND C.CODE_TP = L.CODE_TP(+) '
                || '       AND L.LANGUAGE_TP(+) = ''' || PSV_LANG_CD || ''' '
                || '       AND C.COMP_CD = ''' || PSV_COMP || ''' '
                || '     ) A, '
                || q'[     ( SELECT MAX(CASE WHEN C.CODE_CD = '01' THEN NVL(L.CODE_NM,C.CODE_NM  ) ELSE '' END) V01 , ]'
                || q'[           MAX(CASE WHEN C.CODE_CD = '02' THEN NVL(L.CODE_NM,C.CODE_NM  ) ELSE '' END) V02 ,    ]'
                || q'[           MAX(CASE WHEN C.CODE_CD = '03' THEN NVL(L.CODE_NM,C.CODE_NM  ) ELSE '' END) V03 ,    ]'
                || q'[           MAX(CASE WHEN C.CODE_CD = '04' THEN NVL(L.CODE_NM,C.CODE_NM  ) ELSE '' END) V04 ,    ]'
                || q'[           MAX(CASE WHEN C.CODE_CD = '05' THEN NVL(L.CODE_NM,C.CODE_NM  ) ELSE '' END) V05 ,    ]'
                || q'[           MAX(CASE WHEN C.CODE_CD = '06' THEN NVL(L.CODE_NM,C.CODE_NM  ) ELSE '' END) V06 ,    ]'
                || q'[           MAX(CASE WHEN C.CODE_CD = '07' THEN NVL(L.CODE_NM,C.CODE_NM  ) ELSE '' END) V07 ,    ]'
                || q'[           MAX(CASE WHEN C.CODE_CD = '08' THEN NVL(L.CODE_NM,C.CODE_NM  ) ELSE '' END) V08 ,    ]'
                || q'[           MAX(CASE WHEN C.CODE_CD = '09' THEN NVL(L.CODE_NM,C.CODE_NM  ) ELSE '' END) V09 ,    ]'
                || q'[           MAX(CASE WHEN C.CODE_CD = '10' THEN NVL(L.CODE_NM,C.CODE_NM  ) ELSE '' END) V10 ,    ]'
                || q'[           MAX(CASE WHEN C.CODE_CD = '11' THEN NVL(L.CODE_NM,C.CODE_NM  ) ELSE '' END) V11 ,    ]'
                || q'[           MAX(CASE WHEN C.CODE_CD = '12' THEN NVL(L.CODE_NM,C.CODE_NM  ) ELSE '' END) V12      ]'
                || '     FROM COMMON C, LANG_COMMON L '
                || '     WHERE C.COMP_CD = L.COMP_CD(+) '
                || '       AND C.CODE_CD = L.CODE_CD(+) '
                || q'[     AND C.CODE_TP = '01295' ]'
                || '       AND C.CODE_TP = L.CODE_TP(+) '
                || '       AND L.LANGUAGE_TP(+) = ''' || PSV_LANG_CD || ''' '
                || '       AND C.COMP_CD = ''' || PSV_COMP || ''' '
                || ' ) B ,'
                || q'[    ( SELECT MAX(CASE WHEN C.CODE_CD = '01' THEN NVL(L.CODE_NM,C.CODE_NM  ) ELSE '' END) CODE ,  ]'
                || q'[             MAX(CASE WHEN C.CODE_CD = '02' THEN NVL(L.CODE_NM,C.CODE_NM  ) ELSE '' END) NAME ,  ]'
                || q'[             MAX(CASE WHEN C.CODE_CD = '03' THEN NVL(L.CODE_NM,C.CODE_NM  ) ELSE '' END) DATE1,  ]'
                || q'[             MAX(CASE WHEN C.CODE_CD = '04' THEN NVL(L.CODE_NM,C.CODE_NM  ) ELSE '' END) DATE2,  ]'
                || q'[             MAX(CASE WHEN C.CODE_CD = '05' THEN NVL(L.CODE_NM,C.CODE_NM  ) ELSE '' END) S_AVR,  ]'
                || q'[             MAX(CASE WHEN C.CODE_CD = '06' THEN NVL(L.CODE_NM,C.CODE_NM  ) ELSE '' END) RATE1,  ]'
                || q'[             MAX(CASE WHEN C.CODE_CD = '07' THEN NVL(L.CODE_NM,C.CODE_NM  ) ELSE '' END) RATE2   ]'
                || '     FROM COMMON C, LANG_COMMON L '
                || '     WHERE C.COMP_CD = L.COMP_CD(+) '
                || '       AND C.CODE_CD = L.CODE_CD(+) '
                || q'[     AND C.CODE_TP = '01355' ]'
                || '       AND C.CODE_TP = L.CODE_TP(+) '
                || '       AND L.LANGUAGE_TP(+) = ''' || PSV_LANG_CD || ''' '
                || '       AND C.COMP_CD = ''' || PSV_COMP || ''' '
                || ' ) C '
                || ' ) ' ;

      RETURN ls_rtn;
   END;

   PROCEDURE SP_OLAP_SELECT
    ( PSV_COL_CD    IN  VARCHAR2,
      PSV_MODE      IN  VARCHAR2,
      PSV_CT_YN     IN  VARCHAR2,
      PSR_SEL       OUT VARCHAR2,
      PSR_SEL2      OUT VARCHAR2,
      PSR_PV_SEL    OUT VARCHAR2,
      PSR_PV_REQ    OUT VARCHAR2
     )  IS
      ls_col_cd     VARCHAR2(50) ;
      ls_col_nm     VARCHAR2(50) ;
      ls_table      VARCHAR2(50) ;
      ls_rtn        VARCHAR2(200) ;
      ls_rtn2       VARCHAR2(200) ;
      ls_pv_sel     VARCHAR2(200) ;
      ls_pv_req     VARCHAR2(200) ;
   BEGIN
       CASE PSV_COL_CD
            WHEN '01' THEN
                ls_table  :=  'S' ;
                ls_col_cd :=  'BRAND_CD ';
                ls_col_nm :=  'BRAND_NM ';
                ls_pv_sel :=  'BRAND_CD ';
            WHEN '02' THEN
                ls_table  :=  'S' ;
                ls_col_cd :=  'DEPT_CD ';
                ls_col_nm :=  'DEPT_NM ';
                ls_pv_sel :=  'DEPT_CD ';
            WHEN '03' THEN
                ls_table  :=  'S' ;
                ls_col_cd :=  'TEAM_CD ';
                ls_col_nm :=  'TEAM_NM ';
                ls_pv_sel :=  'TEAM_CD ';
            WHEN '04' THEN
                ls_table  :=  'S' ;
                ls_col_cd :=  'SV_USER_ID ';
                ls_col_nm :=  'SV_USER_NM ';
                ls_pv_sel :=  'SV_USER_ID ';
            WHEN '05' THEN
                ls_table  :=  'S' ;
                ls_col_cd :=  'STOR_CD ';
                ls_col_nm :=  'STOR_NM ';
                ls_pv_sel :=  'STOR_CD ';
            WHEN '06' THEN
                ls_table  :=  'S' ;
                ls_col_cd :=  'SIDO_CD ';
                ls_col_nm :=  'SIDO_NM ';
                ls_pv_sel :=  'SIDO_CD ';
            WHEN '07' THEN
                ls_table  :=  'S' ;
                ls_col_cd :=  'REGION_CD ';
                ls_col_nm :=  'REGION_NM ';
                ls_pv_sel :=  'REGION_CD ';
            WHEN '08' THEN
                ls_table  :=  'S' ;
                ls_col_cd :=  'TRAD_AREA ';
                ls_col_nm :=  'TRAD_AREA_NM ';
                ls_pv_sel :=  'TRAD_AREA ';
            WHEN '20' THEN
                ls_table  :=  'I' ;
                ls_col_cd :=  'L_CLASS_CD ';
                ls_col_nm :=  'L_CLASS_NM ';
                ls_pv_sel :=  'L_CLASS_CD ';
            WHEN '21' THEN
                ls_table  :=  'I' ;
                ls_col_cd :=  'M_CLASS_CD ';
                ls_col_nm :=  'M_CLASS_NM ';
                ls_pv_sel :=  'M_CLASS_CD ';
            WHEN '22' THEN
                ls_table  :=  'I' ;
                ls_col_cd :=  'S_CLASS_CD ';
                ls_col_nm :=  'S_CLASS_NM ';
                ls_pv_sel :=  'S_CLASS_CD ';
            WHEN '23' THEN
                ls_table  :=  'I' ;
                ls_col_cd :=  'ITEM_CD ';
                ls_col_nm :=  'ITEM_NM ';
                ls_pv_sel :=  'ITEM_CD ';
            WHEN '50' THEN
                ls_table  :=  'A' ;
                ls_col_cd :=  'SALE_DT ';
                ls_col_nm :=  'SALE_DT ';
                ls_pv_sel :=  'SALE_DT ';
            WHEN '51' THEN
                ls_table  :=  'A' ;
                /*
                ls_col_cd :=  'SALE_YM ';
                ls_col_nm :=  'SALE_YM ';
                ls_pv_sel :=  'SALE_YM ';
                */
                ls_col_cd :=  'SUBSTR(A.SALE_DT, 1, 6) ';
                ls_col_nm :=  'SUBSTR(A.SALE_DT, 1, 6) ';
                ls_pv_sel :=  'SUBSTR(A.SALE_DT, 1, 6) ';
            WHEN '52' THEN
                ls_table  :=  'A' ;
                ls_col_cd :=  'SEC_DIV ';
                ls_col_nm :=  'SEC_DIV ';
                ls_pv_sel :=  'SEC_DIV ';
       END CASE;

       CASE WHEN PSV_MODE = 'C' OR PSV_CT_YN = 'Y'  THEN
                IF PSV_COL_CD = '51' THEN
                   ls_rtn  := ls_col_cd;
                   ls_rtn2 := ls_col_cd;
                ELSE
                   ls_rtn  := ls_table  || '.' || ls_col_cd;
                   ls_rtn2 := ls_col_cd;
                END IF;
            WHEN PSV_MODE = 'N' THEN
                IF PSV_COL_CD = '51' THEN
                   ls_rtn  := ls_col_cd;
                   ls_rtn2 := ls_col_cd;
                ELSE
                   ls_rtn  := ls_table  || '.' || ls_col_nm;
                   ls_rtn2 := ls_col_nm;
                END IF;
            WHEN PSV_MODE = 'A' THEN
                IF PSV_COL_CD = '51' THEN
                   ls_rtn  := ls_col_cd || ',' || ls_col_nm;
                   ls_rtn2 := ls_col_cd || ',' || ls_col_nm;
                ELSE
                   ls_rtn  := ls_table  || '.' || ls_col_cd || ',' || ls_table  || '.' || ls_col_nm;
                   ls_rtn2 := ls_col_cd || ',' || ls_col_nm;
                END IF;
       END CASE;

       PSR_SEL    := ls_rtn;
       PSR_SEL2   := ls_rtn2;
       PSR_PV_SEL := ls_pv_sel;
       IF PSV_COL_CD = '51' THEN
          PSR_PV_REQ := ls_col_cd || ',' || ls_col_nm;
       ELSE
          PSR_PV_REQ := ls_table  || '.' || ls_col_cd || ',' || ls_table  || '.' || ls_col_nm;
       END IF;
   END ;

   FUNCTION F_OLAP_COLUMN
    ( PSV_COL_CD    IN  VARCHAR2
    ) RETURN VARCHAR2 IS
      ls_col_cd     VARCHAR2(50) ;
      ls_rtn        VARCHAR2(200) ;
   BEGIN
       CASE PSV_COL_CD
            WHEN '01' THEN
                ls_col_cd :=  'BRAND_CD ';
            WHEN '02' THEN
                ls_col_cd :=  'DEPT_CD ' ;
            WHEN '03' THEN
                ls_col_cd :=  'TEAM_CD ';
            WHEN '04' THEN
                ls_col_cd :=  'SV_USER_ID ';
            WHEN '05' THEN
                ls_col_cd :=  'STOR_CD ';
            WHEN '06' THEN
                ls_col_cd :=  'SIDO_CD ';
            WHEN '07' THEN
                ls_col_cd :=  'REGION_CD ';
            WHEN '08' THEN
                ls_col_cd :=  'TRAD_AREA ';
            WHEN '20' THEN
                ls_col_cd :=  'L_CLASS_CD ';
            WHEN '21' THEN
                ls_col_cd :=  'M_CLASS_CD ';
            WHEN '22' THEN
                ls_col_cd :=  'S_CLASS_CD ';
            WHEN '23' THEN
                ls_col_cd :=  'S_CLASS_CD ';
            WHEN '24' THEN
                ls_col_cd :=  'ITEM_CD ';
            WHEN '25' THEN
                ls_col_cd :=  'ITEM_DIV ';
            WHEN '31' THEN
                ls_col_cd :=  'DSTN_COMP ';
            WHEN '50' THEN
                ls_col_cd :=  'SALE_DT ';
            WHEN '51' THEN
                ls_col_cd :=  'SALE_YM ';
            WHEN '52' THEN
                ls_col_cd :=  'SEC_DIV ';
       END CASE;

       ls_rtn := ls_col_cd;

       RETURN ls_rtn;
   END;

   PROCEDURE SP_GET_VALUE_02
    ( PSV_COL_CD1       IN  VARCHAR2,
      PSV_COL_CD2       IN  VARCHAR2,
      PSR_VAL_UP       OUT  VARCHAR2,
      PSR_VAL_GR_UP    OUT  VARCHAR2,
      PSR_VAL_UP2      OUT  VARCHAR2,
      PSR_VAL_GR_UP2   OUT  VARCHAR2
    ) IS
    BEGIN

       PSR_VAL_UP     := ' CASE WHEN NVL(STOR_ACNT, 0) = 0 THEN NULL ELSE ROUND('
                      || PSV_COL_CD1  || ' / STOR_ACNT) END ' ;
       PSR_VAL_GR_UP  := ' CASE WHEN NVL(SUM(STOR_ACNT), 0) = 0 THEN NULL ELSE ROUND(SUM('
                      || PSV_COL_CD1  || ') / SUM(STOR_ACNT)) END ' ;
       PSR_VAL_UP2    := ' CASE WHEN NVL(STOR_ACNT2, 0) = 0 THEN NULL ELSE ROUND('
                      || PSV_COL_CD1  || ' / STOR_ACNT2) END ' ;
       PSR_VAL_GR_UP2 := ' CASE WHEN NVL(SUM(STOR_ACNT2), 0) = 0 THEN NULL ELSE ROUND(SUM('
                      || PSV_COL_CD1  || ') / SUM(STOR_ACNT2)) END ' ;

    END ;

   PROCEDURE SP_GET_VALUE_03
    ( PSV_COL_CD1       IN  VARCHAR2,
      PSV_COL_CD2       IN  VARCHAR2,
      PSV_COL_CD3       IN  VARCHAR2,
      PSV_COL_CD4       IN  VARCHAR2,
      PSR_VAL_UP       OUT  VARCHAR2,
      PSR_VAL_GR_UP    OUT  VARCHAR2,
      PSR_VAL_UP2      OUT  VARCHAR2,
      PSR_VAL_GR_UP2   OUT  VARCHAR2
    ) IS
    BEGIN

       PSR_VAL_UP     := ' CASE WHEN NVL(SUM(' || PSV_COL_CD2  || ') OVER (), 0) = 0 THEN NULL ELSE ROUND( '
                      || PSV_COL_CD1  || ' / '  || 'SUM(' || PSV_COL_CD2  || ') OVER () * 100 ,2) END ';
       PSR_VAL_GR_UP  := ' CASE WHEN NVL(SUM(SUM(' || PSV_COL_CD2  || ')) OVER (), 0) = 0 THEN NULL ELSE ROUND( '
                      || 'SUM(' || PSV_COL_CD1  || ') / '  || 'SUM(SUM(' || PSV_COL_CD2  || ')) OVER () * 100 ,2) END ';
       PSR_VAL_UP2    := ' CASE WHEN NVL(SUM(' || PSV_COL_CD4  || ') OVER (), 0) = 0 THEN NULL ELSE ROUND( '
                      || PSV_COL_CD3  || ' / '  || 'SUM(' || PSV_COL_CD4  || ') OVER () * 100 ,2) END ';
       PSR_VAL_GR_UP2 := ' CASE WHEN NVL(SUM(SUM(' || PSV_COL_CD4  || ')) OVER (), 0) = 0 THEN NULL ELSE ROUND( '
                      || 'SUM(' || PSV_COL_CD3  || ') / '  || 'SUM(SUM(' || PSV_COL_CD4  || ')) OVER () * 100 ,2) END ';

    END ;

   PROCEDURE SP_GET_VALUE_04
    ( PSV_COL_CD1       IN  VARCHAR2,
      PSV_COL_CD2       IN  VARCHAR2,
      PSR_VAL_UP       OUT  VARCHAR2,
      PSR_VAL_UP2      OUT  VARCHAR2
    ) IS
    BEGIN
       PSR_VAL_UP    := ' CASE WHEN '
                     || PSV_COL_CD2  || ' = 0 OR '
                     || PSV_COL_CD2  || ' IS NULL THEN NULL ELSE ROUND( '
                     || '(' || PSV_COL_CD1 || '-' || PSV_COL_CD2 || ')' || ' / '
                     || PSV_COL_CD2  || ' * 100,2) END ' ;

       PSR_VAL_UP2   := ' CASE WHEN '
                     || 'SUM(' || PSV_COL_CD2  || ') = 0 OR '
                     || 'SUM(' || PSV_COL_CD2  || ') IS NULL THEN NULL ELSE ROUND( '
                     || '(SUM(' || PSV_COL_CD1 || ') - SUM(' || PSV_COL_CD2 || ')) / '
                     || 'SUM(' || PSV_COL_CD2  || ') * 100,2) END ' ;
   END ;

   PROCEDURE SP_OLAP_VALUE
    ( PSV_COL_CD       IN  VARCHAR2,
      PSV_VAL_TP       IN  VARCHAR2,
      PSV_MODE         IN  VARCHAR2,
      PSV_CT_TP        IN  VARCHAR2,
      PSV_PB           IN  VARCHAR2,
      PSR_VAL          OUT VARCHAR2,
      PSR_ALIAS        OUT VARCHAR2,
      PSR_CT_VAL       OUT VARCHAR2,
      PSR_VAL_UP       OUT VARCHAR2,
      PSR_VAL_UP2      OUT VARCHAR2,
      PSR_VAL_GR_UP    OUT VARCHAR2,
      PSR_VAL_GR_UP2   OUT VARCHAR2
    ) IS
      ls_col_cd      VARCHAR2(1000) ;
      ls_col1        VARCHAR2(1000) ;
      ls_col2        VARCHAR2(1000) ;
      ls_col3        VARCHAR2(1000) ;
      ls_col4        VARCHAR2(1000) ;
      ls_alias       VARCHAR2(1000) ;
      ls_ct_val      VARCHAR2(1000) ;
      ls_sum_ct_val  VARCHAR2(1000) ;
      ls_val_up      VARCHAR2(1000) ;
      ls_val_up2     VARCHAR2(1000) ;
      ls_val_gr_up   VARCHAR2(1000) ;
      ls_val_gr_up2  VARCHAR2(1000) ;

   BEGIN
       CASE PSV_VAL_TP
          WHEN '1' THEN
               CASE PSV_COL_CD
                    WHEN '01' THEN
                        CASE WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'G' THEN
                                ls_col_cd  := 'SUM(SUM(A.SALE_QTY)) OVER(PARTITION BY ' || PSV_PB || ') ';
                                ls_alias   := 'SUM_SALE_QTY ';
                             WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'N' THEN
                                ls_col_cd  := 'SUM(A.SALE_QTY) OVER(PARTITION BY ' || PSV_PB || ') ';
                                ls_alias   := 'SUM_SALE_QTY';
                             WHEN PSV_MODE  = 'G' THEN
                                ls_col_cd  := 'SUM(A.SALE_QTY) ';
                                ls_alias   := 'SALE_QTY';
                             ELSE
                                ls_col_cd  := 'A.SALE_QTY ';
                                ls_alias   := 'SALE_QTY';
                        END CASE;
                        ls_ct_val       := 'SUM(SALE_QTY) SALE_QTY ' ;
                        ls_val_up       := ' SALE_QTY ' ;
                        ls_val_up2      := ' SALE_QTY2 ' ;
                        ls_val_gr_up    := ' SUM(SALE_QTY) ' ;
                        ls_val_gr_up2   := ' SUM(SALE_QTY2) ' ;
                    WHEN '02' THEN
                        CASE WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'G' THEN
                                ls_col_cd :=  'SUM(SUM(A.SALE_AMT)) OVER(PARTITION BY ' || PSV_PB || ') ';
                                ls_alias := 'SUM_SALE_AMT';
                             WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'N' THEN
                                ls_col_cd :=  'SUM(A.SALE_AMT) OVER(PARTITION BY ' || PSV_PB || ') ';
                                ls_alias := 'SUM_SALE_AMT';
                             WHEN PSV_MODE = 'G' THEN
                                ls_col_cd :=  'SUM(A.SALE_AMT) ';
                                ls_alias  := 'SALE_AMT' ;
                             ELSE
                                ls_col_cd :=  'A.SALE_AMT ' ;
                                ls_alias  := 'SALE_AMT' ;
                        END CASE;
                        ls_ct_val     := 'SUM(SALE_AMT) SALE_AMT ' ;
                        ls_val_up     := ' SALE_AMT ' ;
                        ls_val_up2     := ' SALE_AMT2 ' ;
                        ls_val_gr_up    := ' SUM(SALE_AMT) ' ;
                        ls_val_gr_up2   := ' SUM(SALE_AMT2) ' ;
                    WHEN '03' THEN
                        CASE WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'G' THEN
                                 ls_col_cd :=  'SUM(SUM(A.ENR_AMT+A.DC_AMT)) OVER(PARTITION BY ' || PSV_PB || ') ' ;
                                 ls_alias  := 'SUM_ENR_AMT';
                             WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'N' THEN
                                 ls_col_cd :=  'SUM(A.ENR_AMT+A.DC_AMT) OVER(PARTITION BY ' || PSV_PB || ') ';
                                 ls_alias  := 'SUM_ENR_AMT';
                             WHEN PSV_MODE = 'G' THEN
                                 ls_col_cd :=  'SUM(A.ENR_AMT+A.DC_AMT) ';
                                 ls_alias  := 'ENR_AMT';
                             ELSE
                                 ls_col_cd :=  'A.ENR_AMT ';
                                 ls_alias  := 'ENR_AMT';
                        END CASE;
                        ls_ct_val     := 'SUM(ENR_AMT) ENR_AMT ' ;
                        ls_val_up     := ' ENR_AMT ' ;
                        ls_val_up2    := ' ENR_AMT2 ' ;
                        ls_val_gr_up    := ' SUM(ENR_AMT) ' ;
                        ls_val_gr_up2   := ' SUM(ENR_AMT2) ' ;
                    WHEN '04' THEN
                        CASE WHEN PSV_CT_TP = 'CV'  AND PSV_MODE = 'G' THEN
                                  ls_col_cd :=  'SUM(SUM(A.GRD_AMT)) OVER(PARTITION BY ' || PSV_PB || ') ' ;
                                  ls_alias  :=  'SUM_GRD_AMT';
                             WHEN PSV_CT_TP = 'CV'  AND PSV_MODE = 'N' THEN
                                  ls_col_cd :=  'SUM(A.GRD_AMT) OVER(PARTITION BY ' || PSV_PB || ')  ' ;
                                  ls_alias := 'SUM_GRD_AMT';
                             WHEN PSV_MODE = 'G' THEN
                                  ls_col_cd :=  'SUM(A.GRD_AMT) ';
                                  ls_alias  := 'GRD_AMT';
                             ELSE
                                  ls_col_cd :=  'A.GRD_AMT ';
                                  ls_alias  := 'GRD_AMT' ;
                        END CASE;
                        ls_ct_val     := 'SUM(GRD_AMT) GRD_AMT ' ;
                        ls_val_up     := ' GRD_AMT ' ;
                        ls_val_up2     := ' GRD_AMT2 ' ;
                        ls_val_gr_up    := ' SUM(GRD_AMT) ' ;
                        ls_val_gr_up2   := ' SUM(GRD_AMT2) ' ;
                    WHEN '05' THEN
                        CASE WHEN PSV_CT_TP = 'CV'  AND PSV_MODE = 'G' THEN
                                  ls_col_cd :=  'SUM(SUM(A.GRD_AMT - A.VAT_AMT)) OVER(PARTITION BY ' || PSV_PB || ') ' ;
                                  ls_alias  :=  'SUM_NET_AMT';
                             WHEN PSV_CT_TP = 'CV'  AND PSV_MODE = 'N' THEN
                                  ls_col_cd :=  'SUM(A.GRD_AMT - A.VAT_AMT) OVER(PARTITION BY ' || PSV_PB || ')  ' ;
                                  ls_alias := 'SUM_NET_AMT';
                             WHEN PSV_MODE = 'G' THEN
                                  ls_col_cd :=  'SUM(A.GRD_AMT - A.VAT_AMT) ';
                                  ls_alias  := 'NET_AMT';
                             ELSE
                                  ls_col_cd :=  'A.GRD_AMT - A.VAT_AMT ';
                                  ls_alias  := 'NET_AMT' ;
                        END CASE;
                        ls_ct_val     := 'SUM(NET_AMT) NET_AMT ' ;
                        ls_val_up     := ' NET_AMT ' ;
                        ls_val_up2     := ' NET_AMT2 ' ;
                        ls_val_gr_up    := ' SUM(NET_AMT) ' ;
                        ls_val_gr_up2   := ' SUM(NET_AMT2) ' ;
                        
                    WHEN '06' THEN
                        CASE WHEN PSV_CT_TP = 'CV'  AND PSV_MODE = 'G' THEN
                                  ls_col_cd :=  'SUM(SUM(A.GRD_I_AMT)) OVER(PARTITION BY ' || PSV_PB || ') ' ;
                                  ls_alias  :=  'SUM_GRD_I_AMT';
                             WHEN PSV_CT_TP = 'CV'  AND PSV_MODE = 'N' THEN
                                  ls_col_cd :=  'SUM(A.GRD_I_AMT) OVER(PARTITION BY ' || PSV_PB || ') ';
                                  ls_alias  := 'SUM_GRD_I_AMT';
                             WHEN PSV_MODE = 'G' THEN
                                  ls_col_cd :=  'SUM(A.GRD_I_AMT) ' ;
                                  ls_alias  := 'GRD_I_AMT';
                             ELSE
                                  ls_col_cd := 'A.GRD_I_AMT ';
                                  ls_alias  := 'GRD_I_AMT';
                        END CASE;
                        ls_ct_val     := 'SUM(GRD_I_AMT) GRD_I_AMT ' ;
                        ls_val_up     := ' GRD_I_AMT ' ;
                        ls_val_up2     := ' GRD_I_AMT2 ' ;
                        ls_val_gr_up    := ' SUM(GRD_I_AMT) ' ;
                        ls_val_gr_up2   := ' SUM(GRD_I_AMT2) ' ;
                    WHEN '07' THEN
                        CASE WHEN PSV_CT_TP = 'CV'  AND PSV_MODE = 'G' THEN
                                  ls_col_cd :=  'SUM(SUM(A.GRD_O_AMT)) OVER(PARTITION BY ' || PSV_PB || ') ' ;
                                  ls_alias  :=  'SUM_GRD_O_AMT';
                             WHEN PSV_CT_TP = 'CV'  AND PSV_MODE = 'N' THEN
                                  ls_col_cd :=  'SUM(A.GRD_O_AMT) OVER(PARTITION BY ' || PSV_PB || ') ';
                                  ls_alias  := 'SUM_GRD_O_AMT';
                             WHEN PSV_MODE = 'G' THEN
                                  ls_col_cd :=  'SUM(A.GRD_O_AMT) ' ;
                                  ls_alias  := 'GRD_O_AMT';
                             ELSE
                                  ls_col_cd := 'A.GRD_O_AMT ';
                                  ls_alias  := 'GRD_O_AMT';
                        END CASE;
                        ls_ct_val     := 'SUM(GRD_O_AMT) GRD_O_AMT ' ;
                        ls_val_up     := ' GRD_O_AMT ' ;
                        ls_val_up2    := ' GRD_O_AMT ' ;
                        ls_val_gr_up    := ' SUM(GRD_O_AMT) ' ;
                        ls_val_gr_up2   := ' SUM(GRD_O_AMT) ' ;
                    WHEN '08' THEN
                        CASE WHEN PSV_CT_TP = 'CV'   AND PSV_MODE = 'G' THEN
                                  ls_col_cd :=  'SUM(SUM(A.BILL_CNT + A.RTN_BILL_CNT)) OVER(PARTITION BY ' || PSV_PB || ') ' ;
                                  ls_alias  :=  'SUM_BILL_CNT';
                             WHEN PSV_CT_TP = 'CV'   AND PSV_MODE = 'N' THEN
                                  ls_col_cd :=  'SUM(A.BILL_CNT + A.RTN_BILL_CNT) OVER(PARTITION BY ' || PSV_PB || ')';
                                  ls_alias  :=   'SUM_BILL_CNT';
                             WHEN PSV_MODE = 'G' THEN
                                  ls_col_cd :=  'SUM(A.BILL_CNT + A.RTN_BILL_CNT) ';
                                  ls_alias  := 'BILL_CNT';
                             ELSE
                                  ls_col_cd :=  '(A.BILL_CNT + A.RTN_BILL_CNT) ';
                                  ls_alias  := 'BILL_CNT';
                        END CASE ;
                        ls_ct_val     := 'SUM(BILL_CNT) BILL_CNT ' ;
                        ls_val_up     := ' BILL_CNT ' ;
                        ls_val_up2     := ' BILL_CNT2 ' ;
                        ls_val_gr_up    := ' SUM(BILL_CNT) ' ;
                        ls_val_gr_up2   := ' SUM(BILL_CNT2) ' ;

                    WHEN '09' THEN
                        CASE WHEN PSV_CT_TP = 'CV'   AND PSV_MODE = 'G' THEN
                                  ls_col_cd :=  ' CASE WHEN SUM(SUM(A.BILL_CNT + A.RTN_BILL_CNT)) OVER(PARTITION BY ' || PSV_PB || ') = 0 THEN '
                                            ||  ' NULL ELSE '
                                            ||  '  ROUND(SUM(SUM(A.GRD_AMT)) OVER(PARTITION BY ' || PSV_PB || ') '
                                            ||  ' / SUM(SUM(A.BILL_CNT + A.RTN_BILL_CNT)) OVER(PARTITION BY ' || PSV_PB || ')) END ';
                                  ls_alias  := 'SUM_BILL_AMT';
                             WHEN PSV_CT_TP = 'CV'   AND PSV_MODE = 'N' THEN
                                  ls_col_cd :=  ' CASE WHEN SUM(A.BILL_CNT + A.RTN_BILL_CNT) OVER(PARTITION BY ' || PSV_PB || ') = 0 THEN '
                                            ||  ' NULL ELSE '
                                            ||  ' ROUND(SUM(A.GRD_AMT) OVER( PARTITION BY ' || PSV_PB || ') '
                                            ||  ' / SUM(A.BILL_CNT + A.RTN_BILL_CNT) OVER(PARTITION BY  ' || PSV_PB || ')) END ';
                                  ls_alias  :=  'SUM_BILL_AMT';
                             WHEN PSV_MODE = 'G' THEN
                                  ls_col_cd :=  ' CASE WHEN SUM(A.BILL_CNT + A.RTN_BILL_CNT) = 0 THEN '
                                            ||  ' NULL ELSE '
                                            ||  ' ROUND(SUM(A.GRD_AMT) / SUM(A.BILL_CNT  + A.RTN_BILL_CNT)) END ';
                                  ls_alias  :=  'BILL_AMT';
                             ELSE
                                  ls_col_cd :=  ' CASE WHEN (A.BILL_CNT + A.RTN_BILL_CNT) = 0 THEN '
                                            ||  ' NULL ELSE '
                                            ||  ' ROUND(A.GRD_AMT / (A.BILL_CNT  + A.RTN_BILL_CNT)) END ' ;
                                  ls_alias  :=  'BILL_AMT';

                        END CASE;
                        ls_ct_val     := ' SUM(BILL_AMT) BILL_AMT ' ;
                        ls_val_up     := ' BILL_AMT ' ;
                        ls_val_up2    := ' BILL_AMT2 ' ;
                        ls_val_gr_up  := ' SUM(BILL_AMT) ' ;
                        ls_val_gr_up2 := ' SUM(BILL_AMT2) ' ;
                    WHEN '10' THEN
                        CASE WHEN PSV_CT_TP = 'CV'   AND PSV_MODE = 'G' THEN
                                  ls_col_cd := 'SUM(SUM(A.ETC_M_CNT + A.ETC_F_CNT)) OVER(PARTITION BY ' || PSV_PB || ') ';
                                  ls_alias  := 'SUM_CUST_CNT';
                             WHEN PSV_CT_TP = 'CV'    AND PSV_MODE = 'N' THEN
                                  ls_col_cd := 'SUM(A.ETC_M_CNT + A.ETC_F_CNT) OVER(PARTITION BY ' || PSV_PB || ') ' ;
                                  ls_alias  := 'SUM_CUST_CNT';
                             WHEN PSV_MODE = 'G' THEN
                                  ls_col_cd :=  'SUM(A.ETC_M_CNT + A.ETC_F_CNT) ' ;
                                  ls_alias  :=  'CUST_CNT';
                             ELSE
                                  ls_col_cd :=  '(A.ETC_M_CNT + A.ETC_F_CNT) ' ;
                                  ls_alias  :=  'CUST_CNT';
                        END CASE;
                        ls_ct_val     := 'SUM(CUST_CNT) CUST_CNT ' ;
                        ls_val_up     := ' CUST_CNT ' ;
                        ls_val_up2     := ' CUST_CNT2 ' ;
                        ls_val_gr_up    := ' SUM(CUST_CNT) ' ;
                        ls_val_gr_up2   := ' SUM(CUST_CNT2) ' ;
                    WHEN '11' THEN
                        CASE WHEN PSV_CT_TP = 'CV'  AND PSV_MODE = 'G' THEN
                                  ls_col_cd :=  ' CASE WHEN SUM(SUM(A.ETC_M_CNT + A.ETC_F_CNT)) OVER(PARTITION BY ' || PSV_PB || ') = 0 THEN '
                                            ||  ' NULL ELSE  '
                                            ||  ' ROUND(SUM(SUM(A.GRD_AMT)) OVER(PARTITION BY ' || PSV_PB || ') '
                                            ||  ' / SUM(SUM(A.ETC_M_CNT + A.ETC_F_CNT)) OVER(PARTITION BY ' || PSV_PB || ')) END ' ;
                                  ls_alias  := 'SUM_CUST_AMT';
                             WHEN PSV_CT_TP = 'CV'  AND PSV_MODE = 'N' THEN
                                  ls_col_cd :=  ' CASE WHEN SUM(A.ETC_M_CNT + A.ETC_F_CNT) OVER(PARTITION BY ' || PSV_PB || ') = 0 THEN '
                                            ||  ' NULL ELSE '
                                            ||  ' ROUND(SUM(A.GRD_AMT) OVER(PARTITION BY ' || PSV_PB || ') '
                                      ||  ' / SUM(A.ETC_M_CNT + A.ETC_F_CNT) OVER(PARTITION BY ' || PSV_PB || '))  END ' ;
                                  ls_alias  := 'SUM_CUST_AMT';
                             WHEN PSV_MODE = 'G' THEN
                                  ls_col_cd :=  ' CASE WHEN SUM(A.ETC_M_CNT + A.ETC_F_CNT) = 0 THEN '
                                            ||  ' NULL ELSE '
                                            ||  ' ROUND(SUM(A.GRD_AMT) / SUM(A.ETC_M_CNT + A.ETC_F_CNT)) END ' ;
                                  ls_alias := 'CUST_AMT';
                             ELSE
                                  ls_col_cd :=  ' CASE WHEN (A.ETC_M_CNT + A.ETC_F_CNT) = 0 THEN '
                                            ||  ' NULL ELSE '
                                            ||  ' ROUND(A.GRD_AMT / (A.ETC_M_CNT + A.ETC_F_CNT)) END ';
                                  ls_alias  :=  'CUST_AMT';
                        END CASE;
                        ls_ct_val     := ' SUM(CUST_AMT) CUST_AMT ' ;
                        ls_val_up     := ' CUST_AMT ' ;
                        ls_val_up2     := ' CUST_AMT2 ' ;
                        ls_val_gr_up    := ' SUM(CUST_AMT) ' ;
                        ls_val_gr_up2   := ' SUM(CUST_AMT2) ' ;
                    WHEN '12' THEN
                        CASE WHEN PSV_CT_TP = 'CV'  AND PSV_MODE = 'G' THEN
                                  ls_col_cd :=  'SUM(COUNT(DISTINCT A.STOR_CD)) OVER(PARTITION BY ' || PSV_PB || ') ' ;
                                  ls_alias  :=  'SUM_STOR_CNT';
                             WHEN PSV_CT_TP = 'CV'  AND PSV_MODE = 'N' THEN
                                  ls_col_cd :=  'COUNT(DISTINCT A.STOR_CD) OVER(PARTITION BY ' || PSV_PB || ')  ' ;
                                  ls_alias := 'SUM_STOR_CNT';
                             WHEN PSV_MODE = 'G' THEN
                                  ls_col_cd :=  ' COUNT(DISTINCT A.STOR_CD) ';
                                  ls_alias  := 'STOR_CNT';
                             ELSE
                                  ls_col_cd :=  '1 ';
                                  ls_alias  := 'STOR_CNT' ;
                        END CASE;
                        ls_ct_val     := ' SUM(STOR_CNT) STOR_CNT ' ;
                        ls_val_up     := ' STOR_CNT ' ;
                        ls_val_up2     := ' STOR_CNT2 ' ;
                        ls_val_gr_up    := ' SUM(STOR_CNT) ' ;
                        ls_val_gr_up2   := ' SUM(STOR_CNT2) ' ;
                    ELSE
                        ls_col_cd := ' ' ;
                        ls_alias  := ' ' ;
                        ls_ct_val := ' ' ;
                        ls_val_up := ' ' ;
                        ls_val_up2 := ' ' ;
               END CASE;
       WHEN '2' THEN
               CASE PSV_COL_CD
                    WHEN '01' THEN
                        CASE WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'G' THEN
                                ls_col1 :=  'SUM_SALE_QTY';
                                ls_col2 :=  'SUM_SALE_QTY2';
                                ls_alias  :=  'A_SUM_SALE_QTY';
                             WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'N' THEN
                                ls_col1 :=  'SUM_SALE_QTY';
                                ls_col2 :=  'SUM_SALE_QTY2';
                                ls_alias  :=  'A_SUM_SALE_QTY';
                             WHEN PSV_MODE = 'G' THEN
                                ls_col1 :=  'SALE_QTY';
                                ls_col2 :=  'SALE_QTY2';
                                ls_alias  :=  'A_SALE_QTY';
                             ELSE
                                ls_col1 :=  'SALE_QTY';
                                ls_col2 :=  'SALE_QTY2';
                                ls_alias  :=  'A_SALE_QTY';
                        END CASE;
                        SP_GET_VALUE_02 ( ls_col1 ,ls_col2, ls_val_up ,ls_val_gr_up, ls_val_up2 ,ls_val_gr_up2 );
                        ls_ct_val   := ' SUM(A_SALE_QTY) A_SALE_QTY ' ;
                    WHEN '02' THEN
                        CASE WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'G' THEN
                                ls_col1 :=  'SUM_SALE_AMT';
                                ls_col2 :=  'SUM_SALE_AMT2';
                                ls_alias  :=  'A_SUM_SALE_AMT';
                             WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'N' THEN
                                ls_col1 :=  'SUM_SALE_AMT';
                                ls_col2 :=  'SUM_SALE_AMT2';
                                ls_alias  :=  'A_SUM_SALE_AMT';
                             WHEN PSV_MODE = 'G' THEN
                                ls_col1 :=  'SALE_AMT';
                                ls_col2 :=  'SALE_AMT2';
                                ls_alias  :=  'A_SALE_AMT';
                             ELSE
                                ls_col1 :=  'SALE_AMT';
                                ls_col2 :=  'SALE_AMT2';
                                ls_alias  :=  'A_SALE_AMT';
                        END CASE;
                        SP_GET_VALUE_02 ( ls_col1 ,ls_col2, ls_val_up ,ls_val_gr_up, ls_val_up2 ,ls_val_gr_up2 );
                        ls_ct_val   := ' SUM(A_SALE_AMT) A_SALE_AMT ' ;
                    WHEN '03' THEN
                        CASE WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'G' THEN
                                ls_col1 :=  'SUM_ENR_AMT';
                                ls_col2 :=  'SUM_ENR_AMT2';
                                ls_alias  :=  'A_SUM_ENR_AMT';
                             WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'N' THEN
                                ls_col1 :=  'SUM_ENR_AMT';
                                ls_col2 :=  'SUM_ENR_AMT2';
                                ls_alias  :=  'A_SUM_ENR_AMT';
                             WHEN PSV_MODE = 'G' THEN
                                ls_col1 :=  'ENR_AMT';
                                ls_col2 :=  'ENR_AMT2';
                                ls_alias  :=  'A_ENR_AMT';
                             ELSE
                                ls_col1 :=  'ENR_AMT';
                                ls_col2 :=  'ENR_AMT2';
                                ls_alias  :=  'A_ENR_AMT';
                        END CASE;
                        SP_GET_VALUE_02 ( ls_col1 ,ls_col2, ls_val_up ,ls_val_gr_up, ls_val_up2 ,ls_val_gr_up2 );
                        ls_ct_val   := ' SUM(A_ENR_AMT) A_ENR_AMT ' ;
                    WHEN '04' THEN
                        CASE WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'G' THEN
                                ls_col1 :=  'SUM_GRD_AMT';
                                ls_col2 :=  'SUM_GRD_AMT2';
                                ls_alias  :=  'A_SUM_GRD_AMT';
                             WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'N' THEN
                                ls_col1 :=  'SUM_GRD_AMT';
                                ls_col2 :=  'SUM_GRD_AMT2';
                                ls_alias  :=  'A_SUM_GRD_AMT';
                             WHEN PSV_MODE = 'G' THEN
                                ls_col1 :=  'GRD_AMT';
                                ls_col2 :=  'GRD_AMT2';
                                ls_alias  :=  'A_GRD_AMT';
                             ELSE
                                ls_col1 :=  'GRD_AMT';
                                ls_col2 :=  'GRD_AMT2';
                                ls_alias  :=  'A_GRD_AMT';
                        END CASE;
                        SP_GET_VALUE_02 ( ls_col1 ,ls_col2, ls_val_up ,ls_val_gr_up, ls_val_up2 ,ls_val_gr_up2 );
                        ls_ct_val   := ' SUM(A_GRD_AMT) A_GRD_AMT ' ;
                    WHEN '05' THEN
                        CASE WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'G' THEN
                                ls_col1 :=  'SUM_NET_AMT';
                                ls_col2 :=  'SUM_NET_AMT2';
                                ls_alias  :=  'A_SUM_NET_AMT';
                             WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'N' THEN
                                ls_col1 :=  'SUM_NET_AMT';
                                ls_col2 :=  'SUM_NET_AMT2';
                                ls_alias  :=  'A_SUM_NET_AMT';
                             WHEN PSV_MODE = 'G' THEN
                                ls_col1 :=  'NET_AMT';
                                ls_col2 :=  'NET_AMT2';
                                ls_alias  :=  'A_NET_AMT';
                             ELSE
                                ls_col1 :=  'NET_AMT';
                                ls_col2 :=  'NET_AMT2';
                                ls_alias  :=  'A_NET_AMT';
                        END CASE;
                        SP_GET_VALUE_02 ( ls_col1 ,ls_col2, ls_val_up ,ls_val_gr_up, ls_val_up2 ,ls_val_gr_up2 );
                        ls_ct_val   := ' SUM(A_NET_AMT) A_NET_AMT ' ;
                        
                    WHEN '06' THEN
                        CASE WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'G' THEN
                                ls_col1 :=  'SUM_GRD_I_AMT';
                                ls_col2 :=  'SUM_GRD_I_AMT2';
                                ls_alias  :=  'A_SUM_GRD_I_AMT';
                             WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'N' THEN
                                ls_col1 :=  'SUM_GRD_I_AMT';
                                ls_col2 :=  'SUM_GRD_I_AMT2';
                                ls_alias  :=  'A_SUM_GRD_I_AMT';
                             WHEN PSV_MODE = 'G' THEN
                                ls_col1 :=  'GRD_I_AMT';
                                ls_col2 :=  'GRD_I_AMT2';
                                ls_alias  :=  'A_GRD_I_AMT';
                             ELSE
                                ls_col1 :=  'GRD_I_AMT';
                                ls_col2 :=  'GRD_I_AMT2';
                                ls_alias  :=  'A_GRD_I_AMT';
                        END CASE;
                        SP_GET_VALUE_02 ( ls_col1 ,ls_col2, ls_val_up ,ls_val_gr_up, ls_val_up2 ,ls_val_gr_up2 );
                        ls_ct_val   := ' SUM(A_GRD_I_AMT) A_GRD_I_AMT ' ;
                    WHEN '07' THEN
                        CASE WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'G' THEN
                                ls_col1 :=  'SUM_GRD_O_AMT';
                                ls_col2 :=  'SUM_GRD_O_AMT2';
                                ls_alias  :=  'A_SUM_GRD_O_AMT';
                             WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'N' THEN
                                ls_col1 :=  'SUM_GRD_O_AMT';
                                ls_col2 :=  'SUM_GRD_O_AMT2';
                                ls_alias  :=  'A_SUM_GRD_O_AMT';
                             WHEN PSV_MODE = 'G' THEN
                                ls_col1 :=  'GRD_O_AMT';
                                ls_col2 :=  'GRD_O_AMT2';
                                ls_alias  :=  'A_GRD_O_AMT';
                             ELSE
                                ls_col1 :=  'GRD_O_AMT';
                                ls_col2 :=  'GRD_O_AMT2';
                                ls_alias  :=  'A_GRD_O_AMT';
                        END CASE;
                        SP_GET_VALUE_02 ( ls_col1 ,ls_col2, ls_val_up ,ls_val_gr_up, ls_val_up2 ,ls_val_gr_up2 );
                        ls_ct_val   := ' SUM(A_GRD_O_AMT) A_GRD_O_AMT ' ;
                    WHEN '08' THEN
                        CASE WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'G' THEN
                                ls_col1 :=  'SUM_BILL_CNT';
                                ls_col2 :=  'SUM_BILL_CNT2';
                                ls_alias  :=  'A_SUM_BILL_CNT';
                             WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'N' THEN
                                ls_col1 :=  'SUM_BILL_CNT';
                                ls_col2 :=  'SUM_BILL_CNT2';
                                ls_alias  :=  'A_SUM_BILL_CNT';
                             WHEN PSV_MODE = 'G' THEN
                                ls_col1 :=  'BILL_CNT';
                                ls_col2 :=  'BILL_CNT2';
                                ls_alias  :=  'A_BILL_CNT';
                             ELSE
                                ls_col1 :=  'BILL_CNT';
                                ls_col2 :=  'BILL_CNT2';
                                ls_alias  :=  'A_BILL_CNT';
                        END CASE;
                        SP_GET_VALUE_02 ( ls_col1 ,ls_col2, ls_val_up ,ls_val_gr_up, ls_val_up2 ,ls_val_gr_up2 );
                        ls_ct_val   := ' SUM(A_BILL_CNT) A_BILL_CNT ' ;
                    WHEN '09' THEN
                        CASE WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'G' THEN
                                ls_col1 :=  'SUM_BILL_AMT';
                                ls_col2 :=  'SUM_BILL_AMT2';
                                ls_alias  :=  'A_SUM_BILL_AMT';
                             WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'N' THEN
                                ls_col1 :=  'SUM_BILL_AMT';
                                ls_col2 :=  'SUM_BILL_AMT2';
                                ls_alias  :=  'A_SUM_BILL_AMT';
                             WHEN PSV_MODE = 'G' THEN
                                ls_col1 :=  'BILL_AMT';
                                ls_col2 :=  'BILL_AMT2';
                                ls_alias  :=  'A_BILL_AMT';
                             ELSE
                                ls_col1 :=  'BILL_AMT';
                                ls_col2 :=  'BILL_AMT2';
                                ls_alias  :=  'A_BILL_AMT';
                        END CASE;
                        SP_GET_VALUE_02 ( ls_col1 ,ls_col2, ls_val_up ,ls_val_gr_up, ls_val_up2 ,ls_val_gr_up2 );
                        ls_ct_val     := ' SUM(A_BILL_AMT) A_BILL_AMT ' ;
                    WHEN '10' THEN
                       CASE WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'G' THEN
                                ls_col1 :=  'SUM_CUST_CNT';
                                ls_col2 :=  'SUM_CUST_CNT2';
                                ls_alias  :=  'A_SUM_CUST_CNT';
                             WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'N' THEN
                                ls_col1 :=  'SUM_CUST_CNT';
                                ls_col2 :=  'SUM_CUST_CNT2';
                                ls_alias  :=  'A_SUM_CUST_CNT';
                             WHEN PSV_MODE = 'G' THEN
                                ls_col1 :=  'CUST_CNT';
                                ls_col2 :=  'CUST_CNT2';
                                ls_alias  :=  'A_CUST_CNT';
                             ELSE
                                ls_col1 :=  'CUST_CNT';
                                ls_col2 :=  'CUST_CNT2';
                                ls_alias  :=  'A_CUST_CNT';
                       END CASE;
                       SP_GET_VALUE_02 ( ls_col1 ,ls_col2, ls_val_up ,ls_val_gr_up, ls_val_up2 ,ls_val_gr_up2 );
                       ls_ct_val     := ' SUM(A_CUST_CNT) A_CUST_CNT ' ;
                    WHEN '11' THEN
                       CASE WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'G' THEN
                                ls_col1 :=  'SUM_CUST_AMT';
                                ls_col2 :=  'SUM_CUST_AMT2';
                                ls_alias  :=  'A_SUM_CUST_AMT';
                             WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'N' THEN
                                ls_col1 :=  'SUM_CUST_AMT';
                                ls_col2 :=  'SUM_CUST_AMT2';
                                ls_alias  :=  'A_SUM_CUST_AMT';
                             WHEN PSV_MODE = 'G' THEN
                                ls_col1 :=  'CUST_AMT';
                                ls_col2 :=  'CUST_AMT2';
                                ls_alias  :=  'A_CUST_AMT';
                             ELSE
                                ls_col1 :=  'CUST_AMT';
                                ls_col2 :=  'CUST_AMT2';
                                ls_alias  :=  'A_CUST_AMT';
                       END CASE;
                       SP_GET_VALUE_02 ( ls_col1 ,ls_col2, ls_val_up ,ls_val_gr_up, ls_val_up2 ,ls_val_gr_up2 );
                       ls_ct_val     := ' SUM(A_CUST_AMT)  A_CUST_AMT ' ;
                    WHEN '12' THEN
                       CASE WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'G' THEN
                                ls_col1 :=  'SUM_STOR_CNT';
                                ls_col2 :=  'SUM_STOR_CNT2';
                                ls_alias  :=  'A_SUM_STOR_CNT';
                                ls_val_up     := ' SUM_STOR_CNT ' ;
                                ls_val_gr_up  := ' SUM(SUM_STOR_CNT) ' ;
                                ls_val_up2    := ' SUM_STOR_CNT2 ' ;
                                ls_val_gr_up2 := ' SUM(SUM_STOR_CNT2) ' ;
                             WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'N' THEN
                                ls_col1 :=  'SUM_STOR_CNT';
                                ls_col2 :=  'SUM_STOR_CNT2';
                                ls_alias  :=  'A_SUM_STOR_CNT';
                                ls_val_up     := ' SUM_STOR_CNT ' ;
                                ls_val_gr_up  := ' SUM(SUM_STOR_CNT) ' ;
                                ls_val_up2    := ' SUM_STOR_CNT2 ' ;
                                ls_val_gr_up2 := ' SUM(SUM_STOR_CNT2) ' ;
                             WHEN PSV_MODE = 'G' THEN
                                ls_col1 :=  'STOR_CNT';
                                ls_col2 :=  'STOR_CNT2';
                                ls_alias  :=  'A_STOR_CNT';
                                ls_val_up     := ' STOR_CNT ' ;
                                ls_val_gr_up  := ' SUM(STOR_CNT) ' ;
                                ls_val_up2    := ' STOR_CNT2 ' ;
                                ls_val_gr_up2 := ' SUM(STOR_CNT2) ' ;
                             ELSE
                                ls_col1 :=  'STOR_CNT';
                                ls_col2 :=  'STOR_CNT2';
                                ls_alias  :=  'A_STOR_CNT';
                                ls_val_up     := ' STOR_CNT ' ;
                                ls_val_gr_up  := ' SUM(STOR_CNT) ' ;
                                ls_val_up2    := ' STOR_CNT2 ' ;
                                ls_val_gr_up2 := ' SUM(STOR_CNT2) ' ;
                       END CASE;
                       ls_ct_val     := ' SUM(A_STOR_CNT) A_STOR_CNT ';
                    ELSE
                        ls_col_cd := ' ' ;
                        ls_alias  := ' ' ;
                        ls_ct_val := ' ' ;
                        ls_val_up := ' ' ;
               END CASE;
       WHEN '3' THEN
               CASE PSV_COL_CD
                    WHEN '01' THEN
                        CASE WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'G' THEN
                                ls_col1 :=  'SUM_SALE_QTY';
                                ls_col2 :=  'SALE_QTY';
                                ls_col3 :=  'SUM_SALE_QTY2';
                                ls_col4 :=  'SALE_QTY2';
                                ls_alias  :=  'R_SUM_SALE_QTY';
                             WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'N' THEN
                                ls_col1 :=  'SUM_SALE_QTY';
                                ls_col2 :=  'SALE_QTY';
                                ls_col3 :=  'SUM_SALE_QTY2';
                                ls_col3 :=  'SALE_QTY2';
                                ls_alias  :=  'R_SUM_SALE_QTY';
                             WHEN PSV_MODE = 'G' THEN
                                ls_col1 :=  'SALE_QTY';
                                ls_col2 :=  'SALE_QTY';
                                ls_col3 :=  'SALE_QTY2';
                                ls_col4 :=  'SALE_QTY2';
                                ls_alias  :=  'R_SALE_QTY';
                             ELSE
                                ls_col1 :=  'SALE_QTY';
                                ls_col2 :=  'SALE_QTY';
                                ls_col3 :=  'SALE_QTY2';
                                ls_col4 :=  'SALE_QTY2';
                                ls_alias  :=  'R_SALE_QTY';
                        END CASE;
                        SP_GET_VALUE_03 ( ls_col1 ,ls_col2, ls_col3, ls_col4, ls_val_up ,ls_val_gr_up, ls_val_up2 ,ls_val_gr_up2 );
                        ls_ct_val   := ' SUM(R_SALE_QTY) R_SALE_QTY ' ;
                    WHEN '02' THEN
                        CASE WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'G' THEN
                                ls_col1 :=  'SUM_SALE_AMT';
                                ls_col2 :=  'SALE_AMT';
                                ls_col3 :=  'SUM_SALE_AMT2';
                                ls_col4 :=  'SALE_AMT2';
                                ls_alias  :=  'R_SUM_SALE_AMT';
                             WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'N' THEN
                                ls_col1 :=  'SUM_SALE_AMT';
                                ls_col2 :=  'SALE_AMT';
                                ls_col3 :=  'SUM_SALE_AMT2';
                                ls_col4 :=  'SALE_AMT2';
                                ls_alias  :=  'R_SUM_SALE_AMT';
                             WHEN PSV_MODE = 'G' THEN
                                ls_col1 :=  'SALE_AMT';
                                ls_col2 :=  'SALE_AMT';
                                ls_col3 :=  'SALE_AMT2';
                                ls_col4 :=  'SALE_AMT2';
                                ls_alias  :=  'R_SALE_AMT';
                             ELSE
                                ls_col1 :=  'SALE_AMT';
                                ls_col2 :=  'SALE_AMT';
                                ls_col3 :=  'SALE_AMT2';
                                ls_col4 :=  'SALE_AMT2';
                                ls_alias  :=  'R_SALE_AMT';
                        END CASE;
                        SP_GET_VALUE_03 ( ls_col1 ,ls_col2, ls_col3, ls_col4,  ls_val_up ,ls_val_gr_up, ls_val_up2 ,ls_val_gr_up2 );
                        ls_ct_val   := ' SUM(R_SALE_AMT) R_SALE_AMT ' ;
                    WHEN '03' THEN
                        CASE WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'G' THEN
                                ls_col1 :=  'SUM_ENR_AMT';
                                ls_col2 :=  'ENR_AMT';
                                ls_col3 :=  'SUM_ENR_AMT2';
                                ls_col4 :=  'ENR_AMT2';
                                ls_alias  :=  'R_SUM_ENR_AMT';
                             WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'N' THEN
                                ls_col1 :=  'SUM_ENR_AMT';
                                ls_col2 :=  'ENR_AMT';
                                ls_col3 :=  'SUM_ENR_AMT2';
                                ls_col4 :=  'ENR_AMT2';
                                ls_alias  :=  'R_SUM_ENR_AMT';
                             WHEN PSV_MODE = 'G' THEN
                                ls_col1 :=  'ENR_AMT';
                                ls_col2 :=  'ENR_AMT';
                                ls_col3 :=  'ENR_AMT2';
                                ls_col4 :=  'ENR_AMT2';
                                ls_alias  :=  'R_ENR_AMT';
                             ELSE
                                ls_col1 :=  'ENR_AMT';
                                ls_col2 :=  'ENR_AMT';
                                ls_col3 :=  'ENR_AMT2';
                                ls_col4 :=  'ENR_AMT2';
                                ls_alias  :=  'R_ENR_AMT';
                        END CASE;
                        SP_GET_VALUE_03 ( ls_col1 ,ls_col2, ls_col3, ls_col4,  ls_val_up ,ls_val_gr_up, ls_val_up2 ,ls_val_gr_up2 );
                        ls_ct_val   := ' SUM(R_ENR_AMT) R_ENR_AMT ' ;
                    WHEN '04' THEN
                        CASE WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'G' THEN
                                ls_col1 :=  'SUM_GRD_AMT';
                                ls_col2 :=  'GRD_AMT';
                                ls_col3 :=  'SUM_GRD_AMT2';
                                ls_col4 :=  'GRD_AMT2';
                                ls_alias  :=  'R_SUM_GRD_AMT';
                             WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'N' THEN
                                ls_col1 :=  'SUM_GRD_AMT';
                                ls_col2 :=  'GRD_AMT';
                                ls_col3 :=  'SUM_GRD_AMT2';
                                ls_col4 :=  'GRD_AMT2';
                                ls_alias  :=  'R_SUM_GRD_AMT';
                             WHEN PSV_MODE = 'G' THEN
                                ls_col1 :=  'GRD_AMT';
                                ls_col2 :=  'GRD_AMT';
                                ls_col3 :=  'GRD_AMT2';
                                ls_col4 :=  'GRD_AMT2';
                                ls_alias  :=  'R_GRD_AMT';
                             ELSE
                                ls_col1 :=  'GRD_AMT';
                                ls_col2 :=  'GRD_AMT';
                                ls_col3 :=  'GRD_AMT2';
                                ls_col4 :=  'GRD_AMT2';
                                ls_alias  :=  'R_GRD_AMT';
                        END CASE;
                        SP_GET_VALUE_03 ( ls_col1 ,ls_col2, ls_col3, ls_col4,  ls_val_up ,ls_val_gr_up, ls_val_up2 ,ls_val_gr_up2 );
                        ls_ct_val   := ' SUM(R_GRD_AMT) R_GRD_AMT ' ;
                    WHEN '05' THEN
                        CASE WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'G' THEN
                                ls_col1 :=  'SUM_NET_AMT';
                                ls_col2 :=  'NET_AMT';
                                ls_col3 :=  'SUM_NET_AMT2';
                                ls_col4 :=  'NET_AMT2';
                                ls_alias  :=  'R_SUM_NET_AMT';
                             WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'N' THEN
                                ls_col1 :=  'SUM_NET_AMT';
                                ls_col2 :=  'NET_AMT';
                                ls_col3 :=  'SUM_NET_AMT2';
                                ls_col4 :=  'NET_AMT2';
                                ls_alias  :=  'R_SUM_NET_AMT';
                             WHEN PSV_MODE = 'G' THEN
                                ls_col1 :=  'NET_AMT';
                                ls_col2 :=  'NET_AMT';
                                ls_col3 :=  'NET_AMT2';
                                ls_col4 :=  'NET_AMT2';
                                ls_alias  :=  'R_NET_AMT';
                             ELSE
                                ls_col1 :=  'NET_AMT';
                                ls_col2 :=  'NET_AMT';
                                ls_col3 :=  'NET_AMT2';
                                ls_col4 :=  'NET_AMT2';
                                ls_alias  :=  'R_NET_AMT';
                        END CASE;
                        SP_GET_VALUE_03 ( ls_col1 ,ls_col2, ls_col3, ls_col4,  ls_val_up ,ls_val_gr_up, ls_val_up2 ,ls_val_gr_up2 );
                        ls_ct_val   := ' SUM(R_NET_AMT) R_NET_AMT ' ;
                        
                    WHEN '06' THEN
                        CASE WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'G' THEN
                                ls_col1 :=  'SUM_GRD_I_AMT';
                                ls_col2 :=  'GRD_I_AMT';
                                ls_col3 :=  'SUM_GRD_I_AMT2';
                                ls_col4 :=  'GRD_I_AMT2';
                                ls_alias  :=  'R_SUM_GRD_I_AMT';
                             WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'N' THEN
                                ls_col1 :=  'SUM_GRD_I_AMT';
                                ls_col2 :=  'GRD_I_AMT';
                                ls_col3 :=  'SUM_GRD_I_AMT2';
                                ls_col4 :=  'GRD_I_AMT2';
                                ls_alias  :=  'R_SUM_GRD_I_AMT';
                             WHEN PSV_MODE = 'G' THEN
                                ls_col1 :=  'GRD_I_AMT';
                                ls_col2 :=  'GRD_I_AMT';
                                ls_col3 :=  'GRD_I_AMT2';
                                ls_col4 :=  'GRD_I_AMT2';
                                ls_alias  :=  'R_GRD_I_AMT';
                             ELSE
                                ls_col1 :=  'GRD_I_AMT';
                                ls_col2 :=  'GRD_I_AMT';
                                ls_col3 :=  'GRD_I_AMT2';
                                ls_col4 :=  'GRD_I_AMT2';
                                ls_alias  :=  'R_GRD_I_AMT';
                        END CASE;
                        SP_GET_VALUE_03 ( ls_col1 ,ls_col2, ls_col3, ls_col4,  ls_val_up ,ls_val_gr_up, ls_val_up2 ,ls_val_gr_up2 );
                        ls_ct_val   := ' SUM(R_GRD_I_AMT) R_GRD_I_AMT ' ;
                    WHEN '07' THEN
                        CASE WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'G' THEN
                                ls_col1 :=  'SUM_GRD_O_AMT';
                                ls_col2 :=  'GRD_O_AMT';
                                ls_col3 :=  'SUM_GRD_O_AMT2';
                                ls_col4 :=  'GRD_O_AMT2';
                                ls_alias  :=  'R_SUM_GRD_O_AMT';
                             WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'N' THEN
                                ls_col1 :=  'SUM_GRD_O_AMT';
                                ls_col2 :=  'GRD_O_AMT';
                                ls_col3 :=  'SUM_GRD_O_AMT2';
                                ls_col4 :=  'GRD_O_AMT2';
                                ls_alias  :=  'R_SUM_GRD_O_AMT';
                             WHEN PSV_MODE = 'G' THEN
                                ls_col1 :=  'GRD_O_AMT';
                                ls_col2 :=  'GRD_O_AMT';
                                ls_col3 :=  'GRD_O_AMT2';
                                ls_col4 :=  'GRD_O_AMT2';
                                ls_alias  :=  'R_GRD_O_AMT';
                             ELSE
                                ls_col1 :=  'GRD_O_AMT';
                                ls_col2 :=  'GRD_O_AMT';
                                ls_col3 :=  'GRD_O_AMT2';
                                ls_col4 :=  'GRD_O_AMT2';
                                ls_alias  :=  'R_GRD_O_AMT';
                        END CASE;
                        SP_GET_VALUE_03 ( ls_col1 ,ls_col2, ls_col3, ls_col4,  ls_val_up ,ls_val_gr_up, ls_val_up2 ,ls_val_gr_up2 );
                        ls_ct_val   := ' SUM(R_GRD_O_AMT) R_GRD_O_AMT ' ;
                    WHEN '08' THEN
                        CASE WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'G' THEN
                                ls_col1 :=  'SUM_BILL_CNT';
                                ls_col2 :=  'BILL_CNT';
                                ls_col3 :=  'SUM_BILL_CNT2';
                                ls_col4 :=  'BILL_CNT2';
                                ls_alias  :=  'R_SUM_BILL_CNT';
                             WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'N' THEN
                                ls_col1 :=  'SUM_BILL_CNT';
                                ls_col2 :=  'BILL_CNT';
                                ls_col3 :=  'SUM_BILL_CNT2';
                                ls_col4 :=  'BILL_CNT2';
                                ls_alias  :=  'R_SUM_BILL_CNT';
                             WHEN PSV_MODE = 'G' THEN
                                ls_col1 :=  'BILL_CNT';
                                ls_col2 :=  'BILL_CNT';
                                ls_col3 :=  'BILL_CNT2';
                                ls_col4 :=  'BILL_CNT2';
                                ls_alias  :=  'R_BILL_CNT';
                             ELSE
                                ls_col1 :=  'BILL_CNT';
                                ls_col2 :=  'BILL_CNT';
                                ls_col3 :=  'BILL_CNT2';
                                ls_col4 :=  'BILL_CNT2';
                                ls_alias  :=  'R_BILL_CNT';
                        END CASE;
                        SP_GET_VALUE_03 ( ls_col1 ,ls_col2, ls_col3, ls_col4,  ls_val_up ,ls_val_gr_up, ls_val_up2 ,ls_val_gr_up2 );
                        ls_ct_val   := ' SUM(R_BILL_CNT) R_BILL_CNT ' ;
                    WHEN '09' THEN
                        CASE WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'G' THEN
                                ls_col1 :=  'SUM_BILL_AMT';
                                ls_col2 :=  'BILL_AMT';
                                ls_col3 :=  'SUM_BILL_AMT2';
                                ls_col4 :=  'BILL_AMT2';
                                ls_alias  :=  'R_SUM_BILL_AMT';
                             WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'N' THEN
                                ls_col1 :=  'SUM_BILL_AMT';
                                ls_col2 :=  'BILL_AMT';
                                ls_col3 :=  'SUM_BILL_AMT2';
                                ls_col4 :=  'BILL_AMT2';
                                ls_alias  :=  'R_SUM_BILL_AMT';
                             WHEN PSV_MODE = 'G' THEN
                                ls_col1 :=  'BILL_AMT';
                                ls_col2 :=  'BILL_AMT';
                                ls_col3 :=  'BILL_AMT2';
                                ls_col4 :=  'BILL_AMT2';
                                ls_alias  :=  'R_BILL_AMT';
                             ELSE
                                ls_col1 :=  'BILL_AMT';
                                ls_col2 :=  'BILL_AMT';
                                ls_col3 :=  'BILL_AMT2';
                                ls_col4 :=  'BILL_AMT2';
                                ls_alias  :=  'R_BILL_AMT';
                        END CASE;
                        SP_GET_VALUE_03 ( ls_col1 ,ls_col2, ls_col3, ls_col4,  ls_val_up ,ls_val_gr_up, ls_val_up2 ,ls_val_gr_up2 );
                        ls_ct_val     := ' SUM(R_BILL_AMT) R_BILL_AMT ' ;
                    WHEN '10' THEN
                       CASE WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'G' THEN
                                ls_col1 :=  'SUM_CUST_CNT';
                                ls_col2 :=  'CUST_CNT';
                                ls_col3 :=  'SUM_CUST_CNT2';
                                ls_col4 :=  'CUST_CNT2';
                                ls_alias  :=  'R_SUM_CUST_CNT';
                             WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'N' THEN
                                ls_col1 :=  'SUM_CUST_CNT';
                                ls_col2 :=  'CUST_CNT';
                                ls_col3 :=  'SUM_CUST_CNT2';
                                ls_col4 :=  'CUST_CNT2';
                                ls_alias  :=  'R_SUM_CUST_CNT';
                             WHEN PSV_MODE = 'G' THEN
                                ls_col1 :=  'CUST_CNT';
                                ls_col2 :=  'CUST_CNT';
                                ls_col3 :=  'CUST_CNT2';
                                ls_col4 :=  'CUST_CNT2';
                                ls_alias  :=  'R_CUST_CNT';
                             ELSE
                                ls_col1 :=  'CUST_CNT';
                                ls_col2 :=  'CUST_CNT';
                                ls_col3 :=  'CUST_CNT2';
                                ls_col4 :=  'CUST_CNT2';
                                ls_alias  :=  'R_CUST_CNT';
                       END CASE;
                       SP_GET_VALUE_03 ( ls_col1 ,ls_col2, ls_col3, ls_col4,  ls_val_up ,ls_val_gr_up, ls_val_up2 ,ls_val_gr_up2 );
                       ls_ct_val     := ' SUM(R_CUST_CNT) R_CUST_CNT ' ;
                    WHEN '11' THEN
                       CASE WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'G' THEN
                                ls_col1 :=  'SUM_CUST_AMT';
                                ls_col2 :=  'CUST_AMT';
                                ls_col3 :=  'SUM_CUST_AMT2';
                                ls_col4 :=  'CUST_AMT2';
                                ls_alias  :=  'R_SUM_CUST_AMT';
                             WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'N' THEN
                                ls_col1 :=  'SUM_CUST_AMT';
                                ls_col2 :=  'CUST_AMT';
                                ls_col3 :=  'SUM_CUST_AMT2';
                                ls_col4 :=  'CUST_AMT2';
                                ls_alias  :=  'R_SUM_CUST_AMT';
                             WHEN PSV_MODE = 'G' THEN
                                ls_col1 :=  'CUST_AMT';
                                ls_col2 :=  'CUST_AMT';
                                ls_col3 :=  'CUST_AMT2';
                                ls_col4 :=  'CUST_AMT2';
                                ls_alias  :=  'R_CUST_AMT';
                             ELSE
                                ls_col1 :=  'CUST_AMT';
                                ls_col2 :=  'CUST_AMT2';
                                ls_alias  :=  'R_CUST_AMT';
                       END CASE;
                       SP_GET_VALUE_03 ( ls_col1 ,ls_col2, ls_col3, ls_col4,  ls_val_up ,ls_val_gr_up, ls_val_up2 ,ls_val_gr_up2 );
                       ls_ct_val     := ' SUM(R_CUST_AMT)  R_CUST_AMT ' ;
                    WHEN '12' THEN
                       CASE  WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'G' THEN
                                ls_col1 :=  'SUM_STOR_CNT';
                                ls_col2 :=  'STOR_CNT';
                                ls_col3 :=  'SUM_STOR_CNT2';
                                ls_col4 :=  'STOR_CNT2';
                                ls_alias  :=  'R_SUM_STOR_CNT';
                             WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'N' THEN
                                ls_col1 :=  'SUM_STOR_CNT';
                                ls_col2 :=  'STOR_CNT';
                                ls_col3 :=  'SUM_STOR_CNT2';
                                ls_col4 :=  'STOR_CNT2';
                                ls_alias  :=  'R_SUM_STOR_CNT';
                             WHEN PSV_MODE = 'G' THEN
                                ls_col1 :=  'STOR_CNT';
                                ls_col2 :=  'STOR_CNT';
                                ls_col3 :=  'STOR_CNT2';
                                ls_col4 :=  'STOR_CNT2';
                                ls_alias  :=  'R_STOR_CNT';
                             ELSE
                                ls_col1 :=  'STOR_CNT';
                                ls_col2 :=  'STOR_CNT';
                                ls_col3 :=  'STOR_CNT2';
                                ls_col4 :=  'STOR_CNT2';
                                ls_alias  :=  'R_STOR_CNT';
                       END CASE;
                       SP_GET_VALUE_03 ( ls_col1 ,ls_col2, ls_col3, ls_col4,  ls_val_up ,ls_val_gr_up, ls_val_up2 ,ls_val_gr_up2 );
                       ls_ct_val     := ' SUM(R_STOR_CNT) R_STOR_CNT ';
                    ELSE
                        ls_col_cd := ' ' ;
                        ls_alias  := ' ' ;
                        ls_ct_val := ' ' ;
                        ls_val_up := ' ' ;
               END CASE;
       WHEN '4' THEN
              CASE PSV_COL_CD
                    WHEN '01' THEN
                        CASE WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'G' THEN
                                ls_col1 :=  'SUM_SALE_QTY';
                                ls_col2 :=  'SUM_SALE_QTY2';
                                ls_alias  :=  'E_SUM_SALE_QTY';
                             WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'N' THEN
                                ls_col1 :=  'SUM_SALE_QTY';
                                ls_col2 :=  'SUM_SALE_QTY2';
                                ls_alias  :=  'E_SUM_SALE_QTY';
                             WHEN PSV_MODE = 'G' THEN
                                ls_col1 :=  'SALE_QTY';
                                ls_col2 :=  'SALE_QTY2';
                                ls_alias  :=  'E_SALE_QTY';
                             ELSE
                                ls_col1 :=  'SALE_QTY';
                                ls_col2 :=  'SALE_QTY2';
                                ls_alias  :=  'E_SALE_QTY';
                        END CASE;
                        SP_GET_VALUE_04 ( ls_col1 ,ls_col2, ls_val_up , ls_val_gr_up );
                        ls_ct_val   := ' SUM(E_SALE_QTY) E_SALE_QTY ' ;
                    WHEN '02' THEN
                        CASE WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'G' THEN
                                ls_col1 :=  'SUM_SALE_AMT';
                                ls_col2 :=  'SUM_SALE_AMT2';
                                ls_alias  :=  'E_SUM_SALE_AMT';
                             WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'N' THEN
                                ls_col1 :=  'SUM_SALE_AMT';
                                ls_col2 :=  'SUM_SALE_AMT2';
                                ls_alias  :=  'E_SUM_SALE_AMT';
                             WHEN PSV_MODE = 'G' THEN
                                ls_col1 :=  'SALE_AMT';
                                ls_col2 :=  'SALE_AMT2';
                                ls_alias  :=  'E_SALE_AMT ';
                             ELSE
                                ls_col1 :=  'SALE_AMT';
                                ls_col2 :=  'SALE_AMT2';
                                ls_alias  :=  'E_SALE_AMT';
                        END CASE;
                        SP_GET_VALUE_04 ( ls_col1 ,ls_col2, ls_val_up ,ls_val_gr_up );
                        ls_ct_val   := ' SUM(E_SALE_AMT) E_SALE_AMT ' ;
                    WHEN '03' THEN
                        CASE WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'G' THEN
                                ls_col1 :=  'SUM_ENR_AMT';
                                ls_col2 :=  'SUM_ENR_AMT2';
                                ls_alias  :=  'E_SUM_ENR_AMT';
                             WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'N' THEN
                                ls_col1 :=  'SUM_ENR_AMT';
                                ls_col2 :=  'SUM_ENR_AMT2';
                                ls_alias  :=  'E_SUM_ENR_AMT';
                             WHEN PSV_MODE = 'G' THEN
                                ls_col1 :=  'ENR_AMT';
                                ls_col2 :=  'ENR_AMT2';
                                ls_alias  :=  'E_ENR_AMT';
                             ELSE
                                ls_col1 :=  'ENR_AMT';
                                ls_col2 :=  'ENR_AMT2';
                                ls_alias  :=  'E_ENR_AMT';
                        END CASE;
                        SP_GET_VALUE_04 ( ls_col1 ,ls_col2, ls_val_up ,ls_val_gr_up );
                        ls_ct_val   := ' SUM(E_ENR_AMT)E_ENR_AMT ' ;
                    WHEN '04' THEN
                        CASE WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'G' THEN
                                ls_col1 :=  'SUM_GRD_AMT';
                                ls_col2 :=  'SUM_GRD_AMT2';
                                ls_alias  :=  'E_SUM_GRD_AMT';
                             WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'N' THEN
                                ls_col1 :=  'SUM_GRD_AMT';
                                ls_col2 :=  'SUM_GRD_AMT2';
                                ls_alias  :=  'E_SUM_GRD_AMT';
                             WHEN PSV_MODE = 'G' THEN
                                ls_col1 :=  'GRD_AMT';
                                ls_col2 :=  'GRD_AMT2';
                                ls_alias  :=  'E_GRD_AMT';
                             ELSE
                                ls_col1 :=  'GRD_AMT';
                                ls_col2 :=  'GRD_AMT2';
                                ls_alias  :=  'E_GRD_AMT';
                        END CASE;
                        SP_GET_VALUE_04 ( ls_col1 ,ls_col2, ls_val_up ,ls_val_gr_up );
                        ls_ct_val   := ' SUM(E_GRD_AMT) E_GRD_AMT ' ;
                    
                    WHEN '05' THEN
                        CASE WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'G' THEN
                                ls_col1 :=  'SUM_NET_AMT';
                                ls_col2 :=  'SUM_NET_AMT2';
                                ls_alias  :=  'E_SUM_NET_AMT';
                             WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'N' THEN
                                ls_col1 :=  'SUM_NET_AMT';
                                ls_col2 :=  'SUM_NET_AMT2';
                                ls_alias  :=  'E_SUM_NET_AMT';
                             WHEN PSV_MODE = 'G' THEN
                                ls_col1 :=  'NET_AMT';
                                ls_col2 :=  'NET_AMT2';
                                ls_alias  :=  'E_NET_AMT';
                             ELSE
                                ls_col1 :=  'NET_AMT';
                                ls_col2 :=  'NET_AMT2';
                                ls_alias  :=  'E_NET_AMT';
                        END CASE;
                        SP_GET_VALUE_04 ( ls_col1 ,ls_col2, ls_val_up ,ls_val_gr_up );
                        ls_ct_val   := ' SUM(E_NET_AMT) E_NET_AMT ' ;
                        
                    WHEN '06' THEN
                        CASE WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'G' THEN
                                ls_col1 :=  'SUM_GRD_I_AMT';
                                ls_col2 :=  'SUM_GRD_I_AMT2';
                                ls_alias  :=  'RE_SUM_GRD_I_AMT';
                             WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'N' THEN
                                ls_col1 :=  'SUM_GRD_I_AMT';
                                ls_col2 :=  'SUM_GRD_I_AMT2';
                                ls_alias  :=  'E_SUM_GRD_I_AMT';
                             WHEN PSV_MODE = 'G' THEN
                                ls_col1 :=  'GRD_I_AMT';
                                ls_col2 :=  'GRD_I_AMT2';
                                ls_alias  :=  'E_GRD_I_AMT';
                             ELSE
                                ls_col1 :=  'GRD_I_AMT';
                                ls_col2 :=  'GRD_I_AMT2';
                                ls_alias  :=  'E_GRD_I_AMT';
                        END CASE;
                        SP_GET_VALUE_04 ( ls_col1 ,ls_col2, ls_val_up ,ls_val_gr_up );
                        ls_ct_val   := ' SUM(E_GRD_I_AMT) E_GRD_I_AMT ' ;
                    WHEN '07' THEN
                        CASE WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'G' THEN
                                ls_col1 :=  'SUM_GRD_O_AMT';
                                ls_col2 :=  'SUM_GRD_O_AMT2';
                                ls_alias  :=  'E_SUM_GRD_O_AMT';
                             WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'N' THEN
                                ls_col1 :=  'SUM_GRD_O_AMT';
                                ls_col2 :=  'SUM_GRD_O_AMT2';
                                ls_alias  :=  'E_SUM_GRD_O_AMT';
                             WHEN PSV_MODE = 'G' THEN
                                ls_col1 :=  'GRD_O_AMT';
                                ls_col2 :=  'GRD_O_AMT2';
                                ls_alias  :=  'E_GRD_O_AMT';
                             ELSE
                                ls_col1 :=  'GRD_O_AMT';
                                ls_col2 :=  'GRD_O_AMT2';
                                ls_alias  :=  'E_GRD_O_AMT';
                        END CASE;
                        SP_GET_VALUE_04 ( ls_col1 ,ls_col2, ls_val_up ,ls_val_gr_up);
                        ls_ct_val   := ' SUM(E_GRD_O_AMT) E_GRD_O_AMT ' ;
                    WHEN '08' THEN
                        CASE WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'G' THEN
                                ls_col1 :=  'SUM_BILL_CNT';
                                ls_col2 :=  'SUM_BILL_CNT2';
                                ls_alias  :=  'E_SUM_BILL_CNT';
                             WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'N' THEN
                                ls_col1 :=  'SUM_BILL_CNT';
                                ls_col2 :=  'SUM_BILL_CNT2';
                                ls_alias  :=  'E_SUM_BILL_CNT';
                             WHEN PSV_MODE = 'G' THEN
                                ls_col1 :=  'BILL_CNT';
                                ls_col2 :=  'BILL_CNT2';
                                ls_alias  :=  'E_BILL_CNT';
                             ELSE
                                ls_col1 :=  'BILL_CNT';
                                ls_col2 :=  'BILL_CNT2';
                                ls_alias  :=  'E_BILL_CNT';
                        END CASE;
                        SP_GET_VALUE_04 ( ls_col1 ,ls_col2, ls_val_up ,ls_val_gr_up);
                        ls_ct_val   := ' SUM(E_BILL_CNT) E_BILL_CNT ' ;
                    WHEN '09' THEN
                        CASE WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'G' THEN
                                ls_col1 :=  'SUM_BILL_AMT';
                                ls_col2 :=  'SUM_BILL_AMT2';
                                ls_alias  :=  'E_SUM_BILL_AMT';
                             WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'N' THEN
                                ls_col1 :=  'SUM_BILL_AMT';
                                ls_col2 :=  'SUM_BILL_AMT2';
                                ls_alias  :=  'E_SUM_BILL_AMT';
                             WHEN PSV_MODE = 'G' THEN
                                ls_col1 :=  'BILL_AMT';
                                ls_col2 :=  'BILL_AMT2';
                                ls_alias  :=  'E_BILL_AMT';
                             ELSE
                                ls_col1 :=  'BILL_AMT';
                                ls_col2 :=  'BILL_AMT2';
                                ls_alias  :=  'E_BILL_AMT';
                        END CASE;
                        SP_GET_VALUE_04 ( ls_col1 ,ls_col2, ls_val_up ,ls_val_gr_up);
                        ls_ct_val     := ' SUM(E_BILL_AMT) E_BILL_AMT ' ;
                    WHEN '10' THEN
                       CASE WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'G' THEN
                                ls_col1 :=  'SUM_CUST_CNT';
                                ls_col2 :=  'SUM_CUST_CNT2';
                                ls_alias  :=  'E_SUM_CUST_CNT';
                             WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'N' THEN
                                ls_col1 :=  'SUM_CUST_CNT';
                                ls_col2 :=  'SUM_CUST_CNT2';
                                ls_alias  :=  'E_SUM_CUST_CNT';
                             WHEN PSV_MODE = 'G' THEN
                                ls_col1 :=  'CUST_CNT';
                                ls_col2 :=  'CUST_CNT2';
                                ls_alias  :=  'E_CUST_CNT';
                             ELSE
                                ls_col1 :=  'CUST_CNT';
                                ls_col2 :=  'CUST_CNT2';
                                ls_alias  :=  'E_CUST_CNT';
                       END CASE;
                       SP_GET_VALUE_04 ( ls_col1 ,ls_col2, ls_val_up ,ls_val_gr_up );
                       ls_ct_val     := ' SUM(E_CUST_CNT) E_CUST_CNT ' ;
                    WHEN '11' THEN
                       CASE WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'G' THEN
                                ls_col1 :=  'SUM_CUST_AMT';
                                ls_col2 :=  'SUM_CUST_AMT2';
                                ls_alias  :=  'E_SUM_CUST_AMT';
                             WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'N' THEN
                                ls_col1 :=  'SUM_CUST_AMT';
                                ls_col2 :=  'SUM_CUST_AMT2';
                                ls_alias  :=  'E_SUM_CUST_AMT';
                             WHEN PSV_MODE = 'G' THEN
                                ls_col1 :=  'CUST_AMT';
                                ls_col2 :=  'CUST_AMT2';
                                ls_alias  :=  'E_CUST_AMT';
                             ELSE
                                ls_col1 :=  'CUST_AMT';
                                ls_col2 :=  'CUST_AMT2';
                                ls_alias  :=  'E_CUST_AMT';
                       END CASE;
                       SP_GET_VALUE_04 ( ls_col1 ,ls_col2, ls_val_up ,ls_val_gr_up );
                       ls_ct_val     := ' SUM(E_CUST_AMT)  E_CUST_AMT ' ;
                    WHEN '12' THEN
                       CASE  WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'G' THEN
                                ls_col1 :=  'SUM_STOR_CNT';
                                ls_col2 :=  'SUM_STOR_CNT2';
                                ls_alias  :=  'E_SUM_STOR_CNT';
                             WHEN PSV_CT_TP = 'CV' AND PSV_MODE = 'N' THEN
                                ls_col1 :=  'SUM_STOR_CNT';
                                ls_col2 :=  'SUM_STOR_CNT2';
                                ls_alias  :=  'E_SUM_STOR_CNT';
                             WHEN PSV_MODE = 'G' THEN
                                ls_col1 :=  'STOR_CNT';
                                ls_col2 :=  'STOR_CNT2';
                                ls_alias  :=  'E_STOR_CNT';
                             ELSE
                                ls_col1 :=  'STOR_CNT';
                                ls_col2 :=  'STOR_CNT2';
                                ls_alias  :=  'E_STOR_CNT';
                       END CASE;
                       SP_GET_VALUE_04 ( ls_col1 ,ls_col2, ls_val_up ,ls_val_gr_up );
                       ls_ct_val     := ' SUM(E_STOR_CNT) E_STOR_CNT ';
                    ELSE
                        ls_col_cd := ' ' ;
                        ls_alias  := ' ' ;
                        ls_ct_val := ' ' ;
                        ls_val_up := ' ' ;
               END CASE;
       END CASE ;

       PSR_VAL          := ls_col_cd;
       PSR_ALIAS        := ls_alias ;
       PSR_CT_VAL       := ls_ct_val;
       PSR_VAL_UP       := ls_val_up;
       PSR_VAL_UP2      := ls_val_up2;
       PSR_VAL_GR_UP    := ls_val_gr_up;
       PSR_VAL_GR_UP2   := ls_val_gr_up2;

   END;

   FUNCTION F_COLUMN
    ( PSV_TABLE     IN VARCHAR2,
      PSV_COL_CD    IN VARCHAR2
    ) RETURN VARCHAR2 IS
      ls_col_cd     VARCHAR2(100) ;
   BEGIN
       CASE PSV_COL_CD
            WHEN '10' THEN
                ls_col_cd :=  'B.BRAND_CLASS ';
            WHEN '11' THEN
                ls_col_cd :=  'S.BRAND_CD ';
            WHEN '12' THEN
                ls_col_cd :=  'S.STOR_TP ';
            WHEN '13' THEN
                ls_col_cd :=  'NVL(S.TRAD_AREA, ''99'')';
            WHEN '14' THEN
                ls_col_cd :=  'NVL(S.SIDO_CD, ''999'')';
            WHEN '15' THEN
                ls_col_cd :=  'NVL(S.REGION_CD, ''999999'')';
            WHEN '16' THEN
                ls_col_cd :=  'NVL(S.DEPT_CD, ''9999999999'')';
            WHEN '17' THEN
                ls_col_cd :=  'NVL(S.TEAM_CD, ''9999999999'')';
            WHEN '18' THEN
                ls_col_cd :=  'NVL(S.SV_USER_ID, ''9999999999'')';
            WHEN '19' THEN
                ls_col_cd :=  'S.STOR_CD ';
            WHEN '20' THEN
                ls_col_cd :=  'S.CLOSE_DT ';
            WHEN '21' THEN
                ls_col_cd :=  'NVL(C.L_CLASS_CD, ''999'')';
            WHEN '22' THEN
                ls_col_cd :=  'NVL(C.M_CLASS_CD, ''99999'')';
            WHEN '23' THEN
                ls_col_cd :=  'NVL(C.S_CLASS_CD, ''9999999'')';
            WHEN '24' THEN
                ls_col_cd :=  'I.ITEM_CD ';
            WHEN '25' THEN
                ls_col_cd :=  'I.ITEM_DIV ';
            WHEN '31' THEN
                ls_col_cd :=  'NVL(S.DSTN_COMP, ''9999999999'')';
            WHEN '61' THEN -- BR �ܵ�(��Ǵ�з�)
                ls_col_cd :=  'S.TRAD_L_AREA ';
            WHEN '62' THEN -- BR �ܵ�(����ߺз�)
                ls_col_cd :=  'S.TRAD_M_AREA ';
            WHEN '63' THEN -- BR �ܵ�(��ǼҺз�)
                ls_col_cd :=  'S.TRAD_S_AREA ';
            WHEN '27' THEN
                ls_col_cd :=  'I.ITEM_CD ';
            WHEN '50' THEN
                ls_col_cd :=  ' (S.BRAND_CD, S.STOR_CD) ';
            WHEN '60' THEN
                ls_col_cd :=  ' (I.ITEM_CD) ';
       END CASE;

        RETURN ls_col_cd;
   END;

  FUNCTION F_REF_COMMON
    ( PSV_COMP      IN  VARCHAR2
     ,PSV_LANG_CD   IN  VARCHAR2
     ,PSV_COMMON_TP IN  VARCHAR2
    ) RETURN VARCHAR2 IS
      ls_sql_common     VARCHAR2(3000) ;
   BEGIN
      ls_sql_common :=
            ' ( SELECT C.COMP_CD, C.CODE_CD, NVL(L.CODE_NM,C.CODE_NM) CODE_NM, C.SORT_SEQ, C.ACC_CD, C.VAL_D1, C.VAL_D2, C.VAL_C1, C.VAL_C2, C.VAL_C3, C.VAL_C4, C.VAL_C5, C.VAL_N1, C.VAL_N2 '
        ||  '   FROM COMMON C, LANG_COMMON L  '
        ||  '  WHERE C.COMP_CD = L.COMP_CD(+) ' -- ASP
        ||  '    AND C.CODE_CD = L.CODE_CD(+) '
        ||  '    AND C.CODE_TP = '''
        ||  PSV_COMMON_TP || ''' '
        ||  '    AND C.COMP_CD = '''            -- ASP
        ||  PSV_COMP      || ''' '
        ||  q'[  AND C.USE_YN  = 'Y' ]'
        ||  '    AND C.CODE_TP = L.CODE_TP(+) '
        ||  '    AND L.LANGUAGE_TP(+) = '''
        ||  PSV_LANG_CD || '''' 
        ||  q'[  AND L.USE_YN(+) = 'Y' ) ]'  ;
       RETURN ls_sql_common;
   END;

    FUNCTION F_AUTH
    ( PSV_USER        IN  VARCHAR2
    ) RETURN VARCHAR2 IS
      ls_auth     VARCHAR2(3000) ;
   BEGIN
       ls_auth := ' ( '
               || ' EXISTS ( SELECT 1 FROM STORE_USER '
               || ' WHERE  USE_YN = ''Y'' AND USER_ID = '''
               || PSV_USER
               || ''' ) '
               || ' OR '
               || ' S.BRAND_CD IN ( SELECT BRAND_CD FROM USER_AUTH '
               || ' WHERE USE_YN = ''Y'' AND AUTH_LEVEL = ''10'' AND USER_ID = '''
               || PSV_USER
               || ''' ) '
               || ' OR '
               || ' S.DEPT_CD IN ( SELECT AUTH_DEPT_CD FROM USER_AUTH '
               || ' WHERE USE_YN = ''Y'' AND AUTH_LEVEL = ''20'' AND USER_ID = '''
               || PSV_USER
               || ''' ) '
               || ' OR '
               || ' S.TEAM_CD IN ( SELECT AUTH_TEAM_CD FROM USER_AUTH '
               || ' WHERE USE_YN = ''Y'' AND AUTH_LEVEL = ''30'' AND USER_ID = '''
               || PSV_USER
               || ''' ) '
               || ' OR '
               || ' S.SV_USER_ID IN ( SELECT AUTH_SV_USER_ID FROM USER_AUTH '
               || ' WHERE USE_YN = ''Y'' AND AUTH_LEVEL = ''40'' AND USER_ID = '''
               || PSV_USER
               || ''' ) '
               || ' OR '
               || ' S.STOR_CD IN ( SELECT AUTH_STOR_CD FROM USER_AUTH '
               || ' WHERE USE_YN = ''Y'' AND AUTH_LEVEL = ''50'' AND USER_ID = '''
               || PSV_USER
               || ''' ) ) ' ;
       RETURN ls_auth;
   END;

  PROCEDURE RPT_PARA
            (PSV_COMP        IN  VARCHAR2 -- ASP
            ,PSV_USER        IN  VARCHAR2
            ,PSV_PGM_ID      IN  VARCHAR2
            ,PSV_LANG_CD     IN  VARCHAR2
            ,PSV_ORG_CLASS   IN  VARCHAR2
            ,PSV_PARA        IN  VARCHAR2
            ,PSV_FILTER      IN  VARCHAR2
            ,PSR_STORE       OUT VARCHAR2
            ,PSR_ITEM        OUT VARCHAR2
            ,PSR_DATE1       OUT VARCHAR2
            ,PSR_EX_DATE1    OUT VARCHAR2
            ,PSR_DATE2       OUT VARCHAR2
            ,PSR_EX_DATE2    OUT VARCHAR2
            ) IS
       ltr_para             TBL_PARA;
       li_store_cnt         PLS_INTEGER := 0 ;
       li_item_cnt          PLS_INTEGER := 0 ;
       li_store_flag_cnt    PLS_INTEGER := 0 ;
       li_item_flag_cnt     PLS_INTEGER := 0 ;
       li_array             PLS_INTEGER ;
       ls_where_part        VARCHAR2(20000);
       ls_where_store       VARCHAR2(20000);
       ls_where_item        VARCHAR2(20000);
       ls_sql_store         VARCHAR2(20000);
       ls_sql_item          VARCHAR2(20000);
       ls_table             VARCHAR2(50);
       ls_date1             VARCHAR2(2000);
       ls_date2             VARCHAR2(2000);
       ls_ex_date1          VARCHAR2(2000);
       ls_ex_date2          VARCHAR2(2000);
       ls_org_class         ITEM_CLASS.ORG_CLASS_CD%TYPE;
   BEGIN
       
        IF PSV_PARA IS NOT NULL THEN
            ltr_para := F_PARA_PARSING(PSV_PARA);
            li_array :=  ltr_para.LAST;
            FOR idx IN 1..li_array
            LOOP
                CASE ltr_para(idx).TABLE_CD
                    WHEN 'STORE'      THEN
                        li_store_cnt := li_store_cnt + 1;
                        ls_table     := 'S';
                    WHEN 'STORE_FLAG' THEN
                        li_store_flag_cnt := li_store_flag_cnt + 1;
                        ls_table     := 'SF' || TO_CHAR(li_store_flag_cnt);
                    WHEN 'ITEM'       THEN
                        li_item_cnt  := li_item_cnt + 1;
                        ls_table     := 'I';
                    WHEN 'ITEM_FLAG'  THEN
                        li_item_flag_cnt := li_item_flag_cnt + 1;
                        ls_table     := 'IF' || TO_CHAR(li_item_flag_cnt);
                    WHEN 'LOGIN'      THEN -- [H:����, S:����]
                        P_EMP_FLAG   := ltr_para(idx).FR_DATA;
                        BEGIN
                            SELECT DECODE(P_EMP_FLAG, 'H', NVL(VAL_N1, 0), NVL(VAL_N2, 0))
                              INTO P_DATE_LMT
                              FROM COMMON
                             WHERE COMP_CD = PSV_COMP -- ASP
                               AND CODE_TP = '01435'
                               AND CODE_CD = '210';
                            EXCEPTION
                                WHEN OTHERS THEN
                                    P_DATE_LMT := 0;
                        END;
                    ELSE
                        NULL;
                END CASE;

                IF ltr_para(idx).TABLE_CD <> 'DATE' THEN
                    ls_where_part := f_column ( ls_table, ltr_para(idx).COL_CD ) ;
                END IF;

                CASE
                    WHEN ltr_para(idx).COL_CD = '01' AND ltr_para(idx).SEL_TP = 'I' THEN
                        ls_date1      := f_where_op (  ltr_para(idx) ) ;
                    WHEN ltr_para(idx).COL_CD = '01' AND ltr_para(idx).SEL_TP = 'E' THEN
                        ls_ex_date1   := f_where_op (  ltr_para(idx) ) ;
                    WHEN ltr_para(idx).COL_CD = '02' AND ltr_para(idx).SEL_TP = 'I' THEN
                        ls_date2      := f_where_op (  ltr_para(idx) ) ;
                    WHEN ltr_para(idx).COL_CD = '02' AND ltr_para(idx).SEL_TP = 'E' THEN
                        ls_ex_date2   := f_where_op (  ltr_para(idx) ) ;
                    ELSE
                        ls_where_part := ls_where_part || f_where_op (  ltr_para(idx) ) ;
                END CASE;

                IF    ltr_para(idx).TABLE_CD  IN ( 'STORE', 'STORE_FLAG' ) THEN
                    ls_where_store := ls_where_store  || ' AND '
                                   || ls_where_part;
                ELSIF ltr_para(idx).TABLE_CD  IN ( 'ITEM',  'ITEM_FLAG'  ) THEN
                    ls_where_item  := ls_where_item   || ' AND '
                                    || ls_where_part;
                END IF;

            END LOOP;
        
        END IF;
        
        ls_sql_store := ' S_STORE AS ( '
                      || ' SELECT S.COMP_CD,S.BRAND_CLASS,S.BRAND_CD,B.BRAND_NM,S.STOR_CD,S.STOR_NM,S.USE_YN,' -- ASP
                      || ' S.STOR_TP,CM1.CODE_NM STOR_TP_NM,'
                      || ' S.SIDO_CD,NVL(CM2.CODE_NM,FC_GET_WORDPACK(''' || PSV_COMP || ''',''' || PSV_LANG_CD || ''',''UNCLASSIFY'')) SIDO_NM,' -- ASP
                      || ' S.REGION_CD,NVL(R.REGION_NM,FC_GET_WORDPACK(''' || PSV_COMP || ''',''' || PSV_LANG_CD || ''',''UNCLASSIFY'')) REGION_NM,' -- ASP
                      || ' S.TRAD_AREA,NVL(CM3.CODE_NM,FC_GET_WORDPACK(''' || PSV_COMP || ''',''' || PSV_LANG_CD || ''',''UNCLASSIFY'')) TRAD_AREA_NM,' -- ASP
                      || ' S.DEPT_CD,NVL(CM4.CODE_NM,FC_GET_WORDPACK(''' || PSV_COMP || ''',''' || PSV_LANG_CD || ''',''UNCLASSIFY'')) DEPT_NM,' -- ASP
                      || ' S.TEAM_CD,NVL(CM5.CODE_NM,FC_GET_WORDPACK(''' || PSV_COMP || ''',''' || PSV_LANG_CD || ''',''UNCLASSIFY'')) TEAM_NM,' -- ASP
                      || ' S.SV_USER_ID,NVL(U.USER_NM,FC_GET_WORDPACK(''' || PSV_COMP || ''',''' || PSV_LANG_CD || ''',''UNCLASSIFY'')) SV_USER_NM,S.BUSI_NO,S.REP_STOR_CD,S.TABLE_NO,S.SEAT,S.OPEN_DT,'
                      || ' S.DSTN_COMP,NVL(D.STOR_NM,FC_GET_WORDPACK(''' || PSV_COMP || ''',''' || PSV_LANG_CD || ''',''UNCLASSIFY'')) DSTN_COMP_NM'
                      || ' FROM'
                      || ' ('
                      || ' SELECT'
                      || ' S.COMP_CD,B.BRAND_CLASS,S.BRAND_CD,S.STOR_CD,NVL(L.STOR_NM,S.STOR_NM) STOR_NM,' -- ASP
                      || ' S.STOR_TP,NVL(S.SIDO_CD,''999'') SIDO_CD,NVL(S.REGION_CD,''999999'') REGION_CD,NVL(S.TRAD_AREA,''99'') TRAD_AREA,S.USE_YN,NVL(S.DEPT_CD,''9999999999'') DEPT_CD,NVL(S.TEAM_CD,''9999999999'') TEAM_CD,NVL(S.SV_USER_ID,''9999999999'') SV_USER_ID,S.BUSI_NO,'
                      || ' S.REP_STOR_CD,S.TABLE_NO,S.SEAT,S.OPEN_DT,S.DSTN_COMP'
                      || ' FROM STORE S,LANG_STORE L,BRAND B' ;

        /*
        FOR idx IN i..li_store_flag_cnt
        LOOP
           ls_sql_store := ls_sql_store || ', STORE_FLAG SF' TO_CHAR(idx) ;
        END LOOP;
        */

        ls_sql_store := ls_sql_store
                     || ' WHERE S.COMP_CD=L.COMP_CD(+)' -- ASP
                     || ' AND S.BRAND_CD=L.BRAND_CD(+)'
                     || ' AND S.STOR_CD=L.STOR_CD(+)'
                     || ' AND S.COMP_CD=B.COMP_CD'
                     || ' AND S.BRAND_CD=B.BRAND_CD'
                     || ' AND L.LANGUAGE_TP(+)='''
                     || PSV_LANG_CD
                     || ''' AND S.COMP_CD='''             -- ASP
                     || PSV_COMP
                     || ''' ';

        -- ����
        ls_sql_store := ls_sql_store || ' AND ' || f_auth( PSV_USER ) ;
        ls_sql_store := ls_sql_store || ls_where_store || ') S , ' ;
        -- B:��������, CM1:��/����(00590), CM2:�õ�(00590), R:����
        -- CM3:���(00595), CM4:�μ�(00600), CM5:��(00605), U:SV
        -- CM6:��Ǵ�з�(30041), CM7:����ߺз�(30042), CM8:��ǼҺз�(30043)
        -- CM9:�����׷�1(30044), CM10:�����׷�2(30045)
        ls_sql_store := ls_sql_store
                      || ' ( '
                      || ' SELECT B1.BRAND_CD,NVL(B2.LANG_NM,B1.BRAND_NM) BRAND_NM'
                      || ' FROM BRAND B1,LANG_TABLE B2'
                      || ' WHERE B1.COMP_CD=B2.COMP_CD(+)' -- ASP
                      || ' AND B2.TABLE_NM(+)=''BRAND'' AND B2.COL_NM(+)=''BRAND_NM'''
                      || ' AND B2.LANGUAGE_TP(+)='''
                      || PSV_LANG_CD
                      || ''' AND B1.COMP_CD='''                 -- ASP
                      || PSV_COMP
                      || ''' AND LPAD(B1.BRAND_CD,4,'' '')=B2.PK_COL(+)) B,'
                      || ' ( '
                      || ' SELECT C1.CODE_CD,NVL(C2.CODE_NM,C1.CODE_NM) CODE_NM'
                      || ' FROM COMMON C1, LANG_COMMON C2'
                      || ' WHERE C1.COMP_CD=C2.COMP_CD(+)'   -- ASP
                      || ' AND C1.CODE_TP=''00565'''
                      || ' AND C1.CODE_TP=C2.CODE_TP(+)'
                      || ' AND C1.CODE_CD=C2.CODE_CD(+)'
                      || ' AND C2.LANGUAGE_TP(+)='''
                      || PSV_LANG_CD
                      || ''' AND C1.COMP_CD='''          -- ASP
                      || PSV_COMP
                      || ''' ) CM1,'
                      || ' ( '
                      || ' SELECT C1.CODE_CD,NVL(C2.CODE_NM,C1.CODE_NM) CODE_NM'
                      || ' FROM COMMON C1, LANG_COMMON C2'
                      || ' WHERE C1.COMP_CD=C2.COMP_CD(+)'   -- ASP
                      || ' AND C1.CODE_TP=''00590'''
                      || ' AND C1.CODE_TP=C2.CODE_TP(+)'
                      || ' AND C1.CODE_CD=C2.CODE_CD(+)'
                      || ' AND C2.LANGUAGE_TP(+)='''
                      || PSV_LANG_CD
                      || ''' AND C1.COMP_CD='''          -- ASP
                      || PSV_COMP
                      || ''' ) CM2,'
                      || ' ( '
                      || ' SELECT C1.CODE_CD,NVL(C2.CODE_NM,C1.CODE_NM) CODE_NM'
                      || ' FROM COMMON C1,LANG_COMMON C2'
                      || ' WHERE C1.COMP_CD=C2.COMP_CD(+)'   -- ASP
                      || ' AND C1.CODE_TP=''00595'''
                      || ' AND C1.CODE_TP=C2.CODE_TP(+)'
                      || ' AND C1.CODE_CD=C2.CODE_CD(+)'
                      || ' AND C2.LANGUAGE_TP(+)='''
                      || PSV_LANG_CD
                      || ''' AND C1.COMP_CD='''          -- ASP
                      || PSV_COMP
                      || ''' ) CM3,'
                      || ' ( '
                      || ' SELECT C1.CODE_CD,NVL(C2.CODE_NM,C1.CODE_NM) CODE_NM'
                      || ' FROM COMMON C1,LANG_COMMON C2'
                      || ' WHERE C1.COMP_CD=C2.COMP_CD(+)'   -- ASP
                      || ' AND C1.CODE_TP=''00600'''
                      || ' AND C1.CODE_TP=C2.CODE_TP(+)'
                      || ' AND C1.CODE_CD=C2.CODE_CD(+)'
                      || ' AND C2.LANGUAGE_TP(+)='''
                      || PSV_LANG_CD
                      || ''' AND C1.COMP_CD='''          -- ASP
                      || PSV_COMP
                      || ''' ) CM4,'
                      || ' ( '
                      || ' SELECT C1.CODE_CD,NVL(C2.CODE_NM,C1.CODE_NM) CODE_NM'
                      || ' FROM COMMON C1,LANG_COMMON C2'
                      || ' WHERE C1.COMP_CD=C2.COMP_CD(+)'   -- ASP
                      || ' AND C1.CODE_TP=''00605'''
                      || ' AND C1.CODE_TP=C2.CODE_TP(+)'
                      || ' AND C1.CODE_CD=C2.CODE_CD(+)'
                      || ' AND C2.LANGUAGE_TP(+)='''
                      || PSV_LANG_CD
                      || ''' AND C1.COMP_CD='''          -- ASP
                      || PSV_COMP
                      || ''' ) CM5,'
                      || ' ( '
                      || ' SELECT R1.CITY_CD,R1.REGION_CD,NVL( R2.LANG_NM, R1.REGION_NM ) REGION_NM'
                      || ' FROM REGION R1,LANG_TABLE R2'
                      || ' WHERE R1.COMP_CD=R2.COMP_CD(+)' -- ASP
                      || ' AND R2.TABLE_NM(+)=''REGION'' AND R2.COL_NM(+)=''REGION_NM'''
                      || ' AND R2.LANGUAGE_TP(+)='''
                      || PSV_LANG_CD
                      || ''' AND R1.COMP_CD='''                 -- ASP
                      || PSV_COMP
                      || ''' AND R1.NATION_CD||R1.CITY_CD||R1.REGION_CD=R2.PK_COL(+)) R,'
                      || ' (SELECT U.COMP_CD,U.USER_ID,NVL(L.LANG_NM,U.USER_NM) USER_NM'
                      || ' FROM HQ_USER U,LANG_TABLE L'
                      || ' WHERE U.COMP_CD=L.COMP_CD(+)'
                      || ' AND LPAD(U.USER_ID,10,'' '')=L.PK_COL(+)'
                      || ' AND U.COMP_CD='''||PSV_COMP||''''
                      || ' AND L.LANGUAGE_TP(+)='''||PSV_LANG_CD||''''
                      || ' AND L.USE_YN(+)=''Y'''
                      || ' ) U, ' 
                      || ' ( SELECT S.STOR_CD,NVL(L.STOR_NM,S.STOR_NM) STOR_NM'
                      || ' FROM STORE S,LANG_STORE L'
                      || ' WHERE S.COMP_CD=L.COMP_CD(+)'
                      || ' AND S.BRAND_CD=L.BRAND_CD(+)'
                      || ' AND S.STOR_CD=L.STOR_CD(+)'
                      || ' AND S.COMP_CD='''||PSV_COMP||''''
                      || ' AND S.BRAND_CD=''0000'''
                      || ' AND L.LANGUAGE_TP(+)='''||PSV_LANG_CD||''''
                      || ' AND L.USE_YN(+)=''Y'''
                      || ' ) D'
                      ;

         ls_sql_store := ls_sql_store
                      || ' WHERE S.BRAND_CD=B.BRAND_CD(+)'
                      || ' AND S.STOR_TP=CM1.CODE_CD(+)'
                      || ' AND S.SIDO_CD=CM2.CODE_CD(+)'
                      || ' AND S.TRAD_AREA=CM3.CODE_CD(+)'
                      || ' AND S.DEPT_CD=CM4.CODE_CD(+)'
                      || ' AND S.TEAM_CD=CM5.CODE_CD(+)'
                      || ' AND S.SV_USER_ID=U.USER_ID(+)'
                      || ' AND S.DSTN_COMP=D.STOR_CD(+)'
                      || ' AND U.COMP_CD(+)=''' || PSV_COMP || ''''
                      || ' AND S.SIDO_CD=R.CITY_CD(+)'
                      || ' AND S.REGION_CD=R.REGION_CD(+)';

         ls_sql_store := ls_sql_store
                      || ' ) ' ;

         --
         -- S_ITEM  SQL Creation
         --
         ls_org_class := NVL(PSV_ORG_CLASS, '00') ;

         ls_sql_item  := ' S_ITEM AS ('
                      || ' SELECT I.COMP_CD,I.BRAND_CD,I.ITEM_CD,I.REP_ITEM_CD,I.SALE_PRC,' -- ASP
                      || ' I.ITEM_NM,I.STANDARD,I.SALE_START_DT,I.SALE_CLOSE_DT,I.L_CLASS_CD,I.M_CLASS_CD,I.S_CLASS_CD,'
                      || ' NVL(IC1.L_CLASS_NM,FC_GET_WORDPACK(''' || PSV_COMP || ''',''' || PSV_LANG_CD || ''',''UNCLASSIFY'')) L_CLASS_NM,' -- ASP
                      || ' NVL(IC2.M_CLASS_NM,FC_GET_WORDPACK(''' || PSV_COMP || ''',''' || PSV_LANG_CD || ''',''UNCLASSIFY'')) M_CLASS_NM,' -- ASP
                      || ' NVL(IC3.S_CLASS_NM,FC_GET_WORDPACK(''' || PSV_COMP || ''',''' || PSV_LANG_CD || ''',''UNCLASSIFY'')) S_CLASS_NM,' -- ASP
                      || ' IC1.SORT_ORDER L_SORT_ORDER,IC2.SORT_ORDER M_SORT_ORDER,IC3.SORT_ORDER S_SORT_ORDER,'
                      || ' I.ORD_UNIT,IC6.ORD_UNIT_NM,'
                      || ' I.SALE_UNIT,IC7.SALE_UNIT_NM,'
                      || ' I.STOCK_UNIT,IC8.STOCK_UNIT_NM,'
                      || ' I.DO_UNIT,IC9.DO_UNIT_NM,I.WEIGHT_UNIT,I.VENDOR_CD,I.SET_DIV,'
                      || ' I.COST_VAT_YN,I.COST_VAT_RULE,I.COST_VAT_RATE,I.SERVICE_ITEM_YN,'
                      || ' I.REP_ITEM_NM, I.REP_SALE_PRC, I.REP_L_CLASS_CD, I.REP_L_CLASS_NM, I.REP_M_CLASS_CD, I.REP_M_CLASS_NM, I.REP_S_CLASS_CD, I.REP_S_CLASS_NM,'
                      || ' I.REP_L_SORT_ORDER, I.REP_M_SORT_ORDER, I.REP_S_SORT_ORDER '
                      || ' FROM'
                      || ' ('
                      || ' SELECT I.COMP_CD,I.BRAND_CD,I.ITEM_CD,I.REP_ITEM_CD,I.SALE_PRC,' -- ASP
                      || ' NVL(L.ITEM_NM,I.ITEM_NM) ITEM_NM,I.STANDARD,I.SALE_START_DT,I.SALE_CLOSE_DT,'
                      || ' NVL(C.L_CLASS_CD,''999'') L_CLASS_CD,NVL(C.M_CLASS_CD,''99999'') M_CLASS_CD,NVL(C.S_CLASS_CD,''9999999'') S_CLASS_CD,I.ORD_UNIT,I.SALE_UNIT,I.STOCK_UNIT,I.DO_UNIT,I.WEIGHT_UNIT,I.VENDOR_CD,I.SET_DIV,'
                      || ' I.COST_VAT_YN,I.COST_VAT_RULE,I.COST_VAT_RATE,I.SERVICE_ITEM_YN,'
                      || ' V.REP_ITEM_NM, V.REP_SALE_PRC, V.REP_L_CLASS_CD, V.REP_L_CLASS_NM, V.REP_M_CLASS_CD, V.REP_M_CLASS_NM, V.REP_S_CLASS_CD, V.REP_S_CLASS_NM,'
                      || ' V.REP_L_SORT_ORDER, V.REP_M_SORT_ORDER, V.REP_S_SORT_ORDER '
                      || ' FROM ITEM I,ITEM_CLASS C,LANG_ITEM L,'
                      || '(SELECT W01.COMP_CD REP_COMP_CD, W01.ITEM_CD REP_ITEM_CD, W01.ITEM_NM REP_ITEM_NM, W01.SALE_PRC REP_SALE_PRC,'
                      || ' NVL(W01.L_CLASS_CD,''999''    ) REP_L_CLASS_CD, '
                      || ' NVL(WC1.L_CLASS_NM,FC_GET_WORDPACK(''' || PSV_COMP || ''',''' || PSV_LANG_CD || ''',''UNCLASSIFY'')) REP_L_CLASS_NM,' -- ASP
                      || ' NVL(W01.M_CLASS_CD,''99999''  ) REP_M_CLASS_CD, '
                      || ' NVL(WC2.M_CLASS_NM,FC_GET_WORDPACK(''' || PSV_COMP || ''',''' || PSV_LANG_CD || ''',''UNCLASSIFY'')) REP_M_CLASS_NM,' -- ASP
                      || ' NVL(W01.S_CLASS_CD,''9999999'') REP_S_CLASS_CD, '
                      || ' NVL(WC3.S_CLASS_NM,FC_GET_WORDPACK(''' || PSV_COMP || ''',''' || PSV_LANG_CD || ''',''UNCLASSIFY'')) REP_S_CLASS_NM,' -- ASP
                      || ' WC1.SORT_ORDER REP_L_SORT_ORDER, WC2.SORT_ORDER REP_M_SORT_ORDER, WC3.SORT_ORDER REP_S_SORT_ORDER '
                      || ' FROM ITEM W01, ITEM_CLASS W02, LANG_ITEM W03,        '
                      || ' (SELECT C1.L_CLASS_CD, NVL(C2.LANG_NM, C1.L_CLASS_NM) L_CLASS_NM, C1.SORT_ORDER'
                      || ' FROM ITEM_L_CLASS C1,LANG_TABLE C2'
                      || ' WHERE C1.COMP_CD=C2.COMP_CD(+)'
                      || ' AND C1.COMP_CD='''||PSV_COMP||''''
                      || ' AND C1.ORG_CLASS_CD='''||ls_org_class||''''
                      || ' AND C1.COMP_CD||C1.ORG_CLASS_CD||C1.L_CLASS_CD=C2.PK_COL(+)'
                      || ' AND C2.TABLE_NM(+)=''ITEM_L_CLASS'''
                      || ' AND C2.LANGUAGE_TP(+)='''||PSV_LANG_CD||''''
                      || ' ) WC1,'
                      || ' (SELECT C1.L_CLASS_CD,C1.M_CLASS_CD,NVL(C2.LANG_NM,C1.M_CLASS_NM) M_CLASS_NM,C1.SORT_ORDER'
                      || ' FROM ITEM_M_CLASS C1,LANG_TABLE C2'
                      || ' WHERE C1.COMP_CD=C2.COMP_CD(+)'
                      || ' AND C1.COMP_CD='''||PSV_COMP||''''
                      || ' AND C1.ORG_CLASS_CD='''||ls_org_class||''''
                      || ' AND C1.COMP_CD||C1.ORG_CLASS_CD||C1.L_CLASS_CD||C1.M_CLASS_CD=C2.PK_COL(+)'
                      || ' AND C2.TABLE_NM(+) = ''ITEM_M_CLASS'''
                      || ' AND C2.LANGUAGE_TP(+) = '''||PSV_LANG_CD||''''
                      || ' ) WC2 , '
                      || ' (SELECT C1.L_CLASS_CD,C1.M_CLASS_CD,C1.S_CLASS_CD,NVL(C2.LANG_NM,C1.S_CLASS_NM) S_CLASS_NM,C1.SORT_ORDER'
                      || ' FROM ITEM_S_CLASS C1,LANG_TABLE C2'
                      || ' WHERE C1.COMP_CD=C2.COMP_CD(+)'
                      || ' AND C1.COMP_CD='''||PSV_COMP||''''
                      || ' AND C1.ORG_CLASS_CD='''||ls_org_class||''''
                      || ' AND C1.COMP_CD||C1.ORG_CLASS_CD||C1.L_CLASS_CD||C1.M_CLASS_CD||C1.S_CLASS_CD=C2.PK_COL(+)'
                      || ' AND C2.TABLE_NM(+)=''ITEM_S_CLASS'''
                      || ' AND C2.LANGUAGE_TP(+)='''||PSV_LANG_CD||''''
                      || ' ) WC3 '
                      || ' WHERE W01.COMP_CD = W02.COMP_CD(+)'
                      || ' AND W01.ITEM_CD = W02.ITEM_CD(+)'
                      || ' AND W01.COMP_CD = W03.COMP_CD(+)'
                      || ' AND W01.ITEM_CD = W03.ITEM_CD(+)'
                      || ' AND W01.L_CLASS_CD = WC1.L_CLASS_CD(+)'
                      || ' AND W01.L_CLASS_CD = WC2.L_CLASS_CD(+)'
                      || ' AND W01.M_CLASS_CD = WC2.M_CLASS_CD(+)'
                      || ' AND W01.L_CLASS_CD = WC3.L_CLASS_CD(+)'
                      || ' AND W01.M_CLASS_CD = WC3.M_CLASS_CD(+)'
                      || ' AND W01.S_CLASS_CD = WC3.S_CLASS_CD(+)'
                      || ' AND W01.COMP_CD = '''||PSV_COMP||''''
                      || ' AND '''||ls_org_class||''' = W02.ORG_CLASS_CD(+)'
                      || ' AND '''||PSV_LANG_CD ||''' = W03.LANGUAGE_TP(+)'
                      || ' ) V';
        /*
        FOR idx IN i..li_item_flag_cnt
        LOOP
           ls_sql_item := ls_sql_item || ', ITEM_FLAG SF' TO_CHAR(idx) ;
        END LOOP;
        */

        ls_sql_item := ls_sql_item
                     || ' WHERE I.COMP_CD= L.COMP_CD(+)'  -- ASP
                     || ' AND I.ITEM_CD  = L.ITEM_CD(+)'
                     || ' AND I.COMP_CD       ='''||PSV_COMP||''''
                     || ' AND L.LANGUAGE_TP(+)='''||PSV_LANG_CD||''''
                     || ' AND I.COMP_CD = C.COMP_CD(+) '  -- ASP
                     || ' AND I.ITEM_CD = C.ITEM_CD(+) '
                     || ' AND C.ORG_CLASS_CD(+)='''||ls_org_class||'''' 
                     || ' AND I.COMP_CD     = V.REP_COMP_CD(+)'
                     || ' AND I.REP_ITEM_CD = V.REP_ITEM_CD(+)'
                     ;

        ls_sql_item := ls_sql_item || ls_where_item || ') I,' ;

        ls_sql_item := ls_sql_item
                      || '(SELECT C1.L_CLASS_CD,NVL(C2.LANG_NM,C1.L_CLASS_NM) L_CLASS_NM,C1.SORT_ORDER'
                      || ' FROM ITEM_L_CLASS C1,LANG_TABLE C2'
                      || ' WHERE C1.COMP_CD=C2.COMP_CD(+)'
                      || ' AND C1.COMP_CD='''||PSV_COMP||''''
                      || ' AND C1.ORG_CLASS_CD='''||ls_org_class||''''
                      || ' AND C1.COMP_CD||C1.ORG_CLASS_CD||C1.L_CLASS_CD=C2.PK_COL(+)'
                      || ' AND C2.TABLE_NM(+)=''ITEM_L_CLASS'''
                      || ' AND C2.LANGUAGE_TP(+)='''||PSV_LANG_CD||''''
                      || ') IC1,'
                      || '(SELECT C1.L_CLASS_CD,C1.M_CLASS_CD,NVL(C2.LANG_NM,C1.M_CLASS_NM) M_CLASS_NM,C1.SORT_ORDER'
                      || ' FROM ITEM_M_CLASS C1,LANG_TABLE C2'
                      || ' WHERE C1.COMP_CD=C2.COMP_CD(+)'
                      || ' AND C1.COMP_CD='''||PSV_COMP||''''
                      || ' AND C1.ORG_CLASS_CD='''||ls_org_class||''''
                      || ' AND C1.COMP_CD||C1.ORG_CLASS_CD||C1.L_CLASS_CD||C1.M_CLASS_CD=C2.PK_COL(+)'
                      || ' AND C2.TABLE_NM(+) = ''ITEM_M_CLASS'''
                      || ' AND C2.LANGUAGE_TP(+) = '''||PSV_LANG_CD||''''
                      || ') IC2 , '
                      || '(SELECT C1.L_CLASS_CD,C1.M_CLASS_CD,C1.S_CLASS_CD,NVL(C2.LANG_NM,C1.S_CLASS_NM) S_CLASS_NM,C1.SORT_ORDER'
                      || ' FROM ITEM_S_CLASS C1,LANG_TABLE C2'
                      || ' WHERE C1.COMP_CD=C2.COMP_CD(+)'
                      || ' AND C1.COMP_CD='''||PSV_COMP||''''
                      || ' AND C1.ORG_CLASS_CD='''||ls_org_class||''''
                      || ' AND C1.COMP_CD||C1.ORG_CLASS_CD||C1.L_CLASS_CD||C1.M_CLASS_CD||C1.S_CLASS_CD=C2.PK_COL(+)'
                      || ' AND C2.TABLE_NM(+)=''ITEM_S_CLASS'''
                      || ' AND C2.LANGUAGE_TP(+)='''||PSV_LANG_CD||''''
                      || ') IC3,'
                      || '(SELECT C.CODE_CD ORD_UNIT,NVL(L.CODE_NM,C.CODE_NM) ORD_UNIT_NM'
                      || ' FROM COMMON C,LANG_COMMON L'
                      || ' WHERE C.COMP_CD=L.COMP_CD(+)'
                      || ' AND C.CODE_TP=L.CODE_TP(+)'
                      || ' AND C.CODE_CD=L.CODE_CD(+)'
                      ||q'[ AND C.CODE_TP='00095']'
                      ||q'[ AND C.USE_YN='Y']'
                      || ' AND C.COMP_CD='''||PSV_COMP||''''
                      || ' AND L.LANGUAGE_TP(+)='''||PSV_LANG_CD||''''
                      || ') IC6,'
                      || '(SELECT C.CODE_CD SALE_UNIT,NVL(L.CODE_NM,C.CODE_NM) SALE_UNIT_NM'
                      || ' FROM COMMON C,LANG_COMMON L'
                      || ' WHERE C.COMP_CD=L.COMP_CD(+)'
                      || ' AND C.CODE_TP=L.CODE_TP(+)'
                      || ' AND C.CODE_CD=L.CODE_CD(+)'
                      ||q'[ AND C.CODE_TP='00095']'
                      ||q'[ AND C.USE_YN='Y']'
                      || ' AND C.COMP_CD='''||PSV_COMP||''''
                      || ' AND L.LANGUAGE_TP(+)='''||PSV_LANG_CD||''''
                      || ') IC7,'
                      || '(SELECT C.CODE_CD STOCK_UNIT,NVL(L.CODE_NM,C.CODE_NM) STOCK_UNIT_NM'
                      || ' FROM COMMON C,LANG_COMMON L'
                      || ' WHERE C.COMP_CD=L.COMP_CD(+)'
                      || ' AND C.CODE_TP=L.CODE_TP(+)'
                      || ' AND C.CODE_CD=L.CODE_CD(+)'
                      ||q'[ AND C.CODE_TP='00095']'
                      ||q'[ AND C.USE_YN='Y']'
                      || ' AND C.COMP_CD='''||PSV_COMP||''''
                      || ' AND L.LANGUAGE_TP(+)='''||PSV_LANG_CD||''''
                      || ') IC8,'
                      || '(SELECT C.CODE_CD DO_UNIT,NVL(L.CODE_NM,C.CODE_NM) DO_UNIT_NM'
                      || ' FROM COMMON C,LANG_COMMON L'
                      || ' WHERE C.COMP_CD=L.COMP_CD(+)'
                      || ' AND C.CODE_TP=L.CODE_TP(+)'
                      || ' AND C.CODE_CD=L.CODE_CD(+)'
                      ||q'[ AND C.CODE_TP='00095']'
                      ||q'[ AND C.USE_YN='Y']'
                      || ' AND C.COMP_CD='''||PSV_COMP||''''
                      || ' AND L.LANGUAGE_TP(+)='''||PSV_LANG_CD||''''
                      || ') IC9';

         ls_sql_item := ls_sql_item
                      || ' WHERE I.L_CLASS_CD=IC1.L_CLASS_CD(+)'
                      || ' AND I.L_CLASS_CD=IC2.L_CLASS_CD(+)'
                      || ' AND I.M_CLASS_CD=IC2.M_CLASS_CD(+)'
                      || ' AND I.L_CLASS_CD=IC3.L_CLASS_CD(+)'
                      || ' AND I.M_CLASS_CD=IC3.M_CLASS_CD(+)'
                      || ' AND I.S_CLASS_CD=IC3.S_CLASS_CD(+)'
                      || ' AND I.ORD_UNIT=IC6.ORD_UNIT(+)'
                      || ' AND I.SALE_UNIT=IC7.SALE_UNIT(+)'
                      || ' AND I.STOCK_UNIT=IC8.STOCK_UNIT(+)'
                      || ' AND I.DO_UNIT=IC9.DO_UNIT(+)';

         ls_sql_item := ls_sql_item
                      || ' )' ;

         PSR_STORE     := ls_sql_store;
         PSR_ITEM      := ls_sql_item;
         PSR_DATE1     := ls_date1 ;
         PSR_EX_DATE1  := ls_ex_date1 ;
         PSR_DATE2     := ls_date2 ;
         PSR_EX_DATE2  := ls_ex_date2 ;
    --   dbms_output.put_line(ls_sql_store) ;
    --   dbms_output.put_line(ls_sql_item) ;
   END;

   PROCEDURE RPT_OLAP
        (PSV_COMP        IN  VARCHAR2 -- ASP
        ,PSV_USER        IN  VARCHAR2
        ,PSV_PGM_ID      IN  VARCHAR2
        ,PSV_LANG_CD     IN  VARCHAR2
        ,PSV_ORG_CLASS   IN  VARCHAR2
        ,PSV_DYN         IN  VARCHAR2
        ,PSV_PARA        IN  VARCHAR2
        ,PSV_FILTER      IN  VARCHAR2
        ,PR_HEADER       IN OUT REF_CUR
        ,PR_RESULT       IN OUT REF_CUR
        ,PR_RTN_CD       OUT VARCHAR2 ,  -- ó���ڵ�
         PR_RTN_MSG      OUT VARCHAR2    -- ó��Message
        ) IS
            ltr_hd        TBL_CT_HD;
            ltr_para      TBL_PARA;
            ltr_dyn_i     TBL_DYN := TBL_DYN();
            ltr_dyn_c     TBL_DYN := TBL_DYN();
            ltr_dyn_v     TBL_DYN := TBL_DYN();
            ltr_dyn_s     TBL_DYN := TBL_DYN();

            li_array             PLS_INTEGER ;
            li_idx             PLS_INTEGER ;

            ls_sql               VARCHAR2(32767);
            ls_sql_sel_up        VARCHAR2(10000);
            ls_sql_sel           VARCHAR2(10000);
            ls_sql_sel2          VARCHAR2(10000);
            ls_sql_from          VARCHAR2(10000);
            ls_sql_from_a        VARCHAR2(10000);
            ls_sql_from_a        VARCHAR2(10000);
            ls_sql_from_c        VARCHAR2(10000);
            ls_sql_where         VARCHAR2(10000);
            ls_sql_where2        VARCHAR2(10000);

            ls_sql_where_a       VARCHAR2(10000);
            ls_sql_where_b       VARCHAR2(10000);
            ls_sql_where_c       VARCHAR2(10000);
            ls_sql_with          VARCHAR2(20000);
            ls_sql_sale_with_a   VARCHAR2(20000);
            ls_sql_sale_with_b   VARCHAR2(20000);
            ls_sql_sale_with_c   VARCHAR2(20000);

            ls_pv                VARCHAR2(20000);
            ls_msg               VARCHAR2(10000);

            ls_dt_chk            VARCHAR2(1) := 'N';
            ls_item_chk          VARCHAR2(1) := 'N';
            ls_store_chk         VARCHAR2(1) := 'N';
            ls_gb_chk            VARCHAR2(1) := 'N';
            ls_sql_type          VARCHAR2(4) ;
            ls_ct_tp             VARCHAR2(2) ;
            ls_hd_val_tp         VARCHAR2(1) ;

            ls_table             VARCHAR2(200) ;
            ls_col_cd            VARCHAR2(10) ;
            ls_val_tp            VARCHAR2(1) ;
            ls_rtn_col           VARCHAR2(100) ;
            ls_rtn_col2          VARCHAR2(100) ;
            ls_mode              VARCHAR2(10) ;

            ls_pv_sel            VARCHAR2(200) ;
            ls_pv_req            VARCHAR2(200) ;

            ls_gb_dt             VARCHAR2(200) ;
            ls_table_join        VARCHAR2(2000) ;
            ls_sql_gb            VARCHAR2(2000) ;
            ls_sql_value         VARCHAR2(2000) ;
            ls_sql_value2        VARCHAR2(2000) ;
            ls_sql_value3        VARCHAR2(2000) ;
            ls_sql_value4        VARCHAR2(2000) ;
            ls_sql_value_up      VARCHAR2(2000) ;
            ls_sql_value_up2     VARCHAR2(2000) ;

            ls_hd_value          VARCHAR2(2000) ;
            ls_hd_value2         VARCHAR2(2000) ;
            ls_hd_value_up       VARCHAR2(2000) ;
            ls_hd_value_up2      VARCHAR2(2000) ;
            ls_hd_sel            VARCHAR2(10000) ;
            ls_hd                VARCHAR2(32767) ;
            ls_hd1               VARCHAR2(32767) ;
            ls_hd2               VARCHAR2(32767) ;
            ls_hd3               VARCHAR2(32767) ;

            ls_ct_sql_value      VARCHAR2(20000) ;
            ls_ct_sql_value_up   VARCHAR2(20000) ;
            ls_ct_sum_sql_value  VARCHAR2(4000) ;
            ls_ct_sql_sel        VARCHAR2(20000) ;
            ls_ct_sql_sel_up     VARCHAR2(20000) ;
            ls_ct_sql_main       VARCHAR2(20000) ;
            ls_ct_hd_sel         VARCHAR2(20000) ;
            ls_ct_hd_value       VARCHAR2(2000) ;
            ls_ct_val            VARCHAR2(1000) ;
            ls_ct_val_up         VARCHAR2(1000) ;
            ls_ct_val_up2        VARCHAR2(1000) ;
            ls_ct_val_gr_up      VARCHAR2(1000) ;
            ls_ct_val_gr_up2     VARCHAR2(1000) ;
            ls_ct_pv_val         VARCHAR2(1000) ;
            ls_ct_pv_sql_value   VARCHAR2(2000) ;
            ls_ct_sql            VARCHAR2(10000) ;
            ls_ct_pv_sel         VARCHAR2(20000) ;
            ls_ct_req_sel        VARCHAR2(20000) ;
            ls_pv_req_sql        VARCHAR2(20000) ;
            ls_alias             VARCHAR2(500) ;

            ls_sql_store    VARCHAR2(10000);
            ls_sql_item     VARCHAR2(10000);
            ls_date1        VARCHAR2(2000);     -- ��ȸ���� (����)
            ls_date2        VARCHAR2(2000);     -- ��ȸ���� (���)
            ls_ex_date1     VARCHAR2(2000);     -- ��ȸ���� ���� (����)
            ls_ex_date2     VARCHAR2(2000);     -- ��ȸ���� ���� (���)

            ls_store_cnt    VARCHAR2(2000);

            ls_pv_in        VARCHAR2(32767);
            ls_chd1         VARCHAR2(32767);
            ls_chd2         VARCHAR2(32767);
            ls_chd3         VARCHAR2(32767);
            ls_chd3_d       VARCHAR2(20000);
            ls_mhd1         VARCHAR2(1000);
            ls_mhd2         VARCHAR2(1000);
            li_cnt          PLS_INTEGER;
            ls_err_cd     VARCHAR2(7)   := '0' ;
            ls_err_msg    VARCHAR2(500) ;

            ERR_HANDLER   EXCEPTION;

   BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        RPT_PARA(PSV_COMP, PSV_USER ,PSV_PGM_ID ,PSV_LANG_CD ,PSV_ORG_CLASS ,PSV_PARA ,PSV_FILTER , -- ASP
                 ls_sql_store , ls_sql_item , ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );

        -- dbms_output.put_line(ls_sql_store) ;
        -- dbms_output.put_line(ls_sql_item) ;

        SP_DYN_PARSING (PSV_DYN, ltr_dyn_i, ltr_dyn_c, ltr_dyn_v, ltr_dyn_s) ;

        li_array := ltr_dyn_c.COUNT;

        ls_dt_chk := 'N';

        IF li_array = 0 THEN
            li_array := ltr_dyn_i.LAST;
            FOR i IN 1..li_array
            LOOP
                CASE WHEN ltr_dyn_i(i).attr1 = '52' THEN
                        ls_dt_chk := 'T';
                    WHEN ltr_dyn_i(i).attr1  = '50' AND  ls_dt_chk <> 'T' THEN
                        ls_dt_chk := 'D';
                    WHEN ltr_dyn_i(i).attr1  = '51' AND ls_dt_chk not IN ( 'T', 'D')  THEN
                        ls_dt_chk := 'M';
                    ELSE
                        NULL;
                END CASE;

                IF ltr_dyn_i(i).attr1 IN ( '20', '21', '22', '23') THEN
                   ls_item_chk := 'Y';
                END IF;

                IF ltr_dyn_i(i).attr1 = '05' THEN
                   ls_store_chk := 'Y';
                END IF;
                ls_col_cd  := ltr_dyn_i(i).attr1;
                ls_mode    := ltr_dyn_i(i).attr3;
                SP_OLAP_SELECT ( ls_col_cd, ls_mode, 'N' , ls_rtn_col , ls_rtn_col2, ls_pv_sel , ls_pv_req);
                ls_sql_sel := ls_sql_sel ||  CASE WHEN i > 1 THEN ',' ELSE ' ' END || ls_rtn_col;
                ls_sql_sel_up := ls_sql_sel_up ||  CASE WHEN i > 1 THEN ',' ELSE ' ' END || ls_rtn_col2;

                CASE ls_mode
                     WHEN 'C' THEN
                        ls_hd_sel  := ls_hd_sel  ||  CASE WHEN i > 1 THEN ',' ELSE ' ' END || 'CC' || ls_col_cd ;
                     WHEN 'N' THEN
                        ls_hd_sel  := ls_hd_sel  ||  CASE WHEN i > 1 THEN ',' ELSE ' ' END || 'CN' || ls_col_cd ;
                     WHEN 'A' THEN
                        ls_hd_sel  := ls_hd_sel  ||  CASE WHEN i > 1 THEN ',' ELSE ' ' END || 'CC' || ls_col_cd
                                   || ', '
                                   || 'CN' || ls_col_cd ;
                END CASE;
            END LOOP;

           ls_sql_sel_up := REPLACE(ls_sql_sel_up, 'SALE_DT', ' SUBSTR(SALE_DT,1,4) || ''-'' || SUBSTR(SALE_DT,5,2) || ''-'' || SUBSTR(SALE_DT,7,2) ||  ''('' || FC_GET_WEEK(''' || PSV_COMP || ''', SALE_DT,  '''|| PSV_LANG_CD || ''') ||  '')'' AS SALE_DT ');

            IF ls_dt_chk in ( 'D' ) AND ls_store_chk ='Y' THEN
               ls_gb_chk := 'N' ;
            ELSE
               ls_gb_chk := 'G' ;
            END IF;

            CASE
                WHEN ls_item_chk = 'Y' AND ls_dt_chk IN  ( 'D', 'N') THEN
                    ls_table := 'SALE_JDM A, S_STORE S, S_ITEM I ';
                    ls_gb_dt :=  'A.SALE_DT';
                    ls_sql_type := '21' ;
                    ls_table_join := ' A.BRAND_CD = S.BRAND_CD '
                                  || ' AND A.STOR_CD = S.STOR_CD '
                                  || ' AND A.ITEM_CD = I.ITEM_CD '
                                  || ' AND A.COMP_CD = S.COMP_CD '
                                  || ' AND A.COMP_CD = I.COMP_CD '
                                  || ' AND A.COMP_CD = ''' || PSV_COMP || '''';
                WHEN ls_item_chk = 'Y' AND ls_dt_chk = 'M' THEN
                    ls_table := 'SALE_JDM A, S_STORE S, S_ITEM I ';
                    ls_gb_dt := 'SUBSTR(A.SALE_DT,1,6) ' ;
                    ls_sql_type := '22' ;
                    ls_table_join := ' A.BRAND_CD = S.BRAND_CD '
                                  || ' AND A.STOR_CD = S.STOR_CD '
                                  || ' AND A.ITEM_CD = I.ITEM_CD '
                                  || ' AND A.COMP_CD = S.COMP_CD '
                                  || ' AND A.COMP_CD = I.COMP_CD '
                                  || ' AND A.COMP_CD = ''' || PSV_COMP || '''';
                WHEN ls_item_chk = 'Y' AND ls_dt_chk = 'T' THEN
                    ls_table := 'SALE_JTM A, S_STORE S, S_ITEM I ';
                    ls_gb_dt := 'A.SEC_DIV||'':00 ~ ''||A.SEC_DIV||'':59'' SEC_DIV ' ;
                    ls_sql_type := '23' ;
                    ls_table_join := ' A.BRAND_CD = S.BRAND_CD '
                                  || ' AND A.STOR_CD = S.STOR_CD '
                                  || ' AND A.ITEM_CD = I.ITEM_CD '
                                  || ' AND A.COMP_CD = S.COMP_CD '
                                  || ' AND A.COMP_CD = I.COMP_CD '
                                  || ' AND A.COMP_CD = ''' || PSV_COMP || '''';
                WHEN ls_item_chk = 'N' AND ls_dt_chk IN  ( 'D', 'N') THEN
                    ls_table := 'SALE_JDS A, S_STORE S ';
                    ls_gb_dt :=  'A.SALE_DT';
                    ls_sql_type := '11' ;
                    ls_table_join := ' A.BRAND_CD = S.BRAND_CD '
                                  || ' AND A.STOR_CD = S.STOR_CD '
                                  || ' AND A.COMP_CD = S.COMP_CD '
                                  || ' AND A.COMP_CD = ''' || PSV_COMP || '''';
                WHEN ls_item_chk = 'N' AND ls_dt_chk = 'M' THEN
                    ls_table := 'SALE_JDS A, S_STORE S ';
                    ls_gb_dt := 'SUBSTR(A.SALE_DT,1,6) ' ;
                    ls_sql_type := '12' ;
                    ls_table_join := ' A.BRAND_CD = S.BRAND_CD '
                                  || ' AND A.STOR_CD = S.STOR_CD '
                                  || ' AND A.COMP_CD = S.COMP_CD '
                                  || ' AND A.COMP_CD = ''' || PSV_COMP || '''';
                WHEN ls_item_chk = 'N' AND ls_dt_chk = 'T' THEN
                    ls_table := 'SALE_JTS A, S_STORE S ';
                    ls_gb_dt := 'A.SEC_DIV||'':00 ~ ''||A.SEC_DIV||'':59'' SEC_DIV ' ;
                    ls_sql_type := '13' ;
                    ls_table_join := ' A.BRAND_CD = S.BRAND_CD '
                                  || ' AND A.STOR_CD = S.STOR_CD '
                                  || ' AND A.COMP_CD = S.COMP_CD '
                                  || ' AND A.COMP_CD = ''' || PSV_COMP || '''';
            END CASE ;

            ls_ct_tp := 'IV';
            ls_pv    := ls_sql_sel;
            li_array := ltr_dyn_v.LAST;
            FOR i IN 1..li_array
            LOOP
                ls_col_cd := ltr_dyn_v(i).attr1;
                FOR j IN 1..4
                LOOP
                    IF j = 2 and  ltr_dyn_v(i).attr3 = '0' OR
                       j = 3 and  ltr_dyn_v(i).attr4 = '0' OR
                       j = 4 and  ltr_dyn_v(i).attr5 = '0' THEN
                       CONTINUE;
                    END IF;
                    ls_val_tp := TO_CHAR(j) ;
                    SP_OLAP_VALUE( ls_col_cd , ls_val_tp , ls_gb_chk, ls_ct_tp , ls_pv, ls_ct_val,ls_alias, ls_ct_pv_val, ls_ct_val_up , ls_ct_val_up2, ls_ct_val_gr_up , ls_ct_val_gr_up2);

                    IF j = 1 THEN
                        ls_sql_value := ls_sql_value || ',' || ls_ct_val || ' ' || ls_alias ;
                    END IF;

                    IF j  = 1 AND ltr_dyn_v(i).attr2 = '1' THEN
                       ls_hd_val_tp := 'V' ;
                    ELSIF j = 2 THEN
                       ls_hd_val_tp := 'S' ;
                    ELSIF j = 3 THEN
                       ls_hd_val_tp := 'R' ;
                    ELSIF j = 4 THEN
                       ls_hd_val_tp := 'E' ;
                    END IF ;

                    IF j > 1 OR ltr_dyn_v(i).attr2 = '1' THEN
                        ls_hd_value  := ls_hd_value  || ',' || ls_hd_val_tp  || ltr_dyn_v(i).attr1 ;
                    END IF;

                    IF ls_date2 IS NULL THEN
                       IF ltr_dyn_v(i).attr2 = '1' or j > 1 THEN
                        ls_sql_value_up := ls_sql_value_up || ',' || ls_ct_val_up || ' ' || ls_alias ;
                       END IF;
                    ELSE
                       IF j = 1 THEN
                           ls_sql_value2 := ls_sql_value2 || ',' || ' 0 ' || ls_alias || '2' ;
                           ls_sql_value3 := ls_sql_value3 || ',' || ' 0 ' || ls_alias ;
                           ls_sql_value4 := ls_sql_value4 || ',' || ls_ct_val || ' ' || ls_alias || '2' ;
                       END IF ;

                       IF ltr_dyn_v(i).attr2 = '1' or j > 1  THEN
                           ls_sql_value_up := ls_sql_value_up || ',' ||  ls_ct_val_gr_up || ' ' || ls_alias ;
                           ls_hd_value_up   := ls_hd_value_up  || ',' || 'DATE1 ' ||  'D1' || ltr_dyn_v(i).attr1;
                           IF j <> 4 THEN
                               ls_sql_value_up2 := ls_sql_value_up2 || ',' ||  ls_ct_val_gr_up2 ||  ' ' || ls_alias || '2' ;
                               ls_hd_value2     := ls_hd_value2  || ',' || ls_hd_val_tp || ltr_dyn_v(i).attr1 ;
                               ls_hd_value_up2  := ls_hd_value_up2  || ',' || 'DATE2 ' || 'D2' || ltr_dyn_v(i).attr1 ;
                           END IF ;
                       END IF;
                    END IF;

                END LOOP;
           END LOOP;

            ls_sql_from := ' FROM ' || ls_table ;

            ls_sql_where := ' WHERE ' || ls_table_join ;
            ls_sql_where := ls_sql_where || ' AND ' || ' A.SALE_DT ' || ls_date1 ;
            IF ls_ex_date1 IS NOT NULL THEN
               ls_sql_where  := ls_sql_where || ' AND ' || ' A.SALE_DT ' || ls_ex_date1;
            END IF;

            -- ���Ⱓ
            IF ls_date2 IS NOT NULL THEN
                ls_sql_where2 := ' WHERE ' || ls_table_join ;
                ls_sql_where2 := ls_sql_where2 || ' AND ' || ' A.SALE_DT ' || ls_date2 ;
                IF ls_ex_date2 IS NOT NULL THEN
                   ls_sql_where2  := ls_sql_where2 || ' AND ' || ' A.SALE_DT ' || ls_ex_date2;
                END IF;
            END IF ;

            IF ls_dt_chk in (  'D' ) AND ls_store_chk ='Y' THEN
               ls_sql_gb := '';
               ls_store_cnt   := ' COUNT(A.STOR_CD) OVER(PARTITION BY A.BRAND_CD ,A.STOR_CD) ';
            ELSE
               ls_sql_gb := ' GROUP BY ' || ls_sql_sel ;
               ls_store_cnt  := ' MAX(COUNT(DISTINCT A.SALE_DT || A.STOR_CD)) OVER () ';
            END IF;

            ls_sql_with := ' WITH ' || ls_sql_store ;-- S_STORE
            IF ls_item_chk = 'Y' THEN
                ls_sql_with := ls_sql_with ||  ', ' ||  ls_sql_item  ; -- S_ITEM
            END IF;

            IF ls_date2 IS NULL THEN
               ls_sql_sale_with_a := ' , S_SALE AS ( '
                                  || ' SELECT '
                                  ||  ls_sql_sel_up || ls_sql_value_up
                                  || ' FROM ( '
                                  || ' SELECT  '
                                  || ls_sql_sel || ls_sql_value
                                  || ',' || ls_store_cnt || ' STOR_ACNT '
                                  || ls_sql_from || ls_sql_where || ls_sql_gb
                                  || ') A ) ';
               ls_hd1 := F_OLAP_HD(PSV_COMP, PSV_LANG_CD)  || ' SELECT ' || ls_hd_sel || ls_hd_value || ' FROM S_HD ' ;
               ls_sql := ls_sql_with || ls_sql_sale_with_a
                   || ' SELECT * FROM S_SALE A ' ;
            ELSE
               -- Oracle bug �� WITH ���� count( distinct col) UNION �� ��� Error �߻� �� �� ����
               -- => WITH ������ UNION ������ �ߺ� ���
               ls_sql_sale_with_a := ' ( SELECT  '
                                  || ls_sql_sel_up
                                  || ls_sql_value_up
                                  || ls_sql_value_up2
                                  || ' FROM ( '
                                  || ' SELECT '
                                  || ' * '
                                  || ' FROM ( '
                                  || ls_sql_with
                                  || ' SELECT '
                                  || ls_sql_sel || ls_sql_value
                                  || ',' || ls_store_cnt || ' STOR_ACNT '
                                  || ls_sql_value2
                                  || ', 0 STOR_ACNT2 '
                                  || ls_sql_from || ls_sql_where || ls_sql_gb
                                  || ' ) A '
                                  || ' UNION ALL '
                                  || ' SELECT '
                                  || ' * '
                                  || ' FROM ( '
                                  || ls_sql_with
                                  || ' SELECT '
                                  || ls_sql_sel || ls_sql_value3
                                  || ', 0 STOR_ACNT '
                                  || ls_sql_value4
                                  || ',' || ls_store_cnt || ' STOR_ACNT2 '
                                  || ls_sql_from || ls_sql_where2 || ls_sql_gb
                                  || ' ) A '
                                  || ' ) A '
                                  || ' GROUP BY '
                                  || ls_sql_sel_up
                                  || ' ) ';
                ls_hd1 := F_OLAP_HD(PSV_COMP, PSV_LANG_CD)
                       || ' SELECT ' || ls_hd_sel || ls_hd_value_up || ls_hd_value_up2 || ' FROM S_HD '
                       || ' UNION ALL '
                       || ' SELECT ' || ls_hd_sel || ls_hd_value || ls_hd_value2 || ' FROM S_HD ' ;
                ls_sql :=  ' SELECT * FROM '
                       ||  ls_sql_sale_with_a
                       || ' A ' ;

            END IF;
       ELSE
            li_array := ltr_dyn_i.LAST;
            FOR i IN 1..li_array
            LOOP
                CASE WHEN ltr_dyn_i(i).attr1 = '52' THEN
                        ls_dt_chk := 'T';
                    WHEN ltr_dyn_i(i).attr1  = '50' AND ls_dt_chk <> 'T' THEN
                        ls_dt_chk := 'D';
                    WHEN ltr_dyn_i(i).attr1  = '51' AND ls_dt_chk not IN ( 'T', 'D') THEN
                        ls_dt_chk := 'M';
                    ELSE
                        NULL;
                END CASE;

                IF ltr_dyn_i(i).attr1 IN ( '20', '21', '22', '23' ) THEN
                   ls_item_chk := 'Y';
                END IF;

                IF ltr_dyn_i(i).attr1 = '05' THEN
                   ls_store_chk := 'Y';
                END IF;
                ls_col_cd  := ltr_dyn_i(i).attr1;
                ls_mode    := ltr_dyn_i(i).attr3;
                SP_OLAP_SELECT ( ls_col_cd, ls_mode, 'N' , ls_rtn_col, ls_rtn_col2 ,ls_pv_sel , ls_pv_req );

                ls_sql_sel := ls_sql_sel || CASE WHEN i > 1 THEN ',' ELSE ' ' END || ls_rtn_col;
                ls_sql_sel_up := ls_sql_sel_up || CASE WHEN i > 1 THEN ',' ELSE ' ' END || ls_rtn_col2;
                CASE ls_mode
                     WHEN 'C' THEN
                        ls_hd_sel  := ls_hd_sel  ||  CASE WHEN i > 1 THEN ',' ELSE ' ' END || 'CC' || ls_col_cd ;
                     WHEN 'N' THEN
                        ls_hd_sel  := ls_hd_sel  ||  CASE WHEN i > 1 THEN ',' ELSE ' ' END || 'CN' || ls_col_cd ;
                     WHEN 'A' THEN
                        ls_hd_sel  := ls_hd_sel  ||  CASE WHEN i > 1 THEN ',' ELSE ' ' END || 'CC' || ls_col_cd
                                   || ', '
                                   || 'CN' || ls_col_cd ;
                END CASE;
            END LOOP;

            li_array := ltr_dyn_c.LAST;
            FOR i IN 1..li_array
            LOOP
                CASE WHEN ltr_dyn_c(i).attr1 = '52' THEN
                        ls_dt_chk := 'T';
                    WHEN ltr_dyn_c(i).attr1  = '50' AND  ls_dt_chk <> 'T' THEN
                        ls_dt_chk := 'D';
                    WHEN ltr_dyn_c(i).attr1  = '51' AND ls_dt_chk not IN ( 'T', 'D')  THEN
                        ls_dt_chk := 'M';
                    ELSE
                        NULL;
                END CASE;

                IF ltr_dyn_c(i).attr1 IN ( '20', '21', '22', '23' ) THEN
                   ls_item_chk := 'Y';
                END IF;

                IF ltr_dyn_c(i).attr1 = '05' THEN
                   ls_store_chk := 'Y';
                END IF;
                ls_col_cd  := ltr_dyn_c(i).attr1;
                ls_mode    := ltr_dyn_c(i).attr3;
                SP_OLAP_SELECT ( ls_col_cd, ls_mode, 'Y' , ls_rtn_col, ls_rtn_col2, ls_pv_sel , ls_pv_req  );
                ls_ct_sql_sel := ls_ct_sql_sel ||  CASE WHEN i > 1 THEN ',' ELSE ' ' END || ls_rtn_col;
                ls_ct_pv_sel  := ls_ct_pv_sel  ||  CASE WHEN i > 1 THEN ',' ELSE ' ' END || ls_pv_sel ;
                ls_ct_req_sel := ls_ct_req_sel ||  CASE WHEN i > 1 THEN ',' ELSE ' ' END || ls_pv_req ;
                ls_ct_hd_sel  := ls_ct_hd_sel  ||  CASE WHEN i > 1 THEN ',' ELSE ' ' END || 'C' || ls_col_cd ;
                ls_ct_sql_sel_up := ls_ct_sql_sel_up ||  CASE WHEN i > 1 THEN ',' ELSE ' ' END || ls_pv_sel;
            END LOOP;

            IF ls_dt_chk in ( 'D' ) AND ls_store_chk ='Y' THEN
               ls_gb_chk := 'N' ;
            ELSE
               ls_gb_chk := 'G' ;
            END IF;

            CASE
                WHEN ls_item_chk = 'Y' AND ls_dt_chk IN  ( 'D', 'N') THEN
                    ls_table := 'SALE_JDM A, S_STORE S, S_ITEM I ';
                    ls_gb_dt :=  'A.SALE_DT';
                    ls_sql_type := '21' ;
                    ls_table_join := ' A.BRAND_CD = S.BRAND_CD   '
                                  || ' AND A.STOR_CD = S.STOR_CD '
                                  || ' AND A.ITEM_CD = I.ITEM_CD '
                                  || ' AND A.COMP_CD = S.COMP_CD '
                                  || ' AND A.COMP_CD = I.COMP_CD '
                                  || ' AND A.COMP_CD = ''' || PSV_COMP || '''';
                WHEN ls_item_chk = 'Y' AND ls_dt_chk = 'M' THEN
                    ls_table := 'SALE_JDM A, S_STORE S, S_ITEM I ';
                    ls_gb_dt := 'SUBSTR(A.SALE_DT,1,6) ' ;
                    ls_sql_type := '22' ;
                    ls_table_join := ' A.BRAND_CD = S.BRAND_CD '
                                  || ' AND A.STOR_CD = S.STOR_CD '
                                  || ' AND A.ITEM_CD = I.ITEM_CD '
                                  || ' AND A.COMP_CD = S.COMP_CD '
                                  || ' AND A.COMP_CD = I.COMP_CD '
                                  || ' AND A.COMP_CD = ''' || PSV_COMP || '''';
                WHEN ls_item_chk = 'Y' AND ls_dt_chk = 'T' THEN
                    ls_table := 'SALE_JTM A, S_STORE S, S_ITEM I  ';
                    ls_gb_dt := 'A.SEC_DIV||'':00 ~ ''||A.SEC_DIV||'':59'' SEC_DIV ' ;
                    ls_sql_type := '23' ;
                    ls_table_join := ' A.BRAND_CD = S.BRAND_CD '
                                  || ' AND A.STOR_CD = S.STOR_CD '
                                  || ' AND A.ITEM_CD = I.ITEM_CD '
                                  || ' AND A.COMP_CD = S.COMP_CD '
                                  || ' AND A.COMP_CD = I.COMP_CD '
                                  || ' AND A.COMP_CD = ''' || PSV_COMP || '''';
                WHEN ls_item_chk = 'N' AND ls_dt_chk IN  ( 'D', 'N') THEN
                    ls_table := 'SALE_JDS A, S_STORE S ';
                    ls_gb_dt :=  'A.SALE_DT';
                    ls_sql_type := '11' ;
                    ls_table_join := ' A.BRAND_CD = S.BRAND_CD '
                                  || ' AND A.STOR_CD = S.STOR_CD '
                                  || ' AND A.COMP_CD = S.COMP_CD '
                                  || ' AND A.COMP_CD = ''' || PSV_COMP || '''';
                WHEN ls_item_chk = 'N' AND ls_dt_chk = 'M' THEN
                    ls_table := 'SALE_JDS A, S_STORE S ';
                    ls_gb_dt := 'SUBSTR(A.SALE_DT,1,6) ' ;
                    ls_sql_type := '12' ;
                    ls_table_join := ' A.BRAND_CD = S.BRAND_CD '
                                  || ' AND A.STOR_CD = S.STOR_CD '
                                  || ' AND A.COMP_CD = S.COMP_CD '
                                  || ' AND A.COMP_CD = ''' || PSV_COMP || '''';
                WHEN ls_item_chk = 'N' AND ls_dt_chk = 'T' THEN
                    ls_table := 'SALE_JTS A, S_STORE S ';
                    ls_gb_dt := 'A.SEC_DIV||'':00 ~ ''||A.SEC_DIV||'':59'' SEC_DIV ' ;
                    ls_sql_type := '13' ;
                    ls_table_join := ' A.BRAND_CD = S.BRAND_CD '
                                  || ' AND A.STOR_CD = S.STOR_CD '
                                  || ' AND A.COMP_CD = S.COMP_CD '
                                  || ' AND A.COMP_CD = ''' || PSV_COMP || '''';
            END CASE ;

            ls_ct_tp := 'CV';
            ls_pv := ls_sql_sel;

            li_array := ltr_dyn_v.LAST;
            FOR i IN 1..li_array
            LOOP
                ls_col_cd := ltr_dyn_v(i).attr1;
                FOR j IN 1..4
                LOOP
                    IF j = 2 and  ltr_dyn_v(i).attr3 = '0' OR
                       j = 3 and  ltr_dyn_v(i).attr4 = '0' OR
                       j = 4 and  ltr_dyn_v(i).attr5 = '0' THEN
                       CONTINUE;
                    END IF;
                    ls_val_tp := TO_CHAR(j) ;
                    SP_OLAP_VALUE( ls_col_cd , ls_val_tp , ls_gb_chk,ls_ct_tp, ls_pv, ls_ct_val, ls_alias , ls_ct_pv_val , ls_ct_val_up , ls_ct_val_up2, ls_ct_val_gr_up , ls_ct_val_gr_up2);
                    IF j = 1 THEN
                       ls_sql_value  := ls_sql_value || ',' || ls_ct_val  || ' ' || ls_alias ;
                    END IF;

                    IF j = 1 AND ltr_dyn_v(i).attr2 = '1'  THEN
                        ls_sql_value_up := ls_sql_value_up || ','  || ls_alias ;
                    ELSIF j > 1 THEN
                        ls_sql_value_up := ls_sql_value_up ||  ','  || ls_ct_val_up || ' ' || ls_alias ;
                    END IF;

                    IF j  = 1 AND ltr_dyn_v(i).attr2 = '1' THEN
                       ls_hd_val_tp := 'V' ;
                    ELSIF j = 2 THEN
                       ls_hd_val_tp := 'S' ;
                    ELSIF j = 3 THEN
                       ls_hd_val_tp := 'R' ;
                    ELSIF j = 4 THEN
                       ls_hd_val_tp := 'E' ;
                    END IF ;

                    IF j > 1 OR ltr_dyn_v(i).attr2 = '1' THEN
                       ls_hd_value  := ls_hd_value  || ',' || ls_hd_val_tp  || ltr_dyn_v(i).attr1 ;
                    END IF;

                END LOOP ;
            END LOOP;

            ls_ct_tp := 'CS';
            li_array := ltr_dyn_s.LAST;
            FOR i IN 1..li_array
            LOOP
                ls_col_cd := ltr_dyn_s(i).attr1;
                FOR j IN 1..4
                LOOP
                    IF j = 2 and  ltr_dyn_s(i).attr3 = '0' OR
                       j = 3 and  ltr_dyn_s(i).attr4 = '0' OR
                       j = 4 and  ltr_dyn_s(i).attr5 = '0' THEN
                       CONTINUE;
                    END IF;
                    ls_val_tp := TO_CHAR(j) ;
                    SP_OLAP_VALUE( ls_col_cd , ls_val_tp, ls_gb_chk,ls_ct_tp, ls_pv, ls_ct_val, ls_alias ,ls_ct_pv_val, ls_ct_val_up , ls_ct_val_up2, ls_ct_val_gr_up , ls_ct_val_gr_up2 );
                    IF j = 1 THEN
                        ls_ct_pv_sql_value := ls_ct_pv_sql_value ||  CASE WHEN i > 1 THEN ',' ELSE ' ' END  || ls_ct_pv_val ;
                        ls_ct_sql_value    := ls_ct_sql_value || ',' || ls_ct_val || ' ' || ls_alias ;
                    END IF;

                    IF  ltr_dyn_s(i).attr2 = '1' or j > 1 THEN
                        ls_ct_sql_value_up := ls_ct_sql_value_up || ','  || ls_alias ;
                    END IF;

                    IF j  = 1 AND ltr_dyn_s(i).attr2 = '1' THEN
                       ls_hd_val_tp := 'V' ;
                    ELSIF j = 2 THEN
                       ls_hd_val_tp := 'S' ;
                    ELSIF j = 3 THEN
                       ls_hd_val_tp := 'R' ;
                    ELSIF j = 4 THEN
                       ls_hd_val_tp := 'E' ;
                    END IF ;

                    IF j > 1 OR ltr_dyn_s(i).attr2 = '1' THEN
                        ls_ct_hd_value     := ls_ct_hd_value  || ',' || ls_hd_val_tp || ltr_dyn_s(i).attr1 ;
                    END IF;

                END LOOP;
            END LOOP;

            ls_sql_from  := ' FROM '  || ls_table ;
            ls_sql_where := ' WHERE ' || ls_table_join ;
            ls_sql_where := ls_sql_where || ' AND ' || ' A.SALE_DT ' || ls_date1 ;
            IF ls_ex_date1 IS NOT NULL THEN
               ls_sql_where  := ls_sql_where || ' AND ' || ' A.SALE_DT ' || ls_ex_date1;
            END IF;

            IF ls_dt_chk in (  'D' ) AND ls_store_chk ='Y' THEN
               ls_sql_gb    := '';
               ls_store_cnt := ' COUNT(A.STOR_CD) OVER(PARTITION BY A.BRAND_CD ,A.STOR_CD) ';
            ELSE
               ls_sql_gb := ' GROUP BY ' || ls_sql_sel  || ',' || ls_ct_sql_sel ;
               ls_store_cnt  := ' COUNT(MAX(DISTINCT A.SALE_DT || A.STOR_CD)) OVER ()  ';
            END IF;

            ls_sql_with := ' WITH ' || ls_sql_store ; -- S_STORE
            IF ls_item_chk = 'Y' THEN
                ls_sql_with := ls_sql_with || ', ' || ls_sql_item ; -- S_ITEM
            END IF;

            li_array := ltr_dyn_c.LAST ;

            ls_sql_sel :=  ' SELECT ' || ls_sql_sel || ',' || ls_ct_sql_sel ;

            ls_pv_req_sql := ls_sql_with || ' SELECT DISTINCT '
                          || ls_ct_req_sel
                          || CASE WHEN li_array = 1 THEN  q'[ , ' ' COL_CD2 , '' COL_NM2 ]' ELSE ' ' END
                          || ls_sql_from || ls_sql_where
                          || ' ORDER BY '
                          || ls_ct_req_sel ;

            dbms_output.put_line( ls_pv_req_sql  ) ;
            EXECUTE IMMEDIATE  ls_pv_req_sql BULK COLLECT INTO ltr_hd ;

            IF ltr_hd.count = 0 THEN
                ls_err_cd  := '4000100' ;
                ls_err_msg := PKG_COMMON_FC.F_RTN_MSG(PSV_COMP, PSV_LANG_CD, ls_err_cd);
                RAISE ERR_HANDLER ;
            END IF;

            li_idx := 0 ;

            IF ltr_hd.COUNT > 0 THEN
                FOR i IN ltr_hd.FIRST..ltr_hd.LAST
                LOOP
                    BEGIN
                        IF i > 1 THEN
                           ls_pv_in := ls_pv_in || ' , ';
                           ls_chd1  := ls_chd1 || ' , ' ;
                           ls_chd2  := ls_chd2 || ' , ' ;
                         END IF;

                        ls_pv_in := ls_pv_in
                                 || CASE WHEN li_array = 2 THEN  '(''' ELSE '''' END
                                 || ltr_hd(i).COL_CD1
                                 || CASE WHEN li_array = 2 THEN   ''',''' || ltr_hd(i).COL_CD2 || ''')' ELSE '''' END ;

                        FOR j  IN  1..ltr_dyn_s.LAST
                        LOOP
                            ls_chd1 := ls_chd1 || CASE WHEN j = '1' THEN '' ELSE ',' END ||  ''''
                                    || CASE ltr_dyn_c(1).attr3 WHEN 'A' THEN ltr_hd(i).COL_CD1 || '(' ||ltr_hd(i).COL_NM1 || ') '
                                                               WHEN 'N' THEN ltr_hd(i).COL_NM1
                                                               ELSE  ltr_hd(i).COL_CD1 END
                                    || ''' CT'  || TO_CHAR( i*ltr_dyn_s.LAST  - (ltr_dyn_s.LAST - j ) ) ;
                        END LOOP ;

                        IF li_array = 2 THEN
                            FOR j IN 1..ltr_dyn_s.LAST
                            LOOP
                                ls_chd2 := ls_chd2 || CASE WHEN j = '1' THEN '' ELSE ',' END  || ''''
                                || CASE ltr_dyn_c(2).attr3 WHEN 'A' THEN ltr_hd(i).COL_CD2 || '(' ||ltr_hd(i).COL_NM2 || ') '
                                                               WHEN 'N' THEN ltr_hd(i).COL_NM2
                                                               ELSE  ltr_hd(i).COL_CD2 END
                                || ''' CT'  || TO_CHAR( i*ltr_dyn_s.LAST  - (ltr_dyn_s.LAST - j ) );
                            END LOOP ;
                        END IF;

                        ls_chd3 := ls_chd3 || ls_ct_hd_value ;
                    END;
                END LOOP;
            END IF;
            
            ls_ct_sql_main :=  ' SELECT ' || ls_sql_sel_up || ',' || ls_ct_sql_sel_up || ls_sql_value_up || ls_ct_sql_value_up
                            || ' FROM ( '
                            || ls_sql_sel || ls_sql_value || ls_ct_sql_value
                            || ',' || ls_store_cnt || ' STOR_ACNT '
                            || ls_sql_from || ls_sql_where || ls_sql_gb
                            || ' ) A ' ;

            ls_ct_sql_main := ' , S_SALE AS ( ' || ls_ct_sql_main || ') ' ;

            ls_ct_sql      := ' SELECT * FROM S_SALE A '
                           || ' PIVOT ( '
                           || ls_ct_pv_sql_value
                           || ' FOR ( '
                           || ls_ct_pv_sel
                           || ') IN ('
                           || ls_pv_in
                           || ') ) ';

            ls_sql := ls_sql_with || ls_ct_sql_main || ls_ct_sql ;
            ls_hd1 := F_OLAP_HD(PSV_COMP, PSV_LANG_CD)
                  || ' SELECT ' || ls_hd_sel || ls_hd_value
                  || ', ' || ls_chd1
                  || ' FROM S_HD ' ;
            IF ltr_dyn_c.LAST  = 2 THEN
               ls_hd2 :=  ' UNION ALL '
                      || ' SELECT ' || ls_hd_sel || ls_hd_value
                      || ', ' || ls_chd2
                      || ' FROM S_HD ' ;
            END IF;

            ls_hd3 :=  ' UNION ALL '
                   || ' SELECT ' || ls_hd_sel || ls_hd_value
                   || ls_chd3
                   || ' FROM S_HD ' ;

       END IF;

       dbms_output.enable( 1000000 );
       dbms_output.put_line( ls_sql );
       OPEN PR_RESULT FOR ls_sql;
       dbms_output.put_line( ls_hd );
       dbms_output.put_line( ls_hd1 || CASE WHEN ltr_dyn_c.LAST  = 2 THEN  ls_hd2 ELSE '' END || ls_hd3 );
       OPEN PR_HEADER FOR ls_hd1 || CASE WHEN  ltr_dyn_c.LAST  = 2 THEN  ls_hd2 ELSE '' END || ls_hd3;

       PR_RTN_CD  := ls_err_cd;
       PR_RTN_MSG := ls_err_msg;

       --EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=EXACT';
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

   PROCEDURE SP_DUMMY
   IS
   BEGIN
       NULL;
   END;
END;

/
