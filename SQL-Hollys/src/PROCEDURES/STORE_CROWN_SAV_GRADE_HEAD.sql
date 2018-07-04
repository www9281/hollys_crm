--------------------------------------------------------
--  DDL for Procedure STORE_CROWN_SAV_GRADE_HEAD
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."STORE_CROWN_SAV_GRADE_HEAD" (
    P_COMP_CD      IN  VARCHAR2,
    P_LANGUAGE_TP  IN  VARCHAR2,
    O_CURSOR       OUT SYS_REFCURSOR
) IS
    TYPE  rec_ct_hd IS RECORD
        ( 
            LVL_CD    VARCHAR2(10),
            LVL_NM    VARCHAR2(100)
        );
    TYPE tb_ct_hd IS TABLE OF rec_ct_hd
        INDEX BY PLS_INTEGER;

    qry_hd     tb_ct_hd;
    V_CROSSTAB     VARCHAR2(30000);
    V_HD       VARCHAR2(30000);
    V_HD1      VARCHAR2(20000);
    V_HD2      VARCHAR2(20000);
    
    ls_sql VARCHAR2(30000) ;
    ls_sql_crosstab_main VARCHAR2(20000); -- CORSSTAB TITLE
BEGIN
--------------------------------- 매장별 왕관적립현황 그리드 헤더 조회(회원등급별) ----------------------------------
    ls_sql_crosstab_main :=
          ' SELECT  LVL_CD,  '
        ||'         LVL_NM'
        ||' FROM    C_CUST_LVL                                                                                 '
        ||' WHERE   COMP_CD = '''||P_COMP_CD||''''
        ||' AND     USE_YN  = ''Y'''
        ||' ORDER BY LVL_CD';
 
    ls_sql := ls_sql_crosstab_main ;
    EXECUTE IMMEDIATE ls_sql BULK COLLECT INTO qry_hd; 
    
    V_HD1 := ' SELECT  '        
          || '        '''||FC_GET_WORDPACK(P_LANGUAGE_TP,'BRAND_CD')||''', '
          || '        '''||FC_GET_WORDPACK(P_LANGUAGE_TP,'BRAND_NM')||''', '
          || '        '''||FC_GET_WORDPACK(P_LANGUAGE_TP,'SHOP' )||''' AS SHOP, '
          || '        '''||FC_GET_WORDPACK(P_LANGUAGE_TP,'SHOP_NM' )||''' AS SHOP_NM, '
          || '        '''||FC_GET_WORDPACK(P_LANGUAGE_TP,'TOTAL'   )||''' AS TOTAL, '
          || '        '''||FC_GET_WORDPACK(P_LANGUAGE_TP,'TOTAL'   )||''' AS TOTAL, '
          || '        '''||FC_GET_WORDPACK(P_LANGUAGE_TP,'TOTAL'   )||''' AS TOTAL, ';
          
    V_HD2 := ' SELECT  '        
          || '        '''||FC_GET_WORDPACK(P_LANGUAGE_TP,'BRAND_CD')||''', '
          || '        '''||FC_GET_WORDPACK(P_LANGUAGE_TP,'BRAND_NM')||''', '
          || '        '''||FC_GET_WORDPACK(P_LANGUAGE_TP,'SHOP' )||''' AS SHOP, '
          || '        '''||FC_GET_WORDPACK(P_LANGUAGE_TP,'SHOP_NM' )||''' AS SHOP_NM, '
          || '        '''||FC_GET_WORDPACK(P_LANGUAGE_TP,'VISIT_CUST_CNT')||''' AS VISIT_CUST_CNT, '
          || '        '''||FC_GET_WORDPACK(P_LANGUAGE_TP,'TOT_SAV_PT'    )||''' AS TOT_SAV_PT, '
          || '        '''||FC_GET_WORDPACK(P_LANGUAGE_TP,'AVG_SAV_PT'    )||''' AS AVG_SAV_PT, ';

    FOR i IN qry_hd.FIRST..qry_hd.LAST
    LOOP
        BEGIN
            IF i > 1 THEN
               V_CROSSTAB := V_CROSSTAB || ', ';
               V_HD1 := V_HD1 || ' , ' ;
               V_HD2 := V_HD2 || ' , ' ;
            END IF;
            V_CROSSTAB := V_CROSSTAB || '''' || qry_hd(i).LVL_CD ||'''';
            V_HD1 := V_HD1 || ''''   || qry_hd(i).LVL_NM || ''' CT' || TO_CHAR(i*3 - 2) || ',' ;
            V_HD1 := V_HD1 || ''''   || qry_hd(i).LVL_NM || ''' CT' || TO_CHAR(i*3 - 1) || ',' ;
            V_HD1 := V_HD1 || ''''   || qry_hd(i).LVL_NM || ''' CT' || TO_CHAR(i*3)  ;
            V_HD2 := V_HD2 || ''''   || FC_GET_WORDPACK(P_LANGUAGE_TP, 'VISIT_CUST_CNT')|| ''' CT' || TO_CHAR(i*3 - 2 ) || ',' ;
            V_HD2 := V_HD2 || ''''   || FC_GET_WORDPACK(P_LANGUAGE_TP, 'TOT_SAV_PT'    )|| ''' CT' || TO_CHAR(i*3 - 1 ) || ',' ;
            V_HD2 := V_HD2 || ''''   || FC_GET_WORDPACK(P_LANGUAGE_TP, 'AVG_SAV_PT'    )||'''  CT' || TO_CHAR(i*3)   ;
        END;
    END LOOP;

    V_HD1 := V_HD1 || ' FROM DUAL ' ;
    V_HD2 := V_HD2 || ' FROM DUAL ' ;
    V_HD  := V_HD1 || ' UNION ALL ' || V_HD2 ;
              
    OPEN O_CURSOR FOR V_HD;
    
END STORE_CROWN_SAV_GRADE_HEAD;

/
