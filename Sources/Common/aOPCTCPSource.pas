unit aOPCTCPSource;

interface

uses
  SysUtils, Classes,
  DateUtils, SyncObjs,
  aCustomOPCSource, aOPCSource,
  IdTCPClient, IdGlobal, IdException, IdExceptionCore
  , IdIOHandler, IdIOHandlerSocket, IdSSLOpenSSL
  , aDCIntercept
  , IdCompressionIntercept
  , uDCObjects, uUserMessage, uOPCTCPConnection
  , aCustomOPCTCPSource
  ;

type

  TaOPCTCPSource = class(TaCustomOPCTCPSource)
  private
    // работа с TCP клиентом
    function ReadLnCompress: string;
    function ReadInteger: integer;
    procedure ReadStreamCompress(aStream: TStream; aSize: Int64 = -1);
    procedure WriteStream(AStream: TStream);
    procedure WriteStreamCompress(AStream: TStream);

    function GetPrepValues: string;

    //function GetDS: char;
    procedure LoadFS;
  protected
    procedure SetCompressionLevel(const Value: integer); override;
    procedure TryConnect; override;

    procedure Authorize(aUser: string; aPassword: string); override;
  public

    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;

    function SendModBus(aSystemType: integer; aRequest: string;
      aRetByteCount: integer; aTimeOut: integer): string; override;
    function SendModBusEx(aConnectionName: string; aRequest: string;
      aRetByteCount: integer; aTimeOut: integer): string; override;

    //function GetSensorProperties(id: string): TSensorProperties; override;                       // ?
    function GetSensorPropertiesEx(id: string): string; override;                                // +

    function SetSensorPropertiesEx(id: string; sl: TStrings): string; override;                  // +

    function GetValue(PhysID: string; aAsText: Boolean = False): string; override;

    function GetUsers: string; override;
    function Login(const aUserName, aPassword: string): Boolean; override;
                                                            // +
    function GetUserPermission(const aUser, aPassword, aObject: String): String; override;       // +
    function GetClientList: string; override;                                                    // +
    function GetThreadList: string; override;                                                    // +
    function GetThreadProp(aThreadName: string): string; override;
    function SetThreadState(ConnectionName: string; NewState: boolean): string; override;        // +
    function SetThreadLock(ConnectionName: string; NewState: boolean): string; override;         // +

    function GetSensorsReadError: string; override;

    function ExecSql(Sql: string): string; override;
    function LoadLookup(aName: string; var aTimeStamp: TDateTime): string; override;             // +

    function DelSensorValue(PhysID: string; Moment: TDateTime): string; override;
    function SetSensorValue(PhysID, Value: string; Moment: TDateTime = 0): string; override;     // +

    function GetSensorValue(PhysID: String; var ErrorCode: integer; var ErrorString: String;
      var Moment: TDateTime): string; override;
    function GetSensorsValues(PhysIDs: String): string; override;                               // +

    function GetSensorValueOnMoment(PhysID: String; var Moment: TDateTime): string; override;   // +
    function GetSensorsValueOnMoment(PhysIDs: String; Moment: TDateTime): string; override;     // +

    function GetPermissions(PhysIDs: string): string; override;

    procedure FillSensorsValuesStream(var aValuesStream: TMemoryStream); override;              // +

    procedure FillHistory(Stream: TStream; SensorID: string;                                    // +
      Date1: TDateTime; Date2: TDateTime = 0;
      aDataKindSet: TDataKindSet = [dkValue];
      aCalcLeftVal: Boolean = True; aCalcRightVal: Boolean = True); override;

    procedure FillNameSpaceStrings(aNameSpace: TStrings; aRootID: string = ''; aLevelCount: Integer = 0;
      aKinds: TDCObjectKindSet = []); override;

    function GetNameSpace(aObjectID: string = ''; aLevelCount: Integer = 0): boolean; override; // +
    function CalcVolume(aSensorID: integer; aDate1, aDate2: TDateTime): extended; override;
    function GetTimes(aSensorID: Integer; aDate1, aDate2: TDateTime): string; override;
    function GetStatistic(aSensorID: string; aDate1, aDate2: TDateTime): string; override;

    procedure GetFile(aFileName: string; aStream: TStream); override;                 // +
    procedure UploadFile(aFileName: string; aDestDir: string = ''); override;                                          // +

    procedure ChangePassword(aUser, aOldPassword, aNewPassword: string); override;              // +
    procedure DisconnectUser(aUserGUID: string); override;

    procedure SendUserMessage(aUserGUID: string; aMessage: string); override;                   // +
    function GetMessage: TUserMessage; override;                                                // +
  end;


implementation

uses
  StrUtils, IdTCPConnection,
  aOPCLog, aOPCconsts, aOPCUtils,
  DC.StrUtils;

{ TaOPCTCPSource }

