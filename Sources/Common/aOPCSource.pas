unit aOPCSource;

interface

uses
  System.Classes,
  System.SysUtils,
  IniFiles, SyncObjs,
  uDataTypes,
  aCustomOPCSource, uDCObjects, uUserMessage;

const
  NameSpaceSection = 'NameSpace';
  cMaxGroupForSingleUpdate = 5000;

  сV30_ProtocolSet = [30, 31, 32];

type
  EDataLinkError = class(Exception)
  end;

  EDataLinkNotFound = class(Exception)
  end;

  EThreadTerminated = class(Exception)
  end;

  ENotInhibitException = class(Exception)
  end;

  TaOPCUpdateMode = (umAuto, umPacket, umEach, umStreamPacket);

  TMessageStrEvent = procedure(Sender: TObject; MessageStr: string) of object;

  TCrackOPCLink = class(TaOPCDataLink)
  end;

  TaOPCSource = class;

  TOPCUpdateThread = class(TThread)
  private
    ConnectionError: string;
    // DataLinkGroupIndex: Integer;
    ErrorCode: Integer;
    ErrorString: string;
    Moment: TDateTime;
    // PhysID: string;
    DataLinkGroup: TOPCDataLinkGroup;
    GroupsForUpdate: TOPCDataLinkGroupList;
    TimeOfLastBadConnect: TDateTime;
    Value: string;
    FOPCSource: TaOPCSource;
    function GetOPCSource: TaOPCSource;

    procedure UpdateStreamPacket_V30;
  protected
    procedure Execute; override;
  public
    ForceUpdate: Boolean;
    Interval: Integer;
    property OPCSource: TaOPCSource read GetOPCSource write FOPCSource;
    procedure DoError;
    procedure DoLog(aMsg: string);
    // procedure SetActiveFalse;
    // procedure SetActiveTrue;
    // procedure UpdateData;
  end;

  TaOPCSource = class(TaCustomMultiOPCSource)
  private
    // FcsLockOPCSource:TCriticalSection;
    FInterval: Integer;
    FKeepConnection: Boolean;
    FOnError: TMessageStrEvent;
    FPassword: string;
    FPermission: string;
    FThread: TOPCUpdateThread;
    FUser: string;
    FDescription: string;
    FOnRequest: TNotifyEvent;
    FPacketUpdate: Boolean;
    FUpdateMode: TaOPCUpdateMode;
    FError: string;
    FLogMsg: string;
    FProtocolVersion: Integer;
    FServerTimeDataLink: TaOPCDataLink;
    FUserMessages: TUserMessageList;
    FOnNewUserMessage: TNotifyEvent;
    FAvtoShowMessage: Boolean;
    FEnableMessage: Boolean;
//    FLanguage: TUserLanguage;
    FOnLog: TMessageStrEvent;
    FLanguage: string;
    procedure SetInterval(const Value: Integer);
    procedure SetKeepConnection(const Value: Boolean);
    procedure SetPassword(const Value: string);
    procedure SetPermission(const Value: string);
    procedure SetUser(const Value: string);
    procedure SetConnected(const Value: Boolean);
    procedure SetDescription(const Value: string);
    procedure SetPacketUpdate(const Value: Boolean);
    procedure SetServerTimeID(const Value: TPhysID);

    function GetServerTimeID: TPhysID;
    function GetServerTime: TDateTime;

    procedure CalcPhysIDs;
    procedure SetUpdateMode(const Value: TaOPCUpdateMode);
    procedure SetProtocolVersion(const Value: Integer);
    procedure SetAvtoShowMessage(const Value: Boolean);
    procedure SetEnableMessage(const Value: Boolean);
  protected
    FStreamedConnected: Boolean;

    FPhysIDs: string;
    FPhysIDsChanged: Boolean;

    FDataLinkGroupsChanged: Boolean;

    // методы вызываемые из потока
    procedure SyncDoActive;
    procedure SyncDoNotActive;
    procedure SyncConnect;
    procedure SyncDisconnect;
    procedure SyncChangeData;
    procedure SyncUpdateDataLinks;
    procedure SyncUpdateDataLinksData;
    procedure SyncError;
    procedure SyncRequest;
    procedure SyncNewUserMessage;
    procedure SyncLog;
    //

    procedure SetLanguage(const Value: string); virtual;

    procedure DoUpdateThreadTerminate(Sender: TObject);

//    procedure SetLanguage(const Value: TUserLanguage); virtual;

    procedure CheckAnswer(aAnswer: string; aParamCount: Integer = 0); virtual;

    procedure DoEndUpdate; override;

    function GetNameSpaceFileName: string;

    procedure Loaded; override;

    procedure AddDataLink(DataLink: TaOPCDataLink; OldSource: TaCustomOPCSource = nil); override;
    procedure RemoveDataLink(DataLink: TaOPCDataLink); override;

    procedure Reconnect; virtual;
    procedure DoConnect; virtual;
    procedure DoDisconnect; virtual;

    procedure Connect; virtual;
    procedure Disconnect; virtual;

    procedure CheckLock; virtual;

    procedure Authorize(aUser: string; aPassword: string); virtual;
    function GetConnected: Boolean; virtual; abstract;
    procedure DoActive; override;
    procedure DoError(ErrorStr: string);

    procedure DoRequest;
    procedure DoChangeData;
    procedure DoNewUserMessage;

    procedure DoUpdateDataLinksThreaded;

    // обновить показания данными групп
    procedure DoUpdateDataLinksData;
    // отработать изменение данных (вызов обработчика изменения данных)
    procedure DoUpdateDataLinks;

    procedure DoNotActive; override;

    function GetRemoteMachine: string; virtual;
    procedure SetRemoteMachine(const Value: string); virtual;

    function ExtractValue(var aValues: string; var aValue: string; var aErrorCode: Integer; var aErrorStr: string;
      var aMoment: TDateTime): Boolean; virtual;


    // function GetDS: Char; virtual; abstract;
    // procedure LoadFS; virtual; abstract;

    procedure ChangeData;
    // procedure TryConnection; virtual; abstract;
    procedure HistoryDateToClient(Stream: TStream; aDataKindSet: TDataKindSet); virtual;
    procedure ValuesDateToClient(s: TStream);

  public
    FNameSpaceParentID: string;
    FNameSpaceCash: TStrings;
    FNameSpaceTimeStamp: TDateTime;

