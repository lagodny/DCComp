unit uDateTimeInput;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, AppEvnts;

type
  TDateTimeInputForm = class(TForm)
    bOk: TButton;
    bCancel: TButton;
    lCaption: TLabel;
    dtDate: TDateTimePicker;
    chTime: TCheckBox;
    tmTime: TDateTimePicker;
    chNow: TCheckBox;
    Bevel1: TBevel;
    ApplicationEvents1: TApplicationEvents;
    procedure chTimeClick(Sender: TObject);
    procedure chNowClick(Sender: TObject);
    procedure ApplicationEvents1Message(var Msg: tagMSG; var Handled: Boolean);
  private
    procedure SafeSetComboBox(aComboBox: TCheckBox; aValue: Boolean);
    procedure UpdateEnabled;

    function GetDateTime: TDateTime;
    procedure SetDateTime(const Value: TDateTime);
    { Private declarations }
  public
    property DateTime: TDateTime read GetDateTime write SetDateTime;
  end;

  //var
  //  fDateTimeInput: TfDateTimeInput;

function OPCInputDateTime(aDateTime: TDateTime; aCaption: string = ''): TDateTime;
function InputDateTime(var aDateTime: TDateTime; aCaption: string = ''): Boolean;

implementation

uses
  Math;

{$R *.dfm}

function OPCInputDateTime(aDateTime: TDateTime; aCaption: string = ''): TDateTime;
var
  DTI_Form: TDateTimeInputForm;
begin
  DTI_Form := TDateTimeInputForm.Create(nil);
  try
    if aCaption <> '' then
      DTI_Form.lCaption.Caption := aCaption;

    DTI_Form.DateTime := aDateTime;

    if DTI_Form.ShowModal = mrOk then
      Result := DTI_Form.DateTime
    else
      Result := aDateTime;
  finally
    FreeAndNil(DTI_Form);
  end;
end;

function InputDateTime(var aDateTime: TDateTime; aCaption: string = ''): Boolean;
var
  DTI_Form: TDateTimeInputForm;
begin
  DTI_Form := TDateTimeInputForm.Create(nil);
  try
    if aCaption <> '' then
      DTI_Form.lCaption.Caption := aCaption;

    DTI_Form.DateTime := aDateTime;
    Result := DTI_Form.ShowModal = mrOk;
    if Result then
      aDateTime := DTI_Form.DateTime;
  finally
    FreeAndNil(DTI_Form);
  end;
end;

{ TfDateTimeInput }

procedure TDateTimeInputForm.ApplicationEvents1Message(var Msg: tagMSG; var Handled: Boolean);
var
  //mp: TPoint;
  //c: TControl;
  //v: Extended;
  //vStr: string;
  //aFormat: string;
  //aDotFounded: boolean;
  //aDeltaStr: string;
  //aDelta: Extended;
  //i: Integer;
  aHandle: Cardinal;
  //KeyState: TKeyboardState;
  //ShiftState: TShiftState;
begin
  if Msg.message = WM_MOUSEWHEEL then
  begin
    if ActiveControl is TDateTimePicker then
    begin
      aHandle := TDateTimePicker(ActiveControl).Handle;
      if Msg.wParam > 0 then
        SendMessage(aHandle, WM_KEYDOWN, VK_UP, 0)
      else
        SendMessage(aHandle, WM_KEYDOWN, VK_DOWN, 0);
    end;

  end;
end;

procedure TDateTimeInputForm.chNowClick(Sender: TObject);
begin
  UpdateEnabled;
end;

procedure TDateTimeInputForm.chTimeClick(Sender: TObject);
begin
  UpdateEnabled;
end;

function TDateTimeInputForm.GetDateTime: TDateTime;
begin
  if chNow.Checked then
    Result := Now
  else
  begin
    Result := Trunc(dtDate.DateTime);
    if chTime.Checked then
      Result := Result + Frac(tmTime.DateTime);
  end;
end;

procedure TDateTimeInputForm.SafeSetComboBox(aComboBox: TCheckBox; aValue: Boolean);
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

procedure TDateTimeInputForm.SetDateTime(const Value: TDateTime);
begin
  dtDate.Date := Trunc(Value);
  if Frac(Value) <> 0.0 then
  begin
    tmTime.Time := Frac(Value);
    SafeSetComboBox(chTime, True);
  end
  else
  begin
    SafeSetComboBox(chTime, False);
  end;
  UpdateEnabled;
end;

procedure TDateTimeInputForm.UpdateEnabled;
begin
  dtDate.Enabled := not chNow.Checked;
  chTime.Enabled := not chNow.Checked;
  tmTime.Enabled := not chNow.Checked and chTime.Checked;
end;

end.

