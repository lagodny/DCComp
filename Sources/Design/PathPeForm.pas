unit PathPeForm;

interface

uses
  System.ImageList, Vcl.forms, Vcl.ImgList, Vcl.Controls, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.ComCtrls, System.Classes, System.UITypes,
  SysUtils;
//  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
//  Dialogs, ComCtrls, StdCtrls, ExtCtrls, ImgList;

type
  TTreeForm = class(TForm)
    SensorsTree: TTreeView;
    pProperty: TPanel;
    Splitter1: TSplitter;
    gbSensorProperty: TGroupBox;
    Label6: TLabel;
    eStairs: TLabel;
    eSensorKind: TLabel;
    Label5: TLabel;
    Label4: TLabel;
    eUnitName: TLabel;
    eDisplayFormat: TLabel;
    Label3: TLabel;
    gbCommonProperty: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    eID: TLabel;
    eKind: TLabel;
    eObject: TLabel;
    ImageList1: TImageList;
    cbAllowSelectGroup: TCheckBox;
    Panel1: TPanel;
    bOK: TButton;
    bCancel: TButton;
    procedure SensorsTreeKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure SensorsTreeChange(Sender: TObject; Node: TTreeNode);
    procedure SensorsTreeDblClick(Sender: TObject);
  private
    function GetAllowSelectGroup: boolean;
    procedure SetAllowSelectGroup(const Value: boolean);
    { Private declarations }
  public
    destructor Destroy;override;
    procedure LoadTree(Owner:TTreeNodes;aList:TStrings; aID:string = '');

    property AllowSelectGroup:boolean read GetAllowSelectGroup
      write SetAllowSelectGroup default false;
    { Public declarations }
  end;

var
  TreeForm: TTreeForm;

implementation

uses
  DC.StrUtils;

{$R *.dfm}

function TTreeForm.GetAllowSelectGroup: boolean;
begin
  Result := cbAllowSelectGroup.Checked;
end;

procedure TTreeForm.LoadTree(Owner: TTreeNodes; aList: TStrings; aID:string = '');
var
  ANode, NextNode: TTreeNode;
  ALevel, i: Integer;
  CurrStr: string;
  Data: TStringList;
  StairsCase: integer;
  NodeAtID: TTreeNode;

begin
  Owner.BeginUpdate;
  try
    try
      ANode := nil;
      NodeAtID := nil;
      for i := 0 to aList.Count - 1 do
      begin
        CurrStr := GetBufStart(PChar(aList[i]), ALevel);
        // строим дерево
        if ANode = nil then
          ANode := Owner.AddChild(nil, ExtractData(CurrStr))
        else if ANode.Level = ALevel then
          ANode := Owner.AddChild(ANode.Parent, ExtractData(CurrStr))
        else if ANode.Level = (ALevel - 1) then
          ANode := Owner.AddChild(ANode, ExtractData(CurrStr))
        else if ANode.Level > ALevel then
        begin
          NextNode := ANode.Parent;
          while NextNode.Level > ALevel do
            NextNode := NextNode.Parent;
          ANode := Owner.AddChild(NextNode.Parent, ExtractData(CurrStr));
        end
        else
          raise Exception.CreateFmt('ALevel=%d - Node.Level=%d',[ALevel,ANode.Level]);

        Data := TStringList.Create;
        while CurrStr<>'' do
          Data.Add(ExtractData(CurrStr));

        if (not Assigned(NodeAtID)) and (Data.Strings[0] = aID) then
          NodeAtID := ANode;

        ANode.Data := Data;
        if (Data.Strings[1] = '1') or (Data.Count = 2) then // это группа
          ANode.StateIndex := 1
        else
        begin
          StairsCase := StrToIntDef(Data.Strings[5],0);
          case StairsCase of
            0:ANode.StateIndex := 2;
            1:ANode.StateIndex := 3;
            2:ANode.StateIndex := 4;
            3:ANode.StateIndex := 5;
          end;
        end;
      end;
      if not Assigned(NodeAtID) then
        NodeAtID := Owner.GetFirstNode;

      Owner.Owner.Selected := NodeAtID;
      if Assigned(NodeAtID) then
        NodeAtID.Expand(false);
    finally
      Owner.EndUpdate;
    end;
  except
    Owner.Owner.Invalidate;
    raise;
  end;
end;


procedure TTreeForm.SensorsTreeChange(Sender: TObject; Node: TTreeNode);
var
  Data:TStringList;
begin
  eObject.Caption := Node.Text;
  
  Data := TStringList(Node.Data);
  eID.Caption := Data.Strings[0];

  if Data.Strings[1] = '0' then  // это датчик
  begin
    eKind.Caption := 'Датчик';
    eDisplayFormat.Caption := Data.Strings[2];
    eUnitName.Caption := Data.Strings[3];
    eSensorKind.Caption := Data.Strings[4];
    eStairs.Caption := Data.Strings[5];
  end
  else
    eKind.Caption := 'Группа';

  gbSensorProperty.Visible := (Data.Strings[1]='0');
end;

procedure TTreeForm.SensorsTreeDblClick(Sender: TObject);
begin
  if SensorsTree.Selected<>nil then
    if AllowSelectGroup or (SensorsTree.Selected.Count = 0)  then
      ModalResult:=mrOk;
end;

procedure TTreeForm.SensorsTreeKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = vkReturn then
    SensorsTreeDblClick(self);
end;

procedure TTreeForm.SetAllowSelectGroup(const Value: boolean);
begin
  cbAllowSelectGroup.Checked := Value;
end;

destructor TTreeForm.Destroy;
var
  i: Integer;
begin
  try
    for i := 0 to SensorsTree.Items.Count - 1 do
      TObject(SensorsTree.Items[i].Data).Free;
  finally
    inherited;
  end;

end;

end.
