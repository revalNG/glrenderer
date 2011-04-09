unit dfHRenderer;

interface

uses
  Windows;

const
  dllName = 'glrenderer.dll';

type
  IdfCamera = interface

  end;

  IdfRenderer = interface
    function Init(FileName: PAnsiChar): Integer;
    function Step(deltaTime: Double): Integer;
    function Start(): Integer;
    function DeInit(): Integer;

    function GetWindowHandle(): Integer;
    function GetWindowCaption(): PAnsiChar;
    procedure SetWindowCaption(aCaption: PAnsiChar);
    function GetRenderReady(): Boolean;
    function GetFPS(): Single;
    function GetCamera(): IdfCamera;
    procedure SetCamera(aCamera: IdfCamera);

    property WindowHandle: Integer read GetWindowHandle;
    property WindowCaption: PAnsiChar read GetWindowCaption write SetWindowCaption;
    property RenderReady: Boolean read GetRenderReady;
    property FPS: Single read GetFPS;

    property Camera: IdfCamera read GetCamera write SetCamera;
  end;

var

  dfCreateRenderer: function(): IdfRenderer; stdcall;
  dllHandle: THandle;

implementation

initialization
  dllHandle := LoadLibrary(dllname);
  dfCreateRenderer := GetProcAddress(dllHandle, 'CreateRenderer');

end.
