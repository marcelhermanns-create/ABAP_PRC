CLASS ltc_execute DEFINITION FOR TESTING DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS: execute FOR TESTING RAISING cx_apj_rt_content.
ENDCLASS.

CLASS ltc_execute IMPLEMENTATION.
  METHOD execute.
    SELECT uuid FROM ZR_PRC_ProcessedObject
      WHERE AppName = @zcl_prc_demo_create_equi_proc=>co_app_name
      INTO TABLE @DATA(lt_existing).

    MODIFY ENTITIES OF ZR_PRC_ProcessedObject
           ENTITY ProcessedObject
           DELETE FROM VALUE #( FOR k IN lt_existing
                                ( %key-uuid = k-uuid ) ).

    COMMIT ENTITIES.

    NEW zcl_prc_demo_adjust_run_job( )->if_apj_rt_exec_object~execute( it_parameters = VALUE #( ) ). "( selname = zcl_r1_adjustment_run_job=>c_parameter-contract_id
    "  kind = if_apj_dt_exec_object=>select_option
    "   sign = 'I' option = 'EQ' low = '3000000001' ) ) ).
  ENDMETHOD.

ENDCLASS.
