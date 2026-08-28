CLASS zcl_prc_demo_create_equi_init DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

    CLASS-METHODS initialize.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_prc_demo_create_equi_init IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    initialize( ).
    COMMIT ENTITIES.
    out->write( |Demo process instances created| ).
  ENDMETHOD.


  METHOD initialize.
    " 1) Determine existing DEMO_EQUI instances (keys) to be removed
    SELECT uuid FROM ZR_PRC_ProcessedObject
      WHERE AppName = 'DEMO_EQUI'
      INTO TABLE @DATA(lt_existing).

    " TODO: variable is assigned but only used in commented-out code (ABAP cleaner)
    GET TIME STAMP FIELD DATA(lv_timestamp).
*    lv_timestamp += 100.

    " 2) Delete old + create 100 new demo instances via EML (managed numbering assigns UUIDs)
    MODIFY ENTITIES OF ZR_PRC_ProcessedObject
           ENTITY ProcessedObject
           DELETE FROM VALUE #( FOR k IN lt_existing
                                ( %key-uuid = k-uuid ) ).

    zcl_prc_processing_api=>get_instance(
        )->add_processed_objects( EXPORTING i_processed_objects_to_create = VALUE #( FOR i = 1 UNTIL i > 10
                                   ( %param-AppName          = 'DEMO_EQUI'
                                     %param-mailAddress      = 'demo@processing-center.de'
                                     %param-FactoryClassName = zcl_prc_demo_create_equi_proc=>co_class_name
                                     %cid                    = |DEMO_{ i ALIGN = RIGHT PAD = '0' WIDTH = 3 }|
                                     %param-processedObject  = |EQUI{ i ALIGN = RIGHT PAD = '0' WIDTH = 3 }| ) )
                                     IMPORTING e_mapped = DATA(lt_mapped) ).
    COMMIT ENTITIES.
    zcl_prc_processing_api=>get_instance( )->execute_asynch_for_proc_obj( VALUE #( FOR mapped IN lt_mapped-processedobject ( mapped-uuid ) ) ).
  ENDMETHOD.
ENDCLASS.
