unit ChoiceProduct;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls;

type
  TChoiceProductForm = class(TForm)
    ListBox1: TListBox;
    Button1: TButton;
    Button2: TButton;
    rbNow: TRadioButton;
    rbDate: TRadioButton;
    dtpDate: TDateTimePicker;
    dtpTime: TDateTimePicker;
    Bevel1: TBevel;
    procedure ListBox1DblClick(Sender: TObject);
    procedure rbDateClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ChoiceProductForm: TChoiceProductForm;

implementation

{$R *.dfm}

procedure TChoiceProductForm.ListBox1DblClick(Sender: TObject);
begin
  ModalResult:=mrOk;
end;

procedure TChoiceProductForm.rbDateClick(Sender: TObject);
begin
  dtpDate.Enabled:=rbDate.Checked;
  dtpTime.Enabled:=rbDate.Checked;
end;

procedure TChoiceProductForm.FormCreate(Sender: TObject);
begin
  dtpDate.DateTime:=Trunc(Now);
  dtpTime.DateTime:=Frac(Now);
end;

end.
