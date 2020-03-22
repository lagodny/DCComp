unit uOPCIntervalFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, DateUtils, IniFiles, Math,
  uOPCInterval, AppEvnts;

type
  TIntervaKindExt = (ikeInterval, ikeShift, ikeDay, ikeMonth);

//  TDateTimePicker = class(ComCtrls.TDateTimePicker)
//  private
//    FKeyPressed: Boolean;
//  protected
//    //procedure WndProc(var Message: TMessage); override;
//
//    procedure Change; override;
//    procedure KeyPress(var Key: Char); override;
//    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
//  end;


  TOPCIntervalFrame = class(TFrame)
    gbInterval: TGroupBox;
    lFrom: TLabel;
    lTo: TLabel;
    dtFrom: TDateTimePicker;
    tmFrom: TDateTimePicker;
    dtTo: TDateTimePicker;
    tmTo: TDateTimePicker;
    rbLastTime: TRadioButton;
    rbInterval: TRadioButton;
    eHours: TEdit;
    cbPeriod: TComboBox;
    cbHourDay: TComboBox;
    rbDay: TRadioButton;
    dtpDay: TDateTimePicker;
    rbMonth: TRadioButton;
    dtpMonth: TDateTimePicker;
    cbTimeFrom: TCheckBox;
    cbTimeTo: TCheckBox;
    ApplicationEvents1: TApplicationEvents;
    procedure eHoursKeyPress(Sender: TObject; var Key: Char);
    procedure cbPeriodChange(Sender: TObject);
    procedure dtFromChange(Sender: TObject);
    procedure rbLastTimeClick(Sender: TObject);
    procedure rbDayClick(Sender: TObject);
    procedure rbMonthClick(Sender: TObject);
    procedure rbIntervalClick(Sender: TObject);
    procedure cbTimeFromClick(Sender: TObject);
    procedure cbTimeToClick(Sender: TObject);
    procedure rbLastTimeMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure rbDayMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure rbMonthMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure rbIntervalMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ApplicationEvents1Message(var Msg: tagMSG; var Handled: Boolean);
    procedure dtpMonthCloseUp(Sender: TObject);
  private
    FEnableTime: Boolean;
    //FKindExt: TIntervaKindExt;
    //FInterval: TOPCInterval;

    function GetDate1: TDateTime;
    function GetDate2: TDateTime;
    procedure SetDate1(const Value: TDateTime);
    procedure SetDate2(const Value: TDateTime);

    procedure SafeSetComboBox(aComboBox: TCheckBox; aValue: Boolean);

    procedure UpdateEnabled;

    function GetKindExt: TIntervaKindExt;
    procedure SetKindExt(const Value: TIntervaKindExt);

    function GetActiveControl: TWinControl;
    procedure SetActiveControl(const Value: TWinControl);
    procedure SetEnableTime(const Value: Boolean);
  public
    constructor Create(AOwner: TComponent); override;

    procedure SetInterval(aInterval: TOPCInterval);
    procedure GetInterval(aInterval: TOPCInterval);

    procedure StoreSettings(aIniFile: TCustomIniFile; aSection: string);
    procedure RestoreSettings(aIniFile: TCustomIniFile; aSection: string);

    property Date1: TDateTime read GetDate1 write SetDate1;
    property Date2: TDateTime read GetDate2 write SetDate2;
    //    property Kind: TOPCIntervalKind read GetKind write SetKind;
    property KindExt: TIntervaKindExt read GetKindExt write SetKindExt;
    property EnableTime: Boolean read FEnableTime write SetEnableTime;

    property ActiveControl: TWinControl read GetActiveControl write SetActiveControl;
  end;

implementation

//uses
//  uDCLang,
//  uDCLocalizer;

{$R *.dfm}

{ TFrame1 }

procedure TOPCIntervalFrame.ApplicationEvents1Message(var Msg: tagMSG;
  var Handled: Boolean);
var
  //mp: TPoint;
  //c: TControl;
  v: Extended;
  vStr: string;
  aFormat: string;
  aDotFounded: boolean;
  aDeltaStr: string;
  aDelta: Extended;
  i: Integer;
  aHandle: Cardinal;
  KeyState: TKeyboardState;
  ShiftState: TShiftState;
  aWParam: integer;
  dir: SmallInt;
