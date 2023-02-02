unit aOPCTagDictionary;

interface

uses
  Classes,
  aCustomOPCSource,
  aOPCCollection;

type

  TaOPCTagDictionary = class(TComponent)
  private
    FTags: TTagCollection;
    procedure SetTags(Value: TTagCollection);
  protected
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
  public
    constructor Create(AOnwer: TComponent); override;
    destructor Destroy; override;
  published
    property Tags: TTagCollection read FTags write SetTags;
  end;



implementation


{ TaOPCTagDictionary }

constructor TaOPCTagDictionary.Create(AOnwer: TComponent);
begin
  inherited Create(AOnwer);
  FTags := TTagCollection.Create(TTagCollectionItem);
end;

destructor TaOPCTagDictionary.Destroy;
begin
  FTags.Free;
  inherited Destroy;
end;

procedure TaOPCTagDictionary.Notification(AComponent: TComponent;
  Operation: TOperation);
var
  i:integer;
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent is TaCustomOPCSource) then
  begin
    for i := 0 to FTags.Count - 1 do
      if FTags.Items[i].OPCSource = AComponent then
        FTags.Items[i].OPCSource := nil;
  end;
end;

procedure TaOPCTagDictionary.SetTags(Value: TTagCollection);
begin
  FTags.Assign(Value);
end;

end.
