{

}
unit uSprite;

interface

uses
  dfMath, dfHRenderer, uRenderable;

type

  TdfHUDSprite = class(TdfRenderable, IdfSprite)
  private
    FWidth, FHeight: Single;
    FPos, FScale: TdfVec2f;
    FRot: Single;
    FPivot: Tdf2DPivotPoint;
    FCoords: array[0..3] of TdfVec2f;
    procedure RecalcCoords();
  protected
    function GetWidth(): Single;
    procedure SetWidth(const aWidth: Single);
    function GetHeight(): Single;
    procedure SetHeight(const aHeight: Single);
    function GetPos(): TdfVec2f;
    procedure SetPos(const aPos: TdfVec2f);
    function GetScale(): TdfVec2f;
    procedure SetScale(const aScale: TdfVec2f);
    function GetRot(): Single;
    procedure SetRot(const aRot: Single);
    function GetPivot(): Tdf2DPivotPoint;
    procedure SetPivot(const aPivot: Tdf2DPivotPoint);
  public
    constructor Create; virtual;
    destructor Destroy; override;

    property Width: Single read GetWidth write SetWidth;
    property Height: Single read GetHeight write SetHeight;

    procedure DoRender(); override;

    property Position: TdfVec2f read GetPos write SetPos;
    property Scale: TdfVec2f read GetScale write SetScale;
    procedure ScaleMult(const aScale: TdfVec2f);
    property Rotation: Single read GetRot write SetRot;
    property PivotPoint: Tdf2DPivotPoint read GetPivot write SetPivot;
  end;

implementation

uses
  dfHGL;


{ TdfHUDSprite }

constructor TdfHUDSprite.Create;
begin
  inherited;
  FWidth := 1;
  FHeight := 1;
  FPos := dfVec2f(0, 0);
  FScale := dfVec2f(1, 1);
  FRot := 0.0;
  FPivot := ppTopLeft;
  RecalcCoords();
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
  gl.Ortho(0, 800, 600, 0, -1, 1);
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

    // - GL_TRIANGLES
//    gl.TexCoord2f(1, 1);
//    gl.Vertex2fv(FCoords[0]);
//    gl.TexCoord2f(1, 0);
//    gl.Vertex2fv(FCoords[1]);
//    gl.TexCoord2f(0, 0);
//    gl.Vertex2fv(FCoords[2]);
//    gl.TexCoord2f(1, 1);
//    gl.Vertex2fv(FCoords[0]);
//    gl.TexCoord2f(0, 0);
//    gl.Vertex2fv(FCoords[2]);
//    gl.TexCoord2f(0, 1);
//    gl.Vertex2fv(FCoords[3]);

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

function TdfHUDSprite.GetHeight: Single;
begin
  Result := FHeight;
end;

function TdfHUDSprite.GetPivot: Tdf2DPivotPoint;
begin
  Result := FPivot;
end;

function TdfHUDSprite.GetPos: TdfVec2f;
begin
  Result := FPos;
end;

function TdfHUDSprite.GetRot: Single;
begin
  Result := FRot;
end;

function TdfHUDSprite.GetScale: TdfVec2f;
begin
  Result := FScale;
end;

function TdfHUDSprite.GetWidth: Single;
begin
  Result := FWidth;
end;

{TODO: улучшить быстродействие, не считать уже посчитанное}
procedure TdfHUDSprite.RecalcCoords;
begin
  case FPivot of
    ppTopLeft:
    begin
      FCoords[0] := dfVec2f(FWidth * FScale.x, FHeight * FScale.y);
      FCoords[1] := dfVec2f(FWidth * FScale.x, 0);
      FCoords[2] := dfVec2f(0, 0);
      FCoords[3] := dfVec2f(0, FHeight * FScale.y);
    end;
    ppTopRight:
    begin
      FCoords[0] := dfVec2f(0, FHeight * FScale.y);
      FCoords[1] := dfVec2f(0, 0);
      FCoords[2] := dfVec2f(-FWidth * FScale.x, 0);
      FCoords[3] := dfVec2f(-FWidth * FScale.x, FHeight * FScale.y);
    end;
    ppBottomLeft:
    begin
      FCoords[0] := dfVec2f(FWidth * FScale.x, 0);
      FCoords[1] := dfVec2f(FWidth * FScale.x, -FHeight * FScale.y);
      FCoords[2] := dfVec2f(0, -FHeight * FScale.y);
      FCoords[3] := dfVec2f(0, 0);
    end;
    ppBottomRight:
    begin
      FCoords[0] := dfVec2f(0, 0);
      FCoords[1] := dfVec2f(0, -FHeight * FScale.y);
      FCoords[2] := dfVec2f(-FWidth * FScale.x, -FHeight * FScale.y);
      FCoords[3] := dfVec2f(-FWidth * FScale.x, 0);
    end;
    ppCenter:
    begin
      FCoords[0] := dfVec2f(FWidth * FScale.x, FHeight * FScale.y) * 0.5;
      FCoords[1] := dfVec2f(FWidth * FScale.x, -FHeight * FScale.y) * 0.5;
      FCoords[2] := dfVec2f(-FWidth * FScale.x, -FHeight * FScale.y) * 0.5;
      FCoords[3] := dfVec2f(-FWidth * FScale.x, FHeight * FScale.y) * 0.5;
    end;
  end;
end;

procedure TdfHUDSprite.ScaleMult(const aScale: TdfVec2f);
begin
  FScale := FScale * aScale;
  RecalcCoords();
end;

procedure TdfHUDSprite.SetHeight(const aHeight: Single);
begin
  FHeight := aHeight;
  RecalcCoords();
end;

procedure TdfHUDSprite.SetPivot(const aPivot: Tdf2DPivotPoint);
begin
  if FPivot <> aPivot then
  begin
    FPivot := aPivot;
    RecalcCoords;
  end;
end;

procedure TdfHUDSprite.SetPos(const aPos: TdfVec2f);
begin
  FPos := aPos;
  RecalcCoords();
end;

procedure TdfHUDSprite.SetRot(const aRot: Single);
begin
  FRot := aRot;
  RecalcCoords();
end;

procedure TdfHUDSprite.SetScale(const aScale: TdfVec2f);
begin
  FScale := aScale;
  RecalcCoords();
end;

procedure TdfHUDSprite.SetWidth(const aWidth: Single);
begin
  FWidth := aWidth;
  RecalcCoords();
end;

end.
