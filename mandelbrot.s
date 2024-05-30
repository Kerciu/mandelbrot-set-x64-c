section .text
global mandelbrot

; int mandelbrot(unsigned char* pixelBuffer, int width, int height,
;                int processPower, int setPoint, double centerReal,
;                double centerImag, double zoom);
;
; RDI = pixelBuffer;
; RSI = width;
; RDX = height
; RCX = processPower;
; R8 = setPoint;
; xmm0 = centerReal;
; xmm1 = centerImag;
; xmm2 = zoom;

mandelbrot:
    ; Prologue
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14

    ; Body

    ; Check if width or height are not positive
    cmp rsi, 0      ; if (width <= 0)
    jle  end
    cmp rdx, 0      ; if (height <= 0)
    jle  end

    ; Calculate buffer size: r9 = bufferSize = 4 * width * height
    mov rax, rsi
    imul rax, rdx
    shl rax, 2
    mov r9, rax

    ; Initialize idx = 0
    xor r10, r10          ; r10 = idx = 0

    ; Initialize y = (double) height
    cvtsi2sd        xmm3, rdx

for_y_loop:
    ; Initialize x = (double) width
    cvtsi2sd xmm4, rsi

for_x_loop:
    ; Check loop conditions
    pxor   xmm5, xmm5
    ucomisd xmm3, xmm5
    jbe     end

    ucomisd xmm4, xmm5
    jbe     end_x_loop

    ; Check if idx >= bufferSize
    cmp r10, r9
    jge end

    ; Calculate cReal
    ; xmm6 = cReal = (x / width - 0.5) * 4.0 / zoom + centerReal
    ; (4x - 2width) / (width * zoom) + centerReal
    movsd  xmm6, xmm4
    mov rax, 4
    cvtsi2sd xmm5, rax
    mulsd xmm6, xmm5        ; 4x
    mov rax, 2
    cvtsi2sd xmm5, rax
    cvtsi2sd xmm12, rsi
    mulsd xmm12, xmm5       ; 2width
    subsd xmm6, xmm12       ; 4x - 2width
    cvtsi2sd xmm5, rsi
    mulsd xmm5, xmm2        ; width * zoom
    divsd xmm6, xmm5
    addsd xmm6, xmm0

    ; Calculate cImag
    ; xmm8 = cImag = (y / height - 0.5) * 4.0 / zoom + centerImag
    movsd  xmm7, xmm3
    mov rax, 4
    cvtsi2sd xmm5, rax
    mulsd xmm7, xmm5        ; 4x
    mov rax, 2
    cvtsi2sd xmm5, rax
    cvtsi2sd xmm12, rdx
    mulsd xmm12, xmm5       ; 2width
    subsd xmm7, xmm12       ; 4x - 2width
    cvtsi2sd xmm5, rdx
    mulsd xmm5, xmm2        ; width * zoom
    divsd xmm7, xmm5
    addsd xmm7, xmm1

    ; isInSet(cReal=xmm5, cImag=xmm8, processPower=rcx, setPoint=r8)

    ; Initialize Iters
    xor r13, r13        ; int i = 0

    ; Initialize zReal and zImag
    pxor xmm8, xmm8      ; zReal
    pxor xmm9, xmm9     ; zImag
is_in_mandelbrot:

    ; Check if Iters < processPower
    mov rax, rcx
    cmp r13, rax
    jge return_iter
    inc r13

    ; x^2 + 2xyj - y^2
    movsd xmm10, xmm8    ; xmm10 = zReal copy
    movsd xmm11, xmm9   ; xmm11 = zImag copy

    mulsd xmm10, xmm10    ; zReal^2
    mulsd xmm11, xmm11    ; zImag^2
    subsd xmm10, xmm11    ; xmm10 = zReal^2 - zImag^2

    movsd xmm11, xmm9   ; xmm11 = zImag
    mulsd xmm11, xmm8    ; zReal * zImag
    addsd xmm11, xmm11    ; xmm11 = 2 * zReal * zImag

    ; zReal = complexSquaredReal + cReal
    addsd xmm10, xmm6    ; xmm9 = zReal = (zReal^2 - zImag^2) + cReal
    ; zReal = complexSquaredReal + cReal
    addsd xmm11, xmm7    ; xmm9 = zReal = (zReal^2 - zImag^2) + cReal

    ; Update zReal and zImag
    movsd xmm8, xmm10
    movsd xmm9, xmm11

    ; Calculate |z|
    movsd xmm10, xmm8
    movsd xmm11, xmm9
    mulsd xmm10, xmm10
    mulsd xmm11, xmm11
    addsd xmm10, xmm11  ; xmm10 = |z|

    ; Check if |z| > setPoint^2
    mov rax, r8
    imul rax, r8
    cvtsi2sd xmm11, rax   ; xmm10 = setPoint ^ 2
    ucomisd xmm10, xmm11
    jbe is_in_mandelbrot

    ; Save zReal and zImag before updating them
    movsd xmm10, xmm8
    movsd xmm11, xmm9

    ; Update zReal and zImag
    movsd xmm8, xmm10
    movsd xmm9, xmm11

return_iter:
    mov rax, rcx
    cmp r13, rax
    jne  iters_not_equal_process

    mov rbx, 0
    jmp draw_pixel

next_pixel:
    add r10, 4
    mov rax, 1
    cvtsi2sd xmm5, rax
    subsd  xmm4, xmm5    ; decrement x

    ; Check if x counter < width
    jmp  for_x_loop

iters_not_equal_process:
    ; r = (iters * 255) / processPower;
    mov rax, r13
    imul rax, 255
    div rcx
    mov rbx, rax        ; RBX = (iters * 255) / processPower;

draw_pixel:
    mov rax, rdx
    cvtsd2si r14, xmm3
    sub rax, r14
    mul rsi
    cvtsd2si r14, xmm4
    add rax, r14
    shl rax, 2
    mov r10, rax        ; r10 = pixelIdx

    mov byte[rdi + r10], bl
    mov byte[rdi + r10], bl
    mov byte[rdi + r10], bl
    mov byte[rdi + r10], 255

    jmp next_pixel

end_x_loop:
    mov rax, 1
    cvtsi2sd xmm5, rax
    subsd xmm3, xmm5    ; decrement y
    jmp for_y_loop

end:
    ; Epilogue
    pop r14
    pop r13
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
