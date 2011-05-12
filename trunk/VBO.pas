unit VBO;

interface

uses
  File3ds;

//внутренние функции
function VBOInit(): Integer;
function VBOStep(deltaTime: Single): Integer;
function VBODeInit(): Integer;

function VBOAddDataFromMesh(aMesh: TdfMesh): Integer;

implementation

uses
  dfHGL, dfMath, Textures;

var
  indices: Integer;
  bufID, indID, nID, tID: LongInt;

function VBOInit(): Integer;
begin

end;

function VBOStep(deltaTime: Single): Integer;
begin
  gl.Color3f(0.5, 0.5, 0.5);

  gl.EnableClientState(GL_VERTEX_ARRAY);
  gl.BindBuffer(GL_ARRAY_BUFFER, bufID);
  gl.VertexPointer(3, GL_FLOAT, 0, nil);

  gl.EnableClientState(GL_NORMAL_ARRAY);
  gl.BindBuffer(GL_ARRAY_BUFFER, nID);
  gl.NormalPointer(GL_FLOAT, 0, nil);

  gl.EnableClientState(GL_TEXTURE_COORD_ARRAY);
  gl.BindBuffer(GL_ARRAY_BUFFER, tID);
  gl.TexCoordPointer(2, GL_FLOAT, 0, nil);

  gl.BindBuffer(GL_ELEMENT_ARRAY_BUFFER, IndID);

  gl.DrawElements(GL_TRIANGLES, Indices, GL_UNSIGNED_SHORT, nil);

  gl.DisableClientState(GL_VERTEX_ARRAY);
  gl.DisableClientState(GL_NORMAL_ARRAY);
  gl.DisableClientState(GL_TEXTURE_COORD_ARRAY);
  gl.BindBuffer(GL_ARRAY_BUFFER, 0);
  gl.BindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);

  Result := -10;
end;


function VBODeInit(): Integer;
begin
  gl.DeleteBuffers(1, @bufID);
  gl.DeleteBuffers(1, @indID);
  gl.DeleteBuffers(1, @nID);
  gl.DeleteBuffers(1, @tID);

  Result := -10;
end;

function VBOAddDataFromMesh(aMesh: TdfMesh): Integer;
begin
  gl.GenBuffers(1, @bufID);
  gl.BindBuffer(GL_ARRAY_BUFFER, bufID);
  gl.BufferData(GL_ARRAY_BUFFER, SizeOf(TdfVec3f)*Length(aMesh.FSubMeshes[0].Vertices), @aMesh.FSubMeshes[0].Vertices[0], GL_STATIC_DRAW);
  gl.BindBuffer(GL_ARRAY_BUFFER, 0);

  gl.GenBuffers(1, @nID);
  gl.BindBuffer(GL_ARRAY_BUFFER, nID);
  gl.BufferData(GL_ARRAY_BUFFER, SizeOf(TdfVec3f)*Length(aMesh.FSubMeshes[0].Normals), @aMesh.FSubMeshes[0].Normals[0], GL_STATIC_DRAW);
  gl.BindBuffer(GL_ARRAY_BUFFER, 0);

  gl.GenBuffers(1, @tID);
  gl.BindBuffer(GL_ARRAY_BUFFER, tID);
  gl.BufferData(GL_ARRAY_BUFFER, SizeOf(TdfVec2f)*Length(aMesh.FSubMeshes[0].TexCoords), @aMesh.FSubMeshes[0].TexCoords[0], GL_STATIC_DRAW);
  gl.BindBuffer(GL_ARRAY_BUFFER, 0);

  Indices := Length(aMesh.FSubMeshes[0].Indices);
  gl.GenBuffers(1, @IndID);
  gl.BindBuffer(GL_ELEMENT_ARRAY_BUFFER, IndID);
  gl.BufferData(GL_ELEMENT_ARRAY_BUFFER, SizeOf(Word)*Indices, @aMesh.FSubMeshes[0].Indices[0], GL_STATIC_DRAW);
  gl.BindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
end;

end.
