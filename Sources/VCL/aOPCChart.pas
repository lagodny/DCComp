unit aOPCChart;

interface

uses
  Classes, Windows, SysUtils, Types,
  VCL.Controls,
  aOPCSource, aOPCLineSeries, uChoiceIntervalExt, uOPCInterval,
  VCLTee.Chart, VCLTee.TeEngine, VCLTee.TeCanvas;

type
  TZoomKind = (zsTime, zsValue);
  TZoomSet = set of TZoomKind;

  TaOPCChart = class(TChart)
  private
    FRealTime: Boolean;
    //FVisibleInterval: TDateTime;
    FShowState: boolean;
    FShowZero: Boolean;
    FInterval: TOPCInterval;
    FOnIntervalChanged: TNotifyEvent;
    FZoomFactor: Double;
    function GetAutoScaleY: boolean;
    procedure SetAutoScaleY(const Value: boolean);
//    procedure SetVisibleInterval(const Value: TDateTime);
    function GetRealTime: Boolean;
    procedure SetRealTime(const Value: Boolean);
    procedure SetShowState(const Value: boolean);
    procedure SetShowZero(const Value: Boolean);
    procedure SetInterval(const Value: TOPCInterval);
    procedure SetZoomFactor(const Value: Double);
  protected
    procedure ProcessMouseWheel(aCoef: Double);

    function DoMouseWheelDown(Shift: TShiftState; MousePos: TPoint): Boolean; override;
    function DoMouseWheelUp(Shift: TShiftState; MousePos: TPoint): Boolean; override;
    //procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure DoChangeInterval(Sender: TObject); virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure ZoomByPoint(aPoint: TPoint; aZoomFactor: Extended; aZoomSet: TZoomSet);
  published
    property ZoomFactor: Double read FZoomFactor write SetZoomFactor;
    property ShowState: boolean read FShowState write SetShowState default true;
    property AutoScaleY : boolean read GetAutoScaleY write SetAutoScaleY default true;
    property RealTime : Boolean read GetRealTime write SetRealTime default false;
//    property VisibleInterval : TDateTime read FVisibleInterval
//      write SetVisibleInterval;
    property Interval: TOPCInterval read FInterval write SetInterval;
    property ShowZero: Boolean read FShowZero write SetShowZero;
    property Touch;

    property OnIntervalChanged: TNotifyEvent read FOnIntervalChanged write FOnIntervalChanged;
  end;

implementation

uses
  uOPCSeriesTypes, VCLTee.TeeProcs;


{ TaOPCChart }

const
  CZoomFactor = 1.5;

constructor TaOPCChart.Create(AOwner: TComponent);
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

  FZoomFactor := 1.5;
end;

destructor TaOPCChart.Destroy;
begin
  FInterval.Free;
  inherited;
end;

procedure TaOPCChart.DoChangeInterval(Sender: TObject);
begin
  if Assigned(FOnIntervalChanged) then
    FOnIntervalChanged(Sender);
    
  BottomAxis.SetMinMax(Interval.Date1, Interval.Date2);
end;

function TaOPCChart.DoMouseWheelDown(Shift: TShiftState;
  MousePos: TPoint): Boolean;
begin
  ProcessMouseWheel(ZoomFactor);
end;
//var
//  aZoomSet: TZoomSet;
//  //aCtrlDown: boolean;
//begin
//  result:=inherited DoMouseWheelDown(Shift,MousePos);
//
////  if not TeeUseMouseWheel then
//  if Panning.MouseWheel = pmwNone then
//  begin
//    aZoomSet := [];
//    if (GetAsyncKeyState(VK_CONTROL) and $8000) <> 0 then
//      aZoomSet := [zsTime, zsValue]
//    else if (GetAsyncKeyState(VK_SHIFT) and $8000) <> 0 then
//      aZoomSet := [zsValue]
//    else
//      aZoomSet := [zsTime];
//
//    ZoomByPoint(ScreenToClient(MousePos), CZoomFactor, aZoomSet);
//  end;
//end;

