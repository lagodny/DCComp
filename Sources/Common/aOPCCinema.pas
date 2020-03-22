unit aOPCCinema;

interface

uses
  Classes, Forms, ExtCtrls, Windows, Dialogs, Controls,
  aOPCClass, uDCObjects, aCustomOPCSource, aOPCSource, aOPCLog;

type
  TCrackOPCLink = class(TaOPCDataLink);
  TCrackOPCSource = class(TaOPCSource);

  TFillHistoryEvent = procedure(var StopFill: boolean; Progress: integer) of
    object;

  TValueSnapshot = record
    FDateTime: TDateTime;
    FValue: Extended;
    FState: Extended;
  end;

  TOPCDataLinkGroupHistory = class(TOPCDataLinkGroup)
  private
    FBof: boolean;
    FEof: boolean;
    FCurrentPosition: integer;
    procedure SetCurrentPosition(const Value: integer);
    function GetCurrentMoment: TDateTime;
    function GetCurrentValue: Extended;
    function GetCurrentState: Extended;
  public
    FValues: array of TValueSnapshot;
    FSource: TaCustomOPCSource;

    property CurrentPosition: integer read FCurrentPosition write
      SetCurrentPosition;
    function IsEmpty: boolean;
    property Eof: boolean read FEof;
    property Bof: boolean read FBof;
    function GetIndexOnDate(aDateTime: TDateTime): integer;
    function GetValueOnDate(aDateTime: TDateTime): extended;

    function GetSnapshotOnDate(aDateTime: TDateTime): TValueSnapshot;

    function GetNextMoment(var aMoment: TDateTime): boolean;
    function GetPredMoment(var aMoment: TDateTime): boolean;

    property CurrentMoment: TDateTime read GetCurrentMoment;
    property CurrentValue: Extended read GetCurrentValue;
    property CurrentState: Extended read GetCurrentState;
  end;

  TSourceItem = class
  public
    Source: TaOPCSource;
    GroupLinks: TList;
    constructor Create;
    destructor Destroy; override;
  end;

  TaOPCCinema = class(TaCustomMultiOPCSource)
  private
    FInTimer: boolean;
    FInCalc: boolean;

    //FSources: TList;

    FSaveOPCSourceActive: boolean;

    //FOPCSource: TaOPCSource;

    FDate1: TDateTime;
    FDate2: TDateTime;

    FStep: integer;
    FOnChangeMoment: TNotifyEvent;
    FTimer: TTimer;
    FOnFillHistory: TFillHistoryEvent;
    FBof: boolean;
    FEof: boolean;
    FDataKind: TDataKind;
    FOnRequest: TNotifyEvent;
    FSpeed: integer;
    FShowUserMessages: Boolean;
    FBeforeActivate: TNotifyEvent;
    procedure TimeTimer(Sender: TObject);
    //    procedure SetOPCSource(const Value: TaOPCSource);
    procedure SetDate1(const Value: TDateTime);
    procedure SetDate2(const Value: TDateTime);
    procedure SetSleepInterval(const Value: integer);
    procedure SetStep(const Value: integer);
    function GetSleepInterval: integer;
    function GetPlaying: boolean;
    procedure SetPlaing(const Value: boolean);
    procedure SetDataKind(const Value: TDataKind);
    procedure SetSpeed(const Value: integer);
    procedure SetShowUserMessages(const Value: Boolean);
  protected
    function FindDataLinkGroupHistory(
      DataLink: TaOPCDataLink; aSource: TaCustomOPCSource): TOPCDataLinkGroupHistory;

    procedure SetCurrentMoment(const Value: TDateTime); override;

    procedure DoActive; override;
    procedure DoNotActive; override;
    procedure DoRequest;
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
    procedure AddDataLink(DataLink: TaOPCDataLink;
      OldSource: TaCustomOPCSource = nil); override;
    function GetMoment(aDirection: TDirection = dNext): TDateTime;
  public
    // упрощенный вариант (ищем только по ID
    function FindGroupHistory(aID: TPhysID): TOPCDataLinkGroupHistory;
    
    procedure ConnectOPCSourceDataLinks(aSource: TaOPCSource);
    procedure DisconnectOPCSourceDataLinks;
    procedure FreeHistory;
    function FillHistory(Date1, Date2: TDatetime): boolean;
    procedure SaveHistory(aFileName: string; aVersion: string);
    procedure LoadHistory(aFileName: string; aVersion: string);
    function GetNextMoment: TDateTime;
    function GetPredMoment: TDateTime;
    procedure CalcValuesOnMoment(aMoment: TDateTime);
    procedure Play;
    procedure Stop;
    procedure HidePult;
    procedure ShowPult(aFormToPrint: TForm = nil; Modal: boolean = true);
    function Skip(aCount: integer): boolean;

    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;

    property Eof: boolean read FEof;
    property Bof: boolean read FBof;

    property Playing: boolean read GetPlaying write SetPlaing;
  published
    property OnChangeMoment: TNotifyEvent read FOnChangeMoment write FOnChangeMoment;
    property OnFillHistory: TFillHistoryEvent read FOnFillHistory write FOnFillHistory;

    // случается, когда прошел цикл опроса датчиков
    property OnRequest: TNotifyEvent read FOnRequest write FOnRequest;
    // случается перед загрузкой
    property BeforeActivate: TNotifyEvent read FBeforeActivate write FBeforeActivate;

    //    property OPCSource:TaOPCSource read FOPCSource write SetOPCSource;
    property Date1: TDateTime read FDate1 write SetDate1 stored false;
    property Date2: TDateTime read FDate2 write SetDate2 stored false;
    property CurrentMoment;
      // : TDateTime;// read FCurrentMoment write SetCurrentMoment stored false;

    property Step: integer read FStep write SetStep default 20; // в секундах
    property SleepInterval: integer read GetSleepInterval write SetSleepInterval default 100; // милисекунд
    property Speed: integer read FSpeed write SetSpeed default 1;

    property DataKind: TDataKind read FDataKind write SetDataKind default dkValue;
    property ShowUserMessages: Boolean read FShowUserMessages write SetShowUserMessages default False;
  end;

