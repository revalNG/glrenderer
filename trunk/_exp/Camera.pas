{
  TODO: +1) Сделать cameraInit - инициализацию камеры
         2) Сделать основные функции камеры
       +-3) Сохранять LX, LY, LZ при анимации камеры
        +4) При анимации Pos пересчитывать Direction
         5) Set и SetPos работают правильно. Не забывать делать еденичной
            матрицу перед заданием нового смещения.
}
unit Camera;

interface

uses
  dfMath, dfHGL, dfHEngine, dfHInput, dfHRenderer, Node;

type
  TdfCameraTargetMode = (mPoint, mTarget, mFree);

  TdfCamera = class (TdfNode, IdfCamera)
  private
    FMode: TdfCameraTargetMode;
    FTargetPoint: TdfVec3f
    FTarget: IdfNode;
  public
    procedure Pan(X, Y: Single);
    procedure Scale(aScale: Single);
    procedure Rotate(delta: Single; Axis: TdfVec3f);

    procedure Render(deltaTime: Double); override;

    procedure SetCamera(Pos, TargetPos, Up: TdfVec3f);
    procedure SetTarget(Point: TdfVec3f); overload;
    procedure SetTarget(Target: IdfNode); overload;
  end;

  //ВНЕШНИЕ ЭКСПОРТИРУЕМЫЕ ФУНКЦИИ

  //Установка всех параметров камеры: Позиция, Точка наблюдения, Вектор "верха"
  function renderCameraSet(X, Y, Z, LookX, LookY, LookZ, UpX, UpY, UpZ: Single): Integer; stdcall;
  //Установка точки наблюдения с сохранением остальных параметров
  function renderCameraSetTarget(LookX, LookY, LookZ: Single): Integer; stdcall;
  //Установка позиции камеры с сохранием остальных параметров
  function renderCameraSetPos(X, Y, Z: Single): Integer; stdcall;
  //Установка вектора "верха" камеры с сохранением  остальных параметров
  function renderCameraSetUp(UpX, UpY, UpZ: Single): Integer; stdcall;


  //ВНУТРЕННИЕ ФУНКЦИИ
  function CameraInit(x, y, w, h: Integer; FOV, ZNear, ZFar: Single): Integer;
  function CameraStep(deltaTime: Single): Integer;
  function CameraDeInit(): Integer;

  function CameraGetUp(): TdfVec3f;
  function CameraGetDir(): TdfVec3f;
  function CameraGetLeft(): TdfVec3f;
  function CameraGetPos(): TdfVec3f;


implementation

uses
  Windows;

//var
  //Модельная матрица и матрица проекции камеры
//  Model, Proj: TdfMat4f;
  //Точка взгляда камеры - LookX, LookY, LookZ (можно высчитывать каждый раз при анимации,
  // но проще хранить)
//  LX, LY, LZ: Single;
//  aPos, aTarget, aUp: TCameraAnimation;

procedure TdfCamera.Pan(X, Y: Single);
var
  v: TdfVec3f;
begin
  v := CameraGetUp() * Y;
  v := v + CameraGetLeft() * X;
  ModelMatrix.Translate(v);
end;

procedure TdfCamera.Scale(aScale: Single);
begin
  ModelMatrix.Translate(dfVec3f(0,0,0) - (Direction * AScale));
end;

procedure TdfCamera.Rotate(delta: Single; Axis: TdfVec3f);
begin
  ModelMatrix.Rotate(Delta, Axis);
end;

procedure TdfCamera.Render(deltaTime: Double);
begin

end;

procedure TdfCamera.SetCamera(Pos, TargetPos, Up: TdfVec3f);
var
  vDir, vUp, vLeft, newPos: TdfVec3f;
begin
  {LookXYZ - XYZ - вектор направления взгляда - direction.
   Расстояние между ними - трансляция
   векторное произведение direction и up это -left}
  ModelMatrix.Identity;
  Up.Normalize;
  Direction := Pos - TargetPos;
  Direction.Normalize;
  Left := Up.Cross(Direction);
  Left := dfVec3f(0,0,0) - Left;
  Left.Normalize;
  Up := Direction.Cross(Left);
  up.Normalize;
  newPos := Pos;
  with ModelMatrix do
  begin
    e00 := Left.x;       e01 := Left.y;       e02 := Left.z;       e03 := -newpos.Dot(Left);
    e10 := Up.x;         e11 := Up.y;         e12 := Up.z;         e13 := -newpos.Dot(Up);
    e20 := Direction.x;  e21 := Direction.y;  e22 := Direction.z;  e23 := -newpos.Dot(Direction);
    e30 := 0;            e31 := 0;            e32 := 0;            e33 := 1;
  end;
  FTargetPoint := TargetPos;
  FMode := mPoint;
end;

procedure TdfCamera.SetTarget(Point: TdfVec3f); overload;
begin

end;

procedure TdfCamera.SetTarget(Target: IdfNode); overload;
begin

end;



//Установка всех параметров камеры: Позиция, Точка наблюдения, Вектор "верха"
function renderCameraSet(X, Y, Z, LookX, LookY, LookZ, UpX, UpY, UpZ: Single): Integer; stdcall;
var
  dir, up, left, newpos: TdfVec3f;
