unit DC.VCL.Form.NewMessage;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, VCL.Graphics,
  VCL.Controls, VCL.Forms, VCL.Dialogs, aOPCDataObject, aOPCLabel, VCL.Grids, VCL.StdCtrls, VCL.ComCtrls;

type
  TDCNewMessageForm = class(TForm)
    MsgGrid: TStringGrid;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure MsgGridDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure FormResize(Sender: TObject);
  private
    procedure ResizeLastColumn(Grid: TStringGrid);
    procedure AutoSizeRows(Grid: TStringGrid);

    procedure AddMessage(aTime: TDateTime; const aMessage: string);
  public
    class procedure ShowDlg(aTime: TDateTime; const aMessage: string; const aSoundFileName: string);
    class procedure HideDlg;
  end;

resourcestring
  sGridCaptionTime = 'Час';
  sGridCaptionMessage = 'Повідомлення';


implementation

uses
  System.Math,
  Winapi.MMSystem;

var
  DCNewMessageForm: TDCNewMessageForm;

{$R *.dfm}

{ TDCNewMessageForm }

procedure TDCNewMessageForm.AddMessage(aTime: TDateTime; const aMessage: string);
var
  aRow: Integer;
begin
  aRow := MsgGrid.RowCount;
  MsgGrid.RowCount := MsgGrid.RowCount + 1;
  MsgGrid.FixedRows := 1;
  MsgGrid.Cells[0, aRow] := FormatDateTime('hh:mm', aTime);
  MsgGrid.Cells[1, aRow] := aMessage;
  ResizeLastColumn(MsgGrid);
  AutoSizeRows(MsgGrid);
  MsgGrid.Row := aRow;
end;

procedure TDCNewMessageForm.FormClick(Sender: TObject);
begin
  Close;
end;

procedure TDCNewMessageForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // прибираємо всі повідомлення
  MsgGrid.RowCount := 1;
  // зупиняємо звук
  PlaySound(nil, 0, SND_NODEFAULT or SND_MEMORY);
  // ховаємо форму
  Action := caHide;
end;

procedure TDCNewMessageForm.ResizeLastColumn(Grid: TStringGrid);
var
  i, TotalWidth, TotalHeight, AvailableWidth: Integer;
begin
  // Ширина всієї таблиці без останнього стовпця
  TotalWidth := 0;
  for i := 0 to Grid.ColCount - 2 do
    Inc(TotalWidth, Grid.ColWidths[i]);

//  TotalHeight := 0;
//  for i := 0 to Grid.RowCount - 1 do
//    Inc(TotalHeight, Grid.RowHeights[i]);


  // Доступна ширина клієнтської області
  AvailableWidth := Grid.ClientWidth - TotalWidth;

  // Якщо є вертикальний скролбар — віднімаємо його ширину
//  if TotalHeight > Grid.ClientHeight then
    Dec(AvailableWidth, GetSystemMetrics(SM_CXVSCROLL));

  // Мінімальна ширина, щоб уникнути від'ємного значення
  if AvailableWidth < 20 then
    AvailableWidth := 20;

  Grid.ColWidths[Grid.ColCount - 1] := AvailableWidth;
end;

procedure TDCNewMessageForm.AutoSizeRows(Grid: TStringGrid);
var
  ACol, ARow: Integer;
  TextRect: TRect;
  TextHeight: Integer;
begin
  Grid.Canvas.Font := Grid.Font;

  for ARow := 0 to Grid.RowCount - 1 do
  begin
    TextHeight := Grid.Canvas.TextHeight('Hg'); // мінімальна висота

    for ACol := 0 to Grid.ColCount - 1 do
    begin
      TextRect := Rect(0, 0, Grid.ColWidths[ACol] - 8, 0); // -8 для відступів
      DrawText(Grid.Canvas.Handle,
               PChar(Grid.Cells[ACol, ARow]),
               -1,
               TextRect,
               DT_WORDBREAK or DT_CALCRECT or DT_LEFT);

      TextHeight := Max(TextHeight, TextRect.Height + 4);
    end;

    Grid.RowHeights[ARow] := TextHeight;
  end;
end;

procedure TDCNewMessageForm.FormCreate(Sender: TObject);
begin
  MsgGrid.ColCount := 2;
  MsgGrid.RowCount := 1; //4;
  MsgGrid.ColWidths[0] := 50;
  MsgGrid.ColWidths[1] := MsgGrid.Width - MsgGrid.ColWidths[0] - 50;
  MsgGrid.DefaultRowHeight := 36;
  MsgGrid.Cells[0, 0] := sGridCaptionTime;
  MsgGrid.Cells[1, 0] := sGridCaptionMessage;
//  MsgGrid.Cells[0, 1] := '10:11';
//  MsgGrid.Cells[1, 1] := 'Восстановлена связь с РПН 1. Выполните переключение.';
//  MsgGrid.Cells[0, 2] := '10:12';
//  MsgGrid.Cells[1, 2] := 'Еще одно сообщение';
//  MsgGrid.Cells[0, 3] := '10:10';
//  MsgGrid.Cells[1, 3] := 'Message 1';

  ResizeLastColumn(MsgGrid);
  AutoSizeRows(MsgGrid);
end;

procedure TDCNewMessageForm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_ESCAPE) or (Key = VK_RETURN) then
    Close;
end;

procedure TDCNewMessageForm.FormResize(Sender: TObject);
begin
  ResizeLastColumn(MsgGrid);
  AutoSizeRows(MsgGrid);
end;

class procedure TDCNewMessageForm.HideDlg;
begin
  if not Assigned(DCNewMessageForm) then
    Exit;

  DCNewMessageForm.Hide;
  PlaySound(nil, 0, SND_NODEFAULT or SND_MEMORY);
end;

class procedure TDCNewMessageForm.ShowDlg(aTime: TDateTime; const aMessage, aSoundFileName: string);
begin
  if not Assigned(DCNewMessageForm) then
    DCNewMessageForm := TDCNewMessageForm.Create(Application.MainForm);

//  DCNewMessageForm.lCaption.Caption := aCaption;
//  DCNewMessageForm.lMessage.Caption := aMessage;
  DCNewMessageForm.AddMessage(aTime, aMessage);
  DCNewMessageForm.Show;

  if FileExists(aSoundFileName) then
    PlaySound(PWideChar(aSoundFileName), 0, SND_ALIAS or SND_ASYNC or SND_NODEFAULT or SND_NOWAIT or SND_LOOP);
end;

procedure TDCNewMessageForm.MsgGridDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  TextStyle: TTextFormat;
  CellText: string;
  DrawRect: TRect;
begin
  with TStringGrid(Sender) do
  begin
    Canvas.FillRect(Rect); // очистка фону
    if gdFocused in State then
      MsgGrid.Canvas.DrawFocusRect(Rect);

    CellText := Cells[ACol, ARow];


    // Стиль тексту
    TextStyle := [tfWordBreak, tfVerticalCenter]; // перенос + вертикальне центр.

    if (ACol < 1) or (ARow < 1) then
      Include(TextStyle, tfCenter) // фіксовані комірки — горизонтально центр
    else
      Include(TextStyle, tfLeft); // інші — по лівому краю

    // Відступи зсередини комірки
    DrawRect := Rect;
    InflateRect(DrawRect, -4, -2);

    Canvas.TextRect(DrawRect, CellText, TextStyle);
  end;
end;

initialization
  DCNewMessageForm := nil;

end.
