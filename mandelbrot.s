section .text
global mandelbrot

; int mandelbrot(unsigned char* pixelBuffer, int width, int height, double cReal, double cImag,
;                int processPower, int setPoint, double centerReal, double centerImag, double zoom);
;
; RDI = pixelBuffer;
; RSI = width;
; RDX = height
; RCX = processPower;
; R8 = setPoint;
; XMM0 = cReal;
; XMM1 = cImag;
; XMM2 = centerReal;
; XMM3 = centerImag;
; XMM4 = zoom;

mandelbrot:
    ; prologue
    push rbp
    mov rbp, rsp
    push rbx
    push r12

    ; body

    cmp rsi, 0      ; if (width <= 0)
    jle  end
    cmp rdx, 0      ; if (height <= 0)
    jle  end

    ; r9 = bufferSize = 4 * width * height
    imul r9, rsi, 4
    mov rax, r9
    mul rdx
    mov r9, rax
    mov r10, 0          ; r10 = idx = 0

for_y_loop:
    xor r10, r10
    cvtsi2sd xmm5, r10         ; xmm5 = y = 0

for_x_loop:

    ; xmm7 = xReal
    xor r11, r11
    cvtsi2sd xmm6, r11        ; xmm6 = x = 0

    cvtsi2sd xmm8, rsi
    cvtsi2sd xmm9, rdx
    ; comisd x, WIDTH    TODO MAKE THOSE LOOP CONDITIONS
    comisd xmm5, xmm8
    jge   end_x_loop
    ; comisd y, HEIGHT
    comisd xmm6, xmm9
    jge  end

    ; increment x
    mov rax, 1
    cvtsi2sd xmm10, rax
    addsd xmm5, xmm10

    ; double xReal = (x - width / 2.0) * 4.0 / (width * zoom) + centerReal;
    movsd xmm7, xmm6
    mov   rax, rsi
    shr    rax, 1
    cvtsi2sd  xmm8, rax ; itod(width)
    subsd   xmm7, xmm8  ; xReal = (x - width / 2.0)
    shl     rax,  1
    cvtsi2sd    xmm8, rax
    addsd    xmm7, xmm7     ; xReal = (x - width / 2.0) * 2.0
    addsd   xmm7, xmm7      ; xReal = (x - width / 2.0) * 4.0
    mulsd   xmm8, xmm4  ; (width * zoom)
    divsd   xmm7, xmm8  ; xReal = (x - width / 2.0) * 4.0 / (width * zoom)
    addsd   xmm7, xmm2  ; xReal = (x - width / 2.0) * 4.0 / (width * zoom) + centerReal

    ; xmm8 = yReal

    ;double yReal = (y - height / 2.0) * 4.0 / (height * zoom) + centerImag;
    movsd xmm8, xmm5
    mov     rax, rdx
    shr     rax, 1
    cvtsi2sd xmm9, rax  ; itod(height / 2)
    shl     rax, 1
    cvtsi2sd xmm9, rax
    subsd   xmm8, xmm9  ; yReal = (y - height / 2.0)
    addsd   xmm8, xmm8  ; yReal = (y - height / 2.0) * 2.0
    addsd   xmm8, xmm8  ; yReal = (y - height / 2.0) * 4.0
    mulsd   xmm9, xmm4  ; (height * zoom)
    divsd   xmm8, xmm9  ; yReal = (y - height / 2.0) * 4.0 / (height * zoom)
    addsd   xmm8, xmm3  ; yReal = (y - height / 2.0) * 4.0 / (height * zoom) + centerImag

    ; TODO
    ; implement isInSet(xReal=xmm7, yReal=xmm8, processPower=rcx, setPoint=r8) func
    xor r12, r12        ; int i = r12 = 0
    ; for (int i = 0; i < processPower; ++i) {
is_in_mandelbrot:
    cmp r12, rcx
    jge return_zero_iter
    inc r12
    ; x^2 + 2xyj - y^2
    ; xmm7 = xReal^2 - yReal^2
    ; xmm8 = 2xRealyReal
    movsd xmm9, xmm7
    movsd xmm10, xmm8

    mulsd xmm9, xmm9 ; x^2
    mulsd xmm10, xmm10 ; y^2

    subsd xmm9, xmm10   ; xmm9 = x^2 - y^2
    movsd xmm10, xmm8   ; xmm10 = y
    mulsd xmm10, xmm7   ; xy
    addsd xmm10, xmm10  ; 2xy

    ; xReal = xReal^2 - yReal^2
    movsd xmm7, xmm9
    ; yReal = 2 * xReal * yReal
    movsd xmm8, xmm10

    ;     Complex zAdded = complexAdd(zPowered, c);

    ; z + c = (Zx + Cx) + j(Zy + Cy)
    addsd xmm7, xmm0    ; xReal + cReal
    addsd xmm8, xmm1    ; yReal + cImag

    ; Calculate |z|

    movapd xmm9, xmm8
    mulsd xmm9, xmm8    ; x^2
    movapd xmm10, xmm7
    mulsd xmm10, xmm7  ; y^2
    addsd xmm9, xmm10  ; x^2 + y^2

; Calculate sqrt(|z|)
    sqrtsd xmm9, xmm9

    ;     if (complexNorm(z) > setPoint)

    cvtsi2sd xmm10, r8   ; setPoint
    comisd  xmm9, xmm10
    jg      draw_pixels

    jmp is_in_mandelbrot
    ; return 0;   // This is inside the set

return_zero_iter:
    xor r12, r12

draw_pixels:
    ; if (iters == 0) {
    ;     // renderer draw color (renderer , r, g, b, opacity)
    ;     pixelBuffer[idx++] = 0; // R
    ;     pixelBuffer[idx++] = 0; // G
    ;     pixelBuffer[idx++] = 0; // B
    ;     pixelBuffer[idx++] = 255; // Opacity

    ; }
    ; else {
    ;     pixelBuffer[idx++] = (iters * 10) % 255; // R
    ;     pixelBuffer[idx++] = (iters * 15) % 255; // G
    ;     pixelBuffer[idx++] = (iters * 20) % 255; // B
    ;     pixelBuffer[idx++] = 255; // A
    ; }
    test r12, r12
    jz   draw_black

    ; pixelBuffer = rdi
draw_black:
    test r12, r12
    jnz draw_rgb

    mov byte [rdi + r10], 0   ; R
    mov byte [rdi + r10 + 1], 0 ; G
    mov byte [rdi + r10 + 2], 0 ; B
    mov byte [rdi + r10 + 3], 255 ; A

    jmp next_pixel


mov rax, r12
    imul rax, rax, 10
    mov rcx, 255
    xor rdx, rdx
    div rcx     ; there is modulo operation result in rdx register

    mov byte [rdi + r10], dl   ; R
    mov byte [rdi + r10 + 1], dl ; G
    mov byte [rdi + r10 + 2], dl ; B
    mov byte [rdi + r10 + 3], 255 ; A

next_pixel:
    add r10, 4       ; Move to next pixel
    inc r11          ; Increment x

    jmp for_x_loop

end_x_loop:
    xor r11, r11
    cvtsi2sd xmm6, r11        ; xmm6 = x = 0
    mov rax, 1
    cvtsi2sd xmm10, rax
    addsd xmm5, xmm10
    jmp for_x_loop

end:
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret

