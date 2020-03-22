unit aOPCStateLine;

interface
uses
  SysUtils, Windows, Messages, Classes, Graphics,
  Controls, Forms, StdCtrls, //Gauges,
  aCustomOPCSource, aOPCSource, aOPCDataObject,
  uOPCInterval,
  uDCObjects;

type
  TXY = record
    X: TDateTime;
    Y: string;
    S: integer;
  end;

  PXY = ^TXY;

  TaCustomOPCStateLine = class(TaCustomOPCDataObject)
  private
    FXYValues: TList;
    FBorderStyle: TBorderStyle;
    FStateColors: TStrings;
    FErrorColor: TColor;
    FDataLoaded: boolean;
    FInterval: TOPCInterval;

    function Get(Index: Integer): TXY;
    procedure Put(Index: Integer; const Value: TXY);
    procedure SetInterval(const Value: TOPCInterval);

    procedure SetBorderStyle(Value: TBorderStyle);
    procedure SetStateColors(const Value: TStrings);
    procedure SetErrorColor(const Value: TColor);

    procedure PaintBackground(AnImage: TBitmap);
    procedure PaintStateLine(AnImage: TBitmap; PaintRect: TRect);
    function GetCount: Integer;
  protected
    procedure SetPhysID(const Value: TPhysID);override;
    procedure SetOPCSource(const Value: TaCustomOPCSource);override;

    procedure Paint; override;
    procedure ChangeData(Sender:TObject);override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy;override;

    procedure AddXY(X: TDateTime; Y: string; S: integer);
    procedure Delete(i: Integer);
    procedure ClearNotUsedRecs;
    procedure Clear;

    function CorrectStringToColor(aStr: string): TColor;
    function GetStateColor(aState: string): TColor;

    procedure LoadData;

    property Items[Index: Integer]: TXY read Get write Put;
    property Count: Integer read GetCount;
  published
    property Align;
    property BorderStyle: TBorderStyle read FBorderStyle write SetBorderStyle default bsSingle;
    property Color;
    property Constraints;
    property ParentShowHint;

    property StateColors: TStrings read FStateColors write SetStateColors;
    property ErrorColor: TColor read FErrorColor write SetErrorColor default clGray;
    property Interval: TOPCInterval read FInterval write SetInterval;
  end;

  TaOPCStateLine = class(TaCustomOPCStateLine)
  end;

implementation

uses
  StrUtils, math,
  Consts;

type
  TBltBitmap = class(TBitmap)
    procedure MakeLike(ATemplate: TBitmap);
  end;

{ TBltBitmap }

procedure TBltBitmap.MakeLike(ATemplate: TBitmap);
begin
  Width := ATemplate.Width;
  Height := ATemplate.Height;
  Canvas.Brush.Color := clWindowFrame;
  Canvas.Brush.Style := bsSolid;
  Canvas.FillRect(Rect(0, 0, Width, Height));
end;


{ TaCustomOPCStateLine }

procedure TaCustomOPCStateLine.AddXY(X: TDateTime; Y: string; S: integer);
var
  XY: PXY;
begin
  // если последние две записи содержат такое же значние, то обновляем последнюю запись новым временем
  if (Count > 1) then
  begin
    if (Items[Count - 1].Y = Y) and (Items[Count - 2].Y = Y)
      and (Items[Count - 1].S = S) and (Items[Count - 2].S = S) then
    begin
      PXY(FXYValues[Count-1])^.X := X;
      Exit;
    end;
  end;

  // добавляем новую запись
  New(XY);
  XY^.X := X;
  XY^.Y := Y;
  XY^.S := S;
  FXYValues.Add(XY);

  // удаляем записи, которые не входят в период
  ClearNotUsedRecs;
end;

