unit uDataLinkedClasses;

interface

uses
  System.Classes, System.IniFiles, System.Contnrs,
  System.Generics.Collections,
  uExprEval,
  aOPCSource, aCustomOPCSource, aCustomOPCTCPSource, //aOPCCinema,
  aOPCConnectionList,
  aOPCLookupList;
  //uEvents;

type
  TCustomDataPoint = class;

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
    dlwkNone = 0,               // запись невозможна
    dlwkOnCurrentMoment = 1,    // только на текущий момент времени
    dlwkOnMoment = 3            // на любой момент времени (будущее и прошлое)
    );


  // Link к датчику, с дополнительными возможностями
  // может вычитывать и записывать свои параметры
  TDataLinkExtInfo = class(TaOPCDataLink)
  private
    FName: string;
    FSensorUnitName: string;
    FDisplayFormat: string;
    FRefTableName: string;
    FDataPoint: TCustomDataPoint;
    FLookupList: TaOPCLookupList;
    FSectionName: string;

    FIsShifted: Boolean;
    FShiftTime: TDateTime;        // время, на которое у нас есть значение
    FShiftValue: Extended;        // само значение
    FDefValue: string;            // значение, которое будет использовано, если не указан PhysID

    FStoredShiftParams: TDataLinkShift;
    FWriteKind: TDataLinkWriteKind;

    function GetAsBool: boolean;
    function GetAsFloat: extended;
    function GetAsFloatShift: extended;
    function GetAsString: string;
    function GetAsStringShift: string;
    procedure SetDisplayFormat(const Value: string);
    procedure SetName(const Value: string);
    procedure SetSensorUnitName(const Value: string);
    procedure SetLookupList(const Value: TaOPCLookupList);
    procedure SetRefTableName(const Value: string);
    procedure SetDefValue(const Value: string);
    procedure SetSectionName(const Value: string);
    function GetShiftKindStr: string;
    function GetAsInteger: Integer;
    function GetFullName: string;
  protected
    procedure AssignTo(Dest: TPersistent); override;
  public
    ShiftParams: TDataLinkShift; // параметры вычисления относительного значения

    procedure Load(aIniFile: TCustomIniFile; aSection: string); virtual;
    procedure Save(aIniFile: TCustomIniFile; aSection: string;
      aFull: Boolean = false); virtual;

    procedure StoreShiftParams;
    procedure RestoreShiftParams;

    function GetValueFloat(aShifted: Boolean): Extended;

    property Name: string read FName write SetName;
    property FullName: string read GetFullName;
    property SensorUnitName: string read FSensorUnitName write SetSensorUnitName;
    property DisplayFormat: string read FDisplayFormat write SetDisplayFormat;
    property RefTableName: string read FRefTableName write SetRefTableName;
    property DefValue: string read FDefValue write SetDefValue;

    property LookupList: TaOPCLookupList read FLookupList write SetLookupList;
    property SectionName: string read FSectionName write SetSectionName;

    // DataLink может возвращать относительное значение
    property IsShifted: Boolean read FIsShifted write FIsShifted;

    // DataLink доступен для записи
    property WriteKind: TDataLinkWriteKind read FWriteKind write FWriteKind;

    property AsBool: boolean read GetAsBool;
    property AsInteger: Integer read GetAsInteger;
    property AsFloat: extended read GetAsFloat;
    property AsFloatShift: extended read GetAsFloatShift;
    property AsString: string read GetAsString;
    property AsStringShift: string read GetAsStringShift;

    property ShiftKindStr: string read GetShiftKindStr;

    property DataPoint: TCustomDataPoint read FDataPoint write FDataPoint;
  end;

  TDataLinkExtInfoList = class(TObjectList<TDataLinkExtInfo>)
  end;

  // класс - прослойка между объектами НАБЛЮДЕНИЯ (TCustomDataPoint) и
  //         объектами ВИЗУАЛИЗАЦИИ (это могут быть объекты любого класса,
  //         они агрегируют TDataPointLink и работают через него)
  // через такие линки объекты визуализации получают сигнал об изменениях
  TDataPointLink = class
  private
    FDataPoint: TCustomDataPoint;
    FOnChangeData: TNotifyEvent;
    procedure SetDataPoint(const Value: TCustomDataPoint);
    function GetDataPoint: TCustomDataPoint;
  public
    constructor Create;
    destructor Destroy; override;
    // объект DataPoint вызывает ChangeData, когда его данные изменились
    procedure ChangeData(Sender: TObject);
    // объект, который является источником данных
    property DataPoint: TCustomDataPoint read GetDataPoint write SetDataPoint;
    // событие вызывается при изменении данных объекта DataPoint
    property OnChangeData: TNotifyEvent read FOnChangeData write FOnChangeData;
  end;

  TDataPointLinkList = class(TObjectList<TDataPointLink>)
  end;


  // РОДИТЕЛЬСКИЙ класс наблюдаемых объектов : авто, комбайн, метео/насосная станция
  TCustomDataPoint = class(TPersistent)
  private
    FSectionName: string;
    FParentID: integer;
    FName: string;

    // если true, обновление визуальных объектов (FDataPointLinks) не выполняется
    FLocked: boolean;
    // список датчиков объекта
    FDataLinks: TDataLinkExtInfoList;
    // список ссылок на визульные объекты, связанные с этим объектом
    FDataPointLinks: TDataPointLinkList;

    FLastChangeTime: TDateTime;

    FStatus: string;
    FLastStatus: string;
    FStatusStartTime: TDateTime;

    FOnChange: TNotifyEvent;
    FChangedCount: integer;

    FVisible: boolean;

    FParams: TStrings;
    FFields: TStrings;
    FStatusDescription: string;
    FPredStatus: string;

    FStatusEvalExpr: string;
    FStatusEvalFunc: TCompiledExpression;

    FEval: TExpressionCompiler;
    FOnSourceChanged: TNotifyEvent;

    FShiftParams: TDataLinkShift;
    FStoredShiftParams: TDataLinkShift;
    //FEvents: TEvents;
    FEnabled: Boolean;
    FID: string;
    FRealDataPoint: TCustomDataPoint;

    procedure SetName(const Value: string);
    procedure SetVisible(const Value: boolean);

    function GetUID: string;
    procedure SetParentID(const Value: integer);
    procedure SetSectionName(const Value: string);
    procedure SetFields(const Value: TStrings);
    procedure SetStatusDescription(const Value: string);
    function GetEval: TExpressionCompiler;
    procedure SetShiftParams(const Value: TDataLinkShift);
    function GetServerDate: TDateTime;
    procedure SetStatusEvalExpr(const Value: string);
    procedure SetEnabled(const Value: Boolean);
    procedure SetID(const Value: string);
    procedure SetRealDataPoint(const Value: TCustomDataPoint);
  protected
    procedure AssignTo(Dest: TPersistent); override;

    function NewDataLink(aSectionName: string;
      aShifted: Boolean = False; aShiftKind: TDataLinkShiftKind = dlskAbsolute;
      aWriteKind: TDataLinkWriteKind = dlwkNone): TDataLinkExtInfo;

    function GetDate: TDateTime; virtual;
    function GetType: integer; virtual;
    function GetLayerName: string; virtual;

    function GetOPCSource: TaCustomOPCSource; virtual;
    procedure SetOPCSource(const Value: TaCustomOPCSource); virtual;

    function GetRealSource: TaCustomOPCSource; virtual;

    function GetIsNoData: boolean; virtual;
    procedure CalcStatus(aNewChangeTime: TDateTime); virtual;
    function GetError: string; virtual;
    function GetStatusDescription: string; virtual;

    procedure UpdateDataPointLinks(Sender: TObject);

    procedure ChangeDataLink(Sender: TObject);
    procedure PrepVars; virtual;

    property Eval: TExpressionCompiler read GetEval;
  public
    constructor Create; virtual;
    constructor CreateCopy(aDataPoint: TCustomDataPoint); virtual;

    destructor Destroy; override;

    procedure Load(aIniFile: TCustomIniFile; aSection: string); virtual;
    procedure Save(aIniFile: TCustomIniFile; aSection: string); virtual;

    procedure LoadFromText(aText: string; aSection: string);

    procedure InitFromID; virtual;
    procedure InitLookups(aConnection: TOPCConnectionCollectionItem); virtual;

    procedure Lock;
    procedure UnLock;

    procedure BeginUpdate;
    procedure EndUpdate;

    procedure StoreShiftParams;
    procedure RestoreShiftParams;

    procedure ChangeProps(Sender: TObject);
    procedure ChangeData(Sender: TObject);

    function DataLinkByName(aName: string): TDataLinkExtInfo;
    function DataLinkIsActive(aName: string): Boolean;

    function GetPermissions: string;

    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnSourceChanged: TNotifyEvent read FOnSourceChanged write FOnSourceChanged;

    // список связующих объектов (другими словами датчиков)
    property DataLinks: TDataLinkExtInfoList read FDataLinks;

    property SectionName: string read FSectionName write SetSectionName;

    property ID: string read FID write SetID;
    property ParentID: integer read FParentID write SetParentID;

    property Name: string read FName write SetName;
    property LayerName: string read GetLayerName;

    property Enabled: Boolean read FEnabled write SetEnabled;
    property Visible: boolean read FVisible write SetVisible;

    property UID: string read GetUID;

    property OPCSource: TaCustomOPCSource read GetOPCSource write SetOPCSource;
    property RealSource: TaCustomOPCSource read GetRealSource;

    property IsNoData: boolean read GetIsNoData;

    property Params: TStrings read FParams;
    property Fields: TStrings read FFields write SetFields;

    property Status: string read FStatus;
    property PredStatus: string read FPredStatus;
    property LastStatus: string read FLastStatus;
    property StatusStartTime: TDateTime read FStatusStartTime;

    property StatusEvalExpr: string read FStatusEvalExpr write SetStatusEvalExpr;

    property StatusDescription: string read GetStatusDescription write SetStatusDescription;
    property Error: string read GetError;

    property Date: TDateTime read GetDate;
    property ServerDate: TDateTime read GetServerDate;
    property ShiftParams: TDataLinkShift read FShiftParams write SetShiftParams;

    //property Events: TEvents read FEvents;

    property RealDataPoint: TCustomDataPoint read FRealDataPoint write SetRealDataPoint;

  end;

  TCustomDataPointList = class(TObjectList<TCustomDataPoint>)
  end;



