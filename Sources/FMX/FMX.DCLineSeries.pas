unit FMX.DCLineSeries;

interface

uses
  System.Classes, System.SysUtils, System.UITypes, System.Types,
  FMX.Forms,
  FMXTee.Chart, FMXTee.Series, FMXTee.Engine,
  aOPCUtils, aCustomOPCSource, aOPCSource, aOPCLookupList, uDCObjects,
  //uChoiceIntervalExt,
  uOPCInterval;

const
  cErrorSerieColor = TColorRec.Gray;
  //cErrorSerieColor = clNone;

type
  TXY = record
    x: double;
    y: double;
  end;

  TXYS = record
    x: double;
    y: double;
    s: double;
  end;

  TXYArray = array of TXY;

  TTransRec = record
    InValue, OutValue: extended;
  end;

  TaDCLineSeries = class(TLineSeries)
  private
    //FSaveStairs: boolean;
    FOriginalXY: TXYArray;
    FDataLink: TaOPCDataLink;
    FLookupList: TaOPCLookupList;
    //FVisibleInterval: TDateTime;
    FScale: double;
    FDisplayFormat: string;
    FShortName: string;
    FFullName: string;
    FShowFullName: boolean;
    FSensorUnitName: string;
    FOPCSource: TaCustomOPCSource;
    FDifferentialOrder: integer;
    FConnectionName: string;
    FIsState: boolean;
    FStateLookupList: TaOPCLookupList;
    FShift: double;

    FRec1, FRec2: TXYS;
//    FValue0, FState0: extended;
//    FDate0: TDateTime;
    FShowState: boolean;

    function GetRealTime: boolean;
    procedure SetSensorUnitName(const Value: string);
    procedure SetShowFullName(const Value: boolean);
    procedure SetFullName(const Value: string);
    procedure SetShortName(const Value: string);
//    function GetVisibleInterval: TDateTime;
    function GetStairsOptions: TDCStairsOptionsSet;
    procedure SetStairsOptions(const Value: TDCStairsOptionsSet);
    procedure ChangeData(Sender: TObject);
    procedure SetOPCSource(const Value: TaCustomOPCSource);
    procedure SetLookupList(const Value: TaOPCLookupList);
    function GetPhysID: TPhysID;
    procedure SetPhysID(const Value: TPhysID);
//    procedure SetVisibleInterval(const Value: TDateTime);
    procedure SetScale(const Value: double);
    procedure SetDisplayFormat(const Value: string);
    procedure SetDifferentialOrder(const Value: integer);
    function GetSensorUnitName: string;
    procedure SetConnectionName(const Value: string);
    procedure SetIsState(const Value: boolean);
    procedure SetStateLookupList(const Value: TaOPCLookupList);
    procedure SetShift(const Value: double);
    procedure SetShowState(const Value: boolean);
    function GetInterval: TOPCInterval;
  protected
    procedure UpdateTitle;
    procedure SetParentChart(const Value: TCustomAxisPanel); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation);
      override;
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;

    Procedure DrawLegend(ValueIndex:Integer; Const Rect:TRectF); override;

    Function MinYValue:Double; override;
    Function MaxYValue:Double; override;

    procedure sAddXY(aRec: TXYS); overload;
    procedure sAddXY(x, y: double; s: double = 0); overload;
    procedure eAddXY(x, y: double);
    procedure FillOPCData(ToNow: boolean = false; aSourceValues: Boolean = False);
    procedure FillSerie(ToNow: boolean = false; aSourceValues: Boolean = False);
    procedure UpdateRealTime;

    property RealTime: boolean read GetRealTime;
    property Interval: TOPCInterval read GetInterval;
  published
    property ShortName: string read FShortName write SetShortName;
    property FullName: string read FFullName write SetFullName;
    property ShowFullName: boolean read FShowFullName write SetShowFullName;
    property DisplayFormat: string read FDisplayFormat write SetDisplayFormat;
    property StairsOptions: TDCStairsOptionsSet
      read GetStairsOptions write SetStairsOptions;
