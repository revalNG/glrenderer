{
  TODO:
    ���������� GUI � ������ ����, ��� Renderable - ��������� Node
    ������ � ������� ��� ����������
    ��������� align � ������
 +  ��������� pivot point � ������
    ��������� width � ������ - ������� �� ������/������
 +  Z-index � ��� �������� ��� 2d-��������
 +  �������� �������������� �������� ��� TdfVec-����������:
      DiffuseP - pointer. ����� ����� ���� Diffuse.X ������

 -  ��������� SetParent � Node � 2DRenderable
 -  RenderChilds � 2DRenderable ���� �� ������������
 +  ������ CheckHit � HudSprite
    ������ ������� Scene - Renderable � �����. ���� �� Scene � ������ ������ Renderable
    RootNode ��������� �� Iglr3DScene -> IglrBaseScene. Iglr2DScene ����� �����
      ������������ RootNode

 ����� ������� Renderable-Node ��������� ������:
  GUI
  Camera
  Font
  HudSprite
  Light
  Node
  Renderable
  Text
  UserRenderable


  LD - Last Developed - ��� ��� ������� � ��������� ��� � ���� ����


  2013-09-18 - LD - Renderable - ��������� Node. ������ ������
  2013-08-05 - -- - ����������� 0.3.0. ����������� ����� � ���, ������������
  2013-07-31 - LD - ����� ����������� ���� (df -> glr)
  2013-07-30 - LD - �������� glrObjectFactory
  2013-07-14 - LD - GUITextButton ��������
  2013-05-14 - LD - GUITextBox.KeyDown - ��������� ������������� Return
  2013-05-08 - LD - ������ �������: 2DRenderable.ParentScene. ������ �������� X, Y � GUIManager
  2013-05-04 - LD - GUISlider, 1st version
  2013-05-03 - LD - _Focus, _Unfocus, OnFocused � GUIElement, _Focus � GUITextBox
  2013-05-03 - LD - CursorOffset � GUITextBox
  2013-05-03 - LD - ������� ttf/otf ���������. ������ ��� ������ ����������� ���
                    ���������, ���� ��� ������ �������� ����������� �� ����� �����
  2013-05-01 - LD - ���������� ������ ���������� ������.
                    ������ ��� ������ ����������� �� ����� �����, ������ ���
                    �������� �� ttf/otf �����
  2013-04-30 - LD - ��������� pivot point � ������
  2013-04-28 - LD - ����� ������ IdfGUITextBox. �� GUIManager.KeyDown.
  2013-04-27 - LD - ������� � ��� GL_VENDOR, GL_RENDERER, GL_VERSION, GL_GLSL
  2013-04-23 - LD - ������� IdfGUIElement.Reset - ���������� ���������� ���������
                    override � �������� ��� ��������� normal-��������
  2013-04-19 - LD - ������� ����� ������������ ���� - ��� min/max. non sizing border
  2013-04-16 - LD - ��������� � ��������� ������� 2D
                    �������� ���������� Node ������ 2DRenderable.
  2013-04-14 - LD - �������� �������� cursor true/false
  2013-04-13 - LD - PRotation, PDiffuse - build 36
  2013-04-12 - LD - ������ ������� PPosition - ������ PdfVec2f - build 35
  2013-04-06 - LD - ������ ������� (���� ��� ������� � ����)
  2013-03-25 - LD - �������� ���������� ��� �������, ����������� ����� Load2D(File)
  2013-03-24 - LD - ������� FSAA ����� ��������� �������� � ��������������
  2013-03-24 - LD - ����� ������ ��������� multisamle ��� �����������
                    ����� wglChoosePixelFormat. ��� ����� ���� ������ ���������
                    ��������. �� TdfRenderer.OpenGLInitTemporaryContext
                    �� ��������!
  2013-03-03 - LD - ��������� ��������� � ������ � ������� #10
                    Scene.UnregisterElements - ������� ��� ��������
                    ��������� Scale � ������
  2013-02-23 - LD - Load2DRegion - �������� �� Checker5_GUI - ��������.
                    �������� ��� � ������� ������������� �������� � ������.
                    �������� ���������� ���������� ��� ��������, ������� �����
                    region. ���� ���� ������������� �������� UpdateTexCoords()
                    ����� �������� Load2DRegion.
                    ������� TextureSwitches � Renderer - ���������� ������������
                    ������� �� ����
  2013-02-17 - LD - Texture.Load2DRegion - �������� ����� ��� ������������
                    ��������. ��������� ������.
  2012-09-08 - LD - Checker 7 - ragdoll masters, uCharacter - need joints
  2012-08-25 - LD - Idf2DScene. ���� ���0�� ������
  2012-08-23 - LD - GUIManager.MouseDown, Up, Over, Out
                    GUIElement - CheckHit
  2012-08-23 - LD - GUIElement, GUIManager. ����� ������ ��� Idf2DSceneManager
                    TdfGUIButton._MouseDown
  2012-07-02 - LD - ������ ��������� ���������, ���������� ���� ���������.
                    �������� pivot point
  2012-07-01 - LD - ����� ������� � �������������� ������� Node. ����� �����-��
  2012-04-15 - LD - ��� � ��������� � ������� ������� �������:
                    AdjustWindowRect ������ ����������� ������ �������� ����
                    � ��������� - ������������ �������������� ������
  2012-02-27 - LD - ��� � ��������� � ����� �������
  2012-02-?? - LD - TdfTexture, TdfMaterial, TdfSprite. ����� ������ ������ �������

  BUGS:
+  1. TdfNode ������ - �� ������������ left, up � dir
+  2. TdfNode - �������� CreateAsChild � ������������� ����������
+     ��������, ����� ��������� � ���������������� ���� DiF Engine
+  3. TdfNode - ��������� ���������� � �����. ������� ����� �����
+  4. TInterfaceList ������� �������� ������ � �����. ��������� ��� TList, ��
      ���� �����������
   5. TdfLight - ��������� TdfNode, �������. ����� ������� ��� ��� TdfRenderable
      �� ��� ����� ���� � ���������� SetPos?
+  6. ��� � �������� ��������. �������� Camera.Init � Renderer.Init()



  2011-10-11: TODO:
    1. �������� �� ���������� ��� ������������ ������� �������:
+     1. Camera - ������ �������
+     2. Light - ������ �������, �� �������� ��� ���� �������� �����
      3. Shaders
+     4. Textures
    2. �������� ����� ������� � ����������� ������������ ������:
+     1. Node - ������ �������
      2. Scene
      3. VBOBuffer
      4. Mesh
+     5. Sprite
+     6. Material
      7. Actor
    3. �������� ��������������� ������� � �����������:
      1. Resource
      2. ResourceManager

    4. ������ �������, �������� �����������������

    5. �������� ������, ������ � ������ ���������


  2011-04-09//
              ����� ����������� - ������� ��� COM-��������: ���������� � ������
}
library glRenderer;

