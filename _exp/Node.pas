unit Node;

interface

uses
  dfHRenderer, dfMath, dfList;

type
  TdfNode = class(TInterfacedObject, IdfNode)
  private
    FVisible: Boolean;
    FChilds: TdfList;

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
  public

    constructor Create; virtual;
    destructor Destroy; override;
    property Position: TdfVec3f read GetPos write SetPos;
    property Up: TdfVec3f read GetUp write SetUp;
    property Direction: TdfVec3f read GetDir write SetDir;
    property Left: TdfVec3f read GetLeft write SetLeft;
    property ModelMatrix: TdfMat4f read GetModel write SetModel;

    property Visible: Boolean read GetVis write SetVis;
    procedure Render(deltaTime: Double); virtual;
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

procedure TdfNode.SetPos(aPos: TdfVec3f);
begin

end;

function TdfNode.GetUp(): TdfVec3f;
begin
  with ModelMatrix do
    Result := dfVec3f(e10, e11, e12);
end;

procedure TdfNode.SetUp(aUp: TdfVec3f);
begin

end;

function TdfNode.GetDir(): TdfVec3f;
begin
  with ModelMatrix do
    Result := dfVec3f(e20, e21, e22);
end;

procedure TdfNode.SetDir(aDir: TdfVec3f);
begin

end;

function TdfNode.GetLeft(): TdfVec3f;
begin
  with ModelMatrix do
    Result := dfVec3f(e00, e01, e02);
end;

procedure TdfNode.SetLeft(aLeft: TdfVec3f);
begin

end;

function TdfNode.GetModel(): TdfMat4f;
begin

end;

procedure TdfNode.SetModel(aModel: TdfMat4f);
begin

end;

function TdfNode.GetVis(): Boolean;
begin
  Result := FVisible;
end;

procedure TdfNode.SetVis(aVis: Boolean);
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

procedure TdfNode.SetParent(aParent: IdfNode);
begin

end;


constructor TdfNode.Create;
begin

end;

destructor TdfNode.Destroy;
begin

end;


procedure TdfNode.Render(deltaTime: Double);
begin

end;


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
