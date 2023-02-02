unit uCustomProjectData;

interface

uses
  System.Classes, System.SysUtils, System.IniFiles,
  aOPCConnectionList, aOPCVerUpdater,
  uServerProjectInfo;

type
  EConnectionError = class(Exception)

  end;

  TOnConnectionErrorEvent = procedure (Sender: TObject; aMesage: string; var aContinue: Boolean) of object;

  TCustomProjectData = class
  private
    FServerProjects: TStrings;
    FName: string;
    FProgName: string;
    FConnections: TaOPCConnectionList;
    FIsChanged: boolean;
    FProjectVars: TStrings;
    FProjectVersionNo: Integer;
    FCheckPermission: Boolean;
    FProjectPath: string;
    FLastProject: string;
    FLastPassword: string;
    FAppPath: string;
    FVerUpdater: TaOPCVerUpdater;
    FOnConnectionError: TOnConnectionErrorEvent;
    procedure SetIsChanged(const Value: boolean);
    function GetProductVersion: string;
    procedure SetCheckPermission(const Value: Boolean);
    procedure SetProjectVersionNo(const Value: Integer);
    procedure SetProjectPath(const Value: string);
    procedure SetLastPassword(const Value: string);
    procedure SetLastProject(const Value: string);
    procedure SetAppPath(const Value: string);
  protected
    function GetInstallFileName: string; virtual;

    procedure DoSave(aIniFile: TCustomIniFile); virtual;
    procedure DoLoadFromIni(aIniFile: TCustomIniFile); virtual;
  public
    constructor Create(aProgName: string; aExeName: string); virtual;
    destructor Destroy; override;

    function SetVariables(aValue: string): string;
    function GetVariables(aValue: string): string;
    function AbsFileName(aFileName: string): string;
    function RelativeFileName(aFileName: string): string;

    // для отображения хода загрузки и выгрузки эти функции нужно перекрыть в наследнике
    procedure ShowStatus(aMsg: string); virtual;
    procedure ShowStatusPercent(aPercent: Integer); virtual;
    procedure HideStatus; virtual;

    procedure ShowInitStatusFmt(StatusStr:string; const Args:array of TVarRec);

    procedure LoadFromIni(aIniFile: TCustomIniFile);

    procedure Clear;
    procedure Save(aFileName: TFileName);
    procedure Load(aFileName: TFileName);


    function LoadServerProject(aProjectName: string): string;
    procedure UploadToServer(aFileName: string);

    function Init(var aUserName: string; aLoadServerProject: Boolean): boolean;

    property IsChanged: boolean read FIsChanged write SetIsChanged;

    property Name: string read FName;
    property ProgName: string read FProgName;

    property ProductVersion: string read GetProductVersion;
    property ProjectVersionNo: Integer read FProjectVersionNo write SetProjectVersionNo;
    property CheckPermission: Boolean read FCheckPermission write SetCheckPermission;

    // ** список подключений **
    property Connections: TaOPCConnectionList read FConnections;
    property VerUpdater: TaOPCVerUpdater read FVerUpdater;

    property ServerProjects: TStrings read FServerProjects;

    property AppPath: string read FAppPath write SetAppPath;
    property ProjectPath: string read FProjectPath write SetProjectPath;
    property LastProject: string read FLastProject write SetLastProject;
    property LastPassword: string read FLastPassword write SetLastPassword;

    // для возможности игнорировать ошибку подключения нужно обработать это событие
    // иначе будет вызвано исключения и процес загрузки будет прерван
    property OnConnectionError: TOnConnectionErrorEvent read FOnConnectionError write FOnConnectionError;
  end;

implementation

uses
  Winapi.Windows,
  System.StrUtils,
  IdException, JvVersionInfo,
  uMemIniFileEx,
  aOPCLog,
  aCustomOPCTCPSource, aOPCAuthorization, uAppStorage,
  DC.VCL.PasswordForm;

{ TCustomProjectData }

function TCustomProjectData.AbsFileName(aFileName: string): string;
begin
  Result := SetVariables(aFileName);

  if (Length(Result) > 1)
      and (copy(Result, 1, 2) <> '\\')
      and (pos(':',Result) = 0) then
  begin
    if ProjectPath = '' then
      Result := AppPath + Result
    else
      Result := ProjectPath + Result;
  end;
end;

