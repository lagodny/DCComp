unit aCustomOPCTCPSource;

interface

uses
  SysUtils, Classes,
  {$IFDEF MSWINDOWS}
  //Messages,
  Windows,
  {$ENDIF}
  DateUtils,
  //aCustomOPCSource,
  aOPCSource,
  IdTCPClient, IdGlobal, IdException, SyncObjs
  , IdStackConsts
  , IdIOHandler, IdIOHandlerSocket, IdSSLOpenSSL
  , IdCompressionIntercept

  , aDCIntercept
  , uDCObjects, uUserMessage, uOPCTCPConnection
//  , uDCLang
  ;

const
  //cDefWriteBufferThreshold = 1*1024*1024;

  cDefWriteBufferThreshold = 32768;

  cDefConnectTimeout = 5000;
  cDefReadTimeout = 60000;

  cDefCompressionLevel = 0;
  cDefEncrypt = False;

  cDefPort = 5555;

type
  EOPCTCPException = class(ENotInhibitException);
  EOPCTCPCommandException = class(EOPCTCPException);
  EOPCTCPUnknownAnswerException = class(EOPCTCPException);
  EOPCTCPOperationCanceledException = class(EOPCTCPException);

  TOPCProgressNotify = procedure(aIndex, aCount: Integer; var aCancel: boolean) of object;
  TOPCStatusNotify = procedure(aStatus: string; var aCancel: boolean) of object;

  TaCustomOPCTCPSource = class(TaOPCSource)
  private
    FConnectionLock: TCriticalSection;

    FConnection: TOPCTCPConnection;
    FIntercept: TaDCIntercept;

    FMainPort: integer;
    FMainHost: string;
    FAltPort: integer;
    FAltHost: string;
    FAltAddress: string;

    //FTimeOut: integer;
    FCompressionLevel: integer;
//    FLanguage: TUserLanguage;
    FWriteBufferThreshold: Integer;
    FOnProgress: TOPCProgressNotify;

    function GetPort: integer;
    procedure SetPort(const Value: integer);

    function GetCompressionLevel: integer;

    function GetIOHandler: TIdIOHandler;

    procedure SetMainHost(const Value: string);
    procedure SetMainPort(const Value: integer);

    procedure SetWriteBufferThreshold(const Value: Integer);

    function GetConnectTimeOut: integer;
    procedure SetConnectTimeOut(const Value: integer);

    function GetReadTimeOut: integer;
    procedure SetReadTimeOut(const Value: integer);

  protected
    procedure AssignTo(Dest: TPersistent); override;

    function GetEncrypt: boolean; virtual;
    procedure SetEncrypt(const Value: boolean); virtual;

//    procedure SetLanguage(const Value: TUserLanguage); virtual;


    // работа с TCP клиентом
    procedure ClearIncomingData;

    procedure SendCommand(aCommand: string);
    procedure SendCommandFmt(aCommand: string; const Args: array of TVarRec);

    function ReadLn: string;
    function ReadString(aByteCount: Integer): string;

    procedure ReadStream(aStream: TStream; AByteCount: Integer = -1;  const AReadUntilDisconnect: Boolean = False);
    procedure WriteStream(aStream: TStream; const AAll: boolean = true; const AWriteByteCount: Boolean = true; const ASize: Integer = 0);

    procedure OpenWriteBuffer;
    procedure CloseWriteBuffer;


    // обработка ошибок TCP
    function ProcessTCPException(e: EIdException): Boolean;

    procedure SetCompressionLevel(const Value: integer); virtual;

    function GetRemoteMachine: string; override;
    procedure SetRemoteMachine(const Value: string); override;

    function GetConnected: boolean; override;

    procedure CheckLock; override;

    procedure TryConnect; virtual;
    function TryAltReconnect: boolean;
    procedure Reconnect; override;
    procedure DoConnect; override;
    procedure DoDisconnect; override;

    procedure Connect; override;
    procedure Disconnect; override;

    property IOHandler: TIdIOHandler read GetIOHandler;
    property Intercept: TaDCIntercept read FIntercept;
    property Connection: TOPCTCPConnection read FConnection;
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;

    function GetOPCName: string; override;