//    function GetStringRes(idx: UInt32): String;
//    function GetStringResStr(idx: string): String;

    function IsReal: Boolean; override;

    function ExtractParamsFromAnswer(aAnswer: string; aParamCount: Integer = 0): string;
    function OPCStringToFloat(aStr: string): Double;

    property Connected: Boolean read GetConnected write SetConnected default false;
    property Error: string read FError;

    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;

    function GetOPCName: string; override;

    // function GetSensorProperties(id: string): TSensorProperties; virtual;
    function GetSensorPropertiesEx(id: string): string; virtual;

    function SetSensorPropertiesEx(id: string; sl: TStrings): string; virtual;

    function GetGroupProperties(id: string): string; virtual;
    function SetGroupProperties(id: string; sl: TStrings): string; virtual;

    function GetDeviceProperties(id: string): string; virtual;
    function SetDeviceProperties(id: string; sl: TStrings): string; virtual;

    function GetPermissions(PhysIDs: string): string; virtual;

    function GetValue(PhysID: string; aAsText: Boolean = False): string; virtual;
    function SendModBus(aSystemType: integer; aRequest: string;
      aRetByteCount: integer; aTimeOut: integer): string; virtual;
    function SendModBusEx(aConnectionName: string; aRequest: string;
      aRetByteCount: integer; aTimeOut: integer): string; virtual;

   function GetSensorValue(PhysID: string; var ErrorCode: integer; var
      ErrorString: string; var Moment: TDateTime): string; virtual;
    function GetSensorsValues(PhysIDs: string): string; virtual;

    procedure FillSensorsValuesStream(var aValuesStream: TMemoryStream); virtual;

    function GetSensorValueOnMoment(PhysID: string; var Moment: TDateTime): string; virtual;
    // возвращает показания датчиков на заданный момент времени Moment
    // PhysIDs - список адресов через ; (точку с запятой)
    // в ответе список показаний через ; (точку с запятой) в том же порядке
    function GetSensorsValueOnMoment(PhysIDs: string; Moment: TDateTime): string; virtual;

    function DelSensorValue(PhysID: string; Moment: TDateTime): string; virtual;
    function SetSensorValue(PhysID, Value: string; Moment: TDateTime = 0): string; virtual;
    procedure IncSensorValue(PhysID: string; aIncValue: Double; Moment: TDateTime); virtual;

    function DelSensorValues(PhysID: string; Date1, Date2: TDateTime): string; virtual;
    function RecalcSensor(PhysID: string; Date1, Date2: TDateTime; Script: string): string; virtual;
    procedure InsertValues(PhysID: string; aBuffer: TSensorDataArr); virtual;

    function ExecSql(Sql: string): string; virtual;
    function LoadLookup(aName: string; var aTimeStamp: TDateTime): string; virtual;
    procedure ForceUpdate;

    // устаревшее
    // function GetSensorJurnal(var Stream: TMemoryStream; SensorPath: string;
    // Date1, Date2: TDateTime): string; virtual; abstract;
    // устаревшее
    // function GetStateJurnal(var Stream: TMemoryStream; SensorPath: string;
    // Date1, Date2: TDateTime): string; virtual; abstract;

    procedure FillHistory(Stream: TStream; SensorID: string; 
      Date1: TDateTime; Date2: TDateTime = 0;
      aDataKindSet: TDataKindSet = [dkValue]; 
      aCalcLeftVal: Boolean = True; aCalcRightVal: Boolean = True); virtual; abstract;

    function Login(const aUserName, aPassword: string): Boolean; virtual; abstract;

    // получить иерархию в виде списка строк
    procedure FillNameSpaceStrings(aNameSpace: TStrings; aRootID: string = ''; aLevelCount: Integer = 0;
      aKinds: TDCObjectKindSet = []); virtual; abstract;

    function GetNameSpace(aObjectID: string = ''; aLevelCount: Integer = 0): boolean; virtual; abstract;
    function GetUserPermission(const aUser, aPassword, aObject: String): String; virtual; abstract;
    function GetUsers: string; virtual; abstract;
    function GetClientList: string; virtual;
    function GetThreadList: string; virtual; abstract;
    function GetThreadProp(aThreadName: string): string; virtual; abstract;
    function GetSensorsReadError: string; virtual; abstract;

    function CalcVolume(aSensorID: Integer; aDate1, aDate2: TDateTime): extended; virtual; abstract;
    function GetTimes(aSensorID: Integer; aDate1, aDate2: TDateTime): string; virtual; abstract;
    function GetStatistic(aSensorID: string; aDate1, aDate2: TDateTime): string; virtual; abstract;

    function SetThreadState(ConnectionName: string; NewState: Boolean): string; virtual; abstract;
    function SetThreadLock(ConnectionName: string; NewState: Boolean): string; virtual; abstract;

    procedure GetFile(aFileName: string; aStream: TStream); virtual; abstract;
    procedure UploadFile(aFileName: string; aDestDir: string = ''); virtual;

    procedure DownloadSetup(aFileName: string; aStream: TStream); virtual;
    procedure LoadNameSpace(aCustomIniFile: TCustomIniFile; aSectionName: string = '');
    procedure SaveNameSpace(aCustomIniFile: TCustomIniFile; aSectionName: string = '');
    procedure CheckForNewNameSpace(aCustomIniFile: TCustomIniFile; aSectionName:
      string = ''; aReconnect: boolean = false);
    procedure ChangePassword(aUser, aOldPassword, aNewPassword: string); virtual; abstract;

    procedure SendUserMessage(aUserGUID: string; aMessage: string); virtual; abstract;
    function GetMessage: TUserMessage; virtual; abstract;

    procedure DisconnectUser(aUserGUID: string); virtual; abstract;

    property ServerTime: TDateTime read GetServerTime;
    property UserMessages: TUserMessageList read FUserMessages;
    procedure UpdateDescription; virtual;

  published
    // случается, когда прошел цикл опроса датчиков
    property OnRequest: TNotifyEvent read FOnRequest write FOnRequest;
    property OnError: TMessageStrEvent read FOnError write FOnError;
    property OnLog: TMessageStrEvent read FOnLog write FOnLog;
    property OnNewUserMessage: TNotifyEvent read FOnNewUserMessage write FOnNewUserMessage;

    property RemoteMachine: string read GetRemoteMachine write SetRemoteMachine;
    property User: string read FUser write SetUser;
    property Password: string read FPassword write SetPassword;
    property Permission: string read FPermission write SetPermission;

    property PacketUpdate: Boolean read FPacketUpdate write SetPacketUpdate default True;
    property UpdateMode: TaOPCUpdateMode read FUpdateMode write SetUpdateMode default umPacket;
    property Description: string read FDescription write SetDescription;
    property ProtocolVersion: Integer read FProtocolVersion write SetProtocolVersion default 1;
    property Interval: Integer read FInterval write SetInterval default 1000;
    property KeepConnection: Boolean read FKeepConnection write SetKeepConnection default false;

    property ServerTimeID: TPhysID read GetServerTimeID write SetServerTimeID;
    property EnableMessage: Boolean read FEnableMessage write SetEnableMessage default True;
    property AutoShowMessage: Boolean read FAvtoShowMessage write SetAvtoShowMessage default True;

    property Language: string read FLanguage write SetLanguage;
    // property InhibitWNDProcException: Boolean read FInhibitWNDProcException write SetInhibitWNDProcException;
  end;

implementation

uses
  DC.StrUtils,
  uCommonClass,
  aOPCLog, uOPCCash, 
  // uUserMessageForm,
  aOPCConsts;

{ TaOPCSource }

{
  ********************************* TaOPCSource **********************************
}

constructor TaOPCSource.Create(aOwner: TComponent);
begin
  inherited;
  // FcsLockOPCSource  := TCriticalSection.Create;
  FThread := nil;

  FKeepConnection := false;
  FInterval := 1000;
  UpdateMode := umPacket;

  FProtocolVersion := 1; // c 05.04.2007
  // FProtocolVersion := 2; // c 16.07.2007
  // FProtocolVersion := 3; // c 17.07.2007
  FNameSpaceCash := TStringList.Create;
  FNameSpaceTimeStamp := -1;

  FUserMessages := TUserMessageList.Create;

  FServerTimeDataLink := TaOPCDataLink.Create(nil);
  FServerTimeDataLink.OPCSource := Self;

  FAvtoShowMessage := True;
  FEnableMessage := True;

//  FLanguage := langRU;

end;

function TaOPCSource.DelSensorValue(PhysID: string; Moment: TDateTime): string;
begin

end;

function TaOPCSource.DelSensorValues(PhysID: string; Date1, Date2: TDateTime): string;
begin

end;

destructor TaOPCSource.Destroy;
begin
  Active := false;

  FreeAndNil(FNameSpaceCash);

  FreeAndNil(FUserMessages);
  FreeAndNil(FServerTimeDataLink);

  inherited;
end;

procedure TaOPCSource.Connect;
begin
end;

procedure TaOPCSource.Disconnect;
begin
end;

procedure TaOPCSource.DoActive;
begin
  // уже есть поток - выходим
  if Assigned(FThread) then
    Exit;

  // создаем новый
  FThread := TOPCUpdateThread.Create(True);
  FThread.OnTerminate := DoUpdateThreadTerminate;
  FThread.FreeOnTerminate := True;
  FThread.Interval := Interval;
  FThread.OPCSource := Self;
  FThread.Start;
  FActive := True;
  FError := '';

  inherited;
end;

