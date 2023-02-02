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
    procedure InitFromHex(const aHex: string);
    function ToHex: string;
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
  cSensorValueSize = SizeOf(TSensorValue);

function DataArrToString(aDataArr: TSensorDataArr): string;

implementation

uses
  System.SysUtils,
  System.DateUtils,
  aOPCUtils;
//  SynCommons;


function DataArrToString(aDataArr: TSensorDataArr): string;
var
  i: Integer;
begin
  Result := '';
  for i := Low(aDataArr) to High(aDataArr) do
    Result := Result + DateToIso8601(aDataArr[i].Time, False) + ';' + FloatToStr(aDataArr[i].Value, dotFS) + ';';
//    Result := Result + UTF8ToString(DateTimeToIso8601(aDataArr[i].Time, True)) + ';' + DoubleToString(aDataArr[i].Value) + ';';
end;




{ TSensorDataRec }

procedure TSensorDataRec.InitFromHex(const aHex: string);
var
  a: Array [0..SizeOf(TSensorDataRec) - 1] of Byte absolute Self;
begin
  for var i := 0 to High(a) do
    a[i] := StrToInt('$'+Copy(aHex, i*2 + 1, 2));
end;

function TSensorDataRec.ToHex: string;
var
  a: Array [0..SizeOf(TSensorDataRec) - 1] of Byte absolute Self;
begin
  Result := '';
  for var i := 0 to High(a) do
    Result := Result + IntToHex(a[i], 2);
end;

end.