implementation

uses SysUtils, Math
  , uCinemaControlForm
  ;

{ TOPCDataLinkGroupHistory }
{
function TOPCDataLinkGroupHistory.Bof: boolean;
begin
  Result := (CurrentPosition <= Low(FValues));
end;

function TOPCDataLinkGroupHistory.Eof: boolean;
begin
  Result := (CurrentPosition >= High(FValues));
end;
}

function TOPCDataLinkGroupHistory.GetCurrentMoment: TDateTime;
begin
  Result := FValues[CurrentPosition].FDateTime;
end;

function TOPCDataLinkGroupHistory.GetCurrentState: Extended;
begin
  Result := FValues[CurrentPosition].FState;
end;

function TOPCDataLinkGroupHistory.GetCurrentValue: Extended;
begin
  Result := FValues[CurrentPosition].FValue;
end;

function TOPCDataLinkGroupHistory.GetIndexOnDate(
  aDateTime: TDateTime): integer;
var
  L, H, I: Integer;
  Item1: TDateTime;
begin
  H := High(FValues);
  if H = -1 then
  begin
    Result := -1;
    exit;
  end;
  L := low(FValues);
  while L <= H do
  begin
    I := (L + H) shr 1;
    Item1 := FValues[I].FDateTime;

    if Item1 < aDateTime then
      L := I + 1
    else
    begin
      H := I - 1;
      if Item1 = aDateTime then
      begin
        //Result := I;
        L := I;
      end;
    end;
  end;
  if Item1 <= aDateTime then
    Result := I
  else if H < L then
    Result := H
  else
    Result := L;

  if Result < 0 then
    exit;

  while (Result < High(FValues)) and
    (FValues[Result].FDateTime = FValues[Result + 1].FDateTime) do
    Inc(Result);
end;

function TOPCDataLinkGroupHistory.GetNextMoment(
  var aMoment: TDateTime): boolean;
begin
  if FCurrentPosition >= High(FValues) then
    Result := false
  else
  begin
    aMoment := FValues[CurrentPosition + 1].FDateTime;
    Result := True;
  end;
end;

function TOPCDataLinkGroupHistory.GetPredMoment(
  var aMoment: TDateTime): boolean;
begin
  if FCurrentPosition <= Low(FValues) then
    Result := false
  else
  begin
    aMoment := FValues[CurrentPosition - 1].FDateTime;
    Result := True;
  end;
end;

function TOPCDataLinkGroupHistory.GetSnapshotOnDate(aDateTime: TDateTime): TValueSnapshot;
var
  i1: integer;
  v1, v2: extended;
  x1, x2: TDateTime;
