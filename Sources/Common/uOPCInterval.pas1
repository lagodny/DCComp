unit uOPCInterval;

interface

uses
  System.Classes, System.SysUtils,
  System.IniFiles;

type
  TOPCIntervalKind = (ikInterval, ikShift);
  TOPCIntervalTimeShiftUnit = (
    tsuHour = 0,
    tsuDay = 1
  );

  TShiftKind = (
    skNone = 0,
    skToday = 1,
    skYesterday = 2,
    skWeek = 3,
    skLastWeek = 4,
    skMonth = 5,
    skLastMonth = 6,
    skTomorrow = 7,
    skNextWeek = 8,
    skNext12Hours = 9,
    skNextDay = 10
  );

  EIntervalException = class(Exception);

  TOPCInterval = class(TPersistent)
  private
    FLockCount: integer;
    FWasChanged: Boolean;
    FKind: TOPCIntervalKind;
    FTimeShift: TDateTime;
    FDate2: TDatetime;
    FDate1: TDatetime;
    FShiftKind: TShiftKind;
    FOnChanged: TNotifyEvent;
    FTimeShiftUnit: TOPCIntervalTimeShiftUnit;
    function GetDate1: TDatetime;
    function GetDate2: TDatetime;
    procedure SetDate1(const Value: TDatetime);
    procedure SetDate2(const Value: TDatetime);
    procedure SetKind(const Value: TOPCIntervalKind);
    procedure SetTimeShift(const Value: TDateTime);
    procedure SetShiftKind(const Value: TShiftKind);

    function ruDayOfWeek(const DateTime: TDateTime): Word;
    procedure SetTimeShiftUnit(const Value: TOPCIntervalTimeShiftUnit);

    class function GetLastInterval: TOPCInterval; static;
    class procedure SetLastInterval(const Value: TOPCInterval); static;

  protected
    procedure AssignTo(Dest: TPersistent); override;
    procedure DoChanged;
  public
    constructor Create;

    class function ShiftKindToStr(aShiftKind: TShiftKind): string;
    class function ShiftUnitToStr(aShiftUnit: TOPCIntervalTimeShiftUnit): string;

    class property LastInterval: TOPCInterval read GetLastInterval write SetLastInterval;

    procedure SetInterval(aDate1, aDate2: TDateTime);

    procedure Save(aReg: TCustomIniFile; aSectionName: string);
    procedure Load(aReg: TCustomIniFile; aSectionName: string);

    //function ShowIntervalForm: boolean;
    function AsText: string;
    function AsTextForPrint: string;

    procedure Lock;
    procedure Unlock;

    property Kind: TOPCIntervalKind read FKind write SetKind;
    property ShiftKind: TShiftKind read FShiftKind write SetShiftKind;

    property Date1: TDatetime read GetDate1 write SetDate1;
    property Date2: TDatetime read GetDate2 write SetDate2;
    property TimeShift: TDateTime read FTimeShift write SetTimeShift;
    property TimeShiftUnit: TOPCIntervalTimeShiftUnit read FTimeShiftUnit write
      SetTimeShiftUnit;

    property OnChanged: TNotifyEvent read FOnChanged write FOnChanged;
  end;

implementation

uses
  uDCStrResource;
//  uDCLang,
//  uDCLocalizer;

resourcestring
  StrDate1MoreDate2Error = 'Date1 не может быть меньше Date2';
  StrTimeShiftMastBeMoreZeroError = 'TimeShift должно быть >= 0';

var
  FLastInterval: TOPCInterval;

{ TOPCInterval }

procedure TOPCInterval.AssignTo(Dest: TPersistent);
var
  DestOPCInterval: TOPCInterval;
begin
  if Dest = Self then
    Exit;
    
  if Dest is TOPCInterval then
  begin
    DestOPCInterval := TOPCInterval(Dest);

    DestOPCInterval.Lock;
    try
      DestOPCInterval.Kind := Kind;
      DestOPCInterval.TimeShiftUnit := TimeShiftUnit;
      if Kind = ikInterval then
      begin
        DestOPCInterval.SetInterval(Date1, Date2);
        DestOPCInterval.ShiftKind := ShiftKind;
      end
      else
        DestOPCInterval.TimeShift := TimeShift;
    finally
      DestOPCInterval.Unlock;
    end;
  end
  else
    inherited;
end;

constructor TOPCInterval.Create;
begin
  FTimeShift := 0.5; //12 часов
  FTimeShiftUnit := tsuHour;
  FKind := ikInterval;
  FShiftKind := skToday;
  FDate2 := Now;
  FDate1 := FDate2 - TimeShift;
end;