procedure TCustomProjectData.Clear;
var
  i: Integer;
begin
  FProjectVars.Clear;
  Connections.Active := False;
  VerUpdater.Active := False;
  VerUpdater.OPCSource := nil;

  for i := FServerProjects.Count - 1 downto 0 do
    FServerProjects.Objects[i].Free;
  FServerProjects.Clear;

  FConnections.Items.Clear;
end;

constructor TCustomProjectData.Create(aProgName: string; aExeName: string);
begin
  FProgName := aProgName;
  AppPath := ExtractFilePath(aExeName);

  FConnections := TaOPCConnectionList.Create(nil);
  FServerProjects := TStringList.Create;

  FVerUpdater := TaOPCVerUpdater.Create(nil);
  FVerUpdater.InstallFileName := GetInstallFileName; // 'Hole\Hole_Setup.exe';

  FProjectVars := TStringList.Create;
end;

destructor TCustomProjectData.Destroy;
begin
  FProjectVars.Free;

  FServerProjects.Free;
  FVerUpdater.Free;

  FConnections.Free;

  inherited;
end;

procedure TCustomProjectData.DoLoadFromIni(aIniFile: TCustomIniFile);
begin
  // реализовать в наследнике
end;

procedure TCustomProjectData.DoSave(aIniFile: TCustomIniFile);
begin
  // реализовать в наследнике
end;

function TCustomProjectData.GetInstallFileName: string;
begin

end;

function TCustomProjectData.GetProductVersion: string;
var
  vi: TjvVersionInfo;
begin
  vi := TjvVersionInfo.Create(AppFileName);
  try
    Result := vi.ProductVersion;
  finally
    vi.Free;
  end;
end;

function TCustomProjectData.GetVariables(aValue: string): string;
var
  i: integer;
begin
  Result := aValue;
  for i := 0 to FProjectVars.Count - 1 do
    Result := ReplaceText(Result, FProjectVars.ValueFromIndex[i], FProjectVars.Names[i]);

  Result := ReplaceText(Result, ProjectPath, '%ProjectPath%');
  Result := ReplaceText(Result, AppPath, '%AppPath%');
end;

procedure TCustomProjectData.HideStatus;
begin

end;

function TCustomProjectData.Init(var aUserName: string; aLoadServerProject: Boolean): boolean;
var
  i: Integer;
  aServerProjectFileName: string;
  aOPCConnection: TOPCConnectionCollectionItem;
  aOPCSource: TaCustomOPCTCPSource;
  aOPCAuthorization: TaOPCAuthorization;
  aContinueOnError: Boolean;
  aConnectionErrorMessage: string;
begin
  Result := true;

  aOPCAuthorization := TaOPCAuthorization.Create(nil);
  try
    aOPCAuthorization.User := aUserName;
    aOPCAuthorization.Password := LastPassword;

    Connections.Description := ProgName + ' (' + ProductVersion + ') : ' +
      Name + ' (' + IntToStr(ProjectVersionNo) + ')';

    for i := 0 to Connections.Items.Count - 1 do
    begin
      aOPCConnection := Connections.Items[i];
      aOPCSource := aOPCConnection.OPCSource;
      if aOPCSource.Active then
        Continue;

      ShowInitStatusFmt('подключение (%s:%d)...',
      //ShowInitStatusFmt('connection (%s:%d)...',
        [aOPCSource.RemoteMachine, aOPCSource.Port]);
      try
        aOPCSource.Connected := true;
      except
        on e: EIdException do
        begin

          if Assigned(OnConnectionError) then
          begin
            aConnectionErrorMessage :=
              Format(
//                'When you connect to %s:%d error occurred %s. '#13 +
//                'Continue to work without this connection?',
              'При подключении к %s:%d произошла ошибка %s. '#13 +
              'Продолжить работу без этого подключения?',
                [aOPCSource.RemoteMachine, aOPCSource.Port, e.Message]);

            aContinueOnError := False;
            OnConnectionError(Self, aConnectionErrorMessage, aContinueOnError);
            if aContinueOnError then
              Continue
            else
              Abort;
          end
          else
          begin
            aConnectionErrorMessage :=
              Format(
                'When you connect to %s:%d error occurred %s. ' + #13 +
                'The program will be terminated!',
//                'При подключении к %s:%d произошла ошибка %s. '#13 +
//                'Работа программы будет прервана!',
              [aOPCSource.RemoteMachine, aOPCSource.Port, e.Message]);

            raise EConnectionError.Create(aConnectionErrorMessage);
          end;


