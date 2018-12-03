object FormSet: TFormSet
  Left = 289
  Top = 190
  BorderStyle = bsDialog
  Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080
  ClientHeight = 193
  ClientWidth = 297
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object LabelDif: TLabel
    Left = 8
    Top = 8
    Width = 62
    Height = 13
    Caption = #1057#1083#1086#1078#1085#1086#1089#1090#1100':'
  end
  object Label1: TLabel
    Left = 8
    Top = 56
    Width = 38
    Height = 13
    Caption = #1053#1080#1079#1082#1072#1103
  end
  object Label2: TLabel
    Left = 248
    Top = 56
    Width = 45
    Height = 13
    Caption = #1042#1099#1089#1086#1082#1072#1103
  end
  object Label3: TLabel
    Left = 120
    Top = 56
    Width = 45
    Height = 13
    Caption = #1057#1088#1077#1076#1085#1103#1103
  end
  object Bevel1: TBevel
    Left = 0
    Top = 152
    Width = 297
    Height = 9
    Shape = bsTopLine
  end
  object LabelDifV: TLabel
    Left = 72
    Top = 8
    Width = 12
    Height = 13
    Caption = '10'
  end
  object LabelGameType: TLabel
    Left = 8
    Top = 80
    Width = 53
    Height = 13
    Caption = #1042#1080#1076' '#1080#1075#1088#1099':'
  end
  object ButtonClose: TButton
    Left = 192
    Top = 160
    Width = 99
    Height = 25
    Caption = #1047#1072#1082#1088#1099#1090#1100
    TabOrder = 0
    OnClick = ButtonCloseClick
  end
  object TrackBarDif: TTrackBar
    Left = 8
    Top = 24
    Width = 281
    Height = 33
    Max = 9
    Frequency = 10
    Position = 9
    TabOrder = 1
    TickStyle = tsManual
    OnChange = TrackBarDifChange
  end
  object CheckBoxMix: TCheckBox
    Left = 8
    Top = 128
    Width = 177
    Height = 17
    Caption = #1055#1086#1082#1072#1079#1099#1074#1072#1090#1100' '#1087#1077#1088#1077#1084#1077#1096#1080#1074#1072#1085#1080#1077
    TabOrder = 2
    OnClick = CheckBoxMixClick
  end
  object ComboBoxGType: TComboBox
    Left = 8
    Top = 96
    Width = 97
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    ItemIndex = 0
    TabOrder = 3
    Text = #1063#1080#1089#1083#1072
    OnChange = ComboBoxGTypeChange
    Items.Strings = (
      #1063#1080#1089#1083#1072
      #1056#1080#1089#1091#1085#1086#1082)
  end
end
