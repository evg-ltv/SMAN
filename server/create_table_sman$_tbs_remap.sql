
PROMPT ===========================================
PROMPT Create table SMAN$_TBS_REMAP
PROMPT ===========================================


  CREATE TABLE "SMAN$_TBS_REMAP" 
   (	"TABLESPACE_NAME" VARCHAR2(30), 
	"REMAP_TABLESPACE_NAME" VARCHAR2(30)
   ) PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  TABLESPACE "&&DATA_MD" ;
 
PROMPT ===========================================
PROMPT Add comments on SMAN$_TBS_REMAP
PROMPT ===========================================


   COMMENT ON COLUMN "SMAN$_TBS_REMAP"."TABLESPACE_NAME" IS 'Tablespace name';
 
   COMMENT ON COLUMN "SMAN$_TBS_REMAP"."REMAP_TABLESPACE_NAME" IS 'Remap tablespace name (for SQL*Plus variables use the ampersand before names)';
 
   COMMENT ON TABLE "SMAN$_TBS_REMAP"  IS 'Tablespace remapping for SMAN';
 