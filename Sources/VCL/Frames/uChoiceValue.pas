unit uChoiceValue;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ComCtrls;

type
  TChoiceValue = class(TForm)
    bbOK: TBitBtn;
    bbCancel: TBitBtn;
    Edit: TEdit;
    Label1: TLabel;
    ComboBox: TComboBox;
    cbUseDate: TCheckBox;
    dt: TDateTimePicker;
    tm: TDateTimePicker;
    cbTime: TCheckBox;
    procedure FormShow(Sender: TObject);
    procedure EditChange(Sender: TObject);
    procedure ComboBoxChange(Sender: TObject);
    procedure cbUseDateClick(Sender: TObject);
    procedure cbTimeClick(Sender: TObject);
  private
    function GetTimeStamp: TDateTime;
    procedure SetTimeStamp(const Value: TDateTime);
    { Private declarations }
  public
    sl:TStringList;
    property TimeStamp:TDateTime read GetTimeStamp write SetTimeStamp;
  end;

var
  ChoiceValue: TChoiceValue;

implementation

{$R *.dfm}

procedure TChoiceValue.FormShow(Sender: TObject);
var
  I: Integer;
begin
  if sl<>nil then
  begin
    for I := 0 to sl.Count - 1 do
      ComboBox.Items.Add(sl.ValueFromIndex[i]);
    EditChange(Sender);
  end;
  ComboBox.Visible := Assigned(sl);
  TimeStamp := Now;
end;

function TChoiceValue.GetTimeStamp: TDateTime;
begin
  if cbTime.Checked then
    Result := Trunc(dt.DateTime) + Frac(tm.DateTime)
  else
    Result := Trunc(dt.DateTime);
end;

procedure TChoiceValue.SetTimeStamp(const Value: TDateTime);
begin
  dt.Date := Trunc(Value);
  if Frac(Value) <> 0 then
  begin
    tm.Time := Frac(Value);
    cbTime.Checked := Frac(Value) <> 0;
  end;
end;

procedure TChoiceValue.EditChange(Sender: TObject);
var
  sName:string;
  aIndex : integer;
begin
  if sl<>nil then
  begin
    aIndex := sl.IndexOfName(Edit.Text);
    if aIndex >= 0 then
      ComboBox.ItemIndex := ComboBox.Items.IndexOf(sl.ValueFromIndex[aIndex]);
  end;
end;

procedure TChoiceValue.cbTimeClick(Sender: TObject);
begin
  tm.Enabled := cbTime.Checked and cbUseDate.Checked;
end;

procedure TChoiceValue.cbUseDateClick(Sender: TObject);
begin
  dt.Enabled := cbUseDate.Checked;
  tm.Enabled := cbUseDate.Checked;
end;

procedure TChoiceValue.ComboBoxChange(Sender: TObject);
var
  sId:string;
begin
  if sl<>nil then
  begin
    if ComboBox.ItemIndex>=0 then
    begin
      sId:=sl.Names[ComboBox.ItemIndex];
      Edit.Text:=sId;
    end;
  end;
end;

end.
