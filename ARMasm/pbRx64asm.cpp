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

void print2032(void)
{
    for (int i = 0; i < 20; i++) printf("%2u 0x%08X\n", i, buf2032[i + 2]);
    printf("\n");
}
void print2064(void)
{
    for (int i = 0; i < 20; i++) printf("%2u 0x%016llX\n", i, buf2064[i + 1]);
    printf("\n");
}

uint32_t isA = 'A' * 33 * 33;
uint32_t isB = 'B' * 33 * 33;
uint32_t isC = 'C' * 33 * 33;

int main()
{
    uint32_t zz;
    uint64_t yy;

    printf("1032  ARM asm\n");

    init1032(buf1032);
    seedSelf(buf1032);
    zz = random32(buf1032);
    printf("0x%08X\n", zz);
//    seedCstring(buf1032, "ABC");
    zz = random32(buf1032);
    printf("0x%08X\n", zz);

    printf("1064  ARM asm\n");

    init1064(buf1064);
    seedSelf(buf1064);
    yy = random64(buf1064);
    printf("0x%016llX\n", yy);
//    seedCstring(buf1064, "ABC");
    yy = random64(buf1064);
    printf("0x%016llX\n", yy);

    printf("2032  ARM asm\n");

    init2032(buf2032);
    seedSelf(buf2032);
    zz = random32(buf2032);
    printf("0x%08X\n", zz);
//    seedCstring(buf2032, "ABC");
    zz = random32(buf2032);
    printf("0x%08X\n", zz);

    printf("2064  ARM asm\n");

    init2064(buf2064);
    seedSelf(buf2064);
    yy = random64(buf2064);
    printf("0x%016llX\n", yy);
//    seedCstring(buf2064, "ABC");
    yy = random64(buf2064);
    printf("0x%016llX\n", yy);

    return 0;
}
