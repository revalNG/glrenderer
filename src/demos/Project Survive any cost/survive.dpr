{
  ����������� ����� �� ��������� ����:


BUGS:
 + BUG #1 - ���������� ����������� ������
 +-BUG #2 - �������� �� vsync = true
 + BUG #3 - ��������, ������� ���������� Unload
 + BUG #4 - �� ��������� ����� cursorText ��� ������ ���� �����
 + BUG #5 - ������ ����� ����������� �� game, ��� ��� ����� ���������� SetStatus �� Load() -> AV
            ���� ����������� � ���� ����������, ��� ��������� ��� ����� �����������
 + BUG #6 - ������������ ������ ���� � ������� �������� ������������ ����� � ������ ����
 + BUG #7 - AV ��� ����-����� �� ����������� world-�������
 + BUG #8 - ����� ������ �� ����, ���-�� �� ��� ��� ����������
 + BUG #9 - ��� �������� ���� ������ �� ����������
 + BUG #10  AV ��� ������������� ������� ����� ���������
 + BUG #11  ���� ���-�� ������� �� ������, ���� ��� ����� - ������� ��� �� ���������
 + BUG #12  ��������� ������, ����� � ����, ����� � ���� - ��� ������, ������ ���
 + BUG #13  ��������� ������ �� ������ �� ����� :)

TODO:
  �����������:
    ������������� �����, ������� ������� ����� ��� ������ � ������� ����� � ��� �� ���������
    ������������ TpdWorldObject.GetObjectSprite ��� Initialize � ������ ������
    ��������� ����� OnDrop � WorldObject ��� ��������
    ������ ������� _AddNew[Object] � TpdGame.
    ������ RecalBB, ����� �� ������������� ��� ��� ��������� �������

  �����:
  + ���� �������� ������ play � game
  + ���������� ������
    ��������� ��������� ������
    ���� ����� ������, �������� ����������� �� ������
  + �����������, ��� ���� ������� �� ���� ������
  + �������� � ������� ����� ������� ����
  + ����� ����-������ � ������
  + ��������� ���������� ������ ��� � ����
  +-�������� ������:
      ��� ������ ������� ������ - "����� ��������� ������, ���������� �� � ����"
      ��� ���������� ������ - "� ������� ������ ����� ������ ����. ��� ����� ���������� �� � ����, ���� ����������� (������ ������ ����), �������� � ����"
      ��� �������� ������ - "�� ������ ����� ���������� ����� ��������", "� ������ ����� ���� �������"
      ��� ����� � ���� "���������, ���� ����� ��� ������ �� ����, �� �� �������"
      ��� ������������ ��������� - ������ �������� �� ������

  + ��������� ������ ������, ����� ���������� ������ (��� �����) ��� ���� �����������
  + ��������� �������� ������ ������ ���
  + ����������� � �������� � ���������� �� ���. ��������� �� ��� ������ ������� ������� �������� ����� ����
  + ���������� �������� � ���� �����
  + ���������� ��� �� ��� � ������ �� � �������� � ���
  + �������� ��� ������ ���������� ���� ����
  + �� ������ �������� ������!
  +-BUGTEST - mainmenu - game - mainmenu - game
  + �������� ��������: ����� ���.
  + ����� �������� �� ��������� - ����� ��� �����������������. ����� ��������� - ��������
  + WorldObject.IsInside
  - ��������� ��������� (� ���������?) ��������� WorldObjects
  - ���������� ��� ������� - �������
  + ��� + � ��������� ������������ ��� �����. ����� ������� ����� � ����� tcmModulate ������ ����
    �������� ������ ������� � ������
    ��������� ������ ����� �� �������� (�����)
  + �������� ����� �� �����
  + �� ������� ���������, ���� ����� ��� ���� �� 0
    (��������)������� ����, ���������� �� �����
  + ���������� ������ retry ��� gameover?

  - GoAndDrop ������ �������� drop

  + �������� ��� ���, ����� ��������� ������ � ��������� ������ � ������� ������ ������

  ����:
  + ��������� ����
  + �������� ���� �� �����
  + ���� ����
  + � ���� ����� ��� ��������� �����������.
  + ���� �� ������ �� 0 � ���� - �������� ������
  + ������������� ������ � ����
  + ������������� ������ � ����
  + ������� ���� � ����

  �����:
  + ������ ������
  + �������/����� ������ ������
  + �������� �� ������
  + ��� ��������� - ���������� ����������� � �����������
  + ������ ������� ����� ������������ �������
  + ������ ���� �����-�����, ���� ������� ������
  + ��������� ������ - �������� ������ �������, ��� ��������� �������
  + ����� �� ������

  + ������
  + ������ �����
  + ������
  + ����� ������ �� ������
  + ����� � �������� � �����
  + ����� ������ �� ����


  ������� ������
    + �������� �������� � ������������
    -> �������� ������� ������� � ������ ������ (����, ������)
  + ����� + ����� + ��� = ������ + ���
  + 2����� + 2������ = ������
  + ����� -> ������ = ������ ������ �����
  + ������ -> ������ = ������ ������ �����
  + ��� + ����� = ������ �����
  + 2����� + ������ ����� = ������ �� ������
  + ������ �� ������ -> ����� = ������� ������ �� ������
  + ����� -> ���� = ����� � �����
  + ����� � ����� -> ������ = ����� � ���������� �����
  + ����� � ����� + ������� = ����� � �������� � �����
  + ����� � �������� � ����� -> ������ = ���������� ���
  + ���� + ������ ����� + ��� = ����� ������ �� ���� + ���
  + ����� ������ �� ���� -> ������ = ������� ������ �� ����

  ������� �� �����-������:
  + ������
  + ������ �����
  + ������
  + ����� ������ �� ������
  + ����� � �������� � �����
  + ����� ������ �� ����

  ����:

  + MainMenu - Fade in
  + MainMenu - Fade out
  + Game - Fade in
  + Game - Fade out
  + ���� �����
  + ���� gameover
  + Escape �� ���� ����� - ������� � ����

  ���������:
  + ��������� - �������, �����
  + ��������� - ���� ��������
  + ��������� - ����������� ��������
  + ��������� - ���������� ��������
  + ��������� - ��������� ��� ��������� �� ������
  + ��������� - ��������� �������������� ����� � ������ ������� �������
  + ��������� - ���� ������ ������, �� �������� ��������� (���� �� �� �������)

  ������� �������:
  + �������� ����� � ��� �����������
  + ��������� ������ � ���� ������ � ��������������


  ������ �����:
  + ���������� ��������� �� �� ���������
  ? ��������� ��� ��������� �� ���������
  + ���������� ������������� ������ (����, ���...)
  + ��������� �����, ���� ���� �����
  + ��� ����� �� ������ - �������, ����� �����.
  - ������ �������� ������ � ����������� �� ���������� - ������� ����� ���
  + ������ ��
  - � ������ ������� ���� ���� - ���������������� ���������
  + tween ������������ � ��������� ������
  + ����������� ������ ���������� ������� ������
  + ��� ������� ��������� ������������� �������� ��������� �����: "����, ��� �� ������� ����" � ������
  - popup ��� ������� ������ �������


  ���������:
  + ����� ��������� - ����������� ��������. ���������� �������������� � ����
  + ������������� ��������� ������� ����, ���� �������� �� ������� HUD
  - ��������� ��� ��������� ��������� (������, ���, ���������, �����)
  + fade in/out for about
  + ����� ������ ��� ����� � ����
  + ���������� �������� �������
  + ���������� � ����
  + ����������� ������� ��� ��������
  + ��� + � ���� ����, �������� � ���������
  + ������ - ��� ����� � + � ���� ����, �������� ������ ������, �������� ������� � ��� ������
  + ����� + � ���� ����
  + ����� + � ���� ����
  + ������ �����(?)



����� �� �������:
  �������� (������� � ���������). ������ �� ������ � �� �������, �� ��������
  ����� ������, �������
  ����� N ������� ��������� �����
  ����� M ������� ���������� ���� � ��������
  ��������� ������� �����
  ������� ���������� ���������
  ����� ���� ����������� - ���������� ������ ������, ��� ������������ ��
    ������ �����. ����� �� ������ 100% ��������.
  ������������ �� ���� ���
  ��������-�������� � �������� ���������
  ������������� � ��������
  �������
  ���������
  ������������ ���-���� ���
  ������
}

