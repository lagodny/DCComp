unit DC.Notify.Handler;

interface

uses
  System.Classes, System.SysUtils,
  VCL.ExtCtrls,
  DC.Notifier;

type
  /// компонент периодически проверяет очередь уведомлений компонента Notifier
  ///  и визуализирует эти уведомления: показывает окно и проигрывает звук
  TDCNotifyHandler = class(TComponent)
  private
    FNotifier: TDCNotifier;
    FTimer: TTimer;
    FActive: Boolean;
    FSoundFileName: TFileName;
    procedure DoTimer(Sender: TObject);
    procedure SetActive(const Value: Boolean);
    procedure SetSoundFileName(const Value: TFileName);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Notifier: TDCNotifier read FNotifier write FNotifier;
    property Active: Boolean read FActive write SetActive default False;
    property SoundFileName: TFileName read FSoundFileName write SetSoundFileName;
  end;

implementation

uses
  DC.VCL.Form.NewMessage;

{ TNotifyNandler }

constructor TDCNotifyHandler.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FTimer := TTimer.Create(nil);
  FTimer.Enabled := False;
  FTimer.Interval := 1000;
  FTimer.OnTimer := DoTimer;
end;

destructor TDCNotifyHandler.Destroy;
begin
  FTimer.Free;
  inherited;
end;

procedure TDCNotifyHandler.DoTimer(Sender: TObject);
var
  aRec: TNotifyItem;
begin
  if not Assigned(Notifier) then
    Exit;

  FTimer.Enabled := False;
  try
    while Notifier.Queue.Count > 0 do
    begin
      aRec := Notifier.Queue.Dequeue;
      if Notifier.Muted then
        TDCNewMessageForm.ShowDlg(aRec.Moment, aRec.Msg, '')
      else
        TDCNewMessageForm.ShowDlg(aRec.Moment, aRec.Msg, SoundFileName);
    end;
  finally
    FTimer.Enabled := FActive;
  end;
end;

procedure TDCNotifyHandler.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);

  if (Operation = opRemove) and (AComponent is TDCNotifier) then
  begin
    if Notifier = AComponent then
      Notifier := nil;
  end;
end;

procedure TDCNotifyHandler.SetActive(const Value: Boolean);
begin
  FActive := Value;
  FTimer.Enabled := FActive;
end;

procedure TDCNotifyHandler.SetSoundFileName(const Value: TFileName);
begin
  FSoundFileName := Value;
end;

end.
