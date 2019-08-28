unit aOPCProvider;

interface

uses
  SysUtils, Classes, //Dialogs,
  aCustomOPCSource, aOPCSource, uDCObjects;

type
  TDataEvent = (deProviderChange, deProviderListChange,
    dePropertyChange, deFocusControl,
    deDisabledStateChange);


  TCrackOPCLink = class(TaOPCDataLink);
  TaOPCProviderList = class;

  { identifies the control value name for TaOPCProvider }
  [ObservableMember('Value')]

  TaOPCProvider = class(TaCustomSingleOPCSource)
  private
    fDataLink: TaOPCDataLink;
    FOnChange: TNotifyEvent;
    function GetOPCSource: TaCustomOPCSource;
    procedure SetOPCSource(const Value: TaCustomOPCSource);
    function GetPhysID: TPhysID;
    procedure SetPhysID(const Value: TPhysID);
    function GetErrorCode: integer;
    function GetErrorString: string;
    function GetValue: string;
    procedure SetValue(const Value: string);

    procedure ChangeData(Sender:TObject);
    function GetStairsOptions: TDCStairsOptionsSet;
    procedure SetStairsOptions(const Value: TDCStairsOptionsSet);

    procedure ObserverToggle(const AObserver: IObserver; const Value: Boolean);
    function GetValueAsFloat: Double;
    procedure SetValueAsFloat(const Value: Double);
  protected
    function CanObserve(const ID: Integer): Boolean; override;
    procedure ObserverAdded(const ID: Integer; const Observer: IObserver); override;

    procedure DoActive; override;
    procedure DoNotActive; override;

//    procedure DefineProperties(Filer: TFiler); override;
  public
    constructor Create(aOwner : TComponent);override;
    destructor Destroy; override;

  published
    property OnChange: TNotifyEvent read FOnChange write FOnChange;

    property OPCSource : TaCustomOPCSource read GetOPCSource write SetOPCSource;

    property StairsOptions : TDCStairsOptionsSet
      read GetStairsOptions write SetStairsOptions default [];
    property Value : string read GetValue write SetValue;
    property ValueAsFloat : Double read GetValueAsFloat write SetValueAsFloat;
    property PhysID : TPhysID read GetPhysID write SetPhysID;
    property ErrorCode : integer read GetErrorCode;
    property ErrorString : string read GetErrorString;
  end;

  { identifies the control value name for TaOPCProviderItem }
  [ObservableMember('Value')]
  [ObservableMember('PhysID')]

  TaOPCProviderItem = class(TaOPCProvider)
  private
    FProviderList: TaOPCProviderList;
    procedure SetProviderList(const Value: TaOPCProviderList);
    function GetIndex: Integer;
    procedure SetIndex(Value: Integer);
  protected
    procedure ReadState(Reader: TReader); override;
    procedure SetParentComponent(AParent: TComponent); override;
  public
    destructor Destroy; override;

    function GetParentComponent: TComponent; override;
    function HasParent: Boolean; override;

    property ProviderList: TaOPCProviderList read FProviderList write SetProviderList;
  published
    property Index: Integer read GetIndex write SetIndex stored False;
  end;

  TaOPCProviderClass = class of TaOPCProvider;

  TaOPCProviderListDesigner = class;

  TaOPCProviderList = class(TComponent)
  private
    FDesigner : TaOPCProviderListDesigner;
    FProviders: TList;
    FOPCSource: TaOPCSource;
    function GetProvider(Index: Integer): TaOPCProviderItem;
    function GetProviderCount: Integer;
    procedure SetProvider(Index: Integer; Value: TaOPCProviderItem);
    procedure SetOPCSource(const Value: TaOPCSource);
  protected
    procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
    procedure DataEvent(Event: TDataEvent; Info: Longint); virtual;

    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
    procedure SetChildOrder(Component: TComponent; Order: Integer); override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure AddProvider(Provider: TaOPCProviderItem);
    procedure RemoveProvider(Provider: TaOPCProviderItem);

    property Designer: TaOPCProviderListDesigner read FDesigner;
    property Providers[Index: Integer]: TaOPCProviderItem read GetProvider write SetProvider; default;
    property ProviderCount: Integer read GetProviderCount;
  published
    property OPCSource : TaOPCSource read FOPCSource write SetOPCSource;

  end;

  TaOPCProviderListDesigner = class(TObject)
  private
    FProviderList: TaOPCProviderList;
  public
    constructor Create(aProviderList: TaOPCProviderList);
    destructor Destroy; override;

    procedure DataEvent(Event: TDataEvent; Info: Longint); virtual;

    property ProviderList: TaOPCProviderList read FProviderList;
  end;


