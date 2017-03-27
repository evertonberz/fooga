unit untPCV;

interface

uses SysUtils, Classes, Gauges;

type
  TDistancias = array of array of ShortString;     //foi usado ShortString para poder deixar o campo vazio ''

  TCromossomo = array of ShortString;  //foi usado ShortString para poder deixar o campo vazio ''
  TIndividuo = class(TObject)
    cromossomo: TCromossomo;
    fitness: Integer;
  end;

  TPopulacao = array of TIndividuo;

function obterCromossomoAleatorio(iNumeroDeNodos: Integer; iGeneOrigem: Integer): TCromossomo;
function obterFitnessCalculado(cromossomo: TCromossomo; distancias: TDistancias; iGeneOrigem: Integer): Integer;
function obterListaComElementosMutados(iQuantidadeDeMutacoes: Integer;
                                       listaEvolutiva: TPopulacao;
                                       distancias: TDistancias;
                                       iGeneOrigem: Integer): TPopulacao;
function obterListaComMelhoresQuePassamDireto(iQuantidadeDeMelhoresQuePassamDireto: Integer;
                                              listaEvolutiva: TPopulacao): TPopulacao;
function processarPCV(distancias: TDistancias;
                      iGeneOrigem: Integer;
                      iQuantidadeDeGeracoes: Integer;
                      iNumeroDeElementosNaPopulacao: Integer;
                      iQuantidadeDeMelhoresQuePassamDireto: Integer;
                      iQuantidadeDeMutacoes: Integer;
                      iQuantidadeDeMelhoresQueSeReproduzem: Integer;
                      gauProgresso: TGauge): TCromossomo;
procedure ordenarPopulacao(var A: TPopulacao; iLo, iHi: Integer);
function juntarPopulacoes(lista1: TPopulacao;lista2: TPopulacao; lista3: TPopulacao): TPopulacao;
function obterListaComDescendentesReproduzidos(iQuantidadeDeMelhoresQueSeReproduzem: Integer;
                                               iQuantidadeDeFilhos: Integer;
                                               listaEvolutiva: TPopulacao;
                                               distancias: TDistancias;
                                               iGeneOrigem: Integer): TPopulacao;
function verificarSeExisteGeneEmCromossomo(gene: ShortString; cromossomo: TCromossomo): Boolean;
procedure acrescentarGeneOrigemNoInicioEFimDoCromossomo(var cCromossomo: TCromossomo; iGeneOrigem: Integer);

implementation

uses untTerceiros;


function processarPCV(distancias: TDistancias;
                      iGeneOrigem: Integer;
                      iQuantidadeDeGeracoes: Integer;
                      iNumeroDeElementosNaPopulacao: Integer;
                      iQuantidadeDeMelhoresQuePassamDireto: Integer;
                      iQuantidadeDeMutacoes: Integer;
                      iQuantidadeDeMelhoresQueSeReproduzem: Integer;
                      gauProgresso: TGauge): TCromossomo;
var iNumeroDeGenes, iA, iGeracao, iQuantidadeDeFilhos: Integer;
    listaEvolutiva, listaNova1, listaNova2, listaNova3: TPopulacao;
    cMelhorCromossomo: TCromossomo;
begin
  iNumeroDeGenes := Length(distancias);
  if (iNumeroDeGenes <= 1) then
  begin
    exit;
  end;
  //inicia com aleatorio [[[
  SetLength(listaEvolutiva, iNumeroDeElementosNaPopulacao);
  for iA := 0 to iNumeroDeElementosNaPopulacao-1 do
  begin
    listaEvolutiva[iA] := TIndividuo.Create;
    listaEvolutiva[iA].cromossomo := obterCromossomoAleatorio(iNumeroDeGenes, iGeneOrigem);
    listaEvolutiva[iA].fitness := obterFitnessCalculado(listaEvolutiva[iA].cromossomo, distancias, iGeneOrigem);
  end;
  //]]]
  //cria geracoes [[[
  gauProgresso.Progress := 0;
  gauProgresso.MaxValue := iQuantidadeDeGeracoes;
  iGeracao := 0;
  while (iGeracao < iQuantidadeDeGeracoes) do
  begin
    Inc(iGeracao);
    listaNova1 := obterListaComMelhoresQuePassamDireto(iQuantidadeDeMelhoresQuePassamDireto,
                                                       listaEvolutiva);
    iQuantidadeDeFilhos := iNumeroDeElementosNaPopulacao - iQuantidadeDeMelhoresQuePassamDireto - iQuantidadeDeMutacoes;
    listaNova2 := obterListaComDescendentesReproduzidos(iQuantidadeDeMelhoresQueSeReproduzem,
                                                        iQuantidadeDeFilhos,
                                                        listaEvolutiva,
                                                        distancias,
                                                        iGeneOrigem);
    listaNova3 := obterListaComElementosMutados(iQuantidadeDeMutacoes,
                                                listaEvolutiva,
                                                distancias,
                                                iGeneOrigem);
    listaEvolutiva := juntarPopulacoes(listaNova1, listaNova2, listaNova3);
    //progresso [[[
    gauProgresso.AddProgress(1);
    //]]]
  end;
  //]]]
  result := nil;
  if (Length(listaEvolutiva) > 0) then
  begin
    ordenarPopulacao(listaEvolutiva, Low(listaEvolutiva), High(listaEvolutiva));
    cMelhorCromossomo := listaEvolutiva[Low(listaEvolutiva)].cromossomo;
    acrescentarGeneOrigemNoInicioEFimDoCromossomo(cMelhorCromossomo, iGeneOrigem);
    result := cMelhorCromossomo;
  end;
