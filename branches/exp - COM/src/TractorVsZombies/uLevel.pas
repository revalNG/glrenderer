unit uLevel;

interface

uses
  Windows, SysUtils, Classes,

  dfHRenderer,

  UPhysics2D;

type
  TtzBlock = record
    b2Body: Tb2Body;
    glSprite: IdfSprite;
  end;

  TtzLevel = class
  private
    FBlocks: array of TtzBlock;
    FLevelBorders: array[0..2] of Tb2Body;
    FLevelNode: IdfNode;
  protected
  public
    constructor Create(RootNode: IdfNode); virtual;
    destructor Destroy(); override;

    procedure Update(const dt: Double);

    procedure LoadFromFile(aFile: String);
    procedure SaveToFile(aFile: String);

    procedure Clear();

    {DEBUG!!}
    procedure SetBlocks();
  end;

implementation

uses
  uUtils, uSingletons, uMainFunctions,

  dfMath;

//Структура, хранящаяся в файле и записываемая в файл
type
  TtzBlockRec = packed record
    aPos, aSize: TdfVec2f;
    aRot: Single;
  end;

const
  LEVEL_BLOCK = $0001;

{ TtzLevel }

procedure TtzLevel.Clear;
var
  i: Integer;
begin
  SetLength(FBlocks, 0);
  for i := 0 to High(FLevelBorders) do
    if Assigned(FLevelBorders[i]) then
      vb2World.DestroyBody(FLevelBorders[i]);
end;

constructor TtzLevel.Create(RootNode: IdfNode);
begin
  inherited Create();
  FLevelNode := RootNode.AddNewChild();
end;

destructor TtzLevel.Destroy;
begin

  inherited;
end;

//procedure TtzLevel.LoadFromFile(aFile: String);
//var
//  strData: TFileStream;
//  par: TParser;
//
//  procedure ReadBlock();
//  var
//    ind: Integer;
//    aPos, aSize: TdfVec2f;
//    aRot: Single;
//  begin
//    ind := Length(FBlocks);
//    SetLength(FBlocks, ind + 1);
//    with FBLocks[ind] do
//    begin
//      par.NextToken;    aPos.x  := par.TokenFloat;
//      par.NextToken;    aPos.y  := par.TokenFloat;
//      par.NextToken;    aRot    := par.TokenFloat;
//      par.NextToken;    aSize.x := par.TokenFloat;
//      par.NextToken;    aSize.y := par.TokenFloat;
//
//      glSprite := dfNewSpriteWithNode(FLevelNode);
//      SetSpriteParams(glSprite, aPos, aSize.x, aSize.y, aRot, dfVec4f(0.1, 0.5, 0.1, 1), ppCenter);
//      b2Body := dfb2InitBoxStatic(vb2World, glSprite, 1, 1, 0, $0004, $0002)
//    end;
//  end;
//begin
//  Clear();
//  //Без верха
//  {init borders}
//  FLevelBorders[0] := dfb2InitBoxStatic(vb2World, dfVec2f(0, 300), dfVec2f(5, 600), 0, 1, 1, 0, $0004, $0002);
//  FLevelBorders[1] := dfb2InitBoxStatic(vb2World, dfVec2f(800, 300), dfVec2f(5, 600), 0, 1, 1, 0, $0004, $0002);
//  FLevelBorders[2] := dfb2InitBoxStatic(vb2World, dfVec2f(400, 600), dfVec2f(800, 2), 0, 1, 1, 0, $0004, $0002);
//  try
//    strData := TFileStream.Create(aFile, fmOpenRead);
//    par := TParser.Create(strData);
//    repeat
//      if par.TokenString = 'block' then ReadBlock();
//    until par.NextToken = toEOF;
//  finally
//    par.Free;
//    strData.Free;
//  end;
//end;

procedure TtzLevel.LoadFromFile(aFile: String);

  procedure CreateBlock(bl_rec: TtzBlockRec);
  var
    ind: Integer;
  begin
    ind := Length(FBlocks);
    SetLength(FBlocks, ind + 1);
    with FBLocks[ind], bl_rec do
    begin
      glSprite := dfNewSpriteWithNode(FLevelNode);
      SetSpriteParams(glSprite, aPos, aSize.x, aSize.y, aRot, dfVec4f(0.1, 0.5, 0.1, 1), ppCenter);
      b2Body := dfb2InitBoxStatic(vb2World, glSprite, 1, 1, 0, $0004, $0002)
    end;
  end;

var
  fs: TFileStream;
  _type: Word;
  bl_rec: TtzBlockRec;
begin
  Clear();
  //Без верха
  {init borders}
  FLevelBorders[0] := dfb2InitBoxStatic(vb2World, dfVec2f(0, 300), dfVec2f(5, 600), 0, 1, 1, 0, $0004, $0002);
  FLevelBorders[1] := dfb2InitBoxStatic(vb2World, dfVec2f(800, 300), dfVec2f(5, 600), 0, 1, 1, 0, $0004, $0002);
  FLevelBorders[2] := dfb2InitBoxStatic(vb2World, dfVec2f(400, 600), dfVec2f(800, 2), 0, 1, 1, 0, $0004, $0002);

  fs := TFileStream.Create(aFile, fmOpenRead);
  if fs.Handle = INVALID_HANDLE_VALUE then
  begin
    MessageBox(0, PChar('Error loading level from ' + aFile), PChar('uLevel unit'), MB_OK);
    Exit();
  end;
  while fs.Position < fs.Size do
  begin
    fs.Read(_type, SizeOf(Word));
    if _type = LEVEL_BLOCK then
    begin
      fs.Read(bl_rec, SizeOf(TtzBlockRec));
      CreateBlock(bl_rec);
    end;
  end;
  fs.Free;
