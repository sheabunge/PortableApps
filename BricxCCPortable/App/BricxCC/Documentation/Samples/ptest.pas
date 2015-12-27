program ptest;

uses
  conio, unistd, dsound;
  
type
  TValString = string[5];
  PNode = ^TNode;
  TNode = object
  private
    val : TValString;
    pNext : PNode;
  public
    constructor Create(const s : TValString);
    destructor Destroy;
    function Next : PNode;
    procedure SetNext(p : PNode);
    function Value : TValString;
  end;
  
  TList = object
  private
    p_head : PNode;
  public
    constructor Create;
    destructor Destroy;
    function Top : PNode;
    procedure Clear;
    procedure Push(const s : TValString);
    procedure Print;
  end;
  
{ TNode }

constructor TNode.Create(const s : TValString);
begin
  val := s;
  pNext := nil;
end;

destructor TNode.Destroy;
begin
  cputs('D ' + val);
  msleep(500);
  // nothing to destroy
end;

function TNode.Next : PNode;
begin
  Result := pNext;
end;

procedure TNode.SetNext(p : PNode);
begin
  pNext := p;
end;

function TNode.Value : TValString;
begin
  Result := val;
end;

{ TList }

constructor TList.Create;
begin
  p_head := nil;
end;

destructor TList.Destroy;
begin
  Clear;
  cputs('D lst');
  msleep(500);
end;

function TList.Top : PNode;
begin
  Result := p_head;
end;

procedure TList.Push(const s : TValString);
var
  n, tmp : PNode;
begin
  n := New(PNode, Create(s));
  tmp := p_head;
  p_head := n;
  p_head^.SetNext(tmp);
end;

procedure TList.Clear;
var
  p, tmp : PNode;
begin
  // delete all the nodes in our list
  p := Top;
  while p <> nil do
  begin
    tmp := p;
    p := p^.Next;
    Dispose(tmp, Destroy);
  end;
  p_head := nil;
end;

procedure TList.Print;
var
  p, tmp : PNode;
begin
  p := Top;
  while p <> nil do
  begin
    cputs(p^.Value);
    msleep(500);
    p := p^.Next;
  end;
end;

var
  List : TList;

begin
  List.Create;
  // do some stuff
  List.Push('Fun');
  List.Push('What');
  List.Push('ddddd');
  List.Push('ccccc');
  List.Push('bbbbb');
  List.Push('aaaaa');
  List.Print;
  List.Destroy;
  cputs('c4');
end.

