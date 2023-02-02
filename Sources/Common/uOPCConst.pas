unit uOPCConst;

interface

const
// имена свойств датчика
  sSensorID = 'ID';
  sSensorName = 'Name';
  sSensorNameEn = 'NameEn';
  sSensorFullName = 'FullName';

  sSensorConnectionName = 'ConnectionName';
  sSensorControllerAddr = 'ControllerAddr';
  sSensorAddr = 'Addr';

  sSensorUnitName = 'UnitName';
  sSensorDisplayFormat = 'DisplayFormat';

  sSensorMinReadInterval = 'MinReadInterval';
  sSensorUpdateInterval = 'UpdateInterval';

  sSensorCorrectMul = 'CorrectMul';
  sSensorCorrectAdd = 'CorrectAdd';

  sSensorTransformCount = 'TransformCount';
  sSensorTransformIn = 'TransformIn';
  sSensorTransformOut = 'TransformOut';

  sSensorCompression_Precision = 'Compression.Precision';
  sSensorCompression_DeadSpace = 'Compression.DeadSpace';

  sSensorPrecision = 'SensorPrecision';
  sApproxPrecision = 'ApproxPrecision';

  sSensorDataBuffer_MaxInterval = 'DataBuffer.MaxInterval';
  sSensorDataBuffer_MaxRecCount = 'DataBuffer.MaxRecCount';

  sSensorDataBuffer_DataWriter_Kind = 'DataBuffer.DataWriter.Kind';
  sSensorDataBuffer_DataWriter_UpdateDBInterval =
    'DataBuffer.DataWriter.UpdateDBInterval';
  sSensorDataBuffer_DataWriter_ExtDeadband =
    'DataBuffer.DataWriter.ExtDeadband';

  sSensorSmooth_Kind = 'Smooth.Kind';
  sSensorSmooth_Interval = 'Smooth.Interval';

  sSensorRefAutoFill = 'RefAutoFill';
  sSensorRefTableName = 'RefTableName';

  sSensorFuncName = 'FuncName';
  sSensorOnChangValueFuncName = 'OnChangValueFuncName';
  sSensorOsSensornReadConvertValueFuncName = 'ReadConvertValueFuncName';
  sSensorOnWriteConvertValueFuncName = 'OnWriteConvertValueFuncName';

  cState_IsFiltered = -7;

implementation
  
  
end.