procedure TOPCInterval.DoChanged;
begin
  FWasChanged := true;
  if (FLockCount = 0) and Assigned(FOnChanged) then
  begin
    FWasChanged := false;
    FOnChanged(Self);
  end;
end;

function TOPCInterval.GetDate1: TDatetime;
var
  d, m, y: word;
  m1, y1: Word;
begin
  if FKind = ikShift then
    Result := Now - FTimeShift
  else
  begin
    case ShiftKind of
      skNone:
        Result := FDate1;
      skToday:
        Result := Trunc(Now);
      skYesterday:
        Result := Trunc(Now) - 1;
      skWeek:
        Result := Trunc(Now - ruDayOfWeek(Now));
      skLastWeek:
        Result := (Trunc(Now) - ruDayOfWeek(Now)) - 7;
      skMonth:
        begin
          DecodeDate(Now, y, m, d);
          Result := EncodeDate(y, m, 1);
        end;
      skLastMonth:
        begin
          DecodeDate(Now, y, m, d);

          if m = 1 then
          begin
            y1 := y - 1;
            m1 := 12;
          end
          else
          begin
            y1 := y;
            m1 := m - 1;
          end;

          Result := EncodeDate(y1, m1, 1);
        end;
      skTomorrow:
        Result := Trunc(Now) + 1;
      skNextWeek:
        Result := (Trunc(Now) - ruDayOfWeek(Now)) + 7;
      skNext12Hours:
        Result := Now;
      skNextDay:
        Result := Now;

    end;
  end;
end;

function TOPCInterval.GetDate2: TDatetime;
var
  d, m, y: word;
begin
  if FKind = ikShift then
    Result := Now
  else
  begin
    case ShiftKind of
      skNone:
        Result := FDate2;
      skToday:
        Result := Trunc(Now) + 1;
      skYesterday:
        Result := Trunc(Now);
      skWeek:
        Result := Trunc(Now) + 1;
      skLastWeek:
        Result := Trunc(Now) - ruDayOfWeek(Now);
      skMonth:
        Result := Trunc(Now) + 1;
      skLastMonth:
        begin
          DecodeDate(Now, y, m, d);
          Result := EncodeDate(y, m, 1);
        end;
      skTomorrow:
        Result := Trunc(Now) + 2;
      skNextWeek:
        Result := (Trunc(Now) - ruDayOfWeek(Now)) + 7 + 7;
      skNext12Hours:
        Result := Now + 12/HoursPerDay;
      skNextDay:
        Result := Now + 1;

    end;
  end;
end;

class function TOPCInterval.GetLastInterval: TOPCInterval;
begin
  if not Assigned(FLastInterval) then
    FLastInterval := TOPCInterval.Create;

  Result := FLastInterval
end;

function TOPCInterval.AsText: string;

begin
  if Kind = ikInterval then
  begin
    case ShiftKind of
      skNone:
        Result := AsTextForPrint;
      else
        Result := ShiftKindToStr(ShiftKind);

//      skToday:
//        Result := TDCLocalizer.GetStringRes(idxInterval_skToday); //'Сегодня';
//      skYesterday:
//        Result := TDCLocalizer.GetStringRes(idxInterval_skYesterday); //'Вчера';
//      skWeek:
//        Result := TDCLocalizer.GetStringRes(idxInterval_skWeek); //'С начала недели';
//      skLastWeek:
//        Result := TDCLocalizer.GetStringRes(idxInterval_skLastWeek); //'Прошлая неделя';
//      skMonth:
//        Result := TDCLocalizer.GetStringRes(idxInterval_skMonth); //'С начала месяца';
//      skLastMonth:
//        Result := TDCLocalizer.GetStringRes(idxInterval_skLastMonth); //'Прошлый месяц';
//      skTomorrow:
//        Result := TDCLocalizer.GetStringRes(idxInterval_skTomorrow); //'Завтра';
//      skNextWeek:
//        Result := TDCLocalizer.GetStringRes(idxInterval_skNextWeek); //'Следующая неделя';
//      skNext12Hours:
//        Result := TDCLocalizer.GetStringRes(idxInterval_skNext12Hours); //'Следующие 12 часов';
//      skNextDay:
//        Result := TDCLocalizer.GetStringRes(idxInterval_skNextDay); //'Седующий день';
    end;
  end
  else
  begin
    if TimeShiftUnit = tsuHour then
      Result := Format(dcResS_N_LastHoursFmt, //'последние %s ч.',
        [FormatFloat('0.##', TimeShift * 24)])
    else
      Result := Format(dcResS_N_LastDaysFmt, //'последние %s д.',
        [FormatFloat('0.##', TimeShift)])
  end;
end;

