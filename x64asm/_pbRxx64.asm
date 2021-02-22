; _pbRxx64.asm
; implements "List" functions for 64-bit seeds

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
ofs_init         equ  0*2 ;only useful after calling initxxyy
ofs_seedItem64   equ  4*2
ofs_seedItem32   equ  8*2
ofs_seedSelf     equ 12*2
ofs_mix          equ 16*2
ofs_random64     equ 20*2
ofs_random32     equ 24*2 ;(caller ignores bits 32..63)
ofs_seedList64   equ 28*2
ofs_seedList32   equ 32*2
ofs_seedList     equ 36*2 ;byte count - best way
ofs_randomList64 equ 40*2
ofs_randomList32 equ 44*2
ofs_randomList   equ 48*2

; some register defs used in these modules
AAA     equ     rax
BBB     equ     r11
CCC     equ     rcx
DDD     equ     rdx
temp    equ     rdi
tbl     equ     rsi

cntReg  equ     r8d ; shared between all modules
adrsReg equ     r9  ; (only used in the list functions)
funcReg equ     r10 ;used for fList items

        .code

        public  _64seedList64
        public  _64seedList32
        public  _64seedList
        public  _64randomList64
        public  _64randomList32
        public  _64randomList

; all of these functions are called from base via an fList:
; mov     rsi,rcx         ;rsi is tbl
; lodsq   ;load &fList adrs and set tbl=&seed[0]
; mov     rax,[rax+ofs_WHATEVER]
; call    rax
; ret

; Thus when we are called the original user call arguments
; RCX = &fList, RDX = list address, R8 = count

;**********************************************************************
; seed from lists
;**********************************************************************

_64seedList64:
        mov     funcReg,[rcx]
        mov     funcReg,[funcReg+ofs_seedItem64]
        mov     adrsReg,rdx
        or      cntReg,cntReg
        jbe     exit            ;nop if count .LE. zero
SL64a:
        mov     rdx,[adrsReg]
        add     adrsReg,8
        call    funcReg
        dec     cntReg
        jnbe    SL64a
exit:   ret

;**********************************************************************

_64seedList32:
        mov     funcReg,[rcx]
        mov     funcReg,[funcReg+ofs_seedItem32]
        mov     adrsReg,rdx
        or      cntReg,cntReg
        jbe     exit            ;nop if count .LE. zero
SL32a:
        mov     edx,[adrsReg]
        add     adrsReg,4
        call    funcReg
        dec     cntReg
        jnbe    SL32a
        ret

;**********************************************************************

_64seedList:
        mov     funcReg,[rcx]
        mov     funcReg,[funcReg+ofs_seedItem64]
        mov     adrsReg,rdx
        or      cntReg,cntReg
        jbe     exit            ;nop if count .LE. zero
SLa:
        mov     rdx,[adrsReg]
        cmp     cntReg,7
        jbe     SLb             ;if seeding last fraction
        call    funcReg
        sub     cntReg,8
        jne     SLa
        ret

; now do that last part
; cntReg in 1..7
SLb:
        xor     rax,rax         ;all zero bits
        not     rax             ;all one bits
        mov     ecx,cntReg      ;remaining count...
        shl     cl,3            ;...times 8
        shr     rax,cl          ;make mask
        and     rdx,rax         ;zap bytes we dont want
        call    funcReg
        ret

;**********************************************************************
; make lists of random values
;**********************************************************************

_64randomList64:
        mov     funcReg,[rcx]
        mov     funcReg,[funcReg+ofs_random64]
        mov     adrsReg,rdx
        or      cntReg,cntReg
        jbe     exit            ;nop if count .LE. zero
RS64a:
        call    funcReg
        mov     [adrsReg],rax
        add     adrsReg,8
        dec     cntReg
        jnbe    RS64a           ;if not done
        ret

;**********************************************************************

_64randomList32:
        mov     funcReg,[rcx]
        mov     funcReg,[funcReg+ofs_random32]
        mov     adrsReg,rdx
        or      cntReg,cntReg
        jbe     exit            ;nop if count .LE. zero
RS32a:
        call    funcReg
        mov     [adrsReg],eax
        add     adrsReg,4
        dec     cntReg
        jnbe    RS32a           ;if not done
        ret

;**********************************************************************

_64randomList:
        mov     funcReg,[rcx]
        mov     funcReg,[funcReg+ofs_random64]
        mov     adrsReg,rdx
        or      cntReg,cntReg
        jbe     exit            ;nop if count .LE. zero
RLa:    call    funcReg
        cmp     cntReg,7
        jle     RLb             ;if to finish w/ fractional store
        mov     [adrsReg],rax
        add     adrsReg,8
        sub     cntReg,8
        jne     RLa             ;if not done
        ret                     ;no fractional part
; fractional part...
; cntReg is 1..7
RLb:    mov     [adrsReg],al
        inc     adrsReg
        dec     cntReg
        jne     RLb             ;if not done
        ret

        end