constructor TaOPCTCPSource.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  ProtocolVersion := 1;
  //UpdateMode := umStreamPacket;  
end;

function TaOPCTCPSource.DelSensorValue(PhysID: string; Moment: TDateTime): string;
begin
  Result := '';
  LockConnection;
  try
    try
      DoConnect;
      SendCommandFmt('DeleteValue %s;%s', [PhysID, FloatToStr(Moment, OpcFS)]);
      Result := ReadLn;
    except
      on e: EIdException do
        if ProcessTCPException(e) then
          raise;
    end;
  finally
    UnlockConnection;
  end;
end;

destructor TaOPCTCPSource.Destroy;
begin

  inherited;
end;

procedure TaOPCTCPSource.DisconnectUser(aUserGUID: string);
begin
  { TODO : TaOPCTCPSource.DisconnectUser is not implemented }
end;

function TaOPCTCPSource.ExecSql(Sql: string): string;
var
  I: Integer;
  LineCount: integer;
begin
  Result := '';
  LockConnection;
  try
    try
      DoConnect;
      SendCommand('ExecSql ' + Sql);
      LineCount := ReadInteger;
      for I := 0 to LineCount - 1 do // Iterate
        Result := Result + ReadLn + #13#10;
    except
      on e: EIdException do
        if ProcessTCPException(e) then
          raise;
    end;
  finally
    UnlockConnection;
  end;
end;

//function TaOPCTCPSource.GetDS: char;
//var
//  Str: string;
//begin
//  Result := FormatSettings.DecimalSeparator;
//  LockConnection;
//  try
//    try
//      DoConnect;
//      SendCommand('GetDecimalSeparator');
//      Str := ReadLn;
//      Result := str[1];
//    except
//      on e: EIdException do
//        ProcessTCPException(e);
//    end;
//  finally
//    UnlockConnection;
//  end;
//end;

procedure TaOPCTCPSource.GetFile(aFileName: string; aStream: TStream);
var
  Size: integer;
begin
  LockConnection;
  try
    Assert(Assigned(aStream), 'Не создан поток');
//    if not  then
//      Exception.Create('Не создан поток');
    try
      DoConnect;
      SendCommand('GetFile '+aFileName);
      Size := StrToInt(ExtractParamsFromAnswer(ReadLn, 1));
      ReadStreamCompress(aStream, Size);
    except
      on e: EIdException do
        ProcessTCPException(e);
    end;

  finally
    UnlockConnection;
  end;

end;


function TaOPCTCPSource.GetPermissions(PhysIDs: string): string;
var
  aByteCount: integer;
  aStatus: string;
begin
  Result := '';
  LockConnection;
  try
    try
      DoConnect;
      SendCommand('GetPermissions ' + PhysIDs);

      aStatus := ReadLn;
//      CheckAnswer(aStatus);

      if aStatus = sError then
        raise EOPCTCPCommandException.Create(ReadLn)
      else if aStatus <> sOk then
        raise EOPCTCPUnknownAnswerException.Create('Нестандартый ответ на команду');

      ReadLn;                           // количество строк данных
      aByteCount := StrToInt(ReadLn);   // количество байт данных

      // читаем данные
      Result := ReadString(aByteCount);
    except
      on e: EIdException do
        if ProcessTCPException(e) then
          raise;
    end;
  finally
    UnLockConnection;
  end;
end;

function TaOPCTCPSource.GetPrepValues: string;
var
  aPosition, aCount: integer;
  aSize: integer;
  aUnswer: string;
begin
// функция вызаывается после команды подготовки некоторых данных
// (об ошибках чтения, о списке потоков на сервере и т.д)
// в случае большого количества данных,
// функция выполняет выбокру в несколько этапов
// возвращает данные, которые сервер сформировал

  // читаем ответ на запрос (типа Get...)
  aUnswer := ReadLn;
  // в ответе должен быть результат выполнения команды
  // и размер софрмированных данных
  aSize := StrToInt(ExtractParamsFromAnswer(aUnswer));
  if aSize < Connection.IOHandler.MaxLineLength then
  begin
    // прочитать всю строку
    SendCommand('GetPrepValues');
    Result := ReadLnCompress;
  end
  else
  begin
    Result := '';
    aPosition := 1;
    // прочитать строку частями по TCPClient.MaxLineLength - 1 байт
    aCount := Connection.IOHandler.MaxLineLength - 1;
    while aPosition <= aSize do
    begin
      SendCommand(Format('GetPrepValues %d;%d', [aPosition, aCount]));
      Result := Result + ReadLnCompress;
      aPosition := aPosition + aCount;
      // если это последний кусочек, то у него особый размер
      if (aPosition + aCount) > aSize then
        aCount := aSize - aPosition + 1;
    end;
  end;
end;

