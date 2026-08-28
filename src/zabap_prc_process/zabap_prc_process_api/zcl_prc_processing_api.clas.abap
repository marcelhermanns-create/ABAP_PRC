CLASS zcl_prc_processing_api DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    CLASS-METHODS get_instance RETURNING VALUE(r_instance) TYPE REF TO zcl_prc_processing_api.

    TYPES tt_processed_objects_to_create TYPE TABLE FOR ACTION IMPORT zr_prc_processedobject~createprocessedobject.
    TYPES ty_failed                      TYPE RESPONSE FOR FAILED EARLY zr_prc_processedobject.
    TYPES ty_reported                    TYPE RESPONSE FOR REPORTED EARLY zr_prc_processedobject.
    TYPES ty_mapped                      TYPE RESPONSE FOR MAPPED EARLY ZR_PRC_ProcessedObject.

    METHODS add_processed_objects IMPORTING i_processed_objects_to_create TYPE tt_processed_objects_to_create
                                  EXPORTING e_failed                      TYPE ty_failed
                                            e_reported                    TYPE ty_reported
                                            e_mapped                      TYPE ty_mapped.

    TYPES tt_processed_object_uuid TYPE STANDARD TABLE OF zr_prc_processedobject-uuid WITH DEFAULT KEY.

    METHODS execute_synchronously       IMPORTING it_parameters            TYPE if_apj_rt_exec_object=>tt_templ_val OPTIONAL.
    METHODS execute_asynchronously      IMPORTING it_parameters            TYPE if_apj_rt_exec_object=>tt_templ_val OPTIONAL.
    METHODS execute_asynch_for_proc_obj IMPORTING it_processed_object_uuid TYPE tt_processed_object_uuid.

    INTERFACES if_oo_adt_classrun.

  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-DATA g_instance TYPE REF TO zcl_prc_processing_api.
ENDCLASS.



CLASS zcl_prc_processing_api IMPLEMENTATION.
  METHOD add_processed_objects.
    DATA lt_action_parameters TYPE TABLE FOR ACTION IMPORT zr_prc_processedobject~createprocessedobject.

    LOOP AT i_processed_objects_to_create INTO DATA(k).
      INSERT VALUE #( %cid   = COND #( WHEN k-%cid IS NOT INITIAL THEN k-%cid ELSE |CID{ sy-tabix }| )
                      %param = k-%param ) INTO TABLE lt_action_parameters.
    ENDLOOP.

    MODIFY ENTITIES OF ZR_PRC_ProcessedObject
           ENTITY ProcessedObject
           EXECUTE createProcessedObject FROM lt_action_parameters
           FAILED e_failed
           REPORTED e_reported
           MAPPED e_mapped.
  ENDMETHOD.

  METHOD execute_asynchronously.
    TRY.
        cl_bgmc_process_factory=>get_default(
            )->create(
            )->set_name( |ZCL_PRC_JOB async execution|
            )->set_operation_tx_uncontrolled( NEW zcl_prc_bgpf( it_parameters )
            )->save_for_execution( ).
      CATCH cx_bgmc INTO DATA(lx_bgmc).
        ASSERT lx_bgmc IS NOT BOUND.
    ENDTRY.
  ENDMETHOD.

  METHOD execute_asynch_for_proc_obj.
    execute_asynchronously( VALUE #(  FOR k IN it_processed_object_uuid
                                     ( selname = zcl_prc_retry_job=>c_uuid sign = 'I' option = 'EQ' low = k ) ) ).
  ENDMETHOD.


  METHOD execute_synchronously.
    zcl_prc_processing_engine=>get_instance( )->execute_synchronously( it_parameters ).
  ENDMETHOD.


  METHOD get_instance.
    IF g_instance IS NOT BOUND.
      g_instance = NEW #( ).
    ENDIF.
    r_instance = g_instance.
  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.
    DATA lt_parameters TYPE if_apj_rt_exec_object=>tt_templ_val.

*    SELECT * FROM ZR_PRC_ProcessedObject WHERE state <> @zif_prc_process_impl=>co_finished INTO TABLE @DATA(lt_data).
*    lt_parameters = VALUE #( FOR k IN lt_data
*                             ( low = k-uuid sign = 'I' option = 'EQ' selname = zcl_prc_job=>c_uuid  ) ).
*    APPEND VALUE #( selname = zcl_prc_job=>p_ignore_restart
*                    sign    = 'I'
*                    option  = 'EQ'
*                    low     = abap_true ) TO lt_parameters.
    zcl_prc_processing_api=>get_instance( )->execute_synchronously( lt_parameters ).
  ENDMETHOD.
ENDCLASS.
