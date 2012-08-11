unit uRenderer;

interface

uses
  Windows, Messages, SysUtils, Classes,
  dfHGL, dfHRenderer, dfMath,
  uCamera;

type
  TdfRenderer = class(TInterfacedObject, IdfRenderer)
  private
    FEnabled: Boolean;
    //Готовность рендера к, собственно, рендеру
    FRenderReady: Boolean;

    //Параметры окна
    FWHandle: THandle;
    FWCaption: PWideChar;
    FWWidth, FWHeight, FWX, FWY: Integer;
    FdesRect: TRect;
    FWStyle: Cardinal;
    FWndClass: TWndClass;
    FWDC: hDC;

    //Собственное ли окно создано (True), или используем "паразитизм" (False)
    FSelfWindow: Boolean;
    //Для чужого окна сохраняем ссылку на его процедуру
    FParentWndProc: Integer;

    //Курсоры
    FhDefaultCursor, FhHandCursor: HICON;

    FPFD: TPixelFormatDescriptor;
    FnPixelFormat: Integer;

    //Рендер-контекст
    FGLRC: hglRC;

    //Параметры для высокоточного таймера
    FFrames: Integer;
    FNewTicks, FOldTicks, FFreq: Int64;
    FDeltaTime, FFPS: Single;

    //Параметры буфера и рисования(рендера)
    FBackgroundColor: TdfVec3f;
    FDrawAxes: Boolean;

    //Активная камера
    FCamera: IdfCamera;

    FRootNode: IdfNode;


    //коллбэки для мыши
    FOnMouseDown: TdfOnMouseDownProc;
    FOnMouseUp: TdfOnMouseUpProc;
    FOnMouseMove: TdfOnMouseMoveProc;
    FOnMouseWheel: TdfOnMouseWheelProc;

    //Коллбэк на апдейт
    FOnUpdate: TdfOnUpdateProc;

    procedure OpenGLInit(aVSync: Boolean; aFOV, aZNear, aZFar: Single; camPos, camLook, camUp: TdfVec3f);

    function GetWindowHandle(): Integer;
    function GetWindowCaption(): PWideChar;
    procedure SetWindowCaption(aCaption: PWideChar);
    function GetRenderReady(): Boolean;
    function GetFPS(): Single;
    function GetCamera(): IdfCamera;
    procedure SetCamera(aCamera: IdfCamera);
    function GetRoot: IdfNode;
    procedure SetRoot(aRoot: IdfNode);

    procedure SetOnMouseDown(aProc: TdfOnMouseDownProc);
    procedure SetOnMouseUp(aProc: TdfOnMouseUpProc);
    procedure SetOnMouseMove(aProc: TdfOnMouseMoveProc);
    procedure SetOnMouseWheel(aProc: TdfOnMouseWheelProc);

    function GetOnMouseDown(): TdfOnMouseDownProc;
    function GetOnMouseUp(): TdfOnMouseUpProc;
    function GetOnMouseMove(): TdfOnMouseMoveProc;
    function GetOnMouseWheel() : TdfOnMouseWheelProc;

    function GetOnUpdate(): TdfOnUpdateProc;
    procedure SetOnUpdate(aProc: TdfOnUpdateProc);

    function GetEnabled(): Boolean;
    procedure SetEnabled(aEnabled: Boolean);

    function GetSelfVersion(): String;

    function GetDC(): hDC;
    function GetRC(): hglRC;

    function GetWidth(): Integer;
    function GetHeight(): Integer;

    procedure WMLButtonDown    (var Msg: TMessage); message WM_LBUTTONDOWN;
    procedure WMLButtonUp      (var Msg: TMessage); message WM_LBUTTONUP;
    procedure WMLButtonDblClick(var Msg: TMessage); message WM_LBUTTONDBLCLK;

    procedure WMRButtonDown    (var Msg: TMessage); message WM_RBUTTONDOWN;
    procedure WMRButtonUp      (var Msg: TMessage); message WM_RBUTTONUP;
    procedure WMRButtonDblClick(var Msg: TMessage); message WM_RBUTTONDBLCLK;

    procedure WMMButtonDown    (var Msg: TMessage); message WM_MBUTTONDOWN;
    procedure WMMButtonUp      (var Msg: TMessage); message WM_MBUTTONUP;
    procedure WMMButtonDblClick(var Msg: TMessage); message WM_MBUTTONDBLCLK;

    procedure WMMouseMove      (var Msg: TMessage); message WM_MOUSEMOVE;
    procedure WMMouseWheel     (var Msg: TMessage); message WM_MOUSEWHEEL;

    procedure WMSize           (var Msg: TMessage); message WM_SIZE;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure Init(FileName: PAnsiChar); overload;
    procedure Init(Handle: THandle; FileName: PAnsiChar); overload;
    procedure Step(deltaTime: Double);
    procedure Start();
    procedure Stop();
    procedure DeInit();

    property WindowHandle: Integer read GetWindowHandle;
    property WindowCaption: PWideChar read GetWindowCaption write SetWindowCaption;
    property WindowWidth: Integer read GetWidth;
    property WindowHeight: Integer read GetHeight;


    property DC: hDC read GetDC;
    property RC: hglRC read GetRC;

    property RenderReady: Boolean read GetRenderReady;
    property FPS: Single read GetFPS;

    property VersionText: String read GetSelfVersion;

    property Camera: IdfCamera read GetCamera write SetCamera;

    property RootNode: IdfNode read GetRoot write SetRoot;

    property OnMouseDown: TdfOnMouseDownProc read GetOnMouseDown write SetOnMouseDown;
    property OnMouseUp: TdfOnMouseUpProc read GetOnMouseUp write SetOnMouseUp;
    property OnMouseMove: TdfOnMouseMoveProc read GetOnMouseMove write SetOnMouseMove;
    property OnMouseWheel: TdfOnMouseWheelProc read GetOnMouseWheel write SetOnMouseWheel;

    property OnUpdate: TdfOnUpdateProc read GetOnUpdate write SetOnUpdate;
  end;


  function WindowProc(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;

var
  TheRenderer: TdfRenderer;

implementation

uses
  uLight, uSprite, uTexture, uShader, uNode,
  dfHInput, dfHEngine, uLogger;


const
  cDefWindowW = 640;
  cDefWindowH = 480;
  cDefWindowX = 0;
  cDefWindowY = 0;
  cDefWindowCaption = 'Window';

function WindowProc(hWnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
var
//  x, y: Integer;
//  d: SmallInt;

  MsgRec: TMessage;
begin
  case Msg of
    WM_DESTROY:
    begin
      PostQuitMessage(0);
      Result := 0;
    end;
//    WM_PAINT:
//      with TheRenderer do
//      begin
//        QueryPerformanceCounter(FNewTicks);
//        FDeltaTime := (FNewTicks - FOldTicks) / FFreq;
//        FOldTicks := FNewTicks;
//        Inc(FFrames);
//        FFPS :=  1 / FDeltaTime;
//        if RenderReady then
//          Step(FDeltaTime);
//        if FFrames >= 100 then
//        begin
//          //Вывод фпс
//          //SetWindowText(FWHandle, cDefWindowCaption + ' :: ' + FloatToStr(FPS));
//          FFrames := 0;
//        end;
//        Result := 0;
//      end;
    WM_WINDOWPOSCHANGED:
      begin
      with TheRenderer do
        if RenderReady then
        begin
//          GetWindowRect(FWHandle, FdesRect);
//          FWWidth := FdesRect.Right - FdesRect.Left;
//          FWHeight := FdesRect.Bottom - FdesRect.Top;
//          Camera.ViewportOnly(0, 0, FWWidth, FWHeight);
          FWWidth := LOWORD(lParam);
          FWHeight := HIWORD(lParam);
          Camera.ViewportOnly(0, 0, FWWidth, FWHeight);
        end;
//          Camera.ViewportOnly(0, 0, FWWidth, FWHeight);
      //camera.CameraInit(0, 0, LOWORD(lParam), HIWORD(lParam), cFOV, cZNear, cZFar);
      Result := 0;
    end;
    WM_SIZE:
    begin
      with TheRenderer do
        if RenderReady then
        begin
          GetClientRect(FWHandle, FdesRect);
          FWWidth := FdesRect.Right - FdesRect.Left;
          FWHeight := FdesRect.Bottom - FdesRect.Top;
//          Camera.ViewportOnly(0, 0, FWWidth, FWHeight);
//          UpdateWindow(FWHandle);
//          FWWidth := LOWORD(lParam);
//          FWHeight := HIWORD(lParam);
//          Camera.ViewportOnly(0, 0, FWWidth, FWHeight);
          Camera.Viewport(0, 0, FWWidth, FWHeight, 90, 0.1, 500);
        end;
//          Camera.ViewportOnly(0, 0, FWWidth, FWHeight);
      //camera.CameraInit(0, 0, LOWORD(lParam), HIWORD(lParam), cFOV, cZNear, cZFar);
      Result := 0;
    end;
//    WM_MOUSEMOVE:
//    begin
//      //Нажата левая кнопка мыши, и идет движение
//      if wParam and MK_LBUTTON <> 0 then
//      begin
//        x := LOWORD(lParam);
//        y := HIWORD(lParam);
//        with TheRenderer.Camera do
//        begin
//          Rotate(deg2rad*(x - dx), Up);
//          Rotate(deg2rad*(y - dy), Left);
//        end;
//        dx := x;
//        dy := y;
//      end;
      //Нажата правая кнопка мыши, и идет движение
//      if wParam and MK_RBUTTON <> 0 then
//      begin
//        SetCursor(TheRenderer.FhHandCursor);
//        x := LOWORD(lParam);
//        y := HIWORD(lParam);
//        TheRenderer.Camera.Pan(y - dy, dx - x);
//        dx := x;
//        dy := y;
//      end;
//    end;
//    WM_LBUTTONDOWN:
//    begin
//      dx := LOWORD(lParam);
//      dy := HIWORD(lParam);
//    end;
//    WM_LBUTTONUP:
//    begin
//      dX := 0;
//      dY := 0;
//    end;

//    WM_RBUTTONDOWN:
//    begin
//      dx := LOWORD(lParam);
//      dy := HIWORD(lParam);
//      SetCursor(TheRenderer.FhHandCursor);
//    end;
//    WM_RBUTTONUP:
//    begin
//      dX := 0;
//      dY := 0;
//    end;

    WM_ERASEBKGND:
      Result := 0

//    WM_MOUSEWHEEL:
//    begin
//      d := HIWORD(wParam);
//      dfInput.KeyboardNotifyWheelMoved(d);
//    end
  else
    Result := DefWindowProc(hWnd, Msg, wParam, lParam);
  end;
  MsgRec.Msg := Msg;
  MsgRec.WParam := wParam;
  MsgRec.LParam := lParam;
  MsgRec.Result := Result;
  if Assigned(TheRenderer) and TheRenderer.RenderReady and (TheRenderer.FWHandle <> 0) then
    TheRenderer.Dispatch(MsgRec);
end;

{$REGION 'Класс TdfRenderer'}

function TdfRenderer.GetWindowHandle(): Integer;
begin
  if FRenderReady then
    Result := FWHandle
  else
    Result := 0;
end;

procedure TdfRenderer.OpenGLInit(aVSync: Boolean; aFOV, aZNear, aZFar: Single; camPos, camLook, camUp: TdfVec3f);
begin
  FWDC := Windows.GetDC(FWHandle);

  if FWDC = 0 then
  begin
    logWriteError('Ошибка получения Device Context, возвращен нулевой контекст', True, True, True);
    Exit;
  end;

  logWriteMessage('Успешное получение Device Context: ' + IntToStr(FWDC));

  Fpfd.nSize := SizeOf(PIXELFORMATDESCRIPTOR);
  Fpfd.nVersion := 1;
  Fpfd.dwFlags  := PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER;
  Fpfd.iPixelType := PFD_TYPE_RGBA;
  Fpfd.cColorBits := 32;

  FnPixelFormat := ChoosePixelFormat(FWDC, @Fpfd);

  if FnPixelFormat = 0 then
  begin
    logWriteError('Ошибка получения дескриптора пиксельного формата PDF, возвращен нулевой дескриптор', True, True, True);
    Exit;
  end;

  logWriteMessage('Успешное получение PFD: ' + IntToStr(FnPixelFormat));

  SetPixelFormat(FWDC, FnPixelFormat, @Fpfd);

  FGLRC := wglCreateContext(FWDC);

  if FGLRC = 0 then
  begin
    logWriteError('Ошибка получения рендер-контекста, возвращен нулевой контекст', True, True, True);
    Exit;
  end;

  logWriteMessage('Успешное получение рендер-контекста: ' + IntToStr(FGLRC));

  wglMakeCurrent(FWDC, FGLRC);

  gl.Init;
  gl.Enable(GL_DEPTH_TEST);
  gl.Enable(GL_LIGHTING);
  gl.Enable(GL_CULL_FACE);
  gl.Enable(GL_COLOR_MATERIAL);
  gl.Enable(GL_TEXTURE_2D);
  gl.ClearColor(FBackgroundColor.x, FBackgroundColor.y, FBackgroundColor.z, 1.0);
  if aVSync then
    gl.SwapInterval(1)
  else
    gl.SwapInterval(0);

  ShowWindow(FWHandle, CmdShow);
  UpdateWindow(FWHandle);

  FCamera := TdfCamera.Create();
  FCamera.Viewport(0, 0, FWWidth, FWHeight, aFOV, aZNear, aZFar);
  FCamera.SetCamera(camPos, camLook, camUp);

  QueryPerformanceFrequency(FFreq);
end;

function TdfRenderer.GetWidth: Integer;
begin
  Result := FWWidth;
end;

function TdfRenderer.GetWindowCaption(): PWideChar;
begin
  Result := FWCaption;
end;

procedure TdfRenderer.SetWindowCaption(aCaption: PWideChar);
begin
  //if FWCaption <> aCaption then
  begin
    SetWindowText(FWHandle, aCaption);
    FWCaption := aCaption;
  end;
end;

function TdfRenderer.GetRC: hglRC;
begin
  Result := FGLRC;
end;

function TdfRenderer.GetRenderReady(): Boolean;
begin
  Result := FRenderReady;
end;

function TdfRenderer.GetRoot: IdfNode;
begin
  Result := FRootNode;
end;

function TdfRenderer.GetSelfVersion: String;
var
  FileName: String;
  VerInfoSize: Cardinal;
  VerValueSize: Cardinal;
  Dummy: Cardinal;
  PVerInfo: Pointer;
  PVerValue: PVSFixedFileInfo;
begin
  FileName := dfHRenderer.dllName;
  Result := '';
  VerInfoSize := GetFileVersionInfoSize(PChar(FileName), Dummy);
  GetMem(PVerInfo, VerInfoSize);
  try
    if GetFileVersionInfo(PChar(FileName), 0, VerInfoSize, PVerInfo) then
      if VerQueryValue(PVerInfo, '\', Pointer(PVerValue), VerValueSize) then
        with PVerValue^ do
          Result := Format('v%d.%d.%d build %d', [
            HiWord(dwFileVersionMS), //Major
            LoWord(dwFileVersionMS), //Minor
            HiWord(dwFileVersionLS), //Release
            LoWord(dwFileVersionLS)]); //Build
  finally
    FreeMem(PVerInfo, VerInfoSize);
  end;
end;

function TdfRenderer.GetFPS(): Single;
begin
  Result := FFPS;
end;

function TdfRenderer.GetHeight: Integer;
begin
  Result := FWHeight;
end;

function TdfRenderer.GetOnMouseDown: TdfOnMouseDownProc;
begin
  Result := FOnMouseDown;
end;

function TdfRenderer.GetOnMouseMove: TdfOnMouseMoveProc;
begin
  Result := FOnMouseMove;
end;

function TdfRenderer.GetOnMouseUp: TdfOnMouseUpProc;
begin
  Result := FOnMouseUp;
end;

function TdfRenderer.GetOnMouseWheel: TdfOnMouseWheelProc;
begin
  Result := FOnMouseWheel;
end;

function TdfRenderer.GetOnUpdate: TdfOnUpdateProc;
begin
  Result := FOnUpdate;
end;

function TdfRenderer.GetCamera(): IdfCamera;
begin
  Result := FCamera;
end;

function TdfRenderer.GetDC: hDC;
begin
  Result := FWDC;
end;

function TdfRenderer.GetEnabled: Boolean;
begin
  Result := FEnabled;
end;

procedure TdfRenderer.SetCamera(aCamera: IdfCamera);
begin
  FCamera := aCamera;
end;

procedure TdfRenderer.SetEnabled(aEnabled: Boolean);
begin
  FEnabled := aEnabled;
end;

procedure TdfRenderer.SetOnMouseDown(aProc: TdfOnMouseDownProc);
begin
  FOnMouseDown := aProc;
end;

procedure TdfRenderer.SetOnMouseMove(aProc: TdfOnMouseMoveProc);
begin
  FOnMouseMove := aProc;
end;

procedure TdfRenderer.SetOnMouseUp(aProc: TdfOnMouseUpProc);
begin
  FOnMouseUp := aProc;
end;

procedure TdfRenderer.SetOnMouseWheel(aProc: TdfOnMouseWheelProc);
begin
  FOnMouseWheel := aProc;
end;

procedure TdfRenderer.SetOnUpdate(aProc: TdfOnUpdateProc);
begin
  FOnUpdate := aProc;
end;

procedure TdfRenderer.SetRoot(aRoot: IdfNode);
begin
  FRootNode := aRoot;
end;

{$REGION 'Коллбэки'}

procedure TdfRenderer.WMLButtonDown(var Msg: TMessage);
var
  X, Y: TdfInteger;
begin
  if Assigned(FOnMouseDown) then
  begin
    X := LOWORD(Msg.LParam);
    Y := HIWORD(Msg.LParam);
//    Include(ShiftState, ssLeft);
    FOnMouseDown(X, Y, mbLeft, []);
  end;
end;

procedure TdfRenderer.WMLButtonUp(var Msg: TMessage);
var
  X, Y: TdfInteger;
begin
  if Assigned(FOnMouseUp) then
  begin
    X := LOWORD(Msg.LParam);
    Y := HIWORD(Msg.LParam);
//    Exclude(ShiftState, ssLeft);
    FOnMouseUp(X, Y, mbLeft, []);
  end;
end;

procedure TdfRenderer.WMLButtonDblClick(var Msg: TMessage);
var
  X, Y: TdfInteger;
begin
  if Assigned(FOnMouseDown) then
  begin
    X := LOWORD(Msg.LParam);
    Y := HIWORD(Msg.LParam);
    FOnMouseDown(X, Y, mbLeft, [ssDouble]);
  end;
end;

procedure TdfRenderer.WMRButtonDown(var Msg: TMessage);
var
  X, Y: TdfInteger;
begin
  if Assigned(FOnMouseDown) then
  begin
    X := LOWORD(Msg.LParam);
    Y := HIWORD(Msg.LParam);
//    Include(ShiftState, ssRight);
    FOnMouseDown(X, Y, mbRight, []);
  end;
end;

procedure TdfRenderer.WMRButtonUp(var Msg: TMessage);
var
  X, Y: TdfInteger;
begin
  if Assigned(FOnMouseUp) then
  begin
    X := LOWORD(Msg.LParam);
    Y := HIWORD(Msg.LParam);
//    Exclude(ShiftState, ssRight);
    FOnMouseUp(X, Y, mbRight, []);
  end;
end;

procedure TdfRenderer.WMRButtonDblClick(var Msg: TMessage);
var
  X, Y: TdfInteger;
begin
  if Assigned(FOnMouseDown) then
  begin
    X := LOWORD(Msg.LParam);
    Y := HIWORD(Msg.LParam);
    FOnMouseDown(X, Y, mbRight, [ssDouble]);
  end;
end;

procedure TdfRenderer.WMMButtonDown(var Msg: TMessage);
var
  X, Y: TdfInteger;
begin
  if Assigned(FOnMouseDown) then
  begin
    X := LOWORD(Msg.LParam);
    Y := HIWORD(Msg.LParam);
//    Include(ShiftState, ssMiddle);
    FOnMouseDown(X, Y, mbMiddle, []);
  end;
end;

procedure TdfRenderer.WMMButtonUp(var Msg: TMessage);
var
  X, Y: TdfInteger;
begin
  if Assigned(FOnMouseUp) then
  begin
    X := LOWORD(Msg.LParam);
    Y := HIWORD(Msg.LParam);
//    Exclude(ShiftState, ssMiddle);
    FOnMouseUp(X, Y, mbMiddle, []);
  end;
end;

procedure TdfRenderer.WMMButtonDblClick(var Msg: TMessage);
var
  X, Y: TdfInteger;
begin
  if Assigned(FOnMouseDown) then
  begin
    X := LOWORD(Msg.LParam);
    Y := HIWORD(Msg.LParam);
    FOnMouseDown(X, Y, mbMiddle, [ssDouble]);
  end;
end;

procedure TdfRenderer.WMMouseMove(var Msg: TMessage);
var
  X, Y: TdfInteger;
  Shift: TdfMouseShiftState;
begin
  if Assigned(FOnMouseMove) then
  begin
    X := LOWORD(Msg.LParam);
    Y := HIWORD(Msg.LParam);
    if Msg.wParam and MK_LBUTTON <> 0 then
      Include(Shift, ssLeft);
    if Msg.wParam and MK_RBUTTON <> 0 then
      Include(Shift, ssRight);
    if Msg.wParam and MK_MBUTTON <> 0 then
      Include(Shift, ssMiddle);

    FOnMouseMove(X, Y, Shift);
  end;
end;

procedure TdfRenderer.WMMouseWheel(var Msg: TMessage);
var
  delta: SmallInt;
begin
  delta := HIWORD(Msg.WParam);
  dfInput.KeyboardNotifyWheelMoved(delta);
end;

procedure TdfRenderer.WMSize(var Msg: TMessage);
begin
//  if (Camera <> nil) then
    Camera.ViewportOnly(0, 0, LOWORD(Msg.lParam), HIWORD(Msg.lParam));
  //Camera.SetViewport(0, 0, LOWORD(Msg.lParam), HIWORD(Msg.lParam));
end;

{$ENDREGION}

constructor TdfRenderer.Create;
begin
  FRenderReady := False;
  FWHandle := 0;
  FWCaption := cDefWindowCaption;
  FEnabled := True;

  FRootNode := TdfNode.Create();

  uLogger.LogInit();
end;

destructor TdfRenderer.Destroy;
begin
  FRootNode := nil;
  FRenderReady := False;
  uLogger.LogDeinit();
  inherited;
end;

procedure TdfRenderer.Init(FileName: PAnsiChar);
var
  camPos, camLook, camUp: TdfVec3f;

  cFOV, cZNear, cZFar: Single;
  bVSync: Boolean;
  tmpString: String;

  procedure LoadSettings();
  var
    strData: TFileStream;
    par: TParser;
  begin
    if FileExists(FileName) then
      strData := TFileStream.Create(FileName, fmOpenRead)
    else
    begin
      logWriteError('Отсутствует файл конфига ' + FileName, True, True, True);
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
      else if par.TokenString = 'caption' then
      begin
        par.NextToken;
        FWCaption := PWideChar(par.TokenString);
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
    until par.NextToken = toEOF;
    par.Free;
    strData.Free;
    logWriteMessage('Успешная загрузка параметров из конфиг-файла ' + FileName);
  end;

  procedure InitWindow();
  begin
    //Инициализация
    FWStyle := WS_OVERLAPPEDWINDOW or WS_CLIPSIBLINGS or WS_CLIPCHILDREN;

    SetRect(FdesRect, 0, 0, FWWidth, FWHeight);
    AdjustWindowRect(FdesRect, FWStyle, False);
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
    tmpString := FWCaption + ' [glRenderer ' + GetSelfVersion + ']';
    FWHandle := CreateWindow('TdfWindow', PChar(tmpString), FWStyle,
                            FWX, FWY, FdesRect.Right - FdesRect.Left, FdesRect.Bottom - FdesRect.Top, 0, 0, FWndClass.hInstance, nil);
    if FWHandle = 0 then
    begin
      logWriteError('Ошибка инициализации окна. Возвращен нулевой handle', True, True, True);
      Exit;
    end;
    logWriteMessage('Успешная инициализация окна, полученный handle: ' + IntToStr(FWHandle));
  end;

begin
  FSelfWindow := True;

  FWWidth := cDefWindowW;
  FWHeight := cDefWindowH;
  FWX := cDefWindowX;
  FWY := cDefWindowY;

  try
    LoadSettings();

    InitWindow();

    OpenGLInit(bVSync, cFOV, cZNear, cZFar, camPos, camLook, camUp);

    FRenderReady := True;

    logWriteMessage('Успешная инициализация');
  except

  end;
end;

procedure TdfRenderer.Init(Handle: THandle; FileName: PAnsiChar);
var
  camPos, camLook, camUp: TdfVec3f;

  cFOV, cZNear, cZFar: Single;
  bVSync: Boolean;
  tmpString: String;

  procedure LoadSettings();
  var
    strData: TFileStream;
    par: TParser;
  begin
    if FileExists(FileName) then
      strData := TFileStream.Create(FileName, fmOpenRead)
    else
    begin
      logWriteError('Отсутствует файл конфига ' + FileName, True, True, True);
      Exit;
    end;
    par := TParser.Create(strData);
    repeat
      if par.TokenString = 'decimalseparator' then
      begin
        par.NextToken;
        DecimalSeparator := par.TokenString[1];
      end
      else if par.TokenString = 'caption' then
      begin
        par.NextToken;
        FWCaption := PWideChar(par.TokenString);
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
    until par.NextToken = toEOF;
    par.Free;
    strData.Free;
    logWriteMessage('Успешная загрузка параметров из конфиг-файла ' + FileName);
  end;

begin
  FSelfWindow := False;

  FWHandle := Handle;
  GetWindowRect(FWHandle, FdesRect);
  FWWidth := FdesRect.Right - FdesRect.Left;
  FWHeight := FdesRect.Bottom - FdesRect.Top;
  FParentWndProc := GetWindowLong(FWHandle, GWL_WNDPROC);
  SetWindowLong(FWHandle, GWL_WNDPROC, Integer(@WindowProc));
  FWX := 0;
  FWY := 0;
  try
    LoadSettings();

    OpenGLInit(bVSync, cFOV, cZNear, cZFar, camPos, camLook, camUp);

    FRenderReady := True;

    logWriteMessage('Успешная инициализация');
  except

  end;
end;

procedure TdfRenderer.Step(deltaTime: Double);

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
  if Assigned(FOnUpdate) then
    FOnUpdate(deltaTime);

  wglMakeCurrent(FWDC, FGLRC);
  gl.Clear(GL_COLOR_BUFFER_BIT);
  gl.Clear(GL_DEPTH_BUFFER_BIT);
  gl.MatrixMode(GL_MODELVIEW);
  gl.PushMatrix();
    FCamera.Update();
    if FDrawAxes then
      DrawAxes();

    FRootNode.Render(deltaTime);

  gl.PopMatrix();
  Windows.SwapBuffers(FWDC);
  wglMakeCurrent(0, 0);
end;

procedure TdfRenderer.Stop;
begin
  FEnabled := False;
end;

procedure TdfRenderer.Start();
var
  msg: TMsg;
begin
  repeat
    while PeekMessage(msg, 0, 0, 0, 1) do
    begin
//      if GetMessage(msg, 0, 0, 0) then
//      begin
        TranslateMessage(msg);
        DispatchMessageW(msg);
//      end;
    end;
//    else
//    begin
      QueryPerformanceCounter(FNewTicks);
      FDeltaTime := (FNewTicks - FOldTicks) / FFreq;
      FOldTicks := FNewTicks;
//      Inc(FFrames);
      if FDeltaTime > 1 then
        FDeltaTime := 0.5;
      FFPS :=  1 / FDeltaTime;
      if RenderReady then
        Step(FDeltaTime);
//      if FFrames >= 1000 then
//      begin
//        //Вывод фпс
//        SetWindowText(WHandle, FloatToStr(FPS));
//        FFrames := 0;
//      end;
//    end;
  until not FEnabled{GetAsyncKeyState(VK_ESCAPE) < 0};
end;

procedure TdfRenderer.DeInit();
begin
  logWriteMessage('Деинициализация рендера');
  FRenderReady := False;
  FCamera := nil;
  FRootNode := nil;
  wglMakeCurrent(FWDC, 0);
  wglDeleteContext(FGLRC);
  ReleaseDC(FWHandle, FWDC);
  FWDC := 0;
  FGLRC := 0;
  if FSelfWindow then
  begin
    CloseWindow(FWHandle);
    DestroyWindow(FWHandle);
  end
  else
    SetWindowLong(FWHandle, GWL_WNDPROC, FParentWndProc);
  FWHandle := 0;
end;

{$ENDREGION}

end.
