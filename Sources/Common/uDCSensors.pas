unit uDCSensors;

interface

uses
  System.Classes,
  uDCObjects,
  aCustomOPCSource, aOPCTCPSource,
  aOPCLookupList, aOPCConnectionList;

type
  TSensor = class(TDCCustomSensor)
  private
    FImageIndex: integer;
    FSensorKind: integer;
    FLookupList: TaOPCLookupList;
    procedure SetSensorKind(const Value: integer);
    procedure SetImageIndex(const Value: integer);
    procedure SetLookupList(const Value: TaOPCLookupList);
    function GetConnetion: TOPCConnectionCollectionItem;
  public
    function IsLookup: boolean;

    function FormatFloat(aValue: extended): string;
    function FormatFloatStr(aValue: extended): string;
    function GetLookupListValue(aId: string): string;

    property ImageIndex: integer read FImageIndex write SetImageIndex;
    property SensorKind: integer read FSensorKind write SetSensorKind;
    property LookupList: TaOPCLookupList read FLookupList write SetLookupList;

    property Connection: TOPCConnectionCollectionItem read GetConnetion;
  end;

  TExtOPCDataLink = class(TaOPCDataLink)
  public
    Index: integer;
    Sensor: TSensor;
  end;

  TDataLinkShiftKind = (
    dlskAbsolute,
    dlskBeginDay,
    dlskBeginWeek,
    dlskBeginMonth,
    dlskBeginYear,
    dlskMoment
    );

  TDataLinkShift = record
    Kind: TDataLinkShiftKind;
    Time: TDateTime;
  end;

  TDataLinkWriteKind = (
    dlwkNone = 0, // запись невозможна
    dlwkOnCurrentMoment = 1, // только на текущий момент времени
    dlwkOnMoment = 3 // на любой момент времени (будущее и прошлое)
    );

  TSensorDataLink = class(TaOPCDataLink)
  private
    FRefTableName: string;
    //FLookupList: TaOPCLookupList;

    FIsShifted: Boolean;
    FShiftTime: TDateTime; // время, на которое у нас есть значение
    FShiftValue: Extended; // само значение
    FDefValue: string;
      // значение, которое будет использовано, если не указан PhysID

    FWriteKind: TDataLinkWriteKind;
    FSensor: TSensor;

    function GetAsBool: boolean;
    function GetAsFloat: extended;
    function GetAsFloatShift: extended;
    function GetAsString: string;
    function GetAsStringShift: string;
    procedure SetRefTableName(const Value: string);
    procedure SetDefValue(const Value: string);
    function GetShiftKindStr: string;

    function GetName: string;
    function GetDisplayFormat: string;
    function GetSensorUnitName: string;
    function GetLookupList: TaOPCLookupList;
    procedure SetName(const Value: string);
    procedure SetDisplayFormat(const Value: string);
    procedure SetSensorUnitName(const Value: string);
    procedure SetLookupList(const Value: TaOPCLookupList);

    function GetSensor: TSensor;
    procedure SetSensor(const Value: TSensor);
    procedure CheckSensor;
  protected
    function GetPhysID: TPhysID; override;
    procedure SetPhysID(const Value: TPhysID); override;

    procedure AssignTo(Dest: TPersistent); override;
  public
    ShiftParams: TDataLinkShift; // параметры вычисления относительного значения

    function GetValueFloat(aShifted: Boolean): Extended;

    property Name: string read GetName write SetName;
    property SensorUnitName: string read GetSensorUnitName write SetSensorUnitName;
    property DisplayFormat: string read GetDisplayFormat write SetDisplayFormat;
    property RefTableName: string read FRefTableName write SetRefTableName;
    property DefValue: string read FDefValue write SetDefValue;

    property LookupList: TaOPCLookupList read GetLookupList write SetLookupList;

    // DataLink может возвращать относительное значение
    property IsShifted: Boolean read FIsShifted write FIsShifted;

    // DataLink доступен для записи
    property WriteKind: TDataLinkWriteKind read FWriteKind write FWriteKind;

    property AsBool: boolean read GetAsBool;
    property AsFloat: extended read GetAsFloat;
    property AsFloatShift: extended read GetAsFloatShift;
    property AsString: string read GetAsString;
    property AsStringShift: string read GetAsStringShift;

    property ShiftKindStr: string read GetShiftKindStr;

    property Sensor: TSensor read GetSensor write SetSensor;
  end;


