#include "Map.h"
#include <assert.h>
#include <iostream>

using namespace std;

int main(void)
{
    Map m;
    m["hey"] = "hey";
    m["sup"] = "hey";
    m["foo"] = "woo";

    assert(m["hey"] == "hey");
    assert(m["sup"] == "hey");
    assert(m["foo"] == "woo");
    assert(m["roar"] == "");

    return 0;
}
