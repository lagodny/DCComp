{*******************************************************}
{                                                       }
{     Copyright (c) 2001-2018 by Alex A. Lagodny        }
{                                                       }
{*******************************************************}

unit aCustomOPCSource;

interface

uses
  System.Generics.Collections,
  SysUtils, Classes, SyncObjs,
  //Contnrs,
  aOPCLog,
  uDCObjects;

const
  UnUsedValue = -99999;

type
  TPhysID = type string;
  TaCustomOPCSource = class;

  //  TOPCStairsOptions = (soIncrease,soDecrease);
  //  TOPCStairsOptionsSet = set of TOPCStairsOptions;

  TOnGetIsAlarm = procedure (Sender: TObject; var aIsAlarm: Boolean) of object;

  TaCustomDataLink = class(TPersistent)
  private
{$REGION 'Fields'}
      [Weak] FControl: TObject;

      FID: Integer;
      FPhysID: TPhysID;
      FDeleted: boolean;
      FUpdateOnChangeMoment: boolean;
      FStairsOptions: TDCStairsOptionsSet;

      FOnUpdateData: TNotifyEvent;
      FOnChangeData: TNotifyEvent;
      FOnChangeDataThreaded: TNotifyEvent;
      FOnRequest: TNotifyEvent;
      FPrecision: Integer;
      FAlarmMinValue: Double;
      FAlarmMaxValue: Double;
      FAlarmIfNotOK: Boolean;
      FOnGetIsAlarm: TOnGetIsAlarm;
{$ENDREGION}
    procedure SetStairsOptions(const Value: TDCStairsOptionsSet);
    procedure SetAlarmMaxValue(const Value: Double);
  protected
    FValue: string;
    FFloatValue: Double;
    FIsAlarm: Boolean;
    FMoment: TDateTime;

    FOldValue: string;
    FOldFloatValue: Double;
    FOldIsAlarm: Boolean;
    FOldMoment: TDateTime;

    FErrorCode: integer;
    FErrorString: string;

    procedure AssignTo(Dest: TPersistent); override;

    function GetPhysID: TPhysID; virtual;
    procedure SetPhysID(const aValue: TPhysID); virtual;

    procedure SetValue(const aValue: string); virtual;
    procedure SetFloatValue(const aValue: Double);
    procedure UpdateData; virtual;
    procedure ChangeData; virtual;
    procedure DoChangeDataThreaded; virtual;
  public
    function GetIsAlarm: Boolean;

    property Control: TObject read FControl write FControl;

    property OldValue: string read FOldValue;
    property OldFloatValue: Double read FOldFloatValue;
    property OldIsAlarm: Boolean read FOldIsAlarm;
    property OldMoment: TDateTime read FOldMoment;

    property Value: string read FValue write SetValue;
    property FloatValue: Double read FFloatValue write SetFloatValue;
    property IsAlarm: Boolean read FIsAlarm;

    property ID: Integer read FID;
    property PhysID: TPhysID read GetPhysID write SetPhysID;
    property ErrorCode: integer read fErrorCode write fErrorCode;
    property ErrorString: string read fErrorString write fErrorString;
    property Moment: TDateTime read fMoment write fMoment;

    function IsActive: boolean; virtual;

    property Deleted: boolean read FDeleted write FDeleted;
    property StairsOptions: TDCStairsOptionsSet read FStairsOptions write SetStairsOptions;
    property Precision: Integer read FPrecision write FPrecision;
    property UpdateOnChangeMoment: boolean read FUpdateOnChangeMoment write FUpdateOnChangeMoment;

    property AlarmMinValue: Double read FAlarmMinValue write FAlarmMinValue;
    property AlarmMaxValue: Double read FAlarmMaxValue write SetAlarmMaxValue;

    property OnGetIsAlarm: TOnGetIsAlarm read FOnGetIsAlarm write FOnGetIsAlarm;

    //при записи в OPC
    property OnUpdateData: TNotifyEvent read FOnUpdateData write FOnUpdateData;
    //при чтении из OPC
    property OnChangeData: TNotifyEvent read FOnChangeData write FOnChangeData;
    //после того, как данные прочитаны (вызывается в потоке)
    property OnChangeDataThreaded: TNotifyEvent read FOnChangeDataThreaded write FOnChangeDataThreaded;
    //после того, как все данные почитаны (вызывается в главном потоке)
    property OnRequest: TNotifyEvent read FOnRequest write FOnRequest;

    constructor Create(aControl: TObject); virtual;
    destructor Destroy; override;

  end;

  TaCustomDataLinkList = class(TList<TaCustomDataLink>)
  end;

  TaOPCDataLink = class(TaCustomDataLink)
  protected
    procedure SetOPCSource(const Value: TaCustomOPCSource); virtual;
  protected
    //[Weak]
    FOPCSource: TaCustomOPCSource;
    FRealSource: TaCustomOPCSource;

    procedure SetPhysID(const Value: TPhysID); override;
    procedure AssignTo(Dest: TPersistent); override;
  public
    constructor Create(aControl: TObject); override;
    destructor Destroy; override;

    property OPCSource: TaCustomOPCSource read FOPCSource write SetOPCSource;
    property RealSource: TaCustomOPCSource read FRealSource;
  end;

  TaOPCDataLinkList = class(TList<TaOPCDataLink>)
  end;


  TOPCDataLinkGroup = class
    PhysID: TPhysID;

    OldValue: string;
    Value: string;
    FloatValue: Double;
    OldFloatValue: Double;
    ErrorCode: integer;
    ErrorString: string;

    Moment: TDateTime;

    NeedUpdate: boolean;
    UpdateOnChangeMoment: boolean;

    Deleted: boolean;
    StairsOptions: TDCStairsOptionsSet;

    DataLinks: TaOPCDataLinkList;

    constructor Create;
    destructor Destroy; override;
  end;

  TOPCDataLinkGroupList = class(TList<TOPCDataLinkGroup>)
  end;

  TLookupItem = class
    ID: integer;
    Name: string;
    constructor Create(aID: integer; aName: string);
  end;

  TQStringList = class(TStringList)
  private
    FSortedList: TStringList;
    procedure UpdateSortedList;
  protected
    procedure ListChanged(Sender: TObject);
  public
    function IndexOfName(const Name: string): Integer; override;

    constructor Create;
    destructor Destroy; override;
  end;

  TaCustomOPCLookupList = class(TComponent)
  private
    FItems: TStrings;

    procedure SetItems(const Value: TStrings);

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property Items: TStrings read FItems write SetItems;
  end;

  TaCustomOPCSource = class(TComponent)
  private
    FLockUpdate: integer;
    FOnActivate: TNotifyEvent;
    FOnDeactivate: TNotifyEvent;
    FStates: TaCustomOPCLookupList;
    FOnConnect: TNotifyEvent;
    FOnDisconnect: TNotifyEvent;
    FClientOffsetFromUTC: TDateTime;
    procedure SetActive(const Value: boolean); virtual;
    function GetActive: boolean;
    procedure SetStates(const Value: TaCustomOPCLookupList);
  protected
    FOpcFS: TFormatSettings;

    FServerVer: Integer;
    FServerEnableMessage: Boolean;
    FServerSupportingProtocols: string; 
    FServerOffsetFromUTC: TDateTime;

    FActive: boolean;
    FStreamedActive: boolean;

    FDataLinkGroups: TOPCDataLinkGroupList;
    FDataLinkGroupsLock: TCriticalSection;

    procedure SlToFormatSettings(sl: TStringList);

    function GetOpcFS: TFormatSettings; virtual;
    function GetOPCName: string; virtual;

    function FindDataLinkGroup(DataLink: TaOPCDataLink): TOPCDataLinkGroup;
    function FindDataLinkGroups(PhysID: string): TOPCDataLinkGroupList;

    procedure DoActive; virtual;
    procedure DoNotActive; virtual;
    procedure Loaded; override;
    property DataLinkGroups: TOPCDataLinkGroupList read FDataLinkGroups;

    procedure AddDataLink(DataLink: TaOPCDataLink; OldSource: TaCustomOPCSource = nil); virtual;
    procedure RemoveDataLink(DataLink: TaOPCDataLink); virtual;

    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

    procedure DoBeginUpdate; virtual;
    procedure DoEndUpdate; virtual;
    function IsLocked: boolean;
  public
    OpcDS: Char;

    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;

    function IsReal: boolean; virtual;

    function DateToServer(aDate: TDateTime): TDateTime;
    function DateToClient(aDate: TDateTime): TDateTime;
    procedure BeginUpdate;
    procedure EndUpdate;

    property OPCName: string read GetOPCName;
    property OPCFS: TFormatSettings read GetOpcFS write FOpcFS;
    property ServerVer: Integer read FServerVer;
    property ServerOffsetFromUTC: TDateTime read FServerOffsetFromUTC;
    property ClientOffsetFromUTC: TDateTime read FClientOffsetFromUTC;
  published
    property Active: boolean read GetActive write SetActive default false;
    property States: TaCustomOPCLookupList read FStates write SetStates;

    property OnActivate: TNotifyEvent read FOnActivate write FOnActivate;
    property OnDeactivate: TNotifyEvent read FOnDeactivate write FOnDeactivate;

    property OnConnect: TNotifyEvent read FOnConnect write FOnConnect;
    property OnDisconnect: TNotifyEvent read FOnDisconnect write FOnDisconnect;
  end;

  TaCustomMultiOPCSource = class(TaCustomOPCSource)
  private
  protected
    FCurrentMoment: TDateTime;
    function GetCurrentMoment: TDateTime;
    procedure SetCurrentMoment(const Value: TDateTime); virtual;
  public
    property CurrentMoment: TDateTime
      read GetCurrentMoment write SetCurrentMoment;
  end;

  TaCustomSingleOPCSource = class(TaCustomOPCSource);

  //var
  //  OpcDS:Char;
  //  OpcFS:TFormatSettings;