implementation

uses
  System.SysUtils,
  aOPCUtils, uDCObjects,
  uMemIniFileEx,
  aOPCLog;

const
  sIniName = 'Name';
  sIniParentID = 'ParentID';
  sIniKind = 'Kind';
  sIniType = 'Type';
  sIniParams = 'Params';
  sIniFields = 'Fields';
  sIniStatusEvalExpr = 'StatusEvalExpr';
  sIniEvents = 'Events';
//  sIniRefuelingEvalExpr = 'RefuelingEvalExpr';
//  sIniFuelDrainEvalExpr = 'FuelDrainEvalExpr';
//  sIniMinRefuelingToRep = 'MinRefuelingToRep';
//  sIniMinFuelDrainToRep = 'MinFuelDrainToRep';


{ TDataLinkExtInfo }

procedure TDataLinkExtInfo.AssignTo(Dest: TPersistent);
var
  aDest: TDataLinkExtInfo;
begin
  inherited AssignTo(Dest);

  if Dest is TDataLinkExtInfo then
  begin
    aDest := TDataLinkExtInfo(Dest);
    aDest.Name := Name;
    aDest.SensorUnitName := SensorUnitName;
    aDest.DisplayFormat := DisplayFormat;
    aDest.RefTableName := RefTableName;
    aDest.LookupList := LookupList;
    //aDest.SectionName := SectionName;
    //aDest.DataPoint := DataPoint;
  end;
