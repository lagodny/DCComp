unit aOPCDataObject;

interface
uses
  SysUtils, Windows, Messages, Classes,
  Graphics, Controls, Forms, Dialogs, aCustomOPCSource,
  uDCObjects;


type
  TOPCDirection = (vdLeft, vdRight, vdUp, vdDown);
  TOPCPosition = (vpHorizontal, vpVertical, vpLeftDiagonal, vpRightDiagonal);


  TaCustomOPCDataObject = class;

  TaOPCGraphicDataLink = class (TaCustomDataLink)
  private
    fOPCSource: TaCustomOPCDataObject;
    procedure SetOPCSource(const Value: TaCustomOPCDataObject);
  protected
  public
    property OPCSource : TaCustomOPCDataObject read fOPCSource write SetOPCSource;

    constructor Create(aControl : TObject);override;
    destructor Destroy; override;
  end;

  TaDCRangesCheckResult = (
    rcrOk = 0
    , rcrWarnLowLevel = 1
    , rcrWarnHighLevel = 2
    , rcrAlarmLowLevel = 3
    , rcrAlarmHighLevel = 4
    , rcrConvertError = 5
  );

  TaDCRanges = class(TPersistent)
  private
    FWarnLowLevel: Double;
    FAlarmHighLevel: Double;
    FWarnHighLevel: Double;
    FAlarmLowLevel: Double;
    FEnable: Boolean;
    procedure SetAlarmHighLevel(const Value: Double);
    procedure SetAlarmLowLevel(const Value: Double);
    procedure SetWarnHighLevel(const Value: Double);
    procedure SetWarnLowLevel(const Value: Double);
    procedure SetEnable(const Value: Boolean);
  protected
    procedure AssignTo(Dest: TPersistent); override;
  published
    function Check(aValue: string): TaDCRangesCheckResult;

    property WarnLowLevel: Double read FWarnLowLevel write SetWarnLowLevel;
    property WarnHighLevel: Double read FWarnHighLevel write SetWarnHighLevel;
    property AlarmLowLevel: Double read FAlarmLowLevel write SetAlarmLowLevel;
    property AlarmHighLevel: Double read FAlarmHighLevel write SetAlarmHighLevel;

    property Enable: Boolean read FEnable write SetEnable default False;
  end;


  TaCustomOPCDataObject = class {(TDrawObject)}(TGraphicControl)
  private
    FDragImages: TDragImageList;

    fDataLink: TaOPCDataLink;
    fGraphicDataLink: TaOPCGraphicDataLink;
    //FStairsOptions : TOPCStairsOptionsSet;

    FOnChange: TNotifyEvent;
    FInteractive: boolean;
    FMouseInSide: boolean;
    FOnMouseEnter: TNotifyEvent;
    FOnMouseLeave: TNotifyEvent;
    FHints: TStrings;
    FErrorHint: string;
    FParams: TStrings;
    FValueHint: string;
    FRanges: TaDCRanges;
    procedure SetInteractive(const Value: boolean);

    procedure SetGraphicOPCSource(const Value: TaCustomOPCDataObject);

    function GetOPCSource: TaCustomOPCSource;
    function GetGraphicOPCSource: TaCustomOPCDataObject;

    function GetErrorCode: integer;
    function GetErrorString: string;
    function GetPhysID: TPhysID;

    function GetDataLink: TaCustomDataLink;

    procedure AddDataLink(DataLink: TaOPCGraphicDataLink);
    procedure RemoveDataLink(DataLink: TaOPCGraphicDataLink);
    function GetStairsOptions: TDCStairsOptionsSet;
    procedure SetStairsOptions(const Value: TDCStairsOptionsSet);
    function GetMoment: TDateTime;
    function GetUpdateOnChangeMoment: boolean;
    procedure SetUpdateOnChangeMoment(const Value: boolean);
    procedure SetHints(const Value: TStrings);
    procedure SetParams(const Value: TStrings);
    procedure SetErrorHint(const Value: string);

    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;

    procedure SetValueHint(const Value: string);
    procedure SetErrorCode(const Value: integer);
    procedure SetErrorString(const Value: string);
    procedure SetRanges(const Value: TaDCRanges);


  protected
    Scale : extended;
    FDataLinks: TList;

    function CalcHint: string;
    function StoredValue: boolean; virtual;

    procedure UpdateOriginalPosition; virtual;

    procedure DoMouseEnter;virtual;
    procedure DoMouseLeave;virtual;

    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;

    function GetDragImages: TDragImageList; override;

    procedure SetPhysID(const Value: TPhysID);virtual;
    procedure SetOPCSource(const Value: TaCustomOPCSource);virtual;

    function GetValue:string;virtual;
    procedure SetValue(const Value: string);virtual;

    procedure Loaded; override;
    procedure ChangeScale(M, D: Integer); override;

    procedure UpdateDataLinks; virtual;
    procedure ChangeData(Sender:TObject);virtual;
    procedure RepaintRequest(Sender:TObject);virtual;

    property Interactive:boolean read FInteractive write SetInteractive default false;

    property OnMouseEnter: TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave: TNotifyEvent read FOnMouseLeave write FOnMouseLeave;

  public
    OriginalLeft,OriginalTop,OriginalWidth,OriginalHeight:integer;
    OriginalFontSize:Integer;

    FMouseDownX, FMouseDownY: Integer;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;

    function IsActive:boolean;virtual;

    property DataLink : TaCustomDataLink read GetDataLink;

    constructor Create(aOwner : TComponent);override;
    destructor Destroy; override;

    property MouseInside: boolean read FMouseInSide;
    property Moment : TDateTime read GetMoment;
  published
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    // публикуем события родителя
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
    property OnStartDock;
    property OnStartDrag;

    property PopupMenu;
    property Visible;
    property ShowHint;
    property Enabled;
    property Anchors;

    property OPCSource : TaCustomOPCSource read GetOPCSource write SetOPCSource;
    property GraphicOPCSource : TaCustomOPCDataObject read GetGraphicOPCSource write SetGraphicOPCSource;

    property UpdateOnChangeMoment : boolean
      read GetUpdateOnChangeMoment write SetUpdateOnChangeMoment default False;

    property StairsOptions : TDCStairsOptionsSet
      read GetStairsOptions write SetStairsOptions default [];
    property Value : string read GetValue write SetValue; // stored StoredValue;
    property PhysID : TPhysID read GetPhysID write SetPhysID;
    property ErrorCode : integer read GetErrorCode write SetErrorCode default 0;// stored false;
    property ErrorString : string read GetErrorString write SetErrorString;// stored false;

    property Hints: TStrings read FHints write SetHints;
    property ErrorHint: string read FErrorHint write SetErrorHint;
    property ValueHint: string read FValueHint write SetValueHint;

    property Params: TStrings read FParams write SetParams;

    property Ranges: TaDCRanges read FRanges write SetRanges;

  end;

  TaOPCDataObject = class (TaCustomOPCDataObject)
  private
    fColorNotActive: TColor;
    fColorActive: TColor;
    procedure SetColorActive(const Value: TColor);
    procedure SetColorNotActive(const Value: TColor);
    function GetActive: boolean;
    procedure SetActive(const Value: boolean);
  protected
  public
  published
    property ColorActive : TColor read fColorActive write SetColorActive default clBlue;
    property ColorNotActive : TColor read fColorNotActive write SetColorNotActive default clBlack;
    property Active : boolean read GetActive write SetActive stored false;
  end;

