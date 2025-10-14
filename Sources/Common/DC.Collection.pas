unit DC.Collection;

interface

uses
  System.Classes,
  System.SysUtils,
  aCustomOPCSource,
  aOPCClass;

type
  EDCDataLinkCollectionError = class(Exception);

  TDCDataLinkCollection = class;

  TDCDataLinkCollectionItem = class(THashCollectionItem)
  private
    FDataLink: TaOPCDataLink;
    FShowMoment: boolean;
    function GeTDCDataLinkCollection: TDCDataLinkCollection;
    procedure SetDataLink(Value: TaOPCDataLink);
    function GetPhysID: TPhysID;
    function GetValue: string;
    procedure SetPhysID(const Value: TPhysID);
    procedure SetValue(const Value: string);
    function GetRepresentation: string;
    procedure SetShowMoment(const Value: boolean);
    function GetOnGetIsAlarm: TOnGetIsAlarm;
    procedure SetOnGetIsAlarm(const Value: TOnGetIsAlarm);
    function GetMinValue: Double;
    procedure SetMinValue(const Value: Double);
    function GetMaxValue: Double;
    procedure SetMaxValue(const Value: Double);
  protected
    procedure SetName(const Value: string); override;
    procedure ChangeData(Sender: TObject); virtual;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;

    property DataLinkCollection: TDCDataLinkCollection read GeTDCDataLinkCollection;
    property DataLink: TaOPCDataLink read FDataLink write SetDataLink;
    property Representation: string read GetRepresentation;
  published
    property ShowMoment: boolean read FShowMoment write SetShowMoment default false;
    property PhysID: TPhysID read GetPhysID write SetPhysID;
    property Value: string read GetValue write SetValue;

    property MinValue: Double read GetMinValue write SetMinValue;
    property MaxValue: Double read GetMaxValue write SetMaxValue;

    property OnGetIsAlarm: TOnGetIsAlarm read GetOnGetIsAlarm write SetOnGetIsAlarm;
  end;

  { TDCDataLinkCollection }

  TDCDataLinkCollection = class(THashCollection)
  private
    FOwner: TPersistent;
    FOnChangeData: TNotifyEvent;
    FOPCSource : TaCustomMultiOPCSource;
    function GetItem(Index: Integer): TDCDataLinkCollectionItem;
    function GetOPCsource: TaCustomMultiOPCSource;
    procedure SetOPCSource(const Value: TaCustomMultiOPCSource);
  protected
    function GetOwner: TPersistent; override;
    procedure ChangeData(Sender: TObject); virtual;
  public
    constructor Create(AOwner: TPersistent);
    destructor Destroy; override;

    function Find(const Name: string): TDCDataLinkCollectionItem;
    property Items[Index: Integer]: TDCDataLinkCollectionItem read GetItem; default;

    function AddItem(const aName, aSensorID: string; aMin, aMax: Double; aGetIsAlarmProc: TOnGetIsAlarm = nil): TDCDataLinkCollectionItem;

    property OnChangeData:TNotifyEvent read FOnChangeData write FOnChangeData;
  published
    property OPCSource: TaCustomMultiOPCSource read GetOPCsource write SetOPCSource;
  end;

implementation

uses
  aOPCConsts;

resourcestring
  sValueTooLow = 'value too low';
  sValueTooHigh = 'value too high';

  { TDCDataLinkCollectionItem }

procedure TDCDataLinkCollectionItem.Assign(Source: TPersistent);
var
  s: TDCDataLinkCollectionItem;
begin
  if Source is TDCDataLinkCollectionItem then
  begin
    s := TDCDataLinkCollectionItem(Source);
    Name := s.Name;
    FDataLink.PhysID := s.FDataLink.PhysID;
  end
  else
    inherited Assign(Source);
end;

procedure TDCDataLinkCollectionItem.ChangeData(Sender: TObject);
begin
  if Assigned(Collection) and (Collection is TDCDataLinkCollection) then
    TDCDataLinkCollection(Collection).ChangeData(Self);
end;

constructor TDCDataLinkCollectionItem.Create(Collection: TCollection);
begin
  inherited Create(Collection);
//  FDataLink := TaOPCDataLink.Create(Collection.Owner);
  FDataLink := TaOPCDataLink.Create(Collection);
  FDataLink.StairsOptions := [];

  if Assigned(Collection) and (Collection is TDCDataLinkCollection) then
   begin
     FDataLink.OPCSource := DataLinkCollection.OPCSource;
   end;

  FDataLink.OnChangeData := ChangeData;
  FDataLink.Control := Self;
end;

destructor TDCDataLinkCollectionItem.Destroy;
begin
  //Value := '';
  FDataLink.Free;
  inherited Destroy;
