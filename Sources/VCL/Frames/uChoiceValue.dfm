object ChoiceValue: TChoiceValue
  Left = 485
  Top = 231
  BorderIcons = [biSystemMenu]
  Caption = #1059#1089#1090#1072#1085#1086#1074#1080#1090#1100' '#1085#1086#1074#1086#1077' '#1079#1085#1072#1095#1077#1085#1080#1077
  ClientHeight = 134
  ClientWidth = 262
  Color = clBtnFace
  Constraints.MaxHeight = 180
  Constraints.MaxWidth = 500
  Constraints.MinHeight = 173
  Constraints.MinWidth = 278
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Microsoft Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = FormShow
  DesignSize = (
    262
    134)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 12
    Top = 24
    Width = 125
    Height = 13
    Caption = #1042#1074#1077#1076#1080#1090#1077' '#1085#1086#1074#1086#1077' '#1079#1085#1072#1095#1077#1085#1080#1077
  end
  object bbOK: TBitBtn
    Left = 54
    Top = 104
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 6
    NumGlyphs = 2
  end
  object bbCancel: TBitBtn
    Left = 138
    Top = 104
    Width = 75
    Height = 25
    Cancel = True
    Caption = #1054#1090#1084#1077#1085#1072
    ModalResult = 2
    TabOrder = 7
    NumGlyphs = 2
  end
  object Edit: TEdit
    Left = 148
    Top = 18
    Width = 101
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
    Text = 'Edit'
    OnChange = EditChange
  end
  object ComboBox: TComboBox
    Left = 8
    Top = 44
    Width = 241
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    ItemHeight = 13
    TabOrder = 1
    OnChange = ComboBoxChange
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
  object dt: TDateTimePicker
    Left = 50
    Top = 71
    Width = 106
    Height = 21
    Date = 38051.000000000000000000
    Time = 38051.000000000000000000
    Enabled = False
    TabOrder = 3
  end
  object tm: TDateTimePicker
    Left = 180
    Top = 71
    Width = 69
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    Date = 0.384909768516081400
    Time = 0.384909768516081400
    Enabled = False
    Kind = dtkTime
    TabOrder = 5
  end
  object cbTime: TCheckBox
    Left = 162
    Top = 75
    Width = 12
    Height = 17
    TabOrder = 4
    OnClick = cbTimeClick
  end
end
