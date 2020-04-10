%include "include/io.inc"

extern atoi
extern printf
extern exit

; Functions to read/free/print the image.
; The image is passed in argv[1].
extern read_image
extern free_image
; void print_image(int* image, int width, int height);
extern print_image

; Get image's width and height.
; Store them in img_[width, height] variables.
extern get_image_width
extern get_image_height

section .data
	use_str db "Use with ./tema2 <task_num> [opt_arg1] [opt_arg2]", 10, 0

section .bss
    task:       resd 1
    img:        resd 1
    img_width:  resd 1
    img_height: resd 1

section .text
global main
main:
    mov ebp, esp; for correct debugging
    ; Prologue
    ; Do not modify!
    push ebp
    mov ebp, esp

    mov eax, [ebp + 8]
    cmp eax, 1
    jne not_zero_param

    push use_str
    call printf
    add esp, 4

    push -1
    call exit

not_zero_param:
    ; We read the image. You can thank us later! :)
    ; You have it stored at img variable's address.
    mov eax, [ebp + 12]
    push DWORD[eax + 4]
    call read_image
    add esp, 4
    mov [img], eax

    ; We saved the image's dimensions in the variables below.
    call get_image_width
    mov [img_width], eax

    call get_image_height
    mov [img_height], eax

    ; Let's get the task number. It will be stored at task variable's address.
    mov eax, [ebp + 12]
    push DWORD[eax + 8]
    call atoi
    add esp, 4
    mov [task], eax

    ; There you go! Have fun! :D
    mov eax, [task]
    cmp eax, 1
    je solve_task1
    cmp eax, 2
    je solve_task2
    cmp eax, 3
    je solve_task3
    cmp eax, 4
    je solve_task4
    cmp eax, 5
    je solve_task5
    cmp eax, 6
    je solve_task6
    jmp done

solve_task1:
    ;int bruteforce_singlebyte_xor(int* img);
    push dword[img]
    call bruteforce_singlebyte_xor
    add esp, 4
    
    push esi
    push dword[img]
    call print_line
    add esp, 8
    PRINT_DEC 4, eax ;cheia
    NEWLINE
    PRINT_DEC 4, esi ; linia
    NEWLINE 

    jmp done
solve_task2:
    push dword[img]
    call bruteforce_singlebyte_xor
    add esp, 4
    ;acum am eax cheia si in esi linia
    push dword[img]
    push eax
    push esi
    call add_message
    add esp, 12
    
    push dword[img_height]
    push dword[img_width]
    push dword[img]
    call print_image
    add esp, 12
    
    jmp done
solve_task3:
    
    jmp done
solve_task4:
    ;void lsb_encode(int* img, char* msg, int byte_id);
    mov eax, [ebp + 12]
    push DWORD[eax + 16]
    call atoi ;eax = offset
    add esp, 4

    
    mov ebx, [ebp + 12]
    mov edx, dword[ebx + 12] ;cuvantul
    
    push eax
    push edx
    push dword[img]
    call lsb_encode
    add esp, 12
    
    
    
    push dword[img_height]
    push dword[img_width]
    push dword[img]
    call print_image
    add esp, 12
    
    jmp done
solve_task5:
    ;void lsb_decode(int* img, int byte_id);
    mov eax, [ebp + 12]
    push DWORD[eax + 12]
    call atoi ;eax = offset
    add esp, 4
    
    push eax
    push dword[img]
    call lsb_decode
    add esp, 8
    
    jmp done
solve_task6:
    
    jmp done

    ; Free the memory allocated for the image.
done:
    push DWORD[img]
    call free_image
    add esp, 4

    ; Epilogue
    ; Do not modify!
    xor eax, eax
    leave
    ret
    
bruteforce_singlebyte_xor:
    push ebp
    mov ebp, esp
    push ebx
    push ecx
    push edx
    
    mov eax, dword[img_width]
    mov ebx, dword[img_height]
    mul ebx
    mov ecx, eax ; numarul de elemente
 
    mov edx, [ebp + 8]  ;imaginea  
   
    xor eax, eax ; = 0

