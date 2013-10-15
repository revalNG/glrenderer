unit uGameScreen.Game;

interface

uses
  glr, glrUtils, glrMath,
  uGameScreen,
  uGlobal, uWorldObjects;

const
  TIME_FADEIN  = 1.5;
  TIME_FADEOUT = 0.2;

  FILE_SUR = RES_FOLDER + 'level1.sur';

  TIME_SECONDS_IN_MINUTE = 1;
  TIME_MINUTES_IN_HOUR = 60;

type
  TpdGame = class (TpdGameScreen)
  private
    FMainScene, FHUDScene: Iglr2DScene;
    FScrPauseMenu, FScrGameOver: TpdGameScreen;
//    FGoButton: IdfGUIButton;

    //hud elements
    {$IFDEF DEBUG}
    //debug
    FFPSCounter: TglrFPSCounter;
    FDebug: TglrDebugInfo;
    d_playerpos, d_world_objects: Integer;
    d_health, d_hunger, d_thirst, d_fatigue, d_mind: Integer;
    {$ENDIF}

    FPause: Boolean;

    //����������� �������
    FTime: Double;
    FTimeRounded: Integer;
    FTimeHours, FTimeMinutes: Integer;
    FTimeTmp1, FTimeTmp2: String;
    FTimerIcon: IglrSprite;
    FTimeText: IglrText;

    Ft: Single; //����� ��� ������� �������� fadein/fadeout

    FFakeBackground: IglrSprite;

    //��� ��� ������ ���������
    FEditorMode: Boolean;
    //������� ����
    FEditorText, FEditorHintText: IglrText;
    FDragObject: TpdWorldObject;

    //�� ���� � ����� ��������� ���� �����
    FDeathParam: TpdParam;

    procedure OnPlayerDie(aReason: TpdParam);

    procedure LoadFromFile(const aFileName: String);
    //--������� ��� ���������
    {$IFDEF DEBUG}
    procedure _SaveToFile(const aFileName: String);
    procedure _AddNewBush(aPos: TdfVec2f);
    procedure _AddNewTwig(aPos: TdfVec2f);
    procedure _AddNewFlower(aPos: TdfVec2f);
    procedure _AddNewMushroom(aPos: TdfVec2f);
    procedure _AddNewOldGrass(aPos: TdfVec2f);
    procedure _AddNewGrass(aPos: TdfVec2f);
    procedure _AddNewWire(aPos: TdfVec2f);
    procedure _AddNewBottle(aPos: TdfVec2f);
    procedure _AddNewKnife(aPos: TdfVec2f);
    procedure _AddNewBackpack(aPos: TdfVec2f);
    {$ENDIF}
    //--

    procedure LoadHUD();
    procedure FreeHUD();
    procedure DoUpdate(const dt: Double);
    procedure UpdateTime(const dt: Double);

    function GetTimeText(): WideString;
  protected
    procedure FadeIn(deltaTime: Double); override;
    procedure FadeOut(deltaTime: Double); override;

    procedure SetStatus(const aStatus: TpdGameScreenStatus); override;
    procedure FadeInComplete();
    procedure FadeOutComplete();
  public
    constructor Create(); override;
    destructor Destroy; override;

    procedure Load(); override;
    procedure Unload(); override;

    procedure Update(deltaTime: Double); override;

    procedure SetGameScreenLinks(aToPauseMenu, aGameOver: TpdGameScreen);

    procedure OnMouseMove(X, Y: Integer; Shift: TglrMouseShiftState); override;
    procedure OnMouseDown(X, Y: Integer; MouseButton: TglrMouseButton; Shift: TglrMouseShiftState); override;
    procedure OnMouseUp(X, Y: Integer; MouseButton: TglrMouseButton; Shift: TglrMouseShiftState); override;

    //���������, ������� ��������� screen GameOver:
    property SurviveTime: Double read FTime; // ����� � �������� ��� ������
    property SurviveTimeText: WideString read GetTimeText; //����� � ������� �����������
    property DeathReason: TpdParam read FDeathParam;
  end;

var
  game: TpdGame;

implementation

uses
  Windows, SysUtils,
  dfTweener, ogl,
  uPlayer, uWater, uInventory, uCraft, uLevel_SaveLoad;

{ TpdArenaGame }

