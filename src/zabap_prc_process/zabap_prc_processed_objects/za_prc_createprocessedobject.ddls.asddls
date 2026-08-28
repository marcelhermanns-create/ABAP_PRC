@EndUserText.label: 'Parameter to create a Processed Object'
define root abstract entity ZA_PRC_CreateProcessedObject
{
  runUUID             : sysuuid_x16;
  appName             : abap.char(30);
  mailAddress         : abap.char(50);
  factoryClassName    : abap.char(30);
  processedObject     : abap.char(50);
  processedObjectUUID : sysuuid_x16;
  doNotProcessBefore  : tzntstmpl;
  queueID           : abap.char(50);
  queuePosition       : abap.int8;
}
