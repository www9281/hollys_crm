--------------------------------------------------------
--  DDL for Procedure SP_MENU_STOR_GROUP
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_MENU_STOR_GROUP" 
/******************************************************************************
   NAME     :  SP_MENU_STOR_GROUP
   PURPOSE  :  점포 직원구분별 메뉴 저장, 삭제 수정

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     SP_MENU_STOR_GROUP
      Sysdate:         2015-05-12
      Date and Time:   2015-05-12, 오후 8:03:43, and 2009-12-15 오후 8:03:43
      Username:         (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
(    
     p_comp_cd      IN   VARCHAR2
,    p_emp_div      IN   VARCHAR2
,    p_menu_cd      IN   NUMBER
,    p_proc_fg      IN   CHAR
,    p_user_id      IN   VARCHAR2
,    psr_return_cd  OUT  NUMBER
,    psr_msg        OUT  VARCHAR2
)
IS
     liv_msg_code    NUMBER(9) := 0;
     lsv_msg_text    VARCHAR2(200);

     s_menu_cd_insert_yn    CHAR(1);
     s_menu_ref_delete_yn   CHAR(1);
     s_menu_user_ref        NUMBER(5);
     s_menu_ref             NUMBER(5);
     s_menu_cd              NUMBER(5);

     ERR_HANDLER     EXCEPTION;
BEGIN
     liv_msg_code    := 1;
     lsv_msg_text    := '성공.';

     IF( p_menu_cd = 0 ) THEN RETURN;
     END IF;

     IF( p_proc_fg = 'S' ) THEN
          BEGIN
               SELECT    DECODE(COUNT(*), 0 , 'Y' , 'N')
               INTO      s_menu_cd_insert_yn
               FROM      W_MENU_STORE_GROUP
               WHERE     COMP_CD  = p_comp_cd
               AND       MENU_CD  = p_menu_cd
               AND       MENU_GRP = p_emp_div;

               IF( s_menu_cd_insert_yn = 'N') THEN RETURN;
               END IF;

               INSERT INTO W_MENU_STORE_GROUP (COMP_CD, MENU_GRP , MENU_CD ,AUTHORITY, USE_YN , INST_DT , INST_USER , UPD_DT ,UPD_USER)
               VALUES(p_comp_cd, p_emp_div , p_menu_cd , 'C' , 'Y' , sysdate, p_user_id ,sysdate , p_user_id);

               BEGIN
                    SELECT    MENU_CD INTO s_menu_user_ref
                    FROM      W_MENU_STORE_GROUP
                    WHERE     COMP_CD  = p_comp_cd
                    AND       MENU_GRP = p_emp_div
                    AND       MENU_CD  = (
                                   SELECT    MENU_REF
                                   FROM      W_MENU A1
                                   ,         W_MENU_STORE_GROUP A2
                                   WHERE     A2.COMP_CD  = p_comp_cd
                                   AND       A2.MENU_CD  = p_menu_cd
                                   AND       A2.MENU_GRP = p_emp_div
                                   AND       A1.COMP_CD  = A2.COMP_CD
                                   AND       A1.MENU_CD  = A2.MENU_CD
                    )
                    GROUP BY MENU_CD;
               EXCEPTION WHEN NO_DATA_FOUND THEN
                    s_menu_user_ref := 0;
               END;

               BEGIN
                    SELECT    MENU_REF INTO s_menu_ref
                    FROM      W_MENU
                    WHERE     COMP_CD = p_comp_cd
                    AND       MENU_CD = p_menu_cd
                    AND       USE_YN  = 'Y';

               EXCEPTION WHEN NO_DATA_FOUND THEN
                    s_menu_ref := 0;
               END;

               if( s_menu_user_ref = 0  AND s_menu_ref <> 0 ) THEN
                    SP_MENU_STOR_GROUP(p_comp_cd, p_emp_div ,  s_menu_ref , 'S' , p_user_id , liv_msg_code , liv_msg_code );
               END IF;
          END;

     ELSE IF( p_proc_fg = 'D') THEN
         /*
          BEGIN
               SELECT    MENU_REF INTO s_menu_ref
               FROM      W_MENU A1
               ,         W_MENU_STOR_TP A2
               WHERE     A2.MENU_CD   = p_menu_cd
               AND       A2.STOR_TP   = p_stor_tp_cd
               AND       A1.MENU_CD   = A2.MENU_CD;

          EXCEPTION WHEN NO_DATA_FOUND THEN
               DELETE  FROM W_MENU_STOR_TP
               WHERE   MENU_CD       = p_menu_cd
               AND     STOR_TP     = s_stor_tp;

               RETURN;
          END;
         */
          BEGIN
              DELETE  FROM W_MENU_STORE_GROUP
              WHERE   COMP_CD  = p_comp_cd
              AND     MENU_CD  = p_menu_cd
              AND     MENU_GRP = p_emp_div;
            END;

        END IF;
     END IF;

EXCEPTION
     WHEN ERR_HANDLER THEN
          psr_return_cd := liv_msg_code;
          psr_msg       := lsv_msg_text;
     WHEN OTHERS THEN
          psr_return_cd := liv_msg_code;
          psr_msg       := lsv_msg_text;


END SP_MENU_STOR_GROUP;

/
