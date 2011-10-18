{
  LD - Last Developed - ��� ��� ������� � ��������� ��� � ���� ����

  BUGS:
+  1. TdfNode ������ - �� ������������ left, up � dir
-  2. TdfNode - �������� CreateAsChild � ������������� ����������
+     ��������, ����� ��������� � ���������������� ���� DiF Engine
+  3. TdfNode - ��������� ���������� � �����. ������� ����� �����
?  4. TInterfaceList ������� �������� ������ � �����. ��������� ��� TList, ��
      ���� �����������



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
  Main in 'Main.pas',
  Camera in 'Camera.pas',
  Light in 'Light.pas',
  Sprites in 'Sprites.pas',
  Textures in 'Textures.pas',
  Shaders in 'Shaders.pas',
  Logger in 'Logger.pas',
  dfHEngine in 'common\dfHEngine.pas',
  dfHGL in 'common\dfHGL.pas',
  dfHInput in 'common\dfHInput.pas',
  dfLogger in 'common\dfLogger.pas',
  dfMath in 'common\dfMath.pas',
  dfHRenderer in 'headers\dfHRenderer.pas',
  Node in 'Node.pas',
  ExportFunc in 'ExportFunc.pas';

exports
  CreateRenderer, CreateNode;
begin
end.