unit TeeChartTouchZoom;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Classes, System.Math,
  Vcl.Controls, Vcl.Forms,
  VCLTee.TeeProcs, VCLTee.Chart, VCLTee.TeEngine;

type
  TTChartTouchZoom = class
  private
    FChart: TCustomChart;
    FLastDist: Integer;
    FLastMidX: Integer;
    FLastMidY: Integer;

    FEnabled: Boolean;
    FOldWndProc: TWndMethod;

    FZoomFactorMin: Double;
    FZoomFactorMax: Double;
    FWheelZoomScale: Double;

    procedure NewWndProc(var Msg: TMessage);
    procedure WM_Touch(var Msg: TMessage);
    procedure WM_MouseWheel(var Msg: TMessage);

    procedure DoPinchZoom(NewDist: Integer);
    procedure DoZoom(Factor: Double);

    procedure Scroll(dx, dy: Integer);
    procedure DoPan(NewMidX, NewMidY: Integer);
  public
    constructor Create(AChart: TCustomChart);
    destructor Destroy; override;

    property Enabled: Boolean read FEnabled write FEnabled;
    property ZoomMinFactor: Double read FZoomFactorMin write FZoomFactorMin;
    property ZoomMaxFactor: Double read FZoomFactorMax write FZoomFactorMax;
    property WheelZoomScale: Double read FWheelZoomScale write FWheelZoomScale;
  end;

implementation

{ TTChartTouchZoom }

constructor TTChartTouchZoom.Create(AChart: TCustomChart);
begin
  inherited Create;
  FChart := AChart;
  FEnabled := True;

  FLastDist := 0;
  FLastMidX := 0;
  FLastMidY := 0;

  FZoomFactorMin := 0.90;   // мінімальний крок (zoom-in)
  FZoomFactorMax := 1.10;   // максимальний крок (zoom-out)
  FWheelZoomScale := 1.05;  // колесо миші: ±5%

  FOldWndProc := FChart.WindowProc;
  FChart.WindowProc := NewWndProc;

  RegisterTouchWindow(FChart.Handle, 0);
end;

destructor TTChartTouchZoom.Destroy;
begin
  if Assigned(FChart) then
    FChart.WindowProc := FOldWndProc;
  inherited;
end;

procedure TTChartTouchZoom.NewWndProc(var Msg: TMessage);
begin
  case Msg.Msg of
    Winapi.Messages.WM_TOUCH:      WM_Touch(Msg);
    Winapi.Messages.WM_MOUSEWHEEL: WM_MouseWheel(Msg);
  end;

  FOldWndProc(Msg);
end;

procedure TTChartTouchZoom.Scroll(dx, dy: Integer);
var
  a: TChartAxis;
begin
  for var i := 0 to FChart.Axes.Count-1 do
  begin
    a := FChart.Axes[i];
    if a.Horizontal then
      a.Scroll(dx, False)
    else
      a.Scroll(dy, False);
  end;

//      tmp:=(Maximum-Minimum)*3.0*0.01;
//
//      if not Up then
//         tmp:=-tmp;
//
//      tmpAllow:=True;
//
//      if Assigned(FOnAllowScroll) then
//      begin
//        tmpMin:=Axes[t].Minimum+tmp;
//        tmpMax:=Axes[t].Maximum+tmp;
//
//        FOnAllowScroll(Axes[t],tmpMin,tmpMax,tmpAllow);
//      end;
//
//      if tmpAllow then
//         Scroll(tmp,False);
//    end;
//  end;

end;

procedure TTChartTouchZoom.WM_Touch(var Msg: TMessage);
var
  Inputs: array of TTouchInput;
  Count: Integer;
  X1, Y1, X2, Y2: Integer;
  dx, dy: Integer;
  Dist: Integer;
  MidX, MidY: Integer;
begin
  if not FEnabled then Exit;

  Count := Msg.WParam and $FFFF;
  if Count < 2 then
  begin
    FLastDist := 0;
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

    // масштабування
    DoPinchZoom(Dist);

    // панорамування
    DoPan(MidX, MidY);

    CloseTouchInputHandle(Msg.LParam);
  end;
end;

procedure TTChartTouchZoom.DoPinchZoom(NewDist: Integer);
var
  Factor: Double;
begin
  if FLastDist > 0 then
  begin
    // правильний zoom: розведення пальців -> збільшення → Factor > 1
    Factor := FLastDist / NewDist;

    // обмеження різкості зміни
    Factor := EnsureRange(Factor, FZoomFactorMin, FZoomFactorMax);

    DoZoom(Factor);
  end;

  FLastDist := NewDist;
end;

procedure TTChartTouchZoom.DoZoom(Factor: Double);
begin
  // ZoomPercent очікує зворотний коефіцієнт
  FChart.ZoomPercent(Round(100 * Factor));
end;

procedure TTChartTouchZoom.DoPan(NewMidX, NewMidY: Integer);
var
  dx, dy: Integer;
begin
  if FLastMidX <> 0 then
  begin
    dx := NewMidX - FLastMidX;
    dy := NewMidY - FLastMidY;
    Scroll(dx, dy);
    // рухаємо графік у протилежний бік, щоб виглядало природно
//    FChart.scro ScrollBy(-(dx), -(dy));
  end;

  FLastMidX := NewMidX;
  FLastMidY := NewMidY;
end;

procedure TTChartTouchZoom.WM_MouseWheel(var Msg: TMessage);
var
  Delta: Integer;
  Factor: Double;
begin
  Delta := SmallInt(HIWORD(Msg.WParam));

  if Delta > 0 then
    Factor := 1 / FWheelZoomScale   // zoom-in
  else
    Factor := FWheelZoomScale;      // zoom-out

  DoZoom(Factor);
end;

end.

