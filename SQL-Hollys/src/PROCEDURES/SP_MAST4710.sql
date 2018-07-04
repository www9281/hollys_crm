--------------------------------------------------------
--  DDL for Procedure SP_MAST4710
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_MAST4710" 
(
   p_comp_cd               IN    VARCHAR2
,  p_brand_cd              IN    VARCHAR2
,  p_in_dt                 IN    VARCHAR2
,  p_in_seq                IN    VARCHAR2
,  p_user_id               IN    VARCHAR2
,  psr_return_cd           OUT   NUMBER
,  psr_msg                 OUT   VARCHAR2
)
IS
   liv_msg_code            NUMBER(9) := 0;
   lsv_msg_text            VARCHAR2(200);

   s_check_sum_fg          CHAR(1);
   s_gift_cd               VARCHAR2(2);
   s_gift_no_from          VARCHAR2(21);
   s_gift_no_to            VARCHAR2(21);
   s_gift_issue_year       VARCHAR2(4);
   s_gift_issue_seq        VARCHAR2(4);

   s_gift_iss_seq          VARCHAR2(4);

   s_gift_length           NUMBER(2);
   s_gift_cnt              NUMBER(5);

   s_check_sum_mask_1      VARCHAR2(20);
   s_check_sum_mask_2      VARCHAR2(20);
   s_issue_yearseq_yn      CHAR(1);

   s_gift_no_length        NUMBER(3);
   s_cnt                   NUMBER(3);

   s_temp_check_sum        NUMBER(2);
   s_tot_check_sum         NUMBER(3);

   ERR_HANDLER             EXCEPTION;

