unit aOPCChartMessureTool;

{$I VCL.DC.inc}

interface

uses
  System.Classes, System.SysUtils, System.Types,
  Winapi.Windows, Controls,
{$IFDEF TEEVCL}
  VCLTee.Series, VCLTee.TeEngine, VCLTee.TeCanvas, VCLTee.TeeProcs, VCLTee.TeeTools,
{$ELSE}
  Series, TeEngine, TeCanvas, TeeProcs, TeeTools,
{$ENDIF}
  uDCObjects;

const
  TeeMsg_OPCMessureTool = 'Messure';
  TeeMsg_OPCMessureToolDesc = 'Allow messure series values.';

  TeeMsg_OPCMessureBandTool = 'Messure Band';
  TeeMsg_OPCMessureBandToolDesc = 'Allow select and messure series values.';

type
  TaOPCMessureLine = class(TColorLineTool)

  end;

  TaOPCMessureBand = class(TColorBandTool)
  private
    IDragging: Boolean;
    FShift: Double;
    FDragRepaint: Boolean;
    FNoLimitDrag: Boolean;
    FAllowDrag: Boolean;
    function Chart: TCustomAxisPanel;
  protected
    procedure ChartMouseEvent(AEvent: TChartMouseEvent; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
    function LimitValue(const AValue: Double): Double; // 7.0 moved from private
    function Clicked(X, Y: Integer): Boolean; // 6.02
  published
    property AllowDrag: Boolean read FAllowDrag write FAllowDrag default True;
    property DragRepaint: Boolean read FDragRepaint write FDragRepaint
      default True;
    property NoLimitDrag: Boolean read FNoLimitDrag write FNoLimitDrag
      default False;
  end;

  // TaOPCTextShape = class(TTextShape)
  // public
  //
  // end;

  TDCCustomMessureTool = class(TRectangleTool)
  protected
    FAxis: TChartAxis;
    procedure SetAxis(const Value: TChartAxis); virtual;

    function CalcSeriesValue(aSeries: TFastLineSeries; x: Double; var aValue: Double): Boolean;
    function GetSeriesValueStr(aSeries: TFastLineSeries; x: Double): string;
  published
    property Axis: TChartAxis read FAxis write SetAxis stored False;
  end;

  TaOPCMessureTool = class(TDCCustomMessureTool)
  private
    FLine: TaOPCMessureLine;
    function NewColorLine: TaOPCMessureLine;
    procedure DragLine(Sender: TColorLineTool);
  protected
    procedure SetAxis(const Value: TChartAxis); override;

    procedure PaintLine;
    procedure SetParentChart(const Value: TCustomAxisPanel); override;
    procedure ChartEvent(AEvent: TChartToolEvent); override;

    // procedure DoDrawText; overload; override;
    Procedure DoDrawText(const AParent: TCustomAxisPanel); overload; override;
    procedure ShapeDrawText(Panel: TCustomAxisPanel; R: TRect; XOffset, NumLines: Integer);
  public
    property Line: TaOPCMessureLine read FLine;

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    class function Description: String; override;
    class function LongDescription: String; override;

  end;

  TaOPCMessureBandTool = class(TDCCustomMessureTool)
  private
    FBand: TaOPCMessureBand;
    function NewBand: TaOPCMessureBand;
    procedure DragLine(Sender: TColorLineTool);
  protected
    procedure SetAxis(const Value: TChartAxis); override;
    // procedure PaintBand;
    procedure SetParentChart(const Value: TCustomAxisPanel); override;
    procedure ChartEvent(AEvent: TChartToolEvent); override;

    // procedure DrawText; overload; override;
    procedure DoDrawText(const AParent: TCustomAxisPanel); overload; override;
    procedure ShapeDrawText(Panel: TCustomAxisPanel; R: TRect; XOffset, NumLines: Integer);
  public
    property Band: TaOPCMessureBand read FBand;

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    class function Description: String; override;
    class function LongDescription: String; override;
  end;

implementation

uses
  aOPCUtils,
  aOPCLineSeries;

{ TaOPCMessureTool }

procedure TaOPCMessureTool.ChartEvent(AEvent: TChartToolEvent);
begin
  inherited;

  case AEvent of
    // cteBeforeDrawAxes: if DrawBehindAxes then PaintBand;
    cteBeforeDrawSeries:
      PaintLine;
    // cteAfterDraw: if (not DrawBehind) and (not DrawBehindAxes) then PaintBand;
  end;

end;

constructor TaOPCMessureTool.Create(AOwner: TComponent);
begin
  inherited;

  with Shape do
  begin
    Shadow.Size := 2;
    Transparency := 0;
    ShapeBounds.Left := 10;
    ShapeBounds.Top := 10;
    Width := 150;
    Height := 50;
  end;

  FLine := NewColorLine;
  FLine.Pen.Width := 0;
end;

class function TaOPCMessureTool.Description: String;
begin
  Result := TeeMsg_OPCMessureTool;
end;

destructor TaOPCMessureTool.Destroy;
begin
  FreeAndNil(FLine);
  inherited;
end;

procedure TaOPCMessureTool.DragLine(Sender: TColorLineTool);
// var
// tmpWidth: Integer;
begin
  // tmpWidth := Shape.Width;
  // Shape.Left := Axis.CalcPosValue(Line.Value) + 5;
  // Shape.Width := tmpWidth;
end;

procedure TaOPCMessureTool.DoDrawText(const AParent: TCustomAxisPanel);
var
  // tmpTo     : TPoint;
  // tmpMid    : TPoint;
  // tmpFrom   : TPoint;
  tmpR: TRect;
  tmpN, tmpX, tmpY: Integer;
begin
  Shape.Text := ''; //GetText;
  tmpR := GetTextBounds(tmpN, tmpX); // ,tmpY);
  // Shape.DrawText(ParentChart, tmpR, GetXOffset, tmpN);
  ShapeDrawText(ParentChart, tmpR, GetXOffset, tmpN);

  // with Callout do
  // if Visible or Arrow.Visible then
  // begin
  // tmpTo:=TeePoint(XPosition,YPosition);
  // tmpFrom:=CloserPoint(tmpR,tmpTo);
  //
  // if Distance<>0 then
  // tmpTo:=PointAtDistance(tmpFrom,tmpTo,Distance);
  //
  // tmpMid.X:=0;
  // tmpMid.Y:=0;
  //
  // {$IFDEF LCL}Self.Callout.{$ENDIF}Draw(clNone,tmpTo,tmpMid,tmpFrom,ZPosition);
  // end;
end;

class function TaOPCMessureTool.LongDescription: String;
begin
  Result := TeeMsg_OPCMessureToolDesc;
end;

function TaOPCMessureTool.NewColorLine: TaOPCMessureLine;
begin
  Result := TaOPCMessureLine.Create(nil);
  Result.Active := False;
  Result.DragRepaint := True;
  Result.OnDragLine := Self.DragLine;
  // result.Pen.OnChange := CanvasChanged;
  // Result.ParentChart := nil;
end;

procedure TaOPCMessureTool.PaintLine;
begin
  if Assigned(Axis) then
  begin
    if FLine.Active then
    begin
      // FLine.Value := StartValue;
      FLine.InternalDrawLine(False);
    end;
  end;
end;

procedure TaOPCMessureTool.SetAxis(const Value: TChartAxis);
begin
  FAxis := Value;
  FLine.Axis := Value;
end;

procedure TaOPCMessureTool.SetParentChart(const Value: TCustomAxisPanel);
begin
  inherited;

  if Assigned(FLine) then
    FLine.ParentChart := Value;
end;

procedure TaOPCMessureTool.ShapeDrawText(Panel: TCustomAxisPanel; R: TRect;
  XOffset, NumLines: Integer);
var
  X: Integer;
  t: Integer;
  // tmp   : String;
  tmpTop: Integer;
  tmpHeight: Integer;
  saveColor: Integer;
  // v: Double;
  vStr: string;
begin
  OffsetRect(R, Panel.ChartBounds.Left, Panel.ChartBounds.Top);

  if Shape.Visible then
{$IFDEF TEEVCL}
    Shape.Draw(Panel, R);
{$ELSE}
    Shape.DrawRectRotated(Panel, R);
{$ENDIF}

  With Panel.Canvas do
  begin
    if Self.ClipText then
      ClipRectangle(R);

    try
      BackMode := cbmTransparent;

      case TextAlignment of
        taLeftJustify:
          begin
            TextAlign := TA_LEFT;
            X := R.Left + Shape.Margins.Size.Left;

            if Self.Pen.Visible then
              Inc(X, Self.Pen.Width);
          end;
        taCenter:
          begin
            TextAlign := ta_Center;

            with R do
              X := 1 + ((Left + Shape.Margins.Size.Left + Right -
                Shape.Margins.Size.Right) div 2);
          end;
      else
        begin
          TextAlign := ta_Right;
          X := R.Right - Shape.Margins.Size.Right;
        end;
      end;

      AssignFont(Shape.Font);
      tmpHeight := FontHeight;

      tmpTop := R.Top + Shape.Margins.Size.Top;
      TextOut(X + XOffset, tmpTop, FormatDateTime('dd.mm.yyyy HH:MM:SS',
        FLine.Value), Shape.TextFormat = ttfHtml);

      saveColor := Font.Color;
      for t := 0 to ParentChart.SeriesCount - 1 do
      begin
        if ParentChart.Series[t] is TaOPCLineSeries then
        begin
          //vStr := TaOPCLineSeries(ParentChart.Series[t]).GetSerieValueStr(FLine.Value);
          vStr := TaOPCLineSeries(ParentChart.Series[t]).GetSerieValueAndDurationStr(FLine.Value, True);
          Font.Color := ParentChart.Series[t].Color;
          TextOut(X + XOffset, tmpTop + (t + 1) * tmpHeight, vStr, Shape.TextFormat = ttfHtml);
        end;
      end;
      Font.Color := saveColor;

      if (ParentChart.SeriesCount + 1) * tmpHeight + 5 > Shape.Height then
        Shape.Height := (ParentChart.SeriesCount + 1) * tmpHeight + 5;

    finally
      if Shape.ClipText then
        UnClipRectangle;
    end;
  end;
end;

{ TaOPCMessureBandTool }

// procedure TaOPCMessureBandTool.ChartEvent(AEvent: TChartToolEvent);
// begin
// inherited;
//
// end;

function TDCCustomMessureTool.CalcSeriesValue(aSeries: TFastLineSeries; x: Double; var aValue: Double): Boolean;
var
  i: Integer;
  i1,i2: Integer;
begin
  i2 := -1;
  // ищем время больше заданного (возможен бинарный поиск, т.к. время только возрастает)
  for i := 0 to aSeries.XValues.Count - 1 do
  begin
    // нашли точное соотверствие
    if aSeries.XValues[i] = x then
    begin
      aValue := aSeries.YValues[i];
      Exit(True);
    end;
    // нашли индекс точки с большим временем
    if aSeries.XValues[i] > x then
    begin
      i2 := i;
      Break;
    end;
  end;

  // все точки имеют МЕНЬШЕЕ время
  if i2 = -1 then
    Exit(False);

  // все точки имеют БОЛЬШЕЕ время
  if i2 = 0 then
    Exit(False);

  // мы что-то нашли
  Result := True;
  // результат где-то между i1 и i2
  i1 := i2 - 1;
  if (aSeries.Stairs) or (aSeries.YValues[i1] = aSeries.YValues[i2]) then
    aValue := aSeries.YValues[i1]
  else
  begin
    // y = y2 - (y2-y1)*(x2-x)/(x2-x1)
    aValue := aSeries.YValues[i2] - (aSeries.YValues[i2] - aSeries.YValues[i1])*
      (aSeries.XValues[i2] - x)/(aSeries.XValues[i2] - aSeries.XValues[i1]);
  end;


end;

function TDCCustomMessureTool.GetSeriesValueStr(aSeries: TFastLineSeries; x: Double): string;
var
  v: Double;
begin
  if not CalcSeriesValue(aSeries, x, v) then
    Result := ''
  else
    Result := FormatFloat(Axis.AxisValuesFormat, v);
end;

procedure TDCCustomMessureTool.SetAxis(const Value: TChartAxis);
begin
  FAxis := Value;
end;

procedure TaOPCMessureBandTool.ChartEvent(AEvent: TChartToolEvent);
begin
  inherited;

  case AEvent of
    // cteBeforeDrawAxes: if DrawBehindAxes then PaintBand;
    cteBeforeDrawSeries:
      Band.ChartEvent(cteBeforeDrawSeries); // PaintBand;
    cteAfterDraw:
      DoDrawText;
    // cteAfterDraw: if (not DrawBehind) and (not DrawBehindAxes) then PaintBand;
  end;
end;

constructor TaOPCMessureBandTool.Create(AOwner: TComponent);
begin
  inherited;

  with Shape do
  begin
    Shadow.Size := 2;
    Transparency := 0;
    ShapeBounds.Left := 10;
    ShapeBounds.Top := 10;
    Width := 300;
    Height := 40;

  end;
  FBand := NewBand;
  FBand.StartLine.Pen.Width := 0;
  FBand.EndLine.Pen.Width := 0;
end;

class function TaOPCMessureBandTool.Description: String;
begin
  Result := TeeMsg_OPCMessureBandTool;
end;

destructor TaOPCMessureBandTool.Destroy;
begin
  FreeAndNil(FBand);
  inherited;
end;

procedure TaOPCMessureBandTool.DragLine(Sender: TColorLineTool);
begin

end;

procedure TaOPCMessureBandTool.DoDrawText(const AParent: TCustomAxisPanel);
var
  tmpR: TRect;
  tmpN, tmpX, tmpY: Integer;
begin
  Shape.Text := ''; //GetText;
  tmpR := GetTextBounds(tmpN, tmpX); // ,tmpY);
  ShapeDrawText(ParentChart, tmpR, GetXOffset, tmpN);
end;

class function TaOPCMessureBandTool.LongDescription: String;
begin
  Result := TeeMsg_OPCMessureBandToolDesc;
end;

function TaOPCMessureBandTool.NewBand: TaOPCMessureBand;
begin
  Result := TaOPCMessureBand.Create(nil);
  Result.Active := False;

  Result.StartLine.DragRepaint := True;
  // result.StartLine.OnDragLine := Self.DragLine;

  Result.EndLine.DragRepaint := True;
  // result.EndLine.OnDragLine := Self.DragLine;
end;

// procedure TaOPCMessureBandTool.PaintBand;
// begin
// if Assigned(Axis) then
// begin
// if FBand.Active then
// begin
/// /      FLine.Value := StartValue;
// FBand.InternalDrawBand(False);
// end;
// end;
// end;

procedure TaOPCMessureBandTool.SetAxis(const Value: TChartAxis);
begin
  FAxis := Value;
  Band.Axis := Value;
end;

procedure TaOPCMessureBandTool.SetParentChart(const Value: TCustomAxisPanel);
begin
  inherited;

  if Assigned(FBand) then
    FBand.ParentChart := Value;
end;

procedure TaOPCMessureBandTool.ShapeDrawText(Panel: TCustomAxisPanel; R: TRect;
  XOffset, NumLines: Integer);
var
  X: Integer;
  t: Integer;
  tmpTop: Integer;
  tmpHeight: Integer;
  saveColor: Integer;
  vStr: string;
  aText: string;
  xLeft, xRight, xCenter: Integer;
  v1, v2: Double;
  aSeries: TaOPCLineSeries;
  function TimeView(aTime: TDateTime): string;
  begin
    if aTime < 1 then
      Result := FormatDateTime('HH:MM:SS', aTime)
    else
      Result := FormatFloat('# ##0.## д.', aTime);
  end;

begin
  OffsetRect(R, Panel.ChartBounds.Left, Panel.ChartBounds.Top);

  if Shape.Visible then
{$IFDEF TEEVCL}
    Shape.Draw(Panel, R);
{$ELSE}
    Shape.DrawRectRotated(Panel, R);
{$ENDIF}

  With Panel.Canvas do
  begin
    if Self.ClipText then
      ClipRectangle(R);

    try
      BackMode := cbmTransparent;

      xLeft := R.Left + Shape.Margins.Size.Left;
      if Self.Pen.Visible then
        Inc(xLeft, Self.Pen.Width);

      xRight := R.Right - Shape.Margins.Size.Right;
      xCenter := 1 + ((R.Left + Shape.Margins.Size.Left + R.Right - Shape.Margins.Size.Right) div 2);

      AssignFont(Shape.Font);
      tmpHeight := FontHeight;

      tmpTop := R.Top + Shape.Margins.Size.Top;

      if Axis.IsDateTime then
      begin
        TextAlign := TA_LEFT;
        TextOut(xLeft + XOffset, tmpTop, FormatDateTime('dd.mm.yyyy HH:MM:SS', Band.StartValue), Shape.TextFormat = ttfHtml);

        TextAlign := ta_Center;
        TextOut(xCenter, tmpTop, TimeView(Band.EndValue - Band.StartValue), Shape.TextFormat = ttfHtml);

        TextAlign := ta_Right;
        TextOut(xRight, tmpTop, FormatDateTime('dd.mm.yyyy HH:MM:SS', Band.EndValue), Shape.TextFormat = ttfHtml);
      end
      else
      begin
        TextAlign := TA_LEFT;
        TextOut(xLeft + XOffset, tmpTop, FormatFloat(Axis.AxisValuesFormat, Band.StartValue), Shape.TextFormat = ttfHtml);

        TextAlign := ta_Center;
        TextOut(xCenter, tmpTop, FormatFloat(Axis.AxisValuesFormat, Band.EndValue - Band.StartValue), Shape.TextFormat = ttfHtml);

        TextAlign := ta_Right;
        TextOut(xRight, tmpTop, FormatFloat(Axis.AxisValuesFormat, Band.EndValue), Shape.TextFormat = ttfHtml);
      end;


      // aText :=
      // '<table>'+
      // '<tr>'+
      // '<td>'+FormatDateTime('dd.mm.yyyy HH:MM:SS', Band.StartValue)+'</td>'+
      // '<td>'+FormatDateTime('dd.mm.yyyy HH:MM:SS', Band.StartValue)+'</td>'+
      // '</tr>'+
      // '</table>';
      // TextOut( x+XOffset,
      // tmpTop,
      // aText,
      // True);

      saveColor := Font.Color;
      var aLineCount: Integer := 1;
      for t := 0 to ParentChart.SeriesCount - 1 do
      begin
        if not ParentChart.Series[t].Visible then
          Continue;

        if ParentChart.Series[t] is TaOPCLineSeries then
        begin
          aSeries := TaOPCLineSeries(ParentChart.Series[t]);
          Font.Color := aSeries.Color;
          // Font.Color := ParentChart.Series[t].Color;

          vStr := aSeries.GetSerieValueStr(Band.StartValue);
          TextAlign := TA_LEFT;
          TextOut(xLeft + XOffset, tmpTop + aLineCount * tmpHeight, vStr,
            Shape.TextFormat = ttfHtml);

          vStr := aSeries.GetSerieValueStr(Band.EndValue);
          TextAlign := ta_Right;
          TextOut(xRight - XOffset, tmpTop + aLineCount * tmpHeight, vStr,
            Shape.TextFormat = ttfHtml);

          if aSeries.CalcSeriesValue(Band.StartValue, v1) and aSeries.CalcSeriesValue(Band.EndValue, v2) then
          begin
            vStr := FormatFloat(aSeries.DisplayFormat, v2 - v1);
            TextAlign := ta_Center;
            TextOut(xCenter, tmpTop + aLineCount * tmpHeight, vStr, Shape.TextFormat = ttfHtml);
          end
        end
        else if ParentChart.Series[t] is TFastLineSeries then
        begin
          var s := TFastLineSeries(ParentChart.Series[t]);
          Font.Color := s.Color;
          // Font.Color := ParentChart.Series[t].Color;

          vStr := GetSeriesValueStr(s, Band.StartValue);
          TextAlign := TA_LEFT;
          TextOut(xLeft + XOffset, tmpTop + aLineCount * tmpHeight, vStr, Shape.TextFormat = ttfHtml);

          vStr := GetSeriesValueStr(s, Band.EndValue);
          TextAlign := ta_Right;
          TextOut(xRight - XOffset, tmpTop + aLineCount * tmpHeight, vStr, Shape.TextFormat = ttfHtml);

          if CalcSeriesValue(s, Band.StartValue, v1) and CalcSeriesValue(s, Band.EndValue, v2) then
          begin
            vStr := FormatFloat(Axis.AxisValuesFormat, v2 - v1); // FloatToStr(v2 - v1); //FormatFloat(aSeries.DisplayFormat, v2 - v1);
            TextAlign := ta_Center;
            TextOut(xCenter, tmpTop + aLineCount * tmpHeight, vStr, Shape.TextFormat = ttfHtml);
          end
        end;
        Inc(aLineCount);
      end;

      Font.Color := saveColor;

      //if aLineCount * tmpHeight + 5 > Shape.Height then
        Shape.Height := aLineCount * tmpHeight + 5;

    finally
      if Shape.ClipText then
        UnClipRectangle;
    end;
  end;
end;

{ TaOPCMessureBand }

function TaOPCMessureBand.Chart: TCustomAxisPanel;
begin
  Result := StartLine.ParentChart;
  if not Assigned(Result) then
    Result := ParentChart;
end;

procedure TaOPCMessureBand.ChartMouseEvent(AEvent: TChartMouseEvent;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  tmp: Integer;
  tmpNew: Double;
  tmpDoDraw: Boolean;
begin
  // inherited;
  // Exit;

  if not IDragging then
  begin
    if StartLine.Active then
      TaOPCMessureLine(StartLine).ChartMouseEvent(AEvent, Button, Shift, X, Y);

    if EndLine.Active and (not ParentChart.CancelMouse) then
      TaOPCMessureLine(EndLine).ChartMouseEvent(AEvent, Button, Shift, X, Y);
  end;

  if ParentChart.CancelMouse then
    Exit;

  tmpDoDraw := False;

  if AllowDrag and Assigned(Axis) then
  begin
    case AEvent of
      cmeUp:
        if IDragging then // 7.0
        begin
          { force repaint }
          if not FDragRepaint then
            Repaint;

          { call event }
          // DoEndDragLine;

          IDragging := False;
        end;
      cmeMove:
        begin
          if IDragging then
          begin
            if Axis.Horizontal then
              tmp := X
            else
              tmp := Y;

            { calculate new position }
            tmpNew := Axis.CalcPosPoint(tmp);

            { check inside axis limits }
            if not NoLimitDrag then // (already implicit AllowDrag=True)
              tmpNew := LimitValue(tmpNew);

            tmpNew := tmpNew - FShift;

            // if FDragRepaint then { 5.02 }
            begin
              // Value := tmpNew { force repaint whole chart }
              EndValue := (tmpNew - StartValue) + EndValue;
              StartValue := tmpNew;
            end;
            // else
            // begin
            //
            // tmpDoDraw := CalcValue <> tmpNew;
            //
            // if tmpDoDraw then
            // begin
            // { draw line in xor mode, to avoid repaint the whole chart }
            // with Chart.Canvas do
            // begin
            // AssignVisiblePen(Self.Pen);
            // Pen.Mode := pmNotXor;
            // end;
            //
            // { hide previous line }
            // DrawColorLine(True);
            // DrawColorLine(False);
            //
            // { set new value }
            // FStyle := clCustom;
            // FValue := tmpNew;
            // end;
            // end;

            Chart.CancelMouse := True;

            { call event, allow event to change Value }
            // if Assigned(FOnDragLine) then
            // FOnDragLine(Self);

            // if tmpDoDraw then { 5.02 }
            // begin
            // { draw at new position }
            // DrawColorLine(True);
            // DrawColorLine(False);
            //
            // { reset pen mode }
            // Chart.Canvas.Pen.Mode := pmCopy;
            // end;
          end
          else
          begin
            // is mouse on band?
            if Clicked(X, Y) then
            // or StartLine.Clicked(X, Y) or EndLine.Clicked(X, Y) then
            begin
              Chart.CancelMouse := (not ParentChart.Panning.Active) and
                (not ParentChart.Zoom.Active);
              if Chart.CancelMouse then
                Chart.Cursor := crHandPoint;
            end
            // else if StartLine.Clicked(X, Y) or EndLine.Clicked(X, Y) then
            // begin
            // { show appropiate cursor }
            // if Axis.Horizontal then
            // Chart.Cursor:=crHSplit
            // else
            // Chart.Cursor:=crVSplit;
            // Chart.CancelMouse:=True;
            // //Chart.CancelMouse := (not ParentChart.IPanning.Active) and (not ParentChart.Zoom.Active);
            // end;

          end;
        end;
      cmeDown:
        begin
          if Button = mbLeft then
          begin
            { is mouse over? }
            IDragging := Clicked(X, Y);
            Chart.CancelMouse := IDragging;

            if Axis.Horizontal then
              tmp := X
            else
              tmp := Y;

            { calculate new position }
            FShift := Axis.CalcPosPoint(tmp) - StartValue;

            // if IDragging and Assigned(FOnBeginDragLine) then // 7.0
            // FOnBeginDragLine(Self);
          end;

          // if Assigned(FOnClick) and Clicked(X, Y) then
          // FOnClick(Self, Button, Shift, X, Y);

        end;
    end;
  end;
end;

function TaOPCMessureBand.Clicked(X, Y: Integer): Boolean;
var
  R: TRect;
  P: TFourPoints;
begin
  // ParentChart.Canvas.FourPointsFromRect(BoundsRect,ZPosition,P);
  // result:=PointInPolygon(TeePoint(X,Y),P);

  R := BoundsRect;
  InflateRect(R, -StartLine.Pen.Width, 0);
  ParentChart.Canvas.FourPointsFromRect(R, ZPosition, P);
  Result := PointInPolygon(TeePoint(X, Y), P);
end;

constructor TaOPCMessureBand.Create(AOwner: TComponent);
begin
  inherited;
  FAllowDrag := True;
  FNoLimitDrag := False;
  FDragRepaint := True;
end;

function TaOPCMessureBand.LimitValue(const AValue: Double): Double;
var
  tmpLimit: Double;
  tmpStart: Integer;
  tmpEnd: Integer;
begin
  Result := AValue;

  tmpStart := Axis.IEndPos; // 6.01 Fix for Inverted axes
  tmpEnd := Axis.IStartPos;
  if Axis.Horizontal then
    SwapInteger(tmpStart, tmpEnd);
  if Axis.Inverted then
    SwapInteger(tmpStart, tmpEnd);

  // do not use Axis Minimum & Maximum, we need the "real" min and max
  tmpLimit := Axis.CalcPosPoint(tmpStart);
  if Result < tmpLimit then
    Result := tmpLimit
  else
  begin
    tmpLimit := Axis.CalcPosPoint(tmpEnd);
    if Result > tmpLimit then
      Result := tmpLimit;
  end;
end;

end.