procedure TaOPCSource.DoChangeData;
var
  i: Integer;
  // iGroup: integer;
  CrackDataLink: TCrackOPCLink;
  DataLinkGroup: TOPCDataLinkGroup;
  tmpFloat: extended;
begin
  DataLinkGroup := FThread.DataLinkGroup;
  DataLinkGroup.NeedUpdate := false;
  for i := 0 to DataLinkGroup.DataLinks.Count - 1 do
  begin
    CrackDataLink := TCrackOPCLink(DataLinkGroup.DataLinks.Items[i]);

    CrackDataLink.FErrorCode := DataLinkGroup.ErrorCode;
    CrackDataLink.FErrorString := DataLinkGroup.ErrorString;

    CrackDataLink.FValue := DataLinkGroup.Value;
    CrackDataLink.FOldValue := DataLinkGroup.OldValue;
    TryStrToFloat(CrackDataLink.FValue, CrackDataLink.FFloatValue);
    if OpcFS.DecimalSeparator <> FormatSettings.DecimalSeparator then
    begin
      tmpFloat := StrToFloatDef(CrackDataLink.FValue, UnUsedValue, OpcFS);
      if tmpFloat <> UnUsedValue then
        CrackDataLink.FValue := FloatToStr(tmpFloat);
    end;

    CrackDataLink.FMoment := DataLinkGroup.Moment;
    CrackDataLink.ChangeData;
  end;
end;

procedure TaOPCSource.DoConnect;
begin

end;

procedure TaOPCSource.DoDisconnect;
begin

end;

procedure TaOPCSource.DoUpdateDataLinks;
var
  iLink, iGroup: Integer;
  CrackDataLink: TCrackOPCLink;
  aDataLinkGroup: TOPCDataLinkGroup;
begin
  for iGroup := 0 to FThread.GroupsForUpdate.Count - 1 do
  begin
    aDataLinkGroup := FThread.GroupsForUpdate.Items[iGroup];
    for iLink := 0 to aDataLinkGroup.DataLinks.Count - 1 do
    begin
      CrackDataLink := TCrackOPCLink(aDataLinkGroup.DataLinks.Items[iLink]);
      CrackDataLink.ChangeData;
    end;
  end;
end;

procedure TaOPCSource.DoUpdateDataLinksThreaded;
var
  i: Integer;
  iGroup: Integer;
  CrackDataLink: TCrackOPCLink;
  DataLinkGroup: TOPCDataLinkGroup;
begin
  for iGroup := 0 to FThread.GroupsForUpdate.Count - 1 do
  begin
    DataLinkGroup := FThread.GroupsForUpdate.Items[iGroup];
    for i := 0 to DataLinkGroup.DataLinks.Count - 1 do
    begin
      CrackDataLink := TCrackOPCLink(DataLinkGroup.DataLinks.Items[i]);
      CrackDataLink.DoChangeDataThreaded;
    end;
  end;
end;

procedure TaOPCSource.DownloadSetup(aFileName: string; aStream: TStream);
begin

end;


procedure TaOPCSource.DoUpdateThreadTerminate(Sender: TObject);
begin
  FThread := nil;
end;

procedure TaOPCSource.DoEndUpdate;
begin
  FDataLinkGroupsChanged := True;
  inherited;
  ForceUpdate;
end;

procedure TaOPCSource.DoError(ErrorStr: string);
begin
  FError := ErrorStr;
  if Assigned(FOnError) then
    FOnError(Self, ErrorStr)
  else
    OPCLog.WriteToLog(ErrorStr);
end;

procedure TaOPCSource.DoNewUserMessage;
var
  i: Integer;
begin
  if AutoShowMessage then
  begin
    UserMessages.Lock;
    try
      for i := 0 to UserMessages.Count - 1 do
      begin
        { TODO : Добавить вывод сообщения пользователю }
        //ShowUserMessage(UserMessages[i], Self);
        // ShowUserMessage(TUserMessage(aList[i]), Self);
        UserMessages[i].Free;
      end;
      UserMessages.Clear;
    finally
      UserMessages.UnLock;
    end;
  end;

  if Assigned(FOnNewUserMessage) then
    OnNewUserMessage(Self);
end;


procedure TaOPCSource.DoNotActive;
begin
  // останавливаем поток, если он есть
  if Assigned(FThread) then
  begin
    FThread.Terminate;
    while Assigned(FThread) do
      CheckSynchronize(1000);
  end;

  FActive := False;
  inherited;

//  if FThread <> nil then
//  begin
//    FThread.FreeOnTerminate := True;
//
//    FThread.Terminate;
//    while Assigned(FThread) do
//      CheckSynchronize(1000);
//
//    CheckLock; // проверим, не выполняет ли наш OPCSource, что-то длительное
//
//    FThread := nil;
//  end;
//
//  FActive := false;
//  inherited;
end;

function TaOPCSource.ExecSql(Sql: string): string;
begin
end;

function TaOPCSource.ExtractParamsFromAnswer(aAnswer: string;
  aParamCount: integer): string;
begin
  CheckAnswer(aAnswer, aParamCount);
  Result := Copy(aAnswer, Length(sOk) + 1, Length(aAnswer) - Length(sOk));
end;

function TaOPCSource.ExtractValue(var aValues: string; 
  var aValue: string; var aErrorCode: Integer; var aErrorStr: string; var aMoment: TDateTime): Boolean;
var
  p: Integer;
begin
  Result := True;
  // Value
  p := pos(';', aValues);
  if p > 0 then
  begin
    aValue := Copy(aValues, 1, p - 1);
    aValues := Copy(aValues, p + 1, Length(aValues));
  end;

  if ProtocolVersion > 0 then
  begin
    // ErrorCode
    p := pos(';', aValues);
    if p > 0 then
    begin
      aErrorCode := StrToIntDef(Copy(aValues, 1, p - 1), 0);
      aValues := Copy(aValues, p + 1, Length(aValues));
    end;
  end;

  // ErrorStr
  p := pos(';', aValues);
  if p > 0 then
  begin
    aErrorStr := Copy(aValues, 1, p - 1);
    aValues := Copy(aValues, p + 1, Length(aValues));
    if ProtocolVersion = 0 then
    begin
      if aErrorStr <> '' then
        aErrorCode := 1
      else
        aErrorCode := 0;
    end;
  end;

  // Moment
  p := pos(';', aValues);
  if p > 0 then
  begin
    aMoment := StrToDateTime(Copy(aValues, 1, p - 1), OpcFS);
    aValues := Copy(aValues, p + 1, Length(aValues));
  end
  else
  begin
    aMoment := StrToDateTime(aValues, OpcFS);
    aValues := '';
  end;
end;

procedure TaOPCSource.FillSensorsValuesStream(var aValuesStream: TMemoryStream);
begin

end;

procedure TaOPCSource.ForceUpdate;
begin
  if FThread <> nil then
    FThread.ForceUpdate := True;
end;

function TaOPCSource.GetRemoteMachine: string;
begin
end;

function TaOPCSource.RecalcSensor(PhysID: string; Date1, Date2: TDateTime; Script: string): string;
begin

end;

procedure TaOPCSource.Reconnect;
begin

end;

procedure TaOPCSource.RemoveDataLink(DataLink: TaOPCDataLink);
var
  DataLinkGroup: TOPCDataLinkGroup;
begin
  DataLinkGroup := FindDataLinkGroup(DataLink);
  if DataLinkGroup <> nil then
  begin
    DataLinkGroup.DataLinks.Remove(DataLink);
    if DataLinkGroup.DataLinks.Count = 0 then
      DataLinkGroup.Deleted := True;
  end;

  TCrackOPCLink(DataLink).FOPCSource := nil;
  FDataLinkGroupsChanged := True;
end;

procedure TaOPCSource.SetInterval(const Value: Integer);
begin
  if (FInterval <> Value) and (Value >= 10) then
  begin
    if (FThread <> nil) and Active then
      FThread.Interval := Value;
    FInterval := Value;
  end;
end;

