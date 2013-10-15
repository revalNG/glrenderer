unit uWorldObjects;

interface

uses
  glr, glrMath,
  uLevel_SaveLoad;

const
  //�������������� ������ ��� �������
  WIRE_ADDMIND_ONPICKUP     =  3.0;
  KNIFE_ADDMIND_ONPICKUP    = 11.0;
  BACKPACK_ADDMIND_ONPICKUP =  4.0;
  BOTTLE_ADDMIND_ONPICKUP   =  6.0;

  BERRY_BAD_CHANCE = 0.2; //���� ������ ������
  BERRY_BAD_ADD_HEALTH = -2.0; //������ ������ �������� ��������
  BERRY_ADDHUNGER = 1.0; //������� ���������� �����, ����� � ����� ���
  BERRY_ADDTHIRST = 1.0;
  BERRY_ADDFATIGUE = 5.0;

  FLOWER_ADDHEALTH = 2.0;

  //�������, �� ��������� ����
  BOTTLE_ADDTHIRST = 9.0;
  BOTTLE_ADDHEALTH = -1.0;

  //���������
  BOTTLE_HOT_ADDTHIRST = 9.0;
  BOTTLE_HOT_ADDHEALTH = 0.5;

  //��������� ��� ���
  BOTTLE_RAWTEA_ADDTHIRST = 8.0;
  BOTTLE_RAWTEA_ADDHEALTH = BOTTLE_ADDHEALTH + FLOWER_ADDHEALTH;

  //���
  BOTTLE_TEA_ADDTHIRST = 8.0;
  BOTTLE_TEA_ADDHEALTH = 4.0;
  BOTTLE_TEA_ADDFATIGUE = 7.0;

  //����, ��� ��������� �������������� ����
  MUSHROOM_CHANCE_OF_HALLUCINATION = 0.4;

  MUSHROOM_ADDHUNGER = 3.0; //���� ������� ����
  MUSHROOM_ADDMIND   = 12.0; //���� ��������������. ����� ���� ��� ���� ��� � �����

  //������� ������ (����� � �������)
  MUSHROOM_SHASHLIK_RAW_ADDHUNGER = 2 * MUSHROOM_ADDHUNGER;
  MUSHROOM_SHASHLIK_HOT_ADDHUNGER = 3.5 * MUSHROOM_ADDHUNGER;
  MUSHROOM_SHASHLIK_HOT_ADDFATIGUE = 10.0;

  //����
  FISH_ADDHUNGER = 5.0;
  FISH_ADDHEALTH = -6.0;

  //������ �� ���� (����� � �������)
  FISH_SHASHLIK_RAW_ADDHUNGER = FISH_ADDHUNGER;
  FISH_SHASHLIK_RAW_ADDHEALTH = 0.7 * FISH_ADDHEALTH; //��������� ��������

  FISH_SHASHLIK_HOT_ADDHUNGER = 2.5 * FISH_ADDHUNGER;
  FISH_SHASHLIK_HOT_ADDHEALTH = 4.0;
  FISH_SHASHLIK_HOT_ADDFATIGUE = 10.0;

  CAMPFIRE_TIME_TO_LIFE = 45.0; //����� ����� ������
  CAMPFIRE_TIME_ADD = 15.0;     //������� ������� �����������, ����� � ������ ������� ����� ��� ����� �����
  CAMPFIRE_REST_RADIUS = 100; //� ������ ������� (+ ������ ������) � ������ ������� ����������������� ����

  //� ����� ����� ����� ���-������: ����, �������� ��� �����
  GRASS_SNAKE_CHANCE = 0.2;
  GRASS_SNAKE_ADDHEALTH = -10.0;
  GRASS_SNAKE_ADDMIND  = -10.0;

  GRASS_MUSHROOM_CHANCE = 0.2;
  GRASS_TWIG_CHANCE = 0.3;

  LITTLEBERRY_TEXTURE = 'object_bush_berry.png';

