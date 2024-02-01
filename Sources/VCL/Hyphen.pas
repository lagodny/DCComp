////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                            Sanders the Softwarer                           //
//                                                                            //
//                   ����������� ��������� � ������� ������,                  //
//                     �������������� � ��������� �������                     //
//                                                                            //
///////////////////////////////////////////////// Author Sanders Prostorov /////

{ ----- ������� ----------------------------------------------------------------

����� �������� ����� �������������� ���� ������, ������������ ���, ������������
� ����������� ����������� ��������, � ��� ����� ������������, ��� �������������
� �������������� ����������� �� ������. � ����� ������ ������ ������ �����������
���������� �� ��������� ������ � �������� ��������������� ������.

��� ��������������� ������������ ������ ������ ����� �������� ��� ������ �
�������� ������ ��� �������������� �������� ����� ����������� ��������� �������.

���� �� ������� ���������� ��������� � �������� �������������� �� �� ����
�������� - �������� � ���, � �� ��������� ��������� ����� ��������� � ���������
������ ������. ����� ����� �������� � ��������� �������, ���� ����� �����.

�����: Sanders Prostorov, 2:5020/1583, softwarer@mail.ru, softwarer@nm.ru

------------------------------------------------------------------------------ }

{ ----- ������� ������ ---------------------------------------------------------

??.??.1998 ������ ������ ������. ���������� �������� �������� ������� ����;
           ������ �������� ��� ���� ������ ����� (��������� ����������
           TPrintGrid)
23.08.2006 ������ ��������� � �������� ��� �������������.

------------------------------------------------------------------------------ }

unit Hyphen ;

interface

uses Classes, Types, SysUtils, Graphics ;

type
  THAlignment = ( tahLeft, tahRight, tahCenter ) ;
  TVAlignment = ( tavTop, tavBottom, tavCenter ) ;

function PlaceHyphens ( Word : string ) : string ;
  { ����������� ��������� ��������� � ������� ����� }

procedure HyphenParagraph ( Para   : string ;
                            Res    : TStrings ;
                            Width  : integer ;
                            Canvas : TCanvas ) ;
  { ����������� ��������� � ������ � ������������ � �������, �������� � ������� }

function DrawMultilineText ( Text : string ;
                             Canvas : TCanvas ;
                             Rect : TRect ;
                             HAlignment : THAlignment ;
                             VAlignment : TVAlignment ;
                             VMargin : integer ) : integer ;
  { ����� ������ � ��������������� ��� �������� ������������� }

implementation

type
  TCharSet = set of char ;

{ ����������� ��������� ��������� � ������� ����� }
function PlaceHyphens ( Word : string ) : string ;
const
  Vocalics : TCharSet = [ '�', '�', '�', '�', '�', '�', '�', '�', '�', '�' ] ;
var
  Syllables : array of byte ;
  i, c : integer  ;
  S    : string   ;
begin
  Result := Word ;
  if length ( Word ) <= 3 then exit ;
  SetLength ( Syllables, length ( Word ) + 1 ) ;
  { ��������� ��� � ���� ������� }
  S := AnsiLowerCase ( Word ) ;
  { ������ ������ ������� }
  i := 1 ;
  while ( i <= length ( S )) and not ( S [ i ] in Vocalics ) do inc ( i ) ;
  if i > length ( S ) then exit ;
  { ������� ����� ������� �������������� ������� }
  c := 0 ;
  repeat
    Syllables [ i ] := c ;
    inc ( i ) ;
    if S [ i ] in Vocalics then inc ( c ) ;
  until i >= length ( S ) ;
  { ����� ����� ����������� � ����� ����� ��� }
  for i := 1 to length ( S ) - 1 do
    if ( Syllables [ i ] <> Syllables [ i + 1 ]) and
       not ( S [ i ] in ( Vocalics + [ '�', '�' ] ))
      then Syllables [ i ] := Syllables [ i + 1 ] ;
  { � ������ � ����� ����� ������������� ����� ������ ������ ������ }
  Syllables [ 1 ] := Syllables [ 2 ] ;
  Syllables [ length ( S ) ] := Syllables [ length ( S ) - 1 ] ;
  { �������� ��������� �� -�� }
  if copy ( S, length ( S ) - 1, 2 ) = '��' then
  begin
    Syllables [ length ( S ) ] := Syllables [ length ( S ) - 2 ] ;
    Syllables [ length ( S ) - 1 ] := Syllables [ length ( S ) - 2 ] ;
  end ;
  { ��� ����� � ������� �� �����. �������� ������������ ��������� }
  S := '' ;
  for i := 1 to length ( Word ) do
  begin
    S := S + Word [ i ] ;
    if ( i < length ( Word )) and ( Syllables [ i ] <> Syllables [ i + 1 ])
      then S := S + '-' ;
  end ;
  Result := S ;
