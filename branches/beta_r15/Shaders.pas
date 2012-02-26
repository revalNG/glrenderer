unit Shaders;

interface

uses
  Classes,
  dfHGL, dfMath;

type

  TShader = class
  private
    sh: LongWord;
  public
    ShaderText: TStringList;
    constructor Create(_type: TGLConst);
    destructor Destroy();

    procedure LoadFromFile(FileName: PAnsiChar);

  end;

//  TFragmentShader = class
//  private
//  public
//    constructor Create();
//    destructor Destroy();
//
//    procedure LoadFromFile(FileName: PAnsiChar);
//  end;

  TShaderProgram = class
  private
    vs, fs: TShader;
    prog: Integer;
  public
    constructor Create();
    destructor Destroy();

    procedure AttachVertexShader(shader: TShader);
    procedure AttachFragmentShader(shader: TShader);

    procedure Link();

    procedure Use();
    procedure UseNull();

    function GetUniformLocation(const name: String): Integer;

    procedure SetUniforms(const name: String; const value: single;    count: Integer = 1);overload;
    procedure SetUniforms(const name: String; const value: TdfVec2f; count: Integer = 1);overload;
    procedure SetUniforms(const name: String; const value: TdfVec3f; count: Integer = 1);overload;
    procedure SetUniforms(const name: String; const value: TdfVec4f; count: Integer = 1);overload;
    procedure SetUniforms(const name: String; const value: integer;   count: Integer = 1);overload;
//    Procedure SetUniforms(const name : String; const value: TdfVec2i; count: Integer=1);overload;
//    Procedure SetUniforms(const name : String; const value: TdfVec3i; count: Integer=1);overload;
//    Procedure SetUniforms(const name : String; const value: TdfVec4i; count: Integer=1);overload;
//    Procedure SetUniforms(const name : String; const value: TdfMat2f; count: Integer=1; transpose: boolean=false);overload;
//    Procedure SetUniforms(const name : String; const value: TdfMat3f; count: Integer=1; transpose: boolean=false);overload;
    procedure SetUniforms(const name: String; const value: TdfMat4f; count: Integer = 1; transpose: Boolean = False);overload;

  end;

  function shadersInit(): Integer;
  function shadersDeinit(): Integer;

implementation

uses
  SysUtils,
  dfLogger;

var
  slog: Integer;

constructor TShader.Create(_type: TGLConst);
begin
  inherited Create;
  ShaderText := TStringList.Create();
  sh := gl.CreateShader(_type);
end;

destructor TShader.Destroy;
var
  i: Integer;
begin
  gl.DeleteShader(sh);
  for i := 0 to ShaderText.Count - 1 do
    ShaderText[i] := '';
  inherited;
end;

procedure TShader.LoadFromFile(FileName: PAnsiChar);
var
  v, l: Integer;
  pLog: PAnsiChar;
  ptr: PAnsiChar;
begin
  ShaderText.LoadFromFile(FileName, TEncoding.ASCII);
  ptr := PAnsiChar(AnsiString(ShaderText.Text));
  gl.ShaderSource(sh, 1, @ptr, nil);
  ShaderText.Free;
  gl.CompileShader(sh);
  gl.GetShaderiv(sh, GL_COMPILE_STATUS, @v);
  if v = Ord(GL_FALSE) then
  begin
    gl.GetShaderiv(sh, GL_INFO_LOG_LENGTH, @v);
    getmem(pLog, v);
    gl.GetShaderInfoLog(sh, v, l, pLog);
    raise Exception.Create('σορ' + #13#10 + pLog);
    FreeMem(pLog, v);
  end;
end;





constructor TShaderProgram.Create;
begin
  inherited;
  prog := gl.CreateProgram();
end;

destructor TShaderProgram.Destroy;
begin
  inherited;
  gl.DeleteProgram(prog);
  vs.Free;
  fs.Free;
end;

procedure TShaderProgram.AttachVertexShader(shader: TShader);
begin
  gl.AttachShader(prog, shader.sh);
  vs := shader;
end;

procedure TShaderProgram.AttachFragmentShader(shader: TShader);
begin
  gl.AttachShader(prog, shader.sh);
  fs := shader;
end;

procedure TShaderProgram.Link;
var
  v: Integer;
begin
  gl.LinkProgram(prog);
  gl.GetProgramiv(prog, GL_LINK_STATUS, @v);
end;

procedure TShaderProgram.Use();
begin
  gl.UseProgram(prog);
end;

procedure TShaderProgram.UseNull();
begin
  gl.UseProgram(0);
end;

function TShaderProgram.GetUniformLocation(const name: String): Integer;
begin
  Result := gl.GetUniformLocation(prog, PAnsiChar(AnsiString(name)));
  if Result < 0 then
  begin
//    LoggerWriteDateTime(slog, '');
  end;
end;

procedure TShaderProgram.SetUniforms(const name: String; const value: single; count: Integer = 1);
begin
  gl.Uniform1fv(GetUniformLocation(name), count, @value);
end;

procedure TShaderProgram.SetUniforms(const name: String; const value: TdfVec2f; count: Integer = 1);
begin
  gl.Uniform2fv(GetUniformLocation(name), count, @value);
end;

procedure TShaderProgram.SetUniforms(const name: String; const value: TdfVec3f; count: Integer = 1);
begin
  gl.Uniform3fv(GetUniformLocation(name), count, @value);
end;

procedure TShaderProgram.SetUniforms(const name: String; const value: TdfVec4f; count: Integer = 1);
begin
  gl.Uniform4fv(GetUniformLocation(name), count, @value);
end;

procedure TShaderProgram.SetUniforms(const name: String; const value: integer; count: Integer = 1);
begin
  gl.Uniform1iv(GetUniformLocation(name), count, @value);
end;

procedure TShaderProgram.SetUniforms(const name: String; const value: TdfMat4f; count: Integer = 1; transpose: boolean=false);
begin
  gl.UniformMatrix4fv(GetUniformLocation(name), count, transpose, @value);
end;








function shadersInit(): Integer;
begin
  slog := LoggerFindLog('glrenderer.log');
  LoggerWriteDateTime(slog, '');

end;


function shadersDeinit(): Integer;
begin


end;

end.
