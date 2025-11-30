unit uOPCSeriesAdapter;

interface

uses
  System.Classes, System.SysUtils,
  VCL.Graphics, VCL.Controls, VCL.Forms,
  VCLTee.TeEngine, VCLTee.Series,
  aCustomOPCSource, aOPCLookupList,
  uOPCInterval,
  uDCObjects,
  uOPCFilter,
  uOPCSeriesTypes;

const
  cErrorSerieColor = clGray;

type
  TStatisticalFunc = (sfNone, sfMin, sfMax, sfAvg);

  // адаптер для графіка
  // дає можливість адоптувати будь-який нащадок TChartSeries для підключення до Моніторингу
  TOPCSeriesAdapter =  class(TPersistent)
  //TOPCSeriesAdapter =  class(TInterfacedPersistent, IaOPCSeries)
  private
    FSeries: TChartSeries;

    FDataLink: TaOPCDataLink;
    FLookupList: TaOPCLookupList;
    FStateLookupList: TaOPCLookupList;

    FScale: Double;
    FShift: Double;

    FShortName: string;
    FFullName: string;
    FShowFullName: Boolean;

    FDisplayFormat: string;
    FSensorUnitName: string;

    FOPCSource: TaCustomOPCSource;
    FConnectionName: string;

    FIsState: Boolean;
    FShowState: Boolean;
    FDifferentialOrder: integer;

    FStatisticalPeriod: TDateTime;
    FStatisticalFunc: TStatisticalFunc;

  	FFilter: TaOPCFilter;
    FHideFiltered: Boolean;

    FRec1, FRec2: TXYS;
    FOriginalXY: TXYArray;

    FOnDestroy: TNotifyEvent;
  private
    function GetPhysID: TPhysID;
    function GetScale: Double;
    function GetShift: Double;
    function GetConnectionName: string;
    function GetOPCSource: TaCustomOPCSource;
    function GetFullName: string;
    function GetShortName: string;
    function GetShowFullName: Boolean;
    function GetInterval: TOPCInterval;
    function GetRealTime: Boolean;
    function GetFilter: TaOPCFilter;
    function GetStairsOptions: TDCStairsOptionsSet;
    procedure SetPhysID(const Value: TPhysID);
    procedure SetScale(const Value: Double);
    procedure SetShift(const Value: Double);
    procedure SetConnectionName(const Value: string);
    procedure SetOPCSource(const Value: TaCustomOPCSource);
    procedure SetFullName(const Value: string);
    procedure SetShortName(const Value: string);
    procedure SetShowFullName(const Value: Boolean);
    procedure SetDataLink(const Value: TaOPCDataLink);
    procedure SetDifferentialOrder(const Value: Integer);
    procedure SetFilter(const Value: TaOPCFilter);
    procedure SetHideFiltered(const Value: Boolean);
    procedure SetIsState(const Value: boolean);
    procedure SetShowState(const Value: boolean);
    procedure SetStatisticalFunc(const Value: TStatisticalFunc);
    procedure SetStatisticalPeriod(const Value: TDateTime);
    procedure SetLookupList(const Value: TaOPCLookupList);
    procedure SetStateLookupList(const Value: TaOPCLookupList);
    procedure SetDisplayFormat(const Value: string);
    procedure SetStairsOptions(const Value: TDCStairsOptionsSet);
  private
    procedure UpdateTitle;
    procedure StoreToOriginal;
    procedure RestoreFromOriginal;

    procedure ChangeData(Sender: TObject);
  protected
    procedure AssignTo(Dest: TPersistent); override;
  public
    constructor Create(aSeries: TChartSeries);
    destructor Destroy; override;
  public
    procedure sAddXY(aRec: TXYS); overload;
    procedure sAddXY(x, y: Double; s: Double = 0); overload;
    procedure sAddNullXY(x, y: Double);
    procedure eAddXY(x, y: double);

    procedure FillOPCData(ToNow: Boolean = False; aSourceValues: Boolean = False);
    procedure FillSerie(ToNow: Boolean = False; aSourceValues: Boolean = False);
    procedure UpdateRealTime;

    property RealTime: Boolean read GetRealTime;
    property Interval: TOPCInterval read GetInterval;

    property Series: TChartSeries read FSeries;
    property DataLink: TaOPCDataLink read FDataLink write SetDataLink;
  published
    property PhysID: TPhysID read GetPhysID write SetPhysID;

    property OPCSource: TaCustomOPCSource read GetOPCSource write SetOPCSource;
    property ConnectionName: string read GetConnectionName write SetConnectionName;
    property LookupList: TaOPCLookupList read FLookupList write SetLookupList;
    property StateLookupList: TaOPCLookupList read FStateLookupList write SetStateLookupList;

    property ShortName: string read GetShortName write SetShortName;
    property FullName: string read GetFullName write SetFullName;
    property ShowFullName: Boolean read GetShowFullName write SetShowFullName;
    property DisplayFormat: string read FDisplayFormat write SetDisplayFormat;
    property StairsOptions: TDCStairsOptionsSet read GetStairsOptions write SetStairsOptions;

    property Scale: double read GetScale write SetScale;
    property Shift: double read GetShift write SetShift;

    // порядок диференціалу (1-інтеграл, 0-початкове значення, -1-швидкість, -2-прискорення...)
    property DifferentialOrder: Integer read FDifferentialOrder write SetDifferentialOrder stored False;
    property IsState: boolean read FIsState write SetIsState default False;
    property ShowState: boolean read FShowState write SetShowState default True;
    property Filter: TaOPCFilter read GetFilter write SetFilter;
    property HideFiltered: Boolean read FHideFiltered write SetHideFiltered;

    property StatisticalFunc: TStatisticalFunc read FStatisticalFunc write SetStatisticalFunc;
    property StatisticalPeriod: TDateTime read FStatisticalPeriod write SetStatisticalPeriod;

    property OnDestroy: TNotifyEvent read FOnDestroy write FOnDestroy;
  end;

