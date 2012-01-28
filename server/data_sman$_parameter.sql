
PROMPT ===========================================
PROMPT Load data into SMAN$_PARAMETER
PROMPT ===========================================

DELETE SMAN$_PARAMETER;

INSERT INTO SMAN$_PARAMETER (PARAM_NAME, PARAM_VALUE, DESCRIPTION)
VALUES ('ADD_PROMPT_STRING','T','If it is true, prompt comments which show object names will be added before statements');
INSERT INTO SMAN$_PARAMETER (PARAM_NAME, PARAM_VALUE, DESCRIPTION)
VALUES ('ALL_GRANTS_FILENAME','grants_$cmp.sql','File name. Next variables can be used inside: $cmp - component name');
INSERT INTO SMAN$_PARAMETER (PARAM_NAME, PARAM_VALUE, DESCRIPTION)
VALUES ('ALL_GRANTS_PATH','sql','Folder name where files will be saved. "/" - current folder');
INSERT INTO SMAN$_PARAMETER (PARAM_NAME, PARAM_VALUE, DESCRIPTION)
VALUES ('ALL_GRANTS_SORT_ORDER','15','Sort order in which objects appear in a deploy file');
INSERT INTO SMAN$_PARAMETER (PARAM_NAME, PARAM_VALUE, DESCRIPTION)
VALUES ('ALL_PUBLIC_SYNONYMS_FILENAME','public_synonyms_$cmp.sql','File name. Next variables can be used inside: $cmp - component name');
INSERT INTO SMAN$_PARAMETER (PARAM_NAME, PARAM_VALUE, DESCRIPTION)
VALUES ('ALL_PUBLIC_SYNONYMS_PATH','sql','Folder name where files will be saved. "/" - current folder');
INSERT INTO SMAN$_PARAMETER (PARAM_NAME, PARAM_VALUE, DESCRIPTION)
VALUES ('ALL_PUBLIC_SYNONYMS_SORT_ORDER','16','Sort order in which objects appear in a deploy file');
INSERT INTO SMAN$_PARAMETER (PARAM_NAME, PARAM_VALUE, DESCRIPTION)
VALUES ('DELETE_BEFORE_INSERT','T','Add delete statement before insert in DML files');
INSERT INTO SMAN$_PARAMETER (PARAM_NAME, PARAM_VALUE, DESCRIPTION)
VALUES ('DEPLOY_EXEC_FILE_STRING','@../','Prefix which is added before file names in deploy files. It shows the relative path to files (which are stored in *_PATH folders). If there is more than one folder level, it will not work.');
INSERT INTO SMAN$_PARAMETER (PARAM_NAME, PARAM_VALUE, DESCRIPTION)
VALUES ('DEPLOY_FILENAME','deploy_$name.sql','File name. Next variables can be used inside: $name - deploy name (set before creating a deploy file)');
INSERT INTO SMAN$_PARAMETER (PARAM_NAME, PARAM_VALUE, DESCRIPTION)
VALUES ('DEPLOY_HEAD','spool spool.log' || chr(10) || 'set pagesize 50000' || chr(10) || 'set linesize 200','Lines that will be added in the beginning of a deploy file');
INSERT INTO SMAN$_PARAMETER (PARAM_NAME, PARAM_VALUE, DESCRIPTION)
VALUES ('DEPLOY_PATH','deploy','Folder name where files will be saved. "/" - current folder');
INSERT INTO SMAN$_PARAMETER (PARAM_NAME, PARAM_VALUE, DESCRIPTION)
VALUES ('DEPLOY_SORT_ORDER','999','Sort order in which objects appear in a deploy file');
INSERT INTO SMAN$_PARAMETER (PARAM_NAME, PARAM_VALUE, DESCRIPTION)
VALUES ('DEPLOY_TAIL','set echo on' || chr(10) || '--prompt Rebuilding schema ... ' || chr(10) || 'exec dbms_utility.compile_schema(user);' || chr(10) || chr(10) || 'column object_name format a30' || chr(10) || 'column object_type format a30' || chr(10) || 'select object_name,object_type' || chr(10) || 'from user_objects' || chr(10) || 'where status <> ''VALID'';' || chr(10) || chr(10) || 'column owner format a30' || chr(10) || 'column object_name format a30' || chr(10) || 'column object_type format a30' || chr(10) || 'column status format a30' || chr(10) || 'select t.owner, t.object_name, t.object_type, t.status' || chr(10) || '  from dba_objects t' || chr(10) || ' where t.owner = ''PUBLIC' chr(10) || '   and t.object_type = ''SYNONYM' chr(10) || '   and t.status <> ''VALID'' order by 3,2;' || chr(10) || chr(10) || 'prompt Press a key to finish ' || chr(10) || 'prompt =======================' || chr(10) || 'prompt Installation finished.' || chr(10) || 'prompt =======================' || chr(10) || 'pause' || chr(10) || 'spool off' || chr(10) || 'exit 0','Lines that will be added in the end of a deploy file');
INSERT INTO SMAN$_PARAMETER (PARAM_NAME, PARAM_VALUE, DESCRIPTION)
VALUES ('DML_FILENAME','data_$name.sql','File name. Next variables can be used inside: $name - object name, $cmp - component name');
INSERT INTO SMAN$_PARAMETER (PARAM_NAME, PARAM_VALUE, DESCRIPTION)
VALUES ('DML_PATH','data','Folder name where files will be saved. "/" - current folder');
INSERT INTO SMAN$_PARAMETER (PARAM_NAME, PARAM_VALUE, DESCRIPTION)
VALUES ('DML_SORT_ORDER','4','Sort order in which objects appear in a deploy file');
INSERT INTO SMAN$_PARAMETER (PARAM_NAME, PARAM_VALUE, DESCRIPTION)
VALUES ('END_OF_SCRIPT', chr(13) || chr(10) || '/' || chr(13) || chr(10) || 'sho err','Lines that will be added in the end of PL/SQL files and views');
INSERT INTO SMAN$_PARAMETER (PARAM_NAME, PARAM_VALUE, DESCRIPTION)
VALUES ('FORCE_VIEW','T','Add FORCE keyword in CREATE VIEW statement');
INSERT INTO SMAN$_PARAMETER (PARAM_NAME, PARAM_VALUE, DESCRIPTION)
VALUES ('FUNCTION_FILENAME','$name.sql','File name. Next variables can be used inside: $name - object name, $cmp - component name');
INSERT INTO SMAN$_PARAMETER (PARAM_NAME, PARAM_VALUE, DESCRIPTION)
VALUES ('FUNCTION_PATH','sql','Folder name where files will be saved. "/" - current folder');
INSERT INTO SMAN$_PARAMETER (PARAM_NAME, PARAM_VALUE, DESCRIPTION)
VALUES ('FUNCTION_SORT_ORDER','12','Sort order in which objects appear in a deploy file');
INSERT INTO SMAN$_PARAMETER (PARAM_NAME, PARAM_VALUE, DESCRIPTION)
VALUES ('MATERIALIZED_VIEW_FILENAME','create_mv_$name.sql','File name. Next variables can be used inside: $name - object name, $cmp - component name');
INSERT INTO SMAN$_PARAMETER (PARAM_NAME, PARAM_VALUE, DESCRIPTION)
VALUES ('MATERIALIZED_VIEW_PATH','ddl','Folder name where files will be saved. "/" - current folder');
INSERT INTO SMAN$_PARAMETER (PARAM_NAME, PARAM_VALUE, DESCRIPTION)
VALUES ('MATERIALIZED_VIEW_SORT_ORDER','8','Sort order in which objects appear in a deploy file');
INSERT INTO SMAN$_PARAMETER (PARAM_NAME, PARAM_VALUE, DESCRIPTION)
VALUES ('PACKAGE_BODY_FILENAME','$name_body.sql','File name. Next variables can be used inside: $name - object name, $cmp - component name');
INSERT INTO SMAN$_PARAMETER (PARAM_NAME, PARAM_VALUE, DESCRIPTION)
VALUES ('PACKAGE_BODY_PATH','sql','Folder name where files will be saved. "/" - current folder');
INSERT INTO SMAN$_PARAMETER (PARAM_NAME, PARAM_VALUE, DESCRIPTION)
VALUES ('PACKAGE_BODY_SORT_ORDER','14','Sort order in which objects appear in a deploy file');
INSERT INTO SMAN$_PARAMETER (PARAM_NAME, PARAM_VALUE, DESCRIPTION)
VALUES ('PACKAGE_FILENAME','$name_head.sql','File name. Next variables can be used inside: $name - object name, $cmp - component name');
INSERT INTO SMAN$_PARAMETER (PARAM_NAME, PARAM_VALUE, DESCRIPTION)
VALUES ('PACKAGE_PATH','sql','Folder name where files will be saved. "/" - current folder');
INSERT INTO SMAN$_PARAMETER (PARAM_NAME, PARAM_VALUE, DESCRIPTION)
VALUES ('PACKAGE_SORT_ORDER','13','Sort order in which objects appear in a deploy file');
INSERT INTO SMAN$_PARAMETER (PARAM_NAME, PARAM_VALUE, DESCRIPTION)
VALUES ('PROCEDURE_FILENAME','$name.sql','File name. Next variables can be used inside: $name - object name, $cmp - component name');
INSERT INTO SMAN$_PARAMETER (PARAM_NAME, PARAM_VALUE, DESCRIPTION)
VALUES ('PROCEDURE_PATH','sql','Folder name where files will be saved. "/" - current folder');
INSERT INTO SMAN$_PARAMETER (PARAM_NAME, PARAM_VALUE, DESCRIPTION)
VALUES ('PROCEDURE_SORT_ORDER','11','Sort order in which objects appear in a deploy file');
INSERT INTO SMAN$_PARAMETER (PARAM_NAME, PARAM_VALUE, DESCRIPTION)
VALUES ('SEQUENCE_FILENAME','create_$name.sql','File name. Next variables can be used inside: $name - object name, $cmp - component name');
INSERT INTO SMAN$_PARAMETER (PARAM_NAME, PARAM_VALUE, DESCRIPTION)
VALUES ('SEQUENCE_PATH','ddl','Folder name where files will be saved. "/" - current folder');
INSERT INTO SMAN$_PARAMETER (PARAM_NAME, PARAM_VALUE, DESCRIPTION)
VALUES ('SEQUENCE_SORT_ORDER','2','Sort order in which objects appear in a deploy file');
INSERT INTO SMAN$_PARAMETER (PARAM_NAME, PARAM_VALUE, DESCRIPTION)
VALUES ('SYNONYM_FILENAME','create_synonym_$name.sql','File name. Next variables can be used inside: $name - object name, $cmp - component name');
INSERT INTO SMAN$_PARAMETER (PARAM_NAME, PARAM_VALUE, DESCRIPTION)
VALUES ('SYNONYM_PATH','ddl','Folder name where files will be saved. "/" - current folder');
INSERT INTO SMAN$_PARAMETER (PARAM_NAME, PARAM_VALUE, DESCRIPTION)
VALUES ('SYNONYM_SORT_ORDER','6','Sort order in which objects appear in a deploy file');
INSERT INTO SMAN$_PARAMETER (PARAM_NAME, PARAM_VALUE, DESCRIPTION)
VALUES ('TABLE_CONSTRAINTS_FILENAME','table_$name.sql','File name. Next variables can be used inside: $name - object name, $cmp - component name');
INSERT INTO SMAN$_PARAMETER (PARAM_NAME, PARAM_VALUE, DESCRIPTION)
VALUES ('TABLE_CONSTRAINTS_PATH','ddl','Folder name where files will be saved. "/" - current folder');
INSERT INTO SMAN$_PARAMETER (PARAM_NAME, PARAM_VALUE, DESCRIPTION)
VALUES ('TABLE_CONSTRAINTS_SORT_ORDER','5','Sort order in which objects appear in a deploy file');
INSERT INTO SMAN$_PARAMETER (PARAM_NAME, PARAM_VALUE, DESCRIPTION)
VALUES ('TABLE_FILENAME','create_table_$name.sql','File name. Next variables can be used inside: $name - object name, $cmp - component name');
INSERT INTO SMAN$_PARAMETER (PARAM_NAME, PARAM_VALUE, DESCRIPTION)
VALUES ('TABLE_IN_ONE_FILE','F','If it is true, the create statement, indexes and constraints for a table will appear in a single file');
INSERT INTO SMAN$_PARAMETER (PARAM_NAME, PARAM_VALUE, DESCRIPTION)
VALUES ('TABLE_PATH','ddl','Folder name where files will be saved. "/" - current folder');
INSERT INTO SMAN$_PARAMETER (PARAM_NAME, PARAM_VALUE, DESCRIPTION)
VALUES ('TABLE_SORT_ORDER','1','Sort order in which objects appear in a deploy file');
INSERT INTO SMAN$_PARAMETER (PARAM_NAME, PARAM_VALUE, DESCRIPTION)
VALUES ('TRIGGER_FILENAME','$name.sql','File name. Next variables can be used inside: $name - object name, $cmp - component name');
INSERT INTO SMAN$_PARAMETER (PARAM_NAME, PARAM_VALUE, DESCRIPTION)
VALUES ('TRIGGER_PATH','sql','Folder name where files will be saved. "/" - current folder');
INSERT INTO SMAN$_PARAMETER (PARAM_NAME, PARAM_VALUE, DESCRIPTION)
VALUES ('TRIGGER_SORT_ORDER','3','Sort order in which objects appear in a deploy file');
INSERT INTO SMAN$_PARAMETER (PARAM_NAME, PARAM_VALUE, DESCRIPTION)
VALUES ('TYPE_BODY_FILENAME','$name_body.sql','File name. Next variables can be used inside: $name - object name, $cmp - component name');
INSERT INTO SMAN$_PARAMETER (PARAM_NAME, PARAM_VALUE, DESCRIPTION)
VALUES ('TYPE_BODY_PATH','sql','Folder name where files will be saved. "/" - current folder');
INSERT INTO SMAN$_PARAMETER (PARAM_NAME, PARAM_VALUE, DESCRIPTION)
VALUES ('TYPE_BODY_SORT_ORDER','10','Sort order in which objects appear in a deploy file');
INSERT INTO SMAN$_PARAMETER (PARAM_NAME, PARAM_VALUE, DESCRIPTION)
VALUES ('TYPE_FILENAME','$name_head.sql','File name. Next variables can be used inside: $name - object name, $cmp - component name');
INSERT INTO SMAN$_PARAMETER (PARAM_NAME, PARAM_VALUE, DESCRIPTION)
VALUES ('TYPE_PATH','sql','Folder name where files will be saved. "/" - current folder');
INSERT INTO SMAN$_PARAMETER (PARAM_NAME, PARAM_VALUE, DESCRIPTION)
VALUES ('TYPE_SORT_ORDER','9','Sort order in which objects appear in a deploy file');
INSERT INTO SMAN$_PARAMETER (PARAM_NAME, PARAM_VALUE, DESCRIPTION)
VALUES ('VIEW_FILENAME','$name.sql','File name. Next variables can be used inside: $name - object name, $cmp - component name');
INSERT INTO SMAN$_PARAMETER (PARAM_NAME, PARAM_VALUE, DESCRIPTION)
VALUES ('VIEW_PATH','sql','Folder name where files will be saved. "/" - current folder');
INSERT INTO SMAN$_PARAMETER (PARAM_NAME, PARAM_VALUE, DESCRIPTION)
VALUES ('VIEW_SORT_ORDER','7','Sort order in which objects appear in a deploy file');

COMMIT;
