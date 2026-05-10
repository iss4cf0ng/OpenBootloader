; entry.asm
; Stage 2 entry point
; Switch 16-bit Real Mode to 32-bit Protected Mode, call bootloader_main() written in C

[BITS 16]
[ORG 0x8000]

extern bootloader_main
extern __bss_start
extern __bss_end

global _start

_start:


print:
    pusha
.loop
    lodsb
    test al, al
    jz .done
    mov ah, 0x0E
    mov bh, 0
    int 0x10
    jmp .loop
.done:
    popa
    ret

; GDT

gdt_start:

gdt_null:
    dq 0

; Code Segment (selector 0x08): Base=0, Limit=4GB, Ring0, 32-bit
gdt_code:
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10011010b
    db 11001111b
    db 0x00

gdt_data:
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10010010b
    db 11001111b
    db 0x00

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

boot_drive_store: db 0
msg_stage2: db "Stage2: Entry (16-bit OK)", 0x0D, 0x0A, 0

; 32-bit Protected Mode

protected_mode_entry:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    mov esp, 0x90000 ; stack

    ; clear BSS (C environment requires all global variables to be zero)
    mov edi, __bss_start
    mov ecx, __bss_end
    sub ecx, edi
    xor eax, eax
    rep stosd

    movzx eax, byte [boot_drive_store]

.hang
    hlt
    jmp .hang