program survive;

{$R 'icon.res' 'icon.rc'}

uses
  ShareMem,
  glr in '..\..\headers\glr.pas',
  glrUtils in '..\..\headers\glrUtils.pas',
  uGlobal in 'uGlobal.pas',
  uGameScreen.Game in 'gamescreens\uGameScreen.Game.pas',
  uGameScreen.MainMenu in 'gamescreens\uGameScreen.MainMenu.pas',
  uGameScreen in 'gamescreens\uGameScreen.pas',
  uGameScreen.PauseMenu in 'gamescreens\uGameScreen.PauseMenu.pas',
  uGameScreenManager in 'gamescreens\uGameScreenManager.pas',
  Bass in '..\..\headers\Bass.pas',
  uSound in 'uSound.pas',
  uPlayer in 'uPlayer.pas',
  uWorldObjects in 'uWorldObjects.pas',
  uLevel_SaveLoad in 'uLevel_SaveLoad.pas',
  uInventory in 'uInventory.pas',
  uWater in 'uWater.pas',
  uGameScreen.GameOver in 'gamescreens\uGameScreen.GameOver.pas',
  uCraft in 'uCraft.pas',
  uAdvices in 'uAdvices.pas',
  uGameScreen.Advices in 'gamescreens\uGameScreen.Advices.pas',
  dfTweener in '..\..\headers\dfTweener.pas',
  glrMath in '..\..\headers\glrMath.pas',
  ogl in '..\..\headers\ogl.pas';

