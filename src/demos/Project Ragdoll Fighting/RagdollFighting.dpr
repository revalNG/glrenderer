{
  TODO:

    AI
      ��������� ��������� ���� � ������ ��� ��������
    + ��������� � ������ �������


  - ������ ����� ��� ������, �������� ������
  + ��������� ����� ����� ����� ������ ��� �����

  + ������� ����
    + �������� ����� - ��������� ����������
    - �������� ����� - ������� � �����, ����� �������� ���������
    + �������� ����� igdc

  + ������������ ��� �����
  + ���� ��� �����

  + Punch2 - �������� ���������

  + ��������� ��������� - ���� ������, ���� ����������, ����� ������ �����

  + �������� � �������
      + �������� � ������
      + ������� � ���
      + ���������� ��� ������

    ���������
      + ����� "����"
      + ���������� ��� ������
      + ������� ���������� �� �����
      - ��������� ��� ��������� ������ (?)
      + �� 30% ���� ����������� ��������� ���������, ��������:
          ����� �� ��� �������
          ������ �������� � ���������� ����������
        + "��������" ���� � ����� ���������� �� n ������ = 30%
        ����������, ��� ����� ������� ����
        ����������, ��� ���������� ������� ���� (��� ������� ����������)


  + ������
    + ������ IsDead
    + ������ �� �����

  + ���� "��������"
    + ������� You win / You lose
    + ������ replay, menu
    + ������� �� �������� � ��������


  + ���� �����
    + ������ continue, menu

  + �����������
    + ��������� ��� �����/�����
    + �������� �����������
    + ������� �������� ��������
    + �������� ������� ��� �����

  + BUG #1: ����� ��������� ����������� ����� ������ ����������
  + BUG #2: ��� ������ ����� �����, � ������ ����� �� �����������
    BUG #3: �� ������������ ���������� ����������
}


program RagdollFighting;
uses
  ShareMem,
  Windows,
  glr in '..\..\headers\glr.pas',
  glrUtils in '..\..\headers\glrUtils.pas',
  uBox2DImport in '..\..\headers\box2d\uBox2DImport.pas',
  UPhysics2D in '..\..\headers\box2d\UPhysics2D.pas',
  UPhysics2DTypes in '..\..\headers\box2d\UPhysics2DTypes.pas',
  uCharacterController in 'uCharacterController.pas',
  uGUI in 'uGUI.pas',
  uCharacter in 'uCharacter.pas',
  uGlobal in 'uGlobal.pas',
  uGameScreen.Game in 'gamescreens\uGameScreen.Game.pas',
  uGameScreen.GameOver in 'gamescreens\uGameScreen.GameOver.pas',
  uGameScreen.MainMenu in 'gamescreens\uGameScreen.MainMenu.pas',
  uGameScreen in 'gamescreens\uGameScreen.pas',
  uGameScreen.PauseMenu in 'gamescreens\uGameScreen.PauseMenu.pas',
  uGameScreenManager in 'gamescreens\uGameScreenManager.pas',
  uSound in 'uSound.pas',
  bass in '..\..\headers\bass.pas',
  uAccum in 'uAccum.pas',
  uPopup in 'uPopup.pas',
  uSettings_SaveLoad in 'uSettings_SaveLoad.pas',
  uParticles in 'uParticles.pas',
  dfTweener in '..\..\headers\dfTweener.pas',
  glrMath in '..\..\headers\glrMath.pas',
  ogl in '..\..\headers\ogl.pas';

var
  gsManager: TpdGSManager;
  bigPause: Boolean;

  procedure OnUpdate(const dt: Double);
  begin
    if GSManager.IsQuitMessageReceived then
      R.Stop();

    if R.Input.IsKeyPressed(VK_PAUSE) then
      bigPause := not bigPause;

    if not bigPause then
    begin
      gsManager.Update(dt);
      Tweener.Update(dt);
    end;
  end;

  procedure OnMouseMove(X, Y: Integer; Shift: TglrMouseShiftState);
  begin
    if Assigned(gsManager.Current) then
      gsManager.Current.OnMouseMove(X, Y, Shift);
    mousePos.X := X;
    mousePos.Y := Y;
  end;

  procedure OnMouseDown(X, Y: Integer; MouseButton: TglrMouseButton;
    Shift: TglrMouseShiftState);
  begin
    if Assigned(gsManager.Current) then
      gsManager.Current.OnMouseDown(X, Y, MouseButton, Shift);
    mousePos.X := X;
    mousePos.Y := Y;
  end;

  procedure OnMouseUp(X, Y: Integer; MouseButton: TglrMouseButton;
    Shift: TglrMouseShiftState);
  begin
    if Assigned(gsManager.Current) then
      gsManager.Current.OnMouseUp(X, Y, MouseButton, Shift);
    mousePos.X := X;
    mousePos.Y := Y;
  end;

begin
  Randomize();
  LoadRendererLib();
  gl.Init();

  R := glrGetRenderer();
  R.Init('settings_rds.txt');
  R.OnUpdate := OnUpdate;
  R.OnMouseMove := OnMouseMove;
  R.OnMouseDown := OnMouseDown;
  R.OnMouseUp := OnMouseUp;
  R.Camera.ProjectionMode := pmOrtho;
  R.WindowCaption := PWideChar('Ragdoll Fighting. ��������. ������ '
    + GAMEVERSION + ' [glRenderer ' + R.VersionText + ']');
  Factory := glrGetObjectFactory();

  InitializeGlobal();
  gsManager := TpdGSManager.Create();
  mainMenu := TpdMainMenu.Create();
  game := TpdGame.Create();
  pauseMenu := TpdPauseMenu.Create();
  gameOver := TpdGameOver.Create();

  mainMenu.SetGameScreenLinks(game);
  game.SetGameScreenLinks(pauseMenu, gameOver);
  pauseMenu.SetGameScreenLinks(mainMenu, game);
  gameOver.SetGameScreenLinks(mainMenu, game);

  gsManager.Add(mainMenu);
  gsManager.Add(game);
  gsManager.Add(pauseMenu);
  gsManager.Add(gameOver);
  {$IFDEF DEBUG}
  game.GameMode := gmSingle;
  gsManager.Notify(game, naSwitchTo);
  {$ELSE}
  gsManager.Notify(mainMenu, naSwitchTo);
  {$ENDIF}

  R.Start();

  gsManager.Free();
  FinalizeGlobal();

  R.DeInit();
  R := nil;
  UnLoadRendererLib();
end.
