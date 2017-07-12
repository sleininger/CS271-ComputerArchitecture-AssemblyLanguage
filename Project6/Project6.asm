TITLE Program Template     (template.asm)

; Author: Siara Leininger
; Email: leinings@oregonstate.edu
; Course / Project ID : CS 271-400  /  Project #6A              Date: November 28, 2016
; Description: This program will read input from a user as a string, and then convert it to numeric form. It will
;				ask the user to input 10 valid integers, convert the input from a string to an array of integers,
;				and then display the list of integers along with their sum and average.

INCLUDE Irvine32.inc

;-------------------------------------------------------------------------
; Macro: getString
;
; Displays a prompt, gets input from user and moves to memory location
; Receives: Address for memory location, size of string
; Returns: None
;-------------------------------------------------------------------------
getString		MACRO	address, size
	push	edx
	push	ecx

	; Display prompt
	displayString	OFFSET userPrompt

	; Get user's input into memory location
	mov		edx, address
	mov		ecx, size
	call	ReadString

	pop		ecx
	pop		edx
ENDM

;-------------------------------------------------------------------------
; Macro: displayString
;
; Displays a string stored in a memory location
; Receives: Offset of string to be displayed
; Returns: None
;-------------------------------------------------------------------------
displayString	MACRO	printThis
	push	edx
	mov		edx, printThis
	call	WriteString
	pop		edx
ENDM


; (insert constant definitions here)
INPUT_MAX	=	4294967295	; Highest that will fit in 32-bit register
INPUT_MIN	=	0
INPUT_NUM	=	10

.data

; (insert variable definitions here)
progIntro		BYTE	"Designing Low-Level I/O Procedures", 0
myIntro			BYTE	"By: Siara Leininger", 0
progDesc		BYTE	"This program will ask a user for 10 values, then display the numbers in a list along with their sum and average.", 0
userInstr		BYTE	"Please enter 10 unsigned decimal integers.", 0
userIntr2		BYTE	"Each number should be small enough to fit inside a 32 bit register.", 0
userPrompt		BYTE	"Enter an unsigned integer: ", 0
invalidInput	BYTE	"Invalid input. Please be sure to enter an unsigned integer.", 0
invalidInput2	BYTE	"Invalid input. Please be sure your number fits in a 32 bit register.", 0
displayArr		BYTE	"Here are the values you entered: ", 0
sumDisplay		BYTE	"The sum of the entered values is: ", 0
meanDisplay		BYTE	"The average of the entered values is: ", 0
spacing			BYTE	"  ", 0
punc			BYTE	".", 0
goodbyeMessage	BYTE	"Thank you! Goodbye!", 0
array			DWORD	10 DUP(0)
inputString		BYTE	250 DUP(0)
outputString	BYTE	250 DUP(?)

.code
main PROC

; (insert executable instructions here)

; Introduction
	push	OFFSET progIntro
	push	OFFSET myIntro
	push	OFFSET progDesc
	call	introduction

; Get user input
	; Loop to get correct number of values
	mov		ecx, INPUT_NUM
	mov		edi, OFFSET array

; Store input in Array
userLoop:
	push	OFFSET inputString
	push	SIZEOF inputString
	call	ReadVal
	mov		eax, DWORD PTR inputString
	mov		[edi], eax
	add		edi, 4								; Next position in array
	loop	userLoop

; TEST ARRAY VALUES WITH INTS, self check
;	mov		ecx, INPUT_NUM
;	mov		esi, OFFSET array
;testloop:
;	mov		eax, [esi]
;	call	WriteDec
;	mov		edx, OFFSET spacing
;	call	WriteString
;	add		esi, TYPE DWORD
;	loop	testloop

; Display Array
	call	CrLf
	displayString	OFFSET displayArr
	;Loop through array to convert to string and then display to user
	mov		ecx, INPUT_NUM
	mov		esi, OFFSET array

displayLoop:
	mov		eax, [esi]
	push	eax
	push	OFFSET outputString
	call	WriteVal
	add		esi, 4								; Next position in array
	loop	displayLoop
	call	CrLf
	
; Calculate and display sum
	displayString	OFFSET sumDisplay

	push	INPUT_NUM
	push	OFFSET array
	call	ArraySum
	push	eax
	push	OFFSET outputString
	call	WriteVal
	call	CrLf

; Calculate and display average
	displayString	OFFSET meanDisplay

	push	INPUT_NUM
	push	OFFSET array
	call	ArraySum							; Find sum, then divide by size of array
	push	eax
	push	INPUT_NUM
	call	ArrayAverage
	push	eax
	push	OFFSET outputString
	call	WriteVal
	call	CrLf

; Say goodbye
	call	CrLf
	push	OFFSET goodbyeMessage
	call	goodbye

	exit	; exit to operating system
main ENDP

; (insert additional procedures here)

