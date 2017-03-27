unit untTerceiros;

interface

uses Windows, SysUtils, Classes, Graphics;

procedure tcEmbaralharStringList(sl : TStrings; nIntensity : integer);
procedure tcSetarCopiaDaRegiaoClienteDaJanelaAtivaEmBitmap(bm: TBitMap; iAdicaoNoTopo: Integer; iSubtracaoNaBase: Integer; iIgnorarEmTodosOsLados: Integer);

implementation

//http://www.chami.com/tips/delphi/123196D.html
procedure tcEmbaralharStringList(
  sl : TStrings;
  nIntensity : integer );
var
  n1, n2, n3 : integer;
  s1         : string;
begin
  if(0 = nIntensity)then
  begin
    nIntensity := sl.Count;
  end else
  if(nIntensity > sl.Count)then
  begin
    nIntensity := sl.Count;
  end;

  Randomize;

  for n1 := 1 to nIntensity do
  begin
    n2 := Random( nIntensity );
    n3 := Random( nIntensity );

    s1             := sl.Strings[n3];
    sl.Strings[n3] := sl.Strings[n2];
    sl.Strings[n2] := s1;
  end;
end;

//http://www.bitwisemag.com/copy/delphi/delphi1.html   (exemplo 3)
procedure tcSetarCopiaDaRegiaoClienteDaJanelaAtivaEmBitmap(bm: TBitMap; iAdicaoNoTopo: Integer; iSubtracaoNaBase: Integer; iIgnorarEmTodosOsLados: Integer);
var
  DestRect, SourceRect: TRect;
  h: THandle;
  hdcSrc : THandle;
begin
  h := GetForeGroundWindow;
  if h <> 0 then
  begin
    try
      hdcSrc := GetDC(h); // use this for ClientRect
      Windows.GetClientRect(h, SourceRect);
      //modificado por Everton {{{
      SourceRect.Top := SourceRect.Top + iAdicaoNoTopo;
      SourceRect.Bottom := SourceRect.Bottom - iSubtracaoNaBase;
      //
      SourceRect.Left := SourceRect.Left + iIgnorarEmTodosOsLados;
      SourceRect.Top := SourceRect.Top + iIgnorarEmTodosOsLados;
      SourceRect.Right := SourceRect.Right - iIgnorarEmTodosOsLados;
      SourceRect.Bottom := SourceRect.Bottom - iIgnorarEmTodosOsLados;
      //}}}
      bm.Width  := SourceRect.Right - SourceRect.Left;
      bm.Height := SourceRect.Bottom - SourceRect.Top;
      StretchBlt(bm.Canvas.Handle,  //handle destino
                 0,  //coordenadas do rect destino (esquerda)
                 0,  //coordenadas do rect destino (topo)
                 bm.Width, //coordenadas do rect destino (direita)
                 bm.Height, //coordenadas do rect destino (baixo)
                 hdcSrc,  //handle origem
                 SourceRect.Left,  //coordenadas do rect origem (esquerda)
                 SourceRect.Top,  //coordenadas do rect origem (topo)
                 SourceRect.Right - SourceRect.Left, //coordenadas do rect origem (direita)
                 SourceRect.Bottom - SourceRect.Top, //coordenadas do rect origem (baixo)
                 SRCCOPY);
    finally
      ReleaseDC(0, hdcSrc);
    end;
  end;
end;



end.
