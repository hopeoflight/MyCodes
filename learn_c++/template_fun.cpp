#include <iostream>
#include <string>
using namespace std;

template <typename T>
T add(const T &a,const T &b)
{
    return (a + b);    
}

int main(void)
{
    cout << add(3,4) << endl;
    cout << add(3.3,4.4) << endl;
    cout << add(string("name"),string("_bai")) << endl;
    return 0;
}
