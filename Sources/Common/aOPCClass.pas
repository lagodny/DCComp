{*******************************************************}
{                                                       }
{     Copyright (c) 2001-2012 by Alex A. Lagodny        }
{                                                       }
{*******************************************************}

unit aOPCClass;

interface

uses
  SysUtils, Classes;

type

  TDirection = (dNext,dPred);

  {  THashCollectionItem  }

  THashCollectionItem = class(TCollectionItem)
  private
    FHashCode: Integer;
    FIndex: Integer;
    FLeft: THashCollectionItem;
    FRight: THashCollectionItem;
    procedure AddHash;
    procedure DeleteHash;
  protected
    FName: string;
    procedure SetName(const Value: string);virtual;
    function GetDisplayName: string; override;
    procedure SetIndex(Value: Integer); override;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    property Index: Integer read FIndex write SetIndex;
  published
    property Name: string read FName write SetName;
  end;

  {  THashCollection  }

  THashCollection = class(TCollection)
  private
    FHash: array[0..255] of THashCollectionItem;
  public
    function IndexOf(const Name: string): Integer;
  end;

implementation

{  THashCollectionItem  }

function MakeHashCode(const Str: string): Integer;
var
  s: string;
begin
  s := AnsiLowerCase(Str);
  Result := Length(s)*16;
  if Length(s)>=2 then
    Result := Result + (Ord(s[1]) + Ord(s[Length(s)-1]));
  Result := Result and 255;
end;
               
constructor THashCollectionItem.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FIndex := inherited Index;
  AddHash;
end;

destructor THashCollectionItem.Destroy;
var
  i: Integer;
begin
  for i:=FIndex+1 to Collection.Count-1 do
    Dec(THashCollectionItem(Collection.Items[i]).FIndex);
  DeleteHash;
  inherited Destroy;
end;

procedure THashCollectionItem.Assign(Source: TPersistent);
begin
  if Source is THashCollectionItem then
  begin
    Name := THashCollectionItem(Source).Name;
  end else
    inherited Assign(Source);
end;

procedure THashCollectionItem.AddHash;
var
  Item: THashCollectionItem;
begin
  FHashCode := MakeHashCode(FName);

  Item := THashCollection(Collection).FHash[FHashCode];
  if Item<>nil then
  begin
    Item.FLeft := Self;
    Self.FRight := Item;
  end;

  THashCollection(Collection).FHash[FHashCode] := Self;
end;

procedure THashCollectionItem.DeleteHash;
begin
  if FLeft<>nil then
  begin
    FLeft.FRight := FRight;
    if FRight<>nil then
      FRight.FLeft := FLeft;
  end else
  begin
    if FHashCode<>-1 then
    begin
      THashCollection(Collection).FHash[FHashCode] := FRight;
      if FRight<>nil then
        FRight.FLeft := nil;
    end;
  end;
  FLeft := nil;
  FRight := nil;
end;

function THashCollectionItem.GetDisplayName: string;
begin
  Result := Name;
  if Result='' then Result := inherited GetDisplayName;
end;

procedure THashCollectionItem.SetIndex(Value: Integer);
begin
  if FIndex<>Value then
  begin
    FIndex := Value;
    inherited SetIndex(Value);
  end;
end;

procedure THashCollectionItem.SetName(const Value: string);
begin
  if FName<>Value then
  begin
    FName := Value;
    DeleteHash;
    AddHash;
  end;
end;

{  THashCollection  }

function THashCollection.IndexOf(const Name: string): Integer;
var
  Item: THashCollectionItem;
begin
  Item := FHash[MakeHashCode(Name)];
  while Item<>nil do
  begin
    if AnsiCompareText(Item.Name, Name)=0 then
    begin
      Result := Item.FIndex;
      Exit;
    end;
    Item := Item.FRight;
  end;
  Result := -1;
end;


end.