begin
  if Msg.message = WM_MOUSEWHEEL then
  begin
    //aHandle := WindowFromPoint(Msg.pt);
    //if aHandle = eHours.Handle then
    if ActiveControl = eHours then
    begin
      vStr := eHours.Text;
      if vStr = '' then
        vStr := '0';
        
      v := StrToFloat(vStr);
      aDeltaStr := '';
      aFormat := '0';
      aDotFounded := false;

      for i := 1 to Length(vStr) - 1 do
        if CharInSet(vStr[i], ['.', ',']) then
        begin
          aDeltaStr := aDeltaStr + vStr[i];
          aFormat := aFormat + '.';
          aDotFounded := true;
        end
        else
        begin
          aDeltaStr := aDeltaStr + '0';
          if aDotFounded or (Length(aFormat) = 0) then
            aFormat := aFormat + '0';
        end;

      aDeltaStr := aDeltaStr + '1';
      if aDotFounded then
        aFormat := aFormat + '0';
      
      aDelta := StrToFloat(aDeltaStr);
      
      GetKeyboardState(KeyState);
      ShiftState := KeyboardStateToShiftState(KeyState);
      if ssShift in ShiftState then
        aDelta := aDelta * 10;

      dir := HiWord(Msg.wParam);
      if dir > 0 then
        V := v + aDelta
      else
      begin
        if SameValue(v, aDelta, 0.0000001) then
        begin
          aDelta := aDelta / 10;
          if (aDelta < 1) and not aDotFounded then
            aFormat := aFormat + '.';

          aFormat := aFormat + '0';
        end;

        v := v - aDelta;
      end;

      if v <= 0 then
        v := aDelta;

      eHours.Text := FormatFloat(aFormat, v);// FloatToStr(v);
      eHours.SelectAll;
//      ActiveControl := eHours;
//      mp := ScreenToClient(Msg.pt); // MousePos);
//      c := ControlAtPos(mp, false, true);
//      if (c <> nil) and (c is TGIS_ViewerWnd) then
//      begin
//        c.Perform(CM_MOUSEWHEEL, Msg.WParam, Msg.LParam);
//        Handled := true;
//      end;
    end
    //else if aHandle = dtpDay.Handle then
    else if ActiveControl is TDateTimePicker then
    begin
      aWParam := Msg.wParam;
      aHandle := TDateTimePicker(ActiveControl).Handle;
      if aWParam > 0 then
        SendMessage(aHandle, WM_KEYDOWN, VK_UP, 0)
      else
        SendMessage(aHandle, WM_KEYDOWN, VK_DOWN, 0);
    end;

  end;
end;

procedure TOPCIntervalFrame.cbPeriodChange(Sender: TObject);
var
  dow: integer;
  d, m, y: word;

begin

  // день недели по нашему : пн-0, вт-1 ... вс-6
  dow := DayOfWeek(Now);
  if dow = 1 then
    dow := 6
  else
    dow := dow - 2;

  case cbPeriod.ItemIndex of
    1: // сегодня
      begin
        Date1 := trunc(Now);
        Date2 := trunc(Now) + 1;
      end;
    2: // вчера
      begin
        Date1 := trunc(Now) - 1;
        Date2 := trunc(Now);
      end;
    3: // с начала недели
      begin
        Date1 := Trunc(Now - dow);
        Date2 := Trunc(Now) + 1;
      end;
    4: // предыдущая неделя
      begin
        Date2 := Trunc(Now - dow);
        Date1 := Trunc(Now - dow) - 7;
      end;
    5: // с начала месяца
      begin
        DecodeDate(Now, y, m, d);
        Date1 := EncodeDate(y, m, 1);
        Date2 := Trunc(Now) + 1;
      end;
    6: // прошлый месяц
      begin
        DecodeDate(Now, y, m, d);
        Date2 := EncodeDate(y, m, 1);

        if m = 1 then
        begin
          y := y - 1;
          m := 12;
        end
        else
          m := m - 1;

        Date1 := EncodeDate(y, m, 1);
      end;
    7: // следующий день
      begin
        Date1 := trunc(Now) + 1;
        Date2 := trunc(Now) + 2;
      end;
    8: // следующая неделя
      begin
        Date1 := Trunc(Now + 7 - dow);
        Date2 := Trunc(Now + 7 - dow) + 7;
      end;
    9: // следующие 12 часов
      begin
        Date1 := Now;
        Date2 := Now + 12 / HoursPerDay;
      end;
    10: // сдедующиe 24 часа
      begin
        Date1 := Now;
        Date2 := Now + 24 / HoursPerDay;
      end;

  end;
  cbPeriod.Text := cbPeriod.Items[cbPeriod.ItemIndex];
end;

procedure TOPCIntervalFrame.cbTimeFromClick(Sender: TObject);
begin
  tmFrom.Enabled := cbTimeFrom.Checked;
  cbPeriod.ItemIndex := 0;
end;

