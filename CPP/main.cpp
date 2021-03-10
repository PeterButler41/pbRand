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
    pbRand *p;
    pbRand *q;
   
    p = new pbRand1032();
    the32(p);
    q = new pbRand1064();
    the64(q);
   
    p = new pbRand2032();
    the32(p);
    q = new pbRand2064();
    the64(q);
 
    return 0;
}