{
function TaOPCTCPSource.GetSensorProperties(id: string): TSensorProperties;
var
  Unswer: string;
begin
  LockConnection;
  try
    try
      DoConnect;
      SendCommand('GetSensorProperties ' + id);

      Unswer := ReadLn;
      if LowerCase(Unswer) <> 'ok' then
        raise Exception.CreateFmt('Ошибка при получении свойств датчика %s: %s',
          [id, Unswer]);
      with Result do
      begin
        Name := ReadLn; // наименование датчика
        NameEn := ReadLn; // наименование датчика (латиницей)
        FullName := ReadLn; // полное наименование датчика

        ThreadName := ReadLn; // имя потока сбора данных
        EquipmentPath := ReadLn; // адрес контроллера
        Path := ReadLn; // адрес датчика (тега,сигнала)

        Id := ReadLn; // идентификатор датчика на сервере
        UnitName := ReadLn; // единица измерения
        DisplayFormat := ReadLn; // формат представления показаний

        CorrectM := ReadLn; // коэффициент умножения
        Correct := ReadLn; // константа добавления

        Delta := ReadLn; // мёртвая зона (интервал тишины)
        Precision := ReadLn; // точность (знаков после запятой)
        UpdateInterval := ReadLn; // интервал обновления
        MinReadInterval := ReadLn;
          // минимальный интервал между чтением показаний
        Vn := ReadLn; // номинальная скорость изменения показаний

        RefTableName := ReadLn; // ссылка на справочник расшифровки значений
        RefAutoFill := ReadLn; // режим автоматического заполнения справочника

        UpdateDBInterval := ReadLn; // интервал записи в БД
        FuncName := ReadLn; // наименование функции вычисления значения датчика
      end;
    except
      on e: EIdException do
        if ProcessTCPException(e) then
          raise;
    end;
  finally
    UnlockConnection;
  end;

end;
}

function TaOPCTCPSource.GetSensorPropertiesEx(id: string): string;
var
  Unswer: string;
  sl: TStringList;
begin
  Result := '';
  LockConnection;
  try
    try
      DoConnect;
      SendCommand('GetSensorPropertiesEx ' + id);

      Unswer := ReadLn;
      if LowerCase(Unswer) <> 'ok' then
        raise Exception.CreateFmt('Ошибка при получении свойств датчика %s: %s',
          [id, Unswer]);

      sl := TStringList.Create;
      try
        Connection.IOHandler.ReadStrings(sl);
        Result := sl.Text;
      finally
        sl.Free;
      end;
      
    except
      on e: EIdException do
        if ProcessTCPException(e) then
          raise;
    end;
  finally
    UnlockConnection;
  end;
end;

function TaOPCTCPSource.GetUserPermission(const aUser, aPassword, aObject: String): String;
begin
  LockConnection;
  try
    try
      DoConnect;
      SendCommandFmt('GetPermission %s;%s;%s', [aUser, aPassword, aObject]);
      Result := ExtractParamsFromAnswer(ReadLn);
      Authorize(aUser, aPassword);
      LoadFS; // 23.09.2011
    except
      on e: EIdException do
        if ProcessTCPException(e) then
          raise;
    end;
  finally
    UnlockConnection;
  end;
end;

function TaOPCTCPSource.GetUsers: string;
var
  i, LineCount: integer;
begin
  Result := '';
  LockConnection;
  try

    try
      DoConnect;
      SendCommand('GetUsers');
      LineCount := ReadInteger;
      for I := 0 to LineCount - 1 do
        Result := Result + ReadLn + #13#10;
    except
      on e: EIdException do
        if ProcessTCPException(e) then
          raise;
    end;

  finally
    UnlockConnection;
  end;
end;

function TaOPCTCPSource.GetValue(PhysID: string; aAsText: Boolean = False): string;
var
  p: integer;
  Str: string;
  Delimiter: string;
begin
  Result := '';
  LockConnection;
  try
    try
      DoConnect;
      SendCommand('GetValue ' + PhysID);
      Str := ReadLn;
      //Connection.IOHandler.WriteLn('GetValue ' + PhysID);
      //Str := Connection.IOHandler.ReadLn(LF, TimeOut);
  //    if Connection.IOHandler.ReadLnTimedOut then
  //    begin
  //      Result := 'Превышен интервал ожидания ответа';
  //      Exit;
  //    end;

      Delimiter := LeftStr(Str, 1);
      Str := RightStr(Str, length(Str) - 1);

      p := Pos(Delimiter, str);
      Result := LeftStr(Str, p - 1);
    except
      on e: EIdException do
        ProcessTCPException(e);
    end;
  finally
    UnlockConnection;
  end;
end;

procedure TaOPCTCPSource.LoadFS;
var
  sl: TStringList;
  s: string;