{$R *.res}

uses
  ShareMem,
  uRenderer in 'uRenderer.pas',
  uCamera in 'uCamera.pas',
  uLight in 'uLight.pas',
  uHudSprite in 'uHudSprite.pas',
  uTexture in 'uTexture.pas',
  uShader in 'uShader.pas',
  uLogger in 'uLogger.pas',
  glr in '..\headers\glr.pas',
  uNode in 'uNode.pas',
  ExportFunc in 'ExportFunc.pas',
  TexLoad in 'TexLoad.pas',
  uRenderable in 'uRenderable.pas',
  uMaterial in 'uMaterial.pas',
  uFont in 'uFont.pas',
  uText in 'uText.pas',
  uWindow in 'uWindow.pas',
  uPrimitives in 'uPrimitives.pas',
  uUserRenderable in 'uUserRenderable.pas',
  uGUIElement in 'GUI\uGUIElement.pas',
  uGUIButton in 'GUI\uGUIButton.pas',
  uInput in 'uInput.pas',
  uGUIManager in 'GUI\uGUIManager.pas',
  uScene in 'uScene.pas',
  uGUICheckbox in 'GUI\uGUICheckbox.pas',
  uGUITextBox in 'GUI\uGUITextBox.pas',
  uGUISlider in 'GUI\uGUISlider.pas',
  uGUITextButton in 'GUI\uGUITextButton.pas',
  uFactory in 'uFactory.pas',
  dfLogger in 'dfLogger.pas',
  glrMath in '..\headers\glrMath.pas',
  ogl in '..\headers\ogl.pas',
  uBaseInterfaceObject in 'uBaseInterfaceObject.pas';

exports
  GetRenderer, GetObjectFactory;
begin
end.
