--------------------------------------------------------
--  DDL for Procedure SP_B2B_CREDIT_INFO
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_B2B_CREDIT_INFO" (vB2BCODE IN VARCHAR2,
                                               nCREDITVALUE OUT VARCHAR2)
IS                                               
  req           utl_http.req;
  resp          utl_http.resp;
  vCrecitVal    VARCHAR2(32000);
BEGIN
    IF vB2BCODE IS NULL THEN
        nCREDITVALUE := '0';
    ELSE
        req  := utl_http.begin_request('http://121.78.170.201:8388');
        resp := utl_http.get_response(req);

        vCrecitVal := utl_http.request('http://121.78.170.201:8388/EXEC_WPOS/UTIL/ProcedureCall.jsp?SCH_CUST_ID='||vB2BCODE);

        dbms_output.put_line(vCrecitVal);

        nCREDITVALUE := vCrecitVal;
    END IF;

    utl_http.end_response(resp);
EXCEPTION
    WHEN utl_http.end_of_body THEN
        nCREDITVALUE := '0';

        dbms_output.put_line(SQLERRM);
        utl_http.end_response(resp);
END;

/
