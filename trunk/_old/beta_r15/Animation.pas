{
  Мысль: Вычисление fStartTime, fEndTimeX блоков производить на этапе
         подготовки анимации. Реализация:
         1) Расчет
         2) Предварительный прогон, сохранение результатов в другой файл.
         ?

  Мысль: После создания анимаций вида Create отпадет нужда в renderDataAddRomFile.
         С другой стороны - вдруг понадобится только статика, без анимации.
         Вывод - оставить renderDataAddFromFile.

  Связанный с Data.pas модуль, загружающий анимацию и манипулирующий ей.
  TODO:  0) Спецификация 1.0 на формат файла анимаций
         1) Функционал для анимации. Продумать. Возможно, загрузка анимаций из файла?
         2) Реализация менеджера анимаций.
}
unit Animation;

interface

const

  cCurrentVersion = 1;
  //Максимальное количество анимаций в блоке
  cMaxAnimsInBlock = 24;
  //Максимальное число параметров у анимации
  cMaxParamsInAnim = 8;

  //Идентификаторы объектов анимации
  cidCameraAnim   = 0;
  cidSphereAnim   = 1;
  cidCylinderAnim = 2;
  cidCubeAnim     = 3;

  //Идентификаторы типов анимации

  //Общие типы анимации
  cidPosAnim      = 0;
  cidDirAnim      = 1;
  cidUpAnim       = 2;
  cidColorAnim    = 3;

  //Специфические типы анимации
  cidLookAnim       = 8;
  cidMoveAroundAnim = 9;
  cidRadiusAnim     = 10;



  {
    Загрузка анимации из файла
    Формат файла анимации:

    version 1                 - версия формата анимации. Текущая - 1
    decimalseparator .        - указатель разделителя целой и дробной частей

    time <X, next+X, nextall+X>
       - указатель на новый блок анимации.
       Все действия, описанные в одном блоке анимации, начинаются единовременно.
       X           - время, в секундах, в которое начнет действовать данный
                     блок анимаций.
       next+X      - данный блок начнет действия после выполнения последней
                     записанной в предыдущем блоке анимации (ТОЛЬКО последней,
                     т.е. он не дожидается окончания всех анимаций предыдущего
                     блока) с запозданием (смещением) в X секунд.
       nextall+X   - данный блок начнет действовать после выполнения ВСЕХ
                     анимаций предыдущего блока с запозданием (смещением) в X
                     секунд

    При задании внутри блока анимаций строки
         name <имя_блока>
    данному блоку будет присвоено заданное имя

    Возможные анимации блока:
    1) camera <Тип анимации> <параметры>
         Анимация камеры. Ключевой пункт анимации
         Тип анимации:
         * pos   - Изменение позиции камеры.
           Параметры:
             X Y Z     - координаты позиции, числа с плавающей запятой
             MaxSpeed  - максимальная скорость, число с плавающей запятой
             Accel     - ускорение, число с плавающей запятой
             FixTarget - указать, если требуется сохранять "наводку" на цель
         * look  - Изменение целевой точки камеры
           Параметры:
             LX LY LZ   - координаты целевой точки камеры, числа с плавающей запятой
             MaxSpeed   - максимальная скорость, число с плавающей запятой
             Accel      - ускорение, число с плавающей запятой
         * up    - Изменение направления "верха" камеры
           Параметры:
             UpX UpY UpZ - новый вектор верха камеры, числа с плавающей запятой
             MaxSpeed   - максимальная скорость, число с плавающей запятой
             Accel      - ускорение, число с плавающей запятой
         ...etc...

    2) <Тип объекта> <Имя объекта> <Тип анимации> <Параметры>
         Тип объекта - sphere, cylinder, cube, etc...
         Имя объекта - номер(имя) объекта.
           Примечание: имя объекта возвращает функция создания объекта.
         Тип анимации:
         * pos - Изменение позиции
           Параметры:
             X Y Z     - координаты позиции, числа с плавающей запятой
             MaxSpeed  - максимальная скорость, число с плавающей запятой
             Accel     - ускорение, число с плавающей запятой
         * up - Изменение вектора верха
           Параметры:
             UpX UpY UpZ - новый вектор верха, числа с плавающей запятой
             MaxSpeed    - максимальная скорость, число с плавающей запятой
             Accel       - ускорение, число с плавающей запятой
         * dir - Изменение вектора направления
           Параметры:
             DirX DirY DirZ - новый вектор направления, числа с плавающей запятой
             MaxSpeed       - максимальная скорость, число с плавающей запятой
             Accel          - ускорение, число с плавающей запятой
         * col - Изменение цвета
           Параметры:
             R G B A  - цвет объекта + прозрачность, числа с плавающей запятой
             MaxSpeed - максимальная скорость, число с плавающей запятой
             Accel    - ускорение, число с плавающей запятой
  }
  function renderAnimAddFromFile(FileName: PAnsiChar): Integer; stdcall;
  function renderAnimSetSpeed(Speed: Single): Integer; stdcall;
  function renderAnimGetSpeed: Single; stdcall;
  function renderAnimPlay: Integer; stdcall;
  function renderAnimPause: Integer; stdcall;
  function renderAnimStop: Integer; stdcall;
  function renderAnimNextBlock: Integer; stdcall;
  function renderAnimPrevBlock: Integer; stdcall;
  function renderAnimJumpToA(blockName: PAnsiChar): Integer; stdcall;
  function renderAnimJumpToB(blockNumber: Integer): Integer; stdcall;

  //Внутренняя функция шага
  function AnimInit(): Integer;
  function AnimStep(deltaTime: Single): Integer;
  function AnimDeInit(): Integer;

  //d - debug
  function d_renderAnimSaveToFile(FileName: PAnsiChar): Integer; stdcall;