procedure TaOPCSource.SetKeepConnection(const Value: Boolean);
begin
  if Value <> FKeepConnection then
  begin
    FKeepConnection := Value;
    if not Value then
      Disconnect;
  end;
end;

procedure TaOPCSource.SetLanguage(const Value: string);
begin
  FLanguage := Value;
end;

//procedure TaOPCSource.SetLanguage(const Value: TUserLanguage);
//begin
//  FLanguage := Value;
//end;

procedure TaOPCSource.SetPassword(const Value: string);
begin
  FPassword := Value;
end;

procedure TaOPCSource.SetPermission(const Value: string);
begin
  FPermission := Value;
end;

procedure TaOPCSource.SetProtocolVersion(const Value: Integer);
begin
  FProtocolVersion := Value;
end;

procedure TaOPCSource.SetRemoteMachine(const Value: string);
begin
end;

function TaOPCSource.SetSensorPropertiesEx(id: string; sl: TStrings): string;
begin

end;

function TaOPCSource.SetSensorValue(PhysID, Value: string; Moment: TDateTime = 0): string;
begin
end;

procedure TaOPCSource.SetServerTimeID(const Value: TPhysID);
begin
  FServerTimeDataLink.PhysID := Value;
end;

procedure TaOPCSource.SetUser(const Value: string);
begin
  FUser := Value;
end;

procedure TaOPCSource.SyncChangeData;
begin
  DoChangeData;
end;

procedure TaOPCSource.UpdateDescription;
begin

end;

procedure TaOPCSource.SyncConnect;
begin
  if Assigned(OnConnect) then
    OnConnect(Self);
end;

procedure TaOPCSource.SyncDisconnect;
begin
  if Assigned(OnDisconnect) then
    OnDisconnect(Self);
end;

procedure TaOPCSource.SyncDoActive;
begin
  FActive := True;
  if Assigned(OnActivate) then
    OnActivate(Self);
end;

procedure TaOPCSource.SyncDoNotActive;
begin
  FActive := false;
  if Assigned(OnDeactivate) then
    OnDeactivate(Self);
end;

procedure TaOPCSource.SyncError;
begin
  DoError(FThread.ConnectionError);
end;

procedure TaOPCSource.SyncLog;
begin
  if Assigned(FOnLog) then
    FOnLog(Self, FLogMsg);
end;

procedure TaOPCSource.SyncNewUserMessage;
begin
  DoNewUserMessage;
end;

procedure TaOPCSource.SyncRequest;
begin
  DoRequest;
end;

procedure TaOPCSource.SyncUpdateDataLinks;
begin
  DoUpdateDataLinks;
end;

procedure TaOPCSource.SyncUpdateDataLinksData;
begin
  DoUpdateDataLinksData;
end;

procedure TaOPCSource.UploadFile(aFileName: string; aDestDir: string = '');
begin

end;

procedure TaOPCSource.ValuesDateToClient(s: TStream);
var
  d: TDateTime;
  aRecSize: Int64;
begin
  if ServerOffsetFromUTC = ClientOffsetFromUTC then
    Exit;

//  нужно перебрать все записи вида, и заменить в них даты на правильные
//  ID: Word;
//  TDCSensorDataRec_V30 = packed record
//    Value: Double;
//    ErrorCode: SmallInt;
//    Time: TDateTime;
//  end;
  aRecSize := SizeOf(Word) + SizeOf(Double) + SizeOf(SmallInt);
  if s.Size < aRecSize then
    Exit;

  s.Position := aRecSize;
  while s.Position < s.Size do
  begin
    s.Read(d, SizeOf(d));
    d := DateToClient(d);
    s.Position := s.Position - SizeOf(d);
    s.Write(d, SizeOf(d));
    s.Position := s.Position + aRecSize;
  end;
  s.Position := 0;

end;

{ TOPCUpdateThread }

{
  ******************************* TOPCUpdateThread *******************************
}

procedure TOPCUpdateThread.DoError;
begin
  OPCSource.DoError(ConnectionError);
end;

procedure TOPCUpdateThread.DoLog(aMsg: string);
begin
  if not Assigned(FOPCSource) then
    Exit;

  FOPCSource.FLogMsg := aMsg;
  Synchronize(FOPCSource.SyncLog);
  //FOPCSource.SyncLog;
end;

procedure TOPCUpdateThread.Execute;

const
  MinInterval = 100;
var

  iGroup, j: Integer;
  Values: string;
  PhysIDs: string;
  CurPhysID: string;

  ValuesStream: TMemoryStream;
  SensorData: TDCSensorDataRec;

  aIndex_V30: Word;
  aSensorData_V30: TDCSensorDataRec_V30;

  aUserMessage: TUserMessage;
  aDataRecived: Boolean;
  aExceptionMessage: string;

  function ExtractPhysID(var aPhysIDs: string): string;
  var
    p: Integer;
  begin
    p := pos(';', aPhysIDs);
    if p > 0 then
    begin
      Result := Copy(aPhysIDs, 1, p - 1);
      aPhysIDs := Copy(aPhysIDs, p + 1, Length(aPhysIDs));
    end
    else
    begin
      Result := aPhysIDs;
      aPhysIDs := '';
    end;
  end;

  procedure ExtractValue(var aValues: string; 
    var aValue: string; var aErrorCode: Integer; var aErrorStr: string;
    var aMoment: TDateTime);
  var
    p: Integer;
  begin
    // Value
    p := pos(';', aValues);
    if p > 0 then
    begin
      aValue := Copy(aValues, 1, p - 1);
      aValues := Copy(aValues, p + 1, Length(aValues));
    end;

    if OPCSource.ProtocolVersion > 0 then
    begin
      // ErrorCode
      p := pos(';', aValues);
      if p > 0 then
      begin
        aErrorCode := StrToIntDef(Copy(aValues, 1, p - 1), 0);
        aValues := Copy(aValues, p + 1, Length(aValues));
      end;
    end;

    // ErrorStr
    p := pos(';', aValues);
    if p > 0 then
    begin
      aErrorStr := Copy(aValues, 1, p - 1);
      aValues := Copy(aValues, p + 1, Length(aValues));
      if OPCSource.ProtocolVersion = 0 then
      begin
        if aErrorStr <> '' then
          aErrorCode := 1
        else
          aErrorCode := 0;
      end;
    end;

    // Moment
    p := pos(';', aValues);
    if p > 0 then
    begin
      aMoment := StrToDateTime(Copy(aValues, 1, p - 1), OPCSource.OpcFS);
      aValues := Copy(aValues, p + 1, Length(aValues));
    end
    else
    begin
      aMoment := StrToDateTime(aValues, OPCSource.OpcFS);
      aValues := '';
    end;
  end;