//          if Application.MessageBox(
//            PChar(Format('При подключении к %s:%d произошла ошибка %s. '#13
//              +
//            'Продолжить работу без этого подключения?',
//            [aOPCSource.RemoteMachine, aOPCSource.Port, e.Message])),
//            'Ошибка при подключении', MB_YESNO + MB_ICONSTOP) = IDNO then
//            Abort
//          else
//            Continue;

        end;
        on e: Exception do
        begin
{$IFDEF UseExceptionLog}
          ExceptionLog.StandardEurekaNotify(e, ExceptAddr);
{$ENDIF}

          Abort;
        end;
      end;

//      ShowInitStatusFmt('authorization (%s:%d)...',
      ShowInitStatusFmt('авторизация (%s:%d)...',
        [aOPCSource.RemoteMachine, aOPCSource.Port]);

      aOPCAuthorization.OPCSource := aOPCSource;
      aOPCAuthorization.ReadCommandLineExt;
      if not aOPCAuthorization.CheckPermissions then
      begin
        if not TPasswordForm.Execute(aOPCAuthorization) then
//        if not aOPCAuthorization.Execute(nil, True) then
        begin
          Result := false;
          exit;
        end
        else
          Result := true;
      end;
      aOPCSource.User := aOPCAuthorization.User;
      aOPCSource.Password := aOPCAuthorization.Password;
      LastPassword := aOPCAuthorization.Password;
    end;
    aUserName := aOPCAuthorization.User;

    // Удаляем плохие подключения
    for i := Connections.Items.Count - 1 downto 0 do
      if not Connections.Items[i].OPCSource.Connected then
        Connections.Items[i].Free;

    if aLoadServerProject and (ServerProjects.Count = 1) then
    begin
      try
        aServerProjectFileName := LoadServerProject(ServerProjects[0]);
        Connections.Description := ProgName + ' (' + ProductVersion + ') : ' +
          Name + ' : ' + aServerProjectFileName + ' (' + IntToStr(ProjectVersionNo) + ')';
      except
        on e: Exception do
          OPCLog.WriteToLog('LoadServerProject: ' + e.Message);
      end;
    end;

    if Connections.Items.Count > 0 then
      VerUpdater.OPCSource := Connections.Items[0].OPCSource;

    for i := 0 to Connections.Items.Count - 1 do
    begin
      aOPCConnection := Connections.Items[i];
      aOPCSource := aOPCConnection.OPCSource;

      aOPCSource.User := aOPCAuthorization.User;
      aOPCSource.Password := aOPCAuthorization.Password;

      aOPCSource.Connected := True;

      // проверим наличие справочника состояний
      aOPCSource.States := aOPCConnection.GetStatesLookup;

      // загружаем справочную информацию
      ShowInitStatusFmt('загрузка справочников (%s)...', [aOPCConnection.Name]);
      //ShowInitStatusFmt('loading references (%s)...', [aOPCConnection.Name]);
      //aOPCConnection.LoadLookups(AppStorage, TKeys.References(aOPCConnection.Name));
      aOPCConnection.LoadLookups(AppStorage, '');
    end;

    Connections.Active := true;
  finally
    aOPCAuthorization.Free;
    HideStatus;
  end;
end;

procedure TCustomProjectData.Load(aFileName: TFileName);
var
  IniFile: TCustomIniFile;
begin
  //Clear;
  //ShowInitStatusFmt('loading project (%s)...', [aFileName]);
  ShowInitStatusFmt('загрузка проекта (%s)...', [aFileName]);
  try
    ProjectPath := ExtractFilePath(aFileName);
    IncludeTrailingPathDelimiter(ProjectPath);

    IniFile := TMemIniFileEx.Create(aFileName);
    try
      LoadFromIni(IniFile);
    finally
      IniFile.Free;
    end;

    FName := aFileName;
    FLastProject := aFileName;
    //IsChanged := false;
    //ShowInitStatusFmt('project (%s) was loaded', [aFileName]);
    ShowInitStatusFmt('загрузка проекта (%s) выполнена', [aFileName]);
  finally
    HideStatus;
  end;
end;

