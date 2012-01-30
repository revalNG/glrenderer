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
// ���������������� ��������� ������ ������:
//  ModelMatrix.Translate(dfVec3f(0,0,0) - (Direction * AScale));
end;

procedure TdfCamera.Update();
begin
//��������, �� �����.
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
  vDir, vUp, vLeft: TdfVec3f;
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

  Position := aPos;
  UpdateDirUpLeft(vDir, vUp, vLeft);

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
    UpdateDirUpLeft(vDir, vUp, vLeft);
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