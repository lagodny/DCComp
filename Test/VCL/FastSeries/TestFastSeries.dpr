program TestFastSeries;

uses
  Vcl.Forms,
  uMain in 'uMain.pas' {Form1},
  DC.FastSeries in '..\..\..\Sources\VCL\DC.FastSeries.pas',
  DC.SeriesAdapter in '..\..\..\Sources\VCL\DC.SeriesAdapter.pas',
  DC.SeriesAdapterIntf in '..\..\..\Sources\VCL\DC.SeriesAdapterIntf.pas',
  DC.Chart in '..\..\..\Sources\VCL\DC.Chart.pas',
  DC.LineSeries in '..\..\..\Sources\VCL\DC.LineSeries.pas',
  DC.GantSeries in '..\..\..\Sources\VCL\DC.GantSeries.pas',
  DC.SeriesTypes in '..\..\..\Sources\VCL\DC.SeriesTypes.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
