unit FMX.DCChart;

interface

uses
  System.Classes,
  //Windows,
  System.SysUtils, System.Types,
  aOPCSource, //aDCLineSeries,
  uOPCInterval, //uChoiceIntervalExt,
  FMXTee.Chart, FMXTee.Engine;

type
  TZoomKind = (zsTime, zsValue);
  TZoomSet = set of TZoomKind;

  TaDCChart = class(TChart)
  private
    FRealTime: Boolean;
    //FVisibleInterval: TDateTime;
    FShowState: boolean;
    FShowZero: Boolean;
    FInterval: TOPCInterval;
    FOnIntervalChanged: TNotifyEvent;
    function GetAutoScaleY: boolean;
    procedure SetAutoScaleY(const Value: boolean);
//    procedure SetVisibleInterval(const Value: TDateTime);
    function GetRealTime: Boolean;
    procedure SetRealTime(const Value: Boolean);
    procedure SetShowState(const Value: boolean);
    procedure SetShowZero(const Value: Boolean);
    procedure SetInterval(const Value: TOPCInterval);
  protected
    //function DoMouseWheelDown(Shift: TShiftState; MousePos: TPoint): Boolean; override;
    //function DoMouseWheelUp(Shift: TShiftState; MousePos: TPoint): Boolean; override;
    //procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure DoChangeInterval(Sender: TObject); virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure ZoomByPoint(aPoint: TPoint; aZoomFactor: Extended; aZoomSet: TZoomSet);
  published
    property ShowState: boolean read FShowState write SetShowState default true;
    property AutoScaleY : boolean read GetAutoScaleY write SetAutoScaleY default true;
    property RealTime : Boolean read GetRealTime write SetRealTime default false;
//    property VisibleInterval : TDateTime read FVisibleInterval
//      write SetVisibleInterval;
    property Interval: TOPCInterval read FInterval write SetInterval;
    property ShowZero: Boolean read FShowZero write SetShowZero;

    property OnIntervalChanged: TNotifyEvent read FOnIntervalChanged write
      FOnIntervalChanged; 
  end;

implementation

uses
  FMX.DCLineSeries,
  FMXTee.Procs;


{ TaDCChart }

const
  CZoomFactor = 1.5;

constructor TaDCChart.Create(AOwner: TComponent);
begin
  inherited;
  FInterval := TOPCInterval.Create;
  FInterval.OnChanged := DoChangeInterval;

  FRealTime  := false;
  FShowState := true;
  //FVisibleInterval := 1/2/24; //пол часа
  BottomAxis.LabelStyle := talValue;
  BottomAxis.AutomaticMaximum := false;
  BottomAxis.AutomaticMinimum := false;
  BottomAxis.SetMinMax(Interval.Date1, Interval.Date2);

  BufferedDisplay := True;
end;

destructor TaDCChart.Destroy;
begin
  FInterval.Free;
  inherited;
end;

procedure TaDCChart.DoChangeInterval(Sender: TObject);
begin
  if Assigned(FOnIntervalChanged) then
    FOnIntervalChanged(Sender);
    
  BottomAxis.SetMinMax(Interval.Date1, Interval.Date2);
end;

{
function TaDCChart.DoMouseWheelDown(Shift: TShiftState;
  MousePos: TPoint): Boolean;
var
  aZoomSet: TZoomSet;
  //aCtrlDown: boolean;
begin
  result:=inherited DoMouseWheelDown(Shift,MousePos);

  //if not TeeUseMouseWheel then
  if not (Panning.MouseWheel = pmwNone)  then
  begin
    aZoomSet := [];
    if (GetAsyncKeyState(VK_CONTROL) and $8000) <> 0 then
      aZoomSet := [zsTime, zsValue]
    else if (GetAsyncKeyState(VK_SHIFT) and $8000) <> 0 then
      aZoomSet := [zsValue]
    else
      aZoomSet := [zsTime];

    ZoomByPoint(ScreenToClient(MousePos), CZoomFactor, aZoomSet);
  end;

end;
}

{
function TaDCChart.DoMouseWheelUp(Shift: TShiftState;
  MousePos: TPoint): Boolean;
var
  aZoomSet: TZoomSet;
begin
  result:=inherited DoMouseWheelUp(Shift,MousePos);

  //if not TeeUseMouseWheel then
  if not (Panning.MouseWheel = pmwNone)  then
  begin
    aZoomSet := [];
    if (GetAsyncKeyState(VK_CONTROL) and $8000) <> 0 then
      aZoomSet := [zsTime, zsValue]
    else if (GetAsyncKeyState(VK_SHIFT) and $8000) <> 0 then
      aZoomSet := [zsValue]
    else
      aZoomSet := [zsTime];

    ZoomByPoint(ScreenToClient(MousePos), 1/CZoomFactor, aZoomSet);
  end;
end;
}

function TaDCChart.GetAutoScaleY: boolean;
begin
  Result := LeftAxis.Automatic;
end;

function TaDCChart.GetRealTime: Boolean;
begin
  Result := FRealTime
end;

//procedure TaDCChart.KeyDown(var Key: Word; Shift: TShiftState);
//begin
//  inherited KeyDown(Key, Shift);
//end;

procedure TaDCChart.SetAutoScaleY(const Value: boolean);
//begin
  //LeftAxis.Automatic := Value;
