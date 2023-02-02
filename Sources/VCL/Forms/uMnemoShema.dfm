object fmMnemoShema: TfmMnemoShema
  Left = 69
  Top = 77
  Width = 731
  Height = 328
  HorzScrollBar.Tracking = True
  VertScrollBar.Tracking = True
  AutoScroll = True
  Caption = #1052#1085#1077#1084#1086#1089#1093#1077#1084#1072
  Color = clWindow
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu
  Position = poDesigned
  PrintScale = poPrintToFit
  ShowHint = True
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object StatusBar: TStatusBar
    Left = 0
    Top = 270
    Width = 715
    Height = 19
    Panels = <
      item
        Text = #1058#1077#1082#1091#1097#1077#1077' '#1089#1086#1089#1090#1086#1103#1085#1080#1077
        Width = 180
      end
      item
        Width = 120
      end
      item
        Width = 200
      end
      item
        Width = 50
      end>
    ExplicitTop = 250
  end
  object aOPCSource: TaOPCTCPSource_V30
    States = llStates
    OnActivate = aOPCSourceActivate
    OnDeactivate = aOPCSourceDeactivate
    OnConnect = aOPCSourceConnect
    OnRequest = aOPCSourceRequest
    OnError = aOPCSourceError
    RemoteMachine = 'localhost'
    MainHost = 'localhost'
    Left = 346
    Top = 15
  end
  object aOPCAuthorization: TaOPCAuthorization
    OPCSource = aOPCSource
    Left = 496
    Top = 15
  end
  object OPCCinema: TaOPCCinema
    OnActivate = OPCCinemaActivate
    OnDeactivate = OPCCinemaDeactivate
    OnChangeMoment = OPCCinemaChangeMoment
    CurrentMoment = 44892.602158020830000000
    UpdateControlsOnChangeMoment = False
    Left = 406
    Top = 15
  end
  object MainMenu: TMainMenu
    Left = 26
    Top = 15
    object mHistory: TMenuItem
      Action = aHistory
    end
    object mPrint: TMenuItem
      Action = aPrint
    end
    object mParams: TMenuItem
      Caption = #1055#1072#1088#1072#1084#1077#1090#1088#1099
      object mSimulateMode: TMenuItem
        Action = aSimulateMode
        AutoCheck = True
      end
      object mScale: TMenuItem
        Action = aScale
      end
    end
    object mAbout: TMenuItem
      Caption = '?'
      object N3: TMenuItem
        Action = aHelp
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object mAboutProgramm: TMenuItem
        Action = aAbout
      end
    end
  end
  object ActionList: TActionList
    OnUpdate = ActionListUpdate
    Left = 80
    Top = 15
    object aHistory: TAction
      Category = #1048#1089#1090#1086#1088#1080#1103
      Caption = #1048#1089#1090#1086#1088#1080#1103
      Hint = #1055#1088#1086#1089#1084#1086#1090#1088#1077#1090#1100' '#1084#1085#1077#1084#1086#1089#1093#1077#1084#1091' '#1074' '#1079#1072#1087#1080#1089#1080
      ShortCut = 16456
      OnExecute = aHistoryExecute
    end
    object aPrint: TAction
      Category = #1055#1077#1095#1072#1090#1100
      Caption = #1055#1077#1095#1072#1090#1100
      Hint = #1056#1072#1089#1087#1077#1095#1072#1090#1072#1090#1100
      ShortCut = 16464
      OnExecute = aPrintExecute
    end
    object aScale: TAction
      Category = #1052#1072#1089#1096#1090#1072#1073
      Caption = #1052#1072#1089#1096#1090#1072#1073
      ShortCut = 16461
      OnExecute = aScaleExecute
    end
    object aSimulateMode: TAction
      AutoCheck = True
      Caption = #1056#1077#1078#1080#1084' '#1080#1084#1080#1090#1072#1094#1080#1080
      OnExecute = aSimulateModeExecute
    end
    object aAbout: TAction
      Caption = #1054' '#1087#1088#1086#1075#1088#1072#1084#1084#1077
      OnExecute = aAboutExecute
    end
    object HelpContents1: THelpContents
      Category = #1057#1087#1088#1072#1074#1082#1072
      Caption = #1057#1087#1088#1072#1074#1082#1072
      Enabled = False
      Hint = #1057#1087#1088#1072#1074#1082#1072
      ImageIndex = 40
      ShortCut = 112
      Visible = False
    end
    object aHelp: TAction
      Category = #1057#1087#1088#1072#1074#1082#1072
      Caption = #1057#1087#1088#1072#1074#1082#1072
      Hint = #1057#1087#1088#1072#1074#1082#1072
      ImageIndex = 40
      OnExecute = aHelpExecute
    end
  end
  object Timer1: TTimer
    Enabled = False
    OnTimer = Timer1Timer
    Left = 26
    Top = 69
  end
  object PrintDialog1: TPrintDialog
    Left = 161
    Top = 69
  end
  object ApplicationEvents1: TApplicationEvents
    OnHint = ApplicationEvents1Hint
    Left = 160
    Top = 16
  end
  object llStates: TaOPCLookupList
    TableName = 'States'
    OPCSource = aOPCSource
    Left = 408
    Top = 64
  end
  object VerUpdater: TaOPCVerUpdater
    Left = 408
    Top = 120
  end
end
