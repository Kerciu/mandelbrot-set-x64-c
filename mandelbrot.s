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

    lea r9, [4 * rsi]
    lea r9, [r9 * edx]  ; r9 = bufferSize = 4 * width * height
    mov r10, 0          ; r10 = idx = 0

    ; epilogue

for_y_loop:

for_x_loop:

end:
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret

