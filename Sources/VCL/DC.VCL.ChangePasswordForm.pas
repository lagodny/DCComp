unit DC.VCL.ChangePasswordForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Mask,
  aOPCSource;

type
  TfChangePassword = class(TForm)
    bOk: TButton;
    bCancel: TButton;
    lUser: TLabel;
    lOldPassword: TLabel;
    lNewPassword: TLabel;
    lConfirmation: TLabel;
    eUser: TEdit;
    eNewPassword: TMaskEdit;
    eConfirmation: TMaskEdit;
    eOldPassword: TMaskEdit;
    procedure FormShow(Sender: TObject);
    procedure bOkClick(Sender: TObject);
  private
    FOPCSource: TaOPCSource;
    procedure SetOPCSource(const Value: TaOPCSource);
    { Private declarations }
  public
    property OPCSource: TaOPCSource read FOPCSource write SetOPCSource;
  end;

var
  fChangePassword: TfChangePassword;

implementation

uses
  DC.Resources;

{$R *.dfm}

procedure TfChangePassword.FormShow(Sender: TObject);
begin
  if eUser.Text <> '' then
    ActiveControl := eOldPassword;
end;

//procedure TfChangePassword.Localize;
//begin
//  if not Assigned(OPCSource) then
//    Exit;
//
////  Caption := Format(OPCSource.GetStringRes(idxChangePasswordDlg_Caption), [OPCSource.OPCName]);
//
////  lUser.Caption := OPCSource.GetStringRes(idxChangePasswordDlg_User);
////  lOldPassword.Caption := OPCSource.GetStringRes(idxChangePasswordDlg_OldPassword);
////  lNewPassword.Caption := OPCSource.GetStringRes(idxChangePasswordDlg_NewPassword);
////  lConfirmation.Caption := OPCSource.GetStringRes(idxChangePasswordDlg_Confirmation);
//
////  bOk.Caption := OPCSource.GetStringRes(idxButton_OK);
////  bCancel.Caption := OPCSource.GetStringRes(idxButton_Cancel);
//end;

procedure TfChangePassword.bOkClick(Sender: TObject);
begin
  if eNewPassword.Text <> eConfirmation.Text then
  begin
    ShowMessage(sPasswordNotSame);
    ActiveControl := eNewPassword;
  end
  else
    ModalResult := mrOk;
end;

procedure TfChangePassword.SetOPCSource(const Value: TaOPCSource);
begin
  if FOPCSource = Value then
    exit;

  FOPCSource := Value;
end;

end.
