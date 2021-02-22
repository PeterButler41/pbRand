// pbRand.h

typedef signed char        sint8_t;
typedef short              int16_t;
typedef int                int32_t;
typedef long long          int64_t;
typedef unsigned char      uint8_t;
typedef short int          uint16_t;
typedef unsigned int       uint32_t;
typedef unsigned long long uint64_t;

#ifdef __cplusplus
extern "C" {
#endif

// The seed arrays use seedArray[0] for fList,
//  the polymorphic function list.
// The remaining items are used as the random seed.
// Please note the extra seedArray item.
void init1032(void*); // uint32_t seedArray[11];  44 bytes
void init2032(void*); // uint32_t seedArray[21];  84 bytes
void init1064(void*); // uint64_t seedArray[11];  88 bytes
void init2064(void*); // uint64_t seedArray[21]; 108 bytes

// BEGIN *BIG IMPORTANT NOTE*
//
// One of the initxxyy() functions, above,
//  must be called before calling any funtion
//  mentioned below.
// THIS INCULDES init() which when called
//  sets the seedArray the same as initxxyy().
//
// END *BIG IMPORTANT NOTE*

// UTILITY FUNCTIONS
void init(void*); //zero seedArray then seed with default seed
void mix(void*, int count=1);

// RETURN RANDOM VALUES
uint64_t random32(void*);
uint64_t random64(void*);

// RETURN RANDOM VALUES into RAM...
void randomList32(void*, uint32_t* dest, int num);
//       returns random into 32-bit words
void randomList64(void*, uint64_t* dest, int num);
//       returns random into 64-bit words
void randomList(void*, void* dest, int byteCount);
//       returns random<seed type> then bytes as needed

// THE SEEDINGS one item at a time
void seedSelf(void*); //seed with internally generated random item
void seedItem64(void*, uint64_t item);
void seedItem32(void*, uint32_t item);
void seedItem16(void*, uint16_t item);
void seedItem8(void*,   uint8_t item);
void seedByte(void*,    uint8_t item);
void seedChar(void*,    sint8_t item);
;
// SEEDING FROM MEMORY
// (all seedings from memory perform an extra mix() after seeding)
void seedCstring(void*, const char* src);
//       seed 8-bit char’s with null terminated C-string
void seedList64(void*, const uint64_t* src, int num);
void seedList32(void*, const uint32_t* src, int num);
void seedList16(void*, const uint16_t* src, int num);
void seedList8(void*,  const  uint8_t* src, int num);
void seedList(void*,   const     void* src, int byteCount);
//   seed byte count w/ best method
//   i.e. random<seedType> followed by bytes as needed
//   (In reality, only 64 or 32-bit words are seeded.
//    seedList() treats partial words as if unused bytes
//    following the last full word were all zeros.)
#ifdef __cplusplus
}
#endif


