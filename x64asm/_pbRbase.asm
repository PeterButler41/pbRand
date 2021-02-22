; _pbRbase.asm

; _pbR2064.asm
; ==> must return unchanged: RBX, RBP, and R12..R15
;R8–R15 are the new 64-bit registers.
;R8D–R15D are the lowermost 32 bits of each register.
;R8W–R15W are the lowermost 16 bits of each register.
;R8B–R15B are the lowermost 8 bits of each register.

; The first four  user call arguments are in RCX, RDX, R8, R9
; (but we are never called with more than 3 arguments)
; The first parameter, rcx, is the adrs of what might
;  be called seed[-1]. That word, the fList, precedes seed[].

; User call code MUST load &seed[0] into rsi

cntReg  equ     r8d ; shared between all modules
adrsReg equ     r9  ; (only used in the list functions)
funcReg equ     r10 ;only used in base
;**********************************************************************
;
; fList offsets
;
ofs_init         equ  0*2 ;only useful after calling initxxyy
ofs_seedItem64   equ  4*2
ofs_seedItem32   equ  8*2
ofs_seedSelf     equ 12*2
ofs_mix          equ 16*2
ofs_random64     equ 20*2
ofs_random32     equ 24*2
ofs_seedList64   equ 28*2
ofs_seedList32   equ 32*2
ofs_seedList     equ 36*2 ;byte count - best way
ofs_randomList64 equ 40*2
ofs_randomList32 equ 44*2
ofs_randomList   equ 48*2

        .code

ofs     textequ <ofs_>
zzz     macro   arg
        public  arg
arg:
duhArg  textequ <arg>
_offset catstr  ofs, duhArg
        mov     rsi,rcx         ;rsi is tbl
        lodsq   ;load &fList adrs and set tbl=&seed[0]
        mov     rax,[rax+_offset]
        call    rax
        ret
        endm

;        zzz    init
;SEE BELOW FOR zzz init
init:
        mov     rsi,rcx         ;rsi is tbl
        lodsq   ;load &fList adrs and set tbl=&seed[0]
        mov     rax,[rax+ofs_init]
        call    rax
        ret

        zzz    seedItem64
        zzz    seedItem32
        zzz    seedSelf
;       zzz    mix
        zzz    random64
        zzz    random32
        zzz    seedList64
        zzz    seedList32
        zzz    seedList
        zzz    randomList64
        zzz    randomList32
        zzz    randomList

;**********************************************************************
; void mix(int nTimes = 10);
; r8=count

        public  mix
; on entry rdx = count
mix:
        mov     rsi,rcx
        lodsq
        mov     funcReg,[rax+ofs_mix]
        or      cntReg,cntReg
        jbe     exit            ;nop if count .LE. zero
mix1:
        call    funcReg         ;one mix
        dec     cntReg
        jnbe    mix1            ;if not done
exit:   ret

        public  seedList16
seedList16:
; cntReg set by call
        mov     adrsReg,rdx     ;string address
        or      cntReg,cntReg
        jbe     exit            ;nop if count .LE. zero
sL16a:
        mov     dx,[adrsReg]
        add     adrsReg,2
        call    seedItem16        ;ends up returning from seedItem32
        dec     cntReg
        jnbe    sL16a
        ret

        public  seedList8
seedList8:
        mov     rsi,rcx         ;rsi is tbl
        lodsq   ;load &fList adrs and set tbl=&seed[0]
        mov     funcReg,[rax+ofs_seedItem32]
        mov     adrsReg,rdx     ;string address
        or      cntReg,cntReg
        jbe     exit            ;nop if count .LE. zero
L8a:
        mov     dl,[adrsReg]
        inc     adrsReg
        call    seedItem8
        dec     cntReg
        jnbe    L8a             ;if not done
; SHOULD WE CALL MIX?
        ret

; void seedCstring(const int8_t *str);
        public  seedCstring
seedCstring:
        mov     rsi,rcx         ;rsi is tbl
        lodsq   ;load &fList adrs and set tbl=&seed[0]
        mov     funcReg,[rax+ofs_seedItem32]
        mov     adrsReg,rdx     ;string address
sCstr1:
        mov     dl,[adrsReg]
        inc     adrsReg
        or      dl,dl
        jz      sCstr2
        call   seedItem8
        jmp     sCstr1
sCstr2:
; SHOULD WE CALL MIX?
        ret

;**********************************************************************
; helper code for seedList16, 8 and Cstring
;**********************************************************************

public  seedItem8,seedByte,seedChar,seedItem16
;        rseg    .text:NOROOT:CODE(2)
seedItem8:
seedByte:
seedChar:
        and     edx,0FFh
seedItem16:
        and     edx,0FFFFh
        mov     eax,edx
        mov     edx,33*33
        mul     edx
        mov     edx,eax
        jmp     funcReg

        end

