unit uMain;

interface

uses
  dfHRenderer, dfMath, dfHUtility,

  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls;

type
  TtzEarthNode = record
    position: TdfVec2f;
    pointSprite: IdfSprite;
  end;

  TtzEarthMode = (emNewPoints, emSelectPoints);

  TForm1 = class(TForm)
    Panel1: TPanel;
    Button1: TButton;
    Button2: TButton;
    GroupBox1: TGroupBox;
    btnEarthPathCreate: TButton;
    btnEarthPathSelect: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Timer1: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure btnEarthPathSelectClick(Sender: TObject);
    procedure btnEarthPathCreateClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);

  private
  public
  end;

  TtzMyThread = class(TThread)
    procedure Execute(); override;
  end;

  procedure AddNewPointToEarthPath(X, Y: Integer; AtIndex: Integer);

  procedure glrOnEarthRender(); stdcall;
  procedure glrOnUpdate(const dt: Double);
  procedure glrOnMouseDown(X, Y: Integer; MouseButton: TdfMouseButton; Shift: TdfMouseShiftState);

var
  Form1: TForm1;

  FRenderer: IdfRenderer;
  FRenThread: TtzMyThread;

  EarthMode: TtzEarthMode;
  vp: TdfViewportParams;

  {}
  EarthPath: array of TtzEarthNode;
  EarthRenderer: IdfUserRenderable;

implementation

uses
  dfHGL;

procedure AddNewPointToEarthPath(X, Y: Integer; AtIndex: Integer);

  procedure SlideArray(StartIndex: Integer);
  var
    i: Integer;
  begin
    for i := High(EarthPath) - 1 downto StartIndex do
      EarthPath[i + 1] := EarthPath[i];
  end;

var
  ind: Integer;
begin
  //Добавляем новую точку
  ind := Length(EarthPath);
  SetLength(EarthPath, ind + 1);
  //Если необходимо вставить на существующую позицию, то сдвигаем массив
  if AtIndex < ind then
    SlideArray(atIndex);

  with EarthPath[atIndex] do
  begin
    position := dfVec2f(X, Y);
    pointSprite := dfNewSpriteWithNode(FRenderer.RootNode);
    pointSprite.Position := position;
    pointSprite.Width := 5;
    pointSprite.Height := 5;
    pointSprite.PivotPoint := ppCenter;
  end;

  Form1.Caption := 'X: ' + IntToStr(X) + '; Y: ' + IntToStr(Y);
end;

procedure glrOnEarthRender();
var
  i: Integer;
begin
//  wglMakeCurrent(FRenderer.DC, FRenderer.RC);
  gl.MatrixMode(GL_PROJECTION);
  gl.PushMatrix();
  gl.LoadIdentity();
  vp := FRenderer.Camera.GetViewport();
  gl.Ortho(vp.X, vp.W, vp.H, vp.Y, -1, 1);
//  gl.Ortho(0, 600, 450, 0, -1, 1);
  gl.MatrixMode(GL_MODELVIEW);
  gl.LoadIdentity();
//  gl.Translatef(FPos.x, FPos.y, 0);
//  gl.Rotatef(FRot, 0, 0, 1);
  gl.Disable(GL_DEPTH_TEST);
  gl.Disable(GL_LIGHTING);
  gl.Beginp(GL_LINE_STRIP);
    for i := Low(EarthPath) to High(EarthPath) do
      gl.Vertex2fv(EarthPath[i].position);
  gl.Endp;

  {Debug - выводим pivot point}
{
  gl.PointSize(5);
  gl.Color3f(1, 1, 1);
  gl.Translatef(-FPos.x, -FPos.y, 0);
  gl.Beginp(GL_POINTS);
    gl.Vertex2fv(FPos);
  gl.Endp();

}

  gl.Enable(GL_LIGHTING);
  gl.Enable(GL_DEPTH_TEST);
  gl.MatrixMode(GL_PROJECTION);
  gl.PopMatrix();
  gl.MatrixMode(GL_MODELVIEW);
//  wglMakeCurrent(0, 0)
end;

procedure glrOnUpdate(const dt: Double);
begin
  //*
end;

procedure glrOnMouseDown(X, Y: Integer; MouseButton: TdfMouseButton; Shift: TdfMouseShiftState);
begin
  if MouseButton = TdfMouseButton(mbLeft) then
    case EarthMode of
      emNewPoints: AddNewPointToEarthPath(X, Y, High(EarthPath) + 1);
      emSelectPoints: ;
    end;
end;

{$R *.dfm}

procedure TForm1.btnEarthPathCreateClick(Sender: TObject);
begin
  EarthMode := emNewPoints;
  btnEarthPathCreate.Enabled := False;
  btnEarthPathSelect.Enabled := True;
end;

procedure TForm1.btnEarthPathSelectClick(Sender: TObject);
begin
  EarthMode := emSelectPoints;
  btnEarthPathSelect.Enabled := False;
  btnEarthPathCreate.Enabled := True;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  //Инициализация
  //*
  Button1.Enabled := False;
  FRenderer := dfCreateRenderer();
  Caption := 'glRenderer in VCL :: ' + FRenderer.VersionText;
  FRenderer.Init(Panel1.Handle, 'settings.txt');
  FRenderer.OnUpdate := glrOnUpdate;
  FRenderer.OnMouseDown := glrOnMouseDown;
  Button2.Enabled := True;
  btnEarthPathSelectClick(Self);

  //Создаем рендерер земли
  EarthRenderer := dfCreateUserRender();

  with dfCreateNode(FRenderer.RootNode) do
    Renderable := EarthRenderer;

  EarthRenderer.OnRender := glrOnEarthRender;
//  FRenThread := TtzMyThread.Create(True);
//  FRenThread.FreeOnTerminate := True;
//  FRenThread.Resume;
  FRenderer.Start();
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  //Деинициализация
  Button2.Enabled := False;
  if Assigned(FRenderer) then
  begin
    FRenderer.Stop();
//    FRenThread.Suspend;
//    FRenThread.Terminate;
//    FRenThread.Free;
    FRenderer.DeInit();
    FRenderer := nil;
  end;
  Button1.Enabled := True;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Assigned(FRenderer) then
    Button2Click(Sender);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  LoadRendererLib();
  gl.Init();
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  Panel1.Update;
  Label1.Caption := 'Панель: ' + IntToStr(Panel1.Width) + ' ' + IntToStr(Panel1.Height);
  if Assigned(FRenderer) then
  begin
    Label2.Caption := 'У Renderer-а: ' + IntToStr(FRenderer.WindowWidth) + ' ' + IntToStr(FRenderer.WindowHeight);
  end;
end;

{ TtzMyThread }

procedure TtzMyThread.Execute;
begin
  inherited;
  FRenderer.Start();
end;

end.
