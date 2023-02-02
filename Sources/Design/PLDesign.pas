unit PLDesign;

interface

uses
//  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
//  Dialogs, Menus, ImgList, ComCtrls, ToolWin, ActnList, StdCtrls,
  DesignIntf, DesignWindows,
  SysUtils,
  System.Classes, System.ImageList, System.Actions,
  Vcl.Forms, Vcl.Dialogs, Vcl.ImgList, Vcl.Controls, Vcl.Menus,
  Vcl.ActnList, Vcl.ComCtrls, Vcl.ToolWin, Vcl.StdCtrls,
  aOPCProvider;

type
  TProvidersDesigner = class;
  TProvidersDesignerClass = class of TProvidersDesigner;

  TProvidersEditor = class(TDesignWindow)
    ListBoxProviders: TListBox;
    ActionList1: TActionList;
    aAdd: TAction;
    aDelete: TAction;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ImageList1: TImageList;
    ToolButton2: TToolButton;
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    aNew: TAction;
    ToolButton3: TToolButton;
    N3: TMenuItem;
    procedure ListBoxProvidersClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure aNewExecute(Sender: TObject);
    procedure aAddExecute(Sender: TObject);
    procedure aDeleteExecute(Sender: TObject);
  private
    FLastObjectID : string;

    FProviderList : TaOPCProviderList;
    FPLDesigner : TProvidersDesigner;
    FPLDesignerClass : TProvidersDesignerClass;

    procedure UpdateList;
    procedure UpdateSelection;
    procedure SetProviderList(const Value: TaOPCProviderList);
  protected
    function UniqueName(Component: TComponent): string; override;
  public

    property ProviderList: TaOPCProviderList read FProviderList write SetProviderList;
    property PLDesignerClass: TProvidersDesignerClass read FPLDesignerClass write FPLDesignerClass;
    property PLDesigner: TProvidersDesigner read FPLDesigner;

  end;


  TProvidersDesigner = class(TaOPCProviderListDesigner)
  private
    FProvidersEditor: TProvidersEditor;
  public
    destructor Destroy; override;
    procedure DataEvent(Event: TDataEvent; Info: Longint); override;

    property ProvidersEditor: TProvidersEditor read FProvidersEditor;
  end;


procedure ShowProvidersEditor(Designer: IDesigner; aProviderList: TaOPCProviderList;
  DesignerClass: TProvidersDesignerClass);
function CreateProvidersEditor(Designer: IDesigner; aProviderList: TaOPCProviderList;
  DesignerClass: TProvidersDesignerClass): TProvidersEditor;


implementation

{$R *.dfm}

uses
  aOPCSource, aOPCConsts,
  uDCObjects,
  PathPEForm;

procedure ShowProvidersEditor(Designer: IDesigner; aProviderList: TaOPCProviderList;
  DesignerClass: TProvidersDesignerClass);
var
  ProvidersEditor: TProvidersEditor;
begin
  ProvidersEditor := CreateProvidersEditor(Designer, aProviderList, DesignerClass);
  if ProvidersEditor <> nil then
    ProvidersEditor.Show;
end;


function CreateProvidersEditor(Designer: IDesigner; aProviderList: TaOPCProviderList;
  DesignerClass: TProvidersDesignerClass): TProvidersEditor;
begin
  if aProviderList.Designer <> nil then
  begin
    Result := (aProviderList.Designer as TProvidersDesigner).ProvidersEditor;
  end
  else
  begin
    Result := TProvidersEditor.Create(Application);
    Result.PLDesignerClass := DesignerClass;
    Result.Designer := Designer;
    Result.ProviderList := aProviderList;
    Result.UpdateList;
  end;
end;

function CreateUniqueName(aName: string; ProviderList: TaOPCProviderList;
  Component: TComponent): string;
