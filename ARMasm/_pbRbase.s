; _pbRbase.s
        name    _pbRbase
        col     132
        lstxrf  +

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
ofs_mix          equ 16
ofs_random64     equ 20
ofs_random32     equ 24
ofs_seedList64   equ 28
ofs_seedList32   equ 32
ofs_seedList     equ 36      ;   byte count - best way
ofs_randomList64 equ 40
ofs_randomList32 equ 44
ofs_randomList   equ 48
; len 52 or 13 words
;
;**********************************************************************

;**********************************************************************
;
; *EVERY* ENTRY POINT HAS THE SEED BUFFER ADDRESS
;  AS ITS FIRST PARAMETER
;
;**********************************************************************

callMe macro arg
        rseg   .text:NOROOT:CODE(2)
        public  arg
arg     ldr     r3,[r0]
        ldr     r3,[r3,#ofs_\1]
        bx      r3
        endm

        callMe init
        callMe seedItem64
        callMe seedItem32
        callMe seedSelf
;        callMe mix
        callMe random64
        callMe random32
        callMe seedList64
        callMe seedList32
        callMe seedList
        callMe randomList64
        callMe randomList32
        callMe randomList

;**********************************************************************
; void mix(int nTimes = 10);
; r1=count
        rseg    .text:NOROOT:CODE(2)
        public  mix
mix
        push    {r4-r5,lr}
        movs    r4,r1           ;count
        ble     mixX            ;if counr <= zero
        ldr     r2,[r0]         ;&fList
        ldr     r5,[r2,#ofs_mix]
mixA    blx     r5              ;mix()
; the real mix() preserves r0
        subs    r4,r4,#1
        bne     mixA
mixX    pop     {r4-r5,pc}

        rseg    .text:NOROOT:CODE(2)
        public  seedList16
seedList16
        push    {r4-r6,lr}
        mov     r6,r0           ;fList    
        mov     r4,r1           ;source address
        movs    r5,r2           ;byte count
        ble     sL16X           ;if count <= zero
sL16a
        ldrh    r1,[r4],#2
        mov     r0,r6           ;so seedItem32 will work     
        bl      seedItem16
        subs    r5,r5,#1
        bne     sL16a           ;if more to seed
        mov     r1,#1
        bl      mix
sL16X   pop     {r4-r6,pc}

        rseg    .text:NOROOT:CODE(2)
        public  seedList8
seedList8
        push    {r4-r6,lr}
        mov     r6,r0           ;fList 
        mov     r4,r1           ;source address
        movs    r5,r2           ;byte count
        ble     sL8X            ;if count <= zero
sL8a
        ldrh    r1,[r4],#1
        mov     r0,r6           ;so seedItem32 will work     
        bl      seedItem16
        subs    r5,r5,#1
        bne     sL8a            ;if more to seed
sL8X    pop     {r4-r6,pc}

; void seedCstring(const int8_t *str);
        rseg    .text:NOROOT:CODE(2)
        public  seedCstring
seedCstring
        push    {r4,r6,lr}
        mov     r6,r0           ;fLits
        mov     r4,r1           ;source address
seedC1
        ldrb    r1,[r4],#1
        cbz     r1,seedC2
        mov     r0,r6           ;fList so seed32 will work
        bl      seedByte
        b       seedC1

seedC2  movs    r1,#1
        pop     {r4,r6,pc}

        public  seedItem8,seedByte,seedChar,seedItem16
        rseg    .text:NOROOT:CODE(2)
seedItem8
seedByte
seedChar
        uxtb    r1,r1           ;like and(r1,0xFF)
seedItem16
        uxth    r1,r1           ;like and(r1,0xFFFF)
        add     r1,r1,r1,lsl#5  ;r1 += r1 shifted left 5 bits
        add     r1,r1,r1,lsl#5  ;r1+=r1<<5;
        b       seedItem32

        end

