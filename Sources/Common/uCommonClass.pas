unit uCommonClass;

interface

uses
  SysUtils,
  aCustomOPCSource, aOPCSource, aOPCLookupList,
  uDCObjects;

type
  TOnInitNodeProc = procedure(const Percent:integer) of object;

  TSensor = class(TDCCustomSensor)
  private
    FImageIndex: integer;
    FSensorKind: integer;
    FLookupList: TaOPCLookupList;
    procedure SetSensorKind(const Value: integer);
    procedure SetImageIndex(const Value: integer);
    procedure SetLookupList(const Value: TaOPCLookupList);
  public
    function IsLookup:boolean;

    function FormatFloat(aValue: extended): string;
    function FormatFloatStr(aValue: extended): string;
    //function GetLookupList:TaOPCLookupList;
    function GetLookupListValue(aId:string):string;

    property ImageIndex:integer read FImageIndex write SetImageIndex;
    property SensorKind:integer read FSensorKind write SetSensorKind;
    property LookupList:TaOPCLookupList read FLookupList write SetLookupList;
  end;

  TExtOPCDataLink = class (TaOPCDataLink)
  public
    Index      : integer;
    Sensor     : TSensor;
  end;


implementation

//uses
//  uLookupLists;

{ TSensor }

{
function TSensor.GetLookupList: TaOPCLookupList;
begin
  Result:=nil;
  case SensorKind of
    1:  Result := dmLookupLists.llErrors;
    7:  Result := dmLookupLists.llTankNames;
    8:  Result := dmLookupLists.llProduct;
    15: Result := dmLookupLists.llT1Mode;
    20: Result := dmLookupLists.llSymbols;
    21: Result := dmLookupLists.llSterilizerModes;
    25: Result := dmLookupLists.llOperators;
    26: Result := dmLookupLists.llPriProduct;
    27: Result := dmLookupLists.llPriPackages;
    41: Result := dmLookupLists.llTBA_Phases;
    42: Result := dmLookupLists.llPLMS_TCCS;
    43: Result := dmLookupLists.llPLMS_TSA21;
    44: Result := dmLookupLists.llPLMS_TCBP70;
    45: Result := dmLookupLists.llPLMS_TCAP21;
    46: Result := dmLookupLists.llPLMS_TTS51;
    47: Result := dmLookupLists.llPLMS_TCAP45;
    49: Result := dmLookupLists.llPLMS_Stop;
    70: Result := dmLookupLists.llMaterials;
    71: Result := dmLookupLists.llDrinkSteps;
    77: Result := dmLookupLists.llRecipes;
  end;
end;
}

function TSensor.FormatFloat(aValue: extended): string;
begin
  if IsLookup or IsDate then
    Result := FloatToStr(aValue)
  else
    Result := SysUtils.FormatFloat(DisplayFormat,aValue);

end;

function TSensor.FormatFloatStr(aValue: extended): string;
begin
  if IsLookup then
    Result := GetLookupListValue(FloatToStr(aValue))
  else if IsDate then
    Result := DateTimeToStr(aValue)
  else
    Result := SysUtils.FormatFloat(DisplayFormat,aValue);
 
end;

function TSensor.GetLookupListValue(aId:string): string;
begin
  if Assigned(FLookupList) then
    FLookupList.Lookup(aId,Result);
//    Result :=
//Items.Values[aId]
//  else
//    Result := aId;
end;

function TSensor.IsLookup: boolean;
begin
  Result := Assigned(FLookupList);
end;

procedure TSensor.SetImageIndex(const Value: integer);
begin
  FImageIndex := Value;
end;

procedure TSensor.SetLookupList(const Value: TaOPCLookupList);
begin
  FLookupList := Value;
end;

procedure TSensor.SetSensorKind(const Value: integer);
begin
  FSensorKind := Value;
end;

end.
