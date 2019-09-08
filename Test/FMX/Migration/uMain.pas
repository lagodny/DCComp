unit uMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, System.Math.Vectors, FMX.Controls.Presentation, FMX.StdCtrls,
  FMX.Controls3D, FMX.Layers3D, FMX.ScrollBox, FMX.Memo;

type
  TForm2 = class(TForm)
    BufferLayer3D1: TBufferLayer3D;
    Button1: TButton;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    procedure Test1;
  end;

var
  Form2: TForm2;

implementation

{$R *.fmx}

procedure TForm2.Button1Click(Sender: TObject);
begin
  Test1;
end;

procedure TForm2.Test1;
var
  r: RawByteString;
begin
  r := '123';
  Memo1.Lines.Add(r);
end;

end.
