{
  TODO: +1) �� �������� ������� ��������� ���� - MyWndProc. ���� ������� DefWindowProc
        +2) ������� ����� CameraInit � renderInit
        +3) ������� ������ ��� �������� deltaTime � FPS
        +4) ��������� deltaTime � CameraStep, DataStep
        +5) MyWndProc - ��������� ��������� FOV, ZNear, ZFar ��� WM_SIZE.
            �� ����������� ���������� ���������
         6) renderInit2 - ������ ���������� �� �����
        +7) ��������� (X, Y) - ��������� ���� - ��� ������������� �� �����������, ���������
}

unit Main;

interface

uses
  Windows, Messages, SysUtils, dglOpenGL;


const
  cDefWindowW = 640;
  cDefWindowH = 480;
  cDefWindowX = 0;
  cDefWindowY = 0;

  cDefConstAtten = 1;
  cDefLinearAtten = 1;
  cDefQuadroAtten = 1;

  {
    !!!!!
    Deprecated(����������)-������ �������������.
    ������������� ������������ renderInit2.
    ������������, renderInit ����� �������� �� �����������.
    !!!!!

    ������������� �������.
    �������� ����������� ����������:
    Width, Height      - ������� ���� � ������� �����������
    X,Y                - ������� ���� � ������� �����������
    FOV(Field of View) - ���� ������
    ZNear              - ������� ��������� ���������
    ZFar               - ������� ��������� ���������
    ������������ �������� - ��� ������.
     0 - ��� �������� ����������
    -1 - ����������� ������
     1 - ������ �������� ����, ������� ������� �����

  }
  function renderInit(Width, Height, X,Y: Integer;
                      FOV, ZNear, ZFar: Single): Integer; stdcall;
  //������������� ������� � �������������� ����� ����������
  function renderInit2(FileName: PAnsiChar): Integer; stdcall;

  {
    ��� �������.
    ������������ �������� - ��� ������.
     0 - ��� �������� ����������
    -1 - ����������� ������
     1 - ������ ������� ������
     2 - ������ ������� ������
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
  Camera, Data, Light, Animation, VBO, Sprites, Textures,
  dfMath,
  Classes;

var
  renderReady: Boolean = False;
  //������� ������������� �������
  Frames: Integer = 0;
  //��������� ��� ������������� �������
  NewTicks, OldTicks, Freq: Int64;
  //����� ����� ����� ������� � ���
  dt, FPS: Single;
  //����������� ��������, ���������� ������ ��� ������������� �������
  cFOV, cZNear, cZFar: Single;

  texID1, texID2: Integer;

  dx, dy: Integer;
  spinVec1, spinVec2: TdfVec3f;

function MyWindowProc(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
var
  x, y: Integer;
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
        //����� ���
        SetWindowText(WHandle, FloatToStr(FPS));
        Frames := 0;
      end;
    end;
    WM_SIZE:
    begin
      camera.CameraInit(0, 0, LOWORD(lParam), HIWORD(lParam), cFOV, cZNear, cZFar);
    end;
    WM_MOUSEMOVE:
    begin
      if wParam and MK_LBUTTON <> 0 then
      begin
        x := LOWORD(lParam);
        y := HIWORD(lParam);
        SpinVec1 := dfVec3f(0, 1, 0);
        SpinVec2 := CameraGetLeft;
        Camera.CameraRotate(deg2rad*(x - dx), SpinVec1);
        Camera.CameraRotate(deg2rad*(y - dy), SpinVec2);
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
    end
  else
    Result := DefWindowProc(hWnd, Msg, wParam, lParam);
  end;
end;

function renderInit(Width, Height, X,Y: Integer; FOV, ZNear, ZFar: Single): Integer; stdcall;
var
  WC: TWndClass;
  Style: Cardinal;
begin
  Result := -1;
  Style := WS_OVERLAPPEDWINDOW or WS_CLIPSIBLINGS or WS_CLIPCHILDREN;
  ZeroMemory(@WC, SizeOf(TWndClass));
  with WC do
  begin
    style := CS_VREDRAW or CS_HREDRAW or CS_OWNDC;
    hInstance := 0;
    hIcon := LoadIcon(0, IDI_WINLOGO);
    hCursor := LoadCursor(0, IDC_ARROW);
    hbrBackground := GetStockObject (White_Brush);
    lpfnWndProc := @MyWindowProc;
    lpszClassName := 'TMyWindow';
  end;
  Windows.RegisterClass(WC);
  WHandle := CreateWindow('TMyWindow', 'MyCaption', Style,
                          X, Y, Width,
                          Height, 0, 0, WC.hInstance, nil);
  if WHandle = 0 then
  begin
    Result := 1;
    Exit;
  end;

  FDC := GetDC(WHandle);
  InitOpenGL();
  FHGLRC := CreateRenderingContext(FDC, [opDoubleBuffered], 32, 16, 16, 16,16, 0);

  ActivateRenderingContext(FDC, FHGLRC);

  glEnable(GL_DEPTH_TEST);
  glEnable(GL_LIGHTING);
//  glEnable(GL_CULL_FACE);
  glEnable(GL_COLOR_MATERIAL);
//  glEnable(GL_FRONT_AND_BACK);

  ShowWindow(WHandle, CmdShow);
  UpdateWindow(WHandle);

  cFOV := FOV;
  cZNear := ZNear;
  cZFar := ZFar;
  Camera.CameraInit(0, 0, Width, Height, FOV, ZNear, ZFar);
  //������ ��������� ������
  renderCameraSet(1, 1, -10, 0, 0, 0, 0, 1, 0);
  Data.DataInit();
  //2010-05-03 - ��������� ������������� ��������
  Animation.AnimInit();
  Light.LightInit();
  //������ ��������� ��������� �����
  renderLightSet(5, 5, 5,
                 0.0, 0.0, 0.0, 1.0,
                 0.8, 0.8, 0.8, 1.0,
                 1.0, 1.0, 1.0, 1.0,
                 1, 1, 1);

  QueryPerformanceFrequency(Freq);
  renderReady := True;
  Result := 0;
end;

function renderInit2(FileName: PAnsiChar): Integer; stdcall;
var
  strData: TFileStream;
  par: TParser;
  camPos, camLook, camUp, lightPos: TdfVec3f;
  lAmb, lDif, lSpec: TdfVec4f; //���� ��������� �����
  lConstAtten, lLinearAtten, lQuadroAtten: Single; //��������� ��������� �����
  W, H, X, Y: Integer; //��������� ���� - �����, ������, ��������, ��������

  WC: TWndClass;
  Style: Cardinal;
begin

  W := cDefWindowW;
  H := cDefWindowH;
  X := cDefWindowX;
  Y := cDefWindowY;
  lConstAtten := cDefConstAtten;
  lLinearAtten := cDefLinearAtten;
  lQuadroAtten := cDefQuadroAtten;

  try

    {$REGION ' ������ ������ �� ����� ������� ����� TParser'}
    if FileExists(FileName) then
      strData := TFileStream.Create(FileName, fmOpenRead)
    else
      raise Exception.Create('No such a file');
    par := TParser.Create(strData);
    repeat
      if par.TokenString = 'decimalseparator' then
      begin
        par.NextToken;
        DecimalSeparator := par.TokenString[1];
      end
      //����
      else if par.TokenString = 'rendermode' then
      begin
        //���� ������ ������� ������
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
      //������
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
    until par.NextToken = toEOF;
    par.Free;
    strData.Free;
  {$ENDREGION}

    //�������������
    Style := WS_OVERLAPPEDWINDOW or WS_CLIPSIBLINGS or WS_CLIPCHILDREN;
    ZeroMemory(@WC, SizeOf(TWndClass));
    with WC do
    begin
      style := CS_VREDRAW or CS_HREDRAW or CS_OWNDC;
      hInstance := 0;
      hIcon := LoadIcon(0, IDI_WINLOGO);
      hCursor := LoadCursor(0, IDC_ARROW);
      hbrBackground := GetStockObject (White_Brush);
      lpfnWndProc := @MyWindowProc;
      lpszClassName := 'TMyWindow';
    end;
    Windows.RegisterClass(WC);
    WHandle := CreateWindow('TMyWindow', 'MyCaption', Style,
                            X, Y, W, H, 0, 0, WC.hInstance, nil);
    if WHandle = 0 then
    begin
      Result := 1;
      Exit;
    end;

    FDC := GetDC(WHandle);
    InitOpenGL();
    FHGLRC := CreateRenderingContext(FDC, [opDoubleBuffered], 32, 16, 16, 16,16, 0);

    ActivateRenderingContext(FDC, FHGLRC);

    glEnable(GL_DEPTH_TEST);
    glEnable(GL_LIGHTING);
    glEnable(GL_CULL_FACE);
    glEnable(GL_COLOR_MATERIAL);
    glEnable(GL_TEXTURE_2D);
    wglSwapIntervalExt(0);
//    glEnable(GL_FRONT_AND_BACK);

    ShowWindow(WHandle, CmdShow);
    UpdateWindow(WHandle);

    Camera.CameraInit(0, 0, W, H, cFOV, cZNear, cZFar);
    //������ ��������� ������
    renderCameraSet(camPos.x, camPos.y, camPos.z,
                    camLook.x, camLook.y, camLook.z,
                    camUp.x, camUp.y, camUp.z);
    Data.DataInit();
    Light.LightInit();
    //2010-05-03 - ��������� ������������� ��������
    Animation.AnimInit();
    renderLightSet(lightPos.x, lightPos.y, lightpos.z,
                   lAmb.x, lAmb.y, lAmb.z, lAmb.w,
                   lDif.x, lDif.y, lDif.z, lDif.z,
                   lSpec.x, lSpec.y, lSpec.z, lSpec.w,
                   lConstAtten, lLinearAtten, lQuadroAtten);
    VBO.VBOInit();
    Sprites.SpriteInit();
    texID1 := Textures.renderTexLoad('Data\tile.bmp');
    texID2 := Textures.renderTexLoad('Data\sphere.bmp');
    QueryPerformanceFrequency(Freq);
    renderReady := True;
    Result := 0;
  except
    Result := -1;
  end;
end;

function renderStep(): Integer; stdcall;
begin
  Result := 0;
  try
    glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT or GL_STENCIL_BUFFER_BIT);
    glMatrixMode(GL_MODELVIEW);
    glPushMatrix();
      if Camera.CameraStep(dt) = -1 then
        raise Exception.CreateRes(1);
      if Data.DataStep(dt) = -1 then
        raise Exception.CreateRes(2);
      Textures.renderTexBind(texID1);
      VBO.VBOStep(dt);
      Textures.renderTexBind(texID2);
      Sprites.SpriteStep(dt);
      Textures.renderTexUnbind;
      Light.LightStep(dt);
    glPopMatrix();
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
  try
    renderReady := False;
    Camera.CameraDeInit();
    Data.DataDeInit();
    Light.LightDeInit();
    //2010-05-03 - ��������� ��������������� ��������
    Animation.AnimDeInit();
    VBO.VBODeInit();
    Sprites.SpriteDeInit();
    Textures.TexDeInit();
    Textures.renderTexDel(texID1);
    Textures.renderTexDel(texID2);
    ReleaseDC(WHandle, FDC);
    wglMakeCurrent(FDC, 0);
    DestroyRenderingContext(FHGLRC);
    FDC := 0;
    FHGLRC := 0;
    CloseWindow(WHandle);
    DestroyWindow(WHandle);
    WHandle := 0;
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