function CompareDataLinkGroup(Item1, Item2: Pointer): Integer;

implementation

uses
  IdGlobal,
  Math;
  //Windows;

function CompareDataLinkGroup(Item1,
  Item2: Pointer): Integer;
var
  i1, i2: TOPCDataLinkGroup;
begin
  if (Item1 = nil) and (Item2 = nil) then
    Result := 0
  else if (Item1 = nil) then
    Result := 1
  else if (Item2 = nil) then
    Result := -1
  else
  begin
    i1 := TOPCDataLinkGroup(Item1);
    i2 := TOPCDataLinkGroup(Item2);
    if (i1.PhysID = i2.PhysID) then
    begin
      if (i1.UpdateOnChangeMoment = i2.UpdateOnChangeMoment) then
        Result := 0
      else if (i1.UpdateOnChangeMoment < i2.UpdateOnChangeMoment) then
        Result := -1
      else
        Result := 1;
    end
    else if i1.PhysID < i2.PhysID then
      Result := -1
    else
      Result := 1;
  end;
end;

{ TaCustomOPCSource }

procedure TaCustomOPCSource.SlToFormatSettings(sl: TStringList);
begin
  with FOpcFS do
  begin
    ThousandSeparator := sl[0][1];
    DecimalSeparator := sl[1][1]; // +
    TimeSeparator := sl[2][1]; // +
    ListSeparator := sl[3][1];

    CurrencyString := sl.Strings[4];
    ShortDateFormat := sl.Strings[5];
    LongDateFormat := sl.Strings[6];
    TimeAMString := sl.Strings[7];
    TimePMString := sl.Strings[8];
    ShortTimeFormat := sl.Strings[9];
    LongTimeFormat := sl.Strings[10];

    if sl.Count > 11 then
    begin
      DateSeparator := sl[11][1]; // + действительно необходимые

      if sl.Count > 12 then
        FServerVer := StrToInt(sl[12]);
    end;
  end;

  // версия сервера
  if sl.Count > 12 then
    FServerVer := StrToInt(sl[12]);

