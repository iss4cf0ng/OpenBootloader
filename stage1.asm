; stage1.asm — MBR loader
; Load stage2 LBA 1 into 0x0000:0x8000 and jump to it
; Size of the binary must be smaller than 446 bytes

BITS 16 ; real-mode
ORG 0x7C00

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti

    ; Read stage2
    ; Start at LBA 1, read 16 sectors (512 byte x 16 = 8 KB), to 0x0000:0x8000
    mov si, dap
    mov ah, 0x42
    mov dl, 0x80
    int 13h
    jc error

    jmp 0x0000:0x8000

error:
    mov si, err_msg

.print:
    lodsb
    cmp al, 0
    je .hang
    mov ah, 0x0E
    mov bx, 0x0007
    int 10h
    jmp .print

.hang:
    hlt
    jmp .hang

err_msg db "Stage1 load error!", 0

; DAP (Disk Address Packet)
align 4
dap:
    db 0x10 ; DAP Size
    db 0x00 ; reserved
    dw 16 ; sector count (16 sectors, 8 KB)
    dw 0x8000 ; destination offset
    dw 0x0000 ; destination segment
    dq 1 ; LBA start (sector 1)

; MBR signature
times 510 - ($ - $$) db 0
dw 0xAA55