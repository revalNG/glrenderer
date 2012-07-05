unit ExportFunc;

interface

uses
  dfHRenderer;

  function CreateRenderer(): IdfRenderer; stdcall;
  function CreateNode(aParent: IdfNode): IdfNode; stdcall;
  function CreateHUDSprite(): IdfSprite; stdcall;
  function CreateMaterial: IdfMaterial; stdcall;
  function CreateTexture(): IdfTexture; stdcall;

implementation

uses
  uRenderer, uNode, uSprite, uTexture, uMaterial;

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

function CreateHUDSprite(): IdfSprite;
begin
  Result := TdfHUDSprite.Create();
end;

function CreateMaterial(): IdfMaterial;
begin
  Result := TdfMaterial.Create();
end;

function CreateTexture(): IdfTexture;
begin
  Result := TdfTexture.Create();
end;

end.
