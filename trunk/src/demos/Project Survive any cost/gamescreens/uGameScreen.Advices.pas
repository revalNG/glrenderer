unit uGameScreen.Advices;

interface

uses
  uGameScreen, uAdvices,
  glr;

const
  TIME_FADEIN = 0.7;
  TIME_FADEOUT = 0.7;

type
  TpdAdvicesMenu = class (TpdGameScreen)
  private
    FScene: Iglr2DScene;
    FScrGame: TpdGameScreen;
    FGUIManager: IglrGUIManager;

    FFakeBackground: IglrSprite;
    FAdvc: TpdAdviceController;
    FBtnToPauseMenu: IglrGUIButton;

    Ft: Single; //����� ��� �������� fadein / fadeout

    procedure InitButtons();
    procedure InitBackground();
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

    procedure SetGameScreenLinks(aToGame: TpdGameScreen);
  end;

var
  advices: TpdAdvicesMenu;

implementation

uses
  glrMath, dfTweener,
  uGlobal;

const
  OK_NORMAL_TEXTURE  = 'ok_normal.png';
  OK_OVER_TEXTURE  = 'ok_over.png';
  OK_CLICK_TEXTURE = 'ok_click.png';

  OK_OFFSET_Y = 90;
  ADVC_OFFSET_X = 0;
  ADVC_OFFSET_Y = 0;


procedure OnAdviceBtnClick(aElement: IglrGUIElement; X, Y: Integer;
  MouseButton: TglrMouseButton; Shift: TglrMouseShiftState);
begin
  with advices.FAdvc do
  if MouseButton = mbLeft then
  begin
    if aElement = (FBtnPrev as IglrGUIElement) then
      Previous()
    else if aElement = (FBtnNext as IglrGUIElement) then
      Next();
  end
end;

procedure OnMouseClick(Sender: IglrGUIElement; X, Y: Integer; mb: TglrMouseButton;
  Shift: TglrMouseShiftState);
begin
  with advices do
    if Sender = (FBtnToPauseMenu as IglrGUIElement) then
    begin
      OnNotify(FScrGame, naSwitchTo);
    end
end;

{ TpdAdvicesMenu }

