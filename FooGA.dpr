program FooGA;

{%ToDo 'FooGA.todo'}

uses
  Forms,
  SysUtils, Windows, Dialogs,
  untPrincipal in 'untPrincipal.pas' {PrincipalForm},
  untPCV in 'untPCV.pas',
  untTerceiros in 'untTerceiros.pas',
  untDefinicaoDeEscala in 'untDefinicaoDeEscala.pas' {DefinicaoDeEscalaForm},
  untEscolhaDeMapa in 'untEscolhaDeMapa.pas' {EscolhaDeMapaForm};

{$R *.res}

var
  fs: TFormatSettings;

begin 
  Application.Initialize;
  Application.CreateForm(TPrincipalForm, PrincipalForm);
  Application.CreateForm(TDefinicaoDeEscalaForm, DefinicaoDeEscalaForm);
  Application.CreateForm(TEscolhaDeMapaForm, EscolhaDeMapaForm);
  Application.Run;
end.