end;

function TDataLinkExtInfo.GetAsBool: boolean;
begin
  if PhysID = '' then
    Result := StrToBoolDef(DefValue, false)
  else
    Result := StrToBoolDef(Value, false);
end;

function TDataLinkExtInfo.GetAsFloat: extended;
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
        OPCLog.WriteToLogFmt('DataLink %s: %s', [Name, e.Message]);
      end;
    end;
  end;
end;

function TDataLinkExtInfo.GetAsInteger: Integer;
begin
  Result := Trunc(AsFloat);
end;

function TDataLinkExtInfo.GetAsString: string;
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

function TDataLinkExtInfo.GetAsStringShift: string;
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

function TDataLinkExtInfo.GetFullName: string;
begin
  if Assigned(DataPoint) then
    Result := DataPoint.Name + '.' + Name
  else
    Result := Name;
end;

function TDataLinkExtInfo.GetShiftKindStr: string;
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
      Result := 'с '+DateTimeToStr(ShiftParams.Time);
  end;
end;

function TDataLinkExtInfo.GetValueFloat(aShifted: Boolean): Extended;
begin
  if aShifted then
    Result := GetAsFloatShift
  else
    Result := GetAsFloat;
end;

function TDataLinkExtInfo.GetAsFloatShift: extended;
var
  aShiftTime: TDateTime;
  dow: integer;
  d,m,y: word;
  aMoment: TDateTime;
