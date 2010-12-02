unit Shaders;

interface

type

  TShader = class
  private
  public
    constructor Create();
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
  public
    constructor Create();
    destructor Destroy();

    procedure AttachVertexShader(shader: TShader);
    procedure AttachFragmentShader(shader: TShader);
  end;

implementation

constructor TShader.Create;
begin
  inherited;
end;

destructor TShader.Destroy;
begin
  inherited;
end;

procedure TShader.LoadFromFile(FileName: PAnsiChar);
begin

end;





constructor TShaderProgram.Create;
begin
  inherited;
end;

destructor TShaderProgram.Destroy;
begin
  inherited;
end;

procedure TShaderProgram.AttachVertexShader(shader: TShader);
begin

end;

procedure TShaderProgram.AttachFragmentShader(shader: TShader);
begin

end;

end.
