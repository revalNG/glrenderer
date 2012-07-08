unit uMaterial;

interface

uses
  dfHRenderer, dfMath;

type
  TdfMaterialOptions = class(TInterfacedObject, IdfMaterialOptions)
  private
    FAmbColor, FDifColor: TdfVec4f;
    function GetDif(): TdfVec4f;
    procedure SetDif(const aDif: TdfVec4f);
    function GetAmb: TdfVec4f;
    procedure SetAmb(const aAmb: TdfVec4f);
  protected
  public
    constructor Create(); virtual;
    destructor Destroy; override;

    procedure Apply();
    procedure UnApply();

    property Ambient: TdfVec4f read GetAmb write SetAmb;
    property Diffuse: TdfVec4f read GetDif write SetDif;
  end;


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
    constructor Create(); virtual;
    destructor Destroy(); override;


    property Texture: IdfTexture read GetTexture write SetTexture;
    property ShaderProgram: IdfShaderProgram read GetShader write SetShader;
    property MaterialOptions: IdfMaterialOptions read GetOptions write SetOptions;

    procedure Apply();
    procedure Unapply();
  end;

implementation

uses
  dfHGL;

{ TdfMaterial }

procedure TdfMaterial.Apply;
begin
  if Assigned(FTexture) then
    FTexture.Bind();
  if Assigned(FOptions) then
    FOptions.Apply();
  if Assigned(FShader) then
    FShader.Use();
  //*
end;

constructor TdfMaterial.Create;
begin
  inherited;
  FOptions := TdfMaterialOptions.Create;
end;

destructor TdfMaterial.Destroy;
begin
  FOptions := nil;
  inherited;
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
  if Assigned(FOptions) then
    FOptions.Unapply();
  if Assigned(FShader) then
    FShader.Unuse();
end;

{ TdfMaterialOptions }

procedure TdfMaterialOptions.Apply;
begin
  gl.Color4fv(FDifColor);
end;

constructor TdfMaterialOptions.Create;
begin
  inherited;
  FDifColor := dfVec4f(0, 0, 0, 1);
end;

destructor TdfMaterialOptions.Destroy;
begin

  inherited;
end;

function TdfMaterialOptions.GetAmb: TdfVec4f;
begin
  Result := FAmbColor;
end;

function TdfMaterialOptions.GetDif: TdfVec4f;
begin
  Result := FDifColor;
end;

procedure TdfMaterialOptions.SetAmb(const aAmb: TdfVec4f);
begin
  FAmbColor := aAmb;
end;


procedure TdfMaterialOptions.SetDif(const aDif: TdfVec4f);
begin
  FDifColor := aDif;
end;

procedure TdfMaterialOptions.UnApply;
begin
  //* ???
end;

end.
