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
    sub rsp, 32
    push rbx
    push r12
    push r13
    push r14
    push r15

    ; Body
    mov [rbp - 8], rdx

    ; Check if width or height are not positive
    test rsi, rsi
    jle end
    test rdx, rdx
    jle end

    ; Calculate buffer size: r9 = bufferSize = 4 * width * height
    mov rax, rsi
    imul rax, rdx
    shl rax, 2
    mov r9, rax

    ; Initialize y = 0 (integer for loop control)
    xor r12, r12          ; r12 = y = 0

for_y_loop:
    ; Check if y < height
    mov rax, [rbp - 8]
    sub rax, 1
    cmp r12, rax
    jge end

    ; Initialize x = 0 (integer for loop control)
    xor r14, r14          ; r14 = x = 0

for_x_loop:
    ; Check if x < width
    mov rax, rsi
    sub rax, 1
    cmp r14, rax
    jge end_x_loop

    ; Calculate cReal
    ; xmm6 = cReal = (x / width - 0.5) * 4.0 / zoom + centerReal
    ; cReal = (4x - 2width) / (width * zoom) + centerReal
    mov rax, r14
    cvtsi2sd xmm4, rax
    mov rax, 4
    cvtsi2sd xmm5, rax
    mulsd xmm4, xmm5        ; 4x
    mov rax, 2
    cvtsi2sd xmm5, rax
    cvtsi2sd xmm12, rsi
    mulsd xmm12, xmm5       ; 2width
    subsd xmm4, xmm12       ; 4x - 2width
    cvtsi2sd xmm5, rsi
    mulsd xmm5, xmm2        ; width * zoom
    divsd xmm4, xmm5
    addsd xmm4, xmm0
    movsd xmm6, xmm4        ; xmm6 = cReal

    ; Calculate cImag
    ; xmm7 = cImag = (y / height - 0.5) * 4.0 / zoom + centerImag
    mov rax, r12
    cvtsi2sd xmm4, rax
    mov rax, 4
    cvtsi2sd xmm5, rax
    mulsd xmm4, xmm5        ; 4y
    mov rax, 2
    cvtsi2sd xmm5, rax
    mov rax, [rbp - 8]
    cvtsi2sd xmm12, rax
    mulsd xmm12, xmm5       ; 2height
    subsd xmm4, xmm12       ; 4y - 2height
    cvtsi2sd xmm5, rax
    mulsd xmm5, xmm2        ; height * zoom
    divsd xmm4, xmm5
    addsd xmm4, xmm1
    movsd xmm7, xmm4        ; xmm7 = cImag

    ; isInSet(cReal=xmm5, cImag=xmm8, processPower=rcx, setPoint=r8)

    ; Initialize Iters
    xor r13, r13        ; int i = 0

    ; Initialize zReal and zImag
    xorpd xmm8, xmm8      ; zReal
    xorpd xmm9, xmm9     ; zImag

is_in_mandelbrot:
    ; Check if Iters >= processPower
    cmp r13, rcx
    jge max_iter_reached

    ; x^2 + 2xyj - y^2
    movaps xmm10, xmm8    ; xmm10 = zReal copy
    movaps xmm11, xmm9   ; xmm11 = zImag copy

    mulsd xmm10, xmm10    ; zReal^2
    mulsd xmm11, xmm11    ; zImag^2
    subsd xmm10, xmm11    ; xmm10 = zReal^2 - zImag^2

    movaps xmm11, xmm9   ; xmm11 = zImag
    mulsd xmm11, xmm8    ; zReal * zImag
    addsd xmm11, xmm11    ; xmm11 = 2 * zReal * zImag

    ; zReal = complexSquaredReal + cReal
    addsd xmm10, xmm6    ; xmm9 = zReal = (zReal^2 - zImag^2) + cReal
    ; zReal = complexSquaredReal + cReal
    addsd xmm11, xmm7    ; xmm9 = zReal = (zReal^2 - zImag^2) + cReal

    ; Update zReal and zImag
    movaps xmm8, xmm10
    movaps xmm9, xmm11

    ; Calculate |z|
    movaps xmm10, xmm8
    movaps xmm11, xmm9
    mulsd xmm10, xmm10
    mulsd xmm11, xmm11
    addsd xmm10, xmm11  ; xmm10 = |z|

    ; Check if |z| > setPoint^2
    mov rax, r8
    imul rax, r8
    cvtsi2sd xmm11, rax   ; xmm10 = setPoint ^ 2
    ucomisd xmm10, xmm11
    jae return_iter

    inc r13
    jmp is_in_mandelbrot

max_iter_reached:
    ; If max iterations reached, set color to black
    xor rbx, rbx          ; RBX = 0 (black color)
    jmp set_pixel

return_iter:
    mov rax, r13
    imul rax, 255
    xor rdx, rdx
    div rcx
    mov rbx, rax            ; RBX = (iters * 255) / processPower

set_pixel:
    ; idx = 4 * (y * width + x)
    mov rax, rsi        ; rax = width
    imul rax, r12       ; rax = width * y
    add rax, r14        ; rax = width * y + x
    shl rax, 2          ; rax = 4 * (width * y + x)
    add rdi, rax        ; rdi = pixelBuffer + idx

    ; Set pixel color values
    mov byte [rdi], bl      ; Set red component
    mov byte [rdi + 1], bl  ; Set green component
    mov byte [rdi + 2], bl  ; Set blue component
    mov byte [rdi + 3], 255 ; Set alpha component

    ; Restore rdi for next pixel calculation
    sub rdi, 4

next_pixel:
    inc r14                 ; increment x
    jmp for_x_loop

end_x_loop:
    inc r12                 ; increment y
    jmp for_y_loop

end:
    ; Epilogue
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    add rsp, 32
    mov rsp, rbp
    pop rbp
    ret
