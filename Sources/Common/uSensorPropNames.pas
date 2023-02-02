unit uSensorPropNames;

interface

const
  // имена свойств объектов (Групп)
  sID = 'ID';
  sParentID = 'ParentID';
  sName = 'Name';
  sNameEn = 'NameEn';
  sFullName = 'FullName';
  sKind = 'Kind';

  // имена свойств оборудования (Equipment)
  sDevPath = 'Path';
  sDevData = 'Data';
  sDevInfo = 'DevInfo';
  sDevCommands = 'DevCommands';

  // имена свойств датчика
  sSensorID = 'ID';
  sSensorSID = 'SID';
  sSensorUseParentSID = 'UseParentSID';
  sSensorFullSID = 'FullSID';

  sSensorName = 'Name';
  sSensorNameEn = 'NameEn';
  sSensorFullName = 'FullName';

  sSensorConnectionName = 'ConnectionName';
  sSensorControllerAddr = 'ControllerAddr';
  sSensorAddr = 'Addr';

  sSensorPermissions = 'Permissions';

  sSensorUnitName = 'UnitName';
  sSensorDisplayFormat = 'DisplayFormat';

  sSensorMinReadInterval = 'MinReadInterval';
  sSensorUpdateInterval = 'UpdateInterval';
  sSensorTimeShift = 'TimeShift';
  sSensorTimeStart = 'TimeStart';

  sSensorCorrectMul = 'CorrectMul';
  sSensorCorrectAdd = 'CorrectAdd';

  sSensorTransformCount = 'TransformCount';
  sSensorTransformIn = 'TransformIn';
  sSensorTransformOut = 'TransformOut';

  sSensorPrecision = 'SensorPrecision';
  sSensorStairs = 'SensorStairs';

  sSensorCompression_Precision = 'Compression.Precision';
  sSensorCompression_DeadSpace = 'Compression.DeadSpace';

  sSensorDataBuffer_MaxInterval = 'DataBuffer.MaxInterval';
  sSensorDataBuffer_MaxRecCount = 'DataBuffer.MaxRecCount';

  sSensorDataBuffer_DataWriter_Kind = 'DataBuffer.DataWriter.Kind';
  sSensorDataBuffer_DataWriter_UpdateDBInterval = 'DataBuffer.DataWriter.UpdateDBInterval';
  sSensorDataBuffer_DataWriter_ExtDeadband ='DataBuffer.DataWriter.ExtDeadband';

  sSensorSmooth_Kind = 'Smooth.Kind';
  sSensorSmooth_Interval = 'Smooth.Interval';
  sSensorSmooth_Count = 'Smooth.Count';

  sSensorRefAutoFill = 'RefAutoFill';
  sSensorRefTableName = 'RefTableName';
  sSensorRefValue = 'RefValue';

  sSensorRefLayerFileName = 'RefLayerFileName';
  sSensorRefLayerFieldName = 'RefLayerFieldName';

  sSensorEquipmentID = 'EquipmentID';
  sSensorEquipmentPath = 'EquipmentPath';

  sSensorFuncName = 'FuncName';
  sSensorOnChangValueFuncName = 'OnChangValueFuncName';
  sSensorOsSensornReadConvertValueFuncName = 'ReadConvertValueFuncName';
  sSensorOnWriteConvertValueFuncName = 'OnWriteConvertValueFuncName';

  sApproxPrecision = 'ApproxPrecision';



implementation

end.
