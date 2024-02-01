object OPCIntervalFrame: TOPCIntervalFrame
  Left = 0
  Top = 0
  Width = 249
  Height = 166
  TabOrder = 0
  PixelsPerInch = 96
  object gbInterval: TGroupBox
    Left = 5
    Top = 91
    Width = 240
    Height = 73
    Caption = #1055#1077#1088#1080#1086#1076
    Enabled = False
    TabOrder = 9
    object lFrom: TLabel
      Left = 5
      Top = 25
      Width = 8
      Height = 15
      Caption = #1057
    end
    object lTo: TLabel
      Left = 5
      Top = 46
      Width = 14
      Height = 15
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
      OnChange = dtFromChange
    end
    object tmFrom: TDateTimePicker
      Left = 158
      Top = 20
      Width = 73
      Height = 21
      Date = 45296.000000000000000000
      Time = 0.384909768516081400
      Enabled = False
      Kind = dtkTime
      TabOrder = 2
      OnChange = dtFromChange
    end
    object dtTo: TDateTimePicker
      Left = 30
      Top = 43
      Width = 106
      Height = 21
      Date = 38416.000000000000000000
      Time = 38416.000000000000000000
      Enabled = False
      TabOrder = 3
      OnChange = dtFromChange
    end
    object tmTo: TDateTimePicker
      Left = 158
      Top = 43
      Width = 73
      Height = 21
      Date = 45296.000000000000000000
      Time = 0.387262696756806700
      Enabled = False
      Kind = dtkTime
      TabOrder = 5
      OnChange = dtFromChange
    end
    object cbTimeFrom: TCheckBox
      Left = 143
      Top = 24
      Width = 12
      Height = 17
      TabOrder = 1
      OnClick = cbTimeFromClick
    end
    object cbTimeTo: TCheckBox
      Left = 143
      Top = 45
      Width = 12
      Height = 17
      TabOrder = 4
      OnClick = cbTimeToClick
    end
  end
  object rbLastTime: TRadioButton
    Left = 5
    Top = 5
    Width = 231
    Height = 17
    Caption = #1079#1072' '#1087#1086#1089'&'#1083#1077#1076#1085#1080#1077
    Checked = True
    TabOrder = 0
    TabStop = True
    OnClick = rbLastTimeClick
    OnMouseUp = rbLastTimeMouseUp
  end
  object rbInterval: TRadioButton
    Left = 5
    Top = 74
    Width = 231
    Height = 17
    Caption = #1079#1072' &'#1087#1077#1088#1080#1086#1076
    TabOrder = 3
    OnClick = rbIntervalClick
    OnMouseUp = rbIntervalMouseUp
  end
  object eHours: TEdit
    Left = 103
    Top = 3
    Width = 58
    Height = 21
    TabOrder = 4
    Text = '12'
    OnKeyPress = eHoursKeyPress
  end
  object cbPeriod: TComboBox
    Left = 103
    Top = 72
    Width = 133
    Height = 23
    Style = csDropDownList
    Enabled = False
    TabOrder = 8
    OnChange = cbPeriodChange
    Items.Strings = (
      '...'
      #1089#1077#1075#1086#1076#1085#1103
      #1074#1095#1077#1088#1072
      #1089' '#1085#1072#1095#1072#1083#1072' '#1085#1077#1076#1077#1083#1080
      #1087#1088#1086#1096#1083#1072#1103' '#1085#1077#1076#1077#1083#1103
      #1089' '#1085#1072#1095#1072#1083#1072' '#1084#1077#1089#1103#1094#1072
      #1087#1088#1086#1096#1083#1099#1081' '#1084#1077#1089#1103#1094
      #1079#1072#1074#1090#1088#1072
      #1089#1083#1077#1076#1091#1102#1097#1072#1103' '#1085#1077#1076#1077#1083#1103
      #1089#1083#1077#1076#1091#1102#1097#1080#1077' 12 '#1095#1072#1089#1086#1074
      #1089#1083#1077#1076#1091#1102#1097#1080#1077' 24 '#1095#1072#1089#1072)
  end
  object cbHourDay: TComboBox
    Left = 167
    Top = 3
    Width = 69
    Height = 23
    Style = csDropDownList
    ItemIndex = 0
    TabOrder = 5
    Text = #1095#1072#1089#1086#1074
    Items.Strings = (
      #1095#1072#1089#1086#1074
      #1076#1085#1077#1081)
  end
  object rbDay: TRadioButton
    Left = 5
    Top = 28
    Width = 231
    Height = 17
    Caption = #1079#1072' &'#1076#1077#1085#1100
    TabOrder = 1
    OnClick = rbDayClick
    OnMouseUp = rbDayMouseUp
  end
  object dtpDay: TDateTimePicker
    Left = 103
    Top = 26
    Width = 133
    Height = 21
    Date = 38051.000000000000000000
    Time = 38051.000000000000000000
    Enabled = False
    TabOrder = 6
  end
  object rbMonth: TRadioButton
    Left = 5
    Top = 51
    Width = 231
    Height = 17
    Caption = #1079#1072' &'#1084#1077#1089#1103#1094
    TabOrder = 2
    OnClick = rbMonthClick
    OnMouseUp = rbMonthMouseUp
  end
  object dtpMonth: TDateTimePicker
    Left = 103
    Top = 49
    Width = 133
    Height = 21
    Date = 38051.000000000000000000
    Format = 'MMMM yyyy'
    Time = 38051.000000000000000000
    Enabled = False
    TabOrder = 7
    OnCloseUp = dtpMonthCloseUp
  end
  object ApplicationEvents1: TApplicationEvents
    OnMessage = ApplicationEvents1Message
    Left = 72
    Top = 16
  end
end
