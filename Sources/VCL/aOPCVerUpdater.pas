unit aOPCVerUpdater;

interface

uses
  Windows, Forms, Controls, Messages,
  Classes,
  aCustomOPCSource, aCustomOPCTCPSource, aOPCTCPSource,
  aOPCConnectionList;


type
  TaOPCVerUpdateExistsEvent = procedure(aVer1, aVer2: Integer) of object;

  TaOPCVerUpdater = class(TComponent)
  private
    FEscPressed: Boolean;

    FAppVer: Integer;

    FVerDataLink: TaOPCDataLink;

    FOnUpdateExists: TaOPCVerUpdateExistsEvent;
    FActive: Boolean;
    FInstallFileName: string;
    FConfirmRun: Boolean;
    procedure SetOnUpdateExists(const Value: TaOPCVerUpdateExistsEvent);

    procedure DoChangeVersion(aSender: TObject);

    function GetOPCSource: TaCustomOPCSource;
    procedure SetOPCSource(const Value: TaCustomOPCSource);

    function GetServerAppVer: Integer;
    procedure SetActive(const Value: Boolean);
    procedure SetInstallFileName(const Value: string);

    procedure DoProgressNotify(aIndex, aCount: Integer; var aCancel: boolean);
    function GetVerID: TPhysID;
    procedure SetVerID(const Value: TPhysID);
    procedure SetConfirmRun(const Value: Boolean);

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure DoUpdate(aVer1, aVer2: Integer);
    function DownloadUpdate(aStream: TStream; aProgressNotify: TOPCProgressNotify): Boolean;

    property VerDataLink: TaOPCDataLink read FVerDataLink;

  published
    property Active: Boolean read FActive write SetActive default False;
    property OPCSource : TaCustomOPCSource read GetOPCSource write SetOPCSource;

    property AppVer: Integer read FAppVer;
    property ServerAppVer: Integer read GetServerAppVer;
    property InstallFileName: string read FInstallFileName write SetInstallFileName;

    property VerID: TPhysID read GetVerID write SetVerID;
    property ConfirmRun: Boolean read FConfirmRun write SetConfirmRun default False;

    property OnUpdateExists: TaOPCVerUpdateExistsEvent read FOnUpdateExists write SetOnUpdateExists;
  end;


implementation

uses
  uDCStatus, uDCCommonProc,
  DC.Resources,
  SysUtils,
  JclFileUtils,
  JvVersionInfo;

{ TaOPCVerUpdater }

constructor TaOPCVerUpdater.Create(AOwner: TComponent);
var
  vi:TjvVersionInfo;
begin
  inherited Create(AOwner);

  // определяем текущую версию программы
  vi := TjvVersionInfo.Create(AppFileName);
  try
//    FAppVer := vi.ProductLongVersion.All[4] +
//      vi.ProductLongVersion.All[3] * 100 +
//      vi.ProductLongVersion.All[2] * 10000;
    FAppVer := StrToInt(StringReplace(vi.ProductVersion, '.', '', [rfReplaceAll]))
  finally
    vi.Free;
  end;

  FVerDataLink := TaOPCDataLink.Create(Self);
  FVerDataLink.OnChangeData := DoChangeVersion;
end;

destructor TaOPCVerUpdater.Destroy;
begin
  FVerDataLink.Free;

  inherited;
end;

procedure TaOPCVerUpdater.DoChangeVersion(aSender: TObject);
begin
  if not Active then
    Exit;

  if FAppVer < StrToIntDef(FVerDataLink.Value, 0) then
  begin
    if Assigned(FOnUpdateExists) then
      OnUpdateExists(FAppVer, StrToIntDef(VerDataLink.Value, 0))
    else
      DoUpdate(FAppVer, StrToIntDef(VerDataLink.Value, 0));
  end;

end;

procedure TaOPCVerUpdater.DoProgressNotify(aIndex, aCount: Integer; var aCancel: boolean);
begin
  //Sleep(200);
  DCStatus.ProgressWin.Percent := Trunc(aIndex / aCount * 1000);
  aCancel := FEscPressed or DCStatus.ProgressWin.Canceled;
end;

// выполнить стандартное обновление программы
procedure TaOPCVerUpdater.DoUpdate(aVer1, aVer2: Integer);
var
  aStream: TStream;
  aFileName: string;
  //dlgRes: Integer;
  aUser, aPassword: string;
