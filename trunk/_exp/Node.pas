unit Node;

interface

uses
  Classes, dfHRenderer, dfMath;

type
  TdfNode = class(TInterfacedObject, IdfNode)
  private
    FVisible: Boolean;
    FChilds: TList;

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
  public

    constructor Create; virtual;
    destructor Destroy; override;
    property Position: TdfVec3f read GetPos write SetPos;
    property Up: TdfVec3f read GetUp write SetUp;
    property Direction: TdfVec3f read GetDir write SetDir;
    property Left: TdfVec3f read GetLeft write SetLeft;
    property ModelMatrix: TdfMat4f read GetModel write SetModel;

    property Visible: Boolean read GetVis write SetVis;
    property Renderable: IdfRenderable read GetRenderable write SetRenderable;
//    procedure Render(deltaTime: Double); virtual;
    property Childs[Index: Integer]: IdfNode read GetChild write SetChild;
    //Добавить уже существующий рендер-узел себе в потомки
    function AddChild(AChild: IdfNode): Integer;
    //Удалить потомка из списка по индексу. Физически объект остается в памяти.
    procedure RemoveChild(Index: Integer); overload;
    //Удалить потомка из списка по указателю. Физически объект остается в памяти.
    procedure RemoveChild(AChild: IdfNode); overload;
    //Удалить потомка из списка по индексу. Физически объект уничтожается.
    procedure FreeChild(Index: Integer);
  end;

implementation

function TdfNode.GetPos(): TdfVec3f;
begin
  with ModelMatrix do
    Result := Pos;
end;

function TdfNode.GetRenderable: IdfRenderable;
begin

end;

procedure TdfNode.SetPos(const aPos: TdfVec3f);
begin

end;

procedure TdfNode.SetRenderable(const aRenderable: IdfRenderable);
begin

end;

function TdfNode.GetUp(): TdfVec3f;
begin
  with ModelMatrix do
    Result := dfVec3f(e10, e11, e12);
end;

procedure TdfNode.SetUp(const aUp: TdfVec3f);
begin

end;

function TdfNode.GetDir(): TdfVec3f;
begin
  with ModelMatrix do
    Result := dfVec3f(e20, e21, e22);
end;

procedure TdfNode.SetDir(const aDir: TdfVec3f);
begin

end;

function TdfNode.GetLeft(): TdfVec3f;
begin
  with ModelMatrix do
    Result := dfVec3f(e00, e01, e02);
end;

procedure TdfNode.SetLeft(const aLeft: TdfVec3f);
begin

end;

function TdfNode.GetModel(): TdfMat4f;
begin

end;

procedure TdfNode.SetModel(const aModel: TdfMat4f);
begin

end;

function TdfNode.GetVis(): Boolean;
begin
  Result := FVisible;
end;

procedure TdfNode.SetVis(const aVis: Boolean);
begin
  FVisible := aVis;
end;

function TdfNode.GetChild(Index: Integer): IdfNode;
begin
  Result := nil;
  if (Index >= 0)and(Index < FChilds.Count) then
    Result := IdfNode(FChilds[Index]);
end;

procedure TdfNode.SetChild(Index: Integer; aChild: IdfNode);
begin

end;

function TdfNode.GetParent(): IdfNode;
begin

end;

procedure TdfNode.SetParent(const aParent: IdfNode);
begin

end;


constructor TdfNode.Create;
begin

end;

destructor TdfNode.Destroy;
begin

end;


//procedure TdfNode.Render(deltaTime: Double);
//begin
//
//end;


function TdfNode.AddChild(AChild: IdfNode): Integer;
begin

end;

procedure TdfNode.RemoveChild(Index: Integer);
begin

end;

procedure TdfNode.RemoveChild(AChild: IdfNode);
begin

end;

procedure TdfNode.FreeChild(Index: Integer);
begin

end;



end.