type

{2010-06-27: Первый вариант структуры}

  //Анимация - эквивалент конкретной процедуре, например CameraSetPosMove и т.д.
  TrenderAnim = record
    ObjectType,        //Тип объекта (например, camera)
    AnimType: Integer; //Тип анимации (pos, dir, up, create, destroy, ...)
    pars: array [0..cMaxParamsInAnim - 1] of Single; //Параметры анимации
  end;

  //Блок анимации, соответствует блоку анимации time в файле
  //Фактически - набор анимаций (TrenderAnim), выполняющихся одновременно
  TrenderAnimBlock = record
  public
    cName: PAnsiChar;      //Имя блока

    fTimeStart: Single;    //Время в которое начнет выполняться данный блок.
    fTimeEndLast: Single;  //Конец выполнения последней анимации блока
    fTimeEndAll: Single;   //Конец вполнения всех анимаций блока

    bDoneLast,             //Флаг, что завершена последняя анимация блока
    bDoneAll: Boolean;     //Флаг, что завершены все анимации блока

    aAnims: array[0..cMaxAnimsInBlock - 1] of TrenderAnim;
  end;

  PrenderAnimBlock = ^TrenderAnimBlock;

  //Менеджер анимации, управляет процессом анимации
  TrenderAnimManager = class
  private
    FBlocks: array of TrenderAnimBlock;
    FCurrent: PrenderAnimBlock;
    FSpeed: Single;
    FPaused: Boolean;
    function Step(deltaTime: Single): Integer;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    property Speed: Single read FSpeed write FSpeed;
    function Play: Integer;
    function Pause: Integer;
    function Stop: Integer;
    function NextBlock: Integer;
    function PrevBlock: Integer;
    function JumpTo(blockName: PAnsiChar): Integer; overload;
    function JumpTo(blockNumber: Integer): Integer; overload;

    //Рассчитать fTimeStart, fTimeEndLast, fTimeEndAll для блоков
    function CalculateTimes(): Integer;
    function AddBlock(aName: PAnsiChar): PrenderAnimBlock;
  end;

implementation

uses
  Classes, SysUtils;

var
  AnimManager: TrenderAnimManager;

function TrenderAnimManager.Step(deltaTime: Single): Integer;
begin
  Result := -10;
end;

constructor TrenderAnimManager.Create;
begin
  inherited;
  SetLength(FBlocks, 0);
  FCurrent := nil;
end;

destructor TrenderAnimManager.Destroy;
begin
  SetLength(FBlocks, 0);
  FCurrent := nil;
  inherited;
end;

function TrenderAnimManager.Play: Integer;
begin
  Result := -10;
end;

function TrenderAnimManager.Pause: Integer;
begin
  Result := -10;
end;

function TrenderAnimManager.Stop: Integer;
begin
  Result := -10;
end;

function TrenderAnimManager.NextBlock: Integer;
begin
  Result := -10;
end;

function TrenderAnimManager.PrevBlock: Integer;
begin
  Result := -10;
end;

function TrenderAnimManager.JumpTo(blockName: PAnsiChar): Integer;
begin
  Result := -10;
end;

function TrenderAnimManager.JumpTo(blockNumber: Integer): Integer;
begin
  Result := -10;
end;


function TrenderAnimManager.CalculateTimes: Integer;
begin
  Result := -10;
end;

function TrenderAnimManager.AddBlock(aName: PAnsiChar): PrenderAnimBlock;
var
  i, j, ind: Integer;
