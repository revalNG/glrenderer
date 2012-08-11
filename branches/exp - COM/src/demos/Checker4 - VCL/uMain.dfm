object Form1: TForm1
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = '-'
  ClientHeight = 455
  ClientWidth = 765
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  DesignSize = (
    765
    455)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 627
    Top = 208
    Width = 31
    Height = 13
    Anchors = [akTop, akRight]
    Caption = 'Label1'
  end
  object Label2: TLabel
    Left = 627
    Top = 227
    Width = 31
    Height = 13
    Anchors = [akTop, akRight]
    Caption = 'Label2'
  end
  object Label3: TLabel
    Left = 627
    Top = 246
    Width = 31
    Height = 13
    Anchors = [akTop, akRight]
    Caption = 'Label3'
  end
  object Panel1: TPanel
    Left = 8
    Top = 8
    Width = 600
    Height = 440
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
  end
  object Button1: TButton
    Left = 624
    Top = 8
    Width = 137
    Height = 33
    Anchors = [akTop, akRight]
    Caption = #1048#1085#1080#1094#1080#1072#1083#1080#1079#1072#1094#1080#1103
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 624
    Top = 47
    Width = 137
    Height = 34
    Anchors = [akTop, akRight]
    Caption = #1044#1077#1080#1085#1080#1094#1080#1072#1083#1080#1079#1072#1094#1080#1103
    Enabled = False
    TabOrder = 2
    OnClick = Button2Click
  end
  object GroupBox1: TGroupBox
    Left = 624
    Top = 104
    Width = 137
    Height = 81
    Anchors = [akTop, akRight]
    Caption = #1047#1077#1084#1083#1103
    TabOrder = 3
    object btnEarthPathCreate: TButton
      Left = 3
      Top = 46
      Width = 131
      Height = 25
      Caption = #1056#1077#1078#1080#1084' '#1085#1086#1074#1099#1093' '#1090#1086#1095#1077#1082
      TabOrder = 0
      OnClick = btnEarthPathCreateClick
    end
    object btnEarthPathSelect: TButton
      Left = 3
      Top = 15
      Width = 131
      Height = 25
      Caption = #1056#1077#1078#1080#1084' '#1074#1099#1073#1086#1088#1072' '#1090#1086#1095#1077#1082
      TabOrder = 1
      OnClick = btnEarthPathSelectClick
    end
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 648
    Top = 296
  end
end
