object fChangePassword: TfChangePassword
  Left = 0
  Top = 0
  BorderIcons = [biMinimize, biMaximize]
  BorderStyle = bsDialog
  Caption = #1057#1084#1077#1085#1072' '#1087#1072#1088#1086#1083#1103
  ClientHeight = 163
  ClientWidth = 337
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poDesktopCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object lUser: TLabel
    Left = 16
    Top = 16
    Width = 76
    Height = 13
    Caption = #1055#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1100':'
  end
  object lOldPassword: TLabel
    Left = 16
    Top = 43
    Width = 82
    Height = 13
    Caption = #1057#1090#1072#1088#1099#1081' '#1087#1072#1088#1086#1083#1100':'
  end
  object lNewPassword: TLabel
    Left = 16
    Top = 70
    Width = 76
    Height = 13
    Caption = #1053#1086#1074#1099#1081' '#1087#1072#1088#1086#1083#1100':'
  end
  object lConfirmation: TLabel
    Left = 16
    Top = 97
    Width = 87
    Height = 13
    Caption = #1055#1086#1076#1090#1074#1077#1088#1078#1076#1077#1085#1080#1077':'
  end
  object bOk: TButton
    Left = 171
    Top = 127
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    TabOrder = 4
    OnClick = bOkClick
  end
  object bCancel: TButton
    Left = 251
    Top = 127
    Width = 75
    Height = 25
    Cancel = True
    Caption = #1054#1090#1084#1077#1085#1072
    ModalResult = 2
    TabOrder = 5
  end
  object eUser: TEdit
    Left = 117
    Top = 13
    Width = 209
    Height = 21
    TabOrder = 0
    Text = 'eUser'
  end
  object eNewPassword: TMaskEdit
    Left = 117
    Top = 67
    Width = 209
    Height = 21
    PasswordChar = '*'
    TabOrder = 2
    Text = ''
  end
  object eConfirmation: TMaskEdit
    Left = 117
    Top = 94
    Width = 209
    Height = 21
    PasswordChar = '*'
    TabOrder = 3
    Text = ''
  end
  object eOldPassword: TMaskEdit
    Left = 117
    Top = 40
    Width = 209
    Height = 21
    PasswordChar = '*'
    TabOrder = 1
    Text = ''
  end
end