implementation

uses
  System.SysUtils,
  aOPCUtils,
  aOPCLog;

var
  dotFS: TFormatSettings;


function TSensor.FormatFloat(aValue: extended): string;
begin
  if IsLookup or IsDate then
    Result := FloatToStr(aValue)
  else
    Result := System.SysUtils.FormatFloat(DisplayFormat, aValue);

end;

function TSensor.FormatFloatStr(aValue: extended): string;
begin
  if IsLookup then
    Result := GetLookupListValue(FloatToStr(aValue))
  else if IsDate then
    Result := DateTimeToStr(aValue)
  else
    Result := System.SysUtils.FormatFloat(DisplayFormat, aValue);

end;

function TSensor.GetConnetion: TOPCConnectionCollectionItem;
begin
  Result := TOPCConnectionCollectionItem(Owner);
end;

function TSensor.GetLookupListValue(aId: string): string;
begin
  if Assigned(FLookupList) then
    FLookupList.Lookup(aId, Result);
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

{ TSensorDataLink }

procedure TSensorDataLink.AssignTo(Dest: TPersistent);
var
  aDest: TSensorDataLink;
begin
  inherited AssignTo(Dest);

  if Dest is TSensorDataLink then
  begin
    aDest := TSensorDataLink(Dest);
    aDest.Name := Name;
    aDest.SensorUnitName := SensorUnitName;
    aDest.DisplayFormat := DisplayFormat;
    aDest.RefTableName := RefTableName;
    aDest.LookupList := LookupList;
  end;
end;

procedure TSensorDataLink.CheckSensor;
begin
  Assert(Assigned(FSensor));
end;

function TSensorDataLink.GetAsBool: boolean;
begin
  if PhysID = '' then
    Result := StrToBoolDef(DefValue, false)
  else
    Result := StrToBoolDef(Value, false);
end;

function TSensorDataLink.GetAsFloat: extended;
begin
  if PhysID = '' then
    Result := StrToFloatDef(DefValue, 0, dotFS)
  else
  begin
    try
      Result := StrToFloat(Value);
    except
      on e: Exception do
      begin
        Result := 0;
        //OPCLog.WriteToLogFmt('DataLink %s: %s', [Name, e.Message]);
      end;
    end;
  end;
end;

function TSensorDataLink.GetAsFloatShift: extended;
var
  aShiftTime: TDateTime;
  dow: integer;
  d, m, y: word;
  aMoment: TDateTime;
begin
  if PhysID = '' then
    Result := GetAsFloat
  else
  begin
    case ShiftParams.Kind of
      dlskAbsolute: // абсолютное значение
        aShiftTime := 0;
      dlskBeginDay: // с начала дня
        aShiftTime := Trunc(Moment);
      dlskBeginWeek: // с начала недели
        begin
          // день недели по нашему : пн-0, вт-1 ... вс-6
          dow := DayOfWeek(Moment);
          if dow = 1 then
            dow := 6
          else
            dow := dow - 2;

          aShiftTime := Trunc(Moment - dow);
        end;
      dlskBeginMonth: // с начала месяца
        begin
          DecodeDate(Moment, y, m, d);
          aShiftTime := EncodeDate(y, m, 1);
        end;
      dlskBeginYear: // с начала года
        begin
          DecodeDate(Moment, y, m, d);
          aShiftTime := EncodeDate(y, 1, 1);
        end;
      dlskMoment: // на заданный момент времени
        aShiftTime := ShiftParams.Time;
    end;

    // расчитатываем значение на дату, если дата изменилась
    if aShiftTime <> FShiftTime then
    begin
      if Assigned(RealSource)
        and (RealSource is TaOPCTCPSource)
        and RealSource.Active then
      begin
        if aShiftTime = 0 then
        begin
          FShiftValue := 0;
        end
        else
        begin
          aMoment := aShiftTime;
          try
            FShiftValue := StrToFloat(
              TaOPCTCPSource(RealSource).GetSensorValueOnMoment(PhysID,
                aMoment),
              RealSource.OpcFS);
          except
            on e: Exception do
            begin
              //OPCLog.WriteToLogFmt('GetSensorValueOnMoment: %s : %s', [PhysID, e.Message]);
              FShiftValue := 0;
            end;
          end;
        end;
        FShiftTime := aShiftTime;
      end;
    end;

    Result := GetAsFloat - FShiftValue;
  end;
