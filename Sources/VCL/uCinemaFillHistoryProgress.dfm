object FillHistoryProgress: TFillHistoryProgress
  Left = 259
  Top = 190
  BorderIcons = [biMinimize, biMaximize]
  BorderStyle = bsToolWindow
  Caption = #1047#1072#1075#1088#1091#1079#1082#1072'...'
  ClientHeight = 71
  ClientWidth = 258
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnActivate = FormActivate
  PixelsPerInch = 96
  TextHeight = 13
  object ProgressBar1: TProgressBar
    Left = 5
    Top = 15
    Width = 249
    Height = 17
    TabOrder = 0
  end
  object bCancel: TButton
    Left = 85
    Top = 40
    Width = 75
    Height = 25
    Cancel = True
    Caption = #1054#1090#1084#1077#1085#1072
    ModalResult = 2
    TabOrder = 1
    OnClick = bCancelClick
  end
end
