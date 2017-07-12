TITLE Program Template     (template.asm)

; Author: Siara Leininger
; Email: leinings@oregonstate.edu
; Course / Project ID : CS 271-400 / Project 3                 Date: October 28, 2016
; Description: This program will introduce itself and identify me as the author. It will get the user's name and greet the user. It will then
;				prompt the user to enter a number, validate the number is between -11 and -1, and continually prompt the user to enter a number
;				until a positive number is entered. It will calculate and display the number of negative numbers entered, their sum, and the 
;				rounded average of those numbers. Then the program will exit and say goodbye.

INCLUDE Irvine32.inc

; (insert constant definitions here)
INPUT_MIN	=	-100
INPUT_MAX	=	-1

.data

; (insert variable definitions here)
progIntro		BYTE	"Project #3 - Integer Accumulator", 0
myIntro			BYTE	"By: Siara Leininger", 0
userNameInstr	BYTE	"Please enter your name, then press 'enter': ", 0
userGreet		BYTE	"Hello, ", 0
userInstr		BYTE	"Please enter numbers between -100 and -1.", 0
userInstr2		BYTE	"When you are finished, enter a non-negative number to see results.", 0
userInstr3		BYTE	"Enter a number: ", 0
inputNotValid	BYTE	"Invalid input, I cannot accept values lower than -100. Please try again.", 0
special			BYTE	"No calculations have been done as no negative values have been entered.", 0
exclaim			BYTE	"!", 0
period			BYTE	".", 0
goodbye			BYTE	"Thank you for playing! Goodbye, ", 0
enteredMessage	BYTE	"You entered ", 0
endEnter		BYTE	" valid numbers.", 0
sumMessage		BYTE	"The sum of your valid numbers is ", 0
averageMessage	BYTE	"The rounded average is ", 0
userName		DWORD 33 DUP(0)
numCount		DWORD 0
curNum			DWORD ?
sum				DWORD ?
average			DWORD ?
roundTest		DWORD ?
temp			DWORD ?
remainder		DWORD ?

.code
main PROC

; (insert executable instructions here)

; Introduce the program and programmer
	mov		edx, OFFSET progIntro
	call	WriteString
	call	CrLf
	mov		edx, OFFSET myIntro
	call	WriteString
	call	CrLf

; Get name from and greet user
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
	mov		edx, OFFSET exclaim
	call	WriteString
	call	CrLf

; Prompt user to enter numbers and provide instructions for how to do so
	mov		edx, OFFSET userInstr
	call	WriteString
	call	CrLf
	mov		edx, OFFSET userInstr2
	call	WriteString
	call	CrLf
L1:
	mov		edx, OFFSET userInstr3
	call	WriteString
	call	ReadInt
	mov		curNum, eax
	mov		eax, curNum
	jns		L5							; If sign flag not set, discard value and jump to calculations
	js		L2							; If sign flag set, jump to lower limit check
L2:
	mov		eax, curNum
	cmp		eax, INPUT_MIN
	jl		L3							; Jump to invalid input message
	jge		L4							; Jump to accumulators
L3:
	mov		edx, OFFSET inputNotValid
	call	WriteString
	call	CrLf
	jmp		L1

; Calculate sum of negative numbers entered so far
L4:
	mov		eax, sum
	mov		ebx, curNum
	add		eax, ebx
	mov		sum, eax

; Increment total value accumulator
	mov		eax, numCount
	inc		eax
	mov		numCount, eax
	jmp		L1							; Ask user for another number, non-negative has not been entered yet

; Check to see if any negative numbers have been entered
L5:
	mov		eax, numCount
	mov		ebx, 0
	cmp		eax, ebx
	jg		L6
	mov		edx, OFFSET special
	call	WriteString
	call	CrLf
	jmp		endProgram

; Calculate average of negative numbers
L6:
	mov		eax, sum
	cdq
	mov		ebx, numCount
	idiv	ebx
	mov		average, eax
	mov		roundTest, edx

	; Test remainder to see if necessary to round up
	; We know if the remainder is >= half of the divisor, we round up (or in this case, down)
	mov		edx, 0
	mov		eax, numCount
	mov		ebx, 2
	div		ebx
	mov		temp, eax
	mov		eax, temp
	mov		ebx, roundTest
	neg		ebx								; Remainder comes negative, change to positive
	cmp		eax, ebx
	jge		L7
	mov		eax, average
	dec		eax
	mov		average, eax





; Display results
L7:
	mov		edx, OFFSET enteredMessage
	call	WriteString
	mov		eax, numCount
	call	WriteDec
	mov		edx, OFFSET endEnter
	call	WriteString
	call	CrLf
	mov		edx, OFFSET sumMessage
	call	WriteString
	mov		eax, sum
	call	WriteInt
	mov		edx, OFFSET period
	call	WriteString
	call	CrLf
	mov		edx, OFFSET averageMessage
	call	WriteString
	mov		eax, average
	call	WriteInt
	mov		edx, OFFSET period
	call	WriteString
	call	CrLf

; Say goodbye and exit
endProgram:
	call	CrLf
	mov		edx, OFFSET goodbye
	call	WriteString
	mov		edx, OFFSET userName
	call	WriteString
	mov		edx, OFFSET exclaim
	call	WriteString
	call	CrLf

	exit	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
