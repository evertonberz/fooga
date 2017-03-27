object EscolhaDeMapaForm: TEscolhaDeMapaForm
  Left = 361
  Top = 345
  BorderStyle = bsDialog
  Caption = 'Mapa'
  ClientHeight = 126
  ClientWidth = 199
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
  object rgpOrigem: TRadioGroup
    Left = 41
    Top = 6
    Width = 117
    Height = 80
    ItemIndex = 0
    Items.Strings = (
      'via &GoogleMaps'#174
      'via &Arquivo'
      '&Limpar')
    TabOrder = 0
    TabStop = True
  end
  object btnOk: TBitBtn
    Left = 16
    Top = 94
    Width = 75
    Height = 25
    TabOrder = 1
    Kind = bkOK
  end
  object btnCancelar: TBitBtn
    Left = 108
    Top = 94
    Width = 75
    Height = 25
    Caption = 'Cancelar'
    TabOrder = 2
    Kind = bkCancel
  end
end
