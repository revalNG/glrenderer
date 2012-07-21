unit ExportFunc;

interface

uses
  dfHRenderer;

  function CreateRenderer(): IdfRenderer; stdcall;
  function CreateNode(aParent: IdfNode): IdfNode; stdcall;
  function CreateHUDSprite(): IdfSprite; stdcall;
  function CreateMaterial: IdfMaterial; stdcall;
  function CreateTexture(): IdfTexture; stdcall;
  function CreateFont(): IdfFont; stdcall;
  function CreateText(): IdfText; stdcall;

implementation

uses
  uRenderer, uNode, uSprite, uTexture, uMaterial, uFont, uText;

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

function CreateFont(): IdfFont;
begin
  Result := TdfFont.Create();
end;

function CreateText(): IdfText;
begin
  Result := TdfText.Create();
end;

end.