begin
  Result.FDateTime := aDateTime;
  Result.FValue := 0;
  Result.FState := 0;

  i1 := GetIndexOnDate(aDateTime);
  if i1 < 0 then
  begin
    CurrentPosition := 0;
    Exit;
  end;
  CurrentPosition := i1;

  v1 := FValues[i1].FValue;
  Result.FState := FValues[i1].FState;

  if i1 = High(FValues) then
  begin
    Moment := FValues[i1].FDateTime;
    Result.FValue := v1
  end
  else
  begin
    x1 := FValues[i1].FDateTime;
    x2 := FValues[i1 + 1].FDateTime;
    v2 := FValues[i1 + 1].FValue;

    if
      (Result.FState = 0) and // добавим проверку на корректность данных
      (x2 <> x1) and
      (((v1 < v2) and (soIncrease in StairsOptions))
      or ((v1 > v2) and (soDecrease in StairsOptions))) then
    begin
      Moment := aDateTime;
      Result.FValue := v2 - (v2 - v1) * (x2 - aDateTime) / (x2 - x1)
    end
    else
    begin
      Moment := FValues[i1].FDateTime;
      Result.FValue := FValues[i1].FValue;
    end;
  end;
end;

function TOPCDataLinkGroupHistory.GetValueOnDate(
  aDateTime: TDateTime): extended;
var
  i1: integer;
  v1, v2: extended;
  x1, x2: TDateTime;
begin
  i1 := GetIndexOnDate(aDateTime);
  if i1 < 0 then
  begin
    CurrentPosition := 0;
    Result := 0;
    Exit;
  end;
  CurrentPosition := i1;
  v1 := FValues[i1].FValue;
  if i1 = High(FValues) then
  begin
    Moment := FValues[i1].FDateTime;
    Result := v1
  end
  else
  begin
    x1 := FValues[i1].FDateTime;
    x2 := FValues[i1 + 1].FDateTime;
    v2 := FValues[i1 + 1].FValue;
    if (x2 <> x1) and
      (((v1 < v2) and (soIncrease in StairsOptions))
      or ((v1 > v2) and (soDecrease in StairsOptions))) then
    begin
      Moment := aDateTime;
      Result := v2 - (v2 - v1) * (x2 - aDateTime) / (x2 - x1)
    end
    else
    begin
      Moment := FValues[i1].FDateTime;
      Result := FValues[i1].FValue;
    end;
  end;
end;

function TOPCDataLinkGroupHistory.IsEmpty: boolean;
begin
  Result := (High(FValues) = -1);
end;

procedure TOPCDataLinkGroupHistory.SetCurrentPosition(const Value: integer);
begin
  FBof := false;
  FEof := false;
  FCurrentPosition := Value;

  if Value < Low(FValues) then
  begin
    FBof := true;
    FCurrentPosition := Low(FValues);
  end;
  if Value > High(FValues) then
  begin
    FEof := true;
    FCurrentPosition := High(FValues);
  end;
end;

{ TaOPCCinema }

procedure TaOPCCinema.AddDataLink(DataLink: TaOPCDataLink;
  OldSource: TaCustomOPCSource = nil);
var
  HistoryGroup: TOPCDataLinkGroupHistory;
begin
  HistoryGroup := FindDataLinkGroupHistory(DataLink, DataLink.RealSource);
    // OldSource);
  if HistoryGroup = nil then
  begin
    Active := false;
    HistoryGroup := TOPCDataLinkGroupHistory.Create;
    HistoryGroup.PhysID := DataLink.PhysID;

    // для анализа состояний и записей пользователей нет возрастаний и убываний
    if (DataKind = dkValue) then
      HistoryGroup.StairsOptions := DataLink.StairsOptions
    else
      HistoryGroup.StairsOptions := [];

    HistoryGroup.UpdateOnChangeMoment := DataLink.UpdateOnChangeMoment;
    HistoryGroup.FSource := DataLink.RealSource; //OldSource;
    DataLinkGroups.Add(HistoryGroup);
  end;

  HistoryGroup.NeedUpdate := true;
  HistoryGroup.DataLinks.Add(DataLink);
  TCrackOPCLink(DataLink).FOPCSource := Self;
end;

function TaOPCCinema.FillHistory(Date1, Date2: TDatetime): boolean;
const
  sizeT = SizeOf(TDateTime);
  sizeV = SizeOf(extended);
  sizeS = SizeOf(extended);
var
  i, j: integer;
  d1, d2: TDateTime;

  Stream: TMemoryStream;
  aDataLinkGroupHistory: TOPCDataLinkGroupHistory;
  StopFill: boolean;
  V, S: extended;
  T: TDateTime;
  L: integer;
  //  tc1 : cardinal;
  mr: integer;
