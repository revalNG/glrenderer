unit dfHRenderer;

interface

uses
  Windows, Graphics,
  dfMath;

const
  dllName = 'glrenderer.dll';

type
  TdfOnUpdateProc = procedure(const dt: Double);

  TdfMouseShiftState = set of (ssLeft, ssRight, ssMiddle, ssDouble);
  TdfMouseButton = (mbNone, mbLeft, mbRight, mbMiddle);

  //TODO: А нужнен ли ShiftState для Up?
  TdfOnMouseDownProc   = procedure(X, Y: Integer; MouseButton: TdfMouseButton; Shift: TdfMouseShiftState);
  TdfOnMouseUpProc     = procedure(X, Y: Integer; MouseButton: TdfMouseButton; Shift: TdfMouseShiftState);
  TdfOnMouseMoveProc   = procedure(X, Y: Integer; Shift: TdfMouseShiftState);
  TdfOnMouseWheelProc  = procedure(X, Y: Integer; Shift: TdfMouseShiftState; WheelDelta: Integer);

  {$REGION ' Utility types '}

  TdfStream = class
    class function Init(Memory: Pointer; MemSize: LongInt): TdfStream; overload;
    class function Init(const FileName: string; RW: Boolean = False): TdfStream; overload;
    destructor Destroy; override;
  private
    SType  : (stMemory, stFile);
    FSize  : LongInt;
    FPos   : LongInt;
    FBPos  : LongInt;
    F      : File;
    Mem    : Pointer;
    procedure SetPos(Value: LongInt);
    procedure SetBlock(BPos, BSize: LongInt);
  public
    procedure CopyFrom(const Stream: TdfStream);
    function Read(out Buf; BufSize: LongInt): LongInt;
    function Write(const Buf; BufSize: LongInt): LongInt;
    function ReadAnsi: AnsiString;
    procedure WriteAnsi(const Value: AnsiString);
    function ReadUnicode: WideString;
    procedure WriteUnicode(const Value: WideString);
    property Size: LongInt read FSize;
    property Pos: LongInt read FPos write SetPos;
  end;

  {$ENDREGION

  {$REGION ' Input '}

  IdfInput = interface
    ['{5552ED21-B3E8-4F3D-9551-AD7A9EF82CF4}']
    {$REGION '[private]'}
    function GetAllow(): Boolean;
    procedure SetAllow(aAllow: Boolean);
    {$ENDREGION}
    function IsKeyDown(const vk: Integer): Boolean; overload;
    function IsKeyDown(const c: Char): Boolean; overload;

    function IsKeyPressed(aCode: Integer; aPressed: PBoolean): Boolean; overload;
    function IsKeyPressed(aChar: Char; aPressed: PBoolean): Boolean; overload;

    procedure KeyboardNotifyWheelMoved(wheelDelta : Integer);
    //Разрешить захват клавиш.
    //Автоматически меняется в зависимости от того, активно окно или нет
    property AllowKeyCapture: Boolean read GetAllow write SetAllow;
  end;
  {$ENDREGION}

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

  TdfTextureAtlasInfo = record
    aPos: TdfVec2f;
    aTexture: IdfTexture;
  end;

  IdfTextureAtlas = interface
    ['{36F427A0-A11F-4B80-B40B-F7904C1179BE}']
    procedure LoadFromFile(aFileName: String);
    procedure SaveToFile(aFileName: String);

    function AddTexture(aTexture: IdfTexture): Integer;

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
    procedure SetTexture(const aTexture: IdfTexture);
    function GetShader(): IdfShaderProgram;
    procedure SetShader(const aShader: IdfShaderProgram);
    function GetOptions(): IdfMaterialOptions;
    procedure SetOptions(const aOptions: IdfMaterialOptions);
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

  TdfViewportParams = record
    X,Y,W,H: Integer;
    FOV, ZNear, ZFar: Single;
  end;

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

    function GetViewport(): TdfViewportParams;

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

  IdfMesh = interface (IdfRenderable)
    ['{90223F0B-7F8F-4EBF-9752-DF84CE75B7E7}']

  end;

  {$REGION ' 2D-рендер '}

  {Точка отсчета для рендера 2Д вещей}
  Tdf2DPivotPoint = (ppTopLeft, ppTopRight, ppBottomLeft, ppBottomRight, ppCenter);

  {Отличительные особенности - не использует матрицу Node, а собственные свойства}
  Idf2DRenderable = interface(IdfRenderable)
    ['{EC48E06A-778E-45B7-A239-3DE1897A7C06}']
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

    property Position: TdfVec2f read GetPos write SetPos;
    property Scale: TdfVec2f read GetScale write SetScale;
    procedure ScaleMult(const aScale: TdfVec2f);
    property Rotation: Single read GetRot write SetRot;
    property PivotPoint: Tdf2DPivotPoint read GetPivot write SetPivot;

    property Width: Single read GetWidth write SetWidth;
    property Height: Single read GetHeight write SetHeight;
  end;

  { IdfSprite - двумерный спрайт, отображающийся на экране (HUD-sprite) без искажений }
  IdfSprite = interface (Idf2DRenderable)
    ['{C8048F34-9F3D-4E58-BC71-633F2413A9A5}']
  end;

  { IdfFont отвечает за хранение шрифта, которым может быть отрендерен текст }
  IdfFont = interface
    ['{C05DAC6F-ABC0-41BF-9752-6064395741D2}']
    {$REGION '[private]'}
    function GetTexture(): IdfTexture;
//    procedure SetTexture(aTexture: IdfTexture);
    function GetFontSize(): Integer;
    procedure SetFontSize(aSize: Integer);
    function GetFontStyle(): TFontStyles;
    procedure SetFontStyle(aStyle: TFontStyles);
    {$ENDREGION}
    {
     Порядок действий:
     1. Добавить диапазоны
     2. Установить параметры (размер, начертание и пр.
      3. Сгенерировать шрифт из файла ttf
      3. Сгенерировать шрифт из системного шрифта
    }
    procedure AddRange(aStart, aStop: Word); overload;
    procedure AddRange(aStart, aStop: WideChar); overload;
    procedure AddSymbols(aText: String);

    property FontSize: Integer read GetFontSize write SetFontSize;
    property FontStyle: TFontStyles read GetFontStyle write SetFontStyle;

    procedure GenerateFromTTF(aFile: String);
    procedure GenerateFromFont(aFontName: String);
    property Texture: IdfTexture read GetTexture;

    procedure PrintText(aText: String);
  end;

  { IdfText - текст, отображающийся на экране без искажений и вне зависимости
    от положения камеры (HUD-элемент)}
  IdfText = interface (Idf2DRenderable)
    ['{C0E53D75-7C6B-4218-AA3E-B6FE6076EA68}']
    {$REGION '[private]'}
    function GetFont(): IdfFont;
    procedure SetFont(aFont: IdfFont);
    function GetText(): String;
    procedure SetText(aText: String);

//    function GetWidth(): Single;
//    procedure SetWidth(const aWidth: Single);
//    function GetHeight(): Single;
//    procedure SetHeight(const aHeight: Single);
    {$ENDREGION}

    property Font: IdfFont read GetFont write SetFont;
    property Text: String read GetText write SetText;

//    property Width: Single read GetWidth write SetWidth;
//    property Height: Single read GetHeight write SetHeight;
  end;

  { Idf2DScene - класс, организующий все Idf2DRenderable-сущности}
  Idf2DScene = interface
    ['{3D0DB66F-077A-406B-88A4-882972D8077A}']
    {$REGION '[private]'}
    function GetUpdateProc(): TdfOnUpdateProc;
    procedure SetUpdateProc(aProc: TdfOnUpdateProc);
    {$ENDREGION}

    function AddNewSprite(): IdfSprite;
    function AddNewText(): IdfText;

    property OnUpdate: TdfOnUpdateProc read GetUpdateProc write SetUpdateProc;

    procedure Render();
    procedure Update();
  end;

  {$ENDREGION}

  {$REGION ' GUI '}

  IdfGUIElement = interface;

  //Виды проверок:
  // - hmBox - проверка по всей площади кнопки
  // - hmCircle - проверка по радиусу, равному Width
  // - hmAlpha0 - за кнопку считается все, у чего альфа больше 0
  // - hmAlpha50 - за кнопку считается все, у чего альфа больше 50%
  TdfGUIHitMode = (hmBox, hmCircle, hmAlpha0, hmAlpha50);
  TdfMouseEvent = procedure(Sender: IdfGUIElement; X, Y: Integer; Button: TdfMouseButton; Shift: TdfMouseShiftState);
  TdfWheelEvent = procedure(Sender: IdfGUIElement; X, Y: Integer; Shift: TdfMouseShiftState; WheelDelta: Integer);
  TdfMousePos = (mpOut = 0, mpOver);

  {
    ОБщий предок для всех элементов GUI
  }
  IdfGUIElement = interface(Idf2DRenderable)
    ['{68635C44-C704-438B-8D98-C741C325F3CA}']
    {$REGION '[private]'}
    function GetHitMode(): TdfGUIHitMode;
    procedure SetHitMode(aMode: TdfGUIHitMode);

    function GetOnClick(): TdfMouseEvent;
    function GetOnOver(): TdfMouseEvent;
    function GetOnOut(): TdfMouseEvent;
    function GetOnDown(): TdfMouseEvent;
    function GetOnUp(): TdfMouseEvent;
    function GetOnWheel(): TdfWheelEvent;

    procedure SetOnClick(aProc: TdfMouseEvent);
    procedure SetOnOver(aProc: TdfMouseEvent);
    procedure SetOnOut(aProc: TdfMouseEvent);
    procedure SetOnDown(aProc: TdfMouseEvent);
    procedure SetOnUp(aProc: TdfMouseEvent);
    procedure SetOnWheel(aProc: TdfWheelEvent);

    function GetZIndex(): Integer;
    procedure SetZIndex(aIndex: Integer);

    function GetMousePos(): TdfMousePos;
    {$ENDREGION}

    //Для внутреннего использования. Либо для принудительного вызова события
    procedure _MouseMove (X, Y: Integer; Shift: TdfMouseShiftState);
    procedure _MouseOver (X, Y: Integer; Shift: TdfMouseShiftState);
    procedure _MouseOut (X, Y: Integer; Shift: TdfMouseShiftState);
    procedure _MouseDown (X, Y: Integer; MouseButton: TdfMouseButton; Shift: TdfMouseShiftState);
    procedure _MouseUp   (X, Y: Integer; MouseButton: TdfMouseButton; Shift: TdfMouseShiftState);
    procedure _MouseWheel(X, Y: Integer; Shift: TdfMouseShiftState; WheelDelta: Integer);
    procedure _MouseClick(X, Y: Integer; MouseButton: TdfMouseButton; Shift: TdfMouseShiftState);

    //Режим проверки попадания по элементу.
    property HitMode: TdfGUIHitMode read GetHitMode write SetHitMode;
    //Проверка на попадание по элементу
    function CheckHit(X, Y: Integer): Boolean;
    //Коллбэки для пользователя
    property OnMouseClick: TdfMouseEvent read GetOnClick write SetOnClick;
    property OnMouseOver: TdfMouseEvent read GetOnOver write SetOnOver;
    property OnMouseOut: TdfMouseEvent read GetOnOut write SetOnOut;
    property OnMouseDown: TdfMouseEvent read GetOnDown write SetOnDown;
    property OnMouseUp: TdfMouseEvent read GetOnUp write SetOnUp;
    property OnMouseWheel: TdfWheelEvent read GetOnWheel write SetOnWheel;

    property MousePos: TdfMousePos read GetMousePos;

    //Порядок сортировки при обработке ввода.
    // При конфликте двух GUI-элементов обработка
    // перейдет к тому, чей ZIndex МЕНЬШЕ
    property ZIndex: Integer read GetZIndex write SetZIndex;
  end;

  IdfGUIButton = interface;

  IdfGUIButton = interface(IdfGUIElement)
    ['{D8A90E06-F07C-48B4-9F9A-8E7C31BDFA1F}']
    {$REGION '[private]'}
    function GetTextureNormal(): IdfTexture;
    function GetTextureOver(): IdfTexture;
    function GetTextureClick(): IdfTexture;

    procedure SetTextureNormal(aTexture: idfTexture);
    procedure SetTextureOver(aTexture: idfTexture);
    procedure SetTextureClick(aTexture: idfTexture);

    function GetAutoChange: Boolean;
    procedure SetAutoChange(aChange: Boolean);

    {$ENDREGION}
    property TextureNormal: IdfTexture read GetTextureNormal write SetTextureNormal;
    property TextureOver: IdfTexture read GetTextureOver write SetTextureOver;
    property TextureClick: IdfTexture read GetTextureClick write SetTextureClick;

    //Текстуры будут меняться автоматически при наведении, клие и уходе мыши
    property TextureAutoChange: Boolean read GetAutoChange write SetAutoChange;
  end;

  IdfGUIManager = interface
    ['{E29C453A-E98E-4881-A444-397AEC9007A8}']
    {$REGION '[private]'}
    function GetFocused(): IdfGUIElement;
    procedure SetFocused(aElement: IdfGUIElement);
    {$ENDREGION}
    //Зарегистрировать/разрегистрировать элемент
    procedure RegisterElement(aElement: IdfGUIElement);
    procedure UnregisterElement(aElement: IdfGUIElement);

    //Элемент, находящийся в фокусе
    property Focused: IdfGUIElement read GetFocused write SetFocused;

    //для внутреннего использования IdfRenderer-ом.
    procedure MouseMove (X, Y: Integer; Shift: TdfMouseShiftState);
    procedure MouseDown (X, Y: Integer; MouseButton: TdfMouseButton; Shift: TdfMouseShiftState);
    procedure MouseUp   (X, Y: Integer; MouseButton: TdfMouseButton; Shift: TdfMouseShiftState);
    procedure MouseWheel(X, Y: Integer; Shift: TdfMouseShiftState; WheelDelta: Integer);
  end;

  {$ENDREGION}

  TdfUserRenderableCallback = procedure(); stdcall;

  IdfUserRenderable = interface(IdfRenderable)
    ['{1315E4FF-F4EF-4049-A4FD-18FEE4FA0A8E}']
    {$REGION '[private]'}
    function GetUserCallback: TdfUserRenderableCallback;
    procedure SetUserCallback(urc: TdfUserRenderableCallback);
    {$ENDREGION}
    property OnRender: TdfUserRenderableCallback read GetUserCallback write SetUserCallback;
  end;

  IdfRenderer = interface
    ['{BFB518E7-A55A-48E2-B0C4-ED7BE8D23796}']
    {$REGION '[private]'}
    function GetWindowHandle(): Integer;
    function GetWindowCaption(): PWideChar;
    procedure SetWindowCaption(aCaption: PWideChar);
    function GetRenderReady(): Boolean;
    function GetFPS(): Single;
    function GetCamera(): IdfCamera;
    procedure SetCamera(const aCamera: IdfCamera);
    function GetRoot: IdfNode;
    procedure SetRoot(const aRoot: IdfNode);

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

    function GetInput(): IdfInput;
    procedure SetInput(const aInput: IdfInput);

    function GetManager(): IdfGUIManager;
    procedure SetManager(const aManager: IdfGUIManager);

    procedure Dispatch(var Message);
    {$ENDREGION}

    //Инициализация с параметрами из файла
    procedure Init(FileName: PAnsiChar); overload;
    //Инициализация в определенный хэндл
    procedure Init(Handle: THandle; FileName: PAnsiChar); overload;
    procedure Step(deltaTime: Double);
    procedure Start();
    procedure Stop();
    procedure DeInit();

    property Enabled: Boolean read GetEnabled write SetEnabled;

    property WindowHandle: Integer read GetWindowHandle;
    property WindowCaption: PWideChar read GetWindowCaption write SetWindowCaption;
    property WindowWidth: Integer read GetWidth;
    property WindowHeight: Integer read GetHeight;

    property DC: hDC read GetDC;
    property RC: hglRC read GetRC;

    property RenderReady: Boolean read GetRenderReady;
    property FPS: Single read GetFPS;

    property VersionText: String read GetSelfVersion;

    {Вероятно, вынести в класс TdfWindow?}
    property OnMouseDown: TdfOnMouseDownProc read GetOnMouseDown write SetOnMouseDown;
    property OnMouseUp: TdfOnMouseUpProc read GetOnMouseUp write SetOnMouseUp;
    property OnMouseMove: TdfOnMouseMoveProc read GetOnMouseMove write SetOnMouseMove;
    property OnMouseWheel: TdfOnMouseWheelProc read GetOnMouseWheel write SetOnMouseWheel;

    property OnUpdate: TdfOnUpdateProc read GetOnUpdate write SetOnUpdate;

    property Camera: IdfCamera read GetCamera write SetCamera;

    {debug - надо юзать IdfScene}
    property RootNode: IdfNode read GetRoot write SetRoot;

    property Input: IdfInput read GetInput write SetInput;

    property GUIManager: IdfGUIManager read GetManager write SetManager;
  end;

  procedure LoadRendererLib();
  procedure UnLoadRendererLib();

var
  {Пока все в стадии дебага, впоследствии заменить на фабрики}
  dfCreateRenderer: function(): IdfRenderer; stdcall;
  dfDestroyRenderer: function(): Integer; stdcall;

  dfCreateNode: function(aParent: IdfNode): IdfNode; stdcall;
  dfCreateUserRender: function(): IdfUserRenderable; stdcall;
  dfCreateHUDSprite: function(): IdfSprite; stdcall;
  dfCreateMaterial: function(): IdfMaterial; stdcall;
  dfCreateTexture: function(): IdfTexture; stdcall;
  dfCreateFont: function(): IdfFont; stdcall;
  dfCreateText: function(): IdfText; stdcall;
  dfCreateGUIButton: function(): IdfGUIButton; stdcall;

  dllHandle: THandle;

implementation

procedure LoadRendererLib();
begin
  dllHandle := LoadLibrary(dllname);
  Assert(dllHandle <> 0, 'Ошибка загрузки библиотеки: вероятно библиотека не найдена');

  dfCreateRenderer := GetProcAddress(dllHandle, 'CreateRenderer');
  dfDestroyRenderer := GetProcAddress(dllHandle, 'DestroyRenderer');

  dfCreateNode := GetProcAddress(dllHandle, 'CreateNode');
  dfCreateUserRender := GetProcAddress(dllHandle, 'CreateUserRender');
  dfCreateHUDSprite := GetProcAddress(dllHandle, 'CreateHUDSprite');
  dfCreateMaterial := GetProcAddress(dllHandle, 'CreateMaterial');
  dfCreateTexture := GetProcAddress(dllHandle, 'CreateTexture');
  dfCreateFont := GetProcAddress(dllHandle, 'CreateFont');
  dfCreateText := GetProcAddress(dllHandle, 'CreateText');
  dfCreateGUIButton := GetProcAddress(dllHandle, 'CreateGUIButton');
end;

procedure UnLoadRendererLib();
begin
//  dfCreateRenderer := nil;
//  dfCreateNode := nil;
//  dfDestroyRenderer();
//  FreeLibrary(dllHandle);
end;

class function TdfStream.Init(Memory: Pointer; MemSize: LongInt): TdfStream;
begin
  Result := TdfStream.Create;
  with Result do
  begin
    SType := stMemory;
    Mem   := Memory;
    FSize := MemSize;
    FPos  := 0;
    FBPos := 0;
  end;
end;

class function TdfStream.Init(const FileName: String; RW: Boolean): TdfStream;
var
  io: Integer;
begin
  Result := TdfStream.Create();
  AssignFile(Result.F, FileName);
  if RW then
    Rewrite(Result.F, 1)
  else
    Reset(Result.F, 1);
  io := IOResult;
  if io = 0 then
  begin
    Result.SType := stFile;
    Result.FSize := FileSize(Result.F);
    Result.FPos  := 0;
    Result.FBPos := 0;
  end
  else
  begin
    Result.Free;
    Result := nil;
  end;
end;

destructor TdfStream.Destroy;
begin
  if SType = stFile then
    CloseFile(F);
end;

procedure TdfStream.SetPos(Value: LongInt);
begin
  FPos := Value;
  if SType = stFile then
    Seek(F, FBPos + FPos);
end;

procedure TdfStream.SetBlock(BPos, BSize: LongInt);
begin
  FSize := BSize;
  FBPos := BPos;
  Pos := 0;
end;

procedure TdfStream.CopyFrom(const Stream: TdfStream);
var
  p : Pointer;
  CPos : LongInt;
begin
  p := GetMemory(Stream.Size);
  CPos := Stream.Pos;
  Stream.Pos := 0;
  Stream.Read(p^, Stream.Size);
  Stream.Pos := CPos;
  Write(p^, Stream.Size);
  FreeMemory(p);
end;

function TdfStream.Read(out Buf; BufSize: LongInt): LongInt;
begin
  if SType = stMemory then
  begin
    Result := Min(FPos + BufSize, FSize) - FPos;
    Move(Mem^, Buf, Result);
  end else
    BlockRead(F, Buf, BufSize, Result);
  Inc(FPos, Result);
end;

function TdfStream.Write(const Buf; BufSize: LongInt): LongInt;
begin
  if SType = stMemory then
  begin
    Result := Min(FPos + BufSize, FSize) - FPos;
    Move(Buf, Mem^, Result);
  end else
    BlockWrite(F, Buf, BufSize, Result);
  Inc(FPos, Result);
  Inc(FSize, Max(0, FPos - FSize));
end;

function TdfStream.ReadAnsi: AnsiString;
var
  Len : Word;
begin
  Read(Len, SizeOf(Len));
  if Len > 0 then
  begin
    SetLength(Result, Len);
    Read(Result[1], Len);
  end else
    Result := '';
end;

procedure TdfStream.WriteAnsi(const Value: AnsiString);
var
  Len : Word;
begin
  Len := Length(Value);
  Write(Len, SizeOf(Len));
  if Len > 0 then
    Write(Value[1], Len);
end;

function TdfStream.ReadUnicode: WideString;
var
  Len : Word;
begin
  Read(Len, SizeOf(Len));
  SetLength(Result, Len);
  Read(Result[1], Len * 2);
end;

procedure TdfStream.WriteUnicode(const Value: WideString);
var
  Len : Word;
begin
  Len := Length(Value);
  Write(Len, SizeOf(Len));
  Write(Value[1], Len * 2);
end;

end.
