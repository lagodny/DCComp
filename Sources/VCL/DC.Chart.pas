unit DC.Chart;

interface

uses
  System.Classes, System.Types, System.SysUtils,
  Winapi.Windows, Winapi.Messages,
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
  private
    // touch
    FLastDist: Integer;
    FLastMidX: Integer;
    FLastMidY: Integer;
    FLastDX, FLastDY: Integer;
    FLastRec: TRect;

    FOldWndProc: TWndMethod;
    FShowZero: Boolean;
    procedure NewWndProc(var Msg: TMessage);
    procedure WM_Touch(var Msg: TMessage);
    procedure WM_Touch1(var Msg: TMessage);
    procedure SetShowZero(const Value: Boolean);
  protected
    procedure CreateWnd; override;
    procedure DestroyWnd; override;

    function DoMouseWheelDown(Shift: TShiftState; MousePos: TPoint): Boolean; override;
    function DoMouseWheelUp(Shift: TShiftState; MousePos: TPoint): Boolean; override;
    procedure DoChangeInterval(Sender: TObject); virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    // масштабувати та перетягнути aRect1 в aRect2
    procedure RectToRect(aRect1, aRect2: TRect);

    procedure ZoomByPoint(aPoint: TPoint; aZoomFactorX, aZoomFactorY: Extended; aZoomSet: TZoomSet);
  published
    property RealTime : Boolean read GetRealTime write SetRealTime default False;
    property ZoomFactor: Double read FZoomFactor write SetZoomFactor;
    property AutoScaleY: Boolean read GetAutoScaleY write SetAutoScaleY default True;

    property Interval: TOPCInterval read FInterval write SetInterval;
    property OnIntervalChanged: TNotifyEvent read FOnIntervalChanged write FOnIntervalChanged;

    property ShowZero: Boolean read FShowZero write SetShowZero;
    property Touch;
  end;



implementation

uses
  System.Math,
  DC.SeriesAdapter, DC.SeriesAdapterIntf;

const
  cZoomFactor = 1.5;


{ TDCChart }

constructor TDCChart.Create(AOwner: TComponent);
begin
  inherited;

  // touch
  FLastDist := 0;
  FLastMidX := 0;
  FLastMidY := 0;

  FOldWndProc := WindowProc;
  WindowProc := NewWndProc;

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

procedure TDCChart.CreateWnd;
begin
  inherited;

  // На цьому етапі Handle вже створено
  if not RegisterTouchWindow(Handle, TWF_FINETOUCH or TWF_WANTPALM) then
    RaiseLastOSError;
end;

destructor TDCChart.Destroy;
begin
  WindowProc := FOldWndProc;
  FInterval.Free;
  inherited;
end;

procedure TDCChart.DestroyWnd;
begin
  UnregisterTouchWindow(Handle);
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

procedure TDCChart.NewWndProc(var Msg: TMessage);
begin
  case Msg.Msg of
    Winapi.Messages.WM_TOUCH:
      WM_Touch(Msg);
//    Winapi.Messages.WM_MOUSEWHEEL: WM_MouseWheel(Msg);
  end;
  FOldWndProc(Msg);
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

    ZoomByPoint(p, aCoef, aCoef, aZoomSet);
  end;
end;

procedure TDCChart.RectToRect(aRect1, aRect2: TRect);
var
  i: Integer;
  aSerie: TChartSeries;
  aVertAxis, aHorizAxis: TChartAxis;
  x1, x2: Integer;
  k, b: Double;
begin
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

//  // треба прорахвати Мін / Макс значення кожної осі з урахуванням співвідношення прямокутників
  k := aRect2.Width/aRect1.Width;
  b := aRect2.Left - k * aRect2.Left;
//  x1 := aHorizAxis.IStartPos + b;
//  x2 := aHorizAxis.Minimum + k * (aHorizAxis.Maximum - aHorizAxis.Minimum) + b;
  x1 := aRect2.Left + Round((aHorizAxis.IStartPos - aRect1.Left) * k);
  x2 := aRect2.Left + Round((aHorizAxis.IEndPos - aRect1.Left) * k);
  aHorizAxis.SetMinMax(aHorizAxis.CalcPosPoint(x1), aHorizAxis.CalcPosPoint(x2));

//  k :=  aRect2.Height/aRect1.Height;
//  x1 := aRect2.Top + (aVertAxis.Minimum - aRect1.Top) * k;
//  x2 := aRect2.Top + (aVertAxis.Maximum - aRect1.Top) * k;
//  aVertAxis.SetMinMax(x1, x2);

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
  s: IDCSeriesAdapter;
begin
  if FRealTime = Value then
    Exit;

  UndoZoom;
  FRealTime := Value;
  for i := 0 to SeriesCount - 1 do
    if Supports(Series[i], IDCSeriesAdapter, s) then
      s.DCAdapter.UpdateRealTime;
end;

procedure TDCChart.SetShowZero(const Value: Boolean);
begin
  SetBooleanProperty(FShowZero, Value);
end;

procedure TDCChart.SetZoomFactor(const Value: Double);
begin
  FZoomFactor := Value;
end;

procedure TDCChart.WM_Touch(var Msg: TMessage);
var
  Inputs: array of TTouchInput;
  aRect: TRect;
  aCount: Integer;