begin
  Result := false;
  StopFill := false;
  mr := mrYes;

  // фактические данные о периоде
  d1 := 0; // начало
  d2 := 0; // конец

  Stream := TMemoryStream.Create;
  try
    for i := 0 to FDataLinkGroups.Count - 1 do
    begin
      if Assigned(FOnFillHistory) then
        FOnFillHistory(StopFill, (i * 100) div FDataLinkGroups.Count);

      if StopFill then
        Exit;

      aDataLinkGroupHistory := TOPCDataLinkGroupHistory(FDataLinkGroups.Items[i]);

      if not Assigned(aDataLinkGroupHistory.FSource) then
      begin
        if not ShowUserMessages then
          Continue;

        OPCLog.WriteToLogFmt(
          'TaOPCCinema.FillHistory: для %s не указан источник данных.',
          [aDataLinkGroupHistory.PhysID]);

        if mr <> mrYesToAll then
          mr := MessageDlg(
            Format('Для одного из датчиков (ID = %s) не указан источник данных'
              + #13
            + 'и получение данных за выбранный период по нему невозможно.' + #13
            + 'Продолжить процесс получения данных?',
              [aDataLinkGroupHistory.PhysID]),
            mtWarning, [mbYes, mbYesToAll, mbNo], 0, mbYes);

        if mr = mrNo then
          Break
        else
          Continue;
      end;

//      TaOPCSource(aDataLinkGroupHistory.FSource).FillHistory(
//        Stream, aDataLinkGroupHistory.PhysID, Date1, Date2, [FDataKind]);

      if FDataKind = dkValue then
      begin
        TaOPCSource(aDataLinkGroupHistory.FSource).FillHistory(
          Stream, aDataLinkGroupHistory.PhysID, Date1, Date2, [dkValue, dkState]);

        // расчитаем количество элементов массива
        L := Stream.Size div (sizeT + sizeV + sizeS);
        // выделим память под массив
        SetLength(aDataLinkGroupHistory.FValues, L);

        aDataLinkGroupHistory.CurrentPosition := 0;

        j := 0;
        while Stream.Position < Stream.Size do
        begin
          Stream.Read(T, sizeT);
          Stream.Read(V, sizeV);
          Stream.Read(S, sizeS);
          // добавляем данные так, чтобы следующая дата не была меньше предыдущей
          if (j = 0) or (T > aDataLinkGroupHistory.FValues[j - 1].FDateTime) then
          begin
            aDataLinkGroupHistory.FValues[j].FDateTime := T;
            aDataLinkGroupHistory.FValues[j].FValue := V;
            aDataLinkGroupHistory.FValues[j].FState := S;

            // расчитываем фактические данные о периоде
            if (d1 = 0) or (T < d1) then
              d1 := T;
            if d2 < T then
              d2 := T;

            inc(j);
          end;
        end;
      end
      else
      begin
        TaOPCSource(aDataLinkGroupHistory.FSource).FillHistory(
          Stream, aDataLinkGroupHistory.PhysID, Date1, Date2, [FDataKind]);

        // расчитаем количество элементов массива
        L := Stream.Size div (sizeT + sizeV);
        // выделим память под массив
        SetLength(aDataLinkGroupHistory.FValues, L);

        aDataLinkGroupHistory.CurrentPosition := 0;

        j := 0;
        while Stream.Position < Stream.Size do
        begin
          Stream.Read(T, sizeT);
          Stream.Read(V, sizeV);
          // добавляем данные так, чтобы следующая дата не была меньше предыдущей
          if (j = 0) or (T > aDataLinkGroupHistory.FValues[j - 1].FDateTime) then
          begin
            aDataLinkGroupHistory.FValues[j].FDateTime := T;
            aDataLinkGroupHistory.FValues[j].FValue := V;

            // расчитываем фактические данные о периоде
            if (d1 = 0) or (T < d1) then
              d1 := T;
            if d2 < T then
              d2 := T;

            inc(j);
          end;
        end;
      end;

      // если при заполнении массива мы пропустили ряд элементов, то уменьшим размер
      if L > j then
        SetLength(aDataLinkGroupHistory.FValues, j);

      Stream.Clear;
    end;
  finally
    Stream.Free;
  end;

  FDate1 := d1;
  FDate2 := d2;

  Result := true;
end;

function TaOPCCinema.FindDataLinkGroupHistory(DataLink: TaOPCDataLink;
  aSource: TaCustomOPCSource): TOPCDataLinkGroupHistory;
var
  i: integer;
  HistoryGroup: TOPCDataLinkGroupHistory;
