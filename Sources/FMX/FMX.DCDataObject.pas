unit FMX.DCDataObject;

interface

uses
  System.Generics.Collections,
  System.Classes, System.UITypes, System.SysUtils,
  FMX.Controls,
  aCustomOPCSource, uDCObjects;

type
  TaCustomOPCDataObject = class;

  TaOPCGraphicDataLink = class(TaCustomDataLink)
  private
    FOPCSource: TaCustomOPCDataObject;
    procedure SetOPCSource(const Value: TaCustomOPCDataObject);
  public
    constructor Create(aControl: TObject); override;
    destructor Destroy; override;

    property OPCSource: TaCustomOPCDataObject read FOPCSource write SetOPCSource;
  end;

//  TaOPCGraphicDataLinkList = class(TList<TaOPCGraphicDataLink>)
//  end;

  TaCustomOPCDataObject = class(TStyledControl)
  private
    FDataLink: TaOPCDataLink;
    FGraphicDataLink: TaOPCGraphicDataLink;

    FOnChange: TNotifyEvent;
    FInteractive: boolean;

    FHints: TStrings;
    FErrorHint: string;
    FParams: TStrings;
    FValueHint: string;
    procedure SetInteractive(const Value: boolean);

    procedure SetGraphicOPCSource(const Value: TaCustomOPCDataObject);

    function GetOPCSource: TaCustomOPCSource;
    function GetGraphicOPCSource: TaCustomOPCDataObject;

    function GetMoment: TDateTime;
    function GetErrorCode: Integer;
    function GetErrorString: string;
    function GetPhysID: TPhysID;

    function GetDataLink: TaCustomDataLink;

    procedure AddDataLink(DataLink: TaCustomDataLink);
    procedure RemoveDataLink(DataLink: TaCustomDataLink);

    function GetStairsOptions: TDCStairsOptionsSet;
    procedure SetStairsOptions(const Value: TDCStairsOptionsSet);

    function GetUpdateOnChangeMoment: boolean;
    procedure SetUpdateOnChangeMoment(const Value: boolean);
    procedure SetHints(const Value: TStrings);
    procedure SetParams(const Value: TStrings);
    procedure SetErrorHint(const Value: string);

    function CalcHint: string;
    procedure SetValueHint(const Value: string);

  protected
    FDataLinks: TaCustomDataLinkList;

    function StoredValue: boolean; virtual;

    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;

    procedure SetPhysID(const Value: TPhysID); virtual;
    procedure SetOPCSource(const Value: TaCustomOPCSource); virtual;

    function GetValue: string; virtual;
    procedure SetValue(const Value: string); virtual;

    procedure UpdateDataLinks; virtual;
    procedure ChangeData(Sender: TObject); virtual;
    procedure RepaintRequest(Sender: TObject); virtual;

    property Interactive: boolean read FInteractive write SetInteractive default false;
  public
    FMouseDownX, FMouseDownY: Single;

    function IsActive: boolean; virtual;

    property DataLink: TaCustomDataLink read GetDataLink;

    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;

    property Moment: TDateTime read GetMoment;
  published
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    // публикуем события родителя
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;

    property PopupMenu;
    property Visible;
    property ShowHint;
    property Enabled;
    property Anchors;

    property OPCSource: TaCustomOPCSource read GetOPCSource write SetOPCSource;
    property GraphicOPCSource: TaCustomOPCDataObject read GetGraphicOPCSource write SetGraphicOPCSource;

    property StairsOptions: TDCStairsOptionsSet read GetStairsOptions write SetStairsOptions default [];
    property UpdateOnChangeMoment: boolean read GetUpdateOnChangeMoment write SetUpdateOnChangeMoment default false;

    property Value: string read GetValue write SetValue stored StoredValue;
    property PhysID: TPhysID read GetPhysID write SetPhysID;
    property ErrorCode: integer read GetErrorCode stored false;
    property ErrorString: string read GetErrorString stored false;

    property Hints: TStrings read FHints write SetHints;
    property ErrorHint: string read FErrorHint write SetErrorHint;
    property ValueHint: string read FValueHint write SetValueHint;

    property Params: TStrings read FParams write SetParams;
  end;

  TaOPCDataObject = class(TaCustomOPCDataObject)
  private
    FColorActive: TColor;
    FColorNotActive: TColor;
    function GetActive: boolean;
    procedure SetActive(const Value: boolean);
    procedure SetColorActive(const Value: TColor);
    procedure SetColorNotActive(const Value: TColor);
  published