implementation

uses Math;

{ TaCustomOPCDataObject }

constructor TaCustomOPCDataObject.Create(aOwner: TComponent);
begin
  inherited;
  FInteractive := false;

  FDataLinks:=TList.Create;
  FDataLink := TaOPCDataLink.Create(Self);
  FDataLink.OnChangeData := ChangeData;
  FDataLink.StairsOptions := [];

  FGraphicDataLink := TaOPCGraphicDataLink.Create(Self);
  FGraphicDataLink.OnChangeData := ChangeData;

  FHints := TStringList.Create;
  FParams := TStringList.Create;

  FRanges := TaDCRanges.Create;
end;

destructor TaCustomOPCDataObject.Destroy;
begin
  FOnChange := nil;
  OPCSource := nil;
  GraphicOPCSource := nil;

  FreeAndNil(FDataLink);
  FreeAndNil(FGraphicDataLink);

  while FDataLinks.Count > 0 do
    RemoveDataLink(FDataLinks.Last);
  FreeAndNil(FDataLinks);

  FreeAndNil(FDragImages);

  FreeAndNil(FHints);
  FreeAndNil(FParams);

  FreeAndNil(FRanges);

  inherited;
end;

procedure TaCustomOPCDataObject.DoMouseEnter;
begin

end;

