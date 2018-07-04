--------------------------------------------------------
--  DDL for Procedure XXX_BATCH_TRANS_SALE_DATA
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."XXX_BATCH_TRANS_SALE_DATA" 
IS 
    v_hd_date DATE;
    v_dt_date DATE;
    v_st_date DATE;
    v_dc_date DATE;
BEGIN 
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2018-02-20
    -- Description   :   POS DB의 SALE_DT, SALE_HD 정보이관 프로시저
    -- ==========================================================================================

             SELECT 
                     NVL(MAX(CASE WHEN TRAN_TYPE = 'SALE_HD' THEN MAX(TRAN_DATE) ELSE NULL END), SYSDATE)
                  ,  NVL(MAX(CASE WHEN TRAN_TYPE = 'SALE_DT' THEN MAX(TRAN_DATE) ELSE NULL END), SYSDATE)
                  ,  NVL(MAX(CASE WHEN TRAN_TYPE = 'SALE_ST' THEN MAX(TRAN_DATE) ELSE NULL END), SYSDATE)
                  ,  NVL(MAX(CASE WHEN TRAN_TYPE = 'SALE_DC' THEN MAX(TRAN_DATE) ELSE NULL END), SYSDATE)
               INTO  v_hd_date, v_dt_date, v_st_date, v_dc_date
               FROM  SALE_TRAN_DT
              GROUP  BY TRAN_TYPE;
    
    -----------------------------------------  SALE_HD ------------------------------------------
    
    BEGIN
             MERGE INTO SALE_HD T
             USING (
                     SELECT 
                            COMP_CD
                          , SALE_DT
                          , BRAND_CD
                          , STOR_CD
                          , POS_NO
                          , BILL_NO
                          , CASHIER_ID,SALE_DIV,GIFT_DIV,SORD_TM,SALE_TM,ORDER_NO,FLOOR,TABLE_NO,TABLE_CNT,FOREIGN_DIV,CUST_SEX
                          , CUST_AGE,CUST_M_CNT,CUST_F_CNT,VOID_BEFORE_DT,VOID_BEFORE_NO,RTN_REASON_CD,RTN_MEMO,SALE_QTY,SALE_AMT
                          , DC_AMT,ENR_AMT,GRD_I_AMT,GRD_O_AMT,VAT_I_AMT
                          , VAT_O_AMT,SVC_AMT,SVC_DC_AMT,SVC_VAT_AMT,CREDIT_AMT,PACK_AMT,SALER_DT,SAP_IF_YN,SAP_IF_DT
                          , SALE_TYPE,CNT_ORD_NO,SAV_MLG,SAV_PT,CUST_ID,CARD_ID,CUST_NM,INST_DT
                      FROM  SALE_HD@HPOSDB 
                     WHERE  INST_DT > v_hd_date
             )FR 
             ON(  
                            T.COMP_CD = FR.COMP_CD  
                       AND  T.SALE_DT  = FR.SALE_DT  
                       AND  T.BRAND_CD = FR.BRAND_CD 
                       AND  T.STOR_CD  = FR.STOR_CD  
                       AND  T.POS_NO   = FR.POS_NO   
                       AND  T.BILL_NO  = FR.BILL_NO  
             ) 
             WHEN MATCHED THEN    
                     UPDATE SET 
                            T.CASHIER_ID     =  FR.CASHIER_ID    
                          , T.SALE_DIV       =  FR.SALE_DIV      
                          , T.GIFT_DIV       =  FR.GIFT_DIV      
                          , T.SORD_TM        =  FR.SORD_TM       
                          , T.SALE_TM        =  FR.SALE_TM       
                          , T.ORDER_NO       =  FR.ORDER_NO      
                          , T.FLOOR          =  FR.FLOOR         
                          , T.TABLE_NO       =  FR.TABLE_NO      
                          , T.TABLE_CNT      =  FR.TABLE_CNT     
                          , T.FOREIGN_DIV    =  FR.FOREIGN_DIV   
                          , T.CUST_SEX       =  FR.CUST_SEX      
                          , T.CUST_AGE       =  FR.CUST_AGE      
                          , T.CUST_M_CNT     =  FR.CUST_M_CNT    
                          , T.CUST_F_CNT     =  FR.CUST_F_CNT    
                          , T.VOID_BEFORE_DT =  FR.VOID_BEFORE_DT
                          , T.VOID_BEFORE_NO =  FR.VOID_BEFORE_NO
                          , T.RTN_REASON_CD  =  FR.RTN_REASON_CD 
                          , T.RTN_MEMO       =  FR.RTN_MEMO      
                          , T.SALE_QTY       =  FR.SALE_QTY      
                          , T.SALE_AMT       =  FR.SALE_AMT      
                          , T.DC_AMT         =  FR.DC_AMT        
                          , T.ENR_AMT        =  FR.ENR_AMT       
                          , T.GRD_I_AMT      =  FR.GRD_I_AMT     
                          , T.GRD_O_AMT      =  FR.GRD_O_AMT     
                          , T.VAT_I_AMT      =  FR.VAT_I_AMT     
                          , T.VAT_O_AMT      =  FR.VAT_O_AMT     
                          , T.SVC_AMT        =  FR.SVC_AMT       
                          , T.SVC_DC_AMT     =  FR.SVC_DC_AMT    
                          , T.SVC_VAT_AMT    =  FR.SVC_VAT_AMT   
                          , T.CREDIT_AMT     =  FR.CREDIT_AMT    
                          , T.PACK_AMT       =  FR.PACK_AMT      
                          , T.SALER_DT       =  FR.SALER_DT      
                          , T.SAP_IF_YN      =  FR.SAP_IF_YN     
                          , T.SAP_IF_DT      =  FR.SAP_IF_DT     
                          , T.SALE_TYPE      =  FR.SALE_TYPE     
                          , T.CNT_ORD_NO     =  FR.CNT_ORD_NO    
                          , T.SAV_MLG        =  FR.SAV_MLG       
                          , T.SAV_PT         =  FR.SAV_PT        
                          , T.CUST_ID        =  FR.CUST_ID       
                          , T.CARD_ID        =  FR.CARD_ID       
                          , T.CUST_NM        =  FR.CUST_NM       
             WHEN NOT MATCHED THEN    
                    INSERT  VALUES (
                            FR.COMP_CD, FR.SALE_DT, FR.BRAND_CD, FR.STOR_CD, FR.POS_NO, FR.BILL_NO
                          , FR.CASHIER_ID, FR.SALE_DIV, FR.GIFT_DIV, FR.SORD_TM, FR.SALE_TM, FR.ORDER_NO, FR.FLOOR, FR.TABLE_NO, FR.TABLE_CNT, FR.FOREIGN_DIV, FR.CUST_SEX
                          , FR.CUST_AGE, FR.CUST_M_CNT, FR.CUST_F_CNT, FR.VOID_BEFORE_DT, FR.VOID_BEFORE_NO, FR.RTN_REASON_CD, FR.RTN_MEMO, FR.SALE_QTY, FR.SALE_AMT, FR.DC_AMT, FR.ENR_AMT, FR.GRD_I_AMT, FR.GRD_O_AMT, FR.VAT_I_AMT
                          , FR.VAT_O_AMT, FR.SVC_AMT, FR.SVC_DC_AMT, FR.SVC_VAT_AMT, FR.CREDIT_AMT, FR.PACK_AMT, FR.SALER_DT, FR.SAP_IF_YN, FR.SAP_IF_DT, FR.SALE_TYPE, FR.CNT_ORD_NO, FR.SAV_MLG, FR.SAV_PT, FR.CUST_ID, FR.CARD_ID, FR.CUST_NM, FR.INST_DT
                    );
           
             SELECT NVL(MAX(INST_DT), SYSDATE) INTO v_hd_date FROM SALE_HD;
            
             MERGE INTO SALE_TRAN_DT
             USING DUAL
             ON (TRAN_TYPE = 'SALE_HD')
             WHEN NOT MATCHED THEN
               INSERT (
                 TRAN_TYPE
                 ,TRAN_DATE
               ) VALUES (
                 'SALE_HD'
                 ,v_hd_date
               )
             WHEN MATCHED THEN
               UPDATE SET 
                 TRAN_DATE = v_hd_date
             ;
             COMMIT;
    END;
    -----------------------------------------  SALE_DT ------------------------------------------
    BEGIN
     
             MERGE INTO SALE_DT T
             USING (
                    SELECT
                            COMP_CD
                          , SALE_DT
                          , BRAND_CD
                          , STOR_CD
                          , POS_NO
                          , BILL_NO
                          , SEQ
                          , SALE_DIV,TAKE_DIV,GIFT_DIV,SORD_TM,DELIVER_TM,SALE_TM,ITEM_CD,MAIN_ITEM_CD,T_SEQ,ITEM_SET_DIV
                          , PACK_DIV,SUB_ITEM_DIV,SUB_TOUCH_DIV,SUB_TOUCH_GR_CD,SUB_TOUCH_CD,SUB_ITEM_CD,TR_GR_NO,FREE_DIV,DC_DIV,SALE_QTY,SALE_PRC,SALE_AMT,DC_RATE,DC_AMT,ENR_AMT
                          , GRD_AMT,NET_AMT,VAT_RATE,VAT_AMT,SVC_RATE,SVC_AMT,SVC_VAT_AMT,SALER_DT,SALE_TYPE,RTN_DIV,USER_ID,CUST_ID,CARD_ID,SAV_MLG,SAV_PT,DC_QTY,FREE_QTY,INST_DT
                     FROM   SALE_DT@HPOSDB
                    WHERE   INST_DT > v_dt_date
             )FR 
             ON(            T.COMP_CD = FR.COMP_CD  
                       AND  T.SALE_DT  = FR.SALE_DT  
                       AND  T.BRAND_CD = FR.BRAND_CD 
                       AND  T.STOR_CD  = FR.STOR_CD  
                       AND  T.POS_NO   = FR.POS_NO   
                       AND  T.BILL_NO  = FR.BILL_NO
                       AND  T.SEQ      = FR.SEQ
             ) 
             WHEN MATCHED THEN    
                   UPDATE   SET    
                            T.SALE_DIV         =  FR.SALE_DIV         
                          , T.TAKE_DIV         =  FR.TAKE_DIV         
                          , T.GIFT_DIV         =  FR.GIFT_DIV         
                          , T.SORD_TM          =  FR.SORD_TM          
                          , T.DELIVER_TM       =  FR.DELIVER_TM       
                          , T.SALE_TM          =  FR.SALE_TM          
                          , T.ITEM_CD          =  FR.ITEM_CD          
                          , T.MAIN_ITEM_CD     =  FR.MAIN_ITEM_CD     
                          , T.T_SEQ            =  FR.T_SEQ            
                          , T.ITEM_SET_DIV     =  FR.ITEM_SET_DIV     
                          , T.PACK_DIV         =  FR.PACK_DIV        
                          , T.SUB_ITEM_DIV     =  FR.SUB_ITEM_DIV     
                          , T.SUB_TOUCH_DIV    =  FR.SUB_TOUCH_DIV    
                          , T.SUB_TOUCH_GR_CD  =  FR.SUB_TOUCH_GR_CD  
                          , T.SUB_TOUCH_CD     =  FR.SUB_TOUCH_CD     
                          , T.SUB_ITEM_CD      =  FR.SUB_ITEM_CD      
                          , T.TR_GR_NO         =  FR.TR_GR_NO         
                          , T.FREE_DIV         =  FR.FREE_DIV         
                          , T.DC_DIV           =  FR.DC_DIV           
                          , T.SALE_QTY         =  FR.SALE_QTY         
                          , T.SALE_PRC         =  FR.SALE_PRC         
                          , T.SALE_AMT         =  FR.SALE_AMT         
                          , T.DC_RATE          =  FR.DC_RATE          
                          , T.DC_AMT           =  FR.DC_AMT           
                          , T.ENR_AMT          =  FR.ENR_AMT          
                          , T.GRD_AMT          =  FR.GRD_AMT          
                          , T.NET_AMT          =  FR.NET_AMT          
                          , T.VAT_RATE         =  FR.VAT_RATE         
                          , T.VAT_AMT          =  FR.VAT_AMT          
                          , T.SVC_RATE         =  FR.SVC_RATE         
                          , T.SVC_AMT          =  FR.SVC_AMT          
                          , T.SVC_VAT_AMT      =  FR.SVC_VAT_AMT      
                          , T.SALER_DT         =  FR.SALER_DT         
                          , T.SALE_TYPE        =  FR.SALE_TYPE        
                          , T.RTN_DIV          =  FR.RTN_DIV          
                          , T.USER_ID          =  FR.USER_ID          
                          , T.CUST_ID          =  FR.CUST_ID          
                          , T.CARD_ID          =  FR.CARD_ID          
                          , T.SAV_MLG          =  FR.SAV_MLG          
                          , T.SAV_PT           =  FR.SAV_PT           
                          , T.DC_QTY           =  FR.DC_QTY           
                          , T.FREE_QTY         =  FR.FREE_QTY         
             WHEN NOT MATCHED THEN    
                     INSERT  VALUES (
                            FR.COMP_CD
                          , FR.SALE_DT
                          , FR.BRAND_CD
                          , FR.STOR_CD
                          , FR.POS_NO
                          , FR.BILL_NO
                          , FR.SEQ
                          , FR.SALE_DIV, FR.TAKE_DIV, FR.GIFT_DIV, FR.SORD_TM, FR.DELIVER_TM, FR.SALE_TM, FR.ITEM_CD, FR.MAIN_ITEM_CD, FR.T_SEQ, FR.ITEM_SET_DIV
                          , FR.PACK_DIV, FR.SUB_ITEM_DIV, FR.SUB_TOUCH_DIV, FR.SUB_TOUCH_GR_CD, FR.SUB_TOUCH_CD, FR.SUB_ITEM_CD, FR.TR_GR_NO, FR.FREE_DIV, FR.DC_DIV, FR.SALE_QTY, FR.SALE_PRC, FR.SALE_AMT, FR.DC_RATE, FR.DC_AMT, FR.ENR_AMT
                          , FR.GRD_AMT, FR.NET_AMT, FR.VAT_RATE, FR.VAT_AMT, FR.SVC_RATE, FR.SVC_AMT, FR.SVC_VAT_AMT, FR.SALER_DT, FR.SALE_TYPE, FR.RTN_DIV, FR.USER_ID, FR.CUST_ID, FR.CARD_ID, FR.SAV_MLG, FR.SAV_PT, FR.DC_QTY, FR.FREE_QTY, FR.INST_DT
                    );
       
             SELECT NVL(MAX(INST_DT), SYSDATE) INTO v_dt_date FROM SALE_DT;
              
             MERGE INTO SALE_TRAN_DT
             USING DUAL
             ON (TRAN_TYPE = 'SALE_DT')
             WHEN NOT MATCHED THEN
               INSERT (
                 TRAN_TYPE
                 ,TRAN_DATE
               ) VALUES (
                 'SALE_DT'
                 ,v_dt_date
               )
             WHEN MATCHED THEN
               UPDATE SET 
                 TRAN_DATE = v_dt_date
             ;
             COMMIT;
           END;
    -----------------------------------------  SALE_ST ------------------------------------------
    
             MERGE INTO SALE_ST T
             USING (
                     SELECT 
                            SALE_DT
                          , BRAND_CD
                          , STOR_CD
                          , POS_NO
                          , BILL_NO
                          , SEQ
                          , PAY_DIV,CURRENCY_CD,EXC_RATE,SALE_DIV,GIFT_DIV,APPR_VAN_CD,APPR_MAEIP_CD,APPR_MAEIP_NM,APPR_VAL_CD
                          , COOP_CARD,CARD_NO,CARD_NM,CARD_LMT,ALLOT_LMT,READ_DIV,APPR_DIV,APPR_NO,APPR_DT,APPR_TM,APPR_AMT,CHANGE_AMT,ORG_AMT,PAY_AMT,REMAIN_AMT,CHANGE_CASHAMT
                          , APPR_QTY,SALER_DT,SALE_TYPE,CUST_ID,CARD_ID,SALE_TM,INST_DT
                   FROM SALE_ST@HPOSDB
                   WHERE INST_DT > v_st_date
             )FR 
             ON(            T.SALE_DT  = FR.SALE_DT  
                       AND  T.BRAND_CD = FR.BRAND_CD 
                       AND  T.STOR_CD  = FR.STOR_CD  
                       AND  T.POS_NO   = FR.POS_NO   
                       AND  T.BILL_NO  = FR.BILL_NO
                       AND  T.SEQ      = FR.SEQ
             ) 
             WHEN MATCHED THEN    
                     UPDATE SET 
                            T.PAY_DIV         =  FR.PAY_DIV         
                          , T.CURRENCY_CD     =  FR.CURRENCY_CD     
                          , T.EXC_RATE        =  FR.EXC_RATE        
                          , T.SALE_DIV        =  FR.SALE_DIV        
                          , T.GIFT_DIV        =  FR.GIFT_DIV        
                          , T.APPR_VAN_CD     =  FR.APPR_VAN_CD     
                          , T.APPR_MAEIP_CD   =  FR.APPR_MAEIP_CD   
                          , T.APPR_MAEIP_NM   =  FR.APPR_MAEIP_NM   
                          , T.APPR_VAL_CD     =  FR.APPR_VAL_CD     
                          , T.COOP_CARD       =  FR.COOP_CARD       
                          , T.CARD_NO         =  FR.CARD_NO         
                          , T.CARD_NM         =  FR.CARD_NM         
                          , T.CARD_LMT        =  FR.CARD_LMT        
                          , T.ALLOT_LMT       =  FR.ALLOT_LMT       
                          , T.READ_DIV        =  FR.READ_DIV        
                          , T.APPR_DIV        =  FR.APPR_DIV        
                          , T.APPR_NO         =  FR.APPR_NO         
                          , T.APPR_DT         =  FR.APPR_DT         
                          , T.APPR_TM         =  FR.APPR_TM         
                          , T.APPR_AMT        =  FR.APPR_AMT        
                          , T.CHANGE_AMT      =  FR.CHANGE_AMT      
                          , T.ORG_AMT         =  FR.ORG_AMT         
                          , T.PAY_AMT         =  FR.PAY_AMT         
                          , T.REMAIN_AMT      =  FR.REMAIN_AMT      
                          , T.CHANGE_CASHAMT  =  FR.CHANGE_CASHAMT  
                          , T.APPR_QTY        =  FR.APPR_QTY        
                          , T.SALER_DT        =  FR.SALER_DT        
                          , T.SALE_TYPE       =  FR.SALE_TYPE       
                          , T.CUST_ID         =  FR.CUST_ID         
                          , T.CARD_ID         =  FR.CARD_ID         
                          , T.SALE_TM         =  FR.SALE_TM         
             WHEN NOT MATCHED THEN    
                    INSERT  VALUES (
                            FR.SALE_DT
                          , FR.BRAND_CD
                          , FR.STOR_CD
                          , FR.POS_NO
                          , FR.BILL_NO
                          , FR.SEQ
                          , FR.PAY_DIV, FR.CURRENCY_CD, FR.EXC_RATE, FR.SALE_DIV, FR.GIFT_DIV, FR.APPR_VAN_CD, FR.APPR_MAEIP_CD, FR.APPR_MAEIP_NM, FR.APPR_VAL_CD
                          , FR.COOP_CARD, FR.CARD_NO, FR.CARD_NM, FR.CARD_LMT, FR.ALLOT_LMT, FR.READ_DIV, FR.APPR_DIV, FR.APPR_NO, FR.APPR_DT, FR.APPR_TM, FR.APPR_AMT, FR.CHANGE_AMT, FR.ORG_AMT, FR.PAY_AMT, FR.REMAIN_AMT, FR.CHANGE_CASHAMT
                          , FR.APPR_QTY, FR.SALER_DT, FR.SALE_TYPE, FR.CUST_ID, FR.CARD_ID, FR.SALE_TM, FR.INST_DT
                    );
             
             SELECT NVL(MAX(INST_DT), SYSDATE) INTO v_st_date FROM SALE_ST;
             
             MERGE INTO SALE_TRAN_DT
             USING DUAL
             ON (TRAN_TYPE = 'SALE_ST')
             WHEN NOT MATCHED THEN
               INSERT (
                 TRAN_TYPE
                 ,TRAN_DATE
               ) VALUES (
                 'SALE_ST'
                 ,v_st_date
               )
             WHEN MATCHED THEN
               UPDATE SET 
                 TRAN_DATE = v_st_date
             ;
             COMMIT;
             
    -----------------------------------------  SALE_DC ------------------------------------------
          
             MERGE INTO SALE_DC T
             USING (
                    SELECT
                            COMP_CD
                          , SALE_DT
                          , BRAND_CD
                          , STOR_CD
                          , POS_NO
                          , BILL_NO
                          , SEQ 
                          , DC_SEQ
                          , SALE_DIV,TAKE_DIV,GIFT_DIV,ITEM_CD,MAIN_ITEM_CD,T_SEQ,ITEM_SET_DIV,SUB_TOUCH_DIV,FREE_DIV
                          , DC_DIV,SALE_QTY,SALE_PRC,SALE_AMT,DC_RATE,DC_AMT,ENR_AMT,GRD_AMT,VAT_AMT,SVC_AMT,SVC_VAT_AMT,SALE_TYPE,USER_ID,CUST_ID,CARD_ID,DC_AMT_H,DC_AMT_S,INST_DT
                     FROM SALE_DC@HPOSDB
                     WHERE INST_DT > v_dc_date
             )FR 
             ON(            T.COMP_CD = FR.COMP_CD  
                       AND  T.SALE_DT  = FR.SALE_DT  
                       AND  T.BRAND_CD = FR.BRAND_CD 
                       AND  T.STOR_CD  = FR.STOR_CD  
                       AND  T.POS_NO   = FR.POS_NO   
                       AND  T.BILL_NO  = FR.BILL_NO
                       AND  T.SEQ      = FR.SEQ
                       AND  T.DC_SEQ   = FR.DC_SEQ
             ) 
             WHEN MATCHED THEN    
                     UPDATE SET 
                            T.SALE_DIV       =   FR.SALE_DIV      
                          , T.TAKE_DIV       =   FR.TAKE_DIV      
                          , T.GIFT_DIV       =   FR.GIFT_DIV      
                          , T.ITEM_CD        =   FR.ITEM_CD       
                          , T.MAIN_ITEM_CD   =   FR.MAIN_ITEM_CD  
                          , T.T_SEQ          =   FR.T_SEQ         
                          , T.ITEM_SET_DIV   =   FR.ITEM_SET_DIV  
                          , T.SUB_TOUCH_DIV  =   FR.SUB_TOUCH_DIV 
                          , T.FREE_DIV       =   FR.FREE_DIV      
                          , T.DC_DIV         =   FR.DC_DIV        
                          , T.SALE_QTY       =   FR.SALE_QTY      
                          , T.SALE_PRC       =   FR.SALE_PRC      
                          , T.SALE_AMT       =   FR.SALE_AMT      
                          , T.DC_RATE        =   FR.DC_RATE       
                          , T.DC_AMT         =   FR.DC_AMT        
                          , T.ENR_AMT        =   FR.ENR_AMT       
                          , T.GRD_AMT        =   FR.GRD_AMT       
                          , T.VAT_AMT        =   FR.VAT_AMT       
                          , T.SVC_AMT        =   FR.SVC_AMT       
                          , T.SVC_VAT_AMT    =   FR.SVC_VAT_AMT   
                          , T.SALE_TYPE      =   FR.SALE_TYPE     
                          , T.USER_ID        =   FR.USER_ID       
                          , T.CUST_ID        =   FR.CUST_ID       
                          , T.CARD_ID        =   FR.CARD_ID       
                          , T.DC_AMT_H       =   FR.DC_AMT_H      
                          , T.DC_AMT_S       =   FR.DC_AMT_S      
             WHEN NOT MATCHED THEN    
                    INSERT  VALUES ( 
                            FR.COMP_CD
                          , FR.SALE_DT
                          , FR.BRAND_CD
                          , FR.STOR_CD
                          , FR.POS_NO
                          , FR.BILL_NO
                          , FR.SEQ
                          , FR.DC_SEQ
                          , FR.SALE_DIV, FR.TAKE_DIV, FR.GIFT_DIV, FR.ITEM_CD, FR.MAIN_ITEM_CD, FR.T_SEQ, FR.ITEM_SET_DIV, FR.SUB_TOUCH_DIV, FR.FREE_DIV
                          , FR.DC_DIV, FR.SALE_QTY, FR.SALE_PRC, FR.SALE_AMT, FR.DC_RATE, FR.DC_AMT, FR.ENR_AMT, FR.GRD_AMT, FR.VAT_AMT, FR.SVC_AMT, FR.SVC_VAT_AMT, FR.SALE_TYPE, FR.USER_ID, FR.CUST_ID, FR.CARD_ID, FR.DC_AMT_H, FR.DC_AMT_S, FR.INST_DT
                    );
             
             SELECT NVL(MAX(INST_DT), SYSDATE) INTO v_dc_date FROM SALE_DC;
             
             MERGE INTO SALE_TRAN_DT
             USING DUAL
             ON (TRAN_TYPE = 'SALE_DC')
             WHEN NOT MATCHED THEN
               INSERT (
                  TRAN_TYPE
                 ,TRAN_DATE
               ) VALUES (
                  'SALE_DC'
                 ,v_dc_date
               )
             WHEN MATCHED THEN
               UPDATE SET 
                 TRAN_DATE = v_dc_date
             ;
             COMMIT;
END XXX_BATCH_TRANS_SALE_DATA;

/
