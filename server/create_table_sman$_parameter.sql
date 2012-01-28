
PROMPT ===========================================
PROMPT Create table SMAN$_PARAMETER
PROMPT ===========================================


  CREATE TABLE "SMAN$_PARAMETER" 
   (	"PARAM_NAME" VARCHAR2(30), 
	"PARAM_VALUE" VARCHAR2(4000), 
	"DESCRIPTION" VARCHAR2(4000)
   ) PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  TABLESPACE "&&DATA_MD" ;
 
PROMPT ===========================================
PROMPT Add comments on SMAN$_PARAMETER
PROMPT ===========================================


   COMMENT ON COLUMN "SMAN$_PARAMETER"."PARAM_NAME" IS 'Name';
 
   COMMENT ON COLUMN "SMAN$_PARAMETER"."PARAM_VALUE" IS 'Value';
 
   COMMENT ON COLUMN "SMAN$_PARAMETER"."DESCRIPTION" IS 'Description';
 
   COMMENT ON TABLE "SMAN$_PARAMETER"  IS 'Parameters';
 