procedure TaCustomOPCDataObject.DoMouseLeave;
begin

end;

function TaCustomOPCDataObject.GetErrorCode: integer;
begin
  Result := DataLink.ErrorCode;
end;

function TaCustomOPCDataObject.GetErrorString: string;
begin
  Result := DataLink.ErrorString;
end;

function TaCustomOPCDataObject.GetPhysID: TPhysID;
begin
  Result := DataLink.PhysID;
end;

function TaCustomOPCDataObject.GetValue: string;
begin
  Result := DataLink.Value;
end;

function TaCustomOPCDataObject.GetOPCSource: TaCustomOPCSource;
begin
  Result := fDataLink.OPCSource;
end;

procedure TaCustomOPCDataObject.SetParams(const Value: TStrings);
begin
  FParams.Assign(Value);
end;

procedure TaCustomOPCDataObject.SetPhysID(const Value: TPhysID);
begin
  fDataLink.PhysID := Value;
  fGraphicDataLink.PhysID := Value;
end;

procedure TaCustomOPCDataObject.SetRanges(const Value: TaDCRanges);
begin
  FRanges.AssignTo(Value);
end;

procedure TaCustomOPCDataObject.SetValue(const Value: string);
begin
  if DataLink.Value <> Value then
    DataLink.Value := Value;
end;

procedure TaCustomOPCDataObject.SetValueHint(const Value: string);
begin
  if FValueHint <> Value then
  begin
    FValueHint := Value;
    Hint := CalcHint;
  end;
end;

function TaCustomOPCDataObject.StoredValue: boolean;
begin
  // сохраняем значение только если
  // (не задан источник данных или адрес)
  // и (не задан графический источник данных)
  Result :=
    (not Assigned(OPCSource) or not (PhysID <> ''))
    and not Assigned(GraphicOPCSource);
end;

procedure TaCustomOPCDataObject.SetOPCSource(const Value: TaCustomOPCSource);
begin
  if fDataLink.OPCSource <> Value then
    fDataLink.OPCSource := Value;
  if Value<>nil then
    fGraphicDataLink.OPCSource := nil;
end;

function TaCustomOPCDataObject.CalcHint: string;
var
  i: integer;
  v: extended;
  Key, LastKey : extended;
  IsFound: boolean;
begin
  Result := '';

  if (ErrorHint <> '') and (ErrorString <> '') then
    Result := Format(ErrorHint,[ErrorString])

  else if (ValueHint <> '') then
  begin
    if Pos('%s', ValueHint) > 0 then
      Result := Format(ValueHint, [Value])
    else
      Result := ValueHint;
  end

  else if Hints.Count > 0 then
  begin
    try
      // если есть однозначное соответствие - возвращаем его
      i := Hints.IndexOfName(Value);
      if i >= 0 then
      begin
        Result := Hints.ValueFromIndex[i];
        exit;
      end;

      // иначе ищем промежуточное значение
      //(записи должны быть упорядочены)
      //TStringList(Hints).Sorted := true; 
      
      v := StrToFloat(Value);
      LastKey := StrToFloat(FHints.Names[0]);

      IsFound := false;
      for i:=1 to FHints.Count-1 do
      begin
        try
          Key := StrToFloat(FHints.Names[i]);
          if (LastKey >= Key) then
          begin
            IsFound := true;
            Result := 'значения для отображения подсказок должны быть отсортированы в порядке возрастания';
            break;
          end;

          if (LastKey <= v) and (v < Key) then
          begin
            IsFound := true;
            Result := FHints.ValueFromIndex[i-1];
            break;
          end;
          LastKey := Key;
        except
          on e:exception do;
        end;
      end;

      if (not IsFound) and (v >= LastKey) then
        Result := FHints.ValueFromIndex[FHints.Count-1];
    except
      on e:exception do;
    end;
  end;