implementation

//uses
//  Controls;

{ TaOPCProvider }

constructor TaOPCProvider.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);

  fDataLink := TaOPCDataLink.Create(Self);
  fDataLink.OnChangeData := ChangeData;
  fDataLink.StairsOptions := [];
end;

//procedure TaOPCProvider.DefineProperties(Filer: TFiler);
//begin
//end;

destructor TaOPCProvider.Destroy;
begin
  FOnChange := nil;
  OPCSource := nil;
  fDataLink.Free;
  inherited;
end;

function TaOPCProvider.GetErrorCode: integer;
begin
  Result := fDataLink.ErrorCode;
end;

function TaOPCProvider.GetErrorString: string;
begin
  Result := fDataLink.ErrorString;
end;

function TaOPCProvider.GetPhysID: TPhysID;
begin
  Result := fDataLink.PhysID;
end;

function TaOPCProvider.GetValue: string;
begin
  Result := fDataLink.Value;
end;

function TaOPCProvider.GetValueAsFloat: Double;
begin
  Result := fDataLink.FloatValue;
end;

procedure TaOPCProvider.ObserverAdded(const ID: Integer;
  const Observer: IObserver);
begin
  if ID = TObserverMapping.EditLinkID then
    Observer.OnObserverToggle := ObserverToggle;
end;

// на будущее можно запретить связанным элемента менять Value
// например, добавить свойство ReadOnly

{ All controls that support the EditLink observer should prevent the user from changing the
  control value. Disabling the control is one way to do it. Some observer implementations ignore
  certain types of input to prevent the user from changing the control value. }
procedure TaOPCProvider.ObserverToggle(const AObserver: IObserver; const Value: Boolean);
//var
//  LEditLinkObserver: IEditLinkObserver;
begin
//  if Value then
//  begin
//    if Supports(AObserver, IEditLinkObserver, LEditLinkObserver) then
//      { disable the trackbar if the associated field does not support editing }
//      Enabled := not LEditLinkObserver.IsReadOnly;
//  end else
//    Enabled := True;
end;

function TaOPCProvider.GetOPCSource: TaCustomOPCSource;
begin
  Result := fDataLink.OPCSource;
end;

procedure TaOPCProvider.SetPhysID(const Value: TPhysID);
var
  DataLinkGroup:TOPCDataLinkGroup;
  i,j: Integer;
begin
  if PhysID<>Value then
  begin
    fDataLink.PhysID := Value;
    for i:=DataLinkGroups.Count - 1 downto 0 do
    begin
      DataLinkGroup:=TOPCDataLinkGroup(DataLinkGroups.Items[i]);
      DataLinkGroup.PhysID:=Value;
      if DataLinkGroup<>nil then
        for j := 0 to DataLinkGroup.DataLinks.Count - 1 do
          TaOPCDataLink(DataLinkGroup.DataLinks.Items[j]).PhysID := Value;
    end;
  end;
end;

procedure TaOPCProvider.SetValue(const Value: string);
begin
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    Exit;

  if fDataLink.Value <> Value then
  begin
    fDataLink.Value := Value;
    if Assigned(FOnChange) then
      FOnChange(Self);
  end;
{
  if Assigned(FOnChange) and (not (csLoading in ComponentState)) then
    FOnChange(self);
}
    