begin
  TimeOfLastBadConnect := 0;

  GroupsForUpdate := TOPCDataLinkGroupList.Create;
  ValuesStream := TMemoryStream.Create;

  // CoInitialize(nil);
  try
    while not Terminated do
    begin
      try
        DoLog('begin');

        if OPCSource.IsLocked then
        begin
          Sleep(MinInterval);
          Continue;
        end;

        // обновление списка адресов запрашиваемых датчиков (пакетный режим) и
        // очистка помеченных на удаление групп
        if OPCSource.FDataLinkGroupsChanged then
          OPCSource.CalcPhysIDs;

        DoLog('Получение группы данных...');
{$REGION 'Получение группы данных'}
        aExceptionMessage := '';

        // режим получения данных по всем тегам в потоке
        if OPCSource.UpdateMode = umStreamPacket then
        begin
          try
            DoLog('FillSensorsValuesStream...');
            OPCSource.FillSensorsValuesStream(ValuesStream);
            DoLog('FillSensorsValuesStream OK');
            if OPCSource.ProtocolVersion in сV30_ProtocolSet then
            begin
              if ValuesStream.Position < ValuesStream.Size then
                ValuesStream.Read(aIndex_V30, SizeOf(aIndex_V30))
              else
                aIndex_V30 := $FFFF;
            end;
          except
            on e: EThreadTerminated do
              exit;
            on e: Exception do
            begin
              aExceptionMessage := e.Message;
              ValuesStream.Clear;
              Synchronize(OPCSource.SyncError);
              // SendMessage(OPCSource.FWindowHandle, am_Error, 0, 0);
            end;
          end;
        end

        else if OPCSource.PacketUpdate then
        begin
          try
            PhysIDs := OPCSource.FPhysIDs;
            if PhysIDs <> '' then
            begin
              if OPCSource.FPhysIDsChanged then
              begin
                OPCSource.FPhysIDsChanged := false;
                DoLog('GetSensorsValues...');
                Values := OPCSource.GetSensorsValues(PhysIDs);
                DoLog('GetSensorsValues OK');
              end
              else
                Values := OPCSource.GetSensorsValues('');
            end
            else
              Values := '';

            CurPhysID := ExtractPhysID(PhysIDs);
          except
            on e: EThreadTerminated do
              exit;
            on e: Exception do
            begin
              ConnectionError := e.Message;
              aExceptionMessage := e.Message;
              Values := '';
              CurPhysID := ExtractPhysID(PhysIDs);
              OPCSource.FPhysIDsChanged := True;
              Synchronize(OPCSource.SyncError);
              // SendMessage(OPCSource.FWindowHandle, am_Error, 0, 0);
            end;
          end;
        end;
{$ENDREGION}
        DoLog('Получение группы данных OK');

        DoLog('цикл по группам...');
        // цикл по группам
        GroupsForUpdate.Clear;

        for iGroup := 0 to OPCSource.FDataLinkGroups.Count - 1 do
        begin
          if Terminated then
            exit;

          DataLinkGroup := OPCSource.FDataLinkGroups.Items[iGroup];

          if not OPCSource.FPacketUpdate and ((OPCSource.UpdateMode = umEach) or ((OPCSource.UpdateMode = umAuto))) then
{$REGION 'umEach'}
          begin
            if DataLinkGroup.PhysID = '' then
              Continue;

            Moment := 0;
            try
              // OPCSource.Connect;
              try
                Value := OPCSource.GetSensorValue(DataLinkGroup.PhysID, ErrorCode, ErrorString, Moment);
                aDataRecived := True;
              except
                on e: EThreadTerminated do
                  exit;
                on e: Exception do
                begin
                  aExceptionMessage := e.Message;
                  Value := e.Message;
                  ErrorString := e.Message;
                  ErrorCode := 1;
                end;
              end;
            except
              on e: EThreadTerminated do
                exit;
              on e: Exception do
              begin
                ConnectionError := e.Message;
                if Terminated then
                  exit
                else
                  Synchronize(OPCSource.SyncError);
                // SendMessage(OPCSource.FWindowHandle, am_Error, 0, 0);
                // OPCSource.Disconnect;
                for j := 0 to 10000 div MinInterval do
                begin
                  if Terminated then
                    exit;
                  Sleep(MinInterval);
                  if Terminated then
                    exit;
                end;
                break;
              end;
            end;
          end
{$ENDREGION}
          else if OPCSource.UpdateMode = umStreamPacket then
{$REGION 'umStreamPacket'}
          begin
            if aExceptionMessage <> '' then
            begin
              aDataRecived := True;
              Value := DataLinkGroup.Value;
              TryStrToFloat(Value, DataLinkGroup.FloatValue);
              ErrorCode := -1;
              ErrorString := aExceptionMessage;
              Moment := DataLinkGroup.Moment;
            end
            else
            begin
              if (OPCSource.ProtocolVersion in сV30_ProtocolSet) then
              begin
                aDataRecived := (iGroup = aIndex_V30);
                if aDataRecived then
                begin
                  ValuesStream.Read(aSensorData_V30, SizeOf(aSensorData_V30));

                  Value := FloatToStr(aSensorData_V30.Value);

                  ErrorCode := aSensorData_V30.ErrorCode;
                  if ErrorCode = 0 then
                    ErrorString := ''
                  else if Assigned(OPCSource.States) then
                    ErrorString := OPCSource.States.Items.Values[IntToStr(ErrorCode)];

                  Moment := aSensorData_V30.Time;

                  if ValuesStream.Position < ValuesStream.Size then
                    ValuesStream.Read(aIndex_V30, SizeOf(aIndex_V30));
                end;
              end
              else
              begin
                if ValuesStream.Position >= ValuesStream.Size then
                  Continue;

                ValuesStream.Read(SensorData, SizeOf(SensorData));

                Value := FloatToStr(SensorData.Value);

                ErrorCode := SensorData.ErrorCode;
                if ErrorCode = 0 then
                  ErrorString := ''
                else if Assigned(OPCSource.States) then
                  ErrorString := OPCSource.States.Items.Values[IntToStr(ErrorCode)];

                Moment := SensorData.Time;
                aDataRecived := True;
              end;
            end;
          end
{$ENDREGION}
          else
{$REGION 'umPacket'}
          begin
            DataLinkGroup := TOPCDataLinkGroup(OPCSource.FDataLinkGroups.Items[iGroup]);

            if (DataLinkGroup.PhysID = CurPhysID) and (DataLinkGroup.PhysID <> '') then
            begin
              if (Values = '') and (aExceptionMessage = '') then
              begin
                OPCSource.FDataLinkGroupsChanged := True;
                Continue;
              end;

              if aExceptionMessage = '' then
              begin
                aDataRecived := OPCSource.ExtractValue(Values, Value, ErrorCode, ErrorString, Moment);
                CurPhysID := ExtractPhysID(PhysIDs);
              end
              else
              begin
                aDataRecived := True;
                Value := DataLinkGroup.Value;
                TryStrToFloat(Value, DataLinkGroup.FloatValue);
                ErrorCode := -1;
                ErrorString := aExceptionMessage;
                Moment := DataLinkGroup.Moment;
                CurPhysID := ExtractPhysID(PhysIDs);
              end;
            end
            else
              Continue;
          end;
{$ENDREGION}
          if DataLinkGroup.PhysID = '' then
            Continue;

          if DataLinkGroup.UpdateOnChangeMoment or DataLinkGroup.NeedUpdate
            or
            (
            aDataRecived and
            ((DataLinkGroup.Value <> Value) or
            (DataLinkGroup.ErrorCode <> ErrorCode) or
            (DataLinkGroup.ErrorString <> ErrorString))
            ) then
          begin
            if Terminated then Exit;

            if DataLinkGroup.UpdateOnChangeMoment then
              Moment := OPCSource.ServerTime; // now;

            if aDataRecived then
            begin
              if DataLinkGroup.Value <> Value then
                DataLinkGroup.OldValue := DataLinkGroup.Value;

              DataLinkGroup.Value := Value;
              TryStrToFloat(Value, DataLinkGroup.FloatValue);
              DataLinkGroup.ErrorString := ErrorString;
              DataLinkGroup.ErrorCode := ErrorCode;
              DataLinkGroup.Moment := Moment;
            end
            else if DataLinkGroup.UpdateOnChangeMoment then
              DataLinkGroup.Moment := Moment;


            if Terminated then Exit;

            if (OPCSource.PacketUpdate and (OPCSource.UpdateMode = umAuto))
              or (OPCSource.UpdateMode in [umPacket, umStreamPacket]) then
            begin
              GroupsForUpdate.Add(DataLinkGroup);
              if GroupsForUpdate.Count > cMaxGroupForSingleUpdate then
              begin
                if Terminated then
                  exit;
                Synchronize(OPCSource.SyncUpdateDataLinksData);
                // SendMessage(OPCSource.FWindowHandle, am_UpdateDataLinksData, 0, 0);
                OPCSource.DoUpdateDataLinksThreaded;

                if Terminated then
                  exit;
                Synchronize(OPCSource.SyncUpdateDataLinks);
                // SendMessage(OPCSource.FWindowHandle, am_UpdateDataLinks, 0, 0);
                GroupsForUpdate.Clear;
              end;
            end
            else
              Synchronize(OPCSource.SyncChangeData);
            // SendMessage(OPCSource.FWindowHandle, am_ChangeData, 0, 0);
          end;

        end;
        DoLog('цикл по группам OK');

        DoLog('SyncUpdateDataLinks...');
        if GroupsForUpdate.Count > 0 then
        begin
          if Terminated then
            exit;
          Synchronize(OPCSource.SyncUpdateDataLinksData);
          // SendMessage(OPCSource.FWindowHandle, am_UpdateDataLinksData, 0, 0);
          OPCSource.DoUpdateDataLinksThreaded;

          if Terminated then
            exit;
          Synchronize(OPCSource.SyncUpdateDataLinks);
          // SendMessage(OPCSource.FWindowHandle, am_UpdateDataLinks, 0, 0);
          GroupsForUpdate.Clear;
        end;
        DoLog('SyncUpdateDataLinks OK');

        // проверим наличие новых сообщений от других пользователей
        DoLog('Check message...');
        repeat
          // читаем сообщение с сервера
          aUserMessage := OPCSource.GetMessage;
          if not Assigned(aUserMessage) then
            break;

          // добавляем его в список
          OPCSource.UserMessages.AddMessage(aUserMessage);
          // сообщим о новом сообщении пользователю
          Synchronize(OPCSource.SyncNewUserMessage);
          // SendMessage(OPCSource.FWindowHandle, am_NewUserMessage, 0, 0);
        until Terminated or not(Assigned(aUserMessage));
        DoLog('Check message OK');

        // отчитаемся, что мы прошли цикл опроса
        OPCSource.CurrentMoment := OPCSource.GetServerTime; // Now;

        if Terminated then
          exit;

        DoLog('SyncRequest...');
        Synchronize(OPCSource.SyncRequest);
        DoLog('SyncRequest OK');
        // SendMessage(OPCSource.FWindowHandle, am_Request, 0, 0);

        DoLog('before wait');
        for j := 0 to Interval div MinInterval do
        begin
          if Terminated then
            exit;
          if ForceUpdate then
          begin
            ForceUpdate := false;
            break;
          end;
          Sleep(MinInterval);
          if Terminated then
            exit;
        end;
        DoLog('after wait');

        DoLog('begin');
      except
        on e: EThreadTerminated do
          exit;
        on e: Exception do
          OPCLog.WriteToLog('Ошибка в потоке : ' + e.Message);
      end;


    end;
  finally
    // CoUninitialize;
    ValuesStream.Free;
    GroupsForUpdate.Free;
    // OutputDebugString('Выход из потока TOPCUpdateThread');
  end;