//  else
//    Result := Hint;
end;

procedure TaCustomOPCDataObject.ChangeData(Sender: TObject);
begin
  UpdateDataLinks;
  Hint := CalcHint;

  if Assigned(FOnChange) and (not (csLoading  in ComponentState))
    and (not (csDestroying in ComponentState)) then
    FOnChange(Self);

  RepaintRequest(self);
end;

function TaCustomOPCDataObject.GetGraphicOPCSource: TaCustomOPCDataObject;
begin
  Result := fGraphicDataLink.OPCSource;
end;

procedure TaCustomOPCDataObject.SetGraphicOPCSource(
  const Value: TaCustomOPCDataObject);
begin
  if fGraphicDataLink.OPCSource <> Value then
  begin
    fGraphicDataLink.OPCSource := Value;
    if Assigned(fGraphicDataLink.OPCSource) then
      fGraphicDataLink.Value := fGraphicDataLink.OPCSource.Value;
  end;
  if Value <> nil then
    fDataLink.OPCSource := nil;
end;

procedure TaCustomOPCDataObject.SetHints(const Value: TStrings);
begin
  FHints.Assign(Value);
  //TStringList(FHints).Sort;
  Hint := CalcHint;
end;

procedure TaCustomOPCDataObject.SetInteractive(const Value: boolean);
begin
  FInteractive := Value;
end;

function TaCustomOPCDataObject.GetDataLink: TaCustomDataLink;
begin
  if GraphicOPCSource<>nil then
    Result := fGraphicDataLink
  else
    Result := fDataLink;
end;

function TaCustomOPCDataObject.GetDragImages: TDragImageList;
var
  i: integer;
  B: TBitmap;
//  aCanvas: TCanvas;
begin
  if not Assigned(FDragImages) then
    FDragImages := TDragImageList.Create(nil);
  Result := FDragImages;
  Result.Clear;
  B := TBitmap.Create;
  try
    B.Height := Height ;
    B.Width  := Width;
    B.Canvas.Brush.Color := clLime;
    //B.Canvas.Rectangle(B.Canvas.ClipRect);
    //B.Canvas.FillRect(B.Canvas.ClipRect);

    B.Canvas.CopyRect(Rect(0,0,Width,Height),Canvas,Rect(0,0,Width,Height));

    //B.Canvas.Rectangle(0,0,Width,Height);
    Result.Width := B.Width;
    Result.Height := B.Height;
    i:= Result.AddMasked(B, clLime);
    Result.SetDragImage(i, FMouseDownX, FMouseDownY);
  finally
    B.Free;
  end
end;

procedure TaCustomOPCDataObject.AddDataLink(DataLink:TaOPCGraphicDataLink);
begin
  FDataLinks.Add(DataLink);
  DataLink.fOPCSource := Self;
end;

procedure TaCustomOPCDataObject.RemoveDataLink(DataLink: TaOPCGraphicDataLink);
begin
  DataLink.fOPCSource := nil;
  FDataLinks.Remove(DataLink);
end;

procedure TaCustomOPCDataObject.RepaintRequest(Sender: TObject);
begin
  Invalidate;
end;

function TaCustomOPCDataObject.GetStairsOptions: TDCStairsOptionsSet;
begin
  if GraphicOPCSource <> nil then
    Result := GraphicOPCSource.StairsOptions
  else
    Result := DataLink.StairsOptions;
end;