//    property VisibleInterval: TDateTime read GetVisibleInterval write
//      SetVisibleInterval;

    property PhysID: TPhysID read GetPhysID write SetPhysID;
    property Scale: double read FScale write SetScale;
    property Shift: double read FShift write SetShift;
    property LookupList: TaOPCLookupList read FLookupList write SetLookupList;
    property StateLookupList: TaOPCLookupList read FStateLookupList write
      SetStateLookupList;
    property OPCSource: TaCustomOPCSource read FOPCSource write SetOPCSource;
    property SensorUnitName: string read GetSensorUnitName write SetSensorUnitName;
    // порядок дифференциала (1-интеграл,0-норамльное значение,-1-скорость, -2-ускорение...)
    property DifferentialOrder: integer read FDifferentialOrder write
      SetDifferentialOrder stored false;
    property IsState: boolean read FIsState write SetIsState default false;
    property ShowState: boolean read FShowState write SetShowState default true;
    property ConnectionName: string read FConnectionName write
      SetConnectionName;
  end;

var
  TeeMsg_GalleryOPCLine: string;

implementation

uses
  Math,
  uOPCConst, FMX.DCChart, aOPCLog;

function GetXYSRec(x, y, s: double): TXYS;
begin
  Result.x := x;
  Result.y := y;
  Result.s := s;
end;

{ TaDCLineSeries }

procedure TaDCLineSeries.ChangeData(Sender: TObject);
var
  tmpY: double;
  Rec: TXYS;
  D2: TDateTime;
begin
  if (not Assigned(ParentChart)) or (not (ParentChart is TaDCChart)) then
    Exit;

  try
    if (FDataLink.Moment = 0) or (FDataLink.Value = '') then
      Exit;

    if (Interval.Kind = ikInterval) and
      ((FDataLink.Moment < Interval.Date1) or (FDataLink.Moment > Interval.Date2)) then
      Exit;

    Rec.x := fDataLink.Moment;
    if IsState then
    begin
      Rec.y := FDataLink.ErrorCode;
      Rec.s := 0;
    end
    else
    begin
      Rec.y := StrToFloatDef(fDataLink.Value, 0);
      Rec.s := FDataLink.ErrorCode;
    end;

    if XValues.Count > 1 then
    begin

      // если были ошибки, добавляем новую точку
      if (FRec1.s <> Rec.s) or (FRec2.s <> Rec.s) then
      begin
        sAddXY(Rec)
      end

      // сдвигаем предыдущую точку, если последние две и новая одинаковы
      else if (FRec1.y = Rec.y) and (FRec2.y = Rec.y) then
      begin
        XValues.Value[XValues.Count - 1] := Rec.x;
        FRec1 := Rec;
      end

      // проверяем возможность линейной апроксимации предыдущей точки
      else if (FRec1.x <> FRec2.x) then
      begin
        tmpY := FRec2.y +
          (FRec2.y - FRec1.y) * (Rec.x - FRec2.x) / (FRec2.x - FRec1.x);
        tmpY := StrToFloatDef(FormatValue(tmpY, DisplayFormat), tmpY);

        if (FRec2.x <> FRec1.x) and (Rec.y = tmpY) then
        begin
          Delete(XValues.Count - 1);
          FRec1 := FRec2;
        end;

        sAddXY(Rec);
      end

      else
        sAddXY(Rec);

      // удаляем самую левую точку, если это возможно и необходимо
      if (XValues.Count > 3) and (XValue[1] < Interval.Date1) then
        Delete(0);

    end
    else
      sAddXY(Rec);

    // если ось времени в нормальном состоянии, то обновим ее шкалу
    if not ParentChart.Zoomed then
    begin
      if (Interval.Kind = ikShift) then
        D2 := Max(Interval.Date2, Rec.x)
      else
        D2 := Interval.Date2;

      ParentChart.BottomAxis.SetMinMax(Interval.Date1, D2); //Interval.Date2);
    end;

  except
    on e: Exception do
      OPCLog.WriteToLog('Error in TaDCLineSeries.ChangeData : ' + e.Message);
  end;

end;

constructor TaDCLineSeries.Create(aOwner: TComponent);
begin
  inherited;
  FShift := 0;
  FScale := 1;
  FShowState := true;
  Active := true;
  XValues.DateTime := true;

  fDataLink := TAOPCDataLink.Create(Self);
  fDataLink.UpdateOnChangeMoment := true;
  fDataLink.OnChangeData := ChangeData;
  ColorEachLine := true;
  ColorEachPoint := true;
end;

destructor TaDCLineSeries.Destroy;
begin
  OPCSource := nil;
  fDataLink.Free;

  inherited;
end;

procedure TaDCLineSeries.DrawLegend(ValueIndex: Integer; const Rect: TRectF);
begin
  if (ValueIndex = -1) then
    ValueIndex := ValuesList.Count - 1;

  inherited DrawLegend(ValueIndex, Rect);
end;

procedure TaDCLineSeries.eAddXY(x, y: double);

  function CalcLabel(aValue: double): string;
  var
    aStates: TaOPCLookupList;
  begin
    Result := 'Error';
    if Assigned(OPCSource) then
    begin
      aStates := TaOPCLookupList(OPCSource.States);
      if Assigned(OPCSource.States) then
        Result := aStates.GetValue(FloatToStr(aValue), 'Unknown Error');
    end;
  end;

begin
  if (XValues.Count > 0) then // это не первая точка в графике
    AddXY(x, FRec1.y / Scale + Shift, CalcLabel(FRec1.y), Color);

  AddXY(x, y / Scale + Shift, CalcLabel(y), Color);
  FRec2 := FRec1;
  FRec1.x := x;
  FRec1.y := y;
  FRec1.s := 0;
end;

procedure TaDCLineSeries.FillOPCData(ToNow: boolean; aSourceValues: Boolean);
var
  Stream: TMemoryStream;
  aOPCSource: TaOPCSource;
  aDate1, aDate2: TDateTime;
  D2: TDateTime;
  V1, V2: Extended;
  readV: TExtended80Rec;
  saveScreenCursor: TCursor;
  aDataKindSet: TDataKindSet;
begin
  //  if Assigned(ParentChart) and (ParentChart is TaDCChart) then
  //    aOPCSource := TaDCChart(ParentChart).OPCSource
  //  else
  if not IsState then
  begin
    FillSerie(ToNow, aSourceValues);
    exit;
  end;

  aOPCSource := TaOPCSource(OPCSource);

  if not Assigned(aOPCSource) then
    exit;

  if Assigned(ParentChart) then
    ParentChart.Enabled := false;

  //saveScreenCursor := Screen.Cursor;
  try
    //Screen.Cursor := crHourGlass;

    Clear;
    Stream := TMemoryStream.Create;
    try
      aDate1 := ParentChart.BottomAxis.Minimum;
      if ToNow then
        aDate2 := 0
      else
        aDate2 := ParentChart.BottomAxis.Maximum;

      if IsState then
        aDataKindSet := [dkState]
      else
        aDataKindSet := [dkValue];

      aOPCSource.FillHistory(Stream, PhysID, aDate1, aDate2, aDataKindSet);

      if Stream.Size > 0 then
      begin
        Stream.Read(D2, SIZEOF(D2));
        Stream.Read(readV, SIZEOF(readV));
        v2 := Extended(readV);

        eAddXY(D2, V2);
        if Stream.Size = SIZEOF(D2) + SIZEOF(readV) then
        begin
          eAddXY(aDate1, V2);
          eAddXY(IfThen(aDate2 = 0, Now, aDate2), V2);
        end
        else
        begin
          while Stream.Position < Stream.Size do
          begin
            V1 := V2;

            Stream.Read(D2, SIZEOF(D2));
            Stream.Read(readV, SIZEOF(readV));
            v2 := Extended(readV);

            eAddXY(D2, V2);
          end;
        end;
      end;
    finally
      stream.free;
    end;
  finally
    //Screen.Cursor := saveScreenCursor;

    if Assigned(ParentChart) then
      ParentChart.Enabled := true;
  end;
end;

procedure TaDCLineSeries.FillSerie(ToNow: boolean; aSourceValues: Boolean);
var
  Stream: TMemoryStream;
  aOPCSource: TaOPCSource;

  aDate1, aDate2: TDateTime;

  aMoment: TDatetime;
  aValue1, aValue2: extended;
  readV: TExtended80Rec;
  aStateValue: extended;

  saveScreenCursor: TCursor;
  //tc: Cardinal;

  sl: TStringList;
  i: Integer;
  a, b, vin, vout: Extended;
  TransCount: integer;
  BackTransformation: array of TTransRec;

  function BackTransform(aInValue: Extended): Extended;
  var
    i1, i2: Integer;
  begin
    Result := 0;

    if TransCount = 0 then
    begin
      Result := (aInValue - b)/a;
      exit;
    end
    else
    begin
      if TransCount > 1 then
      begin
        for i2 := 1 to TransCount - 1 do
        begin
          i1 := i2 - 1;
          if (BackTransformation[i1].InValue <= aInValue) and
            (BackTransformation[i2].InValue >= aInValue) and
            (BackTransformation[i1].InValue <> BackTransformation[i2].InValue) then
          begin
            Result := BackTransformation[i2].OutValue - // y2
            (BackTransformation[i2].OutValue - BackTransformation[i1].OutValue) * //(y2 - y1)
            (BackTransformation[i2].InValue - aInValue) / // (x2 - x)
            (BackTransformation[i2].InValue - BackTransformation[i1].InValue); //(x2-x1)

            exit;
          end;
        end;
      end;
    end;
  end;

begin
  aOPCSource := TaOPCSource(OPCSource);

  if not Assigned(aOPCSource) then
    exit;

  if Assigned(ParentChart) then
  begin
    ParentChart.Enabled := false;
    //TChart(ParentChart).AutoRepaint := False;
  end;

  //tc := GetTickCount;
  //saveScreenCursor := Screen.Cursor;
  try
    //Screen.Cursor := crHourGlass;

    Clear;
    Stream := TMemoryStream.Create;
    try
      // определимся с периодом выборки
      aDate1 := ParentChart.BottomAxis.Minimum;
      if ToNow then
        aDate2 := 0
      else
        aDate2 := ParentChart.BottomAxis.Maximum;

      // выбираем показания и состояния датчика за период
      if ShowState then
        aOPCSource.FillHistory(Stream, PhysID, aDate1, aDate2, [dkValue, dkState])
      else
        aOPCSource.FillHistory(Stream, PhysID, aDate1, aDate2, [dkValue]);

      // если нужны исходные данне, без преобразований, то загружаем коэффициенты и таблицу преобразований
      if aSourceValues then
      begin
        sl := TStringList.Create;
        try
          sl.Text := aOPCSource.GetSensorPropertiesEx(PhysID);
          a := StrToFloatDef(sl.Values[sSensorCorrectMul], 1, aOPCSource.OpcFS);
          b := StrToFloatDef(sl.Values[sSensorCorrectAdd], 0, aOPCSource.OpcFS);

          TransCount := StrToIntDef(sl.Values[sSensorTransformCount], 0);
          SetLength(BackTransformation, TransCount);

          for i := 1 to TransCount do
          begin
            BackTransformation[i-1].OutValue := StrToFloatDef(sl.Values[Format('%s%d', [sSensorTransformIn, i-1])], 0, aOPCSource.OpcFS);
            BackTransformation[i-1].InValue := StrToFloatDef(sl.Values[Format('%s%d', [sSensorTransformOut, i-1])], 0, aOPCSource.OpcFS);
          end;

        finally
          sl.Free;
        end;
      end;


      aStateValue := 0;
      if Stream.Size > 0 then
      begin
        Stream.Read(aMoment, SizeOf(aMoment)); // момент времени
        Stream.Read(readV, SizeOf(readV)); // значение
        aValue2 := Extended(readV);
        if aSourceValues then
          aValue2 := BackTransform(aValue2);

        if ShowState then
        begin
          Stream.Read(readV, SizeOf(readV)); // состояние
          aStateValue := Extended(readV);
        end;

        sAddXY(aMoment, aValue2, aStateValue);
        if Stream.Position = Stream.Size then
        begin
          // если у нас всего одно значение, добавим еще парочку точек
          sAddXY(aDate1, aValue2, aStateValue);
          sAddXY(IfThen(aDate2 = 0, Now, aDate2), aValue2, aStateValue);
        end
        else
        begin
          while Stream.Position < Stream.Size do
          begin
            aValue1 := aValue2;

            Stream.Read(aMoment, SizeOf(aMoment)); // момент времени
            Stream.Read(readV, SizeOf(readV)); // значение
            aValue2 := Extended(readV);

            if aSourceValues then
              aValue2 := BackTransform(aValue2);
            if ShowState then
            begin
              Stream.Read(readV, SizeOf(readV)); // состояние
              aStateValue := Extended(readV);
            end;

            //            if not (((aValue1 < aValue2) and (soIncrease in StairsOptions))
            //                 or ((aValue1 > aValue2) and (soDecrease in StairsOptions))) then
            //              sAddXY(aMoment, aValue1, aStateValue);

            sAddXY(aMoment, aValue2, aStateValue);

          end;
        end;
      end;
    finally
      stream.free;
    end;
  finally
    //Screen.Cursor := saveScreenCursor;
    if Assigned(ParentChart) then
    begin
      ParentChart.Enabled := true;
      //TChart(ParentChart).AutoRepaint := true;
      //TChart(ParentChart).Repaint;
    end;
    //OPCLog.WriteToLog(IntToStr(XValues.Count) +' точек за ' + IntToStr(GetTickCount - tc));
  end;
end;

function TaDCLineSeries.GetInterval: TOPCInterval;
begin
  if ParentChart is TaDCChart then
    Result := TaDCChart(ParentChart).Interval
  else
    Result := nil;
end;

function TaDCLineSeries.GetPhysID: TPhysID;
begin
  Result := fDataLink.PhysID;

end;

function TaDCLineSeries.GetRealTime: boolean;
begin
  if Assigned(ParentChart) and (ParentChart is TaDCChart) then
    Result := TaDCChart(ParentChart).RealTime
  else
    Result := false;
end;

function TaDCLineSeries.GetStairsOptions: TDCStairsOptionsSet;
begin
  Result := FDataLink.StairsOptions;
end;

function TaDCLineSeries.GetSensorUnitName: string;
var
  h: string;
  i: integer;
begin
  h := '';
  for i := 1 to Abs(DifferentialOrder) do
    h := h + 'ч*';

  if h <> '' then
  begin
    h := Copy(h, 1, length(h) - 1);
    if DifferentialOrder < 0 then
      h := '/' + h
    else
      h := '*' + h;
  end;

  Result := FSensorUnitName + h;
end;

//function TaDCLineSeries.GetVisibleInterval: TDateTime;
//begin
//  if Assigned(ParentChart) and (ParentChart is TaDCChart) then
//    Result := TaDCChart(ParentChart).VisibleInterval
//  else
//    Result := FVisibleInterval;
//end;

function TaDCLineSeries.MaxYValue: Double;
begin
  Result := inherited MaxYValue;

  if (Result < 0)
    and Assigned(ParentChart) and (ParentChart is TaDCChart)
    and TaDCChart(ParentChart).ShowZero then
  begin
    Result := 0;
  end;
end;

function TaDCLineSeries.MinYValue: Double;
begin
  Result := inherited MinYValue;

  if (Result > 0)
    and Assigned(ParentChart) and (ParentChart is TaDCChart)
    and TaDCChart(ParentChart).ShowZero then
  begin
    Result := 0;
  end;


end;