const
  VERSION = '0.10a';

var
  gsManager: TpdGSManager;

  procedure OnUpdate(const dt: Double);
  begin
    if GSManager.IsQuitMessageReceived then
      R.Stop();
    gsManager.Update(dt);
    Tweener.Update(dt);
    UpdateCursor(dt);
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
  R := glrGetRenderer();
  R.Init('settings_survive.txt');
  Factory := glrGetObjectFactory();

  gl.Init();
  R.OnUpdate := OnUpdate;
  R.OnMouseMove := OnMouseMove;
  R.OnMouseDown := OnMouseDown;
  R.OnMouseUp := OnMouseUp;
  R.Camera.ProjectionMode := pmOrtho;
  R.WindowCaption := PWideChar('Survive. ��������. ������ '
    + VERSION + ' [glRenderer ' + R.VersionText + ']');

  gsManager := TpdGSManager.Create();
  LoadGlobalResources();

  mainMenu := TpdMainMenu.Create();
  game := TpdGame.Create();
  pauseMenu := TpdPauseMenu.Create();
  advices := TpdAdvicesMenu.Create();
  gameOver := TpdGameOver.Create();

  mainMenu.SetGameScreenLinks(game, advices);
  game.SetGameScreenLinks(pauseMenu, gameOver);
  pauseMenu.SetGameScreenLinks(mainMenu, game, advices);
  advices.SetGameScreenLinks(game);
  gameOver.SetGameScreenLinks(mainMenu, game);

  gsManager.Add(mainMenu);
  gsManager.Add(game);
  gsManager.Add(pauseMenu);
  gsManager.Add(advices);
  gsManager.Add(gameOver);
  {$IFDEF DEBUG}
  gsManager.Notify(game, naSwitchTo);
  sound.Enabled := False;
  {$ELSE}
  gsManager.Notify(mainMenu, naSwitchTo);
  {$ENDIF}

  R.Start();

  gsManager.Free();
  FreeGlobalResources();
  R.DeInit();
  UnLoadRendererLib();
end.