procedure TaCustomOPCDataObject.SetStairsOptions(const Value: TDCStairsOptionsSet);
begin
  if GraphicOPCSource <> nil then
    GraphicOPCSource.StairsOptions := Value
  else
    FDataLink.StairsOptions := Value;
end;

procedure TaCustomOPCDataObject.UpdateDataLinks;
var
  i: Integer;
  IsChanged:boolean;
  CrackDataLink:TaOPCGraphicDataLink;
begin
  for I := 0 to FDataLinks.Count - 1 do
  begin
    CrackDataLink := TaOPCGraphicDataLink(FDataLinks.Items[i]);
    IsChanged:=(CrackDataLink.fValue<>Value) or
      (CrackDataLink.fErrorCode<>ErrorCode) or
      (CrackDataLink.fErrorString<>ErrorString);
    if IsChanged then
    begin
      CrackDataLink.fValue       := Value;
      CrackDataLink.fErrorCode   := ErrorCode;
      CrackDataLink.fErrorString := ErrorString;
      CrackDataLink.ChangeData;
    end;
  end;
end;

function TaCustomOPCDataObject.IsActive: boolean;
begin
  Result := not ((Value='0') or (Value='') or
    (Pos('FALSE',UpperCase(Value))>0) or (StrToIntDef(Value,0)=0));
end;

procedure TaCustomOPCDataObject.SetBounds(ALeft, ATop, AWidth,
  AHeight: Integer);
begin
  inherited;
//  if (csLoading in ComponentState) then
//    UpdateOriginalPosition;
end;

procedure TaCustomOPCDataObject.SetErrorCode(const Value: integer);
begin
  DataLink.ErrorCode := Value;
end;

procedure TaCustomOPCDataObject.SetErrorHint(const Value: string);
begin
  if FErrorHint <> Value then
  begin
    FErrorHint := Value;
    Hint := CalcHint;
  end;
end;

procedure TaCustomOPCDataObject.SetErrorString(const Value: string);
begin
  DataLink.ErrorString := Value;
end;

procedure TaCustomOPCDataObject.UpdateOriginalPosition;
begin
  OriginalLeft := Left;
  OriginalTop  := Top;
  OriginalWidth := Width;
  OriginalHeight := Height;
  OriginalFontSize := Font.Size;
  Scale := 1;
end;

procedure TaCustomOPCDataObject.ChangeScale(M, D: Integer);
begin
{  if Name = 'St1' then
  begin
    ShowMessageFmt('OriginalLeft = %d; Left = %d; csLoading = %s; csReading = %s',
    [OriginalLeft,Left,BoolToStr(csLoading in ComponentState),
    BoolToStr(csReading in ComponentState)]);
  end;
}
  if M = 0 then exit;
  
  if (csLoading in ComponentState) or (OriginalWidth = 0) or
    (csReading in ComponentState) then
  begin
    inherited ChangeScale(M, D);
    exit;
  end;

  if M <> D then
  begin
    if SameValue(D/M,Scale,0.001) then
    begin
      Scale := 1;
      SetBounds(OriginalLeft,OriginalTop,OriginalWidth,OriginalHeight);
      Font.Size := OriginalFontSize;
    end
    else
    begin
      Scale := Scale * M/D;
      SetBounds(Round(OriginalLeft*Scale),Round(OriginalTop*Scale),
        Round(OriginalWidth*Scale),Round(OriginalHeight*Scale));
      Font.Size := Round(OriginalFontSize*Scale);
    end;
  //  if not ParentFont then
  //    Font.Size := MulDiv(Font.Size, M, D);
  end;
end;

procedure TaCustomOPCDataObject.CMMouseEnter(var Message: TMessage);
begin
  FMouseInSide := true;
  DoMouseEnter;
  if Assigned(FOnMouseEnter) then
    FOnMouseEnter(Self);
end;

procedure TaCustomOPCDataObject.CMMouseLeave(var Message: TMessage);
begin
  FMouseInSide := false;
  DoMouseLeave;
  if Assigned(FOnMouseLeave) then
    FOnMouseLeave(Self);
end;

