unit uOPCGanttSeries;

{$I VCL.DC.inc}

interface

uses
  System.Classes, System.SysUtils,
  Vcl.Controls, Vcl.Forms, Vcl.Graphics,
  {$IFDEF TEEVCL}
  VCLTee.Chart, VCLTee.Series, VCLTee.TeEngine, VCLTee.GanttCh,
  {$ELSE}
  Chart, Series, TeEngine, GanttCh,
  {$ENDIF}
  aOPCSeries,
  uOPCSeriesTypes,
  uDCObjects, uOPCInterval,
  aOPCLookupList, uOPCFilter,
  aCustomOPCSource;

type

  TaOPCGanttSeries = class(TGanttSeries, IaOPCSeries)
  private
  	FFilter: TaOPCFilter;
    FHideFiltered: Boolean;
    FDataLink: TaOPCDataLink;
    FLookupList: TaOPCLookupList;
    FOnDestroy: TNotifyEvent;
    FOPCSource: TaCustomOPCSource;
    FConnectionName: string;
    FShowState: boolean;

    FRec1, FRec2: TXYS;
    FStateLookupList: TaOPCLookupList;
    FDisplayFormat: string;
    FShift: double;
    FScale: double;
    FShowFullName: boolean;
    FShortName: string;
    FFullName: string;

    function GetInterval: TOPCInterval;
    function GetRealTime: boolean;
    procedure SetDataLink(const Value: TaOPCDataLink);
    procedure SetConnectionName(const Value: string);
    procedure SetLookupList(const Value: TaOPCLookupList);
    procedure SetOPCSource(const Value: TaCustomOPCSource);
    function GetFilter: TaOPCFilter;
    procedure SetFilter(const Value: TaOPCFilter);
    procedure SetHideFiltered(const Value: Boolean);

    procedure ChangeData(Sender: TObject);
    function GetPhysID: TPhysID;
    procedure SetPhysID(const Value: TPhysID);
    procedure SetShowState(const Value: boolean);
    procedure SetStateLookupList(const Value: TaOPCLookupList);
    procedure SetDisplayFormat(const Value: string);
    procedure SetScale(const Value: double);
    procedure SetShift(const Value: double);
    procedure SetFullName(const Value: string);
    procedure SetShortName(const Value: string);
    procedure SetShowFullName(const Value: boolean);
    function GetScale: Double;
    function GetShift: Double;
    function GetConnectionName: string;
    function GetOPCSource: TaCustomOPCSource;
    function GetFullName: string;
    function GetShortName: string;
    function GetShowFullName: boolean;
  protected
    procedure UpdateTitle;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;

    function RecIsActive(aRec: TXYS): Boolean;
    procedure ClearRecs;
    procedure UpdateRecs(aRec: TXYS);

    procedure eAddXY(x, y: double);

    procedure sAddXY(aRec: TXYS); overload;
    procedure sAddXY(x, y: Double; s: Double = 0); overload;
    procedure sAddNullXY(x, y: Double);

    procedure FillSerie(ToNow: boolean = false; aSourceValues: Boolean = False);
    procedure UpdateRealTime;

    property RealTime: boolean read GetRealTime;
    property Interval: TOPCInterval read GetInterval;

    property DataLink: TaOPCDataLink read FDataLink write SetDataLink;
  published
    property ShortName: string read GetShortName write SetShortName;
    property FullName: string read GetFullName write SetFullName;
    property ShowFullName: boolean read GetShowFullName write SetShowFullName;

    property PhysID: TPhysID read GetPhysID write SetPhysID;
    property Scale: Double read GetScale write SetScale;
    property Shift: Double read GetShift write SetShift;


    property OPCSource: TaCustomOPCSource read GetOPCSource write SetOPCSource;
    property ConnectionName: string read GetConnectionName write SetConnectionName;

    property LookupList: TaOPCLookupList read FLookupList write SetLookupList;
    property StateLookupList: TaOPCLookupList read FStateLookupList write SetStateLookupList;

    property DisplayFormat: string read FDisplayFormat write SetDisplayFormat;


    property ShowState: boolean read FShowState write SetShowState default True;

    property Filter: TaOPCFilter read GetFilter write SetFilter;
    property HideFiltered: Boolean read FHideFiltered write SetHideFiltered;

    property OnDestroy: TNotifyEvent read FOnDestroy write FOnDestroy;

  end;



