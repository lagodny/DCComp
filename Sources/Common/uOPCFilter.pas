unit uOPCFilter;

interface

uses
  Classes, Contnrs,
  SysUtils,
  uExprEval,
  uDCObjects,
  aCustomOPCSource, aOPCCinema;

type
  EaOPCFilterException = class(Exception)

  end;

  // вычислитель выполняет расчет фильтра на каждый момент времени
  TaOPCFilterCalc = class
  private
    FEval: TExpressionCompiler;
    FCinema: TaOPCCinema;
    FOnCalcValueExpr: TCompiledExpression;
  public
    constructor Create;
    destructor Destroy; override;

    function Calc: Double;
    procedure Recompile(aExpression: string);

    property Eval: TExpressionCompiler read FEval;
    property Cinema: TaOPCCinema read FCinema;
  end;

  // Фильтр хранит информацию о датчиках и выражение для вычисления фильтра
  TaOPCFilter = class(TPersistent)
  private
    FEvaluator: TaOPCFilterCalc;

    FExpression: string;

    FDataLink: TaOPCDataLink;
    FDataLinks: TObjectList;

    FActive: Boolean;
    FAutoActive: Boolean;
    procedure SetExpression(const Value: string);
    procedure SetActive(const Value: Boolean);
    function GetEvaluator: TaOPCFilterCalc;
    procedure SetAutoActive(const Value: Boolean);

    function FindDataLinkByID(aID: TFloat64): TaOPCDataLink;

    // функция доступа к значению датчика (ступеньки)
    //function S(aID: TFloat64): TFloat64;
    function S(aID: TFloat): TFloat;
    // функция доступа к значению датчика (линия)
    //function L(aID: TFloat64): TFloat64;
    function L(aID: TFloat): TFloat;

    function GetActive: Boolean;
    function GetAutoActive: Boolean;
    function GetExpression: string;
    procedure SetDataLink(const Value: TaOPCDataLink);
  protected
    procedure AssignTo(Dest: TPersistent); override;
  public
    constructor Create;
    destructor Destroy; override;

    function AddDataLink(aID: string; aStairs: TDCStairsOptionsSet; aSource: TaCustomOPCSource): TaOPCDataLink;

    // фильтр включен: доступно свойство Expression (выключение Active освободит объект Expression)
    property Active: Boolean read GetActive write SetActive;

    // датчик, для которого будет применен фильтр
    property DataLink: TaOPCDataLink read FDataLink write SetDataLink;

    // датчики, которые учавтвуют в расчете фильтра
    property DataLinks: TObjectList read FDataLinks;

    property Evaluator: TaOPCFilterCalc read GetEvaluator;

  published
    // фильтр будет автоматически включаться при попытке доступа к Expression
    property AutoActive: Boolean read GetAutoActive write SetAutoActive default True;

    property Expression: string read GetExpression write SetExpression;
  end;

implementation

{
function S(aID: Double): Double;
var
  aHistoryGroup: TOPCDataLinkGroupHistory;
begin
  Result := 0;
  if not Assigned(GlobalCinema) then
    Exit;

  // 1. найти DataLink по ID
  aHistoryGroup := GlobalCinema.FindGroupHistory(IntToStr(Round(aID)));
  if not Assigned(aHistoryGroup) then
    Exit;

  // 2. вернуть значение на текущий момент
  Result := aHistoryGroup.GetValueOnDate(GlobalCinema.CurrentMoment);
end;
}

{ TaOPCFilter }

function TaOPCFilter.AddDataLink(aID: string; aStairs: TDCStairsOptionsSet; aSource: TaCustomOPCSource): TaOPCDataLink;
begin
  Result := TaOPCDataLink.Create(nil);
  FDataLinks.Add(Result);
  Result.PhysID := aID;
  Result.StairsOptions := aStairs;
  Result.OPCSource := aSource;
end;

procedure TaOPCFilter.AssignTo(Dest: TPersistent);
var
  aDestFilter: TaOPCFilter;
  aDataLink: TaOPCDataLink;
  i: Integer;
begin
  inherited AssignTo(Dest);

  if Dest is TaOPCFilter then
  begin
    aDestFilter := TaOPCFilter(Dest);
    aDestFilter.DataLink := DataLink;
    aDestFilter.Expression := Expression;
    
    aDestFilter.DataLinks.Clear;
    for i := 0 to DataLinks.Count - 1 do
    begin
      aDataLink := TaOPCDataLink(DataLinks[i]);
      aDestFilter.AddDataLink(aDataLink.PhysID, aDataLink.StairsOptions, aDataLink.RealSource);
    end;

    aDestFilter.AutoActive := AutoActive;
    aDestFilter.Active := Active;
  end;
end;