function TOPCInterval.AsTextForPrint: string;
begin
  if (Frac(Date1) = 0) and (Frac(Date2) = 0) then
  begin
    if Date1 + 1 = Date2 then
      Result := FormatDateTime('dd.mm.yyyy', Date1)
    else
      Result :=
        FormatDateTime('dd.mm.yyyy', Date1) + ' - ' +
        FormatDateTime('dd.mm.yyyy', Date2 - 1)
  end
  else
  begin
    if (Frac(Date1) = 0) then
      Result := FormatDateTime('dd.mm.yyyy', Date1)
    else
      Result := FormatDateTime('dd.mm.yyyy hh:mm.ss', Date1);

    if (Frac(Date2) = 0) then
      Result := Result + ' - ' + FormatDateTime('dd.mm.yyyy', Date2 - 1)
    else
      Result := Result + ' - ' + FormatDateTime('dd.mm.yyyy hh:mm.ss', Date2);
  end;

end;

procedure TOPCInterval.Load(aReg: TCustomIniFile; aSectionName: string);
var
  aDate1, aDate2: TDateTime;
begin
  Lock;
  try
    aDate1 := aReg.ReadDateTime(aSectionName, 'Date1', Date1);
    aDate2 := aReg.ReadDateTime(aSectionName, 'Date2', Date2);

    SetInterval(aDate1, aDate2);

    FKind := TOPCIntervalKind(aReg.ReadInteger(aSectionName, 'Kind', Ord(FKind)));
    ShiftKind := TShiftKind(aReg.ReadInteger(aSectionName, 'ShiftKind', Ord(FShiftKInd)));

    FTimeShift := aReg.ReadDateTime(aSectionName, 'TimeShift', FTimeShift);
    FTimeShiftUnit := TOPCIntervalTimeShiftUnit(
      aReg.ReadInteger(aSectionName, 'TimeShiftUnit', Ord(FTimeShiftUnit)));
  finally
    Unlock;
  end;
end;

procedure TOPCInterval.Lock;
begin
  Inc(FLockCount);
end;

function TOPCInterval.ruDayOfWeek(const DateTime: TDateTime): Word;
begin
  // день недели по нашему : пн-0, вт-1 ... вс-6
  Result := DayOfWeek(DateTime);
  if Result = 1 then
    Result := 6
  else
    Result := Result - 2;
end;

procedure TOPCInterval.Save(aReg: TCustomIniFile; aSectionName: string);
begin
  aReg.WriteDateTime(aSectionName, 'Date1', Date1);
  aReg.WriteDateTime(aSectionName, 'Date2', Date2);
  aReg.WriteInteger(aSectionName, 'Kind', Ord(Kind));
  aReg.WriteInteger(aSectionName, 'ShiftKind', Ord(ShiftKind));
  aReg.WriteDateTime(aSectionName, 'TimeShift', TimeShift);
  aReg.WriteInteger(aSectionName, 'TimeShiftUnit', Ord(TimeShiftUnit));
end;

procedure TOPCInterval.SetDate1(const Value: TDatetime);
begin
  if FDate2 < Value then
    raise EIntervalException.Create(StrDate1MoreDate2Error);

  FDate1 := Value;
  FTimeShift := FDate2 - FDate1;
  FShiftKind := skNone;

  DoChanged;
end;

procedure TOPCInterval.SetDate2(const Value: TDatetime);
begin
  if Value < FDate1 then
    raise EIntervalException.Create(StrDate1MoreDate2Error);

  FDate2 := Value;
  FTimeShift := FDate2 - FDate1;
  FShiftKind := skNone;

  DoChanged;
end;

procedure TOPCInterval.SetInterval(aDate1, aDate2: TDateTime);
begin
  if aDate1 < aDate2 then
  begin
    FDate1 := aDate1;
    FDate2 := aDate2;
  end
  else if aDate1 = aDate2 then
  begin
    FDate1 := aDate1;
    FDate2 := aDate1 + 1;
  end
  else
  begin
    FDate1 := aDate2;
    FDate2 := aDate1;
  end;

  FTimeShift := FDate2 - FDate1;
  FShiftKind := skNone;

  DoChanged;
end;

procedure TOPCInterval.SetKind(const Value: TOPCIntervalKind);
begin
  if FKind <> Value then
  begin
    FKind := Value;
    if Kind = ikShift then
      ShiftKind := skNone;

    DoChanged;
  end;
end;

class procedure TOPCInterval.SetLastInterval(const Value: TOPCInterval);
begin
  if not Assigned(FLastInterval) then
    FLastInterval := TOPCInterval.Create;

  FLastInterval.Assign(Value);
end;

