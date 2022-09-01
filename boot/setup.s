INITSEG = 0x9000
entry _start
_start:
	mov	ah,#0x03		! read cursor pos
	xor	bh,bh
	int	0x10
	
	mov	cx,#25
	mov	bx,#0x0007		! page 0, attribute 7 (normal)
	mov	bp,#msg2
	mov ax,cs
	mov es,ax
	mov	ax,#0x1301		! write string, move cursor
	int	0x10

    mov ax,cs
    mov es,ax
! init ss:sp
    mov ax,#INITSEG
    mov ss,ax
    mov sp,#0xFF00

! read the paramters and store in 0x9000

	mov    ax,#INITSEG
	mov    ds,ax

	! stor cursor
	mov    ah,#0x03
	xor    bh,bh
	int    0x10
	mov    [0],dx

	! store memory size
	mov    ah,#0x88
	int    0x15
	mov    [2],ax

	! 从 0x41 处拷贝 16 个字节（磁盘参数表）
	mov    ax,#0x0000
	mov    ds,ax
	lds    si,[4*0x41]
	mov    ax,#INITSEG
	mov    es,ax
	mov    di,#0x0004
	mov    cx,#0x10
	! 重复16次
	rep
	movsb	

! Be Ready to Print
    mov ax,cs
    mov es,ax
    mov ax,#INITSEG
    mov ds,ax

! Cursor Position
    mov ah,#0x03
    xor bh,bh
    int 0x10
    mov cx,#18
    mov bx,#0x0007
    mov bp,#msg_cursor
    mov ax,#0x1301
    int 0x10
    mov dx,[0]
    call    print_hex

! Memory Size
    mov ah,#0x03
    xor bh,bh
    int 0x10
    mov cx,#14
    mov bx,#0x0007
    mov bp,#msg_memory
    mov ax,#0x1301
    int 0x10
    mov dx,[2]
    call    print_hex


inf_loop:
	jmp inf_loop

print_hex:
    mov    cx,#4
print_digit:
    rol    dx,#4
    mov    ax,#0xe0f
    and    al,dl
    add    al,#0x30
    cmp    al,#0x3a
    jl     outp
    add    al,#0x07
outp:
    int    0x10
    loop   print_digit
    ret
print_nl:
    mov    ax,#0xe0d     ! CR
    int    0x10
    mov    al,#0xa     ! LF
    int    0x10
    ret

msg2:
	.byte 13,10
	.ascii "now we are in setup"
	.byte 13,10,13,10

msg_cursor:
    .byte 13,10
    .ascii "Cursor position:"

msg_memory:
    .byte 13,10
    .ascii "Memory Size:"

.org 510
boot_flag:
	.word 0xAA55
