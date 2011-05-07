{
  TODO: +1) Не работает функция обработки окна - MyWndProc. Пока сделано DefWindowProc
        +2) Сделать вызов CameraInit в renderInit
        +3) Сделать таймер для подсчета deltaTime и FPS
        +4) Исправить deltaTime у CameraStep, DataStep
        +5) MyWndProc - исправить изменение FOV, ZNear, ZFar при WM_SIZE.
            Не сохраняются переданные параметры
        -6) renderInit2 - больше параметров из файла
        +7) Параметры (X, Y) - положение окна - при инициализации не учитываются, исправить
}

unit Main;

interface

uses
  Windows, Messages, SysUtils, dfHGL;


const
  cDefWindowW = 640;
  cDefWindowH = 480;
  cDefWindowX = 0;
  cDefWindowY = 0;

  cDefConstAtten = 1;
  cDefLinearAtten = 1;
  cDefQuadroAtten = 1;

   //Инициализация рендера с использованием файла параметров
  function renderInit(FileName: PAnsiChar): Integer; stdcall;

  {
    Шаг рендера.
    Возвращаемое значение - код ошибки.
     0 - Код удачного завершения
    -1 - Неизвестная ошибка
     1 - Ошибка рендера камеры
     2 - Ошибка рендера данных
  }
  function renderStep(): Integer; stdcall;

  function renderDeInit(): Integer; stdcall;
  function renderWindowSetCaption(aCaption: PAnsiChar): Integer; stdcall;
  function renderWindowGetHandle: Integer; stdcall;

var
  WHandle: THandle;
  FDC: hDC;
  FHGLRC: hglRC;

implementation

uses
  Camera, Light, Sprites, Textures, Shaders, Logger, File3ds, VBO,
  dfMath, dfHInput, dfHEngine,
  Classes;

var
  renderReady: Boolean = False;
  //Счетчик отрендеренных фреймов
  Frames: Integer = 0;
  //Параметры для высокоточного таймера
  NewTicks, OldTicks, Freq: Int64;
  //время между двумя кадрами и ФПС
  dt, FPS: Single;
  //Сохраненные значения, переданные юзером при инициализации рендера
  cFOV, cZNear, cZFar: Single;

  texID2: Integer;

  dx, dy: Integer;

  Scale: Single;

  hDefaultCursor, hHandCursor: HICON;

  backgroundColor: TdfVec3f;

  bDrawAxis: Boolean;

  camPos, camLook, camUp: TdfVec3f;

  mesh: TdfMesh;