//  X1, Y1, X2, Y2: Integer;
//  dx, dy: Integer;
//  Dist: Integer;
//  MidX, MidY: Integer;
//  MidP: TPoint;
//  aZoomFactorX, aZoomFactorY: Double;
begin
//  if not FEnabled then Exit;

  aCount := Msg.WParam and $FFFF;
  if aCount <> 2 then
  begin
    FLastDist := 0;
    FLastRec := TRect.Empty;
    Exit;
  end;

  SetLength(Inputs, aCount);

  if GetTouchInputInfo(Msg.LParam, aCount, @Inputs[0], SizeOf(TTouchInput)) then
  begin
    aRect := ScreenToClient(Rect(
      Min(Inputs[0].x, Inputs[1].x) div 100,
      Min(Inputs[0].y, Inputs[1].y) div 100,
      Max(Inputs[0].x, Inputs[1].x) div 100,
      Max(Inputs[0].y, Inputs[1].y) div 100));

    if not FLastRec.IsEmpty then
      RectToRect(FLastRec, aRect);
    FLastRec := aRect;

    CloseTouchInputHandle(Msg.LParam);
  end;
end;

procedure TDCChart.WM_Touch1(var Msg: TMessage);
var
  Inputs: array of TTouchInput;
  Count: Integer;
  X1, Y1, X2, Y2: Integer;
  dx, dy: Integer;
  Dist: Integer;
  MidX, MidY: Integer;
  MidP: TPoint;
  aRect: TRect;
  aZoomFactorX, aZoomFactorY: Double;
begin
  Count := Msg.WParam and $FFFF;
  if Count <> 2 then
  begin
    FLastDist := 0;
    FLastRec := TRect.Empty;
    Exit;
  end;

  SetLength(Inputs, Count);

  if GetTouchInputInfo(Msg.LParam, Count, @Inputs[0], SizeOf(TTouchInput)) then
  begin
    X1 := Inputs[0].x div 100;
    Y1 := Inputs[0].y div 100;

    X2 := Inputs[1].x div 100;
    Y2 := Inputs[1].y div 100;

    dx := X2 - X1;
    dy := Y2 - Y1;
    Dist := Round(Sqrt(dx*dx + dy*dy));

    // центр між пальцями
    MidX := (X1 + X2) div 2;
    MidY := (Y1 + Y2) div 2;

    if (FLastDist = 0) then
    begin
      FLastDist := Dist;
      FLastMidX := MidX;
      FLastMidY := MidY;
      FLastDX := X2 - X1;
      FLastDY := Y2 - Y1;
      Exit;
    end;

    if ABS(FLastDist - Dist) < 5 then
      Exit;

    if dx = 0 then
      aZoomFactorX := 1
    else
      aZoomFactorX := FLastDX / dx;

    if dy = 0 then
      aZoomFactorY := 1
    else
      aZoomFactorY := FLastDY / dy;

    if aZoomFactorX < 0.8 then
      aZoomFactorX := 0.8;
    if aZoomFactorX > 1.2 then
      aZoomFactorX := 1.2;

    if aZoomFactorY < 0.8 then
      aZoomFactorY := 0.8;
    if aZoomFactorY > 1.2 then
      aZoomFactorY := 1.2;



    ZoomByPoint(ScreenToClient(Point(MidX, MidY)), aZoomFactorX, aZoomFactorY, [zsTime, zsValue]);

    FLastDist := Dist;
    FLastMidX := MidX;
    FLastMidY := MidY;
    FLastDX := dx;
    FLastDY := dy;

    CloseTouchInputHandle(Msg.LParam);
  end;
end;

procedure TDCChart.ZoomByPoint(aPoint: TPoint; aZoomFactorX, aZoomFactorY: Extended; aZoomSet: TZoomSet);
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
    w1 := Trunc((aZoomRect.Right - aZoomRect.Left) * aZoomFactorX) div 2;
    dw := Trunc((aPoint.X - (aZoomRect.Right + aZoomRect.Left) / 2) * aZoomFactorX);

    aZoomRect.Left := aPoint.X - w1 - dw;
    aZoomRect.Right := aPoint.X + w1 - dw;
  end

  else if aZoomSet = [zsValue] then
  begin
    h1 := Trunc((aZoomRect.Bottom - aZoomRect.Top) * aZoomFactorY) div 2;
    dh := Trunc((aPoint.Y - (aZoomRect.Bottom + aZoomRect.Top)/2) * aZoomFactorY);

    aZoomRect.Top := aPoint.Y - h1 - dh;
    aZoomRect.Bottom := aPoint.Y + h1 - dh;
  end

  else
  begin
    w1 := Trunc((aZoomRect.Right - aZoomRect.Left) * aZoomFactorX) div 2;
    dw := Trunc((aPoint.X - (aZoomRect.Right + aZoomRect.Left) / 2) * aZoomFactorX);

    aZoomRect.Left := aPoint.X - w1 - dw;
    aZoomRect.Right := aPoint.X + w1 - dw;

    h1 := Trunc((aZoomRect.Bottom - aZoomRect.Top) * aZoomFactorY) div 2;
    dh := Trunc((aPoint.Y - (aZoomRect.Bottom + aZoomRect.Top)/2) * aZoomFactorY);

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
