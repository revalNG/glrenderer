unit uGameScreen.GameOver;

interface

uses
  uGameScreen,
  glr;

const
  TIME_FADEIN = 1.8;
  TIME_FADEOUT = 0.5;

type
  TpdGameOver = class (TpdGameScreen)
  private
    FScene: Iglr2DScene;
    FGUIManager: IglrGUIManager;
    FScrMainMenu, FScrGame: TpdGameScreen;

    //������
    FBtnReplay, FBtnMenu: IglrGUITextButton;

    FGameOverText: IglrText;

    FBackground: IglrSprite;
    Ft: Single; //����� ��� �������� fadein / fadeout

    FEscapeDown: Boolean;

    procedure LoadButtons();
    procedure LoadBackground();
    procedure LoadTexts();
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

    procedure SetGameScreenLinks(aMainMenu, aGame: TpdGameScreen);
  end;

var
  gameOver: TpdGameOver;

implementation

uses
  SysUtils,
  glrMath, dfTweener,
  uGameScreen.Game, uGlobal;

const
  //������ ����, ������ �� ������
  BTN_RETRY_OFFSET_X = 0;
  BTN_RETRY_OFFSET_Y = 90;
  BTN_MENU_OFFSET_X  = 0;
  BTN_MENU_OFFSET_Y  = 160;

  TEXT_OFFSET_X = 0;
  TEXT_OFFSET_Y = 0;

procedure OnMouseClick(Sender: IglrGUIElement; X, Y: Integer; mb: TglrMouseButton;
  Shift: TglrMouseShiftState);
begin
  sound.PlaySample(sClick);
  with gameOver do
  begin
    if Sender = FBtnReplay as IglrGUIElement then
    begin
      FScrGame.Status := gssNone;
      FScrGame.Unload();
      OnNotify(FScrGame, naSwitchTo);
    end
    else if Sender = FBtnMenu as IglrGUIElement then
    begin
      FScrGame.Status := gssFadeOut;
      OnNotify(FScrMainMenu, naSwitchTo);
    end;
  end;
end;

procedure OnMouseOver(Sender: IglrGUIElement; X, Y: Integer; Button: TglrMouseButton;
  Shift: TglrMouseShiftState);
begin

end;

procedure OnMouseOut(Sender: IglrGUIElement; X, Y: Integer; Button: TglrMouseButton;
  Shift: TglrMouseShiftState);
begin

end;

{ TpdPauseMenu }

constructor TpdGameOver.Create;
begin
  inherited;
  FGUIManager := R.GUIManager;
  FScene := Factory.New2DScene();

  LoadBackground();
  LoadTexts();
  LoadButtons();
end;

destructor TpdGameOver.Destroy;
begin
  Unload();

  FScene.RootNode.RemoveAllChilds();
  FScene := nil;
  inherited;
end;

procedure TpdGameOver.FadeIn(deltaTime: Double);
begin
  if Ft <= 0 then
    inherited
  else
  begin
    Ft := Ft - deltaTime;
    FBackground.Material.PDiffuse.w := 0.75 * (1 - Ft / TIME_FADEIN);
  end;
end;

procedure TpdGameOver.FadeInComplete;
begin
  Status := gssReady;
end;

procedure TpdGameOver.FadeOut(deltaTime: Double);
begin
  if Ft <= 0 then
    inherited
  else
  begin
    Ft := Ft - deltaTime;
    FBackground.Material.PDiffuse.w := 0.75 * Ft / TIME_FADEOUT;
  end;
end;

procedure TpdGameOver.FadeOutComplete;
begin
  Status := gssNone;
end;

procedure TpdGameOver.LoadBackground;
begin
  FBackground := Factory.NewHudSprite();

  with FBackground do
  begin
    Material.Diffuse := dfVec4f(0.0, 0, 0, 0.0);
    Material.Texture.BlendingMode := tbmTransparency;
    PivotPoint := ppTopLeft;
    Width := R.WindowWidth;
    Height := R.WindowHeight;
    Position := dfVec3f(0, 0, Z_INGAMEMENU);
  end;

  FScene.RootNode.AddChild(FBackground);
end;

procedure TpdGameOver.LoadButtons();
begin
  FBtnReplay := Factory.NewGUITextButton();
  FBtnMenu := Factory.NewGUITextButton();

  with FBtnReplay do
  begin
    PivotPoint := ppCenter;
    Position := dfVec3f(R.WindowWidth div 2 + BTN_RETRY_OFFSET_X,
                        R.WindowHeight div 2 +  BTN_RETRY_OFFSET_Y,
                        Z_INGAMEMENU + 2);
    with TextObject do
    begin
      Font := fontCooper;
      Text := '��� �����!';
      PivotPoint := ppTopLeft;
      Position2D := dfVec2f(-150, -15);
      Material.Diffuse := colorWhite;
    end;

    TextureNormal := atlasMain.LoadTexture(REPLAY_NORMAL_TEXTURE);
    TextureOver := atlasMain.LoadTexture(REPLAY_OVER_TEXTURE);
    TextureClick := atlasMain.LoadTexture(REPLAY_CLICK_TEXTURE);

    UpdateTexCoords();
    SetSizeToTextureSize();
  end;

  with FBtnMenu do
  begin
    PivotPoint := ppCenter;
    Position := dfVec3f(R.WindowWidth div 2 + BTN_MENU_OFFSET_X,
                        R.WindowHeight div 2 + BTN_MENU_OFFSET_Y,
                        Z_INGAMEMENU + 2);
    with TextObject do
    begin
      Font := fontCooper;
      Text := '� ����...';
      PivotPoint := ppTopLeft;
      Position2D := dfVec2f(-150, -15);
      Material.Diffuse := colorWhite;
    end;

    TextureNormal := atlasMain.LoadTexture(MENU_NORMAL_TEXTURE);
    TextureOver := atlasMain.LoadTexture(MENU_OVER_TEXTURE);
    TextureClick := atlasMain.LoadTexture(MENU_CLICK_TEXTURE);

    UpdateTexCoords();
    SetSizeToTextureSize();
  end;

  FBtnReplay.OnMouseClick := OnMouseClick;
  FBtnMenu.OnMouseClick := OnMouseClick;

  FScene.RootNode.AddChild(FBtnReplay);
  FScene.RootNode.AddChild(FBtnMenu);