end ;

{ ����������� ��������� � ������ � ������������ � �������, �������� � ������� }
procedure HyphenParagraph ( Para   : string ;
                            Res    : TStrings ;
                            Width  : integer ;
                            Canvas : TCanvas ) ;

  const
    typHyph   =  1 ;
    typNoHyph =  2 ;
    Divider   = #1 ;

  function RussianLetter ( Ch : char ) : boolean ;
  const Lets = '�����Ũ��������������������������' +
               '��������������������������������' ;
  begin
    RussianLetter := Pos ( Ch, Lets ) > 0 ;
  end ;

  function RussianLetterOrDivider ( Ch : char ) : boolean ;
  begin
    RussianLetterOrDivider := ( Ch = Divider ) or RussianLetter ( Ch ) ;
  end ;

  { ��������� ��������� ������� }
  procedure GetNextWord ( var S, Res : string ; var Typ : integer ) ;
  begin
    if S [ 1 ] = ' ' then
      begin
        Res := ' ' ;
        while ( S <> '' ) and ( S [ 1 ] = ' ' ) do delete ( S, 1, 1 ) ;
        Typ := typNoHyph ;
      end
    else if RussianLetter ( S [ 1 ]) then
      begin
        Res := '' ;
        Typ := typHyph ;
        repeat
          Res := Res + S [ 1 ] ;
          delete ( S, 1, 1 ) ;
        until ( S = '' ) or not RussianLetter ( S [ 1 ]) ;
      end
    else
      begin
        Res := '' ;
        Typ := TypNoHyph ;
        repeat
          Res := Res + S [ 1 ] ;
          delete ( S, 1, 1 ) ;
        until ( S = '' ) or RussianLetter ( S [ 1 ]) or ( S [ 1 ] = ' ' ) ;
      end ;
  end ;

  { �������� �� ������ ������ �������� }
  function DeleteDividers ( S : string ) : string ;
  var i : integer ;
  begin
    i := 1 ;
    while i <= length ( S ) do
      if S [ i ] = Divider
        then delete ( S, i, 1 )
        else inc ( i ) ;
    DeleteDividers := S ;
  end ;

  { �������� �� ������ ��������� ������ �������� }
  function DeleteStartingDividers ( S : string ) : string ;
  begin
    while ( S <> '' ) and ( S [ 1 ] = Divider ) do Delete ( S, 1, 1 ) ;
    DeleteStartingDividers := S ;
  end ;

  { ����������� ������ ��������� ������ }
  function CheckWidth ( S : string ; C : TCanvas ) : integer ;
  begin
    CheckWidth := C.TextWidth ( DeleteDividers ( S )) + C.TextWidth ( '-' ) ;
  end ;

  { ��������� ��������� ������ ���������� ������ }
  function GetNextStr ( var S : string ;
                        Width : integer ;
                        Canvas : TCanvas ) : string ;
  var
    pos, lastgood : integer ;
  begin
    lastgood := 0 ;
    pos := 0 ;
    S := DeleteStartingDividers ( S ) ;
    { ����� ���������� ������, ���� ��� �� �������� �������� ������ }
    while CheckWidth ( copy ( S, 1, pos ), Canvas ) <= Width do
    begin
      inc ( pos ) ;
      { ������ ������ - ����� ������ }
      if pos > length ( S ) then
      begin
        lastgood := pos - 1 ;
        if lastgood <= 0 then lastgood := 1 ;
        break ;
      end ;
      { �������� �������� ��������� ��������� ������� }
      if S [ pos ] = Divider
        then lastgood := pos ;
    end ;
    { ������ ������� ������������ ����� }
    Result := DeleteDividers ( copy ( S, 1, lastgood )) ;
    if Result = '' { ���-�� ������������� �� ������� �� ������ } then
    begin
      lastgood := pos - 1 ;
      if lastgood <= 0 then lastgood := 1 ;
      Result := DeleteDividers ( copy ( S, 1, lastgood )) ;
    end ;
    { �������� ������������ ������� ������ }
    Delete ( S, 1, lastgood ) ;
    { ���� �� ��� ������� �����, ���� ��������� ���� �������� }
    if ( S <> '' ) and RussianLetterOrDivider ( Result [ length ( Result )]) and
       RussianLetterOrDivider ( S [ 1 ])
      then Result := Result + '-' ;
    { � ������ ������ }
