CLASS lhc_ServiceContract DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR ServiceContract RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR ServiceContract RESULT result.

    METHODS adjustViaSelectOptions FOR MODIFY
      IMPORTING keys FOR ACTION ServiceContract~adjustViaSelectOptions RESULT result.

    METHODS GetDefaultsForAdjSelOpt FOR READ
      IMPORTING keys FOR FUNCTION ServiceContract~GetDefaultsForAdjSelOpt RESULT result.

    METHODS _append_select_option_eq IMPORTING !name          TYPE zif_prc_run=>ty_run_parameter
                                               !value         TYPE string
                                     CHANGING  select_options TYPE zif_prc_run=>tt_select_options.

ENDCLASS.

CLASS lhc_ServiceContract IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD _append_select_option_eq.
    LOOP AT select_options ASSIGNING FIELD-SYMBOL(<fs_select_option>) USING KEY name WHERE name = name.
      EXIT.
    ENDLOOP.

    IF <fs_select_option> IS NOT ASSIGNED.
      INSERT VALUE #( name = name ) INTO TABLE select_options ASSIGNING <fs_select_option>.
    ENDIF.

    APPEND VALUE #( option = 'EQ'
                    sign   = 'I'
                    low    = value ) TO <fs_select_option>-t_value.
  ENDMETHOD.

  METHOD adjustviaselectoptions.
    DATA select_options TYPE zif_prc_run=>tt_select_options.

    /ui2/cl_json=>deserialize( EXPORTING json = keys[ 1 ]-%param-selectOptions
                               CHANGING  data = select_options ).

    _append_select_option_eq( EXPORTING name           = zcl_prc_demo_adjust_run_job=>c_parameter-equipment_category
                                        value          = CONV #( keys[ 1 ]-%param-EquipmentCategory )
                              CHANGING  select_options = select_options ).

    _append_select_option_eq( EXPORTING name           = zcl_prc_demo_adjust_run_job=>c_parameter-material
                                        value          = CONV #( keys[ 1 ]-%param-Material )
                              CHANGING  select_options = select_options ).

    _append_select_option_eq( EXPORTING name           = zcl_prc_demo_adjust_run_job=>c_parameter-discount_percent
                                        value          = CONV #( keys[ 1 ]-%param-DiscountInPercent )
                              CHANGING  select_options = select_options ).

    DATA(json) = /ui2/cl_json=>serialize( select_options ).

    MODIFY ENTITIES OF ZR_PRC_Run ENTITY Run
           EXECUTE initiateRun FROM VALUE #(
               ( %cid   = 'CID'
                 %param = VALUE #( applicationName    = zif_prc_run=>co_application_names-rate_adjustment
                                   jobName            = |Rate Adjustment Run - { sy-datum }, { sy-uzeit } - { sy-uname }|
                                   jobTemplateName    = zif_prc_run=>co_job_template_names-rate_adjustment
                                   selectOptionString = json ) ) )
           MAPPED DATA(ls_mapped)
           " TODO: variable is assigned but never used (ABAP cleaner)
           REPORTED DATA(ls_reported)
           FAILED DATA(ls_failed).
    ASSERT ls_failed IS INITIAL.
    ASSERT line_Exists( ls_mapped-run[ 1 ] ).
    APPEND INITIAL LINE TO result ASSIGNING FIELD-SYMBOL(<result>).
    <result> = VALUE #( %cid   = keys[ 1 ]-%cid
                        %param = VALUE #( runUUID = ls_mapped-run[ 1 ]-uuid ) ).
  ENDMETHOD.

  METHOD GetDefaultsForAdjSelOpt.
    LOOP AT keys INTO DATA(ls_key).
      APPEND INITIAL LINE TO result ASSIGNING FIELD-SYMBOL(<result>).
      <result> = VALUE #( %cid   = ls_key-%cid
                          %param = VALUE #( EquipmentCategory = 'EQC0000001'
                                            Material          = 'MAT0000003'
                                            DiscountInPercent = 10 ) ).
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
