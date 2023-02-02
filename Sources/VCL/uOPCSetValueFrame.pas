unit uOPCSetValueFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, AppEvnts;

type
  TFrame1 = class(TFrame)
    Label1: TLabel;
    eNewValue: TEdit;
    cbNewValue: TComboBox;
    cbUseDate: TCheckBox;
    dtDate: TDateTimePicker;
    cbTime: TCheckBox;
    tmTime: TDateTimePicker;
    ApplicationEvents1: TApplicationEvents;
    procedure eNewValueChange(Sender: TObject);
    procedure cbNewValueChange(Sender: TObject);
    procedure cbUseDateClick(Sender: TObject);
    procedure cbTimeClick(Sender: TObject);
    procedure ApplicationEvents1Message(var Msg: tagMSG; var Handled: Boolean);
  private
    FLookup: TStrings;
    FRefAutoFill: Boolean;

    procedure SafeSetComboBox(aComboBox: TCheckBox; aValue: Boolean);

    function GetActiveControl: TWinControl;
    procedure SetActiveControl(const Value: TWinControl);

    procedure SetDate(const Value: TDateTime);
    function GetDate: TDateTime;

    function GetValue: string;
    procedure SetValue(const Value: string);

    procedure SetRefAutoFill(const Value: Boolean);
    procedure SetLookup(const Value: TStrings);
  public
    constructor Create(AOwner: TComponent); override;

    procedure UpdateClientAction;

    property Date: TDateTime read GetDate write SetDate;
    property Value: string read GetValue write SetValue;
    property RefAutoFill: Boolean read FRefAutoFill write SetRefAutoFill;
    property Lookup: TStrings read FLookup write SetLookup;

    property ActiveControl: TWinControl read GetActiveControl write SetActiveControl;
  end;

implementation

{$R *.dfm}

procedure TFrame1.ApplicationEvents1Message(var Msg: tagMSG; var Handled: Boolean);
var
  aHandle: Cardinal;
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

procedure TFrame1.cbNewValueChange(Sender: TObject);
var
  sId: string;
begin
  if Assigned(FLookup) then
  begin
    if cbNewValue.ItemIndex >= 0 then
    begin
      sId := FLookup.Names[cbNewValue.ItemIndex];
      eNewValue.Text := sId;
    end;
  end;
end;

procedure TFrame1.cbTimeClick(Sender: TObject);
begin
  UpdateClientAction;
end;

procedure TFrame1.cbUseDateClick(Sender: TObject);
begin
  UpdateClientAction;
end;

constructor TFrame1.Create(AOwner: TComponent);
//var
//  aMoment: TDateTime;
begin
  inherited Create(AOwner);

  Date := Now;

//  aMoment := Now;
//  dtDate.DateTime := Trunc(Now);
//  if Frac(aMoment) <> 0.0 then
//    tmTime.DateTime := Frac(aMoment);
end;

procedure TFrame1.eNewValueChange(Sender: TObject);
var
  aIndex: integer;
begin
  if Assigned(FLookup) then
  begin
    aIndex := FLookup.IndexOfName(eNewValue.Text);
    if aIndex >= 0 then
      cbNewValue.ItemIndex := cbNewValue.Items.IndexOf(FLookup.ValueFromIndex[aIndex]);
  end;
end;

function TFrame1.GetActiveControl: TWinControl;
begin
  if Assigned(Owner) and (Owner is TForm) then
    Result := TForm(Owner).ActiveControl
  else
    Result := nil;
end;

function TFrame1.GetDate: TDateTime;
begin
  if not cbUseDate.Checked then
    Result := 0
  else if cbTime.Checked then
    Result := Trunc(dtDate.DateTime) + Frac(tmTime.DateTime)
  else
    Result := Trunc(dtDate.DateTime);
end;

function TFrame1.GetValue: string;
begin
  if RefAutoFill and Assigned(FLookup) then
    Result := cbNewValue.Text
  else
    Result := eNewValue.Text;
end;

procedure TFrame1.SafeSetComboBox(aComboBox: TCheckBox; aValue: Boolean);
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

procedure TFrame1.SetActiveControl(const Value: TWinControl);
begin
  if Assigned(Owner) and (Owner is TForm) then
  begin
    Value.Visible := true;
    Value.Enabled := true;
    TForm(Owner).ActiveControl := Value;
  end;
end;

procedure TFrame1.SetDate(const Value: TDateTime);
begin
  if Value = 0 then
    cbUseDate.Checked := false
  else
  begin
    cbUseDate.Checked := true;     
    dtDate.Date := Trunc(Value);
    if Frac(Value) <> 0.0 then
    begin
      tmTime.Time := Frac(Value);
      SafeSetComboBox(cbTime, True);
    end
    else
    begin
      SafeSetComboBox(cbTime, False);
    end;
  end;
  UpdateClientAction;
end;

procedure TFrame1.SetLookup(const Value: TStrings);
var
  i: integer;
begin
  FLookup := Value;
  if Assigned(FLookup) then
  begin
    for i := 0 to FLookup.Count - 1 do
      cbNewValue.Items.Add(FLookup.ValueFromIndex[i]);

    ActiveControl := cbNewValue;
  end;
  eNewValueChange(eNewValue);
end;

procedure TFrame1.SetRefAutoFill(const Value: Boolean);
begin
  FRefAutoFill := Value;
  
  if FRefAutoFill then
    //разрешим ввести новый элемент
    cbNewValue.Style := csDropDown
  else
    //запретим вводить новый элемент
    cbNewValue.Style := csDropDownList;

end;

procedure TFrame1.SetValue(const Value: string);
begin
  eNewValue.Text := Value;
end;

procedure TFrame1.UpdateClientAction;
begin
  dtDate.Enabled := cbUseDate.Checked;
  tmTime.Enabled := cbUseDate.Checked and cbTime.Checked;
  cbTime.Enabled := cbUseDate.Checked;
  cbNewValue.Visible := Assigned(FLookup);
end;

end.

