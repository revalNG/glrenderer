{
  LD - Last Developed - ��� ��� ������� � ��������� ��� � ���� ����


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
-  2. TdfNode - �������� CreateAsChild � ������������� ����������
+     ��������, ����� ��������� � ���������������� ���� DiF Engine
+  3. TdfNode - ��������� ���������� � �����. ������� ����� �����
?  4. TInterfaceList ������� �������� ������ � �����. ��������� ��� TList, ��
      ���� �����������
   5. TdfLight - ��������� TdfNode, �������. ����� ������� ��� ��� TdfRenderable
      �� ��� ����� ���� � ���������� SetPos?
+  6. ��� � �������� ��������. �������� Camera.Init � Renderer.Init()



  2011-10-11: TODO:
    1. �������� �� ���������� ��� ������������ ������� �������:
+     1. Camera - ������ �������
+     2. Light - ������ �������, �� �������� ��� ���� �������� �����
      3. Shaders
      4. Textures
    2. �������� ����� ������� � ����������� ������������ ������:
+     1. Node - ������ �������
      2. Scene
      3. VBOBuffer
      4. Mesh
      5. Sprite
      6. Material
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
  uRenderer in 'uRenderer.pas',
  uCamera in 'uCamera.pas',
  uLight in 'uLight.pas',
  uSprite in 'uSprite.pas',
  uTexture in 'uTexture.pas',
  uShader in 'uShader.pas',
  uLogger in 'uLogger.pas',
  dfHEngine in '..\common\dfHEngine.pas',
  dfHGL in '..\common\dfHGL.pas',
  dfHInput in '..\common\dfHInput.pas',
  dfLogger in '..\common\dfLogger.pas',
  dfMath in '..\common\dfMath.pas',
  dfHRenderer in '..\headers\dfHRenderer.pas',
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
  uGUIButton in 'GUI\uGUIButton.pas';

exports
  CreateRenderer, CreateNode, CreateUserRender, CreateHUDSprite,
  CreateMaterial, CreateTexture,
  CreateFont, CreateText;
begin
end.