begin
  //Не уверен, что у данного куска кода есть смысл
  //Теоретически, память зануляется при расширении массива
  ind := Length(FBlocks);
  SetLength(FBlocks, ind + 1);
  with FBlocks[ind] do
  begin
    cName := aName;
    fTimeStart := 0;
    fTimeEndLast := 0;
    fTimeEndAll := 0;
    for i := 0 to cMaxAnimsInBlock - 1 do
    begin
      aAnims[i].ObjectType := 0;
      aAnims[i].AnimType := 0;
      for j := 0 to cMaxParamsInAnim - 1 do
        aAnims[i].pars[j] := 0;
    end;
  end;
  Result := @FBlocks[ind];
end;



function renderAnimAddFromFile(FileName: PAnsiChar): Integer; stdcall;
var
  strData: TFileStream;
  par: TParser;
  TimeStart, TimeEndLast, TimeEndAll, t: Single;
  CurBlock: PrenderAnimBlock;

  function CalcStartTime(NextAll: Boolean; Strafe: Single): Single;
  begin
    //Считаем время начала блока, причем CurBlock - предыдущий блок
    if CurBlock <> nil then
    begin
      if NextAll then
        Result := Strafe + CurBlock.fTimeEndAll
      else
        Result := Strafe + CurBlock.fTimeEndLast;
    end
    else
      Result := Strafe;
  end;

  function CalcEndTime(): Single;
  begin
    //Считаем время завершения для текущего блока.
    //Записываем в CurBlock
  end;

begin
  CurBlock := nil;
  try
    if FileExists(FileName) then
      strData := TFileStream.Create(FileName, fmOpenRead)
    else
      raise Exception.Create('No such a file');
    par := TParser.Create(strData);
    repeat
// ----->>>>>>>

      if par.TokenString = 'camera' then
      begin
        //*
        //Читаем параметры анимации
        //Записываем их в текущий блок новой командой
      end


      //Блок тайм
      else if par.TokenString = 'time' then
      begin
        //Создаем новый блок анимации, назначаем его текущим
        //Читаем время выполнения блока - точное, next, и т.п.
        par.NextToken;
        if par.Token = toFloat then
          //Стоит конкретное абсолютное время начала выполнения
          TimeStart := par.TokenFloat
        else if par.TokenString = 'next' then
        begin
          par.NextToken; //Знак '+'
          par.NextToken; //Смещение
          t := par.TokenFloat;
          TimeStart := CalcStartTime(False, t);
          //*
        end
        else if par.TokenString = 'nextall' then
        begin
          par.NextToken; //Знак '+'
          par.NextToken; //Смещение
          t := par.TokenFloat;
          TimeStart := CalcStartTime(True, t);
          //*
        end;

        //*
        CurBlock := AnimManager.AddBlock('');
        CalcEndTime();
      end

      else if par.TokenString = 'name' then
      begin
        par.NextToken;
        CurBlock^.cName := PAnsiChar(par.TokenString);
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
      Result := StrToInt(e.Message + ' on line ' + IntTostr(par.SourceLine)
                         + ' at pos ' + IntToStr(par.SourcePos));
    end;
  end;
  Result := -10;
end;

function renderAnimSetSpeed(Speed: Single): Integer; stdcall;
begin
  AnimManager.Speed := Speed;
  Result := -10;
end;

function renderAnimGetSpeed: Single; stdcall;
begin
  Result := AnimManager.Speed;
end;

function renderAnimPlay: Integer; stdcall;
begin
  Result := AnimManager.Play;
end;

function renderAnimPause: Integer; stdcall;
begin
  Result := AnimManager.Pause;
end;

function renderAnimStop: Integer; stdcall;
begin
  Result := AnimManager.Stop;
end;

function renderAnimNextBlock: Integer; stdcall;
begin
  Result := AnimManager.NextBlock;
end;

function renderAnimPrevBlock: Integer; stdcall;
begin
  Result := AnimManager.PrevBlock;
end;

function renderAnimJumpToA(blockName: PAnsiChar): Integer; stdcall;
begin
  Result := AnimManager.JumpTo(blockName);
end;

function renderAnimJumpToB(blockNumber: Integer): Integer; stdcall;
begin
  Result := AnimManager.JumpTo(blockNumber);
end;



function AnimInit(): Integer;
begin
  AnimManager := TrenderAnimManager.Create;

  Result := -10;
end;

//Внутренняя функция шага
function AnimStep(deltaTime: Single): Integer;
begin
  AnimManager.Step(deltaTime);
  Result := -10;
end;

function AnimDeInit(): Integer;
begin
  AnimManager.Free;
//  AnimManager := nil;

  Result := -10;
end;

function d_renderAnimSaveToFile(FileName: PAnsiChar): Integer;
begin
  //*
  //Проверка правильности чтения аимации из файла
end;

end.
