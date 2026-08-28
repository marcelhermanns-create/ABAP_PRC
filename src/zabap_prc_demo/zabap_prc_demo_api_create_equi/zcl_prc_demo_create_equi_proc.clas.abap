CLASS zcl_prc_demo_create_equi_proc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_prc_process.

    ALIASES tt_transition FOR zif_prc_process~tt_transition.
    ALIASES ty_state      FOR zif_prc_process~ty_state.

    TYPES: BEGIN OF ty_activity_implementation,
             class_name TYPE string,
           END OF ty_activity_implementation.

    CONSTANTS co_create_equi   TYPE ty_state    VALUE 'CREATE_EQUI'.
    CONSTANTS co_link_serial   TYPE ty_state    VALUE 'LINK_SERIAL'.
    CONSTANTS co_check_install TYPE ty_state    VALUE 'CHECK_INSTALL'.
    CONSTANTS co_install_equi  TYPE ty_state    VALUE 'INSTALL_EQUI'.
    CONSTANTS co_class_name    TYPE c LENGTH 30 VALUE 'ZCL_PRC_DEMO_CREATE_EQUI_PROC'.
    CONSTANTS co_app_name      TYPE c LENGTH 30 VALUE 'DEMO_CREATE_EQUI'.

  PROTECTED SECTION.

  PRIVATE SECTION.

ENDCLASS.



CLASS ZCL_PRC_DEMO_CREATE_EQUI_PROC IMPLEMENTATION.


  METHOD zif_prc_process~get_transitions.
    rt_transitions = VALUE tt_transition( ( start_state = zif_prc_process~co_start  end_state   = co_create_equi )
                                          ( start_state = co_create_equi            end_state   = co_link_serial )
                                          ( start_state = co_link_serial            end_state   = co_check_install )
                                          ( start_state = co_check_install          end_state   = co_install_equi )
                                          ( start_state = co_install_equi           end_state   = zif_prc_process~co_finished )
                                          ( start_state = co_check_install          end_state   = zif_prc_process~co_finished ) ).
  ENDMETHOD.


  METHOD zif_prc_process~get_transition_handler.
    CASE i_start_state.
      WHEN zif_prc_process~co_start.
        ro_transition_handler = NEW lcl_validate( ).
      WHEN co_create_equi.
        ro_transition_handler = NEW lcl_create_equi( ).
      WHEN co_link_serial.
        ro_transition_handler = NEW lcl_link_serial( ).
      WHEN co_check_install.
        ro_transition_handler = NEW lcl_check_install( ).
      WHEN co_install_equi.
        ro_transition_handler = NEW lcl_install_equi( ).
      WHEN zif_prc_process~co_finished.
        " finished state has no transitions
        ASSERT 1 = 2.
      WHEN OTHERS.
        " unexpected state
        ASSERT 1 = 2.
    ENDCASE.
  ENDMETHOD.


  METHOD zif_prc_process~get_url_for_processed_object.
    RETURN |#ServiceContract-display?ServiceContract={ iv_processed_object }|.
  ENDMETHOD.
ENDCLASS.