begin
//  MessageBox(Handle, 'Не удалось загрузить новую версия программы.', '',
//    MB_YESNO + MB_ICONINFORMATION);


  if MessageBox(
    Application.MainForm.Handle,
    PChar(Format(sNewVersionAvailableFmt, [aVer2])),
    PChar(Application.Title),
    MB_YESNO + MB_ICONQUESTION) <> mrYes then
    Exit;

  // загружаем мастер установки с сервера
  aFileName := PathGetTempPath + ExtractFileName(InstallFileName); //'\Setup.exe';
  aStream := TFileStream.Create(aFileName, fmCreate);
  try
    // качаем инсталятор с отображением процента выполненной работы
    DCStatus.ShowStatus(Format(
      sDownloadingFmt,
      [ExtractFileName(aFileName)]), True, 0);
    try
      FEscPressed := False;
      if not DownloadUpdate(aStream, DoProgressNotify) then
        Exit;
    finally
      DCStatus.HideStatus;
    end;

  finally
    aStream.Free;
  end;

  // проверяем его наличие на диске и запускаем
  if FileExists(aFileName) then
  begin
    if ConfirmRun then
      if MessageBox(
        Application.Handle,
        PChar(Format(sSuccesfulDouwnloadFmt, [#13#10 + aFileName + #13#10])),
        PChar(Application.Title),
        MB_YESNO + MB_ICONQUESTION) <> mrYes then
        Exit;

    Application.ProcessMessages;
    if OPCSource is TaCustomOPCTCPSource then
    begin
      aUser := TaOPCTCPSource(OPCSource).User;
      aPassword := TaOPCTCPSource(OPCSource).Password;
    end
    else
    begin
      aUser := '';
      aPassword := '';
    end;

    ExecuteFile(aFileName, Format('/SILENT u="%s" p="%s"', [aUser, aPassword]), ExtractFilePath(aFileName), SW_SHOWNORMAL);

    //PostMessage(Application.Handle, WM_QUIT, 0, 0)
    Application.Terminate;
  end
  else
    MessageBox(
      Application.Handle,
      PChar(sUnableToDouwnload),
      PChar(Application.Title),
      MB_OK + MB_ICONERROR);

end;



function TaOPCVerUpdater.DownloadUpdate(aStream: TStream; aProgressNotify: TOPCProgressNotify): Boolean;
var
  saveProgressNonify: TOPCProgressNotify;
begin
  Result := False;
  
  if not Assigned(OPCSource) then
    Exit;

  if not (OPCSource is TaCustomOPCTCPSource) then
    Exit;

  saveProgressNonify := TaCustomOPCTCPSource(OPCSource).OnProgress;
  if Assigned(aProgressNotify) then
    TaCustomOPCTCPSource(OPCSource).OnProgress := aProgressNotify;
    
  try
    try
      TaCustomOPCTCPSource(OPCSource).DownloadSetup(InstallFileName, aStream);
      Result := True;
    except
      on e: EOPCTCPCommandException do
        Application.MessageBox(PChar(e.Message), 'Ошибка', MB_OK + MB_ICONSTOP);
    end;
  finally
    TaCustomOPCTCPSource(OPCSource).OnProgress := saveProgressNonify;
  end;

  //TaOPCTCPSource_V32(OPCSource).DownloadPMCSetup(aStream, aProgressNotify);

end;

function TaOPCVerUpdater.GetOPCSource: TaCustomOPCSource;
begin
  Result := FVerDataLink.OPCSource;
end;

function TaOPCVerUpdater.GetServerAppVer: Integer;
begin
  Result := StrToIntDef(FVerDataLink.Value, 0);
end;

function TaOPCVerUpdater.GetVerID: TPhysID;
begin
  Result := VerDataLink.PhysID;
end;

procedure TaOPCVerUpdater.SetActive(const Value: Boolean);
begin
  FActive := Value;
  DoChangeVersion(Self);
end;

procedure TaOPCVerUpdater.SetConfirmRun(const Value: Boolean);
begin
  FConfirmRun := Value;
end;

procedure TaOPCVerUpdater.SetInstallFileName(const Value: string);
begin
  FInstallFileName := Value;
end;

procedure TaOPCVerUpdater.SetOnUpdateExists(const Value: TaOPCVerUpdateExistsEvent);
begin
  FOnUpdateExists := Value;
end;

procedure TaOPCVerUpdater.SetOPCSource(const Value: TaCustomOPCSource);
begin
  VerDataLink.OPCSource := Value;
end;

procedure TaOPCVerUpdater.SetVerID(const Value: TPhysID);
begin
  VerDataLink.PhysID := Value;
end;

end.