end;

procedure TaCustomOPCSource.AddDataLink(DataLink: TaOPCDataLink;
  OldSource: TaCustomOPCSource = nil);
var
  DataLinkGroup: TOPCDataLinkGroup;
begin
  DataLinkGroup := FindDataLinkGroup(DataLink);
  if not Assigned(DataLinkGroup) then
  begin
    DataLinkGroup := TOPCDataLinkGroup.Create;
    DataLinkGroup.PhysID := DataLink.PhysID;
    DataLinkGroup.StairsOptions := DataLink.StairsOptions;
    DataLinkGroup.UpdateOnChangeMoment := DataLink.UpdateOnChangeMoment;
    DataLinkGroups.Add(DataLinkGroup);
  end;

  DataLinkGroup.NeedUpdate := true;
  DataLinkGroup.DataLinks.Add(DataLink);
  DataLink.FOPCSource := Self;
end;

procedure TaCustomOPCSource.BeginUpdate;
begin
  DoBeginUpdate;
end;

constructor TaCustomOPCSource.Create(aOwner: TComponent);
begin
  inherited;
  FActive := false;

  FDataLinkGroups := TOPCDataLinkGroupList.Create;
  FDataLinkGroupsLock := TCriticalSection.Create;
  FClientOffsetFromUTC := OffsetFromUTC;

  OpcFS := TFormatSettings.Create;
