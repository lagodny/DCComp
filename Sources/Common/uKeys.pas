unit uKeys;

interface

type
  TKeys = class
    // ветка текущего приложения
    class function Home: string;
    // ветка настроек приложения
    class function Main:string;

    // ветка подключений
    class function Connections:string;
    class function Connection(aConnectionName:string):string;

    // ветка пространства имён
    class function NameSpace(aConnectionName:string):string;
    // ветка справочников
    class function References(aConnectionName:string):string;
  end;


implementation

uses
  System.SysUtils,
  Forms;

{ TKeys }

class function TKeys.Connection(aConnectionName: string): string;
begin
  Result := TKeys.Connections + '\' + aConnectionName;
end;

class function TKeys.Connections: string;
begin
  Result := TKeys.Home+'\Connection';
end;

class function TKeys.Home: string;
var
  fn:string;
begin
  fn := ExtractFileName(Application.ExeName);
  fn := ChangeFileExt(fn,'');
  Result := '\Software\Monitoring\'+fn;
end;

class function TKeys.Main: string;
begin
  Result := TKeys.Home+'\Main';
end;

class function TKeys.NameSpace(aConnectionName: string): string;
begin
  Result := Format('%s\%s\NameSpace', [TKeys.Connections, aConnectionName]);
end;

class function TKeys.References(aConnectionName: string): string;
begin
  Result := Format('%s\%s\References', [TKeys.Connections, aConnectionName]);
end;


end.
