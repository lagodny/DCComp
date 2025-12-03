unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  uOPCInterval,
  //aOPCLineSeries,
  DC.FastSeries, DC.LineSeries, DC.GantSeries, DC.Chart,
  //uOPCGanttSeries,
  DC.SeriesAdapter, DC.SeriesAdapterIntf,
  VCLTee.Series,
  VclTee.TeeGDIPlus, aCustomOPCSource, aOPCSource, aCustomOPCTCPSource, aOPCTCPSource_V30,
  Vcl.StdCtrls, Vcl.ExtCtrls, VCLTee.TeEngine, VCLTee.TeeProcs, VCLTee.Chart, aOPCChart, VCLTee.TeeShape;

type
  TForm1 = class(TForm)
    Chart: TDCChart;
    Panel1: TPanel;
    bAdd: TButton;
    aOPCTCPSource_V301: TaOPCTCPSource_V30;
    bClear: TButton;
    bInterval: TButton;
    chDrawAll: TCheckBox;
    cbDrawAllStyle: TComboBox;
    cbDrawStyle: TComboBox;
    Apply: TButton;
    Label1: TLabel;
    bAddLine: TButton;
    bCalcTime: TButton;
    bAddGant: TButton;
    procedure bAddClick(Sender: TObject);
    procedure bClearClick(Sender: TObject);
    procedure bIntervalClick(Sender: TObject);
    procedure DoIntervalChanged(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ApplyClick(Sender: TObject);
    procedure bAddLineClick(Sender: TObject);
    procedure bCalcTimeClick(Sender: TObject);
    procedure bAddGantClick(Sender: TObject);
  private
//    FDAPStyle       : TDrawAllPointsStyle;
//    FDrawAll        : Boolean;
//    FDrawStyle      : TFastLineDrawStyle;
    procedure AddSerie(aDAPStyle: TDrawAllPointsStyle; aDrawAll: Boolean; aDrawStyle: TFastLineDrawStyle);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses
  System.Diagnostics,
  uOPCIntervalForm;


{$R *.dfm}

procedure TForm1.AddSerie(aDAPStyle: TDrawAllPointsStyle; aDrawAll: Boolean; aDrawStyle: TFastLineDrawStyle);
var
  f: TDCFastLineSeries;
  a: TDCSeriesAdapter;
  aIntf: IDCSeriesAdapter;
begin
  f := TDCFastLineSeries.Create(Chart);

  f.DrawAllPoints := aDrawAll;
  f.DrawAllPointsStyle := aDAPStyle;
  f.DrawStyle := aDrawStyle;

  f.FastPen := True;
  f.IgnoreNulls := True;
  f.Stairs := False;

  if not Supports(f, IDCSeriesAdapter, aIntf) then
  begin
    f.Free;
    Exit;
  end;

  a := aIntf.DCAdapter;

  a.PhysID := '4';
  a.OPCSource := aOPCTCPSource_V301;
  Chart.AddSeries(a.Series);
  a.FillSerie(Chart.Interval.Kind = ikShift)

end;

procedure TForm1.ApplyClick(Sender: TObject);
var
  f: TDCFastLineSeries;
begin
  if Chart.SeriesList.Count < 1 then
    Exit;

  f := Chart.Series[0] as TDCFastLineSeries;

  f.DrawAllPoints := chDrawAll.Checked;
  f.DrawAllPointsStyle := TDrawAllPointsStyle(cbDrawAllStyle.ItemIndex);
  f.DrawStyle := TFastLineDrawStyle(cbDrawStyle.ItemIndex);

end;

procedure TForm1.bAddClick(Sender: TObject);
begin
  AddSerie(TDrawAllPointsStyle(cbDrawAllStyle.ItemIndex), chDrawAll.Checked, TFastLineDrawStyle(cbDrawStyle.ItemIndex));
end;

procedure TForm1.bAddGantClick(Sender: TObject);
var
  f: TDCGantSeries;
  a: TDCSeriesAdapter;
  aIntf: IDCSeriesAdapter;
begin
  f := TDCGantSeries.Create(Chart);

//  f.DrawAllPoints := aDrawAll;
//  f.DrawAllPointsStyle := aDAPStyle;
//  f.DrawStyle := aDrawStyle;
//
//  f.FastPen := True;
//  f.IgnoreNulls := True;
//  f.Stairs := False;

  if not Supports(f, IDCSeriesAdapter, aIntf) then
  begin
    f.Free;
    Exit;
  end;

  a := aIntf.DCAdapter;

  a.PhysID := '9965';
  a.OPCSource := aOPCTCPSource_V301;
  Chart.AddSeries(a.Series);
  a.FillSerie(Chart.Interval.Kind = ikShift)

end;

procedure TForm1.bClearClick(Sender: TObject);
begin
  while Chart.SeriesCount > 0 do
  begin
    if Assigned(Chart.Series[0].CustomVertAxis) then
      Chart.Series[0].CustomVertAxis.Free;
    Chart.Series[0].Free;
  end;
end;

procedure TForm1.bIntervalClick(Sender: TObject);
begin
  ShowIntervalForm(Chart.Interval, 0, Self);
end;

procedure TForm1.bAddLineClick(Sender: TObject);
var
  f: TDCLineSeries;
  a: TDCSeriesAdapter;
  aIntf: IDCSeriesAdapter;
begin
  f := TDCLineSeries.Create(Chart);

//  f.DrawAllPoints := aDrawAll;
//  f.DrawAllPointsStyle := aDAPStyle;
//  f.DrawStyle := aDrawStyle;

//  f.FastPen := True;
//  f.IgnoreNulls := True;
//  f.Stairs := False;

//  if not Supports(f, IDCSeriesAdapter, aIntf) then
//  begin
//    f.Free;
//    Exit;
//  end;

//  a := aIntf.OPCAdapter;

  f.DCAdapter.PhysID := '4';
  f.DCAdapter.OPCSource := aOPCTCPSource_V301;
  Chart.AddSeries(f);
  f.DCAdapter.FillSerie(Chart.Interval.Kind = ikShift)

end;

procedure TForm1.bCalcTimeClick(Sender: TObject);
begin
  var sw := TStopwatch.StartNew;
  Chart.Repaint;
  sw.Stop;
  Label1.Caption := sw.ElapsedMilliseconds.ToString;
end;

procedure TForm1.DoIntervalChanged(Sender: TObject);
var
  s: IDCSeriesAdapter;
begin
  Chart.UndoZoom;
  if Chart.RealTime then
    Chart.BottomAxis.SetMinMax(Chart.Interval.Date1, Chart.Interval.Date2)
  else
    Chart.BottomAxis.SetMinMax(Chart.Interval.Date1, Chart.Interval.Date2);

  for var i := 0 to Chart.SeriesCount - 1 do
  begin
    if Supports(Chart.Series[i], IDCSeriesAdapter, s) then
      s.DCAdapter.FillSerie(Chart.Interval.Kind = ikShift);
  end;

end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Chart.Interval.OnChanged := DoIntervalChanged;
end;

end.
