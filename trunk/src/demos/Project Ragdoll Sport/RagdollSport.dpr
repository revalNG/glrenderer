{
  BUGS:
  + BUG #1:  ������ ��� �������� ����. ��������� ������ ���� ��� ������� � ����.
             �������� ������� � ��������� ������
  + BUG #2:  �� ����������� ��������� ������ ���������
  + BUG #3:  �������� ����� ������� ������ � GameOver
  + BUG #4:  Tween-��������� ������� ��������
    BUG #5:  Fadeout ������� ��������



  ����:
    ���� �����
      ����������, ����
      ��������� �� ����������
      ���������, ��� ������

  + ���� ���������
  +   ����� ����� ������
  +   ������������ ���� �����
  +   ������ ������
  +   ������ - ������, ����
  + ���� �������
  +   Fade out
  -   Circles
  + ���� ��������
  +   ��������� ������,
  +   ������,
      ���� ����
      ��� ������
  + ������-������� ��������
  +   ��������� �������
  +   ����������� �������
  +   ������ ������

  ����:
    ������� �����:
  +   �������� �����
  +   ������� ������ � �����

    ���������� � ������� ����

  + ����������/�������� ��������

    ����, ������� ������ ������� (�����)
    ����������� ���� (�������������� �� ������������ ����������)
    ������� ������ (������������ ����� 10-15 �����)
    ����������
    ������
    ��� ����
  +   ���� �� ������
    ����������� �� ��������
  + ��������� ����� �� ����
  + ������� ������� ��� ������ �� ����
  +-������� �������� online � mousecontrol


    ������?!
}

program RagdollSport;
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
  uObjects in 'uObjects.pas',
  uAccum in 'uAccum.pas',
  uPopup in 'uPopup.pas',
  uGameSync in 'uGameSync.pas',
  uSettings_SaveLoad in 'uSettings_SaveLoad.pas',
  dfTweener in '..\..\headers\dfTweener.pas',
  glrMath in '..\..\headers\glrMath.pas',
  ogl in '..\..\headers\ogl.pas';

var
  gsManager: TpdGSManager;

  procedure OnUpdate(const dt: Double);
  begin
    if GSManager.IsQuitMessageReceived then
      R.Stop();
    gsManager.Update(dt);
    Tweener.Update(dt);
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
  R.WindowCaption := PWideChar('Ragdoll Sports. ��������. ������ '
    + GAMEVERSION + ' [glRenderer ' + R.VersionText + ']');
  Factory := glrGetObjectFactory();

  gl.ClearColor(99 / 255, 99 / 255, 99 / 255, 1.0);
  InitializeGlobal();
  gsManager := TpdGSManager.Create();
  mainMenu := TpdMainMenu.Create();
  game := TpdGame.Create();
//  pauseMenu := TpdPauseMenu.Create();
  gameOver := TpdGameOver.Create();

  mainMenu.SetGameScreenLinks(game);
  game.SetGameScreenLinks(pauseMenu, gameOver);
//  pauseMenu.SetGameScreenLinks(mainMenu, game);
  gameOver.SetGameScreenLinks(mainMenu, game);

  gsManager.Add(mainMenu);
  gsManager.Add(game);
//  gsManager.Add(pauseMenu);
  gsManager.Add(gameOver);
//  {$IFDEF DEBUG}
//  gsManager.Notify(game, naSwitchTo);
//  {$ELSE}
  gsManager.Notify(mainMenu, naSwitchTo);
//  {$ENDIF}

  R.Start();

  gsManager.Free();
  FinalizeGlobal();

  R.DeInit();
  R._Release();
  R := nil;
  UnLoadRendererLib();
end.