//procedure OnMouseClick(Sender: IdfGUIElement; X, Y: Integer; mb: TdfMouseButton;
//  Shift: TdfMouseShiftState);
//begin
//  if Sender = (game.FGoButton as IdfGUIElement) then
//  begin
//    game.Status := gssReady;
//    game.FGoButton.Visible := False;
//  end
//end;

constructor TpdGame.Create;
begin
  inherited;

  FMainScene := Factory.New2DScene();
  FHUDScene := Factory.New2DScene();

  mainScene := FMainScene;
  hudScene := FHUDScene;
end;

destructor TpdGame.Destroy;
begin
  Unload();
  FreeHUD();
  DeinitializeInventory();
  DeinitializeWater();
  DeinitializeWorldObjects();
  DeinitializePlayer();
  DeinitializeCraft();

  FMainScene.UnregisterElements();
  FHudScene.UnregisterElements();

  FMainScene := nil;
  FHUDscene := nil;
  inherited;
end;

procedure TpdGame.DoUpdate(const dt: Double);
begin
  if R.Input.IsKeyDown(VK_ESCAPE) then
  begin
    cursorText.Text := '';
    OnNotify(FScrPauseMenu, naShowModal);
  end;

  {$IFDEF DEBUG}
  if R.Input.IsKeyPressed(68) then
  begin
    FDebug.FText.Visible := not FDebug.FText.Visible;
    FFPSCounter.TextObject.Visible := not FFPSCounter.TextObject.Visible;
  end;

  FFpsCounter.Update(dt);

  if R.Input.IsKeyPressed(69) then
  begin
    FEditorMode := not FEditorMode;
    FEditorText.Visible := FEditorMode;
    FEditorHintText.Visible := FEditorMode;
    if FEditorMode then
      FEditorText.Text := '����� ���������';
  end;


  if R.Input.IsKeyDown(Ord('G')) then
    OnPlayerDie(pMind);

  if FEditorMode then
  begin
    if R.Input.IsKeyPressed(83) then
    begin
      _SaveToFile(FILE_SUR);
      FEditorText.Text := '����� ���������' + #13#10 + '"' + FILE_SUR + '" ��������';
    end;

    if Assigned(FDragObject) then
    begin
      FDragObject.sprite.Position := mousePos - FMainScene.Origin;
      if R.Input.IsKeyDown(Ord('A')) then
        FDragObject.sprite.Rotation := FDragObject.sprite.Rotation - dt * 30
      else if R.Input.IsKeyDown(Ord('D')) then
        FDragObject.sprite.Rotation := FDragObject.sprite.Rotation + dt * 30;
    end;

    //���������� "������"
    if R.Input.IsKeyDown(VK_LEFT) then
      FMainScene.Origin := FMainScene.Origin + dfVec2f(300 * dt, 0)
    else if R.Input.IsKeyDown(VK_RIGHT) then
      FMainScene.Origin := FMainScene.Origin + dfVec2f(-300 * dt, 0);
    if R.Input.IsKeyDown(VK_UP) then
      FMainScene.Origin := FMainScene.Origin + dfVec2f(0, 300 * dt)
    else if R.Input.IsKeyDown(VK_DOWN) then
      FMainScene.Origin := FMainScene.Origin + dfVec2f(0, -300 * dt);

    //������� ��������
    if R.Input.IsKeyPressed(49) then
      _AddNewBush(mousePos - FMainScene.Origin);
    if R.Input.IsKeyPressed(50) then
      _AddNewTwig(mousePos - FMainScene.Origin);
    if R.Input.IsKeyPressed(51) then
      _AddNewFlower(mousePos - FMainScene.Origin);
    if R.Input.IsKeyPressed(52) then
      _AddNewMushroom(mousePos - FMainScene.Origin);
    if R.Input.IsKeyPressed(53) then
      _AddNewOldGrass(mousePos - FMainScene.Origin);
    if R.Input.IsKeyPressed(54) then
      _AddNewGrass(mousePos - FMainScene.Origin);
    if R.Input.IsKeyPressed(55) then
      _AddNewWire(mousePos - FMainScene.Origin);
    if R.Input.IsKeyPressed(56) then
      _AddNewBottle(mousePos - FMainScene.Origin);
    if R.Input.IsKeyPressed(57) then
      _AddNewKnife(mousePos - FMainScene.Origin);
    if R.Input.IsKeyPressed(48) then
      _AddNewBackpack(mousePos - FMainScene.Origin);
  end
  else
  {$ENDIF}
  begin
    FMainScene.Origin := dfVec2f(R.WindowWidth div 2, R.WindowHeight div 2) - player.sprite.Position;

    //--update all
    UpdatePlayer(dt);
    UpdateWorldObjects(dt);
    UpdateWater(dt);
    UpdateInventory(dt);
    UpdateCraft(dt);
    UpdateTime(dt);


    //��������/���������� ���������, ������ ������ � ������
    if R.Input.IsKeyPressed(73) or R.Input.IsKeyPressed(90) then
      inventory.Visible := not inventory.Visible;
    if R.Input.IsKeyPressed(67) then
      craftPanel.Visible := not craftPanel.Visible;