end;


//pega os melhores e faz reprodução
function obterListaComDescendentesReproduzidos(iQuantidadeDeMelhoresQueSeReproduzem: Integer;
                                               iQuantidadeDeFilhos: Integer;
                                               listaEvolutiva: TPopulacao;
                                               distancias: TDistancias;
                                               iGeneOrigem: Integer): TPopulacao;
var listaNova, listaEvolutivaAuxCompleta, listaEvolutivaAuxMelhores: TPopulacao;
    iA, iB, iC, iD, iPai, iMae, iGeneInicial, iPaiInterno, iMaeInterno, iContador: Integer;
    cromossomoPai, cromossomoMae, cromossomoFilho: TCromossomo;
    processarPai, processarMae: Boolean;
begin
  //cria lista de fitness apenas com os iQuantidadeDeMelhoresQueSeReproduzem melhores [[[
  listaEvolutivaAuxCompleta := Copy(listaEvolutiva);
  ordenarPopulacao(listaEvolutivaAuxCompleta, Low(listaEvolutivaAuxCompleta), High(listaEvolutivaAuxCompleta));
  SetLength(listaEvolutivaAuxMelhores, iQuantidadeDeMelhoresQueSeReproduzem);
  for iA := Low(listaEvolutivaAuxCompleta) to iQuantidadeDeMelhoresQueSeReproduzem-1 do
  begin
    listaEvolutivaAuxMelhores[iA] := listaEvolutivaAuxCompleta[iA];
  end;
  //]]]
  SetLength(listaNova, iQuantidadeDeFilhos);
  Randomize();
  for iB := Low(listaNova) to High(listaNova) do
  begin
    //pega o pai e a mae aleatorios [[[
    iPai := Random(High(listaEvolutivaAuxMelhores)-1);
    cromossomoPai := listaEvolutivaAuxMelhores[iPai].cromossomo;
    iMae := Random(High(listaEvolutivaAuxMelhores)-1);
    cromossomoMae := listaEvolutivaAuxMelhores[iMae].cromossomo;
    //]]]
    //inicia o filho com gene aleatorio do pai [[[
    iGeneInicial := Random(High(cromossomoPai));
    cromossomoFilho := nil;
    SetLength(cromossomoFilho, Length(cromossomoPai));
    cromossomoFilho[iGeneInicial] := cromossomoPai[iGeneInicial];
    //]]]
    //processa genes que compoe o filho [[[
    iPai := iGeneInicial;
    iMae := iGeneInicial;
    iPaiInterno := iPai-1;
    iMaeInterno := iMae+1;
    processarPai := true;
    processarMae := true;
    iContador := 1;
    while (processarPai or processarMae) do
    begin
      Dec(iPai);
      Inc(iMae);
      //ve se ja nao excedeu tamanho [[[
      if (iPai < 0) then
      begin
        processarPai := false;
      end;
      if (iMae > High(cromossomoFilho)) then
      begin
        processarMae := false;
      end;
      //]]]
      //coloca do pai a esquerda [[[
      if (processarPai) then
      begin
        if (not verificarSeExisteGeneEmCromossomo(cromossomoPai[iPai], cromossomoFilho)) then
        begin
          Inc(iContador);          
          cromossomoFilho[iPaiInterno] := cromossomoPai[iPai];
          Dec(iPaiInterno);
        end
        else
        begin
          processarPai := false;
        end;
      end;
      //]]]
      //coloca da mae a direita [[[
      if (processarMae) then
      begin
        if (not verificarSeExisteGeneEmCromossomo(cromossomoMae[iMae], cromossomoFilho)) then
        begin
          Inc(iContador);
          cromossomoFilho[iMaeInterno] := cromossomoMae[iMae];
          Inc(iMaeInterno);
        end
        else
        begin
          processarMae := false;
        end;
      end;
      //]]]
    end;
    //coloca os que faltaram (pega do pai) [[[
    if (iContador < Length(cromossomoPai)) then
    begin
      //o q faltou na esquerda
      for iC := 0 to iPaiInterno do
      begin
        for iD := Low(cromossomoPai) to High(cromossomoPai) do
        begin
          if (not verificarSeExisteGeneEmCromossomo(cromossomoPai[iD], cromossomoFilho)) then
          begin
            cromossomoFilho[iC] := cromossomoPai[iD];
            break;
          end;
        end;
      end;
      //o q faltou na direita
      for iC := High(cromossomoFilho) downto iMaeInterno do
      begin
        for iD := High(cromossomoMae) downto Low(cromossomoMae) do
        begin
          if (not verificarSeExisteGeneEmCromossomo(cromossomoMae[iD], cromossomoFilho)) then
          begin
            cromossomoFilho[iC] := cromossomoMae[iD];
            break;
          end;
        end;
      end;
    end;
    //]]]    
    // TODO : teste pra ver a linha filho esta completa - remover mais tarde [[[
    if (verificarSeExisteGeneEmCromossomo('', cromossomoFilho)) then
    begin
      //'[Erro interno] o filho no cromossomo ficou com um elemento vazio.';
    end;
    //]]]
    //adiciona na listaNova [[[
    listaNova[iB] := TIndividuo.Create;
    listaNova[iB].cromossomo := cromossomoFilho;
    listaNova[iB].fitness := obterFitnessCalculado(listaNova[iB].cromossomo, distancias, iGeneOrigem);
    //]]]
    { ATENCAO: Nao coloquei o "break" q tinha no script antigo q nao deixava o mesmo pai/mae
               se reproduzir 2x.  Ou seja, este algoritmo processa até o numero de filhos for
               alcançado. }
  end;
  result := listaNova;
