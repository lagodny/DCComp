{*******************************************************}
{                                                       }
{     Copyright (c) 2001-2016 by Alex A. Lagodny        }
{                                                       }
{*******************************************************}
{$I OPC.INC}

unit uMnemoShema;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, XPMan, aOPCProvider, aOPCCinema, aOPCAuthorization,
  StoHtmlHelp,
  ExtCtrls,
  Registry, IniFiles,
  ActnList, Menus, ComCtrls, AppEvnts, StdActns,
//  About,
  uAppStorage,
  aOPCDataObject, aOPCLookupList,
  aCustomOPCSource, aOPCSource, aOPCTCPSource_V30,
  aCustomOPCTCPSource, aOPCTCPSource, aOPCVerUpdater, System.Actions,
  mORMoti18n;

const
  ssRealTime = 'Режим реального времени';
  ssShowHistory = 'Режим просмотра истории';
  ssDemoMode = 'Нет подключения. Демо режим';

type
  TIniSettingsOperationEvent = procedure
    (Sender: TObject; IniFile: TCustomIniFile) of object;

  TfmMnemoShema = class(TForm)
    aOPCSource: TaOPCTCPSource_V30;
    aOPCAuthorization: TaOPCAuthorization;
    OPCCinema: TaOPCCinema;
    MainMenu: TMainMenu;
    ActionList: TActionList;
    aHistory: TAction;
    aPrint: TAction;
    mHistory: TMenuItem;
    mPrint: TMenuItem;
    StatusBar: TStatusBar;
    Timer1: TTimer;
    PrintDialog1: TPrintDialog;
    aScale: TAction;
    aSimulateMode: TAction;
    mParams: TMenuItem;
    mSimulateMode: TMenuItem;
    mScale: TMenuItem;
    aAbout: TAction;
    mAbout: TMenuItem;
    mAboutProgramm: TMenuItem;
    N3: TMenuItem;
    N1: TMenuItem;
    HelpContents1: THelpContents;
    ApplicationEvents1: TApplicationEvents;
    llStates: TaOPCLookupList;
    aHelp: TAction;
    VerUpdater: TaOPCVerUpdater;
    procedure aOPCSourceRequest(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure aHistoryExecute(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure aPrintExecute(Sender: TObject);
    procedure aOPCSourceActivate(Sender: TObject);
    procedure aOPCRestartChange(Sender: TObject);
    procedure aOPCSourceDeactivate(Sender: TObject);
    procedure OPCCinemaChangeMoment(Sender: TObject);
    procedure ActionListUpdate(Action: TBasicAction; var Handled: Boolean);
    procedure aScaleExecute(Sender: TObject);
    procedure aSimulateModeExecute(Sender: TObject);
    procedure aAboutExecute(Sender: TObject);
    procedure OPCCinemaActivate(Sender: TObject);
    procedure OPCCinemaDeactivate(Sender: TObject);
    procedure aOPCSourceError(Sender: TObject; MessageStr: string);
    procedure N3Click(Sender: TObject);
    procedure ApplicationEvents1Hint(Sender: TObject);
    procedure aHelpExecute(Sender: TObject);
    procedure aOPCSourceConnect(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FIniFileName: string;

    FSavedStatus: string;
    FDesignFormCaption: string;
    FRestartApp: string;
    FCurrentMoment: TDateTime;
    FOnChangeStatus: TNotifyEvent;
    FOnLoadIniSettings: TIniSettingsOperationEvent;
    FBackColor: TColor;
    FLabelColor: TColor;

    procedure DoData(Sender: TObject; const Data: string);

    procedure SetStatus(const Value: string);
    function GetStatus: string;
    function GetCurrentMoment: TDateTime;
    procedure SetError(const Value: string);
    function GetAllowClick: boolean;
    procedure SetAllowClick(const Value: boolean);
    procedure SetUserHint(const Value: string);
    procedure CreateTmpForm;
  protected
    OldScale: integer;

//    DevelopInfo: TDevelopInfo;

    hMutex: THandle;
    hPrev: HWND;
    function CheckIfOnlyOne(FUnique: string): boolean;

    procedure SetCurrentMoment(const Value: TDateTime); virtual;

    function GetFormCaption: string; virtual;
    function GetIniFileName: TFileName; virtual;

    procedure SetBackColor(const Value: TColor); virtual;
    procedure SetLabelColor(const Value: TColor); virtual;

    procedure CreateObjects; virtual;
    procedure InitObjects; virtual;
    function GetAppGUID: string;

    procedure LoadSettings; virtual;
    procedure SaveSettings; virtual;
    procedure CustomLoadIni(Ini: TCustomIniFile); virtual;

    procedure LoadLookups; virtual;

    procedure CustomLoadSettings(aStore: TCustomIniFile); virtual;
    procedure CustomSaveSettings(aStore: TCustomIniFile); virtual;
  public
    Scale: integer;
//    function AppSectionName: string;
//    function MainSectionName: string;

//    function GetRegistryKey: string; virtual;

    property Status: string read GetStatus write SetStatus;
    property CurrentMoment: TDateTime read GetCurrentMoment write SetCurrentMoment;
    property Error: string write SetError;
    property UserHint: string write SetUserHint;
    property AllowClick: boolean read GetAllowClick write SetAllowClick;

    property BackColor: TColor read FBackColor write SetBackColor;
    property LabelColor: TColor read FLabelColor write SetLabelColor;
  published
    property OnLoadIniSettings: TIniSettingsOperationEvent read FOnLoadIniSettings write FOnLoadIniSettings;
    property OnChangeStatus: TNotifyEvent read FOnChangeStatus write FOnChangeStatus;
  end;

var
  fmMnemoShema: TfmMnemoShema;

implementation

uses
  uOPCFrame,
  jvVersionInfo,
  uKeys, uCommandLine, uDataExchange,
  DC.VCL.PasswordForm,
//  DC.VCL.ChangePasswordForm,
  uCinemaControlForm;

{$R *.dfm}

{ TfmMnemoShema }

procedure TfmMnemoShema.LoadSettings;
var
  Registry: TRegistry;
  IniFile: TIniFile;
  aRect: TRect;
begin
  // ини файлик с параметрами подключения
  IniFile := TIniFile.Create(GetIniFileName);
  try
    with IniFile do
    begin
      aOPCSource.RemoteMachine := ReadString('Common', 'RemoteMashine', aOPCSource.RemoteMachine);
      aOPCSource.Port := ReadInteger('Common', 'Port', aOPCSource.Port);
      aOPCSource.AltAddress := ReadString('Common', 'AltAddress', aOPCSource.AltAddress);
      aOPCSource.ConnectTimeOut := ReadInteger('Common', 'ConnectTimeOut', aOPCSource.ConnectTimeOut);
      aOPCSource.ReadTimeOut := ReadInteger('Common', 'ReadTimeOut', aOPCSource.ReadTimeOut);
      aOPCSource.Interval := ReadInteger('Common', 'Interval', aOPCSource.Interval);
      aOPCSource.UpdateMode := TaOPCUpdateMode(ReadInteger('Common', 'UpdateMode', Ord(aOPCSource.UpdateMode)));
      aOPCSource.CompressionLevel := ReadInteger('Common', 'CompressionLevel', aOPCSource.CompressionLevel);
      aOPCSource.Encrypt := ReadBool('Common', 'Encrypt', aOPCSource.Encrypt);

      VerUpdater.VerID := ReadString('VerUpdater', 'VerID', VerUpdater.VerID);
    end;

    CustomLoadIni(IniFile);

    if Assigned(FOnLoadIniSettings) then
      FOnLoadIniSettings(Self, IniFile);
  finally
    IniFile.Free;
  end;

  // реестр - состояние форм
  AppStorageKind := skRegistry;
  aOPCAuthorization.User := AppStorage(TKeys.Home).ReadString(TKeys.Main, 'User', '');

  //Scale := 100;
  Scale := AppStorage.ReadInteger(TKeys.Main, 'Scale', 100);
  if Scale <= 10 then
    Scale := 100;

  BackColor := AppStorage.ReadInteger(TKeys.Main, 'BackColor', Color); // $808080);
  LabelColor := AppStorage.ReadInteger(TKeys.Main, 'LabelColor', Font.Color);// clBlack);


  //AllowClick := AppStorage.ReadBool(TKeys.Main, 'AllowClick', False);

  if Position = poDefaultPosOnly then
  begin
    Left := AppStorage.ReadInteger(TKeys.Main, 'Left', Left);
    Top := AppStorage.ReadInteger(TKeys.Main, 'Top', Top);
  end
  else
  begin
    SetBounds(
      AppStorage.ReadInteger(TKeys.Main, 'Left', Left),
      AppStorage.ReadInteger(TKeys.Main, 'Top', Top),
      AppStorage.ReadInteger(TKeys.Main, 'Width', Width),
      AppStorage.ReadInteger(TKeys.Main, 'Height', Height)
      );
  end;
  WindowState := TWindowState(AppStorage.ReadInteger(TKeys.Main, 'WindowState', Ord(WindowState)));

  try
    CustomLoadSettings(AppStorage);
  except
  end;

  if Scale <> 100 then
    ScaleBy(Scale, 100);


{
  Registry := TRegistry.Create(KEY_ALL_ACCESS);
  try
    Registry.RootKey := HKEY_CURRENT_USER;
    if Registry.OpenKey(GetRegistryKey, false) then
    begin
      Scale := StrToIntDef(Registry.ReadString('Scale'), 100);
      if Scale = 0 then
        Scale := 100;
        
      aOPCAuthorization.User := Registry.ReadString('User');
      try
        AllowClick := Registry.ReadBool('AllowClick');
      except
        AllowClick := false;
      end;

      if Position = poDefaultPosOnly then
      begin
        Left := StrToIntDef(Registry.ReadString('Left'), Left);
        Top := StrToIntDef(Registry.ReadString('Top'), Top);
      end
      else
      begin
        SetBounds(
          StrToIntDef(Registry.ReadString('Left'), Left),
          StrToIntDef(Registry.ReadString('Top'), Top),
          StrToIntDef(Registry.ReadString('Width'), Width),
          StrToIntDef(Registry.ReadString('Height'), Height)
          );
      end;
      WindowState := TWindowState(StrToIntDef(Registry.ReadString('WindowState'), Ord(WindowState)));

      if Scale <> 100 then
        ScaleBy(Scale, 100);

      try
        CustomLoadSettings(AppStorage);
      except
      end;

    end;
  finally
    Registry.Free;
  end;
}


end;

procedure TfmMnemoShema.N3Click(Sender: TObject);
begin
  //Application.HelpCommand(HELP_CONTENTS, 0);
end;

procedure TfmMnemoShema.FormCreate(Sender: TObject);
//var
//  CustomIniFile:TRegistryIniFile;

begin
{$ifdef EXTRACTALLRESOURCES}
  // нам не нужно что-то делать, если мы просто извлекаем ресурсы
  Exit;
{$endif}

  if not CheckIfOnlyOne(GetAppGUID) then
    Exit;


  AppStorage(TKeys.Home);

  aOPCSource.Connected := False;
  CreateTmpForm;
  Status := ssRealTime;
  FDesignFormCaption := Caption;
  aOPCSource.Description := Format('%s %d - %s', [FDesignFormCaption, VerUpdater.AppVer, Application.ExeName]);

  // := GetFormCaption;

  // нужно переопределить у наследника, чтобы создать нужные формы и фреймы
  CreateObjects;
  // нужно переопределить у наследника, чтобы подгрузить его настройки
  LoadSettings;

  //aOPCSource.Connected := true;
  try
    aOPCAuthorization.ReadCommandLineExt;
    if not aOPCAuthorization.CheckPermissions then
    begin
//      if not aOPCAuthorization.Execute then
      if not TPasswordForm.Execute(aOPCAuthorization) then
      begin
        aOPCSource.Connected := false;
        Application.Terminate;
        Application.ShowMainForm := false;
        Abort;
      end;
    end;
  except
    on e: Exception do
    begin
      Status := ssDemoMode;
      Error := e.Message;
    end;
  end;
  LoadLookups;

  Caption := GetFormCaption;
  Application.Title := Caption;
  Application.HelpFile := ChangeFileExt(Application.ExeName, '.chm');

  // нужно переопределить у наследника, чтобы проставить полученные после загзурки настроек параметры
  InitObjects;

//  with DevelopInfo do
//  begin
//    ApplicationName := FDesignFormCaption;
//    Version := IntToStr(VerUpdater.AppVer); //GetVersion;
//    Company := '';//'ООО "Данон"';
//    Department := 'отдел АСУТП';
//    Developers := 'Лагодный Александр';
//    WebSite := '';
//    MailTo := 'a.lagodny@gmail.com';
//    Title := 'DANONE';
//  end;

  SetForegroundWindow(Handle);
end;

procedure TfmMnemoShema.FormShow(Sender: TObject);
{$IFDEF EXTRACTALLRESOURCES}
begin
  ExtractAllResources(
    // first, all enumerations to be translated
    //[TypeInfo(TCuteEvent),TypeInfo(TCuteAction),TypeInfo(TPreviewAction)],
//    [TypeInfo(TSQLLineState)
//      , TypeInfo(TSQLDocLineShiftReportPhase)
//      , TypeInfo(TSQLPasterKind)
//      , TypeInfo(TCCPType)
//      , TypeInfo(TCCPEvent)
//      , TypeInfo(TCCPCheckPeriod)
//      , TypeInfo(TSQLEmployeeFunction)
//      , TypeInfo(TPeriodicity)
//      //, TypeInfo(TSQLCuteUserKind)
//      , TypeInfo(TShiftType)
//      , TypeInfo(TCIPProduct)
//      , TypeInfo(TCIPState)
//      , TypeInfo(TCIPMenu)
//      , TypeInfo(TEquipmentKind)
//      , TypeInfo(TTOParameterValueType)
//      , TypeInfo(TTOParameterType)
//      , TypeInfo(TLossCalcMethod)
//      , TypeInfo(TLossMaterialKind)
//      , TypeInfo(TComponentType)
//      , TypeInfo(TTOParameterCalcFunction)
//      , TypeInfo(TStageDocStatus)
//      , TypeInfo(TPeriodCalcProc)
//    ],
    [],
    // then some class instances (including the TSQLModel will handle all TSQLRecord)
//    [aModel],
    [],
    // some custom classes or captions
    [], []);

  //mORMotUILogin.
  ShowMessage('All resources have extracted!');
  Close;
{$ELSE}
begin
  Application.BringToFront;
  SetForegroundWindow(Application.Handle);
{$ENDIF}
end;

//function TfmMnemoShema.GetVersion: string;
//var
//  vi: TjvVersionInfo;
//begin
//  Result := '';
//  vi := TjvVersionInfo.Create(AppFileName);
//  try
//    Result := vi.FileVersion;
//  finally
//    vi.Free;
//  end;
//end;

function TfmMnemoShema.GetIniFileName: TFileName;
  function AbsFileName(aFileName: string): string;
  begin
    Result := aFileName;

    if (Length(Result) > 1)
      and (copy(Result, 1, 2) <> '\\')
      and (pos(':', Result) = 0) then
    begin
      Result := ExtractFilePath(Application.ExeName) + '\' + Result;
    end;
  end;

var
  i: Integer;

begin
  if FIniFileName <> '' then
  begin
    Result := FIniFileName;
    Exit;
  end;

  if ParamCount = 1 then
    Result := AbsFileName(ParamStr(1))
  else if ParamCount > 1 then
  begin
    for i := 1 to ParamCount do
    begin
      if AnsiSameText(Copy(ParamStr(i), 1, 2), '-f') then
      begin
        Result := AbsFileName(
          Copy(ParamStr(i), 3, Length(ParamStr(i)) - 2));
        Break;
      end;
    end;
  end
  else
    Result := ChangeFileExt(Application.ExeName, '.ini');

  if (Result = '') or (not FileExists(Result)) then
    Result := ChangeFileExt(Application.ExeName, '.ini');

  FIniFileName := Result;
end;

//function TfmMnemoShema.GetRegistryKey: string;
//var
//  fn: string;
//begin
//  fn := ExtractFileName(Application.ExeName);
//  fn := ChangeFileExt(fn, '');
//  Result := '\Software\Monitoring\' + fn;
//end;

function TfmMnemoShema.GetFormCaption: string;
begin
  Result := Format('%s - версия %d', [FDesignFormCaption, VerUpdater.AppVer]);
end;

procedure TfmMnemoShema.SaveSettings;
//var
//  Registry: TRegistry;
begin
  AppStorage(TKeys.Home);
  AppStorage.WriteString(TKeys.Main, 'User', aOPCAuthorization.User);
  AppStorage.WriteInteger(TKeys.Main, 'Left', Left);
  AppStorage.WriteInteger(TKeys.Main, 'Top', Top);
  AppStorage.WriteInteger(TKeys.Main, 'Width', Width);
  AppStorage.WriteInteger(TKeys.Main, 'Height', Height);
  AppStorage.WriteInteger(TKeys.Main, 'Scale', Scale);
  AppStorage.WriteInteger(TKeys.Main, 'BackColor', BackColor);
  AppStorage.WriteInteger(TKeys.Main, 'LabelColor', LabelColor);
  AppStorage.WriteBool(TKeys.Main, 'AllowClick', AllowClick);
  AppStorage.WriteInteger(TKeys.Main, 'WindowState', ord(WindowState));

  try
    CustomSaveSettings(AppStorage);
  except
  end;

{
  Registry := TRegistry.Create(KEY_ALL_ACCESS);
  try
    try
      Registry.RootKey := HKEY_CURRENT_USER;
      if Registry.OpenKey(GetRegistryKey, true) then
      begin
        Registry.WriteString('User', aOPCAuthorization.User);
        Registry.WriteString('Left', IntToStr(Left));
        Registry.WriteString('Top', IntToStr(Top));
        Registry.WriteString('Width', IntToStr(Width));
        Registry.WriteString('Height', IntToStr(Height));
        Registry.WriteString('Scale', IntToStr(Scale));
        Registry.WriteBool('AllowClick', AllowClick);
        Registry.WriteString('WindowState', IntToStr(ord(WindowState)));

        CustomSaveSettings(AppStorage);
      end;
    except
    end;
  finally
    Registry.Free;
  end;
}
end;

procedure TfmMnemoShema.FormClose(Sender: TObject;
  var Action: TCloseAction);
var
  i: Integer;
begin
  if Assigned(CinemaControlForm) then
  begin
    CinemaControlForm.Close;
    Application.ProcessMessages;
  end;

  aOPCSource.Connected := false;
  for i := 0 to ComponentCount - 1 do
    if Components[i] is TaOPCFrame then
      TaOPCFrame(Components[i]).StopAnimate;

  SaveSettings;
end;

procedure TfmMnemoShema.aHelpExecute(Sender: TObject);
begin
  Application.HelpSystem.ShowTableOfContents;
end;

procedure TfmMnemoShema.aHistoryExecute(Sender: TObject);
begin
  OPCCinema.ConnectOPCSourceDataLinks(aOPCSource);
//  OPCCinema.ShowPult(Self, false);
  TCinemaControlForm.ShowPult(OPCCinema, nil, False);
end;

procedure TfmMnemoShema.SetStatus(const Value: string);
begin
  Timer1.Enabled := (Value = ssDemoMode);
  StatusBar.Panels[0].Text := Value;
  if Assigned(FOnChangeStatus) then
    FOnChangeStatus(Self);
end;

procedure TfmMnemoShema.SetUserHint(const Value: string);
begin
  if StatusBar.Panels.Count >= 4 then
    StatusBar.Panels[3].Text := Value;
end;

function TfmMnemoShema.GetStatus: string;
begin
  Result := StatusBar.Panels[0].Text;
end;

procedure TfmMnemoShema.InitObjects;
begin

end;

procedure TfmMnemoShema.Timer1Timer(Sender: TObject);
begin
  CurrentMoment := Now;
end;

function TfmMnemoShema.GetCurrentMoment: TDateTime;
begin
  Result := FCurrentMoment;
end;

procedure TfmMnemoShema.SetCurrentMoment(const Value: TDateTime);
begin
  FCurrentMoment := Value;
  StatusBar.Panels[1].Text := DateTimeToStr(FCurrentMoment);
end;

procedure TfmMnemoShema.aPrintExecute(Sender: TObject);
begin
  if PrintDialog1.Execute then
    Print;
end;

procedure TfmMnemoShema.SetError(const Value: string);
begin
  StatusBar.Panels[2].Text := Value;
end;

procedure TfmMnemoShema.SetLabelColor(const Value: TColor);
var
  i: Integer;
begin
  if FLabelColor <> Value then
  begin
    FLabelColor := Value;
    for i := 0 to ComponentCount - 1 do
    begin
      if Components[i] is TaOPCFrame then
        TaOPCFrame(Components[i]).SetLabelColor(Value);
    end;
  end;
end;

procedure TfmMnemoShema.aOPCSourceActivate(Sender: TObject);
begin

  //Timer1.Enabled := true;
  Status := ssRealTime;
  Error := '';

end;

procedure TfmMnemoShema.aOPCSourceConnect(Sender: TObject);
begin
  Error := '';
end;

procedure TfmMnemoShema.aOPCRestartChange(Sender: TObject);
var
  CmdStr: string;
  OPCProvider: TaOPCProvider;

  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
begin
  OPCProvider := (Sender as TaOPCProvider);
  if StrToIntDef(OPCProvider.Value, 0) > 1 then
  begin
    CmdStr := Format('"%s" "%s" "%s" "%s" "%s"', [FRestartApp, OPCProvider.Value,
      Application.ExeName, aOPCSource.User, aOPCSource.Password]);

    FillChar(StartupInfo, SizeOf(TStartupInfo), #0);
    StartupInfo.cb := SizeOf(TStartupInfo);
    StartupInfo.dwFlags := STARTF_USESHOWWINDOW;
    StartupInfo.wShowWindow := CmdShow;

    CreateProcess(nil, PChar(CmdStr), nil, nil, False,
      NORMAL_PRIORITY_CLASS, nil, nil, StartupInfo, ProcessInfo);

    PostMessage(Handle, WM_CLOSE, 0, 0);
  end;
end;

procedure TfmMnemoShema.aOPCSourceDeactivate(Sender: TObject);
begin

  Timer1.Enabled := false;
  Status := ssShowHistory;

end;

procedure TfmMnemoShema.aOPCSourceError(Sender: TObject; MessageStr: string);
var
  tmpOPCTCPSource: TaCustomOPCTCPSource;
begin

  tmpOPCTCPSource := Sender as TaCustomOPCTCPSource;
  Error := Format('%s(%d):%s',
    [tmpOPCTCPSource.RemoteMachine, tmpOPCTCPSource.Port, MessageStr]);

end;

procedure TfmMnemoShema.OPCCinemaChangeMoment(Sender: TObject);
begin
  CurrentMoment := OPCCinema.CurrentMoment;
end;

procedure TfmMnemoShema.ActionListUpdate(Action: TBasicAction;
  var Handled: Boolean);
var
  i: integer;
  aFound: boolean;
begin
  aFound := false;
  //if aOPCSource.Connected then
  begin
    for i := 0 to Screen.FormCount - 1 do
      if Screen.Forms[i] is TCinemaControlForm then
      begin
        aFound := true;
        Break;
      end;
  end;
  aHistory.Enabled := not aFound;// and aOPCSource.Connected;
end;

procedure TfmMnemoShema.aScaleExecute(Sender: TObject);
var
  sScale: string;
begin
  if InputQuery('Укажите масштаб', IntToStr(Scale), sScale) then
  begin
    ScaleBy(100, Scale);
    Scale := StrToInt(sScale);
    ScaleBy(Scale, 100);
  end;
end;

function TfmMnemoShema.CheckIfOnlyOne(FUnique: string): boolean;
var
  Ca: string[255];
  Wnd:HWND;
//  FUnique: string;

  function FindRecvWnd(const ID:string):HWND;
  type
    TWndInfo = record
      ID: string;
      Wnd: HWND;
    end;

    function EnumWindowsProc(Wnd:HWND;var Info:TWndInfo):BOOL; stdcall;
    begin
      Result := GetProp(Wnd,PChar(Info.ID)) <> iID;
      if not Result then
        Info.Wnd := Wnd;
    end;
  var
    Info: TWndInfo;
  begin
    Info.ID := ID;
    Info.Wnd := 0;
    EnumWindows(@EnumWindowsProc, Integer(@Info));
    Result := Info.Wnd;
  end;

  procedure SendData(Wnd:HWND;const Data:string);
  var
    CDS:TCopyDataStruct;
  begin
    CDS.dwData := $12345;
    CDS.cbData := Length(Data);
    CDS.lpData := PChar(Data);
    SendMessage(Wnd, WM_COPYDATA, $12345, Integer(@CDS));
  end;


begin
//  FUnique := GetFUnique; //'D1DB1A63-3E4C-4F3A-9F17-3FFB421307D6';
//  if FUnique = '' then
//    Exit;
  if FUnique = '' then
    Exit(True);

  // мютекс пытаемся создать в любом случае
  hMutex := CreateMutex(nil, True, PChar(FUnique));
  if GetLastError = ERROR_ALREADY_EXISTS then
  begin
    // а вот отменяем запуск второго экземпляра только если это задано в командной строке
    if not (CommandLineStrings.Values[sCommandLineSingleInstance] = '1') then
    begin
      Result := true;
      exit;
    end;

    try
      Result := false;

      Ca := Application.Title;
      Ca[ord(Ca[0]) + 1] := #0;
      Application.Title := '';               // dont let it find this window
      HPrev := FindWindow('TApplication', @Ca[1]);
      if IsIconic(hPrev) then
        ShowWindow(hPrev, SW_RESTORE);

      SetForeGroundWindow(HPrev);

      Wnd := FindRecvWnd(sDataExchangeWindow);
      if Wnd <> 0 then
        SendData(Wnd, CommandLineStrings.Values[sCommandLineCommandFile]);

      Application.ShowMainForm := False;     // dont show a button or form
    finally
      //MessageDlg('Запуск нескольких копий программы на одном компьютере запрещён.'+#13+#10+'Приложение уже запущено.',mtError,[mbOK],-1);
      Application.Terminate;
      Abort;
    end;
  end
  else
    Result := True;
end;

procedure TfmMnemoShema.CreateObjects;
begin

end;

procedure TfmMnemoShema.CreateTmpForm;
var
  f: TForm;
begin
  f := TForm.Create(Application);
  try
    f.SetBounds(0, 0, 0, 0);
    f.BorderStyle := bsNone;
    f.Show;
    Application.ProcessMessages;
  finally
    f.Free;
  end;
end;

procedure TfmMnemoShema.CustomLoadIni(Ini: TCustomIniFile);
begin

end;

procedure TfmMnemoShema.CustomLoadSettings(aStore: TCustomIniFile);
begin

end;

procedure TfmMnemoShema.CustomSaveSettings(aStore: TCustomIniFile);
begin

end;

procedure TfmMnemoShema.DoData(Sender: TObject; const Data: string);
begin
  if Data = '' then
    Exit;

  // обрабатываем полученные данные

//  if (TMapForm.ActiveForm <> nil) then
//    TMapForm.ActiveForm.ExecCommandFile(Data);
end;

procedure TfmMnemoShema.aSimulateModeExecute(Sender: TObject);
begin
  AllowClick := aSimulateMode.Checked;
end;

function TfmMnemoShema.GetAllowClick: boolean;
begin
  Result := aSimulateMode.Checked;
end;

function TfmMnemoShema.GetAppGUID: string;
begin
  Result := '';
end;

//function TfmMnemoShema.MainSectionName: string;
//begin
//  Result := AppSectionName + '\Main';
//end;

procedure TfmMnemoShema.SetAllowClick(const Value: boolean);
var
  i: integer;
  tmpSource: TaCustomOPCSource;
begin
  aSimulateMode.Checked := Value;
  aOPCSource.Active := not Value;

  for i := 0 to ComponentCount - 1 do
  begin
    // чтобы вернуться в нормальный режим (нужно отключиться и подключиться)
    if not Value then
    begin
      if Components[i] is TaCustomOPCDataObject then
      begin
        tmpSource := TaCustomOPCDataObject(Components[i]).OPCSource;
        TaCustomOPCDataObject(Components[i]).OPCSource := nil;
        TaCustomOPCDataObject(Components[i]).OPCSource := tmpSource;
      end
      else if Components[i] is TaOPCFrame then
      begin
        tmpSource := TaOPCFrame(Components[i]).OPCSource;
        TaOPCFrame(Components[i]).OPCSource := nil;
        TaOPCFrame(Components[i]).OPCSource := TaCustomMultiOPCSource(tmpSource);
      end
    end;

    if Components[i] is TaOPCFrame then
      TaOPCFrame(Components[i]).AllowClick := aSimulateMode.Checked;
  end;
end;

procedure TfmMnemoShema.SetBackColor(const Value: TColor);
var
  i: Integer;
begin
  if FBackColor <> Value then
  begin
    FBackColor := Value;
    for i := 0 to ComponentCount - 1 do
    begin
      if Components[i] is TaOPCFrame then
        TaOPCFrame(Components[i]).SetBackColor(Value);
    end;
  end;
end;

procedure TfmMnemoShema.aAboutExecute(Sender: TObject);
begin
  {
    ShowMessage(FDesignFormCaption+' '+
      GetVersion+#13#10+
      aOPCSource.User+#13#10+
      #13#10+
      'ООО Сандора'+#13#10+
      'Отдел АСУТП'+#13#10+
      'Лагодный А.А');
  }
  {
    with TAboutForm.Create(self) do
    begin
      try
        ApplicationName.Caption := FDesignFormCaption;
        Version.Caption := GetVersion;
        User.Caption := aOPCAuthorization.User;
        ShowModal;
      finally
        Free;
      end;
    end;
    }
//  ShowAbout(DevelopInfo, aOPCAuthorization.User);
end;

procedure TfmMnemoShema.aOPCSourceRequest(Sender: TObject);
begin

  if Status = ssRealTime then
    CurrentMoment := Now;

end;

procedure TfmMnemoShema.ApplicationEvents1Hint(Sender: TObject);
begin
  UserHint := Application.Hint;
end;

//function TfmMnemoShema.AppSectionName: string;
//var
//  fn:string;
//begin
//  fn := ExtractFileName(Application.ExeName);
//  fn := ChangeFileExt(fn,'');
//  Result := '\Software\Monitoring\' + fn;
//end;

procedure TfmMnemoShema.LoadLookups;
var
  i: integer;
  Lookup: TaOPCLookupList;
//  CustomIniFile: TCustomIniFile;
begin
//  CustomIniFile := TRegistryIniFile.Create(GetRegistryKey);
//  try
    for i := 0 to ComponentCount - 1 do
    begin
      if Components[i] is TaOPCLookupList then
      begin
        Lookup := TaOPCLookupList(Components[i]);
        if Assigned(Lookup.OPCSource) then
          Lookup.CheckForNewLookup(AppStorage);
      end
      else if Components[i] is TaOPCFrame then
        TaOPCFrame(Components[i]).CheckForNewLookup(AppStorage);
    end;
//  finally
//    FreeAndNil(CustomIniFile);
//  end;
end;

procedure TfmMnemoShema.OPCCinemaActivate(Sender: TObject);
begin
  FSavedStatus := Status;
  Status := ssShowHistory;
end;

procedure TfmMnemoShema.OPCCinemaDeactivate(Sender: TObject);
begin
  Status := FSavedStatus;
end;

end.

