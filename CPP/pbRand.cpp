// pbRand.cpp

#ifndef __PBRAND_HPP_
#include "pbRand.hpp"
#endif

/*
 Comments about what and why
*/

void pbRand::seedItem16(uint16_t item) //seed tbl with 16-bit value
{
    uint32_t b = item & 0xFFFF;
    b += b << 5;
    b += b << 5;
    seedItem32(b);
}
void pbRand::seedItem8(uint8_t item) { seedItem16(item); }  //seed tbl with 8-bit value
void pbRand::seedByte(uint8_t item) { seedItem16(item); }  //exactly the same as above
void pbRand::seedChar(int8_t item) { seedItem16(item); }     //exactly the same as above
//
// seeding from memory...

void pbRand::seedList16(const uint16_t *src, int itemCount)
{
    while (itemCount--)  seedItem16(*src++);
}

//void pbRand::seedItem8(uint8_t ch)
//{
//    uint16_t val = ch;
//    val &= 0x00FF;
//    seedItem16(val);
//}

void pbRand::seedList8(const uint8_t *src, int byteCount)
{
    while (byteCount--) seedItem8(*src++);
}

void pbRand::seedList8(const int8_t *src, int byteCount)
{
    while (byteCount--) seedItem8(*src++);
}
void pbRand::seedCstring(const char *str) //seed char’s with null terminated C-string
{
    while (1)
    {
        uint8_t b = *str++;
        if (b == 0) break;
        seedItem8(b);
    }
}

void pbRand::mix(int nTimes) //no default value
{
    while (nTimes--) mx();
}