implementation

uses
  Math,
  aOPCUtils, aOPCLog,
  uOPCConst,
  aOPCSource,
  aOPCChart;

{ TaOPCGanttSeries }

procedure TaOPCGanttSeries.ChangeData(Sender: TObject);
var
  //tmpY: double;
  aRec: TXYS;
  D2: TDateTime;
begin
  if (not Assigned(ParentChart)) or (not (ParentChart is TaOPCChart)) then
    Exit;

  try
    if (FDataLink.Moment = 0) or (FDataLink.Value = '') then
      Exit;

    if (Interval.Kind = ikInterval) and
      ((FDataLink.Moment < Interval.Date1) or (FDataLink.Moment > Interval.Date2)) then
      Exit;

    aRec.x := FDataLink.Moment;
    aRec.y := StrToFloatDef(FDataLink.Value, 0);
    aRec.s := FDataLink.ErrorCode;

    sAddXY(aRec);

    {
    if XValues.Count > 1 then
    begin
      // удаляем самую левую точку, если это возможно и необходимо
      if (XValues.Count > 3) and (XValue[1] < Interval.Date1) then
        Delete(0);

    end;
    }

    // если ось времени в нормальном состоянии, то обновим ее шкалу
    if not ParentChart.Zoomed then
    begin
      if (Interval.Kind = ikShift) then
        D2 := Max(Interval.Date2, aRec.x)
      else
        D2 := Interval.Date2;

      ParentChart.BottomAxis.SetMinMax(Interval.Date1, D2); //Interval.Date2);
    end;

  except
    on e: Exception do
      OPCLog.WriteToLog('Error in TaOPCGanttSeries.ChangeData : ' + e.Message);
  end;

//  if FRec1.y <> 0 then
//    AddGanttColor(FRec1.x, aRec.x, FRec1.y / Scale + Shift, CalcLabel(FRec1.y, FRec1.s), CalcColor);

end;

procedure TaOPCGanttSeries.ClearRecs;
begin
  FRec1.Clear;
  FRec2.Clear;
end;

constructor TaOPCGanttSeries.Create(aOwner: TComponent);
begin
  inherited;
  Pointer.Pen.Width := 0;

  Active := true;

  XValues.DateTime := true;

  FDataLink := TAOPCDataLink.Create(Self);
  FDataLink.UpdateOnChangeMoment := true;
  FDataLink.OnChangeData := ChangeData;

  ColorEachLine := true;
  ColorEachPoint := true;

  FScale := 1;
  FShift := 0;

  FFilter := TaOPCFilter.Create;
end;

destructor TaOPCGanttSeries.Destroy;
begin
  if Assigned(OnDestroy) then
    OnDestroy(Self);

  OPCSource := nil;

  FreeAndNil(FFilter);
  FreeAndNil(FDataLink);

  inherited;
end;


procedure TaOPCGanttSeries.eAddXY(x, y: double);
begin

end;

procedure TaOPCGanttSeries.FillSerie(ToNow, aSourceValues: Boolean);
var
  Stream: TMemoryStream;
  aOPCSource: TaOPCSource;

  aDate1, aDate2: TDateTime;

  aMoment: TDatetime;
  //aValue1,
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

  if Assigned(ParentChart) then
    ParentChart.Enabled := False;

  saveScreenCursor := Screen.Cursor;
  try
    Screen.Cursor := crHourGlass;

    // 1. готовим почву - чистимся
    Clear;
    ClearRecs;

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
    aDate1 := ParentChart.BottomAxis.Minimum;
    if ToNow then
      aDate2 := 0
    else
      aDate2 := ParentChart.BottomAxis.Maximum;


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
      //aCalc2 := 0;
      aMoment := aDate1;
      //aValue2 := 0;
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
          //AddNullXY(aMoment, MinYValue);
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
            //aValue1 := aValue2;

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
    if Assigned(ParentChart) then
      ParentChart.Enabled := true;
  end;