implementation

uses
  System.Math,
  aOPCLog,
  aOPCChart,
  aOPCSource,
  aOPCUtils,
  uOPCConst;

{ TOPCSeriesAdapter }

procedure TOPCSeriesAdapter.AssignTo(Dest: TPersistent);
var
  d: TOPCSeriesAdapter;
begin
  if Dest is TOPCSeriesAdapter then
  begin
    d := TOPCSeriesAdapter(Dest);
//    d.DataLink := DataLink;
    d.PhysID := PhysID;
    d.OPCSource := OPCSource;
    d.ConnectionName := ConnectionName;
    d.LookupList := LookupList;
    d.StateLookupList := StateLookupList;
    d.ShortName := ShortName;
    d.FullName := FullName;
    d.ShowFullName := ShowFullName;
    d.DisplayFormat := DisplayFormat;
    d.StairsOptions := StairsOptions;
    d.Scale := Scale;
    d.Shift := Shift;
    d.DifferentialOrder := DifferentialOrder;
    d.IsState := IsState;
    d.ShowState := ShowState;
    d.Filter := Filter;
    d.HideFiltered := HideFiltered;
    d.StatisticalFunc := StatisticalFunc;
    d.StatisticalPeriod := StatisticalPeriod;
    d.OnDestroy := OnDestroy;
  end;

end;

procedure TOPCSeriesAdapter.ChangeData(Sender: TObject);
var
  tmpY: double;
  Rec: TXYS;
  D2: TDateTime;
