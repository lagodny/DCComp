object UserMessageForm: TUserMessageForm
  Left = 0
  Top = 0
  Caption = #1054#1082#1085#1086' '#1089#1086#1086#1073#1097#1077#1085#1080#1081
  ClientHeight = 276
  ClientWidth = 441
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyPress = FormKeyPress
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 0
    Top = 175
    Width = 441
    Height = 3
    Cursor = crVSplit
    Align = alBottom
    ExplicitTop = 145
    ExplicitWidth = 159
  end
  object pIn: TPanel
    Left = 0
    Top = 0
    Width = 441
    Height = 175
    Align = alClient
    TabOrder = 1
    DesignSize = (
      441
      175)
    object Label1: TLabel
      Left = 8
      Top = 8
      Width = 76
      Height = 13
      Caption = #1055#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1100':'
    end
    object Label2: TLabel
      Left = 8
      Top = 24
      Width = 62
      Height = 13
      Caption = #1050#1086#1084#1087#1100#1102#1090#1077#1088':'
    end
    object lUser: TLabel
      Left = 112
      Top = 8
      Width = 24
      Height = 13
      Anchors = [akLeft, akTop, akRight]
      Caption = 'lUser'
    end
    object lHost: TLabel
      Left = 112
      Top = 24
      Width = 24
      Height = 13
      Anchors = [akLeft, akTop, akRight]
      Caption = 'lHost'
    end
    object Label3: TLabel
      Left = 8
      Top = 56
      Width = 62
      Height = 13
      Caption = #1057#1086#1086#1073#1097#1077#1085#1080#1077':'
    end
    object Bevel1: TBevel
      Left = 8
      Top = 43
      Width = 425
      Height = 2
      Anchors = [akLeft, akTop, akRight]
      ExplicitWidth = 367
    end
    object mMessage: TMemo
      Left = 8
      Top = 72
      Width = 425
      Height = 95
      Anchors = [akLeft, akTop, akRight, akBottom]
      Lines.Strings = (
        'mMessage')
      ReadOnly = True
      ScrollBars = ssBoth
      TabOrder = 0
    end
  end
  object pOut: TPanel
    Left = 0
    Top = 178
    Width = 441
    Height = 98
    Align = alBottom
    TabOrder = 0
    DesignSize = (
      441
      98)
    object mAnswer: TMemo
      Left = 8
      Top = 6
      Width = 354
      Height = 83
      Anchors = [akLeft, akTop, akRight, akBottom]
      Lines.Strings = (
        'mAnswer')
      ScrollBars = ssBoth
      TabOrder = 0
      OnChange = mAnswerChange
    end
    object bAnswer: TButton
      Left = 367
      Top = 6
      Width = 65
      Height = 83
      Anchors = [akTop, akRight, akBottom]
      Caption = #1054#1090#1074#1077#1090#1080#1090#1100
      Default = True
      TabOrder = 1
      OnClick = bAnswerClick
    end
  end
end
