object SetValueForm: TSetValueForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = #1059#1089#1090#1072#1085#1086#1074#1082#1072' '#1085#1086#1074#1086#1075#1086' '#1079#1085#1072#1095#1077#1085#1080#1103
  ClientHeight = 140
  ClientWidth = 251
  Color = clBtnFace
  Constraints.MinHeight = 178
  Constraints.MinWidth = 267
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    251
    140)
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 8
    Top = 103
    Width = 235
    Height = 2
    Anchors = [akLeft, akTop, akRight]
    ExplicitWidth = 246
  end
  inline SetValueFrame: TFrame1
    Left = 0
    Top = -4
    Width = 250
    Height = 104
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
    ExplicitTop = -4
    ExplicitWidth = 260
    inherited eNewValue: TEdit
      Width = 94
      ExplicitWidth = 104
    end
    inherited cbNewValue: TComboBox
      Width = 234
      ExplicitWidth = 244
    end
  end
  object Button1: TButton
    Left = 87
    Top = 111
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
    ExplicitLeft = 97
  end
  object Button2: TButton
    Left = 168
    Top = 111
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Cancel = True
    Caption = #1054#1090#1084#1077#1085#1072
    ModalResult = 2
    TabOrder = 2
    ExplicitLeft = 178
  end
end
