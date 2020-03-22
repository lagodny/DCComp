{$INCLUDE dcDataTypes.inc}

unit uDataTypes;

interface

type
  // тип данных, в котором храним показания датчиков
  {$IFDEF VALUE_IS_DOUBLE}
  TSensorValue = Double;
  {$ELSE}
  TSensorValue = Extended;
  {$ENDIF}

  PSensorValue = ^TSensorValue;


  // запись, в которой храним показания в файле данных
  TSensorDataRec = packed record
    Time: TDateTime;
    Value: TSensorValue;
  end;
  PSensorDataRec = ^TSensorDataRec;

  // данные на момент времени + информация об ошибке
  TSensorHistDataRec = packed record
    Time: TDateTime;
    Value, Error: TSensorValue;
  end;

  // массив записей
  TSensorDataArr = array of TSensorDataRec;

const
  cSensorDataRecSize = SizeOf(TSensorDataRec);



implementation



end.
