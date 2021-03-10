
// pbRand2032.hpp

#ifndef __PBRANDXX32_HPP_
#include "pbRandXX32.hpp"
#endif

#ifndef __PBRAND2032_HPP_
#define __PBRAND2032_HPP_


class pbRand2032 : virtual public pbRandXX32
{
public:

    uint32_t seed[20];  //seed should be private

    pbRand2032()
    {
        //printf("pbRand2032::pbRand2032(-in .hpp)\n");
        clr();
        seedItem32(0x4321);
    }

    void reInit(void);  //[re]setup mix tbl
    void clr(void);  // zeros seed table
    void print(void); //prints seed array for debug

    uint32_t random32();
    void seedItem32(uint32_t arg);
    void mx(void);
};
#endif //__PBRAND2032_HPP_