end;

function TaOPCGanttSeries.GetConnectionName: string;
begin
  Result := FConnectionName;
end;

function TaOPCGanttSeries.GetFilter: TaOPCFilter;
begin
  Result := FFilter;
end;

function TaOPCGanttSeries.GetFullName: string;
begin
  Result := FFullName;
end;

function TaOPCGanttSeries.GetInterval: TOPCInterval;
begin
  if ParentChart is TaOPCChart then
    Result := TaOPCChart(ParentChart).Interval
  else
    Result := nil;
end;

function TaOPCGanttSeries.GetOPCSource: TaCustomOPCSource;
begin
  Result := FOPCSource;
end;

function TaOPCGanttSeries.GetPhysID: TPhysID;
begin
  Result := FDataLink.PhysID;
end;

function TaOPCGanttSeries.GetRealTime: boolean;
begin
  if Assigned(ParentChart) and (ParentChart is TaOPCChart) then
    Result := TaOPCChart(ParentChart).RealTime
  else
    Result := False;
end;

function TaOPCGanttSeries.GetScale: Double;
begin
  Result := FScale;
end;

function TaOPCGanttSeries.GetShift: Double;
begin
  Result := FShift;
end;

function TaOPCGanttSeries.GetShortName: string;
begin
  Result := FShortName;
end;

function TaOPCGanttSeries.GetShowFullName: boolean;
begin
  Result := FShowFullName;
end;

procedure TaOPCGanttSeries.Notification(AComponent: TComponent; Operation: TOperation);
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

function TaOPCGanttSeries.RecIsActive(aRec: TXYS): Boolean;
begin
  Result := (aRec.x <> 0) and (aRec.y <> 0);
end;

procedure TaOPCGanttSeries.sAddNullXY(x, y: Double);
var
  aRec: TXYS;
begin
  // добавляем новое значение
  aRec := GetXYSRec(x, y, 0);
  AddNullXY(aRec.x, aRec.y / Scale + Shift);

  FRec2 := FRec1;
  FRec1 := aRec;
end;

procedure TaOPCGanttSeries.sAddXY(x, y, s: Double);
begin
  sAddXY(GetXYSRec(x, y, s));
end;

procedure TaOPCGanttSeries.sAddXY(aRec: TXYS);
//var
//  aLabel: string;
//  aColor: TColor;

  function CalcColor: TColor; //(aState1, aState2: extended): TColor;
  begin
    if {(aState = 0) and }(FRec1.s = 0) then
      Result := Color
    else if (aRec.s = cState_IsFiltered) and HideFiltered then
    begin
      //if Assigned(ParentChart) then
        Result := clNone // ParentChart.Color
    end
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
    //aIndex: integer;
    aLookupList: TaOPCLookupList;
    aStates: TaOPCLookupList;
  begin
    aLookupList := LookupList;

    if aStateValue = 0 then // нет ошибок
    begin
      // если есть справочник, то поищем в нём
      if Assigned(aLookupList) then
        aLookupList.Lookup(FloatToStr(aValue), Result)
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
        aStates.Lookup(FloatToStr(aStateValue), Result);
    end;
  end;
begin
  // первая точка, но уже нужно что-то рисовать
  if (FRec1.x = 0) and RecIsActive(aRec) then
    AddGanttColor(aRec.x, aRec.x, aRec.y / Scale + Shift, CalcLabel(aRec.y, aRec.s), Color)

  // были активны - нужно дорисовать начатое
  else if RecIsActive(FRec1) then
  begin
    EndValues[EndValues.Count-1] := aRec.x;
    Repaint;
  end

  // стали активны - новая полоса
  else if RecIsActive(aRec) then
    AddGanttColor(aRec.x, aRec.x, aRec.y / Scale + Shift, CalcLabel(aRec.y, aRec.s), Color);

  UpdateRecs(aRec);

