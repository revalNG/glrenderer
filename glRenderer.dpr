{
  LD - Last Developed - ��� ��� ������� � ��������� ��� � ���� ����

  2010-10-31 - LD Sprites - ��������� ������� �������� ����� ���� I X Y Z ...
  2010-09-28 - LD Camera, Main - ������� ������. ����� SetCamera �����������.
                                 � ������������ � ��� ���������� ���������
                                 ������ ������ ������.
                                 �������� ������ � WndProc Main.pas
  2010-09-08 - LD Camera   - ����� �������� ��������� ������ � ��������� ����
                           - ������ ���� ����� �����, ��� ������ �� �����.
                             �������� �� ���������� ������. ������ Y ������������.
                             ��. WndProc � Main.pas
  2010-08-25 - LD Textures - ��������� ��������. ������� Fantom �� ������ ��������
  2010-08-08 - LD Sprites - �������� ������ �������.
  2010-07-01 - LD Anim   - ������ ��� renderAnimAddFromFile(). ������� time.
  2010-06-27 - LD Anim   - ������������� ������ - �������� ������ render.
               LD Main   - ����������� renderInit, renderInit2 - �� ����������
                           �������� ������� ����.
               LD Main   - ��������� ��������� ������, ������ � ������� ����
                           �� ��������� (renderInit2)
               LD Main   - ��������� ��������� ��������� ����� �� ���������
                           (renderInit2)
               LD Main   - renderInit ��������� ��� deprecated.

               LD ----   - ���������� �������������� warnings, ��������� �
                           ����������� � ��������� �������� ����������� ��������.
               LD Anim   - ������ ��� renderAnimAddFromFile(). ������ ��� ��������.

  2010-04-26 - LD Anim   - ������ ��� ������������� ������� ����� ��������
  2010-04-20 - LD Main   - renderInit2. �������� ���������� �� ����� ����� ������.
  2010-04-16 - LD Data   - renderDataAddFromFile. ������ ������� ��� ����. ��������
  2010-04-15 - LD Data   - renderDataAddFromFile. ������� ������� ����� TParser
  2010-04-13 - LD Data   - renderDataAddSphere. ���������.
  2010-04-07 - LD Light  - ������ � ����������� ��������� �����
  2010-04-06 - LD Camera - ��������. �������, �������� SetPos � Set.
                           ������� �� �������� ���������.
  2010-04-04 - LD Camera - ��������. ������ Transpose � SetPos. ��������� ���������.
  2010-04-01 - LD Camera - �������� ������, ������ ����-�� �������,
                           �� ����������� �����������.
  2010-03-31 - LD Camera - �������� ������.
  2010-03-31 - LD Light
  2010-03-30 - LD ������ - Set, SetTarget.

  TODO:  \2010-04-13\
         0)������� � ���������� ������������� �����������.
           ���������� ������ ����������� ������ � ������ ������ �������������.
        +1)������� ������� ������
        +2)��������� ��� ������� ������ � ��� ��� ��������������
        ?3)��������� ������������
        +4)light.pas. ���������� ���������� �����
       +-5)����������� �������� ���� ��������� ���������� �� �����:
         + ��������� ����,
         + ��������� ������,
         + ��������� ��������� �����,
           ������������ ���������� (���/���� VBO, shaders � ������)
         6)   Result := -10; //�������
              ������ ������ ���������� �� ���� ��������, ��������� ��������
         7) ���������� / �������� ��������. ����� ��������.

}

{
  glRenderer

  ������ 3� ������������� ��� ���������� ������� (��-061)

  ������:
   - ���������� ������������ ������ ������
   - ������������ ������, �����
   - �������� ���������
   - ����������� "�����" - ��������� ����� ������ � �������� �������
   - ������ ��������

  ������ ����������:
   - ����� ���������
   - ��������� ����������
   - ����������� ������
   - ����� ������
   - �������?
   - ������ ����� � ����

  ������������ ����������:
   - VBO - ��� ������������ �������� ������
     P.S. ����� ����� ������������ ������ ����� ���������� ������ ��� ���������
          ���������� ��������� � ��������� � ������� �������
   - Shaders - ��� ������������ ��������
     P.S. ������������� ��� �������. ������������� ����������� ����������.
   - FBO - ��� RTT.
     P.S. ����������� - �.�. �������� �������� ���������.

  ������������ ��������:
   - ��������������� ����������� �� DLL � �������������� �������.
   - ������ �������������� ������� ��� �������������� ��������� ����
     �������� ��������� 'render'.
   - ������ ������� ������� ���������� ������� �� ��������:
     * (���)  - �������� ������� ��� ������ � ��������������
     * Camera - ������� ������ � �������
     * Data   - ������ � �������
     * Light  - ������ � ���������� �����
     * ...
   - ������ ������� (����� ���������, ���������� ������������) ����������
     ������������� ��� ������. ����������� ����:
     *  0 - ��� �������� ����������
     * -1 - ����������� ������
     ���������� ����������� ���������� ��� ������ ��������������� �������
       ���� ������� �� ��������������� ��������� ����� ������, �� �������� "-1"
     �������� ������ ���������� �������� �/��� ������������ ��������.
   - �������, ����������� ��������� MaxSpeed � Accel, �������� ��������������� ��������������
     � ��������� ������������ ��������� � ��������� ����������.

  ������� �����������
   - ���������� ���������� � ���������. ������������� �������.
   - ������� ������� renderInit(), ������� �� �� ���� ����������� ���������
     (���� ��������������� �������� renderInit2(), ������� �� �� ���� ���� ������������)
     2010-04-20
   - �� ��������� ������ �������� renderDeInit()
}
library glRenderer;

{$R *.res}

uses
  Main in 'Main.pas',
  dglOpenGL in 'dglOpenGL.pas',
  dfHInput in 'dfHInput.pas',
  dfMath in 'dfMath.pas',
  dfHEngine in 'dfHEngine.pas',
  Camera in 'Camera.pas',
  Data in 'Data.pas',
  Light in 'Light.pas',
  Animation in 'Animation.pas',
  VBO in 'VBO.pas',
  Sprites in 'Sprites.pas',
  Log in 'Log.pas',
  Textures in 'Textures.pas';

exports
  renderInit,
  renderInit2,
  renderStep,
  renderDeInit,

  renderWindowSetCaption,
  renderWindowGetHandle,

  renderCameraSet,
  renderCameraSetTarget, renderCameraSetTargetMove,
  renderCameraSetPos, renderCameraSetPosMove,
  renderCameraSetUp, renderCameraSetUpMove,
  renderCameraMoveAroundTarget,

  renderDataAddFromFile,
  renderDataSaveToFile,
  renderDataSphereAdd,
  renderDataSpherePos, renderDataSpherePosMove,
  renderDataSphereRad, renderDataSphereRadMove,
  renderDataSphereRGB, renderDataSphereRGBMove,

  renderDataCylinderAdd,

  renderAnimAddFromFile,
  renderAnimSetSpeed,
  renderAnimGetSpeed,
  renderAnimPlay,
  renderAnimPause,
  renderAnimStop,
  renderAnimNextBlock,
  renderAnimPrevBlock,
  renderAnimJumpToA,
  renderAnimJumpToB,

  renderLightSet,
  renderLightSetPos,  renderLightSetPosMove,
  renderLightSetAmb, renderLightSetAmbMove,
  renderLightSetDif, renderLightSetDifMove,
  renderLightSetSpec, renderLightSetSpecMove,

  renderSpritesAddFromFile;
begin
end.