//    property ColorActive: TColor read FColorActive write SetColorActive default TColorRec.Blue; // clBlue;
//    property ColorNotActive: TColor read FColorNotActive write SetColorNotActive default TColorRec.Black; // clBlack;
//
//    property Active: boolean read GetActive write SetActive stored false;
  end;

implementation

uses Math;

{ TaCustomOPCDataObject }

constructor TaCustomOPCDataObject.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  FInteractive := false;

  FDataLinks := TaCustomDataLinkList.Create;

  FDataLink := TaOPCDataLink.Create(Self);
  FDataLink.OnChangeData := ChangeData;
  FDataLink.StairsOptions := [];

  FGraphicDataLink := TaOPCGraphicDataLink.Create(Self);
  FGraphicDataLink.OnChangeData := ChangeData;

  FHints := TStringList.Create;
  FParams := TStringList.Create;
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

  FreeAndNil(FHints);
  FreeAndNil(FParams);
  inherited;
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
  Result := FDataLink.OPCSource;
end;

procedure TaCustomOPCDataObject.SetParams(const Value: TStrings);
begin
  FParams.Assign(Value);
end;

procedure TaCustomOPCDataObject.SetPhysID(const Value: TPhysID);
begin
  FDataLink.PhysID := Value;
  FGraphicDataLink.PhysID := Value;
end;

procedure TaCustomOPCDataObject.SetValue(const Value: string);
begin
  if DataLink.Value <> Value then
    DataLink.Value := Value;
end;

procedure TaCustomOPCDataObject.SetValueHint(const Value: string);
begin
  FValueHint := Value;
end;

function TaCustomOPCDataObject.StoredValue: boolean;
begin
  // сохраняем значение только если
  // (не задан источник данных или адрес)
  // и (не задан графический источник данных)
  Result := (not Assigned(OPCSource) or not(PhysID <> '')) and not Assigned(GraphicOPCSource);
end;

procedure TaCustomOPCDataObject.SetOPCSource(const Value: TaCustomOPCSource);
begin
  if FDataLink.OPCSource <> Value then
    FDataLink.OPCSource := Value;
  if Value <> nil then
    FGraphicDataLink.OPCSource := nil;
end;

function TaCustomOPCDataObject.CalcHint: string;
var
  i: integer;
  v: extended;
  Key, LastKey: extended;
  IsFound: boolean;
begin
  Result := '';

  if (ErrorHint <> '') and (ErrorString <> '') then
    Result := Format(ErrorHint, [ErrorString])

  else if (ValueHint <> '') then
    Result := Format(ValueHint, [Value])

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
      // (записи должны быть упорядочены)
      // TStringList(Hints).Sorted := true;

      v := StrToFloat(Value);
      LastKey := StrToFloat(FHints.Names[0]);

      IsFound := false;
      for i := 1 to FHints.Count - 1 do
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
            Result := FHints.ValueFromIndex[i - 1];
            break;
          end;
          LastKey := Key;
        except
          on e: exception do;
        end;
      end;

      if (not IsFound) and (v >= LastKey) then
        Result := FHints.ValueFromIndex[FHints.Count - 1];
    except
      on e: exception do;
    end;
  end;
  // else
  // Result := Hint;
end;

procedure TaCustomOPCDataObject.ChangeData(Sender: TObject);
begin
  UpdateDataLinks;
  Hint := CalcHint;

  if Assigned(FOnChange) and (not(csLoading in ComponentState)) and (not(csDestroying in ComponentState)) then
    FOnChange(Self);

  RepaintRequest(Self);
end;

function TaCustomOPCDataObject.GetGraphicOPCSource: TaCustomOPCDataObject;
begin
  Result := FGraphicDataLink.OPCSource;
end;

procedure TaCustomOPCDataObject.SetGraphicOPCSource(const Value: TaCustomOPCDataObject);
begin
  if FGraphicDataLink.OPCSource <> Value then
  begin
    FGraphicDataLink.OPCSource := Value;
    if Assigned(FGraphicDataLink.OPCSource) then
      FGraphicDataLink.Value := FGraphicDataLink.OPCSource.Value;
  end;
  if Value <> nil then
    FDataLink.OPCSource := nil;
