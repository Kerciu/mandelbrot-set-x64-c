section .text
global mandelbrot

mandelbrot:
    ; prologue
    push rbp
    mov rbp, rsp

    ; body

    ; epilogue
end:
    mov rsp, rbp
    pop rbp
    ret

