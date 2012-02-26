unit Node;

interface

uses
  Classes, dfHRenderer, dfMath;

type
  TdfNode = class(TInterfacedObject, IdfNode)
  private
    function GetChildIndex(aChild: IdfNode): Integer;
//    function IsChild(aChild: IdfNode): Boolean;
  protected
    FParent: IdfNode;
    FChilds: TList; //TInterfaceList;

    FVisible: Boolean;

    FDir, FLeft, FUp: TdfVec3f;
    FModelMatrix: TdfMat4f;

    FRenderable: IdfRenderable;

    function GetPos(): TdfVec3f;
    procedure SetPos(const aPos: TdfVec3f); virtual;
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

    procedure UpdateDirUpLeft(NewDir, NewUp, NewLeft: TdfVec3f);
  public

    constructor Create; virtual;
    destructor Destroy; override;

    property Position: TdfVec3f read GetPos write SetPos;
    property Up: TdfVec3f read GetUp write SetUp;
    property Direction: TdfVec3f read GetDir write SetDir;
    property Left: TdfVec3f read GetLeft write SetLeft;
    property ModelMatrix: TdfMat4f read GetModel write SetModel;

    property Visible: Boolean read GetVis write SetVis;
    property Parent: IdfNode read GetParent write SetParent;
    property Renderable: IdfRenderable read GetRenderable write SetRenderable;
//    procedure Render(deltaTime: Double); virtual;
    property Childs[Index: Integer]: IdfNode read GetChild write SetChild;
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

    procedure Render(aDeltaTime: Single); virtual;
  end;

implementation


{ TdfNode }

function TdfNode.AddChild(aChild: IdfNode): Integer;
var
  Index: Integer;
begin
  Index := GetChildIndex(aChild);
  if Index <> -1 then //Такой потомок уже есть
    Exit(Index)  //Возвращаем его индекс
  else
  begin
    aChild.Parent := Self;
    Result := FChilds.Add(Pointer(aChild));
  end;
end;

function TdfNode.AddNewChild: IdfNode;
begin
  Result := TdfNode.Create;
  Result.Parent := Self;
  FChilds.Add(Pointer(Result));
  Left := dfVec3f(5, 5, 2);
end;

constructor TdfNode.Create;
begin
  inherited;
  FChilds := TList.Create;
  FModelMatrix.Identity;

end;

destructor TdfNode.Destroy;
var
  i: Integer;
begin
  for i := 0 to FChilds.Count - 1 do
    FChilds[i] := nil;
  FChilds.Free; //InterfaceList зануляет ссылки
  inherited;
end;

procedure TdfNode.FreeChild(Index: Integer);
begin
  if (Index >= 0) and (Index < FChilds.Count) then
    if Assigned(FChilds[Index]) then
    begin
//      RemoveChild(Index);
      //Это зануляет ссылку в листе. Значит, объект должен освободиться,
      //если на него нет других ссылок
      FChilds.Delete(Index);
    end;
end;

function TdfNode.GetChild(Index: Integer): IdfNode;
begin
  if (Index >= 0) and (Index < FChilds.Count) then
    if Assigned(FChilds[Index]) then
      Result := IdfNode(FChilds[Index]);
end;

function TdfNode.GetChildIndex(aChild: IdfNode): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to FChilds.Count - 1 do
    if IInterface(FChilds[i]) = aChild then
      Exit(i);
end;

function TdfNode.GetDir: TdfVec3f;
begin
  Result := FDir;
end;

function TdfNode.GetLeft: TdfVec3f;
begin
  Result := FLeft;
end;

function TdfNode.GetModel: TdfMat4f;
begin
  Result := FModelMatrix;
end;

function TdfNode.GetParent: IdfNode;
begin
  Result := FParent;
end;

function TdfNode.GetPos: TdfVec3f;
begin
  Result := FModelMatrix.Pos;
end;

function TdfNode.GetRenderable: IdfRenderable;
begin
  Result := FRenderable;
end;