decrypt_image:  ;facem xor pe toata imaginea
 
    xor [edx + (ecx - 1) * 4], eax
    loop decrypt_image

    push eax; pastram cheia
    
    push edx
    call check_word
    pop edx
    cmp eax, 0
    jne done_bfsbx; prescurtare semnatura functie
    cmp eax, 256
    jg done_bfsbx
      
    mov eax, dword[img_width]
    mov ebx, dword[img_height]
    mul ebx
    mov ecx, eax    ; numarul de elemente   
    pop eax
    
    mov edx, [ebp + 8]  ;imaginea  
   
    encrypt_image: ; facem xor sa revenim la img data
        xor [edx + (ecx - 1) * 4], eax
        loop encrypt_image
        
    inc eax
    push eax
    mov eax, dword[img_width]
    mov ebx, dword[img_height]
    mul ebx
    mov ecx, eax; numarul de elemente
    pop eax
    mov edx, [ebp + 8]  ;imaginea  
    jmp decrypt_image
    
done_bfsbx:
    xor edx, edx
    mov esi, dword[img_width]
    div esi
    
    mov esi, eax
    pop eax
    
    
    
    pop edx
    pop ecx
    pop ebx  
    leave
    ret


check_word:
    push ebp
    mov ebp, esp

    push ebx
    push ecx
    
    mov eax, dword[img_width]
    mov ebx, dword[img_height]
    mul ebx
    
    mov ecx, eax
    sub ecx, 5
    mov ebx, [ebp + 8]
    xor eax, eax
check: ;for word 'revient'
    cmp dword[ebx + (ecx - 1) * 4], 'r'
    jne done_check
    cmp dword[ebx + (ecx) * 4], 'e'
    jne done_check
    cmp dword[ebx + (ecx + 1) * 4], 'v'
    jne done_check
    cmp dword[ebx + (ecx + 2) * 4], 'i'
    jne done_check
    cmp dword[ebx + (ecx + 3) * 4], 'e'
    jne done_check
    cmp dword[ebx + (ecx + 4) * 4], 'n'
    jne done_check
    cmp dword[ebx + (ecx + 5) * 4], 't'
    jne done_check
    mov eax, ecx
done_check:
    dec ecx
    cmp ecx, 0
    jne check
    
    
    pop ecx
    pop ebx
    leave
    ret
    
    
print_line:
    push ebp
    mov ebp, esp
    push eax
    push ebx
    push ecx
    push edx    
    
    mov ecx, [ebp + 12] ; nr liniei
    mov eax, [img_width]
    mul ecx
    
    mov ecx, [img_width]
    mov ebx, eax
    
    mov edx, [ebp + 8] ;img
    
print:        
    mov eax, dword[edx + ebx* 4]
    cmp eax, 0
    je done_print
    PRINT_CHAR eax
    
    inc ebx
    dec ecx
    cmp ecx, 0
    jne print
                    
done_print:
    NEWLINE
    pop edx
    pop ecx
    pop ebx
    pop eax
    leave
    ret
        
add_line:
    push ebp
    mov ebp, esp
    push eax
    push ebx
    push ecx
    push edx    
    
    mov ecx, [ebp + 12] ; nr liniei
    mov eax, [img_width]
    mul ecx
    
    mov ecx, [img_width]
    mov ebx, eax
    
    mov edx, [ebp + 8] ;img
    
add:        
    mov dword[edx + ebx* 4],'C'
    inc ebx
    mov dword[edx + ebx* 4], 39
    inc ebx
    mov dword[edx + ebx* 4], 'e'
    inc ebx
    mov dword[edx + ebx* 4], 's'
    inc ebx
    mov dword[edx + ebx* 4], 't'
    inc ebx
    mov dword[edx + ebx* 4], ' '
    inc ebx
    mov dword[edx + ebx* 4], 'u'
    inc ebx
    mov dword[edx + ebx* 4], 'n'
    inc ebx
    mov dword[edx + ebx* 4], ' '
    inc ebx
    mov dword[edx + ebx* 4], 'p'
    inc ebx
    mov dword[edx + ebx* 4], 'r'
    inc ebx
    mov dword[edx + ebx* 4], 'o'
    inc ebx
    mov dword[edx + ebx* 4], 'v'
    inc ebx
    mov dword[edx + ebx* 4], 'e'
    inc ebx
    mov dword[edx + ebx* 4], 'r'
    inc ebx
    mov dword[edx + ebx* 4], 'b'
    inc ebx
    mov dword[edx + ebx* 4], 'e'
    inc ebx
    mov dword[edx + ebx* 4], ' '
    inc ebx
    mov dword[edx + ebx* 4], 'f'
    inc ebx
    mov dword[edx + ebx* 4], 'r'
    inc ebx
    mov dword[edx + ebx* 4], 'a'
    inc ebx
    mov dword[edx + ebx* 4], 'n'
    inc ebx
    mov dword[edx + ebx* 4], 'c'
    inc ebx
    mov dword[edx + ebx* 4], 'a'
    inc ebx
    mov dword[edx + ebx* 4], 'i'
    inc ebx
    mov dword[edx + ebx* 4], 's'
    inc ebx
    mov dword[edx + ebx* 4], '.'
    inc ebx
    mov dword[edx + ebx* 4], 0
    inc ebx
                    
