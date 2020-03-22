{*******************************************************}
{                                                       }
{     Copyright (c) 2001-2017 by Alex A. Lagodny        }
{                                                       }
{*******************************************************}

unit aOPCImageList;

{$I VCL.DC.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  aCustomOPCSource, aOPCClass, aOPCConsts
  , Vcl.Imaging.pngimage
  {$IFDEF GIF}
  ,Vcl.Imaging.GIFImg
  //,GifImage
  {$ENDIF}
  ;

type
  EPictureCollectionError = class(Exception);

  {  TPictureCollectionItem  }

  TPictureCollection = class;
  TaOPCCustomImageList = class;
  TPictureCollectionItem = class;

  TBeforChangePictureEvent = procedure(Sender: TObject; aItem:TPictureCollectionItem) of object;

  TOPCImageListChangeLink = class(TObject)
  private
    FSender: TaOPCCustomImageList;
    FOnChange: TNotifyEvent;
    FBeforChangePicture: TBeforChangePictureEvent;
  public
    destructor Destroy; override;

    procedure Change; dynamic;
    procedure ChangePicture(aItem:TPictureCollectionItem);

    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property BeforChangePicture: TBeforChangePictureEvent
      read FBeforChangePicture write FBeforChangePicture;
    property Sender: TaOPCCustomImageList read FSender write FSender;
  end;


  TPictureCollectionItem = class(THashCollectionItem)
  private
    FPicture: TPicture;
    FTransparent: Boolean;
    FTransparentColor: TColor;
    function GetPictureCollection: TPictureCollection;
    procedure SetPicture(Value: TPicture);
    procedure SetTransparentColor(Value: TColor);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    property PictureCollection: TPictureCollection read GetPictureCollection;
  published
    property Picture: TPicture read FPicture write SetPicture;
    property Transparent: Boolean read FTransparent write FTransparent;
    property TransparentColor: TColor read FTransparentColor write SetTransparentColor;
  end;

  {  TPictureCollection  }

  TPictureCollection = class(THashCollection)
  private
    FOwner: TPersistent;
    function GetItem(Index: Integer): TPictureCollectionItem;
  protected
    function GetOwner: TPersistent; override;
  public
    constructor Create(AOwner: TPersistent);
    destructor Destroy; override;
    function Find(const Name: string): TPictureCollectionItem;
    procedure LoadFromFile(const FileName: string);
    procedure LoadFromStream(Stream: TStream);
    procedure SaveToFile(const FileName: string);
    procedure SaveToStream(Stream: TStream);
    property Items[Index: Integer]: TPictureCollectionItem read GetItem; default;
  end;


  {  TaOPCCustomImageList  }

  TaOPCCustomImageList = class(TComponent)
  private
    FChanged: Boolean;
    FUpdateCount: Integer;
    FClients: TList;

    FItems: TPictureCollection;
    FOnChange: TNotifyEvent;
    FBeforChangePicture: TBeforChangePictureEvent;
    procedure SetItems(Value: TPictureCollection);

  protected
    procedure Change; dynamic;
    procedure ChangePicture(aItem: TPictureCollectionItem);
  public
    procedure BeginUpdate;
    procedure EndUpdate;

    procedure RegisterChanges(Value: TOPCImageListChangeLink);
    procedure UnRegisterChanges(Value: TOPCImageListChangeLink);

    constructor Create(AOnwer: TComponent); override;
    destructor Destroy; override;
    property Items: TPictureCollection read FItems write SetItems;
  published
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property BeforChangePicture: TBeforChangePictureEvent
      read FBeforChangePicture write FBeforChangePicture;
  end;


  {  TaOPCImageList  }

  TaOPCImageList = class(TaOPCCustomImageList)
  published
    property Items;
  end;


implementation

{  TPictureCollectionItem  }

constructor TPictureCollectionItem.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FPicture := TPicture.Create;
  FTransparent := True;
end;

destructor TPictureCollectionItem.Destroy;
var
  aImageList: TaOPCCustomImageList;
begin
  aImageList := TaOPCCustomImageList(Collection.Owner);

  aImageList.ChangePicture(Self);
  FPicture.Free;
  inherited Destroy;
  aImageList.Change;
end;

procedure TPictureCollectionItem.Assign(Source: TPersistent);
begin
  if Source is TPictureCollectionItem then
  begin
    FTransparent := TPictureCollectionItem(Source).FTransparent;
    FTransparentColor := TPictureCollectionItem(Source).FTransparentColor;

    FPicture.Assign(TPictureCollectionItem(Source).FPicture);

  end else
    inherited Assign(Source);
end;                         

function TPictureCollectionItem.GetPictureCollection: TPictureCollection;
begin
  Result := Collection as TPictureCollection;
end;

procedure TPictureCollectionItem.SetPicture(Value: TPicture);
begin
  TaOPCCustomImageList(Collection.Owner).ChangePicture(Self);

  FPicture.Assign(Value);
  if Picture.Graphic is TBitmap then
    TransparentColor := TBitmap(Picture.Graphic).TransparentColor;

  TaOPCCustomImageList(Collection.Owner).Change;

end;

procedure TPictureCollectionItem.SetTransparentColor(Value: TColor);
begin
  if Value<>FTransparentColor then
    FTransparentColor := Value;
end;


{  TPictureCollection  }

constructor TPictureCollection.Create(AOwner: TPersistent);
begin
  inherited Create(TPictureCollectionItem);
  FOwner := AOwner;
end;

destructor TPictureCollection.Destroy;
begin
  inherited Destroy;
end;

function TPictureCollection.GetItem(Index: Integer): TPictureCollectionItem;
begin
  Result := TPictureCollectionItem(inherited Items[Index]);
end;

function TPictureCollection.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

function TPictureCollection.Find(const Name: string): TPictureCollectionItem;
var
  i: Integer;
begin
  i := IndexOf(Name);
  if i=-1 then
    raise EPictureCollectionError.CreateFmt(SImageNotFound, [Name]);
  Result := Items[i];
end;

procedure TPictureCollection.LoadFromFile(const FileName: string);
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

type
  TPictureCollectionComponent = class(TComponent)
  private
    FList: TPictureCollection;
  published
    property List: TPictureCollection read FList write FList;
  end;


procedure TPictureCollection.LoadFromStream(Stream: TStream);
var
  Component: TPictureCollectionComponent;
begin
  Clear;
  Component := TPictureCollectionComponent.Create(nil);
  try
    Component.FList := Self;
    Stream.ReadComponentRes(Component);
  finally
    Component.Free;
  end;
end;

procedure TPictureCollection.SaveToFile(const FileName: string);
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(FileName, fmCreate);
  try
    SaveToStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TPictureCollection.SaveToStream(Stream: TStream);
var
  Component: TPictureCollectionComponent;
begin
  Component := TPictureCollectionComponent.Create(nil);
  try
    Component.FList := Self;
    Stream.WriteComponentRes('OPCPictureCollection', Component);
  finally
    Component.Free;
  end;
end;

{  TaOPCCustomImageList  }

procedure TaOPCCustomImageList.BeginUpdate;
begin
  Inc(FUpdateCount);
end;

procedure TaOPCCustomImageList.Change;
var
  i: Integer;
begin
  FChanged := True;
  if FUpdateCount > 0 then Exit;
  if FClients <> nil then
    for I := 0 to FClients.Count - 1 do
      TOPCImageListChangeLink(FClients[I]).Change;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TaOPCCustomImageList.ChangePicture(aItem: TPictureCollectionItem);
var
  i: Integer;
begin
  if FClients <> nil then
    for I := 0 to FClients.Count - 1 do
      TOPCImageListChangeLink(FClients[I]).ChangePicture(aItem);
  if Assigned(FBeforChangePicture) then FBeforChangePicture(Self,aItem);
end;

constructor TaOPCCustomImageList.Create(AOnwer: TComponent);
begin
  inherited Create(AOnwer);
  FClients := TList.Create;
  FItems := TPictureCollection.Create(Self);
end;

destructor TaOPCCustomImageList.Destroy;
//var
//  aItems: TPictureCollection;
begin

  while FClients.Count > 0 do
    UnRegisterChanges(TOPCImageListChangeLink(FClients.Last));

  FClients.Free;
  FClients := nil;

//  aItems := FItems;
  inherited Destroy;
  FreeAndNil(FItems);
//  aItems.Free;
end;

procedure TaOPCCustomImageList.EndUpdate;
begin
  if FUpdateCount > 0 then Dec(FUpdateCount);
  if FChanged then
  begin
    FChanged := False;
    Change;
  end;
end;

procedure TaOPCCustomImageList.RegisterChanges(Value: TOPCImageListChangeLink);
begin
  Value.Sender := Self;
  if FClients <> nil then FClients.Add(Value);
end;

procedure TaOPCCustomImageList.SetItems(Value: TPictureCollection);
begin
  FItems.Assign(Value);
end;


procedure TaOPCCustomImageList.UnRegisterChanges(
  Value: TOPCImageListChangeLink);
var
  I: Integer;
begin
  if FClients <> nil then
    for I := 0 to FClients.Count - 1 do
      if FClients[I] = Value then
      begin
        Value.Sender := nil;
        FClients.Delete(I);
        Break;
      end;
end;

{ TOPCImageListChangeLink }

procedure TOPCImageListChangeLink.Change;
begin
  if Assigned(OnChange) then OnChange(Sender);
end;

procedure TOPCImageListChangeLink.ChangePicture(aItem: TPictureCollectionItem);
begin
  if Assigned(FBeforChangePicture) then FBeforChangePicture(Sender,aItem);
end;

destructor TOPCImageListChangeLink.Destroy;
begin
  if Sender <> nil then Sender.UnRegisterChanges(Self);
  inherited Destroy;
end;

end.