//    Result := Trim ( Result ) ;
  end ;

  var
    ResStr, DivStr : string ;
    p, typ : integer ;

begin
  Res.Clear ;
  ResStr := '' ;
  { ���� ��������� �������� ��� ������ }
//  Para := Trim ( Para ) ;
  if length ( Para ) = 0 then exit ;
  { ������ ���� ���������� � ������ ��������� �������� }
  while Para <> '' do
  begin
    GetNextWord ( Para, DivStr, typ ) ;
    case typ of
      typNoHyph : begin
          if DivStr [ 1 ] in [ '(', '[', ' ' ]
            then ResStr := ResStr + Divider ;
          ResStr := ResStr + DivStr ;
          if not ( DivStr [ length ( DivStr ) ] in [ '(', '[', '"', '''' ] )
            then ResStr := ResStr + Divider ;
        end ;
      typHyph   : begin
          DivStr := PlaceHyphens ( DivStr ) ;
          { ��������� ���� ������ �������� }
          repeat
            p := Pos ( '-', DivStr ) ;
            if p <> 0 then DivStr [ p ] := Divider ;
          until p = 0 ;
          ResStr := ResStr + DivStr ;
        end ;
    end ;
  end ;
  { �������� ������� ������ �������� ������ � ��������� }
  while ResStr <> '' do
  begin
    DivStr := GetNextStr ( ResStr, Width, Canvas ) ;
    if DivStr <> '' then Res.Add ( DivStr ) ;
  end ;
end ;

var
  MLText : TStringList = nil ;

{ ����� ������ � ��������������� ��� �������� ������������� }
function DrawMultilineText ( Text : string ;
                             Canvas : TCanvas ;
                             Rect : TRect ;
                             HAlignment : THAlignment ;
                             VAlignment : TVAlignment ;
                             VMargin : integer ) : integer ;
var
  LineHeight, LineWidth, i, Width, Height, RealHeight, shift, vshift : integer ;
  Line : string ;
  R : TRect ;
begin
  Result := Rect.Top ;
  HyphenParagraph ( Text, MLText, Rect.Right - Rect.Left, Canvas ) ;
  if MLText.Count = 0 then exit ;
  LineHeight := Canvas.TextHeight ( 'Hp' ) ;
  Width := Rect.Right - Rect.Left ;
  Height := Rect.Bottom - Rect.Top ;
  RealHeight := MLText.Count * ( LineHeight + VMargin ) - VMargin ;
  case VAlignment of
    tavBottom : vshift := Height - RealHeight ;
    tavCenter : vshift := ( Height - RealHeight ) div 2 ;
    else vshift := 0 ;
  end ;
  if vshift < 0 then vshift := 0 ;
  for i := 0 to MLText.Count - 1 do
  begin
    R.Top := Rect.Top + i * ( LineHeight + VMargin ) + vshift ;
    R.Left := Rect.Left ;
    R.Right := Rect.Right ;
    R.Bottom := R.Top + LineHeight ;
    if R.Bottom > Rect.Bottom then break ;
    Line := MLText [ i ] ;
    LineWidth := Canvas.TextWidth ( Line ) ;
    case HAlignment of
      tahRight  : shift := Width - LineWidth ;
      tahCenter : shift := ( Width - LineWidth ) div 2 ;
      else shift := 0 ;
    end ;
    Canvas.TextRect ( R, R.Left + shift, R.Top, Line ) ;
    Result := R.Bottom ;
  end ;
end ;

initialization
  MLText := TStringList.Create ;

finalization
  FreeAndNil ( MLText ) ;

end.
