{
  ����������� ����� ��� ���������� ���� "������������":
    ���� � ������ ������� �������, ������� ��������� ���������� � ��������,
    � ��� ���������, ��������� ����������� �������� � ��������, ����� ������������
    ����������� (������ �������� - ���) ��������.

    ����� ������ ��������� ���� ������, �� �� ���������, � ���������� ���
    ���������������� � ������������ � �����������. ����� ��������� �������������
    � ����� �������, �� ������� �� ������������, ��� �������������� ������������.
    ���� � ������������ ��� ��������� ��������, �� �� ������������� �������������

    �������� ��� ���������� - �� ������� � �� �����������

    ���������� �� ������� ������ �� ���� �������, ����� �� ������ �����������
    ������ ������������ ������ ������ � TpdAccumItem, �� ����:
    TMyClass = class(TpdAccumItem)

    ���������� ����������� ������ � ������, ���� ������������ ����������. ������,
    �������� ������������� �������������� ��������� ��� �������������� � �����
    �������� ����� Get(), ��� ��� ������ ������ ��� ����� � �������� ��
    ������������ ���������� ������ �� ������

    1. ������
      TpdAccumItem - ������, ���������� � �����������
        + ���������� ����������� ������ OnCreate, OnGet, onFree

      TpdAccum - ��� �����������
        + ���������� ����������� ����� NewAccumItem() ��� ����, ����� ��
          ��������� ������ ������ ������. ��������:

          function TMyAccum.NewAccumItem(): TpdAccumItem;
          begin
            Result := TMyAccumItem.Create();
          end;

        + ����� (�� �� �����������) ������������ ����� GetItem ��� ����������
          ��� ���������� � ������ ���� ������. ��������:

          function TMyAccum.GetItem(): TMyAccumItem; reintroduce;

          function TMyAccum.GetItem(): TMyAccumItem;
          begin
            Result := inherited GetItem() as TMyAccumItem;
          end;

    2. ����������
      IpdAccumItem - ������, ���������� � �����������, ������ �������������
        ���� ���������. ���������� ������� ������� � ���������� ����������.

        + ������������� (������������ ���������� �� �������) ���������� �����������
          �������� IsUsed.

      TpdAccumI - ��� �����������, ����������� ������������
        + ���������� ����������� ����� NewAccumItem() ��� ����, ����� ��
          ��������� ������ ������ ������. ��������:

          function TMyAccumI.NewAccumItem(): IpdAccumItem;
          begin
            Result := TMyClass.Create();
          end;

        + ����� (�� �� �����������) ������������ ����� GetItem ��� ���������� Result
          � ������ ���������� (�������� ������ �� ���������� �� ���������).
          ��������:

          function TMyAccumI.GetItem(): IMyClassInterface; reintroduce;

          function TMyAccumI.GetItem(): IMyClassInterface;
          begin
            Result := inherited GetItem() as IMyClassInterface;
            //���     inherited GetItem().QueryInterface(IMyClassInterface);
          end;

  �����: perfect.daemon
}

unit uAccum;

interface

//���������� �� �������

type
  TpdAccumItem = class
  protected
    FUsed: Boolean;
  public
    {��������� ���������� ����� �������� ������ �������, �. �. ���� ��� �� ��� �����}
    procedure OnCreate(); virtual;
    {��������� ���������� ������ ���, ����� ������ ������� �� ������������}
    procedure OnGet(); virtual;
    {��������� ����������, ����� ����� �������� � �����������}
    procedure OnFree(); virtual;

    property Used: Boolean read FUsed;
  end;

  TpdAccum = class
  protected
    procedure Expand();
  public
    Items: array of TpdAccumItem;
    constructor Create(aInitialCapacity: Integer); virtual;
    destructor Destroy(); override;

    function NewAccumItem(): TpdAccumItem; virtual; abstract;

    function GetItem(): TpdAccumItem; virtual;
    procedure FreeItem(aItem: TpdAccumItem); virtual;
  end;


//���������� �� �����������

