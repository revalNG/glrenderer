unit uRenderer;

interface

uses
  Windows, Messages, SysUtils, Classes,
  dfHGL, dfHRenderer, dfMath,
  uCamera;

type
  TdfRenderer = class(TInterfacedObject, IdfRenderer)
  private
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

    {debug}
//    FSprite: IdfSprite;
    FLight: IdfLight;
    bL, bR, bU, bD: Boolean;

    //коллбэки для мыши
    FOnMouseDown: TdfOnMouseDownProc;
    FOnMouseUp: TdfOnMouseUpProc;
    FOnMouseMove: TdfOnMouseMoveProc;
    FOnMouseWheel: TdfOnMouseWheelProc;

    //Коллбэк на апдейт
    FOnUpdate: TdfOnUpdateProc;

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

    function GetSelfVersion(): String;

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

    function Init(FileName: PAnsiChar): Integer;
    function Step(deltaTime: Double): Integer;
    function Start(): Integer;
    function DeInit(): Integer;

    property WindowHandle: Integer read GetWindowHandle;
    property WindowCaption: PWideChar read GetWindowCaption write SetWindowCaption;
    property RenderReady: Boolean read GetRenderReady;
    property FPS: Single read GetFPS;

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
  cDefWindowCaption = 'glRenderer :: render window';

  cDefConstAtten = 1;
  cDefLinearAtten = 1;
  cDefQuadroAtten = 1;

var
  //Сохраненные значения, переданные юзером при инициализации рендера
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

  MsgRec: TMessage;
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
          //Вывод фпс
          //SetWindowText(FWHandle, cDefWindowCaption + ' :: ' + FloatToStr(FPS));
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
    MsgRec.Msg := Msg;
  MsgRec.WParam := wParam;
  MsgRec.LParam := lParam;
  MsgRec.Result := Result;
  if Assigned(TheRenderer) and TheRenderer.RenderReady then
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

procedure TdfRenderer.SetCamera(aCamera: IdfCamera);
begin
  FCamera := aCamera;
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

constructor TdfRenderer.Create;
begin
  FRenderReady := False;
  FWHandle := 0;
  FWCaption := cDefWindowCaption;

  FRootNode := TdfNode.Create();
end;

destructor TdfRenderer.Destroy;
begin
  FRenderReady := False;
  inherited;
end;

function TdfRenderer.Init(FileName: PAnsiChar): Integer;
var
  strData: TFileStream;
  par: TParser;
  camPos, camLook, camUp, lightPos: TdfVec3f;
  lAmb, lDif, lSpec: TdfVec4f; //Цвет источника света
  lConstAtten, lLinearAtten, lQuadroAtten: Single; //Параметры источника света
  atomColor: TdfVec3f;
  cFOV, cZNear, cZFar: Single;
  bDrawLight, bVSync: Boolean;
  tmpString: String;
begin
  uLogger.LogInit();

  FWWidth := cDefWindowW;
  FWHeight := cDefWindowH;
  FWX := cDefWindowX;
  FWY := cDefWindowY;
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
    logWriteMessage('Успешная загрузка параметров из конфиг-файла ' + FileName);
  {$ENDREGION}

    //Инициализация
    FWStyle := WS_OVERLAPPEDWINDOW or WS_CLIPSIBLINGS or WS_CLIPCHILDREN;

    SetRect(FdesRect, 0, 0, FWWidth, FWHeight);
    AdjustWindowRect(FdesRect, FWStyle, False);
//    FWWidth := FdesRect.Right - FdesRect.Left;
//    FWHeight := FdesRect.Bottom - FdesRect.Top;
    //FWWidth := Abs(FdesRect.Left) + FdesRect.Right;
    //FWHeight := Abs(FdesRect.Top) + FdesRect.Bottom;
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
      Result := 1;
      Exit;
    end;
    logWriteMessage('Успешная инициализация окна, полученный handle: ' + IntToStr(FWHandle));

    FWDC := GetDC(FWHandle);

    if FWDC = 0 then
    begin
      logWriteError('Ошибка получения Device Context, возвращен нулевой контекст', True, True, True);
      Result := 2;
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
      Result := 3;
      Exit;
    end;

    logWriteMessage('Успешное получение PFD: ' + IntToStr(FnPixelFormat));

    SetPixelFormat(FWDC, FnPixelFormat, @Fpfd);

    FGLRC := wglCreateContext(FWDC);

    if FGLRC = 0 then
    begin
      logWriteError('Ошибка получения рендер-контекста, возвращен нулевой контекст', True, True, True);
      Result := 4;
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
    if bVSync then
      gl.SwapInterval(1)
    else
      gl.SwapInterval(0);

    ShowWindow(FWHandle, CmdShow);
    UpdateWindow(FWHandle);

    FCamera := TdfCamera.Create();
    //FCamera.Viewport(FdesRect.Left, FdesRect.Top, FdesRect.Right, FdesRect.Bottom, cFOV, cZNear, cZFar);
    FCamera.Viewport(0, 0, FWWidth, FWHeight, cFOV, cZNear, cZFar);
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

    logWriteMessage('Успешная инициализация');
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

  if Assigned(FOnUpdate) then
    FOnUpdate(deltaTime);

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

//      if dfInput.IsKeyDown(VK_MOUSEWHEELUP) then
//      begin
//        FCamera.Scale(0.9);
//      end;
//
//      if dfInput.IsKeyDown(VK_MOUSEWHEELDOWN) then
//      begin
//        FCamera.Scale(1.1);
//      end;
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
//        //Вывод фпс
//        SetWindowText(WHandle, FloatToStr(FPS));
//        FFrames := 0;
//      end;
    end;
  until GetAsyncKeyState(VK_ESCAPE) < 0;
end;

function TdfRenderer.DeInit(): Integer;
var
  i: Integer;
begin
  Result := 0;
  logWriteMessage('Деинициализация рендера');
  try
    FRenderReady := False;
    FCamera := nil;
    FLight := nil;

    //Необходимо для успешного удаления без утечек
//    with FRootNode do
//      for i := 0 to ChildsCount - 1 do
//        IdfNode(Childs[i]).Parent := nil;
//    FRootNode._Release();
    FRootNode := nil;

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
    uLogger.LogDeinit();
  except
    Result := -1;
    Exit;
  end;
  //*
end;

{$ENDREGION}

end.