//    if R.Input.IsKeyPressed(65, @FAPressed) or R.Input.IsKeyPressed(88, @FXPressed) then
//      advController.Visible := not advController.Visible;


    //--debug
    {$IFDEF DEBUG}
    FDebug.UpdateParam(d_playerpos, player.sprite.Position);
    FDebug.UpdateParam(d_world_objects, Length(worldObjects));
    FDebug.UpdateParam(d_health, Round(player.params[pHealth]));
    FDebug.UpdateParam(d_hunger, Round(player.params[pHunger]));
    FDebug.UpdateParam(d_thirst, Round(player.params[pThirst]));
    FDebug.UpdateParam(d_fatigue, Round(player.params[pFatigue]));
    FDebug.UpdateParam(d_mind, Round(player.params[pMind]));
    {$ENDIF}
  end;
end;

procedure TpdGame.FadeIn(deltaTime: Double);
begin
  if Ft <= 0 then
    inherited
  else
  begin
    Ft := Ft - deltaTime;
    FFakeBackground.Material.PDiffuse.w := Ft / TIME_FADEIN;
  end;
end;

procedure TpdGame.FadeInComplete;
begin
  //Status := gssPaused;
  FFakeBackground.Visible := False;
  Status := gssReady;
end;

procedure TpdGame.FadeOut(deltaTime: Double);
begin
  if Ft <= 0 then
    inherited
  else
  begin
    Ft := Ft - deltaTime;
    FFakeBackground.Material.PDiffuse.w := 1 - Ft / TIME_FADEOUT;
  end;
end;

procedure TpdGame.FadeOutComplete;
begin
  Status := gssNone;
  Unload();
end;

procedure TpdGame.FreeHUD;
begin
  {$IFDEF DEBUG}
  FDebug.Free();
  FFPSCounter.Free();
  {$ENDIF}
end;

function TpdGame.GetTimeText: WideString;
begin
  Result := FTimeText.Text;
end;

procedure TpdGame.Load;
begin
  inherited;
  if FLoaded then
    Exit();

  FMainScene.UnregisterElements();
  FMainScene.Origin := dfVec2f(0, 0);
  FHudScene.UnregisterElements();

  //������ ���� ���� ������ (������ �������� ����������)
  gl.ClearColor(0.40, 0.65, 0.40, 1.0);

  LoadHUD();
  LoadFromFile(FILE_SUR); //����� ���������� ��� �������������
  FTime := 0;

  FFakeBackground := Factory.NewHudSprite();
  FFakeBackground.Position := dfVec2f(0, 0);
  FFakeBackground.Z := 100;
  FFakeBackground.Material.Diffuse := dfVec4f(1, 1, 1, 1);
  FFakeBackground.Material.Texture.BlendingMode := tbmTransparency;
  FFakeBackground.Width := R.WindowWidth;
  FFakeBackground.Height := R.WindowHeight;
  FHUDScene.RegisterElement(FFakeBackground);

  R.RegisterScene(FMainScene);
  R.RegisterScene(FHUDScene);

  FLoaded := True;
end;

procedure TpdGame.LoadFromFile(const aFileName: String);
var
  aSurFile: TSURFile;
begin
  aSurFile := TSURFile.LoadFromFile(aFileName);

  InitializeWorldObjects(aSurFile);
  InitializeWater(aSurFile);
  InitializePlayer();
  player.OnDie := OnPlayerDie;
  InitializeInventory();
  InitializeCraft();
  //��������� ��������� � �����-�������, ����� ��������� �����
  //����������� ��������� � ��������� ��� ��������� ����������� ������
  inventory.onItemsChanged := craftPanel.OnInventoryChanged;
  craftPanel.OnInventoryChanged();
  aSurFile.Free();