begin
  if PhysID = '' then
    Result := GetAsFloat
  else
  begin
    case ShiftParams.Kind of
      dlskAbsolute:   // абсолютное значение
        aShiftTime := 0;
      dlskBeginDay:   // с начала дня
        aShiftTime := Trunc(DataPoint.Date);
      dlskBeginWeek:  // с начала недели
      begin
        // день недели по нашему : пн-0, вт-1 ... вс-6
        dow := DayOfWeek(DataPoint.Date);
        if dow = 1 then
          dow := 6
        else
          dow := dow - 2;

        aShiftTime := Trunc(DataPoint.Date - dow);
      end;
      dlskBeginMonth: // с начала месяца
      begin
        DecodeDate(DataPoint.Date, y, m, d);
        aShiftTime := EncodeDate(y, m, 1);
      end;
      dlskBeginYear: // с начала года
      begin
        DecodeDate(DataPoint.Date, y, m, d);
        aShiftTime := EncodeDate(y, 1, 1);
      end;
      dlskMoment:   // на заданный момент времени
        aShiftTime := ShiftParams.Time;
      else
        raise Exception.Create('Unknown ShiftParams.Kind');
    end;

    // расчитатываем значение на дату, если дата изменилась
    if aShiftTime <> FShiftTime then
    begin
      if Assigned(RealSource)
        and (RealSource is TaCustomOPCTCPSource)
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
              TaCustomOPCTCPSource(RealSource).GetSensorValueOnMoment(PhysID, aMoment),
              RealSource.OpcFS);
          except
            on e: Exception do
            begin
              OPCLog.WriteToLogFmt('GetSensorValueOnMoment: %s : %s', [PhysID, e.Message]);
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


procedure TDataLinkExtInfo.Load(aIniFile: TCustomIniFile; aSection: string);
var
  aStairs: integer;
begin
  PhysID := aIniFile.ReadString(aSection, 'PhysID', PhysID);
  Name := aIniFile.ReadString(aSection, 'Name', Name);
  SensorUnitName := aIniFile.ReadString(aSection, 'UnitName', UnitName);
  DisplayFormat := aIniFile.ReadString(aSection, 'DisplayFormat', DisplayFormat);
  FRefTableName := aIniFile.ReadString(aSection, 'RefTableName', FRefTableName);
  aStairs := aIniFile.ReadInteger(aSection, 'StairsOptions', StairsOptionsSetToInt(StairsOptions));
  case aStairs of
    0: StairsOptions := [soIncrease, soDecrease];
    1: StairsOptions := [];
    2: StairsOptions := [soIncrease];
    3: StairsOptions := [soDecrease];
  end;
  IsShifted := aIniFile.ReadBool(aSection, 'Shifted', IsShifted);
  ShiftParams.Kind := TDataLinkShiftKind(
    aIniFile.ReadInteger(aSection, 'ShiftKind', Ord(ShiftParams.Kind)));

  WriteKind := TDataLinkWriteKind(
    aIniFile.ReadInteger(aSection, 'WriteKind', Ord(WriteKind)));

  DefValue := aIniFile.ReadString(aSection, 'DefValue', DefValue);
end;

procedure TDataLinkExtInfo.RestoreShiftParams;
begin
  ShiftParams := FStoredShiftParams;
end;

procedure TDataLinkExtInfo.Save(aIniFile: TCustomIniFile; aSection: string;
  aFull: Boolean);
var
  aStairs: integer;

  procedure WriteIfNoDef(aName, aValue, aDef: string); overload;
  begin
    if aFull or (aValue <> aDef) then
      aIniFile.WriteString(aSection, aName, aValue)
    else
      aIniFile.DeleteKey(aSection, aName);
  end;

  procedure WriteIfNoDef(aName: string; aValue, aDef: Integer); overload;
  begin
    if aFull or (aValue <> aDef) then
      aIniFile.WriteInteger(aSection, aName, aValue)
    else
      aIniFile.DeleteKey(aSection, aName);
  end;

  procedure WriteIfNoDef(aName: string; aValue, aDef: Boolean); overload;
  begin
    if aFull or (aValue <> aDef) then
      aIniFile.WriteBool(aSection, aName, aValue)
    else
      aIniFile.DeleteKey(aSection, aName);
  end;

begin
  if not aFull and (PhysID = '') then
  begin
    aIniFile.EraseSection(aSection);
    Exit;
  end;

  WriteIfNoDef('PhysID', PhysID, '');
  WriteIfNoDef('Name', Name, '');
  WriteIfNoDef('UnitName', UnitName, '');
  WriteIfNoDef('DisplayFormat', DisplayFormat, '');
  WriteIfNoDef('RefTableName', RefTableName, '');

