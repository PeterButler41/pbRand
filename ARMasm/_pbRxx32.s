; pbRxx32.s
; common code for 10 ro 20 32-bit seeds

        name    _pbRxx32
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
ofs_mix          equ 16  ;only one mix() via fList
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

;
; helper functions
;
seedItem32
        ldr     r3,[r0]
        ldr     r3,[r3,#ofs_seedItem32]
        bx      r3
random32 ;local helper function
        ldr     r3,[r0]
        ldr     r3,[r3,#ofs_random32]
        bx      r3

;r0: &fList and mix buffer
        public  _pbR32seedItem64
_pbR32seedItem64
        push    {r5,r6,lr}
        mov     r5,r2           ;high part of 64-bit word
        bl      seedItem32      ;seed low word
        mov     r1,r5
        bl      seedItem32      ;seed high word
        pop     {r4-r6,pc}

;r2: number of 64-bit words
;r1: source address
;r0: &buffer with fList as first word
; can this be made simpler by doulbing word count and falling into ...32
        public  _pbR32seedList64
_pbR32seedList64
        push    {r5,r6,lr}
        mov     r6,r2           ;word count
        mov     r5,r1           ;&source
sLst64a ldm     r5!,{r1,r2}
        bl      _pbR32seedItem64
        subs    r6,r6,#1
        bne     sLst64a         ;if more to go
        pop     {r5,r6,pc}

;r2: number of 32-bit words
;r1: source address
;r0: &buffer with fList as first word
        public  _pbR32seedList32
_pbR32seedList32
        push    {r5,r6,lr}
        mov     r6,r2           ;word count
        mov     r5,r1           ;&source
sLst32a ldr     r1,[r5],#4
        bl      seedItem32
        subs    r6,r6,#1
        bne     sLst32a         ;if more to go
        pop     {r5,r6,pc}

        public  _pbR32seedList
_pbR32seedList
        push    {r5,r6,lr}
        mov     r6,r2           ;byte count
        mov     r5,r1           ;&source
sLsta   cmp     r6,#4
        blt     sLstb
        ldr     r1,[r5],#4
        bl      seedItem32      ;call seed32()
        subs    r6,r6,#4
        b       sLsta
;less than 4 bytes left
sLstb   ldr     r1,[r5]         ;load last word
        lsl     r6,r6,#8 ;remaing count*8 is num of bits to discard
        lsl     r1,r1,r6 ;discard bytes out of range
        lsr     r1,r1,r6        ;make it look like unused bytes weer zero
        bl      seedItem32
        pop     {r5,r6,pc}

;
; the various random returns
;
        public  _pbR32random64
_pbR32random64
        push    {r4,r5,lr}
        mov     r4,r0           ;save fList pointer
        bl      random32
        mov     r5,r1           ;random value just returned
        mov     r0,r4           ;retore fList pointer
        bl      random32
        mov     r2,r1           ;last random32 is high part
        mov     r1,r5
        pop     {r4,r5,lr}

        public  _pbR32seedSelf
_pbR32seedSelf
        push    {lr}
        push    {r0}            ;save fList adrs
        bl      random32
        mov     r1,r0           ;32-bit random value
        pop     {r0}            ;restore fList adrs
        bl      seedItem32
        pop     {pc}

        public  _pbR32randomList64
_pbR32randomList64
        push    {r4-r6,lr}
        mov     r4,r0           ;&fList
        movs    r5,r2           ;loop count
        bls     rL64b           ;if loop count .LE. 0
        mov     r6,r1           ;dest'n adrs
rL64a
        bl      _pbR32random64
        stm     r6!,{r0,r1}
        subs    r5,r5,#1
        bne     rL64a
rL64b
        pop     {r4-r6,pc}

        public  _pbR32randomList32
_pbR32randomList32
        push    {r4-r6,lr}
        mov     r4,r0           ;&fList
        movs    r5,r2           ;loop count
        bls     rL32b           ;if loop count .LE. 0
        mov     r6,r1           ;dest'n adrs
rL32a
        mov     r0,r4           ;&fList
        bl      random32
        str     r1,[r6],#4
        subs    r5,r5,#1
        bne     rL32a           ;if not done
rL32b   pop     {r4-r6,pc}

        public  _pbR32randomList
_pbR32randomList
        push    {r4-r6,lr}
        mov     r4,r0           ;&fList
        movs    r5,r2           ;byte count
        ble     rL32e           ;if zero or negative count
        mov     r6,r1           ;dest'n adrs
rL32c
        mov     r0,r4           ;&fList
        bl      random32
        cmp     r5,#4
        blt     rL32d           ;if fewer than 4 bytes left
        str     r1,[r6],#4
        subs    r5,r5,#4
        bne     rL32c           ;if more to go
        b       rL32e           ;else done
; store trailing partial word
rL32d
        strb    r1,[r6],#1
        lsr     r1,r1,#8
        subs    r5,r5,#1
        bne     rL32c           ;if last byte not stored
rL32e   pop     {r4-r6,pc}

        end
