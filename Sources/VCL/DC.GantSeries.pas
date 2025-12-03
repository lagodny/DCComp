unit DC.GantSeries;

interface

uses
  System.Classes,
  VCL.Graphics,
  VCLTee.Chart, VCLTee.Series, VCLTee.GanttCh, uOPCGanttSeries,
  DC.SeriesAdapter, DC.SeriesAdapterIntf, DC.SeriesTypes;

type
  TDCGantSeries = class(TGanttSeries, IDCSeriesAdapter)
  private
    FDCAdapter: TDCSeriesAdapter;
    function GetDCAdapter: TDCSeriesAdapter;
    procedure SetDCAdapter(const Value: TDCSeriesAdapter);
  private
    procedure DCChangeData(Sender: TObject);
    procedure sAddXY(aRec: TXYS);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
  published
    property DCAdapter: TDCSeriesAdapter read GetDCAdapter write SetDCAdapter;
  end;

var
  TeeMsg_GalleryDCGant: string;

implementation

uses
  System.SysUtils, System.Math,
  aOPCLog,
  uOPCConst,
  uOPCInterval;

procedure TDCGantSeries.DCChangeData(Sender: TObject);
var
  aRec: TXYS;
  D2: TDateTime;
begin
  if (not Assigned(ParentChart)) then // or (not (ParentChart is TDCChart)) then
    Exit;

  try
    if (DCAdapter.DataLink.Moment = 0) or (DCAdapter.DataLink.Value = '') then
      Exit;

    if (DCAdapter.Interval.Kind = ikInterval) and
      ((DCAdapter.DataLink.Moment < DCAdapter.Interval.Date1) or (DCAdapter.DataLink.Moment > DCAdapter.Interval.Date2)) then
      Exit;

    aRec.x := DCAdapter.DataLink.Moment;
    aRec.y := StrToFloatDef(DCAdapter.DataLink.Value, 0);
    aRec.s := DCAdapter.DataLink.ErrorCode;

    sAddXY(aRec);

    // если ось времени в нормальном состоянии, то обновим ее шкалу
    if not ParentChart.Zoomed then
    begin
      if (DCAdapter.Interval.Kind = ikShift) then
        D2 := Max(DCAdapter.Interval.Date2, aRec.x)
      else
        D2 := DCAdapter.Interval.Date2;

      ParentChart.BottomAxis.SetMinMax(DCAdapter.Interval.Date1, D2);
    end;

  except
    on e: Exception do
      OPCLog.WriteToLog('Error in TDCGantSeries.ChangeData : ' + e.Message);
  end;
end;

{ TDCFastLineSeries }

constructor TDCGantSeries.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  Active := true;
  Pointer.Pen.Width := 0;
  XValues.DateTime := true;

  ColorEachLine := true;
  ColorEachPoint := true;

  // створюємо Адаптер, через який будемо виконувати всі команди та налаштування
  FDCAdapter := TDCSeriesAdapter.Create(Self);
  // для додавання нових значень використовуємо власний обробник
  FDCAdapter.DataLink.OnChangeData := DCChangeData;
  FDCAdapter.OnAddXYS := sAddXY;
end;

destructor TDCGantSeries.Destroy;
begin
  FDCAdapter.Free;
  inherited;
end;

function TDCGantSeries.GetDCAdapter: TDCSeriesAdapter;
begin
  Result := FDCAdapter;
end;

procedure TDCGantSeries.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  DCAdapter.Notification(AComponent, Operation);
end;

procedure TDCGantSeries.sAddXY(aRec: TXYS);
begin
  // первая точка, но уже нужно что-то рисовать
  if (DCAdapter.FRec1.x = 0) and DCAdapter.RecIsActive(aRec) then
    AddGanttColor(aRec.x, aRec.x, aRec.y / DCAdapter.Scale + DCAdapter.Shift, DCAdapter.CalcLabel(aRec.y, aRec.s), Color)

  // были активны - нужно дорисовать начатое
  else if DCAdapter.RecIsActive(DCAdapter.FRec1) then
  begin
    EndValues[EndValues.Count-1] := aRec.x;
    Repaint;
  end

  // стали активны - новая полоса
  else if DCAdapter.RecIsActive(aRec) then
    AddGanttColor(aRec.x, aRec.x, aRec.y / DCAdapter.Scale + DCAdapter.Shift, DCAdapter.CalcLabel(aRec.y, aRec.s), Color);

  DCAdapter.UpdateRecs(aRec);
end;

procedure TDCGantSeries.SetDCAdapter(const Value: TDCSeriesAdapter);
begin
  FDCAdapter.Assign(Value);
end;

initialization
  TeeMsg_GalleryDCGant := 'DC Gant';
  RegisterTeeSeries(TDCGantSeries, @TeeMsg_GalleryDCGant);


end.
