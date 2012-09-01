program Checker5_GUI;

uses
  Windows,
  dfHRenderer in '..\..\headers\dfHRenderer.pas',
  dfHEngine in '..\..\common\dfHEngine.pas',
  dfMath in '..\..\common\dfMath.pas',
  dfHUtility in '..\..\headers\dfHUtility.pas';

var
  R: IdfRenderer;

  Button1: IdfGUIButton;
  n, n2: IdfNode;
  tn, tn2, tn3: IdfTexture;

  font1: IdfFont; text1: IdfText;


  fpsCounter: TdfFPSCounter;

  procedure OnUpdate(const dt: Double);
  begin
    if R.Input.IsKeyDown(VK_ESCAPE) then
      R.Stop();
    fpsCounter.Update(dt);
  end;

  procedure OnMouseClick(Sender: IdfGUIElement; X, Y: Integer; mb: TdfMouseButton; shift: TdfMouseShiftState);
  begin
    text1.Text := 'Mouse click';
  end;

  procedure OnMouseOver(Sender: IdfGUIElement; X, Y: Integer; Button: TdfMouseButton; Shift: TdfMouseShiftState);
  begin
    text1.Text := 'Mouse over';
  end;

  procedure OnMouseOut(Sender: IdfGUIElement; X, Y: Integer; Button: TdfMouseButton; Shift: TdfMouseShiftState);
  begin
    text1.Text := 'Mouse out';
  end;

begin
  LoadRendererLib();

  R := dfCreateRenderer();

  R.Init('settings.txt');

  fpsCounter := TdfFPSCounter.Create(R.RootNode, 'FPS:', 1, nil);

  R.OnUpdate := OnUpdate;

  //Text & font
  font1 := dfCreateFont();
  font1.AddRange('!', '~');
  font1.AddRange('À', 'ÿ');
  font1.AddSymbols(' ');
  font1.FontSize := 14;
  font1.FontStyle := [];
  font1.GenerateFromFont('Times New Roman');


  text1 := dfCreateText();
  text1.Font := font1;
  text1.Position := dfVec2f(50, 20);
  text1.Text := 'bla-bla';

  n2 := R.RootNode.AddNewChild();
  n2.Renderable := text1;

  //GUI
  Button1 := dfCreateGUIButton();
  // - normal texture
  tn := dfCreateTexture();
  tn.Load2D('data/button_normal1.tga');
  tn.BlendingMode := tbmTransparency;
  tn.CombineMode := tcmModulate;

  // - over texture
  tn2 := dfCreateTexture();
  tn2.Load2D('data/button_over1.tga');
  tn2.BlendingMode := tbmTransparency;
  tn2.CombineMode := tcmModulate;

  // - click texture
  tn3 := dfCreateTexture();
  tn3.Load2D('data/button_click1.tga');
  tn3.BlendingMode := tbmTransparency;
  tn3.CombineMode := tcmModulate;

  Button1.TextureNormal := tn;
  Button1.TextureOver := tn2;
  Button1.TextureClick := tn3;
  tn := nil;
  tn2 := nil;
  tn3 := nil;

  Button1.OnMouseOver := OnMouseOver;
  Button1.OnMouseOut := OnMouseOut;
  Button1.OnMouseClick := OnMouseClick;
  Button1.Width := 130;
  Button1.Height := 43;
  Button1.Position := dfVec2f(220, 20);

  n := R.RootNode.AddNewChild();
  n.Renderable := Button1;

  R.GUIManager.RegisterElement(Button1);

  R.Start();
  R.DeInit();

  fpsCounter.Free;

  UnLoadRendererLib();
end.