begin
  Result := nil;
  for i := 0 to DataLinkGroups.Count - 1 do
  begin
    HistoryGroup := TOPCDataLinkGroupHistory(DataLinkGroups[i]);
    if HistoryGroup <> nil then
    begin
      if (HistoryGroup.PhysID = DataLink.PhysID) and
        (HistoryGroup.UpdateOnChangeMoment = DataLink.UpdateOnChangeMoment) and
        (HistoryGroup.FSource = aSource) and
        not HistoryGroup.Deleted then
      begin
        Result := HistoryGroup;
        exit;
      end;
    end;
  end;
end;

function TaOPCCinema.FindGroupHistory(aID: TPhysID): TOPCDataLinkGroupHistory;
var
  i: integer;
  HistoryGroup: TOPCDataLinkGroupHistory;
begin
  Result := nil;
  for i := 0 to DataLinkGroups.Count - 1 do
  begin
    HistoryGroup := TOPCDataLinkGroupHistory(DataLinkGroups[i]);
    if HistoryGroup <> nil then
    begin
      if (HistoryGroup.PhysID = aID) and
        not HistoryGroup.Deleted then
      begin
        Result := HistoryGroup;
        Exit;
      end;
    end;
  end;
end;

{
function TaOPCCinema.FillHistory(Date1,Date2:TDatetime):boolean;
var
  i,j,IDIndex:integer;
  Stream:TMemoryStream;
  aDataLinkGroupHistory:TOPCDataLinkGroupHistory;
  StopFill : boolean;
  SensorIDs : string;
  IDList : TStringList;
  sID : string;
  sCount:integer;
  List : TList;
begin
  Result := false;
  StopFill := false;
  if (OPCSource = nil)
    or not TaOPCSource(OPCSource).Connected
    or (Date1>Date2) then exit;

  FDataLinkGroups.Sort(CompareDataLinkGroup);
  Stream := TMemoryStream.Create;
  try
    SensorIDs := ',';
    for i:=0 to FDataLinkGroups.Count - 1 do
      SensorIDs := SensorIDs +
        TOPCDataLinkGroupHistory(FDataLinkGroups.Items[i]).PhysID+',';
      //OPCSource.GetSensorsJurnal(Stream,
      //  TOPCDataLinkGroupHistory(FDataLinkGroups.Items[i]).PhysID,Date1,Date2)+';';

    SensorIDs := OPCSource.GetSensorsJurnal(Stream,SensorIDs,Date1,Date2);
    IDList := TStringList.Create;
    try
      IDList.Delimiter := ';';
      IDList.DelimitedText := SensorIDs;
      for IDIndex:=0 to IDList.Count - 1 do
      begin
        if Assigned(FOnFillHistory) then
          FOnFillHistory(StopFill,((IDIndex+1)*100) div IDList.Count);
        if StopFill then
          Exit;

        sID := IDList.Names[IDIndex];
        sCount := StrToIntDef(IDList.ValueFromIndex[IDIndex],0);
        List := FindDataLinkGroups(sID);
        if List<>nil then
        begin
          try
            aDataLinkGroupHistory := TOPCDataLinkGroupHistory(List.Items[0]);
            SetLength(aDataLinkGroupHistory.FValues,sCount);

            aDataLinkGroupHistory.CurrentPosition := Low(aDataLinkGroupHistory.FValues);
            for j:=Low(aDataLinkGroupHistory.FValues) to High(aDataLinkGroupHistory.FValues) do
            begin
              Stream.Read(aDataLinkGroupHistory.FValues[j].FDateTime,SIZEOF(TDateTime));
              Stream.Read(aDataLinkGroupHistory.FValues[j].FValue,SIZEOF(Extended));
            end;

            for j:=1 to List.Count - 1 do
              TOPCDataLinkGroupHistory(List.Items[j]).FValues := aDataLinkGroupHistory.FValues;
          finally
            FreeAndNil(List);
          end;
        end;
      end;
    finally
      IDList.Free;
    end;
  finally
    Stream.Free;
  end;
  Result := true;
end;
}

procedure TaOPCCinema.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  //  if (Operation = opRemove) and (AComponent = FOPCSource) then
  //    FOPCSource := nil;
end;

procedure TaOPCCinema.Play;
begin
  Playing := True;
end;

procedure TaOPCCinema.SetDataKind(const Value: TDataKind);
begin
  FDataKind := Value;
end;

procedure TaOPCCinema.SetDate1(const Value: TDateTime);
begin
  if FDate1 <> Value then
  begin
    Active := False;
    FDate1 := Value;
    if FDate1 > FDate2 then
      FDate2 := FDate1 + 1;
  end;
end;

