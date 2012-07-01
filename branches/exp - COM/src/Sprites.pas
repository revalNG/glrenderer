{

}
unit Sprites;

interface

uses
  dfMath, dfHRenderer, uRenderable;

type

  TdfHUDSprite = class(TdfRenderable, IdfSprite)
  private
    FWidth, FHeight: Single;
  protected
    {debug - для проверки вывода спрайта, смещение вывода}
    Fdx, Fdy: Integer;
    {/debug}
    function GetWidth(): Single;
    procedure SetWidth(const aWidth: Single);
    function GetHeight(): Single;
    procedure SetHeight(const aHeight: Single);
  public
    property Width: Single read GetWidth write SetWidth;
    property Height: Single read GetHeight write SetHeight;

    procedure DoRender(); override;

    {debug - для проверки смещения вывода спрайта}
    procedure AddX(aX: Integer);
    procedure AddY(aY: Integer);
    function GetX: Integer;
    function GetY: Integer;
  end;

implementation

uses
  dfHGL;


{ TdfHUDSprite }

procedure TdfHUDSprite.AddX(aX: Integer);
begin
  Fdx := Fdx + aX;
end;

procedure TdfHUDSprite.AddY(aY: Integer);
begin
  Fdy := Fdy + aY;
end;

procedure TdfHUDSprite.DoRender;
begin
  inherited;
  gl.MatrixMode(GL_PROJECTION);
  gl.PushMatrix();
  gl.LoadIdentity();
  gl.Ortho(0, 800, 600, 0, -1, 1);
//  gl.Ortho(-8, 800, 630, 22, -1, 1);
  gl.MatrixMode(GL_MODELVIEW);
//  gl.LoadIdentity();
  gl.Disable(GL_DEPTH_TEST);
  gl.Disable(GL_LIGHTING);
  gl.Color3f(1, 0, 0);
  gl.Beginp(GL_TRIANGLE_STRIP);
//    gl.Vertex2f(0, FHeight);
//    gl.Vertex2f(0, 0);
//    gl.Vertex2f(FWidth, 0);
    gl.Vertex2f(FWidth, FHeight);
    gl.Vertex2f(FWidth, 0);
    gl.Vertex2f(0, 0);
    gl.Vertex2f(0, FHeight);
    gl.Vertex2f(FWidth, FHeight);

//    gl.Vertex2f(-0.5 * FWidth, -0.5 * FHeight);
//    gl.Vertex2f( 0.5 * FWidth, -0.5 * FHeight);
//    gl.Vertex2f( 0.5 * FWidth,  0.5 * FHeight);
  gl.Endp();
  gl.Enable(GL_LIGHTING);
  gl.Enable(GL_DEPTH_TEST);
  gl.MatrixMode(GL_PROJECTION);
  gl.PopMatrix();
  gl.MatrixMode(GL_MODELVIEW);
end;

function TdfHUDSprite.GetHeight: Single;
begin
  Result := FHeight;
end;

function TdfHUDSprite.GetWidth: Single;
begin
  Result := FWidth;
end;

function TdfHUDSprite.GetX: Integer;
begin
  Result := Fdx;
end;

function TdfHUDSprite.GetY: Integer;
begin
  Result := Fdy;
end;

procedure TdfHUDSprite.SetHeight(const aHeight: Single);
begin
  FHeight := aHeight;
end;

procedure TdfHUDSprite.SetWidth(const aWidth: Single);
begin
  FWidth := aWidth;
end;

end.