function MyWindowProc(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
var
  x, y: Integer;
  d: SmallInt;
begin
  case Msg of
    WM_QUIT:
    begin
      PostQuitMessage(0);
      Result := 0;
    end;
    WM_PAINT:
    begin
      QueryPerformanceCounter(NewTicks);
      dt := (NewTicks - OldTicks) / Freq;
      OldTicks := NewTicks;
      Inc(Frames);
      FPS :=  1 / dT;
      if renderReady then
        renderStep();
      if Frames >= 1000 then
      begin
        //Вывод фпс
//        SetWindowText(WHandle, FloatToStr(FPS));
        Frames := 0;
      end;
    end;
    WM_SIZE:
    begin
      camera.CameraInit(0, 0, LOWORD(lParam), HIWORD(lParam), cFOV, cZNear, cZFar);
    end;
    WM_MOUSEMOVE:
    begin
      //Нажата левая кнопка мыши, и идет движение
      if wParam and MK_LBUTTON <> 0 then
      begin
        x := LOWORD(lParam);
        y := HIWORD(lParam);
//        Camera.CameraRotate(deg2rad*(x - dx), dfVec3f(0, 1, 0));
        Camera.CameraRotate(deg2rad*(x - dx), CameraGetUp());
        Camera.CameraRotate(deg2rad*(y - dy), CameraGetLeft());
        dx := x;
        dy := y;
      end;
      //Нажата правая кнопка мыши, и идет движение
      if wParam and MK_RBUTTON <> 0 then
      begin
        SetCursor(hHandCursor);
        x := LOWORD(lParam);
        y := HIWORD(lParam);
        Camera.CameraPan(y-dy, dx-x);
        dx := x;
        dy := y;
      end;
    end;
    WM_LBUTTONDOWN:
    begin
      dx := LOWORD(lParam);
      dy := HIWORD(lParam);
    end;
    WM_LBUTTONUP:
    begin
      dX := 0;
      dY := 0;
    end;

    WM_RBUTTONDOWN:
    begin
      dx := LOWORD(lParam);
      dy := HIWORD(lParam);
      SetCursor(hHandCursor);
    end;
    WM_RBUTTONUP:
    begin
      dX := 0;
      dY := 0;
    end;

    WM_MOUSEWHEEL:
    begin
      d := HIWORD(wParam);
      dfInput.KeyboardNotifyWheelMoved(d);
    end
  else
    Result := DefWindowProc(hWnd, Msg, wParam, lParam);
  end;
end;

function renderInit(FileName: PAnsiChar): Integer; stdcall;
var
  strData: TFileStream;
  par: TParser;
  lightPos: TdfVec3f;
  lAmb, lDif, lSpec: TdfVec4f; //Цвет источника света
  lConstAtten, lLinearAtten, lQuadroAtten: Single; //Параметры источника света
  W, H, X, Y: Integer; //Параметры окна - длина, ширина, позицияХ, позицияУ
  windowCaption: PWideChar;

  WC: TWndClass;
  Style: Cardinal;

  PFD: TPixelFormatDescriptor;
  nPixelFormat: Integer;
  atomColor: TdfVec3f;
  atomTexturePath: PWideChar;
  atomSize: Single;
  dataPath: PWideChar;

begin
  Logger.LogInit();

  W := cDefWindowW;
  H := cDefWindowH;
  X := cDefWindowX;
  Y := cDefWindowY;
  lConstAtten := cDefConstAtten;
  lLinearAtten := cDefLinearAtten;
  lQuadroAtten := cDefQuadroAtten;

  try

    {$REGION ' Чтение данных из файла конфига через TParser'}
    if FileExists(FileName) then
      strData := TFileStream.Create(FileName, fmOpenRead)
    else
    begin
      logWriteError('Отсутствует файл конфига ' + FileName, True, True, True);
      Result := -1;
      Exit;
    end;
    par := TParser.Create(strData);
    repeat
      if par.TokenString = 'decimalseparator' then
      begin
        par.NextToken;
        DecimalSeparator := par.TokenString[1];
      end
      //Окно
      else if par.TokenString = 'rendermode' then
      begin
        //Пока только оконный рендер
        par.NextToken;
        if par.TokenString = 'window' then
        begin
          //Bla-Bla
        end
        else
        begin
          //Bla-Bla
        end;
      end
      else if par.TokenString = 'resolution' then
      begin
        par.NextToken;
        W := par.TokenInt;
        par.NextToken;
        H := par.TokenInt;
      end
      else if par.TokenString = 'windowPos' then
      begin
        par.NextToken;
        X := par.TokenInt;
        par.NextToken;
        Y := par.TokenInt;
      end
      else if par.TokenString = 'backgroundColor' then
      begin
        par.NextToken;
        backgroundColor.x := par.TokenFloat;
        par.NextToken;
        backgroundColor.y := par.TokenFloat;
        par.NextToken;
        backgroundColor.z := par.TokenFloat;
      end
      else if par.TokenString = 'axis' then
      begin
        par.NextToken;
        bDrawAxis := (par.TokenString = 'true');
      end
      else if par.TokenString = 'caption' then
      begin
        par.NextToken;
        windowCaption := PWideChar(par.TokenString);
      end
      //Камера
      else if par.TokenString = 'FOV' then
      begin
        par.NextToken;
        cFOV := par.TokenFloat;
      end
      else if par.TokenString = 'zNear' then
      begin
        par.NextToken;
        czNear := par.TokenFloat;
      end
      else if par.TokenString = 'zFar' then
      begin
        par.NextToken;
        czFar := par.TokenFloat;
      end
      else if par.TokenString = 'cameraPos' then
      begin
        par.NextToken;
        camPos.x := par.TokenFloat;
        par.NextToken;
        camPos.y := par.TokenFloat;
        par.NextToken;
        camPos.z := par.TokenFloat;
      end
      else if par.TokenString = 'cameraLook' then
      begin
        par.NextToken;
        camLook.x := par.TokenFloat;
        par.NextToken;
        camLook.y := par.TokenFloat;
        par.NextToken;
        camLook.z := par.TokenFloat;
      end
      else if par.TokenString = 'cameraUp' then
      begin
        par.NextToken;
        camUp.x := par.TokenFloat;
        par.NextToken;
        camUp.y := par.TokenFloat;
        par.NextToken;
        camUp.z := par.TokenFloat;
      end
      else if par.TokenString = 'lightPos' then
      begin
        par.NextToken;
        lightPos.x := par.TokenFloat;
        par.NextToken;
        lightPos.y := par.TokenFloat;
        par.NextToken;
        lightPos.z := par.TokenFloat;
      end
      else if par.TokenString = 'lightAmbColor' then
      begin
        par.NextToken;
        lAmb.x := par.TokenFloat;
        par.NextToken;
        lAmb.y := par.TokenFloat;
        par.NextToken;
        lAmb.z := par.TokenFloat;
        par.NextToken;
        lAmb.w := par.TokenFloat;
      end
      else if par.TokenString = 'lightDifColor' then
      begin
        par.NextToken;
        lDif.x := par.TokenFloat;
        par.NextToken;
        lDif.y := par.TokenFloat;
        par.NextToken;
        lDif.z := par.TokenFloat;
        par.NextToken;
        lDif.w := par.TokenFloat;
      end
      else if par.TokenString = 'lightSpecColor' then
      begin
        par.NextToken;
        lSpec.x := par.TokenFloat;
        par.NextToken;
        lSpec.y := par.TokenFloat;
        par.NextToken;
        lSpec.z := par.TokenFloat;
        par.NextToken;
        lSpec.w := par.TokenFloat;
      end
      else if par.TokenString = 'lightConstAtten' then
      begin
        par.NextToken;
        lConstAtten := par.TokenFloat;
      end
      else if par.TokenString = 'lightLinearAtten' then
      begin
        par.NextToken;
        lLinearAtten := par.TokenFloat;
      end
      else if par.TokenString = 'lightQuadroAtten' then
      begin
        par.NextToken;
        lQuadroAtten := par.TokenFloat;
      end
      else if par.TokenString = 'lightDraw' then
      begin
        par.NextToken;
        Light.bDrawLight := (par.TokenString = 'true');
      end
      else if par.TokenString = 'atomColor' then
      begin
        par.NextToken;
        atomColor.x := par.TokenFloat;
        par.NextToken;
        atomColor.y := par.TokenFloat;
        par.NextToken;
        atomColor.z := par.TokenFloat;
      end
      else if par.TokenString = 'atomTexturePath' then
      begin
        par.NextToken;
        atomTexturePath := PWideChar(par.TokenString);
      end
      else if par.TokenString = 'atomSize' then
      begin
        par.NextToken;
        atomSize := par.TokenFloat;
      end
      else if par.TokenString = 'dataPath' then
      begin
        par.NextToken;
        dataPath := PWideChar(par.TokenString);
      end;
    until par.NextToken = toEOF;
    par.Free;
    strData.Free;
    logWriteMessage('Успешная загрузка параметров из конфиг-файла ' + FileName);
  {$ENDREGION}

    //Инициализация
    Style := WS_OVERLAPPEDWINDOW or WS_CLIPSIBLINGS or WS_CLIPCHILDREN;
    ZeroMemory(@WC, SizeOf(TWndClass));
    with WC do
    begin
      style := CS_VREDRAW or CS_HREDRAW or CS_OWNDC;
      hInstance := 0;
      hIcon := LoadIcon(0, IDI_WINLOGO);
      hCursor := LoadCursor(0, IDC_ARROW);
      hDefaultCursor := hCursor;
      hbrBackground := GetStockObject (White_Brush);
      lpfnWndProc := @MyWindowProc;
      lpszClassName := 'TMyWindow';
    end;
    hHandCursor := LoadCursor(0, IDC_HAND);
    Windows.RegisterClass(WC);
    WHandle := CreateWindow('TMyWindow', windowCaption, Style,
                            X, Y, W, H, 0, 0, WC.hInstance, nil);
    if WHandle = 0 then
    begin
      logWriteError('Ошибка инициализации окна. Возвращен нулевой handle', True, True, True);
      Result := 1;
      Exit;
    end;
    logWriteMessage('Успешная инициализация окна, полученный handle: ' + IntToStr(WHandle));

    FDC := GetDC(WHandle);

    if FDC = 0 then
    begin
      logWriteError('Ошибка получения Device Context, возвращен нулевой контекст', True, True, True);
      Result := 2;
      Exit;
    end;

    logWriteMessage('Успешное получение Device Context: ' + IntToStr(FDC));

    pfd.nSize := SizeOf(PIXELFORMATDESCRIPTOR);
    pfd.nVersion := 1;
    pfd.dwFlags  := PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER;
    pfd.iPixelType := PFD_TYPE_RGBA;
    pfd.cColorBits := 32;

    nPixelFormat := ChoosePixelFormat(FDC, @pfd);

    if nPixelFormat = 0 then
    begin
      logWriteError('Ошибка получения дескриптора пиксельного формата PDF, возвращен нулевой дескриптор', True, True, True);
      Result := 3;
      Exit;
    end;

    logWriteMessage('Успешное получение PFD: ' + IntToStr(nPixelFormat));

    SetPixelFormat(FDC, nPixelFormat, @pfd);

    FHGLRC := wglCreateContext(FDC);

    if FHGLRC = 0 then
    begin
      logWriteError('Ошибка получения рендер-контекста, возвращен нулевой контекст', True, True, True);
      Result := 4;
      Exit;
    end;

    logWriteMessage('Успешное получение рендер-контекста: ' + IntToStr(FHGLRC));

    wglMakeCurrent(FDC, FHGLRC);

    gl.Init;
    gl.Enable(GL_DEPTH_TEST);
    gl.Enable(GL_LIGHTING);
//    gl.Enable(GL_CULL_FACE);
    gl.Enable(GL_COLOR_MATERIAL);
    gl.Enable(GL_TEXTURE_2D);
    gl.ClearColor(backgroundColor.x, backgroundColor.y, backgroundColor.z, 1.0);
    gl.SwapInterval(0);

    ShowWindow(WHandle, CmdShow);
    UpdateWindow(WHandle);

    Camera.CameraInit(0, 0, W, H, cFOV, cZNear, cZFar);
    //Задаем параметры камеры
    renderCameraSet(camPos.x, camPos.y, camPos.z,
                    camLook.x, camLook.y, camLook.z,
                    camUp.x, camUp.y, camUp.z);
    Light.LightInit();
    renderLightSet(lightPos.x, lightPos.y, lightpos.z,
                   lAmb.x, lAmb.y, lAmb.z, lAmb.w,
                   lDif.x, lDif.y, lDif.z, lDif.z,
                   lSpec.x, lSpec.y, lSpec.z, lSpec.w,
                   lConstAtten, lLinearAtten, lQuadroAtten);
    Sprites.SpriteInit(atomColor, atomSize);
    Shaders.ShadersInit();
    VBO.VBOInit();
    texID2 := Textures.renderTexLoad(PWideToPChar(atomTexturePath));

    Scale := 1.0;

    QueryPerformanceFrequency(Freq);
    renderReady := True;

    logWriteMessage('Успешная инициализация');
    renderSpritesAddFromFile(PWideToPChar(dataPath));
    mesh := TdfMesh.Create;
    mesh.LoadFrom3ds('Data\su37.3ds');
    VBO.VBOAddDataFromMesh(mesh);
    Result := 0;
  except
    Result := -1;
  end;
end;

function renderStep(): Integer; stdcall;
var
  lp: TdfVec3f;

procedure DrawAxis();
begin
  //Draw axes
  gl.Disable(GL_LIGHTING);
  gl.Beginp(GL_LINES);
    gl.Color4ub(255, 0, 0, 255);
    gl.Vertex3f(0, 0, 0);
    gl.Vertex3f(10, 0, 0);

    gl.Color4ub(0, 255, 0, 255);
    gl.Vertex3f(0, 0, 0);
    gl.Vertex3f(0, 10, 0);

    gl.Color4ub(0, 0, 255, 255);
    gl.Vertex3f(0, 0, 0);
    gl.Vertex3f(0, 0, 10);
  gl.Endp();
  gl.Enable(GL_LIGHTING);
end;

begin
  Result := 0;
  try
    lp := Light.LightGetPos();
    gl.Clear(GL_COLOR_BUFFER_BIT);
    gl.Clear(GL_DEPTH_BUFFER_BIT);
    gl.MatrixMode(GL_MODELVIEW);
    gl.PushMatrix();
      if Camera.CameraStep(dt) = -1 then
        raise Exception.CreateRes(1);
      if bDrawAxis then
        DrawAxis();
      Light.LightStep(dt);
//      Textures.renderTexBind(texID2);
//      Sprites.SpriteStep(dt);
//      Textures.renderTexUnbind;
      VBO.VBOStep(dt);
      if dfInput.IsKeyDown(VK_MOUSEWHEELUP) then
        Camera.CameraScale(-1.0)
      else if dfInput.IsKeyDown(VK_MOUSEWHEELDOWN) then
        Camera.CameraScale(1.0);

      if dfInput.IsKeyDown('z') or dfInput.IsKeyDown('я') then
        CameraRotate(0.001, CameraGetDir())
      else if dfInput.IsKeyDown('x') or dfInput.IsKeyDown('ч') then
        CameraRotate(-0.001, CameraGetDir());

      if dfInput.IsKeyDown('c') or dfInput.IsKeyDown('с') then
        renderCameraSet(camPos.x, camPos.y, camPos.z,
                        camLook.x, camLook.y, camLook.z,
                        camUp.x, camUp.y, camUp.z);

    gl.PopMatrix();
    Windows.SwapBuffers(FDC);
  except
    on E: Exception do
      case StrToInt(e.Message) of
        1:
          Result := 1;
        2:
          Result := 2;
        else
          Result := -1;
      end;
  end;
end;

function renderDeInit(): Integer; stdcall;
begin
  Result := 0;
  logWriteMessage('Деинициализация рендера');
  try
    renderReady := False;
    Camera.CameraDeInit();
    Light.LightDeInit();
    Sprites.SpriteDeInit();
    Textures.TexDeInit();
    Textures.renderTexDel(texID2);
    VBO.VBODeInit();
    wglDeleteContext(FHGLRC);
    ReleaseDC(WHandle, FDC);
    wglMakeCurrent(FDC, 0);
    FDC := 0;
    FHGLRC := 0;
    CloseWindow(WHandle);
    DestroyWindow(WHandle);
    WHandle := 0;
    Logger.LogDeinit();

    mesh.Free;
  except
    Result := -1;
    Exit;
  end;
  //*
end;

function renderWindowSetCaption(aCaption: PAnsiChar): Integer; stdcall;
begin
  SetWindowText(WHandle, aCaption);
  Result := 0;
end;

function renderWindowGetHandle: Integer; stdcall;
begin
  Result := WHandle;
end;

end.
