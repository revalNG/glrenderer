{
  �����: ���������� fStartTime, fEndTimeX ������ ����������� �� �����
         ���������� ��������. ����������:
         1) ������
         2) ��������������� ������, ���������� ����������� � ������ ����.
         ?

  �����: ����� �������� �������� ���� Create ������� ����� � renderDataAddRomFile.
         � ������ ������� - ����� ����������� ������ �������, ��� ��������.
         ����� - �������� renderDataAddFromFile.

  ��������� � Data.pas ������, ����������� �������� � �������������� ��.
  TODO:  0) ������������ 1.0 �� ������ ����� ��������
         1) ���������� ��� ��������. ���������. ��������, �������� �������� �� �����?
         2) ���������� ��������� ��������.
}
unit Animation;

interface

const

  cCurrentVersion = 1;
  //������������ ���������� �������� � �����
  cMaxAnimsInBlock = 24;
  //������������ ����� ���������� � ��������
  cMaxParamsInAnim = 8;

  //�������������� �������� ��������
  cidCameraAnim   = 0;
  cidSphereAnim   = 1;
  cidCylinderAnim = 2;
  cidCubeAnim     = 3;

  //�������������� ����� ��������

  //����� ���� ��������
  cidPosAnim      = 0;
  cidDirAnim      = 1;
  cidUpAnim       = 2;
  cidColorAnim    = 3;

  //������������� ���� ��������
  cidLookAnim       = 8;
  cidMoveAroundAnim = 9;
  cidRadiusAnim     = 10;



  {
    �������� �������� �� �����
    ������ ����� ��������:

    version 1                 - ������ ������� ��������. ������� - 1
    decimalseparator .        - ��������� ����������� ����� � ������� ������

    time <X, next+X, nextall+X>
       - ��������� �� ����� ���� ��������.
       ��� ��������, ��������� � ����� ����� ��������, ���������� �������������.
       X           - �����, � ��������, � ������� ������ ����������� ������
                     ���� ��������.
       next+X      - ������ ���� ������ �������� ����� ���������� ���������
                     ���������� � ���������� ����� �������� (������ ���������,
                     �.�. �� �� ���������� ��������� ���� �������� �����������
                     �����) � ����������� (���������) � X ������.
       nextall+X   - ������ ���� ������ ����������� ����� ���������� ����
                     �������� ����������� ����� � ����������� (���������) � X
                     ������

    ��� ������� ������ ����� �������� ������
         name <���_�����>
    ������� ����� ����� ��������� �������� ���

    ��������� �������� �����:
    1) camera <��� ��������> <���������>
         �������� ������. �������� ����� ��������
         ��� ��������:
         * pos   - ��������� ������� ������.
           ���������:
             X Y Z     - ���������� �������, ����� � ��������� �������
             MaxSpeed  - ������������ ��������, ����� � ��������� �������
             Accel     - ���������, ����� � ��������� �������
             FixTarget - �������, ���� ��������� ��������� "�������" �� ����
         * look  - ��������� ������� ����� ������
           ���������:
             LX LY LZ   - ���������� ������� ����� ������, ����� � ��������� �������
             MaxSpeed   - ������������ ��������, ����� � ��������� �������
             Accel      - ���������, ����� � ��������� �������
         * up    - ��������� ����������� "�����" ������
           ���������:
             UpX UpY UpZ - ����� ������ ����� ������, ����� � ��������� �������
             MaxSpeed   - ������������ ��������, ����� � ��������� �������
             Accel      - ���������, ����� � ��������� �������
         ...etc...

    2) <��� �������> <��� �������> <��� ��������> <���������>
         ��� ������� - sphere, cylinder, cube, etc...
         ��� ������� - �����(���) �������.
           ����������: ��� ������� ���������� ������� �������� �������.
         ��� ��������:
         * pos - ��������� �������
           ���������:
             X Y Z     - ���������� �������, ����� � ��������� �������
             MaxSpeed  - ������������ ��������, ����� � ��������� �������
             Accel     - ���������, ����� � ��������� �������
         * up - ��������� ������� �����
           ���������:
             UpX UpY UpZ - ����� ������ �����, ����� � ��������� �������
             MaxSpeed    - ������������ ��������, ����� � ��������� �������
             Accel       - ���������, ����� � ��������� �������
         * dir - ��������� ������� �����������
           ���������:
             DirX DirY DirZ - ����� ������ �����������, ����� � ��������� �������
             MaxSpeed       - ������������ ��������, ����� � ��������� �������
             Accel          - ���������, ����� � ��������� �������
         * col - ��������� �����
           ���������:
             R G B A  - ���� ������� + ������������, ����� � ��������� �������
             MaxSpeed - ������������ ��������, ����� � ��������� �������
             Accel    - ���������, ����� � ��������� �������
  }
  function renderAnimAddFromFile(FileName: PAnsiChar): Integer; stdcall;
  function renderAnimSetSpeed(Speed: Single): Integer; stdcall;
  function renderAnimGetSpeed: Single; stdcall;
  function renderAnimPlay: Integer; stdcall;
  function renderAnimPause: Integer; stdcall;
  function renderAnimStop: Integer; stdcall;
  function renderAnimNextBlock: Integer; stdcall;
  function renderAnimPrevBlock: Integer; stdcall;
  function renderAnimJumpToA(blockName: PAnsiChar): Integer; stdcall;
  function renderAnimJumpToB(blockNumber: Integer): Integer; stdcall;

  //���������� ������� ����
  function AnimInit(): Integer;
  function AnimStep(deltaTime: Single): Integer;
  function AnimDeInit(): Integer;

  //d - debug
  function d_renderAnimSaveToFile(FileName: PAnsiChar): Integer; stdcall;