//  if FRec1.y <> 0 then
//    AddGanttColor(FRec1.x, aRec.x, FRec1.y / Scale + Shift, CalcLabel(FRec1.y, FRec1.s), CalcColor);

{
  if (XValues.Count > 0) // это не первая точка в графике
    and (FRec1.s <> aRec.s) then
  begin
    // добавляем  СТАРОЕ ЗНАЧЕНИЕ на НОВЫЙ МОМЕНТ времени, с целью
    // показать длительность действия этого значения
    AddXY(aRec.x, FRec1.y / Scale + Shift, CalcLabel(FRec1.y, FRec1.s), CalcColor0);
  end;

  // добавляем новое значение
  AddXY(aRec.x, aRec.y / Scale + Shift, CalcLabel(aRec.y, aRec.s), CalcColor);

  FRec2 := FRec1;
  FRec1 := aRec;
}
end;

procedure TaOPCGanttSeries.SetConnectionName(const Value: string);
begin
  FConnectionName := Value;
end;

procedure TaOPCGanttSeries.SetDataLink(const Value: TaOPCDataLink);
begin
  FDataLink.Assign(Value);
end;

procedure TaOPCGanttSeries.SetDisplayFormat(const Value: string);
begin
  FDisplayFormat := Value;
end;

procedure TaOPCGanttSeries.SetFilter(const Value: TaOPCFilter);
begin
  FFilter.Assign(Value);
end;

procedure TaOPCGanttSeries.SetFullName(const Value: string);
begin
  FFullName := Value;
  UpdateTitle;
end;

procedure TaOPCGanttSeries.SetHideFiltered(const Value: Boolean);
begin
  FHideFiltered := Value;
end;

procedure TaOPCGanttSeries.SetLookupList(const Value: TaOPCLookupList);
begin
  FLookupList := Value;
end;

procedure TaOPCGanttSeries.SetOPCSource(const Value: TaCustomOPCSource);
begin
  FOPCSource := Value;

  if RealTime and (FDataLink.OPCSource <> Value) then
    FDataLink.OPCSource := Value;
end;

procedure TaOPCGanttSeries.SetPhysID(const Value: TPhysID);
begin
  FDataLink.PhysID := Value;
end;

procedure TaOPCGanttSeries.SetScale(const Value: double);
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

procedure TaOPCGanttSeries.SetShift(const Value: double);
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

procedure TaOPCGanttSeries.SetShortName(const Value: string);
begin
  if FShortName <> Value then
  begin
    FShortName := Value;
    UpdateTitle;
  end;
end;

procedure TaOPCGanttSeries.SetShowFullName(const Value: boolean);
begin
  if FShowFullName <> Value then
  begin
    FShowFullName := Value;
    UpdateTitle;
  end;
end;

procedure TaOPCGanttSeries.SetShowState(const Value: boolean);
begin
  FShowState := Value;
end;

procedure TaOPCGanttSeries.SetStateLookupList(const Value: TaOPCLookupList);
begin
  FStateLookupList := Value;
end;

procedure TaOPCGanttSeries.UpdateRealTime;
begin
  if Assigned(ParentChart) and (ParentChart is TaOPCChart) then
  begin
    if TaOPCChart(ParentChart).RealTime then
      FDataLink.OPCSource := FOPCSource
    else
      FDataLink.OPCSource := nil;
  end;
end;

procedure TaOPCGanttSeries.UpdateRecs(aRec: TXYS);
begin
  FRec2 := FRec1;
  FRec1 := aRec;
end;

procedure TaOPCGanttSeries.UpdateTitle;
var
  tmpName: string;
begin
  if ShowFullName then
    tmpName := FullName
  else
    tmpName := ShortName;

  if tmpName = '' then
    tmpName := Name;

//  if (FScale <> 1) then
//    tmpName := Format('%s (1x%g)', [tmpName, FScale]);
//
//  if FShift > 0 then
//    tmpName := Format('%s + %g', [tmpName, FShift])
//  else if FShift < 0 then
//    tmpName := Format('%s %g', [tmpName, FShift]);

  Title := tmpName;
end;

end.
