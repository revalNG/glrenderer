unit uText;

interface

uses
  uRenderable,
  dfHRenderer, dfMath;

type
  TdfText = class(Tdf2DRenderable, IdfText)
  private
    vp: TdfViewportParams;
    FFont: IdfFont;
    FText: String;
  protected
    function GetFont(): IdfFont;
    procedure SetFont(aFont: IdfFont);
    function GetText(): String;
    procedure SetText(aText: String);

//    function GetWidth(): Single; override;
    procedure SetWidth(const aWidth: Single); override;
//    function GetHeight(): Single; override;
    procedure SetHeight(const aHeight: Single); override;

    procedure RecalcCoords(); override;
  public

    destructor Destroy; override;

    property Font: IdfFont read GetFont write SetFont;
    property Text: String read GetText write SetText;

    procedure DoRender(); override;

//    property Width: Single read GetWidth write SetWidth;
//    property Height: Single read GetHeight write SetHeight;
  end;

implementation

uses
  dfHGL, uRenderer;

{ TdfText }

destructor TdfText.Destroy;
begin
  FFont := nil;
  inherited;
end;

procedure TdfText.DoRender;
begin
  inherited;
  if not Assigned(FFont) then
    Exit();

  gl.MatrixMode(GL_PROJECTION);
  gl.PushMatrix();
  gl.LoadIdentity();
  vp := TheRenderer.Camera.GetViewport();
  gl.Ortho(vp.X, vp.W, vp.H, vp.Y, -1, 1);
  gl.MatrixMode(GL_MODELVIEW);
  gl.LoadIdentity();
  gl.Translatef(FPos.x, FPos.y, 0);
  gl.Rotatef(FRot, 0, 0, 1);
  gl.Disable(GL_DEPTH_TEST);
  gl.Disable(GL_LIGHTING);

  FFont.PrintText(FText);
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

function TdfText.GetFont: IdfFont;
begin
  Result := FFont;
end;

function TdfText.GetText: String;
begin
  Result := FText;
end;

procedure TdfText.RecalcCoords;
begin
  //inherited;

end;

procedure TdfText.SetFont(aFont: IdfFont);
begin
  FFont := aFont;
end;

procedure TdfText.SetHeight(const aHeight: Single);
begin
  inherited;
end;

procedure TdfText.SetText(aText: String);
begin
  FText := aText;
end;

procedure TdfText.SetWidth(const aWidth: Single);
begin
  inherited;
end;

end.