constructor TaOPCFilter.Create;
begin
  FDataLink := TaOPCDataLink.Create(nil);
  FDataLinks := TObjectList.Create;

  FAutoActive := True;
end;

destructor TaOPCFilter.Destroy;
begin
  Active := False;

  FreeAndNil(FDataLinks);
  FreeAndNil(FDataLink);

  inherited;
end;

function TaOPCFilter.FindDataLinkByID(aID: TFloat64): TaOPCDataLink;
var
  i: Integer;
  aDataLink: TaOPCDataLink;
begin
  Result := nil;

  if DataLink.ID = Trunc(aID) then
  begin
    Result := DataLink
  end
  else
  begin
    for i := FDataLinks.Count - 1 downto 0 do
    begin
      aDataLink := TaOPCDataLink(FDataLinks[i]);
      if aDataLink.ID = Trunc(aID) then
      begin
        Result := aDataLink;
        Exit;
      end;
    end;
  end;
end;

function TaOPCFilter.GetActive: Boolean;
begin
  Result := FActive;
end;

function TaOPCFilter.GetAutoActive: Boolean;
begin
  Result := FAutoActive;
end;

function TaOPCFilter.GetEvaluator: TaOPCFilterCalc;
begin
  //Result := nil;
  
  if Active then
  begin
    Result := FEvaluator
  end

  else if AutoActive then
  begin
    Active := True;
    Result := FEvaluator;
  end
  
  else
    raise EaOPCFilterException.Create('Фильтр неактивен (Active = False), вычислитель недоступен.');
end;

function TaOPCFilter.GetExpression: string;
begin
  Result := FExpression;
end;

//function TaOPCFilter.L(aID: TFloat64): TFloat64;
function TaOPCFilter.L(aID: TFloat): TFloat;
var
  aDataLink: TaOPCDataLink;
begin
  Result := 0;

  aDataLink := FindDataLinkByID(aID);
  if Assigned(aDataLink) then
    Result := StrToFloatDef(aDataLink.Value, 0)
  else
    AddDataLink(IntToStr(Trunc(aID)), [soIncrease, soDecrease], DataLink.OPCSource);
end;

//function TaOPCFilter.S(aID: TFloat64): TFloat64;
function TaOPCFilter.S(aID: TFloat): TFloat;
var
  aDataLink: TaOPCDataLink;
begin
  Result := 0;

  aDataLink := FindDataLinkByID(aID);
  if Assigned(aDataLink) then
    Result := StrToFloatDef(aDataLink.Value, 0)
  else
    AddDataLink(IntToStr(Trunc(aID)), [], DataLink.OPCSource);
end;

procedure TaOPCFilter.SetActive(const Value: Boolean);
var
  i: Integer;
  aDataLink: TaOPCDataLink;
begin
  if FActive <> Value then
  begin
    FActive := Value;
    
    FDataLinks.Clear;

    if FActive then
    begin
      FEvaluator := TaOPCFilterCalc.Create;
      FEvaluator.Eval.AddFuncOfObject('S', S);
      FEvaluator.Eval.AddFuncOfObject('L', L);

      FEvaluator.Recompile(FExpression);

      DataLink.OPCSource := FEvaluator.Cinema;
      for i := 0 to FDataLinks.Count - 1 do
      begin
        aDataLink := TaOPCDataLink(FDataLinks[i]);
        aDataLink.OPCSource := FEvaluator.Cinema;
      end;
    end
    else
    begin
      DataLinks.Clear;
      DataLink.OPCSource := DataLink.RealSource;

      FreeAndNil(FEvaluator);
    end;
  end;
end;

procedure TaOPCFilter.SetAutoActive(const Value: Boolean);
begin
  FAutoActive := Value;
end;

procedure TaOPCFilter.SetDataLink(const Value: TaOPCDataLink);
begin
  FDataLink.Assign(Value);
end;

procedure TaOPCFilter.SetExpression(const Value: string);
begin
  if FExpression <> Value then
  begin
    FExpression := Value;
    
    if Active then
    begin
      Active := False;
      Active := True;
      //Evaluator.Recompile(FExpression);
    end;
  end;
end;

{ TaOPCFilterCalc }

function TaOPCFilterCalc.Calc: Double;
begin
  Result := FOnCalcValueExpr;
end;

constructor TaOPCFilterCalc.Create;
begin
  FEval := TExpressionCompiler.Create;
  FCinema := TaOPCCinema.Create(nil);
end;

destructor TaOPCFilterCalc.Destroy;
begin
  FreeAndNil(FCinema);
  FreeAndNil(FEval);

  inherited;
end;

procedure TaOPCFilterCalc.Recompile(aExpression: string);
begin
  FOnCalcValueExpr := FEval.Compile(aExpression);
  // выполнем тестовый расчет, чтобы заполнить DataLinks
  Calc;
end;

end.
