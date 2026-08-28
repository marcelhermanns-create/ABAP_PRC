@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Available application Names'
@Search.searchable: true
define view entity ZI_PRC_ApplicationNameVH
  as select from ZR_PRC_ProcessedObject
{
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.6
  key AppName
}
group by
  AppName