procedure TOPCIntervalFrame.cbTimeToClick(Sender: TObject);
begin
  tmTo.Enabled := cbTimeTo.Checked;
  cbPeriod.ItemIndex := 0;
end;

constructor TOPCIntervalFrame.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

procedure TOPCIntervalFrame.dtFromChange(Sender: TObject);
begin
  cbPeriod.ItemIndex := 0;
end;

procedure TOPCIntervalFrame.dtpMonthCloseUp(Sender: TObject);
begin
  dtpMonth.DateTime := StartOfTheMonth(dtpMonth.DateTime);
end;

procedure TOPCIntervalFrame.eHoursKeyPress(Sender: TObject; var Key: Char);
begin
  if (Key = '.') or (Key = ',') then
  begin
    if pos(FormatSettings.DecimalSeparator, (Sender as TEdit).Text) = 0 then
      Key := FormatSettings.DecimalSeparator
    else
    begin
      Key := #0;
      beep;
      exit;
    end
  end;

  if not (
    (Key = FormatSettings.DecimalSeparator) or
    (Key = Char(VK_BACK)) or
    (Key = Char(VK_DELETE)) or
    (CharInSet(Key, ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']))
    ) then
  begin
    Key := #0;
    beep;
  end

end;

function TOPCIntervalFrame.GetActiveControl: TWinControl;
begin
  if Assigned(Owner) and (Owner is TForm) then
    Result := TForm(Owner).ActiveControl
  else
    Result := nil;
end;

function TOPCIntervalFrame.GetDate1: TDateTime;
var
  d, m, y: Word;
begin
  Result := 0;
  case KindExt of
    ikeInterval:
    begin
      if cbTimeFrom.Checked then
        Result := Trunc(dtFrom.DateTime) + Frac(tmFrom.DateTime)
      else
        Result := Trunc(dtFrom.DateTime);
    end;
    ikeShift:
      Result := Now - StrToFloat(eHours.Text);
    ikeDay:
      Result := Trunc(dtpDay.DateTime);
    ikeMonth:
    begin
      DecodeDate(dtpMonth.DateTime, y, m, d);
      Result := EncodeDate(y, m, 1);
    end;
    else
      Assert(False, 'unknown KindExt');
  end;
end;

function TOPCIntervalFrame.GetDate2: TDateTime;
var
  d, m, y: Word;
begin
  Result := 0;
  case KindExt of
    ikeInterval:
    begin
      if cbTimeTo.Checked then
        Result := Trunc(dtTo.DateTime) + Frac(tmTo.DateTime)
      else
        Result := Trunc(dtTo.DateTime) + 1;
    end;
    ikeShift:
      Result := Now;
    ikeDay:
      Result := Trunc(dtpDay.DateTime) + 1;
    ikeMonth:
    begin
      DecodeDate(dtpMonth.DateTime, y, m, d);
      if m = 12 then
        Result := EncodeDate(y + 1, 1, 1)
      else
        Result := EncodeDate(y, m + 1, 1)
    end;
    else
      Assert(False, 'unknown KindExt');

  end;
end;

procedure TOPCIntervalFrame.GetInterval(aInterval: TOPCInterval);
begin
  if KindExt = ikeShift then
    aInterval.Kind := ikShift
  else
    aInterval.Kind := ikInterval;

  aInterval.TimeShiftUnit := TOPCIntervalTimeShiftUnit(cbHourDay.ItemIndex);

  case KindExt of
    ikeInterval:
      begin
        aInterval.SetInterval(Date1, Date2);
        aInterval.ShiftKind := TShiftKind(cbPeriod.ItemIndex);
      end;
    ikeDay, ikeMonth:
      begin
        aInterval.SetInterval(Date1, Date2);
        aInterval.ShiftKind := skNone;
      end;
    ikeShift:
      if eHours.Text <> '' then
      begin
        if cbHourDay.ItemIndex = 0 then
          aInterval.TimeShift := StrToFloat(eHours.Text) / 24   // часы
        else
          aInterval.TimeShift := StrToFloat(eHours.Text);       // дни
      end;
  end;
end;

function TOPCIntervalFrame.GetKindExt: TIntervaKindExt;
begin
  if rbLastTime.Checked then
    Result := ikeShift
  else if rbDay.Checked then
    Result := ikeDay
  else if rbMonth.Checked then
    Result := ikeMonth
  else
    Result := ikeInterval;
end;

//procedure TOPCIntervalFrame.Localize;
//begin
//  rbLastTime.Caption := TDCLocalizer.GetStringRes(idxIntervalFrame_ForLast);
//  rbDay.Caption := TDCLocalizer.GetStringRes(idxIntervalFrame_ForDay);
//  rbMonth.Caption := TDCLocalizer.GetStringRes(idxIntervalFrame_ForMonth);
//  rbInterval.Caption := TDCLocalizer.GetStringRes(idxIntervalFrame_ForPeriod);
//
//  lFrom.Caption := TDCLocalizer.GetStringRes(idxIntervalFrame_Date1From);
//  lTo.Caption := TDCLocalizer.GetStringRes(idxIntervalFrame_Date2To);
//
//  gbInterval.Caption := TDCLocalizer.GetStringRes(idxIntervalFrame_gbInterval);
//
//end;

procedure TOPCIntervalFrame.rbDayClick(Sender: TObject);
begin
  KindExt := ikeDay;
  //ActiveControl := dtpDay;
end;

procedure TOPCIntervalFrame.rbDayMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  ActiveControl := dtpDay;
end;

procedure TOPCIntervalFrame.rbIntervalClick(Sender: TObject);
begin
  KindExt := ikeInterval;
  //ActiveControl := cbPeriod;
end;

procedure TOPCIntervalFrame.rbIntervalMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ActiveControl := cbPeriod;
end;

procedure TOPCIntervalFrame.rbLastTimeClick(Sender: TObject);
begin
  KindExt := ikeShift;
  //ActiveControl := eHours;
end;

procedure TOPCIntervalFrame.rbLastTimeMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ActiveControl := eHours;
end;

procedure TOPCIntervalFrame.rbMonthClick(Sender: TObject);
begin
  KindExt := ikeMonth;
  //ActiveControl := dtpMonth;
end;

procedure TOPCIntervalFrame.rbMonthMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ActiveControl := dtpMonth;
end;

procedure TOPCIntervalFrame.RestoreSettings(aIniFile: TCustomIniFile;
  aSection: string);
var
  aInterval: TOPCInterval;
begin
  aInterval := TOPCInterval.Create;
  try
    aInterval.Load(aIniFile, aSection);
    SetInterval(aInterval);
  finally
    aInterval.Free;
  end;
end;

procedure TOPCIntervalFrame.SafeSetComboBox(aComboBox: TCheckBox; aValue: Boolean);
var
  aSaveEvent: TNotifyEvent;
begin
  aSaveEvent := aComboBox.OnClick;
  try
    aComboBox.OnClick := nil;
    aComboBox.Checked := aValue;
  finally
    aComboBox.OnClick := aSaveEvent;
  end;
end;

procedure TOPCIntervalFrame.SetActiveControl(const Value: TWinControl);
begin
  //Exit;
  if Assigned(Owner) and (Owner is TForm) then
  begin
    Value.Visible := true;
    Value.Enabled := true;
    TForm(Owner).ActiveControl := Value;
  end;
end;

procedure TOPCIntervalFrame.SetDate1(const Value: TDateTime);
begin
  dtFrom.Date := Trunc(Value);
  if Frac(Value) <> 0.0 then
  begin
    tmFrom.Time := Frac(Value);
    SafeSetComboBox(cbTimeFrom, True);
  end
  else
  begin
    SafeSetComboBox(cbTimeFrom, False);
  end;
  UpdateEnabled;
end;

procedure TOPCIntervalFrame.SetDate2(const Value: TDateTime);
begin
  dtTo.Date := Trunc(Value);
  if Frac(Value) <> 0.0 then
  begin
    tmTo.Time := Frac(Value);
    SafeSetComboBox(cbTimeTo, True);
  end
  else
  begin
    dtTo.Date := dtTo.Date - 1;
    SafeSetComboBox(cbTimeTo, False);
  end;
  UpdateEnabled;
end;

procedure TOPCIntervalFrame.SetEnableTime(const Value: Boolean);
begin
  FEnableTime := Value;

  cbTimeFrom.Visible := FEnableTime;
  cbTimeTo.Visible := FEnableTime;
  tmFrom.Visible := FEnableTime;
  tmTo.Visible := FEnableTime;

  if not FEnableTime then
  begin
    cbHourDay.ItemIndex := Ord(TOPCIntervalTimeShiftUnit.tsuDay);
    cbHourDay.Enabled := False;
  end;

end;

procedure TOPCIntervalFrame.SetInterval(aInterval: TOPCInterval);
var
  d1, m1, y1: Word;
  d2, m2, y2: Word;

  procedure InitCombos;
  var
    i: TShiftKind;
    indexHD: TOPCIntervalTimeShiftUnit;
  begin
    cbPeriod.Clear;
    for i := Low(TShiftKind) to High(TShiftKind) do
      cbPeriod.AddItem(TOPCInterval.ShiftKindToStr(i), nil);

    cbHourDay.Clear;
    for indexHD := Low(TOPCIntervalTimeShiftUnit) to High(TOPCIntervalTimeShiftUnit) do
      cbHourDay.AddItem(TOPCInterval.ShiftUnitToStr(indexHD), nil);

  end;
begin
  InitCombos;

  Date1 := aInterval.Date1;
  Date2 := aInterval.Date2;
  if aInterval.Kind = ikInterval then
    cbPeriod.ItemIndex := Ord(aInterval.ShiftKind)
  else
    cbPeriod.ItemIndex := Ord(skNone);
    
  cbHourDay.ItemIndex := Ord(aInterval.TimeShiftUnit);
  dtpDay.DateTime := aInterval.Date1;
  dtpMonth.DateTime := StartOfTheMonth(aInterval.Date1);

  if aInterval.TimeShiftUnit = tsuHour then
    eHours.Text := FormatFloat('0.##', aInterval.TimeShift * 24)
  else
    eHours.Text := FormatFloat('0.##', aInterval.TimeShift);

  if aInterval.Kind = ikInterval then
  begin
    if aInterval.ShiftKind <> skNone then
      KindExt := ikeInterval
    else if (aInterval.Date1 = aInterval.Date2 - 1) and (Frac(aInterval.Date1) = 0) then
      KindExt := ikeDay
    else if (Frac(aInterval.Date1) = 0) and (Frac(aInterval.Date2) = 0) then
    begin
      DecodeDate(aInterval.Date1, y1, m1, d1);
      DecodeDate(aInterval.Date2, y2, m2, d2);
      if (d1 = 1) and (d2 = 1) and (
        ((y1 = y2) and (m1 + 1 = m2)) or
        ((y1 + 1 = y2) and (m1 = 12) and (m2 = 1))
        ) then
        KindExt := ikeMonth
      else
        KindExt := ikeInterval;
    end
    else
      KindExt := ikeInterval;
  end
  else
    KindExt := ikeShift;

  EnableTime := aInterval.EnableTime;

end;

procedure TOPCIntervalFrame.SetKindExt(const Value: TIntervaKindExt);
begin
  case Value of
    ikeInterval:
      rbInterval.Checked := True;
    ikeShift:
      rbLastTime.Checked := True;
    ikeDay:
      rbDay.Checked := True;
    ikeMonth:
      rbMonth.Checked := True;
  end;
  
  UpdateEnabled;
end;

procedure TOPCIntervalFrame.StoreSettings(aIniFile: TCustomIniFile;
  aSection: string);
var
  aInterval: TOPCInterval;
begin
  aInterval := TOPCInterval.Create;
  try
    GetInterval(aInterval);
    aInterval.Save(aIniFile, aSection);
  finally
    aInterval.Free;
  end;
end;

procedure TOPCIntervalFrame.UpdateEnabled;
var
  i: Integer;
begin
  case KindExt of
    ikeShift:
      begin
        eHours.Enabled := true;
        cbHourDay.Enabled := true;

        dtpDay.Enabled := false;
        dtpMonth.Enabled := false;
        cbPeriod.Enabled := false;

        gbInterval.Enabled := false;
      end;
    ikeInterval, ikeDay, ikeMonth:
      begin
        eHours.Enabled := false;
        cbHourDay.Enabled := false;

        dtpDay.Enabled := KindExt = ikeDay;
        dtpMonth.Enabled := KindExt = ikeMonth;

        cbPeriod.Enabled := KindExt = ikeInterval;
        gbInterval.Enabled := KindExt = ikeInterval;
      end;
  end;

  for i := 0 to gbInterval.ControlCount - 1 do
    gbInterval.Controls[i].Enabled := gbInterval.Enabled;

  tmFrom.Enabled := gbInterval.Enabled and cbTimeFrom.Checked;
  tmTo.Enabled := gbInterval.Enabled and cbTimeTo.Checked;
end;

{ TDateTimePicker }
{
procedure TDateTimePicker.Change;
var
  m: TMessage;
begin
  inherited Change;

  if FKeyPressed then
  begin
    SendMessage(Handle, 256, VK_RIGHT, 0);
    FKeyPressed := False;
  end;
end;

procedure TDateTimePicker.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if Key in [VK_LEFT, VK_RIGHT, VK_UP, VK_DOWN] then
    FKeyPressed := False;

  inherited KeyDown(Key, Shift);
end;

procedure TDateTimePicker.KeyPress(var Key: Char);
begin
  FKeyPressed := Key in ['0'..'9'];

  inherited KeyPress(Key);
end;
}

end.