procedure TaOPCCinema.SetDate2(const Value: TDateTime);
begin
  if FDate2 <> Value then
  begin
    Active := False;
    FDate2 := Value;
    if FDate2 < FDate1 then
      FDate1 := FDate2 - 1;
  end;
end;

procedure TaOPCCinema.SetShowUserMessages(const Value: Boolean);
begin
  FShowUserMessages := Value;
end;

procedure TaOPCCinema.SetSleepInterval(const Value: integer);
begin
  FTimer.Interval := Value;
end;

procedure TaOPCCinema.SetSpeed(const Value: integer);
begin
  FSpeed := Value;
  if FSpeed = 0 then
    FSpeed := 1;
end;

//procedure TaOPCCinema.SetOPCSource(const Value: TaOPCSource);
//begin
//  if FOPCSource <> Value then
//  begin
//    FOPCSource := Value;
//    if Value <> nil then Value.FreeNotification(Self);
//  end;
//end;

function TaOPCCinema.Skip(aCount: integer): boolean;
begin
  if not Active then
    Active := True;
  CurrentMoment := CurrentMoment + Step * Speed / (24 * 60 * 60) * aCount;
  Result := CurrentMoment < Date2;
end;

procedure TaOPCCinema.SetStep(const Value: integer);
begin
  FStep := Value;
end;

procedure TaOPCCinema.SetCurrentMoment(const Value: TDateTime);
begin
  if (not Active) or FInCalc {or (FCurrentMoment=Value)} then
    exit;

  FInCalc := true;
  FBof := false;
  FEof := false;
  FCurrentMoment := Value;
  try
    if Value > FDate2 then
    begin
      FEof := true;
      FCurrentMoment := Date2;
    end;
    if Value < FDate1 then
    begin
      FBof := true;
      FCurrentMoment := Date1
    end;

    CalcValuesOnMoment(FCurrentMoment);
    if Assigned(FOnChangeMoment) and (not (csLoading in ComponentState)) then
      FOnChangeMoment(Self);

    //    Application.ProcessMessages;
  finally
    FInCalc := false;
  end;
end;

constructor TaOPCCinema.Create(aOwner: TComponent);
begin
  inherited;

  FShowUserMessages := False;

  FTimer := TTimer.Create(self);
  FTimer.OnTimer := TimeTimer;
  FTimer.Enabled := false;
  FTimer.Interval := 100;
  FTimer.OnTimer := TimeTimer;

  FDataKind := dkValue;

  FStep := 5;
  FSpeed := 1;

  FDate2 := Now;
  FDate1 := Now - 1;
  FCurrentMoment := Date1;
end;

procedure TaOPCCinema.CalcValuesOnMoment(aMoment: TDateTime);
var
  i, j: integer;
  aShapshort: TValueSnapshot;
  aDataLinkGroupHistory: TOPCDataLinkGroupHistory;
  CrackDataLink: TCrackOPCLink;
begin
  if not Active then
    exit;

  for i := 0 to FDataLinkGroups.Count - 1 do
  begin
    aDataLinkGroupHistory := TOPCDataLinkGroupHistory(FDataLinkGroups.Items[i]);
    if aDataLinkGroupHistory.IsEmpty then
      Continue;

    aShapshort := aDataLinkGroupHistory.GetSnapshotOnDate(CurrentMoment);
    aDataLinkGroupHistory.Value := FloatToStr(aShapshort.FValue);
    aDataLinkGroupHistory.FloatValue := aShapshort.FValue;
    aDataLinkGroupHistory.ErrorCode := Trunc(aShapshort.FState);
    //aDataLinkGroupHistory.ErrorString := ;
//      FloatToStr(aDataLinkGroupHistory.GetValueOnDate(CurrentMoment));
    for j := 0 to aDataLinkGroupHistory.DataLinks.Count - 1 do
    begin
      CrackDataLink := TCrackOPCLink(aDataLinkGroupHistory.DataLinks.Items[j]);
      if (CrackDataLink.fValue <> aDataLinkGroupHistory.Value) or
         (CrackDataLink.ErrorCode <> aDataLinkGroupHistory.ErrorCode)then
      begin
        CrackDataLink.FMoment := aDataLinkGroupHistory.Moment;
        CrackDataLink.FOldValue := CrackDataLink.FValue;
        CrackDataLink.FValue := aDataLinkGroupHistory.Value;
        CrackDataLink.FFloatValue := aDataLinkGroupHistory.FloatValue;
        CrackDataLink.FErrorCode := aDataLinkGroupHistory.ErrorCode;
        if (CrackDataLink.FErrorCode <> 0) and
          Assigned(CrackDataLink.RealSource) and
          Assigned(CrackDataLink.RealSource.States) then
          CrackDataLink.ErrorString := CrackDataLink.RealSource.States.Items.Values[IntToStr(CrackDataLink.FErrorCode)]
        else
          CrackDataLink.ErrorString := '';

        CrackDataLink.DoChangeDataThreaded;
        CrackDataLink.ChangeData;
      end;
    end;
  end;

  DoRequest;