;----------------------------------------------------------------------------------
; introduction
;
; Introduces the program, programmer, and provides initial instructions to user
; Receives: 3 string variables to print
; Returns: No values, prints information to screen
;----------------------------------------------------------------------------------
introduction PROC
	push	ebp
	mov		ebp, esp
	pushad

	mov		edx, [ebp+16]
	call	WriteString
	call	CrLf
	mov		edx, [ebp+12]
	call	WriteString
	call	CrLf
	call	CrLf
	mov		edx, [ebp+8]
	call	WriteString
	call	CrLf
	call	CrLf

	popad
	pop		ebp
	ret		12
introduction ENDP

;----------------------------------------------------------------------------------
; ReadVal
;
; Prompts user to enter number, calls Macro to convert string to numeric values
; Validates that numbers are in specified range
; Receives: Offset of address to store input string
; Returns: Array of numeric values
;----------------------------------------------------------------------------------
ReadVal PROC
	push	ebp
	mov		ebp, esp
	pushad

beginInput:
	mov		ecx, [ebp+8]				; Parameters for getString macro
	mov		edx, [ebp+12]
	getString	edx, ecx				; Invoke getString to get digits

	; Convert to numeric value
	mov		esi, edx
	mov		eax, 0
	mov		ecx, 0
	mov		ebx, 10
	; Load byte from memory at esi into ax for validation before conversion
transform:
	lodsb
	cmp		ax, 0						; Check for end of input
	je		endInput

	cmp		ax, 48						
	jb		invalidChar					; Validate ASCII above 0
	cmp		ax, 57
	ja		invalidChar					; Validate ASCII below 9

	sub		ax, 48						; Find numeric value of ASCII value
	xchg	eax, ecx					; Move value into eax
	mul		ebx		
	jc		invalidSize					; Check carry flag for size					

	; At this point determined valid, add digit to the rest of the value
	add		eax, ecx
	xchg	eax, ecx					; For next loop through
	jmp		transform

invalidChar:
	mov		edx, OFFSET invalidInput
	call	WriteString
	call	CrLf
	jmp		beginInput

invalidSize:
	mov		edx, OFFSET invalidInput2
	call	WriteString
	call	CrLf
	jmp		beginInput

endInput:
	xchg	ecx, eax
	mov		DWORD PTR inputString, eax

	popad
	pop		ebp
	ret		8
ReadVal ENDP

;---------------------------------------------------------------------------------
; WriteVal
;
; Converts numeric values to strings, then displays string for output
; Receives: integer value to convert to string, address of output string
; Returns: None
;---------------------------------------------------------------------------------
WriteVal PROC
	push	ebp
	mov		ebp, esp
	pushad

	mov		eax, [ebp+12]
	mov		edi, [ebp+8]
	mov		ebx, INPUT_NUM
	push	0								; Top of stack

beginConvert:
	mov		edx, 0
	div		ebx								; Next digit
	add		edx, 48							; ASCII value of character for digit
	push	edx
	cmp		eax, 0							; Check if end of number
	jne		beginConvert

moveToString:
	pop		[edi]
	mov		eax, [edi]
	inc		edi
	cmp		eax, 0
	jne		moveToString

	; Invoke display string to produce output
	mov		edx, [ebp+8]
	displayString	OFFSET outputString
	displayString	OFFSET spacing


	popad
	pop		ebp
	ret		8
WriteVal ENDP

;---------------------------------------------------------------------------------
; ArraySum
;
; Calculates the sum of an array
; Receives: Offset of an array, number of elements in the array
; Returns: Sum of the array elements in eax
;---------------------------------------------------------------------------------
ArraySum PROC
	; Borrowed code from page 150 in Irvine text
	push	ebp
	mov		ebp, esp
	push	esi
	push	ecx

	mov		esi, [ebp+8]
	mov		ecx, [ebp+12]
	mov		eax, 0
sumLoop:
	add		eax, [esi]
	add		esi, TYPE DWORD
	loop	sumLoop

	pop		ecx
	pop		esi
	pop		ebp
	ret		8
ArraySum ENDP

;---------------------------------------------------------------------------------
; ArrayAverage
;
; Calculates the average of the values in an array
; Receives: Sum of an array, number of elements in the array
; Returns: Average of the values in the array in eax
;---------------------------------------------------------------------------------
ArrayAverage PROC
	push	ebp
	mov		ebp, esp
	push	ebx
	push	edx

	mov		edx, 0
	mov		eax, [ebp+12]
	mov		ebx, [ebp+8]
	div		ebx

	pop		edx
	pop		ebx
	pop		ebp
	ret		8
ArrayAverage ENDP


;---------------------------------------------------------------------------------
; goodbye
;
; Lets user know program has finished running and says goodbye.
; Receives: EDX = string with goodbye message for user
; Returns: Nothing
;---------------------------------------------------------------------------------
goodbye PROC
	push	ebp
	mov		ebp, esp
	pushad

	call	CrLf
	call	CrLf
	mov		edx, [ebp+8]
	call	WriteString
	call	CrLf
	call	CrLf

	popad
	pop		ebp
	ret		4
goodbye ENDP

END main