end;

function TaCustomOPCSource.DateToClient(aDate: TDateTime): TDateTime;
begin
  Result := aDate + ClientOffsetFromUTC - ServerOffsetFromUTC;
end;

function TaCustomOPCSource.DateToServer(aDate: TDateTime): TDateTime;
begin
  if aDate <> 0 then
    Result := aDate - ClientOffsetFromUTC + ServerOffsetFromUTC
  else
    Result := 0;
end;

destructor TaCustomOPCSource.Destroy;
var
  i: Integer;
begin
  Active := false;

  for i := 0 to FDataLinkGroups.Count - 1 do
    FDataLinkGroups[i].Free;

  FreeAndNil(FDataLinkGroups);
  FreeAndNil(FDataLinkGroupsLock);

  inherited;
end;

procedure TaCustomOPCSource.DoActive;
begin
  if Assigned(FOnActivate) then
    FOnActivate(Self);
end;

procedure TaCustomOPCSource.DoBeginUpdate;
begin
  Inc(FLockUpdate);
end;

procedure TaCustomOPCSource.DoEndUpdate;
begin
  Dec(FLockUpdate);

end;

procedure TaCustomOPCSource.DoNotActive;
begin
  if not (csDestroying in ComponentState) then
  begin
    if Assigned(FOnDeactivate) then
      FOnDeactivate(Self);
  end;
end;

procedure TaCustomOPCSource.EndUpdate;
begin
  DoEndUpdate;
end;

function TaCustomOPCSource.FindDataLinkGroup(DataLink: TaOPCDataLink): TOPCDataLinkGroup;
var
  i: integer;
  //DataLinkGroup: TOPCDataLinkGroup;
begin
  Result := nil;

  // поиск может выполняться в основном потоке приложения
  // необходимо запретить потоку сбора данных Упаковать
  // (уменьшить размер списка) DataLinkGroups
  FDataLinkGroupsLock.Enter;
  try
    for i := 0 to DataLinkGroups.Count - 1 do
    begin
      if i >= DataLinkGroups.Count then
        Exit;

      //DataLinkGroup := DataLinkGroups[i];
      if Assigned(DataLinkGroups[i]) then
      begin
        if (DataLinkGroups[i].PhysID = DataLink.PhysID) and
          (DataLinkGroups[i].UpdateOnChangeMoment = DataLink.UpdateOnChangeMoment) and
          not DataLinkGroups[i].Deleted then
        begin
          Result := DataLinkGroups[i];
          exit;
        end;
      end;
    end;
  finally
    FDataLinkGroupsLock.Leave;
  end;
end;

function TaCustomOPCSource.FindDataLinkGroups(PhysID: string): TOPCDataLinkGroupList;
var
  L, H, I, I1: integer;
  Item1: string;
  DLG: TOPCDataLinkGroup;
