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

    ; Body

    ; Check if width or height are not positive
    cmp rsi, 0      ; if (width <= 0)
    jle  end
    cmp rdx, 0      ; if (height <= 0)
    jle  end

    ; Calculate buffer size: r9 = bufferSize = 4 * width * height
    imul r9, rsi, 4
    mov rax, r9
    mul rdx
    mov r9, rax

    ; Initialize idx = 0
    mov r10, 0          ; r10 = idx = 0

    ; Initialize y = 0
    cvtsi2sd xmm3, r10         ; xmm3 = y = 0

for_y_loop:
    ; Initialize x = 0
    xor r11, r11
    cvtsi2sd xmm4, r11        ; xmm4 = x = 0

for_x_loop:
    ; Check if idx >= bufferSize
    cmp r10, r9
    jge end

    cvtsi2sd xmm6, rsi        ; width
    cvtsi2sd xmm7, rdx        ; height

    ; Check loop conditions
    comisd xmm3, xmm7   ; Compare x with width
    jge  end

    comisd xmm4, xmm6   ; Compare y with height
    jge   end_x_loop

    ; Calculate xReal
    movsd xmm5, xmm4
    mov   rax, rsi
    shr    rax, 1
    cvtsi2sd  xmm6, rax ; itod(width / 2.0)
    subsd   xmm5, xmm6  ; xReal = (x - width / 2.0)
    shl     rax,  1
    cvtsi2sd    xmm6, rax
    addsd    xmm5, xmm5     ; xReal = (x - width / 2.0) * 2.0
    addsd   xmm5, xmm5      ; xReal = (x - width / 2.0) * 4.0
    mulsd   xmm6, xmm2  ; (width * zoom)
    divsd   xmm5, xmm6  ; xReal = (x - width / 2.0) * 4.0 / (width * zoom)
    addsd   xmm5, xmm0  ; xReal = (x - width / 2.0) * 4.0 / (width * zoom) + centerReal

    ; Calculate yReal
    movsd xmm6, xmm3
    mov     rax, rdx
    shr     rax, 1
    cvtsi2sd xmm7, rax  ; itod(height / 2)
    shl     rax, 1
    cvtsi2sd xmm7, rax
    subsd   xmm6, xmm7  ; yReal = (y - height / 2.0)
    addsd   xmm6, xmm6  ; yReal = (y - height / 2.0) * 2.0
    addsd   xmm6, xmm6  ; yReal = (y - height / 2.0) * 4.0
    mulsd   xmm7, xmm2  ; height = (height * zoom)
    divsd   xmm6, xmm7  ; yReal = (y - height / 2.0) * 4.0 / (height * zoom)
    addsd   xmm6, xmm1  ; yReal = (y - height / 2.0) * 4.0 / (height * zoom) + centerImag

    ; Implement isInSet(xReal=xmm5, yReal=xmm6, processPower=rcx, setPoint=r8) func

    ; Initialize Iters
    xor r12, r12        ; int i = r12 = 0
is_in_mandelbrot:

    ; Check if Iters >= processPower
    cmp r12, rcx
    jge return_zero_iter
    inc r12

    ; x^2 + 2xyj - y^2
    movsd xmm7, xmm5    ; xmm7 = xReal
    movsd xmm8, xmm6    ; xmm8 = yReal

    mulsd xmm7, xmm7    ; x^2
    mulsd xmm8, xmm8    ; y^2
    subsd xmm7, xmm8    ; xmm7 = x^2 - y^2

    movsd xmm8, xmm6    ; xmm8 = yReal
    mulsd xmm8, xmm5    ; xy
    addsd xmm8, xmm8    ; 2xy

    ; xReal = xReal^2 - yReal^2
    movsd xmm5, xmm7
    ; yReal = 2 * xReal * yReal
    movsd xmm6, xmm8

    ; Complex zAdded = complexAdd(zPowered, c);

    ; z + c = (Zx + Cx) + j(Zy + Cy)
    addsd xmm5, xmm0    ; xReal + cReal
    addsd xmm6, xmm1    ; yReal + cImag

    ; Calculate |z|
    movapd xmm7, xmm6
    mulsd xmm7, xmm6    ; x^2
    movapd xmm8, xmm5
    mulsd xmm8, xmm5  ; y^2
    addsd xmm7, xmm8  ; x^2 + y^2

    ; Calculate sqrt(|z|)
    sqrtsd xmm7, xmm7

    ; Check if (complexNorm(z) > setPoint)
    cvtsi2sd xmm8, r8   ; xmm8 = setPoint
    comisd  xmm7, xmm8
    jg      draw_pixels

    jmp is_in_mandelbrot

return_zero_iter:
    xor r12, r12

draw_pixels:

    ; Check if Iters == 0
    test r12, r12
    jz draw_black

    mov byte [rdi + r10], 0    ; R
    mov byte [rdi + r10 + 1], 0  ; G
    mov byte [rdi + r10 + 2], 0  ; B
    mov byte [rdi + r10 + 3], 255 ; A
    jmp next_pixel

draw_black:
    mov byte [rdi + r10], dl   ; R
    mov byte [rdi + r10 + 1], dl ; G
    mov byte [rdi + r10 + 2], dl ; B
    mov byte [rdi + r10 + 3], 255 ; A

next_pixel:
    add r10, 4       ; Move to next pixel
    inc r11          ; Increment x

    cmp r11, rsi     ; Check if x counter > width
    jge for_x_loop

end_x_loop:
    ; Clear x counter ( r11 ) and increment y counter ( r10 - xmm3 )
    xor r11, r11
    cvtsi2sd xmm4, r11        ; xmm4 = x = 0
    mov rax, 1
    cvtsi2sd xmm8, rax
    addsd xmm3, xmm8         ; ++y

    ; Check condition if y < height
    cvtsi2sd xmm7, rdx        ; height
    comisd xmm3, xmm7
    jl for_y_loop            ; If y < height, continue for_y_loop

end:

    ; Epilogue
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
