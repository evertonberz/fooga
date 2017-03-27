unit untEscolhaDeMapa;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls;

type
  TEscolhaDeMapaForm = class(TForm)
    rgpOrigem: TRadioGroup;
    btnOk: TBitBtn;
    btnCancelar: TBitBtn;
  private
    { Private declarations }
  public
    { Public declarations }
    class function executar(out iOrigem: Integer): Boolean;
  end;

var
  EscolhaDeMapaForm: TEscolhaDeMapaForm;

implementation

{$R *.dfm}

class function TEscolhaDeMapaForm.executar(out iOrigem: Integer): Boolean;
begin
  Result := False;
  with Create(Application) do
  try
    if ShowModal = mrOK then
    begin
      iOrigem := rgpOrigem.ItemIndex;
      Result := True;
    end;
  finally
    Free;
  end;
end;



end.
 