procedure TaCustomOPCStateLine.ChangeData(Sender: TObject);
begin
//  Progress := Round(StrToFloatDef(Value,Progress,OpcFS));
  if not FDataLoaded then
    LoadData;
    
  AddXY(DataLink.Moment, DataLink.Value, DataLink.ErrorCode);
  UpdateDataLinks;
  if Assigned(OnChange) and (not (csLoading  in ComponentState))
    and (not (csDestroying in ComponentState)) then
    OnChange(Self);

  RepaintRequest(self);
  //inherited;
end;

procedure TaCustomOPCStateLine.Clear;
var
  i: Integer;
begin
  for i := 0 to FXYValues.Count - 1 do
    Dispose(PXY(FXYValues[i]));
  FXYValues.Clear;

  FDataLoaded := false;
end;

procedure TaCustomOPCStateLine.ClearNotUsedRecs;
var
  p, p1, p2: Integer;
  i: Integer;
begin
  // ищем левую границу
  p1 := -1;
  for i := 0 to Count - 1 do
    if Items[i].X > Interval.Date1 then
    begin
      p1 := i;
      Break;
    end;

  if p1 < 0 then
    Exit;

  // p - позиция элемента, левее которого все удаляем
  p := p1 - 1;

  // удаляем левые элементы (кроме одного)
  while p > 0 do
  begin
    Delete(0);
    Dec(p);
  end;

  // ищем правую границу
  p2 := -1;
  for i := Count - 1 downto 0 do
    if Items[i].X < Interval.Date2 then
    begin
      p2 := i;
      Break;
    end;

  // p - позиция элемента, правее которого все удаляем
  p := p2 + 1;

  while p < Count - 1 do
    Delete(Count-1);
end;

function TaCustomOPCStateLine.CorrectStringToColor(aStr: string): TColor;
var
  aColor: Integer;
begin
  // пытаемся получить число из строки: $FFAAB0, 255, 65535 и пр.
  if TryStrToInt(aStr, aColor) then
    Result := TColor(aColor)
  else
    // иначе ищем в таблице соответствий: название - цвет: clYellow, clGreen ...
    Result := StringToColor(aStr);
end;

constructor TaCustomOPCStateLine.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FInterval := TOPCInterval.Create;

  FDataLoaded := false;
  FXYValues := TList.Create;
  FStateColors := TStringList.Create;

  ControlStyle := ControlStyle + [csFramed, csOpaque];
  BorderStyle := bsSingle;

  { default values }
  Width := 100;
  Height := 16;
  StairsOptions := [];
  DataLink.UpdateOnChangeMoment := true;

  ErrorColor := clGray;
  FStateColors.Add('0=clWhite');
  FStateColors.Add('1=clGreen');

end;

procedure TaCustomOPCStateLine.Delete(i: Integer);
begin
  Dispose(PXY(FXYValues[i]));
  FXYValues.Delete(i);
end;

destructor TaCustomOPCStateLine.Destroy;
begin
  Clear;
  FStateColors.Free;
  FXYValues.Free;
  FInterval.Free;
  inherited;
end;

function TaCustomOPCStateLine.Get(Index: Integer): TXY;
begin
  Result := PXY(FXYValues[Index])^;
end;

function TaCustomOPCStateLine.GetCount: Integer;
begin
  Result := FXYValues.Count;
end;

function TaCustomOPCStateLine.GetStateColor(aState: string): TColor;
var
  aLeftIndex: Integer;
  colorIndex: Integer;
//  aColor: Integer;
begin
  Result := ErrorColor;
  try
    // точное соответствие ?
    colorIndex := StateColors.IndexOfName(aState);
    if colorIndex >= 0 then
      Result := CorrectStringToColor(StateColors.ValueFromIndex[colorIndex])

    else
    // не нашли, тогда в зависимости от StairsOptions ищем левое, правое и т.д.
    begin
      aLeftIndex := -1;
      for colorIndex := 0 to StateColors.Count - 1 do
      begin
        aLeftIndex := colorIndex;
        if StrToFloat(StateColors.Names[colorIndex]) > StrToFloat(aState) then
          Break;
      end;

      // пока берем левое
      { TODO : сделать расчет промежуточного цвета }
      if aLeftIndex >= 0 then
        Result := CorrectStringToColor(StateColors.ValueFromIndex[aLeftIndex]);
    end;
  except
    Result := ErrorColor;
  end;
