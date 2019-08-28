object CinemaPropertyForm: TCinemaPropertyForm
  Left = 302
  Top = 169
  BorderStyle = bsDialog
  Caption = #1055#1072#1088#1072#1084#1077#1090#1088#1099' '#1087#1088#1086#1089#1084#1086#1090#1088#1072
  ClientHeight = 117
  ClientWidth = 267
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox2: TGroupBox
    Left = 8
    Top = 4
    Width = 254
    Height = 77
    Caption = #1055#1088#1086#1080#1075#1088#1099#1074#1072#1077#1085#1080#1077
    TabOrder = 0
    object Label3: TLabel
      Left = 15
      Top = 20
      Width = 151
      Height = 13
      Caption = #1064#1072#1075' '#1074#1099#1073#1086#1088#1082#1080' '#1076#1072#1085#1085#1099#1093' ('#1089#1077#1082#1091#1085#1076')'
    end
    object Label4: TLabel
      Left = 15
      Top = 45
      Width = 172
      Height = 13
      Caption = #1048#1085#1090#1077#1088#1074#1072#1083' '#1086#1078#1080#1076#1072#1085#1080#1103' ('#1084#1080#1083#1080#1089#1077#1082#1091#1085#1076')'
    end
    object edStep: TEdit
      Left = 195
      Top = 15
      Width = 51
      Height = 21
      TabOrder = 0
      Text = '60'
    end
    object edSleepTime: TEdit
      Left = 195
      Top = 40
      Width = 51
      Height = 21
      TabOrder = 1
      Text = '100'
    end
  end
  object bOk: TButton
    Left = 104
    Top = 85
    Width = 75
    Height = 27
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object bCancel: TButton
    Left = 184
    Top = 85
    Width = 75
    Height = 27
    Cancel = True
    Caption = #1054#1090#1084#1077#1085#1072
    ModalResult = 2
    TabOrder = 2
  end
end
