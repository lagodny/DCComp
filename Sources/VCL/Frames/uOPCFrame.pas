{*******************************************************}
{                                                       }
{     Copyright (c) 2001-2017 by Alex A. Lagodny        }
{                                                       }
{*******************************************************}

unit uOPCFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, IniFiles,
  uDCObjects, aOPCLabel,
  aCustomOPCSource, aOPCImage, aOPCLookupList, aOPCImageList;

const
  sSerieIdent = 'serie';
  sShowDetail = 'detail';


type
  TaOPCFrame = class(TFrame)
  private
    OriginalLeft, OriginalTop, OriginalWidth, OriginalHeight: integer;

    FAllowClick: boolean;
    FDragImages: TDragImageList;
  protected
    FID: TPhysID;
    Scale: extended;
    procedure ChangeScale(M, D: integer); override;
    procedure Loaded; override;

    function GetDragImages: TDragImageList; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: integer); override;

    procedure SetAllowClick(const Value: boolean); virtual;

    // стандартный вариант отображения метки
    procedure CommonDrawLabel(Sender: TObject; aCanvas: TCanvas; var aText: string; var aHandled: Boolean); virtual;

    // методы для переопределения в наследниках
    procedure SetID(const Value: TPhysID); virtual;
    procedure ClearIDs; virtual;

    procedure SetOPCSource(const Value: TaCustomMultiOPCSource); virtual; abstract;
    function GetOPCSource: TaCustomMultiOPCSource; virtual; abstract;
  public
    FMouseDownX, FMouseDownY: integer;
    procedure UpdateOriginalPosition;

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    // универсальная инициализация меток
    procedure InitLabels(aAddToChart: TNotifyEvent; aShowDetail: TNotifyEvent); virtual;
    procedure DrawLabel(Sender: TObject; aCanvas: TCanvas; var aText: string; var aHandled: Boolean); virtual;

    procedure CheckForNewLookup(aCustomIniFile: TCustomIniFile); virtual;
    procedure ClearAnimateComp;
    procedure StopAnimate;
    procedure LocalInit(aId: integer; aOPCObjects: TDCObjectList); virtual;
    procedure SetBackColor(aColor: TColor); virtual;
    procedure SetLabelColor(aColor: TColor); virtual;
  published
    property ID: TPhysID read FID write SetID stored false;
    property AllowClick: boolean read FAllowClick write SetAllowClick;
    property OPCSource: TaCustomMultiOPCSource read GetOPCSource write SetOPCSource;
  end;

  TaOPCFrameClass = class of TaOPCFrame;

implementation

uses
  aOPCDataObject,
  aOPCConsts,
  math;

const
  сOPCErrorBrushColor = clYellow;
  cOPCErrorFontColor = clRed;
  cOPCZeroValueFontColor = clGray;



{$R *.dfm}
{ TaOPCFrame }

procedure TaOPCFrame.ChangeScale(M, D: integer);
begin
  inherited;
  {
    DisableAlign;
    try
    if M <> D then
    begin
    if SameValue(D/M,Scale,0.001) then
    begin
    Scale := 1;
    SetBounds(OriginalLeft,OriginalTop,OriginalWidth,OriginalHeight);
    end
    else
    begin
    Scale := Scale * M/D;
    SetBounds(Round(OriginalLeft*Scale),Round(OriginalTop*Scale),
    Round(OriginalWidth*Scale),Round(OriginalHeight*Scale));
    end;
    end;
    finally
    EnableAlign;
    end;
  }
end;

procedure TaOPCFrame.CheckForNewLookup(aCustomIniFile: TCustomIniFile);
var
  i: integer;
begin
  for i := 0 to ComponentCount - 1 do
    if Components[i] is TaOPCLookupList then
    begin
      if Assigned(TaOPCLookupList(Components[i]).OPCSource) and (TaOPCLookupList(Components[i]).TableName <> '') then
        TaOPCLookupList(Components[i]).CheckForNewLookup(aCustomIniFile);
    end;
