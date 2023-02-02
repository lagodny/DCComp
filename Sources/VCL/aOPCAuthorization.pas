unit aOPCAuthorization;

interface

uses
  System.Classes,
  aOPCSource;

const
  EncryptKey = 77;

type
  TaOPCAuthorization = class(TComponent)
  private
    FUser: string;
    FPermissions: string;
    FOPCSource: TaOPCSource;
    FPassword: string;
    procedure SetUser(const Value: string);
    procedure SetPermissions(const Value: string);
    procedure SetOPCSource(const Value: TaOPCSource);
    procedure SetPassword(const Value: string);
    function GetEncryptedPassword: string;
    procedure SetEncryptedPassword(const Value: string);

    function Encrypt(Value: string): string;
  protected
    FTimeStamp: TDateTime;

    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    property Permissions: string read FPermissions write SetPermissions;
    property EncryptedPassword: string read GetEncryptedPassword write SetEncryptedPassword;

//    function Execute(aParent: TCustomForm = nil; aShowInTaskBar: boolean = false): boolean;

    function CheckPermissions: boolean;
    function Login: boolean;

    procedure ReadCommandLine;
    procedure ReadCommandLineExt;

    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
  published
    property OPCSource: TaOPCSource read FOPCSource write SetOPCSource;
    property User: string read FUser write SetUser;
    property Password: string read FPassword write SetPassword;
  end;


implementation

uses
  System.UITypes, System.SysUtils;
//  DC.VCL.PasswordForm,
//  DC.VCL.ChangePasswordForm;

{ TaOPCAuthorization }

function TaOPCAuthorization.CheckPermissions: boolean;
begin
  Result := false;
  try
    Permissions := '';
    if User <> '' then
      Permissions := OPCSource.GetUserPermission(User, Password, '');
    Result := Permissions <> '';

//    Result := OPCSource.Login(User, Password);

  except
    on e: Exception do
      ;
  end;
end;

constructor TaOPCAuthorization.Create(aOwner: TComponent);
begin
  inherited;

end;

destructor TaOPCAuthorization.Destroy;
begin

  inherited;
end;

function TaOPCAuthorization.Encrypt(Value: string): string;
var
  i: integer;
begin
  Result := Value;
  for i := 1 to Length(Result) do
    Result[i] := Chr(Ord(Result[i]) xor ((i + EncryptKey) mod 255));
end;

//function TaOPCAuthorization.Execute(aParent: TCustomForm; aShowInTaskBar: boolean): boolean;
//var
//  //s: string;
//  i: integer;
//  UserChoice: TUserChoice;
//begin
//  Result := False;
//
//  UserChoice := TUserChoice.Create(Application);
//  try
//    UserChoice.OPCSource := OPCSource;
//    UserChoice.cbUser.Items.Text := OPCSource.GetUsers;
//    UserChoice.cbUser.ItemIndex := UserChoice.cbUser.Items.IndexOf(User);
//
////    while not Result do
////    begin
//      UserChoice.ePassword.Text := '';
//
////      UserChoice.ShowModal(
////        procedure (ModalResult: TModalResult)
////        begin
////          if ModalResult = mrOK then
////            ShowMessage('OK')
////          else
////            ShowMessage('Cancel');
////          UserChoice.DisposeOf;
////        end
////      )
//
//      UserChoice.ShowModal(
//        procedure (ModalResult: TModalResult)
//        begin
//          if ModalResult = mrOk then
//          begin
//            try
//              User := UserChoice.cbUser.Selected.Text;
//              Password := UserChoice.ePassword.Text;
//              //Result :=
//              OPCSource.Login(User, Password);
////              if not Result then
////                MessageDlg(
////                  Format('У пользователя %s недостаточно прав для работы с системой!', [User]),
////                  TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);
//            except
//              on e: Exception do
//                MessageDlg(e.Message, TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);
//            end;
//          end
//          else
//          begin
//            Permissions := '';
//            //Break;
//          end;
//
//          //UserChoice.DisposeOf;
//
//        end
//        );
//
////      if UserChoice.ShowModal = mrOk then
////      begin
////        try
////          User := UserChoice.cbUser.Selected.Text;
////          Password := UserChoice.ePassword.Text;
////          Result := OPCSource.Login(User, Password);
////          if not Result then
////            MessageDlg(
////              Format('У пользователя %s недостаточно прав для работы с системой!', [User]),
////              TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);
////        except
////          on e: Exception do
////            MessageDlg(e.Message, TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);
////        end;
////      end
////      else
////      begin
////        Permissions := '';
////        break;
////      end;
////    end;
//  finally
//    //UserChoice.Free;
//  end;
//
//end;

function TaOPCAuthorization.GetEncryptedPassword: string;
begin
  Result := Encrypt(Password);
end;

function TaOPCAuthorization.Login: boolean;
begin
  Result := false;
  try
    Result := OPCSource.Login(User, Password);
  except
    on e: Exception do ;
  end;
end;

procedure TaOPCAuthorization.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FOPCSource) then
    FOPCSource := nil;
end;

procedure TaOPCAuthorization.ReadCommandLine;
var
  i: integer;
  ch: string;
begin
  for i := 0 to ParamCount do
  begin
    ch := copy(LowerCase(ParamStr(i)), 1, 2);
    if ch = '-u' then
      User := Copy(ParamStr(i), 3, length(ParamStr(i)))
    else if ch = '-p' then
      Password := Copy(ParamStr(i), 3, length(ParamStr(i)));
  end;
end;

procedure TaOPCAuthorization.ReadCommandLineExt;
var
  s: TStringList;
  i: Integer;
begin
  s := TStringList.Create;
  try
    for i := 1 to ParamCount do
      s.Add(UpperCase(ParamStr(i)));

    // имя пользователя
    if s.Values['USER'] <> '' then
      User := s.Values['USER']
    else if s.Values['U'] <> '' then
      User := s.Values['U'];

    // пароль
    if s.Values['PASSWORD'] <> '' then
      Password := s.Values['PASSWORD']
    else if s.Values['P'] <> '' then
      Password := s.Values['P'];
  finally
    s.Free;
  end;

end;

procedure TaOPCAuthorization.SetEncryptedPassword(const Value: string);
begin
  Password := Encrypt(Value);
end;

procedure TaOPCAuthorization.SetOPCSource(const Value: TaOPCSource);
begin
  FOPCSource := Value;
  if Value <> nil then
    Value.FreeNotification(Self);
end;

procedure TaOPCAuthorization.SetPassword(const Value: string);
begin
  FPassword := Value;
  if FOPCSource <> nil then
    FOPCSource.Password := Value;
end;

procedure TaOPCAuthorization.SetPermissions(const Value: string);
begin
  FPermissions := Value;
end;

procedure TaOPCAuthorization.SetUser(const Value: string);
begin
  FUser := Value;
  if FOPCSource <> nil then
    FOPCSource.User := Value;
end;

end.
