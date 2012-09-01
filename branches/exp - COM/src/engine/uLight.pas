{
  TODO:  1) Init, Step, DeInit
        +2) Основные функции для работы с источником света
         3) Анимация источника света
         4) Описание к функциям
}
unit uLight;

interface

uses
  dfHRenderer, uNode,
  dfMath;

const
  LIGHT_SIZE_Y = 0.4;
  LIGHT_SIZE_XZ = 0.10;

type
  TdfLight = class(TdfNode, IdfLight)
  private
    FAmb, FDif, FSpec: TdfVec4f;
    FCAtten, FLAtten, FQAtten: Single;
    FPos4: TdfVec4f;

    FDebugRender: Boolean;

    function GetAmb(): TdfVec4f;
    procedure SetAmb(const aAmb: TdfVec4f);
    function GetDif(): TdfVec4f;
    procedure SetDif(const aDif: TdfVec4f);
    function GetSpec(): TdfVec4f;
    procedure SetSpec(const aSpec: TdfVec4f);
    function GetConstAtten(): Single;
    procedure SetConstAtten(const aAtten: Single);
    function GetLinAtten(): Single;
    procedure SetLinAtten(const aAtten: Single);
    function GetQuadroAtten(): Single;
    procedure SetQuadroAtten(const aAtten: Single);
    function GetDR(): Boolean;
    procedure SetDR(aDR: Boolean);

    procedure DrawLight();
  protected
    procedure SetPos(const aPos: TdfVec3f); override;
  public
    constructor Create; override;

    property Ambient: TdfVec4f read GetAmb write SetAmb;
    property Diffuse: TdfVec4f read GetDif write SetDif;
    property Specular: TdfVec4f read GetSpec write SetSpec;

    property ConstAtten: Single read GetConstAtten write SetConstAtten;
    property LinearAtten: Single read GetLinAtten write SetLinAtten;
    property QuadraticAtten: Single read GetQuadroAtten write SetQuadroAtten;

    property DebugRender: Boolean read GetDR write SetDR;

    procedure Render(aDeltaTime: Single); override;
  end;

implementation

uses
  dfHGL;


{ TdfLight }

constructor TdfLight.Create;
begin
  inherited;
  gl.Enable(GL_LIGHT0);

  Ambient := dfVec4f(0.1, 0.1, 0.1, 1.0);
  Diffuse := dfVec4f(0.5, 0.5, 0.5, 1.0);
  Specular := dfVec4f(0.9, 0.9, 0.9, 1.0);
  ConstAtten := 1;
  LinearAtten := 1;
  QuadraticAtten := 1;
  Position := dfVec3f(0, 0, 0);
end;

procedure TdfLight.DrawLight;
begin
  gl.PushAttrib(GL_COLOR);
  gl.Color4f(FDif.x, FDif.y, FDif.z, FDif.w);
  gl.Disable(GL_LIGHTING);
  gl.Beginp(GL_TRIANGLES);
    gl.Vertex3f(FPos4.x - LIGHT_SIZE_XZ, FPos4.y, FPos4.z + LIGHT_SIZE_XZ);
    gl.Vertex3f(FPos4.x + LIGHT_SIZE_XZ, FPos4.y, FPos4.z + LIGHT_SIZE_XZ);
    gl.Vertex3f(FPos4.x, FPos4.y + LIGHT_SIZE_Y, FPos4.z);

    gl.Vertex3f(FPos4.x + LIGHT_SIZE_XZ, FPos4.y, FPos4.z + LIGHT_SIZE_XZ);
    gl.Vertex3f(FPos4.x + LIGHT_SIZE_XZ, FPos4.y, FPos4.z - LIGHT_SIZE_XZ);
    gl.Vertex3f(FPos4.x, FPos4.y + LIGHT_SIZE_Y, FPos4.z);

    gl.Vertex3f(FPos4.x + LIGHT_SIZE_XZ, FPos4.y, FPos4.z - LIGHT_SIZE_XZ);
    gl.Vertex3f(FPos4.x - LIGHT_SIZE_XZ, FPos4.y, FPos4.z - LIGHT_SIZE_XZ);
    gl.Vertex3f(FPos4.x, FPos4.y + LIGHT_SIZE_Y, FPos4.z);

    gl.Vertex3f(FPos4.x - LIGHT_SIZE_XZ, FPos4.y, FPos4.z - LIGHT_SIZE_XZ);
    gl.Vertex3f(FPos4.x - LIGHT_SIZE_XZ, FPos4.y, FPos4.z + LIGHT_SIZE_XZ);
    gl.Vertex3f(FPos4.x, FPos4.y + LIGHT_SIZE_Y, FPos4.z);



    gl.Vertex3f(FPos4.x + LIGHT_SIZE_XZ, FPos4.y, FPos4.z + LIGHT_SIZE_XZ);
    gl.Vertex3f(FPos4.x - LIGHT_SIZE_XZ, FPos4.y, FPos4.z + LIGHT_SIZE_XZ);
    gl.Vertex3f(FPos4.x, FPos4.y - LIGHT_SIZE_Y, FPos4.z);

    gl.Vertex3f(FPos4.x + LIGHT_SIZE_XZ, FPos4.y, FPos4.z - LIGHT_SIZE_XZ);
    gl.Vertex3f(FPos4.x + LIGHT_SIZE_XZ, FPos4.y, FPos4.z + LIGHT_SIZE_XZ);
    gl.Vertex3f(FPos4.x, FPos4.y - LIGHT_SIZE_Y, FPos4.z);

    gl.Vertex3f(FPos4.x - LIGHT_SIZE_XZ, FPos4.y, FPos4.z - LIGHT_SIZE_XZ);
    gl.Vertex3f(FPos4.x + LIGHT_SIZE_XZ, FPos4.y, FPos4.z - LIGHT_SIZE_XZ);
    gl.Vertex3f(FPos4.x, FPos4.y - LIGHT_SIZE_Y, FPos4.z);

    gl.Vertex3f(FPos4.x - LIGHT_SIZE_XZ, FPos4.y, FPos4.z + LIGHT_SIZE_XZ);
    gl.Vertex3f(FPos4.x - LIGHT_SIZE_XZ, FPos4.y, FPos4.z - LIGHT_SIZE_XZ);
    gl.Vertex3f(FPos4.x, FPos4.y - LIGHT_SIZE_Y, FPos4.z);

  gl.Endp;
  gl.Enable(GL_LIGHTING);
  gl.PopAttrib();
end;

function TdfLight.GetAmb: TdfVec4f;
begin
  Result := FAmb;
end;

function TdfLight.GetConstAtten: Single;
begin
  Result := FCAtten;
end;

function TdfLight.GetDif: TdfVec4f;
begin
  Result := FDif;
end;

function TdfLight.GetDR: Boolean;
begin
  Result := FDebugRender;
end;

function TdfLight.GetLinAtten: Single;
begin
  Result := FLAtten;
end;

function TdfLight.GetQuadroAtten: Single;
begin
  Result := FQAtten;
end;

function TdfLight.GetSpec: TdfVec4f;
begin
  Result := FSpec;
end;

procedure TdfLight.Render(aDeltaTime: Single);
begin
  if FDebugRender then
    DrawLight();

  inherited;
end;

procedure TdfLight.SetAmb(const aAmb: TdfVec4f);
begin
  FAmb := aAmb;
  gl.Lightfv(GL_LIGHT0, GL_AMBIENT, @FAmb);
end;

procedure TdfLight.SetConstAtten(const aAtten: Single);
begin
  FCAtten := aAtten;
  gl.Lightfv(GL_LIGHT0, GL_CONSTANT_ATTENUATION, @FCAtten);
end;

procedure TdfLight.SetDif(const aDif: TdfVec4f);
begin
  FDif := aDif;
  gl.Lightfv(GL_LIGHT0, GL_DIFFUSE, @FDif);
end;

procedure TdfLight.SetDR(aDR: Boolean);
begin
  FDebugRender := aDR;
end;

procedure TdfLight.SetLinAtten(const aAtten: Single);
begin
  FLAtten := aAtten;
  gl.Lightfv(GL_LIGHT0, GL_LINEAR_ATTENUATION, @FLAtten);
end;

procedure TdfLight.SetPos(const aPos: TdfVec3f);
begin
  inherited;
  FPos4 := dfVec4f(aPos);
  gl.Lightfv(GL_LIGHT0, GL_POSITION, @FPos4);
end;

procedure TdfLight.SetQuadroAtten(const aAtten: Single);
begin
  FQAtten := aAtten;
  gl.Lightfv(GL_LIGHT0, GL_QUADRATIC_ATTENUATION, @FQAtten);
end;

procedure TdfLight.SetSpec(const aSpec: TdfVec4f);
begin
  FSpec := aSpec;
  gl.Lightfv(GL_LIGHT0, GL_SPECULAR, @FSpec);
end;

end.
