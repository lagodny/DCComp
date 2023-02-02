object Frame1: TFrame1
  Left = 0
  Top = 0
  Width = 261
  Height = 104
  TabOrder = 0
  DesignSize = (
    261
    104)
  object Label1: TLabel
    Left = 12
    Top = 24
    Width = 126
    Height = 13
    Caption = #1042#1074#1077#1076#1080#1090#1077' '#1085#1086#1074#1086#1077' '#1079#1085#1072#1095#1077#1085#1080#1077
  end
  object eNewValue: TEdit
    Left = 148
    Top = 18
    Width = 105
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
    OnChange = eNewValueChange
  end
  object cbNewValue: TComboBox
    Left = 8
    Top = 44
    Width = 245
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    ItemHeight = 13
    TabOrder = 1
    OnChange = cbNewValueChange
  end
  object cbUseDate: TCheckBox
    Left = 12
    Top = 75
    Width = 36
    Height = 17
    Caption = #1085#1072
    TabOrder = 2
    OnClick = cbUseDateClick
  end
  object dtDate: TDateTimePicker
    Left = 54
    Top = 71
    Width = 106
    Height = 21
    Date = 38051.000000000000000000
    Time = 38051.000000000000000000
    Enabled = False
    TabOrder = 3
  end
  object cbTime: TCheckBox
    Left = 167
    Top = 75
    Width = 12
    Height = 17
    TabOrder = 4
    OnClick = cbTimeClick
  end
  object tmTime: TDateTimePicker
    Left = 182
    Top = 71
    Width = 73
    Height = 21
    Date = 0.384909768516081400
    Time = 0.384909768516081400
    Enabled = False
    Kind = dtkTime
    TabOrder = 5
  end
  object ApplicationEvents1: TApplicationEvents
    OnMessage = ApplicationEvents1Message
    Left = 96
    Top = 8
  end
end
