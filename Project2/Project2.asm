TITLE Program Template     (template.asm)

; Author: Siara Leininger
; Email: leinings@oregonstate.edu
; Course / Project ID : CS 271-400 / Project 2              Due Date: October 16, 2016
; Description: This program will introduce itself and identify me as the author. It will get the user's name and then greet the user by name.
;				Then it will prompt the user to enter how many terms of the Fibonacci sequence they would like to have displayed, with a max of 46.
;				It will validate the user input and display the correct number of Fibonacci terms, then exit and say goodbye.

INCLUDE Irvine32.inc

; (insert constant definitions here)
INPUT_MIN	=	1
INPUT_MAX	=	46
PER_LINE	=	5


.data

; (insert variable definitions here)
progIntro		BYTE	"Project #2 - Fibonacci Sequence", 0
myIntro			BYTE	"By: Siara Leininger", 0
userNameInstr	BYTE	"Please enter your name, then press 'enter': ", 0
userGreet		BYTE	"Hello, ", 0
userInstr		BYTE	"Enter the number of Fibonacci terms you would like displayed. Please choose a number between 1 and 46: ", 0
inputNotValid	BYTE	"Invalid input, next time please enter a number between 1 and 46.", 0
goodbye			BYTE	"Thank you! Goodbye, ", 0
punc			BYTE	"!", 0
space			BYTE	"     ", 0
userName		DWORD 33 DUP(0)
buffer			DWORD 33 DUP(0)
numTerms		DWORD 47 DUP(1)
numFib			DWORD ?
newNumFib		DWORD ?
temp			DWORD ?
fibVal			DWORD ?

.code
main PROC

; Introduce program and programmer
	mov		edx, OFFSET progIntro
	call	WriteString
	call	CrLf
	mov		edx, OFFSET myIntro
	call	WriteString
	call	CrLf

; Get name from user, then greet user
	mov		edx, OFFSET userNameInstr
	call	WriteString
	mov		edx, OFFSET userName
	mov		ecx, 32
	call	ReadString
	call	CrLf
	mov		edx, OFFSET userGreet
	call	WriteString
	mov		edx, OFFSET userName
	call	WriteString
	mov		edx, OFFSET punc
	call	WriteString
	call	CrLf

; Get number of Fibonacci terms desired from user, validate the input is between 1 and 46 
L1:
	mov		edx, OFFSET userInstr
	call	WriteString
	call	ReadInt
	mov		numFib, eax
	mov		eax, numFib
	cmp		eax, INPUT_MAX
	jg		L2						; Jump to invalid input message
	jle		L3						; Jump to lower limit check
L2:
	mov		edx, OFFSET inputNotValid
	call	WriteString
	call	CrLf
	jmp		L1						; User has reached this point because of invalid input, loop back to get a new input
L3:
	mov		eax, numFib
	cmp		eax, INPUT_MIN
	jl		L2						; If input is less than lower limit, then jump to invalid input message
	jge		L4						; If input passes both comparisons, then jump to calculations

; Calculate and display appropriate number of Fibonacci terms
L4:
	mov		eax, numFib				; Subtract one from value entered by user because loop will not write the first value
	sub		eax, 1
	mov		newNumFib, eax

	mov		temp, 1					; Move 1 and 1 as starting values into variables to begin calculating Fibonacci values
	mov		fibVal, 1

	mov		eax, 1					; Write first term outside of loop
	call	WriteDec
	mov		edx, OFFSET space
	call	WriteString

	mov		eax, fibVal		
	mov		ebx, 1			
	mov		ecx, newNumFib			; First value written outside of loop, so run loop the number of times entered by user - 1

findFib:
	mov		eax, fibVal				; Write the current value in the sequence
	call	WriteDec	
	mov		edx, OFFSET space
	call	WriteString
format:								; Use accumulator variable to check when 5 terms have been written, then add a new line
	mov		eax, numTerms
	inc		eax
	mov		numTerms, eax
	cmp		numTerms, PER_LINE
	jne		L5
	call	CrLf
	mov		numTerms, 0
L5:									; Calculate the next value in the sequence
	mov		eax, fibVal
	mov		ebx, temp
	add		eax, ebx
	mov		ebx, fibVal
	mov		temp, ebx
	mov		fibVal, eax
	loop	findFib

; Say goodbye and exit program
endProgram:
	call	CrLf
	mov		edx, OFFSET goodbye
	call	WriteString
	mov		edx, OFFSET userName
	call	WriteString
	mov		edx, OFFSET punc
	call	WriteString
	call	CrLf

	exit	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
