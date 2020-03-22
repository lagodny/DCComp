unit uChoiceIntervalExt;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls,
  Registry, IniFiles,
  StrUtils,
  uOPCInterval;

type

  TChoiceIntervalExt = class(TForm)
    gbInterval: TGroupBox;
    dtFrom: TDateTimePicker;
    Label1: TLabel;
    tmFrom: TDateTimePicker;
    Label2: TLabel;
    dtTo: TDateTimePicker;
    tmTo: TDateTimePicker;
    bOk: TButton;
    bCancel: TButton;
    rbLastTime: TRadioButton;
    rbInterval: TRadioButton;
    eHours: TEdit;
    Label3: TLabel;
    cbPeriod: TComboBox;
    procedure FormShow(Sender: TObject);
    procedure rbLastTimeKeyPress(Sender: TObject; var Key: Char);
    procedure rbIntervalClick(Sender: TObject);
    procedure eHoursKeyPress(Sender: TObject; var Key: Char);
    procedure cbPeriodChange(Sender: TObject);
    procedure tmFromChange(Sender: TObject);
  private
    procedure ChangeKind;
    function GetKind: TOPCIntervalKind;
    procedure SetKind(const Value: TOPCIntervalKind);
    function GetDate1: TDateTime;
    function GetDate2: TDateTime;
    procedure SetDate1(const Value: TDateTime);
    procedure SetDate2(const Value: TDateTime);

    procedure UpdateEnabled;
  public
    procedure SetInterval(aInterval:TOPCInterval);
    procedure GetInterval(aInterval:TOPCInterval);
    
    property Date1:TDateTime read GetDate1 write SetDate1;
    property Date2:TDateTime read GetDate2 write SetDate2;
    property Kind :TOPCIntervalKind read GetKind write SetKind;

  end;

  function ShowIntervalForm(aInterval: TOPCInterval): boolean;



implementation

//var
//  ChoiceIntervalExt: TChoiceIntervalExt;

function ShowIntervalForm(aInterval: TOPCInterval): boolean;
begin
  with TChoiceIntervalExt.Create(nil) do
  begin
    try
      SetInterval(aInterval);
      if ShowModal = mrOk then
      begin
        GetInterval(aInterval);
        Result := true;
      end
      else
        Result := false;
    finally
      Free;
    end;
  end;
end;



{$R *.dfm}

{ TCinemaPropertyForm }

procedure TChoiceIntervalExt.cbPeriodChange(Sender: TObject);
var
  dow: integer;
  d,m,y: word;
begin
  // день недели по нашему : пн-0, вт-1 ... вс-6
  dow := DayOfWeek(Now);
  if dow = 1 then
    dow := 6
  else
    dow := dow - 2;

  case cbPeriod.ItemIndex of
    1: // сегодн€
    begin
      Date1 := trunc(Now);
      Date2 := trunc(Now)+1;
    end;
    2: // вчера
    begin
      Date1 := trunc(Now)-1;
      Date2 := trunc(Now);
    end;
    3: // с начала недели
    begin
      Date1 := Trunc(Now - dow);
      Date2 := Trunc(Now)+1;
    end;
    4: // предыдуща€ недел€
    begin
      Date2 := Trunc(Now - dow);
      Date1 := Trunc(Now - dow) - 7;
    end;
    5: // с начала мес€ца
    begin
      DecodeDate(Now, y, m,d);
      Date1 := EncodeDate(y,m,1);
      Date2 := Trunc(Now)+1;
    end;
    6: // прошлый мес€ц
    begin
      DecodeDate(Now, y, m,d);
      Date2 := EncodeDate(y,m,1);

      if m = 1 then
      begin
        y := y - 1;
        m := 12;
      end
      else
        m := m - 1;

      Date1 := EncodeDate(y,m,1);
    end;
  end;
end;

procedure TChoiceIntervalExt.ChangeKind;
begin
  if rbInterval.Checked then
    Kind := ikInterval
  else
    Kind := ikShift;
  UpdateEnabled;
