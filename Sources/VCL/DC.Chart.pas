unit DC.Chart;

interface

uses
  System.Classes, System.Types, System.SysUtils,
  Winapi.Windows,
  VCL.Controls,
  VCLTee.Chart, VCLTee.TeeProcs, VCLTee.TeCanvas, VCLTee.TeEngine,
  uOPCInterval;

type
  TZoomKind = (zsTime, zsValue);
  TZoomSet = set of TZoomKind;

type
  TDCChart = class(TChart)
  private
    FRealTime: Boolean;
    FInterval: TOPCInterval;
    FZoomFactor: Double;
    FOnIntervalChanged: TNotifyEvent;
    function GetAutoScaleY: Boolean;
    function GetRealTime: Boolean;
    procedure SetAutoScaleY(const Value: Boolean);
    procedure SetRealTime(const Value: Boolean);
    procedure SetInterval(const Value: TOPCInterval);
    procedure SetZoomFactor(const Value: Double);
  private
    procedure ProcessMouseWheel(aCoef: Double);
  protected
    function DoMouseWheelDown(Shift: TShiftState; MousePos: TPoint): Boolean; override;
    function DoMouseWheelUp(Shift: TShiftState; MousePos: TPoint): Boolean; override;
    procedure DoChangeInterval(Sender: TObject); virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure ZoomByPoint(aPoint: TPoint; aZoomFactor: Extended; aZoomSet: TZoomSet);
  published
    property RealTime : Boolean read GetRealTime write SetRealTime default False;
    property ZoomFactor: Double read FZoomFactor write SetZoomFactor;
    property AutoScaleY: Boolean read GetAutoScaleY write SetAutoScaleY default True;

    property Interval: TOPCInterval read FInterval write SetInterval;
    property OnIntervalChanged: TNotifyEvent read FOnIntervalChanged write FOnIntervalChanged;

    property Touch;
  end;



implementation

uses
  uOPCSeriesAdapter, uOPCSeriesAdapterIntf;

const
  cZoomFactor = 1.5;


{ TDCChart }

constructor TDCChart.Create(AOwner: TComponent);
begin
  inherited;

  FInterval := TOPCInterval.Create;
  FInterval.OnChanged := DoChangeInterval;

  FRealTime  := False;

  BottomAxis.LabelStyle := talValue;
  BottomAxis.AutomaticMaximum := False;
  BottomAxis.AutomaticMinimum := False;
  BottomAxis.SetMinMax(Interval.Date1, Interval.Date2);

  Legend.Pen.Width := 0;

  Title.Visible := False;

  Panning.MouseWheel := pmwNone;

  Legend.Visible := True;
  Legend.Alignment := laBottom;
  Legend.CheckBoxes := True;
  Legend.LegendStyle := lsSeries;

  FZoomFactor := cZoomFactor;
end;

destructor TDCChart.Destroy;
begin
  FInterval.Free;
  inherited;
end;

procedure TDCChart.DoChangeInterval(Sender: TObject);
begin
  if Assigned(FOnIntervalChanged) then
    FOnIntervalChanged(Sender);

  BottomAxis.SetMinMax(Interval.Date1, Interval.Date2);
end;

function TDCChart.DoMouseWheelDown(Shift: TShiftState; MousePos: TPoint): Boolean;
begin
  ProcessMouseWheel(ZoomFactor);
end;

function TDCChart.DoMouseWheelUp(Shift: TShiftState; MousePos: TPoint): Boolean;
begin
  ProcessMouseWheel(1/ZoomFactor);
end;

function TDCChart.GetAutoScaleY: Boolean;
begin
  Result := LeftAxis.Automatic;
end;

function TDCChart.GetRealTime: Boolean;
begin
  Result := FRealTime
end;

procedure TDCChart.ProcessMouseWheel(aCoef: Double);
begin
  if Panning.MouseWheel = pmwNone then
  begin
    var p := ScreenToClient(Mouse.CursorPos);
    var aVertRect := TeeRect(0, LeftAxis.IStartPos, LeftAxis.PosAxis + 10, LeftAxis.IEndPos);
    var aHorRect := TeeRect(BottomAxis.IStartPos, BottomAxis.PosAxis - 10, BottomAxis.IEndPos, Height);
    var aZoomSet: TZoomSet := [];

    if (GetAsyncKeyState(VK_CONTROL) and $8000) <> 0 then
      aZoomSet := [zsTime, zsValue]
    else if (GetAsyncKeyState(VK_SHIFT) and $8000) <> 0 then
      aZoomSet := [zsValue]
    else if PointInRect(aVertRect, p) then
      aZoomSet := [zsValue]
    else if PointInRect(aHorRect, p) then
      aZoomSet := [zsTime]
    else
      aZoomSet := [zsTime];

    ZoomByPoint(p, aCoef, aZoomSet);
  end;
end;

