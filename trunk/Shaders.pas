unit Shaders;

interface

uses
  Classes,
  dfHGL;

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
    prog: LongWord;
  public
    constructor Create();
    destructor Destroy();

    procedure AttachVertexShader(shader: TShader);
    procedure AttachFragmentShader(shader: TShader);
    procedure DetachVertexShader();
    procedure DetachFragmentShader();

    procedure Link();

    procedure Use();
    procedure UseNull();
  end;

implementation

uses
  SysUtils;

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
  ShaderText.Free;
  inherited;
end;

procedure TShader.LoadFromFile(FileName: PAnsiChar);
var
  v: Integer;
begin
  ShaderText.LoadFromFile(FileName);
  gl.ShaderSource(sh, 1, PChar(ShaderText.Text), nil);
  gl.CompileShader(sh);
  gl.GetShaderiv(sh, GL_COMPILE_STATUS, @v);
  if v = Ord(GL_FALSE) then
  begin
    raise Exception.Create('σορ');
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

procedure TShaderProgram.DetachVertexShader();
begin

end;

procedure TShaderProgram.DetachFragmentShader();
begin

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

end.