end;

procedure TaOPCFrame.ClearAnimateComp;
var
  i: integer;
begin
  for i := 0 to ComponentCount - 1 do
    if Components[i] is TaOPCImage then
      if TaOPCImage(Components[i]).PhysID <> '' then
        TaOPCImage(Components[i]).Value := '';
end;

procedure TaOPCFrame.ClearIDs;
begin

end;

constructor TaOPCFrame.Create(AOwner: TComponent);
begin
  inherited;

end;

destructor TaOPCFrame.Destroy;
begin
  FDragImages.Free;
  inherited;
end;

procedure TaOPCFrame.DrawLabel(Sender: TObject; aCanvas: TCanvas; var aText: string; var aHandled: Boolean);
begin
  aHandled := False;
  if not (Sender is TaOPCLabel) then
    Exit;

  // нет ошибок
  if TaOPCLabel(Sender).ErrorCode = 0 then
  begin
    if TaOPCLabel(Sender).Value = '0' then
      aCanvas.Font.Color := cOPCZeroValueFontColor;
  end
  else
  // есть ошибка - выделяем
  begin
    aCanvas.Brush.Color := сOPCErrorBrushColor;  // clYellow;
    aCanvas.Font.Style := aCanvas.Font.Style + [fsStrikeOut];
    aCanvas.Font.Color := cOPCErrorFontColor;
  end;
end;

procedure TaOPCFrame.CommonDrawLabel(Sender: TObject; aCanvas: TCanvas; var aText: string; var aHandled: Boolean);
var
  aLabel: TaOPCLabel;
  aBlink: Boolean;
begin
  aHandled := False;
  if not (Sender is TaOPCLabel) then
    Exit;

  aLabel := TaOPCLabel(Sender);

  // нет ошибок
  if TaOPCLabel(Sender).ErrorCode = 0 then
  begin

    aBlink := False;
    if Sender is TaOPCBlinkLabel then
    begin
      aBlink := aLabel.Ranges.Check(aLabel.Value) in [rcrAlarmLowLevel, rcrAlarmHighLevel];
      TaOPCBlinkLabel(Sender).Blink := aBlink;
    end;

    if not aBlink then
    begin
      case aLabel.Ranges.Check(aLabel.Value) of
        rcrOk: ;

        rcrWarnLowLevel:
          aCanvas.Brush.Color := $00FFDFBF;

        rcrWarnHighLevel:
          aCanvas.Brush.Color := $00BFFFFF;

        rcrAlarmLowLevel:
          aCanvas.Brush.Color := $00FFB871;

        rcrAlarmHighLevel:
          aCanvas.Brush.Color := $00B0B0FF;

        rcrConvertError:
          ;

      end;
    end;

    if TaOPCLabel(Sender).Value = '0' then
      aCanvas.Font.Color := cOPCZeroValueFontColor;
  end
  else
  // есть ошибка - выделяем
  begin
    aCanvas.Brush.Color := сOPCErrorBrushColor;  // clYellow;
    aCanvas.Font.Style := aCanvas.Font.Style + [fsStrikeOut];
    aCanvas.Font.Color := cOPCErrorFontColor;
  end;
end;

function TaOPCFrame.GetDragImages: TDragImageList;
var
  i: integer;
  B: TBitmap;
  aCanvas: TCanvas;
begin
  if not Assigned(FDragImages) then
    FDragImages := TDragImageList.Create(nil);
  Result := FDragImages;
  Result.Clear;
  B := TBitmap.Create;
  try
    B.Height := Height;
    B.Width := Width;
    B.Canvas.Brush.Color := clLime;
    B.Canvas.FillRect(B.Canvas.ClipRect);

    aCanvas := TCanvas.Create;
    try
      aCanvas.Handle := GetDC(Handle);

      B.Canvas.CopyRect(Rect(0, 0, Width, Height), aCanvas, Rect(0, 0, Width, Height));
    finally
      aCanvas.Free;
    end;
    // B.Canvas.Rectangle(0,0,Width,Height);
    Result.Width := B.Width;
    Result.Height := B.Height;
    i := Result.AddMasked(B, clLime);
    Result.SetDragImage(i, FMouseDownX, FMouseDownY);
  finally
    B.Free;
  end