begin
  Result := nil;
  DLG := nil;

  L := 0;
  I := 0;
  H := FDataLinkGroups.Count - 1;
  while L <= H do
  begin
    I := (L + H) shr 1;
    if FDataLinkGroups[i] <> nil then
      Item1 := FDataLinkGroups[i].PhysID
    else
      Item1 := '';

    if Item1 < PhysID then
      L := I + 1
    else
    begin
      H := I - 1;
      if Item1 = PhysID then
      begin
        DLG := FDataLinkGroups[i];
        L := I;
      end;
    end;
  end;

  if DLG <> nil then
  begin
    Result := TOPCDataLinkGroupList.Create;
    Result.Add(DLG);

    // в списке групп может быть две группы с одинаковым PhisID
    // но у первого UpdateOnChangeMoment = false
    // а у второго true
    // мы должны вернуть обоих
    if DLG.UpdateOnChangeMoment then
      i1 := IfThen(i > 0, i - 1, i)
    else
      i1 := IfThen(i < FDataLinkGroups.Count - 1, i + 1, i);

    if (i <> I1)
      and (FDataLinkGroups[i1] <> nil)
      and (DLG.PhysID = FDataLinkGroups[i1].PhysID) then
      Result.Add(FDataLinkGroups[i1]);
  end;
end;

function TaCustomOPCSource.GetActive: boolean;
begin
  Result := FActive;
end;

function TaCustomOPCSource.GetOpcFS: TFormatSettings;
begin
  Result := FOpcFS;
end;

function TaCustomOPCSource.GetOPCName: string;
begin
  Result := Name;
end;

function TaCustomOPCSource.IsLocked: boolean;
begin
  Result := FLockUpdate <> 0;
end;

function TaCustomOPCSource.IsReal: boolean;
begin
  Result := false;
end;

procedure TaCustomOPCSource.Loaded;
begin
  inherited Loaded;
  if FStreamedActive then
    SetActive(True);
end;

procedure TaCustomOPCSource.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FStates) then
    FStates := nil;
end;

procedure TaCustomOPCSource.RemoveDataLink(DataLink: TaOPCDataLink);
var
  DataLinkGroup: TOPCDataLinkGroup;
begin
  DataLink.FOPCSource := nil;

  DataLinkGroup := FindDataLinkGroup(DataLink);
  if Assigned(DataLinkGroup) then
  begin
    DataLinkGroup.DataLinks.Remove(DataLink);

    // удаляем группу, если ДатаЛанков не осталось
    if DataLinkGroup.DataLinks.Count = 0 then
    begin
      DataLinkGroups.Remove(DataLinkGroup);
      FreeAndNil(DataLinkGroup);
    end;
  end;
end;

procedure TaCustomOPCSource.SetActive(const Value: boolean);
begin
  if (csReading in ComponentState) and Value then
    FStreamedActive := Value
  else
  begin
    if Value = GetActive then
      Exit;
    if Value then
      DoActive
    else
      DoNotActive;
  end;
end;

procedure TaCustomOPCSource.SetStates(const Value: TaCustomOPCLookupList);
begin
  FStates := Value;
end;

{ TaCustomDataLink }

procedure TaCustomDataLink.AssignTo(Dest: TPersistent);
var
  aDest: TaCustomDataLink;
begin
  if not (Dest is TaCustomDataLink) then
    inherited AssignTo(Dest)
  else
  begin
    aDest := TaCustomDataLink(Dest);
    aDest.FPhysID := PhysID;
    aDest.FStairsOptions := StairsOptions;
    aDest.AlarmMinValue := AlarmMinValue;
    aDest.AlarmMaxValue := AlarmMaxValue;
    aDest.FUpdateOnChangeMoment := UpdateOnChangeMoment;

    //aDest.FOnUpdateData := OnUpdateData;
    //aDest.FOnChangeData := OnChangeData;
    //aDest.OnChangeDataThreaded := OnChangeDataThreaded;
    //aDest.FOnRequest := OnRequest;

    //aDest.FControl := Control;
  end;

end;

