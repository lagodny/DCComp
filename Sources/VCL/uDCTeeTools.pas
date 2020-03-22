unit uDCTeeTools;

{$I VCL.DC.inc}

interface

uses
  System.Classes, System.Types, Winapi.Windows,
  {$IFDEF TEEVCL}
  VCLTee.TeeTools, VCLTee.TeCanvas, VCLTee.TeEngine,
  {$ELSE}
  TeeTools, TeCanvas, TeEngine,
  {$ENDIF}
  aOPCLabel;

type
  TDCTextColorBandTool = class(TColorBandTool)
  private
    FText: string;
    FFont: TTeeFont;
    FTextOrientation: Integer;
    procedure SetText(const Value: string);
    procedure SetFont(const Value: TTeeFont);
  protected
    procedure ChartEvent(AEvent: TChartToolEvent); override;
    procedure DrawDCText;
    function GetDisplayText(r: TRect): string;
  public
    Constructor Create(AOwner: TComponent); override;
    Destructor Destroy; override;
  published
    property Font:TTeeFont read FFont write SetFont;
    property Text: string read FText write SetText;
    property TextOrientation: Integer read FTextOrientation write FTextOrientation;
  end;

implementation

uses
  TeeHyphen;

{ TDCTextColorBandTool }

procedure TDCTextColorBandTool.ChartEvent(AEvent: TChartToolEvent);
begin
  inherited;

  case AEvent of
   cteBeforeDrawAxes: if DrawBehindAxes then DrawDCText;
   cteBeforeDrawSeries: if DrawBehind and (not DrawBehindAxes) then DrawDCText;
   cteAfterDraw: if (not DrawBehind) and (not DrawBehindAxes) then DrawDCText;
  end;

//  DrawDCText;

end;

constructor TDCTextColorBandTool.Create(AOwner: TComponent);
begin
  inherited;
  FFont:=TTeeFont.Create(CanvasChanged);
end;

destructor TDCTextColorBandTool.Destroy;
begin
  FFont.Free;
  inherited;
end;

procedure TDCTextColorBandTool.DrawDCText;
var
  r: TRect;
  t: String;
  h: Integer;
begin
  r := BoundsRect();
  InflateRect(r, -1, -1);
  ParentChart.Canvas.BackMode:=cbmTransparent;
  ParentChart.Canvas.Font.Assign(Font);

  if TextOrientation = 0 then
  begin
    t := GetDisplayText(r);
    DrawText(ParentChart.Canvas.Handle, PChar(t), Length(t), r, DT_WORDBREAK + DT_CENTER);
  end
  else
  begin
    t := Text;
    h := Abs(ParentChart.Canvas.Font.Height);

    if r.Width > 3 then
    begin
      if (r.Width < h) then
      begin
        ParentChart.Canvas.Font.Height := -(r.Width+2);
        h := Abs(ParentChart.Canvas.Font.Height);
      end;

      if TextOrientation = -90 then
        ParentChart.Canvas.RotateLabel(r.Left + (r.Width + h + 2) div 2, r.Top, t, TextOrientation)
      else if TextOrientation = 90 then
        ParentChart.Canvas.RotateLabel(r.Right - (r.Width + h + 2) div 2, r.Bottom, t, TextOrientation);
    end;
  end;


  //ParentChart.Canvas.Font.Orientation := -900; //TextOrientation;

  //TextOut(r.Left, r.Top, Text, False);
end;

function TDCTextColorBandTool.GetDisplayText(r: TRect): string;
var
  Strs: TStrings;
  t:string;
begin
  Strs := TStringList.Create;
  try
    HyphenParagraph(Text, Strs, r.Width, ParentChart.Canvas);
    t := Strs.Text;
    Result := Copy(t,1,Length(t)-2);
  finally
    Strs.Free;
  end;
end;

procedure TDCTextColorBandTool.SetFont(const Value: TTeeFont);
begin
  FFont.Assign(Value);
end;

procedure TDCTextColorBandTool.SetText(const Value: string);
begin
  FText := Value;
end;

end.
