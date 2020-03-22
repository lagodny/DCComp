object DateTimeInputForm: TDateTimeInputForm
  Left = 598
  Top = 115
  BorderStyle = bsDialog
  Caption = #1044#1072#1090#1072' '#1074#1088#1077#1084#1103
  ClientHeight = 139
  ClientWidth = 231
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  PixelsPerInch = 96
  TextHeight = 13
  object lCaption: TLabel
    Left = 14
    Top = 8
    Width = 134
    Height = 13
    Caption = #1059#1082#1072#1078#1080#1090#1077' '#1084#1086#1084#1077#1085#1090' '#1074#1088#1077#1084#1077#1085#1080
  end
  object Bevel1: TBevel
    Left = 17
    Top = 89
    Width = 201
    Height = 2
  end
  object bOk: TButton
    Left = 63
    Top = 104
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 4
  end
  object bCancel: TButton
    Left = 143
    Top = 104
    Width = 75
    Height = 25
    Cancel = True
    Caption = #1054#1090#1084#1077#1085#1072
    ModalResult = 2
    TabOrder = 5
  end
  object dtDate: TDateTimePicker
    Left = 17
    Top = 39
    Width = 106
    Height = 21
    Date = 38051.000000000000000000
    Time = 38051.000000000000000000
    Enabled = False
    TabOrder = 0
  end
  object chTime: TCheckBox
    Left = 130
    Top = 43
    Width = 12
    Height = 17
    TabOrder = 1
    OnClick = chTimeClick
  end
  object tmTime: TDateTimePicker
    Left = 145
    Top = 39
    Width = 73
    Height = 21
    Date = 0.384909768516081400
    Time = 0.384909768516081400
    Enabled = False
    Kind = dtkTime
    TabOrder = 2
  end
  object chNow: TCheckBox
    Left = 17
    Top = 66
    Width = 70
    Height = 17
    Caption = #1089#1077#1081#1095#1072#1089
    TabOrder = 3
    OnClick = chNowClick
  end
  object ApplicationEvents1: TApplicationEvents
    OnMessage = ApplicationEvents1Message
    Left = 176
    Top = 8
  end
end