//  if StairsOptions = [soIncrease, soDecrease] then
//    aStairs := 0
//  else if StairsOptions = [] then
//    aStairs := 1
//  else if StairsOptions = [soIncrease] then
//    aStairs := 2
//  else if StairsOptions = [soDecrease] then
//    aStairs := 3;

  aStairs := StairsOptionsSetToInt(StairsOptions);

  WriteIfNoDef('StairsOptions', aStairs, 0);
  WriteIfNoDef('Shifted', IsShifted, false);
  if IsShifted then
    aIniFile.WriteInteger(aSection, 'ShiftKind', Ord(ShiftParams.Kind))
  else
    aIniFile.DeleteKey(aSection, 'ShiftKind');

  WriteIfNoDef('WriteKind', Ord(WriteKind), Ord(dlwkNone));
  WriteIfNoDef('DefValue', DefValue, '');

end;

procedure TDataLinkExtInfo.SetDefValue(const Value: string);
begin
  FDefValue := Value;
end;

procedure TDataLinkExtInfo.SetDisplayFormat(const Value: string);
begin
  FDisplayFormat := Value;
end;

procedure TDataLinkExtInfo.SetLookupList(const Value: TaOPCLookupList);
begin
  FLookupList := Value;
end;

procedure TDataLinkExtInfo.SetName(const Value: string);
begin
  FName := Value;
end;

procedure TDataLinkExtInfo.SetRefTableName(const Value: string);
begin
  FRefTableName := Value;
end;

procedure TDataLinkExtInfo.SetSectionName(const Value: string);
begin
  FSectionName := Value;
end;

procedure TDataLinkExtInfo.SetSensorUnitName(const Value: string);
begin
  FSensorUnitName := Value;
end;

procedure TDataLinkExtInfo.StoreShiftParams;
begin
  FStoredShiftParams := ShiftParams;
end;

{ TDataPointLink }

procedure TDataPointLink.ChangeData(Sender: TObject);
begin
  if Assigned(FOnChangeData) then
    FOnChangeData(Sender);
end;

constructor TDataPointLink.Create;
begin
  FDataPoint := nil;
end;

destructor TDataPointLink.Destroy;
begin
  DataPoint := nil;
  inherited;
end;

function TDataPointLink.GetDataPoint: TCustomDataPoint;
begin
  Result := FDataPoint;
end;

procedure TDataPointLink.SetDataPoint(const Value: TCustomDataPoint);
begin
  if FDataPoint = Value then
    exit;

  // удаляем из списка линков старого объекта
  if Assigned(FDataPoint) then
    FDataPoint.FDataPointLinks.Remove(Self);

  // добавляем в спискоа линков нового объекта
  if Assigned(Value) then
    Value.FDataPointLinks.Add(Self);

  FDataPoint := Value;
  // сообщим клиентам, что изменился источник данных DataPoint
  ChangeData(Value);
end;


{ TCustomDataPoint }

procedure TCustomDataPoint.AssignTo(Dest: TPersistent);
var
  i: Integer;
  aDest: TCustomDataPoint;
  aDataLink, aDataLinkDest: TDataLinkExtInfo;
begin
  if not (Dest is TCustomDataPoint) then
    inherited AssignTo(Dest)
  else
  begin
    aDest := TCustomDataPoint(Dest);
    aDest.FSectionName := SectionName;
    aDest.FName := Name;
    aDest.FVisible := Visible;
    aDest.FEnabled := Enabled;

    aDest.FOnChange := OnChange;

    aDest.FFields.Assign(Fields);
    aDest.FParams.Assign(Params);

    for i := 0 to DataLinks.Count - 1 do
    begin
      aDataLink := TDataLinkExtInfo(DataLinks[i]);
      aDataLinkDest := TDataLinkExtInfo(aDest.DataLinks[i]);
      aDataLinkDest.Assign(aDataLink);
      aDataLinkDest.DataPoint := aDest;
    end;

    //aDest.OPCSource := OPCSource;

  end;

end;

procedure TCustomDataPoint.BeginUpdate;
begin
  FLocked := true;
end;

procedure TCustomDataPoint.CalcStatus(aNewChangeTime: TDateTime);
begin
end;

procedure TCustomDataPoint.ChangeData(Sender: TObject);
begin
  if (FChangedCount > 0) then
  begin
    //if OPCSource is TaOPCCinema then
    //  CalcLocation;
    try
      if Sender is TaOPCDataLink then
      begin
        CalcStatus(TaOPCDataLink(Sender).Moment);
      end;

      if (not FLocked) then
      begin
        FChangedCount := 0;

        //UpdateDataPointLinks(Sender);
        UpdateDataPointLinks(Self);

        PrepVars;
        //Events.Check(0, ServerDate);

        if Assigned(FOnChange) then
          FOnChange(Self);
      end;

    except
      on e: Exception do
      begin
        {$IFDEF UseExceptionLog}
        ExceptionLog.StandardEurekaNotify(e, ExceptAddr);
        {$ENDIF}
        OPCLog.WriteToLogFmt('%s(%s).ChangeData: %s', [Name, ID, e.Message]);
      end;
    end;
  end;