begin
  if not (Series.ParentChart is TaOPCChart) then
    Exit;

  try
    if (FDataLink.Moment = 0) or (FDataLink.Value = '') then
      Exit;

    if (Interval.Kind = ikInterval) and
      ((FDataLink.Moment < Interval.Date1) or (FDataLink.Moment > Interval.Date2)) then
      Exit;

    Rec.x := FDataLink.Moment;
    if IsState then
    begin
      Rec.y := FDataLink.ErrorCode;
      Rec.s := 0;
    end
    else
    begin
      Rec.y := StrToFloatDef(FDataLink.Value, 0);
      Rec.s := FDataLink.ErrorCode;
    end;

    if Series.XValues.Count > 1 then
    begin

      // если были ошибки, добавляем новую точку
      if (FRec1.s <> Rec.s) or (FRec2.s <> Rec.s) then
      begin
        sAddXY(Rec)
      end

      // сдвигаем предыдущую точку, если последние две и новая одинаковы
      else if (FRec1.y = Rec.y) and (FRec2.y = Rec.y) then
      begin
        Series.XValues.Value[Series.XValues.Count - 1] := Rec.x;
        FRec1 := Rec;
      end

      // проверяем возможность линейной апроксимации предыдущей точки
      else if (FRec1.x <> FRec2.x) then
      begin
        tmpY := FRec2.y +
          (FRec2.y - FRec1.y) * (Rec.x - FRec2.x) / (FRec2.x - FRec1.x);
        tmpY := StrToFloatDef(aOPCUtils.FormatValue(tmpY, DisplayFormat), tmpY);

        if (FRec2.x <> FRec1.x) and (Rec.y = tmpY) then
        begin
          Series.Delete(Series.XValues.Count - 1);
          FRec1 := FRec2;
        end;

        sAddXY(Rec);
      end

      else
        sAddXY(Rec);

      // удаляем самую левую точку, если это возможно и необходимо
      if (Series.XValues.Count > 3) and (Series.XValue[1] < Interval.Date1) then
        Series.Delete(0);

    end
    else
      sAddXY(Rec);

    // если ось времени в нормальном состоянии, то обновим ее шкалу
    if not Series.ParentChart.Zoomed then
    begin
      if (Interval.Kind = ikShift) then
        D2 := Max(Interval.Date2, Rec.x)
      else
        D2 := Interval.Date2;

      Series.ParentChart.BottomAxis.SetMinMax(Interval.Date1, D2); //Interval.Date2);
    end;

  except
    on e: Exception do
      OPCLog.WriteToLog('Error in TOPCSeriesAdapter.ChangeData : ' + e.Message);
  end;

end;

constructor TOPCSeriesAdapter.Create(aSeries: TChartSeries);
begin
  inherited Create;
  FSeries := aSeries;
  FDataLink := TaOPCDataLink.Create(aSeries);
  FDataLink.UpdateOnChangeMoment := True;
  FDataLink.OnChangeData := ChangeData;

  FShift := 0;
  FScale := 1;
  FShowState := True;

  Series.Active := True;
  Series.XValues.DateTime := true;

  Series.ColorEachPoint := True;
  if (Series is TCustomSeries) then
    TCustomSeries(Series).ColorEachLine := True;

  FFilter := TaOPCFilter.Create;
  //FFilter.DataLink := FDataLink;
  Series.Pen.Width := 0;

end;

destructor TOPCSeriesAdapter.Destroy;
begin
  if Assigned(OnDestroy) then
    OnDestroy(Self);

  OPCSource := nil;

  FreeAndNil(FFilter);
  FreeAndNil(FDataLink);

  inherited;
end;

procedure TOPCSeriesAdapter.eAddXY(x, y: double);

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
  if (Series.XValues.Count > 0) then // это не первая точка в графике
    Series.AddXY(x, FRec1.y / Scale + Shift, CalcLabel(FRec1.y), Series.Color);

  Series.AddXY(x, y / Scale + Shift, CalcLabel(y), Series.Color);
  FRec2 := FRec1;
  FRec1.x := x;
  FRec1.y := y;
  FRec1.s := 0;
end;

procedure TOPCSeriesAdapter.FillOPCData(ToNow, aSourceValues: Boolean);
var
  Stream: TMemoryStream;
  aOPCSource: TaOPCSource;
  aDate1, aDate2: TDateTime;
  D2: TDateTime;
  V2: Extended;
  saveScreenCursor: TCursor;
  aDataKindSet: TDataKindSet;
