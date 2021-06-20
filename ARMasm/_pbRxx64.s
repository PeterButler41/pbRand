; _pbRxx64.s

        name    _pbR1064
        col     132
        lstxrf  +

        public  _pbR64seedItem32
        public  _pbR64seedSelf
        public  _pbR64seedList64
        public  _pbR64seedList32
        public  _pbR64seedList
        public  _pbR64randomList64
        public  _pbR64randomList32
        public  _pbR64randomList

        rseg   .text:NOROOT:CODE(2)
        thumb

;**********************************************************************
;
; fList offsets
;
ofs_init         equ  0  ;only useful after calling initxxyy
ofs_seedItem64   equ  4
ofs_seedItem32   equ  8
ofs_seedSelf     equ 12
ofs_mix          equ 16  ;only one mix() via fList
ofs_random64     equ 20
ofs_random32     equ 24
ofs_seedList64    equ 28
ofs_seedList32   equ 32
ofs_seedList     equ 36      ;   byte count - best way
ofs_randomList64 equ 40
ofs_randomList32 equ 44
ofs_randomList   equ 48
; len 52 or 13 words
;
;**********************************************************************


; Seeding consists of adding three different rotations of
;  sVal to seed[0], seed[1], and seed[2]
; For 32-bit sVal that code is so simple and short that
;  it would be unreasonable not to do it twice.
; However, the same is not true for 64-bit seeds

; we begin with some #defines for clarity
#define sVlo r1
#define sVhi r2
#define Atemp r3
#define Btemp r4
; 0x48 (72) bytes in _pbR64seedHead
        public  _pbR64seedHead
_pbR64seedHead
        push    {r4-r6,lr}

; first rotate sVal (r2:r1) left one bit
        adds    sVlo,sVlo,sVlo
        adcs    sVhi,sVhi,sVhi
        adcs    sVlo,sVlo,#0
