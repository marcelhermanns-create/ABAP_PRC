@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Equipment'
@Metadata.allowExtensions: true
@Search.searchable: true

define root view entity ZR_PRC_DEMO_Equipment
  as select from zprc_demo_equi as Equipment
  association [0..1] to ZC_PRC_DEMO_EquipmentCategory as _EquipmentCategory on $projection.EquipmentCategory = _EquipmentCategory.Identifier
{
  key id                    as Identifier,

      @ObjectModel.foreignKey.association: '_EquipmentCategory'
      equipment_category_id as EquipmentCategory,

      @Search.defaultSearchElement: true
      _EquipmentCategory
}
