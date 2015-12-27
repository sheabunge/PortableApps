/*math.h*/

#define PI 3.1415

/*
*puiss(2, 3) == 2^3
*/

extern float puiss(float nb, int deg);

/*
*factor(5) == 5!
*be aware taht the RCX can't calculate foctor like 20! :)
*/

extern int factor(int n);

/*
*Precision is not really good but enought for the RCX
*/

extern float sin(float x);
extern float cos(float x);