begin
  //csTCPCommand.Acquire;
  sl := TStringList.Create;
  try
    try
      DoConnect;
      SendCommand('GetFS');
      s := ReadLn;
      //Connection.{$IFDEF INDY100}IOHandler.{$ENDIF}WriteLn('GetFS');
      //s := Connection.{$IFDEF INDY100}IOHandler.{$ENDIF}ReadLn(LF, TimeOut);
      sl.CommaText := s;
      SlToFormatSettings(sl);
    except
      on e: EIdException do
        ProcessTCPException(e);
    end;
  finally
    sl.Free;
    //csTCPCommand.Release;
  end;
end;

procedure TaOPCTCPSource.SetCompressionLevel(const Value: integer);
begin
  if CompressionLevel = Value then
    exit;

  inherited SetCompressionLevel(Value);

  if Connected then
  begin
    Authorize(User, Password);
    LoadFS; // 23.09.2011
  end;
end;

function TaOPCTCPSource.SetSensorPropertiesEx(id: string; sl: TStrings): string;
begin
  Result := '';
  LockConnection;
  try
    try
      DoConnect;
      SendCommandFmt('SetSensorPropertiesEx %s', [id]);
      Result := ReadLn;
      CheckAnswer(Result);
//      if AnsiSameText(Result,'ok') then
//      begin
      Connection.IOHandler.Write(sl, true);
      Result := ReadLn;
//      end;
    except
      on e: EIdException do
        if ProcessTCPException(e) then
          raise;
    end;
  finally
    UnlockConnection;
  end;

end;

function TaOPCTCPSource.SetSensorValue(PhysID, Value: string;
  Moment: TDateTime): string;
begin
  Result := '';
  LockConnection;
  try
    try
      DoConnect;
      SendCommandFmt('SetValue %s;%s;%s', [PhysID, Value, FloatToStr(Moment, OpcFS)]);
      Result := ReadLn;
    except
      on e: EIdException do
        if ProcessTCPException(e) then
          raise;
    end;
  finally
    UnlockConnection;
  end;
end;


function TaOPCTCPSource.GetSensorValue(PhysID: String;
  var ErrorCode: integer; var ErrorString: String;
  var Moment: TDateTime): string;
var
  p: integer;
  Str: string;
  Delimiter: string;
begin
  LockConnection;
  try
    try
      DoConnect;
      SendCommand('GetValue ' + PhysID);
      Str := ReadLn;
    except
      on e: EIdException do
        if ProcessTCPException(e) then
          raise;
    end;

    Delimiter := LeftStr(Str, 1);
    Str := RightStr(Str, length(Str) - 1);

    // Value (Result)
    p := Pos(Delimiter, str);
    Result := LeftStr(Str, p - 1);
    Str := RightStr(Str, length(Str) - p);

    // ErrorCode
    if ProtocolVersion > 0 then
    begin
      p := Pos(Delimiter, str);
      ErrorCode := StrToIntDef(LeftStr(Str, p - 1), 0);
      Str := RightStr(Str, length(Str) - p);
    end;

    // ErrorString
    p := Pos(Delimiter, str);
    ErrorString := LeftStr(Str, p - 1);
    Str := RightStr(Str, length(Str) - p);

    if ProtocolVersion = 0 then
    begin
      if ErrorString <> '' then
        ErrorCode := -2
      else
        ErrorCode := 0;
    end;

    // Moment
    Moment := StrToDateTime(Str, OpcFS);
  finally
    UnlockConnection;
  end;
end;

function TaOPCTCPSource.GetClientList: string;
var
  i, LineCount: integer;
  s: String;
begin
  Result := '';
  LockConnection;
  try
    try
      DoConnect;
      if ServerVer > 0 then
        SendCommand('GetClientList1')
      else
        SendCommand('GetClientList');

      LineCount := ReadInteger;
      for I := 0 to LineCount - 1 do
      begin
        s := ReadLn;
        //OPCLog.WriteToLog(s);
        Result := Result + s + #13#10;
      end;
    except
      on e: EIdException do
        if ProcessTCPException(e) then
          raise;
    end;
  finally
    UnlockConnection;
  end;
end;

function TaOPCTCPSource.CalcVolume(aSensorID: integer; aDate1,
  aDate2: TDateTime): extended;
begin
  Result := 0;
  LockConnection;
  try
    try
      DoConnect;
      SendCommandFmt('CalcVolume %d;%s;%s',
        [aSensorID, DateTimeToStr(aDate1, OpcFS), DateTimeToStr(aDate2, OpcFS)]);

      Result := StrToFloat(ReadLn, OpcFS);
    except
      on e: EIdException do
        if ProcessTCPException(e) then
          raise;
    end;
  finally
    UnlockConnection;
  end;
end;

procedure TaOPCTCPSource.ChangePassword(aUser, aOldPassword,
  aNewPassword: string);
var
  Str: string;
