unit TeeChartTouchZoom;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Classes, System.Math,
  Vcl.Controls, Vcl.Forms,
  VCLTee.TeeProcs, VCLTee.Chart;

type
  TTChartTouchZoom = class
  private
    FChart: TCustomChart;
    FLastDist: Integer;
    FEnabled: Boolean;
    FOldWndProc: TWndMethod;

    FZoomFactorMin: Double;
    FZoomFactorMax: Double;
    FWheelZoomScale: Double; // коефіцієнт zoom при колесі миші

    procedure NewWndProc(var Msg: TMessage);
    procedure WM_Touch(var Msg: TMessage);
    procedure DoZoomByFactor(Factor: Double);
    procedure DoPinchZoom(NewDist: Integer);
    procedure WM_MouseWheel(var Msg: TMessage);
  public
    constructor Create(AChart: TCustomChart);
    destructor Destroy; override;

    property Enabled: Boolean read FEnabled write FEnabled;

    // Зовнішні параметри
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

  // межі коефіцієнтів zoom (захист від надто різкого масштабу)
  FZoomFactorMin := 0.90;   // мінімальний коеф. за одну подію
  FZoomFactorMax := 1.10;   // максимальний коеф. за одну подію

  FWheelZoomScale := 1.05;  // колесо миші ±5%

  // перехоплюємо wndproc Chart
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
//  WM_TOUCH
  case Msg.Msg of
    Winapi.Messages.WM_TOUCH:
      WM_Touch(Msg);

    Winapi.Messages.WM_MOUSEWHEEL:
      WM_MouseWheel(Msg);
  end;

  FOldWndProc(Msg);
end;

procedure TTChartTouchZoom.WM_Touch(var Msg: TMessage);
var
  Inputs: array of TTouchInput;
  Count: Integer;
  X1, Y1, X2, Y2: Integer;
  dx, dy: Integer;
  Dist: Integer;
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

    DoPinchZoom(Dist);

    CloseTouchInputHandle(Msg.LParam);
  end;
end;

procedure TTChartTouchZoom.DoPinchZoom(NewDist: Integer);
var
  Factor: Double;
begin
  if FLastDist > 0 then
  begin
    // справжній коефіцієнт zoom
    Factor := NewDist / FLastDist;

    // обмеження
    Factor := EnsureRange(Factor, FZoomFactorMin, FZoomFactorMax);

    DoZoomByFactor(Factor);
  end;

  FLastDist := NewDist;
end;

procedure TTChartTouchZoom.DoZoomByFactor(Factor: Double);
begin
  // ZoomPercent очікує значення в %
  FChart.ZoomPercent(Round(100 / Factor));
end;

procedure TTChartTouchZoom.WM_MouseWheel(var Msg: TMessage);
var
  Delta: Integer;
  Factor: Double;
begin
  Delta := SmallInt(HIWORD(Msg.WParam));

  if Delta > 0 then
    Factor := 1 / FWheelZoomScale  // Zoom In
  else
    Factor := FWheelZoomScale;     // Zoom Out

  DoZoomByFactor(Factor);
end;

end.