begin
  {LookXYZ - XYZ - вектор направления взгляда - direction.
   Расстояние между ними - трансляция
   векторное произведение direction и up это -left}
  Model.Identity;
  up := dfVec3f(UpX, UpY, UpZ);
  up.Normalize;
  dir := dfVec3f(X - LookX, Y - LookY, Z - LookZ);
  dir.Normalize;
  left := up.Cross(dir);
  left := dfVec3f(0,0,0) - left;
  left.Normalize;
  up := dir.Cross(left);
  up.Normalize;
  newpos := dfVec3f(X, Y, Z);
  with Model do
  begin
    e00 := left.x; e01 := left.y; e02 := left.z; e03 := -newpos.Dot(left);
    e10 := up.x;   e11 := up.y;   e12 := up.z;   e13 := -newpos.Dot(up);
    e20 := dir.x;  e21 := dir.y;  e22 := dir.z;  e23 := -newpos.Dot(dir);
    e30 := 0;      e31 := 0;      e32 := 0;      e33 := 1;
  end;
  LX := LookX;
  LY := LookY;
  LZ := LookZ;

  Result := 0;
end;

//Установка точки наблюдения с сохранением остальных параметров
function renderCameraSetTarget(LookX, LookY, LookZ: Single): Integer; stdcall;
var
  dir, up, left: TdfVec3f;
begin
  with Model do
  begin
    dir := dfVec3f(e03 - LookX, e13 - LookY, e23 - LookZ);
    dir.Normalize;
    up := dfVec3f(e01, e11, e21);
    left := dir.Cross(up);
    left.Normalize;
    up := left.Cross(dir);
    up.Normalize;
    left := dfvec3f(0,0,0) - left;
    e00 := left.x; e10 := left.y; e20 := left.z; e30 := 0;
    e01 := up.x;   e11 := up.y;   e21 := up.z;   e31 := 0;
    e02 := dir.x;  e12 := dir.y;  e22 := dir.z;  e32 := 0;
  end;
  LX := LookX;
  LY := LookY;
  LZ := LookZ;

  Result := 0;
end;

//Установка позиции камеры с сохранием остальных параметров
function renderCameraSetPos(X, Y, Z: Single): Integer; stdcall;
var
  left, up, dir, newpos: TdfVec3f;
begin
  with Model do
  begin
    dir := dfVec3f(X - LX, Y - LY, Z - LZ);
    dir.Normalize;
    up := dfVec3f(e01, e11, e21);
    left := dir.Cross(up);
    left.Normalize;
    up := left.Cross(dir);
    up.Normalize;
    left := dfVec3f(0,0,0) - left;
    Identity;
    e00 := left.x; e10 := left.y; e20 := left.z; e30 := 0;
    e01 := up.x;   e11 := up.y;   e21 := up.z;   e31 := 0;
    e02 := dir.x;  e12 := dir.y;  e22 := dir.z;  e32 := 0;
    Model := Model.Transpose;
    newpos := Model * dfVec3f(-X, -Y, -Z);
    Pos := newpos;
  end;

  Result := 0;
end;

//Установка вектора "верха" камеры с сохранением  остальных параметров
function renderCameraSetUp(UpX, UpY, UpZ: Single): Integer; stdcall;
begin
  Result := -10; //Затычка
end;


//**********

function CameraInit(x, y, w, h: Integer; FOV, ZNear, ZFar: Single): Integer;
begin
  Result := 0;
  try
    gl.Viewport(x, y, w, h);
    Proj.Identity;
    Proj.Perspective(FOV, w / h, ZNear, ZFar);
//    ZeroMemory(@aPos, SizeOf(aPos));
//    ZeroMemory(@aTarget, SizeOf(aTarget));
//    ZeroMemory(@aUp, SizeOf(aUp));
    gl.MatrixMode(GL_PROJECTION);
    gl.LoadMatrixf(Proj);
  except
    Result := -1;
    Exit;
  end;
end;

function CameraStep(deltaTime: Single): Integer;

//  procedure SetPos();
//  var
//    pos: TdfVec3f;
//  begin
//    with aPos do
//      begin
//        if Speed < MaxSpeed then
//          Speed := Speed + Accel;
//        t := t + Speed * deltaTime;
//        pos := Start.Lerp(Finish, t);
//        if t - cEPS  >= 1 then
//        begin
//          Enabled := False;
//          Exit;
//        end;
//        renderCameraSetPos(pos.x, pos.y, pos.z);
//      end;
//  end;

begin
  Result := 0;
  try
//    if aPos.Enabled then
//      SetPos();

    if dfInput.IsKeyDown('z') or dfInput.IsKeyDown('я') then
      CameraRotate(0.001, CameraGetDir())
    else if dfInput.IsKeyDown('x') or dfInput.IsKeyDown('ч') then
      CameraRotate(-0.001, CameraGetDir());
    gl.MatrixMode(GL_PROJECTION);
    gl.LoadMatrixf(Proj);
    gl.MatrixMode(GL_MODELVIEW);
    gl.MultMatrixf(Model);
  except
    Result := -1;
    Exit;
  end;
end;

function CameraDeInit(): Integer;
begin
  Model.Identity;
  Proj.Identity;
//  ZeroMemory(@aPos, SizeOf(aPos));
//  ZeroMemory(@aTarget, SizeOf(aTarget));
//  ZeroMemory(@aUp, SizeOf(aUp));
  //*

  Result := 0;
end;

function CameraGetUp(): TdfVec3f;
begin
  with Model do
    Result := dfVec3f(e10, e11, e12);
end;

function CameraGetDir(): TdfVec3f;
begin
  with Model do
    Result := dfVec3f(e20, e21, e22);
end;

function CameraGetLeft(): TdfVec3f;
begin
  with Model do
    Result := dfVec3f(e00, e01, e02);
end;

function CameraGetPos(): TdfVec3f;
begin
  with Model do
    Result := Pos;
end;

end.