; add rotated sVal to seed[0]
        ldrd    r5,r6,[r0,#8]   ;load seed[0]
        adds    r5,r5,sVlo
        adcs    r6,r6,sVhi
        strd    r5,r6,[r0,#8]   ;updated seed[0]

; now rotate sVal (r2:r1) left 20 more bits (for 21 total)
        lsrs    Atemp,sVhi,#32-20
        lsls    sVhi,sVhi,#20
        eor     sVhi,sVhi,sVlo,lsr#32-20
        eor     sVlo,Atemp,sVlo,lsl#20

; add rotated sVal to seed[1]
        ldrd    r5,r6,[r0,#16]   ;load seed[1]
        adds    r5,r5,sVlo
        adcs    r6,r6,sVhi
        strd    r5,r6,[r0,#16]   ;updated seed[1]

; add (orginal) sVal rotated left 42bits to seed[2]
; rotate sVal (r2:r1) left 21 more bits (for 42 total)
        lsrs    Atemp,sVhi,#32-21
        lsls    sVhi,sVhi,#21
        eor     sVhi,sVhi,sVlo,lsr#32-21
        eor     sVlo,Atemp,sVlo,lsl#21

; add sVal to seed[2]
        ldrd    r5,r6,[r0,#24]   ;load seed[2]
        adds    r5,r5,sVlo
        adcs    r6,r6,sVhi
        strd    r5,r6,[r0,#24]   ;updated seed[2]

        pop     {r4-r6,pc}

;=============================================
; common tail of 64-bit random()
;=============================================

        public  _pbR64randTail
; We begin with r0-r5 = t0,t1,t2
; where for some n
; r1:r0 is seed[n]
; r3:r2 is seed[n+1]
; r5:r6 is seed[n+2]
; We use f(t0, t1, t2)
;  to form random return in r1:r0

; in random, fearful coder used a few defines
;  to maintain what little sanity he possessed
#undef Atemp
#undef Btemp
#define t0lo r0
#define t0hi r1
#define t1lo r2
#define t1hi r3
#define t2lo r4
#define t2hi r5
#define Atemp r6
#define Btemp r7
#define TEMP r6

_pbR64randTail
; rotate t0 left one bit
        adds    r0,r0,r0
        adcs    r1,r1,r1
        adcs    r0,r0,#0

; rotate t1 left 21 bits
; look at t1hi as aaabbb and
;         t1lo as cccddd
; where aaa and ccc are 21 bits
;   and bbb and ddd are 32-21 = 11 bits

        lsrs    TEMP,t1hi,#32-21
        lsls    t1hi,t1hi,#21
        eor     t1hi,t1hi,t1lo,lsr#32-21
        eor     t1lo,TEMP,t1lo,lsl#21
; add the rotated values
        adds    t0lo,t0lo,t1lo
        adcs    t0hi,t0hi,t1hi

#ifdef USE_XOR_SHIFT
; for t2 we map t2 into t2 as follows:
;t2 ^= t2 >> 15; t2 ^= t2 << 13; t2 ^= t2 > 28;

        ;                  start       aaabbb cccddd
        ;        wanted xor with       000aaa bbbccc
; t2 ^= t2 >> 15;
        lsls    TEMP,t2hi,#32-15      ; bbb000
        eor     t2hi,t2hi,t2hi,lsr#15 ; aaabbb^000aaa
        eor     t2lo,t2lo,t2lo,lsr#15 ; cccddd^000ccc
        eors    t2lo,t2lo,TEMP        ; cccddd^000ccc^bbb000

        ;                   start       aaabbb cccddd
        ;         wanted xor with       bbbccc ddd000
; t2 ^= t2 << 13;
        lsrs    TEMP,t2lo,#32-13      ; 000ccc
        eor     t2hi,t2hi,t2hi,lsl#13 ; aaabbb^bbb000
        eor     t2lo,t2lo,t2lo,lsl#13 ; cccddd^ddd000
        eors    t2hi,t2hi,TEMP        ; aaabbb^000ccc

        ;                   start       aaabbb cccddd
        ;         wanted xor with       000aaa bbbccc
; t2 ^= t2 >> 28;
        lsls    TEMP,t2hi,#32-28      ; bbb000
        eor     t2hi,t2hi,t2hi,lsr#28 ; aaabbb^000aaa
        eor     t2lo,t2lo,t2lo,lsr#28 ; cccddd^000ccc
        eors    t2lo,t2lo,TEMP        ; cccddd^000ccc^bbb000

; then finally return  r0:r1 = (t0+t1)^t2
        eors    t0lo,t0lo,t2lo
        eors    t0hi,t0hi,t2hi
#else
;resuming what we had before if useXorShift...
;
; we simply rotate t2 left 42 bits and xor with the sum performed
;  before the if xor_shift thing
; EXCEPT we are using a 32-bit CPU so...
;  ...we rotate left 10 bits and get the other 32 bits by
;     xoing top to botton and bottom to top
        lsrs    TEMP,t2hi,#32-10
        lsls    t2hi,t2hi,#10
        eor     t2hi,t2hi,t2lo,lsr#32-10
        eor     t2lo,TEMP,t2lo,lsl#10
; and now the backwards xor to return r0:r1
        eors    t0lo,t0lo,t2hi
        eors    t0hi,t0hi,t2lo
#endif
        bx      lr

;=============================================

; now some fList utility functions

_pbR64seedItem32
seedItem32
        mov     r2,#0   ;kill high seed
seed
        ldr     r3,[r0]
        ldr     r3,[r3,#ofs_seedItem64]
        bx      r3

random ;local helper function
        ldr     r3,[r0]
        ldr     r3,[r3,#ofs_random64]
        bx      r3

mix
        ldr     r3,[r0]
        ldr     r3,[r3,#ofs_mix]
        bx      r3

_pbR64seedSelf
        push    {r4,lr}
        mov     r4,r0       ;save fList adrs
        bl      random      ;low:high is r0:r1
        mov     r2,r1       ;high...
        mov     r1,r0       ;...low for seed function
        mov     r0,r4       ;fList needed to dispatcg
        bl      seed
        pop     {r4,pc}

;r2: count of 64-bit words
;r1: &source
;r0: fList, seed[0] ...
; seed() preserves r0
_pbR64seedList64
        push    {r5,r6,lr}
        mov     r5,r1           ;&source
        movs    r6,r2           ;count
        ble     sLstb           ;if count<=0
sLsta
        ldm     r5!,{r1,r2}
        bl      seed
        subs    r6,r6,#1
        bne     sLsta           ;if not done
        bl      mix
sLstb
        pop     {r5,r6,pc}

;r2: count of 32-bit words
;r1: &source
;r0: fList, seed[0] ...
; seed() preserves r0
_pbR64seedList32
        push    {r5,r6,lr}
        mov     r5,r1           ;&source
        movs    r6,r2           ;count
        ble     sLstd           ;if count<=0
sLstc
        ldm     r5!,{r1}
        bl      seedItem32
        subs    r6,r6,#1
        bne     sLstc           ;if not done
        bl      mix
sLstd
        pop     {r5,r6,pc}

;r2: byte count
;r1: &source
;r0: fList, seed[0] ...
_pbR64seedList
        push    {r5,r6,lr}
        mov     r5,r1           ;&source
        movs    r6,r2           ;byte count
        ble     sLstk          ;if count<=0
sLste
        ldm     r5!,{r1,r2}     ;fetch seeding material
        cmp     r6,#8
        blt     sLstf           ;if almost time to wrap
        bl      seed
        subs    r6,r6,#8
        bne     sLste           ;if not done
        b       sLstj           ;final mix and exit
sLstf
; seeding bytes have been fetched
; but some must not be used
        rsbs    r6,r6,#8        ;bytes to xap = 8-remaingCount
        mov     r3,#0xFF000000
sLstg
        bics    r2,r2,r3
        subs    r6,r6,#1
        beq     sLsti           ;if done zapping bytes
        lsrs    r3,r3,#8
        bne     sLstg
; finished zapping all 4 sVal high bytes
        mov     r3,#0xFF000000
sLsth
        bics    r1,r1,r3
        subs    r6,r6,#1
        beq     sLsti          ;if done zapping bytes
        lsrs    r3,r3,#8
        bne     sLsth

  b . ;we should never get here

sLsti   bl      seed            ;final seed and mix
sLstj   bl      mix
sLstk   pop     {r5,r6,pc}


_pbR64randomList64
        push    {r4-r6,lr}
        mov     r4,r0           ;&fList
        mov     r5,r1           ;&dest'n
        movs    r6,r2           ;count
        blt     rLstb           ;nop if count <= 0
rLsta   mov     r0,r4           ;&fList
        bl      random
        stm     r5!,{r0,r1}
        subs    r6,r6,#1
        bne     rLsta
rLstb   pop     {r4-r6,pc}

_pbR64randomList32
        push    {r4-r6,lr}
        mov     r4,r0           ;&fList
        mov     r5,r1           ;&dest'n
        movs    r6,r2           ;count
        blt     rLste           ;nop if count <= 0
rLstc
        mov     r0,r4
        bl      random
        subs    r6,r6,#2
        bmi     rLstd           ;if only one 32-bit value left
        stm     r4!,{r0,r1}     ;store 64 bits
        bne     rLstc           ;if more to fill
        b       rLste           ;else done
; final store
rLstd   str     r0,[r4]         ;store last 32-bit word
rLste   pop     {r4-r6,pc}


_pbR64randomList
        push    {r4-r6,lr}
        mov     r4,r0           ;&fList
        mov     r5,r1           ;&dest'n
        movs    r6,r2           ;count
        blt     rLsti           ;nop if count <= 0
rLstf
        mov     r0,r4
        bl      random
        subs    r6,r6,#8
        bmi     rLstg           ;if partial store and exit
        stm     r4!,{r0,r1}
        bne     rLstf           ;loop if more random is needed
        b       rLsti           ;else...all done
; only store part of last random value
rLstg
        adds    r6,r6,#8        ;number of bytes to store (1..7)
rLsth
        strb    r0,[r5],#1
        lsrs    r0,r0,#8
        bfi     r0,r1,#24,#8
        lsrs    r1,r1,#8
        subs    r6,r6,#1
        bne     rLsth
rLsti   pop     {r4-r6,pc}

        end
