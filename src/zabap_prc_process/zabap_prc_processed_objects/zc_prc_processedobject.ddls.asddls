@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Processed Object'
@Metadata.allowExtensions: true
@Search.searchable: true
//@UI.presentationVariant: [ { sortOrder: [ { by: 'RetryDateTime', direction: #DESC } ] } ]
//
//@UI.selectionVariant: [
//  {
//    qualifier: 'sVariant',
//    text: 'SelectionVariant',
//    filter: 'MessageSeverity EQ E'
//  }
//]

@UI: {
  headerInfo: {
    typeName: 'Processed Object',
    typeNamePlural: 'Processed Objects',
    title: { type: #STANDARD, value: 'ExternalProcessedObjectID' },
    description: { type: #STANDARD, value: 'MessageText' },
    typeImageUrl: 'sap-icon://blank-tag'
  },
  presentationVariant: [
    {
      qualifier: 'pVariant',
      maxItems: 5,
      sortOrder: [
        {
          by: 'LastChangedAt',
          direction: #DESC
        }
      ],
      visualizations: [{type: #AS_LINEITEM}]
    },
    {
      qualifier: 'p50Variant',
      maxItems: 50,
      sortOrder: [
        {
          by: 'LastChangedAt',
          direction: #DESC
        }
      ],
      visualizations: [{type: #AS_LINEITEM}]
    }
  ],
  selectionVariant: [
    {
      qualifier: 'sVariant',
      text: 'SelectionVariant',
      filter: 'MessageSeverity EQ E'
    }
  ],
  selectionPresentationVariant: [
    { qualifier: 'spVariant',
      presentationVariantQualifier: 'pVariant',
      selectionVariantQualifier: 'sVariant'
    },
    { presentationVariantQualifier: 'p50Variant'
    }
    
  ]
}

define root view entity ZC_PRC_ProcessedObject
  provider contract transactional_query
  as projection on ZR_PRC_ProcessedObject

{
  key     UUID,

          LatestStepUUID,
          RunUUID,
          AppName,
          MailAddress,
          FactoryClassName,
          RetryCount,
          RetryDateTime,
          DoNotProcessBefore,
          QueueID,
          QueuePosition,
          CreatedAt,
          CreatedBy,
          LastChangedAt,
          LastChangedBy,
          LocalLastChangedAt,

          @Search.defaultSearchElement: true
          @Search.fuzzinessThreshold: 0.8
          State,

          @Search.defaultSearchElement: true
          ExternalProcessedObjectID,

          ExternalProcessedObjectUUID,

          @Search.defaultSearchElement: true
          @Search.fuzzinessThreshold: 0.7
          _LatestStep.MessageText          as MessageText,

          _LatestStep.MessageSeverity      as MessageSeverity,
          _LatestStep.MessageSeverityCode  as MessageSeverityCode,
          _ProcessedObjectAggr.StepCounter as StepCounter,

          StepTotal,

          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_PRC_PROC_OBJ_LINK'
  virtual link : abap.char(1000),

          _ProcessedStep : redirected to composition child ZC_PRC_ProcessedStep,
          _LatestStep    : redirected to ZC_PRC_ProcessedStep,

          _ProcessedObjectAggr
}