end;

procedure TCustomDataPoint.ChangeDataLink(Sender: TObject);
begin
  inc(FChangedCount);
end;

procedure TCustomDataPoint.ChangeProps(Sender: TObject);
begin
  Inc(FChangedCount);
  ChangeData(Sender);
end;

function TCustomDataPoint.GetPermissions: string;
var
  aID: string;
begin
  Result := '';

  Assert(Assigned(RealSource));
  if ID <> '' then
    aID := ID
  else if DataLinks.Count > 0 then
    aID := TDataLinkExtInfo(DataLinks[0]).PhysID;

  if aID = '' then
    Exit;

  Result := TaCustomOPCTCPSource(RealSource).GetPermissions(aID);
end;

constructor TCustomDataPoint.Create;
begin
  FDataLinks := TDataLinkExtInfoList.Create;
  FDataPointLinks := TDataPointLinkList.Create(False);
  FParams := TStringList.Create;
  FFields := TStringList.Create;
  //FEvents := TEvents.Create(Eval);
  FRealDataPoint := Self;
end;

constructor TCustomDataPoint.CreateCopy(aDataPoint: TCustomDataPoint);
begin
  Create;
  RealDataPoint := aDataPoint.RealDataPoint;
  Assign(aDataPoint);
end;

function TCustomDataPoint.DataLinkByName(aName: string): TDataLinkExtInfo;
var
  i: integer;
begin
  Result := nil;
  for i := 0 to DataLinks.Count - 1 do
  begin
    if AnsiCompareText(TDataLinkExtInfo(DataLinks[i]).Name, aName) = 0 then
    begin
      Result := TDataLinkExtInfo(DataLinks[i]);
      exit;
    end;
  end;
end;

function TCustomDataPoint.DataLinkIsActive(aName: string): Boolean;
var
  aDataLink: TDataLinkExtInfo;
begin
  aDataLink := DataLinkByName(aName);// 'Уровень топлива');
  Result := Assigned(aDataLink) and (aDataLink.PhysID <> '');
end;

destructor TCustomDataPoint.Destroy;
var
  i: integer;
begin
  for i := FDataPointLinks.Count - 1 downto 0 do
    FDataPointLinks[i].DataPoint := nil;

  FDataPointLinks.Free;
  FDataLinks.Free;

  FFields.Free;
  FParams.Free;

  FEval.Free;
  //FEvents.Free;

  inherited;
end;

procedure TCustomDataPoint.EndUpdate;
begin
  FLocked := false;
  if FChangedCount > 0 then
    ChangeData(Self);
end;

function TCustomDataPoint.GetDate: TDateTime;
begin
  if Assigned(OPCSource) then
  begin
//    if (OPCSource is TaOPCCinema) then
//      Result := TaOPCCinema(OPCSource).CurrentMoment
//    else
    if (OPCSource is TaCustomOPCTCPSource) then
      Result := TaCustomOPCTCPSource(OPCSource).CurrentMoment
    else
      Result := Now;
  end
  else
    Result := Now;
end;

function TCustomDataPoint.GetError: string;
begin
  Result := '';
end;

function TCustomDataPoint.GetEval: TExpressionCompiler;
begin
  if Not Assigned(FEval) then
    FEval := TExpressionCompiler.Create;
  Result := FEval;
end;

function TCustomDataPoint.GetIsNoData: boolean;
begin
  Result := false;
end;

function TCustomDataPoint.GetLayerName: string;
begin
  Result := Name;
end;

function TCustomDataPoint.GetOPCSource: TaCustomOPCSource;
var
  i: Integer;
begin
  Result := nil;
  // вернем первый попавшийся
  for i := 0 to FDataLinks.Count - 1 do
  begin
    if Assigned(FDataLinks[i].OPCSource) then
      Exit(FDataLinks[i].OPCSource);
  end;
//    if FDataLinks.Count > 0 then
//      Result := FDataLinks[0].OPCSource
//    else
//      Result := nil;

end;

function TCustomDataPoint.GetRealSource: TaCustomOPCSource;
var
  i: Integer;
begin
  Result := nil;
  // вернем первый попавшийся
  for i := 0 to FDataLinks.Count - 1 do
  begin
    if Assigned(FDataLinks[i].RealSource) then
      Exit(FDataLinks[i].RealSource);
  end;
//  if FDataLinks.Count > 0 then
//    Result := FDataLinks[0].RealSource
//  else
//    Result := nil;
end;

function TCustomDataPoint.GetServerDate: TDateTime;
begin
  if Assigned(OPCSource) then
  begin