done_add:
    pop edx
    pop ecx
    pop ebx
    pop eax
    leave
    ret
        
        
add_message:
    push ebp
    mov ebp, esp
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    
    mov edx, [ebp + 16] ; img
    mov ebx, [ebp + 8] ; linia cu revient
    inc ebx
    push ebx
    push edx
    call add_line
    pop edx
    pop ebx
    
    push edx
    xor edx, edx
    mov eax, [ebp + 12];key
    mov ebx, 2      ;c
    mul ebx         ;a
    add eax, 3      ;l
    mov ebx, 5      ;c
    div ebx         ;u
    sub eax, 4      ;l
    mov ebx, dword[img_width]
    push eax
    mov eax, dword[img_height]
    mul ebx
    mov ecx, eax
    pop eax
    pop edx
    
encrypt_image_2: ; facem xor sa revenim la img data
    xor [edx + (ecx - 1) * 4], eax
    loop encrypt_image_2
    
    
    
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    
    
    leave
    ret
    
    
    
    
lsb_encode:
    push ebp
    mov ebp, esp
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    
    mov esi, [ebp + 12];cuvant
    mov ecx, [ebp + 16];offset
    xor edx, edx
    mov eax, 1
parcurgere_cuvant:
    mov ebx, dword[esi + edx]
    cmp bl, 0
    je done_parc
    push dword[ebp + 8]
    push ecx
    push ebx
    call binar
    add esp, 4
    pop ecx
    inc edx
    add ecx, 8
    jmp parcurgere_cuvant
done_parc:
    push dword[ebp + 8]
    sub ecx, 2
    push ecx
    call adauga_zero
    add esp, 8
    
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    leave
    ret
    
    
binar:
    push ebp
    mov ebp, esp
    push eax ;octetul/nr
    push ebx; bitul de 1 shiftat
    push ecx
    push edi; 8 biti
    push esi; indicele lui img

    mov esi, [ebp + 12]
    dec esi
    mov eax, [ebp + 8]
    mov edi, 8
    mov ebx, 1
    shl ebx, 7
    mov ecx, [ebp + 16]
binary:
    test bl, al
    jne print_bit
    and dword[ecx + 4 * esi], 254
    jmp done_print_bit
    
print_bit:
    or dword[ecx + 4 * esi], 1
    jmp done_print_bit
done_print_bit:
    inc esi
    shr ebx, 1
    dec edi
    cmp edi, 0
    jne binary
    
    pop esi
    pop edi
    pop ecx
    pop ebx
    pop eax
    leave
    ret
    

adauga_zero:
    push ebp
    mov ebp, esp
    push eax
    push ebx
    push ecx
    push edx
    
    mov eax, [ebp +12]
    mov ebx, [ebp + 8]
    mov ecx, 8
loop1:
    mov edx, ebx
    add edx, ecx
    and dword[eax + edx * 4], 254
    dec ecx
    cmp ecx, 0
    jne loop1
    
    pop edx
    pop ecx
    pop ebx
    pop eax
    
    leave
    ret
    
    
lsb_decode:
    push ebp
    mov ebp, esp
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    
    mov eax, [ebp + 8];img
    mov ebx, [ebp + 12];offset
    mov ecx, 0; luam litera cu litera
litera_aux:
    xor edx, edx
litera:
    
    mov esi, ebx
    add esi, ecx ; indicele
    shl edx, 1
    test dword[eax + 4 * esi], 1
    jz done_bit
bit_unu:
    inc edx
done_bit:
    inc ecx
    cmp ecx, 7
    jne litera
    cmp edx, 0
    je done_litera
    PRINT_CHAR edx
    
    add ebx, 8
    mov ecx, 0
    cmp edx, 0
    jmp litera_aux
done_litera:    
    NEWLINE
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    leave
    ret