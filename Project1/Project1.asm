TITLE Program Template     (Project1.asm)

; Author: Siara Leininger
; Email: leinings@oregonstate.edu
; Course / Project ID : CS 271-400 / Project #1              Due Date: October 9, 2016
; Description: This program will display my name and the program title on the output screen, display instructions for the user,
;	prompt the user to enter two numbers, calculate the sum, difference, product, quotient, and remainder of the numbers,
;	and display a terminating message.

INCLUDE Irvine32.inc


.data

; Variable definitions
intro		BYTE	"By: Siara Leininger", 0
progName	BYTE	"Elementary Arithmetic", 0 
progDesc	BYTE	"If you enter two numbers, this program will find the sum, difference, product, qoutient, and remainder.", 0
extraCredit	BYTE	"**EC: This program will also validate that the second number entered is less than the first.", 0
userInstr1	BYTE	"Please enter a number: ", 0
userInstr2	BYTE	"Please enter another number: ", 0
displaySum	BYTE	"The sum is: ", 0
displayDif	BYTE	"The difference is: ", 0
displayPro	BYTE	"The product is: ", 0
displayQuot	BYTE	"The quotient is: ", 0
displayRem	BYTE	"The remainder is: ", 0
goodbye		BYTE	"Thank you! Goodbye!", 0
addOp		BYTE	" + ", 0
subOp		BYTE	" - ", 0
mulOp		BYTE	" x ", 0
divOp		BYTE	" / ", 0
equalOp		BYTE	" = ", 0
firstNum	DWORD ?
secondNum	DWORD ?
sumNums		DWORD ?
difNums		DWORD ?
proNums		DWORD ?
quotNums	DWORD ?
remNums		DWORD ?

;Extra Credit variable definitions
inputNotValid	BYTE	"Sorry, the second number must be less than the first number.", 0

.code
main PROC

;Introduce program and programmer
	mov		edx, OFFSET progName
	call	WriteString
	call	CrLf
	mov		edx, OFFSET intro
	call	WriteString
	call	CrLf

;Describe program
	mov		edx, OFFSET progDesc
	call	WriteString
	call	CrLf
	mov		edx, OFFSET extraCredit
	call	WriteString
	call	CrLf

;Get first number from user
	mov		edx, OFFSET userInstr1
	call	WriteString
	call	ReadInt
	mov		firstNum, eax
	call	CrLf

;Get second number from user
	mov		edx, OFFSET userInstr2
	call	WriteString
	call	ReadInt
	mov		secondNum, eax
	call	CrLf

;Validate the second number is less than the first
	mov		eax, firstNum
	cmp		eax, secondNum
	jle		L1
	jg		calculations
L1:
	mov		edx, OFFSET inputNotValid
	call	WriteString
	call	CrLf
	jmp		endProgram

;Find sum and begin calculations once user input has been validated
calculations:
	mov		eax, firstNum
	mov		ebx, secondNum
	add		eax, ebx
	mov		sumNums, eax

;Find difference
	mov		eax, firstNum
	mov		ebx, secondNum
	sub		eax, ebx
	mov		difNums, eax

;Find product
	mov		eax, firstNum
	mov		ebx, secondNum
	mul		ebx
	mov		proNums, eax

;Find quotient and remainder
	mov		edx, 0
	mov		eax, firstNum
	mov		ebx, secondNum
	div		ebx
	mov		quotNums, eax
	mov		remNums, edx

;Display results
	mov		edx, OFFSET displaySum
	call	WriteString
	mov		eax, sumNums
	call	WriteInt
	call	CrLf
	mov		edx, OFFSET displayDif
	call	WriteString
	mov		eax, difNums
	call	WriteInt
	call	CrLf
	mov		edx, OFFSET displayPro
	call	WriteString
	mov		eax, proNums
	call	WriteInt
	call	CrLf
	mov		edx, OFFSET displayQuot
	call	WriteString
	mov		eax, quotNums
	call	WriteInt
	call	CrLf
	mov		edx, OFFSET displayRem
	call	WriteString
	mov		eax, remNums
	call	WriteInt
	call	CrLf	
	call	CrLf

;Say goodbye and end the program
endProgram:
	mov		edx, OFFSET goodbye
	call	WriteString
	call	CrLf

	exit	; exit to operating system
main ENDP


END main
