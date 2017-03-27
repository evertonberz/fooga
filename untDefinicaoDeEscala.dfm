object DefinicaoDeEscalaForm: TDefinicaoDeEscalaForm
  Left = 361
  Top = 345
  BorderStyle = bsDialog
  Caption = 'Defini'#231#227'o de escala'
  ClientHeight = 73
  ClientWidth = 340
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  ShowHint = True
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 10
    Top = 11
    Width = 263
    Height = 13
    Caption = 'Informe a dist'#226'ncia (em metros) para a linha desenhada:'
    Transparent = True
  end
  object btnOk: TBitBtn
    Left = 87
    Top = 40
    Width = 75
    Height = 25
    TabOrder = 1
    Kind = bkOK
  end
  object btnCancelar: TBitBtn
    Left = 179
    Top = 40
    Width = 75
    Height = 25
    Caption = 'Cancelar'
    TabOrder = 2
    Kind = bkCancel
  end
  object edtEscalaReal: TEdit
    Left = 278
    Top = 7
    Width = 53
    Height = 21
    TabOrder = 0
  end
end