end;

procedure TtzLevel.SaveToFile(aFile: String);

  procedure WriteBlock(F: THandle; aBlock: TtzBlock);
  var
    _type: Word;
    bytes_written: Cardinal;
    bl_rec: TtzBlockRec;
  begin
    with aBlock.b2Body, aBlock.glSprite do
    begin
      with bl_rec do
      begin
        aPos := Position;
        aSize := dfVec2f(Width, Height);
        aRot := Rotation;
      end;
      _type := LEVEL_BLOCK;
      WriteFile(f, _type, SizeOf(Word), bytes_written, nil);
      WriteFile(f, bl_rec, SizeOf(bl_rec), bytes_written, nil);
    end;
  end;

var
  f: THandle;
  i: Integer;
begin
  f := CreateFile(PChar(aFile), GENERIC_WRITE, 0, nil, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);
  if f = INVALID_HANDLE_VALUE then
  begin
    MessageBox(0, PChar('Error saving level into ' + aFile), PChar('uLevel unit'), MB_OK);
    Exit();
  end;
  for i := Low(FBlocks) to High(FBlocks) do
    WriteBlock(F, FBlocks[i]);
  CloseHandle(f);
end;

//procedure TtzLevel.SaveToFile(aFile: String);
//
////function SetBuffer(aBlock: TtzBlock): String;
////begin
////  with aBlock.b2Body, aBlock.glSprite do
////    Result := 'block ' +
////    {coords} FloatToStr(Position.x) + ' ' + FloatToStr(Position.y) + ' ' +
////    {rotation} FloatToStr(Rotation) + ' ' +
////    {size} FloatToStr(Width) + ' ' + FloatToStr(Height) + #13#10;
////end;
//
//var
////  f: THandle;
//  i: Integer;
//  fs: TFileStream;
////  bytes_written: Cardinal;
//  buffer: String;
//begin
//  fs := TFileStream.Create(aFile, fmOpenWrite);
//  fs.Seek(0, soFromBeginning);
//  for i := Low(FBlocks) to High(FBlocks) do
//  begin
//    buffer := SetBuffer(FBlocks[i]);
//    fs.WriteBuffer(buffer[1], SizeOf(buffer[1]) * Length(buffer));
//  end;
//  fs.Free;
////    f := CreateFile(PChar(aFile), GENERIC_WRITE, 0, nil, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);
////    if f = INVALID_HANDLE_VALUE then
////    begin
////      MessageBox(0, PChar('Error saving level into ' + aFile), PChar('uLevel unit'), MB_OK);
////      Exit();
////    end;
////  try
////    for i := Low(FBlocks) to High(FBlocks) do
////    begin
////      buffer := SetBuffer(FBlocks[i]);
////      WriteFile(f, buffer[1], SizeOf(buffer[1]) * Length(buffer), bytes_written, nil);
////    end;
////  finally
////    CloseHandle(f);
////  end;
//end;

procedure TtzLevel.SetBlocks;
begin
  //Без верха
  {init borders}
  FLevelBorders[0] := dfb2InitBoxStatic(vb2World, dfVec2f(0, 300), dfVec2f(5, 600), 0, 1, 1, 0, $0004, $0002);
  FLevelBorders[1] := dfb2InitBoxStatic(vb2World, dfVec2f(800, 300), dfVec2f(5, 600), 0, 1, 1, 0, $0004, $0002);
  FLevelBorders[2] := dfb2InitBoxStatic(vb2World, dfVec2f(400, 600), dfVec2f(800, 2), 0, 1, 1, 0, $0004, $0002);

  SetLength(FBlocks, 3);

  FBlocks[0].glSprite := dfNewSpriteWithNode(vRootNode);
  SetSpriteParams(FBlocks[0].glSprite, dfVec2f(100, 120), 200, 20, 0, dfVec4f(0.3, 0.8, 0.3, 1), ppCenter);
  FBlocks[0].b2Body := dfb2InitBoxStatic(vb2World, FBlocks[0].glSprite, 1, 1, 0, $0004, $0002);

  FBlocks[1].glSprite := dfNewSpriteWithNode(vRootNode);
  SetSpriteParams(FBlocks[1].glSprite, dfVec2f(400, 180), 200, 20, 0, dfVec4f(0.3, 0.8, 0.3, 1), ppCenter);
  FBlocks[1].b2Body := dfb2InitBoxStatic(vb2World, FBlocks[1].glSprite, 1, 1, 0, $0004, $0002);

  FBlocks[2].glSprite := dfNewSpriteWithNode(vRootNode);
  SetSpriteParams(FBlocks[2].glSprite, dfVec2f(350, 380), 680, 20, 0, dfVec4f(0.3, 0.8, 0.3, 1), ppCenter);
  FBlocks[2].b2Body := dfb2InitBoxStatic(vb2World, FBlocks[2].glSprite, 1, 1, 0, $0004, $0002);
end;

procedure TtzLevel.Update(const dt: Double);
begin

end;

end.
