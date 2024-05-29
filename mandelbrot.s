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

    ; Body

    ; Check if width or height are not positive
    cmp rsi, 0      ; if (width <= 0)
    jle  end
    cmp rdx, 0      ; if (height <= 0)
    jle  end

    ; Calculate buffer size: r9 = bufferSize = 4 * width * height
    mov rax, rsi
    imul rax, rdx
    sal rax, 2
    mov r9, rax

    ; Initialize idx = 0
    xor r10, r10          ; r10 = idx = 0

    ; Initialize y = 0
    xor r12, r12

    pxor xmm3, xmm3         ; xmm3 = y = 0
    pxor xmm4, xmm4        ; xmm4 = x = 0

for_y_loop:
    ; Initialize x = 0
    xor r11, r11

for_x_loop:
    ; Check if idx >= bufferSize
    cmp r10, r9
    jge end

    ; Check loop conditions
    mov rax, rdx
    dec rax
    cmp r12, rax   ; Compare y with height - 1
    jnl  end

    mov rax, rsi
    dec rax
    cmp r11, rax   ; Compare x with width - 1
    jnl   end_x_loop

    ; Calculate cReal
    cvtsi2sd xmm5, r11  ; convert x to double
    mov rax, rsi        ; rax = width
    sar rax, 1          ; rax = width / 2
    cvtsi2sd xmm3, rax
    subsd   xmm5, xmm3  ; xmm5 = x - width / 2
    addsd   xmm5, xmm5
    addsd   xmm5, xmm5  ; xmm5 = (x - width / 2) * 4
    sal rax, 1
    cvtsi2sd xmm3, rax
    mulsd   xmm3, xmm2  ; xmm3 = width * zoom
    divsd   xmm5, xmm3  ; xmm5 = (x - width / 2) * 4 / (width * zoom)
    addsd   xmm5, xmm0  ; xmm5 = cReal = (x - width / 2.0) * 4.0 / (width * zoom) + centerReal

    ; Calculate cImag
    cvtsi2sd xmm6, r12
    mov rax, rdx
    sar rax, 1
    cvtsi2sd xmm4, rax
    subsd  xmm6, xmm3
    addsd  xmm6, xmm5
    addsd  xmm6, xmm5
    sal  rax, 1
    cvtsi2sd xmm4, rax
    mulsd   xmm4, xmm2
    divsd    xmm6, xmm4
    addsd   xmm6, xmm1  ; xmm6 = cImag = (y - height / 2.0) * 4.0 / (height * zoom) + centerImag

    ; isInSet(cReal=xmm5, cImag=xmm6, processPower=rcx, setPoint=r8)

    ; Initialize Iters
    xor r13, r13        ; int iters = r13 = 0

    ; Initialize zReal and zImag
    pxor xmm9, xmm9      ; zReal
    pxor xmm10, xmm10     ; zImag
is_in_mandelbrot:

    ; Check if Iters >= processPower
    cmp r13, rcx
    jge return_zero_iter
    inc r13

    ; x^2 + 2xyj - y^2
    movsd xmm7, xmm9    ; xmm7 = zReal
    movsd xmm8, xmm10   ; xmm8 = zImag

    mulsd xmm7, xmm7    ; zReal^2
    mulsd xmm8, xmm8    ; zImag^2
    subsd xmm7, xmm8    ; xmm7 = zReal^2 - zImag^2

    movsd xmm8, xmm10   ; xmm8 = zImag
    mulsd xmm8, xmm9    ; zReal * zImag
    addsd xmm8, xmm8    ; 2 * zReal * zImag

    ; zReal = complexSquaredReal + cReal
    addsd xmm7, xmm5    ; xmm7 = zReal = (zReal^2 - zImag^2) + cReal

    ; zImag = complexSquaredImag + cImag
    addsd xmm8, xmm6    ; xmm8 = zImag = (2 * zReal * zImag) + cImag

    movsd xmm9, xmm7    ; update zReal
    movsd xmm10, xmm8   ; update zImag

    ; Calculate |z|
    movsd xmm7, xmm9
    mulsd xmm7, xmm9     ; x^2
    movsd xmm8, xmm10
    mulsd xmm8, xmm10    ; y^2
    addsd xmm7, xmm8     ; x^2 + y^2

    ; Check if |z|^2 > setPoint^2
    cvtsi2sd xmm8, r8   ; xmm8 = setPoint
    mulsd xmm8, xmm8    ; xmm8 = setPoint^2
    comisd xmm7, xmm8
    ja draw_pixels

    jmp is_in_mandelbrot

return_zero_iter:
    xor r13, r13
    jmp draw_black

draw_pixels:
    ; Calculate color based on iters
    mov rax, r13
    imul rax, 10
    and rax, 0xFF    ; R = (iters * 10) % 255
    mov byte [rdi + r10], al

    mov rax, r13
    imul rax, 15
    and rax, 0xFF    ; G = (iters * 15) % 255
    mov byte [rdi + r10 + 1], al

    mov rax, r13
    imul rax, 20
    and rax, 0xFF    ; B = (iters * 20) % 255
    mov byte [rdi + r10 + 2], al

    mov byte [rdi + r10 + 3], 255 ; A

    jmp next_pixel

draw_black:
    mov byte [rdi + r10], 0    ; R
    mov byte [rdi + r10 + 1], 0  ; G
    mov byte [rdi + r10 + 2], 0  ; B
    mov byte [rdi + r10 + 3], 255 ; A

next_pixel:
    add r10, 4       ; Move to next pixel
    inc r11          ; Increment x

    ; Check if idx >= bufferSize
    cmp r10, r9
    jge end

    ; Check if x counter < width
    jmp  for_x_loop

end_x_loop:
    ; Clear x counter ( r11 ) and increment y counter ( r12 )
    inc r12     ; increment y
    jmp for_y_loop

end:
    ; Epilogue
    pop r13
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