constructor TpdAdvicesMenu.Create;
begin
  inherited;
  FGUIManager := R.GUIManager;
  FScene := Factory.New2DScene();

  InitBackground();

  InitButtons();

  FAdvc := TpdAdviceController.Initialize(FScene);
  FAdvc.FBtnNext.OnMouseClick := OnAdviceBtnClick;
  FAdvc.FBtnPrev.OnMouseClick := OnAdviceBtnClick;

  //--oops
  FAdvc.AddAdvice('������ ����, �����! � ����, ��� ��� ������ ������, ��'
       + #13#10 + '������ ����������� �������� ���� ������ �����'
       + #13#10 + '������� �� ���������.'
       + #13#10 + '��� ������ ����� �������� ������� �� ���� �����.'
       + #13#10
       + #13#10 + '����� OK, ����� ������ ������.');
  FAdvc.AddAdvice('����� ������ ���� � �������� � �������������� c'
       + #13#10 + '���������. �������, ����� ���������.'
       + #13#10 + '������ ������ � ������������� �������� ���������'
       + #13#10 + '����� ��������� �������, ��������� ��� �� ���������'
       + #13#10 + 'Z ��� I � ��������/������ ���������'
       + #13#10 + 'C � ��������/������ ������ ������', False);
  FAdvc.AddAdvice('������� ����� �� �����. ��� ����� ����� ����������:'
       + #13#10 + '������, ���, ����� � �����. ��� ������ �������.'
       , False);
  FAdvc.AddAdvice('���� ���� �� ����������, ����� ������ ���,'
       + #13#10 + '������ �� ����, �� �������� �����. '
       + #13#10 + '������� ����� ��� �������� ������ � ���� � �����'
       + #13#10 + '�������.'
       , False);
  FAdvc.AddAdvice('�����, ������ ��������� � ����, ���������� �����.'
       + #13#10 + '���� ���������� ������ � ���� � ����� ������� ����'
       + #13#10 + '�����, ����� � ������ ����� ��������� �� ���������,'
       + #13#10 + '�������� � ���� (������ ������ ����).'
       + #13#10 + '�����: ���������� ����� � ���� ���� ������.'
       , False);
  FAdvc.AddAdvice('������ � ����� ������ �������. ����� � ��� �����'
       + #13#10 + '����������, ����� ���-������ �������� ���'
       + #13#10 + '�����������. ����� ��������� � ������ ����� ���'
       + #13#10 + '�����, ����� �� ������ �����.'
       + #13#10 + '������ ���������� �������� �� ��������� �� ������.'
       , False);
  FAdvc.AddAdvice('����� ����� ��������� ���� (������� ��� ���������)'
       + #13#10 + '��� ��� (��������� ��� ���������)'
       + #13#10 + '��� ����������� ����� ������������� ������ ������ �'
       + #13#10 + '������������� ����� � ���������� �� ������.'
       , False);
end;

destructor TpdAdvicesMenu.Destroy;
begin
  FScene.UnregisterElements();
  FAdvc.Free();
  inherited;
end;

procedure TpdAdvicesMenu.FadeIn(deltaTime: Double);
begin
  if Ft <= 0 then
    inherited
  else
  begin
    Ft := Ft - deltaTime;
    FFakeBackground.Material.PDiffuse.w := 0.5 - 0.5 * Ft / TIME_FADEIN;
  end;
end;

procedure TpdAdvicesMenu.FadeInComplete;
begin
  Status := gssReady;
  FGUIManager.RegisterElement(FBtnToPauseMenu);
end;

procedure TpdAdvicesMenu.FadeOut(deltaTime: Double);
begin
  if Ft <= 0 then
    inherited
  else
  begin
    Ft := Ft - deltaTime;
    FFakeBackground.Material.PDiffuse.w := 0.5 * Ft / TIME_FADEOUT;
  end;
end;

procedure TpdAdvicesMenu.FadeOutComplete;
begin
  Status := gssNone;
  FFakeBackground.Visible := False;
end;

procedure TpdAdvicesMenu.InitBackground;
begin
  FFakeBackground := Factory.NewHudSprite();
  with FFakeBackground do
  begin
    Material.Diffuse := dfVec4f(0, 0, 0, 0.0);
    Material.Texture.BlendingMode := tbmTransparency;
    Z := Z_INGAMEMENU - 2;
    PivotPoint := ppTopLeft;
    Width := R.WindowWidth;
    Height := R.WindowHeight;
    Position := dfVec2f(0, 0);
  end;

  FScene.RegisterElement(FFakeBackground);
end;

procedure TpdAdvicesMenu.InitButtons();
begin
  FBtnToPauseMenu:= Factory.NewGUIButton();

  with FBtnToPauseMenu do
  begin
    PivotPoint := ppCenter;
    Position := dfVec2f(R.WindowWidth div 2, R.WindowHeight div 2 + OK_OFFSET_Y);
    Z := Z_INGAMEMENU + 1;
    TextureNormal := atlasInGameMenu.LoadTexture(OK_NORMAL_TEXTURE);
    TextureOver := atlasInGameMenu.LoadTexture(OK_OVER_TEXTURE);
    TextureClick := atlasInGameMenu.LoadTexture(OK_CLICK_TEXTURE);

    UpdateTexCoords();
    SetSizeToTextureSize();
  end;

  FBtnToPauseMenu.OnMouseClick := OnMouseClick;

  FScene.RegisterElement(FBtnToPauseMenu);
end;

procedure TpdAdvicesMenu.Load;
begin
  inherited;
  R.RegisterScene(FScene);
end;

procedure TpdAdvicesMenu.SetGameScreenLinks(aToGame: TpdGameScreen);
begin
  FScrGame := aToGame;
end;

procedure TpdAdvicesMenu.SetStatus(const aStatus: TpdGameScreenStatus);
begin
  inherited;
  case aStatus of
    gssNone: Exit;

    gssReady: Exit;

    gssFadeIn:
    begin
      FFakeBackground.Visible := True;
      Ft := TIME_FADEIN;
      Tweener.AddTweenPSingle(@FBtnToPauseMenu.PPosition.y, tsExpoEaseIn,
        R.WindowHeight + 90, R.WindowHeight div 2 + OK_OFFSET_Y, 2, 0.1);
      FAdvc.Visible := True;
    end;

    gssFadeInComplete: FadeInComplete();

    gssFadeOut:
    begin
      Tweener.AddTweenPSingle(@FBtnToPauseMenu.PPosition.y, tsExpoEaseIn,
        R.WindowHeight div 2 + OK_OFFSET_Y, R.WindowHeight + 90, 2, 0.1);
      FGUIManager.UnregisterElement(FBtnToPauseMenu);
      Ft := TIME_FADEOUT;
      FAdvc.Visible := False;
    end;

    gssFadeOutComplete: FadeOutComplete();
  end;
end;

procedure TpdAdvicesMenu.Unload;
begin
  inherited;
  R.UnregisterScene(FScene);
end;

procedure TpdAdvicesMenu.Update(deltaTime: Double);
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
        OnMouseClick(FBtnToPauseMenu as IglrGUIElement, 0, 0, mbLeft, []);
      FAdvc.Update(deltaTime);
    end;
  end;
end;

end.
