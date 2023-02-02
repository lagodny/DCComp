unit DC.VCL.PasswordForm;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, Dialogs, Messages,
  aOPCSource, aOPCAuthorization;

type
  TPasswordForm = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    lUser: TLabel;
    lPassword: TLabel;
    cbUser: TComboBox;
    ePassword: TEdit;
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
    property OPCSource: TaOPCSource read FOPCSource write SetOPCSource;

    class function Execute(aAuth: TaOPCAuthorization): Boolean;

  end;


implementation

uses
  aOPCConnectionList,
  DC.Resources, DC.VCL.ChangePasswordForm;

{$R *.dfm}

procedure TPasswordForm.bChangePasswordClick(Sender: TObject);
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
      eUser.Text := Self.cbUser.Text;
      eOldPassword.Text := Self.ePassword.Text;
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

          ShowMessage(sPasswordChangedSuccessfuly);
          ePassword.Text := eNewPassword.Text;
          ePassword.SelectAll;
          PostMessage(Self.OKBtn.Handle, CM_ACTIVATE, 0, 0);
        except
          on e: Exception do
          begin
            if Assigned(aConnection) then
              aConnName := aConnection.DisplayName
            else
              aConnName := '';

            MessageDlg(Format(sUnableChangePasswordFmt,  [aConnName]), mtError, [mbOK], 0);
          end;
        end;
      end;
    end;
  end;
end;

procedure TPasswordForm.bChangePasswordMouseEnter(Sender: TObject);
begin
  bChangePassword.Font.Color := clHighlight;
  bChangePassword.Font.Style := [fsUnderline];
end;

procedure TPasswordForm.bChangePasswordMouseLeave(Sender: TObject);
begin
  bChangePassword.Font.Color := clGrayText;
  bChangePassword.Font.Style := [];
end;

constructor TPasswordForm.CreateAndShowOnTaskBar(AOwner: TComponent);
begin
  FShowOnTaskBar := true;
  inherited Create(AOwner);
end;

procedure TPasswordForm.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);

  // http://www.transl-gunsmoker.ru/2009/03/windows-vista-delphi-1.html
  // для каждой формы, для которой мы хотим иметь кнопку на панели задач
  // нам нужно переопределить CreateParams
  if FShowOnTaskBar then
    Params.ExStyle := Params.ExStyle and not WS_EX_TOOLWINDOW or WS_EX_APPWINDOW;
end;

class function TPasswordForm.Execute(aAuth: TaOPCAuthorization): Boolean;
var
  f: TPasswordForm;
  User, Password: string;
begin
  Result := False;

  f := TPasswordForm.CreateAndShowOnTaskBar(nil);
  try
    User := aAuth.User;
    f.OPCSource := aAuth.OPCSource;
    f.cbUser.Items.Text := f.OPCSource.GetUsers;
    f.cbUser.ItemIndex := f.cbUser.Items.IndexOf(User);
    if f.ShowModal = mrOk then
    begin
      try
        User := f.cbUser.Text;
        Password := f.ePassword.Text;
        Result := f.OPCSource.Login(User, Password);
        if not Result then
          MessageDlg(
            Format('У пользователя %s недостаточно прав для работы с системой!', [User]),
            TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0)
        else
        begin
          aAuth.User := User;
          aAuth.Password := Password;
        end;
      except
        on e: Exception do
          MessageDlg(e.Message, TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);
      end;
    end;
  finally
    f.Free;
  end;
end;

procedure TPasswordForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = 86) and (ssAlt in Shift) then
    bChangePasswordClick(self);
  //ShowMessage(Chr(Key));
end;

procedure TPasswordForm.FormShow(Sender: TObject);
begin
  if cbUser.Text = '' then
    ActiveControl := cbUser
  else
    ActiveControl := ePassword;

  bChangePassword.Enabled := Assigned(OPCSource);

  //Application.BringToFront;
  //SetForegroundWindow(Application.Handle);
end;

procedure TPasswordForm.SetOPCSource(const Value: TaOPCSource);
begin
  FOPCSource := Value;
end;

procedure TPasswordForm.WMSyscommand(var Message: TWmSysCommand);
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