end;

function TOPCUpdateThread.GetOPCSource: TaOPCSource;
begin
  if Terminated then
    raise
      EThreadTerminated.Create('Попытка обращения к OPCSource во время остановки потока.');

  Result := FOPCSource;
end;

procedure TOPCUpdateThread.UpdateStreamPacket_V30;
var
  aStream: TMemoryStream;
  aStreamSize: Int64;
  aIndex: Word;
  aRec: TDCSensorDataRec_V30;
begin
  aStream := TMemoryStream.Create;
  try
    OPCSource.FillSensorsValuesStream(aStream);

    aStreamSize := aStream.Size;
    aStream.Position := 0;
    while aStream.Position < aStreamSize do
    begin
      aStream.Read(aIndex, SizeOf(aIndex));
      aStream.Read(aRec, SizeOf(aRec));

    end;

  finally
    aStream.Free;
  end;
end;

{
  procedure TOPCUpdateThread.SetActiveFalse;
  begin
  OPCSource.fActive:=false;
  if Assigned(OPCSource.OnDeactivate) then
  OPCSource.OnDeactivate(OPCSource);
  end;
}

{
  procedure TOPCUpdateThread.SetActiveTrue;
  begin
  OPCSource.fActive:=true;
  if Assigned(OPCSource.OnActivate) then
  OPCSource.OnActivate(OPCSource);
  end;
}
{
  procedure TOPCUpdateThread.UpdateData;
  begin

  CrackDataLink:=TCrackOPCLink(OPCSource.FDataLinks.Items[DataLinkIndex]);

  CrackDataLink.fErrorCode:=ErrorCode;
  CrackDataLink.fErrorString:=ErrorString;
  CrackDataLink.fValue:=Value;
  CrackDataLink.fMoment:=Moment;
  CrackDataLink.ChangeData;

  end;
}

procedure TaOPCSource.SetAvtoShowMessage(const Value: Boolean);
begin
  FAvtoShowMessage := Value;
end;

procedure TaOPCSource.SetConnected(const Value: Boolean);
begin
  if (csReading in ComponentState) then
    FStreamedConnected := Value
  else
  begin
    FNameSpaceTimeStamp := 0;
    if Value then
      Connect
    else
      Disconnect;
  end;
end;

function TaOPCSource.GetSensorValue(PhysID: string;
  var ErrorCode: integer; var ErrorString: string;
  var Moment: TDateTime): string;
begin
  Result := 'GetSensorValue Реализация только у наследников';
end;

function TaOPCSource.GetValue(PhysID: string; aAsText: Boolean = False): string;
begin
end;

procedure TaOPCSource.HistoryDateToClient(Stream: TStream; aDataKindSet: TDataKindSet);
var
  d: TDateTime;
  aRecSize: Int64;
begin
  if ServerOffsetFromUTC = ClientOffsetFromUTC then
    Exit;

  aRecSize := 0;

  if dkValue in aDataKindSet then
    aRecSize := aRecSize + SizeOf(Extended);
  if dkState in aDataKindSet then
    aRecSize := aRecSize + SizeOf(Extended);
  if dkUser in aDataKindSet then
    aRecSize := aRecSize + SizeOf(Extended);

  Stream.Position := 0;
  while Stream.Position < Stream.Size do
  begin
    Stream.Read(d, SizeOf(d));
    d := DateToClient(d);
    Stream.Position := Stream.Position - SizeOf(d);
    Stream.Write(d, SizeOf(d));
    Stream.Position := Stream.Position + aRecSize;
  end;
  Stream.Position := 0;

end;

procedure TaOPCSource.IncSensorValue(PhysID: string; aIncValue: Double; Moment: TDateTime);
begin
  raise ENotImplemented.Create('IncSensorValue not Implemented');
end;

procedure TaOPCSource.InsertValues(PhysID: string; aBuffer: TSensorDataArr);
begin

end;

function TaOPCSource.IsReal: Boolean;
begin
  Result := True;
end;

procedure TaOPCSource.SetDescription(const Value: string);
begin
  FDescription := Value;
end;

function TaOPCSource.SetDeviceProperties(id: string; sl: TStrings): string;
begin

end;

procedure TaOPCSource.SetEnableMessage(const Value: Boolean);
begin
  FEnableMessage := Value;
end;

function TaOPCSource.SetGroupProperties(id: string; sl: TStrings): string;
begin

end;

function TaOPCSource.GetClientList: string;
begin
  Result := 'GetClientList Реализация только у наследников';
end;

function TaOPCSource.GetDeviceProperties(id: string): string;
begin

end;

function TaOPCSource.GetGroupProperties(id: string): string;
begin

end;

function TaOPCSource.GetNameSpaceFileName: string;
begin
  Result := OPCCash.Path + '\' + GetOPCName + '_NameSpace.cash';
end;

function TaOPCSource.GetOPCName: string;
begin
  Result := RemoteMachine;
end;

function TaOPCSource.GetPermissions(PhysIDs: string): string;
begin

end;

function TaOPCSource.GetSensorValueOnMoment(PhysID: string;
  var Moment: TDateTime): string;
begin
  Result := 'GetSensorValueOnMoment Реализация только у наследников';
end;

function TaOPCSource.GetServerTime: TDateTime;
begin
  Result := 0;
  if FServerTimeDataLink.PhysID <> '' then
    Result := StrToFloatDef(FServerTimeDataLink.Value, 0);

  if Result = 0 then
    Result := Now;
end;