type

{2010-06-27: ������ ������� ���������}

  //�������� - ���������� ���������� ���������, �������� CameraSetPosMove � �.�.
  TrenderAnim = record
    ObjectType,        //��� ������� (��������, camera)
    AnimType: Integer; //��� �������� (pos, dir, up, create, destroy, ...)
    pars: array [0..cMaxParamsInAnim - 1] of Single; //��������� ��������
  end;

  //���� ��������, ������������� ����� �������� time � �����
  //���������� - ����� �������� (TrenderAnim), ������������� ������������
  TrenderAnimBlock = record
  public
    cName: PAnsiChar;      //��� �����

    fTimeStart: Single;    //����� � ������� ������ ����������� ������ ����.
    fTimeEndLast: Single;  //����� ���������� ��������� �������� �����
    fTimeEndAll: Single;   //����� ��������� ���� �������� �����

    bDoneLast,             //����, ��� ��������� ��������� �������� �����
    bDoneAll: Boolean;     //����, ��� ��������� ��� �������� �����

    aAnims: array[0..cMaxAnimsInBlock - 1] of TrenderAnim;
  end;

  PrenderAnimBlock = ^TrenderAnimBlock;

  //�������� ��������, ��������� ��������� ��������
  TrenderAnimManager = class
  private
    FBlocks: array of TrenderAnimBlock;
    FCurrent: PrenderAnimBlock;
    FSpeed: Single;
    FPaused: Boolean;
    function Step(deltaTime: Single): Integer;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    property Speed: Single read FSpeed write FSpeed;
    function Play: Integer;
    function Pause: Integer;
    function Stop: Integer;
    function NextBlock: Integer;
    function PrevBlock: Integer;
    function JumpTo(blockName: PAnsiChar): Integer; overload;
    function JumpTo(blockNumber: Integer): Integer; overload;

    //���������� fTimeStart, fTimeEndLast, fTimeEndAll ��� ������
    function CalculateTimes(): Integer;
    function AddBlock(aName: PAnsiChar): PrenderAnimBlock;
  end;

implementation

uses
  Classes, SysUtils;

var
  AnimManager: TrenderAnimManager;

function TrenderAnimManager.Step(deltaTime: Single): Integer;
begin
  Result := -10;
end;

constructor TrenderAnimManager.Create;
begin
  inherited;
  SetLength(FBlocks, 0);
  FCurrent := nil;
end;

destructor TrenderAnimManager.Destroy;
begin
  SetLength(FBlocks, 0);
  FCurrent := nil;
  inherited;
end;

function TrenderAnimManager.Play: Integer;
begin
  Result := -10;
end;

function TrenderAnimManager.Pause: Integer;
begin
  Result := -10;
end;

function TrenderAnimManager.Stop: Integer;
begin
  Result := -10;
end;

function TrenderAnimManager.NextBlock: Integer;
begin
  Result := -10;
end;

function TrenderAnimManager.PrevBlock: Integer;
begin
  Result := -10;
end;

function TrenderAnimManager.JumpTo(blockName: PAnsiChar): Integer;
begin
  Result := -10;
end;

function TrenderAnimManager.JumpTo(blockNumber: Integer): Integer;
begin
  Result := -10;
end;


function TrenderAnimManager.CalculateTimes: Integer;
begin
  Result := -10;
end;

function TrenderAnimManager.AddBlock(aName: PAnsiChar): PrenderAnimBlock;
var
  i, j, ind: Integer;
begin
  //�� ������, ��� � ������� ����� ���� ���� �����
  //������������, ������ ���������� ��� ���������� �������
  ind := Length(FBlocks);
  SetLength(FBlocks, ind + 1);
  with FBlocks[ind] do
  begin
    cName := aName;
    fTimeStart := 0;
    fTimeEndLast := 0;
    fTimeEndAll := 0;
    for i := 0 to cMaxAnimsInBlock - 1 do
    begin
      aAnims[i].ObjectType := 0;
      aAnims[i].AnimType := 0;
      for j := 0 to cMaxParamsInAnim - 1 do
        aAnims[i].pars[j] := 0;
    end;
  end;
  Result := @FBlocks[ind];