begin
  LockConnection;
  try
    try
      DoConnect;
      SendCommandFmt('ChangePassword %s;%s;%s', [aUser, aOldPassword, aNewPassword]);
      Str := ReadLn;
      if not AnsiSameText(Str, sOk) then
        raise Exception.Create('Не удалось изменить пароль.');
    except
      on e: EIdException do
        if ProcessTCPException(e) then
          raise;
    end;
  finally
    UnlockConnection;
  end;
end;

function TaOPCTCPSource.GetSensorValueOnMoment(PhysID: String;
  var Moment: TDateTime): string;
var
  p: integer;
  Str: string;
begin
  LockConnection;
  try
    try
      DoConnect;
      SendCommandFmt('GetValueOnMoment %s;%s', [PhysID, DateTimeToStr(Moment, OpcFS)]);
      Str := ReadLn;
    except
      on e: EIdException do
        if ProcessTCPException(e) then
          raise;
    end;

    Str := ExtractParamsFromAnswer(Str, 2);

    p := Pos(cParamsDelimiter, str);
    Result := LeftStr(Str, p - 1);
    Str := RightStr(Str, length(Str) - p);

    Moment := StrToDateTime(Str, OpcFS);
  finally
    UnlockConnection;
  end;
end;

function TaOPCTCPSource.GetStatistic(aSensorID: string; aDate1, aDate2: TDateTime): string;
begin
  { TODO : TaOPCTCPSource.GetStatistic is not implemented }
  Result := '';
end;

function TaOPCTCPSource.GetThreadList: string;
begin
  LockConnection;
  try
    try
      DoConnect;
      SendCommand('PrepThreadList');
      Result := GetPrepValues;
    except
      on e: EIdException do
        if ProcessTCPException(e) then
          raise;
    end;
  finally
    UnlockConnection;
  end;
end;

function TaOPCTCPSource.GetThreadProp(aThreadName: string): string;
begin
  { TODO : TaOPCTCPSource.GetThreadProp is not implemented }
  Result := '';
end;

function TaOPCTCPSource.GetTimes(aSensorID: Integer; aDate1, aDate2: TDateTime): string;
begin
  { TODO : TaOPCTCPSource.GetTimes is not implemented }
  Result := '';
end;

function TaOPCTCPSource.SetThreadLock(ConnectionName: string; NewState: boolean): string;
begin
  LockConnection;
  try
    try
      DoConnect;
      SendCommandFmt('SetThreadLock %s;%s', [ConnectionName, BoolToStr(NewState)]);
      Result := ReadLn;
    except
      on e: EIdException do
        if ProcessTCPException(e) then
          raise;
    end;
  finally
    UnlockConnection;
  end;
end;

function TaOPCTCPSource.SetThreadState(ConnectionName: string; NewState:
  boolean): string;
begin
  LockConnection;
  try
    try
      DoConnect;
      SendCommandFmt('SetThreadState %s;%s', [ConnectionName, BoolToStr(NewState)]);
      Result := ReadLn;
    except
      on e: EIdException do
        if ProcessTCPException(e) then
          raise;
    end;
  finally
    UnlockConnection;
  end;
end;

procedure TaOPCTCPSource.TryConnect;
begin
  inherited TryConnect;

  Intercept.CompressionLevel := 0;

  Authorize(User, Password);
  LoadFS;
end;

procedure TaOPCTCPSource.UploadFile(aFileName: string; aDestDir: string = '');
var
  //Answer: string;
  //Size: integer;
  Stream: TFileStream;
begin
  LockConnection;
  try

    Stream := TFileStream.Create(aFileName, fmOpenRead or fmShareDenyNone);
    try
      try
        DoConnect;
        SendCommand(Format('UploadFile %s;%d', [aFileName, Stream.Size]));
        ExtractParamsFromAnswer(ReadLn);
        WriteStreamCompress(Stream);
      except
        on e: EIdException do
          ProcessTCPException(e);
      end;
    finally
      Stream.Free;
    end;
  finally
    UnlockConnection;
  end;

end;

procedure TaOPCTCPSource.WriteStream(AStream: TStream);
begin
  Connection.IOHandler.Write(aStream);
end;

procedure TaOPCTCPSource.WriteStreamCompress(AStream: TStream);
begin
  Connection.Intercept := Intercept;
  try
    WriteStream(AStream);
  finally
    Connection.Intercept := nil;
  end;
end;

function TaOPCTCPSource.GetSensorsReadError: string;
var
  aPosition, aCount: integer;
  aSize: integer;
  aUnswer: string;
  //  tc1: cardinal;
