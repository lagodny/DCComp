unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, LA.Net.Connector, LA.Net.Connector.Http, FMX.Memo.Types, FMX.ScrollBox, FMX.Memo,
  FMX.Controls.Presentation, FMX.StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    LAHttpConnector1: TLAHttpConnector;
    procedure Button1Click(Sender: TObject);
  private
    procedure Log(const aMsg: string);

  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.Button1Click(Sender: TObject);
var
  aConnection: TLAHttpTrackingConnection;
  v: Variant;
begin
//  DCHttpConnector1.Connect;
  aConnection := TLAHttpTrackingConnection.Create(nil);
  try
//    aConnection.Address := 'localhost:89';
    aConnection.Address := 'https://dc.tdc.org.ua:443';
    aConnection.UserName := 'Лагодный';
    aConnection.Password := '314';
//    aConnection.UserName := 'nst';
//    aConnection.Password := '678964';
    aConnection.Connect;
    log('connected');
    v := aConnection.GetClients;
    log(v);
    v := aConnection.GetDevices([]);
    log(v);
    v := aConnection.GetDevicesData([]);
    log(v);
//    log(v.prototypes);
//    log(v.devices);
  finally
    aConnection.Free;
  end;
end;

procedure TForm1.Log(const aMsg: string);
begin
  Memo1.Lines.Add(DateTimeToStr(Now) + ': ' + aMsg);
  Application.ProcessMessages;
end;

end.