//    function GetStringRes(idx: DWORD): WideString;


    function LockConnection(aMessage: string = ''): TOPCTCPConnection;
    procedure UnLockConnection(aMessage: string = '');

//    procedure SendUserMessage(aUserGUID: string; aMessage: string); override;
//    function GetMessage: TUserMessage; override;


  published
    property Connected;
    // уровень сжатия
    property CompressionLevel: integer read GetCompressionLevel write SetCompressionLevel default cDefCompressionLevel;
    // шифрование
    property Encrypt: boolean read GetEncrypt write SetEncrypt default cDefEncrypt;
    // максимальный объем буфера при передаче файлов и пр. больших объемов данных
    property WriteBufferThreshold: Integer read FWriteBufferThreshold write SetWriteBufferThreshold default cDefWriteBufferThreshold;

//    property Language: TUserLanguage read FLanguage write SetLanguage default langRU;

    // ожидание подключения
    property ConnectTimeOut: integer read GetConnectTimeOut write SetConnectTimeOut default cDefConnectTimeout;
    // ожидание отклика на команду
    property ReadTimeOut: integer read GetReadTimeOut write SetReadTimeOut default cDefReadTimeout;

    property Port: integer read GetPort write SetPort default cDefPort;

    // главные настройки подключения
    property MainHost: string read FMainHost write SetMainHost;
    property MainPort: integer read FMainPort write SetMainPort default cDefPort;
    // альтернативные настройки подключения будут использоваться,
    // когда основные не отработали
    property AltHost: string read FAltHost write FAltHost;
    property AltPort: integer read FAltPort write FAltPort default 0;

    property AltAddress: string read FAltAddress write FAltAddress;

    // обработка длительных операций
    property OnProgress: TOPCProgressNotify read FOnProgress write FOnProgress;
  end;

  function GetComputerName: string;
  function GetLocalUserName: string;

implementation

uses
  StrUtils, Math,
  IdTCPConnection,
  aOPCLog, aOPCconsts,
  DC.StrUtils;

  { TODO : Разобраться с GetLocalUserName }
  function GetLocalUserName: string;
  var
    Count: UInt32;
  begin
    Result := '';
    {$IFDEF MSWINDOWS}
      Count := 256 + 1; // UNLEN + 1
      SetLength(Result, Count);
      if GetUserName(PChar(Result), Count) then
        SetLength(Result, StrLen(PChar(Result)));
    {$ENDIF}
  end;

  function GetComputerName: string;
  var
    Size: UInt32;
  begin
    Result := '';
    {$IFDEF MSWINDOWS}
    Size := MAX_PATH;
    SetLength(Result, Size);
    if Windows.GetComputerName(PChar(Result), Size) then
      SetLength(Result, StrLen(PChar(Result)))
    else
      RaiseLastOSError;
    {$ENDIF}
  end;

{ TaCustomOPCTCPSource }

procedure TaCustomOPCTCPSource.AssignTo(Dest: TPersistent);
var
  aDest: TaCustomOPCTCPSource;
begin
  if not (Dest is TaCustomOPCTCPSource) then
    Exit;

  aDest := TaCustomOPCTCPSource(Dest);

  aDest.RemoteMachine := RemoteMachine;
  aDest.Port := Port;
  aDest.AltAddress := AltAddress;

  aDest.ConnectTimeOut := ConnectTimeOut;
  aDest.ReadTimeOut := ReadTimeOut;
  aDest.Interval := Interval;

  aDest.Encrypt := Encrypt;
  aDest.CompressionLevel := CompressionLevel;

  aDest.ServerTimeID := ServerTimeID;
  aDest.Description := Description;

//  aDest.Language := Language;

  aDest.User := User;
  aDest.Password := Password;
end;

procedure TaCustomOPCTCPSource.CheckLock;
begin
  // все длительные операции в потоке связаны с получением данных через TCP
  // такие операции выполняются в критической секции

  FConnectionLock.Enter;
  FConnectionLock.Leave;
end;

