--------------------------------------------------------
--  DDL for Function GET_LUNAR_TRANS
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."GET_LUNAR_TRANS" ( as_lunar IN CHAR )
    RETURN VARCHAR2
    IS 
       Out_Of_Range exception;
       ls_return VARCHAR2(100);
       LunerY  NUMBER(5) := 0 ;
       LunerM  NUMBER(5) := 0 ;
       LunerD  NUMBER(5) := 0 ;
       i  NUMBER(5) := 0 ; 
       j NUMBER(5) := 0 ;

        -- 1921년부터 해당년까지의 년수
       ll_FromYear                  NUMBER(10) := 0 ;
       ls_YunMon    VARCHAR2(500);     --윤달
       ls_YunLen     VARCHAR2(500);    --윤달의 길이(29 OR 30)

--매년 정상적인 달의 길이의 합
        --( 12 byte의 자리값 * (30일인 경우만 1 ) 의 합)
       ls_MonLen     VARCHAR2(500) ;
       ls_lYearDay    VARCHAR2(500);   --음력으로 윤달의 길이(29 OR 30)
       ls_SolarMon    VARCHAR2(39) ;
       
        --0000-00-00부터 해당일자까지의 누적일수
       ll_DaySum        NUMBER(10);

       li_M NUMBER(5) := 0 ;
       MM NUMBER(5) := 0 ; 
       MK NUMBER(5):=0 ;

       v_loop NUMBER(5) :=0;

       li_PrevYear NUMBER(5):=0;
       li_OneYearDay  NUMBER(5):=0;
       NA NUMBER(5):=0;
       YD NUMBER(5):=0;
       KA NUMBER(5):=0;
       SolarY NUMBER(5):=0 ;
       SolarM NUMBER(5):=0 ;
       SolarD NUMBER(5):=0;
BEGIN
    LunerY := TO_NUMBER(SUBSTR( as_lunar,1,4)) + 2333;
    LunerM := TO_NUMBER(SUBSTR( as_lunar,5,2));
    LunerD := TO_NUMBER(SUBSTR( as_lunar,7,2));

    -- 1921-2030년 범위, 1-12월 범위, 1-31일 범위를 벗어날 경우 에러처리.
    IF (SUBSTR(as_lunar,1,4) < '1921' OR SUBSTR(as_lunar,1,4) > '2030')
       OR
       (SUBSTR(as_lunar,5,2) < '01' OR SUBSTR(as_lunar,5,2) > '12')
       OR
       (SUBSTR(as_lunar,7,2) < '01' OR SUBSTR(as_lunar,7,2) > '31')
       THEN
       raise Out_Of_Range;
    END IF ;

   --1921 - 2030
   ls_YunMon := ' 0 5 0 0 4 0 0 2 0 6'|| 
' 0 0 5 0 0 3 0 7 0 0'||
' 6 0 0 4 0 0 2 0 7 0'||
' 0 5 0 0 3 0 8 0 0 6'||
' 0 0 4 0 0 3 0 7 0 0'||
' 5 0 0 4 0 8 0 0 6 0'||
' 0 4 010 0 0 6 0 0 5'||
' 0 0 3 0 8 0 0 5 0 0'||
' 4 0 0 2 0 7 0 0 5 0'||
' 0 3 0 9 0 0 5 0 0 4'||
' 0 0 2 0 6 0 0 5 0 0';
   --1921 - 2030
   ls_YunLen := ' 029 0 029 0 029 029'||
' 0 030 0 030 030 0 0'||
'30 0 030 0 029 029 0'||
' 030 0 030 029 0 029'||
' 0 029 0 029 029 0 0'||
'29 0 029 029 0 030 0'||
' 029 029 0 029 0 029'||
' 0 029 029 0 029 0 0'||
'29 0 029 029 0 029 0'||
' 030 029 0 029 0 029'||
' 0 029 029 0 029 0 0';

   --1921 - 2030
   ls_lYearDay :=
' 354 384 354 354 385 354 355 384 354 383'||
' 354 355 384 355 354 384 354 384 354 354'||
                ' 384 355 355 384 354 354 384 354 384 354'||
' 355 384 355 354 384 354 384 354 354 384'||
                ' 355 354 384 355 353 384 355 384 354 355'||
' 384 354 354 384 354 384 354 355 384 355'||
                ' 354 384 354 384 354 354 385 354 355 384'||
' 354 354 383 355 384 355 354 384 354 354'||
' 384 354 355 384 355 384 354 354 384 354'||
' 354 384 355 384 355 354 384 354 354 384'||
' 354 355 384 354 384 355 354 383 355 354';

--1921 - 2030
   ls_MonLen := 
'26352891170527722997 6942395133511751622'||
'3658374917051461 69422222350321332213402'||
                '346629211389 603 60523493371270934132890'||
'290113651243 603213513232715168517062794'||
              '2741120627342647131838783477171713862477'||
'1245119826383405336534132900343423942395'||
              '1179271526352855170117482901 69423951207'||
