unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  uOPCInterval,
  aOPCLineSeries, aOPCFastSeries, uOPCGanttSeries,
  uOPCSeriesAdapter, uOPCSeriesAdapterIntf,
  VCLTee.Series,
  VclTee.TeeGDIPlus, aCustomOPCSource, aOPCSource, aCustomOPCTCPSource, aOPCTCPSource_V30,
  Vcl.StdCtrls, Vcl.ExtCtrls, VCLTee.TeEngine, VCLTee.TeeProcs, VCLTee.Chart, aOPCChart, VCLTee.TeeShape;

type
  TForm1 = class(TForm)
    Chart: TaOPCChart;
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
    procedure bAddClick(Sender: TObject);
    procedure bClearClick(Sender: TObject);
    procedure bIntervalClick(Sender: TObject);
    procedure DoIntervalChanged(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ApplyClick(Sender: TObject);
    procedure bAddLineClick(Sender: TObject);
    procedure bCalcTimeClick(Sender: TObject);
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
  f: TaOPCFastLineSeries;
  a: TOPCSeriesAdapter;
  aIntf: IOPCSeriesAdapter;
begin
  f := TaOPCFastLineSeries.Create(Chart);

  f.DrawAllPoints := aDrawAll;
  f.DrawAllPointsStyle := aDAPStyle;
  f.DrawStyle := aDrawStyle;

  f.FastPen := True;
  f.IgnoreNulls := True;
  f.Stairs := False;

  if not Supports(f, IOPCSeriesAdapter, aIntf) then
  begin
    f.Free;
    Exit;
  end;

  a := aIntf.OPCAdapter;

  a.PhysID := '4';
  a.OPCSource := aOPCTCPSource_V301;
  Chart.AddSeries(a.Series);
  a.FillSerie(Chart.Interval.Kind = ikShift)

end;

procedure TForm1.ApplyClick(Sender: TObject);
var
  f: TaOPCFastLineSeries;
begin
  if Chart.SeriesList.Count < 1 then
    Exit;

  f := Chart.Series[0] as TaOPCFastLineSeries;

  f.DrawAllPoints := chDrawAll.Checked;
  f.DrawAllPointsStyle := TDrawAllPointsStyle(cbDrawAllStyle.ItemIndex);
  f.DrawStyle := TFastLineDrawStyle(cbDrawStyle.ItemIndex);

end;

procedure TForm1.bAddClick(Sender: TObject);
begin
  AddSerie(TDrawAllPointsStyle(cbDrawAllStyle.ItemIndex), chDrawAll.Checked, TFastLineDrawStyle(cbDrawStyle.ItemIndex));
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
  f: TaOPCLineSeries;
  a: TOPCSeriesAdapter;
  aIntf: IOPCSeriesAdapter;
begin
  f := TaOPCLineSeries.Create(Chart);

//  f.DrawAllPoints := aDrawAll;
//  f.DrawAllPointsStyle := aDAPStyle;
//  f.DrawStyle := aDrawStyle;

//  f.FastPen := True;
//  f.IgnoreNulls := True;
//  f.Stairs := False;

//  if not Supports(f, IOPCSeriesAdapter, aIntf) then
//  begin
//    f.Free;
//    Exit;
//  end;

//  a := aIntf.OPCAdapter;

  f.PhysID := '4';
  f.OPCSource := aOPCTCPSource_V301;
  Chart.AddSeries(f);
  f.FillSerie(Chart.Interval.Kind = ikShift)

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
  s: IOPCSeriesAdapter;
begin
  Chart.UndoZoom;
  if Chart.RealTime then
    Chart.BottomAxis.SetMinMax(Chart.Interval.Date1, Chart.Interval.Date2)
  else
    Chart.BottomAxis.SetMinMax(Chart.Interval.Date1, Chart.Interval.Date2);

  for var i := 0 to Chart.SeriesCount - 1 do
  begin
    if Supports(Chart.Series[i], IOPCSeriesAdapter, s) then
      s.OPCAdapter.FillSerie(Chart.Interval.Kind = ikShift);
  end;

end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Chart.Interval.OnChanged := DoIntervalChanged;
end;

end.
