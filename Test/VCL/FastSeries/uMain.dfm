object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 641
  ClientWidth = 1181
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 15
  object Chart: TaOPCChart
    Left = 0
    Top = 0
    Width = 1056
    Height = 641
    BackWall.Brush.Gradient.Direction = gdBottomTop
    BackWall.Brush.Gradient.EndColor = clWhite
    BackWall.Brush.Gradient.StartColor = 15395562
    BackWall.Brush.Gradient.Visible = True
    BackWall.Transparent = False
    Foot.Font.Color = clBlue
    Foot.Font.Name = 'Verdana'
    Gradient.Direction = gdBottomTop
    Gradient.EndColor = clWhite
    Gradient.MidColor = 15395562
    Gradient.StartColor = 15395562
    Gradient.Visible = True
    LeftWall.Color = clLightyellow
    Legend.Font.Name = 'Verdana'
    Legend.Frame.Width = 0
    Legend.Shadow.Transparency = 0
    Legend.Visible = False
    RightWall.Color = clLightyellow
    Title.Font.Name = 'Verdana'
    Title.Text.Strings = (
      'TaOPCChart')
    BottomAxis.Automatic = False
    BottomAxis.AutomaticMaximum = False
    BottomAxis.AutomaticMinimum = False
    BottomAxis.Axis.Color = 4210752
    BottomAxis.Grid.Color = clDarkgray
    BottomAxis.LabelsFormat.Font.Name = 'Verdana'
    BottomAxis.LabelStyle = talValue
    BottomAxis.Maximum = 45991.000000000000000000
    BottomAxis.Minimum = 45658.000000000000000000
    BottomAxis.TicksInner.Color = clDarkgray
    BottomAxis.Title.Font.Name = 'Verdana'
    DepthAxis.Axis.Color = 4210752
    DepthAxis.Grid.Color = clDarkgray
    DepthAxis.LabelsFormat.Font.Name = 'Verdana'
    DepthAxis.TicksInner.Color = clDarkgray
    DepthAxis.Title.Font.Name = 'Verdana'
    DepthTopAxis.Axis.Color = 4210752
    DepthTopAxis.Grid.Color = clDarkgray
    DepthTopAxis.LabelsFormat.Font.Name = 'Verdana'
    DepthTopAxis.TicksInner.Color = clDarkgray
    DepthTopAxis.Title.Font.Name = 'Verdana'
    LeftAxis.Axis.Color = 4210752
    LeftAxis.Grid.Color = clDarkgray
    LeftAxis.LabelsFormat.Font.Name = 'Verdana'
    LeftAxis.TicksInner.Color = clDarkgray
    LeftAxis.Title.Font.Name = 'Verdana'
    RightAxis.Axis.Color = 4210752
    RightAxis.Grid.Color = clDarkgray
    RightAxis.LabelsFormat.Font.Name = 'Verdana'
    RightAxis.TicksInner.Color = clDarkgray
    RightAxis.Title.Font.Name = 'Verdana'
    TopAxis.Axis.Color = 4210752
    TopAxis.Grid.Color = clDarkgray
    TopAxis.LabelsFormat.Font.Name = 'Verdana'
    TopAxis.TicksInner.Color = clDarkgray
    TopAxis.Title.Font.Name = 'Verdana'
    View3D = False
    Align = alClient
    TabOrder = 0
    ZoomFactor = 1.500000000000000000
    Interval.Kind = ikInterval
    Interval.ShiftKind = skNone
    Interval.Date1 = 45658.000000000000000000
    Interval.Date2 = 45991.000000000000000000
    Interval.TimeShift = 333.000000000000000000
    Interval.TimeShiftUnit = tsuHour
    Interval.EnableTime = True
    ShowZero = False
    DefaultCanvas = 'TGDIPlusCanvas'
    ColorPaletteIndex = 13
  end
  object Panel1: TPanel
    Left = 1056
    Top = 0
    Width = 125
    Height = 641
    Align = alRight
    TabOrder = 1
    object Label1: TLabel
      Left = 24
      Top = 313
      Width = 34
      Height = 15
      Caption = 'Label1'
    end
    object bAdd: TButton
      Left = 16
      Top = 16
      Width = 75
      Height = 25
      Caption = 'Add Fast'
      TabOrder = 0
      OnClick = bAddClick
    end
    object bClear: TButton
      Left = 16
      Top = 79
      Width = 75
      Height = 25
      Caption = 'Clear'
      TabOrder = 1
      OnClick = bClearClick
    end
    object bInterval: TButton
      Left = 14
      Top = 110
      Width = 75
      Height = 25
      Caption = 'Interval...'
      TabOrder = 2
      OnClick = bIntervalClick
    end
    object chDrawAll: TCheckBox
      Left = 16
      Top = 160
      Width = 97
      Height = 17
      Caption = 'Draw All'
      TabOrder = 3
    end
    object cbDrawAllStyle: TComboBox
      Left = 16
      Top = 183
      Width = 87
      Height = 23
      ItemIndex = 0
      TabOrder = 4
      Text = 'daFirst'
      Items.Strings = (
        'daFirst'
        'daMinMax')
    end
    object cbDrawStyle: TComboBox
      Left = 16
      Top = 212
      Width = 87
      Height = 23
      ItemIndex = 0
      TabOrder = 5
      Text = 'flSegments'
      Items.Strings = (
        'flSegments'
        'flAll')
    end
    object Apply: TButton
      Left = 16
      Top = 241
      Width = 75
      Height = 25
      Caption = 'Apply'
      TabOrder = 6
      OnClick = ApplyClick
    end
    object bAddLine: TButton
      Left = 16
      Top = 47
      Width = 75
      Height = 25
      Caption = 'Add Line'
      TabOrder = 7
      OnClick = bAddLineClick
    end
    object bCalcTime: TButton
      Left = 16
      Top = 282
      Width = 75
      Height = 25
      Caption = 'Calc Time'
      TabOrder = 8
      OnClick = bCalcTimeClick
    end
  end
  object aOPCTCPSource_V301: TaOPCTCPSource_V30
    RemoteMachine = '193.109.249.118'
    User = #1051#1072#1075#1086#1076#1085#1099#1081
    Password = '314'
    Port = 5152
    MainHost = '193.109.249.118'
    MainPort = 5152
    Left = 500
    Top = 176
  end
end
