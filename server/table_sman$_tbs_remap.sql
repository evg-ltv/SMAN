
PROMPT ===========================================
PROMPT Add constraints on SMAN$_TBS_REMAP
PROMPT ===========================================


  ALTER TABLE "SMAN$_TBS_REMAP" MODIFY ("TABLESPACE_NAME" NOT NULL ENABLE);
 
  ALTER TABLE "SMAN$_TBS_REMAP" MODIFY ("REMAP_TABLESPACE_NAME" NOT NULL ENABLE);
 