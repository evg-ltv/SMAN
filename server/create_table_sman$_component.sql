
PROMPT ===========================================
PROMPT Create table SMAN$_COMPONENT
PROMPT ===========================================


  CREATE TABLE "SMAN$_COMPONENT" 
   (	"CMP_ID" VARCHAR2(30), 
	"CMP_DESC" VARCHAR2(2000)
   ) PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  TABLESPACE "&&DATA_MD" ;
 
PROMPT ===========================================
PROMPT Add comments on SMAN$_COMPONENT
PROMPT ===========================================


   COMMENT ON COLUMN "SMAN$_COMPONENT"."CMP_ID" IS 'Component id';
 
   COMMENT ON COLUMN "SMAN$_COMPONENT"."CMP_DESC" IS 'Component description';
 
   COMMENT ON TABLE "SMAN$_COMPONENT"  IS 'List of components';
 