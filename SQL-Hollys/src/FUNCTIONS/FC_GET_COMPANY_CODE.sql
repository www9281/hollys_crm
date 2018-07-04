--------------------------------------------------------
--  DDL for Function FC_GET_COMPANY_CODE
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."FC_GET_COMPANY_CODE" 
    RETURN VARCHAR2 IS
    
    vNXT_COMP_CD  VARCHAR2(3) := NULL;
BEGIN
    SELECT  COMP_CD_1||COMP_CD_2||COMP_CD_3 INTO vNXT_COMP_CD
    FROM   (
            SELECT  CASE WHEN ASCII(COMP_CD_2) = 90 AND ASCII(COMP_CD_3) = 90
                                                    THEN (CASE WHEN ASCII(COMP_CD_1) < 57 THEN CHR(ASCII(COMP_CD_1)+1)
                                                               WHEN ASCII(COMP_CD_1) = 57 THEN CHR(65)
                                                               WHEN ASCII(COMP_CD_1) < 90 THEN CHR(ASCII(COMP_CD_1)+1)
                                                               ELSE CHR(48) END)
                         ELSE COMP_CD_1 END COMP_CD_1,
                    CASE WHEN ASCII(COMP_CD_3) = 90 THEN (CASE WHEN ASCII(COMP_CD_2) < 57 THEN CHR(ASCII(COMP_CD_2)+1)
                                                               WHEN ASCII(COMP_CD_2) = 57 THEN CHR(65)
                                                               WHEN ASCII(COMP_CD_2) < 90 THEN CHR(ASCII(COMP_CD_2)+1)
                                                               ELSE CHR(48) END)
                         ELSE COMP_CD_2 END COMP_CD_2,
                    CASE WHEN ASCII(COMP_CD_3) < 57 THEN CHR(ASCII(COMP_CD_3)+1)
                         WHEN ASCII(COMP_CD_3) = 57 THEN CHR(65)
                         WHEN ASCII(COMP_CD_3) < 90 THEN CHR(ASCII(COMP_CD_3)+1)
                         ELSE CHR(48) END COMP_CD_3
            FROM   (            
                    SELECT  SUBSTR(COMP_CD, 1, 1) COMP_CD_1,
                            SUBSTR(COMP_CD, 2, 1) COMP_CD_2,
                            SUBSTR(COMP_CD, 3, 1) COMP_CD_3
                    FROM   (
                            SELECT NVL(MAX(COMP_CD), 'A00')||SUBSTR('000', LENGTH(NVL(MAX(COMP_CD), 'A00'))+1, 3-LENGTH(NVL(MAX(COMP_CD), 'A00'))) COMP_CD
                            FROM   COMPANY
                            WHERE  COMP_CD != 'ZZZ'
                           )
                   )
          );

    RETURN vNXT_COMP_CD;
END FC_GET_COMPANY_CODE;

/
