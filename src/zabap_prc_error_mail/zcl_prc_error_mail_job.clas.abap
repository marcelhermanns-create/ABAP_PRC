CLASS zcl_prc_error_mail_job DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_apj_dt_exec_object.
    INTERFACES if_apj_rt_exec_object.

    METHODS execute_synchronously.

protected section.
  PRIVATE SECTION.
    TYPES: BEGIN OF ty_failed_objects,
             appName         TYPE ZR_PRC_ProcessedObject-AppName,
             mailAddress     TYPE ZR_PRC_ProcessedObject-MailAddress,
             ExternalProcessedObjectID TYPE ZR_PRC_ProcessedObject-ExternalProcessedObjectID,
             MessageText     TYPE ZR_PRC_ProcessedStep-MessageText,
             CreatedAt       TYPE ZR_PRC_ProcessedStep-CreatedAt,
           END OF ty_failed_objects,
           tt_failed_objects TYPE STANDARD TABLE OF ty_failed_objects WITH DEFAULT KEY.

    METHODS _get_failed_processed_objects RETURNING VALUE(r_failed_processed_objects) TYPE tt_failed_objects.
    METHODS _send_mail_for_entries IMPORTING i_failed_processed_objects TYPE tt_failed_objects.

    METHODS _get_mail_html IMPORTING i_failed_processed_objects TYPE tt_failed_objects
                           RETURNING VALUE(r_result)            TYPE string.
ENDCLASS.



CLASS ZCL_PRC_ERROR_MAIL_JOB IMPLEMENTATION.


  METHOD if_apj_rt_exec_object~execute.
    execute_synchronously( ).
  ENDMETHOD.


  METHOD if_apj_dt_exec_object~get_parameters.
    CLEAR: et_parameter_def,
           et_parameter_val.
  ENDMETHOD.


  METHOD _send_mail_for_entries.
    TRY.
        DATA(lv_main) = cl_bcs_mail_textpart=>create_text_html( _get_mail_html( i_failed_processed_objects ) ).
        DATA(lo_mail_api) = cl_bcs_mail_message=>create_instance( ).

* not possible in 2023, but later:
 lo_mail_api->set_importance( cl_bcs_mail_message=>importance-high ).

        lo_mail_api->set_sender( 'Process-Center@jungheinrich.de' ).
        DATA(lv_mail_recipient) = 'ITSM_Sales_Asset_Management_Service@jungheinrich.com'.
        lo_mail_api->add_recipient( CONV #( lv_mail_recipient ) ).
*        DATA(lv_system_id) = zcl_system_host_util=>get_instance( )->get_logical_system( ).
        lo_mail_api->set_subject( |Error in equipment transition| ).
        lo_mail_api->set_main( lv_main ).

        lo_mail_api->send( IMPORTING et_status      = DATA(lt_status)
                                     ev_mail_status = DATA(lv_mail_status) ).
        COMMIT WORK.
      CATCH cx_bcs_mail INTO DATA(lo_message).
    ENDTRY.
  ENDMETHOD.


  METHOD _get_mail_html.
    r_result = |<!DOCTYPE html>| &&
    |<html>| &&
    |<body>| &&
    |<p>Dear Sales Asset Management Service Team,</p> | &&
    |<p>adding the following Equipments was not not possible. </p>| &&
    |<table style="border-collapse: collapse; width: 100%; font-family: Arial, sans-serif; font-size: 14px;">| &&
    | <thead> | &&
    |  <tr style="background-color: #0078D4; color: white;">| &&
    |    <th style="padding: 10px; border: 1px solid #d1d1d1; text-align: left;">Equipment ID</th>| &&
    |    <th style="padding: 10px; border: 1px solid #d1d1d1; text-align: left;">Error Message</th>| &&
    |    <th style="padding: 10px; border: 1px solid #d1d1d1; text-align: left;">Created at</th>| &&
    |  </tr>| &&
    | </thead> | &&
    |  <tbody> <tr>|.

    LOOP AT i_failed_processed_objects INTO DATA(ls_entry).
      r_result = |{ r_result }  <tr style="background-cor: #f8f9fa;"> | &&
                 |                <td style="padding: 10px; border: 1px solid #d1d1d1;">{ ls_entry-ExternalProcessedObjectID }</td>| &&
                 |                <td style="padding: 10px; border: 1px solid #d1d1d1;">{ ls_entry-MessageText }</td>| &&
                 |                <td style="padding: 10px; border: 1px solid #d1d1d1;">{ CONV timestamp( ls_entry-CreatedAt ) TIMESTAMP = ENVIRONMENT TIMEZONE = 'UTC' }</td>| &&
                 |              </tr>|.
    ENDLOOP.

    r_result = r_result &&
    |<tbody></table>| &&

    |<div style="margin-top: 15px; padding: 12px; background-color: #FFF4CE; border-left: 4px solid #FFB900; font-family: Arial, sans-serif;"> | &&
    |<strong>Action Required:</strong><br>Kindly investigate and resolve the issue listed above.</div><p>Thank you.</p> | &&
    |</body>| &&
    |</html>|.
  ENDMETHOD.


  METHOD _get_failed_processed_objects.
    DATA(lv_system_date) = cl_abap_context_info=>get_system_date( ).

    CONVERT DATE lv_system_date TIME '000000'
            INTO TIME STAMP DATA(lv_cutoff) TIME ZONE 'UTC'.

    SELECT FROM ZR_PRC_ProcessedObject
      FIELDS AppName,
             MailAddress,
             ExternalProcessedObjectID,
             \_LatestStep-MessageText,
             \_LatestStep-CreatedAt

      WHERE \_LatestStep-MessageSeverity  = 'E'
        AND CreatedAt < @lv_cutoff
        AND MailAddress                  IS NOT INITIAL
      INTO TABLE @r_failed_processed_objects.
  ENDMETHOD.


  METHOD execute_synchronously.
    DATA(lt_failed_processed_objects) = _get_failed_processed_objects( ).

    IF lt_failed_processed_objects IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT lt_failed_processed_objects INTO DATA(ls_group)
         GROUP BY ( appName     = ls_group-appName
                    mailAddress = ls_group-mailAddress )
         ASSIGNING FIELD-SYMBOL(<ls_group_key>).

      DATA(lt_members) = VALUE tt_failed_objects( ).
      LOOP AT GROUP <ls_group_key> ASSIGNING FIELD-SYMBOL(<ls_member>).
        APPEND <ls_member> TO lt_members.
      ENDLOOP.

      _send_mail_for_entries( lt_members ).
    ENDLOOP.

    COMMIT WORK.
  ENDMETHOD.
ENDCLASS.
