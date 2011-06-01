{Юнит для тестовой загрузки 3ds-моделей
}
{ TODO 1 -opd : Убрать дурацкий способ считать нормали, добавить нормальный. }
unit File3ds;

interface

uses
  dfMath;

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
  TdfMaterialType = (mtAmbient, mtDiffuse, mtSpecular);

  { TODO -opd : Позже облагородить класс - добавить геттеры,
    сеттеры для инкапсуляции и прочее }
  TdfMaterial = class
  public
    //Имя материала
    Name: String;
    //Тип материала (см. выше)
    MatType: TdfMaterialType;
    //Пути к файлам текстуры, к картам бампа и прозрачности
    TexturePath: String;
    BumpMapPath: String;
    OpacMaoPath: String;
    //Эмбиент, диффузный ии спекулярный цвета
    Amb, Dif, Spec: TdfVec3f;
    //Прозрачность
    Transparency: Single;
    //Сила бампа
    BumpStrength: Single;
    //Сила прозрачности
    OpacStrength: Single;
    //Есть текстура, есть бамп, есть опасити
    HasTexture, HasBumpMap, HasOpacMap: Boolean;

    //Текстурные координаты U, V: масштаб и смещение
    UScale, VScale, UOff, VOff: Single;
    //Поворот текстуры?
    Rotate: Single;

    TextureID: Integer;
  end;

  TdfFace = packed record
    v1, v2, v3: Word; //Индексы вершин фэйса
    Material: TdfMaterial;
  end;

  TdfSubMesh = class
  public
    Name: String;

    Visible: Boolean;

    Vertices: array of TdfVec3f;
    Indices: array of Word;
    Normals: array of TdfVec3f;
    TexCoords: array of TdfVec2f;
    Faces: array of TdfFace;

    constructor Create; virtual;
    destructor Destroy; override;
  end;

  TdfMesh = class
  private
    procedure SendToVBO;
  public
    FSubMeshes: array of TdfSubMesh;
    FMaterials: array of TdfMaterial;
    constructor Create; virtual;
    destructor Destroy; override;

    procedure LoadFrom3ds(FileName: PAnsiChar);
    function GetMaterial(aName: String): TdfMaterial;
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

constructor TdfMesh.Create;
begin
  inherited;

end;

destructor TdfMesh.Destroy;
var
  i: Integer;
begin
  for i := 0 to Length(FMaterials) - 1 do
    FMaterials[i].Free;
  SetLength(FMaterials, 0);
  for i := 0 to Length(FSubMeshes) - 1 do
    FSubMeshes[i].Free;
  inherited;
end;

function TdfMesh.GetMaterial(aName: String): TdfMaterial;
var
  i: Integer;
begin
  for i := 0 to Length(FMaterials) - 1 do
    if FMaterials[i].Name = aName then
    begin
      Result := FMaterials[i];
      Exit;
    end;
end;

procedure TdfMesh.LoadFrom3ds(FileName: PAnsiChar);
var
  aFileName: String;
  fs: TFileStream;

  chunkHeader: TdfChunkHeader;

  //Версия 3ds файла
  lwVersion: LongWord;
  //Видимо, масштаб сцены
  MasterScale: Single;
  //Количество материалов
  MatCount: Integer;
  //Буфер для побайтового чтения
  chrbuf: Byte;
  //Буфер для чтения 2-байтных значений
  wrdbuf: Word;
  //Буфер для чтения сингловых значений
  sbuf: Single;
  //Путь к карте (текстуре, карте бампа, карте опасити)
  mapname: String;
  //Промежуточные значения для бампа и опасити
  bump, opac, transp: SmallInt;
    //различное представление цвета для материала
  bRGB: array[0..2] of Byte;
  sRGB: TdfVec3f;
  //Количество сабмешей - подобъектов меша
  SubCount: Integer;
  //Число вершин/фейсов и прочего
  vCount: Word;
  //Для счетчика
  i: Integer;
  //Вершина (для чтения)
  vertex: TdfVec3f;
  //UV-координаты
  uv: TdfVec2f;
  //Булевский буфер для чтения
  boolbuf: Boolean;
  //Массив для помеченных вершин (если помечена, значит уже использована в другом фейсе)
  marked: array of Boolean;
  //Индекс для ускорения работы с элементом массива
  ind: Word;
  //Нормаль для фейсов
  normal: TdfVec3f;


  //Проверяет, задействована ли вершина, если да, то дублирует ее, если нет - возвращает старый индекс
  function GetIndex(aInd: Word): Word;
  begin
    if marked[aInd] then
    begin
      //Дублируем вершину
      SetLength(FSubMeshes[SubCount - 1].Vertices, Length(FSubMeshes[SubCount - 1].Vertices) + 1);
      Result := Length(FSubMeshes[SubCount - 1].Vertices) - 1;
      FSubMeshes[SubCount - 1].Vertices[Result] := FSubMeshes[SubCount - 1].Vertices[aInd];

      SetLength(FSubMeshes[SubCount - 1].TexCoords, Length(FSubMeshes[SubCount - 1].TexCoords) + 1);
      FSubMeshes[SubCount - 1].TexCoords[Result] := FSubMeshes[SubCount - 1].TexCoords[aInd];
    end
    else
    begin
      marked[aInd] := True;
      Result := aInd;
    end;
  end;

  function CalcNormal(v1, v2, v3: TdfVec3f): TdfVec3f;
  var
    vec1, vec2: TdfVec3f;
  begin
    vec1 := v1 - v2;
    vec2 := v3 - v2;
    Result := vec1.Cross(vec2);
    Result.Normalize;
  end;
