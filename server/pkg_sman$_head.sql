
PROMPT ===========================================
PROMPT Create package PKG_SMAN$
PROMPT ===========================================

CREATE OR REPLACE package pkg_sman$ is

  type to_object is record(
    path      varchar2(2000),
    file_name varchar2(2000),
    data      clob);

  type tt_object is table of to_object;

  --Functions called in SQL queries

  function get_obj_type_replaced(p_object_type in varchar2) return varchar2;

  function get_obj_sort_order(p_object_type in varchar2,
                              p_with_sort   in varchar2) return number;

  --Functions called by SMAN Client

  procedure save_objects(p_component in varchar2, p_label in varchar2);

  procedure save_single_object(p_component   in varchar2,
                               p_label       in varchar2,
                               p_object_name in varchar2);

  function get_objects(p_label in varchar2) return tt_object
    pipelined;

  function get_full_deploy(p_label in varchar2, p_deploy_name in varchar2)
    return tt_object
    pipelined;

  function get_diff_deploy(p_from_label  in varchar2,
                           p_to_label    in varchar2,
                           p_new_label   in varchar2,
                           p_deploy_name in varchar2) return tt_object
    pipelined;

  function get_components return clob;

  function get_component_labels(p_component in varchar2) return clob;

  function get_component_details(p_component in varchar2) return clob;

  function get_label_details(p_label in varchar2) return clob;

  function get_drop_script(p_component in varchar2) return clob;

  procedure dummy;

  function get_version return varchar2;

end pkg_sman$;

/
sho err