procedure TaCustomDataLink.ChangeData;
begin
  if (Control <> nil) and Assigned(FOnChangeData) then
    FOnChangeData(Self);
end;

constructor TaCustomDataLink.Create(aControl: TObject);
begin
  Control := aControl;
  FValue := '';
  fErrorCode := 0;
  fErrorString := '';
  FPhysID := '';
  fMoment := 0;
  FDeleted := false;
  FUpdateOnChangeMoment := false;
  FStairsOptions := [];
  OnUpdateData := nil;
  OnChangeData := nil;
  //  OPCSource := nil;
end;

destructor TaCustomDataLink.Destroy;
begin
  //  OPCSource := nil;
  Control := nil;
  inherited;
end;

procedure TaCustomDataLink.DoChangeDataThreaded;
begin
  if Assigned(OnChangeDataThreaded) then
    OnChangeDataThreaded(Self);
end;

function TaCustomDataLink.GetIsAlarm: Boolean;
begin
  Result := False;
  // если есть обработчик определения аварий - вызываем его
  if Assigned(FOnGetIsAlarm) then
    FOnGetIsAlarm(Self, Result)

  else if (AlarmMinValue = 0) and (AlarmMaxValue = 0) then
  begin
    // старый вариант - для датчиков аварий мониторинга
    Result := not ((Value = '0') or (Value = '') or
      (Pos('FALSE', UpperCase(Value)) > 0) or (StrToIntDef(Value, 0) = 0));
  end
  else
  begin
    // новый вариант - для аналоговых датчиков
    Result := (FloatValue < AlarmMinValue) or (FloatValue > AlarmMaxValue);
  end;
end;

function TaCustomDataLink.GetPhysID: TPhysID;
begin
  Result := FPhysID;
end;

function TaCustomDataLink.IsActive: boolean;
begin
  if (AlarmMinValue = 0) and (AlarmMaxValue = 0) then
  begin
    // старый вариант - для датчиков аварий мониторинга
    Result := not ((Value = '0') or (Value = '') or
      (Pos('FALSE', UpperCase(Value)) > 0) or (StrToIntDef(Value, 0) = 0));
  end
  else
  begin
    // новый вариант - для аналоговых датчиков
    Result := (FloatValue < AlarmMinValue) or (FloatValue > AlarmMaxValue);
  end;
end;

procedure TaCustomDataLink.SetAlarmMaxValue(const Value: Double);
begin
  FAlarmMaxValue := Value;
end;

procedure TaCustomDataLink.SetFloatValue(const aValue: Double);
begin
  if FFloatValue <> aValue then
  begin
    FOldFloatValue := FFloatValue;
    FFloatValue := aValue;
    FValue := FloatToStr(FFloatValue);

    FOldIsAlarm := FIsAlarm;
    FIsAlarm := GetIsAlarm;
    
    ChangeData;
  end;
end;

procedure TaCustomDataLink.SetPhysID(const aValue: TPhysID);
begin
  FPhysID := aValue;
  FID := StrToIntDef(FPhysID, 0);
end;

procedure TaCustomDataLink.SetStairsOptions(const Value: TDCStairsOptionsSet);
begin
  FStairsOptions := Value;
end;

procedure TaCustomDataLink.SetValue(const aValue: string);
begin
  if FValue <> aValue then
  begin
    FValue := aValue;
    TryStrToFloat(FValue, FFloatValue);

    ChangeData;
  end;
end;

procedure TaCustomDataLink.UpdateData;
begin
  if (Control <> nil) and Assigned(FOnUpdateData) then
    FOnUpdateData(Self);
end;

procedure TaOPCDataLink.AssignTo(Dest: TPersistent);
var
  aDest: TaOPCDataLink;
begin
  inherited AssignTo(Dest);

  if Dest is TaOPCDataLink then
  begin
    aDest := TaOPCDataLink(Dest);
    aDest.PhysID := PhysID;
    aDest.StairsOptions := StairsOptions;
    aDest.Precision := Precision;
    aDest.OPCSource := OPCSource;
  end;

end;

constructor TaOPCDataLink.Create(aControl: TObject);
begin
  inherited Create(aControl);
  FOPCSource := nil;
  FRealSource := nil;
