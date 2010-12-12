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
  dfMath, dfHGL, dfHEngine, dfHInput;

  //ВНЕШНИЕ ЭКСПОРТИРУЕМЫЕ ФУНКЦИИ

  //Установка всех параметров камеры: Позиция, Точка наблюдения, Вектор "верха"
  function renderCameraSet(X, Y, Z, LookX, LookY, LookZ, UpX, UpY, UpZ: Single): Integer; stdcall;
  //Установка точки наблюдения с сохранением остальных параметров
  function renderCameraSetTarget(LookX, LookY, LookZ: Single): Integer; stdcall;
  //Плавное передвижение камеры к новой точке с максимальной скоростью MaxSpeed
  function renderCameraSetTargetMove(LookX, LookY, LookZ, MaxSpeed, Accel: Single): Integer; stdcall;
  //Установка позиции камеры с сохранием остальных параметров
  function renderCameraSetPos(X, Y, Z: Single): Integer; stdcall;
  //Плавное перемещение позиции камеры с максимальной скоростью MaxSpeed с сохранением остальных параметров
  function renderCameraSetPosMove(X, Y, Z, MaxSpeed, Accel: Single): Integer; stdcall;
  //Установка вектора "верха" камеры с сохранением  остальных параметров
  function renderCameraSetUp(UpX, UpY, UpZ: Single): Integer; stdcall;
  //Плавное изменение вектора "верха" камеры с максимальной скоростью MaxSpeed с сохранением остальных параметров
  function renderCameraSetUpMove(UpX, UpY, UpZ, MaxSpeed, Accel: Single): Integer; stdcall;
  //Вращение камеры вокруг позиции наблюдения с сохранением расстояния до нее
  function renderCameraMoveAroundTarget(HorDelta, VerDelta: Single): Integer; stdcall;


  //ВНУТРЕННИЕ ФУНКЦИИ
  function CameraInit(x, y, w, h: Integer; FOV, ZNear, ZFar: Single): Integer;
  function CameraStep(deltaTime: Single): Integer;
  function CameraDeInit(): Integer;

  //Функции для дебага
  function CameraRotate(Delta: Single; Axis: TdfVec3f): Integer;
  function CameraScale(AScale: Single): Integer;
  function CameraGetUp(): TdfVec3f;
  function CameraGetDir(): TdfVec3f;
  function CameraGetLeft(): TdfVec3f;
  function CameraGetPos(): TdfVec3f;

implementation

uses
  Windows;

type

  //Анимация камеры
  TCameraAnimation = record
    //t - величина времени, необходимая для интерполяции 0..1
    //Speed - текущая скорость
    t, Accel, Speed, MaxSpeed: Single;
    //start - вектор начального состояния
    //finish - вектор конечного состояния
    Start, Finish: TdfVec3f;
    Enabled: Boolean;
  end;

var
  //Модельная матрица и матрица проекции камеры
  Model, Proj: TdfMat4f;
  //Точка взгляда камеры - LookX, LookY, LookZ (можно высчитывать каждый раз при анимации,
  // но проще хранить)
  LX, LY, LZ: Single;
  aPos, aTarget, aUp: TCameraAnimation;

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

function renderCameraSetTargetMove(LookX, LookY, LookZ, MaxSpeed, Accel: Single): Integer; stdcall;
begin
  if not aTarget.Enabled then
  begin
    aTarget.Enabled := True;
    aTarget.t := 0;
    aTarget.Start := dfVec3f(LX, LY, LZ);
    aTarget.Finish := dfVec3f(0, 0, 0);
  end;
  aTarget.Finish := aTarget.Finish + dfVec3f(LookX, LookY, LookZ);
  aTarget.Accel := Accel;
  aTarget.MaxSpeed := MaxSpeed;
  aTarget.Speed := 0;

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

function renderCameraSetPosMove(X, Y, Z, MaxSpeed, Accel: Single): Integer; stdcall;
begin
  if not aPos.Enabled then
  begin
    aPos.Enabled := True;
    aPos.t := 0;
    aPos.Start := Model.Pos;
    aPos.Finish := dfVec3f(0, 0, 0);
  end;
  aPos.Finish := aPos.Finish + dfVec3f(X, Y, Z);
  aPos.Accel := Accel;
  aPos.MaxSpeed := MaxSpeed;
  aPos.Speed := 0;

  Result := 0;
end;

//Установка вектора "верха" камеры с сохранением  остальных параметров
function renderCameraSetUp(UpX, UpY, UpZ: Single): Integer; stdcall;
begin
  Result := -10; //Затычка
end;

//Плавное изменение вектора "верха" камеры со скоростью Speed с сохранением остальных параметров
function renderCameraSetUpMove(UpX, UpY, UpZ, MaxSpeed, Accel: Single): Integer; stdcall;
begin
  if not aUp.Enabled then
  begin
    aUp.Enabled := True;
    aUp.t := 0;
    aUp.Start := dfVec3f(Model.e01, Model.e11, Model.e21);
    aUp.Finish := dfVec3f(0, 0, 0);
  end;
  aUp.Finish := aUp.Finish + dfVec3f(UpX, UpY, UpZ);
  aUp.Accel := Accel;
  aUp.MaxSpeed := MaxSpeed;
  aUp.Speed := 0;

  Result := 0;
end;

//Вращение камеры вокруг позиции наблюдения с сохранением расстояния до нее
function renderCameraMoveAroundTarget(HorDelta, VerDelta: Single): Integer; stdcall;
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
    ZeroMemory(@aPos, SizeOf(aPos));
    ZeroMemory(@aTarget, SizeOf(aTarget));
    ZeroMemory(@aUp, SizeOf(aUp));
    gl.MatrixMode(GL_PROJECTION);
    gl.LoadMatrixf(Proj);
    gl.ClearColor(0.3, 0.3, 0.3, 1.0);
  except
    Result := -1;
    Exit;
  end;
end;

function CameraStep(deltaTime: Single): Integer;

  procedure SetPos();
  var
    pos: TdfVec3f;
  begin
    with aPos do
      begin
        if Speed < MaxSpeed then
          Speed := Speed + Accel;
        t := t + Speed * deltaTime;
        pos := Start.Lerp(Finish, t);
        if t - cEPS  >= 1 then
        begin
          Enabled := False;
          Exit;
        end;
        renderCameraSetPos(pos.x, pos.y, pos.z);
      end;
  end;

begin
  Result := 0;
  try
    if aPos.Enabled then
      SetPos();
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
  ZeroMemory(@aPos, SizeOf(aPos));
  ZeroMemory(@aTarget, SizeOf(aTarget));
  ZeroMemory(@aUp, SizeOf(aUp));
  //*

  Result := 0;
end;

function CameraRotate(Delta: Single; Axis: TdfVec3f): Integer;
begin
  Model.Rotate(Delta, Axis);
  Result := 0;
end;

function CameraScale(AScale: Single): Integer;
begin
  Model.Translate(dfVec3f(0,0,0) - (CameraGetDir * AScale));
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
