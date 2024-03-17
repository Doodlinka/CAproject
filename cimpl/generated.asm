	.file	"main.c"
	.text
	.def	__main;	.scl	2;	.type	32;	.endef
	.section .rdata,"dr"
.LC0:
	.ascii "id: \0"
.LC1:
	.ascii ", sum: %ld, count: %d\0"
.LC2:
	.ascii ", value: %.3f\12\0"
	.text
	.globl	main
	.def	main;	.scl	2;	.type	32;	.endef
	.seh_proc	main
main:
	pushq	%rbp
	.seh_pushreg	%rbp
	movl	$240064, %eax
	call	___chkstk_ms
	subq	%rax, %rsp
	.seh_stackalloc	240064
	leaq	128(%rsp), %rbp
	.seh_setframe	%rbp, 128
	.seh_endprologue
	call	__main
	leaq	-96(%rbp), %rax
	movq	%rax, %rcx
	call	readDataFromSTDIN
	movl	%eax, 239924(%rbp)
	movl	$0, 239932(%rbp)
	jmp	.L2
.L3:
	leaq	.LC0(%rip), %rax
	movq	%rax, %rcx
	call	printf
	leaq	-96(%rbp), %rcx
	movl	239932(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	addq	%rax, %rax
	addq	%rdx, %rax
	salq	$3, %rax
	addq	%rcx, %rax
	movq	%rax, %rcx
	call	printstr
	movl	239932(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	addq	%rax, %rax
	addq	%rdx, %rax
	salq	$3, %rax
	leaq	239936(%rax), %rax
	addq	%rbp, %rax
	subq	$240012, %rax
	movzwl	(%rax), %eax
	movzwl	%ax, %ecx
	movl	239932(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	addq	%rax, %rax
	addq	%rdx, %rax
	salq	$3, %rax
	leaq	239936(%rax), %rax
	addq	%rbp, %rax
	subq	$240016, %rax
	movl	(%rax), %eax
	movl	%ecx, %r8d
	movl	%eax, %edx
	leaq	.LC1(%rip), %rax
	movq	%rax, %rcx
	call	printf
	movl	239932(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	addq	%rax, %rax
	addq	%rdx, %rax
	salq	$3, %rax
	leaq	239936(%rax), %rax
	addq	%rbp, %rax
	subq	$240016, %rax
	movl	(%rax), %eax
	pxor	%xmm0, %xmm0
	cvtsi2sdl	%eax, %xmm0
	movl	239932(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	addq	%rax, %rax
	addq	%rdx, %rax
	salq	$3, %rax
	leaq	239936(%rax), %rax
	addq	%rbp, %rax
	subq	$240012, %rax
	movzwl	(%rax), %eax
	movzwl	%ax, %eax
	pxor	%xmm1, %xmm1
	cvtsi2sdl	%eax, %xmm1
	divsd	%xmm1, %xmm0
	movl	239932(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	addq	%rax, %rax
	addq	%rdx, %rax
	salq	$3, %rax
	leaq	239936(%rax), %rax
	addq	%rbp, %rax
	subq	$240016, %rax
	movsd	%xmm0, (%rax)
	movl	239932(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	addq	%rax, %rax
	addq	%rdx, %rax
	salq	$3, %rax
	leaq	239936(%rax), %rax
	addq	%rbp, %rax
	subq	$240016, %rax
	movsd	(%rax), %xmm0
	movq	%xmm0, %rax
	movq	%rax, %rdx
	movq	%rdx, %xmm0
	movapd	%xmm0, %xmm1
	movq	%rax, %rdx
	leaq	.LC2(%rip), %rax
	movq	%rax, %rcx
	call	printf
	addl	$1, 239932(%rbp)
.L2:
	movl	239932(%rbp), %eax
	cmpl	239924(%rbp), %eax
	jl	.L3
	movl	239924(%rbp), %eax
	cltq
	movq	%rax, %rcx
	call	malloc
	movq	%rax, 239912(%rbp)
	movl	239924(%rbp), %ecx
	movq	239912(%rbp), %rdx
	leaq	-96(%rbp), %rax
	movl	%ecx, %r8d
	movq	%rax, %rcx
	call	mergeSort
	movq	%rax, 239904(%rbp)
	movl	$0, 239928(%rbp)
	jmp	.L4
.L5:
	movl	239928(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	addq	%rax, %rax
	addq	%rdx, %rax
	salq	$3, %rax
	movq	%rax, %rdx
	movq	239904(%rbp), %rax
	addq	%rdx, %rax
	movq	%rax, %rcx
	call	printstr
	movl	$10, %ecx
	call	putchar
	addl	$1, 239928(%rbp)
.L4:
	movl	239928(%rbp), %eax
	cmpl	239924(%rbp), %eax
	jl	.L5
	movq	239912(%rbp), %rax
	movq	%rax, %rcx
	call	free
	movl	$0, %eax
	addq	$240064, %rsp
	popq	%rbp
	ret
	.seh_endproc
	.globl	readDataFromSTDIN
	.def	readDataFromSTDIN;	.scl	2;	.type	32;	.endef
	.seh_proc	readDataFromSTDIN
readDataFromSTDIN:
	pushq	%rbp
	.seh_pushreg	%rbp
	movq	%rsp, %rbp
	.seh_setframe	%rbp, 0
	subq	$80, %rsp
	.seh_stackalloc	80
	.seh_endprologue
	movq	%rcx, 16(%rbp)
	movl	$0, -4(%rbp)
	movl	$0, -8(%rbp)
	movl	$0, -24(%rbp)
	movl	$0, -12(%rbp)
	leaq	-48(%rbp), %rax
	movq	%rax, %rcx
	call	fillWithNewlines
	movb	$0, -13(%rbp)
	movl	$0, -20(%rbp)
	jmp	.L8
.L19:
	cmpl	$2, -20(%rbp)
	je	.L9
	cmpl	$2, -20(%rbp)
	ja	.L8
	cmpl	$0, -20(%rbp)
	je	.L10
	cmpl	$1, -20(%rbp)
	je	.L11
	jmp	.L8
.L9:
	leaq	-48(%rbp), %rcx
	movl	-4(%rbp), %edx
	movq	16(%rbp), %rax
	movq	%rcx, %r8
	movq	%rax, %rcx
	call	findRecordWithID
	movl	%eax, -28(%rbp)
	movl	-28(%rbp), %eax
	cmpl	-4(%rbp), %eax
	jne	.L12
	movl	-28(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	addq	%rax, %rax
	addq	%rdx, %rax
	salq	$3, %rax
	movq	%rax, %rdx
	movq	16(%rbp), %rax
	addq	%rdx, %rax
	movq	%rax, %rcx
	leaq	-48(%rbp), %rax
	movq	%rax, %rdx
	call	movstr
	movl	-28(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	addq	%rax, %rax
	addq	%rdx, %rax
	salq	$3, %rax
	movq	%rax, %rdx
	movq	16(%rbp), %rax
	addq	%rdx, %rax
	movl	$0, 16(%rax)
	movl	-28(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	addq	%rax, %rax
	addq	%rdx, %rax
	salq	$3, %rax
	movq	%rax, %rdx
	movq	16(%rbp), %rax
	addq	%rdx, %rax
	movw	$0, 20(%rax)
	addl	$1, -4(%rbp)
.L12:
	cmpb	$0, -13(%rbp)
	je	.L13
	negl	-12(%rbp)
.L13:
	movl	-28(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	addq	%rax, %rax
	addq	%rdx, %rax
	salq	$3, %rax
	movq	%rax, %rdx
	movq	16(%rbp), %rax
	addq	%rdx, %rax
	movl	16(%rax), %ecx
	movl	-28(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	addq	%rax, %rax
	addq	%rdx, %rax
	salq	$3, %rax
	movq	%rax, %rdx
	movq	16(%rbp), %rax
	addq	%rdx, %rax
	movl	-12(%rbp), %edx
	addl	%ecx, %edx
	movl	%edx, 16(%rax)
	movl	-28(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	addq	%rax, %rax
	addq	%rdx, %rax
	salq	$3, %rax
	movq	%rax, %rdx
	movq	16(%rbp), %rax
	addq	%rdx, %rax
	movzwl	20(%rax), %edx
	addl	$1, %edx
	movw	%dx, 20(%rax)
	movl	$0, -8(%rbp)
	movl	$0, -12(%rbp)
	leaq	-48(%rbp), %rax
	movq	%rax, %rcx
	call	fillWithNewlines
	movb	$0, -13(%rbp)
	movl	$0, -20(%rbp)
	cmpl	$13, -24(%rbp)
	je	.L8
	cmpl	$10, -24(%rbp)
	je	.L8
	cmpl	$-1, -24(%rbp)
	je	.L8
.L10:
	cmpl	$32, -24(%rbp)
	jne	.L14
	movl	$1, -20(%rbp)
	jmp	.L8
.L14:
	movl	-24(%rbp), %eax
	movl	%eax, %edx
	movl	-8(%rbp), %eax
	cltq
	movb	%dl, -48(%rbp,%rax)
	addl	$1, -8(%rbp)
	jmp	.L8
.L11:
	cmpl	$13, -24(%rbp)
	je	.L16
	cmpl	$10, -24(%rbp)
	je	.L16
	cmpl	$-1, -24(%rbp)
	jne	.L17
.L16:
	movl	$2, -20(%rbp)
	jmp	.L8
.L17:
	cmpl	$45, -24(%rbp)
	jne	.L18
	movb	$1, -13(%rbp)
	jmp	.L8
.L18:
	movl	-12(%rbp), %edx
	movl	%edx, %eax
	sall	$2, %eax
	addl	%edx, %eax
	addl	%eax, %eax
	movl	%eax, -12(%rbp)
	movl	-24(%rbp), %eax
	subl	$48, %eax
	addl	%eax, -12(%rbp)
.L8:
	call	getchar
	movl	%eax, -24(%rbp)
	cmpl	$-1, -24(%rbp)
	jne	.L19
	cmpl	$0, -20(%rbp)
	jne	.L19
	movl	-4(%rbp), %eax
	addq	$80, %rsp
	popq	%rbp
	ret
	.seh_endproc
	.globl	findRecordWithID
	.def	findRecordWithID;	.scl	2;	.type	32;	.endef
	.seh_proc	findRecordWithID
findRecordWithID:
	pushq	%rbp
	.seh_pushreg	%rbp
	movq	%rsp, %rbp
	.seh_setframe	%rbp, 0
	subq	$16, %rsp
	.seh_stackalloc	16
	.seh_endprologue
	movq	%rcx, 16(%rbp)
	movl	%edx, 24(%rbp)
	movq	%r8, 32(%rbp)
	movl	24(%rbp), %eax
	subl	$1, %eax
	movl	%eax, -4(%rbp)
	jmp	.L22
.L30:
	movb	$1, -5(%rbp)
	movl	$0, -12(%rbp)
	jmp	.L23
.L27:
	movl	-4(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	addq	%rax, %rax
	addq	%rdx, %rax
	salq	$3, %rax
	movq	%rax, %rdx
	movq	16(%rbp), %rax
	addq	%rax, %rdx
	movl	-12(%rbp), %eax
	cltq
	movzbl	(%rdx,%rax), %edx
	movl	-12(%rbp), %eax
	movslq	%eax, %rcx
	movq	32(%rbp), %rax
	addq	%rcx, %rax
	movzbl	(%rax), %eax
	cmpb	%al, %dl
	je	.L24
	movb	$0, -5(%rbp)
	jmp	.L25
.L24:
	movl	-4(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	addq	%rax, %rax
	addq	%rdx, %rax
	salq	$3, %rax
	movq	%rax, %rdx
	movq	16(%rbp), %rax
	addq	%rax, %rdx
	movl	-12(%rbp), %eax
	cltq
	movzbl	(%rdx,%rax), %eax
	cmpb	$10, %al
	je	.L31
	addl	$1, -12(%rbp)
.L23:
	cmpl	$15, -12(%rbp)
	jle	.L27
	jmp	.L25
.L31:
	nop
.L25:
	cmpb	$0, -5(%rbp)
	je	.L28
	movl	-4(%rbp), %eax
	jmp	.L29
.L28:
	subl	$1, -4(%rbp)
.L22:
	cmpl	$0, -4(%rbp)
	jns	.L30
	movl	24(%rbp), %eax
.L29:
	addq	$16, %rsp
	popq	%rbp
	ret
	.seh_endproc
	.globl	movstr
	.def	movstr;	.scl	2;	.type	32;	.endef
	.seh_proc	movstr
movstr:
	pushq	%rbp
	.seh_pushreg	%rbp
	movq	%rsp, %rbp
	.seh_setframe	%rbp, 0
	subq	$16, %rsp
	.seh_stackalloc	16
	.seh_endprologue
	movq	%rcx, 16(%rbp)
	movq	%rdx, 24(%rbp)
	movl	$0, -4(%rbp)
	jmp	.L33
.L34:
	movl	-4(%rbp), %eax
	movslq	%eax, %rdx
	movq	24(%rbp), %rax
	addq	%rdx, %rax
	movl	-4(%rbp), %edx
	movslq	%edx, %rcx
	movq	16(%rbp), %rdx
	addq	%rcx, %rdx
	movzbl	(%rax), %eax
	movb	%al, (%rdx)
	addl	$1, -4(%rbp)
.L33:
	cmpl	$15, -4(%rbp)
	jle	.L34
	nop
	nop
	addq	$16, %rsp
	popq	%rbp
	ret
	.seh_endproc
	.globl	fillWithNewlines
	.def	fillWithNewlines;	.scl	2;	.type	32;	.endef
	.seh_proc	fillWithNewlines
fillWithNewlines:
	pushq	%rbp
	.seh_pushreg	%rbp
	movq	%rsp, %rbp
	.seh_setframe	%rbp, 0
	subq	$16, %rsp
	.seh_stackalloc	16
	.seh_endprologue
	movq	%rcx, 16(%rbp)
	movl	$0, -4(%rbp)
	jmp	.L36
.L37:
	movl	-4(%rbp), %eax
	movslq	%eax, %rdx
	movq	16(%rbp), %rax
	addq	%rdx, %rax
	movb	$10, (%rax)
	addl	$1, -4(%rbp)
.L36:
	cmpl	$15, -4(%rbp)
	jle	.L37
	nop
	nop
	addq	$16, %rsp
	popq	%rbp
	ret
	.seh_endproc
	.globl	mergeSort
	.def	mergeSort;	.scl	2;	.type	32;	.endef
	.seh_proc	mergeSort
mergeSort:
	pushq	%rbp
	.seh_pushreg	%rbp
	movq	%rsp, %rbp
	.seh_setframe	%rbp, 0
	subq	$32, %rsp
	.seh_stackalloc	32
	.seh_endprologue
	movq	%rcx, 16(%rbp)
	movq	%rdx, 24(%rbp)
	movl	%r8d, 32(%rbp)
	movl	$1, -4(%rbp)
	jmp	.L39
.L49:
	movl	-4(%rbp), %eax
	movl	%eax, -8(%rbp)
	movl	-4(%rbp), %eax
	addl	%eax, %eax
	movl	%eax, -12(%rbp)
	movl	-12(%rbp), %eax
	cmpl	32(%rbp), %eax
	jl	.L40
	movl	32(%rbp), %eax
	movl	%eax, -12(%rbp)
.L40:
	movl	$0, -16(%rbp)
	movl	-4(%rbp), %eax
	movl	%eax, -20(%rbp)
	movl	$0, -24(%rbp)
	movl	$0, -24(%rbp)
	jmp	.L41
.L48:
	movl	-16(%rbp), %eax
	cmpl	-8(%rbp), %eax
	jge	.L42
	movl	-20(%rbp), %eax
	cmpl	-12(%rbp), %eax
	jge	.L43
	movl	-16(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	addq	%rax, %rax
	addq	%rdx, %rax
	salq	$3, %rax
	movq	%rax, %rdx
	movq	16(%rbp), %rax
	addq	%rdx, %rax
	movsd	16(%rax), %xmm0
	movl	-20(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	addq	%rax, %rax
	addq	%rdx, %rax
	salq	$3, %rax
	movq	%rax, %rdx
	movq	16(%rbp), %rax
	addq	%rdx, %rax
	movsd	16(%rax), %xmm1
	comisd	%xmm1, %xmm0
	jb	.L42
.L43:
	movl	-16(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	addq	%rax, %rax
	addq	%rdx, %rax
	salq	$3, %rax
	movq	%rax, %rdx
	movq	16(%rbp), %rax
	leaq	(%rdx,%rax), %r8
	movl	-24(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	addq	%rax, %rax
	addq	%rdx, %rax
	salq	$3, %rax
	movq	%rax, %rdx
	movq	24(%rbp), %rax
	leaq	(%rdx,%rax), %rcx
	movq	(%r8), %rax
	movq	8(%r8), %rdx
	movq	%rax, (%rcx)
	movq	%rdx, 8(%rcx)
	movq	16(%r8), %rax
	movq	%rax, 16(%rcx)
	addl	$1, -16(%rbp)
	addl	$1, -24(%rbp)
	jmp	.L45
.L42:
	movl	-20(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	addq	%rax, %rax
	addq	%rdx, %rax
	salq	$3, %rax
	movq	%rax, %rdx
	movq	16(%rbp), %rax
	leaq	(%rdx,%rax), %r8
	movl	-24(%rbp), %eax
	movslq	%eax, %rdx
	movq	%rdx, %rax
	addq	%rax, %rax
	addq	%rdx, %rax
	salq	$3, %rax
	movq	%rax, %rdx
	movq	24(%rbp), %rax
	leaq	(%rdx,%rax), %rcx
	movq	(%r8), %rax
	movq	8(%r8), %rdx
	movq	%rax, (%rcx)
	movq	%rdx, 8(%rcx)
	movq	16(%r8), %rax
	movq	%rax, 16(%rcx)
	addl	$1, -20(%rbp)
	addl	$1, -24(%rbp)
.L45:
	movl	-24(%rbp), %eax
	cmpl	-12(%rbp), %eax
	jl	.L41
	movl	-12(%rbp), %eax
	movl	%eax, -16(%rbp)
	movl	-4(%rbp), %eax
	addl	%eax, %eax
	addl	%eax, -8(%rbp)
	movl	-8(%rbp), %eax
	cmpl	32(%rbp), %eax
	jl	.L46
	movl	32(%rbp), %eax
	movl	%eax, -8(%rbp)
.L46:
	movl	-4(%rbp), %eax
	addl	%eax, %eax
	addl	%eax, -12(%rbp)
	movl	-12(%rbp), %eax
	cmpl	32(%rbp), %eax
	jl	.L47
	movl	32(%rbp), %eax
	movl	%eax, -12(%rbp)
.L47:
	movl	-8(%rbp), %eax
	movl	%eax, -20(%rbp)
.L41:
	movl	-24(%rbp), %eax
	cmpl	32(%rbp), %eax
	jl	.L48
	movq	24(%rbp), %rax
	movq	%rax, -32(%rbp)
	movq	16(%rbp), %rax
	movq	%rax, 24(%rbp)
	movq	-32(%rbp), %rax
	movq	%rax, 16(%rbp)
	sall	-4(%rbp)
.L39:
	movl	-4(%rbp), %eax
	cmpl	32(%rbp), %eax
	jl	.L49
	movq	16(%rbp), %rax
	addq	$32, %rsp
	popq	%rbp
	ret
	.seh_endproc
	.globl	printstr
	.def	printstr;	.scl	2;	.type	32;	.endef
	.seh_proc	printstr
printstr:
	pushq	%rbp
	.seh_pushreg	%rbp
	movq	%rsp, %rbp
	.seh_setframe	%rbp, 0
	subq	$48, %rsp
	.seh_stackalloc	48
	.seh_endprologue
	movq	%rcx, 16(%rbp)
	movl	$0, -4(%rbp)
	jmp	.L52
.L55:
	movl	-4(%rbp), %eax
	movslq	%eax, %rdx
	movq	16(%rbp), %rax
	addq	%rdx, %rax
	movzbl	(%rax), %eax
	cmpb	$10, %al
	je	.L56
	movl	-4(%rbp), %eax
	movslq	%eax, %rdx
	movq	16(%rbp), %rax
	addq	%rdx, %rax
	movzbl	(%rax), %eax
	movsbl	%al, %eax
	movl	%eax, %ecx
	call	putchar
	addl	$1, -4(%rbp)
.L52:
	cmpl	$15, -4(%rbp)
	jle	.L55
	jmp	.L51
.L56:
	nop
.L51:
	addq	$48, %rsp
	popq	%rbp
	ret
	.seh_endproc
	.ident	"GCC: (MinGW-W64 x86_64-ucrt-mcf-seh, built by Brecht Sanders) 13.2.0"
	.def	printf;	.scl	2;	.type	32;	.endef
	.def	malloc;	.scl	2;	.type	32;	.endef
	.def	putchar;	.scl	2;	.type	32;	.endef
	.def	free;	.scl	2;	.type	32;	.endef
	.def	getchar;	.scl	2;	.type	32;	.endef