BEGIN
   liv_msg_code    := 1;
   lsv_msg_text    := '성공.';

   -- IN_DT와 IN_SEQ를 이용한 CHECKSUM MASK를 가져온다.
   SELECT  CHECKSUM_MASK1
   ,       CHECKSUM_MASK2
   ,       USE_ISSUE_DT
   INTO    s_check_sum_mask_1
   ,       s_check_sum_mask_2
   ,       s_issue_yearseq_yn
   FROM    GIFT_CODE_MST
   WHERE   (GIFT_CD, COMP_CD) IN ( SELECT GIFT_CD , COMP_CD 
                                               FROM GIFT_IN_HD 
                                              WHERE COMP_CD = p_comp_cd
                                                AND IN_DT   = p_in_dt 
                                                AND IN_SEQ  = p_in_seq )
   ;


   -- ----------------------------------- CHECK_SUM을 제외한 상품권 코드 생성 ------------------------------------------

   SELECT  GIFT_CD
   ,       GIFT_NO_FROM
   ,       GIFT_NO_TO
   ,       LENGTH(GIFT_NO_FROM)
   ,       ISSUE_YEAR
   ,       ISSUE_SEQ
   INTO    s_gift_cd
   ,       s_gift_no_from
   ,       s_gift_no_to
   ,       s_gift_length
   ,       s_gift_issue_year
   ,       s_gift_issue_seq
   FROM    GIFT_IN_HD
   WHERE   COMP_CD = p_comp_cd
   AND     IN_DT   = p_in_dt
   AND     IN_SEQ  = p_in_seq;

   s_gift_cnt := TO_NUMBER(s_gift_no_to) - TO_NUMBER(s_gift_no_from);

   IF s_issue_yearseq_yn = 'Y'  THEN 
        s_gift_iss_seq := SUBSTR(s_gift_issue_year ,3 , 2) || s_gift_issue_seq;
   ELSE                              
        s_gift_iss_seq := '';
   END IF;

   LOOP
      INSERT INTO GIFT_IN_DT(
                  COMP_CD
            ,     IN_DT
            ,     IN_SEQ
            ,     GIFT_NO
            ,     GIFT_CREATE_FG
            ,     USE_YN
            ,     INST_DT
            ,     INST_USER
            ,     UPD_DT
            ,     UPD_USER
            )
            VALUES(
                  p_comp_cd
            ,     p_in_dt
            ,     p_in_seq
            ,     s_gift_cd || s_gift_iss_seq || LPAD( TO_CHAR(TO_NUMBER(s_gift_no_to) - s_gift_cnt) , s_gift_length , '0')
            ,     '1'
            ,     'Y'
            ,     SYSDATE
            ,     p_user_id
            ,     SYSDATE
            ,     p_user_id
            );

      s_gift_cnt := s_gift_cnt - 1;

      EXIT WHEN s_gift_cnt < 0;
   END LOOP;

   IF LENGTH(s_check_sum_mask_1) <> 0 THEN
   BEGIN
      s_gift_cnt := TO_NUMBER(s_gift_no_to) - TO_NUMBER(s_gift_no_from);

      LOOP
         s_gift_no_length := LENGTH(s_check_sum_mask_1);
         s_cnt := 1;
         s_tot_check_sum := 0;
         LOOP

            SELECT   (TO_NUMBER(NVL(SUBSTR(GIFT_NO,s_cnt,1) ,0)) * SUBSTR( s_check_sum_mask_1,s_cnt,1)) INTO s_temp_check_sum
            FROM     GIFT_IN_DT
            WHERE    COMP_CD = p_comp_cd
            AND      IN_DT   = p_in_dt
            AND      IN_SEQ  = p_in_seq
            AND      GIFT_NO = s_gift_cd || s_gift_iss_seq || LPAD( TO_CHAR(TO_NUMBER(s_gift_no_to) - s_gift_cnt) , s_gift_length , '0');

            s_cnt             := s_cnt + 1;
            s_gift_no_length  := s_gift_no_length -1 ;
            s_tot_check_sum   := TO_NUMBER(s_temp_check_sum) + TO_NUMBER(s_tot_check_sum);

            EXIT WHEN   s_gift_no_length = 0;

         END LOOP;

         UPDATE   GIFT_IN_DT A1
           SET    A1.GIFT_NO  = A1.GIFT_NO ||  MOD(10 - MOD(s_tot_check_sum, 10 ),10)
         WHERE    A1.COMP_CD  = p_comp_cd
         AND      A1.IN_DT    = p_in_dt
         AND      A1.IN_SEQ   = p_in_seq
         AND      A1.GIFT_NO = s_gift_cd || s_gift_iss_seq || LPAD( TO_CHAR(TO_NUMBER(s_gift_no_to) - s_gift_cnt) , s_gift_length , '0') ;

         s_gift_cnt := s_gift_cnt - 1;

         EXIT WHEN   s_gift_cnt < 0;
      END LOOP;
   END;
   END IF;


   IF LENGTH(s_check_sum_mask_2) <> 0 THEN
   BEGIN
      s_gift_cnt := TO_NUMBER(s_gift_no_to) - TO_NUMBER(s_gift_no_from);

      LOOP
         s_gift_no_length := LENGTH(s_check_sum_mask_2);
         s_cnt := 1;
         s_tot_check_sum := 0;
         LOOP

            SELECT   (TO_NUMBER(NVL(SUBSTR(GIFT_NO,s_cnt,1) ,0)) * SUBSTR( s_check_sum_mask_2,s_cnt,1)) INTO s_temp_check_sum
            FROM     GIFT_IN_DT
            WHERE    COMP_CD = p_comp_cd
            AND      IN_DT   = p_in_dt
            AND      IN_SEQ  = p_in_seq
            AND      GIFT_NO LIKE s_gift_cd || s_gift_iss_seq || LPAD( TO_CHAR(TO_NUMBER(s_gift_no_to) - s_gift_cnt) , s_gift_length  , '0') || '%';

            s_cnt             := s_cnt + 1;
            s_gift_no_length  := s_gift_no_length -1 ;
            s_tot_check_sum   := TO_NUMBER(s_temp_check_sum) + TO_NUMBER(s_tot_check_sum);

            EXIT WHEN   s_gift_no_length = 0;

         END LOOP;

         UPDATE   GIFT_IN_DT A1
           SET    A1.GIFT_NO  = A1.GIFT_NO ||  MOD(10 - MOD(s_tot_check_sum, 10 ),10)           
         WHERE    A1.COMP_CD  = p_comp_cd
         AND      A1.IN_DT    = p_in_dt
         AND      A1.IN_SEQ   = p_in_seq
         AND      A1.GIFT_NO  LIKE s_gift_cd || s_gift_iss_seq || LPAD( TO_CHAR(TO_NUMBER(s_gift_no_to) - s_gift_cnt) , s_gift_length , '0') || '%';

         s_gift_cnt := s_gift_cnt - 1;

         EXIT WHEN   s_gift_cnt < 0;
      END LOOP;
   END;
   END IF;
END;

/