end;

procedure TaOPCProvider.SetValueAsFloat(const Value: Double);
begin
  fDataLink.FloatValue := Value;
end;

procedure TaOPCProvider.SetOPCSource(const Value: TaCustomOPCSource);
begin
  if (fDataLink.OPCSource <> Value) and (Value <> Self) then
    fDataLink.OPCSource := Value;
end;

function TaOPCProvider.CanObserve(const ID: Integer): Boolean;
{ Controls which implement observers always override TComponent.CanObserve(const ID: Integer). }
{ This method identifies the type of observers supported by TObservableTrackbar. }
begin
  case ID of
    TObserverMapping.EditLinkID,      { EditLinkID is the observer that is used for control-to-field links }
    TObserverMapping.ControlValueID:
      Result := True;
  else
    Result := False;
  end;
end;

procedure TaOPCProvider.ChangeData(Sender: TObject);
var
  i,j: Integer;
  IsChanged:boolean;
  DataLinkGroup:TOPCDataLinkGroup;
  CrackDataLink:TCrackOPCLink;
begin
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    Exit;

  TLinkObservers.ControlChanged(Self);

  if Active then
  begin
    for i := 0 to FDataLinkGroups.Count - 1 do    // Iterate
    begin
      DataLinkGroup:=TOPCDataLinkGroup(FDataLinkGroups.Items[i]);
      if DataLinkGroup<>nil then
      begin
        for j := 0 to DataLinkGroup.DataLinks.Count - 1 do
        begin
          CrackDataLink := TCrackOPCLink(DataLinkGroup.DataLinks.Items[j]);
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
    end;
  end;

  if Assigned(FOnChange) and (not (csLoading in ComponentState))
    and (not (csDestroying in ComponentState)) then
    FOnChange(Self);


{
  if Assigned(FOnChange) then
    FOnChange(Self);
}
end;

procedure TaOPCProvider.DoActive;
begin
  fActive:=true;
  inherited;
end;

procedure TaOPCProvider.DoNotActive;
begin
  fActive:=False;
  inherited;
end;

function TaOPCProvider.GetStairsOptions: TDCStairsOptionsSet;
begin
  Result := fDataLink.StairsOptions;
end;

procedure TaOPCProvider.SetStairsOptions(const Value: TDCStairsOptionsSet);
begin
  fDataLink.StairsOptions := Value;
end;

{ TCustomProviderList }

procedure TaOPCProviderList.AddProvider(Provider: TaOPCProviderItem);
begin
  FProviders.Add(Provider);
  Provider.FProviderList := Self;
  Provider.FreeNotification(Self);
  DataEvent(deProviderListChange,0);
end;

constructor TaOPCProviderList.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FProviders := TList.Create;
end;

procedure TaOPCProviderList.DataEvent(Event: TDataEvent; Info: Integer);
begin
  if FDesigner <> nil then
    FDesigner.DataEvent(Event, Info);
end;

destructor TaOPCProviderList.Destroy;
begin
  FreeAndNil(FDesigner);

  while FProviders.Count > 0 do
    TaOPCProvider(FProviders.Last).Free;

  FProviders.Free;
  inherited Destroy;
end;

procedure TaOPCProviderList.GetChildren(Proc: TGetChildProc;
  Root: TComponent);
var
  I: Integer;
  Provider: TaOPCProvider;
begin
  for I := 0 to FProviders.Count - 1 do
  begin
    Provider := FProviders.List[I];
    if Provider.Owner = Root then Proc(Provider);
  end;
end;

function TaOPCProviderList.GetProvider(Index: Integer): TaOPCProviderItem;
begin
  Result := FProviders[Index];
end;

function TaOPCProviderList.GetProviderCount: Integer;
begin
  Result := FProviders.Count;
