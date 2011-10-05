unit dfHRenderer;

interface

uses
  Windows,
  dfMath;

const
  dllName = 'glrenderer.dll';

type
  IdfRenderable = interface
    ['{A2DD3046-3FDE-43DD-93AE-83C7A29A2196}']
    procedure Render;
  end;

  IdfNode = interface
    ['{3D31C699-4B5F-4FC3-8F08-2E91BA918135}']
    {$REGION '[private]'}
    function GetPos(): TdfVec3f;
    procedure SetPos(aPos: TdfVec3f);
    function GetUp(): TdfVec3f;
    procedure SetUp(aUp: TdfVec3f);
    function GetDir(): TdfVec3f;
    procedure SetDir(aDir: TdfVec3f);
    function GetLeft(): TdfVec3f;
    procedure SetLeft(aLeft: TdfVec3f);
    function GetModel(): TdfMat4f;
    procedure SetModel(aModel: TdfMat4f);
    function GetVis(): Boolean;
    procedure SetVis(aVis: Boolean);
    function GetChild(Index: Integer): IdfNode;
    procedure SetChild(Index: Integer; aChild: IdfNode);
    function GetParent(): IdfNode;
    procedure SetParent(aParent: IdfNode);
    function GetRenderable(): IdfRenderable;
    procedure SetRenderable(aRenderable: IdfRenderable);
    {$ENDREGION}

    property Position: TdfVec3f read GetPos write SetPos;
    property Up: TdfVec3f read GetUp write SetUp;
    property Direction: TdfVec3f read GetDir write SetDir;
    property Left: TdfVec3f read GetLeft write SetLeft;
    property ModelMatrix: TdfMat4f read GetModel write SetModel;
    property Parent: IdfNode read GetParent write SetParent;
    property Visible: Boolean read GetVis write SetVis;

    property Childs[Index: Integer]: IdfNode read GetChild write SetChild;
    property Renderable: IdfRenderable read GetRenderable write SetRenderable;

    //Добавить уже существующий рендер-узел себе в потомки
    function AddChild(AChild: IdfNode): Integer;
    //Удалить потомка из списка по индексу. Физически объект остается в памяти.
    procedure RemoveChild(Index: Integer); overload;
    //Удалить потомка из списка по указателю. Физически объект остается в памяти.
    procedure RemoveChild(AChild: IdfNode); overload;
    //Удалить потомка из списка по индексу. Физически объект уничтожается.
    procedure FreeChild(Index: Integer);
  end;

  IdfCamera = interface
    ['{D6E97126-FF5F-4CE7-9687-4F358A90B34E}']
    procedure Pan(X, Y: Single);
    procedure Scale(aScale: Single);
    procedure Rotate(delta: Single; Axis: TdfVec3f);
    procedure SetCamera(Pos, TargetPos, Up: TdfVec3f);
    procedure SetTarget(Point: TdfVec3f); overload;
    procedure SetTarget(Target: IdfNode); overload;
  end;

  IdfRenderer = interface
    ['{BFB518E7-A55A-48E2-B0C4-ED7BE8D23796}']
    {$REGION '[private]'}
    function GetWindowHandle(): Integer;
    function GetWindowCaption(): PAnsiChar;
    procedure SetWindowCaption(aCaption: PAnsiChar);
    function GetRenderReady(): Boolean;
    function GetFPS(): Single;
    function GetCamera(): IdfCamera;
    procedure SetCamera(aCamera: IdfCamera);
    {$ENDREGION}

    function Init(FileName: PAnsiChar): Integer;
    function Step(deltaTime: Double): Integer;
    function Start(): Integer;
    function DeInit(): Integer;

    property WindowHandle: Integer read GetWindowHandle;
    property WindowCaption: PAnsiChar read GetWindowCaption write SetWindowCaption;
    property RenderReady: Boolean read GetRenderReady;
    property FPS: Single read GetFPS;

    property Camera: IdfCamera read GetCamera write SetCamera;
  end;

  IdfMesh = interface
    ['{90223F0B-7F8F-4EBF-9752-DF84CE75B7E7}']

  end;

  IdfScene = interface
    ['{5E52434E-3A00-478E-AE73-BA45C77BD2AC}']
    function GetRoot: IdfNode;
    procedure SetRoot(aRoot: IdfNode);
    property RootNode: IdfNode read GetRoot write SetRoot;
  end;

var

  dfCreateRenderer: function(): IdfRenderer; stdcall;
  dllHandle: THandle;

implementation

initialization
  dllHandle := LoadLibrary(dllname);
  dfCreateRenderer := GetProcAddress(dllHandle, 'CreateRenderer');

end.