var
  I: Integer;
  tmpName: string;

  function GetEnVarName(aName:string):string;
  var
    i:integer;
    ch: char;
  begin
    Result := Trim(aName);
    i:=1;
    while i <= Length(Result) do
    begin
      ch := Result[i];
      if (not (ch in ['0'..'9','a'..'z','A'..'Z'])) or
        ((ch in ['0'..'9']) and (i=1)) then
      begin
        if (i>1) and (Result[i-1]<>'_') then
        begin
          Result[i] := '_';
          inc(i);
        end
        else
          Delete(Result,i,1);
      end
      else
        inc(i);
    end;
  end;


  function IsUnique(const AName: string): Boolean;
  var
    I: Integer;
  begin
    Result := False;
    with ProviderList.Owner do
      for I := 0 to ComponentCount - 1 do
        if (Component <> Components[i]) and (CompareText(AName, Components[I].Name) = 0) then Exit;
    Result := True;
  end;

begin
  tmpName := GetEnVarName(aName);
  if tmpName <> '' then
  begin
    if IsUnique(tmpName) then
    begin
      Result := tmpName;
      Exit;
    end
  end
  else
    tmpName := Copy(Component.ClassName,2,Length(Component.ClassName));

  for I := 1 to MaxInt do
  begin
    Result := Format('%s%d', [tmpName, I]);
    if IsUnique(Result) then Exit;
  end;
end;


procedure TProvidersEditor.aAddExecute(Sender: TObject);
var
  i:integer;
  OPCSource:TaOPCSource;

  aParent: TTreeNode;
  aParentName: string;

  aName   : string;
  Data    : TStringList;
  StairsCase: integer;
  sStairs : string;

  aProvider: TaOPCProviderItem;

  function FullName(aNode:TTreeNode):string;
  begin
    if Assigned(aNode) then
      if Assigned(aNode.Parent) then
        Result := FullName(aNode.Parent)+'.'+aNode.Text
      else
        Result := aNode.Text;
  end;

begin
  if not Assigned(ProviderList.OPCSource) then
  begin
    ShowMessage('Не выбран источник данных OPCSource.');
    exit;
  end;
  OPCSource := ProviderList.OPCSource;

  TreeForm := TTreeForm.Create(Application);

  OPCSource.GetNameSpace;//(0);
  TreeForm.LoadTree(TreeForm.SensorsTree.Items,OPCSource.FNameSpaceCash,FLastObjectID);
  TreeForm.SensorsTree.MultiSelectStyle := [msControlSelect,msShiftSelect];
  TreeForm.SensorsTree.MultiSelect := true;
  TreeForm.SensorsTree.OnDblClick := nil;

  if TreeForm.ShowModal = mrOk then
  begin
    for i := 0 to TreeForm.SensorsTree.SelectionCount-1 do
    begin
      // определим параметры датчика
      Data := TStringList(TreeForm.SensorsTree.Selections[i].Data);

      if (Data.Strings[1] = '0') then // это датчик
      begin
        // определим английское наименование родителя
        aParentName := '';
        aParent := TreeForm.SensorsTree.Selections[i].Parent;
        if Assigned(aParent) then
        begin
          if TStringList(aParent.Data).Count >= 4 then
            aParentName := TStringList(aParent.Data).Strings[3];
        end;

        aProvider := TaOPCProviderItem.Create(ProviderList.Owner);

        aProvider.PhysID := Data.Strings[0];
        sStairs := Data.Strings[5]; //stairs
        StairsCase := StrToIntDef(sStairs,0);
        case StairsCase of
          0:aProvider.StairsOptions := [soIncrease,soDecrease];
          1:aProvider.StairsOptions := [];
          2:aProvider.StairsOptions := [soIncrease];
          3:aProvider.StairsOptions := [soDecrease];
        end;
        //aProvider.Hint := FullName(TreeForm.SensorsTree.Selections[i]); // наименование

        aProvider.OPCSource := ProviderList.OPCSource;

        if Data.Count>=8 then
          aName := Data.Strings[7]
        else
          aName := '';

        aName := Trim(aName);
        if aName='_' then
          aName := '';

        if (aName<>'') and (aParentName<>'') then
          aName := aParentName+'_'+aName;

        aProvider.Name := CreateUniqueName(aName, ProviderList, aProvider);

        ProviderList.AddProvider(aProvider);
        FLastObjectID := aProvider.PhysID;
        //ListBoxProviders.AddItem(aProvider.Name,aProvider);
      end;
    end;

  end;