end;

procedure TaOPCCinema.DoActive;
begin
  if Assigned(FBeforeActivate) then
    BeforeActivate(Self);

  FActive := FillHistory(Date1, Date2);
  if fActive then
  begin
    CurrentMoment := Date1;
    inherited;
  end;
end;

procedure TaOPCCinema.DoNotActive;
begin
  FreeHistory;
  FActive := false;
  inherited;
end;

procedure TaOPCCinema.DoRequest;
var
  iGroup, iDataLink: integer;
  DataLinkGroup: TOPCDataLinkGroup;
  DataLink: TaOPCDataLink;
begin
  for iGroup := FDataLinkGroups.Count - 1 downto 0 do
  begin
    DataLinkGroup := TOPCDataLinkGroup(FDataLinkGroups.Items[iGroup]);
    if not Assigned(DataLinkGroup) then
      Continue;

    for iDataLink := DataLinkGroup.DataLinks.Count - 1 downto 0 do
    begin
      DataLink := TaOPCDataLink(DataLinkGroup.DataLinks[iDataLink]);
      if Assigned(DataLink) and Assigned(DataLink.OnRequest) then
        DataLink.OnRequest(DataLink);
    end;
  end;

  if Assigned(FOnRequest) then
    FOnRequest(Self);
end;

procedure TaOPCCinema.FreeHistory;
var
  i: integer;
  aDataLinkGroupHistory: TOPCDataLinkGroupHistory;
begin
  for i := 0 to FDataLinkGroups.Count - 1 do
  begin
    aDataLinkGroupHistory := TOPCDataLinkGroupHistory(FDataLinkGroups.Items[i]);
    SetLength(aDataLinkGroupHistory.FValues, 0);
  end;
end;

procedure TaOPCCinema.Stop;
begin
  FTimer.Enabled := false;
end;

destructor TaOPCCinema.Destroy;
begin
  Stop;
  FTimer.Free;
  inherited;
end;

function TaOPCCinema.GetNextMoment: TDateTime;
begin
  Result := GetMoment(dNext);
end;

procedure TaOPCCinema.ConnectOPCSourceDataLinks(aSource: TaOPCSource);
var
  i, j: integer;

  CrackOPCSource: TCrackOPCSource;
  tmpGroup: TOPCDataLinkGroup;
  List: TList;
begin
  if not Assigned(aSource) then
    Exit;

  Stop;
  FSaveOPCSourceActive := aSource.Active;
  aSource.Active := false;
  List := TList.Create;
  try
    CrackOPCSource := TCrackOPCSource(aSource);
    for i := 0 to CrackOPCSource.DataLinkGroups.Count - 1 do
    begin
      tmpGroup := CrackOPCSource.DataLinkGroups[i];
      if tmpGroup = nil then
        Continue;
      for j := 0 to tmpGroup.DataLinks.Count - 1 do
        List.Add(tmpGroup.DataLinks[j]);
    end;

    for i := 0 to List.Count - 1 do
      TaOPCDataLink(List.Items[i]).OPCSource := Self;

    aSource.Active := FSaveOPCSourceActive;
  finally
    List.Free;
  end;
end;

procedure TaOPCCinema.DisconnectOPCSourceDataLinks;
var
  i, j: integer;
  tmpGroup: TOPCDataLinkGroupHistory;
  LinkList: TList;
  SourceList: TList;
  //aOPCSource: TaOPCSource;
begin
  Stop;
  //  FSaveOPCSourceActive := OPCSource.Active;
  Active := false;
  LinkList := TList.Create;
  SourceList := TList.Create;
  try
    for i := 0 to DataLinkGroups.Count - 1 do
    begin
      tmpGroup := TOPCDataLinkGroupHistory(DataLinkGroups.Items[i]);
      for j := 0 to tmpGroup.DataLinks.Count - 1 do
      begin
        LinkList.Add(tmpGroup.DataLinks.Items[j]);
        SourceList.Add(tmpGroup.FSource);
      end;
    end;
    for i := 0 to LinkList.Count - 1 do
    begin
      TaOPCDataLink(LinkList.Items[i]).OPCSource := //OPCSource;
      TaOPCSource(SourceList[i]);
    end;
  finally
    SourceList.Free;
    LinkList.Free;
    //    OPCSource.Active := FSaveOPCSourceActive;
  end;
