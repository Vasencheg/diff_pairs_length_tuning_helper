object FormDPLengthTuning: TFormDPLengthTuning
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsToolWindow
  BorderWidth = 1
  Caption = 'Differential Pairs Length Tuning Helper'
  ClientHeight = 657
  ClientWidth = 496
  Color = clBtnFace
  UseDockManager = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Visible = True
  OnCreate = FormDPLengthTuningCreate
  FormKind = fkNormal
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 24
    Width = 75
    Height = 13
    Caption = 'Diff Pairs Class:'
  end
  object LabelFileName: TLabel
    Left = 88
    Top = 118
    Width = 77
    Height = 13
    Caption = 'No File Choosen'
  end
  object Label8: TLabel
    Left = 8
    Top = 56
    Width = 75
    Height = 13
    Caption = 'Reference pair:'
  end
  object Label4: TLabel
    Left = 262
    Top = 26
    Width = 59
    Height = 13
    Caption = 'Select units:'
  end
  object Label6: TLabel
    Left = 265
    Top = 55
    Width = 69
    Height = 13
    Caption = 'Delay, ps/mm:'
  end
  object Label7: TLabel
    Left = 262
    Top = 87
    Width = 99
    Height = 13
    Caption = 'D2D skew tolerance:'
  end
  object Label2: TLabel
    Left = 262
    Top = 119
    Width = 98
    Height = 13
    Caption = 'P2N skew tolerance:'
  end
  object ComboBoxNetClass: TComboBox
    Left = 88
    Top = 22
    Width = 157
    Height = 21
    Style = csDropDownList
    Sorted = True
    TabOrder = 0
    OnChange = ComboBoxNetClassChange
  end
  object CheckBoxICDelay: TCheckBox
    Left = 8
    Top = 88
    Width = 176
    Height = 17
    Caption = 'Include delay inside IC Package:'
    TabOrder = 1
    OnClick = CheckBoxICDelayClick
  end
  object ButtonLoadFile: TButton
    Left = 8
    Top = 112
    Width = 75
    Height = 25
    Caption = 'Open File'
    Enabled = False
    TabOrder = 2
    OnClick = ButtonLoadFileClick
  end
  object ComboBoxIC: TComboBox
    Left = 184
    Top = 86
    Width = 64
    Height = 21
    Style = csDropDownList
    Sorted = True
    TabOrder = 3
    OnChange = ComboBoxICChange
  end
  object DiffPairInfo: TStringGrid
    Left = 8
    Top = 144
    Width = 480
    Height = 424
    ColCount = 7
    DefaultColWidth = 40
    DefaultRowHeight = 18
    DoubleBuffered = False
    DrawingStyle = gdsGradient
    FixedColor = clWindow
    FixedCols = 0
    RowCount = 2
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing, goRowSelect, goFixedColClick, goFixedRowClick]
    ParentDoubleBuffered = False
    TabOrder = 4
    OnSelectCell = DiffPairInfoSelectCell
    ColWidths = (
      125
      50
      72
      71
      66
      33
      31)
  end
  object DiffPairNetsInfo: TStringGrid
    Left = 8
    Top = 584
    Width = 480
    Height = 64
    DefaultRowHeight = 18
    DrawingStyle = gdsGradient
    FixedCols = 0
    RowCount = 3
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine]
    TabOrder = 5
    ColWidths = (
      165
      99
      95
      81
      31)
  end
  object ComboBoxReferencePair: TComboBox
    Left = 88
    Top = 54
    Width = 157
    Height = 21
    Style = csDropDownList
    Sorted = True
    TabOrder = 6
    OnChange = ComboBoxReferencePairChange
  end
  object UnitsPS: TRadioButton
    Left = 369
    Top = 24
    Width = 40
    Height = 17
    Caption = 'ps'
    TabOrder = 7
    OnClick = UnitsClick
  end
  object UnitsMM: TRadioButton
    Left = 409
    Top = 24
    Width = 40
    Height = 17
    Caption = 'mm'
    Checked = True
    TabOrder = 8
    TabStop = True
    OnClick = UnitsClick
  end
  object Delay: TEdit
    Left = 368
    Top = 51
    Width = 104
    Height = 21
    TabOrder = 9
    Text = '6.15'
    OnChange = DelayChange
  end
  object D2DSkewTolerance: TEdit
    Left = 368
    Top = 83
    Width = 104
    Height = 21
    TabOrder = 10
    Text = '0.127'
    OnChange = D2DSkewToleranceChange
  end
  object P2NSkewTolerance: TEdit
    Left = 368
    Top = 115
    Width = 104
    Height = 21
    TabOrder = 11
    Text = '0.127'
    OnChange = P2NSkewToleranceChange
  end
  object StayOnTop: TCheckBox
    Left = 416
    Top = 0
    Width = 72
    Height = 17
    Caption = 'Stay on top'
    TabOrder = 12
    OnClick = StayOnTopClick
  end
  object OpenFileDialog: TOpenDialog
    DefaultExt = 'csv'
    Filter = 'CSV File | *.csv'
    Left = 192
    Top = 112
  end
  object UpdateInfoTimer: TTimer
    Enabled = False
    Interval = 200
    OnTimer = UpdateInfoTimer
  end
end
