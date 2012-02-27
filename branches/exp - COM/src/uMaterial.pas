unit uMaterial;

interface

uses
  dfHRenderer;

type
  TdfMaterial = class(TInterfacedObject, IdfMaterial)
  private
  protected
    function GetTexture: IdfTexture;
    procedure SetTexture(const aTexture: IdfTexture);
    function GetShader(): IdfShaderProgram;
    procedure SetShader(const aShader: IdfShaderProgram);
    function GetOptions(): IdfMaterialOptions;
    procedure SetOptions(const aOptions: IdfMaterialOptions);
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

end;

function TdfMaterial.GetOptions: IdfMaterialOptions;
begin

end;

function TdfMaterial.GetShader: IdfShaderProgram;
begin

end;

function TdfMaterial.GetTexture: IdfTexture;
begin

end;

procedure TdfMaterial.SetOptions(const aOptions: IdfMaterialOptions);
begin

end;

procedure TdfMaterial.SetShader(const aShader: IdfShaderProgram);
begin

end;

procedure TdfMaterial.SetTexture(const aTexture: IdfTexture);
begin

end;

procedure TdfMaterial.Unapply;
begin

end;

end.
