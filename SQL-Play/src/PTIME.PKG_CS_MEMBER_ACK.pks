CREATE OR REPLACE PACKAGE       PKG_CS_MEMBER_ACK AS 
-------------------------------------------------------------------------------- 
--  Package Name     : PKG_CS_MEMBER_ACK 
--  Description      : 회원 인증 처리[서비스업종](소켓방식)
--  Ref. Table       : 
-------------------------------------------------------------------------------- 
--  Create Date      : 2016-05-18 
--  Modify Date      :   
-------------------------------------------------------------------------------- 
   
    P_COMP_CD        VARCHAR2(4)  := '';  -- DEFAULT 
    P_BRAND_CD       VARCHAR2(4)  := ''; 
    P_STOR_CD        VARCHAR2(10) := '';   
   
    PROCEDURE GET_MEMB_INFO_10
    ( 
        PSV_COMP_CD           IN   VARCHAR2,        -- 1. 회사코드
        PSV_BRAND_CD          IN   VARCHAR2,        -- 2. 영업조직
        PSV_STOR_CD           IN   VARCHAR2,        -- 3. 점포코드
        PSV_LANG_TP           IN   VARCHAR2,        -- 4. 언어코드 
        PSV_REQ_VAL           IN   VARCHAR2,        -- 5. 조회값 
        asRetVal              OUT  VARCHAR2,        -- 6. 결과코드[0000:정상  그외는 오류] 
        asRetMsg              OUT  VARCHAR2,        -- 7. 결과메시지 
        asResult              OUT  REC_SET.M_REFCUR -- 8. 결과레코드
    );
    
    PROCEDURE GET_MEMB_INFO_20
    ( 
        PSV_COMP_CD           IN   VARCHAR2,        -- 1. 회사코드 
        PSV_LANG_TP           IN   VARCHAR2,        -- 2. 언어코드 
        PSV_BRAND_CD          IN   VARCHAR2,        -- 3. 영업조직
        PSV_STOR_CD           IN   VARCHAR2,        -- 4. 점포코드
        PSV_MEMBER_NO         IN   VARCHAR2,        -- 5. 회원번호
        asRetVal              OUT  VARCHAR2,        -- 6. 결과코드[0000:정상  그외는 오류] 
        asRetMsg              OUT  VARCHAR2,        -- 7. 결과메시지 
        asResult              OUT  REC_SET.M_REFCUR -- 8. 결과레코드
    );
    
    PROCEDURE GET_MEMB_INFO_30
    ( 
        PSV_COMP_CD           IN   VARCHAR2,        -- 1. 회사코드
        PSV_BRAND_CD          IN   VARCHAR2,        -- 2. 영업조직
        PSV_STOR_CD           IN   VARCHAR2,        -- 3. 점포코드
        PSV_LANG_TP           IN   VARCHAR2,        -- 4. 언어코드 
        PSV_MEMBER_NM         IN   VARCHAR2,        -- 5. 회원명
        PSV_MOBILE            IN   VARCHAR2,        -- 6. 핸드폰번호(FULL) 
        asRetVal              OUT  VARCHAR2,        -- 7. 결과코드[0000:정상  그외는 오류] 
        asRetMsg              OUT  VARCHAR2,        -- 8. 결과메시지 
        asResult              OUT  REC_SET.M_REFCUR -- 9. 결과레코드
    );
    
    PROCEDURE SET_MEMB_INFO_10
    ( 
        PSV_COMP_CD           IN   VARCHAR2,        -- 1. 회사코드 
        PSV_LANG_TP           IN   VARCHAR2,        -- 2. 언어코드 
        PSV_BRAND_CD          IN   VARCHAR2,        -- 3. 영업조직
        PSV_STOR_CD           IN   VARCHAR2,        -- 4. 점포코드
        PSV_MEMBER            IN   VARCHAR2,        -- 5. 부모정보
        PSV_CARD_ID           IN   VARCHAR2,        -- 6. 회원카드번호
        PSV_CHILD_CNT         IN   VARCHAR2,        -- 7. 자녀수
        PSV_MEMBER_CHILD      IN   VARCHAR2,        -- 8. 자녀정보
        PSV_TEL_CNT           IN   VARCHAR2,        -- 9. 회원연락처수
        PSV_MEMBER_TEL        IN   VARCHAR2,        -- 10.회원연락처정보
        asRetVal              OUT  VARCHAR2,        -- 11.결과코드[0000:정상  그외는 오류] 
        asRetMsg              OUT  VARCHAR2,        -- 12.결과메시지 
        asResult              OUT  REC_SET.M_REFCUR -- 13.결과레코드
    );
    
    PROCEDURE SET_MEMB_CHG_20 
   ( 
    PSV_COMP_CD           IN   VARCHAR2, -- 1. 회사코드 
    PSV_LANG_TP           IN   VARCHAR2, -- 2. 언어코드 
    PSV_CARD_ID           IN   VARCHAR2, -- 3. 카드번호 
    PSV_USE_DT            IN   VARCHAR2, -- 4. 사용일자 
    PSV_MEMB_DIV          IN   VARCHAR2, -- 5. 멤버십구분[1: 충전금액, 2: 포인트] 
    PSV_SALE_DIV          IN   VARCHAR2, -- 6. 판매구분 
    PSV_USE_AMT           IN   VARCHAR2, -- 7. 사용금액 
    PSV_SAV_MLG           IN   VARCHAR2, -- 8. 적립마일리지 
    PSV_SAV_PT            IN   VARCHAR2, -- 9. 적립포인트 
    PSV_USE_PT            IN   VARCHAR2, -- 10. 사용포인트 
    PSV_BRAND_CD          IN   VARCHAR2, -- 11. 영업조직 
    PSV_STOR_CD           IN   VARCHAR2, -- 12. 점포코드 
    PSV_POS_NO            IN   VARCHAR2, -- 13. 포스번호 
    PSV_BILL_NO           IN   VARCHAR2, -- 14. 영수증번호 
    PSV_USE_TM            IN   VARCHAR2, -- 15. 사용시간 
    PSV_ORG_USE_DT        IN   VARCHAR2, -- 16. 원거래일자 
    PSV_ORG_USE_SEQ       IN   VARCHAR2, -- 17. 원거래일련번호 
    asRetVal              OUT  VARCHAR2, -- 18. 결과코드[1:정상  그외는 오류] 
    asRetMsg              OUT  VARCHAR2, -- 19. 결과메시지 
    asResult              OUT  REC_SET.M_REFCUR 
   ); 
   
    PROCEDURE GET_MEMBSHIP_INFO_10
    ( 
        PSV_COMP_CD           IN   VARCHAR2,        -- 1. 회사코드 
        PSV_LANG_TP           IN   VARCHAR2,        -- 2. 언어코드 
        PSV_BRAND_CD          IN   VARCHAR2,        -- 3. 영업조직
        PSV_STOR_CD           IN   VARCHAR2,        -- 4. 점포코드
        PSV_MEMBER_NO         IN   VARCHAR2,        -- 5. 회원번호
        asRetVal              OUT  VARCHAR2,        -- 6. 결과코드[0000:정상  그외는 오류] 
        asRetMsg              OUT  VARCHAR2,        -- 7. 결과메시지 
        asResult              OUT  REC_SET.M_REFCUR -- 8. 결과레코드
    );
    
    PROCEDURE SET_MEMBSHIP_INFO_10
    ( 
        PSV_COMP_CD           IN   VARCHAR2,        -- 1. 회사코드 
        PSV_LANG_TP           IN   VARCHAR2,        -- 2. 언어코드
        PSV_PROC_DIV          IN   VARCHAR2,        -- 3. 처리구분(1:판매, 2:판매반품/환불, 3:사용, 4:사용취소(사용반품), 5:환불요청)
        PSV_SALE_DT           IN   VARCHAR2,        -- 4. 처리일자
        PSV_BRAND_CD          IN   VARCHAR2,        -- 5. 영업조직
        PSV_STOR_CD           IN   VARCHAR2,        -- 6. 점포코드
        PSV_PROGRAM_ID        IN   VARCHAR2,        -- 7. 프로그램ID
        PSV_MBS_DIV           IN   VARCHAR2,        -- 8. 회원권종류(1:시간권, 2:횟수권, 3:금액권)
        PSV_MBS_NO            IN   VARCHAR2,        -- 9. 회원권번호
        PSV_CERT_NO           IN   VARCHAR2,        -- 10.인증번호
        PSV_APPR_SEQ          IN   VARCHAR2,        -- 11.승인번호
        PSV_MEMBER_NO         IN   VARCHAR2,        -- 12.회원번호
        PSV_CHILD_NO          IN   VARCHAR2,        -- 13.자녀번호
        PSV_POS_NO            IN   VARCHAR2,        -- 14.포스번호
        PSV_BILL_NO           IN   VARCHAR2,        -- 15.영수증번호
        PSV_SALE_SEQ          IN   VARCHAR2,        -- 16.판매순번
        PSV_ENTR_PRC          IN   VARCHAR2,        -- 17.1회 입장료
        PSV_SALE_AMT          IN   VARCHAR2,        -- 18.판매금액
        PSV_DC_AMT            IN   VARCHAR2,        -- 19.할인금액
        PSV_GRD_AMT           IN   VARCHAR2,        -- 20.결제금액
        PSV_CHARGE_YN         IN   VARCHAR2,        -- 21.유무상구분
        PSV_PROC_TM           IN   VARCHAR2,        -- 22.처리시간(시간권 : 사용시간, 횟수권 : 기본이용시간 * 사용횟수)
        PSV_PROC_CNT          IN   VARCHAR2,        -- 23.처리횟수(횟수권만 사용횟수 전달)
        PSV_PROC_AMT          IN   VARCHAR2,        -- 24.처리금액(시간권 : 사용시간 * 분단위 단가(잔여금액의 조정필요), 횟수권 : 사용횟수 * 횟수단위 단가(잔여금액의 조정필요), 금액권 : 사용금액)
        PSV_MATL_CNT          IN   VARCHAR2,        -- 25.교구횟수(1:제공횟수, 2:0, 3:사용횟수, 4:취소횟수, 5:0)
        asRetVal              OUT  VARCHAR2,        -- 26.결과코드[0000:정상  그외는 오류] 
        asRetMsg              OUT  VARCHAR2,        -- 27.결과메시지 
        asResult              OUT  REC_SET.M_REFCUR -- 28.결과레코드
    );
    
    PROCEDURE SET_MEMBSHIP_INFO_11
    ( 
        PSV_COMP_CD           IN   VARCHAR2,        -- 1. 회사코드 
        PSV_LANG_TP           IN   VARCHAR2,        -- 2. 언어코드
        PSV_PROC_DIV          IN   VARCHAR2,        -- 3. 처리구분(1:판매, 2:판매반품/환불, 3:사용, 4:사용취소(사용반품), 5:환불요청)
        PSV_SALE_DT           IN   VARCHAR2,        -- 4. 처리일자
        PSV_BRAND_CD          IN   VARCHAR2,        -- 5. 영업조직
        PSV_STOR_CD           IN   VARCHAR2,        -- 6. 점포코드
        PSV_PROGRAM_ID        IN   VARCHAR2,        -- 7. 프로그램ID
        PSV_MBS_DIV           IN   VARCHAR2,        -- 8. 회원권종류(1:시간권, 2:횟수권, 3:금액권)
        PSV_MBS_NO            IN   VARCHAR2,        -- 9. 회원권번호
        PSV_CERT_NO           IN   VARCHAR2,        -- 10.인증번호
        PSV_APPR_SEQ          IN   VARCHAR2,        -- 11.승인번호
        PSV_MEMBER_NO         IN   VARCHAR2,        -- 12.회원번호
        PSV_CHILD_NO          IN   VARCHAR2,        -- 13.자녀번호
        PSV_POS_NO            IN   VARCHAR2,        -- 14.포스번호
        PSV_BILL_NO           IN   VARCHAR2,        -- 15.영수증번호
        PSV_SALE_SEQ          IN   VARCHAR2,        -- 16.판매순번
        PSV_ENTR_PRC          IN   VARCHAR2,        -- 17.1회 입장료
        PSV_SALE_AMT          IN   VARCHAR2,        -- 18.판매금액
        PSV_DC_AMT            IN   VARCHAR2,        -- 19.할인금액
        PSV_GRD_AMT           IN   VARCHAR2,        -- 20.결제금액
        PSV_CHARGE_YN         IN   VARCHAR2,        -- 21.유무상구분
        PSV_PROC_TM           IN   VARCHAR2,        -- 22.처리시간(시간권 : 사용시간, 횟수권 : 기본이용시간 * 사용횟수)
        PSV_PROC_CNT          IN   VARCHAR2,        -- 23.처리횟수(횟수권만 사용횟수 전달)
        PSV_PROC_AMT          IN   VARCHAR2,        -- 24.처리금액(시간권 : 사용시간 * 분단위 단가(잔여금액의 조정필요), 횟수권 : 사용횟수 * 횟수단위 단가(잔여금액의 조정필요), 금액권 : 사용금액)
        PSV_MATL_CNT          IN   VARCHAR2,        -- 25.교구횟수(1:제공횟수, 2:0, 3:사용횟수, 4:취소횟수, 5:0)
        PSV_REMARKS           IN   VARCHAR2,        -- 26.비고
        PSV_UPD_USER          IN   VARCHAR2,        -- 27.등록자
        asRetVal              OUT  VARCHAR2,        -- 28.결과코드[0000:정상  그외는 오류] 
        asRetMsg              OUT  VARCHAR2         -- 29.결과메시지
    );
    
    PROCEDURE SET_MEMBSHIP_INFO_20
    ( 
        PSV_COMP_CD           IN   VARCHAR2,        -- 1. 회사코드 
        PSV_LANG_TP           IN   VARCHAR2,        -- 2. 언어코드
        PSV_BRAND_CD          IN   VARCHAR2,        -- 3. 영업조직
        PSV_STOR_CD           IN   VARCHAR2,        -- 4. 점포코드
        PSV_PROGRAM_ID        IN   VARCHAR2,        -- 5. 프로그램ID
        PSV_MBS_DIV           IN   VARCHAR2,        -- 6. 회원권종류(1:시간권, 2:횟수권)
        PSV_MBS_NO            IN   VARCHAR2,        -- 7. 회원권번호
        PSV_MEMBER_NO         IN   VARCHAR2,        -- 8. 회원번호
        PSV_ENTR_PRC          IN   VARCHAR2,        -- 9. 1회 입장료
        PSV_BASE_USE_TM       IN   VARCHAR2,        -- 10.기본이용시간
        PSV_SALE_AMT          IN   VARCHAR2,        -- 11.판매금액
        PSV_CHARGE_YN         IN   VARCHAR2,        -- 12.유무상구분
        PSV_OFFER_TM          IN   VARCHAR2,        -- 13.제공시간
        PSV_REMAIN_TM         IN   VARCHAR2,        -- 14.잔여시간
        PSV_OFFER_CNT         IN   VARCHAR2,        -- 15.제공횟수
        PSV_REMAIN_CNT        IN   VARCHAR2,        -- 16.잔여횟수
        PSV_OFFER_AMT         IN   VARCHAR2,        -- 17.제공금액
        PSV_REMAIN_AMT        IN   VARCHAR2,        -- 18.잔여금액
        PSV_OFFER_MCNT        IN   VARCHAR2,        -- 19.제공교구수
        PSV_REMAIN_MCNT       IN   VARCHAR2,        -- 20.잔여교구수
        PSV_CERT_TDT          IN   VARCHAR2,        -- 21.만기일자
        asRetVal              OUT  VARCHAR2,        -- 22.결과코드[0000:정상  그외는 오류] 
        asRetMsg              OUT  VARCHAR2,        -- 23.결과메시지 
        asResult              OUT  REC_SET.M_REFCUR -- 24.결과레코드
    );
    
   PROCEDURE SET_CUST_CARD_10
   (
    PSV_COMP_CD           IN   VARCHAR2, -- 1. 회사코드 
    PSV_LANG_TP           IN   VARCHAR2, -- 2. 언어코드
    PSV_MEMBER_NO         IN   VARCHAR2, -- 3. 회원번호
    PSV_CUST_ID           IN   VARCHAR2, -- 4. 회원번호
    PSV_CARD_ID           IN   VARCHAR2, -- 5. 카드번호
    asRetVal              OUT  VARCHAR2, -- 6. 결과코드[0000:정상  그외는 오류]
    asRetMsg              OUT  VARCHAR2  -- 7. 결과메시지
   );
   
    PROCEDURE SEND_SMS
    ( 
        PSV_COMP_CD           IN   VARCHAR2,        -- 1. 회사코드 
        PSV_LANG_TP           IN   VARCHAR2,        -- 2. 언어코드 
        PSV_BRAND_CD          IN   VARCHAR2,        -- 3. 영업조직
        PSV_STOR_CD           IN   VARCHAR2,        -- 4. 점포코드
        PSV_MEMBER_NO         IN   VARCHAR2,        -- 5. 회원번호
        PSV_MOBILE            IN   VARCHAR2,        -- 6. 연락처(수신번호)
        PSV_SMS_DIV           IN   VARCHAR2,        -- 7. 전송구분(1:입장, 2:퇴장, 3:단체, 4:임의발송)
        PSV_SUBJECT           IN   VARCHAR2,        -- 8. 제목
        PSV_CONTENTS          IN   VARCHAR2,        -- 9. 전송문구
        PSV_STOR_TEL          IN   VARCHAR2,        -- 10.점포연락처(발송번호)
        asRetVal              OUT  VARCHAR2,        -- 11.결과코드[0000:정상  그외는 오류] 
        asRetMsg              OUT  VARCHAR2,        -- 12.결과메시지 
        asResult              OUT  REC_SET.M_REFCUR -- 13.결과레코드
    );
    
    PROCEDURE SEND_MMS
    ( 
        PSV_COMP_CD           IN   VARCHAR2,        -- 1. 회사코드 
        PSV_LANG_TP           IN   VARCHAR2,        -- 2. 언어코드 
        PSV_BRAND_CD          IN   VARCHAR2,        -- 3. 영업조직
        PSV_STOR_CD           IN   VARCHAR2,        -- 4. 점포코드
        PSV_MEMBER_NO         IN   VARCHAR2,        -- 5. 회원번호
        PSV_MOBILE            IN   VARCHAR2,        -- 6. 연락처(수신번호)
        PSV_SMS_DIV           IN   VARCHAR2,        -- 7. 전송구분(1:입장, 2:퇴장, 3:단체, 4:임의발송)
        PSV_SUBJECT           IN   VARCHAR2,        -- 8. 제목
        PSV_CONTENTS          IN   VARCHAR2,        -- 9. 전송문구
        PSV_STOR_TEL          IN   VARCHAR2,        -- 10.점포연락처(발송번호)
        PSV_FILE_NAME         IN   VARCHAR2,        -- 11.FILE FULL NAME
        asRetVal              OUT  VARCHAR2,        -- 12.결과코드[0000:정상  그외는 오류] 
        asRetMsg              OUT  VARCHAR2,        -- 13.결과메시지 
        asResult              OUT  REC_SET.M_REFCUR -- 14.결과레코드
    );
    
    FUNCTION F_GET_CARD_ID
    (
        PSV_COMP_CD           IN   VARCHAR2, -- 1. 회사코드 
        PSV_MEMBER_NO         IN   VARCHAR2  -- 2. 회원번호
    ) RETURN VARCHAR2;
    
    FUNCTION F_GET_SAV_PT_RATE
    (
        PSV_COMP_CD           IN   VARCHAR2, -- 1. 회사코드 
        PSV_MEMBER_NO         IN   VARCHAR2  -- 2. 회원번호
    ) RETURN NUMBER;
       
END PKG_CS_MEMBER_ACK;

/

