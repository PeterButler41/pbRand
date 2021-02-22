#include "pbRand.h"
#include <stdio.h>

unsigned int buf1032[12]; // 2 ints makes space for fList
unsigned int buf2032[22]; // the other 10 are the seed words
unsigned long long buf1064[11]; //one long long for flist
unsigned long long buf2064[21]; //others are seed words

uint64_t outData[1000];

void print1032(void)
{
    for (int i = 0; i < 10; i++) printf("%2u 0x%08X\n", i, buf1032[i + 2]);
    printf("\n");
}
void print1064(void)
{
    for (int i = 0; i < 10; i++) printf("%2u 0x%016llX\n", i, buf1064[i + 1]);
    printf("\n");
}
uint32_t isA = 'A' * 33 * 33;
uint32_t isB = 'B' * 33 * 33;
uint32_t isC = 'C' * 33 * 33;

int main()
{ 
#if 1

    printf("2032  ASMx64\n");
    uint32_t zz;
    init2032(buf2032);
    zz = random32(buf2032);
    printf("0x%08X\n", zz);
    //print2032();
    seedCstring(buf2032, "ABC");
    zz = random32(buf2032);
    printf("0x%08X\n", zz);

//#else

    printf("2064  ASMx64\n");
    uint64_t yy;
    init2064(buf2064);
    //print2064();
    yy = random64(buf2064);
    printf("0x%016llX\n", yy);
    //print2064();
#if 1
//    seedItem32(buf2064, isA);
//    seedItem32(buf2064, isB);
//    seedItem32(buf2064, isC);
    seedCstring(buf2064, "ABC");
//    print2064();
    yy = random64(buf2064);
    printf("0x%016llX\n", yy);
#endif
    yy++;

#endif
    return 0;
}