end;

procedure TpdGame.LoadHUD;
const
  TIMER_TEXTURE = 'hud_timer.png';
begin
  {$IFDEF DEBUG}
  if Assigned(FFPSCounter) then
    FFPSCounter.Free();
  FFPSCounter := TglrFPSCounter.Create(FHUDScene, 'FPS:', 1, nil);
  FFPSCounter.TextObject.Material.Diffuse := dfVec4f(0, 0, 0, 1);
  FFPSCounter.TextObject.Visible := False;

  if Assigned(FDebug) then
    FDebug.Free();
  FDebug := TglrDebugInfo.Create(FHUDScene);
  FDebug.FText.Material.Diffuse := dfVec4f(0, 0, 0, 1);
  d_playerpos := FDebug.AddNewString('������� ������');
  d_world_objects := FDebug.AddNewString('�������� �������� ����');
  d_health := FDebug.AddNewString('��������');
  d_hunger := FDebug.AddNewString('�����');
  d_thirst := FDebug.AddNewString('�����');
  d_fatigue := FDebug.AddNewString('����');
  d_mind := FDebug.AddNewString('�����');
  FDebug.FText.Visible := False;
  FDebug.FText.PPosition.y := 20;

  FEditorText := Factory.NewText();
  FEditorText.Font := FDebug.FText.Font;
  FEditorText.Position := dfVec2f(R.WindowWidth div 2 - 100, 0);
  FEditorText.Material.Diffuse := dfVec4f(0, 0, 0, 1);
      FEditorText.Visible := False;
  FHUDScene.RegisterElement(FEditorText);

  FEditorHintText := Factory.NewText();
  FEditorHintText.Font := FDebug.FText.Font;
  FEditorHintText.Position := dfVec2f(R.WindowWidth div 2 - 300, 40);
  FEditorHintText.Material.Diffuse := dfVec4f(0, 0, 0, 1);
  FEditorHintText.Text := '��� - ����� � ����������� �������'#13#10 +
     '��� - ������� ������'#13#10 +
     '�����, ������ - ������� ��������� ������'#13#10 +
     '�������: ' + '1 - ����, 2 - �����, 3 - �������, 4 - ����,'#13#10 +
     '5 - ����� �����, 6 - ������� �����, '#13#10'7 - ����� �����, 8 - �����(1),'#13#10'9 - ��� (1), 0 - ������ (1)';
    FEditorHintText.Visible := False;
  FHUDScene.RegisterElement(FEditorHintText);
  {$ENDIF}

//  FGoButton := dfCreateGUIButton();
//  with FGoButton do
//  begin
//    PivotPoint := ppCenter;
//    Position := dfVec2f(512, 380);
//    Z := Z_MAINMENU_BUTTONS;
//    TextureNormal := atlasMenu.LoadTexture(PLAY_NORMAL_TEXTURE);
//    TextureOver := atlasMenu.LoadTexture(PLAY_OVER_TEXTURE);
//    TextureClick := atlasMenu.LoadTexture(PLAY_CLICK_TEXTURE);
//
//    UpdateTexCoords();
//    SetSizeToTextureSize();
//    Visible := True;
//  end;
//  FGoButton.OnMouseClick := OnMouseClick;

  FTimerIcon := Factory.NewHudSprite();
  FTimerIcon.Z := Z_HUD;
  FTimerIcon.PivotPoint := ppTopLeft;
  FTimerIcon.Position := dfVec2f(10, 10);
  FTimerIcon.Material.Texture := atlasGame.LoadTexture(TIMER_TEXTURE);
  FTimerIcon.Material.Texture.BlendingMode := tbmTransparency;
  FTimerIcon.UpdateTexCoords();
  FTimerIcon.SetSizeToTextureSize();
  FTimerIcon.Material.Diffuse := dfVec4f(1, 1, 1, 0.8);

  FTimeText := Factory.NewText();
  FTimeText.Font := fontCooper;
  FTimeText.Z := Z_HUD;
  FTimeText.Position := FTimerIcon.Position + dfVec2f(40, 5);
  FTimeText.Text := '00:00';
  FTimeText.Material.Diffuse := dfVec4f(1, 1, 1, 1);

  FHUDScene.RegisterElement(FTimerIcon);
  FHUDScene.RegisterElement(FTimeText);
