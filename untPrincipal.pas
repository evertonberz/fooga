unit untPrincipal;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, jpeg, SimpleGraph, Math, Buttons, Menus, untPCV,
  ActnList, ExtDlgs, OleCtrls, SHDocVw, ComCtrls, Gauges;

type
  TListaDeNodos = array of TGraphNode;
  TListaDeLinks = array of TGraphLink;

  TPrincipalForm = class(TForm)
    pnlBotoes: TPanel;
    btnIr: TButton;
    btnLimpar: TButton;
    popObjetos: TPopupMenu;
    alPrincipal: TActionList;
    aExcluir: TAction;
    aDefinirComoOrigem: TAction;
    miExcluir: TMenuItem;
    miDefinirComoOrigem: TMenuItem;
    aTornarAssimetrico: TAction;
    miTornarMaoDupla: TMenuItem;
    spbDefinirEscala: TSpeedButton;
    spbInserirNodo: TSpeedButton;
    spbEdicao: TSpeedButton;
    imgLogo: TImage;
    spbNavegacao: TSpeedButton;
    popGrafo: TPopupMenu;
    aEscolherFundoViaArquivo: TAction;
    aEscolherFundoViaGoogleMaps: TAction;
    miDefinirFundo: TMenuItem;
    miDefinirFundoViaArquivo: TMenuItem;
    miDefinirFundoViaGoogleMaps: TMenuItem;
    opdFundo: TOpenPictureDialog;
    aExibirGrade: TAction;
    miExibirGrade: TMenuItem;
    aZoomMais: TAction;
    aZoomMenos: TAction;
    aEscolherFundoNenhum: TAction;
    miDefinirFundoNenhum: TMenuItem;
    pnlDestino: TPanel;
    edtDestino: TLabeledEdit;
    btnOkDestino: TBitBtn;
    sgPrincipal: TSimpleGraph;
    wbPrincipal: TWebBrowser;
    lblFundo: TLabel;
    aResetarZoom: TAction;
    btnResetarZoom: TBitBtn;
    lblZoom: TLabel;
    btnZoomMais: TBitBtn;
    btnZoomMenos: TBitBtn;
    btnUtilizarEsteMapa: TBitBtn;
    btnMapa: TButton;
    btnCancelarGoogleMaps: TBitBtn;
    sSeparaGrafoStatus: TSplitter;
    memStatus: TMemo;
    gauProgresso: TGauge;
    procedure btnIrClick(Sender: TObject);
    procedure sgPrincipalObjectDblClick(Graph: TSimpleGraph;
      GraphObject: TGraphObject);
    procedure btnLimparClick(Sender: TObject);
    procedure sgPrincipalObjectChange(Graph: TSimpleGraph;
      GraphObject: TGraphObject);
    procedure sgPrincipalObjectSelect(Graph: TSimpleGraph;
      GraphObject: TGraphObject);
    procedure sgPrincipalCanRemoveObject(Graph: TSimpleGraph;
      GraphObject: TGraphObject; var CanRemove: Boolean);
    procedure popObjetosPopup(Sender: TObject);
    procedure aExcluirExecute(Sender: TObject);
    procedure aDefinirComoOrigemExecute(Sender: TObject);
    procedure aTornarAssimetricoExecute(Sender: TObject);
    procedure spbDefinirEscalaClick(Sender: TObject);
    procedure sgPrincipalMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure spbInserirNodoClick(Sender: TObject);
    procedure sgPrincipalObjectInitInstance(Graph: TSimpleGraph;
      GraphObject: TGraphObject);
    procedure sgPrincipalCanHookLink(Graph: TSimpleGraph;
      GraphObject: TGraphObject; Link: TGraphLink; Index: Integer;
      var CanHook: Boolean);
    procedure sgPrincipalCommandModeChange(Sender: TObject);
    procedure spbEdicaoClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure spbNavegacaoClick(Sender: TObject);
    procedure aEscolherFundoViaArquivoExecute(Sender: TObject);
    procedure aExibirGradeExecute(Sender: TObject);
    procedure aExibirGradeUpdate(Sender: TObject);
    procedure sgPrincipalMouseWheelDown(Sender: TObject;
      Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure sgPrincipalMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure aZoomMaisExecute(Sender: TObject);
    procedure aZoomMenosExecute(Sender: TObject);
    procedure aZoomMenosUpdate(Sender: TObject);
    procedure aZoomMaisUpdate(Sender: TObject);
    procedure aEscolherFundoNenhumExecute(Sender: TObject);
    procedure aEscolherFundoViaGoogleMapsExecute(Sender: TObject);
    procedure btnOkDestinoClick(Sender: TObject);
    procedure aResetarZoomExecute(Sender: TObject);
    procedure btnUtilizarEsteMapaClick(Sender: TObject);
    procedure btnMapaClick(Sender: TObject);
    procedure btnCancelarGoogleMapsClick(Sender: TObject);
  private
    { Private declarations }
    g_bExibindoMelhorCaminho: Boolean;
    g_iEscalaReal, g_iEscalaPixel: Integer;
    function obterDistanciaDeLink(link: TGraphLink; bUsarEscalaReal: Boolean = true): Integer;
    procedure alterarEstadoDosLinksParaNeutro(sgGrafo: TSimpleGraph);
    procedure alterarEstadoDosNodosParaNeutro(sgGrafo: TSimpleGraph);
    procedure selecionarNenhumObjeto(sgGrafo: TSimpleGraph);
    procedure resetarEstadoDosObjetos();
    function obterLinkQueEstaEntre(nodoOrigem: TGraphNode; nodoDestino: TGraphNode): TGraphLink;
    function obterListaDeNodos(sgGrafo: TSimpleGraph; bSomenteSelecionados: Boolean = false): TListaDeNodos;
    function obterListaDeLinks(sgGrafo: TSimpleGraph; bSomenteSelecionados: Boolean = false): TListaDeLinks;
    procedure exibirMelhorCaminho(cMelhorCromossomo: TCromossomo);
    procedure recalcularDistanciaDeTodosLinks(sgGrafo: TSimpleGraph);
  public
    { Public declarations }
  end;

var
  PrincipalForm: TPrincipalForm;

implementation

{$R *.dfm}

uses
  untDefinicaoDeEscala,
  untEscolhaDeMapa,
  untTerceiros;

const
  TAG_LINK_ESCALA = -1;

  NODO_LARGURA = 16;
  NODO_ALTURA = 16;
  NODO_MARGEM = 0;
  NODO_FONTE_TAMANHO = 8;
  NODO_NEUTRO_FONTE_ESTILO = [];
  NODO_NEUTRO_COR_FUNDO = clWhite;
  NODO_ORIGEM_COR_FUNDO = clAqua;
  NODO_MELHOR_COR = clLime;
  NODO_MELHOR_FONTE_ESTILO = [fsBold];

  LINK_NEUTRO_FONTE_ESTILO = [];
  LINK_NEUTRO_COR = clBlack;
  LINK_NEUTRO_ESTILO = psDot;

  LINK_SIMETRICO_TIPO_SETA = lsArrow;
  LINK_ASSIMETRICO_TIPO_SETA_INICIO = lsCircle;
  LINK_ASSIMETRICO_TIPO_SETA_FIM = lsArrowSimple;

  LINK_SELECIONADO_FONTE_ESTILO = [fsBold];
  LINK_SELECIONADO_COR = clBlue;
  LINK_SELECIONADO_ESTILO = psSolid;

  LINK_MELHOR_FONTE_ESTILO = [fsBold];
  LINK_MELHOR_COR = clGreen;
  LINK_MELHOR_ESTILO = psSolid;

  LINK_ESCALA_COR = clMaroon;
  LINK_ESCALA_ESTILO = psSolid;

  URL_PARA_GOOGLE_MAPS = 'http://fit.faccat.br/~everton/google_maps/';
  DESTINO_PADRAO = 'Taquara, RS, Brazil';  

procedure TPrincipalForm.btnIrClick(Sender: TObject);
var
  dDistancias: TDistancias;
  cMelhorCromossomo: TCromossomo;
  ldnNodos, ldnSubNodos: TListaDeNodos;
  iNumeroDeNodos, iDistancia, iNodoA, iNodoB, iNodoOrigem: Integer;
  gnLink: TGraphLink;
begin
  resetarEstadoDosObjetos();
  //criar array de distancias a partir do grafo
  ldnNodos := obterListaDeNodos(sgPrincipal);
  iNumeroDeNodos := Length(ldnNodos);
  //constrói lista de distancias [[[
  SetLength(dDistancias, iNumeroDeNodos);
  for iDistancia := Low(dDistancias) to High(dDistancias) do
  begin
    SetLength(dDistancias[iDistancia], iNumeroDeNodos);
  end;
  //
  ldnSubNodos := obterListaDeNodos(sgPrincipal);
  iNodoOrigem := -1;
  for iNodoA := Low(ldnNodos) to High(ldnNodos) do
  begin
    for iNodoB := Low(ldnSubNodos) to High(ldnSubNodos) do
    begin
      gnLink := obterLinkQueEstaEntre(ldnNodos[iNodoA], ldnNodos[iNodoB]);
      if (gnLink <> nil) then
      begin
        dDistancias[iNodoA][iNodoB] := gnLink.Text;
      end;
    end;
    //
    if (ldnNodos[iNodoA].Brush.Color = NODO_ORIGEM_COR_FUNDO) then
    begin
      iNodoOrigem := iNodoA;
    end;
  end;
  //]]]
  //busca melhor rota [[[
  gauProgresso.Show;
  cMelhorCromossomo := processarPCV(dDistancias, iNodoOrigem, 100, 500, 30, 150, 400, gauProgresso);
  gauProgresso.Hide;
  PrincipalForm.exibirMelhorCaminho(cMelhorCromossomo);
  //]]]
end;

procedure TPrincipalForm.exibirMelhorCaminho(cMelhorCromossomo: TCromossomo);
var
  gnAnterior, gnResultado: TGraphNode;
  glLink: TGraphLink;
  ldnNodos: TListaDeNodos;
  iCromossomo, iChaveResultado: Integer;
  sMensagem: AnsiString;
begin
  ldnNodos := obterListaDeNodos(sgPrincipal);
  gnAnterior := nil;
  for iCromossomo := Low(cMelhorCromossomo) to High(cMelhorCromossomo) do
  begin
    iChaveResultado := StrToInt(cMelhorCromossomo[iCromossomo]);
    gnResultado := ldnNodos[iChaveResultado];
    if (gnResultado.Brush.Color <> NODO_ORIGEM_COR_FUNDO) then // nodo origem
    begin
      gnResultado.Brush.Color := NODO_MELHOR_COR;
    end;
    gnResultado.Font.Style := NODO_MELHOR_FONTE_ESTILO;
    gnResultado.BringToFront;
    //
    if (sMensagem = '') then
    begin
      sMensagem := 'Vá por: ' + gnResultado.Text;
    end
    else
    begin
      sMensagem := sMensagem + ', ' + gnResultado.Text;
    end;
    //altera estado do glLink q entre este nodo e o nodo anterior [[[
    if gnAnterior <> nil then
    begin
      glLink := obterLinkQueEstaEntre(gnAnterior, gnResultado);
      if (glLink <> nil) then
      begin
        glLink.Font.Style := LINK_MELHOR_FONTE_ESTILO;
        glLink.Pen.Color := LINK_MELHOR_COR;
        glLink.Pen.Style := LINK_MELHOR_ESTILO;
        glLink.BringToFront;
        //se for SIMETRICO remove seta da direcao contrária [[[
        if (glLink.BeginStyle = LINK_SIMETRICO_TIPO_SETA) and
           (glLink.EndStyle = LINK_SIMETRICO_TIPO_SETA) then
        begin
          if (glLink.Source = gnAnterior) then
          begin
            glLink.BeginStyle := lsNone
          end
          else
          begin
            glLink.EndStyle := lsNone;
          end;
        end;
        //]]]
      end;
    end;
    gnAnterior := gnResultado;
    //]]]
  end;
  g_bExibindoMelhorCaminho := true;
  memStatus.Lines.Add(sMensagem);
end;


function TPrincipalForm.obterLinkQueEstaEntre(nodoOrigem: TGraphNode; nodoDestino: TGraphNode): TGraphLink;
var
  ldnLinks: TListaDeLinks;
  iLinkAtual: Integer;
begin
  result := nil;
  ldnLinks := obterListaDeLinks(sgPrincipal);
  for iLinkAtual := Low(ldnLinks) to High(ldnLinks) do
  begin
    //SIMETRICO
    if (ldnLinks[iLinkAtual].BeginStyle = LINK_SIMETRICO_TIPO_SETA) and
       (ldnLinks[iLinkAtual].EndStyle = LINK_SIMETRICO_TIPO_SETA) then
    begin
      if ((ldnLinks[iLinkAtual].Source = nodoOrigem) and (ldnLinks[iLinkAtual].Target = nodoDestino)) or
         ((ldnLinks[iLinkAtual].Source = nodoDestino) and (ldnLinks[iLinkAtual].Target = nodoOrigem))then
      begin
        result := ldnLinks[iLinkAtual];
      end;
    end
    //ASSIMETRICO
    else if (ldnLinks[iLinkAtual].BeginStyle = LINK_ASSIMETRICO_TIPO_SETA_INICIO) and
            (ldnLinks[iLinkAtual].EndStyle = LINK_ASSIMETRICO_TIPO_SETA_FIM) then
    begin
      if (ldnLinks[iLinkAtual].Source = nodoOrigem) and (ldnLinks[iLinkAtual].Target = nodoDestino) then
      begin
        result := ldnLinks[iLinkAtual];
      end;
    end;
  end;
end;

procedure TPrincipalForm.sgPrincipalObjectDblClick(Graph: TSimpleGraph;
  GraphObject: TGraphObject);
var
  link: TGraphLink;
begin
  if GraphObject.IsLink then
  begin
    link := TGraphLink(GraphObject);
    link.AddBreakPoint(sgPrincipal.CursorPos);
  end;
end;

procedure TPrincipalForm.sgPrincipalObjectChange(Graph: TSimpleGraph;
  GraphObject: TGraphObject);
var
  link: TGraphLink;
  bUsarEscalaReal: Bool;
begin
  if (g_bExibindoMelhorCaminho) then
  begin
    resetarEstadoDosObjetos();
    g_bExibindoMelhorCaminho := false;
  end;
  //
  if GraphObject.IsLink then
  begin
    link := TGraphLink(GraphObject);
    bUsarEscalaReal := not (Graph.CommandMode = cmInsertLink);
    link.Text := IntToStr(obterDistanciaDeLink(link, bUsarEscalaReal));
  end;
end;

procedure TPrincipalForm.btnLimparClick(Sender: TObject);
begin
  g_iEscalaReal := 1;
  g_iEscalaPixel := 1;
  sgPrincipal.Clear();
end;

function TPrincipalForm.obterDistanciaDeLink(link: TGraphLink; bUsarEscalaReal: Boolean = true): Integer;
var
  pontos: TPoints;
  iPonto, iXAnterior, iYAnterior, iCatetoVertical, iCatetoHorizontal: Integer;
  nHipotenusa, nTotal: extended;
begin
  pontos := link.Polyline;
  nTotal := 0;
  iXAnterior := 0;
  iYAnterior := 0;
  iPonto := Low(pontos);
  repeat
    if (iPonto > 0) then
    begin
      iCatetoVertical := Abs(pontos[iPonto].X - iXAnterior);
      iCatetoHorizontal := Abs(pontos[iPonto].Y - iYAnterior);
      //c2 := a2 + b2;
      nHipotenusa := Sqrt( IntPower(iCatetoVertical, 2) + IntPower(iCatetoHorizontal, 2) );
      nTotal := nTotal + nHipotenusa;
    end;
    iXAnterior := pontos[iPonto].X;
    iYAnterior := pontos[iPonto].Y;
    Inc(iPonto);
  until iPonto > High(pontos);
  //
  if (bUsarEscalaReal) then
  begin
    nTotal := Round(g_iEscalaReal*nTotal) / g_iEscalaPixel;
  end;
  result := Round(nTotal);
end;

procedure TPrincipalForm.alterarEstadoDosLinksParaNeutro(sgGrafo: TSimpleGraph);
var
  ldnLinks: TListaDeLinks;
  iLinkAtual: Integer;
begin
  ldnLinks := obterListaDeLinks(sgGrafo);
  for iLinkAtual := Low(ldnLinks) to High(ldnLinks) do
  begin
    ldnLinks[iLinkAtual].Font.Style := LINK_NEUTRO_FONTE_ESTILO;
    ldnLinks[iLinkAtual].Pen.Color := LINK_NEUTRO_COR;
    ldnLinks[iLinkAtual].Pen.Style := LINK_NEUTRO_ESTILO;
    if (ldnLinks[iLinkAtual].BeginStyle = lsNone) then
    begin
      ldnLinks[iLinkAtual].BeginStyle := LINK_SIMETRICO_TIPO_SETA;
    end;
    if (ldnLinks[iLinkAtual].EndStyle = lsNone) then
    begin
      ldnLinks[iLinkAtual].EndStyle := LINK_SIMETRICO_TIPO_SETA;
    end;
  end;
end;

procedure TPrincipalForm.alterarEstadoDosNodosParaNeutro(sgGrafo: TSimpleGraph);
var
  ldnNodos: TListaDeNodos;
  iNodoAtual: Integer;
begin
  ldnNodos := obterListaDeNodos(sgGrafo);
  for iNodoAtual := Low(ldnNodos) to High(ldnNodos) do
  begin
    ldnNodos[iNodoAtual].Font.Style := NODO_NEUTRO_FONTE_ESTILO;
    if (ldnNodos[iNodoAtual].Brush.Color <> NODO_ORIGEM_COR_FUNDO) then  // nodo origem
    begin
      ldnNodos[iNodoAtual].Brush.Color := NODO_NEUTRO_COR_FUNDO;
    end;
  end;
end;

procedure TPrincipalForm.resetarEstadoDosObjetos();
begin
  alterarEstadoDosLinksParaNeutro(sgPrincipal);
  alterarEstadoDosNodosParaNeutro(sgPrincipal);
  selecionarNenhumObjeto(sgPrincipal);
end;

procedure TPrincipalForm.selecionarNenhumObjeto(sgGrafo: TSimpleGraph);
var
  golObjetos: TGraphObjectList;
  iObjetoAtual: Integer;
begin
  golObjetos := sgGrafo.Objects;
  for iObjetoAtual := 0 to golObjetos.Count-1 do
  begin
    golObjetos.Items[iObjetoAtual].Selected := false;
  end;
end;

procedure TPrincipalForm.sgPrincipalObjectSelect(Graph: TSimpleGraph;
  GraphObject: TGraphObject);
var
  ldnLinks: TListaDeLinks;
  iLinkAtual: Integer;
begin
  if (Graph.CommandMode <> cmInsertLink) and (GraphObject.Selected) then
  begin
    alterarEstadoDosLinksParaNeutro(Graph);
    if (GraphObject.IsNode) then
    begin
      ldnLinks := obterListaDeLinks(sgPrincipal);
      for iLinkAtual := Low(ldnLinks) to High(ldnLinks) do
      begin
        if (ldnLinks[iLinkAtual].Source = GraphObject) or (ldnLinks[iLinkAtual].Target = GraphObject) then
        begin
          ldnLinks[iLinkAtual].Font.Style := LINK_SELECIONADO_FONTE_ESTILO;
          ldnLinks[iLinkAtual].Pen.Color := LINK_SELECIONADO_COR;
          ldnLinks[iLinkAtual].Pen.Style := LINK_SELECIONADO_ESTILO;
        end;
      end;
    end
    else if (GraphObject.IsLink) then
    begin
      GraphObject.Font.Style := LINK_SELECIONADO_FONTE_ESTILO;
      GraphObject.Pen.Color := LINK_SELECIONADO_COR;
      GraphObject.Pen.Style := LINK_SELECIONADO_ESTILO;
    end;
  end;
end;

function TPrincipalForm.obterListaDeNodos(sgGrafo: TSimpleGraph; bSomenteSelecionados: Boolean = false): TListaDeNodos;
var
  iA, iObjetoAtual: Integer;
  ldnLista: TListaDeNodos;
  golObjetos: TGraphObjectList;
  goAux: TGraphObject;
begin
  if (bSomenteSelecionados) then
  begin
    SetLength(ldnLista, sgGrafo.SelectedObjectsCount(TGraphNode));
  end
  else
  begin
    SetLength(ldnLista, sgGrafo.ObjectsCount(TGraphNode));
  end;
  //
  iA := 0;
  golObjetos := sgGrafo.Objects;
  for iObjetoAtual := 0 to golObjetos.Count-1 do
  begin
    goAux := golObjetos.Items[iObjetoAtual];
    if (goAux <> nil) and (goAux.isNode) then
    begin
      if (bSomenteSelecionados and goAux.Selected = true) or
         (not bSomenteSelecionados) then
      begin
        ldnLista[iA] := TGraphNode(goAux);
        Inc(iA);
      end;
    end;
  end;
  result := ldnLista;
end;

function TPrincipalForm.obterListaDeLinks(sgGrafo: TSimpleGraph; bSomenteSelecionados: Boolean = false): TListaDeLinks;
var
  iA, iObjetoAtual: Integer;
  ldnLista: TListaDeLinks;
  golObjetos: TGraphObjectList;
  goAux: TGraphObject;
begin
  if (bSomenteSelecionados) then
  begin
    SetLength(ldnLista, sgGrafo.SelectedObjectsCount(TGraphLink));
  end
  else
  begin
    SetLength(ldnLista, sgGrafo.ObjectsCount(TGraphLink));
  end;
  //
  iA := 0;
  golObjetos := sgGrafo.Objects;
  for iObjetoAtual := 0 to golObjetos.Count-1 do
  begin
    goAux := golObjetos.Items[iObjetoAtual];
    if (goAux <> nil) and (goAux.isLink) then
    begin
      if (bSomenteSelecionados and goAux.Selected = true) or
         (not bSomenteSelecionados) then
      begin
        ldnLista[iA] := TGraphLink(goAux);
        Inc(iA);
      end;
    end;
  end;
  result := ldnLista;
end;

procedure TPrincipalForm.sgPrincipalCanRemoveObject(Graph: TSimpleGraph;
  GraphObject: TGraphObject; var CanRemove: Boolean);
var
  ldnLinks: TListaDeLinks;
  iLinkAtual: Integer;
  bOk: Boolean;
begin
  bOk := true;
  if (GraphObject.IsNode) then
  begin
    //exclui links ligados ao nodo [[[
    ldnLinks := obterListaDeLinks(sgPrincipal);
    for iLinkAtual := Low(ldnLinks) to High(ldnLinks) do
    begin
      if (ldnLinks[iLinkAtual].Source = GraphObject) or
         (ldnLinks[iLinkAtual].Target = GraphObject) then
      begin
        if (not ldnLinks[iLinkAtual].Delete) then
        begin
          bOk := false;
        end
      end;
    end;
    //]]]
  end;
  CanRemove := bOk;
end;

procedure TPrincipalForm.popObjetosPopup(Sender: TObject);
begin
  aExcluir.Visible := (sgPrincipal.SelectedObjectsCount(TGraphLink) = 0);
  aDefinirComoOrigem.Visible := (sgPrincipal.SelectedObjectsCount() = 1) and
                                (sgPrincipal.SelectedObjects[0].IsNode);
  aDefinirComoOrigem.Checked := (sgPrincipal.SelectedObjectsCount() = 1) and
                                (sgPrincipal.SelectedObjects[0].IsNode) and
                                (sgPrincipal.SelectedObjects[0].Brush.Color = NODO_ORIGEM_COR_FUNDO);
  aTornarAssimetrico.Visible := (sgPrincipal.SelectedObjectsCount() = 1) and
                                (sgPrincipal.SelectedObjects[0].isLink) and
                                (TGraphLink(sgPrincipal.SelectedObjects[0]).BeginStyle = LINK_SIMETRICO_TIPO_SETA) and
                                (TGraphLink(sgPrincipal.SelectedObjects[0]).EndStyle = LINK_SIMETRICO_TIPO_SETA);
end;

procedure TPrincipalForm.aExcluirExecute(Sender: TObject);
var
  ldnNodosSelecionados, ldnNodosParaOrigem: TListaDeNodos;
  iNodoAtual: Integer;
  bNodoOrigem: Boolean;
  sNodoOrigem: String;
begin
  //exclui nodos selecionados e seus links [[[
  ldnNodosSelecionados := obterListaDeNodos(sgPrincipal, true);
  for iNodoAtual := Low(ldnNodosSelecionados) to High(ldnNodosSelecionados) do
  begin
    bNodoOrigem := false;
    if (ldnNodosSelecionados[iNodoAtual].Brush.Color = NODO_ORIGEM_COR_FUNDO) then
    begin
      bNodoOrigem := true;
    end;
    if (not ldnNodosSelecionados[iNodoAtual].Delete) then
    begin
      showmessage('Não foi possível excluir ' + ldnNodosSelecionados[iNodoAtual].Text);
    end;
    //se excluiu nodo origem marca o 1o da lista como origem [[[
    if (bNodoOrigem) then
    begin
      ldnNodosParaOrigem := obterListaDeNodos(sgPrincipal);
      if (Length(ldnNodosParaOrigem) > 0) then
      begin
        ldnNodosParaOrigem[Low(ldnNodosParaOrigem)].Brush.Color := NODO_ORIGEM_COR_FUNDO;
        sNodoOrigem := ldnNodosParaOrigem[Low(ldnNodosParaOrigem)].Text;
      end;
    end;
    //]]]
  end;
  if (Length(sNodoOrigem) > 0) then
  begin
    showmessage('O nodo origem agora é o ' + sNodoOrigem);
  end;
  //]]]
end;

procedure TPrincipalForm.aDefinirComoOrigemExecute(Sender: TObject);
var
  ldnNodosSelecionados, ldnNodos: TListaDeNodos;
  iNodoAtual: Integer;
begin
  ldnNodosSelecionados := obterListaDeNodos(sgPrincipal, true);
  if (Length(ldnNodosSelecionados) <> 1) then
  begin
    exit;
  end
  else if (Length(ldnNodosSelecionados) = 1) then
  begin
    //desmarca como origem o atual [[[
    ldnNodos := obterListaDeNodos(sgPrincipal);
    for iNodoAtual := Low(ldnNodos) to High(ldnNodos) do
    begin
      if (ldnNodos[iNodoAtual].Brush.Color = NODO_ORIGEM_COR_FUNDO) then
      begin
        ldnNodos[iNodoAtual].Brush.Color := NODO_NEUTRO_COR_FUNDO;
      end;
    end;
    //]]]
    //marca o selecionado como origem [[[
    ldnNodosSelecionados[Low(ldnNodosSelecionados)].Brush.Color := NODO_ORIGEM_COR_FUNDO;
    //]]]
  end;
end;

procedure TPrincipalForm.aTornarAssimetricoExecute(Sender: TObject);
var
  ldnLinksSelecionados: TListaDeLinks;
  glLinkSelecionado, glNovoLink: TGraphLink;
begin
  ldnLinksSelecionados := obterListaDeLinks(sgPrincipal, true);
  if (Length(ldnLinksSelecionados) <> 1) then
  begin
    exit;
  end
  else if (Length(ldnLinksSelecionados) = 1) then
  begin
    glLinkSelecionado := ldnLinksSelecionados[Low(ldnLinksSelecionados)];
    //verifica se é simetrico (tem setas dos dois lados) [[[
    if (glLinkSelecionado.BeginStyle <> LINK_SIMETRICO_TIPO_SETA) or
       (glLinkSelecionado.EndStyle <> LINK_SIMETRICO_TIPO_SETA) then
    begin
      exit;
    end;
    //]]]
    //ajusta setas do selecionado [[[
    glLinkSelecionado.BeginStyle := LINK_ASSIMETRICO_TIPO_SETA_INICIO;
    glLinkSelecionado.EndStyle := LINK_ASSIMETRICO_TIPO_SETA_FIM;
    //]]]
    //cria novo link [[[
    glNovoLink := sgPrincipal.InsertLink(glLinkSelecionado.Target, glLinkSelecionado.Source);
    glNovoLink.BeginStyle := LINK_ASSIMETRICO_TIPO_SETA_INICIO;
    glNovoLink.EndStyle := LINK_ASSIMETRICO_TIPO_SETA_FIM;
    glNovoLink.LinkOptions := [gloFixedStartPoint, gloFixedEndPoint];
    //
    glNovoLink.Font.Style := LINK_SELECIONADO_FONTE_ESTILO;
    glNovoLink.Pen.Color := LINK_SELECIONADO_COR;
    glNovoLink.Pen.Style := LINK_SELECIONADO_ESTILO;
    //]]]
  end;
end;

procedure TPrincipalForm.spbDefinirEscalaClick(Sender: TObject);
begin
  if (spbDefinirEscala.Down) then
  begin
    sgPrincipal.CommandMode := cmInsertLink;
  end;
end;

procedure TPrincipalForm.spbInserirNodoClick(Sender: TObject);
begin
  sgPrincipal.DefaultNodeClass := TEllipticNode;
  sgPrincipal.CommandMode := cmInsertNode;
end;

procedure TPrincipalForm.sgPrincipalMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  iObjetoAtual, iEscalaReal, iEscalaPixel: Integer;
  golObjetos: TGraphObjectList;
  gnLinkEscala: TGraphLink;
begin
  if (Button = mbLeft) then
  begin
    if (spbDefinirEscala.Down) then
    begin
      //obtem link da escala [[[
      golObjetos := sgPrincipal.Objects;
      for iObjetoAtual := 0 to golObjetos.Count-1 do
      begin
        if (golObjetos.Items[iObjetoAtual].isLink) and (golObjetos.Items[iObjetoAtual].Tag = TAG_LINK_ESCALA) then
        begin
          gnLinkEscala := TGraphLink(golObjetos.Items[iObjetoAtual]);
        end;
      end;
      //]]]
      //seta valores e recalcula links [[[
      if (gnLinkEscala <> nil) then
      begin
        iEscalaPixel := StrToIntDef(gnLinkEscala.Text, 1);
        if TDefinicaoDeEscalaForm.executar(iEscalaReal, iEscalaPixel) then
        begin
          g_iEscalaReal := iEscalaReal;
          g_iEscalaPixel := iEscalaPixel;
          memStatus.Lines.Add('Escala: '+IntToStr(g_iEscalaPixel)+' pixel(s) equivale a '+IntToStr(g_iEscalaReal)+'.')
        end;
        gnLinkEscala.Delete;
      end;
      //]]]
      //volta para modo de edicao e recalcula valores dos links [[[
      spbEdicao.Down := true;
      spbEdicaoClick(spbEdicao);
      recalcularDistanciaDeTodosLinks(sgPrincipal);
      //]]]
    end;
  end;
end;

procedure TPrincipalForm.recalcularDistanciaDeTodosLinks(sgGrafo: TSimpleGraph);
var
  ldnLinks: TListaDeLinks;
  iLinkAtual: Integer;
  gnLink: TGraphLink;
begin
  ldnLinks := obterListaDeLinks(sgGrafo);
  for iLinkAtual := Low(ldnLinks) to High(ldnLinks) do
  begin
    gnLink := ldnLinks[iLinkAtual];
    gnLink.Text := IntToStr(obterDistanciaDeLink(gnLink));
  end;
end;

procedure TPrincipalForm.sgPrincipalObjectInitInstance(Graph: TSimpleGraph;
  GraphObject: TGraphObject);
var
  iNodoAtual: Integer;
  gnNovoNodo: TGraphNode;
  glNovoLink: TGraphLink;
  ldnNodos: TListaDeNodos;
begin
  if (Graph.CommandMode = cmInsertNode) and (GraphObject.IsNode) then
  begin
    //cria novo nodo [[[
    gnNovoNodo := TGraphNode(GraphObject);
    gnNovoNodo.Width := NODO_LARGURA;
    gnNovoNodo.Height := NODO_ALTURA;
    gnNovoNodo.Margin := NODO_MARGEM;
    gnNovoNodo.Font.Size := NODO_FONTE_TAMANHO;
    gnNovoNodo.Text := IntToStr(sgPrincipal.ObjectsCount(TGraphNode)+1);
    gnNovoNodo.NodeOptions := [gnoMovable, gnoShowBackground];
    if (sgPrincipal.ObjectsCount(TGraphNode) = 0) then
    begin
      gnNovoNodo.Brush.Color := NODO_ORIGEM_COR_FUNDO; // nodo origem
    end
    else
    begin
      gnNovoNodo.Brush.Color := NODO_NEUTRO_COR_FUNDO;
    end;
    //]]]
    //cria links entre o objeto novo e outros nodos [[[
    ldnNodos := obterListaDeNodos(sgPrincipal);
    for iNodoAtual := Low(ldnNodos) to High(ldnNodos) do
    begin
      if (gnNovoNodo = ldnNodos[iNodoAtual]) then  //nao cria link pra ele mesmo
      begin
        continue;
      end;
      glNovoLink := sgPrincipal.InsertLink(gnNovoNodo, ldnNodos[iNodoAtual]);
      glNovoLink.BeginStyle := LINK_SIMETRICO_TIPO_SETA;
      glNovoLink.EndStyle := LINK_SIMETRICO_TIPO_SETA;
      glNovoLink.LinkOptions := [gloFixedStartPoint, gloFixedEndPoint];
    end;
    //]]]
  end
  else if (Graph.CommandMode = cmInsertLink) and (GraphObject.IsLink) then
  begin
    glNovoLink := TGraphLink(GraphObject);
    glNovoLink.Tag := TAG_LINK_ESCALA;
    glNovoLink.BeginStyle := lsNone;
    glNovoLink.EndStyle := lsNone;
    glNovoLink.Pen.Color := LINK_ESCALA_COR;
    glNovoLink.Pen.Style := LINK_ESCALA_ESTILO;
  end;
end;

procedure TPrincipalForm.sgPrincipalCanHookLink(Graph: TSimpleGraph;
  GraphObject: TGraphObject; Link: TGraphLink; Index: Integer;
  var CanHook: Boolean);
begin
  CanHook := not (Graph.CommandMode = cmInsertLink);
end;

procedure TPrincipalForm.sgPrincipalCommandModeChange(Sender: TObject);
begin
  if (sgPrincipal.CommandMode = cmEdit) then
  begin
    if (spbDefinirEscala.Down) then
    begin
      spbDefinirEscalaClick(spbDefinirEscala);
    end
    else if (spbInserirNodo.Down) then
    begin
      spbInserirNodoClick(spbInserirNodo);
    end;
  end;
end;

procedure TPrincipalForm.spbEdicaoClick(Sender: TObject);
begin
  sgPrincipal.CommandMode := cmEdit;
end;

procedure TPrincipalForm.FormCreate(Sender: TObject);
begin
  //inicia variaveis globais [[[
  g_bExibindoMelhorCaminho := false;
  g_iEscalaReal := 1;
  g_iEscalaPixel := 1;
  //]]]
  //inicia propriedades padrao dos componentes [[[
  wbPrincipal.Align := alClient;
  wbPrincipal.Hide;
  pnlDestino.Hide;
  //
  lblFundo.Align := alClient;
  //
  sgPrincipal.Align := alClient;
  sgPrincipal.CommandMode := cmPan;
  sgPrincipal.ShowGrid := false;
  //]]]
end;

procedure TPrincipalForm.spbNavegacaoClick(Sender: TObject);
begin
  sgPrincipal.CommandMode := cmPan;
end;

procedure TPrincipalForm.aEscolherFundoViaArquivoExecute(Sender: TObject);
begin
  if (opdFundo.Execute) then
  begin
    sgPrincipal.Fundo.LoadFromFile(opdFundo.FileName);
    sgPrincipal.Refresh;
  end;
end;

procedure TPrincipalForm.aExibirGradeExecute(Sender: TObject);
begin
  sgPrincipal.ShowGrid := not sgPrincipal.ShowGrid;
end;

procedure TPrincipalForm.aExibirGradeUpdate(Sender: TObject);
begin
  aExibirGrade.Checked := sgPrincipal.ShowGrid;
end;

procedure TPrincipalForm.sgPrincipalMouseWheelDown(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
var
  iA: Integer;
begin
  MousePos := sgPrincipal.ScreenToClient(MousePos);
  if PtInRect(sgPrincipal.ClientRect, MousePos) then
  begin
    for iA := 1 to 5 do
    begin
      sgPrincipal.ChangeZoomBy(-1, zoCursor);
      sgPrincipal.Update;
    end;
    Handled := True;
  end;
end;

procedure TPrincipalForm.sgPrincipalMouseWheelUp(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
var
  iA: Integer;
begin
  MousePos := sgPrincipal.ScreenToClient(MousePos);
  if PtInRect(sgPrincipal.ClientRect, MousePos) then
  begin
    for iA := 1 to 5 do
    begin
      sgPrincipal.ChangeZoomBy(+1, zoCursor);
      sgPrincipal.Update;
    end;
    Handled := True;
  end;
end;

procedure TPrincipalForm.aZoomMaisExecute(Sender: TObject);
begin
  sgPrincipal.ChangeZoomBy(+10, zoTopLeft);
end;

procedure TPrincipalForm.aZoomMenosExecute(Sender: TObject);
begin
  sgPrincipal.ChangeZoomBy(-10, zoTopLeft);
end;

procedure TPrincipalForm.aZoomMenosUpdate(Sender: TObject);
begin
  aZoomMenos.Enabled := (sgPrincipal.Zoom > Low(TZoom));
end;

procedure TPrincipalForm.aZoomMaisUpdate(Sender: TObject);
begin
  aZoomMenos.Enabled := (sgPrincipal.Zoom < High(TZoom));
end;

procedure TPrincipalForm.aEscolherFundoNenhumExecute(Sender: TObject);
begin
  sgPrincipal.Fundo := nil;
  sgPrincipal.Refresh;
end;

procedure TPrincipalForm.aEscolherFundoViaGoogleMapsExecute(
  Sender: TObject);
var
  iControle: Integer;  
begin
  sgPrincipal.Hide;
  //
  for iControle := 0 to pnlBotoes.ControlCount-1 do
  begin
    pnlBotoes.Controls[iControle].Enabled := False;
  end;
  //
  pnlDestino.Show;
  wbPrincipal.Show;
  //
  edtDestino.Text := DESTINO_PADRAO;
  edtDestino.SetFocus;
  btnOkDestinoClick(self);
end;

procedure TPrincipalForm.btnOkDestinoClick(Sender: TObject);
var
  iLargura, iAltura: Integer;
begin
  iLargura := wbPrincipal.Width - 50;
  iAltura := wbPrincipal.Height - 50;
  wbPrincipal.Navigate(URL_PARA_GOOGLE_MAPS +
                       '?largura=' + IntToStr(iLargura) +
                       '&altura=' + IntToStr(iAltura) +
                       '&destino=' + edtDestino.Text);
end;

procedure TPrincipalForm.aResetarZoomExecute(Sender: TObject);
begin
  sgPrincipal.Zoom := 100;
end;

procedure TPrincipalForm.btnUtilizarEsteMapaClick(Sender: TObject);
var
  iAdicaoNoTopo, iSubtracaoNaBase: Integer;
begin
  iAdicaoNoTopo := pnlBotoes.Height + pnlDestino.Height;
  iSubtracaoNaBase := memStatus.Height + sSeparaGrafoStatus.Height;
  tcSetarCopiaDaRegiaoClienteDaJanelaAtivaEmBitmap(sgPrincipal.Fundo.Bitmap, iAdicaoNoTopo, iSubtracaoNaBase, 2);
  sgPrincipal.Refresh;
  //
  btnCancelarGoogleMapsClick(btnCancelarGoogleMaps);
end;

procedure TPrincipalForm.btnMapaClick(Sender: TObject);
var
  iOrigem: Integer;
begin
  if TEscolhaDeMapaForm.executar(iOrigem) then
  begin
    case iOrigem of
      0: aEscolherFundoViaGoogleMaps.Execute;
      1: aEscolherFundoViaArquivo.Execute;
      2: aEscolherFundoNenhum.Execute;
    end;
  end;
end;

procedure TPrincipalForm.btnCancelarGoogleMapsClick(Sender: TObject);
var
  iControle: Integer;
begin
  pnlDestino.Hide;
  wbPrincipal.Hide;
  //
  sgPrincipal.Show;
  //
  for iControle := 0 to pnlBotoes.ControlCount-1 do
  begin
    pnlBotoes.Controls[iControle].Enabled := True;
  end;
end;

end.

