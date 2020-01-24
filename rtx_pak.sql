CREATE OR REPLACE PACKAGE rtf IS
  FUNCTION to_text(rtf_in IN CLOB) RETURN CLOB IS
    language java name 'rtf.getString( oracle.sql.CLOB ) return oracle.sql.CLOB ';
END rtf;





