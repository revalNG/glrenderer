unit Camera;

interface

uses
  dfMath, dfHGL, dfHEngine, dfHInput, dfHRenderer, Node;

type
  TdfCameraTargetMode = (mPoint, mTarget, mFree);

  TdfCamera = class (TdfNode, IdfCamera)
  private
    FProjMatrix: TdfMat4f;
    FMode: TdfCameraTargetMode;
    FTargetPoint: TdfVec3f;
    FTarget: IdfNode;
    FFOV, FZNear, FZFar: Single;
  public
    procedure Viewport(x, y, w, h: Integer; FOV, ZNear, ZFar: Single);

    procedure Pan(X, Y: Single);
    procedure Scale(aScale: Single);
    procedure Rotate(delta: Single; Axis: TdfVec3f);

    procedure Update;

    procedure SetCamera(aPos, aTargetPos, aUp: TdfVec3f);
    procedure SetTarget(aPoint: TdfVec3f); overload;
    procedure SetTarget(aTarget: IdfNode); overload;
  end;

implementation

uses
  Windows;

procedure TdfCamera.Viewport(x, y, w, h: Integer; FOV, ZNear, ZFar: Single);
begin
  FFOV := FOV;
  FZNear := ZNear;
  FZFar := ZFar;
  gl.Viewport(x, y, w, h);
  FProjMatrix.Identity;
  FProjMatrix.Perspective(FOV, w / h, ZNear, ZFar);
  gl.MatrixMode(GL_PROJECTION);
  gl.LoadMatrixf(FProjMatrix);
end;

procedure TdfCamera.Pan(X, Y: Single);
var
  v: TdfVec3f;
begin
  v := Up * X * 0.01;
  v := v + Left * Y * 0.01;
  FModelMatrix.Translate(v);
end;

procedure TdfCamera.Scale(aScale: Single);
begin
  FModelMatrix.Scale(dfVec3f(aScale, aScale, aScale));
// Мастштабирование смещением камеры вперед:
//  ModelMatrix.Translate(dfVec3f(0,0,0) - (Direction * AScale));
end;

procedure TdfCamera.Update();
begin
//Вероятно, не нужно.
//  gl.MatrixMode(GL_PROJECTION);
//  gl.LoadMatrixf(FProjMatrix);
  gl.MatrixMode(GL_MODELVIEW);
  gl.MultMatrixf(FModelMatrix);
end;

procedure TdfCamera.Rotate(delta: Single; Axis: TdfVec3f);
begin
  FModelMatrix.Rotate(Delta, Axis);
end;

procedure TdfCamera.SetCamera(aPos, aTargetPos, aUp: TdfVec3f);
var
  vDir, vUp, vLeft, newPos: TdfVec3f;
begin
  FModelMatrix.Identity;
  vUp := aUp;
  vUp.Normalize;
  vDir := aPos - aTargetPos;
  vDir.Normalize;
  vLeft := vUp.Cross(vDir);
  vLeft.Negate;
  vLeft.Normalize;
  vUp := vDir.Cross(vLeft);
  vUp.Normalize;
  newPos := aPos;
  with FModelMatrix do
  begin
    e00 := vLeft.x;  e01 := vLeft.y;  e02 := vLeft.z;  e03 := -newpos.Dot(vLeft);
    e10 := vUp.x;    e11 := vUp.y;    e12 := vUp.z;    e13 := -newpos.Dot(vUp);
    e20 := vDir.x;   e21 := vDir.y;   e22 := vDir.z;   e23 := -newpos.Dot(vDir);
    e30 := 0;        e31 := 0;        e32 := 0;        e33 := 1;
  end;
  FTargetPoint := aTargetPos;
  FMode := mPoint;
end;

procedure TdfCamera.SetTarget(aPoint: TdfVec3f);
var
  vDir, vUp, vLeft: TdfVec3f;
begin
  FTargetPoint := aPoint;
  with FModelMatrix do
  begin
    vDir := Position - aPoint;
    vDir.Normalize;
    vUp := Up;
    vLeft := vDir.Cross(vUp);
    vLeft.Normalize;
    vUp :=vLeft.Cross(vDir);
    vUp.Normalize;
    vLeft.Negate;
    e00 := vLeft.x; e10 := vLeft.y; e20 := vLeft.z; e30 := 0;
    e01 := vUp.x;   e11 := vUp.y;   e21 := vUp.z;   e31 := 0;
    e02 := vDir.x;  e12 := vDir.y;  e22 := vDir.z;  e32 := 0;
  end;
  FMode := mPoint;
end;

procedure TdfCamera.SetTarget(aTarget: IdfNode);
begin
  FTarget := aTarget;
  SetTarget(aTarget.Position);
  FMode := mTarget;
end;

end.