end;

procedure TaCustomOPCStateLine.LoadData;
var
  aOPCSource: TaOPCSource;
  Stream:TMemoryStream;

  aDate1, aDate2: TDateTime;

  aMoment: TDatetime;
  aValue1, aValue2: extended;
  aStateValue: extended;

  saveScreenCursor: TCursor;
begin
  if Assigned(OPCSource) and (OPCSource is TaOPCSource) then
  begin
    aOPCSource := TaOPCSource(OPCSource);
    aOPCSource.Connected := True;
    if aOPCSource.Connected and (PhysID <> '') then
    begin
      saveScreenCursor := Screen.Cursor;
      Stream := TMemoryStream.Create;
      try
        aDate2 := Interval.Date2;
        aDate1 := Interval.Date1;

        aOPCSource.FillHistory(Stream, PhysID, aDate1, aDate2, [dkValue,dkState]);

        if Stream.Size > 0 then
        begin
          Clear;

          Stream.Read(aMoment, SizeOf(aMoment));        // момент времени
          Stream.Read(aValue2, SizeOf(aValue2));        // значение
          Stream.Read(aStateValue, SizeOf(aStateValue));// состояние

          AddXY(aMoment, FloatToStr(aValue2), trunc(aStateValue));
          if Stream.Position = Stream.Size then
          begin
            // если у нас всего одно значение, добавим еще парочку точек
            AddXY(aDate1, FloatToStr(aValue2), trunc(aStateValue));
            AddXY(IfThen(aDate2=0, Now, aDate2), FloatToStr(aValue2), trunc(aStateValue));
          end
          else
          begin
            while Stream.Position < Stream.Size do
            begin
              //aValue1 := aValue2;

              Stream.Read(aMoment, SizeOf(aMoment));        // момент времени
              Stream.Read(aValue2, SizeOf(aValue2));        // значение
              Stream.Read(aStateValue, SizeOf(aStateValue));// состояние

              AddXY(aMoment, FloatToStr(aValue2), trunc(aStateValue));

            end;
          end;
        end;
        FDataLoaded := true;
        Repaint;

      finally
        Stream.Free;
        Screen.Cursor := saveScreenCursor;
      end;
    end;
  end;
  
end;

procedure TaCustomOPCStateLine.Paint;
var
  TheImage: TBitmap;
  OverlayImage: TBltBitmap;
  PaintRect: TRect;

begin
  with Canvas do
  begin
    TheImage := TBitmap.Create;
    try
      TheImage.Height := Height;
      TheImage.Width := Width;
      PaintBackground(TheImage);
      PaintRect := ClientRect;

      if FBorderStyle = bsSingle then
        InflateRect(PaintRect, -1, -1);

      OverlayImage := TBltBitmap.Create;
      try
        OverlayImage.MakeLike(TheImage);
        PaintBackground(OverlayImage);
        PaintStateLine(OverlayImage,PaintRect);

        TheImage.Canvas.CopyMode := cmSrcInvert;
        TheImage.Canvas.Draw(0, 0, OverlayImage);
        TheImage.Canvas.CopyMode := cmSrcCopy;
      finally
        OverlayImage.Free;
      end;
      Canvas.CopyMode := cmSrcCopy;
      Canvas.Draw(0, 0, TheImage);
    finally
      TheImage.Destroy;
    end;
  end;
end;


procedure TaCustomOPCStateLine.PaintBackground(AnImage: TBitmap);
var
  ARect: TRect;
begin
  with AnImage.Canvas do
  begin
    CopyMode := cmBlackness;
    ARect := Rect(0, 0, Width, Height);
    CopyRect(ARect, Animage.Canvas, ARect);
    CopyMode := cmSrcCopy;
  end;
end;

procedure TaCustomOPCStateLine.PaintStateLine(AnImage: TBitmap;
  PaintRect: TRect);
