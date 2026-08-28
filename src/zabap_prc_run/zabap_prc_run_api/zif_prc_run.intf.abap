INTERFACE zif_prc_run
  PUBLIC.

  TYPES ty_run_parameter     TYPE c LENGTH 8.
  TYPES ty_job_template_name TYPE c LENGTH 30.
  TYPES tt_select_options    TYPE cl_apj_rt_api=>tt_job_parameter_value.

  CONSTANTS: BEGIN OF co_job_template_names,
               contract_billing TYPE ty_job_template_name VALUE 'ZAJT_R1_BILLING',
               rate_adjustment  TYPE ty_job_template_name VALUE 'ZAJT_PRC_DEMO_ADJUST_RUN',
             END OF co_job_TEMPLATE_NAMES.

  CONSTANTS: BEGIN OF co_application_names,
               contract_billing TYPE zprc_run_app_name VALUE 'Contract Billing',
               rate_adjustment  TYPE zprc_run_app_name VALUE 'Rate Adjustment',
             END OF co_application_names.

  CONSTANTS: BEGIN OF co_message_severity,
               neutral TYPE zprc_message_severity_code VALUE 0,
               error   TYPE zprc_message_severity_code VALUE 1,
               warning TYPE zprc_message_severity_code VALUE 2,
               success TYPE zprc_message_severity_code VALUE 3,
               info    TYPE zprc_message_severity_code VALUE 5,
             END OF co_message_Severity.

  CONSTANTS: BEGIN OF co_execution_status,
               Started  TYPE zprc_run_execution_status VALUE 'ST',
               planned  TYPE zprc_run_execution_status VALUE 'PL',
               finished TYPE zprc_run_execution_status VALUE 'FI',
             END OF co_execution_status.

  CONSTANTS: BEGIN OF co_parameter,
               p_uuid      TYPE c LENGTH 8                   VALUE 'P_UUID',
               p_exec_type TYPE zif_prc_run=>ty_run_parameter VALUE 'P_EXEC_T',
             END OF co_PARAMETER.

  CONSTANTS: BEGIN OF co_bal,
               run TYPE string VALUE 'ZALO_R1_RUN',
             END OF co_bal.
  CONSTANTS: BEGIN OF co_subbal,
               Service_contract TYPE string VALUE 'SERVICE_CONTRACT',
             END OF co_subbal.
  CONSTANTS: BEGIN OF co_external_id,
               adjustment_run TYPE string VALUE 'ADJUSTMENT_RUN',
             END OF co_external_id.

ENDINTERFACE.