type
  //������ ������� - � ���� (����� �� ����� � �.�) ��� � ���������
  //��� ��������� �������� ��������� Hint
  TpdWorldObjectStatus = (sWorld, sInventory);

  TpdBB = record
    Left, Right, Top, Bottom: Single;
  end;

  //NOTE: ��� �������� ������� ������� ������������� �������� ����
  //����� RecalcBB
  TpdWorldObject = class
  protected
    bb: TpdBB;
    constructor Create(); virtual;
    destructor Destroy(); override;
    function GetHintText(): WideString; virtual; abstract;
  public
    sprite: IglrSprite;
    status: TpdWorldObjectStatus;
    removeOnUse: Boolean; //�������� �� ��� �������������
    class function Initialize(aScene: Iglr2DScene): TpdWorldObject; virtual; abstract;
    class function GetObjectSprite(): IglrSprite; virtual; abstract;

    procedure OnCollect(); virtual; //�������� ��� ������� ��������
    procedure OnUse(); virtual; //�������� ��� �������������
    function IsInside(aPos: TdfVec2f): Boolean; virtual; //�������� �� ���������
    property HintText: WideString read GetHintText; //��������� ��� ���������
    procedure RecalcBB(); virtual; //����������� ��
  end;

  TpdWorldObjectClass = class of TpdWorldObject;

  //--���������. �� ���� ����� ������ �����
  TpdBush = class (TpdWorldObject)
  protected
    FScene: Iglr2DScene;
    FBerryCount: Integer;
    FBerries: array of IglrSprite;
    function GetHintText(): WideString; override;
    class function InitLittleBerry(): IglrSprite;
    procedure RemoveOnBerry();
  public
    class function Initialize(aScene: Iglr2DScene): TpdWorldObject; override;
    class function GetObjectSprite(): IglrSprite; override;
    procedure OnCollect(); override;
    procedure RecalcBB(); override;
  end;

  //�����. ��� ������������ ��� ��������� ����
  TpdTwig = class (TpdWorldObject)
  protected
    function GetHintText(): WideString; override;
  public
    class function Initialize(aScene: Iglr2DScene): TpdWorldObject; override;
    class function GetObjectSprite(): IglrSprite; override;
    procedure OnCollect(); override;
  end;

  //�������. ����� �������� �� ����� ��� ������� � ����� - ��������� ���������� ���
  TpdFlower = class (TpdWorldObject)
  protected
    function GetHintText(): WideString; override;
  public
    class function Initialize(aScene: Iglr2DScene): TpdWorldObject; override;
    class function GetObjectSprite(): IglrSprite; override;
    procedure OnCollect(); override;
    procedure OnUse(); override;
  end;

  //��������. ������� �����, � ����� �������� ����� �������� ��� ������� ���� ����
  //������������ � ������� �������� ��������������
  TpdMushroom = class (TpdWorldObject)
  protected
    function GetHintText(): WideString; override;
  public
    class function Initialize(aScene: Iglr2DScene): TpdWorldObject; override;
    class function GetObjectSprite(): IglrSprite; override;
    procedure OnCollect(); override;
    procedure OnUse(); override;
  end;

  //������ (��������) �����
  //������ ��� ���������� ������
  TpdOldGrass = class (TpdWorldObject)
  protected
    function GetHintText(): WideString; override;
  public
    class function Initialize(aScene: Iglr2DScene): TpdWorldObject; override;
    class function GetObjectSprite(): IglrSprite; override;
    procedure OnCollect(); override;
  end;

  //���. ������ �������� �����
  TpdKnife = class (TpdWorldObject)
  protected
    function GetHintText(): WideString; override;
  public
    class function Initialize(aScene: Iglr2DScene): TpdWorldObject; override;
    class function GetObjectSprite(): IglrSprite; override;
    procedure OnCollect(); override;
  end;

  //������. ���� ����������� ���������� ���� � ���������
  TpdBackpack = class (TpdWorldObject)
  protected
    function GetHintText(): WideString; override;
  public
    class function Initialize(aScene: Iglr2DScene): TpdWorldObject; override;
    procedure OnCollect(); override;
  end;

  //������ �������� �� �����
  //������� ����, ��������� ����, ��������� ��� ���, ���
  TpdWaterStatus = (bsWater, bsHotWater, bsRawTea, bsTea);

  //�����. ��������� �������� ����
  TpdBottle = class (TpdWorldObject)
  protected
    FNormTex, FTeaTex: IglrTexture;
    FWaterStatus: TpdWaterStatus;
    FWaterLevel: Integer;
    procedure SetWaterLevel(const Value: Integer);
    procedure SetWaterStatus(const Value: TpdWaterStatus);
    procedure SetTexture(aTex: IglrTexture);
    function GetHintText(): WideString; override;
  public
    //0-5 (��������� ��� 0 - 500 ��)
    property WaterLevel: Integer read FWaterLevel write SetWaterLevel;
    class function Initialize(aScene: Iglr2DScene): TpdWorldObject; override;
    class function GetObjectSprite(): IglrSprite; override;
    procedure OnCollect(); override;
    procedure OnUse(); override;
    procedure FillWithWater();

    property WaterStatus: TpdWaterStatus read FWaterStatus write SetWaterStatus;
  end;

  //����� �����. ���������� ��� �������� ������
  TpdWire = class (TpdWorldObject)
  protected
    function GetHintText(): WideString; override;
  public
    class function Initialize(aScene: Iglr2DScene): TpdWorldObject; override;
    class function GetObjectSprite(): IglrSprite; override;
    procedure OnCollect(); override;
  end;

  //�����. ���� �� ���� �� ��������, ����������� �� ������
  TpdBerry = class (TpdWorldObject)
  protected
    function GetHintText(): WideString; override;
  public
    class function Initialize(aScene: Iglr2DScene): TpdWorldObject; override;
    class function GetObjectSprite(): IglrSprite; override;
    procedure OnCollect(); override;
    procedure OnUse(); override;
  end;

  //������� �����, ����� ������, �� ����� ����� ����� ���-������ ���������� � ���?
  TpdNewGrass = class (TpdWorldObject)
  protected
    alreadySearch: Boolean;
    function GetHintText(): WideString; override;
  public
    class function Initialize(aScene: Iglr2DScene): TpdWorldObject; override;
    procedure OnCollect(); override;
  end;

  //����
  TpdFish = class (TpdWorldObject)
  protected
    function GetHintText(): WideString; override;
  public
    class function Initialize(aScene: Iglr2DScene): TpdWorldObject; override;
    class function GetObjectSprite(): IglrSprite; override;
    procedure OnCollect(); override;
    procedure OnUse(); override;
  end;


  {
    ����������� �����
  }

  //������ �����
  TpdSharpTwig = class (TpdWorldObject)
  protected
    function GetHintText(): WideString; override;
  public
    class function Initialize(aScene: Iglr2DScene): TpdWorldObject; override;
    class function GetObjectSprite(): IglrSprite; override;
    procedure OnCollect(); override;
  end;

  //������
  TpdFishRod = class (TpdWorldObject)
  protected
    function GetHintText(): WideString; override;
  public
    class function Initialize(aScene: Iglr2DScene): TpdWorldObject; override;
    class function GetObjectSprite(): IglrSprite; override;
    procedure OnCollect(); override;
    procedure OnUse(); override;
  end;

  //������ �� ������ (�����)
  TpdMushroomShashlikRaw = class (TpdWorldObject)
  protected
    function GetHintText(): WideString; override;
  public
    class function Initialize(aScene: Iglr2DScene): TpdWorldObject; override;
    class function GetObjectSprite(): IglrSprite; override;
    procedure OnCollect(); override;
    procedure OnUse(); override;
  end;

  //������ �� ������ (�������)
  TpdMushroomShashlikHot = class (TpdWorldObject)
  protected
    function GetHintText(): WideString; override;
  public
    class function Initialize(aScene: Iglr2DScene): TpdWorldObject; override;
    class function GetObjectSprite(): IglrSprite; override;
    procedure OnCollect(); override;
    procedure OnUse(); override;
  end;

  //������ �� ���� (�����)
  TpdFishShashlikRaw = class (TpdWorldObject)
  protected
    function GetHintText(): WideString; override;
  public
    class function Initialize(aScene: Iglr2DScene): TpdWorldObject; override;
    class function GetObjectSprite(): IglrSprite; override;
    procedure OnCollect(); override;
    procedure OnUse(); override;
  end;

  //������ �� ���� (�������)
  TpdFishShashlikHot = class (TpdWorldObject)
  protected
    function GetHintText(): WideString; override;
  public
    class function Initialize(aScene: Iglr2DScene): TpdWorldObject; override;
    class function GetObjectSprite(): IglrSprite; override;
    procedure OnCollect(); override;
    procedure OnUse(); override;
  end;

  //������
  TpdCampFire = class (TpdWorldObject)
  protected
    lifeSpr: IglrSprite;
    function GetHintText(): WideString; override;
  public
    timeToLife: Single; //���������� ����� ������� ������
    restRadius: Single;
    class function Initialize(aScene: Iglr2DScene): TpdWorldObject; override;
    class function GetObjectSprite(): IglrSprite; override;
    procedure OnCollect(); override;
    procedure RecalcBB(); override;
  end;

  procedure InitializeWorldObjects(aSURFile: TSURFile);
  procedure DeinitializeWorldObjects();
  function GetWorldObjectAtPosition(aPos: TdfVec2f): TpdWorldObject;
  procedure UpdateWorldObjects(const dt: Double);
  function WorldObjectsOnMouseMove(X, Y: Integer; Shift: TglrMouseShiftState): Boolean;
  function WorldObjectsOnMouseDown(X, Y: Integer;  MouseButton: TglrMouseButton;
    Shift: TglrMouseShiftState): Boolean;

  //for editor mode uses only
  procedure _SaveWorldObjects(var aSurFile: TSURFile);

  function AddNewWorldObject(aClass: TpdWorldObjectClass): TpdWorldObject;
  procedure DeleteWorldObject(aObject: TpdWorldObject);

  procedure NoPlaceToPut();

var
  worldObjects: array of TpdWorldObject;
  selectedWorldObject: TpdWorldObject;

implementation

uses
  SysUtils,
  uInventory, uPlayer, uWater,
  uGlobal;

var
  //��������� �� ��, ��� � �������� ��� ����������� (True) ��� ��� (False)
  //��� �������������� ������������ ������� � ������ - ������, �������, ������...
  knifeFirstPickup, wireFirstPickup, bottleFirstPickup: Boolean;


procedure NoPlaceToPut();
begin
  player.speech.Say('������ ������...', 3, colorRed, true);
  if not inventory.Visible then
    inventory.Visible := True;
end;

{ TpdWorldObject }

constructor TpdWorldObject.Create;
begin
  inherited Create();
  sprite := Factory.NewSprite();
  sprite.PivotPoint := ppCenter;
  sprite.Z := Z_STATICOBJECTS;
  status := sWorld;
  removeOnUse := True;
end;

destructor TpdWorldObject.Destroy;
begin
  sprite := nil;
  inherited;
end;

function TpdWorldObject.IsInside(aPos: TdfVec2f): Boolean;
begin
  Result := ( (aPos.x > bb.Left) and (aPos.x < bb.Right) )
       and( (aPos.y > bb.Top) and (aPos.y < bb.Bottom) );
end;

procedure TpdWorldObject.OnCollect;
begin
  DeleteWorldObject(Self);
end;

procedure TpdWorldObject.OnUse;
begin

end;

procedure TpdWorldObject.RecalcBB;
var
  i: Integer;