begin
  if not IsState then
  begin
    FillSerie(ToNow, aSourceValues);
    Exit;
  end;

  aOPCSource := TaOPCSource(OPCSource);

  if not Assigned(aOPCSource) then
    Exit;

  if Assigned(Series.ParentChart) then
    Series.ParentChart.Enabled := False;

  saveScreenCursor := Screen.Cursor;
  try
    Screen.Cursor := crHourGlass;

    Series.Clear;
    Stream := TMemoryStream.Create;
    try
      aDate1 := Series.ParentChart.BottomAxis.Minimum;
      if ToNow then
        aDate2 := 0
      else
        aDate2 := Series.ParentChart.BottomAxis.Maximum;

      if IsState then
        aDataKindSet := [dkState]
      else
        aDataKindSet := [dkValue];

      aOPCSource.FillHistory(Stream, PhysID, aDate1, aDate2, aDataKindSet);

      if Stream.Size > 0 then
      begin
        Stream.Read(D2, SIZEOF(D2));
        Stream.Read(V2, SIZEOF(V2));

        eAddXY(D2, V2);
        if Stream.Size = SIZEOF(D2) + SIZEOF(V2) then
        begin
          eAddXY(aDate1, V2);
          eAddXY(IfThen(aDate2 = 0, Now, aDate2), V2);
        end
        else
        begin
          while Stream.Position < Stream.Size do
          begin
            Stream.Read(D2, SIZEOF(D2));
            Stream.Read(V2, SIZEOF(V2));
            eAddXY(D2, V2);
          end;
        end;
      end;
    finally
      Stream.free;
    end;
  finally
    Screen.Cursor := saveScreenCursor;

    if Assigned(Series.ParentChart) then
      Series.ParentChart.Enabled := True;
  end;
end;

procedure TOPCSeriesAdapter.FillSerie(ToNow, aSourceValues: Boolean);
var
  Stream: TMemoryStream;
  aOPCSource: TaOPCSource;

  aDate1, aDate2: TDateTime;

  aMoment: TDatetime;
  aValue2: extended;
  aStateValue: extended;

  aCalc1, aCalc2: Double;

  saveScreenCursor: TCursor;

  sl: TStringList;
  i: Integer;
  a, b: Extended;
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
    Exit;

  if Assigned(Series.ParentChart) then
    Series.ParentChart.Enabled := false;

  saveScreenCursor := Screen.Cursor;
  try
    Screen.Cursor := crHourGlass;

    // 1. готовим почву - чистимся
    Series.Clear;

    // 2. если нужны исходные данне, без преобразований, то загружаем коэффициенты и таблицу преобразований
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

    // 3. определимся с периодом выборки
    aDate1 := Series.ParentChart.BottomAxis.Minimum;
    if ToNow then
      aDate2 := 0
    else
      aDate2 := Series.ParentChart.BottomAxis.Maximum;


    // получаем данные

    // вариант с фильтром
    if (Filter.Expression <> '') then
    begin
      // привязываем датчик к фильтру
      Filter.DataLink := DataLink;
      Filter.DataLink.OPCSource := OPCSource;

      // загружаем данные: наш датчик + датчики из фильтра
      Filter.Evaluator.Cinema.Date1 := aDate1;
      Filter.Evaluator.Cinema.Date2 := aDate2;
      Filter.Evaluator.Cinema.Active := True;

      // проходим по выборке
      aCalc1 := 0;
      aMoment := aDate1;
      Filter.Evaluator.Cinema.CurrentMoment := aMoment;
      aValue2 := StrToFloat(Filter.DataLink.Value);
      while not Filter.Evaluator.Cinema.Eof do
      begin
        // устанавливаемся на позицию
        Filter.Evaluator.Cinema.CurrentMoment := aMoment;

        // расчитываем фильтр
        aCalc2 := Filter.Evaluator.Calc;
        if (aCalc1 = 0) and (aCalc2 = 0) then
        begin
          sAddNullXY(aMoment, aValue2);
          aStateValue := cState_IsFiltered;
        end
        else if (aCalc1 <> 0) and (aCalc2 = 0) then
        begin
          // дорисовываем нормальные данные
          aStateValue := 0;
          aValue2 := StrToFloat(Filter.DataLink.Value);
          sAddXY(aMoment, aValue2, aStateValue);
          // начинаем пустышку
          sAddNullXY(aMoment, aValue2);
          aStateValue := cState_IsFiltered;
        end
        else
        begin
          aStateValue := 0;
          // расчитываем датчик
          aValue2 := StrToFloat(Filter.DataLink.Value);
          // добавляем точку на график
          sAddXY(aMoment, aValue2, aStateValue);
        end;

        aCalc1 := aCalc2;

        // вычисляем следующую позицию
        aMoment := Filter.Evaluator.Cinema.GetNextMoment;
        if aMoment = 0 then
          Break;
      end;

      // выключаем фильтр
      Filter.Active := False;
    end

    // вариант без фильтрации
    else
    begin
      Stream := TMemoryStream.Create;
      try
        // выбираем показания и состояния датчика за период
        if ShowState then
          aOPCSource.FillHistory(Stream, PhysID, aDate1, aDate2, [dkValue, dkState])
        else
          aOPCSource.FillHistory(Stream, PhysID, aDate1, aDate2, [dkValue]);

      aStateValue := 0;
      if Stream.Size > 0 then
      begin
        Stream.Read(aMoment, SizeOf(aMoment)); // момент времени
        Stream.Read(aValue2, SizeOf(aValue2)); // значение
        if aSourceValues then
          aValue2 := BackTransform(aValue2);

        if ShowState then
          Stream.Read(aStateValue, SizeOf(aStateValue)); // состояние

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
            Stream.Read(aMoment, SizeOf(aMoment)); // момент времени
            Stream.Read(aValue2, SizeOf(aValue2)); // значение
            if aSourceValues then
              aValue2 := BackTransform(aValue2);
            if ShowState then
              Stream.Read(aStateValue, SizeOf(aStateValue)); // состояние

            sAddXY(aMoment, aValue2, aStateValue);
          end;
        end;
      end;
    finally
        Stream.free;
      end;
    end;
  finally
    Screen.Cursor := saveScreenCursor;
    if Assigned(Series.ParentChart) then
      Series.ParentChart.Enabled := true;
    //OPCLog.WriteToLog(IntToStr(XValues.Count) +' точек за ' + IntToStr(GetTickCount - tc));
  end;
end;

function TOPCSeriesAdapter.GetConnectionName: string;
begin
  Result := FConnectionName;
end;

function TOPCSeriesAdapter.GetFilter: TaOPCFilter;
begin
  Result := FFilter;
end;

function TOPCSeriesAdapter.GetFullName: string;
begin
  Result := FFullName;
end;

function TOPCSeriesAdapter.GetInterval: TOPCInterval;
begin
  if Series.ParentChart is TaOPCChart then
    Result := TaOPCChart(Series.ParentChart).Interval
  else
    Result := nil;
end;

function TOPCSeriesAdapter.GetOPCSource: TaCustomOPCSource;
begin
  Result := FOPCSource;
end;

function TOPCSeriesAdapter.GetPhysID: TPhysID;
begin
  Result := FDataLink.PhysID;
end;

function TOPCSeriesAdapter.GetRealTime: Boolean;
begin
  if Series.ParentChart is TaOPCChart then
    Result := TaOPCChart(Series.ParentChart).RealTime
  else
    Result := False;
end;

function TOPCSeriesAdapter.GetScale: Double;
begin
  Result := FScale;
end;

function TOPCSeriesAdapter.GetShift: Double;
begin
  Result := FShift;
end;

function TOPCSeriesAdapter.GetShortName: string;
begin
  Result := FShortName;
end;

