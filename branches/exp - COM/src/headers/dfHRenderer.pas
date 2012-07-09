unit dfHRenderer;

interface

uses
  Windows,
  dfMath;

const
  dllName = 'glrenderer.dll';

type
  {$REGION ' Resource manager '}

  { IdfResource - ресурс(изображение, звук, текстовый файл, бинарный файл) }
  IdfResource = interface
    ['{A95929A4-C8B6-4EE3-844F-E5C9B5E1249A}']
  end;

  { IdfResourceManager - менеджер по загрузке и использованию ресурсов }
  IdfResourceManager = interface
    ['{BF733D21-0F1B-4907-98B0-F03F2B0FFCCB}']
  end;

  {$ENDREGION}

  {$REGION ' Texture, shaders and material '}

  //Вид текстуры
  TdfTextureTarget = (ttTexture1D, ttTexture2D, ttTexture3D{, ttTextureRectangle,
                ttTextureRectangleNV,
                ttCubemap, ttCubemapPX, ttCubemapPY, ttCubemapNX, ttCubemapNY,
                ttCubemapPZ, ttCubemapNZ, tt1DArray, tt2DArray, ttCubeMapArray});
  //Режим враппинга (повторения и рамок)
  TdfTextureWrap = (twClamp, twRepeat, twClampToEdge, twClampToBorder, twMirrorRepeat);
//  TdfTexGens = (tgDisable,tgObjectLinear,tgEyeLinear,tgSphereMap,tgNormalMap,tgReflectionMap);
  //маг и мин фильтры
  TdfTextureMagFilter = (tmgNearest, tmgLinear);
  TdfTextureMinFilter = (tmnNearest, tmnLinear, tmnNearestMipmapNearest, tmnNearestMipmapLinear,
                tmnLinearMipmapNearest, tmnLinearMipmapLinear);
  //Режимы прозрачности
  TdfTextureBlendingMode = (tbmOpaque, tbmTransparency, tbmAdditive, tbmAlphaTest50,
                    tbmAlphaTest100, tbmModulate, tbmMesh);
  //Режимы смешивания с цветом
  TdfTextureCombineMode = (tcmDecal, tcmModulate, tcmBlend, tcmReplace, tcmAdd);


  IdfTexture = interface
    ['{3D75E1EB-E4C8-4856-BA55-B98020407605}']
    {$REGION '[private]'}
    function GetWidth(): Integer;
    function GetHeight(): Integer;

    function GetTexTarget(): TdfTextureTarget;
    function GetTexWrapS(): TdfTextureWrap;
    function GetTexWrapT(): TdfTextureWrap;
    function GetTexWrapR(): TdfTextureWrap;
    function GetTexMinFilter(): TdfTextureMinFilter;
    function GetTexMagFilter(): TdfTextureMagFilter;
    function GetTexBlendingMode(): TdfTextureBlendingMode;
    function GetTexCombineMode(): TdfTextureCombineMode;

    procedure SetTexWrapS(aWrap: TdfTextureWrap);
    procedure SetTexWrapT(aWrap: TdfTextureWrap);
    procedure SetTexWrapR(aWrap: TdfTextureWrap);
    procedure SetTexMinFilter(aFilter: TdfTextureMinFilter);
    procedure SetTexMagFilter(aFilter: TdfTextureMagFilter);
    procedure SetTexBlendingMode(aMode: TdfTextureBlendingMode);
    procedure SetTexCombineMode(aMode: TdfTextureCombineMode);
    {$ENDREGION}
    procedure Bind;
    procedure Unbind;

    {debug procedure
     Переделать на загрузку из Stream через ResourceManager}
    procedure Load2D(const aFileName: String); overload;

    property Target: TdfTextureTarget read GetTexTarget;
    property WrapS: TdfTextureWrap read GetTexWrapS write SetTexWrapS;
    property WrapT: TdfTextureWrap read GetTexWrapT write SetTexWrapT;
    property WrapR: TdfTextureWrap read GetTexWrapR write SetTexWrapR;
    property MinFilter: TdfTextureMinFilter read GetTexMinFilter write SetTexMinFilter;
    property MagFilter: TdfTextureMagFilter read GetTexMagFilter write SetTexMagFilter;
    property BlendingMode: TdfTextureBlendingMode read GetTexBlendingMode write SetTexBlendingMode;
    property CombineMode: TdfTextureCombineMode read GetTexCombineMode write SetTexCombineMode;

    property Width: Integer read GetWidth;
    property Height: Integer read GetHeight;

