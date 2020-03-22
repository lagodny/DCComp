object ChoiceIntervalExt: TChoiceIntervalExt
  Left = 697
  Top = 149
  BorderStyle = bsDialog
  Caption = #1059#1082#1072#1078#1080#1090#1077' '#1087#1077#1088#1080#1086#1076
  ClientHeight = 187
  ClientWidth = 252
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label3: TLabel
    Left = 207
    Top = 17
    Width = 29
    Height = 13
    Caption = #1095#1072#1089#1086#1074
  end
  object gbInterval: TGroupBox
    Left = 8
    Top = 67
    Width = 240
    Height = 81
    Caption = #1055#1077#1088#1080#1086#1076
    Enabled = False
    TabOrder = 3
    object Label1: TLabel
      Left = 5
      Top = 25
      Width = 7
      Height = 13
      Caption = #1057
    end
    object Label2: TLabel
      Left = 5
      Top = 50
      Width = 12
      Height = 13
      Caption = #1087#1086
    end
    object dtFrom: TDateTimePicker
      Left = 30
      Top = 20
      Width = 106
      Height = 21
      Date = 38051.000000000000000000
      Time = 38051.000000000000000000
      Enabled = False
      TabOrder = 0
      OnChange = tmFromChange
    end
    object tmFrom: TDateTimePicker
      Left = 145
      Top = 20
      Width = 86
      Height = 21
      Date = 0.384909768516081400
      Time = 0.384909768516081400
      ShowCheckbox = True
      Enabled = False
      Kind = dtkTime
      TabOrder = 1
      OnChange = tmFromChange
    end
    object dtTo: TDateTimePicker
      Left = 30
      Top = 45
      Width = 106
      Height = 21
      Date = 38416.000000000000000000
      Time = 38416.000000000000000000
      Enabled = False
      TabOrder = 2
      OnChange = tmFromChange
    end
    object tmTo: TDateTimePicker
      Left = 145
      Top = 45
      Width = 86
      Height = 21
      Date = 0.387262696756806700
      Time = 0.387262696756806700
      ShowCheckbox = True
      Enabled = False
      Kind = dtkTime
      TabOrder = 3
      OnChange = tmFromChange
    end
  end
  object bOk: TButton
    Left = 78
    Top = 154
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 4
  end
  object bCancel: TButton
    Left = 159
    Top = 154
    Width = 75
    Height = 25
    Cancel = True
    Caption = #1054#1090#1084#1077#1085#1072
    ModalResult = 2
    TabOrder = 5
  end
  object rbLastTime: TRadioButton
    Left = 13
    Top = 16
    Width = 92
    Height = 17
    Caption = #1079#1072' '#1087#1086#1089#1083#1077#1076#1085#1080#1077
    Checked = True
    TabOrder = 0
    TabStop = True
    OnClick = rbIntervalClick
    OnKeyPress = rbLastTimeKeyPress
  end
  object rbInterval: TRadioButton
    Left = 13
    Top = 41
    Width = 92
    Height = 17
    Caption = #1079#1072' '#1087#1077#1088#1080#1086#1076
    TabOrder = 1
    OnClick = rbIntervalClick
  end
  object eHours: TEdit
    Left = 145
    Top = 14
    Width = 56
    Height = 21
    TabOrder = 2
    Text = '12'
    OnKeyPress = eHoursKeyPress
  end
  object cbPeriod: TComboBox
    Left = 111
    Top = 39
    Width = 133
    Height = 21
    Style = csDropDownList
    ItemIndex = 0
    TabOrder = 6
    Text = '...'
    OnChange = cbPeriodChange
    Items.Strings = (
      '...'
      #1089#1077#1075#1086#1076#1085#1103
      #1074#1095#1077#1088#1072
      #1089' '#1085#1072#1095#1072#1083#1072' '#1085#1077#1076#1077#1083#1080
      #1087#1088#1086#1096#1083#1072#1103' '#1085#1077#1076#1077#1083#1103
      #1089' '#1085#1072#1095#1072#1083#1072' '#1084#1077#1089#1103#1094#1072
      #1087#1088#1086#1096#1083#1099#1081' '#1084#1077#1089#1103#1094)
  end
end
