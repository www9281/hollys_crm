--------------------------------------------------------
--  DDL for Procedure SP_CRT_CALENDAR
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_CRT_CALENDAR" 
    (
     PSV_FR_YYYY     IN  VARCHAR2 -- From 연도 (YYYY)
    ,PSV_TO_YYYY     IN  VARCHAR2 -- To 연도 (YYYY)
    ) IS
    ldt_fr_dt    DATE ;
    ldt_to_dt    DATE ;
/******************************************************************************
   NAME:       SP_CRT_CALENDAR
   PURPOSE:

   REVISIONS:
   VER        DATE        AUTHOR           DESCRIPTION
   ---------  ----------  ---------------  ------------------------------------
   1.0        2010-03-23   HotnCool        Calendar Data 생성.

   NOTES:

      OBJECT NAME:     SP_CRT_CALENDAR
      SYSDATE:         2010-03-23
      USERNAME:
      TABLE NAME:
******************************************************************************/
BEGIN
    ldt_fr_dt := TO_DATE( PSV_FR_YYYY || '0101' , 'YYYYMMDD') ;
    ldt_to_dt := TO_DATE( PSV_TO_YYYY || '1231' , 'YYYYMMDD') ;
    INSERT INTO CALENDAR
            (YMD, YMD_DATE, YMD_DISP, YM_DISP, DAY_NAME, DAY_NUM_IN_WEEK, DAY_SNAME, WEEK_YM,
            WEEK_IN_MONTH, WEEK_STARTING_DT, WEEK_ENDING_DT, WEEK_DISP, CALENDAR_WEEK_NUM,
            CALENDAR_MONTH, CALENDAR_YEAR, DAYS_IN_CAL_MONTH, CALENDAR_MONTH_NAME, DAYS_IN_CAL_YEAR )
     SELECT YMD, YMD_DATE, YMD_DISP, YM_DISP, DAY_NAME, DAY_NUM_IN_WEEK, DAY_SNAME, WEEK_YM,
            TRUNC((TO_NUMBER(SUBSTRB(WEEK_STARTING_DT, -2, 2)) + 7 - TO_NUMBER(TO_CHAR(TO_DATE(WEEK_STARTING_DT, 'YYYYMMDD'), 'D')) + 1) / 7)  WEEK_IN_MONTH,
            WEEK_STARTING_DT, WEEK_ENDING_DT,
            TO_CHAR(TO_DATE(WEEK_STARTING_DT, 'YYYYMMDD') , 'MON')  ||
            CASE  TRUNC((TO_NUMBER(SUBSTRB(WEEK_STARTING_DT, -2, 2)) + 7 - TO_NUMBER(TO_CHAR(TO_DATE(WEEK_STARTING_DT, 'YYYYMMDD'), 'D')) + 1) / 7)
               WHEN 1 THEN '첫째주'
               WHEN 2 THEN '둘째주'
               WHEN 3 THEN '세째주'
               WHEN 4 THEN '네째주'
               WHEN 5 THEN '다섯째주' END WEEK_DISP,
            CALENDAR_WEEK_NUM,
            CALENDAR_MONTH, CALENDAR_YEAR, DAYS_IN_CAL_MONTH, CALENDAR_MONTH_NAME, DAYS_IN_CAL_YEAR
      FROM
          (
            SELECT
                  YMD, YMD_DATE, TO_CHAR(YMD_DATE, 'YYYY-MM-DD') YMD_DISP, TO_CHAR(YMD_DATE, 'YYYY-MM') YM_DISP,
                  TO_CHAR(YMD_DATE , 'DAY') DAY_NAME,
                  TO_CHAR(YMD_DATE - 1 , 'D') DAY_NUM_IN_WEEK,
                  TO_CHAR(YMD_DATE , 'DY') DAY_SNAME,
                  CASE WHEN LAST_DAY((TRUNC(YMD_DATE - 1 , 'DAY') + 1)) - (TRUNC(YMD_DATE - 1 , 'DAY') + 1) >= 3 THEN
                       TO_CHAR( TRUNC(YMD_DATE - 1 , 'DAY') + 1 , 'YYYYMM')
                       ELSE TO_CHAR( TRUNC(YMD_DATE - 1 , 'DAY') + 1  + 6, 'YYYYMM') END  WEEK_YM,
                  TO_CHAR( TRUNC(YMD_DATE - 1 , 'DAY') + 1 , 'YYYYMMDD')   WEEK_STARTING_DT,
                  TO_CHAR( TRUNC(YMD_DATE - 1 , 'DAY') + 1  + 6, 'YYYYMMDD')  WEEK_ENDING_DT,
                  TO_CHAR(YMD_DATE , 'IW') CALENDAR_WEEK_NUM,
                  TO_CHAR(YMD_DATE , 'YYYYMM') CALENDAR_MONTH,
                  TO_CHAR(YMD_DATE , 'YYYY')  CALENDAR_YEAR,
                  TO_CHAR(LAST_DAY(YMD_DATE), 'DD')   DAYS_IN_CAL_MONTH ,
                  TO_CHAR(YMD_DATE , 'MON') CALENDAR_MONTH_NAME,
                  TO_CHAR(YMD_DATE , 'DDD')  DAYS_IN_CAL_YEAR
              FROM
                  (
                    SELECT ldt_fr_dt + LVL -1  YMD_DATE,
                           TO_CHAR ( ldt_fr_dt + LVL -1 , 'YYYYMMDD') YMD
                      FROM
                            (
                              SELECT LEVEL LVL
                                FROM DUAL
                             CONNECT BY  LEVEL   <=  ldt_to_dt - ldt_fr_dt + 1
                            ) A
                  ) A
            ) A
            ;
END;

/
