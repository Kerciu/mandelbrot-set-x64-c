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
    test rdi, rdi   ; if (pixelBuffer == NULL)
    jz   end
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

loop:
    ; comisd xmm5, WIDTH    TODO MAKE THOSE LOOP CONDITIONS
    ; comisd xmm6, HEIGHT

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
    jge return_iters
    inc r12
    ;     Complex zPowered = complexSquared(z);
power_complex:
    ; x^2 + 2xyj - y^2
    ; xmm7 = xReal^2 - yReal^2
    ; xmm8 = 2xRealyReal
    movsd xmm9, xmm7
    movsd xmm10, xmm8
    mulsd xmm9, xmm9 ; x^2
    mulsd xmm10, xmm10 ; y^2
    subsd xmm9, xmm10   ; x^2 - y^2
    movsd xmm10, xmm8
    mulsd xmm10, xmm7   ; xy
    addsd xmm10, xmm10  ; 2xy
    movsd xmm7, xmm9
    movsd xmm8, xmm10

    ;     Complex zAdded = complexAdd(zPowered, c);
add_complex:
    ; z + c = (Zx + Cx) + j(Zy + Cy)
    addsd xmm7, xmm0    ; xReal + cReal
    addsd xmm8, xmm1    ; yReal + cImag

    ;     z = zAdded;

    ;     // Check if this point is still in the set
complex_norm:
    ; int sqroot(int n) {
    ;     int x = n;
    ;     for (int i = 0; i < (n/2); i++)
    ;          x = (x + n / x) / 2;

    ;     return x;
    ; }

    movsd xmm9, xmm7
    mulsd xmm9, xmm9
    movsd xmm10, xmm8
    mulsd xmm10, xmm10

    ; sqrt(pow(num->x, 2) + pow(num->y, 2));
    addsd xmm9, xmm10
    ; now I have in xmm9 register value of x^2 + y^2

sqroot:
    ; n = xmm9
    movsd xmm1, xmm9     ; x = n
    ; movsd xmm11, xmm9       ; save n as temporary

sqroot_loop:
    movsd xmm0, xmm1   ; x = xmm0
    divsd xmm0, xmm9          ; x / n
    addsd xmm1, xmm0   ; x + x / n
    mov   rax, 2
    movq  xmm3, rax
    divsd xmm1, xmm3   ; x = (x + x / n) / 2
    subsd xmm2, xmm1
    andpd xmm2, xmm2
    movmskpd rax, xmm2
    test rax, rax
    jnz  sqroot_loop

    ;     if (complexNorm(z) > setPoint)

    cvtsi2sd xmm2, r8   ; setPoint
    comisd  xmm1, xmm2
    jg      return_iters

    ; this will be a hell to implement

    ;     {
    ;         return i;
    ;     } // If we want to call mandelbrot set, we check how much iterations it took
    ; }

    jmp loop
    ; return 0;   // This is inside the set
return_iters:


end:
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret

