{Юнит для тестовой загрузки 3ds-моделей}
unit File3ds;

interface

const
    //Chunk ID's
  //  INT_PERCENTAGE = $0030; //hm transparency always has this subchunck
  MAIN3DS = $4D4D;
  VERS3DS = $0002;
  EDIT3DS = $3D3D;
  KEYF3DS = $B000;

  EDIT_OBJECT = $4000;

  MASTER_SCALE = $0100;

  OBJ_HIDDEN = $4010;
  OBJ_VERINFO = $3D3E;
  OBJ_TRIMESH = $4100;
  OBJ_LIGHT = $4600;
  OBJ_CAMERA = $4700;

  TRI_VERTEXL = $4110;
  TRI_FACEL1 = $4120;
  TRI_MATERIAL = $4130;
  TRI_MAPPINGCOORDS = $4140;
  TRI_MATRIX = $4160; //TRI_LOCAL; //Gives a matrix for each mesh?
  TRI_VISIBLE = $4165; //Is mesh visible or not


  MAT_MATRIAL = $AFFF;
  MAT_MATNAME = $A000;
  MAT_AMBIENT = $A010;
  MAT_DIFFUSE = $A020;
  MAT_SPECULAR = $A030;
  MAT_TRANSPARENCY = $A050; // Transparency Material
  MAT_TEXTURE = $A200;  //texmap
  MAT_OPACMAP = $A210;
  MAT_BUMPMAP = $A230;
  MAT_MAPFILE = $A300;
  MAT_VSCALE = $A354;
  MAT_USCALE = $A356;
  MAT_VOFF = $A35A;
  MAT_UOFF = $A358;
  MAT_TEXROT = $A35C;
  MAT_COLOR = $0010;
  MAT_COLOR24 = $0011;
  MAT_TWO_SIDE = $A081; //thanks sos

  KEYF_OBJDES = $B002;
  KEYF_OBJHIERARCH = $B010;
  KEYF_OBJPIVOT = $B013;

type
  TdfMesh = class
  private
  public
    procedure LoadFrom3ds(FileName: PAnsiChar);
  end;

  //Заголовок чанков
  TdfChunkHeader = packed record
    ID    : Word;
    Length: LongWord;
  end;

implementation

uses
  SysUtils, Classes,
  Logger;


{ TdfMesh }

procedure TdfMesh.LoadFrom3ds(FileName: PAnsiChar);
var
  aFileName: String;
  fs: TFileStream;
begin
  aFileName := FileName;
  logWriteMessage('File3ds: Загрузка модели из файла ' + aFileName);
  fs := TFileStream.Create(aFileName, $0000);



  fs.Free;
end;

end.
