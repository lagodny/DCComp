unit uUserMessageForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,
  aOPCSource,
  uUserMessage;

type
  TUserMessageForm = class(TForm)
    pIn: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    lUser: TLabel;
    lHost: TLabel;
    Label3: TLabel;
    mMessage: TMemo;
    Bevel1: TBevel;
    pOut: TPanel;
    Splitter1: TSplitter;
    mAnswer: TMemo;
    bAnswer: TButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure mAnswerChange(Sender: TObject);
    procedure bAnswerClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    FUserGUID: string;
    FOPCSource: TaOPCSource;
    procedure SetUserGUID(const Value: string);
    procedure SetOPCSource(const Value: TaOPCSource);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    procedure UpdateClientAction;

    procedure AddMessage(aMessage: TUserMessage; aSource: TaOPCSource);
    property UserGUID: string read FUserGUID write SetUserGUID;
    property OPCSource: TaOPCSource read FOPCSource write SetOPCSource;
  end;

  TMessageFormList = class
  private
    FList: TList;
    function FindMessageForm(aGUID: string): TUserMessageForm;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Add(aUserMessage: TUserMessage; aSource: TaOPCSource);
  end;

  procedure ShowUserMessage(aUserMessage: TUserMessage; aSource: TaOPCSource);

implementation

var
  FMessageFormList: TMessageFormList;

{$R *.dfm}

procedure ShowUserMessage(aUserMessage: TUserMessage; aSource: TaOPCSource);
begin
  if not Assigned(aUserMessage) then
    Exit;

  FMessageFormList.Add(aUserMessage, aSource);
end;


procedure TUserMessageForm.AddMessage(aMessage: TUserMessage; aSource: TaOPCSource);
begin
  UserGUID := aMessage.SenderGUID;
  OPCSource := aSource;

  lUser.Caption := aMessage.SenderUserName;
  lHost.Caption := aMessage.SenderAddr;

  if aMessage.Text <> '' then
    mMessage.Lines.Add('>> ' + FormatDateTime('hh:mm:ss', Now) + #9 + 'мне'#9 + aMessage.Text);

end;

procedure TUserMessageForm.bAnswerClick(Sender: TObject);
begin
  if Assigned(OPCSource) then
  begin
    OPCSource.SendUserMessage(UserGUID, mAnswer.Text);
    mMessage.Lines.Add('>> ' + FormatDateTime('hh:mm:ss', Now) + #9 + 'я'#9 + mAnswer.Text);
    mAnswer.Clear;
    UpdateClientAction;
  end;
end;

procedure TUserMessageForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FMessageFormList.FList.Remove(Self);
  Action := caFree;
end;

procedure TUserMessageForm.FormCreate(Sender: TObject);
begin
  mMessage.Clear;
  mAnswer.Clear;
end;

procedure TUserMessageForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = Chr(VK_ESCAPE) then
    Close
  else if Key = Chr(VK_RETURN) then
  begin
    Key := #0;
    bAnswerClick(Sender);
  end;
       
end;

procedure TUserMessageForm.mAnswerChange(Sender: TObject);
begin
  UpdateClientAction;
end;

procedure TUserMessageForm.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FOPCSource) then
    OPCSource := nil;
end;

procedure TUserMessageForm.SetOPCSource(const Value: TaOPCSource);
begin
  FOPCSource := Value;
  UpdateClientAction;  
end;

procedure TUserMessageForm.SetUserGUID(const Value: string);
begin
  FUserGUID := Value;
end;

procedure TUserMessageForm.UpdateClientAction;
begin
  bAnswer.Enabled := (mAnswer.Lines.Text <> '') and Assigned(OPCSource);
end;

{ TMessageFormList }

procedure TMessageFormList.Add(aUserMessage: TUserMessage; aSource: TaOPCSource);
var
  aForm: TUserMessageForm;
begin
  if not Assigned(aUserMessage) then
    Exit;

  aForm := FindMessageForm(aUserMessage.SenderGUID);
  if not Assigned(aForm) then
  begin
    aForm := TUserMessageForm.Create(nil);
    FList.Add(aForm);
  end;

  aForm.AddMessage(aUserMessage, aSource);
  aForm.Show;
  SetForegroundWindow(aForm.Handle);
end;

constructor TMessageFormList.Create;
begin
  FList := TList.Create;
end;

destructor TMessageFormList.Destroy;
var
  I: Integer;
begin
  for I := 0 to FList.Count - 1 do
    TObject(FList[i]).Free;
  FList.Free;
  
  inherited;
end;

function TMessageFormList.FindMessageForm(aGUID: string): TUserMessageForm;
var
  i: Integer;
begin
  Result := nil;

  for i := 0 to FList.Count - 1 do
    if TUserMessageForm(FList[i]).UserGUID = aGUID then
    begin
      Result := TUserMessageForm(FList[i]);
      Break;
    end;
end;

initialization
  FMessageFormList := TMessageFormList.Create;

finalization
  FMessageFormList.Free;


end.