//    if (OPCSource is TaOPCCinema) then
//      Result := TaOPCCinema(OPCSource).CurrentMoment
//    else
    if (OPCSource is TaCustomOPCTCPSource) then
      Result := TaCustomOPCTCPSource(OPCSource).CurrentMoment
    else
      Result := Now;
  end
  else
    Result := Now;
end;

function TCustomDataPoint.GetStatusDescription: string;
begin
  Result := '';
end;

function TCustomDataPoint.GetType: integer;
begin
  Result := 0;
end;

function TCustomDataPoint.GetUID: string;
begin
  Result := Fields.Values['UID'];
  if Result = '' then
    Result := SectionName;
end;

procedure TCustomDataPoint.InitFromID;
begin

end;

procedure TCustomDataPoint.InitLookups(aConnection:
  TOPCConnectionCollectionItem);
var
  i: Integer;
  aDataLink: TDataLinkExtInfo;
begin
  for i := 0 to FDataLinks.Count - 1 do
  begin
    aDataLink := FDataLinks[i];
    if aDataLink.RefTableName <> '' then
      aDataLink.LookupList :=
        aConnection.GetLookupByTableName(aDataLink.RefTableName);
  end;
end;

procedure TCustomDataPoint.Load(aIniFile: TCustomIniFile; aSection: string);
var
  i: Integer;
  aDataLink: TDataLinkExtInfo;