end;

function TSensorDataLink.GetAsString: string;
var
  aValue: string;
begin
  if PhysID = '' then
    aValue := DefValue
  else
    aValue := Value;

  if aValue = '' then
    Result := ''
  else if Assigned(LookupList) then
    LookupList.Lookup(aValue, Result)
  else
    Result := FormatValue(AsFloat, DisplayFormat);
end;

function TSensorDataLink.GetAsStringShift: string;
var
  aValue: string;
begin
  if PhysID = '' then
    aValue := DefValue
  else
    aValue := Value;

  if aValue = '' then
    Result := ''
  else if Assigned(LookupList) then
    LookupList.Lookup(aValue, Result)
  else
    Result := FormatValue(AsFloatShift, DisplayFormat);
end;

function TSensorDataLink.GetDisplayFormat: string;
begin
  CheckSensor;
  Result := Sensor.DisplayFormat;
end;

function TSensorDataLink.GetLookupList: TaOPCLookupList;
begin
  CheckSensor;
  Result := Sensor.LookupList;
end;

function TSensorDataLink.GetName: string;
begin
  CheckSensor;
  Result := Sensor.Name
end;

function TSensorDataLink.GetPhysID: TPhysID;
begin
  CheckSensor;
  Result := Sensor.IdStr;
end;

function TSensorDataLink.GetSensor: TSensor;
begin
  Result := FSensor;
end;

function TSensorDataLink.GetShiftKindStr: string;
begin
  case ShiftParams.Kind of
    dlskAbsolute:
      Result := '';
    dlskBeginDay:
      Result := 'с начала дня';
    dlskBeginWeek:
      Result := 'с начала недели';
    dlskBeginMonth:
      Result := 'с начала месяца';
    dlskBeginYear:
      Result := 'с начала года';
    dlskMoment:
      Result := 'с ' + DateTimeToStr(ShiftParams.Time);
  end;
end;

function TSensorDataLink.GetSensorUnitName: string;
begin
  CheckSensor;
  Result := Sensor.SensorUnitName;
end;

function TSensorDataLink.GetValueFloat(aShifted: Boolean): Extended;
begin
  if aShifted then
    Result := GetAsFloatShift
  else
    Result := GetAsFloat;
end;

procedure TSensorDataLink.SetDefValue(const Value: string);
begin
  FDefValue := Value;
end;

procedure TSensorDataLink.SetDisplayFormat(const Value: string);
begin
  CheckSensor;
  Sensor.DisplayFormat := Value;
end;

procedure TSensorDataLink.SetLookupList(const Value: TaOPCLookupList);
begin
  CheckSensor;
  Sensor.LookupList := Value;
end;

procedure TSensorDataLink.SetName(const Value: string);
begin
  CheckSensor;
  Sensor.Name := Value;
end;

procedure TSensorDataLink.SetPhysID(const Value: TPhysID);
begin
  inherited;
  CheckSensor;
  Sensor.IdStr := Value;
end;

procedure TSensorDataLink.SetRefTableName(const Value: string);
begin
  FRefTableName := Value;
end;

procedure TSensorDataLink.SetSensor(const Value: TSensor);
begin
  FSensor := Value;
end;

procedure TSensorDataLink.SetSensorUnitName(const Value: string);
begin
  CheckSensor;
  Sensor.SensorUnitName := Value;
end;

initialization
  GetLocaleFormatSettings(0, dotFS);
  dotFS.DecimalSeparator := '.';


end.