begin
  with bb, sprite do
  begin
    Left := 1/0;
    for i := 0 to 3 do
      if (Coords[i].x + Position.x) < Left then
        Left := Position.x + Coords[i].x;
    Right := - 1/0;
    for i := 0 to 3 do
      if (Coords[i].x + Position.x) > Right then
        Right := Position.x + Coords[i].x;
    Top :=  1/0;
    for i := 0 to 3 do
      if (Coords[i].y + Position.y) < Top then
        Top := Position.y + Coords[i].y;
    Bottom := - 1/0;
    for i := 0 to 3 do
      if (Coords[i].y + Position.y) > Bottom then
        Bottom := Position.y + Coords[i].y;
  end;
end;

{ TpdBush }

const
  BERRIES_COORDS: array[0..4] of TdfVec2f =
  ((x: -25; y: -20), (x: 25; y: 20),
   (x: -25; y: 20), (x: 0; y: 0),
   (x: 25; y: -20)
  );

function TpdBush.GetHintText: WideString;
begin
  if FBerryCount > 0 then
    Result := '���� � ������ (����: ' + IntToStr(FBerryCount) + ')'#13#10 + TEXT_LMB_COLLECT
  else
    Result := '���� ��� ����';
end;

class function TpdBush.GetObjectSprite: IglrSprite;
begin
  Result := Factory.NewSprite();
  Result.Material.Texture := atlasGame.LoadTexture(BUSH_TEXTURE);
  Result.UpdateTexCoords();
  Result.SetSizeToTextureSize();
  Result.PivotPoint := ppCenter;
end;

class function TpdBush.Initialize(aScene: Iglr2DScene): TpdWorldObject;
var
  i: Integer;
begin
  Result := TpdBush.Create();
  with Result as TpdBush do
  begin
    sprite.Material.Texture := atlasGame.LoadTexture(BUSH_TEXTURE);
    sprite.UpdateTexCoords();
    sprite.SetSizeToTextureSize();
    sprite.Z := sprite.Z - 2;
    aScene.RegisterElement(sprite);

    FBerryCount := 1 + Random(5);
    FScene := aScene;
    SetLength(FBerries, FBerryCount);
    for i := 0 to FBerryCount - 1 do
    begin
      FBerries[i] := InitLittleBerry();
      FScene.RegisterElement(FBerries[i]);
    end;
  end;
end;

class function TpdBush.InitLittleBerry: IglrSprite;
begin
  Result := Factory.NewSprite();
  with Result do
  begin
    Material.Texture := atlasGame.LoadTexture(LITTLEBERRY_TEXTURE);
    UpdateTexCoords();
    SetSizeToTextureSize();
    PivotPoint := ppCenter;
    Z := Z_STATICOBJECTS + 1;
  end;
end;

procedure TpdBush.OnCollect;
begin
  if FBerryCount > 0 then
    case inventory.AddObject(TpdBerry) of
      INV_OK:
      begin
        RemoveOnBerry();
      end;
      INV_NO_SLOTS: NoPlaceToPut();
      INV_MAX_CAPACITY: player.speech.Say('������ �� ������, � �� �������!', 3, colorYellow);
    end
  else
    player.speech.Say('������ ���� �� �����', 3);
end;

procedure TpdBush.RecalcBB;
var
  i: Integer;
begin
  inherited;
  //���, ���
  for i := 0 to FBerryCount - 1 do
    FBerries[i].Position := sprite.Position
      + BERRIES_COORDS[i]
      + dfVec2f(6 - Random(13), 6 - Random(13));
end;

procedure TpdBush.RemoveOnBerry;
begin
   FBerryCount := FBerryCount - 1;
   FScene.UnregisterElement(FBerries[High(FBerries)]);
   SetLength(FBerries, High(FBerries));
end;

{ TpdTwig }

function TpdTwig.GetHintText: WideString;
begin
  case status of
    sWorld: Result := '�����.'#13#10 + TEXT_LMB_GET;
    sInventory: Result := '�����.'#13#10'����� ���������� ���'#13#10'������� ������.';
  end;
end;

class function TpdTwig.GetObjectSprite: IglrSprite;
begin
  Result := Factory.NewSprite();
  Result.Material.Texture := atlasGame.LoadTexture(TWIG_TEXTURE);
  Result.UpdateTexCoords();
  Result.SetSizeToTextureSize();
  Result.Rotation := 35;
  Result.PivotPoint := ppCenter;
end;

class function TpdTwig.Initialize(aScene: Iglr2DScene): TpdWorldObject;
begin
  Result := TpdTwig.Create();
  with Result do
  begin
    sprite.Material.Texture := atlasGame.LoadTexture(TWIG_TEXTURE);
    sprite.UpdateTexCoords();
    sprite.SetSizeToTextureSize();
    //sprite.Rotation := 90 - Random(180);
    aScene.RegisterElement(sprite);
    removeOnUse := False;
  end;
end;