var
  i: Integer;
begin
  for i := 0 to Axes.Count - 1 do
    if not Axes[i].Horizontal then
      Axes[i].Automatic := Value;
end;

procedure TaDCChart.SetInterval(const Value: TOPCInterval);
begin
  FInterval.Assign(Value);
end;

procedure TaDCChart.SetRealTime(const Value: Boolean);
var
  i:integer;
begin
  if FRealTime = Value then
    Exit;

  UndoZoom;
  FRealTime := Value;
  for i := 0 to SeriesCount - 1 do
    if Series[i] is TaDCLineSeries then
      TaDCLineSeries(Series[i]).UpdateRealTime;
end;

procedure TaDCChart.SetShowState(const Value: boolean);
var
  i: Integer;
begin
  if Value <> FShowState then
  begin
    FShowState := Value;
    for i := 0 to SeriesCount - 1 do
      if Series[i] is TaDCLineSeries then
        TaDCLineSeries(Series[i]).ShowState := Value;
  end;
end;

procedure TaDCChart.SetShowZero(const Value: Boolean);
begin
  SetBooleanProperty(FShowZero, Value);
end;

//procedure TaDCChart.SetVisibleInterval(const Value: TDateTime);
//var
//  i: Integer;
//begin
//  //UndoZoom;
//  FVisibleInterval := Value;
//  for i := 0 to SeriesCount - 1 do
//  begin
//    if Series[i] is TaDCLineSeries then
//      TaDCLineSeries(Series[i]).VisibleInterval := FVisibleInterval;
//  end;
//end;

procedure TaDCChart.ZoomByPoint(aPoint: TPoint; aZoomFactor: Extended;
  aZoomSet: TZoomSet);
var
  i: Integer;
  w1, h1: integer;
  dw, dh: integer;
  SaveAnimatedZoom: Boolean;
  aVertAxis, aHorizAxis: TChartAxis;
  aSerie: TChartSeries;
  aZoomRect: TRectF;
begin
  aSerie := nil;
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

//  aZoomRect.Top := aVertAxis.CalcYPosValue(aVertAxis.Maximum);
//  aZoomRect.Bottom := aVertAxis.CalcYPosValue(aVertAxis.Minimum);
//
//  aZoomRect.Left := aHorizAxis.CalcXPosValue(aHorizAxis.Minimum);
//  aZoomRect.Right := aHorizAxis.CalcXPosValue(aHorizAxis.Maximum);

  aZoomRect := ChartRect;

  // отработаем случай с перестановкой осей
  if (aVertAxis.PositionUnits = muPercent) then
  begin
    aZoomRect.Top := ChartRect.Top + Round(0.01 * ChartHeight * aVertAxis.StartPosition);
    aZoomRect.Bottom := ChartRect.Top + Round(0.01 * ChartHeight * aVertAxis.EndPosition);
  end;

  if (aVertAxis.PositionUnits = muPercent) then
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

//    w1 := Trunc(ChartWidth * aZoomFactor) div 2;
//    dw := Trunc((aPoint.X - ChartXCenter) * aZoomFactor);
//    h1 := Trunc(ChartHeight * aZoomFactor) div 2;
//    dh := Trunc((aPoint.Y - ChartYCenter) * aZoomFactor);
  end;



//  if aZoomSet = [zsTime] then
//  begin
//    aVertAxis := nil;
//    for i := 0 to Axes.Count - 1 do
//      if (not Axes[i].Horizontal) and Axes[i].Visible then
//      begin
//        aVertAxis := Axes[i];
//        Break;
//      end;
//
//    if not Assigned(aVertAxis) then
//      Exit;
//
//    w1 := Trunc(ChartWidth * aZoomFactor) div 2;
//    dw := Trunc((aPoint.X - ChartXCenter) * aZoomFactor);
//    h1 := ChartHeight div 2;
//    dh := aPoint.Y - ChartYCenter;
//    ZoomRect(Rect(
//      aPoint.X - w1 - dw, aVertAxis.CalcYPosValue(aVertAxis.Minimum),
//      aPoint.X + w1 - dw, aVertAxis.CalcYPosValue(aVertAxis.Maximum)
//      ));
//    Exit;
//  end
//  else if aZoomSet = [zsValue] then
//  begin
//    w1 := ChartWidth div 2;
//    dw := aPoint.X - ChartXCenter;
//    h1 := Trunc(ChartHeight * aZoomFactor) div 2;
//    dh := Trunc((aPoint.Y - ChartYCenter) * aZoomFactor);
//  end
//  else
//  begin
//    w1 := Trunc(ChartWidth * aZoomFactor) div 2;
//    dw := Trunc((aPoint.X - ChartXCenter) * aZoomFactor);
//    h1 := Trunc(ChartHeight * aZoomFactor) div 2;
//    dh := Trunc((aPoint.Y - ChartYCenter) * aZoomFactor);
//  end;

  SaveAnimatedZoom := AnimatedZoom;
  try
    AnimatedZoom := False;
    ZoomRect(aZoomRect);
//    ZoomRect(Rect(
//      aPoint.X - w1 - dw, aPoint.Y - h1 - dh,
//      aPoint.X + w1 - dw, aPoint.Y + h1 - dh
//      ));
  finally
    AnimatedZoom := SaveAnimatedZoom;
  end;
end;

end.