end;

procedure TaCustomOPCDataObject.SetHints(const Value: TStrings);
begin
  FHints.Assign(Value);
  // TStringList(FHints).Sort;
end;

procedure TaCustomOPCDataObject.SetInteractive(const Value: boolean);
begin
  FInteractive := Value;
end;

function TaCustomOPCDataObject.GetDataLink: TaCustomDataLink;
begin
  if GraphicOPCSource <> nil then
    Result := FGraphicDataLink
  else
    Result := FDataLink;
end;

procedure TaCustomOPCDataObject.AddDataLink(DataLink: TaCustomDataLink);
begin
  if (DataLink is TaOPCGraphicDataLink) then
  begin
    FDataLinks.Add(DataLink);
    TaOPCGraphicDataLink(DataLink).FOPCSource := Self;
  end;
end;

procedure TaCustomOPCDataObject.RemoveDataLink(DataLink: TaCustomDataLink);
begin
  if (DataLink is TaOPCGraphicDataLink) then
  begin
    TaOPCGraphicDataLink(DataLink).FOPCSource := nil;
    FDataLinks.Remove(DataLink);
  end;
end;

procedure TaCustomOPCDataObject.RepaintRequest(Sender: TObject);
begin
  Repaint;
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
  i: integer;
  IsChanged: boolean;
  CrackDataLink: TaOPCGraphicDataLink;
begin
  for i := 0 to FDataLinks.Count - 1 do
  begin
    if Assigned(FDataLinks.Items[i])
      and (FDataLinks.Items[i] is TaOPCGraphicDataLink) then
    begin
      CrackDataLink := TaOPCGraphicDataLink(FDataLinks.Items[i]);
      IsChanged :=
        (CrackDataLink.fValue <> Value) or
        (CrackDataLink.fErrorCode <> ErrorCode) or
        (CrackDataLink.fErrorString <> ErrorString);
      if IsChanged then
      begin
        CrackDataLink.fValue := Value;
        CrackDataLink.fErrorCode := ErrorCode;
        CrackDataLink.fErrorString := ErrorString;
        CrackDataLink.ChangeData;
      end;
    end;
  end;
end;

function TaCustomOPCDataObject.IsActive: boolean;
begin
  Result := not((Value = '0') or (Value = '') or (Pos('FALSE', UpperCase(Value)) > 0) or (StrToIntDef(Value, 0) = 0));
end;

procedure TaCustomOPCDataObject.SetErrorHint(const Value: string);
begin
  FErrorHint := Value;
end;

function TaCustomOPCDataObject.GetMoment: TDateTime;
begin
  Result := FDataLink.Moment;
end;

procedure TaCustomOPCDataObject.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  FMouseDownX := X;
  FMouseDownY := Y;
  inherited;
end;

function TaCustomOPCDataObject.GetUpdateOnChangeMoment: boolean;
begin
  Result := DataLink.UpdateOnChangeMoment;
end;

procedure TaCustomOPCDataObject.SetUpdateOnChangeMoment(const Value: boolean);
begin
  DataLink.UpdateOnChangeMoment := Value;
end;

{ TaOPCDataObject }

procedure TaOPCDataObject.SetActive(const Value: boolean);
begin
  if Value then
    Self.Value := '1'
  else
    Self.Value := '0';
end;

function TaOPCDataObject.GetActive: boolean;
begin
  Result := IsActive;
end;

procedure TaOPCDataObject.SetColorActive(const Value: TColor);
begin
  if FColorActive <> Value then
  begin
    FColorActive := Value;
    RepaintRequest(Self);
  end;
end;

procedure TaOPCDataObject.SetColorNotActive(const Value: TColor);
begin
  if FColorNotActive <> Value then
  begin
    FColorNotActive := Value;
    RepaintRequest(Self);
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

procedure TaOPCGraphicDataLink.SetOPCSource(const Value: TaCustomOPCDataObject);
begin
  if (FOPCSource <> Value) and (Control <> Value) then
  begin
    if FOPCSource <> nil then
      FOPCSource.RemoveDataLink(Self);
    if Value <> nil then
      Value.AddDataLink(Self);
  end;
end;

end.
