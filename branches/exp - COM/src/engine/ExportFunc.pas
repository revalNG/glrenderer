unit ExportFunc;

interface

uses
  dfHRenderer;

  function CreateRenderer(): IdfRenderer; stdcall;
  function CreateNode(aParent: IdfNode): IdfNode; stdcall;
  function CreateUserRender(): IdfUserRenderable; stdcall;
  function CreateHUDSprite(): IdfSprite; stdcall;
  function CreateMaterial: IdfMaterial; stdcall;
  function CreateTexture(): IdfTexture; stdcall;
  function CreateFont(): IdfFont; stdcall;
  function CreateText(): IdfText; stdcall;

  function CreateGUIButton(): IdfGUIButton; stdcall;

  function DestroyRenderer(): Integer; stdcall;

implementation

uses
  uRenderer, uNode, uUserRenderable,
  uSprite, uTexture, uMaterial, uFont, uText,
  uGUIButton;

function CreateRenderer(): IdfRenderer;
begin
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

function CreateUserRender(): IdfUserRenderable;
begin
  Result := TdfUserRenderable.Create();
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

function CreateGUIButton(): IdfGUIButton;
begin
  Result := TdfGUIButton.Create();
end;

function DestroyRenderer(): Integer;
begin
//  TheRenderer.Free;
  Exit(0);
end;

end.