function TaOPCSource.GetServerTimeID: TPhysID;
begin
  Result := FServerTimeDataLink.PhysID;
end;

//function TaOPCSource.GetStringRes(idx: UInt32): String;
//begin
//  Result := uDCLang.GetStringRes(idx, Ord(Language));
//end;
//
//function TaOPCSource.GetStringResStr(idx: string): String;
//begin
//  Result := uDCLang.GetStringResStr(idx, LanguageToStr(Language));
//end;

procedure TaOPCSource.DoRequest;
var
  iGroup, iDataLink: Integer;
  //DataLinkGroup: TOPCDataLinkGroup;
  //DataLink: TaOPCDataLink;
begin
  for iGroup := FDataLinkGroups.Count - 1 downto 0 do
  begin
    //DataLinkGroup := TOPCDataLinkGroup(FDataLinkGroups.Items[iGroup]);
    if not Assigned(FDataLinkGroups[iGroup]) then
      Continue;

    for iDataLink := FDataLinkGroups[iGroup].DataLinks.Count - 1 downto 0 do
    begin
      //DataLink := TaOPCDataLink(DataLinkGroup.DataLinks[iDataLink]);
      if Assigned(FDataLinkGroups[iGroup].DataLinks[iDataLink])
        and Assigned(FDataLinkGroups[iGroup].DataLinks[iDataLink].OnRequest) then
        FDataLinkGroups[iGroup].DataLinks[iDataLink].OnRequest(FDataLinkGroups[iGroup].DataLinks[iDataLink]);
    end;
  end;

  if Assigned(FOnRequest) then
    FOnRequest(Self);
end;

procedure TaOPCSource.DoUpdateDataLinksData;
var
  i: integer;
  iGroup: integer;
  CrackDataLink: TCrackOPCLink;
  DataLinkGroup: TOPCDataLinkGroup;
  aGroupValue: string;
  aGroupFloatValue: Double;
begin
  for iGroup := 0 to FThread.GroupsForUpdate.Count - 1 do
  begin
    DataLinkGroup := TOPCDataLinkGroup(FThread.GroupsForUpdate.Items[iGroup]);
    DataLinkGroup.NeedUpdate := False;

    if OpcFS.DecimalSeparator <> FormatSettings.DecimalSeparator then
      aGroupValue := StringReplace(DataLinkGroup.Value, OpcFS.DecimalSeparator, FormatSettings.DecimalSeparator, [])
    else
      aGroupValue := DataLinkGroup.Value;

    TryStrToFloat(aGroupValue, aGroupFloatValue);


    for i := 0 to DataLinkGroup.DataLinks.Count - 1 do
    begin
      CrackDataLink := TCrackOPCLink(DataLinkGroup.DataLinks.Items[i]);

      CrackDataLink.FErrorCode := DataLinkGroup.ErrorCode;
      CrackDataLink.FErrorString := DataLinkGroup.ErrorString;

      // если еще не было данных, то будем считать Старые равными Новым
      if CrackDataLink.FOldValue = '' then
      begin
        CrackDataLink.FOldValue := aGroupValue;
        CrackDataLink.FOldFloatValue := aGroupFloatValue;
      end
      else
      begin
        CrackDataLink.FOldValue := CrackDataLink.FValue;
        CrackDataLink.FOldFloatValue := CrackDataLink.FFloatValue;
      end;

      CrackDataLink.FValue := aGroupValue;
      CrackDataLink.FFloatValue := aGroupFloatValue;


      CrackDataLink.FMoment := DataLinkGroup.Moment;
    end;
  end;
end;

// function TaOPCSource.GetSensorProperties(id: string): TSensorProperties;
// begin
// end;

function TaOPCSource.GetSensorPropertiesEx(id: string): string;
begin

end;

function TaOPCSource.GetSensorsValueOnMoment(PhysIDs: string; Moment: TDateTime): string;
begin
  Result := 'GetSensorsValueOnMoment Реализация только у наследников';
end;

function TaOPCSource.GetSensorsValues(PhysIDs: string): string;
begin
  Result := 'Error:GetSensorsValues Реализация только у наследников';
end;

procedure TaOPCSource.SetPacketUpdate(const Value: Boolean);
begin
  FPacketUpdate := Value;
  if FPacketUpdate then
    CalcPhysIDs;
end;

// процедура вызывается только внутри потока и только она может уменьшить
// размер списка групп FDataLinkGroups

procedure TaOPCSource.CalcPhysIDs;
var
  i: Integer;
  aNeedPack: Boolean;
  aDataLinkGroup: TOPCDataLinkGroup;
begin
  FPhysIDs := '';
  FPhysIDsChanged := True;

  aNeedPack := false;
  for i := 0 to FDataLinkGroups.Count - 1 do
  begin
    aDataLinkGroup := TOPCDataLinkGroup(FDataLinkGroups.Items[i]);

    // помеченные на удаление удаляем
    if Assigned(aDataLinkGroup) and aDataLinkGroup.Deleted then
    begin
      FDataLinkGroups.Items[i] := nil;
      FreeAndNil(aDataLinkGroup);
    end;

    // расчитываем необходимость упаковки
    if not Assigned(aDataLinkGroup) then
    begin
      aNeedPack := True;
      Continue;
    end;

    if PacketUpdate and (aDataLinkGroup.PhysID <> '') then
    begin
      if UpdateMode in [umAuto, umPacket, umStreamPacket] then
        FPhysIDs := FPhysIDs + ';' + aDataLinkGroup.PhysID;
    end;
  end;

  FPhysIDs := Copy(FPhysIDs, 2, Length(FPhysIDs));

  if aNeedPack then
  begin
    FDataLinkGroupsLock.Enter;
    try
      // упаковку выполняем в критической секции
      FDataLinkGroups.Pack;
    finally
      FDataLinkGroupsLock.Leave;
    end;
  end;

  if not (UpdateMode in [umStreamPacket]) then
    FDataLinkGroupsChanged := false;
  //ForceUpdate;
end;

procedure TaOPCSource.AddDataLink(DataLink: TaOPCDataLink;
  OldSource: TaCustomOPCSource = nil);
begin
  inherited AddDataLink(DataLink, OldSource);
  FDataLinkGroupsChanged := True;
  // ForceUpdate;
  // CalcPhysIDs;
end;

procedure TaOPCSource.Loaded;
begin
  inherited Loaded;
  Connected := FStreamedConnected;
end;

function TaOPCSource.LoadLookup(aName: string;
  var aTimeStamp: TDateTime): string;
begin
  Result := 'Error:LoadLookup Реализация только у наследников';
end;

procedure TaOPCSource.LoadNameSpace(aCustomIniFile: TCustomIniFile;
  aSectionName: string = '');
begin
  if aSectionName = '' then
    aSectionName := 'NameSpace'
  else
    aSectionName := aSectionName + '\NameSpace';

  FNameSpaceTimeStamp := aCustomIniFile.ReadDateTime(aSectionName, 'TimeStamp', 0);

  if FileExists(GetNameSpaceFileName) then
    // загружаемся из файла (новый режим)
    FNameSpaceCash.LoadFromFile(GetNameSpaceFileName)
  else
    // попытаемся использовать старый режим загрузки из реестра
    aCustomIniFile.ReadSection(aSectionName + 'Data', FNameSpaceCash);

end;

function TaOPCSource.OPCStringToFloat(aStr: string): Double;
begin
  if OpcFS.DecimalSeparator <> FormatSettings.DecimalSeparator then
    Result := StrToFloat(StringReplace(aStr, OpcFS.DecimalSeparator, FormatSettings.DecimalSeparator, []))
  else
    Result := StrToFloat(aStr);
end;

