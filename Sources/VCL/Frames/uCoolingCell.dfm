inherited CoolingCellFrame: TCoolingCellFrame
  Width = 155
  Height = 84
  ExplicitWidth = 155
  ExplicitHeight = 84
  PixelsPerInch = 96
  object Cell: TaOPCColorLabel
    Left = 0
    Top = 0
    Width = 155
    Height = 84
    StairsOptions = []
    Value = '4'
    PhysID = '14530'
    Hints.Strings = (
      '1='#1043#1086#1090#1086#1074#1072' '#1076#1086' '#1088#1086#1073#1086#1090#1080
      '2='#1042' '#1088#1086#1073#1086#1090#1110
      '3='#1040#1074#1072#1088#1110#1103
      '4='#1056#1086#1073#1086#1090#1072' '#1079#1072#1074#1077#1088#1096#1077#1085#1072', '#1072#1083#1077' '#1087#1088#1086#1076#1091#1082#1094#1110#1102' '#1097#1077' '#1085#1072' '#1079#1072#1073#1088#1072#1083#1080)
    Params.Strings = (
      'serie=Status')
    InteractiveFont.Charset = DEFAULT_CHARSET
    InteractiveFont.Color = clHighlight
    InteractiveFont.Height = -11
    InteractiveFont.Name = 'Tahoma'
    InteractiveFont.Style = [fsUnderline]
    RotationAngle = 0
    Alignment = taCenter
    AutoSize = False
    BorderWidth = 1
    Caption = #1050#1086#1084#1110#1088#1082#1072' 1'
    Color = 15132391
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
    Layout = tlCenter
    ErrorColor = clBlack
    Colors.Strings = (
      '0=$E6E6E7'
      '1=$E6E6E7'
      '2=$50D092'
      '3=$0000FF'
      '4=$E6E6E7')
  end
  object lMode: TaOPCColorLabel
    Left = 0
    Top = 0
    Width = 107
    Height = 25
    Hint = #1042#1099#1093#1086#1076' '#1085#1072' '#1091#1089#1083#1086#1074#1080#1103
    StairsOptions = []
    Value = '1'
    PhysID = '14529'
    Hints.Strings = (
      '1='#1042#1099#1093#1086#1076' '#1085#1072' '#1091#1089#1083#1086#1074#1080#1103
      '2='#1057#1090#1077#1088#1080#1083#1080#1079#1072#1094#1080#1103
      '3='#1055#1088#1086#1080#1079#1074#1086#1076#1089#1090#1074#1086
      '4='#1055#1088#1086#1084#1099#1074#1082#1072
      '5=CIP'
      '6='#1054#1093#1083#1072#1078#1076#1077#1085#1080#1077
      '7='#1056#1077#1094#1080#1088#1082#1091#1083#1103#1094#1080#1103
      '8='#1054#1089#1090#1072#1085#1086#1074)
    Params.Strings = (
      'serie=Mode')
    InteractiveFont.Charset = DEFAULT_CHARSET
    InteractiveFont.Color = clHighlight
    InteractiveFont.Height = -11
    InteractiveFont.Name = 'Tahoma'
    InteractiveFont.Style = [fsUnderline]
    LookupList = llMode
    RotationAngle = 0
    Alignment = taCenter
    AutoSize = False
    BorderWidth = 1
    Caption = #1056#1091#1095#1085#1080#1081
    Color = 15652797
    Layout = tlCenter
    ErrorColor = clBlack
    Colors.Strings = (
      '0=$EED7BD'
      '1=$EED7BD')
    ShowValue = True
  end
  object lStatus: TaOPCColorLabel
    Left = 0
    Top = 59
    Width = 155
    Height = 25
    StairsOptions = []
    Value = '4'
    PhysID = '14530'
    Hints.Strings = (
      '1='#1043#1086#1090#1086#1074#1072' '#1076#1086' '#1088#1086#1073#1086#1090#1080
      '2='#1042' '#1088#1086#1073#1086#1090#1110
      '3='#1040#1074#1072#1088#1110#1103
      '4='#1056#1086#1073#1086#1090#1072' '#1079#1072#1074#1077#1088#1096#1077#1085#1072', '#1072#1083#1077' '#1087#1088#1086#1076#1091#1082#1094#1110#1102' '#1097#1077' '#1085#1072' '#1079#1072#1073#1088#1072#1083#1080)
    Params.Strings = (
      'serie=Status')
    InteractiveFont.Charset = DEFAULT_CHARSET
    InteractiveFont.Color = clHighlight
    InteractiveFont.Height = -11
    InteractiveFont.Name = 'Tahoma'
    InteractiveFont.Style = [fsUnderline]
    RotationAngle = 0
    Alignment = taCenter
    AutoSize = False
    BorderWidth = 1
    Color = 6740479
    Layout = tlCenter
    ErrorColor = clBlack
    Colors.Strings = (
      '0=$E6E6E7'
      '1=$E6E6E7'
      '2=$50D092'
      '3=$0000FF'
      '4=$66D9FF')
  end
  object llMode: TaOPCLookupList
    Items.Strings = (
      '0='#1040#1074#1090#1086
      '1='#1056#1091#1095#1085#1080#1081)
    Left = 119
    Top = 24
  end
end