unit uMaterial;

interface

uses
  dfHRenderer;

type
  TdfMaterial = class(TInterfacedObject, IdfMaterial)
  private
    FTexture: IdfTexture;
    FShader: IdfShaderProgram;
    FOptions: IdfMaterialOptions;
  protected
    function GetTexture: IdfTexture;
    procedure SetTexture(aTexture: IdfTexture);
    function GetShader(): IdfShaderProgram;
    procedure SetShader(aShader: IdfShaderProgram);
    function GetOptions(): IdfMaterialOptions;
    procedure SetOptions(aOptions: IdfMaterialOptions);
  public
    property Texture: IdfTexture read GetTexture write SetTexture;
    property ShaderProgram: IdfShaderProgram read GetShader write SetShader;
    property MaterialOptions: IdfMaterialOptions read GetOptions write SetOptions;

    procedure Apply();
    procedure Unapply();
  end;

implementation

{ TdfMaterial }

procedure TdfMaterial.Apply;
begin
  if Assigned(FTexture) then
    FTexture.Bind();
  //*
end;

function TdfMaterial.GetOptions: IdfMaterialOptions;
begin
  Result := FOptions;
end;

function TdfMaterial.GetShader: IdfShaderProgram;
begin
  Result := FShader;
end;

function TdfMaterial.GetTexture: IdfTexture;
begin
  Result := FTexture;
end;

procedure TdfMaterial.SetOptions(aOptions: IdfMaterialOptions);
begin
  FOptions :=  aOptions;
end;

procedure TdfMaterial.SetShader(aShader: IdfShaderProgram);
begin
  FShader := aShader;
end;

procedure TdfMaterial.SetTexture(aTexture: IdfTexture);
begin
  FTexture := aTexture;
end;

procedure TdfMaterial.Unapply;
begin
  if Assigned(FTexture) then
    FTexture.Unbind;
  //*
end;

end.
