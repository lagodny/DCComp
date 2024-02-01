object ChoiceProductForm: TChoiceProductForm
  Left = 345
  Top = 202
  BorderStyle = bsDialog
  Caption = #1059#1089#1090#1072#1085#1086#1074#1080#1090#1100' '#1087#1088#1086#1076#1091#1082#1090
  ClientHeight = 270
  ClientWidth = 252
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  DesignSize = (
    252
    270)
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 4
    Top = 188
    Width = 245
    Height = 49
    Shape = bsFrame
  end
  object ListBox1: TListBox
    Left = 0
    Top = 0
    Width = 252
    Height = 185
    Align = alTop
    ItemHeight = 13
    TabOrder = 0
    OnDblClick = ListBox1DblClick
  end
  object Button1: TButton
    Left = 96
    Top = 241
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #1054#1050
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object Button2: TButton
    Left = 172
    Top = 241
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = #1054#1090#1084#1077#1085#1072
    ModalResult = 2
    TabOrder = 2
  end
  object rbNow: TRadioButton
    Left = 12
    Top = 192
    Width = 73
    Height = 17
    Caption = #1085#1072' '#1089#1077#1081#1095#1072#1089
    Checked = True
    TabOrder = 3
    TabStop = True
    OnClick = rbDateClick
  end
  object rbDate: TRadioButton
    Left = 12
    Top = 212
    Width = 65
    Height = 17
    Caption = #1085#1072' '#1076#1072#1090#1091
    TabOrder = 4
    OnClick = rbDateClick
  end
  object dtpDate: TDateTimePicker
    Left = 84
    Top = 208
    Width = 81
    Height = 21
    Date = 37944.000000000000000000
    Time = 37944.000000000000000000
    Enabled = False
    TabOrder = 5
  end
  object dtpTime: TDateTimePicker
    Left = 168
    Top = 208
    Width = 73
    Height = 21
    Date = 0.425506840278103500
    Time = 0.425506840278103500
    Enabled = False
    Kind = dtkTime
    TabOrder = 6
  end
end