begin
  ID := aIniFile.ReadString(aSection, 'ID', '');
  ParentID := aIniFile.ReadInteger(aSection, sIniParentID, 0);

  Name := aIniFile.ReadString(aSection, sIniName, '');

  //Kind := TDataPointKind(aIniFile.ReadInteger(aSection, sIniKind, 0));
  StatusEvalExpr := aIniFile.ReadString(aSection, sIniStatusEvalExpr, '');

  aIniFile.ReadSectionValues(aSection + '\' + sIniParams, Params);
  aIniFile.ReadSectionValues(aSection + '\' + sIniFields, Fields);

  for i := 0 to FDataLinks.Count - 1 do
  begin
    aDataLink := FDataLinks[i];
    if aDataLink.SectionName <> '' then
      aDataLink.Load(aIniFile, aSection + '\' + aDataLink.SectionName);
  end;

//  Events.Load(aIniFile, aSection + '\' + sIniEvents);
//  for i := 0 to Events.Count - 1 do
//    Events[i].ObjectName := Name;

end;

procedure TCustomDataPoint.LoadFromText(aText, aSection: string);
var
  aIni: TMemIniFileEx;
  //s: TStringList;
begin
  if aText = '' then
    Exit;

  aIni := TMemIniFileEx.CreateFromText(aText);
  try
    //aIni.SetStrings(s);
    Load(aIni, aSection);
  finally
    aIni.Free;
  end;
end;

procedure TCustomDataPoint.Lock;
begin
  FLocked := True;
end;

function TCustomDataPoint.NewDataLink(aSectionName: string;
  aShifted: Boolean; aShiftKind: TDataLinkShiftKind;
  aWriteKind: TDataLinkWriteKind): TDataLinkExtInfo;
begin
  // создаём DataLink
  Result := TDataLinkExtInfo.Create(Self);
  Result.SectionName := aSectionName;
  //  Result.PhysID := aID;
  //  Result.Name := aName;
  //  Result.UnitName := aUnitName;
  //  Result.DisplayFormat := aDisplayFormat;

  Result.DataPoint := Self;
  Result.IsShifted := aShifted;
  Result.ShiftParams.Kind := aShiftKind;
  Result.WriteKind := aWriteKind;
  Result.OnChangeData := ChangeDataLink;
  if FDataLinks.Count = 0 then
    Result.OnRequest := ChangeData;

  // добавляем в список для удобства групповой обработки (удаление, формирование списков)
  FDataLinks.Add(Result);
end;

procedure TCustomDataPoint.PrepVars;
begin

end;

procedure TCustomDataPoint.RestoreShiftParams;
begin
  ShiftParams := FStoredShiftParams;
end;

procedure TCustomDataPoint.Save(aIniFile: TCustomIniFile; aSection: string);
var
  i: Integer;
  aDataLink: TDataLinkExtInfo;
begin
  aIniFile.WriteString(aSection, '*', Format('******************** %s ********************=*', [SectionName]));
  aIniFile.WriteInteger(aSection, sIniType, GetType);

  aIniFile.WriteString(aSection, 'ID', ID);
  aIniFile.WriteInteger(aSection, sIniParentID, ParentID);

  aIniFile.WriteString(aSection, sIniName, Name);

  //aIniFile.WriteInteger(aSection, sIniKind, ord(Kind));
  aIniFile.WriteString(aSection, sIniStatusEvalExpr, StatusEvalExpr);

  //aIniFile.EraseSection(aSection+'\Params');
  for i := 0 to Params.Count - 1 do
    aIniFile.WriteString(aSection + '\' + sIniParams, Params.Names[i],
      Params.ValueFromIndex[i]);

  //aIniFile.EraseSection(aSection+'\Fields');
  for i := 0 to Fields.Count - 1 do
    aIniFile.WriteString(aSection + '\' + sIniFields, Fields.Names[i],
      Fields.ValueFromIndex[i]);

  for i := 0 to FDataLinks.Count - 1 do
  begin
    aDataLink := FDataLinks[i];
    if aDataLink.SectionName <> '' then
      aDataLink.Save(aIniFile, aSection + '\' + aDataLink.SectionName);
  end;

  //Events.Save(aIniFile, aSection + '\' + sIniEvents);
end;


procedure TCustomDataPoint.SetEnabled(const Value: Boolean);
begin
  FEnabled := Value;
end;

procedure TCustomDataPoint.SetFields(const Value: TStrings);
begin
  if FFields.Text <> Value.Text then
  begin
    FFields.Text := Value.Text;
    ChangeProps(Self);
  end;
end;

procedure TCustomDataPoint.SetID(const Value: string);
begin
  FID := Value;
end;

procedure TCustomDataPoint.SetSectionName(const Value: string);
begin
  FSectionName := Value;
end;

//procedure TCustomDataPoint.SetKind(const Value: TDataPointKind);
//begin
//  FKind := Value;
//end;

procedure TCustomDataPoint.SetName(const Value: string);
//var
//  i: integer;
begin
  if FName <> Value then
  begin
    FName := Value;
    //UpdateDataPointLinks(Self);
    ChangeProps(Self);
//    for i := 0 to Events.Count - 1 do
//      Events[i].ObjectName := Name;
  end;
end;

procedure TCustomDataPoint.SetOPCSource(const Value: TaCustomOPCSource);
var
  i: Integer;
begin
  if Value <> OPCSource then
  begin
    for i := 0 to FDataLinks.Count - 1 do
      FDataLinks[i].OPCSource := Value;

    FLastChangeTime := -1;
    // Alex - события
    //Events.Reset;

    if Assigned(FOnSourceChanged) then
      FOnSourceChanged(Self);
  end;
end;

procedure TCustomDataPoint.SetParentID(const Value: integer);
begin
  FParentID := Value;
end;

procedure TCustomDataPoint.SetRealDataPoint(const Value: TCustomDataPoint);
begin
  FRealDataPoint := Value;
end;

procedure TCustomDataPoint.SetShiftParams(const Value: TDataLinkShift);
var
  i: Integer;
  aDataLink: TDataLinkExtInfo;
begin
  FShiftParams := Value;
  for i := 0 to FDataLinks.Count - 1 do
  begin
    aDataLink := FDataLinks[i];
    if aDataLink.IsShifted then
      aDataLink.ShiftParams := Value;
  end;
end;

procedure TCustomDataPoint.SetStatusDescription(const Value: string);
begin
  FStatusDescription := Value;
end;

procedure TCustomDataPoint.SetStatusEvalExpr(const Value: string);
var
  saveDecimalSeparator: Char;
begin
  FStatusEvalExpr := Value;
  if FStatusEvalExpr = '' then
    FStatusEvalFunc := nil
  else
  begin
    saveDecimalSeparator := FormatSettings.DecimalSeparator;
    try
      FormatSettings.DecimalSeparator := '.';
      FStatusEvalFunc := Eval.Compile(FStatusEvalExpr);
    finally
      FormatSettings.DecimalSeparator := saveDecimalSeparator;
    end;
  end;
end;

procedure TCustomDataPoint.SetVisible(const Value: boolean);
begin
  if FVisible <> Value then
  begin
    FVisible := Value;
    ChangeProps(Self);
  end;
end;

procedure TCustomDataPoint.StoreShiftParams;
begin
  FStoredShiftParams := ShiftParams;
end;

procedure TCustomDataPoint.UnLock;
begin
  FChangedCount := 0;
  FLocked := False;
end;

procedure TCustomDataPoint.UpdateDataPointLinks(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to FDataPointLinks.Count - 1 do
  begin
    if Sender is TCustomDataPoint then
      FDataPointLinks[i].ChangeData(Sender)
    else
      FDataPointLinks[i].ChangeData(TObject(FDataPointLinks[i]));
    //Sender);
  end;
end;



end.