end;



function renderAnimAddFromFile(FileName: PAnsiChar): Integer; stdcall;
var
  strData: TFileStream;
  par: TParser;
  TimeStart, TimeEndLast, TimeEndAll, t: Single;
  CurBlock: PrenderAnimBlock;

  function CalcStartTime(NextAll: Boolean; Strafe: Single): Single;
  begin
    //������� ����� ������ �����, ������ CurBlock - ���������� ����
    if CurBlock <> nil then
    begin
      if NextAll then
        Result := Strafe + CurBlock.fTimeEndAll
      else
        Result := Strafe + CurBlock.fTimeEndLast;
    end
    else
      Result := Strafe;
  end;

  function CalcEndTime(): Single;
  begin
    //������� ����� ���������� ��� �������� �����.
    //���������� � CurBlock
  end;

begin
  CurBlock := nil;
  try
    if FileExists(FileName) then
      strData := TFileStream.Create(FileName, fmOpenRead)
    else
      raise Exception.Create('No such a file');
    par := TParser.Create(strData);
    repeat
// ----->>>>>>>

      if par.TokenString = 'camera' then
      begin
        //*
        //������ ��������� ��������
        //���������� �� � ������� ���� ����� ��������
      end


      //���� ����
      else if par.TokenString = 'time' then
      begin
        //������� ����� ���� ��������, ��������� ��� �������
        //������ ����� ���������� ����� - ������, next, � �.�.
        par.NextToken;
        if par.Token = toFloat then
          //����� ���������� ���������� ����� ������ ����������
          TimeStart := par.TokenFloat
        else if par.TokenString = 'next' then
        begin
          par.NextToken; //���� '+'
          par.NextToken; //��������
          t := par.TokenFloat;
          TimeStart := CalcStartTime(False, t);
          //*
        end
        else if par.TokenString = 'nextall' then
        begin
          par.NextToken; //���� '+'
          par.NextToken; //��������
          t := par.TokenFloat;
          TimeStart := CalcStartTime(True, t);
          //*
        end;

        //*
        CurBlock := AnimManager.AddBlock('');
        CalcEndTime();
      end

      else if par.TokenString = 'name' then
      begin
        par.NextToken;
        CurBlock^.cName := PAnsiChar(par.TokenString);
      end

       //���������� ������
      else if par.TokenString = 'version' then
      begin
        par.NextToken;
        if par.TokenInt <> cCurrentVersion then
          raise Exception.Create('Bad version');
      end
      //����������� ����� � ������� �����
      else if par.TokenString = 'decimalseparator' then
      begin
        par.NextToken;
        DecimalSeparator := par.TokenString[1];
      end;
    until par.NextToken = toEOF;
    par.Free;
    strData.Free();
  except
    on E:Exception do
    begin
      Result := StrToInt(e.Message + ' on line ' + IntTostr(par.SourceLine)
                         + ' at pos ' + IntToStr(par.SourcePos));
    end;
  end;
  Result := -10;
end;

function renderAnimSetSpeed(Speed: Single): Integer; stdcall;
begin
  AnimManager.Speed := Speed;
  Result := -10;
end;

function renderAnimGetSpeed: Single; stdcall;
begin
  Result := AnimManager.Speed;
end;

function renderAnimPlay: Integer; stdcall;
begin
  Result := AnimManager.Play;
end;

function renderAnimPause: Integer; stdcall;
begin
  Result := AnimManager.Pause;
end;

function renderAnimStop: Integer; stdcall;
begin
  Result := AnimManager.Stop;
end;

function renderAnimNextBlock: Integer; stdcall;
begin
  Result := AnimManager.NextBlock;
end;

function renderAnimPrevBlock: Integer; stdcall;
begin
  Result := AnimManager.PrevBlock;
end;

function renderAnimJumpToA(blockName: PAnsiChar): Integer; stdcall;
begin
  Result := AnimManager.JumpTo(blockName);
end;

function renderAnimJumpToB(blockNumber: Integer): Integer; stdcall;
begin
  Result := AnimManager.JumpTo(blockNumber);
end;



function AnimInit(): Integer;
begin
  AnimManager := TrenderAnimManager.Create;

  Result := -10;
end;

//���������� ������� ����
function AnimStep(deltaTime: Single): Integer;
begin
  AnimManager.Step(deltaTime);
  Result := -10;
end;

function AnimDeInit(): Integer;
begin
  AnimManager.Free;
//  AnimManager := nil;

  Result := -10;
end;

function d_renderAnimSaveToFile(FileName: PAnsiChar): Integer;
begin
  //*
  //�������� ������������ ������ ������� �� �����
end;

end.
