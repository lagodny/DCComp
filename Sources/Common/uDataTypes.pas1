unit uDataTypes;

interface

type
  TDataValue = Double;

  TDataRec = packed record
    Time: TDateTime;
    Value: TDataValue;
  end;

  PDataRec = ^TDataRec;

  TDataArr = array of TDataRec;

  function DataArrToString(aDataArr: TDataArr): string;

implementation

uses
  SynCommons;

function DataArrToString(aDataArr: TDataArr): string;
var
  i: Integer;
begin
  Result := '';
  for i := Low(aDataArr) to High(aDataArr) do
    Result := Result + UTF8ToString(DateTimeToIso8601(aDataArr[i].Time, True)) + ';' + DoubleToString(aDataArr[i].Value) + ';';
end;


end.