end;

procedure TaOPCFrame.InitLabels(aAddToChart: TNotifyEvent; aShowDetail: TNotifyEvent);
var
  i: Integer;
  o: TaCustomOPCDataObject;
begin
  for i := 0 to ComponentCount - 1 do
    if Components[i] is TaCustomOPCDataObject then
    begin
      o := TaCustomOPCDataObject(Components[i]);
      // метки, которые показывают цифры
      if o.PhysID <> '' then
      begin
        o.Cursor := crHandPoint;
        //o.OnClick := AddToChart;
        o.OnClick := aAddToChart;

        if o.ErrorHint = '' then
          o.ErrorHint := 'Ошибка: %s';

        if o is TaCustomOPCLabel then
          TaCustomOPCLabel(o).OnDrawLabel := CommonDrawLabel;
      end;

      if o.Params.Count > 0 then
      begin
        // метки которые можно развернуть
        if o.Params.Names[0] <> sSerieIdent then
        //if o.Params.Names[0] = sShowDetail then
        begin
          o.Cursor := crHandPoint;
          if not Assigned(o.OnClick) then
            o.OnClick := aShowDetail;
          if o is TaOPCLabel then
            TaOPCLabel(o).Font.Style := TaOPCLabel(o).Font.Style + [fsUnderline];
        end;

        // если подсказки не заданы, но указано наименование серии, то используем его как подсказку
        if (o.Hints.Count = 0) and (o.Params.Values[sSerieIdent] <> '') then
        begin
          o.Hints.Add('0=' + o.Params.Values[sSerieIdent]);
          o.Hint := o.Params.Values[sSerieIdent];
        end;

      end;
    end;
end;

procedure TaOPCFrame.Loaded;
begin
  inherited;
  UpdateOriginalPosition;
end;

procedure TaOPCFrame.LocalInit(aId: integer; aOPCObjects: TDCObjectList);
begin
  ClearIDs;
end;

procedure TaOPCFrame.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: integer);
begin
  FMouseDownX := X;
  FMouseDownY := Y;
  inherited;
end;

procedure TaOPCFrame.SetAllowClick(const Value: boolean);
begin
  FAllowClick := Value;
end;

procedure TaOPCFrame.SetBackColor(aColor: TColor);
begin
  Color := aColor;
end;

procedure TaOPCFrame.SetID(const Value: TPhysID);
begin
  FID := Value;
  ClearIDs;
end;

procedure TaOPCFrame.SetLabelColor(aColor: TColor);
var
  i: Integer;
begin
  inherited;
  for i := 0 to ComponentCount - 1 do
  begin
    if Components[i] is TaOPCFrame then
      TaOPCFrame(Components[i]).SetLabelColor(aColor)

    else if Components[i] is TaOPCLabel then
    begin
      if TaCustomOPCLabel(Components[i]).Params.Values['isLabel'] = '1' then
        TaOPCLabel(Components[i]).Font.Color := aColor;
    end;

  end;
end;

procedure TaOPCFrame.StopAnimate;
var
  i: integer;
begin
  for i := ComponentCount - 1 downto 0 do
    if Components[i] is TaOPCImageList then
      Components[i].Free;
end;

procedure TaOPCFrame.UpdateOriginalPosition;
begin
  OriginalLeft := Left;
  OriginalTop := Top;
  OriginalWidth := Width;
  OriginalHeight := Height;
  Scale := 1;
end;

end.
