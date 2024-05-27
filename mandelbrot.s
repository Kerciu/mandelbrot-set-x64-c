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
    ; implement isInSet(xReal, yReal, processPower, setPoint) func

end:
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret

