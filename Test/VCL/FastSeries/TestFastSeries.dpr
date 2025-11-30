program TestFastSeries;

uses
  Vcl.Forms,
  uMain in 'uMain.pas' {Form1},
  aOPCFastSeries in '..\..\..\Sources\VCL\aOPCFastSeries.pas',
  uOPCSeriesAdapter in '..\..\..\Sources\Common\uOPCSeriesAdapter.pas',
  uOPCSeriesAdapterIntf in '..\..\..\Sources\VCL\uOPCSeriesAdapterIntf.pas',
  DC.Chart in '..\..\..\Sources\VCL\DC.Chart.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