type
  IpdAccumItem = interface
    {��������� ���������� ����� �������� ������ �������, �. �. ���� ��� �� ��� �����
     IsUsed ������ ����� ����� ������ ���������� Fakkse}
    procedure OnCreate();
    {��������� ���������� ������ ���, ����� ������ ������� �� ������������
     IsUsed ������ ����� ����� ������ ���������� True}
    procedure OnGet();
    {��������� ����������, ����� ������ �������� � �����������
     IsUsed ������ ����� ����� ������ ���������� False}
    procedure OnFree();

    {���������, ������������ �� ������.
     ���������� ����������� }
    function IsUsed(): Boolean;
  end;

  TpdAccumI = class
  protected
    FAccum: array of IpdAccumItem;
    procedure Expand();
  public
    constructor Create(aInitialCapacity: Integer); virtual;
    destructor Destroy(); override;

    {���������� �������������� ��� �������,
    � ��� ���������� �����������
      Result := TYourClass.Create();}
    function NewAccumItem(): IpdAccumItem; virtual; abstract;

    function Get(): IpdAccumItem; virtual;
    procedure Free(aItem: IpdAccumItem); virtual;
  end;


implementation

{$REGION '���������� �� �������'}

{ TpdAccumItem }

procedure TpdAccumItem.OnCreate();
begin
  FUsed := False;
end;

procedure TpdAccumItem.OnFree();
begin
  FUsed := False;
end;

procedure TpdAccumItem.OnGet();
begin
  FUsed := True;
end;

{ TpdAccum }

constructor TpdAccum.Create(aInitialCapacity: Integer);
var
  i: Integer;
begin
  if aInitialCapacity > 4 then
    SetLength(Items, aInitialCapacity)
  else
    SetLength(Items, 4);
  for i := 0 to High(Items) do
  begin
    Items[i] := NewAccumItem();
    Items[i].OnCreate();
  end;
end;

destructor TpdAccum.Destroy();
var
  i: Integer;
begin
  for i := 0 to High(Items) do
  begin
    Items[i].Free;
  end;
  SetLength(Items, 0);
  inherited;
end;

procedure TpdAccum.Expand();
var
  l, i: Integer;
begin
  l := Length(Items);
  SetLength(Items, l + l div 4); // + 1/4 �������� ������� ������������
  for i := l to Length(Items) - 1 do
  begin
    Items[i] := NewAccumItem();
    Items[i].OnCreate();
  end;
end;

procedure TpdAccum.FreeItem(aItem: TpdAccumItem);
begin
  aItem.OnFree();
end;

function TpdAccum.GetItem(): TpdAccumItem;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to High(Items) do
    if not Items[i].Used then
    begin
      Result := Items[i];
      Break;
    end;

  if Result = nil then
  begin
    i := Length(Items); //�������������, i = Length, �� ��� ������������
    Expand();
    Result := Items[i];
  end;

  Result.OnGet();
end;

{$ENDREGION}

{$REGION '���������� �� �����������'}

{ TpdAccumI }

constructor TpdAccumI.Create(aInitialCapacity: Integer);
var
  i: Integer;
begin
  if aInitialCapacity > 4 then
    SetLength(FAccum, aInitialCapacity)
  else
    SetLength(FAccum, 4);
  for i := 0 to High(FAccum) do
  begin
    FAccum[i] := NewAccumItem();
    FAccum[i].OnCreate();
  end;
end;

destructor TpdAccumI.Destroy();
var
  i: Integer;
begin
  //�������������
  for i := 0 to High(FAccum) do
    FAccum[i] := nil;
  SetLength(FAccum, 0);
  inherited;
end;

procedure TpdAccumI.Expand();
var
  l, i: Integer;
begin
  l := Length(FAccum);
  SetLength(FAccum, l + l div 4); // + 1/4 �������� ������� ������������
  for i := l to Length(FAccum) - 1 do
  begin
    FAccum[i] := NewAccumItem();
    FAccum[i].OnCreate();
  end;
end;

procedure TpdAccumI.Free(aItem: IpdAccumItem);
begin
  aItem.OnFree();
end;

function TpdAccumI.Get(): IpdAccumItem;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to High(FAccum) do
    if not FAccum[i].IsUsed() then
    begin
      Result := FAccum[i];
      Break;
    end;

  if Result = nil then
  begin
    i := Length(FAccum); //�������������, i = Length, �� ��� ������������
    Expand();
    Result := FAccum[i];
  end;

  Result.OnGet();
end;

{$ENDREGION}

end.