begin
  aFileName := FileName;
  logWriteMessage('File3ds: Загрузка модели из файла ' + aFileName);
  fs := TFileStream.Create(aFileName, $0000);
  MatCount := 0;
//  lwVersion := 0;
//  MasterScale := 0.0;
  SubCount := 0;
  while fs.Position < fs.Size do
  begin
    fs.ReadBuffer(chunkHeader, SizeOf(TdfChunkHeader));
    case chunkHeader.ID of
      MAIN3DS:
      begin
//        logWriteMessage('File3ds: найден chunk MAIN3DS');
        //*?
      end;

      VERS3DS:
      begin
        fs.Read(lwVersion, SizeOf(lwVersion));
        logWriteMessage('File3ds: найден chunk VERS3DS: Версия файла: ' + IntToStr(lwVersion));
      end;

      EDIT3DS:
      begin
        //*?
      end;

      MASTER_SCALE:
      begin
        fs.Read(MasterScale, sizeof(MasterScale));
//        logWriteMessage('File3ds: найден chunk MASTER_SCALE');
      end;

      //read material data
      MAT_MATRIAL:
      begin
        //*?
      end;
      MAT_MATNAME:
      begin
//        logWriteMessage('File3ds: найден chunk MAT_MATNAME');
        Inc(MatCount);
        SetLength(FMaterials, MatCount);
        FMaterials[MatCount - 1] := TdfMaterial.Create;
        FMaterials[MatCount - 1].Name := '';
        FMaterials[MatCount - 1].Transparency := 1.0;
        FMaterials[MatCount - 1].HasTexture := false;
        FMaterials[MatCount - 1].HasBumpMap := false;
        FMaterials[MatCount - 1].HasOpacMap := false;
        chrbuf := 1;
        while chrbuf <> 0 do
        begin
          fs.Read(chrbuf, 1);
          FMaterials[MatCount - 1].Name :=
            FMaterials[MatCount - 1].Name + chr(chrbuf);
        end;
        Delete(FMaterials[MatCount - 1].Name, length(FMaterials[MatCount - 1].Name), 1);
        logWriteMessage('File3ds: добавлен материал ' + FMaterials[MatCount - 1].Name);
      end;
      MAT_AMBIENT:
      begin
//        logWriteMessage('File3ds: найден chunk MAT_AMBIENT');
        FMaterials[MatCount - 1].MatType := mtAmbient;
      end;
      MAT_DIFFUSE:
      begin
//        logWriteMessage('File3ds: найден chunk MAT_DIFFUSE');
        FMaterials[MatCount - 1].MatType := mtDiffuse;
      end;
      MAT_SPECULAR:
      begin
//        logWriteMessage('File3ds: найден chunk MAT_SPECULAR');
        FMaterials[MatCount - 1].MatType := mtSpecular;
      end;

      MAT_TEXTURE:
      begin
//        logWriteMessage('File3ds: найден chunk MAT_TEXTURE');
        with FMaterials[MatCount - 1] do
        begin
          HasTexture := True;
          HasBumpMap := False;
          HasOpacMap := False;
          UScale := 0;
          VScale := 0;
          Uoff := 0;
          Voff := 0;
        end;
      end;
      MAT_BUMPMAP:
      begin
        FMaterials[MatCount - 1].HasBumpMap := True;
        bump := 100;
        fs.Read(wrdbuf, SizeOf(TdfChunkHeader));
        //percentage chunk header overslaan...
        fs.Read(bump, 2);
        FMaterials[MatCount - 1].BumpStrength := bump / 10000.0;
      end;
      MAT_OPACMAP:
      begin
        FMaterials[MatCount - 1].HasOpacMap := True;
        opac := 100;
        fs.Read(wrdbuf, SizeOf(TdfChunkHeader));
        //percentage chunk header overslaan...
        fs.Read(opac, 2);
        FMaterials[MatCount - 1].OpacStrength := opac / 10000.0;
      end;
      MAT_MAPFILE:
      begin
        chrbuf := 1;
        mapname:='';
        while chrbuf <> 0 do
        begin
          fs.Read(chrbuf, 1);
          MapName := MapName + chr(chrbuf);
        end;
        Delete(MapName, length(MapName), 1);

        with FMaterials[MatCount - 1] do
        begin
          if (not HasBumpMap) and (not HasOpacMap) then
            TexturePath := mapname;
          if HasBumpMap then
            BumpMapPath := mapname;
          if HasOpacMap then
            OpacMaoPath := mapname;
        end;
      end;

      MAT_VSCALE:
      begin
        sbuf := 0.0;
        fs.Read(sbuf, 4);
        FMaterials[MatCount - 1].VScale := sbuf;
      end;

      MAT_USCALE:
      begin
        sbuf := 0.0;
        fs.Read(sbuf, 4);
        FMaterials[MatCount - 1].UScale := sbuf;
      end;
      MAT_VOFF:
      begin
        sbuf := 0.0;
        fs.Read(sbuf, 4);
        FMaterials[MatCount - 1].Voff := sbuf;
      end;
      MAT_UOFF:
      begin
        sbuf:=0.0;
        fs.Read(sbuf, 4);
        FMaterials[MatCount - 1].Uoff := sbuf
      end;
      MAT_TEXROT:
      begin
        sbuf:=0.0;
        fs.Read(sbuf, 4);
        FMaterials[MatCount - 1].Rotate := sbuf;
      end;

      MAT_COLOR24:
      begin
        bRGB[0] := 0;
        bRGB[1] := 0;
        bRGB[2] := 0;
        fs.Read(bRGB, SizeOf(bRGB));
        with FMaterials[MatCount - 1] do
          case MatType of
            mtAmbient:
            begin
              Amb.x := bRGB[0] / 255;
              Amb.y := bRGB[1] / 255;
              Amb.z := bRGB[2] / 255;
            end;
            mtDiffuse:
            begin
              Dif.x := bRGB[0] / 255;
              Dif.y := bRGB[1] / 255;
              Dif.z := bRGB[2] / 255;
            end;
            mtSpecular:
            begin
              Spec.x := bRGB[0] / 255;
              Spec.y := bRGB[1] / 255;
              Spec.z := bRGB[2] / 255;
            end;
          end;
      end;
      MAT_COLOR:
      begin
        sRGB.x := 0.0;
        sRGB.y := 0.0;
        sRGB.z := 0.0;

        fs.Read(sRGB, SizeOf(TdfVec3f));
        with FMaterials[MatCount - 1] do
          case MatType of
            mtAmbient:
            begin
              Amb.x := sRGB.x;
              Amb.y := sRGB.y;
              Amb.z := sRGB.z;
            end;
            mtDiffuse:
            begin
              Dif.x := sRGB.x;
              Dif.y := sRGB.y;
              Dif.z := sRGB.z;
            end;
            mtSpecular:
            begin
              Spec.x := sRGB.x;
              Spec.y := sRGB.y;
              Spec.z := sRGB.z;
            end;
          end;
      end;

//      MAT_TRANSPARENCY:
//      begin
//        transp := 100;
//        fs.Read(wrdbuf, sizeof(TdfChunkHeader));
//        //percentage chunk header overslaan...
//        fs.Read(transp, 2);
//        FMaterials[MatCount - 1].Transparency := 1.0 - transp / 100.0;
//      end;
//      MAT_TWO_SIDE :
//      begin
////        // This chunk contains nothing but the header. If it's present,
////        // the current material is two-sided and won't get backface-culled
////        FMaterial[mcount-1].TwoSided := True;
//      end;

      //read submeshes (objects) ...
      EDIT_OBJECT{, OBJ_HIDDEN}:
      begin
        Inc(SubCount);
        SetLength(FSubMeshes, SubCount);
//        SetLength(FRenderOrder, SubCount);
        chrbuf := 1;
        FSubMeshes[SubCount - 1] := TdfSubMesh.Create;
        FSubMeshes[SubCount - 1].Visible := True;
        FSubMeshes[SubCount - 1].Name := '';
//        FSubMeshes[SubCount - 1].Id:=acount; //store an id per mesh...
//        FRenderOrder[acount - 1] := acount - 1;
        while chrbuf <> 0 do
        begin
          fs.Read(chrbuf, 1);
          FSubMeshes[SubCount - 1].Name :=
            FSubMeshes[SubCount - 1].Name + chr(chrbuf);
        end;
        Delete(FSubMeshes[SubCount - 1].Name, length(FSubMeshes[SubCount - 1].Name), 1);

        //TODO: add procedure to mesh to add material
        //set dummy material
        //setlength(FMesh[acount - 1].MatName, 1);
//        FMesh[acount - 1].MatName[0] := ''; //???

      end;
      OBJ_TRIMESH:
      begin
//        matarr := 0; //reset matarr to 0 for every submesh
//        FNumMeshes := FNumMeshes + 1;
      end;
      OBJ_LIGHT:
      begin
        //do nothing yet skip it
        fs.Seek(chunkHeader.Length - SizeOf(TdfChunkHeader), soFromCurrent);
//        FNumMeshes := FNumMeshes + 1;
      end;
      OBJ_CAMERA:
      begin
        //do nothing yet skip it
        fs.Seek(chunkHeader.Length - SizeOf(TdfChunkHeader), soFromCurrent);
//        FNumMeshes := FNumMeshes + 1;
      end;

      //ReadVertices...
      TRI_VERTEXL:
      begin
        fs.Read(vCount, 2);
        logWriteMessage('File3ds: Количество вершин в Vertex List: ' + IntToStr(vCount));
        if vCount > 0 then
        begin
//          FSubMeshes[SubCount - 1].VertexCount := vCount;
          SetLength(FSubmeshes[SubCount - 1].Vertices, vCount);
          SetLength(marked, vCount);

          for i := 0 to vCount - 1 do
          begin
            fs.Read(vertex, 12);
            FSubMeshes[SubCount - 1].Vertices[i].x := vertex.x;
            FSubMeshes[SubCount - 1].Vertices[i].y := vertex.y;
            FSubMeshes[SubCount - 1].Vertices[i].z := vertex.z;
            marked[i] := False;

//            //Set dummy values for meshes without mapping
//            tempmap.tu := 0;
//            tempmap.tv := 0;
//            FMesh[acount - 1].Mapping[i] := tempmap;
          end;
        end
        else
        begin
          SetLength(FSubmeshes[SubCount - 1].Vertices, 0);
        end;
      end;
      TRI_MAPPINGCOORDS:
      begin
        fs.Read(vCount, 2);
        //For meshes with texture coord load them from 3ds
        logWriteMessage('File3ds: Количество вертексов для текстурных координат: ' + IntToStr(vCount));
        SetLength(FSubMeshes[SubCount - 1].TexCoords, vCount);
        for i := 0 to vCount - 1 do
        begin
          fs.Read(uv, 8);
          FSubMeshes[SubCount - 1].TexCoords[i] := uv;
        end;
      end;
//      TRI_MATERIAL:
//      begin
//        chrbuf := 1;
//        inc(matarr);
//        //TODO: reimplement setnumber of materials...
//        //setlength(FMesh[acount - 1].MatName, matarr);
//        FMesh[acount - 1].MatName[matarr - 1] := '';
//        while chrbuf <> 0 do
//        begin
//          fs.Read(chrbuf, 1);
//          FMesh[acount - 1].MatName[matarr - 1] :=
//            FMesh[acount - 1].MatName[matarr - 1] + chr(chrbuf);
//        end;
//        StringBuffer:=string(FMesh[acount - 1].MatName[matarr - 1]);
//        Delete(StringBuffer, length(StringBuffer), 1);
//        FMesh[acount - 1].MatName[matarr - 1]:='';
//        FMesh[acount - 1].MatName[matarr - 1]:=StringBuffer;
//
//        //look up and set matid for vertices with this material
//        fs.Read(matcount, 2);
//        if matcount > 0 then //hmm matcount should be higher then 0????
//        begin
//          //TODO: Rewrite Reimplement Number of MatId.
//          //SetLength(FMesh[acount - 1].MatId,
//          //  FMesh[acount - 1].NumFaces div 3);
//          for matcountloop := 0 to matcount - 1 do
//          begin
//            fs.Read(mati, 2);
//            FMesh[acount - 1].MatId[mati] :=
//              GetMaterialIDbyName(FMesh[acount - 1].MatName[matarr - 1]);
//          end;
//        end;
//      end;
      TRI_VISIBLE:
      begin
        //By default all meshes are visible as the only values returned seem to be false
        fs.Read(boolbuf, 1);
        FSubMeshes[SubCount - 1].Visible := boolbuf;
      end;

      TRI_FACEL1:
      begin
        fs.Read(vCount, 2);
        logWriteMessage('File3ds: найден chunk FaceList, количество фейсов: ' + IntToStr(vCount));
        SetLength(FSubMeshes[SubCount - 1].Indices, vCount * 3);
        SetLength(FSubMeshes[SubCount - 1].Normals, vCount * 3);
        SetLength(FSubMeshes[SubCount - 1].Faces, vCount);
