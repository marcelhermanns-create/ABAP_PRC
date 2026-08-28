@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Equipment'
@Metadata.allowExtensions: true
@Search.searchable: true

define root view entity ZC_PRC_DEMO_Equipment
  as select from ZR_PRC_DEMO_Equipment as Equipment
{
  key Identifier,
      EquipmentCategory,
      
      _EquipmentCategory
}