end;

function TaOPCCinema.GetPredMoment: TDateTime;
begin
  Result := GetMoment(dPred);
end;

function TaOPCCinema.GetMoment(aDirection: TDirection): TDateTime;
var
  i: integer;
  aHistory: TOPCDataLinkGroupHistory;
  tmpMoment: TDateTime;
begin
  Result := 0;
  if not Active then
    exit;

  for i := 0 to FDataLinkGroups.Count - 1 do
  begin
    aHistory := TOPCDataLinkGroupHistory(FDataLinkGroups.Items[i]);
    case aDirection of
      dNext:
        if not aHistory.GetNextMoment(tmpMoment) then
          Continue;
      dPred:
        if not aHistory.GetPredMoment(tmpMoment) then
          Continue;
    end;

    if Result = 0 then
      Result := tmpMoment
    else
      case aDirection of
        dNext: if tmpMoment < Result then
            Result := tmpMoment;
        dPred: if tmpMoment > Result then
            Result := tmpMoment;
      end;
  end;
end;

procedure TaOPCCinema.TimeTimer(Sender: TObject);
begin
  FInTimer := true;
  try
    if not Skip(1) then
      Playing := false;
  finally
    FInTimer := false;
  end;
end;

function TaOPCCinema.GetSleepInterval: integer;
begin
  Result := FTimer.Interval;
end;

procedure TaOPCCinema.HidePult;
begin
  if Assigned(CinemaControlForm) then
    CinemaControlForm.Close;
end;

function TaOPCCinema.GetPlaying: boolean;
begin
  Result := FTimer.Enabled;
end;

procedure TaOPCCinema.SetPlaing(const Value: boolean);
begin
  FTimer.Enabled := Value;
end;

procedure TaOPCCinema.ShowPult(aFormToPrint: TForm = nil; Modal: Boolean = True);
begin
  { TODO : Реализовать }
  {.$IFDEF VCL}
  if not Assigned(CinemaControlForm) then
    CinemaControlForm := TCinemaControlForm.Create(aFormToPrint)
  else
    CinemaControlForm.Hide;

  with CinemaControlForm do
  begin
    try
      aOPCCinemaControl1.OPCCinema := Self;
      aOPCCinemaControl1.FormToPrint := aFormToPrint;
      //      if OPCSource<>nil then
      //      begin
      //        //OPCSource.Active := false;
      //        ConnectOPCSourceDataLinks;
      //      end;

      if Modal then
        ShowModal
      else
        Show;
    finally
      //Free;
    end;
  end;
  {.$ENDIF}
end;

procedure TaOPCCinema.LoadHistory(aFileName, aVersion: string);
begin

end;

procedure TaOPCCinema.SaveHistory(aFileName, aVersion: string);
var
  aFileStream: TFileStream;
  VerLength: integer;
  i, j: integer;
  DLG: TOPCDataLinkGroupHistory;
  //dt:TDateTime;
  //Val:Double;
  PhysID: integer;
  aValueSnapshot: TValueSnapshot;
begin
  aFileStream := TFileStream.Create(aFileName, fmOpenWrite);
  try
    VerLength := length(aVersion);
    aFileStream.Write(VerLength, sizeof(VerLength)); //размер строки версии
    aFileStream.Write(PChar(aVersion)^, VerLength); //строка версии
    for i := 0 to FDataLinkGroups.Count - 1 do
    begin
      DLG := TOPCDataLinkGroupHistory(FDataLinkGroups[i]);
      PhysID := StrToIntDef(DLG.PhysID, 0);
      aFileStream.Write(PhysID, sizeof(PhysID)); //адрес (id) датчика
      for j := low(dlg.FValues) to High(dlg.FValues) do
      begin
        aValueSnapshot.FDateTime := DLG.FValues[j].FDateTime;
        aValueSnapshot.FValue := DLG.FValues[j].FValue;
        aValueSnapshot.FState := DLG.FValues[j].FState;
        aFileStream.Write(aValueSnapshot, SizeOf(TValueSnapshot));
      end;
    end;
  finally
    FreeAndNil(aFileStream);
  end;
end;

{ TSourceItem }

constructor TSourceItem.Create;
begin
  GroupLinks := TList.Create;
end;

destructor TSourceItem.Destroy;
begin
  GroupLinks.Free;
  inherited;
end;

initialization
  CinemaControlForm := nil;

end.