procedure TCustomProjectData.LoadFromIni(aIniFile: TCustomIniFile);
var
  i: integer;

  Section: string;

  //ConnectionNo: integer;
  //ConnectionName: string;

  aServerProject: TServerProject;
begin
  Clear;

  aIniFile.ReadSectionValues('Variables', FProjectVars);
  CheckPermission := aIniFile.ReadBool('App', 'CheckPermission', False);
  ProjectVersionNo := aIniFile.ReadInteger('App', 'ProjectVersionNo', 0);

  ShowStatus('чтение подключений');
  //ShowStatus('reading connections');
  Connections.LoadSettings(aIniFile, 'Connections');

  ShowStatus('чтение расписаний');
  //ShowStatus('reading shcedulers');

  ShowStatus('чтение объектов');
  //ShowStatus('reading objects');

  //UpdateVerID
  VerUpdater.VerID := aIniFile.ReadString('Update', 'VerID', '');

  // загрузка списка проектов на сервере
  aIniFile.ReadSection('ServerProjects', FServerProjects);
  for i := 0 to FServerProjects.Count - 1 do
  begin
    Section := 'ServerProjects\' + FServerProjects[i];
    aServerProject := TServerProject.Create;
    FServerProjects.Objects[i] := aServerProject;

    aServerProject.Name := FServerProjects[i];
    aServerProject.ConnectionName := aIniFile.ReadString(Section, 'ConnectionName', '');
    aServerProject.ProjectPathID := aIniFile.ReadString(Section, 'ProjectPathID', '');
  end;

  DoLoadFromIni(aIniFile);

  IsChanged := false;
end;

function TCustomProjectData.LoadServerProject(aProjectName: string): string;
var
  aIndex: Integer;
  aServerProject: TServerProject;
  aConnection: TOPCConnectionCollectionItem;

  aID, aProjectFileName: string;

  aErrorCode: Integer;
  aErrorString: string;
  aMonent: TDateTime;

  s: TStrings;
  d: TDateTime;
  aStream: TStream;

  IniFile: TCustomIniFile;

begin
  Result := '';
  aIndex := ServerProjects.IndexOf(aProjectName);
  if aIndex < 0 then
    raise Exception.CreateFmt('Проект %s не найден', [aProjectName]);

  aServerProject := TServerProject(ServerProjects.Objects[aIndex]);

  aIndex := Connections.IndexOfConnectionName(aServerProject.ConnectionName);
  if aIndex < 0 then
    raise Exception.CreateFmt('Подключение %s не найдено', [aServerProject.ConnectionName]);

  aConnection := Connections.Items[aIndex];

  aID := aConnection.OPCSource.GetSensorValue(aServerProject.ProjectPathID, aErrorCode, aErrorString, aMonent);
  if aID = '' then
    raise Exception.CreateFmt('Путь к проекту на сервере не задан (id=%s)', [aServerProject.ProjectPathID]);


  s := TStringList.Create;
  try
    d := 0;
    s.Text := aConnection.OPCSource.LoadLookup('refProjects', d);
    aProjectFileName := s.Values[aID];
    Result := aProjectFileName;
  finally
    s.Free;
  end;

  aStream := TMemoryStream.Create;
  try
    aConnection.OPCSource.GetFile(aProjectFileName, aStream);
    aStream.Position := 0;

    ShowInitStatusFmt('загрузка проекта (%s)...', [aProjectName]);
    try
      IniFile := TMemIniFileEx.CreateFromStream(aStream);
      try
        LoadFromIni(IniFile);
      finally
        IniFile.Free;
      end;
      ShowInitStatusFmt('загрузка проекта (%s) выполнена', [aProjectName]);
    finally
      HideStatus;
    end;

  finally
    aStream.Free;
  end;

end;

function TCustomProjectData.RelativeFileName(aFileName: string): string;
begin
  Result := GetVariables(aFileName);
end;

procedure TCustomProjectData.Save(aFileName: TFileName);
var
  i: integer;
  //ConnectionNo: integer;
  Section: string;
  aServerProject: TServerProject;
  IniFile: TMemIniFileEx;
  tmpFileName: string;
  ext: string;