end;

function TDCDataLinkCollectionItem.GeTDCDataLinkCollection: TDCDataLinkCollection;
begin
  Result := Collection as TDCDataLinkCollection;
end;

function TDCDataLinkCollectionItem.GetMaxValue: Double;
begin
  Result := DataLink.AlarmMaxValue;
end;

function TDCDataLinkCollectionItem.GetMinValue: Double;
begin
  Result := DataLink.AlarmMinValue;
end;

function TDCDataLinkCollectionItem.GetOnGetIsAlarm: TOnGetIsAlarm;
begin
  Result := DataLink.OnGetIsAlarm;
end;

function TDCDataLinkCollectionItem.GetPhysID: TPhysID;
begin
  Result := FDataLink.PhysID;
end;

function TDCDataLinkCollectionItem.GetRepresentation: string;
begin

  if ((DataLink.Moment = 0) or not ShowMoment) then
    Result := Name
  else
    Result := DateTimeToStr(DataLink.Moment) + ' : ' + Name;

  if DataLink.AlarmMinValue <> DataLink.AlarmMaxValue then
  begin
    if DataLink.FloatValue < DataLink.AlarmMinValue then
      Result := Result + ' : ' + sValueTooLow
    else if DataLink.FloatValue > DataLink.AlarmMaxValue then
      Result := Result + ' : ' + sValueTooHigh;
  end;
end;

function TDCDataLinkCollectionItem.GetValue: string;
begin
  Result := FDataLink.Value;
end;

procedure TDCDataLinkCollectionItem.SetDataLink(Value: TaOPCDataLink);
begin
  FDataLink.Assign(Value);
//  FDataLink.PhysID := Value.PhysID;
end;

procedure TDCDataLinkCollectionItem.SetMaxValue(const Value: Double);
begin
  DataLink.AlarmMaxValue := Value;
end;

procedure TDCDataLinkCollectionItem.SetMinValue(const Value: Double);
begin
  DataLink.AlarmMinValue := Value;
end;

procedure TDCDataLinkCollectionItem.SetName(const Value: string);
{ var
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

procedure TDCDataLinkCollectionItem.SetOnGetIsAlarm(const Value: TOnGetIsAlarm);
begin
  FDataLink.OnGetIsAlarm := Value;
end;

procedure TDCDataLinkCollectionItem.SetPhysID(const Value: TPhysID);
begin
  FDataLink.PhysID := Value;
end;

procedure TDCDataLinkCollectionItem.SetShowMoment(const Value: boolean);
begin
  FShowMoment := Value;
end;

procedure TDCDataLinkCollectionItem.SetValue(const Value: string);
begin
  FDataLink.Value := Value;
end;

{ TDCDataLinkCollection }

function TDCDataLinkCollection.AddItem(const aName, aSensorID: string; aMin, aMax: Double; aGetIsAlarmProc: TOnGetIsAlarm = nil): TDCDataLinkCollectionItem;
begin
  Result := TDCDataLinkCollectionItem(Add);
  Result.Name := aName;
  Result.DataLink.PhysID := aSensorID;
  Result.DataLink.AlarmMinValue := aMin;
  Result.DataLink.AlarmMaxValue := aMax;
  Result.DataLink.OnGetIsAlarm := aGetIsAlarmProc;
end;

procedure TDCDataLinkCollection.ChangeData(Sender: TObject);
begin
  if Assigned(FOnChangeData) then
    FOnChangeData(Sender);
end;

constructor TDCDataLinkCollection.Create(AOwner: TPersistent);
begin
  inherited Create(TDCDataLinkCollectionItem);
  FOwner := AOwner;
end;

destructor TDCDataLinkCollection.Destroy;
begin
  inherited Destroy;
end;

function TDCDataLinkCollection.Find(const Name: string): TDCDataLinkCollectionItem;
var
  i: Integer;
begin
  i := IndexOf(Name);
  if i = -1 then
    raise EDCDataLinkCollectionError.CreateFmt(SDataLinkNotFound, [Name]);
  Result := Items[i];
end;

function TDCDataLinkCollection.GetItem(Index: Integer): TDCDataLinkCollectionItem;
begin
  Result := TDCDataLinkCollectionItem(inherited Items[Index]);
end;

function TDCDataLinkCollection.GetOPCsource: TaCustomMultiOPCSource;
begin
  Result := FOPCSource;
end;

function TDCDataLinkCollection.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

procedure TDCDataLinkCollection.SetOPCSource(const Value: TaCustomMultiOPCSource);
begin
  if FOPCSource <> Value then
  begin
    FOPCSource := Value;
    for var i := 0 to Count - 1 do
      Items[i].DataLink.OPCSource := Value;
  end;
end;

end.