begin
  LockConnection;
  try
    try
      DoConnect;
      SendCommand('PrepSensorsReadError');

      aUnswer := ReadLn;
      aSize := StrToInt(ExtractParamsFromAnswer(aUnswer));
      if aSize < Connection.IOHandler.MaxLineLength then
      begin
        // прочитать всю строку показаний
        SendCommand('GetPrepSensorsReadError');
        Result := ReadLnCompress;
      end
      else
      begin
        Result := '';
        aPosition := 1;
        // прочитать строку частями по TCPClient.MaxLineLength - 1 байт
        aCount := Connection.IOHandler.MaxLineLength - 1;
        while aPosition <= aSize do
        begin
          SendCommand(Format('GetPrepSensorsReadError %d;%d', [aPosition,
            aCount]));
          Result := Result + ReadLnCompress;
          aPosition := aPosition + aCount;
          // если это последний кусочек, то у него особый размер
          if (aPosition + aCount) > aSize then
            aCount := aSize - aPosition + 1;
        end;
      end;
    except
      on e: EIdException do
        if ProcessTCPException(e) then
          raise;
    end;
  finally
    UnlockConnection;
  end;
end;

function TaOPCTCPSource.GetSensorsValueOnMoment(PhysIDs: String; Moment: TDateTime): string;
var
  p: integer;
  Str: string;
begin
  LockConnection;
  try
    try
      DoConnect;
      SendCommandFmt('GetValuesOnMoment %s;%s', [DateTimeToStr(DateToServer(Moment), OpcFS), PhysIDs]);
      Result := ExtractParamsFromAnswer(ReadLn);
    except
      on e: EIdException do
        if ProcessTCPException(e) then
          raise;
    end;
  finally
    UnLockConnection;
  end;
end;

function TaOPCTCPSource.GetSensorsValues(PhysIDs: String): string;
var
  aPosition, aCount: integer;
  aSize: integer;
  aUnswer: string;
  //  tc1: cardinal;
begin
  LockConnection;
  try
    try
      DoConnect;
      //     tc1 := GetTickCount;
      SendCommand('PrepValues ' + PhysIDs);

      aUnswer := ReadLn;
      aSize := StrToInt(ExtractParamsFromAnswer(aUnswer));
      if aSize < Connection.IOHandler.MaxLineLength then
      begin
        // прочитать всю строку показаний
        SendCommand('GetPrepValues');
        Result := ReadLnCompress;
      end
      else
      begin
        Result := '';
        aPosition := 1;
        // прочитать строку частями по TCPClient.MaxLineLength - 1 байт
        aCount := Connection.IOHandler.MaxLineLength - 1;
        while aPosition <= aSize do
        begin
          SendCommand(Format('GetPrepValues %d;%d', [aPosition, aCount]));
          Result := Result + ReadLnCompress;
          aPosition := aPosition + aCount;
          // если это последний кусочек, то у него особый размер
          if (aPosition + aCount) > aSize then
            aCount := aSize - aPosition + 1;
        end;
      end;
      //     OPCLog.WriteToLogFmt('TaOPCTCPSource.GetSensorsValues : ReadLnCompress = %d(%d)',
      //        [GetTickCount - tc1, aSize]);

    except
      on e: EIdException do
        if ProcessTCPException(e) then
          raise;
    end;
  finally
    UnlockConnection;
  end;
end;

procedure TaOPCTCPSource.FillHistory(Stream: TStream; SensorID: string; Date1,
  Date2: TDateTime; aDataKindSet: TDataKindSet;
  aCalcLeftVal: Boolean; aCalcRightVal: Boolean);
var
  aStreamSizeParam: string;
  //tc1: cardinal;
begin
  if SensorID = '' then
    exit;

  LockConnection;
  try
    try
      if not Assigned(Stream) then
        Exception.Create('Не создан поток');

      DoConnect;
      //tc1 := GetTickCount;

      SendCommand('PrepHistory ' +
        SensorID + ';' +
        DateTimeToStr(Date1, OpcFS) + ';' +
        DateTimeToStr(Date2, OpcFS) + ';' +
        BoolToStr(dkState in aDataKindSet) + ';' +
        BoolToStr(dkValue in aDataKindSet) + ';' +
        BoolToStr(dkUser in aDataKindSet) + ';' +
        BoolToStr(aCalcLeftVal) + ';' +
        BoolToStr(aCalcRightVal)
        );

      aStreamSizeParam := ExtractParamsFromAnswer(ReadLn, 1);

      SendCommand('GetPrepHistory ' + aStreamSizeParam);
      ReadStreamCompress(Stream, StrToInt(aStreamSizeParam));

      //OPCLog.WriteToLogFmt('TaOPCTCPSource.GetSensorJurnal :  %d мс (%d Byte)',
      //  [GetTickCount - tc1, Stream.Size]);

      Stream.Position := 0;
    except
      on e: EIdException do
        if ProcessTCPException(e) then
          raise;
    end;
  finally
    UnlockConnection;
  end;
end;

procedure TaOPCTCPSource.FillNameSpaceStrings(aNameSpace: TStrings; aRootID: string; aLevelCount: Integer;
  aKinds: TDCObjectKindSet);
var
  Stream: TMemoryStream;
  //dt: TDateTime;
  Res: string;
  //dtStr: string;
