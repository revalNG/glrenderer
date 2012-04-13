unit Main;

interface

uses
  Windows, Messages, SysUtils,
  dfHGL, dfHRenderer, dfMath,
  Camera;

type
  TdfRenderer = class(TInterfacedObject, IdfRenderer)
  private
    //���������� ������� �, ����������, �������
    FRenderReady: Boolean;

    //��������� ����
    FWHandle: THandle;
    FWCaption: PAnsiChar;
    FWWidth, FWHeight, FWX, FWY: Integer;
    FdesRect: TRect;
    FWStyle: Cardinal;
    FWndClass: TWndClass;
    FWDC: hDC;

    //�������
    FhDefaultCursor, FhHandCursor: HICON;

    FPFD: TPixelFormatDescriptor;
    FnPixelFormat: Integer;

    //������-��������
    FGLRC: hglRC;

    //��������� ��� ������������� �������
    FFrames: Integer;
    FNewTicks, FOldTicks, FFreq: Int64;
    FDeltaTime, FFPS: Single;

    //��������� ������ � ���������(�������)
    FBackgroundColor: TdfVec3f;
    FDrawAxes: Boolean;

    //�������� ������
    FCamera: IdfCamera;

    FLight: IdfLight;

    FRootNode: IdfNode;

    {debug}
    FSprite: IdfSprite;

    function GetWindowHandle(): Integer;
    function GetWindowCaption(): PAnsiChar;
    procedure SetWindowCaption(aCaption: PAnsiChar);
    function GetRenderReady(): Boolean;
    function GetFPS(): Single;
    function GetCamera(): IdfCamera;
    procedure SetCamera(const aCamera: IdfCamera);
    function GetRoot: IdfNode;
    procedure SetRoot(const aRoot: IdfNode);
  public
    constructor Create; virtual;
    destructor Destroy; override;

    function Init(FileName: PAnsiChar): Integer;
    function Step(deltaTime: Double): Integer;
    function Start(): Integer;
    function DeInit(): Integer;

    property WindowHandle: Integer read GetWindowHandle;
    property WindowCaption: PAnsiChar read GetWindowCaption write SetWindowCaption;
    property RenderReady: Boolean read GetRenderReady;
    property FPS: Single read GetFPS;

    property Camera: IdfCamera read GetCamera write SetCamera;

    property RootNode: IdfNode read GetRoot write SetRoot;
  end;


  function WindowProc(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;

var
  TheRenderer: TdfRenderer;

implementation

uses
  Light, Sprites, uTextures, Shaders, Node,
  dfHInput, dfHEngine, Logger,
  Classes;


const
  cDefWindowW = 640;
  cDefWindowH = 480;
  cDefWindowX = 0;
  cDefWindowY = 0;
  cDefWindowCaption = 'glRenderer :: render window';

  cDefConstAtten = 1;
  cDefLinearAtten = 1;
  cDefQuadroAtten = 1;

var
  //����������� ��������, ���������� ������ ��� ������������� �������
//  cFOV, cZNear, cZFar: Single;

  dx, dy: Integer;

//  Scale: Single;

//  hDefaultCursor, hHandCursor: HICON;

//  backgroundColor: TdfVec3f;

//  bDrawAxes: Boolean;

function WindowProc(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
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
      with TheRenderer do
      begin
        QueryPerformanceCounter(FNewTicks);
        FDeltaTime := (FNewTicks - FOldTicks) / FFreq;
        FOldTicks := FNewTicks;
        Inc(FFrames);
        FFPS :=  1 / FDeltaTime;
        if RenderReady then
          Step(FDeltaTime);
        if FFrames >= 100 then
        begin
          //����� ���
          SetWindowText(FWHandle, cDefWindowCaption + ' :: ' + FloatToStr(FPS));
          FFrames := 0;
        end;
      end;
    WM_SIZE:
      with TheRenderer do
        if RenderReady then
          Camera.ViewportOnly(FdesRect.Left, FdesRect.Top, FdesRect.Right, FdesRect.Bottom);
      //camera.CameraInit(0, 0, LOWORD(lParam), HIWORD(lParam), cFOV, cZNear, cZFar);
    WM_MOUSEMOVE:
    begin
      //������ ����� ������ ����, � ���� ��������
      if wParam and MK_LBUTTON <> 0 then
      begin
        x := LOWORD(lParam);
        y := HIWORD(lParam);
        with TheRenderer.Camera do
        begin
          Rotate(deg2rad*(x - dx), Up);
          Rotate(deg2rad*(y - dy), Left);
        end;
        dx := x;
        dy := y;
      end;
      //������ ������ ������ ����, � ���� ��������
      if wParam and MK_RBUTTON <> 0 then
      begin
        SetCursor(TheRenderer.FhHandCursor);
        x := LOWORD(lParam);
        y := HIWORD(lParam);
        TheRenderer.Camera.Pan(y - dy, dx - x);
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
      SetCursor(TheRenderer.FhHandCursor);
    end;
    WM_RBUTTONUP:
    begin
      dX := 0;
      dY := 0;
    end;

    WM_ERASEBKGND:
      Result := 0;

    WM_MOUSEWHEEL:
    begin
      d := HIWORD(wParam);
      dfInput.KeyboardNotifyWheelMoved(d);
    end
  else
    Result := DefWindowProc(hWnd, Msg, wParam, lParam);
  end;
end;

{$REGION '����� TdfRenderer'}

function TdfRenderer.GetWindowHandle(): Integer;
begin
  if FRenderReady then
    Result := FWHandle
  else
    Result := 0;
end;

function TdfRenderer.GetWindowCaption(): PAnsiChar;
begin
  Result := FWCaption;
end;

procedure TdfRenderer.SetWindowCaption(aCaption: PAnsiChar);
begin
  if FWCaption <> aCaption then
  begin
    SetWindowText(FWHandle, aCaption);
    FWCaption := aCaption;
  end;
end;

function TdfRenderer.GetRenderReady(): Boolean;
begin
  Result := FRenderReady;
end;

function TdfRenderer.GetRoot: IdfNode;
begin
  Result := FRootNode;
end;

function TdfRenderer.GetFPS(): Single;
begin
  Result := FFPS;
end;

function TdfRenderer.GetCamera(): IdfCamera;
begin
  Result := FCamera;
end;

procedure TdfRenderer.SetCamera(const aCamera: IdfCamera);
begin
  FCamera := aCamera;
end;

procedure TdfRenderer.SetRoot(const aRoot: IdfNode);
begin
  FRootNode := aRoot;
end;

constructor TdfRenderer.Create;
begin
  FRenderReady := False;
  FWHandle := 0;
  FWCaption := '';
  WindowCaption := cDefWindowCaption;

  FRootNode := TdfNode.Create();
  FSprite := TdfHUDSprite.Create();
  with FSprite do
  begin
    Width := 630;
    Height := 470;
  end;
end;

destructor TdfRenderer.Destroy;
begin
  FRenderReady := False;
  FRootNode := nil;
end;

function TdfRenderer.Init(FileName: PAnsiChar): Integer;
var
  strData: TFileStream;
  par: TParser;
  camPos, camLook, camUp, lightPos: TdfVec3f;
  lAmb, lDif, lSpec: TdfVec4f; //���� ��������� �����
  lConstAtten, lLinearAtten, lQuadroAtten: Single; //��������� ��������� �����
  atomColor: TdfVec3f;
  cFOV, cZNear, cZFar: Single;
  bDrawLight, bVSync: Boolean;

begin
  Logger.LogInit();

  FWWidth := cDefWindowW;
  FWHeight := cDefWindowH;
  FWX := cDefWindowX;
  FWY := cDefWindowY;
  lConstAtten := cDefConstAtten;
  lLinearAtten := cDefLinearAtten;
  lQuadroAtten := cDefQuadroAtten;

  try

    {$REGION ' ������ ������ �� ����� ������� ����� TParser'}
    if FileExists(FileName) then
      strData := TFileStream.Create(FileName, fmOpenRead)
    else
    begin
      logWriteError('����������� ���� ������� ' + FileName, True, True, True);
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
        FWWidth := par.TokenInt;
        par.NextToken;
        FWHeight := par.TokenInt;
      end
      else if par.TokenString = 'windowPos' then
      begin
        par.NextToken;
        FWX := par.TokenInt;
        par.NextToken;
        FWY := par.TokenInt;
      end
      else if par.TokenString = 'backgroundColor' then
      begin
        par.NextToken;
        FBackgroundColor.x := par.TokenFloat;
        par.NextToken;
        FBackgroundColor.y := par.TokenFloat;
        par.NextToken;
        FBackgroundColor.z := par.TokenFloat;
      end
      else if par.TokenString = 'axes' then
      begin
        par.NextToken;
        FDrawAxes := (par.TokenString = 'true');
      end
      else if par.TokenString = 'vsync' then
      begin
        par.NextToken;
        bVSync := (par.TokenString = 'true');
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
      else if par.TokenString = 'lightDraw' then
      begin
        par.NextToken;
        bDrawLight := (par.TokenString = 'true');
      end
      else if par.TokenString = 'atomColor' then
      begin
        par.NextToken;
        atomColor.x := par.TokenFloat;
        par.NextToken;
        atomColor.y := par.TokenFloat;
        par.NextToken;
        atomColor.z := par.TokenFloat;
      end;
    until par.NextToken = toEOF;
    par.Free;
    strData.Free;
    logWriteMessage('�������� �������� ���������� �� ������-����� ' + FileName);
  {$ENDREGION}

    //�������������
    FWStyle := WS_OVERLAPPEDWINDOW or WS_CLIPSIBLINGS or WS_CLIPCHILDREN;

    SetRect(FdesRect, 0, 0, FWWidth, FWHeight);
    AdjustWindowRect(FdesRect, FWStyle, False);
    FWWidth := Abs(FdesRect.Left) + FdesRect.Right;
    FWHeight := Abs(FdesRect.Top) + FdesRect.Bottom;
    ZeroMemory(@FWndClass, SizeOf(TWndClass));
    with FWndClass do
    begin
      style := CS_VREDRAW or CS_HREDRAW or CS_OWNDC;
      hInstance := 0;
      hIcon := LoadIcon(0, IDI_WINLOGO);
      hCursor := LoadCursor(0, IDC_ARROW);
      FhDefaultCursor := hCursor;
      hbrBackground := GetStockObject (White_Brush);
      lpfnWndProc := @WindowProc;
      lpszClassName := 'TdfWindow';
    end;
    FhHandCursor := LoadCursor(0, IDC_HAND);

    Windows.RegisterClass(FWndClass);
    FWHandle := CreateWindow('TdfWindow', cDefWindowCaption, FWStyle,
                            FWX, FWY, FWWidth, FWHeight, 0, 0, FWndClass.hInstance, nil);
    if FWHandle = 0 then
    begin
      logWriteError('������ ������������� ����. ��������� ������� handle', True, True, True);
      Result := 1;
      Exit;
    end;
    logWriteMessage('�������� ������������� ����, ���������� handle: ' + IntToStr(FWHandle));

    FWDC := GetDC(FWHandle);

    if FWDC = 0 then
    begin
      logWriteError('������ ��������� Device Context, ��������� ������� ��������', True, True, True);
      Result := 2;
      Exit;
    end;

    logWriteMessage('�������� ��������� Device Context: ' + IntToStr(FWDC));

    Fpfd.nSize := SizeOf(PIXELFORMATDESCRIPTOR);
    Fpfd.nVersion := 1;
    Fpfd.dwFlags  := PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER;
    Fpfd.iPixelType := PFD_TYPE_RGBA;
    Fpfd.cColorBits := 32;

    FnPixelFormat := ChoosePixelFormat(FWDC, @Fpfd);

    if FnPixelFormat = 0 then
    begin
      logWriteError('������ ��������� ����������� ����������� ������� PDF, ��������� ������� ����������', True, True, True);
      Result := 3;
      Exit;
    end;

    logWriteMessage('�������� ��������� PFD: ' + IntToStr(FnPixelFormat));

    SetPixelFormat(FWDC, FnPixelFormat, @Fpfd);

    FGLRC := wglCreateContext(FWDC);

    if FGLRC = 0 then
    begin
      logWriteError('������ ��������� ������-���������, ��������� ������� ��������', True, True, True);
      Result := 4;
      Exit;
    end;

    logWriteMessage('�������� ��������� ������-���������: ' + IntToStr(FGLRC));

    wglMakeCurrent(FWDC, FGLRC);

    gl.Init;
    gl.Enable(GL_DEPTH_TEST);
    gl.Enable(GL_LIGHTING);
    gl.Enable(GL_CULL_FACE);
    gl.Enable(GL_COLOR_MATERIAL);
    gl.Enable(GL_TEXTURE_2D);
    gl.ClearColor(FBackgroundColor.x, FBackgroundColor.y, FBackgroundColor.z, 1.0);
    if bVSync then
      gl.SwapInterval(1)
    else
      gl.SwapInterval(0);

    ShowWindow(FWHandle, CmdShow);
    UpdateWindow(FWHandle);

    FCamera := TdfCamera.Create();
    FCamera.Viewport(FdesRect.Left, FdesRect.Top, FdesRect.Right, FdesRect.Bottom, cFOV, cZNear, cZFar);
    FCamera.SetCamera(camPos, camLook, camUp);

    FLight := TdfLight.Create;
    with FLight do
    begin
      Position := lightPos;
      Ambient := lAmb;
      Diffuse := lDif;
      Specular := lSpec;
      ConstAtten := lConstAtten;
      LinearAtten := lLinearAtten;
      QuadraticAtten := lQuadroAtten;
      DebugRender := bDrawLight;
    end;

//    Light.LightInit();
//    renderLightSet(lightPos.x, lightPos.y, lightpos.z,
//                   lAmb.x, lAmb.y, lAmb.z, lAmb.w,
//                   lDif.x, lDif.y, lDif.z, lDif.z,
//                   lSpec.x, lSpec.y, lSpec.z, lSpec.w,
//                   lConstAtten, lLinearAtten, lQuadroAtten);
//    Sprites.SpriteInit(atomColor);
//    Shaders.ShadersInit();

//    Scale := 1.0;

    QueryPerformanceFrequency(FFreq);
    FRenderReady := True;

    logWriteMessage('�������� �������������');
    Result := 0;
  except
    Result := -1;
  end;
end;

function TdfRenderer.Step(deltaTime: Double): Integer;

  procedure DrawAxes();
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
    gl.Clear(GL_COLOR_BUFFER_BIT);
    gl.Clear(GL_DEPTH_BUFFER_BIT);
    gl.MatrixMode(GL_MODELVIEW);
    gl.PushMatrix();
      FCamera.Update();
      if FDrawAxes then
        DrawAxes();
      FLight.Render(deltaTime);
      FRootNode.Render(deltaTime);
      FSprite.DoRender;

      if dfInput.IsKeyDown(VK_MOUSEWHEELUP) then
      begin
        FCamera.Scale(0.9);
      end;

      if dfInput.IsKeyDown(VK_MOUSEWHEELDOWN) then
      begin
        FCamera.Scale(1.1);
      end;
    gl.PopMatrix();
    Windows.SwapBuffers(FWDC);
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

function TdfRenderer.Start(): Integer;
var
  msg: TMsg;
begin
  repeat
    if PeekMessage(msg, 0, 0, 0, PM_NOREMOVE) then
    begin
      if GetMessage(msg, 0, 0, 0) then
      begin
        TranslateMessage(msg);
        DispatchMessage(msg);
      end;
    end
    else
    begin
      //SendMessage(FWHandle, 15, 0, 0);  //WM_PAINT
      QueryPerformanceCounter(FNewTicks);
      FDeltaTime := (FNewTicks - FOldTicks) / FFreq;
      FOldTicks := FNewTicks;
//      Inc(FFrames);
      FFPS :=  1 / FDeltaTime;
//      if RenderReady then
      Step(FDeltaTime);
//      if FFrames >= 1000 then
//      begin
//        //����� ���
//        SetWindowText(WHandle, FloatToStr(FPS));
//        FFrames := 0;
//      end;
    end;
  until GetAsyncKeyState(VK_ESCAPE) < 0;
end;

function TdfRenderer.DeInit(): Integer;
begin
  Result := 0;
  logWriteMessage('��������������� �������');
  try
    FRenderReady := False;
    FCamera := nil;
    FLight := nil;
//    Camera.CameraDeInit();
//    Light.LightDeInit();
//    Sprites.SpriteDeInit();
//    Textures.TexDeInit();
    wglDeleteContext(FGLRC);
    ReleaseDC(FWHandle, FWDC);
    wglMakeCurrent(FWDC, 0);
    FWDC := 0;
    FGLRC := 0;
    CloseWindow(FWHandle);
    DestroyWindow(FWHandle);
    FWHandle := 0;
    Logger.LogDeinit();
  except
    Result := -1;
    Exit;
  end;
  //*
end;

{$ENDREGION}

end.
