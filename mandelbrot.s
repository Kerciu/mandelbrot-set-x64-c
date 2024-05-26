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

    ; epilogue
end:
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret

