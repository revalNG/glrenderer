{

}
unit uSprite;

interface

uses
  dfMath, dfHRenderer, uRenderable;

type

  TdfHUDSprite = class(Tdf2DRenderable, IdfSprite)
  private
    vp: TdfViewportParams;
//    FX, FY, FW, FH: Integer; //Размеры вьюпорта, получаем при создании спрайта
  protected
  public
    constructor Create; override;
    destructor Destroy; override;

    procedure DoRender(); override;
  end;

implementation

uses
  uRenderer, dfHGL;


{ TdfHUDSprite }

constructor TdfHUDSprite.Create;
begin
  inherited Create;
  FWidth := 1;
  FHeight := 1;
  FPos := dfVec2f(0, 0);
  FScale := dfVec2f(1, 1);
  FRot := 0.0;
  FPivot := ppTopLeft;
  RecalcCoords();

//  vp := TheRenderer.Camera.GetViewport();
//  FW := vp.W;
//  FH := vp.H;
//  FX := vp.X;
//  FY := vp.Y;
end;

destructor TdfHUDSprite.Destroy;
begin

  inherited;
end;

procedure TdfHUDSprite.DoRender;
begin
  inherited;
  gl.MatrixMode(GL_PROJECTION);
  gl.PushMatrix();
  gl.LoadIdentity();
  //Как получить размеры экрана??
  vp := TheRenderer.Camera.GetViewport();
  gl.Ortho(vp.X, vp.W, vp.H, vp.Y, -1, 1);
  gl.MatrixMode(GL_MODELVIEW);
  gl.LoadIdentity();
  gl.Translatef(FPos.x, FPos.y, 0);
  gl.Rotatef(FRot, 0, 0, 1);
  gl.Disable(GL_DEPTH_TEST);
  gl.Disable(GL_LIGHTING);
  gl.Beginp(GL_TRIANGLE_STRIP);
    gl.TexCoord2f(1, 1);
    gl.Vertex2fv(FCoords[0]);
    gl.TexCoord2f(1, 0);
    gl.Vertex2fv(FCoords[1]);
    gl.TexCoord2f(0, 0);
    gl.Vertex2fv(FCoords[2]);
    gl.TexCoord2f(0, 1);
    gl.Vertex2fv(FCoords[3]);
    gl.TexCoord2f(1, 1);
    gl.Vertex2fv(FCoords[0]);
  gl.Endp();

  {Debug - выводим pivot point}
{
  gl.PointSize(5);
  gl.Color3f(1, 1, 1);
  gl.Translatef(-FPos.x, -FPos.y, 0);
  gl.Beginp(GL_POINTS);
    gl.Vertex2fv(FPos);
  gl.Endp();

}

  gl.Enable(GL_LIGHTING);
  gl.Enable(GL_DEPTH_TEST);
  gl.MatrixMode(GL_PROJECTION);
  gl.PopMatrix();
  gl.MatrixMode(GL_MODELVIEW);
end;

end.