procedure TaDCLineSeries.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) then
  begin
    if (OPCSource = AComponent) then
      OPCSource := nil
    else if LookupList = AComponent then
      LookupList := nil;
  end;
end;

procedure TaDCLineSeries.sAddXY(x, y, s: double);
begin
  sAddXY(GetXYSRec(x, y, s));
end;

procedure TaDCLineSeries.sAddXY(aRec: TXYS);//x, y: double; aState: extended = 0);
var
  aLabel: string;
  aColor: TColor;

  function CalcColor: TColor; //(aState1, aState2: extended): TColor;
  begin
    if {(aState = 0) and }(FRec1.s = 0) then
      Result := Color
    else
      Result := cErrorSerieColor;
  end;

  function CalcColor0: TColor; //(aState1, aState2: extended): TColor;
  begin
    if (FRec1.s = 0) then
      Result := Color
    else
      Result := cErrorSerieColor;
  end;

  function CalcLabel(aValue: double; aStateValue: extended): string;
  var
    aIndex: integer;
    aLookupList: TaOPCLookupList;
    aStates: TaOPCLookupList;
  begin
    if IsState and Assigned(StateLookupList) then
      aLookupList := StateLookupList
    else
      aLookupList := LookupList;

    if aStateValue = 0 then // нет ошибок
    begin
      // если есть справочник, то поищем в нём
      if Assigned(aLookupList) then
      begin
        // поищем в справочнике
        aIndex := aLookupList.Items.IndexOfName(Trim(FloatToStr(aValue)));
        if aIndex >= 0 then
          // нешли - берём из справочника
          Result := aLookupList.Items.ValueFromIndex[aIndex]
        else
          // покажем, что не нашли
          Result := Format('unknow: %d', [Trunc(aValue)]);
      end
      else
        // преобразуем исходное значение согласно формату отображения
        Result := FormatValue(aValue, DisplayFormat);
    end
    else // есть ошибки
    begin
      Result := 'не задан справочник ошибок';

      aStates := StateLookupList;
      if not Assigned(aStates) and Assigned(OPCSource) then
        aStates := TaOPCLookupList(OPCSource.States);

      if Assigned(aStates) then
        Result := aStates.GetValue(FloatToStr(aStateValue), 'Unknown Error');
    end;
  end;
begin
  if (XValues.Count > 0) // это не первая точка в графике
    and (
      // это график состояний, всегда добавляем точку окончания
      (IsState and (FRec1.s <> aRec.s)) or
      // или это обычный график, тогда проверяем что это "лесенка"
      ((FRec1.y <> aRec.y) and not (
        ((FRec1.y < aRec.y) and (soIncrease in StairsOptions)) or
        ((FRec1.y > aRec.y) and (soDecrease in StairsOptions)))
      )) then
  begin
    // добавляем  СТАРОЕ ЗНАЧЕНИЕ на НОВЫЙ МОМЕНТ времени, с целью
    // показать длительность действия этого значения
    AddXY(aRec.x, FRec1.y / Scale + Shift, CalcLabel(FRec1.y, FRec1.s), CalcColor0);
  end;

  // добавляем новое значение
  AddXY(aRec.x, aRec.y / Scale + Shift, CalcLabel(aRec.y, aRec.s), CalcColor);
  FRec2 := FRec1;
  FRec1 := aRec;
//  FState0 := aState;
//  FValue0 := y;
//  FDate0 := x;
end;

procedure TaDCLineSeries.SetLookupList(const Value: TaOPCLookupList);
begin
  FLookupList := Value;
  //  if Value <> nil then Value.FreeNotification(Self);
end;

procedure TaDCLineSeries.SetParentChart(const Value: TCustomAxisPanel);
begin
  inherited;
  {
    if Value is TaDCChart then
    begin
      if TaDCChart(Value).RealTime then
        OPCSource := TaDCChart(Value).OPCSource;
    end;
    }
end;

procedure TaDCLineSeries.SetPhysID(const Value: TPhysID);
begin
  fDataLink.PhysID := Value;
end;