end;

destructor TaOPCDataLink.Destroy;
begin
  OPCSource := nil;
  FRealSource := nil;
  inherited;
end;

procedure TaOPCDataLink.SetOPCSource(const Value: TaCustomOPCSource);
begin
  if FOPCSource <> Value then
  begin
    if FOPCSource <> nil then
      FOPCSource.RemoveDataLink(Self);

    if Value <> nil then
    begin
      if Value.IsReal then
        FRealSource := Value;
      Value.AddDataLink(Self); //, aOldSource);
    end
    else
      FRealSource := Value;

    FOPCSource := Value;
  end;
end;

{ TOPCDataLinkGroup }

constructor TOPCDataLinkGroup.Create;
begin
  inherited Create;

  Deleted := False;
  DataLinks :=  TaOPCDataLinkList.Create;
end;

destructor TOPCDataLinkGroup.Destroy;
var
  i: Integer;
begin
  for i := 0 to DataLinks.Count - 1 do
  begin
    if Assigned(DataLinks[i]) then
    begin
      DataLinks[i].FOPCSource := nil;
      DataLinks[i].FRealSource := nil;
    end;
  end;
  FreeAndNil(DataLinks);

  inherited;
end;

procedure TaOPCDataLink.SetPhysID(const Value: TPhysID);
var
  aOPCSource: TaCustomOPCSource;
begin
  if FPhysID <> Value then
  begin
    aOPCSource := FOPCSource;
    if aOPCSource <> nil then
    begin
      aOPCSource.RemoveDataLink(Self);
      inherited SetPhysID(Value);
      aOPCSource.AddDataLink(self, aOPCSource);
    end
    else
      inherited SetPhysID(Value);

  end;
end;

{ TaCustomMultiOPCSource }

function TaCustomMultiOPCSource.GetCurrentMoment: TDateTime;
begin
  Result := FCurrentMoment;
end;

procedure TaCustomMultiOPCSource.SetCurrentMoment(const Value: TDateTime);
begin
  FCurrentMoment := Value;
end;

{ TaCustomOPCLookupList }

constructor TaCustomOPCLookupList.Create(AOwner: TComponent);
begin
  inherited;
  FItems := TQStringList.Create;
end;

destructor TaCustomOPCLookupList.Destroy;
begin
  FItems.Free;
  inherited;
end;

procedure TaCustomOPCLookupList.SetItems(const Value: TStrings);
begin
  FItems.Assign(Value);
end;

{ TLookupItem }

constructor TLookupItem.Create(aID: integer; aName: string);
begin
  inherited Create;
  ID := aID;
  Name := aName;
end;

{ FQStringList }

constructor TQStringList.Create;
begin
  inherited Create;
  FSortedList := TStringList.Create;
  OnChange := ListChanged;
end;

destructor TQStringList.Destroy;
var
  i: integer;
begin
  for i := 0 to FSortedList.Count - 1 do
    FSortedList.Objects[i].Free;
  FSortedList.Clear;

  FSortedList.Free;
  inherited Destroy;
end;

function TQStringList.IndexOfName(const Name: string): Integer;
begin
  Result := FSortedList.IndexOf(Name);
  if Result >= 0 then
    Result := TLookupItem(FSortedList.Objects[Result]).ID;
end;

procedure TQStringList.ListChanged(Sender: TObject);
begin
  UpdateSortedList;
end;

procedure TQStringList.UpdateSortedList;
var
  i: integer;
  //  tc : cardinal;
begin
  //  tc := GetTickCount;
  for i := 0 to FSortedList.Count - 1 do
    FSortedList.Objects[i].Free;
  FSortedList.Clear;

  for i := 0 to Count - 1 do
  begin
    FSortedList.AddObject(
      Names[i],
      TLookupItem.Create(i, ValueFromIndex[i]));
  end;
  FSortedList.Sort;
  FSortedList.Sorted := True;
  //  OPCLog.WriteToLogFmt('TQStringList.UpdateSortedList: %d', [gettickcount - tc]);
end;

end.


