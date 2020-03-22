////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                            Sanders the Softwarer                           //
//                                                                            //
//                   Расстановка переносов в русских словах,                  //
//                     форматирование и отрисовка абзацев                     //
//                                                                            //
///////////////////////////////////////////////// Author Sanders Prostorov /////

{ ----- Официоз ----------------------------------------------------------------

Любой желающий может распространять этот модуль, дорабатывать его, использовать
в собственных программных проектах, в том числе коммерческих, без необходимости
в дополнительных разрешениях от автора. В любой версии модуля должна сохраняться
информация об авторских правах и условиях распространения модуля.

При распространении доработанных версий модуля прошу изменить имя модуля и
базового класса для предотвращения коллизий между доработками различных авторов.

Если Вы сделали интересную доработку и согласны распространять ее на этих
условиях - сообщите о ней, и мы обговорим включение Вашей доработки в авторскую
версию модуля. Также прошу сообщать о найденных ошибках, если такие будут.

Автор: Sanders Prostorov, 2:5020/1583, softwarer@mail.ru, softwarer@nm.ru

------------------------------------------------------------------------------ }

{ ----- История модуля ---------------------------------------------------------

??.??.1998 Первая версия модуля. Реализован алгоритм переноса русских слов;
           модуль применен для кода печати грида (прообраза компонента
           TPrintGrid)
23.08.2006 Модуль приглажен и оформлен как общедоступный.

------------------------------------------------------------------------------ }

unit Hyphen ;

interface

uses Classes, Types, SysUtils, Graphics ;

type
  THAlignment = ( tahLeft, tahRight, tahCenter ) ;
  TVAlignment = ( tavTop, tavBottom, tavCenter ) ;

function PlaceHyphens ( Word : string ) : string ;
  { Расстановка возможных переносов в русском слове }

procedure HyphenParagraph ( Para   : string ;
                            Res    : TStrings ;
                            Width  : integer ;
                            Canvas : TCanvas ) ;
  { Расстановка переносов в абзаце в соответствии с шириной, канвасом и шрифтом }

function DrawMultilineText ( Text : string ;
                             Canvas : TCanvas ;
                             Rect : TRect ;
                             HAlignment : THAlignment ;
                             VAlignment : TVAlignment ;
                             VMargin : integer ) : integer ;
  { Вывод текста с форматированием под заданный прямоугольник }

implementation

type
  TCharSet = set of char ;

{ Расстановка возможных переносов в русском слове }
function PlaceHyphens ( Word : string ) : string ;
const
  Vocalics : TCharSet = [ 'а', 'е', 'ё', 'и', 'о', 'у', 'ы', 'э', 'ю', 'я' ] ;
var
  Syllables : array of byte ;
  i, c : integer  ;
  S    : string   ;
begin
  Result := Word ;
  if length ( Word ) <= 3 then exit ;
  SetLength ( Syllables, length ( Word ) + 1 ) ;
  { Переведем все в один регистр }
  S := AnsiLowerCase ( Word ) ;
  { Отыщем первую гласную }
  i := 1 ;
  while ( i <= length ( S )) and not ( S [ i ] in Vocalics ) do inc ( i ) ;
  if i > length ( S ) then exit ;
  { Отметим слоги номером предшествующей гласной }
  c := 0 ;
  repeat
    Syllables [ i ] := c ;
    inc ( i ) ;
    if S [ i ] in Vocalics then inc ( c ) ;
  until i >= length ( S ) ;
  { Слогу часто принадлежит и буква перед ним }
  for i := 1 to length ( S ) - 1 do
    if ( Syllables [ i ] <> Syllables [ i + 1 ]) and
       not ( S [ i ] in ( Vocalics + [ 'ъ', 'ь' ] ))
      then Syllables [ i ] := Syllables [ i + 1 ] ;
  { В начале и конце слова однобуквенные слоги сочтем частью соседа }
  Syllables [ 1 ] := Syllables [ 2 ] ;
  Syllables [ length ( S ) ] := Syllables [ length ( S ) - 1 ] ;
  { Проверим окончание на -ся }
  if copy ( S, length ( S ) - 1, 2 ) = 'ся' then
  begin
    Syllables [ length ( S ) ] := Syllables [ length ( S ) - 2 ] ;
    Syllables [ length ( S ) - 1 ] := Syllables [ length ( S ) - 2 ] ;
  end ;
  { Вот слово и разбито на слоги. Осталось сформировать результат }
  S := '' ;
  for i := 1 to length ( Word ) do
  begin
    S := S + Word [ i ] ;
    if ( i < length ( Word )) and ( Syllables [ i ] <> Syllables [ i + 1 ])
      then S := S + '-' ;
  end ;
  Result := S ;
