
PROMPT ===========================================
PROMPT Create package body PKG_SMAN$
PROMPT ===========================================

CREATE OR REPLACE package body pkg_sman$ is

  c_version varchar2(30) := '1.0.12';

  c_eol       constant varchar2(2) := chr(13) || chr(10);
  c_true      constant varchar2(1) := 'T';
  c_false     constant varchar2(1) := 'F';
  c_date_mask constant varchar2(30) := 'DD.MM.YYYY HH24:MI:SS';
  c_err_code  constant number := -20001;

  type tt_varchar2 is table of varchar2(4000);

  --Package errors
  c_err_cmp_not_found          constant number := 1;
  c_err_no_objects             constant number := 2;
  c_err_obj_not_found          constant number := 3;
  c_err_label_required         constant number := 4;
  c_err_label_not_unique       constant number := 5;
  c_err_obj_type_not_supported constant number := 6;
  c_err_param_not_found        constant number := 7;
  c_err_label_not_found        constant number := 8;
  c_err_invalid_data_type      constant number := 9;
  c_err_diff_labels            constant number := 10;
  c_err_labels_coincide        constant number := 11;
  c_err_obj_not_found2         constant number := 12;

  --Messages
  c_msg_cmp_not_found          constant varchar2(240) := 'Component :1 doesn''t exist';
  c_msg_no_objects             constant varchar2(240) := 'Component :1 doesn''t have any objects';
  c_msg_obj_not_found          constant varchar2(240) := 'Object doesn''t exist: :1, :2';
  c_msg_label_required         constant varchar2(240) := 'Label must be specified';
  c_msg_label_not_unique       constant varchar2(240) := 'Label must be unique';
  c_msg_obj_type_not_supported constant varchar2(240) := 'Object type :1 isn''t supported yet';
  c_msg_param_not_found        constant varchar2(240) := 'Parameter :1 hasn''t been found';
  c_msg_label_not_found        constant varchar2(240) := 'Label :1 doesn''t exist';
  c_msg_invalid_data_type      constant varchar2(240) := 'Data type :1 isn''t supported for saving DML';
  c_msg_diff_labels            constant varchar2(240) := 'Labels have to belong to one component';
  c_msg_labels_coincide        constant varchar2(240) := 'Labels must not coincide';
  c_msg_unknown_error          constant varchar2(240) := 'Unknown error';
  c_msg_no_components          constant varchar2(240) := 'There are no components';
  c_msg_no_labels              constant varchar2(240) := 'There are no labels';
  c_msg_no_cmp_data            constant varchar2(240) := 'There is no data about the component :1';
  c_msg_changed_table          constant varchar2(240) := '--Table :1 has been changed. Don''t forget to include alter table commands' ||
                                                         c_eol;
  c_msg_obj_not_found2         constant varchar2(240) := 'Object :1 doesn''t exist';

  --Object types
  c_obj_all_grants       constant varchar2(30) := 'ALL_GRANTS';
  c_obj_all_pub_synonyms constant varchar2(30) := 'ALL_PUBLIC_SYNONYMS';
  c_obj_comment          constant varchar2(30) := 'COMMENT';
  c_obj_constraint       constant varchar2(30) := 'CONSTRAINT';
  c_obj_db_link          constant varchar2(30) := 'DB_LINK';
  c_obj_deploy           constant varchar2(30) := 'DEPLOY';
  c_obj_dml              constant varchar2(30) := 'DML';
  c_obj_function         constant varchar2(30) := 'FUNCTION';
  c_obj_grant            constant varchar2(30) := 'GRANT';
  c_obj_index            constant varchar2(30) := 'INDEX';
  c_obj_mat_view         constant varchar2(30) := 'MATERIALIZED VIEW';
  c_obj_package          constant varchar2(30) := 'PACKAGE';
  c_obj_package_body     constant varchar2(30) := 'PACKAGE BODY';
  c_obj_procedure        constant varchar2(30) := 'PROCEDURE';
  c_obj_public_synonym   constant varchar2(30) := 'PUBLIC SYNONYM';
  c_obj_ref_constraint   constant varchar2(30) := 'REF_CONSTRAINT';
  c_obj_sequence         constant varchar2(30) := 'SEQUENCE';
  c_obj_synonym          constant varchar2(30) := 'SYNONYM';
  c_obj_table            constant varchar2(30) := 'TABLE';
  c_obj_table_constr     constant varchar2(30) := 'TABLE_CONSTRAINTS';
  c_obj_trigger          constant varchar2(30) := 'TRIGGER';
  c_obj_type             constant varchar2(30) := 'TYPE';
  c_obj_type_body        constant varchar2(30) := 'TYPE BODY';
  c_obj_view             constant varchar2(30) := 'VIEW';

  --ALL = every component to be processed
  c_cmp_all constant varchar2(3) := 'ALL';

  --All objects by label
  cursor gc_all_objects(p_label varchar2, p_with_sort in varchar2) is
    select o.object_type, o.object_name, o.object, o.cmp_cmp_id
      from (select t.object_type, t.object_name, t.object, t.cmp_cmp_id
              from sman$_stored_objects t
             where t.label = p_label
               and t.object is not null
            union all
            select get_obj_type_replaced(t.object_type),
                   t.object_name,
                   t.object_body,
                   t.cmp_cmp_id
              from sman$_stored_objects t
             where t.label = p_label
               and t.object_body is not null
            union all
            select c_obj_dml, t.object_name, t.object_dml, t.cmp_cmp_id
              from sman$_stored_objects t
             where t.label = p_label
               and t.object_dml is not null) o,
           sman$_object_config oc
     where o.cmp_cmp_id = oc.cmp_cmp_id(+)
       and o.object_name = oc.object_name(+)
     order by get_obj_sort_order(object_type, p_with_sort), oc.sort_order;

  function is_empty(p_value in clob) return boolean is
  begin
    if p_value is null or length(p_value) = 0 then
      return true;
    else
      return false;
    end if;
  end is_empty;

  function get_message(p_message in varchar2,
                       p_param1  in varchar2 := null,
                       p_param2  in varchar2 := null) return varchar2 is
  begin
    return replace(replace(p_message, ':1', nvl(p_param1, '<NULL>')), ':2',
                   nvl(p_param2, '<NULL>'));
  end get_message;

  procedure raise_error(p_error  in number,
                        p_param1 in varchar2 := null,
                        p_param2 in varchar2 := null) is
  begin
    case p_error
      when c_err_cmp_not_found then
        raise_application_error(c_err_code,
                                get_message(c_msg_cmp_not_found, p_param1));
      when c_err_no_objects then
        raise_application_error(c_err_code,
                                get_message(c_msg_no_objects, p_param1));
      when c_err_obj_not_found then
        raise_application_error(c_err_code,
                                get_message(c_msg_obj_not_found, p_param1,
                                             p_param2));
      when c_err_label_required then
        raise_application_error(c_err_code,
                                get_message(c_msg_label_required));
      when c_err_label_not_unique then
        raise_application_error(c_err_code,
                                get_message(c_msg_label_not_unique));
      when c_err_obj_type_not_supported then
        raise_application_error(c_err_code,
                                get_message(c_msg_obj_type_not_supported,
                                             p_param1));
      when c_err_param_not_found then
        raise_application_error(c_err_code,
                                get_message(c_msg_param_not_found, p_param1));
      when c_err_label_not_found then
        raise_application_error(c_err_code,
                                get_message(c_msg_label_not_found, p_param1));
      when c_err_invalid_data_type then
        raise_application_error(c_err_code,
                                get_message(c_msg_invalid_data_type,
                                             p_param1));
      when c_err_diff_labels then
        raise_application_error(c_err_code, get_message(c_msg_diff_labels));
      when c_err_labels_coincide then
        raise_application_error(c_err_code,
                                get_message(c_msg_labels_coincide));
      when c_err_obj_not_found2 then
        raise_application_error(c_err_code,
                                get_message(c_msg_obj_not_found2, p_param1));
      else
        raise_application_error(c_err_code,
                                get_message(c_msg_unknown_error));
    end case;
  end raise_error;

  function get_param(p_param_name in varchar2) return varchar2 is
    v_param_value varchar2(4000);
  begin
    select t.param_value
      into v_param_value
      from sman$_parameter t
     where t.param_name = p_param_name;
    return v_param_value;
  exception
    when no_data_found then
      raise_error(c_err_param_not_found, p_param_name);
  end get_param;

  procedure ins_sman$_stored_objects(p_row in sman$_stored_objects%rowtype) is
  begin
    insert into sman$_stored_objects values p_row;
  end ins_sman$_stored_objects;

  function get_prompt_string(p_object_name in varchar,
                             p_object_type in varchar2) return varchar2 is
    c_prompt varchar2(10) := 'PROMPT ';
    v_string varchar2(4000);
    v_result varchar2(4000);
  begin
    if get_param('ADD_PROMPT_STRING') = c_true then
      v_result := c_eol || rpad(c_prompt, 50, '=') || c_eol || c_prompt;
      if p_object_type in
         (c_obj_package, c_obj_package_body, c_obj_procedure, c_obj_function,
          c_obj_type, c_obj_type_body, c_obj_trigger, c_obj_view,
          c_obj_sequence, c_obj_table, c_obj_mat_view, c_obj_synonym,
          c_obj_db_link, c_obj_public_synonym) then
        v_string := 'Create ' || replace(lower(p_object_type), '_', null) || ' ' ||
                    p_object_name || c_eol;
      elsif p_object_type = c_obj_comment then
        v_string := 'Add comments on ' || p_object_name || c_eol;
      elsif p_object_type = c_obj_constraint then
        v_string := 'Add constraints on ' || p_object_name || c_eol;
      elsif p_object_type = c_obj_index then
        v_string := 'Create indexes on ' || p_object_name || c_eol;
      elsif p_object_type = c_obj_dml then
        v_string := 'Load data into ' || p_object_name || c_eol;
      elsif p_object_type = c_obj_grant then
        v_string := 'Grant privileges on ' || p_object_name || c_eol;
      end if;
      v_result := v_result || v_string;
      v_result := v_result || rpad(c_prompt, 50, '=') || c_eol || c_eol;
    end if;
    return v_result;
  end get_prompt_string;

  function get_obj_type_replaced(p_object_type in varchar2) return varchar2 is
  begin
    case p_object_type
      when c_obj_package then
        return c_obj_package_body;
      when c_obj_type then
        return c_obj_type_body;
      when c_obj_table then
        return c_obj_table_constr;
      else
        return p_object_type;
    end case;
  end get_obj_type_replaced;

  function get_obj_sort_order(p_object_type in varchar2,
                              p_with_sort   in varchar2) return number is
  begin
    if p_with_sort = c_true then
      return to_number(get_param(replace(p_object_type, ' ', '_') ||
                                 '_SORT_ORDER'));
    else
      return 0;
    end if;
  end get_obj_sort_order;

  function get_schema_name_removed(p_object clob) return clob is
    v_schema varchar2(240);
  begin
    v_schema := chr(34) || user || chr(34) || '.';
    return replace(p_object, v_schema);
  end get_schema_name_removed;

  function get_by_dbms_metadata(p_object_type in varchar2,
                                p_object_name in varchar2,
                                p_object_ddl  in varchar2) return clob is
    v_buffer clob;
    v_result clob;
    v_handle number;
    procedure init_dbms_metadata is
      v_modify_handle number;
      v_ddl_handle    number;
    begin
      v_modify_handle := dbms_metadata.add_transform(v_handle, 'MODIFY');
      v_ddl_handle    := dbms_metadata.add_transform(v_handle, 'DDL');
      dbms_metadata.set_transform_param(v_ddl_handle, 'SQLTERMINATOR', true);
      if p_object_type = c_obj_table then
        dbms_metadata.set_transform_param(v_ddl_handle, 'CONSTRAINTS',
                                          false);
        dbms_metadata.set_transform_param(v_ddl_handle, 'REF_CONSTRAINTS',
                                          false);
      end if;
      if p_object_type in (c_obj_table, c_obj_index, c_obj_constraint) then
        dbms_metadata.set_transform_param(v_ddl_handle, 'STORAGE', false);
        for v_tbs_remap in (select * from sman$_tbs_remap) loop
          dbms_metadata.set_remap_param(v_modify_handle, 'REMAP_TABLESPACE',
                                        v_tbs_remap.tablespace_name,
                                        v_tbs_remap.remap_tablespace_name);
        end loop;
      end if;
    end init_dbms_metadata;
  begin
    dbms_lob.createtemporary(v_result, true);
    v_handle := dbms_metadata.open(p_object_type);
    if p_object_ddl = 'DDL' then
      dbms_metadata.set_filter(v_handle, 'NAME', p_object_name);
    elsif p_object_ddl = 'DEPENDENT_DDL' then
      dbms_metadata.set_filter(v_handle, 'BASE_OBJECT_NAME', p_object_name);
    end if;
    init_dbms_metadata;
    loop
      v_buffer := dbms_metadata.fetch_clob(v_handle);
      if v_buffer is null then
        exit;
      else
        dbms_lob.append(v_result, v_buffer);
      end if;
    end loop;
    return v_result;
  end get_by_dbms_metadata;

  function get_by_dbms_metadata(p_object_type in varchar2,
                                p_object_name in varchar2) return clob is
    v_result clob;
  begin
    dbms_lob.createtemporary(v_result, true);
    dbms_metadata.set_transform_param(dbms_metadata.session_transform,
                                      'SQLTERMINATOR', true);
    v_result := dbms_metadata.get_ddl(p_object_type, p_object_name);
    return v_result;
  end get_by_dbms_metadata;

  function get_by_dbms_metadata_dep(p_object_type in varchar2,
                                    p_object_name in varchar2) return clob is
    v_result clob;
  begin
    dbms_lob.createtemporary(v_result, true);
    dbms_metadata.set_transform_param(dbms_metadata.session_transform,
                                      'SQLTERMINATOR', true);
    v_result := dbms_metadata.get_dependent_ddl(p_object_type, p_object_name);
    return v_result;
  exception
    when dbms_metadata.object_not_found2 then
      return v_result;
  end get_by_dbms_metadata_dep;

  procedure check_component(p_component in varchar2) is
    v_cnt number;
  begin
    select count(1)
      into v_cnt
      from sman$_component t
     where t.cmp_id = p_component;
    if v_cnt = 0 then
      raise_error(c_err_cmp_not_found, p_component);
    end if;
  end check_component;

  function long2clob(p_source   in varchar2,
                     p_long_col in varchar2,
                     p_cols     in tt_varchar2,
                     p_vals     in tt_varchar2) return clob is
    v_csr   binary_integer;
    v_sql   varchar2(32767) := 'select %l% from %v% where 1=1 ';
    v_pred  varchar2(32767) := ' and %c% = :bv%n%';
    v_piece varchar2(32767);
    v_clob  clob;
    v_plen  integer := 32767;
    v_tlen  integer := 0;
    v_rows  integer;
  begin
    v_sql := replace(replace(v_sql, '%l%', p_long_col), '%v%', p_source);
    for i in 1 .. p_cols.count loop
      v_sql := v_sql ||
               replace(replace(v_pred, '%c%', p_cols(i)), '%n%', to_char(i));
    end loop;
    v_csr := dbms_sql.open_cursor;
    dbms_sql.parse(v_csr, v_sql, dbms_sql.native);
    for i in 1 .. p_vals.count loop
      dbms_sql.bind_variable(v_csr, ':bv' || i, p_vals(i));
    end loop;
    dbms_sql.define_column_long(v_csr, 1);
    v_rows := dbms_sql.execute_and_fetch(v_csr);
    if v_rows > 0 then
      loop
        dbms_sql.column_value_long(v_csr, 1, 32767, v_tlen, v_piece, v_plen);
        v_clob := v_clob || v_piece;
        v_tlen := v_tlen + 32767;
        exit when v_plen < 32767;
      end loop;
    end if;
    dbms_sql.close_cursor(v_csr);
    return v_clob;
  end long2clob;

  function get_view(p_object_name in varchar2) return clob is
    v_string varchar2(32767);
    v_text   clob;
    v_object clob;
    procedure fix_chr13_chr10_problem(p_text in out nocopy clob) is
    begin
      p_text := replace(p_text, chr(10), c_eol);
      p_text := replace(p_text, chr(13) || chr(13), chr(13));
    end fix_chr13_chr10_problem;
  begin
    v_text := long2clob('USER_VIEWS', 'TEXT', tt_varchar2('VIEW_NAME'),
                        tt_varchar2(p_object_name));
    fix_chr13_chr10_problem(v_text);
    dbms_lob.createtemporary(v_object, true);
    v_string := get_prompt_string(p_object_name, c_obj_view) ||
                'CREATE OR REPLACE';
    if get_param('FORCE_VIEW') = c_true then
      v_string := v_string || ' FORCE';
    end if;
    v_string := v_string || ' VIEW ' || p_object_name || ' AS' || c_eol;
    dbms_lob.writeappend(v_object, length(v_string), v_string);
    dbms_lob.append(v_object, v_text);
    return v_object;
  end get_view;

  function get_object_by_user_source(p_object_type in varchar2,
                                     p_object_name in varchar2) return clob is
    v_string varchar2(32767);
    v_object clob;
  begin
    for i in (select t.text, t.line
                from user_source t
               where t.type = p_object_type
                 and t.name = p_object_name
               order by t.line) loop
      if v_object is null then
        dbms_lob.createtemporary(v_object, true);
        v_string := get_prompt_string(p_object_name, p_object_type) ||
                    'CREATE OR REPLACE ';
        dbms_lob.writeappend(v_object, length(v_string), v_string);
      end if;
      v_string := rtrim(rtrim(i.text, chr(10)), chr(13)) || c_eol;
      if i.line = 1 then
        v_string := replace(v_string, '"');
      end if;
      dbms_lob.writeappend(v_object, length(v_string), v_string);
    end loop;
    return v_object;
  end get_object_by_user_source;

  function get_sequence(p_object_name in varchar2) return clob is
    v_sequence user_sequences%rowtype;
    v_string   varchar2(32767);
  begin
    v_string := get_prompt_string(p_object_name, c_obj_sequence);
    select t.*
      into v_sequence
      from user_sequences t
     where t.sequence_name = p_object_name;
    v_string := v_string || 'CREATE SEQUENCE ' || v_sequence.sequence_name ||
                ' MINVALUE ' || v_sequence.min_value || ' MAXVALUE ' ||
                v_sequence.max_value;
    v_string := v_string || ' INCREMENT BY ' || v_sequence.increment_by;
    if v_sequence.cache_size = 0 then
      v_string := v_string || ' NOCACHE';
    else
      v_string := v_string || ' CACHE ' || v_sequence.cache_size;
    end if;
    v_string := v_string || ';' || c_eol;
    return v_string;
  end get_sequence;

  function get_mat_view(p_object_name in varchar2) return clob is
    v_prompt   varchar2(240);
    v_comments clob;
    v_result   clob;
  begin
    dbms_lob.createtemporary(v_result, true);
    v_prompt := get_prompt_string(p_object_name, c_obj_mat_view);
    dbms_lob.writeappend(v_result, length(v_prompt), v_prompt);
    dbms_lob.append(v_result,
                    get_by_dbms_metadata(replace(c_obj_mat_view, ' ', '_'),
                                          p_object_name, 'DDL'));
    v_comments := get_by_dbms_metadata(c_obj_comment, p_object_name,
                                       'DEPENDENT_DDL');
    if not is_empty(v_comments) then
      v_prompt := get_prompt_string(p_object_name, c_obj_comment);
      dbms_lob.writeappend(v_result, length(v_prompt), v_prompt);
      dbms_lob.append(v_result, v_comments);
    end if;
    return get_schema_name_removed(v_result);
  end get_mat_view;

  function get_table(p_object_name in varchar2) return clob is
    v_prompt   varchar2(240);
    v_comments clob;
    v_result   clob;
  begin
    dbms_lob.createtemporary(v_result, true);
    v_prompt := get_prompt_string(p_object_name, c_obj_table);
    dbms_lob.writeappend(v_result, length(v_prompt), v_prompt);
    dbms_lob.append(v_result,
                    get_by_dbms_metadata(c_obj_table, p_object_name, 'DDL'));
    v_comments := get_by_dbms_metadata(c_obj_comment, p_object_name,
                                       'DEPENDENT_DDL');
    if not is_empty(v_comments) then
      v_prompt := get_prompt_string(p_object_name, c_obj_comment);
      dbms_lob.writeappend(v_result, length(v_prompt), v_prompt);
      dbms_lob.append(v_result, v_comments);
    end if;
    return get_schema_name_removed(v_result);
  end get_table;

  function get_table_constraints(p_object_name in varchar2) return clob is
    v_buffer clob;
    v_prompt varchar2(240);
    v_result clob;
  begin
    dbms_lob.createtemporary(v_buffer, true);
    dbms_lob.createtemporary(v_result, true);
    for v_index in (select t.index_name
                      from user_indexes t
                     where t.table_name = p_object_name
                       and t.index_type not in
                           ('LOB', 'IOT - TOP', 'IOT - NESTED')) loop
      dbms_lob.append(v_buffer,
                      get_by_dbms_metadata(c_obj_index, v_index.index_name,
                                            'DDL'));
    end loop;
    if not is_empty(v_buffer) then
      v_prompt := get_prompt_string(p_object_name, c_obj_index);
      dbms_lob.writeappend(v_result, length(v_prompt), v_prompt);
      dbms_lob.append(v_result, v_buffer);
    end if;
    dbms_lob.createtemporary(v_buffer, true);
    dbms_lob.append(v_buffer,
                    get_by_dbms_metadata(c_obj_constraint, p_object_name,
                                          'DEPENDENT_DDL'));
    dbms_lob.append(v_buffer,
                    get_by_dbms_metadata(c_obj_ref_constraint, p_object_name,
                                          'DEPENDENT_DDL'));
    if not is_empty(v_buffer) then
      v_prompt := get_prompt_string(p_object_name, c_obj_constraint);
      dbms_lob.writeappend(v_result, length(v_prompt), v_prompt);
      dbms_lob.append(v_result, v_buffer);
    end if;
    v_result := get_schema_name_removed(v_result);
    if not is_empty(v_result) then
      return v_result;
    else
      return null;
    end if;
  end get_table_constraints;

  function get_dml(p_object_name in varchar2) return clob is
    v_insert_column_list varchar2(32767);
    v_select_column_list varchar2(32767);
    v_string             varchar2(32767);
    v_column_name        varchar2(2000);
    v_sql                varchar2(32767);
    v_ref_cursor         sys_refcursor;
    v_prompt             varchar2(240);
    v_object             clob;
    function get_order_by_clause(p_object_name in varchar2) return varchar2 is
      v_string varchar2(32767);
    begin
      for v_pk_columns in (select cc.column_name,
                                  count(1) over() all_cnt,
                                  row_number() over(order by cc.position) row_num
                             from user_constraints c, user_cons_columns cc
                            where c.constraint_type = 'P'
                              and c.constraint_name = cc.constraint_name
                              and c.table_name = p_object_name
                            order by cc.position) loop
        if v_string is null then
          v_string := ' ORDER BY ';
        end if;
        v_string := v_string || v_pk_columns.column_name;
        if v_pk_columns.all_cnt != v_pk_columns.row_num then
          v_string := v_string || ', ';
        end if;
      end loop;
      return v_string;
    end get_order_by_clause;
    function get_prepared_insert_query(p_insert_column_list in varchar2,
                                       p_string             in varchar2)
      return varchar2 is
      v_result varchar2(32767) := p_string;
    begin
      v_result := '(' || v_result || ');';
      while (instr(v_result, ',,') > 0) loop
        v_result := replace(v_result, ',,', ',null,');
      end loop;
      v_result := replace(v_result, '(,', '(null,');
      v_result := replace(v_result, ',,)', ',null,null)');
      v_result := replace(v_result, ',)', ',null)');
      v_result := replace(v_result, 'null,)', 'null,null)');
      v_result := replace(v_result, chr(13), ''' || chr(13) || ''');
      v_result := replace(v_result, chr(10), ''' || chr(10) || ''');
      v_result := replace(v_result, chr(38), ''' || chr(38) || ''');
      v_result := replace(v_result, ' || '''' ', ' ');
      v_result := replace(v_result, ''''' ||');
      v_result := 'INSERT INTO ' || p_object_name || ' ' ||
                  p_insert_column_list || c_eol || 'VALUES ' || v_result ||
                  c_eol;
      return v_result;
    end get_prepared_insert_query;
  begin
    dbms_lob.createtemporary(v_object, true);
    v_prompt := get_prompt_string(p_object_name, c_obj_dml);
    dbms_lob.writeappend(v_object, length(v_prompt), v_prompt);
    if get_param('DELETE_BEFORE_INSERT') = c_true then
      v_string := 'DELETE ' || p_object_name || ';' || c_eol || c_eol;
      dbms_lob.writeappend(v_object, length(v_string), v_string);
    end if;
    for v_columns in (select t.column_name,
                             t.data_type,
                             count(1) over() all_cnt,
                             row_number() over(order by t.column_id) row_num
                        from user_tab_columns t
                       where t.table_name = p_object_name
                       order by t.column_id) loop
      v_insert_column_list := v_insert_column_list || v_columns.column_name;
      if v_columns.data_type = 'NUMBER' then
        v_column_name := v_columns.column_name;
      elsif (v_columns.data_type = 'DATE' or
            v_columns.data_type like 'TIMESTAMP%') then
        --for TIMESTAMP - it's a workaround, because we treat timestamp as date
        --and, consequently, lose fractional seconds
        v_column_name := chr(39) || 'to_date(' || chr(39) || '||chr(39)' ||
                         '||to_char(' || v_columns.column_name || ',' ||
                         chr(39) || c_date_mask || chr(39) ||
                         ')||chr(39)||' || chr(39) || ', ' || chr(39) ||
                         '||chr(39)||' || chr(39) || c_date_mask || chr(39) ||
                         '||chr(39)||' || chr(39) || ')' || chr(39);
      elsif v_columns.data_type = 'VARCHAR2' then
        v_column_name := 'chr(39) || REPLACE(' || v_columns.column_name ||
                         ', chr(39), chr(39) || chr(39)) || chr(39)';
      else
        raise_error(c_err_invalid_data_type, v_columns.data_type);
      end if;
      v_select_column_list := v_select_column_list || v_column_name;
      if v_columns.all_cnt != v_columns.row_num then
        v_insert_column_list := v_insert_column_list || ', ';
        v_select_column_list := v_select_column_list || '||' || chr(39) || ',' ||
                                chr(39) || '||';
      end if;
    end loop;
    v_insert_column_list := '(' || v_insert_column_list || ')';
    v_sql                := 'SELECT ' || v_select_column_list || ' FROM ' ||
                            p_object_name ||
                            get_order_by_clause(p_object_name);
    dbms_output.put_line(v_sql);
    open v_ref_cursor for v_sql;
    loop
      fetch v_ref_cursor
        into v_string;
      exit when v_ref_cursor%notfound;
      v_string := get_prepared_insert_query(v_insert_column_list, v_string);
      dbms_lob.writeappend(v_object, length(v_string), v_string);
    end loop;
    if is_empty(v_object) then
      return null;
    else
      v_string := c_eol || 'COMMIT;' || c_eol;
      dbms_lob.writeappend(v_object, length(v_string), v_string);
      return v_object;
    end if;
  end get_dml;

  function get_synonym(p_object_name in varchar2) return clob is
    v_prompt varchar2(240);
    v_result clob;
  begin
    dbms_lob.createtemporary(v_result, true);
    v_prompt := get_prompt_string(p_object_name, c_obj_synonym);
    dbms_lob.writeappend(v_result, length(v_prompt), v_prompt);
    dbms_lob.append(v_result,
                    get_by_dbms_metadata(c_obj_synonym, p_object_name));
    return get_schema_name_removed(v_result);
  end get_synonym;

  function get_db_link(p_object_name in varchar2) return clob is
    v_prompt varchar2(240);
    v_result clob;
  begin
    dbms_lob.createtemporary(v_result, true);
    v_prompt := get_prompt_string(p_object_name, c_obj_db_link);
    dbms_lob.writeappend(v_result, length(v_prompt), v_prompt);
    dbms_lob.append(v_result,
                    get_by_dbms_metadata(c_obj_db_link, p_object_name));
    return get_schema_name_removed(v_result);
  end get_db_link;

  function get_object(p_object_type in varchar2, p_object_name in varchar2)
    return clob is
  begin
    if p_object_type in
       (c_obj_package, c_obj_package_body, c_obj_procedure, c_obj_function,
        c_obj_type, c_obj_type_body, c_obj_trigger) then
      return get_object_by_user_source(p_object_type, p_object_name);
    elsif p_object_type = c_obj_view then
      return get_view(p_object_name);
    elsif p_object_type = c_obj_sequence then
      return get_sequence(p_object_name);
    elsif p_object_type = c_obj_table then
      return get_table(p_object_name);
    elsif p_object_type = c_obj_table_constr then
      return get_table_constraints(p_object_name);
    elsif p_object_type = c_obj_mat_view then
      return get_mat_view(p_object_name);
    elsif p_object_type = c_obj_dml then
      return get_dml(p_object_name);
    elsif p_object_type = c_obj_synonym then
      return get_synonym(p_object_name);
    elsif p_object_type = c_obj_db_link then
      return get_db_link(p_object_name);
    else
      raise_error(c_err_obj_type_not_supported, p_object_type);
    end if;
  end get_object;

  procedure store_object(p_component    in varchar2,
                         p_label        in varchar2,
                         p_object_type  in varchar2,
                         p_object_name  in varchar2,
                         p_generate_dml in varchar2,
                         p_store_date   in date) is
    v_row sman$_stored_objects%rowtype;
  begin
    v_row.object := get_object(p_object_type, p_object_name);
    if p_object_type in (c_obj_package, c_obj_type, c_obj_table) then
      v_row.object_body := get_object(get_obj_type_replaced(p_object_type),
                                      p_object_name);
    end if;
    if p_object_type = c_obj_table and v_row.object_body is not null and
       get_param('TABLE_IN_ONE_FILE') = c_true then
      dbms_lob.append(v_row.object, v_row.object_body);
      v_row.object_body := null;
    end if;
    if p_generate_dml = c_true then
      v_row.object_dml := get_object(c_obj_dml, p_object_name);
    end if;
    v_row.cmp_cmp_id  := p_component;
    v_row.object_type := p_object_type;
    v_row.object_name := p_object_name;
    v_row.store_date  := p_store_date;
    v_row.label       := p_label;
    ins_sman$_stored_objects(v_row);
  end store_object;

  procedure store_object(p_component   in varchar2,
                         p_label       in varchar2,
                         p_object_type in varchar2,
                         p_data        in clob,
                         p_store_date  in date) is
    v_row sman$_stored_objects%rowtype;
  begin
    if not is_empty(p_data) then
      v_row.object      := p_data;
      v_row.cmp_cmp_id  := p_component;
      v_row.object_type := p_object_type;
      v_row.object_name := p_object_type;
      v_row.store_date  := p_store_date;
      v_row.label       := p_label;
      ins_sman$_stored_objects(v_row);
    end if;
  end store_object;

  function get_object_path(p_object_type in varchar2) return varchar2 is
    v_result varchar2(4000);
  begin
    v_result := get_param(replace(p_object_type, ' ', '_') || '_PATH');
    if substr(v_result, length(v_result)) != '/' then
      v_result := v_result || '/';
    end if;
    return v_result;
  end get_object_path;

  function get_object_file_name(p_object_type in varchar2,
                                p_object_name in varchar2,
                                p_component   in varchar2) return varchar2 is
    v_result varchar2(4000);
  begin
    v_result := get_param(replace(p_object_type, ' ', '_') || '_FILENAME');
    if p_object_name not in (c_obj_all_grants, c_obj_all_pub_synonyms) then
      v_result := replace(v_result, '$name', lower(p_object_name));
    end if;
    if p_object_name != c_obj_deploy then
      v_result := replace(v_result, '$cmp', lower(p_component));
    end if;
    return v_result;
  end get_object_file_name;

  function get_object_data(p_object_type in varchar2,
                           p_object_data in clob) return clob is
    v_object_data   clob;
    v_end_of_script varchar2(4000);
  begin
    if p_object_type in
       (c_obj_function, c_obj_package, c_obj_package_body, c_obj_procedure,
        c_obj_trigger, c_obj_type, c_obj_type_body, c_obj_view) then
      dbms_lob.createtemporary(v_object_data, true);
      dbms_lob.append(v_object_data, p_object_data);
      v_end_of_script := get_param('END_OF_SCRIPT');
      dbms_lob.writeappend(v_object_data, length(v_end_of_script),
                           v_end_of_script);
      return v_object_data;
    else
      return p_object_data;
    end if;
  end get_object_data;

  function get_drop_sql(p_object_type in varchar2,
                        p_object_name in varchar2) return varchar2 is
    v_sql varchar2(32767);
  begin
    v_sql := 'DROP ' || p_object_type || ' ' || p_object_name;
    if p_object_type = c_obj_type then
      v_sql := v_sql || ' FORCE';
    elsif p_object_type = c_obj_table then
      v_sql := v_sql || ' CASCADE CONSTRAINTS';
    end if;
    v_sql := v_sql || ';';
    return v_sql;
  end get_drop_sql;

  procedure get_grants(p_data        in out nocopy clob,
                       p_object_name in varchar2) is
    v_prompt varchar2(240);
    v_sql    clob;
  begin
    if p_data is null then
      dbms_lob.createtemporary(p_data, true);
    end if;
    v_sql := get_schema_name_removed(get_by_dbms_metadata_dep('OBJECT_GRANT',
                                                              p_object_name));
    if not is_empty(v_sql) then
      v_prompt := get_prompt_string(p_object_name, c_obj_grant);
      dbms_lob.writeappend(p_data, length(v_prompt), v_prompt);
      dbms_lob.append(p_data, v_sql);
    end if;
  end get_grants;

  procedure get_public_synonyms(p_data        in out nocopy clob,
                                p_object_name in varchar2) is
    v_prompt varchar2(240);
    v_string varchar2(32767);
  begin
    if p_data is null then
      dbms_lob.createtemporary(p_data, true);
    end if;
    v_prompt := get_prompt_string(p_object_name, c_obj_public_synonym);
    dbms_lob.writeappend(p_data, length(v_prompt), v_prompt);
    v_string := 'CREATE OR REPLACE PUBLIC SYNONYM ' || p_object_name ||
                ' FOR ' || user || '.' || p_object_name || ';' || c_eol;
    dbms_lob.writeappend(p_data, length(v_string), v_string);
  end get_public_synonyms;

  procedure create_deploy_file(p_label       in varchar2,
                               p_deploy_name in varchar2,
                               p_additional  in clob := null) is
    v_row    sman$_stored_objects%rowtype;
    v_string varchar2(32767);
    pragma autonomous_transaction;
  begin
    --delete the previous deploy file
    delete sman$_stored_objects t
     where t.label = p_label
       and t.object_type = c_obj_deploy;
    --create a new deploy file
    dbms_lob.createtemporary(v_row.object, true);
    v_string := get_param('DEPLOY_HEAD') || c_eol || c_eol;
    dbms_lob.writeappend(v_row.object, length(v_string), v_string);
    for i in gc_all_objects(p_label, c_true) loop
      v_string := get_param('DEPLOY_EXEC_FILE_STRING') ||
                  get_object_path(i.object_type) ||
                  get_object_file_name(i.object_type, i.object_name,
                                       i.cmp_cmp_id) || c_eol;
      dbms_lob.writeappend(v_row.object, length(v_string), v_string);
    end loop;
    if p_additional is not null then
      v_string := c_eol;
      dbms_lob.writeappend(v_row.object, length(v_string), v_string);
      dbms_lob.append(v_row.object, p_additional);
      dbms_lob.writeappend(v_row.object, length(v_string), v_string);
    end if;
    v_string := c_eol || get_param('DEPLOY_TAIL') || c_eol;
    dbms_lob.writeappend(v_row.object, length(v_string), v_string);
    --save it
    select distinct t.cmp_cmp_id
      into v_row.cmp_cmp_id
      from sman$_stored_objects t
     where t.label = p_label;
    v_row.object_type := c_obj_deploy;
    v_row.object_name := p_deploy_name;
    v_row.store_date  := sysdate;
    v_row.label       := p_label;
    ins_sman$_stored_objects(v_row);
    commit;
  end create_deploy_file;

  procedure save_difference(p_from_label in varchar2,
                            p_to_label   in varchar2,
                            p_new_label  in varchar2,
                            p_additional out clob) is
    v_row               sman$_stored_objects%rowtype;
    v_store             boolean := false;
    v_string            varchar2(32767);
    v_add_table_warning varchar2(32767);
    cursor vc_diff(p_from varchar2, p_to varchar2) is
      select s_from.object_type s_from_object_type,
             s_from.object_name s_from_object_name,
             s_from.object_body s_from_object_body,
             s_from.object_dml  s_from_object_dml,
             s_from.object      s_from_object,
             s_to.object_type   s_to_object_type,
             s_to.object_name   s_to_object_name,
             s_to.object_body   s_to_object_body,
             s_to.object_dml    s_to_object_dml,
             s_to.object        s_to_object
        from (select *
                from sman$_stored_objects
               where label = p_from
                 and object_type != c_obj_deploy) s_from
        full outer join (select *
                           from sman$_stored_objects
                          where label = p_to
                            and object_type != c_obj_deploy) s_to
          on (s_from.object_type = s_to.object_type and
             s_from.object_name = s_to.object_name);
    pragma autonomous_transaction;
  begin
    select distinct t.cmp_cmp_id
      into v_row.cmp_cmp_id
      from sman$_stored_objects t
     where t.label = p_from_label;
    v_row.label      := p_new_label;
    v_row.store_date := sysdate;
    for i in vc_diff(p_from_label, p_to_label) loop
      if i.s_from_object_name is null then
        --new object - adding
        v_row.object      := i.s_to_object;
        v_row.object_body := i.s_to_object_body;
        v_row.object_dml  := i.s_to_object_dml;
        v_store           := true;
      elsif i.s_to_object_name is null then
        --removed object - deleting
        if p_additional is null then
          dbms_lob.createtemporary(p_additional, true);
        end if;
        v_string := '--' ||
                    get_drop_sql(i.s_from_object_type, i.s_from_object_name) ||
                    c_eol;
        dbms_lob.writeappend(p_additional, length(v_string), v_string);
      else
        --finding the difference
        v_row.object      := null;
        v_row.object_body := null;
        v_row.object_dml  := null;
        if i.s_from_object != i.s_to_object then
          v_row.object := i.s_to_object;
          v_store      := true;
        end if;
        if i.s_from_object_body != i.s_to_object_body then
          v_row.object_body := i.s_to_object_body;
          v_store           := true;
        end if;
        if i.s_from_object_dml != i.s_to_object_dml then
          v_row.object_dml := i.s_to_object_dml;
          v_store          := true;
        end if;
        if i.s_to_object_type = c_obj_table and v_store then
          v_add_table_warning := v_add_table_warning ||
                                 get_message(c_msg_changed_table,
                                             i.s_to_object_name);
        end if;
      end if;
      if v_store then
        v_row.object_type := i.s_to_object_type;
        v_row.object_name := i.s_to_object_name;
        ins_sman$_stored_objects(v_row);
        v_store := false;
      end if;
    end loop;
    if v_add_table_warning is not null then
      if p_additional is null then
        dbms_lob.createtemporary(p_additional, true);
      end if;
      dbms_lob.writeappend(p_additional, length(v_add_table_warning),
                           v_add_table_warning);
    end if;
    commit;
  end save_difference;

  procedure save_(p_component   in varchar2,
                  p_label       in varchar2,
                  p_object_name in varchar2 := null) is
    v_grants          clob;
    v_public_synonyms clob;
    v_store_date      date := sysdate;
  begin
    for i in (select c.object_type,
                     c.object_name,
                     c.generate_dml,
                     c.create_public_synonym,
                     c.generate_grants,
                     o.object_name dict_object_name
                from sman$_object_config c, user_objects o
               where c.cmp_cmp_id = p_component
                 and c.object_type = o.object_type(+)
                 and c.object_name = o.object_name(+)
                 and c.object_name = nvl(p_object_name, c.object_name)) loop
      if i.dict_object_name is null then
        raise_error(c_err_obj_not_found, i.object_type, i.object_name);
      end if;
      store_object(p_component, p_label, i.object_type, i.object_name,
                   i.generate_dml, v_store_date);
      if i.create_public_synonym = c_true then
        get_public_synonyms(v_public_synonyms, i.object_name);
      end if;
      if i.generate_grants = c_true then
        get_grants(v_grants, i.object_name);
      end if;
    end loop;
    store_object(p_component, p_label, c_obj_all_pub_synonyms,
                 v_public_synonyms, v_store_date);
    store_object(p_component, p_label, c_obj_all_grants, v_grants,
                 v_store_date);
  end save_;

  procedure merge_objects(p_object_type in varchar2, p_label in varchar2) is
    v_object clob;
  begin
    --We're merging only object column because
    --there's no need to merge object_body or object_dml columns
    for i in (select t.object
                from sman$_stored_objects t
               where t.object_type = p_object_type
                 and t.label = p_label
                 and t.object is not null) loop
      if v_object is null then
        dbms_lob.createtemporary(v_object, true);
      end if;
      dbms_lob.append(v_object, i.object);
    end loop;
    if v_object is not null then
      delete sman$_stored_objects
       where label = p_label
         and object_type = p_object_type;
      store_object(null, p_label, p_object_type, v_object, sysdate);
    end if;
  end merge_objects;

  procedure save_objects(p_component in varchar2, p_label in varchar2) is
    v_cnt number;
  begin
    --Checks
    if p_component != c_cmp_all then
      check_component(p_component);
      select count(1)
        into v_cnt
        from sman$_object_config t
       where t.cmp_cmp_id = p_component
         and rownum <= 1;
    else
      select count(1)
        into v_cnt
        from sman$_object_config t
       where rownum <= 1;
    end if;
    if v_cnt = 0 then
      raise_error(c_err_no_objects, p_component);
    end if;
    if p_label is null then
      raise_error(c_err_label_required);
    else
      select count(1)
        into v_cnt
        from sman$_stored_objects t
       where t.label = p_label
         and rownum <= 1;
      if v_cnt != 0 then
        raise_error(c_err_label_not_unique);
      end if;
    end if;
    --Getting and storing objects
    if p_component = c_cmp_all then
      for i in (select c.cmp_id from sman$_component c) loop
        save_(i.cmp_id, p_label);
      end loop;
      merge_objects(c_obj_all_grants, p_label);
      merge_objects(c_obj_all_pub_synonyms, p_label);
    else
      save_(p_component, p_label);
    end if;
    commit;
  end save_objects;

  procedure save_single_object(p_component   in varchar2,
                               p_label       in varchar2,
                               p_object_name in varchar2) is
    v_cnt         number;
    v_object_name varchar2(30) := upper(p_object_name);
  begin
    --Checks
    check_component(p_component);
    select count(1)
      into v_cnt
      from sman$_object_config t
     where t.cmp_cmp_id = p_component
       and rownum <= 1;
    if v_cnt = 0 then
      raise_error(c_err_no_objects, p_component);
    end if;
    if p_label is null then
      raise_error(c_err_label_required);
    else
      select count(1)
        into v_cnt
        from sman$_stored_objects t
       where t.label = p_label
         and rownum <= 1;
      if v_cnt != 0 then
        raise_error(c_err_label_not_unique);
      end if;
    end if;
    if v_object_name is not null then
      select count(1)
        into v_cnt
        from sman$_object_config t
       where t.cmp_cmp_id = p_component
         and t.object_name = v_object_name;
      if v_cnt = 0 then
        raise_error(c_err_obj_not_found2, p_object_name);
      end if;
    end if;
    save_(p_component, p_label, v_object_name);
  end save_single_object;

  function get_objects(p_label in varchar2) return tt_object
    pipelined is
    v_cnt    number;
    v_object to_object;
  begin
    --Checks
    select count(1)
      into v_cnt
      from sman$_stored_objects t
     where t.label = p_label;
    if v_cnt = 0 then
      raise_error(c_err_label_not_found, p_label);
    end if;
    --Getting stored objects
    for i in gc_all_objects(p_label, c_false) loop
      v_object.path      := get_object_path(i.object_type);
      v_object.file_name := get_object_file_name(i.object_type,
                                                 i.object_name, i.cmp_cmp_id);
      v_object.data      := get_object_data(i.object_type, i.object);
      pipe row(v_object);
    end loop;
    return;
  end get_objects;

  function get_full_deploy(p_label in varchar2, p_deploy_name in varchar2)
    return tt_object
    pipelined is
    v_cnt number;
  begin
    --Checks
    select count(1)
      into v_cnt
      from sman$_stored_objects t
     where t.label = p_label;
    if v_cnt = 0 then
      raise_error(c_err_label_not_found, p_label);
    end if;
    --Creating deploy
    create_deploy_file(p_label, p_deploy_name);
    for i in (select * from table(get_objects(p_label))) loop
      pipe row(i);
    end loop;
    return;
  end get_full_deploy;

  function get_diff_deploy(p_from_label  in varchar2,
                           p_to_label    in varchar2,
                           p_new_label   in varchar2,
                           p_deploy_name in varchar2) return tt_object
    pipelined is
    v_cnt        number;
    v_cmp1       varchar2(30);
    v_cmp2       varchar2(30);
    v_additional clob;
  begin
    --Checks
    select count(1)
      into v_cnt
      from sman$_stored_objects t
     where t.label = p_from_label;
    if v_cnt = 0 then
      raise_error(c_err_label_not_found, p_from_label);
    end if;
    select count(1)
      into v_cnt
      from sman$_stored_objects t
     where t.label = p_to_label;
    if v_cnt = 0 then
      raise_error(c_err_label_not_found, p_to_label);
    end if;
    if p_from_label = p_to_label then
      raise_error(c_err_labels_coincide);
    end if;
    if p_new_label is null then
      raise_error(c_err_label_required);
    else
      select count(1)
        into v_cnt
        from sman$_stored_objects t
       where t.label = p_new_label;
      if v_cnt != 0 then
        raise_error(c_err_label_not_unique);
      end if;
    end if;
    select distinct t.cmp_cmp_id
      into v_cmp1
      from sman$_stored_objects t
     where t.label = p_from_label;
    select distinct t.cmp_cmp_id
      into v_cmp2
      from sman$_stored_objects t
     where t.label = p_to_label;
    if v_cmp1 != v_cmp2 then
      raise_error(c_err_diff_labels);
    end if;
    --Creating deploy
    save_difference(p_from_label, p_to_label, p_new_label, v_additional);
    create_deploy_file(p_new_label, p_deploy_name, v_additional);
    for i in (select * from table(get_objects(p_new_label))) loop
      pipe row(i);
    end loop;
    return;
  end get_diff_deploy;

  function get_components return clob is
    v_string varchar2(32767);
    v_result clob;
  begin
    for i in (select * from sman$_component t order by t.cmp_id) loop
      if v_result is null then
        dbms_lob.createtemporary(v_result, true);
        v_string := rpad('Component', 35, ' ') || 'Component description' ||
                    c_eol;
        dbms_lob.writeappend(v_result, length(v_string), v_string);
      end if;
      v_string := rpad(i.cmp_id, 35, ' ') || substr(i.cmp_desc, 1, 90) ||
                  c_eol;
      dbms_lob.writeappend(v_result, length(v_string), v_string);
    end loop;
    if v_result is null then
      dbms_lob.createtemporary(v_result, true);
      v_string := get_message(c_msg_no_components);
      dbms_lob.writeappend(v_result, length(v_string), v_string);
    end if;
    return v_result;
  end get_components;

  function get_component_labels(p_component in varchar2) return clob is
    v_string varchar2(32767);
    v_result clob;
  begin
    check_component(p_component);
    for i in (select distinct t.label, t.store_date
                from sman$_stored_objects t
               where t.object_type != c_obj_deploy
                 and t.cmp_cmp_id = p_component
               order by t.store_date) loop
      if v_result is null then
        dbms_lob.createtemporary(v_result, true);
        v_string := rpad('Label', 50, ' ') || rpad('Date', 30, ' ') ||
                    c_eol;
        dbms_lob.writeappend(v_result, length(v_string), v_string);
      end if;
      v_string := rpad(i.label, 50, ' ') ||
                  rpad(to_char(i.store_date, c_date_mask), 30, ' ') ||
                  c_eol;
      dbms_lob.writeappend(v_result, length(v_string), v_string);
    end loop;
    if v_result is null then
      dbms_lob.createtemporary(v_result, true);
      v_string := get_message(c_msg_no_labels);
      dbms_lob.writeappend(v_result, length(v_string), v_string);
    end if;
    return v_result;
  end get_component_labels;

  function get_component_details(p_component in varchar2) return clob is
    v_string varchar2(32767);
    v_result clob;
  begin
    check_component(p_component);
    for i in (select t.object_type,
                     t.object_name,
                     t.object_comment,
                     nvl2(t.generate_dml, 'Y', ' ') generate_dml,
                     nvl2(t.generate_grants, 'Y', ' ') generate_grants,
                     nvl2(t.create_public_synonym, 'Y', ' ') create_public_synonym
                from sman$_object_config t
               where t.cmp_cmp_id = p_component
               order by get_obj_sort_order(t.object_type, c_true)) loop
      if v_result is null then
        dbms_lob.createtemporary(v_result, true);
        v_string := rpad('Object Type', 20, ' ') ||
                    rpad('Object Name', 35, ' ') || rpad('DML', 8, ' ') ||
                    rpad('Grants', 8, ' ') ||
                    rpad('Public synonym', 18, ' ') ||
                    rpad('Object Comment', 50, ' ') || c_eol;
        dbms_lob.writeappend(v_result, length(v_string), v_string);
      end if;
      v_string := rpad(i.object_type, 20, ' ') ||
                  rpad(i.object_name, 35, ' ') ||
                  rpad(i.generate_dml, 8, ' ') ||
                  rpad(i.generate_grants, 8, ' ') ||
                  rpad(i.create_public_synonym, 18, ' ') ||
                  rpad(i.object_comment, 50, ' ') || c_eol;
      dbms_lob.writeappend(v_result, length(v_string), v_string);
    end loop;
    if v_result is null then
      dbms_lob.createtemporary(v_result, true);
      v_string := get_message(c_msg_no_cmp_data, p_component);
      dbms_lob.writeappend(v_result, length(v_string), v_string);
    end if;
    return v_result;
  end get_component_details;

  function get_label_details(p_label in varchar2) return clob is
    v_string varchar2(32767);
    v_cnt    number;
    v_result clob;
  begin
    --Checks
    select count(1)
      into v_cnt
      from sman$_stored_objects t
     where t.label = p_label;
    if v_cnt = 0 then
      raise_error(c_err_label_not_found, p_label);
    end if;
    for i in gc_all_objects(p_label, c_true) loop
      if v_result is null then
        dbms_lob.createtemporary(v_result, true);
        v_string := rpad('Object Type', 20, ' ') ||
                    rpad('Object Name', 35, ' ') || rpad('Path', 25, ' ') ||
                    rpad('File Name', 50, ' ') || c_eol;
        dbms_lob.writeappend(v_result, length(v_string), v_string);
      end if;
      v_string := rpad(i.object_type, 20, ' ') ||
                  rpad(i.object_name, 35, ' ') ||
                  rpad(get_object_path(i.object_type), 25, ' ') ||
                  rpad(get_object_file_name(i.object_type, i.object_name,
                                            i.cmp_cmp_id), 50, ' ') ||
                  c_eol;
      dbms_lob.writeappend(v_result, length(v_string), v_string);
    end loop;
    return v_result;
  end get_label_details;

  function get_drop_script(p_component in varchar2) return clob is
    v_string    varchar2(2000);
    v_result    clob;
    v_component varchar2(30) := p_component;
  begin
    if v_component = c_cmp_all then
      v_component := null;
    else
      check_component(v_component);
    end if;
    dbms_lob.createtemporary(v_result, true);
    for i in (select t.object_type, t.object_name, t.create_public_synonym
                from sman$_object_config t
               where t.cmp_cmp_id = nvl(v_component, t.cmp_cmp_id)) loop
      v_string := get_drop_sql(i.object_type, i.object_name) || c_eol;
      if i.create_public_synonym = c_true then
        v_string := v_string ||
                    get_drop_sql(c_obj_public_synonym, i.object_name) ||
                    c_eol;
      end if;
      dbms_lob.writeappend(v_result, length(v_string), v_string);
    end loop;
    return v_result;
  end get_drop_script;

  procedure dummy is
  begin
    null;
  end dummy;

  function get_version return varchar2 is
  begin
    return c_version;
  end get_version;

end pkg_sman$;

/
sho err