procedure TOPCInterval.SetShiftKind(const Value: TShiftKind);
//var
//  dow: integer;
//  d,m,y: word;
//  m1,y1: word;
begin
  if FShiftKind <> Value then
  begin
    FShiftKind := Value;
    DoChanged;
  end;

  //  if FShiftKind = skNone then
  //    exit;
  //
  //  // день недели по нашему : пн-0, вт-1 ... вс-6
  //  dow := DayOfWeek(Now);
  //  if dow = 1 then
  //    dow := 6
  //  else
  //    dow := dow - 2;
  //
  //  case FShiftKind of
  //    skToday: // сегодня
  //      SetInterval(trunc(Now),trunc(Now)+1);
  //    skYesterday: // вчера
  //      SetInterval(trunc(Now-1),trunc(Now));
  //    skWeek: // с начала недели
  //      SetInterval(Trunc(Now - dow), Trunc(Now)+1 );
  //    skLastWeek: // предыдущая неделя
  //      SetInterval(Trunc(Now - dow)-7, Trunc(Now - dow));
  //    skMonth: // с начала месяца
  //    begin
  //      DecodeDate(Now, y, m,d);
  //      SetInterval(EncodeDate(y,m,1), Trunc(Now)+1);
  //    end;
  //    skLastMonth: // прошлый месяц
  //    begin
  //      DecodeDate(Now, y, m,d);
  //
  //      if m = 1 then
  //      begin
  //        y1 := y - 1;
  //        m1 := 12;
  //      end
  //      else
  //      begin
  //        y1 := y;
  //        m1 := m - 1;
  //      end;
  //
  //      SetInterval(EncodeDate(y1,m1,1), EncodeDate(y,m,1));
  //    end;
  //  end;
end;

procedure TOPCInterval.SetTimeShift(const Value: TDateTime);
begin
  if Value < 0 then
    raise EIntervalException.Create(StrTimeShiftMastBeMoreZeroError);

  FTimeShift := Value;
  FDate2 := Now;
  FDate1 := FDate2 - TimeShift;
  DoChanged;
end;

procedure TOPCInterval.SetTimeShiftUnit(const Value: TOPCIntervalTimeShiftUnit);
begin
  FTimeShiftUnit := Value;
end;

class function TOPCInterval.ShiftKindToStr(aShiftKind: TShiftKind): string;
begin
  case aShiftKind of
    skNone:
      Result := '...';
    skToday:
      Result := 'Сегодня';//TDCLocalizer.GetStringRes(idxInterval_skToday);
    skYesterday:
      Result := 'Вчера';//TDCLocalizer.GetStringRes(idxInterval_skYesterday); //
    skWeek:
      Result := 'С начала недели';//TDCLocalizer.GetStringRes(idxInterval_skWeek); //
    skLastWeek:
      Result := 'Прошлая неделя';//TDCLocalizer.GetStringRes(idxInterval_skLastWeek); //
    skMonth:
      Result := 'С начала месяца';//TDCLocalizer.GetStringRes(idxInterval_skMonth); //
    skLastMonth:
      Result := 'Прошлый месяц';//TDCLocalizer.GetStringRes(idxInterval_skLastMonth); //
    skTomorrow:
      Result := 'Завтра';//TDCLocalizer.GetStringRes(idxInterval_skTomorrow); //
    skNextWeek:
      Result := 'Следующая неделя';//TDCLocalizer.GetStringRes(idxInterval_skNextWeek); //
    skNext12Hours:
      Result := 'Следующие 12 часов';//TDCLocalizer.GetStringRes(idxInterval_skNext12Hours); //
    skNextDay:
      Result := 'Седующий день';//TDCLocalizer.GetStringRes(idxInterval_skNextDay); //
  end;
end;

class function TOPCInterval.ShiftUnitToStr(aShiftUnit: TOPCIntervalTimeShiftUnit): string;
begin
  case aShiftUnit of
    tsuHour:
      Result := 'часов';//TDCLocalizer.GetStringRes(idxInterval_tsuHour);
    tsuDay:
      Result := 'дней';//TDCLocalizer.GetStringRes(idxInterval_tsuDay);
  end;
end;

//function TOPCInterval.ShowIntervalForm: boolean;
//begin
//  with TChoiceIntervalExt.Create(nil) do
//  begin
//    try
//      SetInterval(Self);
//      if ShowModal = mrOk then
//      begin
//        GetInterval(Self);
//        Result := true;
//      end
//      else
//        Result := false;
//    finally
//      Free;
//    end;
//  end;
//
//end;

procedure TOPCInterval.Unlock;
begin
  Dec(FLockCount);
  if FLockCount <= 0 then
  begin
    FLockCount := 0;
    if FWasChanged then
      DoChanged;
  end;
end;

initialization
  FLastInterval := nil;

finalization
  FreeAndNil(FLastInterval);


end.

