{
  TODO: +1)Начальный функционал. Вероятно, реализация через записи?
       ->2)Функционал для анимации. Продумать. Возможно, загрузка анимаций из файла?
         3)Функционал сферы
         4)Функционал цилиндров
         5)Куб.
}
unit Data;

interface

uses
  dglOpengl;

const
  cCurrentVersion = 1;

  //ВНЕШНИЕ ЭКСПОРТИРУЕМЫЕ ФУНКЦИИ

  //Загрузка данных для рендера из внешнего файла.
  {
    2010-04-12 - Формат файла данных

    version 1 //Версия файла
    decimalseparator . //Разделить целой и дробной частей
    Type Name X Y Z R G B A DirX DirY DirZ UpX UpY UpZ
    //Type - Тип примитива: sphere, cube, cylinder.
    //Name - Имя (номер) примитива
    //X, Y, Z - позиция примитива
    //R, G, B, A - цвет примитива
    //DirX, DirY, DirZ - вектор направления
    //UpX, UpY, UpZ - вектор "верха"
    // ... - специфические параметры примитива
             (сфера - радиус,
              куб - длина/ширина/высота,
              цилиндр - длина/радиус
  }
  function renderDataAddFromFile(FileName: PAnsiChar): Integer; stdcall;

  function renderDataSaveToFile(FileName: PAnsiChar): Integer; stdcall;

  //Добавление сферы в позицию X, Y, Z радиусом Radius и цветом RGB.
  //Возвращаемое значение - имя данной сферы для манипулирования
  function renderDataSphereAdd(X, Y, Z, Radius, R, G, B, A: Single): Integer; stdcall;
  //Изменение позиции сферы с именем/номером Name
  function renderDataSpherePos(Name: Integer; X, Y, Z: Single): Integer; stdcall;
  //Изменение позиции сферы с именем/номером Name с максимальной скоросью MaxSpeed и ускорением Accel
  function renderDataSpherePosMove(Name: Integer; X, Y, Z, MaxSpeed, Accel: Single): Integer; stdcall;
  //Изменение радиуса сферы с именем/номером Name
  function renderDataSphereRad(Name: Integer; Radius: Single): Integer; stdcall;
  //Изменение радиуса сферы с именем/номером Name с максимальной скоросью MaxSpeed и ускорением Accel
  function renderDataSphereRadMove(Name: Integer; Radius, MaxSpeed, Accel: Single): Integer; stdcall;
  //Изменение цвета сферы с именем/номером Name
  function renderDataSphereRGB(Name: Integer; R, G, B, A: Single): Integer; stdcall;
  //Изменение цвета сферы с именем/номером Name с максимальной скоростью MaxSpeed и ускорением Accel
  function renderDataSphereRGBMove(Name: Integer; R, G, B, A, MaxSpeed, Accel: Single): Integer; stdcall;

  function renderDataCylinderAdd(X, Y, Z, Radius, ALength, R, G, B, A, DirX, DirY, DirZ, UpX, UpY, UpZ: Single): Integer; stdcall;

  //ВНУТРЕННИЕ ФУНКЦИИ

  function DataInit(): Integer;
  function DataStep(deltaTime: Single): Integer;
  function DataDeInit(): Integer;

  //Возвращает индекс объекта по имени
  //Зарезервировано для последующего изменения именования объектов
  function GetByName(Name: Integer): Integer;

implementation

uses
  dfMath, Classes, SysUtils;

type
  TrenderPrimType = (rSphere, rCube, rCylinder);
  TrenderObject = record
    Name: Integer; //Имя объекта
    Prim: TrenderPrimType; //Тип объекта
    Model: TdfMat4f; //Модельная матрица
    Color: TdfVec4f; //Цвет
    p1, p2, p3, p4: Single; //Параметры (пока 4 с плавающей запятой, впоследствии больше)
    //2010-05-03 - Добавлено свойство видимости
    Visible: Boolean;
  end;
var
  f: PGLUQuadric;
  aRenderData: array of TrenderObject;

//Загрузка данных для рендера из внешнего файла.
function renderDataAddFromFile(FileName: PAnsiChar): Integer; stdcall;
var
  strData: TFileStream;
//  strdata1: TStringList;
  par: TParser;
  k: Integer;

  //Получаем параметры для формировния модельной матрицы
  procedure SetModelMatrix(aIndex: Integer);
  var
    left, up, dir, mpos: TdfVec3f;
    col: TdfVec4f;
  begin
    //Позиция
    par.NextToken;
    mpos.x := par.TokenFloat;
    par.NextToken;
    mpos.y := par.TokenFloat;
    par.NextToken;
    mpos.z := par.TokenFloat;
    //Цвет
    par.NextToken;
    col.x := par.TokenFloat;
    par.NextToken;
    col.y := par.TokenFloat;
    par.NextToken;
    col.z := par.TokenFloat;
    par.NextToken;
    col.w := par.TokenFloat;
    //Направление
    par.NextToken;
    dir.x := par.TokenFloat;
    par.NextToken;
    dir.y := par.TokenFloat;
    par.NextToken;
    dir.z := par.TokenFloat;
    //Верх
    par.NextToken;
    up.x := par.TokenFloat;
    par.NextToken;
    up.y := par.TokenFloat;
    par.NextToken;
    up.z := par.TokenFloat;
    //Левый вектор
    left := dir.Cross(up);
    left := dfVec3f(0,0,0) - left;
    up.Normalize;
    dir.Normalize;
    left.Normalize;
    with aRenderData[aIndex].Model do
    begin
      Identity;
      e00 := left.x; e10 := left.y; e20 := left.z; e30 := 0;
      e01 := up.x;   e11 := up.y;   e21 := up.z;   e31 := 0;
      e02 := dir.x;  e12 := dir.y;  e22 := dir.z;  e32 := 0;
      Pos := mpos;
    end;
    aRenderData[aIndex].Color := Col;
  end;

begin
  try
    if FileExists(FileName) then
      strData := TFileStream.Create(FileName, $0000)
    else
      raise Exception.Create('No such a file');
//    strData1 := TStringList.Create;
    par := TParser.Create(strData);
    repeat
//      strData1.Add(par.TokenString);
      {Хотя, физически в заголовке файла находятся основные параметры,
       они идут последними в связке if ... then ... else if... из соображений
       быстродействия в чтении данных - строки с данными встречаются чаще}
      //Объект "сфера"
      if par.TokenString = 'sphere' then
      begin
        SetLength(aRenderData, Length(aRenderData) + 1);
        k := Length(aRenderData) - 1;
        par.NextToken;
        aRenderData[k].Name := par.TokenInt;
        aRenderData[k].Prim := rSphere;

        SetModelMatrix(k);
        //Параметры
        par.NextToken;
        aRenderData[k].p1 := par.TokenFloat; //Радиус
      end
      //Объект "куб"
      else if par.TokenString = 'cube' then
      begin
        SetLength(aRenderData, Length(aRenderData) + 1);
        k := Length(aRenderData) - 1;
        par.NextToken;
        aRenderData[k].Name := par.TokenInt;
        aRenderData[k].Prim := rCube;

        SetModelMatrix(k);
        //Параметры
        par.NextToken;
        aRenderData[k].p1 := par.TokenFloat; //Длина
        par.NextToken;
        aRenderData[k].p2 := par.TokenFloat; //Ширина
        par.NextToken;
        aRenderData[k].p3 := par.TokenFloat; //Высота
      end
      //Объект "цилиндр"
      else if par.TokenString = 'cylinder' then
      begin
        SetLength(aRenderData, Length(aRenderData) + 1);
        k := Length(aRenderData) - 1;
        par.NextToken;
        aRenderData[k].Name := par.TokenInt;
        aRenderData[k].Prim := rCylinder;

        SetModelMatrix(k);
        //Параметры
        par.NextToken;
        aRenderData[k].p1 := par.TokenFloat; //Длина
        par.NextToken;
        aRenderData[k].p2 := par.TokenFloat; //Радиус
      end
      //Считывание версии
      else if par.TokenString = 'version' then
      begin
        par.NextToken;
        if par.TokenInt <> cCurrentVersion then
          raise Exception.Create('Bad version');
      end
      //Разделитель целой и дробной части
      else if par.TokenString = 'decimalseparator' then
      begin
        par.NextToken;
        DecimalSeparator := par.TokenString[1];
      end;
    until par.NextToken = toEOF;
    par.Free;
    strData.Free();
  except
    on E:Exception do
    begin
      Result := StrToInt(e.Message);
    end;
  end;
  Result := -10; //Затычка
end;

function renderDataSaveToFile(FileName: PAnsiChar): Integer; stdcall;
var
  i: Integer;
  strData: TStringList;
  up, dir, pos: TdfVec3f;
  col: TdfVec4f;
  typename: String;
begin
  strData := TStringList.Create();
  with strData do
  begin
    Add('version '+IntToStr(cCurrentVersion));
    DecimalSeparator := '.';
    Add('decimalseparator .');
    try
      for i := 0 to High(aRenderData) do
      begin
        case aRenderData[i].Prim of
          rSphere: typename := 'sphere';
          rCube: typename := 'cube';
          rCylinder: typename := 'cylinder';
        end;
        up := dfVec3f(aRenderData[i].Model.e01,
                      aRenderData[i].Model.e11,
                      aRenderData[i].Model.e21);
        dir := dfVec3f(aRenderData[i].Model.e02,
                       aRenderData[i].Model.e12,
                       aRenderData[i].Model.e22);
        pos := dfVec3f(aRenderData[i].Model.e03,
                       aRenderData[i].Model.e13,
                       aRenderData[i].Model.e23);
        col :=  aRenderData[i].Color;
        Add(typename + ' '  +  IntToStr(aRenderData[i].Name) + ' ' +
            FloatToStr(pos.x) + ' ' + FloatToStr(pos.y) + ' ' + FloatToStr(pos.z) + ' ' +
            FloatToStr(col.x) + ' ' + FloatToStr(col.y) + ' ' + FloatToStr(col.z) + ' ' + FloatToStr(col.w) + ' ' +
            FloatToStr(dir.x) + ' ' + FloatToStr(dir.y) + ' ' + FloatToStr(dir.z) + ' ' +
            FloatToStr(up.x) + ' ' + FloatToStr(up.y) + ' ' + FloatToStr(up.z) + ' ' +
            FloatToStr(aRenderData[i].p1) + ' ' + FloatToStr(aRenderData[i].p2) + ' ' +
            FloatToStr(aRenderData[i].p3) + ' ' + FloatToStr(aRenderData[i].p4));
      end;
      SaveToFile(FileName);
      Free;
    except
      Result := -1;
    end;
  end;

  Result := 0;
end;

//Добавление сферы в позицию X, Y, Z радиусом Radius и цветом RGB.
//Возвращаемое значение - имя данной сферы для манипулирования
function renderDataSphereAdd(X, Y, Z, Radius, R, G, B, A: Single): Integer; stdcall;
var
  k: Integer;
begin
  SetLength(aRenderData, Length(aRenderData) + 1);
  k := Length(aRenderData) - 1;
  with aRenderData[k] do
  begin
    Name := k;
    Prim := rSphere;
    Model.Identity;
    Model.Pos := dfVec3f(X, Y, Z);
    Color := dfVec4f(R, G, B, A);
    p1 := Radius;
    //*
  end;

  Result := aRenderData[k].Name; //Затычка
end;

//Изменение позиции сферы с именем/номером Name
function renderDataSpherePos(Name: Integer; X, Y, Z: Single): Integer; stdcall;
var
  k: Integer;
begin
  try
    k := GetByName(Name);
    if k = -1 then
      raise exception.Create('Wrong name of render data object');
    aRenderData[k].Model.Pos := dfVec3f(X, Y, Z);
    Result := 0;
  except
    Result := -1;
  end;
//  Result := -10; //Затычка
end;

function renderDataSpherePosMove(Name: Integer; X, Y, Z, MaxSpeed, Accel: Single): Integer; stdcall;
begin
  Result := -10; //Затычка
end;

//Изменение радиуса сферы с именем/номером Name
function renderDataSphereRad(Name: Integer; Radius: Single): Integer; stdcall;
var
  k: Integer;
begin
  try
    k := GetByName(Name);
    if k = -1 then
      raise exception.Create('Wrong name of render data object');
    aRenderData[k].p1 := Radius;
    Result := 0;
  except
    Result := -1;
  end;
//  Result := -10; //Затычка
end;


function renderDataSphereRadMove(Name: Integer; Radius, MaxSpeed, Accel: Single): Integer; stdcall;
begin
  Result := -10; //Затычка
end;

//Изменение цвета сферы с именем/номером Name
function renderDataSphereRGB(Name: Integer; R, G, B, A: Single): Integer; stdcall;
var
  k: Integer;
begin
  try
    k := GetByName(Name);
    if k = -1 then
      raise exception.Create('Wrong name of render data object');
    aRenderData[k].Color := dfVec4f(R, G, B, A);
    Result := 0;
  except
    Result := -1;
  end;
//  Result := -10; //Затычка
end;

function renderDataSphereRGBMove(Name: Integer; R, G, B, A, MaxSpeed, Accel: Single): Integer; stdcall;
begin
  Result := -10; //Затычка
end;



function renderDataCylinderAdd(X, Y, Z, Radius, ALength, R, G, B, A, DirX, DirY, DirZ, UpX, UpY, UpZ: Single): Integer; stdcall;
var
  k: Integer;
  left, dir, up: TdfVec3f;
begin
  SetLength(aRenderData, Length(aRenderData) + 1);
  k := Length(aRenderData) - 1;
  with aRenderData[k] do
  begin
    Name := k;
    Prim := rCylinder;
    Color := dfVec4f(R, G, B, A);
    p1 := ALength;
    p2 := Radius;

    up := dfVec3f(UpX, UpY, UpZ);
    dir := dfVec3f(DirX, DirY, DirZ);
    left := dir.Cross(up);
    left := dfVec3f(0, 0, 0) - left;
    up.Normalize;
    dir.Normalize;
    left.Normalize;
    Model.Identity;
    Model.Pos := dfVec3f(X, Y, Z);
    with Model do
    begin
      e00 := left.x; e10 := left.y; e20 := left.z; e30 := 0;
      e01 := up.x;   e11 := up.y;   e21 := up.z;   e31 := 0;
      e02 := dir.x;  e12 := dir.y;  e22 := dir.z;  e32 := 0;
    end;
    //*
  end;

  Result := aRenderData[k].Name; //Затычка
end;


function DataInit(): Integer;
begin
  f := gluNewQuadric;
  glColorMaterial(GL_FRONT, GL_AMBIENT_AND_DIFFUSE);
  SetLength(aRenderData, 0);
  Result := -10; //Затычка
end;

function DataStep(deltaTime: Single): Integer;
var
  i: Integer;
begin
  glMatrixMode(GL_MODELVIEW);

  for i := 0 to High(aRenderData) do
    with aRenderData[i] do
    begin
      glPushMatrix();
      glMultMatrixf(@Model);
      glColor4f(Color.x, color.y, color.z, color.w);
      case Prim of
        rSphere:
        begin
          gluSphere(f, p1, 16, 16);
        end;
        rCube:
        begin

        end;
        rCylinder:
        begin
          gluCylinder(f, p2, p2, p1, 16, 16);
          gluDisk(f, 0, p2, 16, 16);
          glRotatef(180, 0, 1, 0);
          glTranslatef(0, 0, -p1);
          gluDisk(f, 0, p2, 16, 16);
        end;
      end;
      glPopMatrix();
    end;

  Result := -10; //Затычка
end;

function DataDeInit(): Integer;
begin
  gluDeleteQuadric(f);
  SetLength(aRenderData, 0);
  Result := -10; //Затычка
end;

function GetByName(Name: Integer): Integer;
begin
  //Зарезервировано для последюущего изменения именования объектов
  //В общем случае - поиск по массиву, пока не aRenderData[i].Name = Name
  if Name < Length(aRenderData)  then
    Result := Name
  else
    Result := -1;
end;


end.
