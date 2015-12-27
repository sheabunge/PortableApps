#include <conio.h>
#include <unistd.h>
#include <dsensor.h>

class StateChanger {
public:
  StateChanger();
  
  virtual ~StateChanger();

  virtual void setState(bool state) {
    if(state)
      enable();
    else
      disable();
  }

  virtual void enable()  = 0;
  virtual void disable() = 0;

  void onOff();
  int FredFred(int x);

};

int foo () {
return 0;     }

void bar () {}

int main(int argc, char **argv) {
  cputs("jello");
  sleep(1);
  cputs("world");
  sleep(1);
  cls();

  return 0;
}

void fooBar2 (int x, char y) {}

int fooBar3 (int x, char y) {
  return x;
}

StateChanger::StateChanger() {}

StateChanger::~StateChanger() {
  // do nothing
}

int StateChanger::FredFred (int x) { return 0; }

int MyWeirdFunc(void) {
  return 3;
}

void StateChanger::onOff() {
  // do nothing
  //  int i = MyWeirdFunc();
}


