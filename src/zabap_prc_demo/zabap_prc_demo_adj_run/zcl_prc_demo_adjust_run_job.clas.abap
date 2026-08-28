CLASS zcl_prc_demo_adjust_run_job DEFINITION
  PUBLIC
  INHERITING FROM zcl_prc_run_job FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS if_apj_dt_exec_object~get_parameters REDEFINITION.

    CONSTANTS: BEGIN OF c_parameter,
                 contract_id        TYPE zif_prc_run=>ty_run_parameter VALUE 'S_CTR',
                 sold_to_party      TYPE zif_prc_run=>ty_run_parameter VALUE 'S_SOLD',
                 ship_to_party      TYPE zif_prc_run=>ty_run_parameter VALUE 'S_SHIP',
                 lifecycle_status   TYPE zif_prc_run=>ty_run_parameter VALUE 'S_LIFE',
                 error_status       TYPE zif_prc_run=>ty_run_parameter VALUE 'S_ERR',

                 equipment_category TYPE zif_prc_run=>ty_run_parameter VALUE 'P_EQCAT',
                 material           TYPE zif_prc_run=>ty_run_parameter VALUE 'P_MAT',
                 discount_percent   TYPE zif_prc_run=>ty_run_parameter VALUE 'P_DISC',
               END OF c_parameter.

  PROTECTED SECTION.
    METHODS execute              REDEFINITION.
    METHODS get_log_info         REDEFINITION.
    METHODS get_application_name REDEFINITION.

  PRIVATE SECTION.
    DATA mt_contract_items_to_process TYPE STANDARD TABLE OF ZI_PRC_Demo_SrvCtrItemSel WITH DEFAULT KEY.

    METHODS do_actual_processing RAISING cx_bali_runtime.
    METHODS _get_data.
ENDCLASS.


CLASS zcl_prc_demo_adjust_run_job IMPLEMENTATION.

  METHOD execute.
    _get_data( ).

    IF mt_contract_items_to_process IS INITIAL.
      MESSAGE i001(zprc_demo_adjust_run) INTO DATA(lv_dummy) ##NEEDED.
      io_bali_log->add_item( cl_bali_message_setter=>create_from_sy( ) ).
      RETURN.
    ENDIF.

    do_actual_processing( ).
  ENDMETHOD.

  METHOD get_application_name.
    RETURN zif_prc_run=>co_application_names-rate_adjustment.
  ENDMETHOD.

  METHOD get_log_info.
    es_log_info = VALUE #( bal_object    = zif_prc_run=>co_bal-run
                           bal_subobject = zif_prc_run=>co_subbal-service_contract
                           external_id   = zif_prc_run=>co_external_id-adjustment_run ).
  ENDMETHOD.

  METHOD if_apj_dt_exec_object~get_parameters.
    et_parameter_def = VALUE #(
        changeable_ind = abap_true
        ( selname = c_parameter-contract_id         kind = if_apj_dt_exec_object=>select_option datatype = 'C' length = 10 param_text = 'Service Contract' )
        ( selname = c_parameter-sold_to_party       kind = if_apj_dt_exec_object=>select_option datatype = 'C' length = 10 param_text = 'Sold-to-Party' )
        ( selname        = c_parameter-ship_to_party
          kind           = if_apj_dt_exec_object=>select_option
          component_type = 'ZR0_LIFECYCLE_STATUS'
          datatype       = 'C'
          length         = 10
          param_text     = 'Ship-to-Party' )
        ( selname        = c_parameter-lifecycle_status
          kind           = if_apj_dt_exec_object=>select_option
          component_type = 'ZR0_ERROR_STATUS'
          datatype       = 'C'
          length         = 1
          param_text     = 'Lifecycle Status' )
        ( selname = c_parameter-error_status        kind = if_apj_dt_exec_object=>select_option datatype = 'C' length = 1  param_text = 'Error Status' )

        ( selname        = c_parameter-equipment_category
          kind           = if_apj_dt_exec_object=>parameter
          datatype       = 'C'
          length         = 10
          param_text     = 'Equipment Category' )
        ( selname = c_parameter-material            kind = if_apj_dt_exec_object=>parameter datatype = 'C'   length = 10 param_text = 'Service' )
        ( selname = c_parameter-discount_percent    kind = if_apj_dt_exec_object=>parameter datatype = 'P'   length = 10 param_text = 'Discount (in %)' )
        ( selname = zif_prc_run=>co_parameter-p_uuid kind = if_apj_dt_exec_object=>parameter datatype = 'C'   length = 32 param_text = 'Run UUID' ) ).
  ENDMETHOD.

  METHOD do_actual_processing.
    TYPES: BEGIN OF ty_id_and_uuid,
             id   TYPE ZI_PRC_Demo_SrvCtrItemSel-ServiceContractID,
             uuid TYPE ZI_PRC_Demo_SrvCtrItemSel-ContractUUID,
           END OF ty_id_and_uuid,
           tt_contract_ids TYPE SORTED TABLE OF ty_id_and_uuid WITH UNIQUE KEY uuid.
    DATA lt_contract_ids TYPE tt_contract_ids.

    LOOP AT mt_contract_items_to_process INTO DATA(ls_contract_item).
      INSERT VALUE #( id   = ls_contract_item-ServiceContractID
                      uuid = ls_contract_item-ContractUUID ) INTO TABLE lt_contract_ids.
    ENDLOOP.

    set_total_number( lines( lt_contract_ids ) ).

    zcl_prc_processing_api=>get_instance( )->add_processed_objects(
      EXPORTING i_processed_objects_to_create = VALUE #(
          FOR k IN lt_contract_ids
          ( %param = VALUE #( processedObject     = k-id
                              processedObjectUUID = k-uuid
                              runUUID             = me->mv_current_run_uuid
                              factoryClassName    = zcl_prc_demo_create_equi_proc=>co_class_name
                              appName             = zcl_prc_demo_create_equi_proc=>co_app_name ) ) )
      IMPORTING e_mapped                      = DATA(lt_mapped) ).

    COMMIT ENTITIES.

    zcl_prc_processing_engine=>get_instance( )->execute_synchronously(
        VALUE #( FOR mapped IN lt_mapped-processedobject
                 ( selname = zcl_prc_retry_job=>c_uuid sign = 'I' option = 'EQ' low = mapped-uuid ) ) ).
  ENDMETHOD.

  METHOD _get_data.
    CLEAR mt_contract_items_to_process.
    READ TABLE mt_select_options_values WITH KEY selname = c_parameter-contract_id INTO DATA(ls_select_option_ctr).
    READ TABLE mt_select_options_values WITH KEY selname = c_parameter-sold_to_party INTO DATA(ls_select_option_sold).
    READ TABLE mt_select_options_values WITH KEY selname = c_parameter-ship_to_party INTO DATA(ls_select_option_ship).
    READ TABLE mt_select_options_values WITH KEY selname = c_parameter-lifecycle_status INTO DATA(ls_select_option_life).
    READ TABLE mt_select_options_values WITH KEY selname = c_parameter-error_status INTO DATA(ls_select_option_error).

    SELECT * FROM ZI_PRC_Demo_SrvCtrItemSel
      WHERE ServiceContractID IN @ls_select_option_ctr-ranges
        AND SoldToPartyID     IN @ls_select_option_sold-ranges
        AND ShipToPartyID     IN @ls_select_option_ship-ranges
        AND LifecycleStatus   IN @ls_select_option_life-ranges
        AND ErrorStatus       IN @ls_select_option_error-ranges
      INTO TABLE @mt_contract_items_to_process.
  ENDMETHOD.
ENDCLASS.
