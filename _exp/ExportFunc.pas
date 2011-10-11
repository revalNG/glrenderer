unit ExportFunc;

interface

uses
  Main, dfHRenderer;

  function CreateRenderer(): IdfRenderer; stdcall;

implementation

function CreateRenderer(): IdfRenderer;
begin
  //TheRenderer is declared in Main.pas module
  if not Assigned(TheRenderer) then
  begin
    TheRenderer := TdfRenderer.Create();
    Result := TheRenderer;
  end
  else
    Result := TheRenderer;
end;

end.
