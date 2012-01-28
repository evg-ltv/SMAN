
PROMPT ===========================================
PROMPT Create table SMAN$_OBJECT_CONFIG
PROMPT ===========================================


  CREATE TABLE "SMAN$_OBJECT_CONFIG" 
   (	"CMP_CMP_ID" VARCHAR2(30), 
	"OBJECT_TYPE" VARCHAR2(30), 
	"OBJECT_NAME" VARCHAR2(30), 
	"GENERATE_DML" VARCHAR2(1), 
	"OBJECT_COMMENT" VARCHAR2(2000), 
	"CREATE_PUBLIC_SYNONYM" VARCHAR2(1), 
	"GENERATE_GRANTS" VARCHAR2(1), 
	"SORT_ORDER" NUMBER
   ) PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  TABLESPACE "&&DATA_MD" ;
 
PROMPT ===========================================
PROMPT Add comments on SMAN$_OBJECT_CONFIG
PROMPT ===========================================


   COMMENT ON COLUMN "SMAN$_OBJECT_CONFIG"."CMP_CMP_ID" IS 'Component id';
 
   COMMENT ON COLUMN "SMAN$_OBJECT_CONFIG"."OBJECT_TYPE" IS 'Schema-object type';
 
   COMMENT ON COLUMN "SMAN$_OBJECT_CONFIG"."OBJECT_NAME" IS 'Schema-object name';
 
   COMMENT ON COLUMN "SMAN$_OBJECT_CONFIG"."GENERATE_DML" IS 'Flag - if DML is needed for this object (only tables)';
 
   COMMENT ON COLUMN "SMAN$_OBJECT_CONFIG"."OBJECT_COMMENT" IS 'Comment';
 
   COMMENT ON COLUMN "SMAN$_OBJECT_CONFIG"."CREATE_PUBLIC_SYNONYM" IS 'Flag - if public synonym is needed (doesn''t make sense for triggers and synonyms)';
 
   COMMENT ON COLUMN "SMAN$_OBJECT_CONFIG"."GENERATE_GRANTS" IS 'Flag - if grants are needed (doesn''t make sense for triggers and synonyms)';
 
   COMMENT ON COLUMN "SMAN$_OBJECT_CONFIG"."SORT_ORDER" IS 'Sort order (within an object_type)';
 
   COMMENT ON TABLE "SMAN$_OBJECT_CONFIG"  IS 'List of objects';
 