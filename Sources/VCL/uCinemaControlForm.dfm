object CinemaControlForm: TCinemaControlForm
  Left = 207
  Top = 123
  AlphaBlend = True
  BorderStyle = bsToolWindow
  Caption = #1055#1091#1083#1100#1090' '#1091#1087#1088#1072#1074#1083#1077#1085#1080#1103
  ClientHeight = 68
  ClientWidth = 339
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  Position = poScreenCenter
  ShowHint = True
  OnClose = FormClose
  OnMouseWheelDown = FormMouseWheelDown
  OnMouseWheelUp = FormMouseWheelUp
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object aOPCCinemaControl1: TaOPCCinemaControl
    Left = 0
    Top = 0
    Width = 339
    Height = 68
    Align = alClient
    TabOrder = 0
    TabStop = True
    StepMode = smNextMoment
  end
end