end;

procedure TProvidersEditor.aDeleteExecute(Sender: TObject);
var
  i:integer;
  List: TList;
begin
  List := TList.Create;
  try
    for i := 0 to ListBoxProviders.Count - 1 do
      if ListBoxProviders.Selected[i] then
      begin
        ListBoxProviders.Selected[i] := false;
        List.Add(ListBoxProviders.Items.Objects[i]);
      end;

    with List do
      for i := 0 to Count-1 do
        TObject(Items[i]).Free;
  finally
    List.Free;
  end;
end;

procedure TProvidersEditor.aNewExecute(Sender: TObject);
var
  aProvider: TaOPCProviderItem;
begin
  aProvider := TaOPCProviderItem.Create(ProviderList.Owner);
  aProvider.Name := UniqueName(aProvider);
  ProviderList.AddProvider(aProvider);
//  ListBoxProviders.AddItem(aProvider.Name,aProvider);
end;

procedure TProvidersEditor.FormDestroy(Sender: TObject);
begin
  if FPLDesigner <> nil then
  begin
    { Destroy the designer if the editor is destroyed }
    FPlDesigner.FProvidersEditor := nil;
    FPlDesigner.Free;
  end;

end;

procedure TProvidersEditor.ListBoxProvidersClick(Sender: TObject);
begin
  UpdateSelection;
end;

procedure TProvidersEditor.SetProviderList(const Value: TaOPCProviderList);
begin
  if FProviderList <> Value then
  begin
    if FProviderList <> nil then
      FreeAndNil(FPlDesigner);
    FProviderList := Value;
    if FProviderList <> nil then
    begin
      FPlDesigner := PLDesignerClass.Create(Value);
      FPlDesigner.FProvidersEditor := Self;
//      FPlDesigner.InitializeMenu(LocalMenu);
//      UpdateDisplay;
    end
    else
      Release;
  end;
end;

function TProvidersEditor.UniqueName(Component: TComponent): string;
begin
  Result := CreateUniqueName(Component.ClassName, ProviderList, Component)
end;

procedure TProvidersEditor.UpdateList;
var
  i:integer;
begin
  ListBoxProviders.Clear;
  if Assigned(ProviderList) then
  begin
    for i := 0 to ProviderList.ProviderCount - 1 do
    begin
      ListBoxProviders.AddItem(ProviderList.Providers[i].Name,ProviderList.Providers[i]);
    end;
  end;
end;

procedure TProvidersEditor.UpdateSelection;
var
  I: Integer;
  aProvider: TaOPCProvider;
  ComponentList: IDesignerSelections;
begin
  if Active then
  begin
    ComponentList := TDesignerSelections.Create;
    try
      with ListBoxProviders do
        for I := 0 to Items.Count - 1 do
          if Selected[I] then
          begin
            aProvider := TaOPCProvider(Items.Objects[I]);
            if aProvider <> nil then
              ComponentList.Add(aProvider);
          end;
      if ComponentList.Count = 0 then
        ComponentList.Add(ProviderList);
    except
      raise;
    end;
    Designer.SetSelections(ComponentList);
  end;
end;

{ TProvidersDesigner }

procedure TProvidersDesigner.DataEvent(Event: TDataEvent; Info: Integer);
begin
  if Event = deProviderListChange then
    FProvidersEditor.UpdateList;
end;

destructor TProvidersDesigner.Destroy;
begin
  if FProvidersEditor <> nil then
  begin
    FProvidersEditor.FPLDesigner := nil;
    FProvidersEditor.Release;
  end;
  inherited Destroy;
end;

end.