var
  xy1,xy2: TXY;
  x1,x2: integer;

  XCoef: extended;
  XShift: TDateTime;

  aColor: TColor;

  i: integer;
//  colorIndex: integer;
begin

  with AnImage.Canvas do
  begin
    Brush.Color := clWhite;
    FillRect(PaintRect);

    if (FXYValues.Count = 0) then
      exit;

    if SameValue(Interval.Date1, 0, 1) or SameValue(Interval.Date2, 0, 1) then
      Exit;

    XCoef := (PaintRect.Right-PaintRect.Left)/(Interval.Date2 - Interval.Date1);
    XShift := Interval.Date1;

    xy1 := PXY(FXYValues[0])^;
    x1 := Round((xy1.X - XShift)*XCoef);

    for i := 1 to FXYValues.Count - 1 do
    begin
      xy2 := PXY(FXYValues[i])^;
      //Assert(xy1.X < xy2.X,'xy1.X < xy2.X');

      x2 := Trunc((xy2.X - XShift)*XCoef)+1;

      if xy1.S <> 0 then
        aColor := ErrorColor
      else
      begin
        aColor := GetStateColor(xy1.Y);
//        try
//          colorIndex := StateColors.IndexOfName(xy1.Y);
//          if colorIndex >= 0 then
//            aColor := StringToColor(StateColors.ValueFromIndex[colorIndex])
//          else
//          begin
//            aColor := ErrorColor;
//            for colorIndex := 0 to StateColors.Count - 1 do
//            begin
//              if StrToFloat(StateColors.Names[colorIndex]) > StrToFloat(xy1.Y) then
//                Break;
//
//              aColor := StringToColor(StateColors.ValueFromIndex[colorIndex]);
//            end;
//          end;
//        except
//          aColor := ErrorColor;
//        end;
      end;

      Brush.Color := aColor;
      if x1 < 0 then
        x1 := 0;
      if x2 > (PaintRect.Right - PaintRect.Left) then
        x2 := PaintRect.Right - PaintRect.Left;
      if (x2 < x1) then
      begin
        if (x2 > 0) then
          x1 := x2
        else
          x2 := x1;
      end;
      FillRect(Rect(PaintRect.Left+x1,PaintRect.Top,PaintRect.Left+x2,PaintRect.Bottom));

      xy1 := xy2;
      x1 := x2;
    end;
  end;

end;

procedure TaCustomOPCStateLine.Put(Index: Integer; const Value: TXY);
begin
  PXY(FXYValues[Index])^.X := Value.X;
  PXY(FXYValues[Index])^.Y := Value.Y;
  PXY(FXYValues[Index])^.S := Value.S;
end;

procedure TaCustomOPCStateLine.SetBorderStyle(Value: TBorderStyle);
begin
  if Value <> FBorderStyle then
  begin
    FBorderStyle := Value;
    Refresh;
  end;
end;


procedure TaCustomOPCStateLine.SetErrorColor(const Value: TColor);
begin
  FErrorColor := Value;
end;

procedure TaCustomOPCStateLine.SetInterval(const Value: TOPCInterval);
begin
  FInterval.Assign(Value);
end;

//procedure TaCustomOPCStateLine.SetInterval(const Value: double);
//begin
//  if FInterval <> Value then
//  begin
//    FInterval := Value;
//    FDataLoaded := false;
//  end;
//end;

procedure TaCustomOPCStateLine.SetOPCSource(const Value: TaCustomOPCSource);
begin
  if Value <> OPCSource then
  begin
    Clear;
    inherited;
  end;
end;

procedure TaCustomOPCStateLine.SetPhysID(const Value: TPhysID);
begin
  if Value <> PhysID then
  begin
    Clear;
    inherited;
  end;
end;

procedure TaCustomOPCStateLine.SetStateColors(const Value: TStrings);
begin
  FStateColors.Assign(Value);
  FStateColors.Text := ReplaceStr(FStateColors.Text,' ','');
end;

end.
