unit aOPCListBox;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,
  aOPCClass, aCustomOPCSource, aOPCConsts;

type
  EDataLinkCollectionError = class(Exception);

  {  TDataLinkCollectionItem  }

  TDataLinkCollection = class;

  TDataLinkCollectionItem = class(THashCollectionItem)
  private
    FDataLink: TaOPCDataLink;
    FShowMoment: boolean;
    function GetDataLinkCollection: TDataLinkCollection;
    procedure SetDataLink(Value: TaOPCDataLink);
    function GetPhysID: TPhysID;
    function GetValue: string;
    procedure SetPhysID(const Value: TPhysID);
    procedure SetValue(const Value: string);
    function GetRepresentation: string;
    procedure SetShowMoment(const Value: boolean);
  protected
    procedure SetName(const Value: string);override;
    procedure ChangeData(Sender:TObject);virtual;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    property DataLinkCollection: TDataLinkCollection read GetDataLinkCollection;
    property DataLink: TaOPCDataLink read FDataLink write SetDataLink;
    property Representation: string read GetRepresentation;
  published
    property ShowMoment:boolean read FShowMoment write SetShowMoment default false;
    property PhysID:TPhysID read GetPhysID write SetPhysID;
    property Value:string read GetValue write SetValue;
  end;

  {  TDataLinkCollection  }

  TDataLinkCollection = class(THashCollection)
  private
    FOwner: TPersistent;
    function GetItem(Index: Integer): TDataLinkCollectionItem;
  protected
    function GetOwner: TPersistent; override;
  public
    constructor Create(AOwner: TPersistent);
    destructor Destroy; override;
    function Find(const Name: string): TDataLinkCollectionItem;
//    procedure LoadFromFile(const FileName: string);
//    procedure LoadFromStream(Stream: TStream);
//    procedure SaveToFile(const FileName: string);
//    procedure SaveToStream(Stream: TStream);
    property Items[Index: Integer]: TDataLinkCollectionItem read GetItem; default;
  end;



  TaOPCListBox = class(TListBox)
  private
    FDataLinkItems: TDataLinkCollection;
    FOPCSource : TaCustomMultiOPCSource;
    FOnChangeData: TNotifyEvent;
    procedure SetDataLinkItems(Value: TDataLinkCollection);
  protected
    procedure SetOPCSource(const Value: TaCustomMultiOPCSource);virtual;
    function GetOPCSource: TaCustomMultiOPCSource;virtual;
    procedure ChangeData(Sender:TObject);virtual;
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
  public
    constructor Create(AOnwer: TComponent); override;
    destructor Destroy; override;
  published
    property OnChangeData:TNotifyEvent read FOnChangeData write FOnChangeData;
    property OPCSource: TaCustomMultiOPCSource read GetOPCsource write SetOPCSource;
    property DataLinkItems: TDataLinkCollection read FDataLinkItems write SetDataLinkItems;
  end;


implementation

uses StrUtils;

{ TaOPCListBox }

procedure TaOPCListBox.ChangeData(Sender: TObject);
var
  i:integer;
  dl:TDataLinkCollectionItem;
//  Index:integer;
begin
{
  if (Sender is TDataLinkCollectionItem)
    and not (csDestroying in ComponentState) then
  begin
    dl := TDataLinkCollectionItem(Sender);
    if dl.Name = '' then
      exit;
    Index := Items.IndexOf(dl.Representation);
    if dl.FDataLink.IsActive then
    begin
      if Index < 0 then
        Items.Add(dl.Representation);
    end
    else
    begin
      if Index >= 0 then
        Items.Delete(Index);
    end;
    if Assigned(FOnChangeData) then
      FOnChangeData(Self);
  end;
}
  if (csDestroying in ComponentState)
    or (csLoading in ComponentState)
    or (csReading in ComponentState) then
    exit;
    
  Items.BeginUpdate;
  Items.Clear;
  for i:=0 to Pred(FDataLinkItems.Count) do
  begin
    dl := FDataLinkItems[i];
    if not (dl.Name = '') and dl.DataLink.IsActive and (dl.DataLink.ErrorCode = 0) then
      Items.AddObject(dl.Representation, dl);
  end;
  Items.EndUpdate;

  if Assigned(FOnChangeData) then
    FOnChangeData(Sender);
{
  for i:=FDataLinkItems.Count - 1 downto 0 do
  begin
    dl := FDataLinkItems[i];
    if dl.Name = '' then
      Continue;
    Index := Items.IndexOf(dl.Name);
    if dl.FDataLink.IsActive then
    begin
      if Index < 0 then
        Items.Add(dl.Name);
    end
    else
    begin
      if Index >= 0 then
        Items.Delete(Index);
    end;
  end;
}
end;

constructor TaOPCListBox.Create(AOnwer: TComponent);
begin
  inherited Create(AOnwer);
  FDataLinkItems := TDataLinkCollection.Create(Self);
end;