function TdfNode.GetUp: TdfVec3f;
begin
  Result := FUp;
end;

function TdfNode.GetVis: Boolean;
begin
  Result := FVisible;
end;

procedure TdfNode.RemoveChild(Index: Integer);
begin
  //Аналогично FreeChild, так как удалить чайлда напрямую с интерфейсной ссылкой
  // нельзя, AFAIK
  if (Index >= 0) and (Index < FChilds.Count) then
    if Assigned(FChilds[Index]) then
      FChilds.Delete(Index);
end;

procedure TdfNode.RemoveChild(AChild: IdfNode);
begin
  //Не проверяем, так как внутри TInterfaceList есть проверка
  FChilds.Remove(Pointer(aChild));
end;

procedure TdfNode.Render(aDeltaTime: Single);
begin
//  FRenderable.Material;
  FRenderable.DoRender();
  //*
end;

procedure TdfNode.SetChild(Index: Integer; aChild: IdfNode);
begin
  FChilds[Index] := Pointer(aChild);
end;

procedure TdfNode.SetDir(const aDir: TdfVec3f);
var
  NewUp, NewLeft: TdfVec3f;
begin
  NewLeft := FUp.Cross(aDir);
  NewLeft.Negate;
  NewLeft.Normalize;
  NewUp := aDir.Cross(NewLeft);
  NewUp.Normalize;
  UpdateDirUpLeft(aDir, NewUp, NewLeft);
end;

procedure TdfNode.SetLeft(const aLeft: TdfVec3f);
var
  NewDir, NewUp: TdfVec3f;
begin
  NewDir := aLeft.Cross(FUp);
  NewDir.Normalize;
  NewUp := NewDir.Cross(aLeft);
  NewUp.Normalize;
  UpdateDirUpLeft(NewDir, NewUp, aLeft);
end;

procedure TdfNode.SetModel(const aModel: TdfMat4f);
begin
  FModelMatrix := aModel;
  with FModelMatrix do
  begin
    FLeft := dfVec3f(e00, e01, e02);
    FUp   := dfVec3f(e10, e11, e12);
    FDir  := dfVec3f(e20, e21, e22);
  end;
end;

procedure TdfNode.SetParent(const aParent: IdfNode);
begin
  if Assigned(Parent) and (Parent <> aParent) then
    FParent.RemoveChild(Self);
  FParent := aParent;
end;

procedure TdfNode.SetPos(const aPos: TdfVec3f);
begin
  FModelMatrix.Pos := aPos;
end;

procedure TdfNode.SetRenderable(const aRenderable: IdfRenderable);
begin
  FRenderable := aRenderable;
end;

procedure TdfNode.SetUp(const aUp: TdfVec3f);
var
  NewDir, NewLeft: TdfVec3f;
begin
  NewLeft := aUp.Cross(FDir);
  NewLeft.Negate;
  NewLeft.Normalize;
  NewDir := NewLeft.Cross(aUp);
  NewDir.Normalize;
  UpdateDirUpLeft(NewDir, aUp, NewLeft);
end;

procedure TdfNode.SetVis(const aVis: Boolean);
begin
  FVisible := aVis;
end;

procedure TdfNode.UpdateDirUpLeft(NewDir, NewUp, NewLeft: TdfVec3f);
var
  NewPos: TdfVec3f;
begin
  NewPos := FModelMatrix.Pos;
  with FModelMatrix do
  begin
    e00 := NewLeft.x; e01 := NewLeft.y; e02 := NewLeft.z; e03 := -NewPos.Dot(NewLeft);
    e10 := NewUp.x;   e11 := NewUp.y;   e12 := NewUp.z;   e13 := -NewPos.Dot(NewUp);
    e20 := NewDir.x;  e21 := NewDir.y;  e22 := NewDir.z;  e23 := -NewPos.Dot(NewDir);
    e30 := 0;         e31 := 0;         e32 := 0;         e33 := 1;
  end;
  FLeft := NewLeft;
  FUp   := NewUp;
  FDir  := NewDir;
end;

end.