{
procedure TaOPCSource.NameStaceToObjectList(var aObjectList: TDCObjectList);
var
  i: Integer;
  ALevel: Integer;
  //aObjectLevel: Integer;
  aCaption: string;
  Data: TStrings;
  CurrStr: string;
  aObject, aNewObject, aNextObject: TDCObject;
  //aSensor: TDCCustomSensor;
  CaseStairs: integer;
  aRefTableName: string;
begin
  // уже добавленный в список объект
  aObject := nil;

  // проходим по предварительно загруженной иерархии
  for i := 0 to FNameSpaceCash.Count - 1 do
  begin
    // вычитываем информационную строку и определяем грубину вложенности
    CurrStr  := GetBufStart(PChar(FNameSpaceCash[i]), ALevel);

    // вычитываем наименование объекта
    aCaption := ExtractData(CurrStr);

    // вычитываем данные по объекту, создаем и наполняем объект
    Data := TStringList.Create;
    try
      while CurrStr<>'' do
        Data.Add(ExtractData(CurrStr));

      if Data.Strings[1] = '1' then
      begin
        aNewObject := TDCObject.Create;
        aNewObject.Kind  := StrToIntDef(Data.Strings[2],1000);
        aNewObject.ServerChildCount := StrToIntDef(Data.Strings[5], 0);
      end
      else
      begin
        aNewObject := TSensor.Create;
        aNewObject.Kind := 0;

        with TSensor(aNewObject) do
        begin
          DisplayFormat := Data.Strings[2];
          SensorUnitName := Data.Strings[3];
//            SensorKind    := StrToIntDef(Data.Strings[1],0);
//
            aRefTableName := Data.Strings[6];
            if aRefTableName <> '' then
            begin
              LookupList := aOPCConnection.GetLookupByTableName(aRefTableName);
              if Data.Count >= 10 then
              begin
                if Data.Strings[9] = '1' then
                  LookupList.ShowValue := svLeft
                else if Data.Strings[9] = '2' then
                  LookupList.ShowValue := svRight;
              end;
            end;

          CaseStairs := StrToIntDef(Data.Strings[5],0);
          case CaseStairs of
            0: StairsOptions := [soIncrease,soDecrease];
            1: StairsOptions := [];
            2: StairsOptions := [soIncrease];
            3: StairsOptions := [soDecrease];
          end;
        end;
      end;

      // добавляем объект в список
      aObjectList.Add(aNewObject);
      //aNewObject.Owner := aOPCConnection;

      aNewObject.Name  := aCaption;
      aNewObject.IDStr := Data.Strings[0];

      // определяем родетеля обхекта
      if aObject = nil then
        aNewObject.Parent := nil
      else if aObject.Level = ALevel then
        aNewObject.Parent := aObject.Parent
      else if aObject.Level = (ALevel - 1) then
        aNewObject.Parent := aObject
      else if aObject.Level > ALevel then
      begin
        aNextObject := aObject.Parent;
        while Assigned(aNextObject) and (aNextObject.Level >= ALevel) do
          aNextObject := aNextObject.Parent;
        aNewObject.Parent := aNextObject;
      end
      else
        raise Exception.CreateFmt('ALevel=%d - aObject.Level=%d',[ALevel, aObject.Level]);

      aObject := aNewObject;
    finally
      FreeAndNil(Data);
    end;
  end;
end;
}

procedure TaOPCSource.SaveNameSpace(aCustomIniFile: TCustomIniFile; aSectionName: string = '');
// var
// i:integer;
begin
  if aSectionName = '' then
    aSectionName := 'NameSpace'
  else
    aSectionName := aSectionName + '\NameSpace';

  try
    FNameSpaceCash.SaveToFile(GetNameSpaceFileName);
    // сохраняем время последнего обновления
    aCustomIniFile.WriteDateTime(aSectionName, 'TimeStamp', FNameSpaceTimeStamp);
  except
    on e: Exception do
      OPCLog.WriteToLogFmt('Не удалось сохранить иерархию в файл %s. Ошибка: %s',
        [GetNameSpaceFileName, e.Message]);
  end;
  { СТАРЫЙ ВАРИАНТ ХРАНЕНИЯ
    //очищаем секцию с данными
    aCustomIniFile.EraseSection(aSectionName+'Data');
    //сохраняем новые данные
    for i:=0 to FNameSpaceCash.Count-1 do
    aCustomIniFile.WriteString(aSectionName+'Data',FNameSpaceCash.Strings[i],IntToStr(i));
  }
  // FNameSpaceCash.SaveToFile(GetNameSpaceFileName);
end;

procedure TaOPCSource.ChangeData;
var
  DataLinkGroup: TOPCDataLinkGroup;
  i: Integer;
  CrackDataLink: TCrackOPCLink;
  tmpFloat: extended;
begin
  DataLinkGroup := FThread.DataLinkGroup;
  // TOPCDataLinkGroup(DataLinkGroups.Items[fThread.DataLinkGroupIndex]);
  DataLinkGroup.NeedUpdate := false;
  for i := 0 to DataLinkGroup.DataLinks.Count - 1 do
  begin
    CrackDataLink := TCrackOPCLink(DataLinkGroup.DataLinks.Items[i]);

    CrackDataLink.FErrorCode := DataLinkGroup.ErrorCode; // fThread.ErrorCode;
    CrackDataLink.FErrorString := DataLinkGroup.ErrorString;
    // fThread.ErrorString;

    CrackDataLink.FValue := DataLinkGroup.Value;
    if OpcFS.DecimalSeparator <> FormatSettings.DecimalSeparator then
    begin
      tmpFloat := StrToFloatDef(CrackDataLink.FValue, UnUsedValue, OpcFS);
      if tmpFloat <> UnUsedValue then
        CrackDataLink.FValue := FloatToStr(tmpFloat);
    end;

    CrackDataLink.FMoment := DataLinkGroup.Moment; // fThread.Moment;
    CrackDataLink.ChangeData;
  end; // for
end;

procedure TaOPCSource.CheckAnswer(aAnswer: string; aParamCount: Integer = 0);
var
  i: Integer;
  aFoundParamCount: Integer;
begin
  if Copy(aAnswer, 1, Length(sError)) = sError then
    raise Exception.Create(Copy(aAnswer, Length(sError) + 1, Length(aAnswer)))
  else if Copy(aAnswer, 1, Length(sOk)) <> sOk then
    raise Exception.CreateFmt(sUnknownAnswer, [aAnswer]);

  if aParamCount <> 0 then
  begin
    if Length(aAnswer) > Length(sOk) then
      aFoundParamCount := 1
    else
      aFoundParamCount := 0;

    for i := 1 to Length(aAnswer) do
      if aAnswer[i] = cParamsDelimiter then
        inc(aFoundParamCount);

    if aParamCount <> aFoundParamCount then
      raise Exception.CreateFmt(sBadParamCount, [aFoundParamCount, aParamCount]);
  end;
end;



procedure TaOPCSource.CheckForNewNameSpace(aCustomIniFile: TCustomIniFile;
  aSectionName: string = '';
  aReconnect: boolean = false);
begin
  if not aReconnect then
    FNameSpaceTimeStamp := aCustomIniFile.ReadDateTime(aSectionName +
      '\NameSpace', 'TimeStamp', 0)
  else
    FNameSpaceTimeStamp := -1;

  if Connected and GetNameSpace then
    SaveNameSpace(aCustomIniFile, aSectionName)
  else
    LoadNameSpace(aCustomIniFile, aSectionName);
end;

procedure TaOPCSource.CheckLock;
begin

end;

procedure TaOPCSource.SetUpdateMode(const Value: TaOPCUpdateMode);
begin
  FUpdateMode := Value;

  if FUpdateMode = umPacket then
    PacketUpdate := True
  else if FUpdateMode = umEach then
    PacketUpdate := false;
end;

procedure TaOPCSource.Authorize(aUser: string; aPassword: string);
begin
end;

function TaOPCSource.SendModBus(aSystemType: integer; aRequest: string;
  aRetByteCount, aTimeOut: integer): string;
begin
  Result := 'SendModBus Реализация только у наследников';
end;

function TaOPCSource.SendModBusEx(aConnectionName, aRequest: string;
  aRetByteCount, aTimeOut: integer): string;
begin
  Result := 'SendModBusEx Реализация только у наследников';
end;

end.

