#include "pbRand.h"
#include <stdio.h>

unsigned int buf1032[11];
unsigned int buf2032[21];
unsigned long long buf1064[11];
unsigned long long buf2064[21];


int main()
{
    uint64_t zz;
    uint32_t yy;

    printf("asmARM 2032\n");
    init2032(buf2032);
    yy = random32(buf2032);
    printf("0x%08X\n", yy);
    seedCstring(buf2032, "ABC");
    yy = random32(buf2032);
    printf("0x%08X\n", yy);
    
    printf("asmARM 2064\n");
    init2064(buf2064);
    zz = random64(buf2064);
    printf("0x%016llX\n", zz);
    seedCstring(buf2064, "ABC");
    zz = random64(buf2064);
    printf("0x%016llX\n", zz);

    yy++;
    zz++;

    return 0;
}