begin
  ShowInitStatusFmt('сохранение проекта (%s)...', [aFileName]);
  try

    ProjectVersionNo := ProjectVersionNo + 1;

    FName := aFileName;

    ProjectPath := ExtractFilePath(aFileName);
    IncludeTrailingPathDelimiter(ProjectPath);

    if FileExists(aFileName) then
    begin
      ext := ExtractFileExt(aFileName);
      ext := '.~' + Copy(ext, 2, Length(ext));

      tmpFileName := ChangeFileExt(aFileName, ext);
      if FileExists(tmpFileName) then
        System.SysUtils.DeleteFile(tmpFileName);

      RenameFile(aFileName, tmpFileName);
    end;

    IniFile := TMemIniFileEx.Create(aFileName);
    try
      IniFile.WriteString(ProgName, 'Name', ProgName);
      IniFile.WriteString(ProgName, 'Version', ProductVersion);

      IniFile.WriteInteger(ProgName, 'ProjectVersionNo', ProjectVersionNo);

      IniFile.WriteBool(ProgName, 'CheckPermission', CheckPermission);

      for i := 0 to FProjectVars.Count - 1 do
        IniFile.WriteString('Variables', FProjectVars.Names[i], FProjectVars.ValueFromIndex[i]);

      ShowStatus('запись подключений');
      Connections.SaveSettings(IniFile, 'Connections');

      ShowStatus('запись списка проектов на сервере');
      for i := 0 to FServerProjects.Count - 1 do
      begin
        aServerProject := TServerProject(FServerProjects.Objects[i]);
        IniFile.WriteString('ServerProjects', aServerProject.Name, '');

        Section := 'ServerProjects\' + aServerProject.Name;
        IniFile.WriteString(Section, 'ConnectionName', aServerProject.ConnectionName);
        IniFile.WriteString(Section, 'ProjectPathID', aServerProject.ProjectPathID);
      end;

      IniFile.WriteString('Update', 'VerID', VerUpdater.VerID);// UpdateVerID);

      DoSave(IniFile);

      ShowStatus('сохранение проекта на диск');
      IniFile.UpdateFile;
    finally
      IniFile.Free;
    end;

    IsChanged := false;

    ShowInitStatusFmt('выгрузка проекта на сервер', [aFileName]);
    UploadToServer(aFileName);

    ShowInitStatusFmt('проект (%s) сохранен', [aFileName]);

  finally
    HideStatus;
  end;
end;

procedure TCustomProjectData.SetAppPath(const Value: string);
begin
  FAppPath := Value;
end;

procedure TCustomProjectData.SetCheckPermission(const Value: Boolean);
begin
  FCheckPermission := Value;
end;

procedure TCustomProjectData.SetIsChanged(const Value: boolean);
begin
  FIsChanged := Value;
end;

procedure TCustomProjectData.SetLastPassword(const Value: string);
begin
  FLastPassword := Value;
end;

procedure TCustomProjectData.SetLastProject(const Value: string);
begin
  FLastProject := Value;
end;

procedure TCustomProjectData.SetProjectPath(const Value: string);
begin
  FProjectPath := Value;
end;

procedure TCustomProjectData.SetProjectVersionNo(const Value: Integer);
begin
  FProjectVersionNo := Value;
end;

function TCustomProjectData.SetVariables(aValue: string): string;
var
  i: integer;
begin
  Result := aValue;
  for i := 0 to FProjectVars.Count - 1 do
    Result := ReplaceText(Result, FProjectVars.Names[i], FProjectVars.ValueFromIndex[i]);

  Result := ReplaceText(Result, '%AppPath%', AppPath);
  Result := ReplaceText(Result, '%ProjectPath%', ProjectPath);
end;

procedure TCustomProjectData.ShowStatus(aMsg: string);
begin

  //CommonData.ShowStatus(aMsg);
end;

procedure TCustomProjectData.ShowStatusPercent(aPercent: Integer);
begin

end;

procedure TCustomProjectData.ShowInitStatusFmt(StatusStr: string; const Args: array of TVarRec);
begin
  ShowStatus(Format(StatusStr, Args));
end;

procedure TCustomProjectData.UploadToServer(aFileName: string);
begin
  if Connections.Items.Count = 0 then
    Exit;

  try
    Connections.Items[0].OPCSource.UploadFile(aFileName);
  except
    on e: Exception do
      OPCLog.WriteToLogFmt('Ошибка при выгрузке проекта на сервер: %s', [e.Message]);
  end;
end;


end.
