#include <iostream>

int main()
{
    union {
        short value;
        char  bytes[sizeof(short)];
    } test;

    test.value = 0x0102;

    if (test.bytes[0] == 1 && test.bytes[1] == 2) {
        std::cout << "big endian" << std::endl;
    } else if (test.bytes[0] == 2 && test.bytes[1] == 1) {
        std::cout << "little endian" << std::endl;
    }
}