'117516111866374917531453 694241423503222'||
'37333402349318771389 699 605234932432709'||
'28902890290113731211 6032391132327092965'||
'1706277317171206267026471319170234751450';
   ll_DaySum := 701303  ; --1920년까지의 누적일수

   --1921년무터 해당일자 직전 년도 까지의 년수 계산
   ll_FromYear := LunerY - 4254  ;
   FOR  i IN 1..ll_FromYear LOOP
        ll_DaySum := ll_DaySum + TO_NUMBER( SubStr( ls_lYearDay, i*4-3, 4 ) );
   END LOOP;

   --해당년도의 월 계산
   IF LunerM <> 1  THEN --1월이 아닐 경우에만 월->일로 환산
         li_M := 2048;
         ll_FromYear := ll_FromYear + 1;

         MM := TO_NUMBER( SUBSTR( ls_MonLen, ll_FromYear*4-3,4 ) );

         FOR  j IN 1..LunerM - 1 LOOP
            --해당월의 일수를 누적시켜나간다.
            ll_DaySum := ll_DaySum + 29 + TRUNC(MM / li_M);

            MM := MM - TRUNC(MM / li_M) * li_M;
            li_M := TRUNC(li_M / 2);

            IF  j = TO_NUMBER( SUBSTR( ls_YunMon,ll_FromYear*2-1,2 ) )  THEN  
                --윤달일 경우
                ll_DaySum := ll_DaySum + 
                      TO_NUMBER( SUBSTR( ls_YunLen, ll_FromYear*2-1,2 ) );
            END IF;
         END LOOP ;
   END IF;

   -- 해당월의 일 누적
   ll_DaySum := ll_DaySum + LunerD;

 

   ------------------------------------------------------
   --1921년부터 해당일 까지의 누적일수를 계산하여 더한다.
   ------------------------------------------------------
   li_PrevYear := TRUNC(ll_DaySum/365) - 1    ;
   NA := TRUNC(ll_DaySum - li_PrevYear*365)    ;
   YD := TRUNC(li_PrevYear/4) 
         - TRUNC(li_PrevYear/100) 
         + TRUNC(li_PrevYear/400) ;
   KA := NA - YD  ;

   IF KA < 0 THEN
        li_PrevYear := li_PrevYear - 1;
        NA := ll_DaySum - TRUNC(li_PrevYear*365);
        YD := TRUNC(li_PrevYear/4) - TRUNC(li_PrevYear/100 )
              + TRUNC(li_PrevYear/400);
        NA := NA - YD;
   ELSE
        NA := KA;
   END IF;

   --양력으로 해당년도의 일수를 계산한다.
   SolarY := li_PrevYear + 1;
   IF   SolarY = TRUNC(SolarY/4)*4  AND  SolarY<>TRUNC(SolarY/100)*100 THEN
        ls_SolarMon :=   ' 0 31 29 31 30 31 30 31 31 30 31 30 31';
        li_OneYearDay := 366;

   ELSIF  SolarY = TRUNC(SolarY/400)*400 THEN
        ls_SolarMon :=   ' 0 31 29 31 30 31 30 31 31 30 31 30 31';
        li_OneYearDay := 366;

   ELSE
ls_SolarMon :=   ' 0 31 28 31 30 31 30 31 31 30 31 30 31';
        li_OneYearDay := 365;

   END IF;

   IF NA = 0 THEN
         NA := li_OneYearDay;
         SolarY := SolarY - 1;
   END IF;

   FOR  I IN 1..13 LOOP
        v_loop := I;
        IF  NA > TO_NUMBER( SUBSTR( ls_SolarMon,I*3-2,3 ) ) THEN
            NA := NA - TO_NUMBER( SUBSTR( ls_SolarMon,I*3-2,3 ) );
        ELSE
            EXIT;
        END IF;
   END LOOP;
   
   SolarM := v_loop - 1;
   SolarD := NA;
   ls_return := LPAD(SolarY,4,0) || 
                LPAD(SolarM,2,0) || 
                LPAD(SolarD,2,0);
   Return ls_return;

   exception 
     WHEN DUP_VAL_ON_INDEX then
          ls_return := 'DUP_VAL_ON_INDEX 입니다.';
          Return ls_return;
     WHEN INVALID_NUMBER then
          ls_return := 'INVALID_NUMBER 입니다.';
          Return ls_return;
     WHEN LOGIN_DENIED then
          ls_return := 'Login Denied.';
          Return ls_return;
     WHEN NOT_LOGGED_ON then
          ls_return := 'Not Logged On.';
          Return ls_return;
     WHEN PROGRAM_ERROR then
          ls_return := 'Program Error입니다.';
          Return ls_return;
     WHEN STORAGE_ERROR then
          ls_return := 'Storage Error입니다.';
          Return ls_return;
     WHEN TIMEOUT_ON_RESOURCE then
          ls_return := 'Timeout on resource.';
          Return ls_return;
     WHEN VALUE_ERROR then
          ls_return := 'VALUE_ERROR 입니다. ';
          Return ls_return;
     WHEN ZERO_DIVIDE then
          ls_return := 'Zero Divide .';
          Return ls_return;
     WHEN Out_Of_Range then
          ls_return := '범위(1921.01.01-2030.11.28)를 벗어났습니다.';
          Return ls_return;
     WHEN others then
          ls_return := SUBSTR(SQLERRM, 1, 100 );
          Return ls_return;
END;

/