end;

procedure TaOPCProviderList.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if Operation = opRemove then
    if (AComponent is TaOPCProviderItem) then
      RemoveProvider(TaOPCProviderItem(AComponent));
end;

procedure TaOPCProviderList.RemoveProvider(Provider: TaOPCProviderItem);
begin
  if FProviders.Remove(Provider) >= 0 then
    Provider.FProviderList := nil;
  DataEvent(deProviderListChange,0);
end;

procedure TaOPCProviderList.SetChildOrder(Component: TComponent;
  Order: Integer);
begin
  if FProviders.IndexOf(Component) >= 0 then
    (Component as TaOPCProviderItem).Index := Order;
end;

procedure TaOPCProviderList.SetOPCSource(const Value: TaOPCSource);
begin
  FOPCSource := Value;
end;

procedure TaOPCProviderList.SetProvider(Index: Integer; Value: TaOPCProviderItem);
begin
  TaOPCProvider(FProviders[Index]).Assign(Value);
  DataEvent(deProviderListChange,0);
end;

{ TaOPCProviderListDesigner }

constructor TaOPCProviderListDesigner.Create(aProviderList: TaOPCProviderList);
begin
  FProviderList := aProviderList;
  aProviderList.FDesigner := self;
end;

procedure TaOPCProviderListDesigner.DataEvent(Event: TDataEvent; Info: Integer);
begin
end;

destructor TaOPCProviderListDesigner.Destroy;
begin
  FProviderList.FDesigner := nil;
  inherited;
end;

{ TaOPCProviderItem }

destructor TaOPCProviderItem.Destroy;
begin
  inherited;
  if ProviderList <> nil then
    ProviderList.RemoveProvider(Self);
end;

function TaOPCProviderItem.GetIndex: Integer;
begin
  if FProviderList <> nil then
    Result := FProviderList.FProviders.IndexOf(Self)
  else
    Result := -1;
end;

function TaOPCProviderItem.GetParentComponent: TComponent;
begin
  if ProviderList <> nil then
  begin
    Result := ProviderList;
    //ShowMessage(ProviderList.Name);
  end
  else
    Result := inherited GetParentComponent;
end;

function TaOPCProviderItem.HasParent: Boolean;
begin
  if ProviderList <> nil then
    Result := True
  else
    Result := inherited HasParent;
end;

procedure TaOPCProviderItem.ReadState(Reader: TReader);
begin
  inherited ReadState(Reader);
  if Reader.Parent is TaOPCProviderList then
     ProviderList := TaOPCProviderList(Reader.Parent);
end;


procedure TaOPCProviderItem.SetIndex(Value: Integer);
var
  CurIndex, Count: Integer;
begin
  CurIndex := GetIndex;
  if CurIndex >= 0 then
  begin
    Count := ProviderList.FProviders.Count;
    if Value < 0 then Value := 0;
    if Value >= Count then Value := Count - 1;
    if Value <> CurIndex then
    begin
      ProviderList.FProviders.Delete(CurIndex);
      ProviderList.FProviders.Insert(Value, Self);
    end;
  end;
end;

procedure TaOPCProviderItem.SetParentComponent(AParent: TComponent);
begin
  if not (csLoading in ComponentState) and (AParent is TaOPCProviderList) then
    ProviderList := TaOPCProviderList(AParent);
end;

procedure TaOPCProviderItem.SetProviderList(const Value: TaOPCProviderList);
begin
  if Value <> ProviderList then
  begin
    if ProviderList <> nil then ProviderList.RemoveProvider(Self);
    if Value <> nil then Value.AddProvider(Self);
  end;
end;

initialization
  Classes.RegisterClass(TaOPCProvider);

//  GroupDescendentsWith(TaOPCProviderList, Controls.TControl);
//  GroupDescendentsWith(TaCustomSingleOPCSource, Controls.TControl);


end.
