; _pbRxx32.asm
; implements "List" functions for 32-bit seeds

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

        public  _32seedList64
        public  _32seedList32
        public  _32seedList
        public  _32randomList64
        public  _32randomList32
        public  _32randomList

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

_32seedList64:
        shl     cntReg,1
;       ...     cheep asm trick, double the count & fall into func
_32seedList32:
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
exit:   ret

;**********************************************************************

_32seedList:
        mov     funcReg,[rcx]
        mov     funcReg,[funcReg+ofs_seedItem32]
        mov     adrsReg,rdx
        or      cntReg,cntReg
        jbe     exit            ;nop if count .LE. zero
SLa:
        mov     edx,[adrsReg]
        add     adrsReg,4
        cmp     cntReg,3
        jbe     SLb             ;if seeding last fraction
        call    funcReg
        sub     cntReg,4
        jne     SLa
        ret

; now do that last part
; cntReg in 1..3
SLb:
        xor     eax,eax         ;all zero bits
        not     eax             ;all one bits
        mov     ecx,cntReg      ;remaining count...
        shl     cl,3            ;...times 8
        shr     eax,cl          ;make mask
        and     edx,eax         ;zap bytes we dont want
        call    funcReg
        ret

;**********************************************************************
; make lists of random values
;**********************************************************************

_32randomList64:
        shl     cntReg,1        ;count *= 2
;       ...                     ;fall into randomList21
_32randomList32:
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

_32randomList:
        mov     funcReg,[rcx]
        mov     funcReg,[funcReg+ofs_random32]
        mov     adrsReg,rdx
        or      cntReg,cntReg
        jbe     exit            ;nop if count .LE. zero
RLa:    call    funcReg
        cmp     cntReg,3
        jle     RLb             ;if to finish w/ fractional store
        mov     [adrsReg],eax
        add     adrsReg,4
        sub     cntReg,4
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