procedure TpdTwig.OnCollect;
begin
  case inventory.AddObject(TpdTwig) of
    INV_OK: inherited OnCollect();
    INV_NO_SLOTS: NoPlaceToPut();
    INV_MAX_CAPACITY: player.speech.Say('� ���� ��� �����'#13#10'�� ����� ������!', 3, colorYellow);
  end;
end;

{ TpdMushroom }

function TpdMushroom.GetHintText: WideString;
begin
  case status of
    sWorld: Result := '����.'#13#10 + TEXT_LMB_COLLECT;
    sInventory: Result := '����.'#13#10'�������, ������������...'#13#10 + TEXT_RMB_EAT;
  end;
end;

class function TpdMushroom.GetObjectSprite: IglrSprite;
begin
  Result := Factory.NewSprite();
  Result.Material.Texture := atlasGame.LoadTexture(MUSHROOM_TEXTURE);
  Result.UpdateTexCoords();
  Result.SetSizeToTextureSize();
  Result.PivotPoint := ppCenter;
end;

class function TpdMushroom.Initialize(aScene: Iglr2DScene): TpdWorldObject;
begin
  Result := TpdMushroom.Create();
  with Result do
  begin
    sprite.Material.Texture := atlasGame.LoadTexture(MUSHROOM_TEXTURE);
    sprite.UpdateTexCoords();
    sprite.SetSizeToTextureSize();
    aScene.RegisterElement(sprite);
    removeOnUse := True;
  end;
end;

procedure TpdMushroom.OnCollect;
begin
  case inventory.AddObject(TpdMushroom) of
    INV_OK: inherited OnCollect();
    INV_NO_SLOTS: NoPlaceToPut();
    INV_MAX_CAPACITY: player.speech.Say('��-�, � ������� ���� ����������...', 3, colorYellow);
  end;
end;

procedure TpdMushroom.OnUse;
var
  isHal, isGood: Boolean;
begin
  inherited;
  isHal := Random() < MUSHROOM_CHANCE_OF_HALLUCINATION; //�������������� ��� ���
  if isHal then
  begin
    isGood := Random() < 0.5; //������� �������������� ��� ���
    if isGood then
    begin
      player.speech.Say('�-�-��. ��������'#13#10'���������� �����������...', 4, colorGreen);
      player.AddParam(pMind, MUSHROOM_ADDMIND);
    end
    else
    begin
      player.speech.Say('���, �� ������ ����! ������!'#13#10'���������������!', 4, colorRed);
      player.AddParam(pMind, -2 * MUSHROOM_ADDMIND);
    end;
  end
  else
    player.AddParam(pHunger, MUSHROOM_ADDHUNGER);
end;

{ TpdFlower }

function TpdFlower.GetHintText: WideString;
begin
  case status of
    sWorld: Result := '�������.'#13#10 + TEXT_LMB_COLLECT;
    sInventory: Result := '�������.'#13#10'�����, �� �����?..'#13#10 + TEXT_RMB_EAT;
  end;
end;

class function TpdFlower.GetObjectSprite: IglrSprite;
begin
  Result := Factory.NewSprite();
  Result.Material.Texture := atlasGame.LoadTexture(FLOWER_TEXTURE);
  Result.UpdateTexCoords();
  Result.SetSizeToTextureSize();
  Result.PivotPoint := ppCenter;
end;

class function TpdFlower.Initialize(aScene: Iglr2DScene): TpdWorldObject;
begin
  Result := TpdFlower.Create();
  with Result do
  begin
    sprite.Material.Texture := atlasGame.LoadTexture(FLOWER_TEXTURE);
    sprite.UpdateTexCoords();
    sprite.SetSizeToTextureSize();
    aScene.RegisterElement(sprite);
    removeOnUse := True;
  end;
end;

procedure TpdFlower.OnCollect;
begin
  case inventory.AddObject(TpdFlower) of
    INV_OK: inherited OnCollect();
    INV_NO_SLOTS: NoPlaceToPut();
    INV_MAX_CAPACITY: player.speech.Say('������ ������, � ���� ��� ��������!'#13#10'�� � ������-�� ������', 3, colorYellow);
  end;
end;

procedure TpdFlower.OnUse;
begin
  inherited;
  player.speech.Say('��� �������, ��� ��� �����'#13#10'����������� ��-�������...', 4);
  player.AddParam(pHealth, FLOWER_ADDHEALTH);
end;

{ TpdOldGrass }

function TpdOldGrass.GetHintText: WideString;
begin
  case status of
    sWorld: Result := '������ �������� �����.'#13#10 + TEXT_LMB_COLLECT;
    sInventory: Result := '������ �������� �����.'#13#10'������� �����.';
  end;
end;

class function TpdOldGrass.GetObjectSprite: IglrSprite;
begin
  Result := Factory.NewSprite();
  Result.Material.Texture := atlasGame.LoadTexture(OLDGRASS_TEXTURE);
  Result.UpdateTexCoords();
  Result.SetSizeToTextureSize();
  Result.PivotPoint := ppCenter;
end;

class function TpdOldGrass.Initialize(aScene: Iglr2DScene): TpdWorldObject;
begin
  Result := TpdOldGrass.Create();
  with Result do
  begin
    sprite.Material.Texture := atlasGame.LoadTexture(OLDGRASS_TEXTURE);
    sprite.UpdateTexCoords();
    sprite.SetSizeToTextureSize();
    aScene.RegisterElement(sprite);
    removeOnUse := False;
  end;
end;


procedure TpdOldGrass.OnCollect;
begin
  case inventory.AddObject(TpdOldGrass) of
    INV_OK: inherited OnCollect();
    INV_NO_SLOTS: NoPlaceToPut();
    INV_MAX_CAPACITY: player.speech.Say('� �� ��� �����,'#13#10'���� ��� ������� �����?', 3, colorYellow);
  end;
end;

{ TpdKnife }

function TpdKnife.GetHintText: WideString;
begin
  case status of
    sWorld: Result := '���!'#13#10 + TEXT_LMB_GET;
    sInventory: Result := '����������� ���.'#13#10'������ ��� � �����.'#13#10'� ����� �� �������.';
  end;
end;

class function TpdKnife.GetObjectSprite: IglrSprite;
begin
  Result := Factory.NewSprite();
  Result.Material.Texture := atlasGame.LoadTexture(KNIFE_TEXTURE);
  Result.UpdateTexCoords();
  Result.SetSizeToTextureSize();
  Result.Rotation := 35;
  Result.PivotPoint := ppCenter;
end;

class function TpdKnife.Initialize(aScene: Iglr2DScene): TpdWorldObject;
begin
  Result := TpdKnife.Create();
  with Result do
  begin
    sprite.Material.Texture := atlasGame.LoadTexture(KNIFE_TEXTURE);
    sprite.UpdateTexCoords();
    sprite.SetSizeToTextureSize();
    aScene.RegisterElement(sprite);
    removeOnUse := False;
  end;
end;

procedure TpdKnife.OnCollect;
begin
  case inventory.AddObject(TpdKnife) of
    INV_OK:
    begin
      if not knifeFirstPickup then
      begin
        player.speech.Say('�������� ����������, ��� ������'#13#10'���� ����� ����� ���� ������', 5);
        player.AddParam(pMind, KNIFE_ADDMIND_ONPICKUP);
        knifeFirstPickup := True;
      end;
      inherited OnCollect();
    end;
    INV_NO_SLOTS: NoPlaceToPut();
    INV_MAX_CAPACITY: ;
  end;
end;

{ TpdBackpack }

function TpdBackpack.GetHintText: WideString;
begin
  Result := '��������� �� �����-�� ������'#13#10 + TEXT_LMB_GET;
end;

class function TpdBackpack.Initialize(aScene: Iglr2DScene): TpdWorldObject;
begin
  Result := TpdBackpack.Create();
  with Result do
  begin
    sprite.Material.Texture := atlasGame.LoadTexture(BACKPACK_TEXTURE);
    sprite.UpdateTexCoords();
    sprite.SetSizeToTextureSize();
    aScene.RegisterElement(sprite);
  end;
end;

procedure TpdBackpack.OnCollect;
begin
  player.speech.Say('��-��-��, ������ � ���� ���� ������!', 5);
  player.AddParam(pMind, BACKPACK_ADDMIND_ONPICKUP);
  player.SetTextureWithBackpack();
  inventory.AddSlots(9);
  if inventory.Visible then
    inventory.Visible := False;
  inventory.Visible := True;
  inherited OnCollect();
end;

{ TpdBottle }

procedure TpdBottle.FillWithWater;
begin
  WaterLevel := 5;
  if WaterStatus in [bsHotWater, bsTea] then
    WaterStatus := bsWater;
  player.speech.Say('����� �� �����!', 3);
end;

function TpdBottle.GetHintText: WideString;
var
  rmbText: WideString;
begin
  case status of
    sWorld: Result := '�����.'#13#10'�����, ������ ���-������ ��������?'#13#10 + TEXT_LMB_GET;
    sInventory:
    begin
      if player.inWater then
        rmbText := TEXT_RMB_FULFILL
      else
        rmbText := TEXT_RMB_DRINK;
      case WaterStatus of
        bsWater: Result := '�����, 500 ��.'#13#10'����: ' + IntToStr(FWaterLevel * 100) +' ��.'#13#10 + rmbText;
        bsHotWater: Result := '�����, 500 ��.'#13#10'��������� ����: ' + IntToStr(FWaterLevel * 100) +' ��.'#13#10 + rmbText;
        bsRawTea: Result := '�����, 500 ��.'#13#10'���� � ��������: ' + IntToStr(FWaterLevel * 100) +' ��.'#13#10 + rmbText;
        bsTea: Result := '�����, 500 ��.'#13#10'���: ' + IntToStr(FWaterLevel * 100) +' ��.'#13#10 + rmbText;
      end;
    end;
  end;
end;

class function TpdBottle.GetObjectSprite: IglrSprite;
begin
  Result := Factory.NewSprite();
  Result.Material.Texture := atlasGame.LoadTexture(BOTTLE_TEXTURE);
  Result.UpdateTexCoords();
  Result.SetSizeToTextureSize();
  Result.PivotPoint := ppCenter;
end;

class function TpdBottle.Initialize(aScene: Iglr2DScene): TpdWorldObject;
begin
  Result := TpdBottle.Create();
  with Result as TpdBottle do
  begin
    FNormTex := atlasGame.LoadTexture(BOTTLE_TEXTURE);
    FTeaTex := atlasGame.LoadTexture(BOTTLE_TEA_TEXTURE);
    SetTexture(FNormTex);
    aScene.RegisterElement(sprite);
    removeOnUse := False;
    WaterLevel := 0;
    FWaterStatus := bsWater;
  end;
end;

procedure TpdBottle.OnCollect;
begin
  case inventory.AddObject(TpdBottle) of
    INV_OK:
    begin
      if not bottleFirstPickup then
      begin
        player.speech.Say('15 ������� �� ������ ��������!'#13#10'��-��-��! � �������... � ���, ��� ����', 7);
        player.AddParam(pMind, BOTTLE_ADDMIND_ONPICKUP);
        bottleFirstPickup := True;
      end;
      with (inventory.GetSlotWithItem(TpdBottle).item as TpdBottle) do
      begin
        WaterLevel := Self.WaterLevel;
        WaterStatus := Self.WaterStatus;
      end;
      inherited OnCollect();
    end;
    INV_NO_SLOTS: NoPlaceToPut();
    INV_MAX_CAPACITY: ;
  end;
end;

procedure TpdBottle.OnUse;
begin
  inherited;
  //���� � ����, �� ��������� ������
  if player.inWater then
  begin
    FillWithWater();
    Exit();
  end;

  if FWaterLevel > 0 then
  begin
    case WaterStatus of
      bsWater:
      begin
        player.AddParam(pThirst, BOTTLE_ADDTHIRST);
        player.AddParam(pHealth, BOTTLE_ADDHEALTH);
      end;
      bsHotWater:
      begin
        player.AddParam(pThirst, BOTTLE_HOT_ADDTHIRST);
        player.AddParam(pHealth, BOTTLE_HOT_ADDHEALTH);
      end;
      bsRawTea:
      begin
        player.AddParam(pThirst, BOTTLE_RAWTEA_ADDTHIRST);
        player.AddParam(pHealth, BOTTLE_RAWTEA_ADDHEALTH);
      end;
      bsTea:
      begin
        player.AddParam(pThirst, BOTTLE_TEA_ADDTHIRST);
        player.AddParam(pHealth, BOTTLE_TEA_ADDHEALTH);
        player.AddParam(pFatigue, BOTTLE_TEA_ADDFATIGUE);
      end;
    end;
    Dec(FWaterLevel);
    //������ ������ �� �������
    if WaterLevel = 0 then
      WaterStatus := bsWater;
  end
  else
    player.speech.Say('�� ������ �����', 3);
end;

procedure TpdBottle.SetTexture(aTex: IglrTexture);
begin
  sprite.Material.Texture := aTex;
  sprite.UpdateTexCoords();
  sprite.SetSizeToTextureSize();
end;

procedure TpdBottle.SetWaterLevel(const Value: Integer);
begin
  FWaterLevel := Clamp(Value, 0, 5);
end;

procedure TpdBottle.SetWaterStatus(const Value: TpdWaterStatus);
begin
  if FWaterStatus <> Value then
  begin
    FWaterStatus := Value;
    if FWaterStatus in [bsRawTea, bsTea] then
      SetTexture(FTeaTex)
    else
      SetTexture(FNormTex);
  end;
end;

{ TpdWire }

function TpdWire.GetHintText: WideString;
begin
  case status of
    sWorld: Result := '���-�� ������� � �����'#13#10 + TEXT_LMB_GET;
    sInventory: Result := '������� �����.'#13#10'���� ������ �����';
  end;
end;

class function TpdWire.GetObjectSprite: IglrSprite;
begin
  Result := Factory.NewSprite();
  Result.Material.Texture := atlasGame.LoadTexture(WIRE_TEXTURE);
  Result.UpdateTexCoords();
  Result.SetSizeToTextureSize();
  Result.PivotPoint := ppCenter;
end;

class function TpdWire.Initialize(aScene: Iglr2DScene): TpdWorldObject;
begin
  Result := TpdWire.Create();
  with Result do
  begin
    sprite.Material.Texture := atlasGame.LoadTexture(WIRE_TEXTURE);
    sprite.UpdateTexCoords();
    sprite.SetSizeToTextureSize();
    sprite.ScaleMult(0.6);
    aScene.RegisterElement(sprite);
    removeOnUse := True;
  end;
end;

procedure TpdWire.OnCollect;
begin
  case inventory.AddObject(TpdWire) of
    INV_OK:
    begin
      if not wireFirstPickup then
      begin
        player.speech.Say('������ ����. ����� ���� ���������'#13#10'� �������� �� �������', 7);
        player.AddParam(pMind, WIRE_ADDMIND_ONPICKUP);
        wireFirstPickup := True;
      end;
      inherited OnCollect();
    end;
    INV_NO_SLOTS: NoPlaceToPut();
    INV_MAX_CAPACITY: ;
  end;
end;


{ TpdBerry }

function TpdBerry.GetHintText: WideString;
begin
  case status of
    sWorld: Result := '�����'#13#10 + TEXT_LMB_COLLECT;
    sInventory: Result := '�����.'#13#10'������ �������� �� ���.'#13#10 + TEXT_RMB_EAT;
  end;
end;

class function TpdBerry.GetObjectSprite: IglrSprite;
begin
  Result := Factory.NewSprite();
  Result.Material.Texture := atlasGame.LoadTexture(BERRY_TEXTURE);
  Result.UpdateTexCoords();
  Result.SetSizeToTextureSize();
  Result.PivotPoint := ppCenter;
end;

class function TpdBerry.Initialize(aScene: Iglr2DScene): TpdWorldObject;
begin
  Result := TpdBerry.Create();
  with Result do
  begin
    sprite.Material.Texture := atlasGame.LoadTexture(BERRY_TEXTURE);
    sprite.UpdateTexCoords();
    sprite.SetSizeToTextureSize();
    aScene.RegisterElement(sprite);
    removeOnUse := True;
  end;
end;

procedure TpdBerry.OnCollect;
begin
  case inventory.AddObject(TpdBerry) of
    INV_OK: inherited OnCollect();
    INV_NO_SLOTS: NoPlaceToPut();
    INV_MAX_CAPACITY: player.speech.Say('������ �� ������, � �� �������!', 3, colorYellow);
  end;
end;


procedure TpdBerry.OnUse;
begin
  inherited;
  if Random() < BERRY_BAD_CHANCE then
  begin
    player.AddParam(pHealth, BERRY_BAD_ADD_HEALTH);
    player.AddParam(pHunger, -BERRY_ADDHUNGER);
    player.AddParam(pThirst, - 2 * BERRY_ADDTHIRST);
    player.speech.Say('����, ������� ������ ��������...', 3, colorRed);
  end
  else
  begin
    player.AddParam(pHunger, BERRY_ADDHUNGER);
    player.AddParam(pThirst, BERRY_ADDTHIRST);
    player.AddParam(pFatigue, BERRY_ADDFATIGUE);
  end;
end;

{ TpdNewGrass }

function TpdNewGrass.GetHintText: WideString;
begin
  Result := '������� �����.'#13#10'��� � �������� ���-������';
end;

class function TpdNewGrass.Initialize(aScene: Iglr2DScene): TpdWorldObject;
begin
  Result := TpdNewGrass.Create();
  with Result as TpdNewGrass do
  begin
    sprite.Material.Texture := atlasGame.LoadTexture(NEWGRASS_TEXTURE);
    sprite.UpdateTexCoords();
    sprite.SetSizeToTextureSize();
    sprite.Z := sprite.Z - 1;
    aScene.RegisterElement(sprite);

    alreadySearch := False;
  end;
end;

procedure TpdNewGrass.OnCollect;
var
  chance: Single;
begin
  if alreadySearch then
    player.speech.Say('��� � ��� �������', 3)
  else
  begin
    chance := Random();
    if chance < GRASS_SNAKE_CHANCE then
    begin
      player.speech.Say('�-�-�! ���� ���-�� �������!', 3, colorRed);
      player.AddParam(pHealth, GRASS_SNAKE_ADDHEALTH);
      player.AddParam(pMind, GRASS_SNAKE_ADDMIND);
    end
    else if chance < GRASS_SNAKE_CHANCE + GRASS_MUSHROOM_CHANCE then
    begin
      player.speech.Say('�� ��, ��������!', 3);
      with AddNewWorldObject(TpdMushroom) do
      begin
        sprite.Position := Self.sprite.Position + dfVec2f(4 - Random(9), 4 - Random(9));
        sprite.Rotation := 10 - Random(20);
        RecalcBB();
      end;
    end
    else if chance < GRASS_SNAKE_CHANCE + GRASS_MUSHROOM_CHANCE + GRASS_TWIG_CHANCE then
    begin
      player.speech.Say('�������� �����!', 3);
      with AddNewWorldObject(TpdTwig) do
      begin
        sprite.Position := Self.sprite.Position + dfVec2f(15 - Random(31), 15 - Random(31));
        sprite.Rotation := 70 - Random(141);
        RecalcBB();
      end;
    end
    else
      player.speech.Say('��, ��� ������ ������ ���', 3);
    alreadySearch := True;
  end;

//  player.speech.Say('���� ����� ���� �� ��������'#13#10'�����, ���� �� ���������'#13#10'��� ������������', 6);
end;

{ TpdFish }

function TpdFish.GetHintText: WideString;
begin
  case status of
    sWorld: Result := '����'#13#10 + TEXT_LMB_GET;
    sInventory: Result := '����.'#13#10'� ����� ����, ����������,'#13#10'������ ��� ��������'#13#10 + TEXT_RMB_EAT;
  end;
end;

class function TpdFish.GetObjectSprite: IglrSprite;
begin
  Result := Factory.NewSprite();
  Result.Material.Texture := atlasGame.LoadTexture(FISH_TEXTURE);
  Result.UpdateTexCoords();
  Result.SetSizeToTextureSize();
  Result.PivotPoint := ppCenter;
  Result.Rotation := 40;
end;

class function TpdFish.Initialize(aScene: Iglr2DScene): TpdWorldObject;
begin
  Result := TpdFish.Create();
  with Result do
  begin
    sprite.Material.Texture := atlasGame.LoadTexture(FISH_TEXTURE);
    sprite.UpdateTexCoords();
    sprite.SetSizeToTextureSize();
    sprite.Rotation := 40;
    aScene.RegisterElement(sprite);
  end;
end;

procedure TpdFish.OnCollect;
begin
  case inventory.AddObject(TpdFish) of
    INV_OK: inherited OnCollect();
    INV_NO_SLOTS: NoPlaceToPut();
    INV_MAX_CAPACITY: player.speech.Say('��������! � ���� ���'#13#10'����� �������� ���� ���!', 3, colorYellow);
  end;
end;

procedure TpdFish.OnUse;
begin
  inherited;
  player.AddParam(pHunger, FISH_ADDHUNGER);
  player.AddParam(pHealth, FISH_ADDHEALTH);
end;

{ TpdSharpTwig }

function TpdSharpTwig.GetHintText: WideString;
begin
  case status of
    sWorld: Result := '������ �����'#13#10 + TEXT_LMB_COLLECT;
    sInventory: Result := '������ �����.'#13#10'����� ���-������ ��'#13#10'���������. ��������, �����...';
  end;
end;

class function TpdSharpTwig.GetObjectSprite: IglrSprite;
begin
  Result := Factory.NewSprite();
  Result.Material.Texture := atlasGame.LoadTexture(SHARP_TWIG_TEXTURE);
  Result.UpdateTexCoords();
  Result.SetSizeToTextureSize();
  Result.PivotPoint := ppCenter;
  Result.Rotation := -40;
end;

class function TpdSharpTwig.Initialize(aScene: Iglr2DScene): TpdWorldObject;
begin
  Result := TpdSharpTwig.Create();
  with Result do
  begin
    sprite.Material.Texture := atlasGame.LoadTexture(SHARP_TWIG_TEXTURE);
    sprite.UpdateTexCoords();
    sprite.SetSizeToTextureSize();
    sprite.Rotation := -40;
    aScene.RegisterElement(sprite);

    removeOnUse := False;
  end;
end;

procedure TpdSharpTwig.OnCollect;
begin
  case inventory.AddObject(TpdSharpTwig) of
    INV_OK: inherited OnCollect();
    INV_NO_SLOTS: NoPlaceToPut();
    INV_MAX_CAPACITY: player.speech.Say('������ � ���� ������ �����!', 3, colorYellow);
  end;
end;


{ TpdFishRod }

function TpdFishRod.GetHintText: WideString;
begin
  case status of
    sWorld: Result := '����������� ������'#13#10 + TEXT_LMB_COLLECT;
    sInventory:
      if player.inWater then
        Result := '����������� ������.'#13#10 + TEXT_RMB_GETFISH
      else
        Result := '����������� ������.'#13#10'����� � �� �������.';
  end;
end;

class function TpdFishRod.GetObjectSprite: IglrSprite;
begin
  Result := Factory.NewSprite();
  Result.Material.Texture := atlasGame.LoadTexture(FISHROD_TEXTURE);
  Result.UpdateTexCoords();
  Result.SetSizeToTextureSize();
  Result.PivotPoint := ppCenter;
end;

class function TpdFishRod.Initialize(aScene: Iglr2DScene): TpdWorldObject;
begin
  Result := TpdFishRod.Create();
  with Result do
  begin
    sprite.Material.Texture := atlasGame.LoadTexture(FISHROD_TEXTURE);
    sprite.UpdateTexCoords();
    sprite.SetSizeToTextureSize();
    aScene.RegisterElement(sprite);
    removeOnUse := False;
  end;
end;

procedure TpdFishRod.OnCollect;
begin
  case inventory.AddObject(TpdFishRod) of
    INV_OK: inherited OnCollect();
    INV_NO_SLOTS: NoPlaceToPut();
    INV_MAX_CAPACITY: player.speech.Say('������, ������ ���� �� ������', 3);
  end;
end;

procedure TpdFishRod.OnUse;
begin
  inherited;
  if Assigned(playerInWater) and (playerInWater.fishCount > 0) then
    case inventory.AddObject(TpdFish) of
      INV_OK:
      begin
        player.speech.Say('������, ����������� ���!', 3);
        playerInWater.GetOneFish();
      end;
      INV_NO_SLOTS: NoPlaceToPut();
      INV_MAX_CAPACITY: player.speech.Say('��������! � ���� ���'#13#10'����� �������� ���� ���!', 3, colorYellow);
    end
  else
    player.speech.Say('�������, ����� ��� ��� ����', 3);
end;

{ TpdMushroomShashlik }

function TpdMushroomShashlikRaw.GetHintText: WideString;
begin
  case status of
    sWorld: Result := '����� ������ �� ������'#13#10 + TEXT_LMB_GET;
    sInventory: Result := '����� ������ �� ������'#13#10'����� ��������'#13#10 + TEXT_RMB_EAT;
  end;
end;

class function TpdMushroomShashlikRaw.GetObjectSprite: IglrSprite;
begin
  Result := Factory.NewSprite();
  Result.Material.Texture := atlasGame.LoadTexture(MUSHROOM_SHASHLIK_TEXTURE);
  Result.UpdateTexCoords();
  Result.SetSizeToTextureSize();
  Result.PivotPoint := ppCenter;
  Result.Rotation := 40;
end;

class function TpdMushroomShashlikRaw.Initialize(
  aScene: Iglr2DScene): TpdWorldObject;
begin
  Result := TpdMushroomShashlikRaw.Create();
  with Result as TpdMushroomShashlikRaw do
  begin
    sprite.Material.Texture := atlasGame.LoadTexture(MUSHROOM_SHASHLIK_TEXTURE);
    sprite.UpdateTexCoords();
    sprite.SetSizeToTextureSize();
    sprite.Rotation := 40;
    aScene.RegisterElement(sprite);
    removeOnUse := True;
  end;
end;

procedure TpdMushroomShashlikRaw.OnCollect;
begin
  case inventory.AddObject(TpdMushroomShashlikRaw) of
    INV_OK: inherited OnCollect();
    INV_NO_SLOTS: NoPlaceToPut();
    INV_MAX_CAPACITY: player.speech.Say('� ���� ��� ��� �������'#13#10'�� ��������', 3, colorYellow);
  end;
end;

procedure TpdMushroomShashlikRaw.OnUse;
begin
  inherited;
  player.AddParam(pHunger, MUSHROOM_SHASHLIK_RAW_ADDHUNGER);
  player.speech.Say('�������, �� ����� �� ��������', 3);
end;

{ TpdMushroomShashlikHot }

function TpdMushroomShashlikHot.GetHintText: WideString;
begin
  case status of
    sWorld: Result := '������� ������ �� ������'#13#10 + TEXT_LMB_GET;
    sInventory: Result := '������� ������ �� ������'#13#10'�������� �����������'#13#10 + TEXT_RMB_EAT;
  end;
end;

class function TpdMushroomShashlikHot.GetObjectSprite: IglrSprite;
begin
  Result := Factory.NewSprite();
  Result.Material.Texture := atlasGame.LoadTexture(MUSHROOM_SHASHLIK_READY_TEXTURE);
  Result.UpdateTexCoords();
  Result.SetSizeToTextureSize();
  Result.PivotPoint := ppCenter;
  Result.Rotation := 40;
end;

class function TpdMushroomShashlikHot.Initialize(
  aScene: Iglr2DScene): TpdWorldObject;
begin
  Result := TpdMushroomShashlikHot.Create();
  with Result as TpdMushroomShashlikHot do
  begin
    sprite.Material.Texture := atlasGame.LoadTexture(MUSHROOM_SHASHLIK_READY_TEXTURE);
    sprite.UpdateTexCoords();
    sprite.SetSizeToTextureSize();
    sprite.Rotation := 40;
    aScene.RegisterElement(sprite);
    removeOnUse := True;
  end;
end;

procedure TpdMushroomShashlikHot.OnCollect;
begin
  case inventory.AddObject(TpdMushroomShashlikHot) of
    INV_OK: inherited OnCollect();
    INV_NO_SLOTS: NoPlaceToPut();
    INV_MAX_CAPACITY: player.speech.Say('� ���� ��� ��� �������'#13#10'�� ��������', 3, colorYellow);
  end;
end;

procedure TpdMushroomShashlikHot.OnUse;
begin
  inherited;
  player.AddParam(pHunger, MUSHROOM_SHASHLIK_HOT_ADDHUNGER);
  player.AddParam(pFatigue, MUSHROOM_SHASHLIK_HOT_ADDFATIGUE);
  player.speech.Say('�� ���� �����, ��� �� ���', 3);
end;


{ TpdFishShashlik }

function TpdFishShashlikRaw.GetHintText: WideString;
begin
  case status of
    sWorld: Result := '����� ������ �� ����'#13#10 + TEXT_LMB_GET;
    sInventory: Result := '����� ������ �� ����'#13#10'�������� ��...'#13#10 + TEXT_RMB_EAT;
  end;
end;

class function TpdFishShashlikRaw.GetObjectSprite: IglrSprite;
begin
  Result := Factory.NewSprite();
  Result.Material.Texture := atlasGame.LoadTexture(FISH_SHASHLIK_TEXTURE);
  Result.UpdateTexCoords();
  Result.SetSizeToTextureSize();
  Result.PivotPoint := ppCenter;
  Result.Rotation := 40;
end;

class function TpdFishShashlikRaw.Initialize(aScene: Iglr2DScene): TpdWorldObject;
begin
  Result := TpdFishShashlikRaw.Create();
  with Result as TpdFishShashlikRaw do
  begin
    sprite.Material.Texture := atlasGame.LoadTexture(FISH_SHASHLIK_TEXTURE);
    sprite.UpdateTexCoords();
    sprite.SetSizeToTextureSize();
    sprite.Rotation := 40;
    aScene.RegisterElement(sprite);
    removeOnUse := True;
  end;
end;

procedure TpdFishShashlikRaw.OnCollect;
begin
  case inventory.AddObject(TpdFishShashlikRaw) of
    INV_OK: inherited OnCollect();
    INV_NO_SLOTS: NoPlaceToPut();
    INV_MAX_CAPACITY: player.speech.Say('� ���� ��� ��� �������'#13#10'�� ��������', 3, colorYellow);
  end;
end;

procedure TpdFishShashlikRaw.OnUse;
begin
  inherited;
  player.AddParam(pHunger, FISH_SHASHLIK_RAW_ADDHUNGER);
  player.AddParam(pHealth, FISH_SHASHLIK_RAW_ADDHEALTH);
  player.speech.Say('����� ���� �� �����, ��...', 3);
end;

{ TpdFishShashlikHot }

function TpdFishShashlikHot.GetHintText: WideString;
begin
  case status of
    sWorld: Result := '������� ������ �� ����'#13#10 + TEXT_LMB_GET;
    sInventory: Result := '������� ������ �� ����'#13#10'�������� ���������!'#13#10 + TEXT_RMB_EAT;
  end;
end;

class function TpdFishShashlikHot.GetObjectSprite: IglrSprite;
begin
  Result := Factory.NewSprite();
  Result.Material.Texture := atlasGame.LoadTexture(FISH_SHASHLIK_READY_TEXTURE);
  Result.UpdateTexCoords();
  Result.SetSizeToTextureSize();
  Result.PivotPoint := ppCenter;
  Result.Rotation := 40;
end;

class function TpdFishShashlikHot.Initialize(
  aScene: Iglr2DScene): TpdWorldObject;
begin
  Result := TpdFishShashlikHot.Create();
  with Result as TpdFishShashlikHot do
  begin
    sprite.Material.Texture := atlasGame.LoadTexture(FISH_SHASHLIK_READY_TEXTURE);
    sprite.UpdateTexCoords();
    sprite.SetSizeToTextureSize();
    sprite.Rotation := 40;
    aScene.RegisterElement(sprite);
    removeOnUse := True;
  end;
end;

procedure TpdFishShashlikHot.OnCollect;
begin
  case inventory.AddObject(TpdFishShashlikHot) of
    INV_OK: inherited OnCollect();
    INV_NO_SLOTS: NoPlaceToPut();
    INV_MAX_CAPACITY: player.speech.Say('� ���� ��� ��� �������'#13#10'�� ��������', 3, colorYellow);
  end;
end;

procedure TpdFishShashlikHot.OnUse;
begin
  inherited;
  player.AddParam(pHunger, FISH_SHASHLIK_HOT_ADDHUNGER);
  player.AddParam(pHunger, FISH_SHASHLIK_HOT_ADDHEALTH);
  player.AddParam(pFatigue, FISH_SHASHLIK_HOT_ADDFATIGUE);
  player.speech.Say('������������ ������!', 3);
end;


{ TpdCampFire }

function TpdCampFire.GetHintText: WideString;
begin
  Result := '������.'#13#10'����� ����� ����������.'#13#10'�� ��� ����� ���-������ ��������';
end;

class function TpdCampFire.GetObjectSprite: IglrSprite;
begin
  Result := Factory.NewSprite();
  Result.Material.Texture := atlasGame.LoadTexture(CAMPFIRE_TEXTURE);
  Result.UpdateTexCoords();
  Result.SetSizeToTextureSize();
  Result.PivotPoint := ppCenter;
end;

class function TpdCampFire.Initialize(aScene: Iglr2DScene): TpdWorldObject;
begin
  Result := TpdCampFire.Create();
  with Result as TpdCampFire do
  begin
    sprite.Material.Texture := atlasGame.LoadTexture(CAMPFIRE_TEXTURE);
    sprite.UpdateTexCoords();
    sprite.SetSizeToTextureSize();
    sprite.Z := sprite.Z - 1;
    aScene.RegisterElement(sprite);

    timeToLife := CAMPFIRE_TIME_TO_LIFE;
    restRadius := CAMPFIRE_REST_RADIUS + (sprite.Width + sprite.Height) / 4;

    lifeSpr := Factory.NewSprite();
    lifeSpr.Z := Z_STATICOBJECTS + 1;
    lifeSpr.Width := sprite.Width;
    lifespr.Height := 5;
    lifespr.Material.Diffuse := colorRed;
    aScene.RegisterElement(lifeSpr);
  end;
end;

procedure TpdCampFire.OnCollect;
begin
  //������ ������ ��� ����� � ������� ����� :)
end;


procedure TpdCampFire.RecalcBB;
begin
  inherited;
  lifeSpr.Position := sprite.Position + dfVec2f(-sprite.Width / 2, 30);
end;

//--����� �������


procedure InitializeWorldObjects(aSURFile: TSURFile);
var
  i: Integer;
begin
  knifeFirstPickup := False;
  wireFirstPickup := False;
  bottleFirstPickup := False;
  if Length(worldObjects) > 0 then
    for i := 0 to High(worldObjects) do
      worldObjects[i].Free();
  selectedWorldObject := nil;

  SetLength(worldObjects, Length(aSURFile.Objects));
  for i := 0 to High(worldObjects) do
  begin
    case aSURFile.Objects[i].aType of
      SUR_OBJ_BUSH:     worldObjects[i] := TpdBush.Initialize(mainScene);
      SUR_OBJ_TWIG:     worldObjects[i] := TpdTwig.Initialize(mainScene);
      SUR_OBJ_FLOWER:   worldObjects[i] := TpdFlower.Initialize(mainScene);
      SUR_OBJ_MUSHROOM: worldObjects[i] := TpdMushroom.Initialize(mainScene);
      SUR_OBJ_OLDGRASS: worldObjects[i] := TpdOldGrass.Initialize(mainScene);
      SUR_OBJ_BACKPACK: worldObjects[i] := TpdBackpack.Initialize(mainScene);
      SUR_OBJ_BOTTLE:   worldObjects[i] := TpdBottle.Initialize(mainScene);
      SUR_OBJ_KNIFE:    worldObjects[i] := TpdKnife.Initialize(mainScene);
      SUR_OBJ_WIRE:     worldObjects[i] := TpdWire.Initialize(mainScene);
      SUR_OBJ_NEWGRASS: worldObjects[i] := TpdNewGrass.Initialize(mainScene);

      SUR_OBJ_IGNORE: Continue;
      else Continue;
    end;
    worldObjects[i].sprite.Position := aSurFile.Objects[i].aPos;
    worldObjects[i].sprite.Rotation := aSurFile.Objects[i].aRot;
  end;

  for i := 0 to High(worldObjects) do
    if not Assigned(worldObjects[i]) then
      DeleteWorldObject(worldObjects[i])
    else
      worldObjects[i].RecalcBB();
end;

procedure _SaveWorldObjects(var aSurFile: TSURFile);

  function ClassTypeToByte(aClassType: TClass): Byte;
  begin
    Result := SUR_OBJ_IGNORE;
    if aClassType = TpdBush then Exit(SUR_OBJ_BUSH);
    if aClassType = TpdTwig then Exit(SUR_OBJ_TWIG);
    if aClassType = TpdFlower then Exit(SUR_OBJ_FLOWER);
    if aClassType = TpdMushroom then Exit(SUR_OBJ_MUSHROOM);
    if aClassType = TpdOldGrass then Exit(SUR_OBJ_OLDGRASS);
    if aClassType = TpdKnife then Exit(SUR_OBJ_KNIFE);
    if aClassType = TpdBackpack then Exit(SUR_OBJ_BACKPACK);
    if aClassType = TpdBottle then Exit(SUR_OBJ_BOTTLE);
    if aClassType = TpdWire then Exit(SUR_OBJ_WIRE);
    if aClassType = TpdNewGrass then Exit(SUR_OBJ_NEWGRASS);
  end;

var
  i: Integer;
begin
  SetLength(aSurFile.Objects, Length(worldObjects));
  for i := 0 to High(worldObjects) do
    with aSurFile.Objects[i] do
    begin
      aType := ClassTypeToByte(worldObjects[i].ClassType);
      aPos := worldObjects[i].sprite.Position;
      aRot := worldObjects[i].sprite.Rotation;
    end;
end;

procedure DeinitializeWorldObjects();
var
  i: Integer;
begin
  if Length(worldObjects) > 0 then
    for i := 0 to High(worldObjects) do
      worldObjects[i].Free();
  selectedWorldObject := nil;
end;

function GetWorldObjectAtPosition(aPos: TdfVec2f): TpdWorldObject;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to High(worldObjects) do
    if worldObjects[i].IsInside(aPos) then
      Exit(worldObjects[i]);
end;

procedure UpdateWorldObjects(const dt: Double);
var
  i: Integer;
  nearFire: Boolean;
begin
  nearFire := False;
  for i := 0 to High(worldObjects) do
    if worldObjects[i] is TpdCampFire then
      with (worldObjects[i] as TpdCampFire) do
      begin
        if player.sprite.Position.Dist(sprite.Position) < restRadius then
          nearFire := True;
        
        timeToLife := timeToLife - dt;
        lifeSpr.Width := sprite.Width * (timeToLife / CAMPFIRE_TIME_TO_LIFE);
        if timeToLife < 0 then
        begin
          mainScene.UnregisterElement(lifeSpr);
          DeleteWorldObject(worldObjects[i]);
        end;
      end;
  player.NearCampFire := nearFire;
end;

function WorldObjectsOnMouseMove(X, Y: Integer; Shift: TglrMouseShiftState): Boolean;
var
  i: Integer;
begin
  Result := False;
  selectedWorldObject := nil;
  cursorText.Text := '';
  for i := 0 to High(worldObjects) do
  begin
    //TODO: ���������� �� ���������
    if worldObjects[i].IsInside(dfVec2f(X, Y) - mainScene.Origin) then
    begin
      //���������, �� ������ �� �����-�� ������ �� ����� � ���������� �� Z-��������
      if Assigned(selectedWorldObject) then
      begin
        if selectedWorldObject.sprite.Z < worldObjects[i].sprite.Z then
        //����� ����, ������ �������� ���
        begin
          selectedWorldObject := worldObjects[i];
          cursorText.Text := selectedWorldObject.HintText;
          Result := True;
        end;
      end
      else
      begin
        selectedWorldObject := worldObjects[i];
        cursorText.Text := selectedWorldObject.HintText;
        Result := True;
      end;
//      break;
    end;
  end;
end;

function WorldObjectsOnMouseDown(X, Y: Integer;  MouseButton: TglrMouseButton;
  Shift: TglrMouseShiftState): Boolean;
begin
  Result := False;
  if Assigned(selectedWorldObject) then
  begin
    Result := True;
    if MouseButton = mbLeft then
    begin
      player.GoAndCollect(selectedWorldObject);
      selectedWorldObject := nil;
    end;
  end;
end;

function AddNewWorldObject(aClass: TpdWorldObjectClass): TpdWorldObject;
var
  l: Integer;
begin
  l := Length(worldObjects);
  SetLength(worldObjects, l + 1);
  worldObjects[l] := aClass.Initialize(mainScene);
  Result := worldObjects[l];
end;

procedure DeleteWorldObject(aObject: TpdWorldObject);

  function GetIndex(): Integer;
  var
    i: Integer;
  begin
    Result := -1;
    for i := 0 to High(worldObjects) do
      if worldObjects[i] = aObject then
        Exit(i);
  end;

var
  index, len: Integer;

begin
  index := GetIndex();
  if index = -1 then
    Exit();

  if Assigned(worldObjects[index]) then
  begin
    mainScene.UnregisterElement(worldObjects[index].sprite);
    worldObjects[index].Free();
  end;
  len := Length(worldObjects);
  if index <> len - 1 then //�� ��������� �������
    //��������� ������ �� ����� ����������, ����� �� ������������� ������
    worldObjects[index] := worldObjects[len - 1];
  SetLength(worldObjects, len - 1);
end;

end.