procedure TaDCLineSeries.SetOPCSource(const Value: TaCustomOPCSource);
begin
  FOPCSource := Value;

  if RealTime and (fDataLink.OPCSource <> Value) then
    fDataLink.OPCSource := Value;
end;

//procedure TaDCLineSeries.SetVisibleInterval(const Value: TDateTime);
//begin
//  FVisibleInterval := Value;
//end;

procedure TaDCLineSeries.UpdateRealTime;
begin
  if Assigned(ParentChart) and (ParentChart is TaDCChart) then
  begin
    if TaDCChart(ParentChart).RealTime then
      FDataLink.OPCSource := FOPCSource
    else
      FDataLink.OPCSource := nil;
  end;
end;

procedure TaDCLineSeries.UpdateTitle;
var
  tmpName: string;
  i: integer;
  aDifOrd: integer;
begin
  if ShowFullName then
    tmpName := FullName
  else
    tmpName := ShortName;

  if tmpName = '' then
    tmpName := Name;

  if FIsState then
    tmpName := tmpName + '(состояние)';

  if DifferentialOrder < 0 then
  begin
    aDifOrd := FDifferentialOrder;
    if Odd(aDifOrd) then
    begin
      tmpName := tmpName + '''';
      aDifOrd := FDifferentialOrder + 1;
    end;
    for i := aDifOrd div 2 to -1 do
      tmpName := tmpName + '"';
  end
  else if DifferentialOrder > 0 then
  begin
    tmpName := Format('%s (интеграл %d-го порядка)', [tmpName,
      FDifferentialOrder]);
  end;

  if (FScale <> 1) then
    tmpName := Format('%s (1x%g)', [tmpName, FScale]);

  if FShift > 0 then
    tmpName := Format('%s + %g', [tmpName, FShift])
  else if FShift < 0 then
    tmpName := Format('%s %g', [tmpName, FShift]);

  Title := tmpName;
end;

procedure TaDCLineSeries.SetScale(const Value: double);
var
  i: integer;
begin
  if (FScale = Value) or (Value = 0) then
    exit;
  for i := 0 to YValues.Count - 1 do
    YValue[i] := (YValue[i] - FShift) * FScale / Value + FShift;
  FScale := Value;
  UpdateTitle;
end;

procedure TaDCLineSeries.SetShift(const Value: double);
var
  i: integer;
begin
  if (FShift = Value) then
    exit;

  for i := 0 to YValues.Count - 1 do
    YValue[i] := YValue[i] - FShift + Value;

  FShift := Value;
  UpdateTitle;
end;

procedure TaDCLineSeries.SetShortName(const Value: string);
begin
  if FShortName <> Value then
  begin
    FShortName := Value;
    UpdateTitle;
  end;
end;

procedure TaDCLineSeries.SetShowFullName(const Value: boolean);
begin
  if FShowFullName <> Value then
  begin
    FShowFullName := Value;
    UpdateTitle;
  end;
end;

procedure TaDCLineSeries.SetShowState(const Value: boolean);
begin
  FShowState := Value;
end;

procedure TaDCLineSeries.SetStairsOptions(const Value: TDCStairsOptionsSet);
begin
  FDataLink.StairsOptions := Value;
end;

procedure TaDCLineSeries.SetStateLookupList(const Value: TaOPCLookupList);
begin
  FStateLookupList := Value;
end;

procedure TaDCLineSeries.SetSensorUnitName(const Value: string);
begin
  FSensorUnitName := Value;
end;

procedure TaDCLineSeries.SetConnectionName(const Value: string);
begin
  FConnectionName := Value;
end;

procedure TaDCLineSeries.SetDifferentialOrder(const Value: integer);
var
  i: integer;
  xy: TXYArray;
  aOrder: integer;

  // продифференцируем массив XY
  // результат помещаем в этот же массив, последние aOrder
  // значений в дальнейшем не используем
  procedure Differential;
  var
    i: integer;
    f, x1, y1, x2, y2: double;
  begin
    Stairs := true;
    if High(XY) - Low(XY) > 0 then
    begin
      x1 := xy[Low(xy)].x;
      y1 := xy[Low(xy)].y;
      for i := Low(xy) + 1 to High(xy) + 1 - aOrder do
      begin
        x2 := xy[i].x;
        y2 := xy[i].y;
        if (x2 <> x1) then
        begin
          f := (y2 - y1) / ((x2 - x1) * 24);

          xy[i - 1].x := x1;//(x2 + x1) / 2;
          xy[i - 1].y := f;

          x1 := x2;
          y1 := y2;
        end;
      end;
    end;
  end;

  // проинтегрируем массив XY
  // результат помещаем в этот же массив, последние aOrder
  // значений в дальнейшем не используем
  procedure Integral;
  var
    i: integer;
    f, x0, x1, y1, x2, y2: double;
  begin
    f := 0;
    Stairs := false;
    if High(XY) - Low(XY) > 0 then
    begin
      x0 := xy[Low(xy)].x;
      x1 := x0; //xy[Low(xy)].x;
      y1 := xy[Low(xy)].y;
      for i := Low(xy) + 1 to High(xy) + 1 - aOrder do
      begin
        x2 := xy[i].x;
        y2 := xy[i].y;

//        f := f + (y1 + y2) * (x2 - x1) * 12;
        f := f + (y1 + y2)/2 * (x2 - x1) * 24;

        xy[i - 1].x := (x2 + x1) / 2;
        xy[i - 1].y := f;// / (x2 - x0);

        x1 := x2;
        y1 := y2;
      end;
    end;
  end;

begin
  if (FDifferentialOrder = Value) then
    exit;

  // если были нормальные показания, то сохраним их и вид графика
  if FDifferentialOrder = 0 then
  begin
    //FSaveStairs := Stairs; // сохраняем вид графика
    SetLength(FOriginalXY, XValues.Count);
    for i := 0 to XValues.Count - 1 do // сохраняем показания
    begin
      FOriginalXY[i].x := XValue[i];
      FOriginalXY[i].y := YValue[i];
    end;
  end;

  Clear;
  if Value = 0 then //мы вернулись к нормальным показаниям
  begin
    Stairs := false;
    for i := Low(FOriginalXY) to High(FOriginalXY) do
      sAddXY(FOriginalXY[i].x, FOriginalXY[i].y);

    //Stairs := FSaveStairs;    // - вернемся к исходному виду графика
    SetLength(FOriginalXY, 0); // - очистим массив (он нам уже не нужен)
  end
  else
  begin
    SetLength(xy, High(FOriginalXY) - Low(FOriginalXY) + 1);
    for i := Low(FOriginalXY) to High(FOriginalXY) do
    begin
      xy[i].x := FOriginalXY[i].x;
      xy[i].y := FOriginalXY[i].y;
    end;

    aOrder := Abs(Value);
    for i := 1 to aOrder do
      if Value > 0 then //интеграл
        Integral
      else
        Differential;

    for i := Low(xy) to High(xy) - aOrder do
      sAddXY(xy[i].x, xy[i].y);

  end;

  FDifferentialOrder := Value;
  UpdateTitle;
end;

procedure TaDCLineSeries.SetDisplayFormat(const Value: string);
begin
  FDisplayFormat := Value;
end;

procedure TaDCLineSeries.SetFullName(const Value: string);
begin
  FFullName := Value;
  UpdateTitle;
end;

procedure TaDCLineSeries.SetIsState(const Value: boolean);
begin
  if FIsState <> Value then
  begin
    FIsState := Value;
    UpdateTitle;
  end;
end;

initialization
  TeeMsg_GalleryOPCLine := 'OPC линия';

  //  RegisterTeeSeries(TaDCLineSeries,TeeMsg_GalleryOPCLine,'OPC',1);//@TeeMsg_GalleryOPCLine);
  //RegisterTeeSeries(TaDCLineSeries, @TeeMsg_GalleryOPCLine);

//  RegisterTeeSeries(TaDCLineSeries, @TeeMsg_GalleryOPCLine);
end.

