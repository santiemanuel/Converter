object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Conversor'
  ClientHeight = 264
  ClientWidth = 299
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 88
    Top = 8
    Width = 31
    Height = 13
    Caption = 'Label1'
  end
  object pgc1: TPageControl
    Left = 0
    Top = 0
    Width = 299
    Height = 264
    ActivePage = Normalizador
    Align = alClient
    TabOrder = 0
    ExplicitWidth = 382
    ExplicitHeight = 329
    object Conversor: TTabSheet
      Caption = 'Conversor'
      ExplicitWidth = 341
      ExplicitHeight = 204
      object lbl1: TLabel
        Left = 16
        Top = 11
        Width = 41
        Height = 13
        Caption = 'Numero:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object lbl2: TLabel
        Left = 16
        Top = 38
        Width = 53
        Height = 13
        Caption = 'Base inicio:'
      end
      object lbl3: TLabel
        Left = 16
        Top = 65
        Width = 42
        Height = 13
        Caption = 'Base fin:'
      end
      object lbl4: TLabel
        Left = 16
        Top = 92
        Width = 80
        Height = 13
        Caption = 'Longitud m'#237'nima:'
      end
      object lbl7: TLabel
        Left = 16
        Top = 144
        Width = 52
        Height = 13
        Caption = 'Resultado:'
      end
      object edtNumber: TEdit
        Left = 104
        Top = 8
        Width = 177
        Height = 21
        TabOrder = 0
      end
      object edtBaseEnd: TEdit
        Left = 104
        Top = 62
        Width = 177
        Height = 21
        NumbersOnly = True
        TabOrder = 2
        TextHint = '2-62'
      end
      object edtBaseStart: TEdit
        Left = 104
        Top = 35
        Width = 177
        Height = 21
        NumbersOnly = True
        TabOrder = 1
        TextHint = '2-62'
      end
      object edtLong: TEdit
        Left = 104
        Top = 89
        Width = 177
        Height = 21
        NumbersOnly = True
        ParentShowHint = False
        ShowHint = True
        TabOrder = 3
      end
      object btn1: TButton
        Left = 116
        Top = 116
        Width = 75
        Height = 25
        Caption = 'Convertir'
        TabOrder = 4
        OnClick = btn1Click
      end
      object mmo1: TMemo
        Left = 16
        Top = 163
        Width = 265
        Height = 70
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 5
      end
    end
    object Normalizador: TTabSheet
      Caption = 'Normalizador'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Roboto'
      Font.Style = []
      ImageIndex = 1
      ParentFont = False
      ExplicitLeft = 8
      ExplicitTop = 27
      ExplicitWidth = 326
      ExplicitHeight = 256
      object lbl5: TLabel
        Left = 3
        Top = 16
        Width = 43
        Height = 13
        Caption = 'Numero:'
      end
      object lbl6: TLabel
        Left = 3
        Top = 48
        Width = 39
        Height = 13
        Caption = 'Valor T:'
      end
      object ResNorm: TJvHTLabel
        Left = 0
        Top = 130
        Width = 278
        Height = 46
        Align = alCustom
        AutoSize = False
        Color = clBtnText
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -16
        Font.Name = 'Roboto'
        Font.Style = [fsBold]
        ParentColor = False
        ParentFont = False
        SuperSubScriptRatio = 0.666666666666666600
      end
      object norm1: TEdit
        Left = 48
        Top = 15
        Width = 121
        Height = 21
        ReadOnly = True
        TabOrder = 0
      end
      object btn2: TButton
        Left = 176
        Top = 11
        Width = 105
        Height = 25
        Caption = 'Cargar convertido'
        TabOrder = 1
        OnClick = btn2Click
      end
      object rg1: TRadioGroup
        Left = 3
        Top = 67
        Width = 170
        Height = 57
        Caption = 'Tipo de redondeo'
        Items.Strings = (
          'Redondeo por corte'
          'Redondeo sim'#233'trico')
        TabOrder = 3
      end
      object btn3: TButton
        Left = 179
        Top = 99
        Width = 75
        Height = 25
        Caption = 'Normalizar'
        TabOrder = 4
        OnClick = btn3Click
      end
      object se1: TSpinEdit
        Left = 48
        Top = 45
        Width = 121
        Height = 22
        MaxValue = 0
        MinValue = 1
        TabOrder = 2
        Value = 0
      end
    end
  end
end