end ;

{ Расстановка переносов в абзаце в соответствии с шириной, канвасом и шрифтом }
procedure HyphenParagraph ( Para   : string ;
                            Res    : TStrings ;
                            Width  : integer ;
                            Canvas : TCanvas ) ;

  const
    typHyph   =  1 ;
    typNoHyph =  2 ;
    Divider   = #1 ;

  function RussianLetter ( Ch : char ) : boolean ;
  const Lets = 'АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЬЫЪЭЮЯ' +
               'абвгдеёжзийклмнопрстуфхцчшщьыъэюя' ;
  begin
    RussianLetter := Pos ( Ch, Lets ) > 0 ;
  end ;

  function RussianLetterOrDivider ( Ch : char ) : boolean ;
  begin
    RussianLetterOrDivider := ( Ch = Divider ) or RussianLetter ( Ch ) ;
  end ;

  { Выделение очередной лексемы }
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

  { Удаление из строки знаков переноса }
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

  { Удаление из строки стартовых знаков переноса }
  function DeleteStartingDividers ( S : string ) : string ;
  begin
    while ( S <> '' ) and ( S [ 1 ] = Divider ) do Delete ( S, 1, 1 ) ;
    DeleteStartingDividers := S ;
  end ;

  { Определение ширины очередной строки }
  function CheckWidth ( S : string ; C : TCanvas ) : integer ;
  begin
    CheckWidth := C.TextWidth ( DeleteDividers ( S )) + C.TextWidth ( '-' ) ;
  end ;

  { Выделение очередной строки допустимой ширины }
  function GetNextStr ( var S : string ;
                        Width : integer ;
                        Canvas : TCanvas ) : string ;
  var
    pos, lastgood : integer ;
  begin
    lastgood := 0 ;
    pos := 0 ;
    S := DeleteStartingDividers ( S ) ;
    { Будем наращивать строку, пока она не превысит заданной ширины }
    while CheckWidth ( copy ( S, 1, pos ), Canvas ) <= Width do
    begin
      inc ( pos ) ;
      { Особый случай - конец строки }
      if pos > length ( S ) then
      begin
        lastgood := pos - 1 ;
        if lastgood <= 0 then lastgood := 1 ;
        break ;
      end ;
      { Осталось отметить очередной возможный перенос }
      if S [ pos ] = Divider
        then lastgood := pos ;
    end ;
    { Теперь выделим перенесенную часть }
    Result := DeleteDividers ( copy ( S, 1, lastgood )) ;
    if Result = '' { что-то непереносимое не влезает по ширине } then
    begin
      lastgood := pos - 1 ;
      if lastgood <= 0 then lastgood := 1 ;
      Result := DeleteDividers ( copy ( S, 1, lastgood )) ;
    end ;
    { Осталось сформировать остаток строки }
    Delete ( S, 1, lastgood ) ;
    { Если по обе стороны буквы, надо поставить знак переноса }
    if ( S <> '' ) and RussianLetterOrDivider ( Result [ length ( Result )]) and
       RussianLetterOrDivider ( S [ 1 ])
      then Result := Result + '-' ;
    { И убрать лишнее }
    Result := Trim ( Result ) ;
  end ;

  var
    ResStr, DivStr : string ;
    p, typ : integer ;

begin
  Res.Clear ;
  ResStr := '' ;
  { Чуть пригладим поданную нам строку }
  Para := Trim ( Para ) ;
  if length ( Para ) = 0 then exit ;
  { Теперь надо расставить в строке возможные переносы }
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
          { Установим наши значки переноса }
          repeat
            p := Pos ( '-', DivStr ) ;
            if p <> 0 then DivStr [ p ] := Divider ;
          until p = 0 ;
          ResStr := ResStr + DivStr ;
        end ;
    end ;
  end ;
  { Осталось разбить строку согласно ширине и переносам }
  while ResStr <> '' do
  begin
    DivStr := GetNextStr ( ResStr, Width, Canvas ) ;
    if DivStr <> '' then Res.Add ( DivStr ) ;
  end ;
end ;

var
  MLText : TStringList = nil ;

{ Вывод текста с форматированием под заданный прямоугольник }
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
