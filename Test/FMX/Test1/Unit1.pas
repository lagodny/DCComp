unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  aCustomOPCSource, aOPCSource, aCustomOPCTCPSource, aOPCTCPSource_V30,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.DCDataObject, FMX.DCText, FMX.DCLabel;

type
  TForm1 = class(TForm)
    aOPCTCPSource_V301: TaOPCTCPSource_V30;
    aOPCLabel1: TaOPCLabel;
    CheckBox1: TCheckBox;
    Button1: TButton;
    procedure CheckBox1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.Button1Click(Sender: TObject);
begin
  aOPCTCPSource_V301.Connected := True;
end;

procedure TForm1.CheckBox1Change(Sender: TObject);
begin
  aOPCTCPSource_V301.Active := CheckBox1.IsChecked;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
//  {$IFDEF ANDROID}
//  aOPCTCPSource_V301.RemoteMachine := 'tdc.org.ua';
//  aOPCTCPSource_V301.Port := 5152;
//  {$ENDIF}
end;

end.
