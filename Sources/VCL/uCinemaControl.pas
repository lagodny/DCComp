unit uCinemaControl;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ImgList, ComCtrls, ToolWin, aCustomOPCSource,
  aOPCCinema, StdCtrls, ActnList,
  uOPCInterval, System.Actions, System.ImageList;

type
  TStepMode = (smNextMoment, smStep);

  TaOPCCinemaControl = class(TFrame)
    Panel: TPanel;
    ToolBar2: TToolBar;
    ToolButton1: TToolButton;
    ImageList: TImageList;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    TrackBar1: TTrackBar;
    ToolButton6: TToolButton;
    lDate1: TLabel;
    lDate2: TLabel;
    lCurrentMoment: TLabel;
    ActionList: TActionList;
    aOption: TAction;
    aBegin: TAction;
    aEnd: TAction;
    aPred: TAction;
    aNext: TAction;
    aPause: TAction;
    aStop: TAction;
    aPlay: TAction;
    ToolButton11: TToolButton;
    ToolButton12: TToolButton;
    aPrint: TAction;
    PrintDialog1: TPrintDialog;
    ToolButton13: TToolButton;
    ToolButton14: TToolButton;
    ToolButton15: TToolButton;
    lSpeed: TLabel;
    aFaster: TAction;
    aSlower: TAction;
    aInterval: TAction;
    ToolButton10: TToolButton;
    Timer: TTimer;
    procedure aBeginExecute(Sender: TObject);
    procedure aEndExecute(Sender: TObject);
    procedure aPredExecute(Sender: TObject);
    procedure aNextExecute(Sender: TObject);
    procedure aPauseExecute(Sender: TObject);
    procedure aPlayExecute(Sender: TObject);
    procedure ActionListUpdate(Action: TBasicAction; var Handled: Boolean);
    procedure aOptionExecute(Sender: TObject);
    procedure aStopExecute(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure aPrintExecute(Sender: TObject);
    procedure lCurrentMomentDblClick(Sender: TObject);
    procedure aFasterExecute(Sender: TObject);
    procedure aSlowerExecute(Sender: TObject);
    procedure aIntervalExecute(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
  private
    FInTimer: Boolean;
    FInTrackChange: Boolean;
    FOPCCinema: TaOPCCinema;
    FStepMode: TStepMode;
    FOPCCinemaOnChangeMoment: TNotifyEvent;
    FFormToPrint: TForm;
    FSpeed: integer;
    FStep: integer;
    procedure UpdateActions;
    procedure SetOPCCinema(const Value: TaOPCCinema);
    procedure UpdateCinemaProperty;
    procedure ChangeMoment(Sender: TObject);
    procedure SetStepMode(const Value: TStepMode);
    procedure SetFormToPrint(const Value: TForm);

    function GetPlaying: Boolean;
    procedure SetPlaying(const Value: Boolean);

    function GetSleepInterval: integer;
    procedure SetSleepInterval(const Value: integer);

    procedure SetSpeed(const Value: integer);
    procedure SetStep(const Value: integer);
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;

    function SelectInterval: Boolean;
    function FillHistory: Boolean;

    procedure Play;
    procedure Stop;
    function Skip(aCount: integer): Boolean;

    // procedure HidePult;
    // procedure ShowPult(aFormToPrint: TForm = nil; Modal: boolean = true);

    property Step: integer read FStep write SetStep default 20; // в секундах
    property SleepInterval: integer read GetSleepInterval write SetSleepInterval
      default 100; // милисекунд
    property Speed: integer read FSpeed write SetSpeed default 1;

    property Playing: Boolean read GetPlaying write SetPlaying;

  published
    property StepMode: TStepMode read FStepMode write SetStepMode;
    property OPCCinema: TaOPCCinema read FOPCCinema write SetOPCCinema;
    property FormToPrint: TForm read FFormToPrint write SetFormToPrint;
  end;

implementation

uses
  uCinemaProperty,
  uCinemaFillHistoryProgress,
  DateUtils, Printers, Math,
  uDateTimeInput,
  uOPCIntervalForm;
// uChoiceIntervalExt;

{$R *.dfm}
{ TFrame1 }

{ TaOPCCinemaControl }

procedure TaOPCCinemaControl.ChangeMoment(Sender: TObject);
begin
  lCurrentMoment.Caption := FormatDateTime('hh.mm.ss dd.mm.yyyy',
    OPCCinema.CurrentMoment);
  // lCurrentMoment.Caption := DateTimeToStr(OPCCinema.CurrentMoment);
  lCurrentMoment.Hint := DateTimeToStr(OPCCinema.CurrentMoment);

  TrackBar1.OnChange := nil;
  try
    if OPCCinema.Bof then
      TrackBar1.Position := TrackBar1.Min
    else if OPCCinema.Eof then
      TrackBar1.Position := TrackBar1.Max
    else if OPCCinema.Date1 = OPCCinema.Date2 then
      TrackBar1.Position := TrackBar1.Min
    else
      TrackBar1.Position :=
        Round(TrackBar1.Min + (TrackBar1.Max - TrackBar1.Min) *
        (OPCCinema.CurrentMoment - OPCCinema.Date1) /
        (OPCCinema.Date2 - OPCCinema.Date1));
  finally
    TrackBar1.OnChange := TrackBar1Change;
  end;

  if Assigned(FOPCCinemaOnChangeMoment) then
    FOPCCinemaOnChangeMoment(Self);
end;

constructor TaOPCCinemaControl.Create(aOwner: TComponent);
begin
  inherited;
  FStep := 5;
  FSpeed := 1;
end;

procedure TaOPCCinemaControl.SetOPCCinema(const Value: TaOPCCinema);
begin
  if FOPCCinema <> Value then
  begin
    if FOPCCinema <> nil then
      FOPCCinema.OnChangeMoment := FOPCCinemaOnChangeMoment;

    FOPCCinema := Value;

    if FOPCCinema <> nil then
    begin
      UpdateCinemaProperty;
      FOPCCinemaOnChangeMoment := OPCCinema.OnChangeMoment;
      // if not Assigned(OPCCinema.OnChangeMoment) then
      OPCCinema.OnChangeMoment := ChangeMoment;
    end;
  end;
end;

procedure TaOPCCinemaControl.SetPlaying(const Value: Boolean);
begin
  Timer.Enabled := Value;
end;

procedure TaOPCCinemaControl.UpdateCinemaProperty;
begin
  if OPCCinema = nil then
    exit;
  lDate1.Caption := FormatDateTime('hh.mm.ss dd.mm.yyyy', OPCCinema.Date1);
  lDate2.Caption := FormatDateTime('hh.mm.ss dd.mm.yyyy', OPCCinema.Date2);
  lCurrentMoment.Caption := FormatDateTime('hh.mm.ss dd.mm.yyyy',
    OPCCinema.CurrentMoment);
  // DateTimeToStr(OPCCinema.CurrentMoment);

  lDate1.Hint := DateTimeToStr(OPCCinema.Date1);
  lDate2.Hint := DateTimeToStr(OPCCinema.Date2);
  lCurrentMoment.Hint := DateTimeToStr(OPCCinema.CurrentMoment);

end;

procedure TaOPCCinemaControl.aBeginExecute(Sender: TObject);
begin
  OPCCinema.CurrentMoment := OPCCinema.Date1 - 1;
end;

procedure TaOPCCinemaControl.aEndExecute(Sender: TObject);
begin
  OPCCinema.CurrentMoment := OPCCinema.Date2 + 1;

end;

procedure TaOPCCinemaControl.aFasterExecute(Sender: TObject);
begin
  Speed := Speed + 1;
  lSpeed.Caption := IntToStr(Speed) + 'x';
end;

procedure TaOPCCinemaControl.aIntervalExecute(Sender: TObject);
begin
  if SelectInterval then
  begin
    Stop;
    FillHistory;
  end;
end;

procedure TaOPCCinemaControl.aPredExecute(Sender: TObject);
var
  dt: TDateTime;
begin
  case StepMode of
    smNextMoment:
      begin
        dt := OPCCinema.GetPredMoment;
        if dt <> 0 then
          OPCCinema.CurrentMoment := dt
        else
          OPCCinema.CurrentMoment := OPCCinema.Date1 - 1;
      end;
    smStep:
      Skip(-1);
  end;
end;

procedure TaOPCCinemaControl.SetSleepInterval(const Value: integer);
begin
  Timer.Interval := Value;
end;

procedure TaOPCCinemaControl.SetSpeed(const Value: integer);
begin
  FSpeed := Value;
end;

procedure TaOPCCinemaControl.SetStep(const Value: integer);
begin
  FStep := Value;
end;

procedure TaOPCCinemaControl.SetStepMode(const Value: TStepMode);
begin
  FStepMode := Value;
end;

function TaOPCCinemaControl.Skip(aCount: integer): Boolean;
begin
  if not OPCCinema.Active then
    OPCCinema.Active := true;
  OPCCinema.CurrentMoment := OPCCinema.CurrentMoment + Step * Speed /
    (24 * 60 * 60) * aCount;
  Result := OPCCinema.CurrentMoment < OPCCinema.Date2;
end;

procedure TaOPCCinemaControl.Stop;
begin
  Playing := False;
end;

procedure TaOPCCinemaControl.aNextExecute(Sender: TObject);
var
  dt: TDateTime;
begin
  case StepMode of
    smNextMoment:
      begin
        dt := OPCCinema.GetNextMoment;
        if dt <> 0 then
          OPCCinema.CurrentMoment := dt
        else
          OPCCinema.CurrentMoment := OPCCinema.Date2 + 1;
      end;
    smStep:
      Skip(1);
  end;
end;

procedure TaOPCCinemaControl.aPauseExecute(Sender: TObject);
begin
  Stop;
end;

procedure TaOPCCinemaControl.aPlayExecute(Sender: TObject);
begin
  Play;
end;

procedure TaOPCCinemaControl.ActionListUpdate(Action: TBasicAction;
  var Handled: Boolean);
begin
  UpdateActions;
end;

procedure TaOPCCinemaControl.aOptionExecute(Sender: TObject);
begin
  with TCinemaPropertyForm.Create(nil) do
  begin
    try
      // чтобы окно настроек находилось поверх панели управления
      if Assigned(Self.Owner) and (Self.Owner is TForm) then
        PopupParent := TForm(Self.Owner);

      if Assigned(FormToPrint) and (FormToPrint.FormStyle = fsStayOnTop) then
        FormStyle := fsStayOnTop;

      edStep.Text := IntToStr(Step);
      edSleepTime.Text := IntToStr(SleepInterval);

      if ShowModal = mrOk then
      begin
        SleepInterval := StrToIntDef(edSleepTime.Text, SleepInterval);
        Step := StrToIntDef(edStep.Text, Step);
      end;
    finally
      Free;
    end;
  end;
end;

procedure TaOPCCinemaControl.UpdateActions;
var
  i: integer;
begin
  if OPCCinema = nil then
  begin
    for i := 0 to ActionList.ActionCount - 1 do
      TAction(ActionList.Actions[i]).Enabled := False;
  end
  else
  begin
    // aOption.Enabled := not OPCCinema.Playing;
    aPause.Enabled := Playing and OPCCinema.Active;
    aStop.Enabled := Playing and OPCCinema.Active;
    aPlay.Enabled := not Playing and OPCCinema.Active;
    aBegin.Enabled := (not Playing) and (not OPCCinema.Bof) and
      OPCCinema.Active;
    aEnd.Enabled := (not Playing) and (not OPCCinema.Eof) and OPCCinema.Active;
    aPred.Enabled := (not Playing) and (not OPCCinema.Bof) and OPCCinema.Active;
    aNext.Enabled := (not Playing) and (not OPCCinema.Eof) and OPCCinema.Active;

    aPrint.Enabled := aPlay.Enabled and Assigned(FormToPrint);
    aSlower.Enabled := Speed > 1;
  end;
end;

procedure TaOPCCinemaControl.aSlowerExecute(Sender: TObject);
begin
  Speed := Speed - 1;
  lSpeed.Caption := IntToStr(Speed) + 'x';
end;

procedure TaOPCCinemaControl.aStopExecute(Sender: TObject);
begin
  Stop;
  OPCCinema.CurrentMoment := OPCCinema.Date1;
end;

procedure TaOPCCinemaControl.TimerTimer(Sender: TObject);
begin
  //
  FInTimer := True;
  try
    if not Skip(1) then
      Playing := False;
  finally
    FInTimer := False;
  end;
end;

procedure TaOPCCinemaControl.TrackBar1Change(Sender: TObject);
begin
  if TrackBar1.Max = TrackBar1.Min then
    exit;
  if FInTrackChange then
    exit;

  FInTrackChange := true;
  try
    if OPCCinema.Active then
    begin
      TrackBar1.OnChange := nil;
      try
        OPCCinema.CurrentMoment := OPCCinema.Date1 +
          (TrackBar1.Position - TrackBar1.Min) *
          (OPCCinema.Date2 - OPCCinema.Date1) / (TrackBar1.Max - TrackBar1.Min);

        Application.ProcessMessages;
      finally
        if not(csDestroying in ComponentState) then
          TrackBar1.OnChange := TrackBar1Change;
      end;
    end;
  finally
    FInTrackChange := False;
  end;
end;

procedure TaOPCCinemaControl.aPrintExecute(Sender: TObject);
begin
  if FormToPrint <> nil then
  begin
    if PrintDialog1.Execute then
      FormToPrint.Print;
  end;
  FormToPrint.Update;
end;

function TaOPCCinemaControl.SelectInterval: Boolean;
var
  aInterval: TOPCInterval;
begin
  aInterval := TOPCInterval.Create;
  try
    aInterval.Kind := ikInterval;
    aInterval.SetInterval(OPCCinema.Date1, OPCCinema.Date2);
    Result := ShowIntervalForm(aInterval, 0, GetParentForm(Self));
    if Result then
    begin
      OPCCinema.Date1 := aInterval.Date1;
      OPCCinema.Date2 := aInterval.Date2;
    end;
  finally
    aInterval.Free;
  end;
end;

procedure TaOPCCinemaControl.SetFormToPrint(const Value: TForm);
begin
  FFormToPrint := Value;
end;

destructor TaOPCCinemaControl.Destroy;
begin
  OPCCinema := nil;
  inherited;
end;

function TaOPCCinemaControl.FillHistory: Boolean;
begin
  Result := False;
  if not OPCCinema.Active then
  begin
    with TFillHistoryProgress.Create(nil) do
    begin
      try
        OPCCinema := Self.OPCCinema;
        ShowModal;
        Result := true;
      finally
        Free;
      end;
    end;
  end;
  UpdateCinemaProperty;
end;

function TaOPCCinemaControl.GetPlaying: Boolean;
begin
  Result := Timer.Enabled;
end;

function TaOPCCinemaControl.GetSleepInterval: integer;
begin
  Result := Timer.Interval;
end;

procedure TaOPCCinemaControl.lCurrentMomentDblClick(Sender: TObject);
begin
  if OPCCinema.Active then
    OPCCinema.CurrentMoment := OPCInputDateTime(OPCCinema.CurrentMoment);
end;

procedure TaOPCCinemaControl.Play;
begin
  Playing := true;
end;

end.
