CLASS zcl_prc_retry_job DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_apj_rt_exec_object.
    INTERFACES if_apj_dt_exec_object.

    CONSTANTS p_ignore_restart TYPE c LENGTH 8 VALUE 'S_IGNR'.
    CONSTANTS c_uuid           TYPE c LENGTH 8 VALUE 'S_UUID'.

  PROTECTED SECTION.

  PRIVATE SECTION.
ENDCLASS.


CLASS zcl_prc_retry_job IMPLEMENTATION.
  METHOD if_apj_dt_exec_object~get_parameters.
    et_parameter_def = VALUE #(
        datatype = 'C'
        ( selname = c_uuid           kind = if_apj_dt_exec_object=>select_option length = 32  param_text = 'UUID' )
        ( selname = p_ignore_restart kind = if_apj_dt_exec_object=>parameter length = 1       param_text = 'Overrule Restart Scheduling' ) ).
  ENDMETHOD.

  METHOD if_apj_rt_exec_object~execute.
    zcl_prc_processing_engine=>get_instance( )->execute_synchronously( it_parameters ).
  ENDMETHOD.
ENDCLASS.
