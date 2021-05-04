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

function DataArrToString(aDataArr: TSensorDataArr): string;



implementation

uses
  SynCommons;


function DataArrToString(aDataArr: TSensorDataArr): string;
var
  i: Integer;
begin
  Result := '';
  for i := Low(aDataArr) to High(aDataArr) do
    Result := Result + UTF8ToString(DateTimeToIso8601(aDataArr[i].Time, True)) + ';' + DoubleToString(aDataArr[i].Value) + ';';
end;




end.
