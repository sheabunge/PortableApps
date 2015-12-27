#include <conio.h>
#include <unistd.h>
#include <dsound.h>

class Node
{
public:
  Node( void *_pData )
  {
    pData = _pData;
    pNext = (Node *)NULL;
  } // end constructor

  Node *Next() { return( pNext ); }
  void SetNext( Node *pNode ) { pNext = pNode; }
  //void *Data() { return( pData ); }

private:
  void *pData;
  Node *pNext;
}; // end Node

class list
{
private:
  Node *p_head;
};

int main(int argc, char **argv)
{
  cputs("c4");
  return 0;
}