CREATE OR REPLACE PACKAGE BODY       PKG_CS_MEMBER_ACK AS
    --------------------------------------------------------------------------------
    --  Procedure Name   : GET_MEMB_INFO_10
    --  Description      : 회원 조회
    --  Ref. Table       : CS_MEMBER         회원보호자 마스터
    --                     CS_MEMBER_CHILD   회원자녀
    --                     CS_MEMBER_TEL     회원연락처
    --------------------------------------------------------------------------------
    --  Create Date      : 2016-05-18   최세원
    --  Modify Date      :  
    --------------------------------------------------------------------------------
    PROCEDURE GET_MEMB_INFO_10
    ( 
        PSV_COMP_CD           IN   VARCHAR2,        -- 1. 회사코드
        PSV_BRAND_CD          IN   VARCHAR2,        -- 2. 영업조직
        PSV_STOR_CD           IN   VARCHAR2,        -- 3. 점포코드
        PSV_LANG_TP           IN   VARCHAR2,        -- 4. 언어코드 
        PSV_REQ_VAL           IN   VARCHAR2,        -- 5. 조회값 
        asRetVal              OUT  VARCHAR2,        -- 6. 결과코드[0000:정상  그외는 오류] 
        asRetMsg              OUT  VARCHAR2,        -- 7. 결과메시지 
        asResult              OUT  REC_SET.M_REFCUR -- 8. 결과레코드
    ) IS
    
    lsSqlMain       VARCHAR2(32000) := NULL;
    nRecCnt         NUMBER(7) := 0;
    vCardStat       C_CARD.CARD_STAT%TYPE;
    
    ERR_HANDLER     EXCEPTION;
    
    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';
        
        asRetVal    := '0000';
        asRetMsg    := 'OK';
    
        lsSqlMain :=        Q'[]'
        ||CHR(13)||CHR(10)||Q'[ WITH MEMBER AS              ]'
        ||CHR(13)||CHR(10)||Q'[ (                           ]'
        ||CHR(13)||CHR(10)||Q'[     SELECT  /*+ INDEX(M IDX01_CS_MEMBER) */  ]'
        ||CHR(13)||CHR(10)||Q'[             M.COMP_CD       ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.MEMBER_NO     ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.MEMBER_NM     ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.MEMBER_DIV    ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.ORG_NM        ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.MOBILE        ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.ADDR1         ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.ADDR2         ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.REMARKS       ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.JOIN_DT       ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.BRAND_CD      ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.STOR_CD       ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.AGREE_DT      ]'
        ||CHR(13)||CHR(10)||Q'[       FROM  CS_MEMBER   M   ]'                  -- 회원 보호자
        ||CHR(13)||CHR(10)||Q'[      WHERE  M.COMP_CD   = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[        AND  M.MEMBER_NM = :PSV_REQ_VAL  ]'      --  회원명
        ||CHR(13)||CHR(10)||Q'[        AND  M.USE_YN    = 'Y'           ]'      -- 사용여부[Y:사용, N:사용안함]
        ||CHR(13)||CHR(10)||Q'[     UNION   ]'
        ||CHR(13)||CHR(10)||Q'[     SELECT  M.COMP_CD       ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.MEMBER_NO     ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.MEMBER_NM     ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.MEMBER_DIV    ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.ORG_NM        ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.MOBILE        ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.ADDR1         ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.ADDR2         ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.REMARKS       ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.JOIN_DT       ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.BRAND_CD      ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.STOR_CD       ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.AGREE_DT      ]'
        ||CHR(13)||CHR(10)||Q'[       FROM  CS_MEMBER   M   ]'                   -- 회원 보호자
        ||CHR(13)||CHR(10)||Q'[      WHERE  M.COMP_CD   = :PSV_COMP_CD         ]'
        ||CHR(13)||CHR(10)||Q'[        AND  M.MEMBER_NO = DECRYPT(:PSV_REQ_VAL)]'-- 멤버십번호
        ||CHR(13)||CHR(10)||Q'[     UNION   ]'
        ||CHR(13)||CHR(10)||Q'[     SELECT  /*+ INDEX(M IDX01_CS_MEMBER) */  ]'
        ||CHR(13)||CHR(10)||Q'[             M.COMP_CD       ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.MEMBER_NO     ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.MEMBER_NM     ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.MEMBER_DIV    ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.ORG_NM        ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.MOBILE        ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.ADDR1         ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.ADDR2         ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.REMARKS       ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.JOIN_DT       ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.BRAND_CD      ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.STOR_CD       ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.AGREE_DT      ]'
        ||CHR(13)||CHR(10)||Q'[       FROM  CS_MEMBER   M   ]'                  -- 회원 보호자
        ||CHR(13)||CHR(10)||Q'[          ,  C_CUST      U   ]'                  -- 멤버십
        ||CHR(13)||CHR(10)||Q'[          ,  C_CARD      C   ]'                  -- 멤버십카드
        ||CHR(13)||CHR(10)||Q'[      WHERE  M.COMP_CD   = U.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[        AND  M.MEMBER_NO = U.MEMBER_NO   ]'
        ||CHR(13)||CHR(10)||Q'[        AND  U.COMP_CD   = C.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[        AND  U.CUST_ID   = C.CUST_ID     ]'
        ||CHR(13)||CHR(10)||Q'[        AND  C.COMP_CD   = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[        AND  C.CARD_ID   = :PSV_REQ_VAL  ]'      --  카드
        ||CHR(13)||CHR(10)||Q'[        AND  C.USE_YN    = 'Y'           ]'      -- 사용여부[Y:사용, N:사용안함]
        ||CHR(13)||CHR(10)||Q'[     UNION   ]'
        ||CHR(13)||CHR(10)||Q'[     SELECT  /*+ INDEX(M IDX02_CS_MEMBER) */  ]'
        ||CHR(13)||CHR(10)||Q'[             M.COMP_CD       ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.MEMBER_NO     ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.MEMBER_NM     ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.MEMBER_DIV    ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.ORG_NM        ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.MOBILE        ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.ADDR1         ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.ADDR2         ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.REMARKS       ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.JOIN_DT       ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.BRAND_CD      ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.STOR_CD       ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.AGREE_DT      ]'
        ||CHR(13)||CHR(10)||Q'[       FROM  CS_MEMBER   M   ]'                      -- 회원 보호자
        ||CHR(13)||CHR(10)||Q'[      WHERE  M.COMP_CD   = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[        AND  M.MOBILE_N3 = DECRYPT(:PSV_REQ_VAL)]'   -- 연락처(뒤4자리)
        ||CHR(13)||CHR(10)||Q'[        AND  M.USE_YN    = 'Y'           ]'          -- 사용여부[Y:사용, N:사용안함]
        ||CHR(13)||CHR(10)||Q'[     UNION   ]'
        ||CHR(13)||CHR(10)||Q'[     SELECT  /*+ INDEX(M IDX04_CS_MEMBER) */  ]'
        ||CHR(13)||CHR(10)||Q'[             M.COMP_CD       ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.MEMBER_NO     ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.MEMBER_NM     ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.MEMBER_DIV    ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.ORG_NM        ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.MOBILE        ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.ADDR1         ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.ADDR2         ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.REMARKS       ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.JOIN_DT       ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.BRAND_CD      ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.STOR_CD       ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.AGREE_DT      ]'
        ||CHR(13)||CHR(10)||Q'[       FROM  CS_MEMBER   M   ]'                      -- 회원 보호자
        ||CHR(13)||CHR(10)||Q'[      WHERE  M.COMP_CD   = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[        AND  M.ORG_NM    = :PSV_REQ_VAL  ]'          -- 단체명
        ||CHR(13)||CHR(10)||Q'[        AND  M.USE_YN    = 'Y'           ]'          -- 사용여부[Y:사용, N:사용안함]
        ||CHR(13)||CHR(10)||Q'[     UNION   ]'
        ||CHR(13)||CHR(10)||Q'[     SELECT  /*+ INDEX(M IDX05_CS_MEMBER) */  ]'
        ||CHR(13)||CHR(10)||Q'[             M.COMP_CD       ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.MEMBER_NO     ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.MEMBER_NM     ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.MEMBER_DIV    ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.ORG_NM        ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.MOBILE        ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.ADDR1         ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.ADDR2         ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.REMARKS       ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.JOIN_DT       ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.BRAND_CD      ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.STOR_CD       ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.AGREE_DT      ]'
        ||CHR(13)||CHR(10)||Q'[       FROM  CS_MEMBER   M   ]'                      -- 회원 보호자
        ||CHR(13)||CHR(10)||Q'[      WHERE  M.COMP_CD   = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[        AND  (   ]'
        ||CHR(13)||CHR(10)||Q'[                 M.MOBILE    = :PSV_REQ_VAL  ]'          -- 연락처 FULL
        ||CHR(13)||CHR(10)||Q'[                 OR  ]'
        ||CHR(13)||CHR(10)||Q'[                 M.MOBILE    = DECODE(LENGTH(DECRYPT(:PSV_REQ_VAL)), 7, ENCRYPT('010'||DECRYPT(:PSV_REQ_VAL)), 8, ENCRYPT('010'||DECRYPT(:PSV_REQ_VAL)), :PSV_REQ_VAL) ]'          -- 연락처 FULL
        ||CHR(13)||CHR(10)||Q'[             )   ]'
        ||CHR(13)||CHR(10)||Q'[        AND  M.USE_YN    = 'Y'           ]'          -- 사용여부[Y:사용, N:사용안함]
        ||CHR(13)||CHR(10)||Q'[     UNION   ]'
        ||CHR(13)||CHR(10)||Q'[     SELECT  M.COMP_CD       ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.MEMBER_NO     ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.MEMBER_NM     ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.MEMBER_DIV    ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.ORG_NM        ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.MOBILE        ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.ADDR1         ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.ADDR2         ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.REMARKS       ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.JOIN_DT       ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.BRAND_CD      ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.STOR_CD       ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.AGREE_DT      ]'
        ||CHR(13)||CHR(10)||Q'[       FROM  CS_MEMBER   M   ]'                      -- 회원 보호자
        ||CHR(13)||CHR(10)||Q'[      WHERE  M.COMP_CD   = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[        AND  M.USE_YN    = 'Y'           ]'          -- 사용여부[Y:사용, N:사용안함]
        ||CHR(13)||CHR(10)||Q'[        AND  M.MEMBER_NO IN (                            ]'        
        ||CHR(13)||CHR(10)||Q'[                         SELECT  /*+ INDEX(MT IDX01_CS_MEMBER_TEL) */ ]' -- 회원연락처 연락처명
        ||CHR(13)||CHR(10)||Q'[                                 MEMBER_NO       ]'              
        ||CHR(13)||CHR(10)||Q'[                           FROM  CS_MEMBER_TEL   MT  ]'
        ||CHR(13)||CHR(10)||Q'[                          WHERE  COMP_CD     = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  TEL_NM      = :PSV_REQ_VAL  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  USE_YN      = 'Y'   ]'
        ||CHR(13)||CHR(10)||Q'[                         UNION   ]'
        ||CHR(13)||CHR(10)||Q'[                         SELECT  /*+ INDEX(MT IDX02_CS_MEMBER_TEL) */ ]' -- 회원연락처 연락처(뒤 4자리)
        ||CHR(13)||CHR(10)||Q'[                                 MEMBER_NO       ]'              
        ||CHR(13)||CHR(10)||Q'[                           FROM  CS_MEMBER_TEL   MT  ]'
        ||CHR(13)||CHR(10)||Q'[                          WHERE  COMP_CD     = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  MOBILE_N3   = DECRYPT(:PSV_REQ_VAL) ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  USE_YN      = 'Y'   ]'
        ||CHR(13)||CHR(10)||Q'[                         UNION   ]'
        ||CHR(13)||CHR(10)||Q'[                         SELECT  /*+ INDEX(MT IDX03_CS_MEMBER_TEL) */ ]' -- 회원연락처 연락처 FULL
        ||CHR(13)||CHR(10)||Q'[                                 MEMBER_NO       ]'              
        ||CHR(13)||CHR(10)||Q'[                           FROM  CS_MEMBER_TEL   MT  ]'
        ||CHR(13)||CHR(10)||Q'[                          WHERE  COMP_CD     = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  MOBILE      = :PSV_REQ_VAL  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  USE_YN      = 'Y'   ]'
        ||CHR(13)||CHR(10)||Q'[                    )        ]'
        ||CHR(13)||CHR(10)||Q'[ )                           ]'
        ||CHR(13)||CHR(10)||Q'[ SELECT  MEMBER_NO           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MEMBER_NM           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MEMBER_DIV          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ORG_NM              ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MOBILE              ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ADDR1               ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ADDR2               ]'
        ||CHR(13)||CHR(10)||Q'[      ,  REMARKS             ]'
        ||CHR(13)||CHR(10)||Q'[      ,  JOIN_DT             ]'
        ||CHR(13)||CHR(10)||Q'[      ,  AGREE_DT            ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MEM_SEX_DIV         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SMS_RCV_YN          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  STOR_CD             ]'
        ||CHR(13)||CHR(10)||Q'[      ,  STOR_NM             ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CARD_ID             ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ABLE_PT             ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SAV_PT_RATE         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MBS_CNT             ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CHILD_NO            ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CHILD_NM            ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SEX_DIV             ]'
        ||CHR(13)||CHR(10)||Q'[      ,  BIRTH_DT            ]'
        ||CHR(13)||CHR(10)||Q'[      ,  AGES                ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ANVS_DT             ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CHILD_REMARKS       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  TEL_NO              ]'
        ||CHR(13)||CHR(10)||Q'[      ,  TEL_NM              ]'
        ||CHR(13)||CHR(10)||Q'[      ,  TEL_MOBILE          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  TEL_REMARKS         ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (                   ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  /*+ USE_NL(M ME S) INDEX(CS IDX07_C_CUST) */   ]'
        ||CHR(13)||CHR(10)||Q'[                     DECRYPT(M.MEMBER_NM)||M.MEMBER_NO||'A'    AS ROW_NUM  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  M.MEMBER_NO     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  M.MEMBER_NM     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  M.MEMBER_DIV    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  M.ORG_NM        ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  M.MOBILE        ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  M.ADDR1         ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  M.ADDR2         ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  M.REMARKS       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  M.JOIN_DT       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  M.AGREE_DT      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(ME.SEX_DIV,    'F') AS MEM_SEX_DIV  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(ME.SMS_RCV_YN, 'Y') AS SMS_RCV_YN   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  M.STOR_CD       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.STOR_NM       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  PKG_CS_MEMBER_ACK.F_GET_CARD_ID(M.COMP_CD, M.MEMBER_NO) AS CARD_ID ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(CS.SAV_PT,0) - NVL(CS.USE_PT,0)- NVL(CS.LOS_PT,0)   AS ABLE_PT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  PKG_CS_MEMBER_ACK.F_GET_SAV_PT_RATE(M.COMP_CD, M.MEMBER_NO) AS SAV_PT_RATE ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MB.MBS_CNT      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS CHILD_NO     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS CHILD_NM     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS SEX_DIV      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS BIRTH_DT     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  0               AS AGES         ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS ANVS_DT      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS CHILD_REMARKS]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS TEL_NO       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS TEL_NM       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS TEL_MOBILE   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS TEL_REMARKS  ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  MEMBER          M   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  C_CUST          CS  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CS_MEMBER_EXT   ME  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  STORE           S   ]'
        ||CHR(13)||CHR(10)||Q'[                  , (                                ]'
        ||CHR(13)||CHR(10)||Q'[                     SELECT  MEM.COMP_CD             ]'
        ||CHR(13)||CHR(10)||Q'[                          ,  MEM.MEMBER_NO           ]'
        ||CHR(13)||CHR(10)||Q'[                          ,  COUNT(*) AS MBS_CNT     ]'
        ||CHR(13)||CHR(10)||Q'[                     FROM    MEMBER             MEM  ]'
        ||CHR(13)||CHR(10)||Q'[                          ,  CS_MEMBERSHIP_SALE CMS  ]'
        ||CHR(13)||CHR(10)||Q'[                     WHERE   MEM.COMP_CD   = CMS.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                     AND     MEM.MEMBER_NO = CMS.MEMBER_NO   ]'
        ||CHR(13)||CHR(10)||Q'[                     AND     CMS.MBS_STAT  = '10'    ]'
        ||CHR(13)||CHR(10)||Q'[                     AND     CMS.SALE_BRAND_CD=:PSV_BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[                     AND     CMS.SALE_STOR_CD =:PSV_STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                     GROUP BY                        ]'
        ||CHR(13)||CHR(10)||Q'[                             MEM.COMP_CD             ]'
        ||CHR(13)||CHR(10)||Q'[                          ,  MEM.MEMBER_NO           ]'
        ||CHR(13)||CHR(10)||Q'[                    ) MB                             ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  M.COMP_CD   = ME.COMP_CD(+)     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  M.MEMBER_NO = ME.MEMBER_NO(+)   ]'
        ||CHR(13)||CHR(10)||Q'[                AND  M.COMP_CD   = CS.COMP_CD(+)     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  M.MEMBER_NO = CS.MEMBER_NO(+)   ]'
        ||CHR(13)||CHR(10)||Q'[                AND  M.COMP_CD   = S.COMP_CD(+)      ]'
        ||CHR(13)||CHR(10)||Q'[                AND  M.BRAND_CD  = S.BRAND_CD(+)     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  M.STOR_CD   = S.STOR_CD(+)      ]'
        ||CHR(13)||CHR(10)||Q'[                AND  M.COMP_CD   = MB.COMP_CD(+)     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  M.MEMBER_NO = MB.MEMBER_NO(+)   ]'
        ||CHR(13)||CHR(10)||Q'[             UNION ALL               ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  /*+ USE_NL(M MC) */   ]'
        ||CHR(13)||CHR(10)||Q'[                     DECRYPT(M.MEMBER_NM)||MC.MEMBER_NO||'B'   AS ROW_NUM  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS MEMBER_NO    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS MEMBER_NM    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS MEMBER_DIV   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS ORG_NM       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS MOBILE       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS ADDR1        ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS ADDR2        ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS REMARKS      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS JOIN_DT      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS AGREE_DT     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS MEM_SEX_DIV  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS SMS_RCV_YN   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS STOR_NM      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS CARD_ID      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  0               AS ABLE_PT      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  0               AS SAV_PT_RATE  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  0               AS MBS_CNT      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MC.CHILD_NO     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MC.CHILD_NM     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MC.SEX_DIV      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MC.BIRTH_DT     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MC.AGES         ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MC.ANVS_DT      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MC.REMARKS      AS CHILD_REMARKS]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS TEL_NO       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS TEL_NM       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS TEL_MOBILE   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS TEL_REMARKS  ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  MEMBER          M   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CS_MEMBER_CHILD MC  ]' 
        ||CHR(13)||CHR(10)||Q'[              WHERE  M.COMP_CD   = MC.COMP_CD        ]'
        ||CHR(13)||CHR(10)||Q'[                AND  M.MEMBER_NO = MC.MEMBER_NO      ]'
        ||CHR(13)||CHR(10)||Q'[                AND  MC.USE_YN   = 'Y'   ]'
        ||CHR(13)||CHR(10)||Q'[             UNION ALL               ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  /*+ USE_NL(M MT) */   ]'
        ||CHR(13)||CHR(10)||Q'[                     DECRYPT(M.MEMBER_NM)||MT.MEMBER_NO||'C'   AS ROW_NUM  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS MEMBER_NO    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS MEMBER_NM    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS MEMBER_DIV   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS ORG_NM       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS MOBILE       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS ADDR1        ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS ADDR2        ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS REMARKS      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS JOIN_DT      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS AGREE_DT     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS MEM_SEX_DIV  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS SMS_RCV_YN   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS STOR_NM      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS CARD_ID      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  0               AS ABLE_PT      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  0               AS SAV_PT_RATE  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  0               AS MBS_CNT      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS CHILD_NO     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS CHILD_NM     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS SEX_DIV      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS BIRTH_DT     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  0               AS AGES         ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS ANVS_DT      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS CHILD_REMARKS]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MT.TEL_NO                       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MT.TEL_NM                       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MT.MOBILE       AS TEL_MOBILE   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MT.REMARKS      AS TEL_REMARKS  ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  MEMBER          M   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CS_MEMBER_TEL   MT  ]' 
        ||CHR(13)||CHR(10)||Q'[              WHERE  M.COMP_CD   = MT.COMP_CD        ]'
        ||CHR(13)||CHR(10)||Q'[                AND  M.MEMBER_NO = MT.MEMBER_NO      ]'
        ||CHR(13)||CHR(10)||Q'[                AND  MT.USE_YN   = 'Y'   ]'
        ||CHR(13)||CHR(10)||Q'[         )       ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY ROW_NUM, TO_NUMBER(CHILD_NO), TO_NUMBER(TEL_NO)  ]'         
        ;
        
        BEGIN
            SELECT  NVL(MAX(CARD_STAT), 'X') INTO vCardStat 
            FROM    CS_MEMBER   M
               ,    C_CUST      U
               ,    C_CARD      C
            WHERE   M.COMP_CD   = U.COMP_CD
            AND     M.MEMBER_NO = U.MEMBER_NO
            AND  U.COMP_CD   = C.COMP_CD
            AND  U.CUST_ID   = C.CUST_ID
            AND  C.COMP_CD   = PSV_COMP_CD
            AND  C.CARD_ID   = PSV_REQ_VAL;
            
            asRetVal := CASE WHEN vCardStat IN ('X', '10') THEN '0000'
                             ELSE '9001'
                        END;
            asRetMsg := CASE WHEN vCardStat IN ('X', '10') THEN 'OK'
                             ELSE FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001398')
                        END;
        EXCEPTION
            WHEN OTHERS THEN
            asRetVal    := '0000';
            asRetMsg    := 'OK';
        END;
        
        --dbms_output.put_line(lsSqlMain);
        
        OPEN asResult FOR lsSqlMain USING PSV_COMP_CD, PSV_REQ_VAL, 
                                          PSV_COMP_CD, PSV_REQ_VAL, 
                                          PSV_COMP_CD, PSV_REQ_VAL,
                                          PSV_COMP_CD, PSV_REQ_VAL,
                                          PSV_COMP_CD, PSV_REQ_VAL, 
                                          PSV_COMP_CD, PSV_REQ_VAL, PSV_REQ_VAL, PSV_REQ_VAL, PSV_REQ_VAL, PSV_REQ_VAL,
                                          PSV_COMP_CD, PSV_COMP_CD, PSV_REQ_VAL, PSV_COMP_CD, PSV_REQ_VAL, PSV_COMP_CD, PSV_REQ_VAL,
                                          PSV_BRAND_CD,PSV_STOR_CD;
        
        IF asRetVal = '0000' THEN
            asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001392'); -- 정상처리 되었습니다.
        END IF;
        
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
        
        RETURN;
        
    EXCEPTION
        WHEN ERR_HANDLER THEN
            OPEN asResult FOR
                SELECT  asRetVal
                  FROM  DUAL;
            
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
            
            RETURN;
        WHEN OTHERS THEN
            asRetVal := '9999';
            asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1004999999');  -- 자료처리중 오류가 발생했습니다. 관리자에게 문의하여 주십시오.
            --asRetMsg := SQLERRM;
            OPEN asResult FOR
                SELECT  asRetVal
                  FROM  DUAL;
            
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
            
            RETURN;
    END GET_MEMB_INFO_10;
    
    --------------------------------------------------------------------------------
    --  Procedure Name   : GET_MEMB_INFO_20
    --  Description      : 회원권/회원 방문이력/구매이력 통합조회
    --  Ref. Table       : 
    --------------------------------------------------------------------------------
    --  Create Date      : 2016-06-07   최세원
    --  Modify Date      :  
    --------------------------------------------------------------------------------
    PROCEDURE GET_MEMB_INFO_20
    ( 
        PSV_COMP_CD           IN   VARCHAR2,        -- 1. 회사코드 
        PSV_LANG_TP           IN   VARCHAR2,        -- 2. 언어코드 
        PSV_BRAND_CD          IN   VARCHAR2,        -- 3. 영업조직
        PSV_STOR_CD           IN   VARCHAR2,        -- 4. 점포코드
        PSV_MEMBER_NO         IN   VARCHAR2,        -- 5. 회원번호
        asRetVal              OUT  VARCHAR2,        -- 6. 결과코드[0000:정상  그외는 오류] 
        asRetMsg              OUT  VARCHAR2,        -- 7. 결과메시지 
        asResult              OUT  REC_SET.M_REFCUR -- 8. 결과레코드
    ) IS
    
    vBrandClass     VARCHAR2(10)    := NULL;
    vStorTp         VARCHAR2(2)     := NULL;
    
    ERR_HANDLER     EXCEPTION;
    
    BEGIN
        
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';
        
        asRetVal    := '0000';
        asRetMsg    := 'OK';
        
        MERGE   INTO CS_MEMBER_STORE
        USING   DUAL
           ON   (
                        COMP_CD     = PSV_COMP_CD
                    AND MEMBER_NO   = PSV_MEMBER_NO
                    AND BRAND_CD    = PSV_BRAND_CD
                    AND STOR_CD     = PSV_STOR_CD
                )
        WHEN MATCHED  THEN
            UPDATE      
               SET  USE_YN          = 'Y'
                 ,  UPD_DT          = SYSDATE
                 ,  UPD_USER        = 'SYSTEM'
        WHEN NOT MATCHED THEN
            INSERT 
            (
                    COMP_CD
                 ,  MEMBER_NO
                 ,  BRAND_CD
                 ,  STOR_CD
                 ,  USE_YN
                 ,  INST_DT
                 ,  INST_USER
                 ,  UPD_DT
                 ,  UPD_USER  
            ) VALUES (
                    PSV_COMP_CD
                 ,  PSV_MEMBER_NO
                 ,  PSV_BRAND_CD
                 ,  PSV_STOR_CD
                 ,  'Y'
                 ,  SYSDATE
                 ,  'SYSTEM'
                 ,  SYSDATE
                 ,  'SYSTEM'
        );
        
        SELECT  B.BRAND_CLASS, S.STOR_TP
          INTO  vBrandClass, vStorTp
          FROM  STORE   S
             ,  BRAND   B
         WHERE  B.COMP_CD   = S.COMP_CD
           AND  B.BRAND_CD  = S.BRAND_CD
           AND  S.COMP_CD   = PSV_COMP_CD
           AND  S.BRAND_CD  = PSV_BRAND_CD
           AND  S.STOR_CD   = PSV_STOR_CD
        ;
        
        OPEN asResult FOR
        SELECT  BRAND_CD                                -- 영업조직
             ,  PROGRAM_ID                              -- 프로그램ID
             ,  MBS_NO                                  -- 회원권번호
             ,  CERT_NO                                 -- 인증번호
             ,  MEMBER_NO                               -- 회원번호
             ,  MOBILE                                  -- 연락처(핸드폰)
             ,  MBS_DIV                                 -- 회원권종류(1:시간권, 2:횟수권, 3:금액권)
             ,  MBS_STAT                                -- 회원권상태
             ,  CHARGE_YN                               -- 유무상구분
             ,  CERT_FDT                                -- 구매일자
             ,  CERT_TDT                                -- 만기일자
             ,  ENTR_PRC                                -- 1회 입장료
             ,  SALE_AMT                                -- 판매금액
             ,  DC_AMT                                  -- 할인금액
             ,  GRD_AMT                                 -- 결제금액
             ,  SALE_BRAND_CD                           -- 판매영업조직
             ,  SALE_STOR_CD                            -- 판매매장코드
             ,  PER_PRICE                               -- 1분/1회당 이용금액
             ,  OFFER_TM                                -- 제공시간
             ,  USE_TM                                  -- 사용시간
             ,  OFFER_CNT                               -- 제공횟수
             ,  USE_CNT                                 -- 사용횟수
             ,  OFFER_AMT                               -- 제공금액
             ,  USE_AMT                                 -- 사용금액
             ,  OFFER_MCNT                              -- 제공 교구수
             ,  USE_MCNT                                -- 사용 교구수
             ,  REFUND_YN                               -- 환불여부
             ,  REFUND_REQ_DT                           -- 환불 요청일자
             ,  REFUND_APPR_DT                          -- 환불 승인 일자
             ,  REFUND_AMT                              -- 환불 금액
             ,  APPR_DT                                 -- 회원권 최근 사용 일자
             ,  ''          AS ENTRY_DT                 -- 입장일자
             ,  ''          AS ENTRY_FTM                -- 입장시간
             ,  ''          AS ENTRY_TTM                -- 퇴실시간
             ,  0           AS USE_TM                   -- 이용시간
             ,  ''          AS MEMBER_NM                -- 보호자명
             ,  ENCRYPT('') AS ENTRY_NM                 -- 입장자녀
             ,  0           AS GRD_AMT                  -- 결제금액
             ,  0           AS UNPAID_AMT               -- 미수금
             ,  ''          AS PROGRAM_NM               -- 프로그램[교구]
             ,  ''          AS MBS_NM                   -- 회원권명
             ,  ''          AS MBS_DIV                  -- 회원권종류
             ,  ''          AS MBS_DIV_NM               -- 회원권종류명
             ,  0           AS OFFER                    -- 제공
             ,  0           AS REMAIN                   -- 잔여
             ,  0           AS REMAIN_MCNT              -- 잔여[교구]
             ,  ''          AS CERT_FDT                 -- 구매일자
             ,  ''          AS CERT_TDT                 -- 만기일자
             ,  0           AS GRD_AMT_2                -- 결제금액
             ,  0           AS REFUND_AMT               -- 환불금액
             ,  ''          AS PROGRAM_NM_2             -- 프로그램명
          FROM  ( 
                    SELECT  M.BRAND_CD                          
                         ,  MS.PROGRAM_ID                       
                         ,  MS.MBS_NO                           
                         ,  MS.CERT_NO                          
                         ,  MS.MEMBER_NO                        
                         ,  MS.MOBILE                           
                         ,  MS.MBS_DIV                          
                         ,  MS.MBS_STAT                         
                         ,  MS.CHARGE_YN                        
                         ,  MS.CERT_FDT                         
                         ,  MS.CERT_TDT                         
                         ,  MS.ENTR_PRC                         
                         ,  MS.SALE_AMT                         
                         ,  MS.DC_AMT                           
                         ,  MS.GRD_AMT                          
                         ,  MS.SALE_BRAND_CD                    
                         ,  MS.SALE_STOR_CD                     
                         ,  CASE WHEN MS.MBS_DIV = '1' THEN ROUND(MS.GRD_AMT / MS.OFFER_TM , 2) 
                                 WHEN MS.MBS_DIV = '2' THEN ROUND(MS.GRD_AMT / MS.OFFER_CNT, 2) 
                                 ELSE 0                         
                            END             AS PER_PRICE        
                         ,  MS.OFFER_TM                         
                         ,  MS.USE_TM                           
                         ,  MS.OFFER_CNT                        
                         ,  MS.USE_CNT                          
                         ,  MS.OFFER_AMT                        
                         ,  MS.USE_AMT                          
                         ,  MS.OFFER_MCNT                       
                         ,  MS.USE_MCNT                         
                         ,  MS.REFUND_YN                        
                         ,  MS.REFUND_REQ_DT                    
                         ,  MS.REFUND_APPR_DT                   
                         ,  CASE WHEN MS.MBS_DIV = '1' THEN           -- 시간권의 환불금액 계산
                                                            CASE WHEN TRUNC(MS.GRD_AMT - (MS.ENTR_PRC * (MS.USE_TM / P.BASE_USE_TM)), -2) <= 0 THEN 0     -- 사용시간금액이 구매금액을 초과하는 경우 환불금액은 0
                                                                 ELSE TRUNC(MS.GRD_AMT - (MS.ENTR_PRC * (MS.USE_TM / P.BASE_USE_TM)), -2)                 -- 환불금액 100원단위 절삭
                                                            END 
                                 WHEN MS.MBS_DIV = '2' THEN           -- 횟수권의 환불금액 계산
                                                            CASE WHEN TRUNC(MS.GRD_AMT - (MS.ENTR_PRC * MS.USE_CNT), -2) <= 0 THEN 0                      -- 사용횟수금액이 구매금액을 초과하는 경우 환불금액은 0
                                                                 ELSE TRUNC(MS.GRD_AMT - (MS.ENTR_PRC * MS.USE_CNT), -2)                                  -- 환불금액 100원단위 절삭
                                                            END 
                                 WHEN MS.MBS_DIV = '3' THEN           -- 금액권의 환불금액 계산
                                                            CASE WHEN TRUNC(MS.GRD_AMT - MS.USE_AMT, -2) <= 0 THEN 0                                      -- 사용금액이 구매금액을 초과하는 경우 환불금액은 0
                                                                 ELSE TRUNC(MS.GRD_AMT - MS.USE_AMT, -2)                                                  -- 환불금액 100원단위 절삭
                                                            END 
                                 ELSE 0                         
                            END                 AS REFUND_AMT
                         ,  MSH.APPR_DT   
                      FROM  CS_MEMBERSHIP_SALE  MS              
                         ,  CS_MEMBERSHIP       M               
                         ,  BRAND               B               
                         ,  CS_PROGRAM          P
                         ,  (
                                SELECT  COMP_CD
                                     ,  PROGRAM_ID
                                     ,  MBS_NO
                                     ,  CERT_NO
                                     ,  MAX(APPR_DT)    AS APPR_DT
                                  FROM  CS_MEMBERSHIP_SALE_HIS
                                 WHERE  COMP_CD     = PSV_COMP_CD
                                   AND  MEMBER_NO   = PSV_MEMBER_NO
                                   AND  SALE_USE_DIV= '2'
                                   AND  USE_STAT    = '10'
                                 GROUP  BY COMP_CD, PROGRAM_ID, MBS_NO, CERT_NO
                            )   MSH                  
                     WHERE  MS.COMP_CD      = M.COMP_CD         
                       AND  MS.PROGRAM_ID   = M.PROGRAM_ID      
                       AND  MS.MBS_NO       = M.MBS_NO          
                       AND  M.COMP_CD       = B.COMP_CD         
                       AND  M.BRAND_CD      = B.BRAND_CD        
                       AND  MS.COMP_CD      = P.COMP_CD         
                       AND  MS.PROGRAM_ID   = P.PROGRAM_ID 
                       AND  MS.COMP_CD      = MSH.COMP_CD(+)
                       AND  MS.PROGRAM_ID   = MSH.PROGRAM_ID(+)
                       AND  MS.MBS_NO       = MSH.MBS_NO(+)
                       AND  MS.CERT_NO      = MSH.CERT_NO(+)     
                       AND  MS.COMP_CD      = PSV_COMP_CD      
                       AND  MS.MEMBER_NO    = PSV_MEMBER_NO    
                       AND  MS.MBS_STAT     IN ('10', '90', '91', '93')     -- 회원권상태 => 10 : 사용가능, 90 : 유효기간만료, 91:환불요청, 93:승인완료
                       AND  MS.SALE_DIV     = '1'                     -- 판매구분   => 1  : 판매
                       AND  (                                   
                                ( MS.MBS_DIV = '1' AND MS.OFFER_TM  - USE_TM  > 0 )       -- 시간권이면서  잔여시간이 남아있는 회원권
                                OR                              
                                ( MS.MBS_DIV = '2' AND MS.OFFER_CNT - USE_CNT > 0 )       -- 횟수권이면서 잔여횟수가 남아있는 회원권
                                OR                              
                                ( MS.MBS_DIV = '3' AND MS.OFFER_AMT - USE_AMT > 0 )       -- 금액권이면서 잔여금액가 남아있는 회원권
                            )                                   
                       AND  MS.USE_YN       = 'Y'                     -- 사용여부(회원권 판매)
                       AND  (                                   
                                (M.USE_DIV = '1' AND (MS.SALE_BRAND_CD = PSV_BRAND_CD AND MS.SALE_STOR_CD = PSV_STOR_CD))   -- 회원권 이용구분이 점포인 경우 구매점포에서만 사용 가능
                                OR                              
                                (M.USE_DIV = '2' AND M.BRAND_CD        = PSV_BRAND_CD                                   )   -- 회원권 이용구분이 영업조직인 경우 해당 영업조직에서만 사용 가능
                                OR                             
                                (M.USE_DIV = '3' AND B.BRAND_CLASS     = vBrandClass                                    )   -- 회원권 이용구분이 조직분류인 경우 해당 영업조직구분에서만 사용 가능
                                OR                              
                                (M.USE_DIV = '4' AND vStorTp           = '10'                                           )   -- 회원권 이용구분이 직영인경우 해당 직영점포에서만 사용 가능
                                OR                              
                                (M.USE_DIV = '5'                                                                        )   -- 회원권 이용구분이 전점포인 경우 사용가능
                            )                                   
                       AND  M.USE_YN        = 'Y'                     -- 사용여부(회원권)
                       AND  P.USE_YN        = 'Y'                     -- 사용여부(프로그램)
                     ORDER  BY MS.CERT_FDT
                )
        UNION ALL
        SELECT  ''          AS BRAND_CD
             ,  ''          AS PROGRAM_ID
             ,  ''          AS MBS_NO
             ,  ''          AS CERT_NO
             ,  ''          AS MEMBER_NO
             ,  ''          AS MOBILE
             ,  ''          AS MBS_DIV
             ,  ''          AS MBS_STAT
             ,  ''          AS CHARGE_YN
             ,  ''          AS CERT_FDT
             ,  ''          AS CERT_TDT
             ,  0           AS ENTR_PRC
             ,  0           AS SALE_AMT
             ,  0           AS DC_AMT
             ,  0           AS GRD_AMT
             ,  ''          AS SALE_BRAND_CD
             ,  ''          AS SALE_STOR_CD
             ,  0           AS PER_PRICE
             ,  0           AS OFFER_TM                         
             ,  0           AS USE_TM                           
             ,  0           AS OFFER_CNT                        
             ,  0           AS USE_CNT                          
             ,  0           AS OFFER_AMT                        
             ,  0           AS USE_AMT                          
             ,  0           AS OFFER_MCNT                       
             ,  0           AS USE_MCNT                         
             ,  ''          AS REFUND_YN                        
             ,  ''          AS REFUND_REQ_DT                    
             ,  ''          AS REFUND_APPR_DT
             ,  0           AS REFUND_AMT
             ,  ''          AS APPR_DT
             ,  ENTRY_DT    
             ,  ENTRY_FTM   
             ,  ENTRY_TTM   
             ,  USE_TM      
             ,  MEMBER_NM   
             ,  ENTRY_NM    
             ,  GRD_AMT     
             ,  UNPAID_AMT  
             ,  PROGRAM_NM  
             ,  ''          AS MBS_NM       
             ,  ''          AS MBS_DIV      
             ,  ''          AS MBS_DIV_NM   
             ,  0           AS OFFER        
             ,  0           AS REMAIN       
             ,  0           AS REMAIN_MCNT  
             ,  ''          AS CERT_FDT     
             ,  ''          AS CERT_TDT     
             ,  0           AS GRD_AMT_2    
             ,  0           AS REFUND_AMT   
             ,  ''          AS PROGRAM_NM_2 
          FROM  (   
                    SELECT  EH.ENTRY_DT              
                         ,  EH.ENTRY_FTM        
                         ,  EH.ENTRY_TTM      
                         ,  CASE WHEN EH.ENTRY_TTM IS NOT NULL THEN TRUNC(MOD(TO_DATE(EH.ENTRY_TTM, 'HH24MISS') - TO_DATE(EH.ENTRY_FTM, 'HH24MISS'), 1) * 24 * 60)    
                                 ELSE 0         
                            END     AS USE_TM          
                         ,  NVL(EH.MEMBER_NM, EH.ORG_NM)    AS MEMBER_NM        
                         ,  ENCRYPT(ED.ENTRY_NM || CASE WHEN ED.ENTRY_CNT - 2 > 0 THEN ' ' || REPLACE(FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_TP, 'PKG_CS_MEMBER_ACK_01'), '${CNT}', ED.ENTRY_CNT - 2) ELSE '' END)    AS ENTRY_NM   
                         ,  NVL(SD.GRD_AMT, 0)              AS GRD_AMT              
                         ,  SH.ROUNDING                     AS UNPAID_AMT
                         ,  ED.PROGRAM_NM||CASE WHEN MATL_ITEM_NM IS NOT NULL THEN '['||ED.MATL_ITEM_NM||']' ELSE '' END  AS PROGRAM_NM   
                      FROM  CS_ENTRY_HD     EH
                         ,  SALE_HD         SH
                         ,  (
                                SELECT  COMP_CD
                                     ,  ENTRY_NO
                                     ,  SUM(GRD_AMT)    AS GRD_AMT
                                  FROM  SALE_DT
                                 WHERE  COMP_CD     = PSV_COMP_CD
                                   AND  BRAND_CD    = PSV_BRAND_CD 
                                   AND  STOR_CD     = PSV_STOR_CD  
                                   AND  CUST_ID     = PSV_MEMBER_NO
                                   AND  CERT_NO IS NULL
                                 GROUP  BY COMP_CD, ENTRY_NO
                            )               SD
                         ,  (   
                                SELECT  E.COMP_CD            
                                     ,  E.ENTRY_NO             
                                     ,  COUNT(DISTINCT E.ENTRY_SEQ_CHD) AS ENTRY_CNT     
                                     ,  MAX(CASE WHEN E.ENTRY_SEQ = '001' THEN DECRYPT(E.ENTRY_NM) ELSE '' END)||MAX(CASE WHEN E.ENTRY_SEQ = '002' THEN ', '||DECRYPT(E.ENTRY_NM) ELSE '' END)  AS ENTRY_NM  
                                     ,  MAX(CASE WHEN E.ENTRY_SEQ = '001' AND E.PROGRAM_SEQ = '001' THEN CP.PROGRAM_NM ELSE '' END)   AS PROGRAM_NM   
                                     ,  MAX(CASE WHEN E.ENTRY_SEQ = '001' AND E.PROGRAM_SEQ = '001' THEN MI.ITEM_NM    ELSE '' END)   AS MATL_ITEM_NM 
                                  FROM  (
                                            SELECT  EH.COMP_CD
                                                 ,  EH.ENTRY_NO
                                                 ,  LPAD(ROW_NUMBER() OVER (PARTITION BY ED.COMP_CD, ED.ENTRY_NO ORDER BY ED.ENTRY_NO, ED.ENTRY_SEQ), 3, '0')   AS ENTRY_SEQ
                                                 ,  ED.ENTRY_NM
                                                 ,  LPAD(ROW_NUMBER() OVER (PARTITION BY EP.COMP_CD, EP.ENTRY_NO, EP.ENTRY_SEQ ORDER BY EP.ENTRY_NO, EP.ENTRY_SEQ, EP.PROGRAM_SEQ), 3, '0')   AS PROGRAM_SEQ
                                                 ,  EP.PROGRAM_ID
                                                 ,  EP.MATL_ITEM_CD
                                                 ,  ED.ENTRY_SEQ AS ENTRY_SEQ_CHD
                                              FROM  CS_ENTRY_HD         EH   
                                                 ,  CS_ENTRY_DT         ED   
                                                 ,  CS_ENTRY_PROGRAM    EP
                                             WHERE  EH.COMP_CD      = ED.COMP_CD      
                                               AND  EH.ENTRY_NO     = ED.ENTRY_NO   
                                               AND  ED.COMP_CD      = EP.COMP_CD    
                                               AND  ED.ENTRY_NO     = EP.ENTRY_NO   
                                               AND  ED.ENTRY_SEQ    = EP.ENTRY_SEQ
                                               AND  EH.COMP_CD      = PSV_COMP_CD  
                                               AND  EH.BRAND_CD     = PSV_BRAND_CD 
                                               AND  EH.STOR_CD      = PSV_STOR_CD  
                                               AND  EH.MEMBER_NO    = PSV_MEMBER_NO
                                               AND  EH.USE_YN       = 'Y'            
                                               AND  ED.ENTRY_DIV    = '2'           
                                               AND  ED.USE_YN       = 'Y'           
                                               AND  EP.USE_YN       = 'Y'
                                        )   E   
                                     ,  (                           
                                            SELECT  P.COMP_CD          
                                                 ,  P.PROGRAM_ID        
                                                 ,  NVL(L.LANG_NM, P.PROGRAM_NM)    AS PROGRAM_NM    
                                              FROM  CS_PROGRAM  P      
                                                 ,  LANG_TABLE  L   
                                             WHERE  L.COMP_CD(+)    = P.COMP_CD 
                                               AND  L.PK_COL(+)     = LPAD(P.PROGRAM_ID, 30, ' ')    
                                               AND  P.COMP_CD       = PSV_COMP_CD  
                                               AND  P.BRAND_CD      = PSV_BRAND_CD 
                                               AND  L.TABLE_NM(+)   = 'CS_PROGRAM'  
                                               AND  L.COL_NM(+)     = 'PROGRAM_NM'  
                                               AND  L.LANGUAGE_TP(+)= PSV_LANG_TP  
                                               AND  L.USE_YN(+)     = 'Y'              
                                        )   CP    
                                     ,  (                              
                                            SELECT  I.COMP_CD      
                                                 ,  I.ITEM_CD   
                                                 ,  NVL(L.ITEM_NM, I.ITEM_NM)   AS ITEM_NM   
                                              FROM  ITEM        I      
                                                 ,  LANG_ITEM   L   
                                             WHERE  I.COMP_CD       = L.COMP_CD(+)   
                                               AND  I.ITEM_CD       = L.ITEM_CD(+)  
                                               AND  I.COMP_CD       = PSV_COMP_CD  
                                               AND  L.LANGUAGE_TP(+)= PSV_LANG_TP  
                                               AND  L.USE_YN(+)     = 'Y'              
                                        )   MI    
                                 WHERE  E.COMP_CD       = CP.COMP_CD    
                                   AND  E.PROGRAM_ID    = CP.PROGRAM_ID  
                                   AND  E.COMP_CD       = MI.COMP_CD(+) 
                                   AND  E.MATL_ITEM_CD  = MI.ITEM_CD(+) 
                                 GROUP  BY E.COMP_CD, E.ENTRY_NO       
                            )   ED                                
                     WHERE  EH.COMP_CD      = SH.COMP_CD
                       AND  EH.ENTRY_NO     = SH.ENTRY_NO
                       AND  EH.COMP_CD      = SD.COMP_CD(+)
                       AND  EH.ENTRY_NO     = SD.ENTRY_NO(+)
                       AND  EH.COMP_CD      = ED.COMP_CD            
                       AND  EH.ENTRY_NO     = ED.ENTRY_NO         
                       AND  EH.COMP_CD      = PSV_COMP_CD   
                       AND  EH.BRAND_CD     = PSV_BRAND_CD  
                       AND  EH.STOR_CD      = PSV_STOR_CD  
                       AND  EH.MEMBER_NO    = PSV_MEMBER_NO
                       AND  EH.USE_YN       = 'Y' 
                     ORDER  BY EH.ENTRY_NO DESC, EH.ENTRY_FTM DESC 
                )         
        UNION ALL
        SELECT  ''          AS BRAND_CD
             ,  ''          AS PROGRAM_ID
             ,  ''          AS MBS_NO
             ,  ''          AS CERT_NO
             ,  ''          AS MEMBER_NO
             ,  ''          AS MOBILE
             ,  ''          AS MBS_DIV
             ,  ''          AS MBS_STAT
             ,  ''          AS CHARGE_YN
             ,  ''          AS CERT_FDT
             ,  ''          AS CERT_TDT
             ,  0           AS ENTR_PRC
             ,  0           AS SALE_AMT
             ,  0           AS DC_AMT
             ,  0           AS GRD_AMT
             ,  ''          AS SALE_BRAND_CD
             ,  ''          AS SALE_STOR_CD
             ,  0           AS PER_PRICE
             ,  0           AS OFFER_TM                         
             ,  0           AS USE_TM                           
             ,  0           AS OFFER_CNT                        
             ,  0           AS USE_CNT                          
             ,  0           AS OFFER_AMT                        
             ,  0           AS USE_AMT                          
             ,  0           AS OFFER_MCNT                       
             ,  0           AS USE_MCNT                         
             ,  ''          AS REFUND_YN                        
             ,  ''          AS REFUND_REQ_DT                    
             ,  ''          AS REFUND_APPR_DT
             ,  0           AS REFUND_AMT
             ,  ''          AS APPR_DT
             ,  ''          AS ENTRY_DT     
             ,  ''          AS ENTRY_FTM    
             ,  ''          AS ENTRY_TTM    
             ,  0           AS USE_TM       
             ,  ''          AS MEMBER_NM    
             ,  ENCRYPT('') AS ENTRY_NM 
             ,  0           AS GRD_AMT      
             ,  0           AS UNPAID_AMT   
             ,  ''          AS PROGRAM_NM   
             ,  MBS_NM       
             ,  MBS_DIV      
             ,  MBS_DIV_NM   
             ,  OFFER        
             ,  REMAIN       
             ,  REMAIN_MCNT  
             ,  CERT_FDT     
             ,  CERT_TDT     
             ,  GRD_AMT      
             ,  REFUND_AMT   
             ,  PROGRAM_NM   
          FROM  (    
                    SELECT  M.MBS_NM                            
                         ,  MSH.MBS_DIV    
                         ,  GET_COMMON_CODE_NM(PSV_COMP_CD, '01850', MSH.MBS_DIV, PSV_LANG_TP) AS MBS_DIV_NM    
                         ,  CASE WHEN MSH.MBS_DIV = '1' THEN MS.OFFER_TM    
                                 WHEN MSH.MBS_DIV = '2' THEN MS.OFFER_CNT   
                                 WHEN MSH.MBS_DIV = '3' THEN MS.OFFER_AMT   
                            END     AS OFFER    
                         ,  CASE WHEN MS.MBS_STAT IN ('10', '90') THEN  
                                      CASE WHEN MSH.MBS_DIV = '1' THEN MS.OFFER_TM  - MS.USE_TM    
                                           WHEN MSH.MBS_DIV = '2' THEN MS.OFFER_CNT - MS.USE_CNT   
                                           WHEN MSH.MBS_DIV = '3' THEN MS.OFFER_AMT - MS.USE_AMT   
                                      END   
                                 ELSE 0 
                            END     AS REMAIN    
                         ,  CASE WHEN MS.MBS_STAT IN ('10', '90') AND MS.OFFER_MCNT > 0 THEN MS.OFFER_MCNT - MS.USE_MCNT   
                                 ELSE 0  
                            END REMAIN_MCNT  
                         ,  MS.CERT_FDT         
                         ,  MS.CERT_TDT         
                         ,  MSH.GRD_AMT         
                         ,  CASE WHEN MS.MBS_STAT IN ('10', '90') THEN        
                                      CASE WHEN MS.MBS_DIV = '1' THEN     
                                                CASE WHEN TRUNC(MS.GRD_AMT - (MS.ENTR_PRC * (MS.USE_TM / P.BASE_USE_TM)), -2) <= 0 THEN 0    
                                                     ELSE TRUNC(MS.GRD_AMT - (MS.ENTR_PRC * (MS.USE_TM / P.BASE_USE_TM)), -2)               
                                                END 
                                           WHEN MS.MBS_DIV = '2' THEN      
                                                CASE WHEN TRUNC(MS.GRD_AMT - (MS.ENTR_PRC * MS.USE_CNT), -2) <= 0THEN 0                      
                                                     ELSE TRUNC(MS.GRD_AMT - (MS.ENTR_PRC * MS.USE_CNT), -2)                                
                                                END 
                                           WHEN MS.MBS_DIV = '3' THEN      
                                                CASE WHEN TRUNC(MS.GRD_AMT - MS.USE_AMT, -2) <= 0 THEN 0                                     
                                                     ELSE TRUNC(MS.GRD_AMT - MS.USE_AMT, -2)                                                
                                                END 
                                            ELSE 0                         
                                    END 
                                ELSE 0 
                            END     AS REFUND_AMT    
                         ,  P.PROGRAM_NM            
                      FROM  CS_MEMBERSHIP_SALE_HIS  MSH          
                         ,  CS_MEMBERSHIP_SALE      MS          
                         ,  (                       
                                SELECT  P.COMP_CD   
                                     ,  P.PROGRAM_ID        
                                     ,  NVL(L.LANG_NM, P.PROGRAM_NM)    AS PROGRAM_NM   
                                     ,  P.BASE_USE_TM       
                                  FROM  CS_PROGRAM      P   
                                     ,  LANG_TABLE      L   
                                 WHERE  L.COMP_CD(+)    = P.COMP_CD 
                                   AND  L.PK_COL(+)     = LPAD(P.PROGRAM_ID, 30, ' ')   
                                   AND  P.COMP_CD       = PSV_COMP_CD  
                                   AND  P.BRAND_CD      = PSV_BRAND_CD 
                                   AND  L.TABLE_NM(+)   = 'CS_PROGRAM'  
                                   AND  L.COL_NM(+)     = 'PROGRAM_NM'  
                                   AND  L.LANGUAGE_TP(+)= PSV_LANG_TP  
                                   AND  L.USE_YN(+)     = 'Y'           
                            )   P  
                         ,  (                                   
                                SELECT  M.COMP_CD               
                                     ,  M.PROGRAM_ID            
                                     ,  M.MBS_NO                
                                     ,  NVL(L.LANG_NM, M.MBS_NM)    AS MBS_NM   
                                  FROM  CS_MEMBERSHIP   M       
                                     ,  LANG_TABLE      L       
                                 WHERE  L.COMP_CD(+)    = M.COMP_CD         
                                   AND  L.PK_COL(+)     = LPAD(M.PROGRAM_ID, 30, ' ')||LPAD(M.MBS_NO, 30, ' ')  
                                   AND  M.COMP_CD       = PSV_COMP_CD     
                                   AND  M.BRAND_CD      = PSV_BRAND_CD     
                                   AND  L.TABLE_NM(+)   = 'CS_MEMBERSHIP'    
                                   AND  L.COL_NM(+)     = 'MBS_NM'          
                                   AND  L.LANGUAGE_TP(+)= PSV_LANG_TP      
                                   AND  L.USE_YN(+)     = 'Y'               
                            )   M                               
                     WHERE  MSH.COMP_CD         = MS.COMP_CD           
                       AND  MSH.PROGRAM_ID      = MS.PROGRAM_ID      
                       AND  MSH.MBS_NO          = MS.MBS_NO            
                       AND  MSH.CERT_NO         = MS.CERT_NO           
                       AND  MSH.COMP_CD         = P.COMP_CD            
                       AND  MSH.PROGRAM_ID      = P.PROGRAM_ID        
                       AND  MSH.COMP_CD         = M.COMP_CD            
                       AND  MSH.PROGRAM_ID      = M.PROGRAM_ID        
                       AND  MSH.MBS_NO          = M.MBS_NO             
                       AND  MSH.COMP_CD         = PSV_COMP_CD        
                       AND  MSH.SALE_BRAND_CD   = PSV_BRAND_CD      
                       AND  MSH.SALE_STOR_CD    = PSV_STOR_CD       
                       AND  MSH.MEMBER_NO       = PSV_MEMBER_NO    
                       AND  MSH.SALE_USE_DIV    = '1'               
                     ORDER  BY MSH.APPR_DT DESC, MSH.APPR_TM DESC 
                ) 
        ;
        
        asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001392'); -- 정상처리 되었습니다.
        
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
        
        RETURN;
        
    EXCEPTION
        WHEN ERR_HANDLER THEN
            OPEN asResult FOR
                SELECT  asRetVal
                  FROM  DUAL;
            
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
            ROLLBACK;
            RETURN;
        WHEN OTHERS THEN
            asRetVal := '9999';
            asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1004999999');  -- 자료처리중 오류가 발생했습니다. 관리자에게 문의하여 주십시오.
            --asRetMsg := SQLERRM;
            OPEN asResult FOR
                SELECT  asRetVal
                  FROM  DUAL;
            
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
            ROLLBACK;
            RETURN;
    END GET_MEMB_INFO_20;
    
    --------------------------------------------------------------------------------
    --  Procedure Name   : GET_MEMB_INFO_30
    --  Description      : 중복가입 회원 조회
    --  Ref. Table       : CS_MEMBER         회원보호자 마스터
    --                     CS_MEMBER_CHILD   회원자녀
    --                     CS_MEMBER_TEL     회원연락처
    --------------------------------------------------------------------------------
    --  Create Date      : 2016-11-14   최세원
    --  Modify Date      :  
    --------------------------------------------------------------------------------
    PROCEDURE GET_MEMB_INFO_30
    ( 
        PSV_COMP_CD           IN   VARCHAR2,        -- 1. 회사코드
        PSV_BRAND_CD          IN   VARCHAR2,        -- 2. 영업조직
        PSV_STOR_CD           IN   VARCHAR2,        -- 3. 점포코드
        PSV_LANG_TP           IN   VARCHAR2,        -- 4. 언어코드 
        PSV_MEMBER_NM         IN   VARCHAR2,        -- 5. 회원명
        PSV_MOBILE            IN   VARCHAR2,        -- 6. 핸드폰번호(FULL) 
        asRetVal              OUT  VARCHAR2,        -- 7. 결과코드[0000:정상  그외는 오류] 
        asRetMsg              OUT  VARCHAR2,        -- 8. 결과메시지 
        asResult              OUT  REC_SET.M_REFCUR -- 9. 결과레코드
    ) IS
    
    lsSqlMain       VARCHAR2(32000) := NULL;
    nRecCnt         NUMBER(7) := 0;
    
    ERR_HANDLER     EXCEPTION;
    
    BEGIN
        
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';
        
        asRetVal    := '0000';
        asRetMsg    := 'OK';
    
        lsSqlMain :=        Q'[]'
        ||CHR(13)||CHR(10)||Q'[ WITH MEMBER AS              ]'
        ||CHR(13)||CHR(10)||Q'[ (                           ]'
        ||CHR(13)||CHR(10)||Q'[     SELECT  /*+ INDEX(M IDX05_CS_MEMBER) */  ]'
        ||CHR(13)||CHR(10)||Q'[             M.COMP_CD       ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.MEMBER_NO     ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.MEMBER_NM     ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.MEMBER_DIV    ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.ORG_NM        ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.MOBILE        ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.ADDR1         ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.ADDR2         ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.REMARKS       ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.JOIN_DT       ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.BRAND_CD      ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.STOR_CD       ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M.AGREE_DT      ]'
        ||CHR(13)||CHR(10)||Q'[       FROM  CS_MEMBER   M   ]'                  -- 회원 보호자
        ||CHR(13)||CHR(10)||Q'[      WHERE  M.COMP_CD   = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[        AND  M.MEMBER_NM = :PSV_MEMBER_NM]'      -- 회원명
        ||CHR(13)||CHR(10)||Q'[        AND  M.MOBILE    = :PSV_MOBILE   ]'      -- 핸드폰번호
        ||CHR(13)||CHR(10)||Q'[        AND  M.USE_YN    = 'Y'           ]'      -- 사용여부[Y:사용, N:사용안함]
        ||CHR(13)||CHR(10)||Q'[ )                           ]'
        ||CHR(13)||CHR(10)||Q'[ SELECT  MEMBER_NO           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MEMBER_NM           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MEMBER_DIV          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ORG_NM              ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MOBILE              ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ADDR1               ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ADDR2               ]'
        ||CHR(13)||CHR(10)||Q'[      ,  REMARKS             ]'
        ||CHR(13)||CHR(10)||Q'[      ,  JOIN_DT             ]'
        ||CHR(13)||CHR(10)||Q'[      ,  AGREE_DT            ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MEM_SEX_DIV         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SMS_RCV_YN          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  STOR_CD             ]'
        ||CHR(13)||CHR(10)||Q'[      ,  STOR_NM             ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CARD_ID             ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ABLE_PT             ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SAV_PT_RATE         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MBS_CNT             ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CHILD_NO            ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CHILD_NM            ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SEX_DIV             ]'
        ||CHR(13)||CHR(10)||Q'[      ,  BIRTH_DT            ]'
        ||CHR(13)||CHR(10)||Q'[      ,  AGES                ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ANVS_DT             ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CHILD_REMARKS       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  TEL_NO              ]'
        ||CHR(13)||CHR(10)||Q'[      ,  TEL_NM              ]'
        ||CHR(13)||CHR(10)||Q'[      ,  TEL_MOBILE          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  TEL_REMARKS         ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (                   ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  /*+ USE_NL(M ME S) */   ]'
        ||CHR(13)||CHR(10)||Q'[                     DECRYPT(M.MEMBER_NM)||M.MEMBER_NO||'A'    AS ROW_NUM  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  M.MEMBER_NO     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  M.MEMBER_NM     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  M.MEMBER_DIV    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  M.ORG_NM        ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  M.MOBILE        ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  M.ADDR1         ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  M.ADDR2         ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  M.REMARKS       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  M.JOIN_DT       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  M.AGREE_DT      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(ME.SEX_DIV,    'F') AS MEM_SEX_DIV  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(ME.SMS_RCV_YN, 'Y') AS SMS_RCV_YN   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  M.STOR_CD       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.STOR_NM       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  PKG_CS_MEMBER_ACK.F_GET_CARD_ID(M.COMP_CD, M.MEMBER_NO) AS CARD_ID ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(CS.SAV_PT,0) - NVL(CS.USE_PT,0)- NVL(CS.LOS_PT,0)   AS ABLE_PT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  PKG_CS_MEMBER_ACK.F_GET_SAV_PT_RATE(M.COMP_CD, M.MEMBER_NO) AS SAV_PT_RATE ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MB.MBS_CNT      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS CHILD_NO     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS CHILD_NM     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS SEX_DIV      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS BIRTH_DT     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  0               AS AGES         ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS ANVS_DT      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS CHILD_REMARKS]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS TEL_NO       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS TEL_NM       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS TEL_MOBILE   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS TEL_REMARKS  ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  MEMBER          M   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  C_CUST          CS  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CS_MEMBER_EXT   ME  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  STORE           S   ]'
        ||CHR(13)||CHR(10)||Q'[                  , (                    ]'
        ||CHR(13)||CHR(10)||Q'[                     SELECT  MEM.COMP_CD             ]'
        ||CHR(13)||CHR(10)||Q'[                          ,  MEM.MEMBER_NO           ]'
        ||CHR(13)||CHR(10)||Q'[                          ,  COUNT(*) AS MBS_CNT     ]'
        ||CHR(13)||CHR(10)||Q'[                     FROM    MEMBER             MEM  ]'
        ||CHR(13)||CHR(10)||Q'[                          ,  CS_MEMBERSHIP_SALE CMS  ]'
        ||CHR(13)||CHR(10)||Q'[                     WHERE   MEM.COMP_CD   = CMS.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                     AND     MEM.MEMBER_NO = CMS.MEMBER_NO   ]'
        ||CHR(13)||CHR(10)||Q'[                     AND     CMS.MBS_STAT  = '10'            ]'
        ||CHR(13)||CHR(10)||Q'[                     AND     CMS.SALE_BRAND_CD=:PSV_BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[                     AND     CMS.SALE_STOR_CD =:PSV_STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                     GROUP BY                        ]'
        ||CHR(13)||CHR(10)||Q'[                             MEM.COMP_CD             ]'
        ||CHR(13)||CHR(10)||Q'[                          ,  MEM.MEMBER_NO           ]'
        ||CHR(13)||CHR(10)||Q'[                    ) MB                             ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  M.COMP_CD   = ME.COMP_CD(+)     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  M.MEMBER_NO = ME.MEMBER_NO(+)   ]'
        ||CHR(13)||CHR(10)||Q'[                AND  M.COMP_CD   = CS.COMP_CD(+)     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  M.MEMBER_NO = CS.MEMBER_NO(+)   ]'
        ||CHR(13)||CHR(10)||Q'[                AND  M.COMP_CD   = S.COMP_CD(+)      ]'
        ||CHR(13)||CHR(10)||Q'[                AND  M.BRAND_CD  = S.BRAND_CD(+)     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  M.STOR_CD   = S.STOR_CD(+)      ]'
        ||CHR(13)||CHR(10)||Q'[                AND  M.COMP_CD   = MB.COMP_CD(+)     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  M.MEMBER_NO = MB.MEMBER_NO(+)   ]'
        ||CHR(13)||CHR(10)||Q'[             UNION ALL               ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  /*+ USE_NL(M MC) */   ]'
        ||CHR(13)||CHR(10)||Q'[                     DECRYPT(M.MEMBER_NM)||MC.MEMBER_NO||'B'   AS ROW_NUM  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS MEMBER_NO    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS MEMBER_NM    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS MEMBER_DIV   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS ORG_NM       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS MOBILE       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS ADDR1        ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS ADDR2        ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS REMARKS      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS JOIN_DT      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS AGREE_DT     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS MEM_SEX_DIV  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS SMS_RCV_YN   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS STOR_NM      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS CARD_ID      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  0               AS ABLE_PT      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  0               AS SAV_PT_RATE  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  0               AS MBS_CNT      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MC.CHILD_NO     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MC.CHILD_NM     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MC.SEX_DIV      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MC.BIRTH_DT     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MC.AGES         ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MC.ANVS_DT      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MC.REMARKS      AS CHILD_REMARKS]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS TEL_NO       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS TEL_NM       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS TEL_MOBILE   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS TEL_REMARKS  ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  MEMBER          M   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CS_MEMBER_CHILD MC  ]' 
        ||CHR(13)||CHR(10)||Q'[              WHERE  M.COMP_CD   = MC.COMP_CD        ]'
        ||CHR(13)||CHR(10)||Q'[                AND  M.MEMBER_NO = MC.MEMBER_NO      ]'
        ||CHR(13)||CHR(10)||Q'[                AND  MC.USE_YN   = 'Y'   ]'
        ||CHR(13)||CHR(10)||Q'[             UNION ALL               ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  /*+ USE_NL(M MT) */   ]'
        ||CHR(13)||CHR(10)||Q'[                     DECRYPT(M.MEMBER_NM)||MT.MEMBER_NO||'C'   AS ROW_NUM  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS MEMBER_NO    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS MEMBER_NM    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS MEMBER_DIV   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS ORG_NM       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS MOBILE       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS ADDR1        ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS ADDR2        ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS REMARKS      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS JOIN_DT      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS AGREE_DT     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS MEM_SEX_DIV  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS SMS_RCV_YN   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS STOR_NM      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS CARD_ID      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  0               AS ABLE_PT      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  0               AS SAV_PT_RATE  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  0               AS MBS_CNT      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS CHILD_NO     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS CHILD_NM     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS SEX_DIV      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS BIRTH_DT     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  0               AS AGES         ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS ANVS_DT      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''              AS CHILD_REMARKS]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MT.TEL_NO                       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MT.TEL_NM                       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MT.MOBILE       AS TEL_MOBILE   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MT.REMARKS      AS TEL_REMARKS  ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  MEMBER          M   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CS_MEMBER_TEL   MT  ]' 
        ||CHR(13)||CHR(10)||Q'[              WHERE  M.COMP_CD   = MT.COMP_CD        ]'
        ||CHR(13)||CHR(10)||Q'[                AND  M.MEMBER_NO = MT.MEMBER_NO      ]'
        ||CHR(13)||CHR(10)||Q'[                AND  MT.USE_YN   = 'Y'   ]'
        ||CHR(13)||CHR(10)||Q'[         )       ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY ROW_NUM, TO_NUMBER(CHILD_NO), TO_NUMBER(TEL_NO)  ]'         
        ;
        
        --dbms_output.put_line(lsSqlMain);
        
        OPEN asResult FOR lsSqlMain USING PSV_COMP_CD, PSV_MEMBER_NM, PSV_MOBILE, PSV_BRAND_CD, PSV_STOR_CD;
    
        asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001392'); -- 정상처리 되었습니다.
        
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
        
        RETURN;
        
    EXCEPTION
        WHEN ERR_HANDLER THEN
            OPEN asResult FOR
                SELECT  asRetVal
                  FROM  DUAL;
            
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
            
            RETURN;
        WHEN OTHERS THEN
            asRetVal := '9999';
            asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1004999999');  -- 자료처리중 오류가 발생했습니다. 관리자에게 문의하여 주십시오.
            --asRetMsg := SQLERRM;
            OPEN asResult FOR
                SELECT  asRetVal
                  FROM  DUAL;
            
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
            
            RETURN;
    END GET_MEMB_INFO_30;
    
    --------------------------------------------------------------------------------
    --  Procedure Name   : SET_MEMB_INFO_10
    --  Description      : 회원 등록(부모/자녀/연락처)
    --  Ref. Table       : CS_MEMBER         회원보호자 마스터
    --                     CS_MEMBER_CHILD   회원자녀
    --                     CS_MEMBER_TEL     회원연락처
    --------------------------------------------------------------------------------
    --  Create Date      : 2016-05-18   최세원
    --  Modify Date      :  
    --------------------------------------------------------------------------------
    PROCEDURE SET_MEMB_INFO_10
    ( 
        PSV_COMP_CD           IN   VARCHAR2,        -- 1. 회사코드 
        PSV_LANG_TP           IN   VARCHAR2,        -- 2. 언어코드 
        PSV_BRAND_CD          IN   VARCHAR2,        -- 3. 영업조직
        PSV_STOR_CD           IN   VARCHAR2,        -- 4. 점포코드
        PSV_MEMBER            IN   VARCHAR2,        -- 5. 부모정보
        PSV_CARD_ID           IN   VARCHAR2,        -- 6. 회원카드번호
        PSV_CHILD_CNT         IN   VARCHAR2,        -- 7. 자녀수
        PSV_MEMBER_CHILD      IN   VARCHAR2,        -- 8. 자녀정보
        PSV_TEL_CNT           IN   VARCHAR2,        -- 9. 회원연락처수
        PSV_MEMBER_TEL        IN   VARCHAR2,        -- 10.회원연락처정보
        asRetVal              OUT  VARCHAR2,        -- 11.결과코드[0000:정상  그외는 오류] 
        asRetMsg              OUT  VARCHAR2,        -- 12.결과메시지 
        asResult              OUT  REC_SET.M_REFCUR -- 13.결과레코드
    ) IS
    
    -- 부모 구조체 선언
    TYPE OT_MEMBER IS RECORD   
    (   
        MEMBER_NO       VARCHAR2(30) , -- 회원번호   
        MEMBER_NM       VARCHAR2(100), -- 회원명  
        MEMBER_DIV      VARCHAR2(1)  , -- 회원구분   
        ORG_NM          VARCHAR2(100), -- 단체명     
        MOBILE          VARCHAR2(50) , -- 연락처
        ADDR1           VARCHAR2(200), -- 주소1
        ADDR2           VARCHAR2(200), -- 주소2
        REMARKS         VARCHAR2(256), -- 기타
        AGREE_DT        VARCHAR2(256)  -- 동의일자
    );
   
    TYPE TBL_MEMBER IS TABLE OF OT_MEMBER INDEX BY PLS_INTEGER; 
    
    -- 자녀 구조체 선언
    TYPE  OT_MEMBER_CHILD IS RECORD   
    (   
        CHILD_NO        VARCHAR2(10) , -- 자녀번호   
        CHILD_NM        VARCHAR2(100), -- 자녀명  
        SEX_DIV         VARCHAR2(1)  , -- 성별   
        BIRTH_DT        VARCHAR2(8)  , -- 생년월일     
        AGES            NUMBER(5)    , -- 나이
        ANVS_DT         VARCHAR2(8)  , -- 기념일
        REMARKS         VARCHAR2(256), -- 기타
        USE_YN          VARCHAR2(1)    -- 사용여부
    );
   
    TYPE TBL_MEMBER_CHILD IS TABLE OF OT_MEMBER_CHILD INDEX BY PLS_INTEGER;
    
    -- 회원연락처 구조체 선언
    TYPE OT_MEMBER_TEL IS RECORD   
    (   
        TEL_NO          VARCHAR2(10) , -- 연락처 순번  
        TEL_NM          VARCHAR2(100), -- 연락처명 
        MOBILE          VARCHAR2(50) , -- 연락처
        REMARKS         VARCHAR2(256), -- 기타
        USE_YN          VARCHAR2(1)    -- 사용여부
    );   
   
    TYPE TBL_MEMBER_TEL IS TABLE OF OT_MEMBER_TEL INDEX BY PLS_INTEGER; 
    
    lsSqlMain       VARCHAR2(32000) := NULL;
    nLoopCnt        NUMBER(7) := 0;
    nLinePosition   NUMBER(7) := 0;
    nColumnPosition NUMBER(7) := 0;
    nCheckDigit     NUMBER(7) := 0;                              -- 체크디지트
    vMemberNo       VARCHAR2(30)    := NULL;
    vMember         VARCHAR2(32000) := NULL;
    vChildNo        VARCHAR2(10)    := NULL;
    vMemberChild    VARCHAR2(32000) := NULL;
    vTelNo          VARCHAR2(10)    := NULL;
    vMemberTel      VARCHAR2(32000) := NULL;
    vIsDupYn        VARCHAR2(1)     := 'N';
    vRTNCODE        VARCHAR2(1024)   := NULL;
    vRTNMSG         VARCHAR2(1024)   := NULL;
    lsCardId        C_CARD.CARD_ID%TYPE;                    -- 회원 ID
    vCardStat       C_CARD.CARD_STAT%TYPE;
    vCmpMemberNo    C_CUST.MEMBER_NO%TYPE;
    
    
    ARR_MEMBER          TBL_MEMBER; 
    ARR_MEMBER_CHILD    TBL_MEMBER_CHILD;
    ARR_MEMBER_TEL      TBL_MEMBER_TEL; 
    ERR_HANDLER         EXCEPTION;
    
    BEGIN
        
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';
        
        asRetVal    := '0000';
        asRetMsg    := 'OK';
        
        -- 1. 부모정보(회원명C$회원구분C$단체명C$연락처C$주소1C$주소2C$기타) 취득
        vMember := PSV_MEMBER;
        
        -- 1.1 회원번호
        nColumnPosition := INSTR(vMember, CHR(29), 1, 1);
        IF nColumnPosition < 1 THEN
            asRetVal := '1001';   
            asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001515'); -- 회원정보가 올바르지 않습니다.   
            RAISE ERR_HANDLER;
        END IF;
        ARR_MEMBER(1).MEMBER_NO := TRIM(SUBSTR(vMember, 1, nColumnPosition - 1));
        vMember := SUBSTR(vMember, nColumnPosition + 1, LENGTH(vMember));
        
        -- 1.2 회원명
        nColumnPosition := INSTR(vMember, CHR(29), 1, 1);
        IF nColumnPosition < 1 THEN
            asRetVal := '1001';   
            asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001515'); -- 회원정보가 올바르지 않습니다.   
            RAISE ERR_HANDLER;
        END IF;
        ARR_MEMBER(1).MEMBER_NM := SUBSTR(vMember, 1, nColumnPosition - 1);
        vMember := SUBSTR(vMember, nColumnPosition + 1, LENGTH(vMember));
        
        -- 1.3 회원구분     
        nColumnPosition := INSTR(vMember, CHR(29), 1, 1);
        IF nColumnPosition < 1 THEN
            asRetVal := '1001';   
            asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001515'); -- 회원정보가 올바르지 않습니다.   
            RAISE ERR_HANDLER;
        END IF;
        ARR_MEMBER(1).MEMBER_DIV := SUBSTR(vMember, 1, nColumnPosition - 1);
        vMember := SUBSTR(vMember, nColumnPosition + 1, LENGTH(vMember));
        
        -- 1.4 단체명     
        nColumnPosition := INSTR(vMember, CHR(29), 1, 1);
        IF nColumnPosition < 1 THEN
            asRetVal := '1001';   
            asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001515'); -- 회원정보가 올바르지 않습니다.   
            RAISE ERR_HANDLER;
        END IF;
        ARR_MEMBER(1).ORG_NM := SUBSTR(vMember, 1, nColumnPosition - 1);
        vMember := SUBSTR(vMember, nColumnPosition + 1, LENGTH(vMember));
        
        -- 1.5 연락처     
        nColumnPosition := INSTR(vMember, CHR(29), 1, 1);
        IF nColumnPosition < 1 THEN
            asRetVal := '1001';   
            asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001515'); -- 회원정보가 올바르지 않습니다.   
            RAISE ERR_HANDLER;
        END IF;
        ARR_MEMBER(1).MOBILE := SUBSTR(vMember, 1, nColumnPosition - 1);
        vMember := SUBSTR(vMember, nColumnPosition + 1, LENGTH(vMember));
        
        -- 1.6 주소1     
        nColumnPosition := INSTR(vMember, CHR(29), 1, 1);
        IF nColumnPosition < 1 THEN
            asRetVal := '1001';   
            asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001515'); -- 회원정보가 올바르지 않습니다.   
            RAISE ERR_HANDLER;
        END IF;
        ARR_MEMBER(1).ADDR1 := SUBSTR(vMember, 1, nColumnPosition - 1);
        vMember := SUBSTR(vMember, nColumnPosition + 1, LENGTH(vMember));
        
        -- 1.7 주소2     
        nColumnPosition := INSTR(vMember, CHR(29), 1, 1);
        IF nColumnPosition < 1 THEN
            asRetVal := '1001';   
            asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001515'); -- 회원정보가 올바르지 않습니다.   
            RAISE ERR_HANDLER;
        END IF;
        ARR_MEMBER(1).ADDR2 := SUBSTR(vMember, 1, nColumnPosition - 1);
        vMember := SUBSTR(vMember, nColumnPosition + 1, LENGTH(vMember));
        
        -- 1.8 기타     
        nColumnPosition := INSTR(vMember, CHR(29), 1, 1);
        IF nColumnPosition < 1 THEN
            asRetVal := '1001';   
            asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001515'); -- 회원정보가 올바르지 않습니다.   
            RAISE ERR_HANDLER;
        END IF;
        ARR_MEMBER(1).REMARKS := SUBSTR(vMember, 1, nColumnPosition - 1);
        vMember := SUBSTR(vMember, nColumnPosition + 1, LENGTH(vMember));
        
        -- 1.9 동의일자     
        nColumnPosition := INSTR(vMember, CHR(29), 1, 1);
        IF nColumnPosition > 0 THEN
            asRetVal := '1001';   
            asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001515'); -- 회원정보가 올바르지 않습니다.   
            RAISE ERR_HANDLER;
        END IF;
        ARR_MEMBER(1).AGREE_DT := vMember;
        
        IF ARR_MEMBER(1).MEMBER_NO IS NULL THEN
            -- 2. 회원중복 체크
            BEGIN
                SELECT  DECODE(MEMBER_NO, NULL, 'N', 'Y')   AS IS_DUP_YN
                  INTO  vIsDupYn
                  FROM  CS_MEMBER
                 WHERE  COMP_CD     = PSV_COMP_CD
                   --AND  BRAND_CD    = PSV_BRAND_CD
                   --AND  STOR_CD     = PSV_STOR_CD
                   AND  MEMBER_NM   = ARR_MEMBER(1).MEMBER_NM   -- 회원명
                   AND  MOBILE      = ARR_MEMBER(1).MOBILE      -- 연락처
                   AND  ROWNUM      = 1;
            
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        vIsDupYn := 'N';
            END;
        
            IF vIsDupYn = 'Y' THEN
                asRetVal := '1002';   
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001516'); -- 이미 등록된 회원정보입니다.   
                RAISE ERR_HANDLER;
            END IF;      
        END IF;
        
        vMemberNo := ARR_MEMBER(1).MEMBER_NO;
        
        IF vMemberNo IS NULL THEN
            -- 부모회원번호 취득
            SELECT  TO_CHAR(SYSDATE, 'YY')  || 
                    LPAD(SQ_CS_MEMBER.NEXTVAL, 8, '0')  AS MEMBER_NO
              INTO  vMemberNo
              FROM  DUAL;
        END IF;
        
        -- 3. 자녀정보 취득
        vMemberChild := PSV_MEMBER_CHILD;
        
        nLoopCnt := TO_NUMBER(PSV_CHILD_CNT);
        
        FOR i IN 1 .. nLoopCnt LOOP
            -- 3.1 자녀번호
            nColumnPosition := INSTR(vMemberChild, CHR(29), 1, 1);
            IF nColumnPosition < 1 THEN
                asRetVal := '1002';   
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001515'); -- 회원정보가 올바르지 않습니다.   
                RAISE ERR_HANDLER;
            END IF;
            ARR_MEMBER_CHILD(i).CHILD_NO := TRIM(SUBSTR(vMemberChild, 1, nColumnPosition - 1));
            vMemberChild := SUBSTR(vMemberChild, nColumnPosition + 1, LENGTH(vMemberChild));
            
            -- 3.2 자녀명
            nColumnPosition := INSTR(vMemberChild, CHR(29), 1, 1);
            IF nColumnPosition < 1 THEN
                asRetVal := '1002';   
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001515'); -- 회원정보가 올바르지 않습니다.   
                RAISE ERR_HANDLER;
            END IF;
            ARR_MEMBER_CHILD(i).CHILD_NM := SUBSTR(vMemberChild, 1, nColumnPosition - 1);
            vMemberChild := SUBSTR(vMemberChild, nColumnPosition + 1, LENGTH(vMemberChild));
            
            -- 3.3 성별     
            nColumnPosition := INSTR(vMemberChild, CHR(29), 1, 1);
            IF nColumnPosition < 1 THEN
                asRetVal := '1003';   
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001515'); -- 회원정보가 올바르지 않습니다.   
                RAISE ERR_HANDLER;
            END IF;
            ARR_MEMBER_CHILD(i).SEX_DIV := SUBSTR(vMemberChild, 1, nColumnPosition - 1);
            vMemberChild := SUBSTR(vMemberChild, nColumnPosition + 1, LENGTH(vMemberChild));
            
            -- 3.4 생년월일     
            nColumnPosition := INSTR(vMemberChild, CHR(29), 1, 1);
            IF nColumnPosition < 1 THEN
                asRetVal := '1002';   
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001515'); -- 회원정보가 올바르지 않습니다.   
                RAISE ERR_HANDLER;
            END IF;
            ARR_MEMBER_CHILD(i).BIRTH_DT := SUBSTR(vMemberChild, 1, nColumnPosition - 1);
            vMemberChild := SUBSTR(vMemberChild, nColumnPosition + 1, LENGTH(vMemberChild));
            
            -- 3.5 나이     
            nColumnPosition := INSTR(vMemberChild, CHR(29), 1, 1);
            IF nColumnPosition < 1 THEN
                asRetVal := '1002';   
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001515'); -- 회원정보가 올바르지 않습니다.   
                RAISE ERR_HANDLER;
            END IF;
            ARR_MEMBER_CHILD(i).AGES := SUBSTR(vMemberChild, 1, nColumnPosition - 1);
            vMemberChild := SUBSTR(vMemberChild, nColumnPosition + 1, LENGTH(vMemberChild));
            
            -- 3.6 기념일     
            nColumnPosition := INSTR(vMemberChild, CHR(29), 1, 1);
            IF nColumnPosition < 1 THEN
                asRetVal := '1002';   
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001515'); -- 회원정보가 올바르지 않습니다.   
                RAISE ERR_HANDLER;
            END IF;
            ARR_MEMBER_CHILD(i).ANVS_DT := SUBSTR(vMemberChild, 1, nColumnPosition - 1);
            vMemberChild := SUBSTR(vMemberChild, nColumnPosition + 1, LENGTH(vMemberChild));
            
            -- 3.7 기타     
            nColumnPosition := INSTR(vMemberChild, CHR(29), 1, 1);
            IF nColumnPosition < 1 THEN
                asRetVal := '1002';   
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001515'); -- 회원정보가 올바르지 않습니다.   
                RAISE ERR_HANDLER;
            END IF;
            ARR_MEMBER_CHILD(i).REMARKS := SUBSTR(vMemberChild, 1, nColumnPosition - 1);
            vMemberChild := SUBSTR(vMemberChild, nColumnPosition + 1, LENGTH(vMemberChild));
            
            -- 3.8 사용여부     
            nLinePosition := INSTR(vMemberChild, CHR(30), 1, 1);
            IF nLinePosition > 0 THEN
                ARR_MEMBER_CHILD(i).USE_YN := SUBSTR(vMemberChild, 1, nLinePosition - 1);
            ELSE
                ARR_MEMBER_CHILD(i).USE_YN := SUBSTR(vMemberChild, 1, 1);
            END IF;
            
            vMemberChild  := SUBSTR(vMemberChild, nLinePosition + 1, LENGTH(vMemberChild));
            
        END LOOP;
        
        -- 4. 회원연락처정보 취득
        vMemberTel := PSV_MEMBER_TEL;
        
        nLoopCnt := TO_NUMBER(PSV_TEL_CNT);
        
        FOR i IN 1 .. nLoopCnt LOOP
            
            -- 4.1 연락처순번
            nColumnPosition := INSTR(vMemberTel, CHR(29), 1, 1);
            IF nColumnPosition < 1 THEN
                asRetVal := '1003';   
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001515'); -- 회원정보가 올바르지 않습니다.   
                RAISE ERR_HANDLER;
            END IF;
            ARR_MEMBER_TEL(i).TEL_NO := TRIM(SUBSTR(vMemberTel, 1, nColumnPosition - 1));
            vMemberTel := SUBSTR(vMemberTel, nColumnPosition + 1, LENGTH(vMemberTel));
            
            -- 4.2 연락처명
            nColumnPosition := INSTR(vMemberTel, CHR(29), 1, 1);
            IF nColumnPosition < 1 THEN
                asRetVal := '1003';   
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001515'); -- 회원정보가 올바르지 않습니다.   
                RAISE ERR_HANDLER;
            END IF;
            ARR_MEMBER_TEL(i).TEL_NM := SUBSTR(vMemberTel, 1, nColumnPosition - 1);
            vMemberTel := SUBSTR(vMemberTel, nColumnPosition + 1, LENGTH(vMemberTel));
            
            -- 4.3 연락처     
            nColumnPosition := INSTR(vMemberTel, CHR(29), 1, 1);
            IF nColumnPosition < 1 THEN
                asRetVal := '1003';   
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001515'); -- 회원정보가 올바르지 않습니다.   
                RAISE ERR_HANDLER;
            END IF;
            ARR_MEMBER_TEL(i).MOBILE := SUBSTR(vMemberTel, 1, nColumnPosition - 1);
            vMemberTel := SUBSTR(vMemberTel, nColumnPosition + 1, LENGTH(vMemberTel));
            
            -- 4.4 기타     
            nColumnPosition := INSTR(vMemberTel, CHR(29), 1, 1);
            IF nColumnPosition < 1 THEN
                asRetVal := '1003';   
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001515'); -- 회원정보가 올바르지 않습니다.   
                RAISE ERR_HANDLER;
            END IF;
            ARR_MEMBER_TEL(i).REMARKS := SUBSTR(vMemberTel, 1, nColumnPosition - 1);
            vMemberTel := SUBSTR(vMemberTel, nColumnPosition + 1, LENGTH(vMemberTel));
            
            -- 4.5 사용여부     
            nLinePosition := INSTR(vMemberTel, CHR(30), 1, 1);
            IF nLinePosition > 0 THEN
                ARR_MEMBER_TEL(i).USE_YN := SUBSTR(vMemberTel, 1, nLinePosition - 1);
            ELSE
                ARR_MEMBER_TEL(i).USE_YN := SUBSTR(vMemberTel, 1, 1);
            END IF;
            
            vMemberTel  := SUBSTR(vMemberTel, nLinePosition + 1, LENGTH(vMemberTel));
            
            IF vMemberNo IS NOT NULL AND ARR_MEMBER_TEL(i).TEL_NO IS NULL THEN
                -- 2. 회원연락처 중복 체크
                BEGIN
                    SELECT  DECODE(TEL_NO, NULL, 'N', 'Y')   AS IS_DUP_YN
                      INTO  vIsDupYn
                      FROM  CS_MEMBER_TEL
                     WHERE  COMP_CD     = PSV_COMP_CD
                       AND  MEMBER_NO   = vMemberNo
                       AND  MOBILE      = ARR_MEMBER_TEL(i).MOBILE
                       AND  ROWNUM      = 1;
            
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            vIsDupYn := 'N';
                END;
        
                IF vIsDupYn = 'Y' THEN
                    asRetVal := '1002';   
                    asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001505'); -- 이미 등록된 회원연락처입니다.   
                    RAISE ERR_HANDLER;
                END IF;      
            END IF;
            
        END LOOP;
        
        -- 회원카드(바코드) 유효성 체크
        IF PSV_CARD_ID IS NOT NULL THEN
            lsCardId    := decrypt(PSV_CARD_ID); 
            nCheckDigit := MOD(TO_NUMBER(SUBSTR(lsCardId,1,1))*1  + TO_NUMBER(SUBSTR(lsCardId,2,1))*3  +  
                               TO_NUMBER(SUBSTR(lsCardId,3,1))*1  + TO_NUMBER(SUBSTR(lsCardId,4,1))*3  +  
                               TO_NUMBER(SUBSTR(lsCardId,5,1))*1  + TO_NUMBER(SUBSTR(lsCardId,6,1))*3  + 
                               TO_NUMBER(SUBSTR(lsCardId,7,1))*1  + TO_NUMBER(SUBSTR(lsCardId,8,1))*3  +  
                               TO_NUMBER(SUBSTR(lsCardId,9,1))*1  + TO_NUMBER(SUBSTR(lsCardId,10,1))*3 +  
                               TO_NUMBER(SUBSTR(lsCardId,11,1))*1 + TO_NUMBER(SUBSTR(lsCardId,12,1))*3 + 
                               TO_NUMBER(SUBSTR(lsCardId,13,1))*1 + TO_NUMBER(SUBSTR(lsCardId,14,1))*3 +  
                               TO_NUMBER(SUBSTR(lsCardId,15,1))*1,10); 
               
            IF SUBSTR(lsCardId, 16, 1) != TO_CHAR(nCheckDigit, 'FM0') OR LENGTH(lsCardId) != 16 THEN 
                asRetVal := '1000'; 
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001436'); -- 유효하지 않은 고객카드 번호입니다. 
                      
                RAISE ERR_HANDLER; 
            END IF; 
       
            SELECT  CASE WHEN COUNT(*) = 0 THEN 'N' ELSE 'Y' END
                  , NVL(MAX(CRD.CARD_STAT), 'ZZ')
                  , NVL(MAX(CST.MEMBER_NO), 'ZZZZZZZZ')
            INTO    vIsDupYn, vCardStat, vCmpMemberNo
            FROM    C_CARD CRD
                 ,  C_CUST CST
            WHERE   CRD.COMP_CD = CST.COMP_CD
            AND     CRD.CUST_ID = CST.CUST_ID
            AND     CRD.COMP_CD = PSV_COMP_CD
            AND     CRD.CARD_ID = PSV_CARD_ID;
            
            -- 폐기된 카드인지 체크
            IF vCardStat NOT IN ('10', 'ZZ') THEN
                asRetVal := '1000';
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001398'); -- 폐기된 카드번호 입니다.    
                RAISE ERR_HANDLER;
            END IF;
            
            -- 등록된 카드인지 체크
            IF vCmpMemberNo != vMemberNo AND vIsDupYn = 'Y' THEN
                asRetVal := '1000';
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001428'); -- 이미 등록된 카드번호 입니다.    
                RAISE ERR_HANDLER;
            END IF;
            
            -- 유효한 카드인지 체크
            SELECT  CASE WHEN COUNT(*) = 0 THEN 'X' ELSE 'N' END INTO vIsDupYn
            FROM    C_CARD_TYPE_REP
            WHERE   COMP_CD = PSV_COMP_CD
            AND     DECRYPT(PSV_CARD_ID) BETWEEN DECRYPT(START_CARD_CD) AND DECRYPT(CLOSE_CARD_CD);
            
            IF vIsDupYn = 'X' THEN
                asRetVal := '1000';
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001436'); -- 유효하지 않은 고객카드 번호입니다.    
                RAISE ERR_HANDLER;
            END IF;
        END IF;
        
        -- 4. 회원정보 저장
        -- 4.1 부모정보 등록
        MERGE   INTO CS_MEMBER
        USING   DUAL
           ON   (
                        COMP_CD     = PSV_COMP_CD
                    AND MEMBER_NO   = vMemberNo
                )
        WHEN MATCHED  THEN
            UPDATE      
               SET  MEMBER_NM       = ARR_MEMBER(1).MEMBER_NM
                 ,  MEMBER_DIV      = ARR_MEMBER(1).MEMBER_DIV
                 ,  ORG_NM          = ARR_MEMBER(1).ORG_NM
                 ,  MOBILE          = ARR_MEMBER(1).MOBILE
                 ,  MOBILE_N3       = SUBSTR(DECRYPT(ARR_MEMBER(1).MOBILE), LENGTH(DECRYPT(ARR_MEMBER(1).MOBILE)) - 3, LENGTH(DECRYPT(ARR_MEMBER(1).MOBILE)))
                 ,  ADDR1           = ARR_MEMBER(1).ADDR1
                 ,  ADDR2           = ARR_MEMBER(1).ADDR2
                 ,  REMARKS         = ARR_MEMBER(1).REMARKS
                 ,  AGREE_DT        = ARR_MEMBER(1).AGREE_DT
                 ,  UPD_DT          = SYSDATE
                 ,  UPD_USER        = 'SYSTEM'
        WHEN NOT MATCHED THEN
            INSERT 
            (
                    COMP_CD
                 ,  MEMBER_NO
                 ,  MEMBER_NM
                 ,  MEMBER_DIV
                 ,  ORG_NM
                 ,  MOBILE
                 ,  MOBILE_N3
                 ,  ADDR1
                 ,  ADDR2
                 ,  REMARKS
                 ,  JOIN_DT
                 ,  BRAND_CD
                 ,  STOR_CD
                 ,  AGREE_DT
                 ,  USE_YN
                 ,  INST_DT
                 ,  INST_USER
                 ,  UPD_DT
                 ,  UPD_USER  
            ) VALUES (
                    PSV_COMP_CD
                 ,  vMemberNo
                 ,  ARR_MEMBER(1).MEMBER_NM
                 ,  ARR_MEMBER(1).MEMBER_DIV
                 ,  ARR_MEMBER(1).ORG_NM
                 ,  ARR_MEMBER(1).MOBILE
                 ,  SUBSTR(DECRYPT(ARR_MEMBER(1).MOBILE), LENGTH(DECRYPT(ARR_MEMBER(1).MOBILE)) - 3, LENGTH(DECRYPT(ARR_MEMBER(1).MOBILE)))
                 ,  ARR_MEMBER(1).ADDR1
                 ,  ARR_MEMBER(1).ADDR2
                 ,  ARR_MEMBER(1).REMARKS
                 ,  TO_CHAR(SYSDATE, 'YYYYMMDD')
                 ,  PSV_BRAND_CD
                 ,  PSV_STOR_CD
                 ,  ARR_MEMBER(1).AGREE_DT
                 ,  'Y'
                 ,  SYSDATE
                 ,  'SYSTEM'
                 ,  SYSDATE
                 ,  'SYSTEM'
        );
        
        COMMIT;
        
        MERGE   INTO CS_MEMBER_EXT
        USING   DUAL
           ON   (
                        COMP_CD     = PSV_COMP_CD
                    AND MEMBER_NO   = vMemberNo
                )
        WHEN NOT MATCHED THEN
            INSERT 
            (
                    COMP_CD
                 ,  MEMBER_NO
                 ,  SEX_DIV
                 ,  SMS_RCV_YN
            ) VALUES (
                    PSV_COMP_CD
                 ,  vMemberNo
                 ,  'F'
                 ,  'Y'
        );
        
        -- 5. 자녀정보 저장
        nLoopCnt := TO_NUMBER(PSV_CHILD_CNT);
        
        FOR i IN 1 .. nLoopCnt LOOP
            
            vChildNo := ARR_MEMBER_CHILD(i).CHILD_NO;
            IF vChildNo IS NULL THEN
                -- 5.1 자녀번호 취득
                SELECT  NVL(MAX(TO_NUMBER(CHILD_NO)), 0) + 1
                  INTO  vChildNo
                  FROM  CS_MEMBER_CHILD
                 WHERE  COMP_CD     = PSV_COMP_CD
                   AND  MEMBER_NO   = vMemberNo;
                
                ARR_MEMBER_CHILD(i).CHILD_NO := vChildNo;
            END IF;
        
            MERGE   INTO CS_MEMBER_CHILD
            USING   DUAL
               ON   (
                            COMP_CD     = PSV_COMP_CD
                        AND MEMBER_NO   = vMemberNo
                        AND CHILD_NO    = vChildNo
                    )
            WHEN MATCHED  THEN
                UPDATE      
                   SET  CHILD_NM        = ARR_MEMBER_CHILD(i).CHILD_NM
                     ,  SEX_DIV         = ARR_MEMBER_CHILD(i).SEX_DIV
                     ,  BIRTH_DT        = ARR_MEMBER_CHILD(i).BIRTH_DT
                     ,  AGES            = NVL(ARR_MEMBER_CHILD(i).AGES, '0')
                     ,  ANVS_DT         = ARR_MEMBER_CHILD(i).ANVS_DT
                     ,  REMARKS         = ARR_MEMBER_CHILD(i).REMARKS
                     ,  USE_YN          = ARR_MEMBER_CHILD(i).USE_YN
                     ,  UPD_DT          = SYSDATE
                     ,  UPD_USER        = 'SYSTEM'
            WHEN NOT MATCHED THEN
                INSERT 
                (
                        COMP_CD
                     ,  MEMBER_NO
                     ,  CHILD_NO
                     ,  CHILD_NM
                     ,  SEX_DIV
                     ,  BIRTH_DT
                     ,  AGES
                     ,  ANVS_DT
                     ,  REMARKS
                     ,  JOIN_DT
                     ,  BRAND_CD
                     ,  STOR_CD
                     ,  USE_YN
                     ,  INST_DT
                     ,  INST_USER
                     ,  UPD_DT
                     ,  UPD_USER
                ) VALUES (
                        PSV_COMP_CD
                     ,  vMemberNo
                     ,  vChildNo
                     ,  ARR_MEMBER_CHILD(i).CHILD_NM
                     ,  ARR_MEMBER_CHILD(i).SEX_DIV
                     ,  ARR_MEMBER_CHILD(i).BIRTH_DT
                     ,  NVL(ARR_MEMBER_CHILD(i).AGES, '0')
                     ,  ARR_MEMBER_CHILD(i).ANVS_DT
                     ,  ARR_MEMBER_CHILD(i).REMARKS
                     ,  TO_CHAR(SYSDATE, 'YYYYMMDD')
                     ,  PSV_BRAND_CD
                     ,  PSV_STOR_CD
                     ,  ARR_MEMBER_CHILD(i).USE_YN
                     ,  SYSDATE
                     ,  'SYSTEM'
                     ,  SYSDATE
                     ,  'SYSTEM'
                );
            
        END LOOP;
        
        nLoopCnt := TO_NUMBER(PSV_TEL_CNT);
        
        -- 6. 회원연락처 등록
        FOR i IN 1 .. nLoopCnt LOOP
            
            vTelNo := ARR_MEMBER_TEL(i).TEL_NO;
            IF vTelNo IS NULL THEN
                -- 6.1 연락처순번 취득
                SELECT  NVL(MAX(TO_NUMBER(TEL_NO)), 0) + 1
                  INTO  vTelNo
                  FROM  CS_MEMBER_TEL
                 WHERE  COMP_CD     = PSV_COMP_CD
                   AND  MEMBER_NO   = vMemberNo;
                
                ARR_MEMBER_TEL(i).TEL_NO := vTelNo;
            END IF;
        
            MERGE   INTO CS_MEMBER_TEL
            USING   DUAL
               ON   (
                            COMP_CD     = PSV_COMP_CD
                        AND MEMBER_NO   = vMemberNo
                        AND TEL_NO      = vTelNo
                    )
            WHEN MATCHED  THEN
                UPDATE      
                   SET  TEL_NM          = ARR_MEMBER_TEL(i).TEL_NM
                     ,  MOBILE          = ARR_MEMBER_TEL(i).MOBILE
                     ,  MOBILE_N3       = SUBSTR(DECRYPT(ARR_MEMBER_TEL(i).MOBILE), LENGTH(DECRYPT(ARR_MEMBER_TEL(i).MOBILE)) - 3, LENGTH(DECRYPT(ARR_MEMBER_TEL(i).MOBILE)))
                     ,  REMARKS         = ARR_MEMBER_TEL(i).REMARKS
                     ,  USE_YN          = ARR_MEMBER_TEL(i).USE_YN
                     ,  UPD_DT          = SYSDATE
                     ,  UPD_USER        = 'SYSTEM'
            WHEN NOT MATCHED THEN
                INSERT 
                (
                        COMP_CD
                     ,  MEMBER_NO
                     ,  TEL_NO
                     ,  TEL_NM
                     ,  MOBILE
                     ,  MOBILE_N3
                     ,  REMARKS
                     ,  JOIN_DT
                     ,  BRAND_CD
                     ,  STOR_CD
                     ,  USE_YN
                     ,  INST_DT
                     ,  INST_USER
                     ,  UPD_DT
                     ,  UPD_USER
                ) VALUES (
                        PSV_COMP_CD
                     ,  vMemberNo
                     ,  vTelNo
                     ,  ARR_MEMBER_TEL(i).TEL_NM
                     ,  ARR_MEMBER_TEL(i).MOBILE
                     ,  SUBSTR(DECRYPT(ARR_MEMBER_TEL(i).MOBILE), LENGTH(DECRYPT(ARR_MEMBER_TEL(i).MOBILE)) - 3, LENGTH(DECRYPT(ARR_MEMBER_TEL(i).MOBILE)))
                     ,  ARR_MEMBER_TEL(i).REMARKS
                     ,  TO_CHAR(SYSDATE, 'YYYYMMDD')
                     ,  PSV_BRAND_CD
                     ,  PSV_STOR_CD
                     ,  ARR_MEMBER_TEL(i).USE_YN
                     ,  SYSDATE
                     ,  'SYSTEM'
                     ,  SYSDATE
                     ,  'SYSTEM'
                );
            
        END LOOP;
        
        lsSqlMain :=        Q'[]'
        ||CHR(13)||CHR(10)||Q'[ SELECT  ']' || vMemberNo || Q'['    ]';
        
        nLoopCnt := TO_NUMBER(PSV_CHILD_CNT);
        FOR i IN 1 .. nLoopCnt LOOP
            lsSqlMain := lsSqlMain ||CHR(13)||CHR(10)||Q'[, ']' || ARR_MEMBER_CHILD(i).CHILD_NO || Q'['  ]';
        END LOOP;
        
        nLoopCnt := TO_NUMBER(PSV_TEL_CNT);
        FOR i IN 1 .. nLoopCnt LOOP
            lsSqlMain := lsSqlMain ||CHR(13)||CHR(10)||Q'[, ']' || ARR_MEMBER_TEL(i).TEL_NO || Q'['  ]';
        END LOOP;
        
        lsSqlMain := lsSqlMain ||CHR(13)||CHR(10)||Q'[   FROM  DUAL ]';
        
        --dbms_output.put_line(lsSqlMain);
        
        -- 멤버십/카드 정보 작성        
        IF PSV_CARD_ID IS NOT NULL THEN
            PKG_CS_MEMBER_ACK.SET_CUST_CARD_10(PSV_COMP_CD, PSV_LANG_TP, vMemberNo, NULL, PSV_CARD_ID, vRTNCODE, vRTNMSG);
        END IF;

        OPEN asResult FOR lsSqlMain;
        
        COMMIT;
        
        asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001392'); -- 정상처리 되었습니다.
        
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
        
        RETURN;
        
    EXCEPTION
        WHEN ERR_HANDLER THEN
            OPEN asResult FOR
                SELECT  asRetVal
                  FROM  DUAL;
            
            ROLLBACK;
            
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
            
            RETURN;
        WHEN OTHERS THEN
            asRetVal := '9999';
            asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1004999999');  -- 자료처리중 오류가 발생했습니다. 관리자에게 문의하여 주십시오.
            --asRetMsg := SQLERRM;
            OPEN asResult FOR
                SELECT  asRetVal
                  FROM  DUAL;
            
            ROLLBACK;
            
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
            
            RETURN;
    END SET_MEMB_INFO_10;
    
    ------------------------------------------------------------------------------
    --  Package Name     : SET_MEMB_CHG_20
    --  Description      : POS 멤버십 사용/적립 > POS에서만 가능
    --  Ref. Table       : C_CARD            멤버십카드 마스터
    --                     C_CUST            회원 마스터
    --                     C_CARD_USE_HIS    멤버십카드 사용이력
    --                     C_CARD_SAV_HIS    멤버십카드 적립이력
    ------------------------------------------------------------------------------
    --  Create Date      : 2015-01-13 엠즈씨드 CRM PJT
    --  Modify Date      : 
    ------------------------------------------------------------------------------
     PROCEDURE SET_MEMB_CHG_20
   (
    PSV_COMP_CD           IN   VARCHAR2, -- 1. 회사코드
    PSV_LANG_TP           IN   VARCHAR2, -- 2. 언어코드
    PSV_CARD_ID           IN   VARCHAR2, -- 3. 카드번호
    PSV_USE_DT            IN   VARCHAR2, -- 4. 사용일자
    PSV_MEMB_DIV          IN   VARCHAR2, -- 5. 멤버십구분[1: 충전금액, 2: 포인트]
    PSV_SALE_DIV          IN   VARCHAR2, -- 6. 판매구분
    PSV_USE_AMT           IN   VARCHAR2, -- 7. 사용금액
    PSV_SAV_MLG           IN   VARCHAR2, -- 8. 적립마일리지
    PSV_SAV_PT            IN   VARCHAR2, -- 9. 적립포인트
    PSV_USE_PT            IN   VARCHAR2, -- 10. 사용포인트
    PSV_BRAND_CD          IN   VARCHAR2, -- 11. 영업조직
    PSV_STOR_CD           IN   VARCHAR2, -- 12. 점포코드
    PSV_POS_NO            IN   VARCHAR2, -- 13. 포스번호
    PSV_BILL_NO           IN   VARCHAR2, -- 14. 영수증번호
    PSV_USE_TM            IN   VARCHAR2, -- 15. 사용시간
    PSV_ORG_USE_DT        IN   VARCHAR2, -- 16. 원거래일자
    PSV_ORG_USE_SEQ       IN   VARCHAR2, -- 17. 원거래일련번호
    asRetVal              OUT  VARCHAR2, -- 18. 결과코드[1:정상  그외는 오류]
    asRetMsg              OUT  VARCHAR2, -- 19. 결과메시지
    asResult              OUT  REC_SET.M_REFCUR
   ) IS
  
    lsCardId        C_CARD.CARD_ID%TYPE;               -- 카드 ID
    lsCustId        C_CARD.CUST_ID%TYPE;               -- 회원 ID
    lsMlgSavDt      C_CUST.MLG_SAV_DT%TYPE;            -- 마일리지 적립 일자 
    nRecSeq         VARCHAR2(7);                       -- 일련번호
    nRecCnt         NUMBER(7) := 0;                    -- 레코드 수
    nCurCash        C_CARD.SAV_CASH%TYPE := 0;         -- 현재 잔액
    nCurPoint       C_CARD.SAV_PT%TYPE   := 0;         -- 현재 포인트
    
    ERR_HANDLER     EXCEPTION;
    
    BEGIN
        asRetVal    := '0000';
        asRetMsg    := 'OK'  ;
    
        BEGIN
            SELECT  COUNT(*), SUM(CRD.SAV_CASH - CRD.USE_CASH), SUM(CST.SAV_PT - CST.USE_PT - CST.LOS_PT), MAX(CST.CUST_ID)
            INTO    nRecCnt,  nCurCash,                         nCurPoint,                                 lsCustId
            FROM    C_CARD CRD
                  , C_CUST CST
            WHERE   CST.COMP_CD   = CRD.COMP_CD
            AND     CST.CUST_ID   = CRD.CUST_ID
            AND     CRD.COMP_CD   = PSV_COMP_CD
            AND     CRD.CARD_ID   = PSV_CARD_ID
            AND     1 = CASE WHEN PSV_MEMB_DIV = '1' AND CRD.CARD_STAT  = '10' THEN 1 -- 카드상태[00:대기, 10:정상, 90:분실신고, 91:해지, 99:폐기]
                             WHEN PSV_MEMB_DIV = '1' AND CRD.CARD_STAT != '10' THEN 0
                             ELSE 1
                        END;

            IF nRecCnt = 0 THEN
                asRetVal := '1001';
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001394'); -- 등록하지 않은 카드번호 입니다.
         
                RETURN;
            END IF;
      
            IF    PSV_MEMB_DIV = '1' AND PSV_SALE_DIV = '1' THEN   -- 충전금액, 사용
                IF nCurCash < TO_NUMBER(PSV_USE_AMT) THEN
                    asRetVal := '1010';
                    asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001395'); -- 충전잔액이 부족합니다.
            
                    RETURN;
                END IF;
            ELSIF PSV_MEMB_DIV = '2' AND PSV_SALE_DIV = '301' THEN -- 포인트, 사용
                IF nCurPoint < TO_NUMBER(PSV_USE_PT) THEN
                    asRetVal := '1010';
                    asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001386'); -- 고객 포인트 잔액이 부족합니다.
            
                    RETURN;
                END IF;
            END IF;
        END;
    
        -- 원거래 존재여부 / 기 취소여부 체크
        IF PSV_SALE_DIV IN ('2', '202', '302') THEN -- 2: 반품, 202: 적립반품, 302: 사용반품
            -- 원거래 존재여부
            IF PSV_SALE_DIV =  '2' THEN
                SELECT  COUNT(*) INTO nRecCnt
                FROM    C_CARD_USE_HIS
                WHERE   COMP_CD = PSV_COMP_CD
                AND     CARD_ID = PSV_CARD_ID
                AND     USE_DT  = PSV_ORG_USE_DT
                AND     USE_SEQ = TO_NUMBER(PSV_ORG_USE_SEQ)
                AND     USE_YN  = 'Y'; -- 사용여부[Y:사용, N:사용안함]
            ELSIF PSV_SALE_DIV IN ('202', '302') THEN
                SELECT COUNT(*) INTO nRecCnt
                FROM C_CARD_SAV_HIS
                WHERE COMP_CD = PSV_COMP_CD
                AND CARD_ID = PSV_CARD_ID
                AND USE_DT  = PSV_ORG_USE_DT
                AND USE_SEQ = TO_NUMBER(PSV_ORG_USE_SEQ);
            END IF;
            
            IF nRecCnt = 0 THEN
                asRetVal := '1020';
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001389'); -- 원거래 내역이 존재하지 않습니다.
                    
                RETURN;
            END IF;
        
            -- 기 취소여부 체크
            IF    PSV_SALE_DIV = '2' THEN 
                SELECT COUNT(*) INTO nRecCnt
                FROM C_CARD_USE_HIS
                WHERE COMP_CD   = PSV_COMP_CD
                AND CARD_ID     = PSV_CARD_ID
                AND ORG_USE_DT  = PSV_ORG_USE_DT
                AND ORG_USE_SEQ = TO_NUMBER(PSV_ORG_USE_SEQ)
                AND USE_YN      = 'Y'; -- 사용여부[Y:사용, N:사용안함]
            ELSIF PSV_SALE_DIV IN ('202', '302') THEN
                SELECT COUNT(*) INTO nRecCnt
                FROM C_CARD_SAV_HIS
                WHERE COMP_CD   = PSV_COMP_CD
                AND CARD_ID     = PSV_CARD_ID
                AND ORG_USE_DT  = PSV_ORG_USE_DT
                AND ORG_USE_SEQ = TO_NUMBER(PSV_ORG_USE_SEQ);
            END IF;
           
            IF nRecCnt > 0 THEN
                asRetVal := '1030';
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1001343008'); -- 이미 반품 확정된 DATA입니다.
                  
                RETURN;
            END IF;
        END IF;
    
        IF PSV_MEMB_DIV = '1' THEN -- 멤버십 
            -- 일련번호 취득
            SELECT  SQ_PCRM_SEQ.NEXTVAL INTO nRecSeq
            FROM    DUAL;
              
            INSERT INTO C_CARD_USE_HIS
           (
            COMP_CD     ,       CARD_ID     ,
            USE_DT      ,       USE_SEQ     ,
            USE_AMT     ,       SALE_DIV    ,
            USE_DIV     ,
            REMARKS     ,
            BRAND_CD    ,       STOR_CD     ,
            POS_NO      ,       BILL_NO     ,
            USE_TM      ,       
            ORG_USE_DT  ,       ORG_USE_SEQ ,
            USE_YN      ,
            INST_DT     ,       INST_USER   ,
            UPD_DT      ,       UPD_USER
           )
            VALUES
           (
            PSV_COMP_CD ,       PSV_CARD_ID ,
            PSV_USE_DT  ,       nRecSeq     ,
            TO_NUMBER(PSV_USE_AMT) ,       PSV_SALE_DIV,
            CASE WHEN PSV_SALE_DIV = '1' THEN '301'             ELSE '302'             END ,
            CASE WHEN PSV_SALE_DIV = '1' THEN '멤버십카드 사용' ELSE '멤버십카드 취소' END ,
            PSV_BRAND_CD,       PSV_STOR_CD ,
            PSV_POS_NO  ,       PSV_BILL_NO ,
            PSV_USE_TM  ,
            PSV_ORG_USE_DT,     CASE WHEN PSV_ORG_USE_SEQ = '0' THEN NULL ELSE TO_NUMBER(PSV_ORG_USE_SEQ) END,
            'Y'         ,
            SYSDATE     ,       'SYS'       ,
            SYSDATE     ,       'SYS'
           );
           
            IF NVL(lsCustId, ' ') <> ' ' THEN -- 회원 ID 존재 시
                IF PSV_SALE_DIV IN('301', '303', '901') AND TO_NUMBER(PSV_USE_AMT) > 0 THEN -- 적립사용종류[301:사용, 302:사용반품, 303:사용누락, 901:조정]
                    UPDATE  C_CUST
                    SET     CASH_USE_DT = PSV_USE_DT
                    WHERE   COMP_CD     = PSV_COMP_CD
                    AND     CUST_ID     = lsCustId;
                END IF;
            END IF;
        ELSE -- 포인트 적립/사용 
            -- 일련번호 취득
            SELECT SQ_PCRM_SEQ.NEXTVAL INTO nRecSeq
            FROM DUAL;
               
            INSERT INTO C_CARD_SAV_HIS
           (
            COMP_CD     ,       CARD_ID     ,
            USE_DT      ,       USE_SEQ     ,
            SAV_USE_FG  ,
            SAV_USE_DIV ,
            REMARKS     ,
            SAV_MLG     ,
            LOS_MLG     ,       LOS_MLG_YN  ,
            LOS_MLG_DT  ,       SAV_PT      ,
            USE_PT      ,       LOS_PT      ,
            LOS_PT_YN   ,       LOS_PT_DT   ,       
            BRAND_CD    ,       STOR_CD     ,
            POS_NO      ,       BILL_NO     ,
            ORG_USE_DT  ,       ORG_USE_SEQ ,
            USE_TM      ,       USE_YN      ,
            INST_DT     ,       INST_USER   ,
            UPD_DT      ,       UPD_USER
           )
            VALUES
           (
            PSV_COMP_CD ,       PSV_CARD_ID ,
            PSV_USE_DT  ,       nRecSeq     ,
            CASE WHEN PSV_SALE_DIV LIKE '2%' THEN '3'             ELSE '4'             END,
            PSV_SALE_DIV ,
            CASE WHEN PSV_SALE_DIV LIKE '2%' THEN '포인트 적립' ELSE '포인트 사용' END ||
            CASE WHEN PSV_SALE_DIV LIKE '%2' THEN '취소'          ELSE NULL            END,
            CASE WHEN PSV_SALE_DIV IN ('201', '301') THEN TO_NUMBER(PSV_SAV_MLG) ELSE TO_NUMBER(PSV_SAV_MLG) END,
            0           ,       'N'         ,
            TO_CHAR(ADD_MONTHS(TO_DATE(PSV_USE_DT, 'YYYYMMDD'), 12) - 1, 'YYYYMMDD'),
            CASE WHEN PSV_SALE_DIV IN ('201', '301') THEN TO_NUMBER(PSV_SAV_PT)  ELSE TO_NUMBER(PSV_SAV_PT) END,
            CASE WHEN PSV_SALE_DIV IN ('201', '301') THEN TO_NUMBER(PSV_USE_PT)  ELSE TO_NUMBER(PSV_USE_PT) END,
            0           ,
            'N'         ,       TO_CHAR(ADD_MONTHS(TO_DATE(PSV_USE_DT, 'YYYYMMDD'), 12) - 1, 'YYYYMMDD'),
            PSV_BRAND_CD,       PSV_STOR_CD ,
            PSV_POS_NO  ,       PSV_BILL_NO ,
            PSV_ORG_USE_DT,     CASE WHEN PSV_ORG_USE_SEQ = '0' THEN NULL ELSE TO_NUMBER(PSV_ORG_USE_SEQ) END,
            PSV_USE_TM  ,       'Y'         ,
            SYSDATE    ,        'SYS'       ,
            SYSDATE    ,        'SYS'
           );
           
            IF NVL(lsCustId, ' ') <> ' ' THEN -- 회원 ID 존재 시
                IF (PSV_SALE_DIV IN(       '201', '203', '901', '902', '903') AND TO_NUMBER(PSV_SAV_MLG) > 0) OR
                   (PSV_SALE_DIV IN('101', '201', '203', '901', '902', '903') AND TO_NUMBER(PSV_SAV_PT)  > 0) THEN -- 적립사용종류[101:회원가입, 102:회원탈퇴 소멸, 201:적립, 202:적립반품, 203:적립누락, 301:사용, 302:사용반품, 303:사용누락, 901:조정, 902:이전, 903:기타]
                 
                    -- 최초 적립 DATA 생성
                    IF PSV_SALE_DIV IN('201', '203', '901', '902', '903') AND TO_NUMBER(PSV_SAV_MLG) > 0 THEN
                        -- 최초구매 쿠폰 발행 존재 여부 
                        SELECT COUNT(*) INTO nRecCnt
                        FROM   C_COUPON_MST      MST
                             , C_COUPON_ITEM_GRP GRP
                        WHERE  MST.COMP_CD   = GRP.COMP_CD
                        AND    MST.COUPON_CD = GRP.COUPON_CD
                        AND    MST.CLOSE_DT >= TO_CHAR(SYSDATE, 'YYYYMMDD')
                        AND    GRP.PRT_DIV   = '07';  -- 쿠폰 발행구분[07:첫구매]
                     
                        -- 최초 마일리지 적립 여부
                        SELECT MLG_SAV_DT INTO lsMlgSavDt
                        FROM   C_CUST CST
                        WHERE  CST.COMP_CD   = PSV_COMP_CD
                        AND    CST.CUST_ID   = lsCustId;
                     
                        IF nRecCnt > 0 AND lsMlgSavDt IS NULL THEN
                            -- 최초 적립 이력 작성
                            MERGE   INTO C_CUST_FBD
                            USING   DUAL
                            ON (
                                    COMP_CD = PSV_COMP_CD
                                AND CUST_ID = lsCustId
                               )
                            WHEN NOT MATCHED THEN
                                INSERT 
                               (
                                COMP_CD    ,    CUST_ID     ,
                                SALE_DT    ,    BRAND_CD    ,
                                STOR_CD    ,    POS_NO      ,
                                BILL_NO    ,    SALE_DIV    ,
                                SAV_MLG    ,    COUPON_PRT  ,
                                INST_DT    ,    INST_USER   ,
                                UPD_DT     ,    UPD_USER
                               )
                                VALUES 
                               (
                                PSV_COMP_CD ,   lsCustId    ,
                                PSV_USE_DT  ,   PSV_BRAND_CD,
                                PSV_STOR_CD ,   PSV_POS_NO  ,
                                PSV_BILL_NO ,   PSV_SALE_DIV,
                                TO_NUMBER(PSV_SAV_MLG) ,   'N'         ,
                                SYSDATE     ,   'PKG'       ,
                                SYSDATE     ,   'PKG'       
                               );
                        END IF;
                    END IF;
                 
                    -- 최근 마일리지 적립일자 
                    UPDATE  C_CUST
                    SET     MLG_SAV_DT  = PSV_USE_DT
                    WHERE   COMP_CD     = PSV_COMP_CD
                    AND     CUST_ID     = lsCustId;
                END IF;
            END IF;
        END IF;
        
        OPEN asResult FOR
        SELECT  REC_SEQ, CUR_SAV_CASH, CUR_SAV_MLG, CUR_SAV_PNT, REM_MLG_CNT
          FROM (-- 마일리지
                SELECT nRecSeq AS REC_SEQ, SAV_CASH - USE_CASH AS CUR_SAV_CASH
                     , 0 AS CUR_SAV_MLG, 0  AS CUR_SAV_PNT
                     , 0 AS REM_MLG_CNT
                  FROM C_CARD
                 WHERE COMP_CD   = PSV_COMP_CD
                   AND CARD_ID   = PSV_CARD_ID
                   AND CARD_STAT = '10' -- 카드상태[00:대기, 10:정상, 90:분실신고, 91:해지, 99:폐기]
                   AND USE_YN    = 'Y' -- 사용여부[Y:사용, N:사용안함]
                   AND 1         = (CASE WHEN PSV_MEMB_DIV = '1' THEN 1 ELSE 0 END)
                UNION ALL -- 포인트(멤버십) 적립/취소
                SELECT nRecSeq AS RECSEQ, 0 AS CUR_SAV_CASH, CST.SAV_MLG - CST.LOS_MLG  AS CUR_SAV_MLG
                     , CST.SAV_PT - CST.USE_PT - CST.LOS_PT AS CUR_SAV_PNT
                     ,(
                       SELECT CASE WHEN MIN(LVL.LVL_STD_STR) IS NULL THEN 0 ELSE MIN(LVL.LVL_STD_STR) - (CST.SAV_MLG - CST.LOS_MLG) END 
                       FROM   C_CUST_LVL LVL
                       WHERE  LVL.COMP_CD     = CST.COMP_CD
                       AND    LVL.LVL_STD_STR > (CST.SAV_MLG - CST.LOS_MLG) 
                       AND    LVL.USE_YN      = 'Y'
                      ) AS REM_MLG_CNT
                  FROM C_CUST CST
                 WHERE COMP_CD   = PSV_COMP_CD
                   AND CUST_ID   = (SELECT CUST_ID FROM C_CARD WHERE COMP_CD = PSV_COMP_CD AND CARD_ID = PSV_CARD_ID)
                   AND CUST_STAT = '2'  -- 회원상태[1:가입, 2:멤버십, 9:탈퇴]
                   AND USE_YN    = 'Y'  -- 사용여부[Y:사용, N:사용안함]
                   AND 1         = (CASE WHEN PSV_MEMB_DIV = '2' THEN 1 ELSE 0 END)
               );
               
        asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001392'); -- 정상 처리되었습니다.
        
        RETURN;
    EXCEPTION
        WHEN ERR_HANDLER THEN
            OPEN asResult FOR
                SELECT 0
                FROM   DUAL;
             
            ROLLBACK;
            RETURN;
        WHEN OTHERS THEN
            OPEN asResult FOR
                SELECT 0
                FROM   DUAL;
             
            asRetVal := '1003';
            asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001187')||'['||SQLERRM||']'; -- 오류가 발생하였습니다.
         
            ROLLBACK;
            RETURN;
    END SET_MEMB_CHG_20;
      
    --------------------------------------------------------------------------------
    --  Procedure Name   : GET_MEMBSHIP_INFO_10
    --  Description      : 회원권 조회
    --  Ref. Table       : CS_MEMBERSHIP    회원권 마스터
    --------------------------------------------------------------------------------
    --  Create Date      : 2016-05-19   최세원
    --  Modify Date      :  
    --------------------------------------------------------------------------------
    PROCEDURE GET_MEMBSHIP_INFO_10
    ( 
        PSV_COMP_CD           IN   VARCHAR2,        -- 1. 회사코드 
        PSV_LANG_TP           IN   VARCHAR2,        -- 2. 언어코드 
        PSV_BRAND_CD          IN   VARCHAR2,        -- 3. 영업조직
        PSV_STOR_CD           IN   VARCHAR2,        -- 4. 점포코드
        PSV_MEMBER_NO         IN   VARCHAR2,        -- 5. 회원번호
        asRetVal              OUT  VARCHAR2,        -- 6. 결과코드[0000:정상  그외는 오류] 
        asRetMsg              OUT  VARCHAR2,        -- 7. 결과메시지 
        asResult              OUT  REC_SET.M_REFCUR -- 8. 결과레코드
    ) IS
    
    lsSqlMain       VARCHAR2(32000) := NULL;
    vBrandClass     VARCHAR2(10)    := NULL;
    vStorTp         VARCHAR2(2)     := NULL;
    
    ERR_HANDLER     EXCEPTION;
    
    BEGIN
        
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';
        
        asRetVal    := '0000';
        asRetMsg    := 'OK';
        
        SELECT  B.BRAND_CLASS, S.STOR_TP
          INTO  vBrandClass, vStorTp
          FROM  STORE   S
             ,  BRAND   B
         WHERE  B.COMP_CD   = S.COMP_CD
           AND  B.BRAND_CD  = S.BRAND_CD
           AND  S.COMP_CD   = PSV_COMP_CD
           AND  S.BRAND_CD  = PSV_BRAND_CD
           AND  S.STOR_CD   = PSV_STOR_CD
        ;
        
        lsSqlMain :=        Q'[]'
        ||CHR(13)||CHR(10)||Q'[ SELECT  M.BRAND_CD                          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MS.PROGRAM_ID                       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MS.MBS_NO                           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MS.CERT_NO                          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MS.MEMBER_NO                        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MS.MOBILE                           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MS.MBS_DIV                          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MS.MBS_STAT                         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MS.CHARGE_YN                        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MS.CERT_FDT                         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MS.CERT_TDT                         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MS.ENTR_PRC                         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MS.SALE_AMT                         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MS.DC_AMT                           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MS.GRD_AMT                          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MS.SALE_BRAND_CD                    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MS.SALE_STOR_CD                     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN MS.MBS_DIV = '1' THEN ROUND(MS.GRD_AMT / MS.OFFER_TM , 2) ]'
        ||CHR(13)||CHR(10)||Q'[              WHEN MS.MBS_DIV = '2' THEN ROUND(MS.GRD_AMT / MS.OFFER_CNT, 2) ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE 0                         ]'
        ||CHR(13)||CHR(10)||Q'[         END             AS PER_PRICE        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MS.OFFER_TM                         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MS.USE_TM                           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MS.OFFER_CNT                        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MS.USE_CNT                          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MS.OFFER_AMT                        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MS.USE_AMT                          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MS.OFFER_MCNT                       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MS.USE_MCNT                         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MS.REFUND_YN                        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MS.REFUND_REQ_DT                    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MS.REFUND_APPR_DT                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN MS.MBS_DIV = '1' THEN     ]'      -- 시간권의 환불금액 계산
        ||CHR(13)||CHR(10)||Q'[                                         CASE WHEN TRUNC(MS.GRD_AMT - (MS.ENTR_PRC * (MS.USE_TM / P.BASE_USE_TM)), -2) <= 0 THEN 0   ]'  -- 사용시간금액이 구매금액을 초과하는 경우 환불금액은 0
        ||CHR(13)||CHR(10)||Q'[                                              ELSE TRUNC(MS.GRD_AMT - (MS.ENTR_PRC * (MS.USE_TM / P.BASE_USE_TM)), -2)               ]'  -- 환불금액 100원단위 절삭
        ||CHR(13)||CHR(10)||Q'[                                         END ]'
        ||CHR(13)||CHR(10)||Q'[              WHEN MS.MBS_DIV = '2' THEN     ]'      -- 횟수권의 환불금액 계산
        ||CHR(13)||CHR(10)||Q'[                                         CASE WHEN TRUNC(MS.GRD_AMT - (MS.ENTR_PRC * MS.USE_CNT), -2) <= 0THEN 0                     ]'  -- 사용횟수금액이 구매금액을 초과하는 경우 환불금액은 0
        ||CHR(13)||CHR(10)||Q'[                                              ELSE TRUNC(MS.GRD_AMT - (MS.ENTR_PRC * MS.USE_CNT), -2)                                ]'  -- 환불금액 100원단위 절삭
        ||CHR(13)||CHR(10)||Q'[                                         END ]'
        ||CHR(13)||CHR(10)||Q'[              WHEN MS.MBS_DIV = '3' THEN     ]'      -- 금액권의 환불금액 계산
        ||CHR(13)||CHR(10)||Q'[                                         CASE WHEN TRUNC(MS.GRD_AMT - MS.USE_AMT, -2) <= 0 THEN 0                                    ]'  -- 사용금액이 구매금액을 초과하는 경우 환불금액은 0
        ||CHR(13)||CHR(10)||Q'[                                              ELSE TRUNC(MS.GRD_AMT - MS.USE_AMT, -2)                                                ]'  -- 환불금액 100원단위 절삭
        ||CHR(13)||CHR(10)||Q'[                                         END ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE 0                         ]'
        ||CHR(13)||CHR(10)||Q'[         END                 AS REFUND_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  CS_MEMBERSHIP_SALE  MS              ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CS_MEMBERSHIP       M               ]'
        ||CHR(13)||CHR(10)||Q'[      ,  BRAND               B               ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CS_PROGRAM          P               ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  MS.COMP_CD      = M.COMP_CD         ]'
        ||CHR(13)||CHR(10)||Q'[    AND  MS.PROGRAM_ID   = M.PROGRAM_ID      ]'
        ||CHR(13)||CHR(10)||Q'[    AND  MS.MBS_NO       = M.MBS_NO          ]'
        ||CHR(13)||CHR(10)||Q'[    AND  M.COMP_CD       = B.COMP_CD         ]'
        ||CHR(13)||CHR(10)||Q'[    AND  M.BRAND_CD      = B.BRAND_CD        ]'
        ||CHR(13)||CHR(10)||Q'[    AND  MS.COMP_CD      = P.COMP_CD         ]'
        ||CHR(13)||CHR(10)||Q'[    AND  MS.PROGRAM_ID   = P.PROGRAM_ID      ]'
        ||CHR(13)||CHR(10)||Q'[    AND  MS.COMP_CD      = :PSV_COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[    AND  MS.MEMBER_NO    = :PSV_MEMBER_NO    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  MS.MBS_STAT     IN ('10', '11', '90', '91', '93')   ]'  -- 회원권상태 => 10 : 사용가능, 90 : 유효기간만료, 91:환불요청
        ||CHR(13)||CHR(10)||Q'[    AND  MS.SALE_DIV     = '1'               ]'      -- 판매구분   => 1  : 판매
        ||CHR(13)||CHR(10)||Q'[    AND  (                                   ]'
        ||CHR(13)||CHR(10)||Q'[             ( MS.MBS_DIV = '1' AND MS.OFFER_TM  - USE_TM  > 0 ) ]'      -- 시간권이면서  잔여시간이 남아있는 회원권
        ||CHR(13)||CHR(10)||Q'[             OR                              ]'
        ||CHR(13)||CHR(10)||Q'[             ( MS.MBS_DIV = '2' AND MS.OFFER_CNT - USE_CNT > 0 ) ]'      -- 횟수권이면서 잔여횟수가 남아있는 회원권
        ||CHR(13)||CHR(10)||Q'[             OR                              ]'
        ||CHR(13)||CHR(10)||Q'[             ( MS.MBS_DIV = '3' AND MS.OFFER_AMT - USE_AMT > 0 ) ]'      -- 금액권이면서 잔여금액가 남아있는 회원권
        ||CHR(13)||CHR(10)||Q'[         )                                   ]'
        ||CHR(13)||CHR(10)||Q'[    AND  MS.USE_YN       = 'Y'               ]'      -- 사용여부(회원권 판매)
        ||CHR(13)||CHR(10)||Q'[    AND  (                                   ]'
        ||CHR(13)||CHR(10)||Q'[             (M.USE_DIV = '1' AND (MS.SALE_BRAND_CD = :PSV_BRAND_CD AND MS.SALE_STOR_CD = :PSV_STOR_CD)) ]'  -- 회원권 이용구분이 점포인 경우 구매점포에서만 사용 가능
        ||CHR(13)||CHR(10)||Q'[             OR                              ]'
        ||CHR(13)||CHR(10)||Q'[             (M.USE_DIV = '2' AND M.BRAND_CD        = :PSV_BRAND_CD                                    ) ]'  -- 회원권 이용구분이 영업조직인 경우 해당 영업조직에서만 사용 가능
        ||CHR(13)||CHR(10)||Q'[             OR                             ]'
        ||CHR(13)||CHR(10)||Q'[             (M.USE_DIV = '3' AND B.BRAND_CLASS     = :PSV_BRAND_CLASS                                 ) ]'  -- 회원권 이용구분이 조직분류인 경우 해당 영업조직구분에서만 사용 가능
        ||CHR(13)||CHR(10)||Q'[             OR                              ]'
        ||CHR(13)||CHR(10)||Q'[             (M.USE_DIV = '4' AND :PSV_STOR_TP      = '10'                                             ) ]'  -- 회원권 이용구분이 직영인경우 해당 직영점포에서만 사용 가능
        ||CHR(13)||CHR(10)||Q'[             OR                              ]'
        ||CHR(13)||CHR(10)||Q'[             (M.USE_DIV = '5'                                                                          ) ]'  -- 회원권 이용구분이 전점포인 경우 사용가능
        ||CHR(13)||CHR(10)||Q'[         )                                   ]'
        ||CHR(13)||CHR(10)||Q'[    AND  M.USE_YN        = 'Y'               ]'      -- 사용여부(회원권)
        ||CHR(13)||CHR(10)||Q'[    AND  P.USE_YN        = 'Y'               ]'      -- 사용여부(프로그램)
        ;
        
        --dbms_output.put_line(lsSqlMain);
        
        OPEN asResult FOR lsSqlMain USING PSV_COMP_CD, PSV_MEMBER_NO, PSV_BRAND_CD, PSV_STOR_CD, PSV_BRAND_CD, vBrandClass, vStorTp;
    
        asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001392'); -- 정상처리 되었습니다.
        
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
        
        RETURN;
        
    EXCEPTION
        WHEN ERR_HANDLER THEN
            OPEN asResult FOR
                SELECT  asRetVal
                  FROM  DUAL;
            
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
            
            RETURN;
        WHEN OTHERS THEN
            asRetVal := '9999';
            asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1004999999');  -- 자료처리중 오류가 발생했습니다. 관리자에게 문의하여 주십시오.
            --asRetMsg := SQLERRM;
            OPEN asResult FOR
                SELECT  asRetVal
                  FROM  DUAL;
            
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
            
            RETURN;
    END GET_MEMBSHIP_INFO_10;
    
    --------------------------------------------------------------------------------
    --  Procedure Name   : SET_MEMBSHIP_INFO_10
    --  Description      : 회원권 판매/사용
    --  Ref. Table       : CS_MEMBERSHIP_SALE       회원권 판매
    --                     CS_MEMBERSHIP_SALE_HIS   회원권 판매이력
    --------------------------------------------------------------------------------
    --  Create Date      : 2016-05-19   최세원
    --  Modify Date      :  
    --------------------------------------------------------------------------------
    PROCEDURE SET_MEMBSHIP_INFO_10
    ( 
        PSV_COMP_CD           IN   VARCHAR2,        -- 1. 회사코드 
        PSV_LANG_TP           IN   VARCHAR2,        -- 2. 언어코드
        PSV_PROC_DIV          IN   VARCHAR2,        -- 3. 처리구분(1:판매, 2:판매반품/환불, 3:사용, 4:사용취소(사용반품), 5:환불요청)
        PSV_SALE_DT           IN   VARCHAR2,        -- 4. 처리일자
        PSV_BRAND_CD          IN   VARCHAR2,        -- 5. 영업조직
        PSV_STOR_CD           IN   VARCHAR2,        -- 6. 점포코드
        PSV_PROGRAM_ID        IN   VARCHAR2,        -- 7. 프로그램ID
        PSV_MBS_DIV           IN   VARCHAR2,        -- 8. 회원권종류(1:시간권, 2:횟수권, 3:금액권)
        PSV_MBS_NO            IN   VARCHAR2,        -- 9. 회원권번호
        PSV_CERT_NO           IN   VARCHAR2,        -- 10.인증번호
        PSV_APPR_SEQ          IN   VARCHAR2,        -- 11.승인번호
        PSV_MEMBER_NO         IN   VARCHAR2,        -- 12.회원번호
        PSV_CHILD_NO          IN   VARCHAR2,        -- 13.자녀번호
        PSV_POS_NO            IN   VARCHAR2,        -- 14.포스번호
        PSV_BILL_NO           IN   VARCHAR2,        -- 15.영수증번호
        PSV_SALE_SEQ          IN   VARCHAR2,        -- 16.판매순번
        PSV_ENTR_PRC          IN   VARCHAR2,        -- 17.1회 입장료
        PSV_SALE_AMT          IN   VARCHAR2,        -- 18.판매금액
        PSV_DC_AMT            IN   VARCHAR2,        -- 19.할인금액
        PSV_GRD_AMT           IN   VARCHAR2,        -- 20.결제금액
        PSV_CHARGE_YN         IN   VARCHAR2,        -- 21.유무상구분
        PSV_PROC_TM           IN   VARCHAR2,        -- 22.처리시간(시간권 : 사용시간, 횟수권 : 기본이용시간 * 사용횟수)
        PSV_PROC_CNT          IN   VARCHAR2,        -- 23.처리횟수(횟수권만 사용횟수 전달)
        PSV_PROC_AMT          IN   VARCHAR2,        -- 24.처리금액(시간권 : 사용시간 * 분단위 단가(잔여금액의 조정필요), 횟수권 : 사용횟수 * 횟수단위 단가(잔여금액의 조정필요), 금액권 : 사용금액)
        PSV_MATL_CNT          IN   VARCHAR2,        -- 25.교구횟수(1:제공횟수, 2:0, 3:사용횟수, 4:취소횟수, 5:0)
        asRetVal              OUT  VARCHAR2,        -- 26.결과코드[0000:정상  그외는 오류] 
        asRetMsg              OUT  VARCHAR2,        -- 27.결과메시지 
        asResult              OUT  REC_SET.M_REFCUR -- 28.결과레코드
    ) IS
    
    lsSqlMain       VARCHAR2(32000) := NULL;
    vMbsStat        CS_MEMBERSHIP_SALE.MBS_STAT%TYPE        := NULL;        -- 회원권상태
    vCertFdt        CS_MEMBERSHIP_SALE.CERT_FDT%TYPE        := NULL;        -- 유효기간 시작일자
    vCertTdt        CS_MEMBERSHIP_SALE.CERT_TDT%TYPE        := NULL;        -- 유효기간 종료일자
    vSaleDiv        CS_MEMBERSHIP_SALE.SALE_DIV%TYPE        := NULL;        -- 판매구분
    vCertNo         CS_MEMBERSHIP_SALE.CERT_NO%TYPE         := NULL;        -- 인증번호
    vSaleBrandCd    CS_MEMBERSHIP_SALE.SALE_BRAND_CD%TYPE   := NULL;        -- 판매영업조직
    vSaleStorCd     CS_MEMBERSHIP_SALE.SALE_STOR_CD%TYPE    := NULL;        -- 판매점포코드
    vRefundYn       CS_MEMBERSHIP_SALE.REFUND_YN%TYPE       := NULL;        -- 환불승인여부
    vSaleStorNm     STORE.STOR_NM%TYPE                      := NULL;        -- 판매점포명
    vRefundTermPassYn   VARCHAR2(1)                         := NULL;        -- 환불기간 경과여부
    nCertMonths     CS_MEMBERSHIP.CERT_MONTHS%TYPE          := 0;           -- 유효기간 개월수
    nApprSeq        CS_MEMBERSHIP_SALE_HIS.APPR_SEQ%TYPE    := 1;           -- 승인순번
    nBaseUseTm      CS_PROGRAM.BASE_USE_TM%TYPE             := 0;           -- 기본이용시간
    nRestTm         CS_MEMBERSHIP_SALE.USE_TM%TYPE          := 0;           -- 잔여시간
    nRestCnt        CS_MEMBERSHIP_SALE.USE_CNT%TYPE         := 0;           -- 잔여횟수
    nRestAmt        CS_MEMBERSHIP_SALE.USE_AMT%TYPE         := 0;           -- 잔여금액
    nRefundAmt      CS_MEMBERSHIP_SALE.REFUND_AMT%TYPE      := 0;           -- 환불금액
    nCheckDigit     NUMBER(7) := 0;                                         -- 체크디지트
    
    ERR_HANDLER     EXCEPTION;
    
    BEGIN
        
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';
        
        asRetVal    := '0000';
        asRetMsg    := 'OK';
        
        IF PSV_PROC_DIV = '1' THEN
            -- 1. 유효성 체크
            IF PSV_CHARGE_YN IS NULL THEN
                asRetVal := '1010';   
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001522') || '[' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_TP, 'CHARGE_YN') || ']'; -- 회원권정보가 올바르지 않습니다.[유무상구분]   
                RAISE ERR_HANDLER;
            END IF;
            
            -- 회원권 판매
            -- 1.2  기본이용시간, 유효기간 개월수 조회
            SELECT  M.CERT_MONTHS, P.BASE_USE_TM
              INTO  nCertMonths, nBaseUseTm
              FROM  CS_MEMBERSHIP   M
                 ,  CS_PROGRAM      P
             WHERE  M.COMP_CD       = P.COMP_CD
               AND  M.PROGRAM_ID    = P.PROGRAM_ID
               AND  M.COMP_CD       = PSV_COMP_CD
               AND  M.BRAND_CD      = PSV_BRAND_CD
               AND  M.PROGRAM_ID    = PSV_PROGRAM_ID
               AND  M.MBS_NO        = PSV_MBS_NO;
            
            -- 1.3  인증번호 조회
            SELECT  TO_CHAR(SYSDATE, 'YYMM')  ||
                    PSV_BRAND_CD              ||
                    PSV_CHARGE_YN             ||
                    LPAD(SQ_MEMBERSHIP_CERT_NO.NEXTVAL, 6, '0')  AS CERT_NO
              INTO  vCertNo
              FROM  DUAL;
            
            nCheckDigit := MOD(
                                TO_NUMBER(SUBSTR(vCertNo, 1 , 1)) * 3 + TO_NUMBER(SUBSTR(vCertNo, 2 , 1)) * 2 +  
                                TO_NUMBER(SUBSTR(vCertNo, 3 , 1)) * 3 + TO_NUMBER(SUBSTR(vCertNo, 4 , 1)) * 2 +  
                                TO_NUMBER(SUBSTR(vCertNo, 5 , 1)) * 3 + TO_NUMBER(SUBSTR(vCertNo, 6 , 1)) * 2 + 
                                TO_NUMBER(SUBSTR(vCertNo, 7 , 1)) * 3 + TO_NUMBER(SUBSTR(vCertNo, 8 , 1)) * 2 +  
                                TO_NUMBER(SUBSTR(vCertNo, 9 , 1)) * 3 + TO_NUMBER(SUBSTR(vCertNo, 10, 1)) * 2 +  
                                TO_NUMBER(SUBSTR(vCertNo, 11, 1)) * 3 + TO_NUMBER(SUBSTR(vCertNo, 12, 1)) * 2 + 
                                TO_NUMBER(SUBSTR(vCertNo, 13, 1)) * 3 + TO_NUMBER(SUBSTR(vCertNo, 14, 1)) * 2
                               , 10);
             
            vCertNo := vCertNo || nCheckDigit;
            
            -- 1.4  회원권 판매(CS_MEMBERSHIP_SALE) 등록
            INSERT  INTO CS_MEMBERSHIP_SALE
            (
                    COMP_CD
                 ,  PROGRAM_ID
                 ,  MBS_NO
                 ,  CERT_NO
                 ,  MEMBER_NO
                 ,  MOBILE
                 ,  MBS_DIV
                 ,  MBS_STAT
                 ,  CHARGE_YN
                 ,  CERT_FDT
                 ,  CERT_TDT
                 ,  SALE_DIV
                 ,  ENTR_PRC
                 ,  SALE_AMT
                 ,  DC_AMT
                 ,  GRD_AMT
                 ,  SALE_BRAND_CD
                 ,  SALE_STOR_CD
                 ,  USE_DIV
                 ,  OFFER_TM
                 ,  USE_TM
                 ,  OFFER_CNT
                 ,  USE_CNT
                 ,  OFFER_AMT
                 ,  USE_AMT
                 ,  OFFER_MCNT
                 ,  USE_MCNT
                 ,  USE_YN
                 ,  INST_DT
                 ,  INST_USER
                 ,  UPD_DT
                 ,  UPD_USER

            ) VALUES (
                    PSV_COMP_CD
                 ,  PSV_PROGRAM_ID
                 ,  PSV_MBS_NO
                 ,  vCertNo
                 ,  PSV_MEMBER_NO
                 ,  (
                        SELECT  MOBILE
                          FROM  CS_MEMBER
                         WHERE  COMP_CD     = PSV_COMP_CD
                           AND  MEMBER_NO   = PSV_MEMBER_NO
                    )
                 ,  PSV_MBS_DIV
                 ,  '10'
                 ,  PSV_CHARGE_YN
                 ,  TO_CHAR(SYSDATE, 'YYYYMMDD')
                 ,  TO_CHAR(ADD_MONTHS(SYSDATE-1, nCertMonths), 'YYYYMMDD')
                 ,  '1'
                 ,  NVL(PSV_ENTR_PRC, 0)
                 ,  NVL(PSV_SALE_AMT, 0)
                 ,  NVL(PSV_DC_AMT, 0)
                 ,  NVL(PSV_GRD_AMT, 0)
                 ,  PSV_BRAND_CD
                 ,  PSV_STOR_CD
                 ,  '00'
                 ,  CASE WHEN PSV_MBS_DIV = '1' THEN TO_NUMBER(PSV_PROC_TM)
                         WHEN PSV_MBS_DIV = '2' THEN nBaseUseTm * TO_NUMBER(PSV_PROC_CNT)
                         ELSE 0
                    END
                 ,  0
                 ,  CASE WHEN PSV_MBS_DIV = '2' THEN TO_NUMBER(PSV_PROC_CNT)
                         ELSE 0
                    END
                 ,  0
                 ,  (
                        CASE WHEN PSV_MBS_DIV = '1' THEN TO_NUMBER(NVL(PSV_GRD_AMT, '0'))
                             WHEN PSV_MBS_DIV = '2' THEN TO_NUMBER(NVL(PSV_GRD_AMT, '0'))
                             WHEN PSV_MBS_DIV = '3' THEN TO_NUMBER(NVL(PSV_PROC_AMT, '0'))
                             ELSE 0
                        END
                    )
                 ,  0
                 ,  PSV_MATL_CNT
                 ,  0
                 ,  'Y'
                 ,  SYSDATE
                 ,  'SYSTEM'
                 ,  SYSDATE
                 ,  'SYSTEM'
            );
            
            -- 1.5  승인순번 조회
            SELECT  NVL(MAX(TO_NUMBER(APPR_SEQ)), 0) + 1  AS APPR_SEQ 
              INTO  nApprSeq
              FROM  CS_MEMBERSHIP_SALE_HIS
             WHERE  COMP_CD     = PSV_COMP_CD
               AND  PROGRAM_ID  = PSV_PROGRAM_ID
               AND  MBS_NO      = PSV_MBS_NO
               AND  CERT_NO     = vCertNo;
               
            -- 1.6  회원권 판매이력(CS_MEMBERSHIP_SALE_HIS) 등록
            INSERT  INTO CS_MEMBERSHIP_SALE_HIS
            (
                    COMP_CD
                 ,  PROGRAM_ID
                 ,  MBS_NO
                 ,  CERT_NO
                 ,  APPR_SEQ
                 ,  APPR_DT
                 ,  APPR_TM
                 ,  MBS_DIV
                 ,  SALE_USE_DIV
                 ,  SALE_DIV
                 ,  USE_STAT
                 ,  MEMBER_NO
                 ,  CHILD_NO
                 ,  USE_TM
                 ,  USE_CNT
                 ,  USE_AMT
                 ,  USE_MCNT
                 ,  SALE_BRAND_CD
                 ,  SALE_STOR_CD
                 ,  SALE_POS_NO
                 ,  SALE_BILL_NO
                 ,  SALE_SEQ
                 ,  SALE_AMT
                 ,  DC_AMT
                 ,  GRD_AMT
                 ,  INST_DT
                 ,  INST_USER
                 ,  UPD_DT
                 ,  UPD_USER
            ) VALUES (
                    PSV_COMP_CD
                 ,  PSV_PROGRAM_ID
                 ,  PSV_MBS_NO
                 ,  vCertNo
                 ,  nApprSeq
                 ,  TO_CHAR(SYSDATE, 'YYYYMMDD')
                 ,  TO_CHAR(SYSDATE, 'HH24MISS')
                 ,  PSV_MBS_DIV
                 ,  '1'
                 ,  '1'
                 ,  '00'
                 ,  PSV_MEMBER_NO
                 ,  PSV_CHILD_NO
                 ,  0
                 ,  0
                 ,  0
                 ,  0
                 ,  PSV_BRAND_CD
                 ,  PSV_STOR_CD
                 ,  PSV_POS_NO
                 ,  PSV_BILL_NO
                 ,  PSV_SALE_SEQ
                 ,  NVL(PSV_SALE_AMT, 0)
                 ,  NVL(PSV_DC_AMT, 0)
                 ,  NVL(PSV_GRD_AMT, 0)
                 ,  SYSDATE
                 ,  'SYSTEM'
                 ,  SYSDATE
                 ,  'SYSTEM'
            );
            
            -- 1.7  인증번호 반환
            OPEN asResult FOR
            SELECT  vCertNo, nApprSeq
              FROM  DUAL;
            
        ELSIF PSV_PROC_DIV = '2' THEN
            -- 2.   회원권 반품
            -- 2.1  회원권 상태 체크
            SELECT  MS.MBS_STAT, MS.SALE_DIV, MS.SALE_BRAND_CD, MS.SALE_STOR_CD, MS.CERT_FDT, MS.REFUND_YN
                 ,  CASE WHEN MS.MBS_STAT IN ('10', '90') THEN       
                              CASE WHEN MS.MBS_DIV = '1' THEN           -- 시간권의 환불금액 계산
                                        CASE WHEN TRUNC(MS.GRD_AMT - (MS.ENTR_PRC * (MS.USE_TM / P.BASE_USE_TM)), -2) <= 0 THEN 0     -- 사용시간금액이 구매금액을 초과하는 경우 환불금액은 0
                                             ELSE TRUNC(MS.GRD_AMT - (MS.ENTR_PRC * (MS.USE_TM / P.BASE_USE_TM)), -2)                 -- 환불금액 100원단위 절삭
                                        END 
                                   WHEN MS.MBS_DIV = '2' THEN           -- 횟수권의 환불금액 계산
                                        CASE WHEN TRUNC(MS.GRD_AMT - (MS.ENTR_PRC * MS.USE_CNT), -2) <= 0THEN 0                       -- 사용횟수금액이 구매금액을 초과하는 경우 환불금액은 0
                                             ELSE TRUNC(MS.GRD_AMT - (MS.ENTR_PRC * MS.USE_CNT), -2)                                  -- 환불금액 100원단위 절삭
                                        END 
                                   WHEN MS.MBS_DIV = '3' THEN           -- 금액권의 환불금액 계산
                                        CASE WHEN TRUNC(MS.GRD_AMT - MS.USE_AMT, -2) <= 0 THEN 0                                      -- 사용금액이 구매금액을 초과하는 경우 환불금액은 0
                                             ELSE TRUNC(MS.GRD_AMT - MS.USE_AMT, -2)                                                  -- 환불금액 100원단위 절삭
                                        END 
                                   ELSE 0                         
                            END 
                         ELSE 0 
                    END
                 ,  CASE WHEN MBS_STAT = '93'                                 THEN 'N'
                         WHEN SYSDATE - TO_DATE(MS.CERT_FDT, 'YYYYMMDD') > 31 THEN 'Y' ELSE 'N' 
                    END
              INTO  vMbsStat, vSaleDiv, vSaleBrandCd, vSaleStorCd, vCertFdt, vRefundYn, nRefundAmt, vRefundTermPassYn
              FROM  CS_MEMBERSHIP_SALE  MS
                 ,  CS_PROGRAM          P
             WHERE  MS.COMP_CD      = P.COMP_CD
               AND  MS.PROGRAM_ID   = P.PROGRAM_ID
               AND  MS.COMP_CD      = PSV_COMP_CD
               AND  MS.PROGRAM_ID   = PSV_PROGRAM_ID
               AND  MS.MBS_NO       = PSV_MBS_NO
               AND  MS.CERT_NO      = PSV_CERT_NO
            ;
            
            IF vSaleBrandCd IS NOT NULL AND vSaleStorCd IS NOT NULL THEN
                SELECT  NVL(L.STOR_NM, S.STOR_NM)
                  INTO  vSaleStorNm
                  FROM  STORE       S
                     ,  LANG_STORE  L
                 WHERE  S.COMP_CD   = L.COMP_CD(+)
                   AND  S.BRAND_CD  = L.BRAND_CD(+)
                   AND  S.STOR_CD   = L.STOR_CD(+)
                   AND  S.COMP_CD   = PSV_COMP_CD
                   AND  S.BRAND_CD  = vSaleBrandCd
                   AND  S.STOR_CD   = vSaleStorCd
                ;
            END IF;
            
            IF vMbsStat = '11' THEN
                asRetVal := '2010';   
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001528'); -- 사용완료 상태의 회원권입니다.   
                RAISE ERR_HANDLER;
            ELSIF vMbsStat = '91' AND vRefundYn = 'N' THEN
                asRetVal := '2020';   
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001495'); -- 환불요청 상태의 회원권입니다.   
                RAISE ERR_HANDLER;
            ELSIF vMbsStat = '92' THEN
                asRetVal := '2030';   
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001496'); -- 환불 상태의 회원권입니다.   
                RAISE ERR_HANDLER;
            ELSIF vMbsStat = '99' THEN
                asRetVal := '2040';   
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001497'); -- 폐기된 회원권입니다.   
                RAISE ERR_HANDLER;
            ELSIF vSaleDiv = '2' THEN
                asRetVal := '2050';   
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001498'); -- 반품상태의 회원권입니다.   
                RAISE ERR_HANDLER;
            --ELSIF nRefundAmt = 0 THEN
            --    asRetVal := '2060';   
            --    asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001517'); -- 환불금액이 0원인 회원권은 환불이 불가능합니다.   
            --    RAISE ERR_HANDLER;
            --ELSIF vRefundTermPassYn = 'Y' THEN
            --    asRetVal := '2070';   
            --    asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001504'); -- 환불기간을 경과하였습니다.\n환불요청 후 다시 시도하여 주십시요.   
            --    RAISE ERR_HANDLER;
            END IF;
            
            -- 2.2  승인순번 조회
            SELECT  NVL(MAX(TO_NUMBER(APPR_SEQ)), 0) + 1  AS APPR_SEQ 
              INTO  nApprSeq
              FROM  CS_MEMBERSHIP_SALE_HIS
             WHERE  COMP_CD     = PSV_COMP_CD
               AND  PROGRAM_ID  = PSV_PROGRAM_ID
               AND  MBS_NO      = PSV_MBS_NO
               AND  CERT_NO     = PSV_CERT_NO;
               
            -- 2.3  회원권 판매이력(CS_MEMBERSHIP_SALE_HIS) 등록
            INSERT  INTO CS_MEMBERSHIP_SALE_HIS
            (
                    COMP_CD
                 ,  PROGRAM_ID
                 ,  MBS_NO
                 ,  CERT_NO
                 ,  APPR_SEQ
                 ,  APPR_DT
                 ,  APPR_TM
                 ,  MBS_DIV
                 ,  SALE_USE_DIV
                 ,  SALE_DIV
                 ,  USE_STAT
                 ,  MEMBER_NO
                 ,  CHILD_NO
                 ,  USE_TM
                 ,  USE_CNT
                 ,  USE_AMT
                 ,  USE_MCNT
                 ,  SALE_BRAND_CD
                 ,  SALE_STOR_CD
                 ,  SALE_POS_NO
                 ,  SALE_BILL_NO
                 ,  SALE_SEQ
                 ,  SALE_AMT
                 ,  DC_AMT
                 ,  GRD_AMT
                 ,  INST_DT
                 ,  INST_USER
                 ,  UPD_DT
                 ,  UPD_USER
            ) VALUES (
                    PSV_COMP_CD
                 ,  PSV_PROGRAM_ID
                 ,  PSV_MBS_NO
                 ,  PSV_CERT_NO
                 ,  nApprSeq
                 ,  TO_CHAR(SYSDATE, 'YYYYMMDD')
                 ,  TO_CHAR(SYSDATE, 'HH24MISS')
                 ,  PSV_MBS_DIV
                 ,  '1'
                 ,  '2'
                 ,  '11'
                 ,  PSV_MEMBER_NO
                 ,  PSV_CHILD_NO
                 ,  0
                 ,  0
                 ,  0
                 ,  0
                 ,  PSV_BRAND_CD
                 ,  PSV_STOR_CD
                 ,  PSV_POS_NO
                 ,  PSV_BILL_NO
                 ,  PSV_SALE_SEQ
                 ,  NVL(PSV_SALE_AMT, 0)
                 ,  NVL(PSV_DC_AMT, 0)
                 ,  NVL(PSV_GRD_AMT, 0)
                 ,  SYSDATE
                 ,  'SYSTEM'
                 ,  SYSDATE
                 ,  'SYSTEM'
            );
            
            -- 2.4  회원권 판매(CS_MEMBERSHIP_SALE) 수정
            UPDATE  CS_MEMBERSHIP_SALE
               SET  MBS_STAT    = '92'                                  -- 환불/반품
                 ,  SALE_DIV    = '2'
                 ,  USE_DIV     = '11'
                 ,  REFUND_DT   = TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')  -- 환불일자에 반품일자 저장
                 ,  REFUND_AMT  = PSV_GRD_AMT                           -- 환불금액에 반품금액 저장
                 ,  UPD_DT      = SYSDATE
                 ,  UPD_USER    = 'SYSTEM'
             WHERE  COMP_CD     = PSV_COMP_CD
               AND  PROGRAM_ID  = PSV_PROGRAM_ID
               AND  MBS_NO      = PSV_MBS_NO
               AND  CERT_NO     = PSV_CERT_NO
            ;
            
            -- 2.5  처리결과 반환
            OPEN asResult FOR
            SELECT  PSV_CERT_NO, nApprSeq
              FROM  DUAL
            ;
            
        ELSIF PSV_PROC_DIV = '3' THEN
            -- 3.   회원권 사용
            -- 3.1  회원권 상태 체크
            SELECT  MBS_STAT, CERT_FDT, CERT_TDT, SALE_DIV, OFFER_TM - USE_TM, OFFER_CNT - USE_CNT, OFFER_AMT - USE_AMT
              INTO  vMbsStat, vCertFdt, vCertTdt, vSaleDiv, nRestTm, nRestCnt, nRestAmt
              FROM  CS_MEMBERSHIP_SALE
             WHERE  COMP_CD     = PSV_COMP_CD
               AND  PROGRAM_ID  = PSV_PROGRAM_ID
               AND  MBS_NO      = PSV_MBS_NO
               AND  CERT_NO     = PSV_CERT_NO
            ;
            
            IF vMbsStat = '90' OR TO_CHAR(SYSDATE, 'YYYYMMDD') > vCertTdt THEN
                asRetVal := '3010';   
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001494'); -- 유효기간이 만료된 회원권입니다.   
                RAISE ERR_HANDLER;
            ELSIF vMbsStat = '91' THEN
                asRetVal := '3020';   
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001495'); -- 환불요청 상태의 회원권입니다.   
                RAISE ERR_HANDLER;
            ELSIF vMbsStat = '92' THEN
                asRetVal := '3030';   
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001496'); -- 환불 상태의 회원권입니다.   
                RAISE ERR_HANDLER;
            ELSIF vMbsStat = '99' THEN
                asRetVal := '3040';   
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001497'); -- 폐기된 회원권입니다.   
                RAISE ERR_HANDLER;
            ELSIF vSaleDiv = '2' THEN
                asRetVal := '3050';   
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001498'); -- 반품상태의 회원권입니다.   
                RAISE ERR_HANDLER;
            ELSIF PSV_MBS_DIV = '1' AND TO_NUMBER(PSV_PROC_TM) > nRestTm THEN
                asRetVal := '3060';   
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001499')||'@$[ '||FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_TP, 'REST_TM')  || ' : '||nRestTm||']'; -- 사용시간이 잔여시간을 초과하였습니다.\n[잔여시간:XXX]   
                RAISE ERR_HANDLER;
            ELSIF PSV_MBS_DIV = '2' AND TO_NUMBER(PSV_PROC_CNT) > nRestCnt THEN
                asRetVal := '3070';   
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001500')||'@$[ '||FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_TP, 'REST_CNT') || ' : '||nRestCnt||']'; -- 사용횟수가 잔여횟수를 초과하였습니다.\n[잔여횟수:XXX]   
                RAISE ERR_HANDLER;
            ELSIF PSV_MBS_DIV = '3' AND TO_NUMBER(PSV_PROC_AMT) > nRestAmt THEN
                asRetVal := '3080';   
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001501')||'@$[ '||FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_TP, 'REST_AMT') || ' : '||TO_CHAR(nRestAmt, 'FM999,999')||']'; -- 사용금액이 잔여금액을 초과하였습니다.\n[잔여금액:XXX]   
                RAISE ERR_HANDLER;
            END IF;
            
            -- 3.2 이중 승인취소 방지
            IF PSV_APPR_SEQ IS NOT NULL THEN
                BEGIN
                    SELECT  APPR_SEQ
                      INTO  nApprSeq
                      FROM  CS_MEMBERSHIP_SALE_HIS
                     WHERE  COMP_CD     = PSV_COMP_CD
                       AND  PROGRAM_ID  = PSV_PROGRAM_ID
                       AND  MBS_NO      = PSV_MBS_NO
                       AND  CERT_NO     = PSV_CERT_NO
                       AND  APPR_SEQ    = PSV_APPR_SEQ;
                    
                    IF nApprSeq > 0 THEN
                        asRetVal := '3090';   
                        asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001523'); -- 이미 승인취소된 회원권입니다.   
                        RAISE ERR_HANDLER;
                    END IF;
                     
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            
                    nApprSeq := 0;
                    
                END;
            END IF;
            
            -- 3.3  승인순번 조회
            SELECT  NVL(MAX(TO_NUMBER(APPR_SEQ)), 0) + 1  AS APPR_SEQ 
              INTO  nApprSeq
              FROM  CS_MEMBERSHIP_SALE_HIS
             WHERE  COMP_CD     = PSV_COMP_CD
               AND  PROGRAM_ID  = PSV_PROGRAM_ID
               AND  MBS_NO      = PSV_MBS_NO
               AND  CERT_NO     = PSV_CERT_NO;
               
            -- 3.4  회원권 판매이력(CS_MEMBERSHIP_SALE_HIS) 등록
            INSERT  INTO CS_MEMBERSHIP_SALE_HIS
            (
                    COMP_CD
                 ,  PROGRAM_ID
                 ,  MBS_NO
                 ,  CERT_NO
                 ,  APPR_SEQ
                 ,  APPR_DT
                 ,  APPR_TM
                 ,  MBS_DIV
                 ,  SALE_USE_DIV
                 ,  SALE_DIV
                 ,  USE_STAT
                 ,  MEMBER_NO
                 ,  CHILD_NO
                 ,  USE_TM
                 ,  USE_CNT
                 ,  USE_AMT
                 ,  USE_MCNT
                 ,  SALE_BRAND_CD
                 ,  SALE_STOR_CD
                 ,  SALE_POS_NO
                 ,  SALE_BILL_NO
                 ,  SALE_SEQ
                 ,  SALE_AMT
                 ,  DC_AMT
                 ,  GRD_AMT
                 ,  INST_DT
                 ,  INST_USER
                 ,  UPD_DT
                 ,  UPD_USER
            ) VALUES (
                    PSV_COMP_CD
                 ,  PSV_PROGRAM_ID
                 ,  PSV_MBS_NO
                 ,  PSV_CERT_NO
                 ,  nApprSeq
                 ,  TO_CHAR(SYSDATE, 'YYYYMMDD')
                 ,  TO_CHAR(SYSDATE, 'HH24MISS')
                 ,  PSV_MBS_DIV
                 ,  '2'
                 ,  '1'
                 ,  '10'
                 ,  PSV_MEMBER_NO
                 ,  PSV_CHILD_NO
                 ,  TO_NUMBER(NVL(PSV_PROC_TM , '0'))
                 ,  TO_NUMBER(NVL(PSV_PROC_CNT, '0'))
                 ,  TO_NUMBER(NVL(PSV_PROC_AMT, '0'))
                 ,  PSV_MATL_CNT
                 ,  PSV_BRAND_CD
                 ,  PSV_STOR_CD
                 ,  PSV_POS_NO
                 ,  PSV_BILL_NO
                 ,  PSV_SALE_SEQ
                 ,  PSV_SALE_AMT
                 ,  PSV_DC_AMT
                 ,  PSV_GRD_AMT
                 ,  SYSDATE
                 ,  'SYSTEM'
                 ,  SYSDATE
                 ,  'SYSTEM'
            );
            
            -- 3.5  회원권 판매(CS_MEMBERSHIP_SALE) 수정
            UPDATE  CS_MEMBERSHIP_SALE
               SET  MBS_STAT    = CASE WHEN PSV_CHARGE_YN = '1' AND PSV_MBS_DIV = '1' AND OFFER_TM  > USE_TM  + TO_NUMBER(NVL(PSV_PROC_TM , '0')) THEN '10'     -- 시간권의 잔여시간이 남은 경우
                                       WHEN PSV_CHARGE_YN = '1' AND PSV_MBS_DIV = '1' AND OFFER_TM  = USE_TM  + TO_NUMBER(NVL(PSV_PROC_TM , '0')) THEN '11'     -- 시간권의 잔여시간이 소진한 경우
                                       WHEN PSV_CHARGE_YN = '2' AND PSV_MBS_DIV = '1'                                                             THEN '11'     -- 시간권이면서 무료회원권인 경우 사용시 소진시킴 
                                       WHEN PSV_CHARGE_YN = '1' AND PSV_MBS_DIV = '2' AND OFFER_CNT > USE_CNT + TO_NUMBER(NVL(PSV_PROC_CNT, '0')) THEN '10'     -- 횟수권의 잔여횟수가 남은 경우
                                       WHEN PSV_CHARGE_YN = '1' AND PSV_MBS_DIV = '2' AND OFFER_CNT = USE_CNT + TO_NUMBER(NVL(PSV_PROC_CNT, '0')) THEN '11'     -- 횟수권의 잔여횟수를 소진한 경우
                                       WHEN PSV_CHARGE_YN = '2' AND PSV_MBS_DIV = '2'                                                             THEN '11'     -- 횟수권이면서 무료회원권인 경우 사용시 소진시킴
                                       WHEN PSV_CHARGE_YN = '1' AND PSV_MBS_DIV = '3' AND OFFER_AMT > USE_AMT + TO_NUMBER(NVL(PSV_PROC_AMT, '0')) THEN '10'     -- 금액권의 잔여금액이 남은 경우
                                       WHEN PSV_CHARGE_YN = '1' AND PSV_MBS_DIV = '3' AND OFFER_AMT = USE_AMT + TO_NUMBER(NVL(PSV_PROC_AMT, '0')) THEN '11'     -- 금액권의 잔여금액을 소진한 경우
                                       WHEN PSV_CHARGE_YN = '2' AND PSV_MBS_DIV = '3'                                                             THEN '11'     -- 금액권이면서 무료회원권인 경우 사용시 소진시킴
                                       ELSE '10'
                                  END
                 ,  USE_DIV     = '10'
                 ,  USE_TM      = USE_TM   + TO_NUMBER(NVL(PSV_PROC_TM  , '0'))
                 ,  USE_CNT     = USE_CNT  + TO_NUMBER(NVL(PSV_PROC_CNT , '0'))
                 ,  USE_AMT     = USE_AMT  + TO_NUMBER(NVL(PSV_PROC_AMT , '0'))
                 ,  USE_MCNT    = CASE WHEN OFFER_MCNT > 0 THEN USE_MCNT + TO_NUMBER(NVL(PSV_MATL_CNT , '0')) ELSE 0 END
                 ,  UPD_DT      = SYSDATE
                 ,  UPD_USER    = 'SYSTEM'
             WHERE  COMP_CD     = PSV_COMP_CD
               AND  PROGRAM_ID  = PSV_PROGRAM_ID
               AND  MBS_NO      = PSV_MBS_NO
               AND  CERT_NO     = PSV_CERT_NO
            ;
            
            -- 3.6  처리결과 반환
            OPEN asResult FOR
            SELECT  PROGRAM_ID, MBS_NO, CERT_NO, nApprSeq, MEMBER_NO, PSV_MBS_DIV, OFFER_TM, USE_TM, OFFER_CNT, USE_CNT, OFFER_AMT, USE_AMT, OFFER_MCNT, USE_MCNT
              FROM  CS_MEMBERSHIP_SALE
             WHERE  COMP_CD     = PSV_COMP_CD
               AND  PROGRAM_ID  = PSV_PROGRAM_ID
               AND  MBS_NO      = PSV_MBS_NO
               AND  CERT_NO     = PSV_CERT_NO
            ;
            
        ELSIF PSV_PROC_DIV = '4' THEN
            -- 4.   회원권 사용취소
            -- 4.1  회원권 상태 체크
            SELECT  MBS_STAT, CERT_FDT, CERT_TDT, SALE_DIV
              INTO  vMbsStat, vCertFdt, vCertTdt, vSaleDiv
              FROM  CS_MEMBERSHIP_SALE
             WHERE  COMP_CD     = PSV_COMP_CD
               AND  PROGRAM_ID  = PSV_PROGRAM_ID
               AND  MBS_NO      = PSV_MBS_NO
               AND  CERT_NO     = PSV_CERT_NO
            ;
            
            IF vMbsStat = '90' OR TO_CHAR(SYSDATE, 'YYYYMMDD') > vCertTdt THEN
                asRetVal := '4010';   
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001494'); -- 유효기간이 만료된 회원권입니다.   
                RAISE ERR_HANDLER;
            ELSIF vMbsStat = '91' THEN
                asRetVal := '4020';   
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001495'); -- 환불요청 상태의 회원권입니다.   
                RAISE ERR_HANDLER;
            ELSIF vMbsStat = '99' THEN
                asRetVal := '4040';   
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001497'); -- 폐기된 회원권입니다.   
                RAISE ERR_HANDLER;
            END IF;
            
            -- 4.2  승인순번 조회
            SELECT  NVL(MAX(TO_NUMBER(APPR_SEQ)), 0) + 1  AS APPR_SEQ 
              INTO  nApprSeq
              FROM  CS_MEMBERSHIP_SALE_HIS
             WHERE  COMP_CD     = PSV_COMP_CD
               AND  PROGRAM_ID  = PSV_PROGRAM_ID
               AND  MBS_NO      = PSV_MBS_NO
               AND  CERT_NO     = PSV_CERT_NO;
               
            -- 4.3  회원권 판매이력(CS_MEMBERSHIP_SALE_HIS) 등록
            INSERT  INTO CS_MEMBERSHIP_SALE_HIS
            (
                    COMP_CD
                 ,  PROGRAM_ID
                 ,  MBS_NO
                 ,  CERT_NO
                 ,  APPR_SEQ
                 ,  APPR_DT
                 ,  APPR_TM
                 ,  MBS_DIV
                 ,  SALE_USE_DIV
                 ,  SALE_DIV
                 ,  USE_STAT
                 ,  MEMBER_NO
                 ,  CHILD_NO
                 ,  USE_TM
                 ,  USE_CNT
                 ,  USE_AMT
                 ,  USE_MCNT
                 ,  SALE_BRAND_CD
                 ,  SALE_STOR_CD
                 ,  SALE_POS_NO
                 ,  SALE_BILL_NO
                 ,  SALE_SEQ
                 ,  SALE_AMT
                 ,  DC_AMT
                 ,  GRD_AMT
                 ,  INST_DT
                 ,  INST_USER
                 ,  UPD_DT
                 ,  UPD_USER
            ) VALUES (
                    PSV_COMP_CD
                 ,  PSV_PROGRAM_ID
                 ,  PSV_MBS_NO
                 ,  PSV_CERT_NO
                 ,  nApprSeq
                 ,  TO_CHAR(SYSDATE, 'YYYYMMDD')
                 ,  TO_CHAR(SYSDATE, 'HH24MISS')
                 ,  PSV_MBS_DIV
                 ,  '2'
                 ,  '2'
                 ,  '11'
                 ,  PSV_MEMBER_NO
                 ,  PSV_CHILD_NO
                 ,  TO_NUMBER(NVL(PSV_PROC_TM , '0'))
                 ,  TO_NUMBER(NVL(PSV_PROC_CNT, '0'))
                 ,  TO_NUMBER(NVL(PSV_PROC_AMT, '0'))
                 ,  PSV_MATL_CNT
                 ,  PSV_BRAND_CD
                 ,  PSV_STOR_CD
                 ,  PSV_POS_NO
                 ,  PSV_BILL_NO
                 ,  PSV_SALE_SEQ
                 ,  PSV_SALE_AMT
                 ,  PSV_DC_AMT
                 ,  PSV_GRD_AMT
                 ,  SYSDATE
                 ,  'SYSTEM'
                 ,  SYSDATE
                 ,  'SYSTEM'
            );
            
            -- 4.4  회원권 판매(CS_MEMBERSHIP_SALE) 수정
            UPDATE  CS_MEMBERSHIP_SALE
               SET  MBS_STAT    = CASE WHEN MBS_STAT    = '92'                                                            THEN '92'
                                       WHEN PSV_MBS_DIV = '1' AND OFFER_TM  > USE_TM  + TO_NUMBER(NVL(PSV_PROC_TM , '0')) THEN '10'
                                       WHEN PSV_MBS_DIV = '1' AND OFFER_TM  = USE_TM  + TO_NUMBER(NVL(PSV_PROC_TM , '0')) THEN '11'
                                       WHEN PSV_MBS_DIV = '2' AND OFFER_CNT > USE_CNT + TO_NUMBER(NVL(PSV_PROC_CNT, '0')) THEN '10'
                                       WHEN PSV_MBS_DIV = '2' AND OFFER_CNT = USE_CNT + TO_NUMBER(NVL(PSV_PROC_CNT, '0')) THEN '11'
                                       WHEN PSV_MBS_DIV = '3' AND OFFER_AMT > USE_AMT + TO_NUMBER(NVL(PSV_PROC_AMT, '0')) THEN '10'
                                       WHEN PSV_MBS_DIV = '3' AND OFFER_AMT = USE_AMT + TO_NUMBER(NVL(PSV_PROC_AMT, '0')) THEN '11'
                                       ELSE '10'
                                  END
                 ,  USE_DIV     = '11'
                 ,  USE_TM      = USE_TM   + TO_NUMBER(NVL(PSV_PROC_TM  , '0'))
                 ,  USE_CNT     = USE_CNT  + TO_NUMBER(NVL(PSV_PROC_CNT , '0'))
                 ,  USE_AMT     = USE_AMT  + TO_NUMBER(NVL(PSV_PROC_AMT , '0'))
                 ,  USE_MCNT    = CASE WHEN OFFER_MCNT > 0 THEN USE_MCNT + TO_NUMBER(NVL(PSV_MATL_CNT , '0')) ELSE 0 END
                 ,  UPD_DT      = SYSDATE
                 ,  UPD_USER    = 'SYSTEM'
             WHERE  COMP_CD     = PSV_COMP_CD
               AND  PROGRAM_ID  = PSV_PROGRAM_ID
               AND  MBS_NO      = PSV_MBS_NO
               AND  CERT_NO     = PSV_CERT_NO
            ;
            
            -- 4.5  처리결과 반환
            OPEN asResult FOR
            SELECT  PROGRAM_ID, MBS_NO, CERT_NO, nApprSeq, MEMBER_NO, PSV_MBS_DIV, OFFER_TM, USE_TM, OFFER_CNT, USE_CNT, OFFER_AMT, USE_AMT, OFFER_MCNT, USE_MCNT
              FROM  CS_MEMBERSHIP_SALE
             WHERE  COMP_CD     = PSV_COMP_CD
               AND  PROGRAM_ID  = PSV_PROGRAM_ID
               AND  MBS_NO      = PSV_MBS_NO
               AND  CERT_NO     = PSV_CERT_NO
            ;
        
        ELSIF PSV_PROC_DIV = '5' THEN
            -- 5.   회원권 환불요청
            -- 5.1  회원권 상태 체크
            SELECT  MS.MBS_STAT, MS.CERT_FDT, MS.CERT_TDT, MS.SALE_DIV
                 ,  CASE WHEN MS.MBS_STAT IN ('10', '90') THEN       
                              CASE WHEN MS.MBS_DIV = '1' THEN           -- 시간권의 환불금액 계산
                                        CASE WHEN TRUNC(MS.GRD_AMT - (MS.ENTR_PRC * (MS.USE_TM / P.BASE_USE_TM)), -2) <= 0 THEN 0     -- 사용시간금액이 구매금액을 초과하는 경우 환불금액은 0
                                             ELSE TRUNC(MS.GRD_AMT - (MS.ENTR_PRC * (MS.USE_TM / P.BASE_USE_TM)), -2)                 -- 환불금액 100원단위 절삭
                                        END 
                                   WHEN MS.MBS_DIV = '2' THEN           -- 횟수권의 환불금액 계산
                                        CASE WHEN TRUNC(MS.GRD_AMT - (MS.ENTR_PRC * MS.USE_CNT), -2) <= 0THEN 0                       -- 사용횟수금액이 구매금액을 초과하는 경우 환불금액은 0
                                             ELSE TRUNC(MS.GRD_AMT - (MS.ENTR_PRC * MS.USE_CNT), -2)                                  -- 환불금액 100원단위 절삭
                                        END 
                                   WHEN MS.MBS_DIV = '3' THEN           -- 금액권의 환불금액 계산
                                        CASE WHEN TRUNC(MS.GRD_AMT - MS.USE_AMT, -2) <= 0 THEN 0                                      -- 사용금액이 구매금액을 초과하는 경우 환불금액은 0
                                             ELSE TRUNC(MS.GRD_AMT - MS.USE_AMT, -2)                                                  -- 환불금액 100원단위 절삭
                                        END 
                                   ELSE 0                         
                            END 
                         ELSE 0 
                    END
              INTO  vMbsStat, vCertFdt, vCertTdt, vSaleDiv, nRefundAmt
              FROM  CS_MEMBERSHIP_SALE  MS
                 ,  CS_PROGRAM          P
             WHERE  MS.COMP_CD      = P.COMP_CD
               AND  MS.PROGRAM_ID   = P.PROGRAM_ID
               AND  MS.COMP_CD      = PSV_COMP_CD
               AND  MS.PROGRAM_ID   = PSV_PROGRAM_ID
               AND  MS.MBS_NO       = PSV_MBS_NO
               AND  MS.CERT_NO      = PSV_CERT_NO
            ;
            
            IF vMbsStat = '91' THEN
                asRetVal := '5010';   
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001495'); -- 환불요청 상태의 회원권입니다.   
                RAISE ERR_HANDLER;
            ELSIF vMbsStat = '92' THEN
                asRetVal := '5020';   
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001496'); -- 환불 상태의 회원권입니다.   
                RAISE ERR_HANDLER;
            ELSIF vMbsStat = '99' THEN
                asRetVal := '5030';   
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001497'); -- 폐기된 회원권입니다.   
                RAISE ERR_HANDLER;
            ELSIF vSaleDiv = '2' THEN
                asRetVal := '5040';   
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001498'); -- 반품상태의 회원권입니다.   
                RAISE ERR_HANDLER;
            ELSIF nRefundAmt = 0 THEN
                asRetVal := '5050';   
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001517'); -- 환불금액이 0원인 회원권은 환불이 불가능합니다.   
                RAISE ERR_HANDLER;
            END IF;
            
            -- 5.2  회원권 판매(CS_MEMBERSHIP_SALE) 수정
            UPDATE  CS_MEMBERSHIP_SALE
               SET  MBS_STAT        = '91'
                 ,  REFUND_REQ_DT   = TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')
                 ,  UPD_DT          = SYSDATE
                 ,  UPD_USER        = 'SYSTEM'
             WHERE  COMP_CD         = PSV_COMP_CD
               AND  PROGRAM_ID      = PSV_PROGRAM_ID
               AND  MBS_NO          = PSV_MBS_NO
               AND  CERT_NO         = PSV_CERT_NO
            ;
            
            -- 5.3  처리결과 반환
            OPEN asResult FOR
            SELECT  MBS_STAT, REFUND_REQ_DT
              FROM  CS_MEMBERSHIP_SALE
             WHERE  COMP_CD     = PSV_COMP_CD
               AND  PROGRAM_ID  = PSV_PROGRAM_ID
               AND  MBS_NO      = PSV_MBS_NO
               AND  CERT_NO     = PSV_CERT_NO
            ;
                
        END IF;
        
        asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001392'); -- 정상처리 되었습니다.
        
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
        
        RETURN;
        
    EXCEPTION
        WHEN ERR_HANDLER THEN
            OPEN asResult FOR
                SELECT  asRetVal
                  FROM  DUAL;
            
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
            ROLLBACK;
            RETURN;
        WHEN OTHERS THEN
            asRetVal := '9999';
            asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1004999999');  -- 자료처리중 오류가 발생했습니다. 관리자에게 문의하여 주십시오.
            --asRetMsg := SQLERRM;
            OPEN asResult FOR
                SELECT  asRetVal
                  FROM  DUAL;
            
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
            ROLLBACK;
            RETURN;
    END SET_MEMBSHIP_INFO_10;
    
        --------------------------------------------------------------------------------
    --  Procedure Name   : SET_MEMBSHIP_INFO_11
    --  Description      : 회원권 조정/조정취소
    --  Ref. Table       : CS_MEMBERSHIP_SALE       회원권 판매
    --                     CS_MEMBERSHIP_SALE_HIS   회원권 판매이력
    --------------------------------------------------------------------------------
    --  Create Date      : 2016-05-19   최세원
    --  Modify Date      :  
    --------------------------------------------------------------------------------
    PROCEDURE SET_MEMBSHIP_INFO_11
    ( 
        PSV_COMP_CD           IN   VARCHAR2,        -- 1. 회사코드 
        PSV_LANG_TP           IN   VARCHAR2,        -- 2. 언어코드
        PSV_PROC_DIV          IN   VARCHAR2,        -- 3. 처리구분(3:조정, 4:조정취소)
        PSV_SALE_DT           IN   VARCHAR2,        -- 4. 처리일자
        PSV_BRAND_CD          IN   VARCHAR2,        -- 5. 영업조직
        PSV_STOR_CD           IN   VARCHAR2,        -- 6. 점포코드
        PSV_PROGRAM_ID        IN   VARCHAR2,        -- 7. 프로그램ID
        PSV_MBS_DIV           IN   VARCHAR2,        -- 8. 회원권종류(1:시간권, 2:횟수권, 3:금액권)
        PSV_MBS_NO            IN   VARCHAR2,        -- 9. 회원권번호
        PSV_CERT_NO           IN   VARCHAR2,        -- 10.인증번호
        PSV_APPR_SEQ          IN   VARCHAR2,        -- 11.승인번호
        PSV_MEMBER_NO         IN   VARCHAR2,        -- 12.회원번호
        PSV_CHILD_NO          IN   VARCHAR2,        -- 13.자녀번호
        PSV_POS_NO            IN   VARCHAR2,        -- 14.포스번호
        PSV_BILL_NO           IN   VARCHAR2,        -- 15.영수증번호
        PSV_SALE_SEQ          IN   VARCHAR2,        -- 16.판매순번
        PSV_ENTR_PRC          IN   VARCHAR2,        -- 17.1회 입장료
        PSV_SALE_AMT          IN   VARCHAR2,        -- 18.판매금액
        PSV_DC_AMT            IN   VARCHAR2,        -- 19.할인금액
        PSV_GRD_AMT           IN   VARCHAR2,        -- 20.결제금액
        PSV_CHARGE_YN         IN   VARCHAR2,        -- 21.유무상구분
        PSV_PROC_TM           IN   VARCHAR2,        -- 22.처리시간(시간권 : 사용시간, 횟수권 : 기본이용시간 * 사용횟수)
        PSV_PROC_CNT          IN   VARCHAR2,        -- 23.처리횟수(횟수권만 사용횟수 전달)
        PSV_PROC_AMT          IN   VARCHAR2,        -- 24.처리금액(시간권 : 사용시간 * 분단위 단가(잔여금액의 조정필요), 횟수권 : 사용횟수 * 횟수단위 단가(잔여금액의 조정필요), 금액권 : 사용금액)
        PSV_MATL_CNT          IN   VARCHAR2,        -- 25.교구횟수(1:제공횟수, 2:0, 3:사용횟수, 4:취소횟수, 5:0)
        PSV_REMARKS           IN   VARCHAR2,        -- 26.비고
        PSV_UPD_USER          IN   VARCHAR2,        -- 27.등록자
        asRetVal              OUT  VARCHAR2,        -- 28.결과코드[0000:정상  그외는 오류] 
        asRetMsg              OUT  VARCHAR2         -- 29.결과메시지
    ) IS
    
    lsSqlMain       VARCHAR2(32000) := NULL;
    vMbsStat        CS_MEMBERSHIP_SALE.MBS_STAT%TYPE        := NULL;        -- 회원권상태
    vCertFdt        CS_MEMBERSHIP_SALE.CERT_FDT%TYPE        := NULL;        -- 유효기간 시작일자
    vCertTdt        CS_MEMBERSHIP_SALE.CERT_TDT%TYPE        := NULL;        -- 유효기간 종료일자
    vSaleDiv        CS_MEMBERSHIP_SALE.SALE_DIV%TYPE        := NULL;        -- 판매구분
    vCertNo         CS_MEMBERSHIP_SALE.CERT_NO%TYPE         := NULL;        -- 인증번호
    vSaleBrandCd    CS_MEMBERSHIP_SALE.SALE_BRAND_CD%TYPE   := NULL;        -- 판매영업조직
    vSaleStorCd     CS_MEMBERSHIP_SALE.SALE_STOR_CD%TYPE    := NULL;        -- 판매점포코드
    vRefundYn       CS_MEMBERSHIP_SALE.REFUND_YN%TYPE       := NULL;        -- 환불승인여부
    vSaleStorNm     STORE.STOR_NM%TYPE                      := NULL;        -- 판매점포명
    vRefundTermPassYn   VARCHAR2(1)                         := NULL;        -- 환불기간 경과여부
    nCertMonths     CS_MEMBERSHIP.CERT_MONTHS%TYPE          := 0;           -- 유효기간 개월수
    nApprSeq        CS_MEMBERSHIP_SALE_HIS.APPR_SEQ%TYPE    := 1;           -- 승인순번
    nBaseUseTm      CS_PROGRAM.BASE_USE_TM%TYPE             := 0;           -- 기본이용시간
    nRestTm         CS_MEMBERSHIP_SALE.USE_TM%TYPE          := 0;           -- 잔여시간
    nRestCnt        CS_MEMBERSHIP_SALE.USE_CNT%TYPE         := 0;           -- 잔여횟수
    nRestAmt        CS_MEMBERSHIP_SALE.USE_AMT%TYPE         := 0;           -- 잔여금액
    nRefundAmt      CS_MEMBERSHIP_SALE.REFUND_AMT%TYPE      := 0;           -- 환불금액
    nCheckDigit     NUMBER(7) := 0;                                         -- 체크디지트
    
    ERR_HANDLER     EXCEPTION;
    
    BEGIN
        
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';
        
        asRetVal    := '0000';
        asRetMsg    := 'OK';
        
        IF PSV_PROC_DIV = '3' THEN
            -- 3.   회원권 사용
            -- 3.1  회원권 상태 체크
            SELECT  MBS_STAT, CERT_FDT, CERT_TDT, SALE_DIV, OFFER_TM - USE_TM, OFFER_CNT - USE_CNT, OFFER_AMT - USE_AMT
              INTO  vMbsStat, vCertFdt, vCertTdt, vSaleDiv, nRestTm, nRestCnt, nRestAmt
              FROM  CS_MEMBERSHIP_SALE
             WHERE  COMP_CD     = PSV_COMP_CD
               AND  PROGRAM_ID  = PSV_PROGRAM_ID
               AND  MBS_NO      = PSV_MBS_NO
               AND  CERT_NO     = PSV_CERT_NO
            ;
            
            IF vMbsStat = '90' OR TO_CHAR(SYSDATE, 'YYYYMMDD') > vCertTdt THEN
                asRetVal := '3010';   
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001494'); -- 유효기간이 만료된 회원권입니다.   
                RAISE ERR_HANDLER;
            ELSIF vMbsStat = '91' THEN
                asRetVal := '3020';   
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001495'); -- 환불요청 상태의 회원권입니다.   
                RAISE ERR_HANDLER;
            ELSIF vMbsStat = '92' THEN
                asRetVal := '3030';   
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001496'); -- 환불 상태의 회원권입니다.   
                RAISE ERR_HANDLER;
            ELSIF vMbsStat = '99' THEN
                asRetVal := '3040';   
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001497'); -- 폐기된 회원권입니다.   
                RAISE ERR_HANDLER;
            ELSIF vSaleDiv = '2' THEN
                asRetVal := '3050';   
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001498'); -- 반품상태의 회원권입니다.   
                RAISE ERR_HANDLER;
            ELSIF PSV_MBS_DIV = '1' AND TO_NUMBER(PSV_PROC_TM) > nRestTm THEN
                asRetVal := '3060';   
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001499')||'@$[ '||FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_TP, 'REST_TM')  || ' : '||nRestTm||']'; -- 사용시간이 잔여시간을 초과하였습니다.\n[잔여시간:XXX]   
                RAISE ERR_HANDLER;
            ELSIF PSV_MBS_DIV = '2' AND TO_NUMBER(PSV_PROC_CNT) > nRestCnt THEN
                asRetVal := '3070';   
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001500')||'@$[ '||FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_TP, 'REST_CNT') || ' : '||nRestCnt||']'; -- 사용횟수가 잔여횟수를 초과하였습니다.\n[잔여횟수:XXX]   
                RAISE ERR_HANDLER;
            ELSIF PSV_MBS_DIV = '3' AND TO_NUMBER(PSV_PROC_AMT) > nRestAmt THEN
                asRetVal := '3080';   
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001501')||'@$[ '||FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_TP, 'REST_AMT') || ' : '||TO_CHAR(nRestAmt, 'FM999,999')||']'; -- 사용금액이 잔여금액을 초과하였습니다.\n[잔여금액:XXX]   
                RAISE ERR_HANDLER;
            END IF;
            
            -- 3.2 이중 승인취소 방지
            IF PSV_APPR_SEQ IS NOT NULL THEN
                BEGIN
                    SELECT  APPR_SEQ
                      INTO  nApprSeq
                      FROM  CS_MEMBERSHIP_SALE_HIS
                     WHERE  COMP_CD     = PSV_COMP_CD
                       AND  PROGRAM_ID  = PSV_PROGRAM_ID
                       AND  MBS_NO      = PSV_MBS_NO
                       AND  CERT_NO     = PSV_CERT_NO
                       AND  APPR_SEQ    = PSV_APPR_SEQ;
                    
                    IF nApprSeq > 0 THEN
                        asRetVal := '3090';   
                        asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001523'); -- 이미 승인취소된 회원권입니다.   
                        RAISE ERR_HANDLER;
                    END IF;
                     
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            
                    nApprSeq := 0;
                    
                END;
            END IF;
            
            -- 3.3  승인순번 조회
            SELECT  NVL(MAX(TO_NUMBER(APPR_SEQ)), 0) + 1  AS APPR_SEQ 
              INTO  nApprSeq
              FROM  CS_MEMBERSHIP_SALE_HIS
             WHERE  COMP_CD     = PSV_COMP_CD
               AND  PROGRAM_ID  = PSV_PROGRAM_ID
               AND  MBS_NO      = PSV_MBS_NO
               AND  CERT_NO     = PSV_CERT_NO;
               
            -- 3.4  회원권 판매이력(CS_MEMBERSHIP_SALE_HIS) 등록
            INSERT  INTO CS_MEMBERSHIP_SALE_HIS
            (
                    COMP_CD
                 ,  PROGRAM_ID
                 ,  MBS_NO
                 ,  CERT_NO
                 ,  APPR_SEQ
                 ,  APPR_DT
                 ,  APPR_TM
                 ,  MBS_DIV
                 ,  SALE_USE_DIV
                 ,  SALE_DIV
                 ,  USE_STAT
                 ,  MEMBER_NO
                 ,  CHILD_NO
                 ,  USE_TM
                 ,  USE_CNT
                 ,  USE_AMT
                 ,  USE_MCNT
                 ,  SALE_BRAND_CD
                 ,  SALE_STOR_CD
                 ,  SALE_POS_NO
                 ,  SALE_BILL_NO
                 ,  SALE_SEQ
                 ,  SALE_AMT
                 ,  DC_AMT
                 ,  GRD_AMT
                 ,  REMARKS
                 ,  INST_DT
                 ,  INST_USER
                 ,  UPD_DT
                 ,  UPD_USER
            ) VALUES (
                    PSV_COMP_CD
                 ,  PSV_PROGRAM_ID
                 ,  PSV_MBS_NO
                 ,  PSV_CERT_NO
                 ,  nApprSeq
                 ,  TO_CHAR(SYSDATE, 'YYYYMMDD')
                 ,  TO_CHAR(SYSDATE, 'HH24MISS')
                 ,  PSV_MBS_DIV
                 ,  '2'
                 ,  '1'
                 ,  '10'
                 ,  PSV_MEMBER_NO
                 ,  PSV_CHILD_NO
                 ,  TO_NUMBER(NVL(PSV_PROC_TM , '0'))
                 ,  TO_NUMBER(NVL(PSV_PROC_CNT, '0'))
                 ,  TO_NUMBER(NVL(PSV_PROC_AMT, '0'))
                 ,  PSV_MATL_CNT
                 ,  PSV_BRAND_CD
                 ,  PSV_STOR_CD
                 ,  PSV_POS_NO
                 ,  PSV_BILL_NO
                 ,  PSV_SALE_SEQ
                 ,  PSV_SALE_AMT
                 ,  PSV_DC_AMT
                 ,  PSV_GRD_AMT
                 ,  PSV_REMARKS
                 ,  SYSDATE
                 ,  PSV_UPD_USER
                 ,  SYSDATE
                 ,  PSV_UPD_USER
            );
            
            -- 3.5  회원권 판매(CS_MEMBERSHIP_SALE) 수정
            UPDATE  CS_MEMBERSHIP_SALE
               SET  MBS_STAT    = CASE WHEN PSV_CHARGE_YN = '1' AND PSV_MBS_DIV = '1' AND OFFER_TM  > USE_TM  + TO_NUMBER(NVL(PSV_PROC_TM , '0')) THEN '10'     -- 시간권의 잔여시간이 남은 경우
                                       WHEN PSV_CHARGE_YN = '1' AND PSV_MBS_DIV = '1' AND OFFER_TM  = USE_TM  + TO_NUMBER(NVL(PSV_PROC_TM , '0')) THEN '11'     -- 시간권의 잔여시간이 소진한 경우
                                       WHEN PSV_CHARGE_YN = '2' AND PSV_MBS_DIV = '1'                                                             THEN '11'     -- 시간권이면서 무료회원권인 경우 사용시 소진시킴 
                                       WHEN PSV_CHARGE_YN = '1' AND PSV_MBS_DIV = '2' AND OFFER_CNT > USE_CNT + TO_NUMBER(NVL(PSV_PROC_CNT, '0')) THEN '10'     -- 횟수권의 잔여횟수가 남은 경우
                                       WHEN PSV_CHARGE_YN = '1' AND PSV_MBS_DIV = '2' AND OFFER_CNT = USE_CNT + TO_NUMBER(NVL(PSV_PROC_CNT, '0')) THEN '11'     -- 횟수권의 잔여횟수를 소진한 경우
                                       WHEN PSV_CHARGE_YN = '2' AND PSV_MBS_DIV = '2'                                                             THEN '11'     -- 횟수권이면서 무료회원권인 경우 사용시 소진시킴
                                       WHEN PSV_CHARGE_YN = '1' AND PSV_MBS_DIV = '3' AND OFFER_AMT > USE_AMT + TO_NUMBER(NVL(PSV_PROC_AMT, '0')) THEN '10'     -- 금액권의 잔여금액이 남은 경우
                                       WHEN PSV_CHARGE_YN = '1' AND PSV_MBS_DIV = '3' AND OFFER_AMT = USE_AMT + TO_NUMBER(NVL(PSV_PROC_AMT, '0')) THEN '11'     -- 금액권의 잔여금액을 소진한 경우
                                       WHEN PSV_CHARGE_YN = '2' AND PSV_MBS_DIV = '3'                                                             THEN '11'     -- 금액권이면서 무료회원권인 경우 사용시 소진시킴
                                       ELSE '10'
                                  END
                 ,  USE_DIV     = '10'
                 ,  USE_TM      = USE_TM   + TO_NUMBER(NVL(PSV_PROC_TM  , '0'))
                 ,  USE_CNT     = USE_CNT  + TO_NUMBER(NVL(PSV_PROC_CNT , '0'))
                 ,  USE_AMT     = USE_AMT  + TO_NUMBER(NVL(PSV_PROC_AMT , '0'))
                 ,  USE_MCNT    = USE_MCNT + TO_NUMBER(NVL(PSV_MATL_CNT , '0'))
                 ,  UPD_DT      = SYSDATE
                 ,  UPD_USER    = PSV_UPD_USER
             WHERE  COMP_CD     = PSV_COMP_CD
               AND  PROGRAM_ID  = PSV_PROGRAM_ID
               AND  MBS_NO      = PSV_MBS_NO
               AND  CERT_NO     = PSV_CERT_NO
            ;
        ELSIF PSV_PROC_DIV = '4' THEN
            -- 4.   회원권 사용취소
            -- 4.1  회원권 상태 체크
            SELECT  MBS_STAT, CERT_FDT, CERT_TDT, SALE_DIV
              INTO  vMbsStat, vCertFdt, vCertTdt, vSaleDiv
              FROM  CS_MEMBERSHIP_SALE
             WHERE  COMP_CD     = PSV_COMP_CD
               AND  PROGRAM_ID  = PSV_PROGRAM_ID
               AND  MBS_NO      = PSV_MBS_NO
               AND  CERT_NO     = PSV_CERT_NO
            ;
            
            IF vMbsStat = '90' OR TO_CHAR(SYSDATE, 'YYYYMMDD') > vCertTdt THEN
                asRetVal := '4010';   
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001494'); -- 유효기간이 만료된 회원권입니다.   
                RAISE ERR_HANDLER;
            ELSIF vMbsStat = '91' THEN
                asRetVal := '4020';   
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001495'); -- 환불요청 상태의 회원권입니다.   
                RAISE ERR_HANDLER;
            ELSIF vMbsStat = '92' THEN
                asRetVal := '4030';   
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001496'); -- 환불 상태의 회원권입니다.   
                RAISE ERR_HANDLER;
            ELSIF vMbsStat = '99' THEN
                asRetVal := '4040';   
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001497'); -- 폐기된 회원권입니다.   
                RAISE ERR_HANDLER;
            ELSIF vSaleDiv = '2' THEN
                asRetVal := '4050';   
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001498'); -- 반품상태의 회원권입니다.   
                RAISE ERR_HANDLER;
            END IF;
            
            -- 4.2  승인순번 조회
            SELECT  NVL(MAX(TO_NUMBER(APPR_SEQ)), 0) + 1  AS APPR_SEQ 
              INTO  nApprSeq
              FROM  CS_MEMBERSHIP_SALE_HIS
             WHERE  COMP_CD     = PSV_COMP_CD
               AND  PROGRAM_ID  = PSV_PROGRAM_ID
               AND  MBS_NO      = PSV_MBS_NO
               AND  CERT_NO     = PSV_CERT_NO;
               
            -- 4.3  회원권 판매이력(CS_MEMBERSHIP_SALE_HIS) 등록
            INSERT  INTO CS_MEMBERSHIP_SALE_HIS
            (
                    COMP_CD
                 ,  PROGRAM_ID
                 ,  MBS_NO
                 ,  CERT_NO
                 ,  APPR_SEQ
                 ,  APPR_DT
                 ,  APPR_TM
                 ,  MBS_DIV
                 ,  SALE_USE_DIV
                 ,  SALE_DIV
                 ,  USE_STAT
                 ,  MEMBER_NO
                 ,  CHILD_NO
                 ,  USE_TM
                 ,  USE_CNT
                 ,  USE_AMT
                 ,  USE_MCNT
                 ,  SALE_BRAND_CD
                 ,  SALE_STOR_CD
                 ,  SALE_POS_NO
                 ,  SALE_BILL_NO
                 ,  SALE_SEQ
                 ,  SALE_AMT
                 ,  DC_AMT
                 ,  GRD_AMT
                 ,  REMARKS
                 ,  INST_DT
                 ,  INST_USER
                 ,  UPD_DT
                 ,  UPD_USER
            ) VALUES (
                    PSV_COMP_CD
                 ,  PSV_PROGRAM_ID
                 ,  PSV_MBS_NO
                 ,  PSV_CERT_NO
                 ,  nApprSeq
                 ,  TO_CHAR(SYSDATE, 'YYYYMMDD')
                 ,  TO_CHAR(SYSDATE, 'HH24MISS')
                 ,  PSV_MBS_DIV
                 ,  '2'
                 ,  '2'
                 ,  '11'
                 ,  PSV_MEMBER_NO
                 ,  PSV_CHILD_NO
                 ,  TO_NUMBER(NVL(PSV_PROC_TM , '0'))
                 ,  TO_NUMBER(NVL(PSV_PROC_CNT, '0'))
                 ,  TO_NUMBER(NVL(PSV_PROC_AMT, '0'))
                 ,  PSV_MATL_CNT
                 ,  PSV_BRAND_CD
                 ,  PSV_STOR_CD
                 ,  PSV_POS_NO
                 ,  PSV_BILL_NO
                 ,  PSV_SALE_SEQ
                 ,  PSV_SALE_AMT
                 ,  PSV_DC_AMT
                 ,  PSV_GRD_AMT
                 ,  PSV_REMARKS
                 ,  SYSDATE
                 ,  PSV_UPD_USER
                 ,  SYSDATE
                 ,  PSV_UPD_USER
            );
            
            -- 4.4  회원권 판매(CS_MEMBERSHIP_SALE) 수정
            UPDATE  CS_MEMBERSHIP_SALE
               SET  MBS_STAT    = CASE WHEN PSV_MBS_DIV = '1' AND OFFER_TM  > USE_TM  + TO_NUMBER(NVL(PSV_PROC_TM , '0')) THEN '10'
                                       WHEN PSV_MBS_DIV = '1' AND OFFER_TM  = USE_TM  + TO_NUMBER(NVL(PSV_PROC_TM , '0')) THEN '11'
                                       WHEN PSV_MBS_DIV = '2' AND OFFER_CNT > USE_CNT + TO_NUMBER(NVL(PSV_PROC_CNT, '0')) THEN '10'
                                       WHEN PSV_MBS_DIV = '2' AND OFFER_CNT = USE_CNT + TO_NUMBER(NVL(PSV_PROC_CNT, '0')) THEN '11'
                                       WHEN PSV_MBS_DIV = '3' AND OFFER_AMT > USE_AMT + TO_NUMBER(NVL(PSV_PROC_AMT, '0')) THEN '10'
                                       WHEN PSV_MBS_DIV = '3' AND OFFER_AMT = USE_AMT + TO_NUMBER(NVL(PSV_PROC_AMT, '0')) THEN '11'
                                       ELSE '10'
                                  END
                 ,  USE_DIV     = '11'
                 ,  USE_TM      = USE_TM   + TO_NUMBER(NVL(PSV_PROC_TM  , '0'))
                 ,  USE_CNT     = USE_CNT  + TO_NUMBER(NVL(PSV_PROC_CNT , '0'))
                 ,  USE_AMT     = USE_AMT  + TO_NUMBER(NVL(PSV_PROC_AMT , '0'))
                 ,  USE_MCNT    = USE_MCNT + TO_NUMBER(NVL(PSV_MATL_CNT , '0'))
                 ,  UPD_DT      = SYSDATE
                 ,  UPD_USER    = PSV_UPD_USER
             WHERE  COMP_CD     = PSV_COMP_CD
               AND  PROGRAM_ID  = PSV_PROGRAM_ID
               AND  MBS_NO      = PSV_MBS_NO
               AND  CERT_NO     = PSV_CERT_NO
            ;
        END IF;
        
        asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001392'); -- 정상처리 되었습니다.
        
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
        
        COMMIT;
        
        RETURN;
        
    EXCEPTION
        WHEN ERR_HANDLER THEN
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
            ROLLBACK;
            RETURN;
        WHEN OTHERS THEN
            asRetVal := '9999';
            asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1004999999');  -- 자료처리중 오류가 발생했습니다. 관리자에게 문의하여 주십시오.

            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
            ROLLBACK;
            RETURN;
    END SET_MEMBSHIP_INFO_11;
    
    --------------------------------------------------------------------------------
    --  Procedure Name   : SET_MEMBSHIP_INFO_20
    --  Description      : 회원권 이관
    --  Ref. Table       : CS_MEMBERSHIP_SALE       회원권 판매
    --                     CS_MEMBERSHIP_SALE_HIS   회원권 판매이력
    --------------------------------------------------------------------------------
    --  Create Date      : 2016-06-14   최세원
    --  Modify Date      :  
    --------------------------------------------------------------------------------
    PROCEDURE SET_MEMBSHIP_INFO_20
    ( 
        PSV_COMP_CD           IN   VARCHAR2,        -- 1. 회사코드 
        PSV_LANG_TP           IN   VARCHAR2,        -- 2. 언어코드
        PSV_BRAND_CD          IN   VARCHAR2,        -- 3. 영업조직
        PSV_STOR_CD           IN   VARCHAR2,        -- 4. 점포코드
        PSV_PROGRAM_ID        IN   VARCHAR2,        -- 5. 프로그램ID
        PSV_MBS_DIV           IN   VARCHAR2,        -- 6. 회원권종류(1:시간권, 2:횟수권)
        PSV_MBS_NO            IN   VARCHAR2,        -- 7. 회원권번호
        PSV_MEMBER_NO         IN   VARCHAR2,        -- 8. 회원번호
        PSV_ENTR_PRC          IN   VARCHAR2,        -- 9. 1회 입장료
        PSV_BASE_USE_TM       IN   VARCHAR2,        -- 10.기본이용시간
        PSV_SALE_AMT          IN   VARCHAR2,        -- 11.판매금액
        PSV_CHARGE_YN         IN   VARCHAR2,        -- 12.유무상구분
        PSV_OFFER_TM          IN   VARCHAR2,        -- 13.제공시간
        PSV_REMAIN_TM         IN   VARCHAR2,        -- 14.잔여시간
        PSV_OFFER_CNT         IN   VARCHAR2,        -- 15.제공횟수
        PSV_REMAIN_CNT        IN   VARCHAR2,        -- 16.잔여횟수
        PSV_OFFER_AMT         IN   VARCHAR2,        -- 17.제공금액
        PSV_REMAIN_AMT        IN   VARCHAR2,        -- 18.잔여금액
        PSV_OFFER_MCNT        IN   VARCHAR2,        -- 19.제공교구수
        PSV_REMAIN_MCNT       IN   VARCHAR2,        -- 20.잔여교구수
        PSV_CERT_TDT          IN   VARCHAR2,        -- 21.만기일자
        asRetVal              OUT  VARCHAR2,        -- 22.결과코드[0000:정상  그외는 오류] 
        asRetMsg              OUT  VARCHAR2,        -- 23.결과메시지 
        asResult              OUT  REC_SET.M_REFCUR -- 24.결과레코드
    ) IS
    
    lsSqlMain       VARCHAR2(32000) := NULL;
    vCertNo         CS_MEMBERSHIP_SALE.CERT_NO%TYPE         := NULL;        -- 인증번호
    nApprSeq        CS_MEMBERSHIP_SALE_HIS.APPR_SEQ%TYPE    := 1;           -- 승인순번
    nCheckDigit     NUMBER(7) := 0;                                         -- 체크디지트
    
    ERR_HANDLER     EXCEPTION;
    
    BEGIN
        
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';
        
        asRetVal    := '0000';
        asRetMsg    := 'OK';
        
        -- 1.1  유효성 체크
        IF PSV_CHARGE_YN IS NULL THEN
            asRetVal := '1010';   
            asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001522') || '[' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_TP, 'CHARGE_YN') || ']'; -- 회원권정보가 올바르지 않습니다.[유무상구분]   
            RAISE ERR_HANDLER;
        ELSIF PSV_CHARGE_YN = '1' AND TO_NUMBER(PSV_SALE_AMT) = 0 THEN
            asRetVal := '1020';   
            asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001333');    -- 결제금액을 입력하여 주십시요.   
            RAISE ERR_HANDLER;
        ELSIF PSV_CERT_TDT IS NULL THEN
            asRetVal := '1030';   
            asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001524');    -- 만기일자를 입력하여 주십시요.   
            RAISE ERR_HANDLER;
        ELSIF PSV_MEMBER_NO IS NULL THEN
            asRetVal := '1040';   
            asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001385');    -- 회원정보를 확인 하세요.   
            RAISE ERR_HANDLER;
        ELSIF PSV_MBS_DIV = '1' AND TO_NUMBER(PSV_REMAIN_TM) > TO_NUMBER(PSV_OFFER_TM) THEN
            asRetVal := '1050';   
            asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001518');    -- 잔여시간이 제공시간을 초과하였습니다.   
            RAISE ERR_HANDLER;
        ELSIF PSV_MBS_DIV = '2' AND TO_NUMBER(PSV_REMAIN_CNT) > TO_NUMBER(PSV_OFFER_CNT) THEN
            asRetVal := '1060';   
            asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001519');    -- 잔여횟수가 제공횟수를 초과하였습니다.   
            RAISE ERR_HANDLER;
        ELSIF PSV_MBS_DIV = '3' AND TO_NUMBER(PSV_REMAIN_AMT) > TO_NUMBER(PSV_OFFER_AMT) THEN
            asRetVal := '1070';   
            asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001520');    -- 잔여금액이 제공금액을 초과하였습니다.   
            RAISE ERR_HANDLER;
        ELSIF TO_NUMBER(PSV_REMAIN_MCNT) > TO_NUMBER(PSV_OFFER_MCNT) THEN
            asRetVal := '1080';   
            asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001521');    -- 잔여교구수가 제공교구수를 초과하였습니다.   
            RAISE ERR_HANDLER;
        END IF;
        
        -- 1.2  인증번호 조회
        SELECT  TO_CHAR(SYSDATE, 'YYMM')  ||
                PSV_BRAND_CD              ||
                PSV_CHARGE_YN             ||
                LPAD(SQ_MEMBERSHIP_CERT_NO.NEXTVAL, 6, '0')  AS CERT_NO
          INTO  vCertNo
          FROM  DUAL;
            
        nCheckDigit := MOD(
                            TO_NUMBER(SUBSTR(vCertNo, 1 , 1)) * 3 + TO_NUMBER(SUBSTR(vCertNo, 2 , 1)) * 2 +  
                            TO_NUMBER(SUBSTR(vCertNo, 3 , 1)) * 3 + TO_NUMBER(SUBSTR(vCertNo, 4 , 1)) * 2 +  
                            TO_NUMBER(SUBSTR(vCertNo, 5 , 1)) * 3 + TO_NUMBER(SUBSTR(vCertNo, 6 , 1)) * 2 + 
                            TO_NUMBER(SUBSTR(vCertNo, 7 , 1)) * 3 + TO_NUMBER(SUBSTR(vCertNo, 8 , 1)) * 2 +  
                            TO_NUMBER(SUBSTR(vCertNo, 9 , 1)) * 3 + TO_NUMBER(SUBSTR(vCertNo, 10, 1)) * 2 +  
                            TO_NUMBER(SUBSTR(vCertNo, 11, 1)) * 3 + TO_NUMBER(SUBSTR(vCertNo, 12, 1)) * 2 + 
                            TO_NUMBER(SUBSTR(vCertNo, 13, 1)) * 3 + TO_NUMBER(SUBSTR(vCertNo, 14, 1)) * 2
                           , 10);
             
        vCertNo := vCertNo || nCheckDigit;
        
        -- 1.3  회원권 판매(CS_MEMBERSHIP_SALE) 등록
        INSERT  INTO CS_MEMBERSHIP_SALE
        (
                COMP_CD
             ,  PROGRAM_ID
             ,  MBS_NO
             ,  CERT_NO
             ,  MEMBER_NO
             ,  MOBILE
             ,  MBS_DIV
             ,  MBS_STAT
             ,  CHARGE_YN
             ,  CERT_FDT
             ,  CERT_TDT
             ,  SALE_DIV
             ,  ENTR_PRC
             ,  SALE_AMT
             ,  DC_AMT
             ,  GRD_AMT
             ,  SALE_BRAND_CD
             ,  SALE_STOR_CD
             ,  USE_DIV
             ,  OFFER_TM
             ,  USE_TM
             ,  OFFER_CNT
             ,  USE_CNT
             ,  OFFER_AMT
             ,  USE_AMT
             ,  OFFER_MCNT
             ,  USE_MCNT
             ,  USE_YN
             ,  INST_DT
             ,  INST_USER
             ,  UPD_DT
             ,  UPD_USER

        ) VALUES (
                PSV_COMP_CD
             ,  PSV_PROGRAM_ID
             ,  PSV_MBS_NO
             ,  vCertNo
             ,  PSV_MEMBER_NO
             ,  (
                    SELECT  MOBILE
                      FROM  CS_MEMBER
                     WHERE  COMP_CD     = PSV_COMP_CD
                       AND  MEMBER_NO   = PSV_MEMBER_NO
                )
             ,  PSV_MBS_DIV
             ,  '10'
             ,  PSV_CHARGE_YN
             ,  TO_CHAR(SYSDATE, 'YYYYMMDD')
             ,  PSV_CERT_TDT
             ,  '1'
             ,  NVL(PSV_ENTR_PRC, 0)
             ,  NVL(PSV_SALE_AMT, 0)
             ,  0
             ,  NVL(PSV_SALE_AMT, 0)
             ,  PSV_BRAND_CD
             ,  PSV_STOR_CD
             ,  '00'
             ,  (
                    CASE WHEN PSV_MBS_DIV = '1' THEN TO_NUMBER(NVL(PSV_OFFER_TM, '0'))
                         WHEN PSV_MBS_DIV = '2' THEN TO_NUMBER(NVL(PSV_OFFER_CNT, '0')) * TO_NUMBER(NVL(PSV_BASE_USE_TM, '0'))
                         ELSE 0
                    END
                )
             ,  (
                    CASE WHEN PSV_MBS_DIV = '1' THEN TO_NUMBER(NVL(PSV_OFFER_TM, '0')) - TO_NUMBER(NVL(PSV_REMAIN_TM, '0'))
                         WHEN PSV_MBS_DIV = '2' THEN (TO_NUMBER(NVL(PSV_OFFER_CNT, '0')) - TO_NUMBER(NVL(PSV_REMAIN_CNT, '0'))) * TO_NUMBER(NVL(PSV_BASE_USE_TM, '0'))
                         ELSE 0
                    END
                )
             ,  (
                    CASE WHEN PSV_MBS_DIV = '2' THEN TO_NUMBER(NVL(PSV_OFFER_CNT, '0'))
                         ELSE 0
                    END
                )
             ,  (
                    CASE WHEN PSV_MBS_DIV = '2' THEN TO_NUMBER(NVL(PSV_OFFER_CNT, '0')) - TO_NUMBER(NVL(PSV_REMAIN_CNT, '0'))
                         ELSE 0
                    END
                )
             ,  (
                    CASE WHEN PSV_MBS_DIV = '1' THEN TO_NUMBER(NVL(PSV_SALE_AMT, '0'))
                         WHEN PSV_MBS_DIV = '2' THEN TO_NUMBER(NVL(PSV_SALE_AMT, '0'))
                         WHEN PSV_MBS_DIV = '3' THEN TO_NUMBER(NVL(PSV_OFFER_AMT, '0'))
                         ELSE 0
                    END
                )
             ,  (
                    CASE WHEN PSV_MBS_DIV = '1' THEN ROUND(TO_NUMBER(NVL(PSV_SALE_AMT, '0')) / TO_NUMBER(NVL(PSV_OFFER_TM, 0)) * (TO_NUMBER(NVL(PSV_OFFER_TM, 0) - TO_NUMBER(NVL(PSV_REMAIN_TM, 0)))))
                         WHEN PSV_MBS_DIV = '2' THEN ROUND(TO_NUMBER(NVL(PSV_SALE_AMT, '0')) / TO_NUMBER(NVL(PSV_OFFER_CNT, 0)) * (TO_NUMBER(NVL(PSV_OFFER_CNT, 0) - TO_NUMBER(NVL(PSV_REMAIN_CNT, 0)))))
                         WHEN PSV_MBS_DIV = '3' THEN TO_NUMBER(NVL(PSV_OFFER_AMT, '0')) - NVL(PSV_REMAIN_AMT, 0)
                         ELSE 0
                    END
                )
             ,  NVL(PSV_OFFER_MCNT, 0)
             ,  NVL(PSV_OFFER_MCNT, 0) - NVL(PSV_REMAIN_MCNT, 0)
             ,  'Y'
             ,  SYSDATE
             ,  'SYSTEM'
             ,  SYSDATE
             ,  'SYSTEM'
        );
        
        -- 1.4  승인순번 조회
        SELECT  NVL(MAX(TO_NUMBER(APPR_SEQ)), 0) + 1  AS APPR_SEQ 
          INTO  nApprSeq
          FROM  CS_MEMBERSHIP_SALE_HIS
         WHERE  COMP_CD     = PSV_COMP_CD
           AND  PROGRAM_ID  = PSV_PROGRAM_ID
           AND  MBS_NO      = PSV_MBS_NO
           AND  CERT_NO     = vCertNo;
               
        -- 1.5  회원권 판매이력(CS_MEMBERSHIP_SALE_HIS) 등록
        INSERT  INTO CS_MEMBERSHIP_SALE_HIS
        (
                COMP_CD
             ,  PROGRAM_ID
             ,  MBS_NO
             ,  CERT_NO
             ,  APPR_SEQ
             ,  APPR_DT
             ,  APPR_TM
             ,  MBS_DIV
             ,  SALE_USE_DIV
             ,  SALE_DIV
             ,  USE_STAT
             ,  MEMBER_NO
             ,  USE_TM
             ,  USE_CNT
             ,  USE_AMT
             ,  USE_MCNT
             ,  SALE_BRAND_CD
             ,  SALE_STOR_CD
             ,  SALE_AMT
             ,  DC_AMT
             ,  GRD_AMT
             ,  INST_DT
             ,  INST_USER
             ,  UPD_DT
             ,  UPD_USER
        ) VALUES (
                PSV_COMP_CD
             ,  PSV_PROGRAM_ID
             ,  PSV_MBS_NO
             ,  vCertNo
             ,  nApprSeq
             ,  TO_CHAR(SYSDATE, 'YYYYMMDD')
             ,  TO_CHAR(SYSDATE, 'HH24MISS')
             ,  PSV_MBS_DIV
             ,  '2'
             ,  '3'
             ,  '10'
             ,  PSV_MEMBER_NO
             ,  (
                    CASE WHEN PSV_MBS_DIV = '1' THEN TO_NUMBER(NVL(PSV_OFFER_TM, '0')) - TO_NUMBER(NVL(PSV_REMAIN_TM, '0'))
                         WHEN PSV_MBS_DIV = '2' THEN (TO_NUMBER(NVL(PSV_OFFER_CNT, '0')) - TO_NUMBER(NVL(PSV_REMAIN_CNT, '0'))) * TO_NUMBER(NVL(PSV_BASE_USE_TM, '0'))
                         ELSE 0
                    END
                )
             ,  (
                    CASE WHEN PSV_MBS_DIV = '2' THEN TO_NUMBER(NVL(PSV_OFFER_CNT, '0')) - TO_NUMBER(NVL(PSV_REMAIN_CNT, '0'))
                         ELSE 0
                    END
                )
             ,  (
                    CASE WHEN PSV_MBS_DIV = '1' THEN ROUND(TO_NUMBER(NVL(PSV_SALE_AMT, '0')) / TO_NUMBER(NVL(PSV_OFFER_TM, 0)) * (TO_NUMBER(NVL(PSV_OFFER_TM, 0) - TO_NUMBER(NVL(PSV_REMAIN_TM, 0)))))
                         WHEN PSV_MBS_DIV = '2' THEN ROUND(TO_NUMBER(NVL(PSV_SALE_AMT, '0')) / TO_NUMBER(NVL(PSV_OFFER_CNT, 0)) * (TO_NUMBER(NVL(PSV_OFFER_CNT, 0) - TO_NUMBER(NVL(PSV_REMAIN_CNT, 0)))))
                         WHEN PSV_MBS_DIV = '3' THEN TO_NUMBER(NVL(PSV_OFFER_AMT, '0')) - NVL(PSV_REMAIN_AMT, 0)
                         ELSE 0
                    END
                )
             ,  NVL(PSV_OFFER_MCNT, 0) - NVL(PSV_REMAIN_MCNT, 0)
             ,  PSV_BRAND_CD
             ,  PSV_STOR_CD
             ,  NVL(PSV_SALE_AMT, 0)
             ,  0
             ,  NVL(PSV_SALE_AMT, 0)
             ,  SYSDATE
             ,  'SYSTEM'
             ,  SYSDATE
             ,  'SYSTEM'
        );
            
        -- 1.6  인증번호 반환
        OPEN asResult FOR
        SELECT  vCertNo, nApprSeq
          FROM  DUAL;
        
        asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001392'); -- 정상처리 되었습니다.
        
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
        
        RETURN;
        
    EXCEPTION
        WHEN ERR_HANDLER THEN
            OPEN asResult FOR
                SELECT  asRetVal
                  FROM  DUAL;
            
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
            ROLLBACK;
            RETURN;
        WHEN OTHERS THEN
            asRetVal := '9999';
            asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1004999999');  -- 자료처리중 오류가 발생했습니다. 관리자에게 문의하여 주십시오.
            --asRetMsg := SQLERRM;
            OPEN asResult FOR
                SELECT  asRetVal
                  FROM  DUAL;
            
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
            ROLLBACK;
            RETURN;
    END SET_MEMBSHIP_INFO_20;
    
    PROCEDURE SET_CUST_CARD_10
   (
    PSV_COMP_CD           IN   VARCHAR2, -- 1. 회사코드 
    PSV_LANG_TP           IN   VARCHAR2, -- 2. 언어코드
    PSV_MEMBER_NO         IN   VARCHAR2, -- 3. 회원번호
    PSV_CUST_ID           IN   VARCHAR2, -- 4. 고객ID
    PSV_CARD_ID           IN   VARCHAR2, -- 5. 카드번호
    asRetVal              OUT  VARCHAR2, -- 6. 결과코드[0000:정상  그외는 오류]
    asRetMsg              OUT  VARCHAR2  -- 7. 결과메시지
   ) IS
  
    lsCardId        C_CARD.CARD_ID%TYPE;            -- 카드 ID
    lsCustId        C_CARD.CUST_ID%TYPE;            -- 회원 ID
    nSavPt          C_CARD.SAV_PT%TYPE := 0;        -- 적립포인트
    lsBrandCd       CS_MEMBER.BRAND_CD%TYPE;        -- 영업조직(가입점)
    lsStorCd        CS_MEMBER.STOR_CD%TYPE;         -- 점포코드(가입점)
    lsNewCustYn     VARCHAR2(1) := 'N';             -- 신규회원 여부
    nRecSeq         VARCHAR2(7);                    -- 일련번호
    nRecCnt         NUMBER(7) := 0;                 -- 레코드 수
    nCurPoint       C_CARD.SAV_PT%TYPE   := 0;      -- 현재 포인트
    
    ERR_HANDLER     EXCEPTION;
    
    BEGIN
        asRetVal    := '0000';
        asRetMsg    := 'OK'  ;
        
        -- 카드 유효성 체크
        BEGIN
            SELECT  COUNT(*) INTO nRecCnt
            FROM    C_CARD
            WHERE   COMP_CD   = PSV_COMP_CD
            AND     CARD_ID   = PSV_CARD_ID; -- 사용여부[Y:사용, N:사용안함]
         
            IF nRecCnt != 0 THEN
                asRetVal := '1001';
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001428'); -- 이미 등록된 카드번호 입니다.
         
                RETURN;
            END IF;
        END;
    
        -- 고객ID 취득
        BEGIN
            SELECT  COUNT(*), MAX(CUST_ID) INTO nRecCnt, lsCustId
            FROM    C_CUST
            WHERE   COMP_CD = PSV_COMP_CD
            AND     CUST_ID = PSV_MEMBER_NO;
         
            IF nRecCnt = 0 THEN
                lsNewCustYn := 'Y';
                lsCustId := PSV_MEMBER_NO;
            END IF;
        END;
    
        -- 기 소지하고 있는 카드 폐기처리
        BEGIN
            UPDATE  C_CARD
            SET     CARD_STAT   = '99'
                 ,  REP_CARD_YN = 'N'
                 ,  USE_YN      = 'N'
            WHERE   COMP_CD     = PSV_COMP_CD
            AND     CUST_ID     = lsCustId
            AND     CARD_STAT   = '10';
        EXCEPTION
            WHEN OTHERS THEN
                asRetVal := '1002';
                asRetMsg := SQLERRM;   
        END;
        
        -- 고객정보 생성
        MERGE INTO C_CUST A
        USING  ( 
                SELECT  COMP_CD    COMP_CD
                      , lsCustId   CUST_ID
                      , MEMBER_NO
                      , MEMBER_NM  CUST_NM
                      , MOBILE     MOBILE
                      , MOBILE_N3  MOBILE_N3
                      , ADDR1      ADDR1
                      , ADDR2      ADDR2
                      , AGREE_DT
                      , REMARKS    REMARKS
                      , BRAND_CD   BRAND_CD
                      , STOR_CD    STOR_CD
                      , USE_YN     USE_YN
                FROM    CS_MEMBER
                WHERE   COMP_CD   = PSV_COMP_CD
                AND     MEMBER_NO = PSV_MEMBER_NO
               ) B
        ON (
                A.COMP_CD     = B.COMP_CD
            AND A.CUST_ID     = B.CUST_ID
           )
        WHEN MATCHED THEN
            UPDATE
            SET A.CUST_NM   = B.CUST_NM
              , A.MOBILE    = B.MOBILE
              , A.MOBILE_N3 = B.MOBILE_N3
              , A.ADDR1     = B.ADDR1
              , A.ADDR2     = B.ADDR2
              , A.REMARKS   = B.REMARKS
              , A.USE_YN    = B.USE_YN
              , A.UPD_DT    = SYSDATE
              , A.UPD_USER  = 'SYS'
        WHEN NOT MATCHED THEN
            INSERT
               (  
                COMP_CD         , CUST_ID
              , CUST_NM         
              , MOBILE          , MOBILE_N3       
              , ADDR_DIV
              , ADDR1           , ADDR2
              , LVL_CD          , CUST_STAT
              , SAV_PT          , REMARKS
              , JOIN_DT         
              , CUST_DIV
              , BRAND_CD        , STOR_CD
              , LAST_LOGIN_DT
              , MEMBER_NO       , USE_YN
              , INST_DT         , INST_USER
              , UPD_DT          , UPD_USER
               )
            VALUES
               (  
                B.COMP_CD       , B.CUST_ID
              , B.CUST_NM       
              , B.MOBILE        , B.MOBILE_N3 
              , 'H'             
              , B.ADDR1         , B.ADDR2
              , '101'           , '2'           -- 회원상태[01720> 1:가입, 2:멤버십, 9:탈퇴]
              , 0               , '시스템 자동발급'
              , NVL(B.AGREE_DT, TO_CHAR(SYSDATE, 'YYYYMMDD'))
              , '1'                             -- 회원관리범위[01820> 1:회사, 2:영업조직, 3:점포]
              , B.BRAND_CD      , B.STOR_CD
              , SYSDATE         
              , B.MEMBER_NO     , 'Y'
              , SYSDATE         , 'SYS'
              , SYSDATE         , 'SYS'
               );

        -- 고객카드정보 생성
        MERGE INTO C_CARD A
        USING  ( 
                SELECT  COMP_CD     COMP_CD
                      , lsCustId    CUST_ID
                      , PSV_CARD_ID CARD_ID
                      , BRAND_CD    BRAND_CD
                      , STOR_CD     STOR_CD
                      , USE_YN      USE_YN
                FROM    CS_MEMBER
                WHERE   COMP_CD   = PSV_COMP_CD
                AND     MEMBER_NO = PSV_MEMBER_NO
               ) B
        ON (
                A.COMP_CD     = B.COMP_CD
            AND A.CARD_ID     = B.CUST_ID
           )
        WHEN NOT MATCHED THEN
            INSERT
               (  
                COMP_CD             , CARD_ID
              , CUST_ID             , CARD_STAT
              , ISSUE_DT            
              , ISSUE_BRAND_CD      , ISSUE_STOR_CD
              , SAV_PT              , CARD_DIV
              , REP_CARD_YN         , USE_YN
              , INST_DT             , INST_USER
              , UPD_DT              , UPD_USER
               ) 
            VALUES
               (
                B.COMP_CD           , B.CARD_ID
              , B.CUST_ID           , '10'         -- [10:정상, 90:분실, 91:해지, 92:환불, 99:폐기]
              , TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')
              , B.BRAND_CD          , B.STOR_CD
              , 0                   , '1'          -- 카드관리범위[01820> 1:회사, 2:영업조직, 3:점포]
              , 'Y'                 , 'Y'
              , SYSDATE             , 'SYS'
              , SYSDATE             , 'SYS'
               );
        
        -- 회원가입 시 지급 포인트
        IF lsNewCustYn = 'Y' THEN    -- 신규회원/신규카드 체크
            BEGIN
                SELECT  CM.BRAND_CD
                      , CM.STOR_CD
                      , NVL(MAX(PARA_VAL), 0)  
                INTO    lsBrandCd, lsStorCd, nSavPt
                FROM    PARA_BRAND PB
                     ,  CS_MEMBER  CM
                WHERE   CM.COMP_CD  = PB.COMP_CD (+)
                AND     CM.BRAND_CD = PB.BRAND_CD(+)
                AND     '1016'      = PB.PARA_CD (+) -- 회원가입 시 지급포인트
                AND     CM.COMP_CD  = PSV_COMP_CD
                AND     CM.MEMBER_NO= PSV_MEMBER_NO
                GROUP BY
                        CM.BRAND_CD
                      , CM.STOR_CD;
                
                INSERT INTO C_CARD_SAV_HIS
               (  
                COMP_CD
              , CARD_ID
              , USE_DT
              , USE_SEQ
              , SAV_USE_FG
              , SAV_USE_DIV
              , REMARKS
              , LOS_MLG_YN
              , LOS_MLG_DT
              , SAV_PT
              , LOS_PT_YN
              , LOS_PT_DT
              , BRAND_CD
              , STOR_CD
              , USE_TM
              , USE_YN
              , INST_DT
              , INST_USER
              , UPD_DT
              , UPD_USER
               ) 
                VALUES
               (  
                PSV_COMP_CD
              , PSV_CARD_ID
              , TO_CHAR(SYSDATE, 'YYYYMMDD')
              , SQ_PCRM_SEQ.NEXTVAL
              , '3'   -- 적립사용구분[1:크라운 적립, 2:크라운 사용, 3:포인트 적립, 4:포인트 사용]
              , '101' -- 적립사용종류[12220> 101:회원가입, 102:회원탈퇴 소멸, 201:적립, 202:적립반품, 203:적립누락, 301:사용, 302:사용반품, 303:사용누락, 901:조정, 902:이전, 903:기타]
              , '회원가입 포인트 적립'
              , 'N'
              , TO_CHAR(ADD_MONTHS(SYSDATE, 12) - 1, 'YYYYMMDD')
              , nSavPt
              , 'N'
              , TO_CHAR(ADD_MONTHS(SYSDATE, 12) - 1, 'YYYYMMDD')
              , lsBrandCd
              , lsStorCd
              , TO_CHAR(SYSDATE, 'HH24MISS')
              , 'Y'
              , SYSDATE
              , 'ACK'
              , SYSDATE
              , 'ACK'
               );
            END;
        END IF;
        
        asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, 'KOR', '1010001392'); -- 정상 처리되었습니다.
    
        RETURN;
    EXCEPTION
        WHEN ERR_HANDLER THEN
            ROLLBACK;
            RETURN;
        WHEN OTHERS THEN
            asRetVal := '1003';
            asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, 'KOR', '1010001187')||'['||SQLERRM||']'; -- 오류가 발생하였습니다.
         
            ROLLBACK;
         RETURN;
    END SET_CUST_CARD_10;
  
    --------------------------------------------------------------------------------
    --  Procedure Name   : SEND_SMS
    --  Description      : SMS전송
    --  Ref. Table       : 
    --------------------------------------------------------------------------------
    --  Create Date      : 2016-06-21   최세원
    --  Modify Date      :  
    --------------------------------------------------------------------------------
    PROCEDURE SEND_SMS
    ( 
        PSV_COMP_CD           IN   VARCHAR2,        -- 1. 회사코드 
        PSV_LANG_TP           IN   VARCHAR2,        -- 2. 언어코드 
        PSV_BRAND_CD          IN   VARCHAR2,        -- 3. 영업조직
        PSV_STOR_CD           IN   VARCHAR2,        -- 4. 점포코드
        PSV_MEMBER_NO         IN   VARCHAR2,        -- 5. 회원번호
        PSV_MOBILE            IN   VARCHAR2,        -- 6. 연락처(수신번호)
        PSV_SMS_DIV           IN   VARCHAR2,        -- 7. 전송구분(1:입장, 2:퇴장, 3:단체, 4:임의발송)
        PSV_SUBJECT           IN   VARCHAR2,        -- 8. 제목
        PSV_CONTENTS          IN   VARCHAR2,        -- 9. 전송문구
        PSV_STOR_TEL          IN   VARCHAR2,        -- 10.점포연락처(발송번호)
        asRetVal              OUT  VARCHAR2,        -- 11.결과코드[0000:정상  그외는 오류] 
        asRetMsg              OUT  VARCHAR2,        -- 12.결과메시지 
        asResult              OUT  REC_SET.M_REFCUR -- 13.결과레코드
    ) IS
    
    vBrandClass     VARCHAR2(10)    := NULL;
    vStorTp         VARCHAR2(2)     := NULL;
    vSendDt         CS_CONTENT_SEND.SEND_DT%TYPE    := TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS');    -- 전송일시
    vSendType       VARCHAR2(3)     := NULL;                                                    -- 전송형태(SMS/MMS)
    nSendSeq        CS_CONTENT_SEND.SEND_SEQ%TYPE   := SQ_SEND_SEQ.NEXTVAL;                     -- 전송순번
    nMsgKey         CS_CONTENT_SEND_LOG.MSGKEY%TYPE := '';                                      -- LG U+ 전송순번(SMS/MMS)
    ERR_HANDLER     EXCEPTION;
    
    BEGIN
        
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';
        
        asRetVal    := '0000';
        asRetMsg    := 'OK';
        
        SELECT  CASE WHEN LENGTHB(CONVERT(REPLACE(PSV_CONTENTS, '@$', CHR(13)||CHR(10)),'KO16KSC5601')) > 80 THEN 'MMS'
                     ELSE 'SMS'
                END
          INTO  vSendType
          FROM  DUAL;
        
        IF vSendType = 'SMS' THEN
            nMsgKey := SC_TRAN_SEQ.NEXTVAL;
        ELSE
            nMsgKey := MMS_MSG_SEQ.NEXTVAL;
        END IF;
        
        -- 1. SMS전송테이블 저장
        INSERT  INTO CS_CONTENT_SEND
        (
                COMP_CD
             ,  SEND_DT
             ,  SEND_SEQ
             ,  SUBJECT
             ,  CONTENT
             ,  MEMBER_NO
             ,  SEND_MOBILE
             ,  MOBILE
             ,  BRAND_CD
             ,  STOR_CD
             ,  SEND_DIV
             ,  MSGKEY
             ,  USE_YN
             ,  INST_DT
             ,  INST_USER
             ,  UPD_DT
             ,  UPD_USER
        ) VALUES (
                PSV_COMP_CD
             ,  vSendDt
             ,  nSendSeq
             ,  NVL(TRIM(PSV_SUBJECT), NVL(FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_TP, 'NO_SUBJECT'), ' '))
             ,  TRIM(REPLACE(PSV_CONTENTS, '@$', CHR(13)||CHR(10)))
             ,  PSV_MEMBER_NO
             ,  PSV_STOR_TEL
             ,  PSV_MOBILE
             ,  PSV_BRAND_CD
             ,  PSV_STOR_CD
             ,  '1'
             ,  nMsgKey
             ,  'Y'
             ,  SYSDATE
             ,  'SYSTEM'
             ,  SYSDATE
             ,  'SYSTEM'
        );
        
        IF vSendType = 'SMS' THEN
            -- 2. 문자메세지 발송처리(SMS)
            INSERT INTO SC_TRAN
            (      
                    TR_NUM
                 ,  TR_SENDDATE
                 ,  TR_SENDSTAT
                 ,  TR_MSGTYPE
                 ,  TR_CALLBACK
                 ,  TR_PHONE
                 ,  TR_MSG
            ) VALUES (
                    nMsgKey
                 ,  TO_DATE(vSendDt, 'YYYYMMDDHH24MISS')
                 ,  '0'
                 ,  '0'
                 ,  DECRYPT(PSV_STOR_TEL)
                 ,  REPLACE(DECRYPT(PSV_MOBILE), '-', '')
                 ,  TRIM(REPLACE(PSV_CONTENTS, '@$', CHR(13)||CHR(10)))
            );
        ELSE
            -- 2. 문자메세지 발송처리(MMS)
            INSERT INTO MMS_MSG
            (      
                    MSGKEY
                 ,  SUBJECT
                 ,  PHONE
                 ,  CALLBACK
                 ,  STATUS
                 ,  REQDATE
                 ,  MSG
                 ,  TYPE
            ) VALUES (
                    nMsgKey
                 ,  NVL(TRIM(PSV_SUBJECT), NVL(FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_TP, 'NO_SUBJECT'), ' '))
                 ,  REPLACE(DECRYPT(PSV_MOBILE), '-', '')
                 ,  DECRYPT(PSV_STOR_TEL)
                 ,  0
                 ,  TO_DATE(vSendDt, 'YYYYMMDDHH24MISS')
                 ,  TRIM(REPLACE(PSV_CONTENTS, '@$', CHR(13)||CHR(10)))
                 ,  '0'
            );
        END IF;    
        
        -- 3.전송로그
        INSERT  INTO CS_CONTENT_SEND_LOG
        (
                COMP_CD
             ,  SEND_DT
             ,  SEND_SEQ
             ,  MSGKEY
             ,  INST_DT
             ,  INST_USER
        ) VALUES (
                PSV_COMP_CD
             ,  vSendDt
             ,  nSendSeq
             ,  nMsgKey
             ,  SYSDATE
             ,  'SYSTEM'
        );
        
        COMMIT;
        
        asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001392'); -- 정상처리 되었습니다.
        
        OPEN asResult FOR
            SELECT  asRetVal
              FROM  DUAL;
                  
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
        
        RETURN;
        
    EXCEPTION
        WHEN ERR_HANDLER THEN
            OPEN asResult FOR
                SELECT  asRetVal
                  FROM  DUAL;
            
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
            ROLLBACK;
            RETURN;
        WHEN OTHERS THEN
            asRetVal := '9999';
            asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1004999999');  -- 자료처리중 오류가 발생했습니다. 관리자에게 문의하여 주십시오.
            --asRetMsg := SQLERRM;
            OPEN asResult FOR
                SELECT  asRetVal
                  FROM  DUAL;
            
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
            ROLLBACK;
            RETURN;
    END SEND_SMS;

    --------------------------------------------------------------------------------
    --  Procedure Name   : SEND_MMS
    --  Description      : MMS전송
    --  Ref. Table       : 
    --------------------------------------------------------------------------------
    --  Create Date      : 2016-06-21
    --  Modify Date      :  
    --------------------------------------------------------------------------------
    PROCEDURE SEND_MMS
    ( 
        PSV_COMP_CD           IN   VARCHAR2,        -- 1. 회사코드 
        PSV_LANG_TP           IN   VARCHAR2,        -- 2. 언어코드 
        PSV_BRAND_CD          IN   VARCHAR2,        -- 3. 영업조직
        PSV_STOR_CD           IN   VARCHAR2,        -- 4. 점포코드
        PSV_MEMBER_NO         IN   VARCHAR2,        -- 5. 회원번호
        PSV_MOBILE            IN   VARCHAR2,        -- 6. 연락처(수신번호)
        PSV_SMS_DIV           IN   VARCHAR2,        -- 7. 전송구분(1:입장, 2:퇴장, 3:단체, 4:임의발송)
        PSV_SUBJECT           IN   VARCHAR2,        -- 8. 제목
        PSV_CONTENTS          IN   VARCHAR2,        -- 9. 전송문구
        PSV_STOR_TEL          IN   VARCHAR2,        -- 10.점포연락처(발송번호)
        PSV_FILE_NAME         IN   VARCHAR2,        -- 11.FILE FULL NAME
        asRetVal              OUT  VARCHAR2,        -- 12.결과코드[0000:정상  그외는 오류] 
        asRetMsg              OUT  VARCHAR2,        -- 13.결과메시지 
        asResult              OUT  REC_SET.M_REFCUR -- 14.결과레코드
    ) IS
    
    vBrandClass     VARCHAR2(10)    := NULL;
    vStorTp         VARCHAR2(2)     := NULL;
    vSendDt         CS_CONTENT_SEND.SEND_DT%TYPE    := TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS');    -- 전송일시
    vSendType       VARCHAR2(3)     := NULL;                                                    -- 전송형태(SMS/MMS)
    nSendSeq        CS_CONTENT_SEND.SEND_SEQ%TYPE   := SQ_SEND_SEQ.NEXTVAL;                     -- 전송순번
    nMsgKey         CS_CONTENT_SEND_LOG.MSGKEY%TYPE := '';                                      -- LG U+ 전송순번(SMS/MMS)
    ERR_HANDLER     EXCEPTION;
    
    BEGIN
        
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';
        
        asRetVal    := '0000';
        asRetMsg    := 'OK';
        nMsgKey     := MMS_MSG_SEQ.NEXTVAL;
        
        -- 1. SMS전송테이블 저장
        INSERT  INTO CS_CONTENT_SEND
        (
                COMP_CD
             ,  SEND_DT
             ,  SEND_SEQ
             ,  SUBJECT
             ,  CONTENT
             ,  MEMBER_NO
             ,  SEND_MOBILE
             ,  MOBILE
             ,  BRAND_CD
             ,  STOR_CD
             ,  SEND_DIV
             ,  MSGKEY
             ,  USE_YN
             ,  INST_DT
             ,  INST_USER
             ,  UPD_DT
             ,  UPD_USER
        ) VALUES (
                PSV_COMP_CD
             ,  vSendDt
             ,  nSendSeq
             ,  NVL(TRIM(PSV_SUBJECT), NVL(FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_TP, 'NO_SUBJECT'), ' '))
             ,  TRIM(REPLACE(PSV_CONTENTS, '@$', CHR(13)||CHR(10)))
             ,  PSV_MEMBER_NO
             ,  PSV_STOR_TEL
             ,  PSV_MOBILE
             ,  PSV_BRAND_CD
             ,  PSV_STOR_CD
             ,  '1'
             ,  nMsgKey
             ,  'Y'
             ,  SYSDATE
             ,  'SYSTEM'
             ,  SYSDATE
             ,  'SYSTEM'
        );
        
        -- 2. 문자메세지 발송처리(MMS)
        INSERT INTO MMS_MSG
        (      
                MSGKEY
             ,  SUBJECT
             ,  PHONE
             ,  CALLBACK
             ,  STATUS
             ,  REQDATE
             ,  MSG
             ,  TYPE
             ,  FILE_CNT
             ,  FILE_CNT_REAL
             ,  FILE_PATH1
             ,  FILE_PATH1_SIZ
        ) VALUES (
                nMsgKey
             ,  NVL(TRIM(PSV_SUBJECT), NVL(FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_TP, 'NO_SUBJECT'), ' '))
             ,  REPLACE(DECRYPT(PSV_MOBILE), '-', '')
             ,  DECRYPT(PSV_STOR_TEL)
             ,  0
             ,  TO_DATE(vSendDt, 'YYYYMMDDHH24MISS')
             ,  TRIM(REPLACE(PSV_CONTENTS, '@$', CHR(13)||CHR(10)))
             ,  '0'
             ,  1
             ,  1
             ,  PSV_FILE_NAME
             ,  NULL
        );
        
        -- 3.전송로그
        INSERT  INTO CS_CONTENT_SEND_LOG
        (
                COMP_CD
             ,  SEND_DT
             ,  SEND_SEQ
             ,  MSGKEY
             ,  INST_DT
             ,  INST_USER
        ) VALUES (
                PSV_COMP_CD
             ,  vSendDt
             ,  nSendSeq
             ,  nMsgKey
             ,  SYSDATE
             ,  'SYSTEM'
        );
        
        COMMIT;
        
        asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1010001392'); -- 정상처리 되었습니다.
        
        OPEN asResult FOR
            SELECT  asRetVal
              FROM  DUAL;
                  
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
        
        RETURN;
        
    EXCEPTION
        WHEN ERR_HANDLER THEN
            OPEN asResult FOR
                SELECT  asRetVal
                  FROM  DUAL;
            
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
            ROLLBACK;
            RETURN;
        WHEN OTHERS THEN
            asRetVal := '9999';
            asRetMsg := FC_GET_WORDPACK_MSG(PSV_COMP_CD, PSV_LANG_TP, '1004999999');  -- 자료처리중 오류가 발생했습니다. 관리자에게 문의하여 주십시오.
            --asRetMsg := SQLERRM;
            OPEN asResult FOR
                SELECT  asRetVal
                  FROM  DUAL;
            
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
            ROLLBACK;
            RETURN;
    END SEND_MMS;
        
    --------------------------------------------------------------------------------
    --  Procedure Name   : F_GET_CARD_ID
    --  Description      : 카드 ID
    --  Ref. Table       : 
    --------------------------------------------------------------------------------
    --  Create Date      :
    --  Modify Date      :  
    --------------------------------------------------------------------------------
    FUNCTION F_GET_CARD_ID
    (
        PSV_COMP_CD           IN   VARCHAR2, -- 1. 회사코드 
        PSV_MEMBER_NO         IN   VARCHAR2  -- 2. 회원번호
    ) RETURN VARCHAR2 IS
        lsCardId        C_CARD.CARD_ID%TYPE; -- 카드 ID
    BEGIN
        SELECT  CARD_ID INTO lsCardId
        FROM    C_CUST CST
              , C_CARD CRD
        WHERE   CST.COMP_CD   = CRD.COMP_CD
        AND     CST.CUST_ID   = CRD.CUST_ID
        AND     CST.COMP_CD   = PSV_COMP_CD
        AND     CST.MEMBER_NO = PSV_MEMBER_NO
        AND     CRD.CARD_STAT = '10'
        AND     ROWNUM    = 1;
        
        RETURN lsCardId;
    EXCEPTION 
        WHEN OTHERS THEN
            RETURN NULL;      
    END;    
    
    --------------------------------------------------------------------------------
    --  Procedure Name   : F_GET_SAVR_PT_RATE
    --  Description      : 포인트 적립률
    --  Ref. Table       : 
    --------------------------------------------------------------------------------
    --  Create Date      :
    --  Modify Date      :  
    --------------------------------------------------------------------------------
    FUNCTION F_GET_SAV_PT_RATE
    (
        PSV_COMP_CD           IN   VARCHAR2, -- 1. 회사코드 
        PSV_MEMBER_NO         IN   VARCHAR2  -- 2. 회원번호
    ) RETURN NUMBER IS
        nSavPtRate        C_CUST_LVL.SAV_PT_RATE%TYPE; -- 포인트 적립률
    BEGIN
        SELECT  LVL.SAV_PT_RATE INTO nSavPtRate
        FROM    C_CUST      CST
              , C_CUST_LVL  LVL
        WHERE   CST.COMP_CD   = LVL.COMP_CD
        AND     CST.LVL_CD    = LVL.LVL_CD
        AND     CST.COMP_CD   = PSV_COMP_CD
        AND     CST.MEMBER_NO = PSV_MEMBER_NO
        AND     ROWNUM    = 1;
        
        RETURN nSavPtRate;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 0;      
    END;
    
END PKG_CS_MEMBER_ACK;

/
