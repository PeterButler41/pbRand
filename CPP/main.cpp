#include "pbRand1032.hpp"
#include "pbRand1064.hpp"
#include "pbRand2032.hpp"
#include "pbRand2064.hpp"

char stuff[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

void the32(pbRand *p)
{
    uint32_t asdf = p->random32();
    printf("0x%08X\n", asdf);
    p->seedCstring("ABC");
    uint32_t pp = p->random32();
    printf("0x%08X\n", pp);
    p->seedList(stuff,9);
}

void the64(pbRand *q)
{
    uint64_t qqqq = q->random64();
    printf("0x%016llX\n", qqqq);
    q->seedCstring("ABC");
    uint64_t qq = q->random64();
    printf("0x%016llX\n", qq);
    q->seedList(stuff,11);
}
int main()
{
    printf("Pure C++ on ARM sim\n");
    pbRand *pbr;
    uint32_t r32;
    uint64_t r64;
   
    printf("1032...\n");
    pbr = new pbRand1032();
    pbr->seedSelf();
    r32 = pbr->random32();
    printf("0x%08X\n", r32);
    r32 = pbr->random32();
    printf("0x%08X\n", r32);
    
    printf("1064...\n");
    pbr = new pbRand1064();
    pbr->seedSelf();
    r64 = pbr->random64();
    printf("0x%016llX\n", r64);
    r64 = pbr->random64();
    printf("0x%016llX\n", r64);
  
    printf("2032...\n");
    pbr = new pbRand2032();
    pbr->seedSelf();
    r32 = pbr->random32();
    printf("0x%08X\n", r32);
    r32 = pbr->random32();
    printf("0x%08X\n", r32);

    printf("2064...\n");
    pbr = new pbRand2064();
    pbr->seedSelf();
    r64 = pbr->random64();
    printf("0x%016llX\n", r64);
    r64 = pbr->random64();
    printf("0x%016llX\n", r64);
   
    return 0;
}