//  FHUDScene.RegisterElement(FGoButton);
//  R.GUIManager.RegisterElement(FGoButton);
end;

{$IFDEF DEBUG}
procedure TpdGame._AddNewBackpack(aPos: TdfVec2f);
begin
  with uWorldObjects.AddNewWorldObject(TpdBackpack) do
  begin
    sprite.Position := aPos;
    RecalcBB();
  end;

end;

procedure TpdGame._AddNewBottle(aPos: TdfVec2f);
begin
  with uWorldObjects.AddNewWorldObject(TpdBottle) do
  begin
    sprite.Position := aPos;
    RecalcBB();
  end;
end;

procedure TpdGame._AddNewBush(aPos: TdfVec2f);
begin
  with uWorldObjects.AddNewWorldObject(TpdBush) do
  begin
    sprite.Position := aPos;
    RecalcBB();
  end;
end;

procedure TpdGame._AddNewFlower(aPos: TdfVec2f);
begin
  with uWorldObjects.AddNewWorldObject(TpdFlower) do
  begin
    sprite.Position := aPos;
    RecalcBB();
  end;
end;

procedure TpdGame._AddNewGrass(aPos: TdfVec2f);
begin
  with uWorldObjects.AddNewWorldObject(TpdNewGrass) do
  begin
    sprite.Position := aPos;
    RecalcBB();
  end;
end;

procedure TpdGame._AddNewKnife(aPos: TdfVec2f);
begin
  with uWorldObjects.AddNewWorldObject(TpdKnife) do
  begin
    sprite.Position := aPos;
    RecalcBB();
  end;
end;

procedure TpdGame._AddNewMushroom(aPos: TdfVec2f);
begin
  with uWorldObjects.AddNewWorldObject(TpdMushroom) do
  begin
    sprite.Position := aPos;
    RecalcBB();
  end;
end;

procedure TpdGame._AddNewOldGrass(aPos: TdfVec2f);
begin
  with uWorldObjects.AddNewWorldObject(TpdOldGrass) do
  begin
    sprite.Position := aPos;
    RecalcBB();
  end;
end;

procedure TpdGame._AddNewTwig(aPos: TdfVec2f);
begin
  with uWorldObjects.AddNewWorldObject(TpdTwig) do
  begin
    sprite.Position := aPos;
    RecalcBB();
  end;
end;

procedure TpdGame._AddNewWire(aPos: TdfVec2f);
begin
  with uWorldObjects.AddNewWorldObject(TpdWire) do
  begin
    sprite.Position := aPos;
    RecalcBB();
  end;
end;

procedure TpdGame._SaveToFile(const aFileName: String);
var
  aSurFile: TSURFile;
begin
  aSurFile := TSURFile.Create();
  _SaveWorldObjects(aSurFile);
  _SaveWater(aSurFile);
  aSurFile.SaveToFile(aFileName);
  aSurFile.Free;
end;

{$ENDIF}

procedure TpdGame.SetGameScreenLinks(aToPauseMenu, aGameOver: TpdGameScreen);
begin
  FScrPauseMenu := aToPauseMenu;
  FScrGameOver := aGameOver;
end;

procedure TpdGame.SetStatus(const aStatus: TpdGameScreenStatus);
begin
  inherited;
    inherited;
  case aStatus of
    gssNone: Exit;

    gssReady: Exit;

    gssFadeIn:
    begin
      FFakeBackground.Visible := True;
      sound.PlayMusic(musicIngame);
      Ft := TIME_FADEIN;
    end;

    gssFadeInComplete: FadeInComplete();

    gssFadeOut:
    begin
      FFakeBackground.Visible := True;
      Ft := TIME_FADEOUT;
    end;

    gssFadeOutComplete: FadeOutComplete();
  end;
end;

procedure TpdGame.Unload;
begin
  inherited;
  if not FLoaded then
    Exit();

  R.UnregisterScene(FMainScene);
  R.UnregisterScene(FHUDScene);

  FLoaded := False;
end;

