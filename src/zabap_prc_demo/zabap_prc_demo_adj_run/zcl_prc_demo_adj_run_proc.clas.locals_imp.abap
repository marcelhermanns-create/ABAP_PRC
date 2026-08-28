CLASS lcl_root DEFINITION INHERITING FROM zcl_prc_transition_handlr_base ABSTRACT.
  PROTECTED SECTION.
    METHODS get_message_prefix_for_log REDEFINITION.
ENDCLASS.


CLASS lcl_root IMPLEMENTATION.

  METHOD get_message_prefix_for_log.
    MESSAGE i009(zprc_demo_adjust_run) WITH get_processed_object( ) INTO DATA(message_prefix).
    r_message = CORRESPONDING #( sy ).
  ENDMETHOD.

ENDCLASS.


CLASS lcl_adjust DEFINITION INHERITING FROM lcl_root.
  PROTECTED SECTION.
    METHODS get_success_message REDEFINITION.
    METHODS _perform_transition REDEFINITION.
ENDCLASS.


CLASS lcl_adjust IMPLEMENTATION.
  METHOD _perform_transition.
    WAIT UP TO 1 SECONDS.
    IF sy-uzeit MOD 10 = 3.
      MESSAGE e004(zr1_adjustment_run) WITH me->get_processed_object( ) INTO DATA(lv_dummy) ##NEEDED.
      get_message_handler( )->add_message_from_sy( ).
    ELSEIF sy-uzeit MOD 10 = 5.
      MESSAGE e005(zr1_adjustment_run) WITH me->get_processed_object( ) INTO lv_dummy.
      get_message_handler( )->add_message_from_sy( ).
    ELSE.
      DO 10 TIMES.
        IF sy-uzeit MOD 10 = 3.
          MESSAGE e003(zr1_adjustment_run) INTO lv_dummy.
          get_message_handler( )->add_message_from_sy( i_fail_on_error_message = abap_false ).
        ELSE.
          DATA(lv_item_pos) = sy-index * 10.
          MESSAGE s002(zr1_adjustment_run) WITH me->get_processed_object( ) lv_item_pos INTO lv_dummy.
          get_message_handler( )->add_message_from_sy( ).
        ENDIF.
      ENDDO.
    ENDIF.
  ENDMETHOD.

  METHOD get_success_message.
    MESSAGE s006(zprc_demo_adjust_run) WITH me->get_processed_object( ) INTO DATA(lv_dummy) ##NEEDED.
    r_message = CORRESPONDING #( sy ).
  ENDMETHOD.
ENDCLASS.
