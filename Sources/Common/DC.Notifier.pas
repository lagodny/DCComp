unit DC.Notifier;

interface

uses
  System.Classes,
  System.Generics.Defaults, System.Generics.Collections,
  aCustomOPCSource,
  DC.Collection;

type
  TNotifyType = (
    ntAlarm,
    ntWarning,
    ntInformation
  );

  TNotifyItem = record
    Moment: TDateTime;
    NotifyType: TNotifyType;
    Msg: string;
  end;

  /// компонент, который содержит список датчиков с настройками срабатывания: значение датчика не входит в заданный диапазон
  ///  при сработке события, оно добавляется в очередь
  ///  по таймеру можно проверять размер очереди, извлекать и показывать события
  TDCNotifier = class(TComponent)
  private
    FItems: TDCDataLinkCollection;
    FQueue: TQueue<TNotifyItem>;
    FMuted: Boolean;
    FActive: Boolean;
    procedure SetItems(const Value: TDCDataLinkCollection);
    procedure SetMuted(const Value: Boolean);
    procedure SetActive(const Value: Boolean);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

    procedure ChangeData(Sender: TObject); virtual;
  public
    constructor Create(AOnwer: TComponent); override;
    destructor Destroy; override;

    procedure AddToQueue(aItem: TDCDataLinkCollectionItem);

    procedure ShowNotification;
    procedure HideNotification;

    procedure StartSound;
    procedure StopSound;

    procedure StartNotify;
    procedure StopNotify;

    property Queue: TQueue<TNotifyItem> read FQueue;
  published
    property Items: TDCDataLinkCollection read FItems write SetItems;

    property Muted: Boolean read FMuted write SetMuted;
    property Active: Boolean read FActive write SetActive;
  end;

implementation

{ TDCNotifier }

procedure TDCNotifier.AddToQueue(aItem: TDCDataLinkCollectionItem);
var
  aRec: TNotifyItem;
begin
  aRec.Moment := aItem.DataLink.Moment;
  aRec.NotifyType := ntInformation;
  aRec.Msg := aItem.Representation;
  FQueue.Enqueue(aRec);
end;

procedure TDCNotifier.ChangeData(Sender: TObject);
var
  aItem: TDCDataLinkCollectionItem;
begin
  if not Active or not Assigned(Sender) or not (Sender is TDCDataLinkCollectionItem) then
    Exit;

  aItem := TDCDataLinkCollectionItem(Sender);

  if aItem.DataLink.IsAlarm and (not aItem.DataLink.OldIsAlarm) and (aItem.DataLink.OldMoment <> 0) then
    AddToQueue(aItem);
end;

constructor TDCNotifier.Create(AOnwer: TComponent);
begin
  inherited Create(AOnwer);
  FQueue := TQueue<TNotifyItem>.Create;
  FItems := TDCDataLinkCollection.Create(Self);
  FItems.OnChangeData := ChangeData;
end;

destructor TDCNotifier.Destroy;
begin
  FItems.Free;
  FQueue.Free;
  inherited;
end;

procedure TDCNotifier.HideNotification;
begin

end;

procedure TDCNotifier.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);

  if (Operation = opRemove) and (AComponent is TaCustomOPCSource) then
  begin
    if FItems.OPCSource = AComponent then
      FItems.OPCSource := nil;
  end;
end;

procedure TDCNotifier.SetActive(const Value: Boolean);
begin
  FActive := Value;
end;

procedure TDCNotifier.SetItems(const Value: TDCDataLinkCollection);
begin
  FItems.Assign(Value);
end;

procedure TDCNotifier.SetMuted(const Value: Boolean);
begin
  FMuted := Value;
end;

procedure TDCNotifier.ShowNotification;
begin

end;

procedure TDCNotifier.StartNotify;
begin
  ShowNotification;
  StartSound;
end;

procedure TDCNotifier.StartSound;
begin

end;

procedure TDCNotifier.StopNotify;
begin
  HideNotification;
  StopSound;
end;

procedure TDCNotifier.StopSound;
begin

end;

end.