//    procedure Load();
  end;

  IdfShader = interface
    ['{5C020C83-273C-4351-A41E-3AE8D12C8A90}']
  end;

  IdfShaderProgram = interface
    ['{B31B84F3-D71D-4117-B5D7-3BEAD6E5D5E2}']
    procedure Use;
    procedure Unuse;
  end;

  IdfMaterialOptions = interface
    ['{8FE8BC07-F1A4-481A-9E24-966941969FCB}']
    {$REGION '[private]'}
    function GetDif(): TdfVec4f;
    procedure SetDif(const aDif: TdfVec4f);
    {$ENDREGION}
    procedure Apply();
    procedure UnApply();
    property Diffuse: TdfVec4f read GetDif write SetDif;
  end;

  IdfMaterial = interface
    ['{DE277592-0C48-4DA0-971F-780470FCCA04}']
    {$REGION '[private]'}
    function GetTexture: IdfTexture;
    procedure SetTexture(aTexture: IdfTexture);
    function GetShader(): IdfShaderProgram;
    procedure SetShader(aShader: IdfShaderProgram);
    function GetOptions(): IdfMaterialOptions;
    procedure SetOptions(aOptions: IdfMaterialOptions);
    {$ENDREGION}

    property Texture: IdfTexture read GetTexture write SetTexture;
    property ShaderProgram: IdfShaderProgram read GetShader write SetShader;
    property MaterialOptions: IdfMaterialOptions read GetOptions write SetOptions;

    procedure Apply();
    procedure Unapply();
  end;

  {$ENDREGION}

  { IdfRenderable - базовый класс чего-то, способного отобразиться на экране.
    Имеется материал и метод рендера, который переопределяется в потомках
    данного класса }
  IdfRenderable = interface
    ['{A2DD3046-3FDE-43DD-93AE-83C7A29A2196}']
    {$REGION '[private]'}
    function GetMaterial(): IdfMaterial;
    procedure SetMaterial(const aMat: IdfMaterial);
    {$ENDREGION}
    procedure DoRender;

    property Material: IdfMaterial read GetMaterial write SetMaterial;
  end;

  {$REGION ' RenderNodes and scenes '}


  { IdfNode - рендер-узел, обладает структурой Родитель-Дети, имеет матрицу,
    позиционирующую его в пространстве, а также привязанный объект Renderable,
    который он собственно и рендерит, предварительно определив необходимость
    рендера и установив матрицу, опции и материал }
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
    procedure SetParent(aParent: IdfNode);
    function GetRenderable(): IdfRenderable;
    procedure SetRenderable(aRenderable: IdfRenderable);
    function GetChildsCount(): Integer;
    {$ENDREGION}

    property Position: TdfVec3f read GetPos write SetPos;
    property Up: TdfVec3f read GetUp write SetUp;
    property Direction: TdfVec3f read GetDir write SetDir;
    property Left: TdfVec3f read GetLeft write SetLeft;
    property ModelMatrix: TdfMat4f read GetModel write SetModel;
    property Parent: IdfNode read GetParent write SetParent;
    property Visible: Boolean read GetVis write SetVis;

    property Childs[Index: Integer]: IdfNode read GetChild write SetChild;
    property ChildsCount: Integer read GetChildsCount;

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

  { IdfScene - идентифицирует игровую сцену, иерархию рендер-узлов с привязанными
    к ним графическими объектами }
  IdfScene = interface
    ['{5E52434E-3A00-478E-AE73-BA45C77BD2AC}']
    {$REGION '[private]'}
    function GetRoot: IdfNode;
    procedure SetRoot(const aRoot: IdfNode);
    {$ENDREGION}
    property RootNode: IdfNode read GetRoot write SetRoot;
  end;

  { IdfSceneManager - оперирует сценами IdfScene, загружает, подгружает и
    выгружает их ресурсы }
  IdfSceneManager = interface
    ['{4AE2CAE0-4273-45B0-85A5-BAC06D198AA5}']
    {$REGION '[private]'}
    function GetScene(Index: String): IdfScene;
    procedure SetScene(Index: String; aScene: IdfScene);
    {$ENDREGION}
    property Scene[Index: String]: IdfScene read GetScene write SetScene;
  end;

  {$ENDREGION}

  { IdfCamera - идентифицирует камеру с возможностями установки вьюпорта,
    панорамирования, масштабирования и прочим }
  IdfCamera = interface (IdfNode)
    ['{D6E97126-FF5F-4CE7-9687-4F358A90B34E}']
    procedure Viewport(x, y, w, h: Integer; FOV, ZNear, ZFar: Single);
    procedure ViewportOnly(x, y, w, h: Integer);
    procedure Pan(X, Y: Single);
    procedure Scale(aScale: Single);
    procedure Rotate(delta: Single; Axis: TdfVec3f);
    procedure SetCamera(Pos, TargetPos, Up: TdfVec3f);
    procedure SetTarget(Point: TdfVec3f); overload;
    procedure SetTarget(Target: IdfNode); overload;

    procedure Update();
  end;

  { IdfLight - источник света }
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

  TdfOnUpdateProc = procedure(const dt: Double);

  TdfMouseShiftState = set of (ssLeft, ssRight, ssMiddle, ssDouble);
  TdfMouseButton = (mbLeft, mbRight, mbMiddle);

  //TODO: А нужнен ли ShiftState для Up?
  TdfOnMouseDownProc   = procedure(X, Y: Integer; MouseButton: TdfMouseButton; Shift: TdfMouseShiftState);
  TdfOnMouseUpProc     = procedure(X, Y: Integer; MouseButton: TdfMouseButton; Shift: TdfMouseShiftState);
  TdfOnMouseMoveProc   = procedure(X, Y: Integer; Shift: TdfMouseShiftState);
  TdfOnMouseWheelProc  = procedure(X, Y: Integer; Shift: TdfMouseShiftState; WheelDelta: Integer);

  IdfRenderer = interface
    ['{BFB518E7-A55A-48E2-B0C4-ED7BE8D23796}']
    {$REGION '[private]'}
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
    {$ENDREGION}

    function Init(FileName: PAnsiChar): Integer;
    function Step(deltaTime: Double): Integer;
    function Start(): Integer;
    function DeInit(): Integer;

    property WindowHandle: Integer read GetWindowHandle;
    property WindowCaption: PWideChar read GetWindowCaption write SetWindowCaption;
    property RenderReady: Boolean read GetRenderReady;
    property FPS: Single read GetFPS;

    {Вероятно, вынести в класс TdfWindow?}
    property OnMouseDown: TdfOnMouseDownProc read GetOnMouseDown write SetOnMouseDown;
    property OnMouseUp: TdfOnMouseUpProc read GetOnMouseUp write SetOnMouseUp;
    property OnMouseMove: TdfOnMouseMoveProc read GetOnMouseMove write SetOnMouseMove;
    property OnMouseWheel: TdfOnMouseWheelProc read GetOnMouseWheel write SetOnMouseWheel;

    property OnUpdate: TdfOnUpdateProc read GetOnUpdate write SetOnUpdate;

    property Camera: IdfCamera read GetCamera write SetCamera;

    {debug - надо юзать IdfScene}
    property RootNode: IdfNode read GetRoot write SetRoot;
  end;

  IdfMesh = interface (IdfRenderable)
    ['{90223F0B-7F8F-4EBF-9752-DF84CE75B7E7}']

  end;

  {Точка отсчета для рендера 2Д вещей}
  Tdf2DPivotPoint = (ppTopLeft, ppTopRight, ppBottomLeft, ppBottomRight, ppCenter);

  { IdfSprite - двумерный спрайт, отображающийся на экране (HUD-sprite) без искажений }
  IdfSprite = interface (IdfRenderable)
    ['{C8048F34-9F3D-4E58-BC71-633F2413A9A5}']
    {$REGION '[private]'}
    function GetWidth(): Single;
    procedure SetWidth(const aWidth: Single);
    function GetHeight(): Single;
    procedure SetHeight(const aHeight: Single);
    function GetPos(): TdfVec2f;
    procedure SetPos(const aPos: TdfVec2f);
    function GetScale(): TdfVec2f;
    procedure SetScale(const aScale: TdfVec2f);
    function GetRot(): Single;
    procedure SetRot(const aRot: Single);
    function GetPivot(): Tdf2DPivotPoint;
    procedure SetPivot(const aPivot: Tdf2DPivotPoint);
    {$ENDREGION}
    property Width: Single read GetWidth write SetWidth;
    property Height: Single read GetHeight write SetHeight;

    //TdfVec3f - для глубины? Как реализовать?
    property Position: TdfVec2f read GetPos write SetPos;
    property Scale: TdfVec2f read GetScale write SetScale;
    procedure ScaleMult(const aScale: TdfVec2f);
    property Rotation: Single read GetRot write SetRot;
    property PivotPoint: Tdf2DPivotPoint read GetPivot write SetPivot;
  end;

  procedure LoadRendererLib();
  procedure UnLoadRendererLib();

var
  dfCreateRenderer: function(): IdfRenderer; stdcall;
  dfCreateNode: function(aParent: IdfNode): IdfNode; stdcall;
  dfCreateHUDSprite: function(): IdfSprite; stdcall;
  dfCreateMaterial: function(): IdfMaterial; stdcall;
  dfCreateTexture: function(): IdfTexture; stdcall;
  dllHandle: THandle;

implementation

procedure LoadRendererLib();
begin
  dllHandle := LoadLibrary(dllname);
  Assert(dllHandle <> 0, 'Ошибка загрузки библиотеки: вероятно библиотека не найдена');
  dfCreateRenderer := GetProcAddress(dllHandle, 'CreateRenderer');
  dfCreateNode := GetProcAddress(dllHandle, 'CreateNode');
  dfCreateHUDSprite := GetProcAddress(dllHandle, 'CreateHUDSprite');
  dfCreateMaterial := GetProcAddress(dllHandle, 'CreateMaterial');
  dfCreateTexture := GetProcAddress(dllHandle, 'CreateTexture');
end;

procedure UnLoadRendererLib();
begin
//  dfCreateRenderer := nil;
//  dfCreateNode := nil;
//  FreeLibrary(dllHandle);
end;

end.