function TaCustomOPCDataObject.GetMoment: TDateTime;
begin
  Result:=fDataLink.Moment;
end;

procedure TaCustomOPCDataObject.Loaded;
begin
  inherited;
  UpdateOriginalPosition;
end;

procedure TaCustomOPCDataObject.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  FMouseDownX := X;
  FMouseDownY := Y; 
  inherited;
end;

function TaCustomOPCDataObject.GetUpdateOnChangeMoment: boolean;
begin
  Result := DataLink.UpdateOnChangeMoment;
end;

procedure TaCustomOPCDataObject.SetUpdateOnChangeMoment(
  const Value: boolean);
begin
  DataLink.UpdateOnChangeMoment := Value;
end;

{ TaOPCDataObject }

procedure TaOPCDataObject.SetActive(const Value: boolean);
begin
  if Value then
    Self.Value:='1'
  else
    Self.Value:='0';
end;

function TaOPCDataObject.GetActive: boolean;
begin
  Result:=IsActive;
end;

procedure TaOPCDataObject.SetColorActive(const Value: TColor);
begin
  if fColorActive<>Value then
  begin
    fColorActive := Value;
    RepaintRequest(self);
  end;
end;

procedure TaOPCDataObject.SetColorNotActive(const Value: TColor);
begin
  if fColorNotActive<>Value then
  begin
    fColorNotActive := Value;
    RepaintRequest(self);
  end;
end;


{ TaOPCGraphicDataLink }

constructor TaOPCGraphicDataLink.Create(aControl: TObject);
begin
  inherited;
  OPCSource := nil;
end;

destructor TaOPCGraphicDataLink.Destroy;
begin
  OPCSource := nil;
  inherited;
end;

procedure TaOPCGraphicDataLink.SetOPCSource(
  const Value: TaCustomOPCDataObject);
begin
  if (fOPCSource <> Value) and (Control <> Value) then
  begin
    if fOPCSource<>nil then
      fOPCSource.RemoveDataLink(Self);
    if Value<>nil then
      Value.AddDataLink(self);
  end;
end;

{ TaDCRanges }

procedure TaDCRanges.AssignTo(Dest: TPersistent);
var
  d: TaDCRanges;
begin
  if not (Dest is TaDCRanges) then
  begin
    inherited AssignTo(Dest);
  end
  else
  begin
    d := TaDCRanges(Dest);
    d.WarnLowLevel := WarnLowLevel;
    d.WarnHighLevel := WarnHighLevel;
    d.AlarmLowLevel := AlarmLowLevel;
    d.AlarmHighLevel := AlarmHighLevel;
  end;

end;

function TaDCRanges.Check(aValue: string): TaDCRangesCheckResult;
var
  v: Double;
begin
  // проверка выключена - выходим
  if not Enable then
    Exit(rcrOk);

  // об ошибках конвертации сообщаем
  if not TryStrToFloat(aValue, v) then
    Exit(rcrConvertError);

  // вначале проверяем аварийные пределы
  if v < AlarmLowLevel then
    Exit(rcrAlarmLowLevel);
  if v > AlarmHighLevel then
    Exit(rcrAlarmHighLevel);

  // аварий нет - проверяем предупреждения
  if v < WarnLowLevel then
    Exit(rcrWarnLowLevel);
  if v > WarnHighLevel then
    Exit(rcrWarnHighLevel);

  // прошли все проверки - порядок
  Result := rcrOk;;

end;

procedure TaDCRanges.SetAlarmHighLevel(const Value: Double);
begin
  FAlarmHighLevel := Value;
end;

procedure TaDCRanges.SetAlarmLowLevel(const Value: Double);
begin
  FAlarmLowLevel := Value;
end;

procedure TaDCRanges.SetEnable(const Value: Boolean);
begin
  FEnable := Value;
end;

procedure TaDCRanges.SetWarnHighLevel(const Value: Double);
begin
  FWarnHighLevel := Value;
end;

procedure TaDCRanges.SetWarnLowLevel(const Value: Double);
begin
  FWarnLowLevel := Value;
end;

end.
