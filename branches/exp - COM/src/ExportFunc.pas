unit ExportFunc;

interface

uses
  Main, dfHRenderer, Node;

  function CreateRenderer(): IdfRenderer; stdcall;
  function CreateNode(aParent: IdfNode): IdfNode; stdcall;

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

function CreateNode(aParent: IdfNode): IdfNode;
begin
  if aParent = nil then
    Result := TdfNode.Create
  else
    Result := aParent.AddNewChild();
end;

end.
