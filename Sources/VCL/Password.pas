unit Password;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, Dialogs, Messages,
  uDCLang,
  aOPCSource;

type
  TUserChoice = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    lUser: TLabel;
    lPassword: TLabel;
    ComboBox1: TComboBox;
    Edit1: TEdit;
    bChangePassword: TLabel;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure bChangePasswordMouseLeave(Sender: TObject);
    procedure bChangePasswordMouseEnter(Sender: TObject);
    procedure bChangePasswordClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FOPCSource: TaOPCSource;
    FShowOnTaskBar: Boolean;
    procedure SetOPCSource(const Value: TaOPCSource);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure WMSyscommand(var Message: TWmSysCommand); message WM_SYSCOMMAND;
  public
    constructor CreateAndShowOnTaskBar(AOwner: TComponent);

    procedure Localize;

    property OPCSource: TaOPCSource read FOPCSource write SetOPCSource;
  end;

var
  UserChoice: TUserChoice;

implementation

uses
  aOPCConnectionList,
  uChangePassword;

{$R *.dfm}

procedure TUserChoice.bChangePasswordClick(Sender: TObject);
var
  i: integer;
  //ok: boolean;
  //aOPCSource: TaOPCSource;
  aConnection: TOPCConnectionCollectionItem;
  aConnName: string;
  aOPCConnectionList: TaOPCConnectionList;
begin
  if Assigned(OPCSource) then
  begin
    with TfChangePassword.Create(self) do
    begin
      OPCSource := Self.OPCSource;
      eUser.Text := Self.ComboBox1.Text;
      eOldPassword.Text := Self.Edit1.Text;
      if ShowModal = mrOk then
      begin
        //ok := true;
        aConnection := nil;
        try
          if OPCSource.Owner is TaOPCConnectionList then
          begin
            aOPCConnectionList := TaOPCConnectionList(OPCSource.Owner);
            for i := 0 to aOPCConnectionList.Items.Count - 1 do
            begin
              aConnection := aOPCConnectionList.Items[i];
              if not aConnection.Enable then
                Continue;

              aConnection.OPCSource.ChangePassword(eUser.Text, eOldPassword.Text, eNewPassword.Text);
            end;
          end
          else
            OPCSource.ChangePassword(eUser.Text, eOldPassword.Text, eNewPassword.Text);

          ShowMessage(OPCSource.GetStringRes(idxChangePasswordMsg_PasswordChangedSuccessfuly));
          Edit1.Text := eNewPassword.Text;
          Edit1.SelectAll;
          PostMessage(Self.OKBtn.Handle, CM_ACTIVATE, 0, 0);
        except
          on e: Exception do
          begin
            if Assigned(aConnection) then
              aConnName := aConnection.DisplayName
            else
              aConnName := '';

            MessageDlg(Format(
              OPCSource.GetStringRes(idxChangePasswordMsg_UnableChangePassword),
              [aConnName]), mtError, [mbOK], 0);
          end;
        end;
      end;
    end;
  end;
end;

procedure TUserChoice.bChangePasswordMouseEnter(Sender: TObject);
begin
  bChangePassword.Font.Color := clHighlight;
  bChangePassword.Font.Style := [fsUnderline];
end;

procedure TUserChoice.bChangePasswordMouseLeave(Sender: TObject);
begin
  bChangePassword.Font.Color := clGrayText;
  bChangePassword.Font.Style := [];
end;

constructor TUserChoice.CreateAndShowOnTaskBar(AOwner: TComponent);
begin
  FShowOnTaskBar := true;
  inherited Create(AOwner);
end;

procedure TUserChoice.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);

  // http://www.transl-gunsmoker.ru/2009/03/windows-vista-delphi-1.html
  // для каждой формы, для которой мы хотим иметь кнопку на панели задач
  // нам нужно переопределить CreateParams
  if FShowOnTaskBar then
    Params.ExStyle := Params.ExStyle and not WS_EX_TOOLWINDOW or WS_EX_APPWINDOW;
end;

procedure TUserChoice.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = 86) and (ssAlt in Shift) then
    bChangePasswordClick(self);
  //ShowMessage(Chr(Key));
end;

procedure TUserChoice.FormShow(Sender: TObject);
begin
  Localize;

  if ComboBox1.Text = '' then
    ActiveControl := ComboBox1
  else
    ActiveControl := Edit1;

  bChangePassword.Enabled := Assigned(OPCSource);

  //Application.BringToFront;
  //SetForegroundWindow(Application.Handle);
end;

procedure TUserChoice.Localize;
begin
  if not Assigned(OPCSource) then
    Exit;

  Caption := Format(OPCSource.GetStringRes(idxAuthorizeDlg_Caption), [OPCSource.OPCName]);

  lUser.Caption := OPCSource.GetStringRes(idxAuthorizeDlg_User);
  lPassword.Caption := OPCSource.GetStringRes(idxAuthorizeDlg_Password);
  bChangePassword.Caption := OPCSource.GetStringRes(idxAuthorizeDlg_ChangePassword);

  CancelBtn.Caption := OPCSource.GetStringRes(idxButton_Cancel);
  OkBtn.Caption := OPCSource.GetStringRes(idxButton_OK);
end;

procedure TUserChoice.SetOPCSource(const Value: TaOPCSource);
begin
  if FOPCSource = Value then
    exit;

  FOPCSource := Value;

  Localize;

//  if Assigned(FOPCSource) then
//    Caption := Format('Авторизация доступа (%s)',
//      [FOPCSource.OPCName])
//  else
//    Caption := 'Авторизация доступа';

end;

procedure TUserChoice.WMSyscommand(var Message: TWmSysCommand);
begin
  // http://www.transl-gunsmoker.ru/2009/03/windows-vista-delphi-1.html
  // для каждой формы, которая имеет кнопку в панели задач и может
  // минимизироваться, нам надо обрабатывать оконное сообщение WM_SYSCOMMAND
  case (Message.CmdType and $FFF0) of
    SC_MINIMIZE:
      begin
        ShowWindow(Handle, SW_MINIMIZE);
        Message.Result := 0;
      end;
    SC_RESTORE:
      begin
        ShowWindow(Handle, SW_RESTORE);
        Message.Result := 0;
      end;
  else
    inherited;
  end;
end;

end.