end;

procedure TpdGameOver.LoadTexts;
begin
  FGameOverText := Factory.NewText();

  with FGameOverText do
  begin
    Font := fontCooper;
    PivotPoint := ppCenter;
    Position := dfVec3f(R.WindowWidth div 2 + TEXT_OFFSET_X, R.WindowHeight div 2 + TEXT_OFFSET_Y, Z_INGAMEMENU + 2);
  end;

  FScene.RootNode.AddChild(FGameOverText);
end;

procedure TpdGameOver.Load;
begin
  inherited;
  R.RegisterScene(FScene);

  if (FScrGame as TpdGame).GameMode = gmSingle then
  begin
    if player.IsDead and player2.IsDead then
      FGameOverText.Text := '����������! �������� �� ���� ������������!'
    else if player.IsDead then
      FGameOverText.Text := '���, ��� �������� �� �����...'#13#10'���������� ����� ��� �������� ��������� � ���� �����'
    else if player2.IsDead then
      FGameOverText.Text := '�� �� �������� �� ���������� ������ �����!'#13#10'��������� ��� �������� ��������� � ���� �����'
  end
  else
  begin
    if player.IsDead and player2.IsDead then
      FGameOverText.Text := '����������! �������� �� ���� ������������!'
    else if player.IsDead then
      FGameOverText.Text := '���, ������ 1 �������� �� �����...'#13#10'����� 2 �������!'
    else if player2.IsDead then
      FGameOverText.Text := '���, ������ 2 �������� �� �����...'#13#10'����� 1 �������!'
  end;
end;

procedure TpdGameOver.SetGameScreenLinks(aMainMenu, aGame: TpdGameScreen);
begin
  FScrMainMenu := aMainMenu;
  FScrGame := aGame;
end;

procedure TpdGameOver.SetStatus(const aStatus: TpdGameScreenStatus);
begin
  inherited;
  case aStatus of
    gssNone: Exit;

    gssReady: Exit;

    gssFadeIn:
    begin
      Ft := TIME_FADEIN;

      FGUIManager.RegisterElement(FBtnReplay);
      FGUIManager.RegisterElement(FBtnMenu);

      Tweener.AddTweenPSingle(@FGameOverText.Material.PDiffuse.w,
        tsSimple, 0.0, 1.0, 1.0, 0.3);
      Tweener.AddTweenPSingle(@FBtnReplay.PPosition.x, tsExpoEaseIn,
        -140, R.WindowWidth div 2 + BTN_RETRY_OFFSET_X, 1.5, 1.0);
      Tweener.AddTweenPSingle(@FBtnMenu.PPosition.x, tsExpoEaseIn,
        R.WindowWidth + 190, R.WindowWidth div 2 + BTN_MENU_OFFSET_X, 1.5, 1.0);
    end;

    gssFadeInComplete: FadeInComplete();

    gssFadeOut:
    begin
      Ft := TIME_FADEOUT;
      FGUIManager.UnregisterElement(FBtnReplay);
      FGUIManager.UnregisterElement(FBtnMenu);

      Tweener.AddTweenPSingle(@FGameOverText.Material.PDiffuse.w,
        tsSimple, 1.0, 0.0, 0.5, 0.0);
      Tweener.AddTweenPSingle(@FBtnReplay.PPosition.x, tsExpoEaseIn,
        R.WindowWidth div 2 + BTN_RETRY_OFFSET_X, -100, 1.5, 0.0);
      Tweener.AddTweenPSingle(@FBtnMenu.PPosition.x, tsExpoEaseIn,
        R.WindowWidth div 2 + BTN_MENU_OFFSET_X, R.WindowWidth + 100, 1.5, 0.0);
    end;

    gssFadeOutComplete: FadeOutComplete();
  end;
end;

procedure TpdGameOver.Unload;
begin
  inherited;
  R.UnregisterScene(FScene);
end;

procedure TpdGameOver.Update(deltaTime: Double);
begin
  inherited;
  case FStatus of
    gssNone           : Exit;
    gssFadeIn         : FadeIn(deltaTime);
    gssFadeInComplete : Exit;
    gssFadeOut        : FadeOut(deltaTime);
    gssFadeOutComplete: Exit;

    gssReady:
    begin
      if R.Input.IsKeyPressed(27) then
        OnMouseClick(FBtnMenu as IglrGUIElement, 0, 0, mbLeft, []);
    end;
  end;
end;

end.