end;

procedure TChoiceIntervalExt.eHoursKeyPress(Sender: TObject; var Key: Char);
begin

  if (Key = '.') or (Key = ',') then
  begin
    if pos(FormatSettings.DecimalSeparator,(Sender as TEdit).Text) = 0 then
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
    CharInSet(Key, ['0','1','2','3','4','5','6','7','8','9'])
    ) then
    begin
      Key := #0;
      beep;
    end
end;

procedure TChoiceIntervalExt.FormShow(Sender: TObject);
begin
  ChangeKind;
  UpdateEnabled;
end;

function TChoiceIntervalExt.GetDate1: TDateTime;
begin
  if tmFrom.Checked then
    Result := Trunc(dtFrom.DateTime) + Frac(tmFrom.DateTime)
  else
    Result := Trunc(dtFrom.DateTime);
end;

function TChoiceIntervalExt.GetDate2: TDateTime;
begin
  if tmTo.Checked then
    Result := Trunc(dtTo.DateTime) + Frac(tmTo.DateTime)
  else
    Result := Trunc(dtTo.DateTime) + 1;
end;

procedure TChoiceIntervalExt.GetInterval(aInterval: TOPCInterval);
begin
  aInterval.Kind := Kind;

  case aInterval.Kind of
    ikInterval:
    begin
      aInterval.SetInterval(Date1, Date2);
      aInterval.ShiftKind := TShiftKind(cbPeriod.ItemIndex);
    end;
    ikShift:
      if eHours.Text<>'' then
        aInterval.TimeShift := StrToFloat(eHours.Text)/24;
  end;

end;

function TChoiceIntervalExt.GetKind: TOPCIntervalKind;
begin
  if rbInterval.Checked then
    Result := ikInterval // интервал
  else
    Result := ikShift;// последние часы
end;

procedure TChoiceIntervalExt.rbIntervalClick(Sender: TObject);
begin
  ChangeKind;
  if rbInterval.Checked then
    ActiveControl := cbPeriod
  else
    ActiveControl := eHours;
end;

procedure TChoiceIntervalExt.rbLastTimeKeyPress(Sender: TObject; var Key: Char);
begin
  ChangeKind;
end;

procedure TChoiceIntervalExt.SetDate1(const Value: TDateTime);
begin
  dtFrom.Date := Trunc(Value);
  tmFrom.Time := Frac(Value);
end;

procedure TChoiceIntervalExt.SetDate2(const Value: TDateTime);
begin
  dtTo.Date := Trunc(Value);
  tmTo.Time := Frac(Value);
  if Frac(Value) = 0 then
    dtTo.Date := dtTo.Date - 1;

end;

procedure TChoiceIntervalExt.SetInterval(aInterval: TOPCInterval);
begin
  Kind  := aInterval.Kind;
  Date1 := aInterval.Date1;
  Date2 := aInterval.Date2;
  cbPeriod.ItemIndex := Ord(aInterval.ShiftKind);
  eHours.Text := FormatFloat('0.##',aInterval.TimeShift*24);
end;

procedure TChoiceIntervalExt.SetKind(const Value: TOPCIntervalKind);
begin
  case Value of
    ikInterval: rbInterval.Checked := true;
    ikShift   : rbLastTime.Checked := true;
  end;
end;

procedure TChoiceIntervalExt.tmFromChange(Sender: TObject);
begin
  cbPeriod.ItemIndex := 0;
end;

procedure TChoiceIntervalExt.UpdateEnabled;
var
  i: Integer;
begin
  case Kind of
    ikInterval:
    begin
      eHours.Enabled     := false;
      gbInterval.Enabled := true;
      cbPeriod.Enabled := true;
    end;
    ikShift:
    begin
      eHours.Enabled     := true;
      gbInterval.Enabled := false;
      cbPeriod.Enabled := false;
    end;
  end;
  for i := 0 to gbInterval.ControlCount - 1 do
    gbInterval.Controls[i].Enabled := gbInterval.Enabled;
end;



end.