end;


function juntarPopulacoes(lista1: TPopulacao;lista2: TPopulacao; lista3: TPopulacao): TPopulacao;
var listaNova: TPopulacao;
    iTamanhoTotal, iNova, iA: Integer;
begin
  iTamanhoTotal := High(lista1)+1 + High(lista2)+1 + High(lista3)+1;
  SetLength(listaNova, iTamanhoTotal);
  iNova := 0;
  for iA := Low(lista1) to High(lista1) do
  begin
    listaNova[iNova] := lista1[iA];
    Inc(iNova);
  end;
  for iA := Low(lista2) to High(lista2) do
  begin
    listaNova[iNova] := lista2[iA];
    Inc(iNova);
  end;
  for iA := Low(lista3) to High(lista3) do
  begin
    listaNova[iNova] := lista3[iA];
    Inc(iNova);
  end;
  result := listaNova;
end;


//pega os melhores e faz mutacao
function obterListaComElementosMutados(iQuantidadeDeMutacoes: Integer;
                                       listaEvolutiva: TPopulacao;
                                       distancias: TDistancias;
                                       iGeneOrigem: Integer): TPopulacao;
var listaNova, listaEvolutivaAux: TPopulacao;
    iContador, iA, iPosicao1, iPosicao2: Integer;
    iValor1, iValor2: ShortString;
    cromossomo: TCromossomo;
begin
  listaEvolutivaAux := Copy(listaEvolutiva);
  ordenarPopulacao(listaEvolutivaAux, Low(listaEvolutivaAux), High(listaEvolutivaAux));
  SetLength(listaNova, iQuantidadeDeMutacoes);
  iContador := 0;
  Randomize();
  for iA := Low(listaEvolutivaAux) to High(listaEvolutivaAux) do
  begin
    cromossomo := Copy(listaEvolutivaAux[iA].cromossomo);
    //troca de posicoes
    iPosicao1 := Random(High(cromossomo));
    iPosicao2 := Random(High(cromossomo));
    iValor1 := cromossomo[iPosicao1];
    iValor2 := cromossomo[iPosicao2];
    cromossomo[iPosicao1] := iValor2;
    cromossomo[iPosicao2] := iValor1;
    //
    listaNova[iA] := TIndividuo.Create;
    listaNova[iA].cromossomo := cromossomo;
    listaNova[iA].fitness := obterFitnessCalculado(listaNova[iA].cromossomo, distancias, iGeneOrigem);
    //
    Inc(iContador);
    if (iContador = High(listaNova)+1) then
    begin
      break;
    end;
  end;
  result := listaNova;
end;




function obterListaComMelhoresQuePassamDireto(iQuantidadeDeMelhoresQuePassamDireto: Integer;
                                              listaEvolutiva: TPopulacao): TPopulacao;
var listaNova, listaEvolutivaAux: TPopulacao;
    iContador, iA: Integer;
