unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, VclTee.TeeGDIPlus, aCustomOPCSource, aOPCSource, aCustomOPCTCPSource, aOPCTCPSource_V30,
  VCLTee.TeEngine, Vcl.ExtCtrls, VCLTee.TeeProcs, VCLTee.Chart, aOPCChart, uOPCFrame, uChartFrame;

type
  TForm3 = class(TForm)
    aOPCTCPSource_V301: TaOPCTCPSource_V30;
    ChartFrame1: TChartFrame;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form3: TForm3;

implementation

uses
  uDCObjects,
  aOPCLineSeries,
  uDCSensors;

{$R *.dfm}

procedure TForm3.FormCreate(Sender: TObject);
var
  aSeries: TaOPCLineSeries;
  aSensor: Tsensor;
begin
  aSensor := TSensor.Create;
  try
    aSensor.ID := 3;
    aSeries := ChartFrame1.AddSerieByParam('3', [soIncrease, soDecrease], aOPCTCPSource_V301, 'Количество подключений', clRed, False, '');
    //(aSensor, True);
    //aSeries.OPCSource := aOPCTCPSource_V301;
    //aSeries.LinePen.Width := 1;
    aSeries.DisplayFormat := '# ##0';

    aOPCTCPSource_V301.Active := True;

    ChartFrame1.Chart.RealTime := True;
    ChartFrame1.aEditor.Visible := True;
  finally
    aSensor.Free;
  end;
end;

end.
