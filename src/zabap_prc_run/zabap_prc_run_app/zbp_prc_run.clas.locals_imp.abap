CLASS lhc_Run DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PUBLIC SECTION.
    CLASS-DATA: gt_trigger_se_events_for TYPE STANDARD TABLE OF sysuuid_x16 WITH DEFAULT KEY.

  PRIVATE SECTION.
    METHODS get_instance_authorizations FOR GLOBAL AUTHORIZATION IMPORTING REQUEST requested_authorizations FOR Run RESULT result.
    METHODS initiaterun FOR MODIFY IMPORTING keys FOR ACTION run~initiaterun.
    METHODS triggerChangedEvent FOR MODIFY keys FOR ACTION Run~triggerChangedEvent.
ENDCLASS.

CLASS zbp_prc_run DEFINITION LOCAL FRIENDS lhc_run.

CLASS lhc_Run IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD initiateRun.
    DATA lt_parameter TYPE cl_apj_rt_api=>tt_job_parameter_value.

    /ui2/cl_json=>deserialize( EXPORTING json = keys[ 1 ]-%param-selectOptionString
                               CHANGING  data = lt_parameter ).

    MODIFY ENTITIES OF zr_prc_run
           IN LOCAL MODE
           ENTITY Run
           CREATE FIELDS ( ExecutionStatus ApplicationName JobName )
           WITH VALUE #( ( %cid            = 'CID'
                           ExecutionStatus = zif_prc_run=>co_execution_status-planned
                           ApplicationName = keys[ 1 ]-%param-applicationName
                           JobName         = keys[ 1 ]-%param-jobName ) )
           FAILED DATA(ls_failed)
           REPORTED DATA(ls_reported)
           MAPPED DATA(ls_mapped).

    ASSERT ls_failed IS INITIAL.
    APPEND VALUE #( %cid = keys[ 1 ]-%param-jobName
                    uuid = ls_mapped-run[ 1 ]-uuid ) TO mapped-run.

    APPEND VALUE #( name    = zif_r1_run=>co_parameter-p_uuid
                    t_value = VALUE #( ( low = ls_mapped-run[ 1 ]-uuid sign = 'I' option = 'EQ' ) ) ) TO lt_parameter.

    APPEND VALUE #( job_template_name = keys[ 1 ]-%param-jobTemplateName
                    job_name          = keys[ 1 ]-%param-jobName
                    parameter         = lt_parameter ) TO zbp_prc_run=>gt_apj_parameters.
  ENDMETHOD.

  METHOD triggerChangedEvent.
    LOOP AT keys INTO DATA(key).
      APPEND key-uuid TO gt_trigger_se_events_for.

*      MODIFY ENTITIES OF zr_prc_run
*         IN LOCAL MODE
*         ENTITY Run
*         UPDATE FIELDS ( ExecutionStatus ApplicationName JobName )
*         WITH VALUE #( ( %key-uuid = key-uuid ExecutionStatus = zif_prc_run=>co_execution_status-planned ) )
*         FAILED DATA(ls_failed)
*         REPORTED DATA(ls_reported)
*         MAPPED DATA(ls_mapped).
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_saver DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS save_modified    REDEFINITION.
    METHODS cleanup_finalize REDEFINITION.
ENDCLASS.

CLASS zbp_prc_run DEFINITION LOCAL FRIENDS lsc_saver.

CLASS lsc_saver IMPLEMENTATION.
  METHOD save_modified.
    LOOP AT zbp_prc_run=>gt_apj_parameters INTO DATA(ls_job_params).
      TRY.
          cl_apj_rt_api=>generate_jobkey( IMPORTING ev_jobname  = DATA(jobname)
                                                    ev_jobcount = DATA(jobCount) ).
          cl_apj_rt_api=>schedule_job( iv_job_template_name   = CONV #( ls_job_params-job_template_name )
                                       iv_job_text            = ls_job_params-job_name
                                       is_start_info          = VALUE #( start_immediately = abap_true )
                                       it_job_parameter_value = ls_job_params-parameter
                                       iv_jobname             = jobname
                                       iv_jobcount            = jobCount ).
        CATCH cx_apj_rt INTO DATA(lo_exception). " TODO: variable is assigned but never used (ABAP cleaner)
          ASSERT 0 = 1.
      ENDTRY.
    ENDLOOP.
    CLEAR zbp_prc_run=>gt_apj_parameters.

    LOOP AT update-run INTO DATA(ls_run).
      RAISE ENTITY EVENT ZR_PRC_Run~runChanged FROM VALUE #( ( %key-uuid = ls_run-uuid ) ).
    ENDLOOP.

    LOOP AT lhc_run=>gt_trigger_se_events_for INTO DATA(lv_uuid).
      RAISE ENTITY EVENT ZR_PRC_Run~runChanged FROM VALUE #( ( %key-uuid = lv_uuid ) ).
    ENDLOOP.

  ENDMETHOD.

  METHOD cleanup_finalize.
    CLEAR zbp_prc_run=>gt_apj_parameters.
  ENDMETHOD.

ENDCLASS.
