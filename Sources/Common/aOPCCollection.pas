unit aOPCCollection;

interface

uses
  Classes, SysUtils,
  uDCObjects,
  aOPCClass, aCustomOPCSource;

type

  TTagCollection = class;

  { TTagCollectionItem  }

  TTagCollectionItem = class(TCollectionItem)
  private
    FDataLink: TaOPCDataLink;
    FOnChange: TNotifyEvent;
    FName: string;
    procedure SetDataLink(Value: TaOPCDataLink);
    function GetPhysID: TPhysID;
    function GetValue: string;
    procedure SetPhysID(const Value: TPhysID);
    procedure SetValue(const Value: string);
    function GetOPCSource: TaCustomOPCSource;
    function GetStairsOptions: TDCStairsOptionsSet;
    procedure SetOPCSource(const Value: TaCustomOPCSource);
    procedure SetStairsOptions(const Value: TDCStairsOptionsSet);
    procedure SetName(const Value: string);
  protected
    procedure ChangeData(Sender:TObject);virtual;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    property DataLink: TaOPCDataLink read FDataLink write SetDataLink;
  published
    property Name: string read FName write SetName;

    property OPCSource : TaCustomOPCSource
      read GetOPCSource write SetOPCSource;

    property PhysID:TPhysID read GetPhysID write SetPhysID;
    property StairsOptions : TDCStairsOptionsSet
      read GetStairsOptions write SetStairsOptions default [];

    property Value:string read GetValue write SetValue;

    property OnChange:TNotifyEvent read FOnChange write FOnChange;
  end;

  TTagCollectionItemClass = class of TCollectionItem;

  {  TTagCollection  }

  TTagCollection = class(TCollection)
  private
    FOnChanged: TNotifyEvent;
    function GetTagItem(Index: Integer): TTagCollectionItem;
    procedure SetTagItem(Index: Integer; const Value: TTagCollectionItem);
  protected
    FOwner: TPersistent;
    //function GetOwner: TPersistent; override;
    procedure Update(Item: TCollectionItem); override;
  public
    //constructor Create(Owner: TPersistent);

    property Items[Index: Integer]: TTagCollectionItem
      read GetTagItem write SetTagItem; default;
  published
    property OnChanged: TNotifyEvent read FOnChanged write FOnChanged;
  end;




implementation

{ TTagCollectionItem }

procedure TTagCollectionItem.Assign(Source: TPersistent);
var
  aSourceItem: TTagCollectionItem;
begin
  if Source is TTagCollectionItem then
  begin
    aSourceItem := TTagCollectionItem(Source);
    FDataLink.PhysID := aSourceItem.FDataLink.PhysID;
    FDataLink.StairsOptions := aSourceItem.FDataLink.StairsOptions;
  end
  else
    inherited Assign(Source);
end;

procedure TTagCollectionItem.ChangeData(Sender: TObject);
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

constructor TTagCollectionItem.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FDataLink := TaOPCDataLink.Create(Self);
  FDataLink.OnChangeData := ChangeData;
  FDataLink.StairsOptions := [];
end;

destructor TTagCollectionItem.Destroy;
begin
  FOnChange := nil;
  OPCSource := nil;
  FDataLink.Free;
  
  inherited Destroy;
end;

function TTagCollectionItem.GetOPCSource: TaCustomOPCSource;
begin
  Result := FDataLink.OPCSource;
end;

function TTagCollectionItem.GetPhysID: TPhysID;
begin
  Result := FDataLink.PhysID;
end;

function TTagCollectionItem.GetStairsOptions: TDCStairsOptionsSet;
begin
  Result := FDataLink.StairsOptions;
end;

function TTagCollectionItem.GetValue: string;
begin
  Result := FDataLink.Value;
end;

procedure TTagCollectionItem.SetDataLink(Value: TaOPCDataLink);
begin
  FDataLink.PhysID := Value.PhysID;
end;

procedure TTagCollectionItem.SetName(const Value: string);
begin
  FName := Value;
end;

procedure TTagCollectionItem.SetOPCSource(const Value: TaCustomOPCSource);
begin
  FDataLink.OPCSource := Value;
end;

procedure TTagCollectionItem.SetPhysID(const Value: TPhysID);
begin
  FDataLink.PhysID := Value;
end;

procedure TTagCollectionItem.SetStairsOptions(
  const Value: TDCStairsOptionsSet);
begin
  FDataLink.StairsOptions := Value;
end;

procedure TTagCollectionItem.SetValue(const Value: string);
begin
  if DataLink.Value<>Value then
    DataLink.Value := Value;
end;

{ TTagCollection }

//constructor TTagCollection.Create(Owner: TPersistent);
//begin
//  inherited Create(TTagCollectionItem);
//  FOwner := Owner;
//end;

function TTagCollection.GetTagItem(Index: Integer): TTagCollectionItem;
begin
  Result := TTagCollectionItem(inherited Items[Index]);
end;

procedure TTagCollection.SetTagItem(Index: Integer;
  const Value: TTagCollectionItem);
begin
  inherited Items[Index] := Value;
end;

//function TTagCollection.GetOwner: TPersistent;
//begin
//  Result := FOwner;
//end;

procedure TTagCollection.Update(Item: TCollectionItem);
begin
  inherited Update(Item);
  if Assigned(FOnChanged) then FOnChanged(Item);
end;

end.