procedure TaCustomOPCTCPSource.ClearIncomingData;
begin
  while not FConnection.IOHandler.InputBufferIsEmpty do
  begin
    FConnection.IOHandler.InputBuffer.Clear;
    FConnection.IOHandler.CheckForDataOnSource(1);
  end;
end;

procedure TaCustomOPCTCPSource.CloseWriteBuffer;
begin
  FConnection.IOHandler.WriteBufferClose;
end;

procedure TaCustomOPCTCPSource.Connect;
begin
  inherited Connect;

  LockConnection;
  try
    DoConnect;
  finally
    UnLockConnection;
  end;
end;

constructor TaCustomOPCTCPSource.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);

  FConnectionLock := TCriticalSection.Create;
  FIntercept := TaDCIntercept.Create(nil);

  FConnection := TOPCTCPConnection.Create(nil);
  FConnection.ConnectTimeout := cDefConnectTimeout;
  FConnection.ReadTimeout := cDefReadTimeout;
  //FConnection.IOHandler
  //FConnection.UseNagle := False;
  //FConnection.ReuseSocket := rsTrue;


  //FConnection.OnDisconnected := OnDeactivate;

  RemoteMachine := 'localhost';
  Port := cDefPort;

//  ConnectTimeOut := 5000;
//  ReadTimeOut := 20000;

  FWriteBufferThreshold := cDefWriteBufferThreshold;
end;

destructor TaCustomOPCTCPSource.Destroy;
begin
  Active := False;
  Disconnect;
  if Assigned(IOHandler) then
    IOHandler.Free;
  FConnection.Free;

  FreeAndNil(FIntercept);
  FreeAndNil(FConnectionLock);

  inherited Destroy;
end;

procedure TaCustomOPCTCPSource.Disconnect;
begin
  inherited;

  Active := false;

  if Connected then
    SendCommand('Close');

  DoDisconnect;
  
//  FConnection.Disconnect;
//
//  if not (csDestroying in ComponentState) then
//  begin
//    if Assigned(OnDeactivate) then
//      OnDeactivate(Self);
//  end;
end;

procedure TaCustomOPCTCPSource.DoConnect;
begin
  if not FConnection.Connected then
    Reconnect
  else
  begin
    try
      FConnection.CheckForGracefulDisconnect(true);
    except
      Reconnect;
    end;
  end;
end;

procedure TaCustomOPCTCPSource.DoDisconnect;
begin
  FConnection.Disconnect;

  if not (csDestroying in ComponentState) then
  begin
    { TODO : Добавить отработку события OnDisconnect }
//    if Assigned(OnDisconnect) then
//      PostMessage(FWindowHandle, am_Disconnect, 0, 0);
  end;
end;

function TaCustomOPCTCPSource.GetCompressionLevel: integer;
begin
  Result := FCompressionLevel;
end;

function TaCustomOPCTCPSource.GetConnected: boolean;
var
  aLock: TOPCTCPConnection;
begin
  aLock := LockConnection('GetConnected');
  try
    Result := aLock.Connected;
  finally
    UnLockConnection('GetConnected');
  end;
end;

function TaCustomOPCTCPSource.GetIOHandler: TIdIOHandler;
begin
  Result := FConnection.IOHandler;
end;

function TaCustomOPCTCPSource.GetOPCName: string;
begin
  Result := Format('%s %d', [RemoteMachine, Port]);
end;

function TaCustomOPCTCPSource.GetPort: integer;
begin
  Result := FConnection.Port;
end;

function TaCustomOPCTCPSource.GetReadTimeOut: integer;
begin
  Result := Connection.ReadTimeout;
end;

function TaCustomOPCTCPSource.GetRemoteMachine: string;
begin
  Result := Connection.Host;
end;

function TaCustomOPCTCPSource.GetConnectTimeOut: integer;
begin
  Result := Connection.ConnectTimeout;
end;

//function TaCustomOPCTCPSource.GetStringRes(idx: DWORD): WideString;
//begin
//  Result := uDCLang.GetStringRes(idx, Ord(Language));
//end;

function TaCustomOPCTCPSource.GetEncrypt: boolean;
begin
  Result := Assigned(IOHandler) and (IOHandler is TIdSSLIOHandlerSocketOpenSSL);