//        FMesh[acount - 1].NumVertexIndices := Count * 3;
//        FMesh[acount - 1].NumNormals := Count * 3;
//        FMesh[acount - 1].NumNormalIndices := Count * 3;
//        FMesh[acount - 1].NumMappingIndices := Count * 3;
        //FMesh[acount - 1].NumFaceRecords := Count;

        for i := 0 to vCount - 1 do
        begin
          wrdbuf := 0;
          fs.Read(wrdbuf, 2);
          ind := GetIndex(wrdbuf);
          FSubMeshes[SubCount - 1].Indices[i * 3] := ind;
          FSubMeshes[SubCount - 1].Faces[i].v1 := ind;

          wrdbuf := 0;
          fs.Read(wrdbuf, 2);
          ind := GetIndex(wrdbuf);
          FSubMeshes[SubCount - 1].Indices[i * 3 + 1] := ind;
          FSubMeshes[SubCount - 1].Faces[i].v2 := ind;

          wrdbuf := 0;
          fs.Read(wrdbuf, 2);
          ind := GetIndex(wrdbuf);
          FSubMeshes[SubCount - 1].Indices[i * 3 + 2] := ind;
          FSubMeshes[SubCount - 1].Faces[i].v3 := ind;

          wrdbuf := 0;
          //Читаем флаги и предательски их не используем
          fs.Read(wrdbuf, 2);
          with FSubMeshes[SubCount - 1] do
            normal := CalcNormal(Vertices[Faces[i].v1],
                                 Vertices[Faces[i].v2],
                                 Vertices[Faces[i].v3]);
          //TODO: А здесь надо убрать этот стыд и рассчитывать нормали правильно
          FSubMeshes[SubCount - 1].Normals[i * 3    ] := normal;
          FSubMeshes[SubCount - 1].Normals[i * 3 + 1] := normal;
          FSubMeshes[SubCount - 1].Normals[i * 3 + 2] := normal;
        end;
      end

//      TRI_MATRIX:
//      begin
//          //Chunk.Data.MeshMatrix := AllocMem(SizeOf(TMeshMatrix));
//
//          for i := 0 to 11 do
//          begin
//          WordBuffer:=0;
//          stream.ReafsleBuffer, sizeof(singlebuffer));
//          FMesh[acount -1].Matrix[i] := SingleBuffer;
//          end;
//          FMesh[acount -1].Matrix[12] := 0;
//          FMesh[acount -1].Matrix[13] := 0;
//          FMesh[acount -1].Matrix[14] := 0;
//          FMesh[acount -1].Matrix[15] := 1;
//
//      end;

//      // read in keyframe data if available (for now only for pivot)
//      KEYF3DS:
//      begin
//        //No nothing seems to be needed here...
//      end;
//      KEYF_OBJDES:
//      begin
//        //if all is ok then for every submesh a keyf_objdes exists
//        inc(keyfcount);
//      end;
//      KEYF_OBJPIVOT:
//      begin
//        //read in pivot point
//        stream.Reafs12);
//        if keyfcount <= FNumMeshes then
//          //stupid way to do, but some 3ds files have less meshes then 'bones'
//          FMesh[keyfcount - 1].Pivot := tv;
//      end;
      else
        fs.Seek(chunkHeader.Length - sizeof(TdfChunkHeader), soFromCurrent);
    end;
  end;

  fs.Free;
end;

procedure TdfMesh.SendToVBO;
begin

end;

{ TdfSubMesh }

constructor TdfSubMesh.Create;
begin
  inherited;
end;

destructor TdfSubMesh.Destroy;
begin
  SetLength(Vertices, 0);
  SetLength(Indices, 0);
  SetLength(Normals, 0);
  SetLength(TexCoords, 0);
  inherited;
end;

end.