procedure TpdGame.Update(deltaTime: Double);
begin
  inherited;
  case FStatus of
    gssFadeIn  : FadeIn(deltaTime);
    gssFadeOut : FadeOut(deltaTime);
    gssReady   : DoUpdate(deltaTime);
  end;
end;

procedure TpdGame.UpdateTime(const dt: Double);
begin
  //��������� ����� � ��������� ������ ���� "12:34"
  FTime := FTime + dt;
  FTimeRounded := Round(FTime);
  FTimeMinutes := FTimeRounded div TIME_SECONDS_IN_MINUTE;
  FTimeHours := FTimeMinutes div TIME_MINUTES_IN_HOUR;
  FTimeMinutes := FTimeMinutes mod TIME_MINUTES_IN_HOUR;
  if FTimeMinutes < 10 then
    FTimeTmp1 := '0' + IntToStr(FTimeMinutes)
  else
    FTimeTmp1 := IntToStr(FTimeMinutes);
  if FTimeHours < 10 then
    FTimeTmp2 := '0' + IntToStr(FTimeHours)
  else
    FTimeTmp2 := IntToStr(FTimeHours);
  FTimeText.Text := FTimeTmp2 + ':' + FTimeTmp1;
end;

procedure TpdGame.OnMouseMove(X, Y: Integer; Shift: TglrMouseShiftState);
begin
  if status <> gssReady then
    Exit();

  if InventoryOnMouseMove(X, Y, Shift) then Exit();
  if CraftOnMouseMove(X, Y, Shift) then Exit();
  if WorldObjectsOnMouseMove(X, Y, Shift) then Exit();
  if WaterObjectsOnMouseMove(X, Y, Shift) then Exit();
  if PlayerOnMouseMove(X, Y, Shift) then Exit();
end;

procedure TpdGame.OnMouseDown(X, Y: Integer; MouseButton: TglrMouseButton;
  Shift: TglrMouseShiftState);
begin
  if status <> gssReady then
    Exit();

  {$IFDEF DEBUG}
  if FEditorMode then
  begin
    //����� ���������
    if MouseButton = mbLeft then
    begin
      FDragObject := GetWorldObjectAtPosition(dfVec2f(X, Y) - FMainScene.Origin);
      if Assigned(FDragObject) then
        FEditorText.Text := '����� ���������' + #13#10 + '������ ��������� ������'
      else
      begin
        FEditorText.Text := '����� ���������' + #13#10 + '��� �������';
      end;
    end
    else if MouseButton = mbRight then
    begin
      FDragObject := GetWorldObjectAtPosition(dfVec2f(X, Y) - FMainScene.Origin);
      if Assigned(FDragObject) then
      begin
        DeleteWorldObject(FDragObject);
        FDragObject := nil;
      end;
    end;
  end
  else
  {$ENDIF}
  begin
    try
      if InventoryOnMouseDown(X, Y, MouseButton, Shift) then Exit();
      if CraftOnMouseDown(X, Y, MouseButton, Shift) then Exit();
//      if AdvControllerOnMouseDown(X, Y, MouseButton, Shift) then Exit();
      if WorldObjectsOnMouseDown(X, Y, MouseButton, Shift) then Exit();
      if WaterObjectsOnMouseDown(X, Y, MouseButton, Shift) then Exit();
      if PlayerOnMouseDown(X, Y, MouseButton, Shift) then Exit();
    finally

    end;
  end;
end;

procedure TpdGame.OnMouseUp(X, Y: Integer; MouseButton: TglrMouseButton;
  Shift: TglrMouseShiftState);
begin
  if status <> gssReady then
    Exit();

  {$IFDEF DEBUG}
  if FEditorMode then
  begin
    //����� ���������
    if Assigned(FDragObject) then
    begin
      FDragObject.RecalcBB();
      FDragObject := nil;
    end;
    FEditorText.Text := '����� ���������';
  end
  else
  {$ENDIF}
  begin
    if InventoryOnMouseUp(X, Y, MouseButton, Shift) then Exit();
    if PlayerOnMouseUp(X, Y, MouseButton, Shift) then Exit();
    //�� ������������
//    if CraftOnMouseUp(X, Y, MouseButton, Shift) then Exit();
  end;
end;

procedure TpdGame.OnPlayerDie(aReason: TpdParam);
begin
  FDeathParam := aReason;
  cursorText.Text := '';
  OnNotify(FScrGameOver, naShowModal);
end;

end.