destructor TaOPCListBox.Destroy;
begin
  FDataLinkItems.Free;
  inherited Destroy;
end;

function TaOPCListBox.GetOPCSource: TaCustomMultiOPCSource;
begin
  Result := FOPCSource;
end;

procedure TaOPCListBox.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FOPCSource) then
    FOPCSource := nil;
end;

procedure TaOPCListBox.SetDataLinkItems(Value: TDataLinkCollection);
begin
  FDataLinkItems.Assign(Value);
end;

procedure TaOPCListBox.SetOPCSource(const Value: TaCustomMultiOPCSource);
var
  i:integer;
begin
  if FOPCSource <> Value then
  begin
    FOPCSource := Value;
    for i:=0 to FDataLinkItems.Count - 1 do
      TDataLinkCollectionItem(FDataLinkItems[i]).DataLink.OPCSource := Value;
  end;
end;

{ TDataLinkCollectionItem }

procedure TDataLinkCollectionItem.Assign(Source: TPersistent);
var
  s: TDataLinkCollectionItem;
begin
  if Source is TDataLinkCollectionItem then
  begin
    s := TDataLinkCollectionItem(Source);
    Name := s.Name;
    FDataLink.PhysID := s.FDataLink.PhysID;
  end
  else
    inherited Assign(Source);
end;

procedure TDataLinkCollectionItem.ChangeData(Sender: TObject);
begin
  if (Collection.Owner <> nil) and (Collection.Owner is TaOPCListBox) then
    TaOPCListBox(Collection.Owner).ChangeData(Self);
end;

constructor TDataLinkCollectionItem.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FDataLink := TaOPCDataLink.Create(Collection.Owner);
  FDataLink.StairsOptions := [];

  if (Collection.Owner <> nil) and (Collection.Owner is TaOPCListBox) then
  begin
    FDataLink.OPCSource := TaOPCListBox(Collection.Owner).OPCSource;
    FDataLink.OnChangeData := ChangeData;
  end;

  FDataLink.Control := Self;
end;

destructor TDataLinkCollectionItem.Destroy;
begin
  Value := '';
  FDataLink.Free;
  inherited Destroy;
end;

function TDataLinkCollectionItem.GetDataLinkCollection: TDataLinkCollection;
begin
  Result := Collection as TDataLinkCollection;
end;

function TDataLinkCollectionItem.GetPhysID: TPhysID;
begin
  Result := FDataLink.PhysID;
end;

function TDataLinkCollectionItem.GetRepresentation: string;
begin
  Result := IfThen((DataLink.Moment = 0) or not ShowMoment,
      '',DateTimeToStr(DataLink.Moment)+' : ')+ Name;
      
end;

function TDataLinkCollectionItem.GetValue: string;
begin
  Result := FDataLink.Value;
end;

procedure TDataLinkCollectionItem.SetDataLink(Value: TaOPCDataLink);
begin
  FDataLink.PhysID := Value.PhysID;
end;

procedure TDataLinkCollectionItem.SetName(const Value: string);
{var
  index:integer;
  OldRepresentation,OldName:string;
  }
begin
{
  OldRepresentation := Representation;
  OldName := Name;
  inherited;

  if FDataLink.IsActive then
  begin
    if (OldName<>Value) then
    begin
      if OldName <> '' then
      begin
        index := TaOPCListBox(Collection.Owner).Items.IndexOf(OldRepresentation);
        if index >= 0 then
        begin
          if Value = '' then
            TaOPCListBox(Collection.Owner).Items.Delete(index)
          else
            TaOPCListBox(Collection.Owner).Items.Strings[index]:= Representation;
        end;
      end
      else
        TaOPCListBox(Collection.Owner).Items.Add(Representation);
    end;
  end;
}
  inherited;
  ChangeData(nil);
end;

procedure TDataLinkCollectionItem.SetPhysID(const Value: TPhysID);
begin
  FDataLink.PhysID := Value;
end;

procedure TDataLinkCollectionItem.SetShowMoment(const Value: boolean);
begin
  FShowMoment := Value;
end;

procedure TDataLinkCollectionItem.SetValue(const Value: string);
begin
  FDataLink.Value := Value;
end;

{ TDataLinkCollection }

constructor TDataLinkCollection.Create(AOwner: TPersistent);
begin
  inherited Create(TDataLinkCollectionItem);
  FOwner := AOwner;
end;

destructor TDataLinkCollection.Destroy;
begin
  inherited Destroy;
end;

function TDataLinkCollection.Find(
  const Name: string): TDataLinkCollectionItem;
var
  i: Integer;
begin
  i := IndexOf(Name);
  if i=-1 then
    raise EDataLinkCollectionError.CreateFmt(SDataLinkNotFound, [Name]);
  Result := Items[i];
end;

function TDataLinkCollection.GetItem(
  Index: Integer): TDataLinkCollectionItem;
begin
  Result := TDataLinkCollectionItem(inherited Items[Index]);
end;

function TDataLinkCollection.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

end.