function TOPCSeriesAdapter.GetShowFullName: Boolean;
begin
  Result := FShowFullName;
end;

function TOPCSeriesAdapter.GetStairsOptions: TDCStairsOptionsSet;
begin
  Result := FDataLink.StairsOptions;
end;

procedure TOPCSeriesAdapter.RestoreFromOriginal;
var
  i: Integer;
begin
  FSeries.Clear;
//  FSeries.Stairs := false;
  for i := Low(FOriginalXY) to High(FOriginalXY) do
    sAddXY(FOriginalXY[i].x, FOriginalXY[i].y);

  // - очистим массив (он нам уже не нужен)
  SetLength(FOriginalXY, 0);
end;

procedure TOPCSeriesAdapter.sAddNullXY(x, y: double);
var
  aRec: TXYS;
begin
  // добавляем новое значение
  aRec := GetXYSRec(x, y, 0);
  Series.AddNullXY(aRec.x, aRec.y / Scale + Shift);

  FRec2 := FRec1;
  FRec1 := aRec;
end;

procedure TOPCSeriesAdapter.sAddXY(aRec: TXYS);

  function CalcColor: TColor;
  begin
    if FRec1.s = 0 then
      Result := Series.Color
    else if (aRec.s = cState_IsFiltered) and HideFiltered then
      Result := clNone
    else
      Result := cErrorSerieColor;
  end;

  function CalcColor0: TColor;
  begin
    if (FRec1.s = 0) then
      Result := Series.Color
    else
      Result := cErrorSerieColor;
  end;

  function CalcLabel(aValue: double; aStateValue: extended): string;
  var
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
        aLookupList.Lookup(FloatToStr(aValue), Result);
      end
      else
        // преобразуем исходное значение согласно формату отображения
        Result := aOPCUtils.FormatValue(aValue, DisplayFormat);
    end
    else // есть ошибки
    begin
      Result := 'не задан справочник ошибок';

      aStates := StateLookupList;
      if not Assigned(aStates) and Assigned(OPCSource) then
        aStates := TaOPCLookupList(OPCSource.States);

      if Assigned(aStates) then
        aStates.Lookup(FloatToStr(aStateValue), Result);
      //  Result := aStates.GetValue(FloatToStr(aStateValue), 'Unknown Error');
    end;
  end;
begin
  if (Series.XValues.Count > 0) // это не первая точка в графике
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
    Series.AddXY(aRec.x, FRec1.y / Scale + Shift, CalcLabel(FRec1.y, FRec1.s), CalcColor0);
  end;

  // добавляем новое значение
  Series.AddXY(aRec.x, aRec.y / Scale + Shift, CalcLabel(aRec.y, aRec.s), CalcColor);
  FRec2 := FRec1;
  FRec1 := aRec;
end;

procedure TOPCSeriesAdapter.sAddXY(x, y, s: double);
begin
  sAddXY(GetXYSRec(x, y, s));
end;

procedure TOPCSeriesAdapter.SetConnectionName(const Value: string);
begin
  FConnectionName := Value;
end;

procedure TOPCSeriesAdapter.SetDataLink(const Value: TaOPCDataLink);
begin
  FDataLink.Assign(Value);
end;

procedure TOPCSeriesAdapter.SetDifferentialOrder(const Value: Integer);
begin
  FDifferentialOrder := Value;
end;

procedure TOPCSeriesAdapter.SetDisplayFormat(const Value: string);
begin
  FDisplayFormat := Value;
end;

procedure TOPCSeriesAdapter.SetFilter(const Value: TaOPCFilter);
begin
  FFilter.Assign(Value);
end;

procedure TOPCSeriesAdapter.SetFullName(const Value: string);
begin
  FFullName := Value;
  UpdateTitle;
end;

procedure TOPCSeriesAdapter.SetHideFiltered(const Value: Boolean);
begin
  FHideFiltered := Value;
end;

procedure TOPCSeriesAdapter.SetIsState(const Value: boolean);
begin
  FIsState := Value;