begin
  listaEvolutivaAux := Copy(listaEvolutiva);
  ordenarPopulacao(listaEvolutivaAux, Low(listaEvolutivaAux), High(listaEvolutivaAux));
  SetLength(listaNova, iQuantidadeDeMelhoresQuePassamDireto);
  iContador := 0;
  for iA := Low(listaEvolutivaAux) to High(listaEvolutivaAux) do
  begin
    listaNova[iA] := listaEvolutivaAux[iA];
    //
    Inc(iContador);
    if (iContador = High(listaNova)+1) then
    begin
      break;
    end;
  end;
  result := listaNova;
end;


{listaDeFitness retorna:
  array(i => fitness,
        1 => 2039,
        2 => 4232,
        ...)
}
function obterFitnessCalculado(cromossomo: TCromossomo; distancias: TDistancias; iGeneOrigem: Integer): Integer;
var
  iA, iDistancia, iMunicipioOrigem, iMunicipioDestino: Integer;
begin
  iDistancia := 0;
  acrescentarGeneOrigemNoInicioEFimDoCromossomo(cromossomo, iGeneOrigem);
  for iA := Low(cromossomo) to High(cromossomo) do
  begin
    if (iA+1 <= High(cromossomo)) then
    begin
      iMunicipioOrigem := StrToInt(cromossomo[iA]);
      iMunicipioDestino := StrToInt(cromossomo[iA+1]);
      Inc(iDistancia, StrToInt(distancias[iMunicipioOrigem][iMunicipioDestino]));
    end;
  end;
  result := iDistancia;
end;

procedure acrescentarGeneOrigemNoInicioEFimDoCromossomo(var cCromossomo: TCromossomo; iGeneOrigem: Integer);
var
  cCromossomoOriginal: TCromossomo;
  iA: Integer;
begin
  //acrescenta nodo origem no inicio e no fim do cromossomo [[[
  cCromossomoOriginal := cCromossomo;
  SetLength(cCromossomo, Length(cCromossomoOriginal)+2);
  cCromossomo[Low(cCromossomo)] := IntToStr(iGeneOrigem);
  for iA := Low(cCromossomoOriginal) to High(cCromossomoOriginal) do
  begin
    cCromossomo[iA+1] := cCromossomoOriginal[iA];
  end;
  cCromossomo[High(cCromossomo)] := IntToStr(iGeneOrigem);
  //]]]
end;


{listaAleatoria retorna:
  array(i => idNodo,
        1 => "3",
        2 => "4",
        ...)
 ATENCAO, apesar do idNodo ser um campo tipo string ele deve conter somente numeros inteiros pois ele eh
 utilizado como indices em arrays, e o Delphi só suporta numeros como indice de array!
 (eles foram declarados com o tipo string para serem iniciados com '' quando é rodado o SetLength)        
}
function obterCromossomoAleatorio(iNumeroDeNodos: Integer; iGeneOrigem: Integer): TCromossomo;
var
  slAleatoria: TStringList;
  cromossomoAleatorio: TCromossomo;
  i: Integer;
begin
  slAleatoria := TStringList.Create;
  //
  for i := 0 to iNumeroDeNodos-1 do
  begin
    if (i <> iGeneOrigem) then
    begin
      slAleatoria.Add(IntToStr(i));
    end;
  end;
  tcEmbaralharStringList(slAleatoria, 0);
  //
  SetLength(cromossomoAleatorio, slAleatoria.Count);
  for i := 0 to slAleatoria.Count-1 do
  begin
    cromossomoAleatorio[i] := slAleatoria[i];
  end;
  slAleatoria.Free;
  result := cromossomoAleatorio;
end;


procedure ordenarPopulacao(var A: TPopulacao; iLo, iHi: Integer);
var
  Lo, Hi, Mid: Integer;
  T: TIndividuo;
begin
  if (Length(A) <> 0) then
  begin
    Lo := iLo;
    Hi := iHi;
    Mid := A[(Lo + Hi) div 2].fitness;
    repeat
      while A[Lo].fitness < Mid do
        Inc(Lo);
      while A[Hi].fitness > Mid do
        Dec(Hi);
      if Lo <= Hi then
      begin
        T := A[Lo];
        A[Lo] := A[Hi];
        A[Hi] := T;
        Inc(Lo);
        Dec(Hi);
      end;
    until Lo > Hi;
    //
    if Hi > iLo then
      ordenarPopulacao(A, iLo, Hi);
    if Lo < iHi then
      ordenarPopulacao(A, Lo, iHi);
  end;
end;


function verificarSeExisteGeneEmCromossomo(gene: ShortString; cromossomo: TCromossomo): Boolean;
var iA: Integer;
begin
  for iA := Low(cromossomo) to High(cromossomo) do
  begin
    if (cromossomo[iA] = gene) then
    begin
      result := true;
      exit;
    end;
  end;
  result := false;
end;

end.
