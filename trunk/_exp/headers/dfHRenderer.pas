unit dfHRenderer;

interface

uses
  Windows,
  dfMath;

const
  dllName = 'glrenderer.dll';

type
  {$REGION ' Resource manager '}

  IdfResource = interface
    ['{A95929A4-C8B6-4EE3-844F-E5C9B5E1249A}']
  end;

  IdfResourceManager = interface
    ['{BF733D21-0F1B-4907-98B0-F03F2B0FFCCB}']
  end;

  {$ENDREGION}

  {$REGION ' Texture, shaders and material '}

  IdfTexture = interface
    ['{3D75E1EB-E4C8-4856-BA55-B98020407605}']
  end;

  IdfShader = interface
    ['{5C020C83-273C-4351-A41E-3AE8D12C8A90}']
  end;

  IdfShaderProgram = interface
    ['{B31B84F3-D71D-4117-B5D7-3BEAD6E5D5E2}']
  end;

  IdfMaterialOptions = interface
    ['{8FE8BC07-F1A4-481A-9E24-966941969FCB}']

//    property Ambient:
//    property Diffuse
  end;

  IdfMaterial = interface
    ['{DE277592-0C48-4DA0-971F-780470FCCA04}']
    {$REGION '[private]'}
    function GetTexture: IdfTexture;
    procedure SetTexture(const aTexture: IdfTexture);
    function GetShader(): IdfShaderProgram;
    procedure SetShader(const aShader: IdfShaderProgram);
    function GetOptions(): IdfMaterialOptions;
    procedure SetOptions(const aOptions: IdfMaterialOptions);
    {$ENDREGION}

    property Texture: IdfTexture read GetTexture write SetTexture;
    property ShaderProgram: IdfShaderProgram read GetShader write SetShader;
    property MaterialOptions: IdfMaterialOptions read GetOptions write SetOptions;
  end;

  {$ENDREGION}

  IdfRenderable = interface
    ['{A2DD3046-3FDE-43DD-93AE-83C7A29A2196}']
    {$REGION '[private]'}
    function GetMaterial(): IdfMaterial;
    procedure SetMaterial(const aMat: IdfMaterial);
    {$ENDREGION}
    procedure DoRender;

    property Material: IdfMaterial read GetMaterial write SetMaterial;
  end;

  IdfNode = interface
    ['{3D31C699-4B5F-4FC3-8F08-2E91BA918135}']
    {$REGION '[private]'}
    function GetPos(): TdfVec3f;
    procedure SetPos(const aPos: TdfVec3f);
    function GetUp(): TdfVec3f;
    procedure SetUp(const aUp: TdfVec3f);
    function GetDir(): TdfVec3f;
    procedure SetDir(const aDir: TdfVec3f);
    function GetLeft(): TdfVec3f;
    procedure SetLeft(const aLeft: TdfVec3f);
    function GetModel(): TdfMat4f;
    procedure SetModel(const aModel: TdfMat4f);
    function GetVis(): Boolean;
    procedure SetVis(const aVis: Boolean);
    function GetChild(Index: Integer): IdfNode;
    procedure SetChild(Index: Integer; aChild: IdfNode);
    function GetParent(): IdfNode;
    procedure SetParent(const aParent: IdfNode);
    function GetRenderable(): IdfRenderable;
    procedure SetRenderable(const aRenderable: IdfRenderable);
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
    function AddChild(aChild: IdfNode): Integer;
    //Добавить нового потомка
    function AddNewChild(): IdfNode;
    //Удалить потомка из списка по индексу. Физически объект остается в памяти.
    procedure RemoveChild(Index: Integer); overload;
    //Удалить потомка из списка по указателю. Физически объект остается в памяти.
    procedure RemoveChild(aChild: IdfNode); overload;
    //Удалить потомка из списка по индексу. Физически объект уничтожается.
    procedure FreeChild(Index: Integer);

    procedure Render(aDeltaTime: Single);
  end;

  IdfCamera = interface (IdfNode)
    ['{D6E97126-FF5F-4CE7-9687-4F358A90B34E}']
    procedure Viewport(x, y, w, h: Integer; FOV, ZNear, ZFar: Single);
    procedure Pan(X, Y: Single);
    procedure Scale(aScale: Single);
    procedure Rotate(delta: Single; Axis: TdfVec3f);
    procedure SetCamera(Pos, TargetPos, Up: TdfVec3f);
    procedure SetTarget(Point: TdfVec3f); overload;
    procedure SetTarget(Target: IdfNode); overload;

    procedure Update();
  end;

  IdfLight = interface (IdfNode)
    ['{2F9B9229-7A8D-4517-9E5D-DB135E1A6929}']
    {$REGION '[private]'}
    function GetAmb(): TdfVec4f;
    procedure SetAmb(const aAmb: TdfVec4f);
    function GetDif(): TdfVec4f;
    procedure SetDif(const aDif: TdfVec4f);
    function GetSpec(): TdfVec4f;
    procedure SetSpec(const aSpec: TdfVec4f);
    function GetConstAtten(): Single;
    procedure SetConstAtten(const aAtten: Single);
    function GetLinAtten(): Single;
    procedure SetLinAtten(const aAtten: Single);
    function GetQuadroAtten(): Single;
    procedure SetQuadroAtten(const aAtten: Single);
    function GetDR(): Boolean;
    procedure SetDR(aDR: Boolean);
    {$ENDREGION}

    property Ambient: TdfVec4f read GetAmb write SetAmb;
    property Diffuse: TdfVec4f read GetDif write SetDif;
    property Specular: TdfVec4f read GetSpec write SetSpec;

    property ConstAtten: Single read GetConstAtten write SetConstAtten;
    property LinearAtten: Single read GetLinAtten write SetLinAtten;
    property QuadraticAtten: Single read GetQuadroAtten write SetQuadroAtten;

    property DebugRender: Boolean read GetDR write SetDR;
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
    procedure SetCamera(const aCamera: IdfCamera);
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

  IdfMesh = interface (IdfRenderable)
    ['{90223F0B-7F8F-4EBF-9752-DF84CE75B7E7}']

  end;

  IdfSprite = interface (IdfRenderable)
    ['{C8048F34-9F3D-4E58-BC71-633F2413A9A5}']
    {$REGION '[private]'}
    function GetWidth(): Integer;
    procedure SetWidth(const aWidth: Integer);
    function GetHeight(): Integer;
    procedure SetHeight(const aHeight: Integer);
    {$ENDREGION}
    property Width: Integer read GetWidth write SetWidth;
    property Height: Integer read GetHeight write SetHeight;
  end;

  IdfScene = interface
    ['{5E52434E-3A00-478E-AE73-BA45C77BD2AC}']
    {$REGION '[private]'}
    function GetRoot: IdfNode;
    procedure SetRoot(const aRoot: IdfNode);
    {$ENDREGION}
    property RootNode: IdfNode read GetRoot write SetRoot;
  end;

  procedure LoadRendererLib();
  procedure UnLoadRendererLib();

var
  dfCreateRenderer: function(): IdfRenderer; stdcall;
  dfCreateNode: function(aParent: IdfNode): IdfNode; stdcall;
  dllHandle: THandle;

implementation

procedure LoadRendererLib();
begin
  dllHandle := LoadLibrary(dllname);
  dfCreateRenderer := GetProcAddress(dllHandle, 'CreateRenderer');
  dfCreateNode := GetProcAddress(dllHandle, 'CreateNode');
end;

procedure UnLoadRendererLib();
begin
//  dfCreateRenderer := nil;
//  dfCreateNode := nil;
//  FreeLibrary(dllHandle);
end;

end.