function TaOPCChart.DoMouseWheelUp(Shift: TShiftState; MousePos: TPoint): Boolean;
begin
  ProcessMouseWheel(1/ZoomFactor);
end;
//var
//  aZoomSet: TZoomSet;
//begin
//  result:=inherited DoMouseWheelUp(Shift,MousePos);
//
////  if not TeeUseMouseWheel then
//  if Panning.MouseWheel = pmwNone then
//  begin
//    aZoomSet := [];
//    if (GetAsyncKeyState(VK_CONTROL) and $8000) <> 0 then
//      aZoomSet := [zsTime, zsValue]
//    else if (GetAsyncKeyState(VK_SHIFT) and $8000) <> 0 then
//      aZoomSet := [zsValue]
//    else
//      aZoomSet := [zsTime];
//
//    ZoomByPoint(ScreenToClient(MousePos), 1/CZoomFactor, aZoomSet);
//  end;
//end;

function TaOPCChart.GetAutoScaleY: boolean;
begin
  Result := LeftAxis.Automatic;
end;

function TaOPCChart.GetRealTime: Boolean;
begin
  Result := FRealTime
end;

procedure TaOPCChart.ProcessMouseWheel(aCoef: Double);
begin
  if Panning.MouseWheel = pmwNone then
  begin
    var p := ScreenToClient(Mouse.CursorPos);
    var aVertRect := TeeRect(
      0, LeftAxis.IStartPos,
      LeftAxis.PosAxis + 10, LeftAxis.IEndPos);
    var aHorRect := TeeRect(
      BottomAxis.IStartPos, BottomAxis.PosAxis - 10,
      BottomAxis.IEndPos, Height);
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

//procedure TaOPCChart.KeyDown(var Key: Word; Shift: TShiftState);
//begin
//  inherited KeyDown(Key, Shift);
//end;

procedure TaOPCChart.SetAutoScaleY(const Value: boolean);
//begin
  //LeftAxis.Automatic := Value;
var
  i: Integer;
begin
  for i := 0 to Axes.Count - 1 do
    if not Axes[i].Horizontal then
      Axes[i].Automatic := Value;
end;

procedure TaOPCChart.SetInterval(const Value: TOPCInterval);
begin
  FInterval.Assign(Value);
end;

procedure TaOPCChart.SetRealTime(const Value: Boolean);
var
  i:integer;
  s: IaOPCSeries;
begin
  if FRealTime = Value then
    Exit;

  UndoZoom;
  FRealTime := Value;
  for i := 0 to SeriesCount - 1 do
    if Supports(Series[i], IaOPCSeries, s) then
      s.UpdateRealTime;
    //if Series[i] is TaOPCLineSeries then
    //  TaOPCLineSeries(Series[i]).UpdateRealTime;
end;

procedure TaOPCChart.SetShowState(const Value: boolean);
var
  i: Integer;
begin
  if Value <> FShowState then
  begin
    FShowState := Value;
    for i := 0 to SeriesCount - 1 do
      if Series[i] is TaOPCLineSeries then
        TaOPCLineSeries(Series[i]).ShowState := Value;
  end;
end;

procedure TaOPCChart.SetShowZero(const Value: Boolean);
begin
  SetBooleanProperty(FShowZero, Value);
end;

procedure TaOPCChart.SetZoomFactor(const Value: Double);
begin
  FZoomFactor := Value;
end;

//procedure TaOPCChart.SetVisibleInterval(const Value: TDateTime);
//var
//  i: Integer;
//begin
//  //UndoZoom;
//  FVisibleInterval := Value;
//  for i := 0 to SeriesCount - 1 do
//  begin
//    if Series[i] is TaOPCLineSeries then
//      TaOPCLineSeries(Series[i]).VisibleInterval := FVisibleInterval;
//  end;
//end;

procedure TaOPCChart.ZoomByPoint(aPoint: TPoint; aZoomFactor: Extended;
  aZoomSet: TZoomSet);
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