end;

function TaCustomOPCTCPSource.LockConnection(aMessage: string = ''): TOPCTCPConnection;
begin
  //OPCLog.WriteToLogFmt('%d: LockConnection %s', [GetCurrentThreadId, aMessage]);
  FConnectionLock.Enter;
  Result := FConnection;
  //OPCLog.WriteToLogFmt('%d: LockConnection OK. %s', [GetCurrentThreadId, aMessage]);
end;

procedure TaCustomOPCTCPSource.OpenWriteBuffer;
begin
  FConnection.IOHandler.WriteBufferOpen(WriteBufferThreshold);
end;

function TaCustomOPCTCPSource.ProcessTCPException(e: EIdException): Boolean;
begin
  Result := True;
  //Connection.Disconnect;
  OPCLog.WriteToLog(e.Message);
  DoDisconnect;
  //raise EIdException.Create(e.Message);
end;

function TaCustomOPCTCPSource.ReadLn: string;
begin
  Result := FConnection.IOHandler.ReadLn;
end;

procedure TaCustomOPCTCPSource.ReadStream(aStream: TStream; AByteCount: Integer = -1;
  const AReadUntilDisconnect: Boolean = False);
begin
  Connection.IOHandler.ReadStream(aStream, AByteCount, AReadUntilDisconnect);
end;

function TaCustomOPCTCPSource.ReadString(aByteCount: Integer): string;
begin
  Result := Connection.IOHandler.ReadString(aByteCount);
end;

procedure TaCustomOPCTCPSource.WriteStream(aStream: TStream; const AAll: boolean;
  const AWriteByteCount: Boolean; const ASize: Integer);
begin
  Connection.IOHandler.Write(aStream, IfThen(AAll, 0, ASize), AWriteByteCount);
end;


procedure TaCustomOPCTCPSource.Reconnect;
var
  TickCount1: Cardinal;
begin
  TickCount1 := TThread.GetTickCount;
  try
    TryConnect;
  except
    try
      TryConnect;
    except
      on e: Exception do
        if not TryAltReconnect then
          raise;
    end;
  end;

  if UpdateMode = umAuto then
    PacketUpdate := ((TThread.GetTickCount - TickCount1) > 1000);

  FPhysIDsChanged := true;
  FDataLinkGroupsChanged := true;

  { TODO : Добавить отработку события OnConnect }
//  if Assigned(OnConnect) then
//    PostMessage(FWindowHandle, am_Connect, 0, 0);
end;

procedure TaCustomOPCTCPSource.SendCommand(aCommand: string);
begin
  ClearIncomingData;
  FConnection.IOHandler.WriteLn(aCommand);
end;

procedure TaCustomOPCTCPSource.SendCommandFmt(aCommand: string; const Args: array of TVarRec);
begin
  SendCommand(Format(aCommand, Args));
end;

procedure TaCustomOPCTCPSource.SetCompressionLevel(const Value: integer);
begin
  FCompressionLevel := Value;
  //Assert(False, 'SetCompressionLevel должна быть реализована у наследников');
  // реализация у наследников
end;

procedure TaCustomOPCTCPSource.SetMainHost(const Value: string);
begin
  FMainHost := Value;
  RemoteMachine := Value;
end;

procedure TaCustomOPCTCPSource.SetMainPort(const Value: integer);
begin
  FMainPort := Value;
  Port := Value;
end;

procedure TaCustomOPCTCPSource.SetPort(const Value: integer);
begin
  FConnection.Port := Value;
  FMainPort := Value;
end;

procedure TaCustomOPCTCPSource.SetReadTimeOut(const Value: integer);
begin
  FConnection.ReadTimeout := Value;
end;

procedure TaCustomOPCTCPSource.SetRemoteMachine(const Value: string);
begin
  if FConnection.Host <> Value then
  begin
    Active := False;
    Connected := false;
    FConnection.Host := Value;
  end;
  FMainHost := Value;
end;

procedure TaCustomOPCTCPSource.SetEncrypt(const Value: boolean);
var
  OldSSL: boolean;
  OldIOHandler: TIdIOHandler;
  OldConnected: boolean;