procedure TDCChart.SetAutoScaleY(const Value: Boolean);
var
  i: Integer;
begin
  for i := 0 to Axes.Count - 1 do
    if not Axes[i].Horizontal then
      Axes[i].Automatic := Value;
end;

procedure TDCChart.SetInterval(const Value: TOPCInterval);
begin
  FInterval.Assign(Value);
end;

procedure TDCChart.SetRealTime(const Value: Boolean);
var
  i: Integer;
  s: IOPCSeriesAdapter;
begin
  if FRealTime = Value then
    Exit;

  UndoZoom;
  FRealTime := Value;
  for i := 0 to SeriesCount - 1 do
    if Supports(Series[i], IOPCSeriesAdapter, s) then
      s.OPCAdapter.UpdateRealTime;
end;

procedure TDCChart.SetZoomFactor(const Value: Double);
begin
  FZoomFactor := Value;
end;

procedure TDCChart.ZoomByPoint(aPoint: TPoint; aZoomFactor: Extended; aZoomSet: TZoomSet);
var
  i: Integer;
  w1, h1: integer;
  dw, dh: integer;
  SaveAnimatedZoom: Boolean;
  aVertAxis, aHorizAxis: TChartAxis;
  aSerie: TChartSeries;
  aZoomRect: TRect;
begin
  //aSerie := nil;
  aVertAxis := nil;
  aHorizAxis := nil;
  for i := 0 to SeriesList.Count - 1 do
  begin
    aSerie := Series[i];
    if aSerie.Active then
    begin
      case aSerie.VertAxis of
        aLeftAxis, aBothVertAxis:
          aVertAxis := LeftAxis;
        aRightAxis:
          aVertAxis := RightAxis;
        aCustomVertAxis:
          aVertAxis := aSerie.CustomVertAxis;
      end;

      case aSerie.HorizAxis of
        aTopAxis, aBothHorizAxis:
          aHorizAxis := TopAxis;
        aBottomAxis:
          aHorizAxis := BottomAxis;
        aCustomHorizAxis:
          aHorizAxis := aSerie.CustomHorizAxis;
      end;

      Break;
    end;
  end;

  if not Assigned(aVertAxis) or not Assigned(aHorizAxis) then
    Exit;

  aZoomRect := ChartRect;

  // отработаем случай с перестановкой осей
//  if (aVertAxis.PositionUnits = muPercent) then
  begin
    aZoomRect.Top := ChartRect.Top + Round(0.01 * ChartHeight * aVertAxis.StartPosition);
    aZoomRect.Bottom := ChartRect.Top + Round(0.01 * ChartHeight * aVertAxis.EndPosition);
  end;

//  if (aVertAxis.PositionUnits = muPercent) then
  begin
    aZoomRect.Left := ChartRect.Left + Round(0.01 * ChartWidth * aHorizAxis.StartPosition);
    aZoomRect.Right := ChartRect.Left + Round(0.01 * ChartWidth * aHorizAxis.EndPosition);
  end;

  if aZoomSet = [zsTime] then
  begin
    w1 := Trunc((aZoomRect.Right - aZoomRect.Left) * aZoomFactor) div 2;
    dw := Trunc((aPoint.X - (aZoomRect.Right + aZoomRect.Left) / 2) * aZoomFactor);

    aZoomRect.Left := aPoint.X - w1 - dw;
    aZoomRect.Right := aPoint.X + w1 - dw;
  end

  else if aZoomSet = [zsValue] then
  begin
    h1 := Trunc((aZoomRect.Bottom - aZoomRect.Top) * aZoomFactor) div 2;
    dh := Trunc((aPoint.Y - (aZoomRect.Bottom + aZoomRect.Top)/2) * aZoomFactor);

    aZoomRect.Top := aPoint.Y - h1 - dh;
    aZoomRect.Bottom := aPoint.Y + h1 - dh;
  end

  else
  begin
    w1 := Trunc((aZoomRect.Right - aZoomRect.Left) * aZoomFactor) div 2;
    dw := Trunc((aPoint.X - (aZoomRect.Right + aZoomRect.Left) / 2) * aZoomFactor);

    aZoomRect.Left := aPoint.X - w1 - dw;
    aZoomRect.Right := aPoint.X + w1 - dw;

    h1 := Trunc((aZoomRect.Bottom - aZoomRect.Top) * aZoomFactor) div 2;
    dh := Trunc((aPoint.Y - (aZoomRect.Bottom + aZoomRect.Top)/2) * aZoomFactor);

    aZoomRect.Top := aPoint.Y - h1 - dh;
    aZoomRect.Bottom := aPoint.Y + h1 - dh;
  end;

  SaveAnimatedZoom := AnimatedZoom;
  try
    AnimatedZoom := False;
    ZoomRect(aZoomRect);
  finally
    AnimatedZoom := SaveAnimatedZoom;
  end;
end;

end.
