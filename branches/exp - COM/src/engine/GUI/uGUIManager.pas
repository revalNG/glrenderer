unit uGUIManager;

interface

uses
  dfHRenderer,
  Classes;

type
  TdfGUIManager = class(TInterfacedObject, IdfGUIManager)
  private
    FElements: TInterfaceList;
    FFocused: IdfGUIElement;

    function GetFocused(): IdfGUIElement;
    procedure SetFocused(aElement: IdfGUIElement);

    function GetElementIndexAtPos(X, Y: Integer): Integer;
  public
    constructor Create(); virtual;
    destructor Destroy(); override;

    //����������������/����������������� �������
    procedure RegisterElement(aElement: IdfGUIElement);
    procedure UnregisterElement(aElement: IdfGUIElement);

    //�������, ����������� � ������
    property Focused: IdfGUIElement read GetFocused write SetFocused;

    //��� ����������� ������������� IdfRenderer-��.
    procedure MouseMove (X, Y: Integer; Shift: TdfMouseShiftState);
    procedure MouseDown (X, Y: Integer; MouseButton: TdfMouseButton; Shift: TdfMouseShiftState);
    procedure MouseUp   (X, Y: Integer; MouseButton: TdfMouseButton; Shift: TdfMouseShiftState);
    procedure MouseWheel(X, Y: Integer; Shift: TdfMouseShiftState; WheelDelta: Integer);
  end;

implementation

{ TdfGUIManager }

constructor TdfGUIManager.Create;
begin
  inherited;
  FElements := TInterfaceList.Create();
  FFocused := nil;
end;

destructor TdfGUIManager.Destroy;
begin
  FFocused := nil;
  FElements.Free;
  inherited;
end;

function TdfGUIManager.GetElementIndexAtPos(X, Y: Integer): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to FElements.Count - 1 do //��� ������� ��������
    if IdfGUIElement(FElements[i]).CheckHit(X, Y) then //���� ���� ���������
      if Result <> -1 then // ���� �� ����� ��� ���� ��������
      begin
        if IdfGUIElement(FElements[i]).ZIndex <
           IdfGUIElement(FElements[Result]).ZIndex then
          Result := i
      end
      else
        Result := i;
end;

function TdfGUIManager.GetFocused: IdfGUIElement;
begin
  Result := FFocused;
end;

procedure TdfGUIManager.MouseDown(X, Y: Integer; MouseButton: TdfMouseButton;
  Shift: TdfMouseShiftState);
var
  ind: Integer;
begin
  ind := GetElementIndexAtPos(X, Y);
  if ind <> -1 then
  begin
    FFocused := IdfGUIElement(FElements[ind]);
    FFocused._MouseDown(X, Y, MouseButton, Shift);
  end
  else
    FFocused := nil;
end;

procedure TdfGUIManager.MouseMove(X, Y: Integer; Shift: TdfMouseShiftState);

  //������� ��� ��������, � ������� ����� ���� � ���, ��� ���� ��� ����
  //��� ����� ExceptIndex �������� ����, exceptIndex - ��� �������, �������
  //�� �������
  procedure SetMouseOut(exceptIndex: Integer);
  var
    i: Integer;
  begin
    for i := 0 to FElements.Count - 1 do
      with IdfGUIElement(FElements[i]) do
        if (MousePos = mpOver) and (i <> exceptIndex) then
          _MouseOut(X, Y, Shift);
  end;

var
  ind: Integer;
begin
  ind := GetElementIndexAtPos(X, Y);
  SetMouseOut(ind);
  if ind <> -1 then
    with IdfGUIElement(FElements[ind]) do
      //���� ���� ����� �� ���� �� ��������, �� ���������� omMouseOver
      if MousePos = mpOut then
        _MouseOver(X, Y, Shift)
      //����� - ������ �������� ���� �� ��������
      else
        _MouseMove(X, Y, Shift);
end;

procedure TdfGUIManager.MouseUp(X, Y: Integer; MouseButton: TdfMouseButton;
  Shift: TdfMouseShiftState);
var
  ind: Integer;
begin
  ind := GetElementIndexAtPos(X, Y);
  if ind <> -1 then
    with IdfGUIElement(FElements[ind]) do
      if MousePos  = mpOver then
      begin
        _MouseClick(X, Y, MouseButton, Shift);
        _MouseUp(X, Y, MouseButton, Shift);
      end
      else
        _MouseUp(X, Y, MouseButton, Shift);
end;

procedure TdfGUIManager.MouseWheel(X, Y: Integer; Shift: TdfMouseShiftState;
  WheelDelta: Integer);
var
  ind: Integer;
begin
  ind := GetElementIndexAtPos(X, Y);
  if (ind <> -1) then
    IdfGUIElement(FElements[ind])._MouseWheel(X, Y, Shift, WheelDelta);
end;

procedure TdfGUIManager.RegisterElement(aElement: IdfGUIElement);
begin
  FElements.Add(aElement);
end;

procedure TdfGUIManager.SetFocused(aElement: IdfGUIElement);
begin
  FFocused := aElement;
end;

procedure TdfGUIManager.UnregisterElement(aElement: IdfGUIElement);
begin
  if aElement = FFocused then
    FFocused := nil;
  FElements.Remove(aElement);
end;

end.