begin
  Assert(Assigned(aNameSpace));
  aNameSpace.Clear;

  LockConnection;
  try
    try
      DoConnect;
      SendCommandFmt('GetNameSpace ObjectID=%s;TimeStamp=%s;LevelCount=%d', [aRootID, '0', aLevelCount]);
      Connection.Intercept := Intercept;
      try
        //dt := StrToDateTimeDef(ReadLn, 0, OpcFS);
        ReadLn; // читаем дату
        Res := ReadLn;
        if Res <> 'Stream' then
          Exit;

        Stream := TMemoryStream.Create;
        try
          ReadStream(Stream);
          Stream.Position := 0;
          aNameSpace.LoadFromStream(Stream);
        finally
          FreeAndNil(Stream);
        end;
      finally
        Connection.Intercept := nil;
      end;
    except
      on e: EIdException do
        if ProcessTCPException(e) then
          raise;
    end;
  finally
    UnlockConnection;
  end;
end;

procedure TaOPCTCPSource.FillSensorsValuesStream(var aValuesStream:
  TMemoryStream);
var
  i: integer;
  Stream: TMemoryStream;
  PhysID: integer;
  aByteCount: integer;
  //  tc1: cardinal;
begin
  LockConnection;
  try
    try
      DoConnect;
      //     tc1 := GetTickCount;
      if FDataLinkGroupsChanged then
      begin
        Stream := TMemoryStream.Create;
        try
          for i := 0 to DataLinkGroups.Count - 1 do
          begin
            PhysID := StrToIntDef(TOPCDataLinkGroup(DataLinkGroups.Items[i]).PhysID, 0);
            Stream.Write(PhysID, SizeOf(PhysID));
          end;
          Stream.Position := 0;

          SendCommandFmt('PrepStreamValues %d', [DataLinkGroups.Count]);
          WriteStream(Stream);
          //WriteStreamCompress(Stream);

          // отметим, что мы передали серверу новые адреса запрашиваемых датчиков
          FDataLinkGroupsChanged := false;
        finally
          Stream.Free;
        end;
      end
      else
        SendCommand('PrepStreamValues');

      aByteCount := StrToInt(ExtractParamsFromAnswer(ReadLn));
      SendCommand('GetPrepStreamValues');

      aValuesStream.Clear;
      ReadStreamCompress(aValuesStream, aByteCount);
      aValuesStream.Position := 0;

      //     OPCLog.WriteToLogFmt('TaOPCTCPSource.FillSensorsValuesStream : ReadStream = %d(%d)',
      //        [GetTickCount - tc1,aValuesStream.Size]);

            // что-то пошло не так (сервер перегрузился...)
            // установим признак необходимости передать серверу новые адреса
      if DataLinkGroups.Count * SizeOf(TDCSensorDataRec) <> aValuesStream.Size then
        FDataLinkGroupsChanged := true;

    except
      on e: EIdException do
        if ProcessTCPException(e) then
          raise;
    end;
  finally
    UnlockConnection;
  end;
end;

function TaOPCTCPSource.GetNameSpace(aObjectID: string; aLevelCount: Integer): boolean;
var
  Stream: TMemoryStream;
  dt: TDateTime;
  Res: string;
  dtStr: string;
begin
  Result := false;
  LockConnection;
  try
    try
      DoConnect;

      if (aObjectID <> FNameSpaceParentID) or
        not (FileExists(GetNameSpaceFileName)) then
        FNameSpaceTimeStamp := 0;

      dtStr := FloatToStr(FNameSpaceTimeStamp, OpcFS);
      SendCommandFmt('GetNameSpace ObjectID=%s;TimeStamp=%s;LevelCount=%d', [aObjectID, dtStr, aLevelCount]);

      Connection.Intercept := Intercept;
      try
        dt := StrToDateTimeDef(ReadLn, 0, OpcFS);
        if (SecondsBetween(dt, FNameSpaceTimeStamp) <= 1) then
          exit;

        Res := ReadLn;
        if Res <> 'Stream' then
          Exit;

        Stream := TMemoryStream.Create;
        try
          ReadStream(Stream);

          Stream.Position := 0;
          FNameSpaceCash.LoadFromStream(Stream);
          FNameSpaceTimeStamp := dt;
          FNameSpaceParentID := aObjectID;
          Result := true;
        finally
          FreeAndNil(Stream);
        end;
      finally
        Connection.Intercept := nil;
      end;
    except
      on e: EIdException do
        if ProcessTCPException(e) then
          raise;
    end;
  finally
    UnlockConnection;
  end;
end;

function TaOPCTCPSource.LoadLookup(aName: string;
  var aTimeStamp: TDateTime): string;
var
  i: Integer;
  LineCount: integer;
  dtStr: string;
  dt: TDateTime;
  answer: string;