begin
  OldSSL := Assigned(IOHandler) and (IOHandler is TIdSSLIOHandlerSocketOpenSSL);
  if OldSSL = Value then
    exit;

  OldConnected := Connected;
  Disconnect;

  OldIOHandler := IOHandler;
  FConnection.IOHandler := nil;
  if Assigned(OldIOHandler) then
    OldIOHandler.Free;

  if Value then
  begin
    FConnection.IOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
    FConnection.IOHandler.SetSubComponent(True);
  end;

  if OldConnected then
    DoConnect;
end;

//procedure TaCustomOPCTCPSource.SetLanguage(const Value: TUserLanguage);
//begin
//  FLanguage := Value;
//end;

procedure TaCustomOPCTCPSource.SetConnectTimeOut(const Value: integer);
begin
  Connection.ConnectTimeout := Value;
end;

procedure TaCustomOPCTCPSource.SetWriteBufferThreshold(const Value: Integer);
begin
  FWriteBufferThreshold := Value;
end;

function TaCustomOPCTCPSource.TryAltReconnect: boolean;
var
  p, p1: integer;
  aHost: string;
  aPort: integer;
  s: String;
  FSaveHost: string;
  FSavePort: Integer;
begin
  Result := False;
  s := Trim(AltAddress);
  if s = '' then
    Exit;

  FSaveHost := FConnection.Host;
  FSavePort := FConnection.Port;

  {
    альтернативные подключения задаются строкой вида:
    Host1:Port1;Host2:Port2;Host3:Port3
  }

  if s[Length(s)] <> ';' then
    s := s + ';';
  
  if Pos(RemoteMachine + ':' + IntToStr(Port), s) <= 0 then
    s := s + RemoteMachine + ':' + IntToStr(Port) + ';';
  
  try
    p1 := 1;
    aHost := '';
    //aPort := 0;
    for p := 1 to Length(s) do
    begin
      if s[p] = ':' then
      begin
        aHost := Trim(Copy(s, p1, p - p1));
        p1 := p + 1;
      end
      else if s[p] = ';' then
      begin
        aPort := StrToInt(Trim(Copy(s, p1, p - p1)));
        p1 := p + 1;

        FConnection.Host := aHost;
        FConnection.Port := aPort;
        try
          TryConnect;
//          FConnection.Disconnect;
//          FConnection.Connect({$IFNDEF INDY100}TimeOut{$ENDIF});
//          FConnection.CheckForGracefulDisconnect(true);
//          Authorize(User, Password);
//          LoadFS;

          Result := True;
          Exit;
        except
        end;
      end;
    end;
  except
    on e: Exception do
      OPCLog.WriteToLogFmt('TryAltReconnect(%s): %s', [AltAddress, e.Message]);
  end;

  if not FConnection.Connected then
  begin
    FConnection.Host := FSaveHost;
    FConnection.Port := FSavePort;
  end;

end;

procedure TaCustomOPCTCPSource.TryConnect;
begin
  FConnection.Disconnect;
  FConnection.Connect;
  FConnection.CheckForGracefulDisconnect(true);
  if Assigned(FConnection.IOHandler) then
  begin
    //FConnection.IOHandler.DefStringEncoding := TIdTextEncoding.ANSI;
    FConnection.IOHandler.DefStringEncoding := IndyTextEncoding_OSDefault;
    FConnection.IOHandler.MaxLineLength := 10000 * (16 * 1024);
    //TIdIOHandlerSocket(FConnection.IOHandler).Binding.SetSockOpt(Id_SOL_SOCKET, Id_SO_RCVTIMEO, ReadTimeOut);
  end;

  // авторизацию и обмен параметрами должны реализовать наследники
end;

procedure TaCustomOPCTCPSource.UnLockConnection(aMessage: string);
begin
  //OPCLog.WriteToLogFmt('%d: UnLockConnection %s', [GetCurrentThreadId, aMessage]);
  FConnectionLock.Leave;
  //OPCLog.WriteToLogFmt('%d: UnLockConnection OK. %s', [GetCurrentThreadId, aMessage]);
end;

end.
