spool spool.log
set pagesize 50000
set linesize 200

@create_table_sman$_parameter.sql
@create_table_sman$_component.sql
@create_table_sman$_tbs_remap.sql
@create_table_sman$_object_config.sql
@create_table_sman$_stored_objects.sql
@data_sman$_parameter.sql
@table_sman$_parameter.sql
@table_sman$_component.sql
@table_sman$_tbs_remap.sql
@table_sman$_object_config.sql
@table_sman$_stored_objects.sql
@pkg_sman$_head.sql
@pkg_sman$_body.sql

set echo on
--prompt Rebuilding schema ... 
exec dbms_utility.compile_schema(user);

column object_name format a30
column object_type format a30
select object_name,object_type
from user_objects
where status <> 'VALID';

column owner format a30
column object_name format a30
column object_type format a30
column status format a30
select t.owner, t.object_name, t.object_type, t.status
  from dba_objects t
 where t.owner = 'PUBLIC'
   and t.object_type = 'SYNONYM'
   and t.status <> 'VALID' order by 3,2;

prompt Press a key to finish 
prompt =======================
prompt Installation finished.
prompt =======================
pause
spool off
exit 0