begin
  Result := '';
  LockConnection;
  try
    try
      DoConnect;
      SendCommandFmt('GetLookupTimeStamp %s', [aName]);

      dtStr := ReadLn;
      dt := StrToDateTimeDef(dtStr, 0, OpcFS);
      if Abs(dt - aTimeStamp) > 1 / 24 / 60 / 60 then // > 1 секунды
      begin
        aTimeStamp := dt;
        SendCommandFmt('GetLookup %s', [aName]);

        Connection.Intercept := Intercept;
        try
          answer := ReadLn;
          if answer <> aName then
            raise Exception.Create(answer);

          LineCount := ReadInteger;
          for I := 0 to LineCount - 1 do
            Result := Result + ReadLn + #13#10;
        finally
          Connection.Intercept := nil;
        end;
      end;
    except
      on e: EIdException do
        if ProcessTCPException(e) then
          raise;
    end;
  finally
    UnlockConnection;
  end;
end;

function TaOPCTCPSource.Login(const aUserName, aPassword: string): Boolean;
begin
  Result := GetUserPermission(aUserName, aPassword, '') <> '';
end;

function TaOPCTCPSource.ReadInteger: integer;
begin
  Result := Connection.IOHandler.ReadInt32;
end;

function TaOPCTCPSource.ReadLnCompress: string;
begin
  Connection.Intercept := Intercept;
  try
    Result := ReadLn;
  finally
    Connection.Intercept := nil;
  end;
end;

procedure TaOPCTCPSource.ReadStreamCompress(aStream: TStream; aSize: Int64 = -1);
begin
  Connection.Intercept := Intercept;
  try
    Connection.IOHandler.ReadStream(aStream, aSize);
  finally
    Connection.Intercept := nil;
  end;
end;

function TaOPCTCPSource.GetMessage: TUserMessage;
var
  aMessageStr: string;
  aMessageLength: integer;
begin
  Result := nil;

  // сервера 0 версии не поддерживают обмен сообщениями
  if ServerVer = 0 then
    Exit;
  
  LockConnection;
  try
    try
      DoConnect;
      SendCommand('GetMessage');
      aMessageLength := StrToInt(ExtractParamsFromAnswer(ReadLn, 1));
      if aMessageLength = 0 then
        Exit;

      aMessageStr := Connection.IOHandler.ReadString(aMessageLength);
      Result := TUserMessage.Create(aMessageStr);
    except
      on e: EIdException do
        if ProcessTCPException(e) then
          raise;
    end;
  finally
    UnLockConnection;
  end;
end;


procedure TaOPCTCPSource.Authorize(aUser: string; aPassword: string);
begin
  SendCommandFmt(
    'AuthorizeUser User=%s;Password=%s;Description=%s;%d;%s;%s;%d;%d;%d',
    [aUser, aPassword, Description, 1, //ProtocolVersion,
      GetLocalUserName, GetComputerName,
      CompressionLevel, Connection.IOHandler.MaxLineLength, Ord(EnableMessage)]);

  Intercept.CompressionLevel := CompressionLevel;

  if OPCLog.AutoFillOnAuthorize then
  begin
    OPCLog.LoginName := GetLocalUserName;
    OPCLog.UserName := aUser;
    OPCLog.ComputerName := GetComputerName;
    OPCLog.IPAdress := Connection.Socket.Binding.IP;
  end;
end;

function TaOPCTCPSource.SendModBus(aSystemType: integer; aRequest: string;
  aRetByteCount, aTimeOut: integer): string;
begin
  Result := '';
  LockConnection;
  try
    try
      DoConnect;
      SendCommandFmt('SendModBus %d;%s;%d;%d', [aSystemType, aRequest, aRetByteCount, aTimeOut]);
      Result := ReadLn;
    except
      on e: EIdException do
        if ProcessTCPException(e) then
          raise;
    end;
  finally
    UnlockConnection;
  end;
end;

function TaOPCTCPSource.SendModBusEx(aConnectionName, aRequest: string;
  aRetByteCount, aTimeOut: integer): string;
begin
  Result := '';
  LockConnection;
  try
    try
      DoConnect;
      SendCommandFmt('SendModBus %s;%s;%d;%d', [aConnectionName, aRequest, aRetByteCount, aTimeOut]);
      Result := ReadLn;
    except
      on e: EIdException do
        if ProcessTCPException(e) then
          raise;
    end;
  finally
    UnlockConnection;
  end;
end;

procedure TaOPCTCPSource.SendUserMessage(aUserGUID, aMessage: string);
begin
  // сервера 0 версии не поддерживают обмен сообщениями
  if ServerVer = 0 then
    Exit;

  LockConnection;
  try
    try
      DoConnect;
      SendCommandFmt('SendMessage %s;%s', [aUserGUID, ConvertBinToStr(aMessage)]);
      CheckAnswer(ReadLn);
    except
      on e: EIdException do
        ProcessTCPException(e);
    end;
  finally
    UnLockConnection;
  end;
end;


end.

