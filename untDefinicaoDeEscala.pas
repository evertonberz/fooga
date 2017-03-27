unit untDefinicaoDeEscala;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons;

type
  TDefinicaoDeEscalaForm = class(TForm)
    Label1: TLabel;
    btnOk: TBitBtn;
    btnCancelar: TBitBtn;
    edtEscalaReal: TEdit;
  private
    { Private declarations }
  public
    { Public declarations }
    class function executar(out iEscalaReal: Integer; iEscalaPixel: Integer): Boolean;
  end;

var
  DefinicaoDeEscalaForm: TDefinicaoDeEscalaForm;

implementation

{$R *.dfm}

class function TDefinicaoDeEscalaForm.executar(out iEscalaReal: Integer; iEscalaPixel: Integer): Boolean;
begin
  Result := False;
  with Create(Application) do
  try
    Caption := Caption + ' - Distância em pixels: ' + IntToStr(iEscalaPixel);
    if ShowModal = mrOK then
    begin
      iEscalaReal := StrToIntDef(edtEscalaReal.Text, 1);
      Result := True;
    end;
  finally
    Free;
  end;
end;

end.