end;

procedure TOPCSeriesAdapter.SetLookupList(const Value: TaOPCLookupList);
begin
  FLookupList := Value;
end;

procedure TOPCSeriesAdapter.SetOPCSource(const Value: TaCustomOPCSource);
begin
  FOPCSource := Value;

  if RealTime and (FDataLink.OPCSource <> Value) then
    FDataLink.OPCSource := Value;
end;

procedure TOPCSeriesAdapter.SetPhysID(const Value: TPhysID);
begin
  FDataLink.PhysID := Value;
end;

procedure TOPCSeriesAdapter.SetScale(const Value: double);
var
  i: integer;
begin
  if (FScale = Value) or (Value = 0) then
    exit;
  for i := 0 to Series.YValues.Count - 1 do
    Series.YValue[i] := (Series.YValue[i] - FShift) * FScale / Value + FShift;
  FScale := Value;
  UpdateTitle;
end;

procedure TOPCSeriesAdapter.SetShift(const Value: double);
var
  i: Integer;
begin
  if (FShift = Value) then
    exit;

  for i := 0 to Series.YValues.Count - 1 do
    Series.YValue[i] := Series.YValue[i] - FShift + Value;

  FShift := Value;
  UpdateTitle;
end;

procedure TOPCSeriesAdapter.SetShortName(const Value: string);
begin
  if FShortName <> Value then
  begin
    FShortName := Value;
    UpdateTitle;
  end;
end;

procedure TOPCSeriesAdapter.SetShowFullName(const Value: Boolean);
begin
  if FShowFullName <> Value then
  begin
    FShowFullName := Value;
    UpdateTitle;
  end;
end;

procedure TOPCSeriesAdapter.SetShowState(const Value: boolean);
begin
  FShowState := Value;
end;

procedure TOPCSeriesAdapter.SetStairsOptions(const Value: TDCStairsOptionsSet);
begin
  FDataLink.StairsOptions := Value;
end;

procedure TOPCSeriesAdapter.SetStateLookupList(const Value: TaOPCLookupList);
begin
  FStateLookupList := Value;
end;

procedure TOPCSeriesAdapter.SetStatisticalFunc(const Value: TStatisticalFunc);
begin
  if FStatisticalFunc <> Value then
    FStatisticalFunc := Value;
end;

procedure TOPCSeriesAdapter.SetStatisticalPeriod(const Value: TDateTime);
begin
  FStatisticalPeriod := Value;
end;

procedure TOPCSeriesAdapter.StoreToOriginal;
var
  i: Integer;
begin
  SetLength(FOriginalXY, FSeries.XValues.Count);
  for i := 0 to FSeries.XValues.Count - 1 do
  begin
    FOriginalXY[i].x := FSeries.XValue[i];
    FOriginalXY[i].y := FSeries.YValue[i];
  end;
end;

procedure TOPCSeriesAdapter.UpdateRealTime;
begin
  if Assigned(Series.ParentChart) and (Series.ParentChart is TaOPCChart) then
  begin
    if TaOPCChart(Series.ParentChart).RealTime then
      FDataLink.OPCSource := FOPCSource
    else
      FDataLink.OPCSource := nil;
  end;
end;

procedure TOPCSeriesAdapter.UpdateTitle;
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
    tmpName := Series.Name;

  if FIsState then
    { TODO -oОлександр -cлокалізація : реалізувати локалізацію }
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
    { TODO -oОлександр -cлокалізація : реалізувати локалізацію }
    tmpName := Format('%s (интеграл %d-го порядка)', [tmpName, FDifferentialOrder]);
  end;

  if (FScale <> 1) then
    tmpName := Format('%s (1x%g)', [tmpName, FScale]);

  if FShift > 0 then
    tmpName := Format('%s + %g', [tmpName, FShift])
  else if FShift < 0 then
    tmpName := Format('%s %g', [tmpName, FShift]);

  Series.Title := tmpName;
end;

end.
