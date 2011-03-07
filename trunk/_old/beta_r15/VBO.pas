unit VBO;

interface

//внутренние функции
function VBOInit(): Integer;
function VBOStep(deltaTime: Single): Integer;
function VBODeInit(): Integer;

implementation

uses
  dfHGL, dfMath, Textures;

var
  bufID, indID, nID, tID: LongInt;
  indices: array[0..35] of byte = (0, 1, 3, //back
                                   0, 3, 2,

                                   4, 6, 7, //front
                                   7, 5, 4,

                                   9, 8, 10, //right
                                   8, 11, 10,

                                   15, 12, 14, //left
                                   15, 13, 12,

                                   19, 17, 16, //top
                                   19, 16, 18,

                                   23, 20, 21, //bottom
                                   23, 22, 20);
  CubeSize: Single = 3.0;

function VBOInit(): Integer;
var
  vertices, normals: array of TdfVec3f;
  tex: array of TdfVec2f;
begin
  SetLength(vertices, 24);
  vertices[0] := dfVec3f(CubeSize/2, CubeSize/2, CubeSize/2);
  vertices[1] := dfVec3f(-CubeSize/2, CubeSize/2, CubeSize/2);
  vertices[2] := dfVec3f(CubeSize/2, -CubeSize/2, CubeSize/2);
  vertices[3] := dfVec3f(-CubeSize/2, -CubeSize/2, CubeSize/2);

  vertices[4] := dfVec3f(CubeSize/2, CubeSize/2, -CubeSize/2);
  vertices[5] := dfVec3f(-CubeSize/2, CubeSize/2, -CubeSize/2);
  vertices[6] := dfVec3f(CubeSize/2, -CubeSize/2, -CubeSize/2);
  vertices[7] := dfVec3f(-CubeSize/2, -CubeSize/2, -CubeSize/2);

  vertices[8] := dfVec3f(CubeSize/2, CubeSize/2, CubeSize/2); //0
  vertices[9] := dfVec3f(CubeSize/2, CubeSize/2, -CubeSize/2); //4
  vertices[10] := dfVec3f(CubeSize/2, -CubeSize/2, -CubeSize/2); //6
  vertices[11] := dfVec3f(CubeSize/2, -CubeSize/2, CubeSize/2); //2

  vertices[12] := dfVec3f(-CubeSize/2, CubeSize/2, CubeSize/2); //1
  vertices[13] := dfVec3f(-CubeSize/2, -CubeSize/2, CubeSize/2); //3
  vertices[14] := dfVec3f(-CubeSize/2, CubeSize/2, -CubeSize/2); //5
  vertices[15] := dfVec3f(-CubeSize/2, -CubeSize/2, -CubeSize/2); //7

  vertices[16] := dfVec3f(CubeSize/2, CubeSize/2, CubeSize/2); //0
  vertices[17] := dfVec3f(-CubeSize/2, CubeSize/2, CubeSize/2); //1
  vertices[18] := dfVec3f(CubeSize/2, CubeSize/2, -CubeSize/2); //4
  vertices[19] := dfVec3f(-CubeSize/2, CubeSize/2, -CubeSize/2); //5

  vertices[20] := dfVec3f(CubeSize/2, -CubeSize/2, CubeSize/2); //2
  vertices[21] := dfVec3f(-CubeSize/2, -CubeSize/2, CubeSize/2); //3
  vertices[22] := dfVec3f(CubeSize/2, -CubeSize/2, -CubeSize/2); //6
  vertices[23] := dfVec3f(-CubeSize/2, -CubeSize/2, -CubeSize/2); //7

  SetLength(normals, 24);
  normals[0] := dfVec3f(0, 0, 1);
  normals[1] := dfVec3f(0, 0, 1);
  normals[2] := dfVec3f(0, 0, 1);
  normals[3] := dfVec3f(0, 0, 1);

  normals[4] := dfVec3f(0, 0, -1);
  normals[5] := dfVec3f(0, 0, -1);
  normals[6] := dfVec3f(0, 0, -1);
  normals[7] := dfVec3f(0, 0, -1);

  normals[8] := dfVec3f(1, 0, 0);
  normals[9] := dfVec3f(1, 0, 0);
  normals[10] := dfVec3f(1, 0, 0);
  normals[11] := dfVec3f(1, 0, 0);

  normals[12] := dfVec3f(-1, 0, 0);
  normals[13] := dfVec3f(-1, 0, 0);
  normals[14] := dfVec3f(-1, 0, 0);
  normals[15] := dfVec3f(-1, 0, 0);

  normals[16] := dfVec3f(0, 1, 0);
  normals[17] := dfVec3f(0, 1, 0);
  normals[18] := dfVec3f(0, 1, 0);
  normals[19] := dfVec3f(0, 1, 0);

  normals[20] := dfVec3f(0, -1, 0);
  normals[21] := dfVec3f(0, -1, 0);
  normals[22] := dfVec3f(0, -1, 0);
  normals[23] := dfVec3f(0, -1, 0);

  SetLength(tex, 24);
  tex[0] := dfVec2f(1, 1);
  tex[1] := dfVec2f(0, 1);
  tex[2] := dfVec2f(1, 0);
  tex[3] := dfVec2f(0, 0);

  tex[4] := dfVec2f(0, 1);
  tex[5] := dfVec2f(1, 1);
  tex[6] := dfVec2f(0, 0);
  tex[7] := dfVec2f(1, 0);

  tex[8] := dfVec2f(0, 1);
  tex[9] := dfVec2f(1, 1);
  tex[10] := dfVec2f(1, 0);
  tex[11] := dfVec2f(0, 0);

  tex[12] := dfVec2f(1, 1);
  tex[13] := dfVec2f(1, 0);
  tex[14] := dfVec2f(0, 1);
  tex[15] := dfVec2f(0, 0);

  tex[16] := dfVec2f(1, 0);
  tex[17] := dfVec2f(0, 0);
  tex[18] := dfVec2f(1, 1);
  tex[19] := dfVec2f(0, 1);

  tex[20] := dfVec2f(1, 1);
  tex[21] := dfVec2f(0, 1);
  tex[22] := dfVec2f(1, 0);
  tex[23] := dfVec2f(0, 0);

  gl.GenBuffers(1, @bufID);
  gl.BindBuffer(GL_ARRAY_BUFFER, bufID);
  gl.BufferData(GL_ARRAY_BUFFER, SizeOf(TdfVec3f)*Length(vertices), @vertices[0], GL_STATIC_DRAW);
  gl.BindBuffer(GL_ARRAY_BUFFER, 0);
  SetLength(vertices, 0);

  gl.GenBuffers(1, @nID);
  gl.BindBuffer(GL_ARRAY_BUFFER, nID);
  gl.BufferData(GL_ARRAY_BUFFER, SizeOf(TdfVec3f)*Length(normals), @normals[0], GL_STATIC_DRAW);
  gl.BindBuffer(GL_ARRAY_BUFFER, 0);
  SetLength(normals, 0);

  gl.GenBuffers(1, @tID);
  gl.BindBuffer(GL_ARRAY_BUFFER, tID);
  gl.BufferData(GL_ARRAY_BUFFER, SizeOf(TdfVec2f)*Length(tex), @tex[0], GL_STATIC_DRAW);
  gl.BindBuffer(GL_ARRAY_BUFFER, 0);
  SetLength(tex, 0);

  gl.GenBuffers(1, @IndID);
  gl.BindBuffer(GL_ELEMENT_ARRAY_BUFFER, IndID);
  gl.BufferData(GL_ELEMENT_ARRAY_BUFFER, SizeOf(Byte)*Length(indices), @indices[0], GL_STATIC_DRAW);
  gl.BindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);

  Result := -10;
end;

function VBOStep(deltaTime: Single): Integer;
begin
  gl.Color3f(1, 1, 1);


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

  gl.DrawElements(GL_TRIANGLES, Length(indices), GL_UNSIGNED_BYTE, nil);

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

end.
