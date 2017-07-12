TITLE Program Template     (template.asm)

; Author: Siara Leininger
; Email: leinings@oregonstate.edu
; Course / Project ID : CS 271-400                Date: November 5, 2016
; Description: This program will ask the user to enter a number of composites they would like to be displayed, in the range 1-400. The program will
;				verify that the number is in this range. Once the number is verified to be in range, the program will calculate and display all
;				of the composite numbers up to and including the nth composite. 

INCLUDE Irvine32.inc

; (insert constant definitions here)
UPPER_LIMIT		=	400 
PER_LINE		=	10

.data

; (insert variable definitions here)
progIntro		BYTE	"Program #4: Composite Numbers",0
myIntro			BYTE	"By: Siara Leininger", 0
userInstr		BYTE	"Please enter how many composite numbers you would like to see. I can show up to 400 numbers.", 0
userPrompt		BYTE	"Enter your number: ", 0
invalidInput	BYTE	"That number is out of range. Please choose a number between 1 and 400.", 0
goodbyeMessage	BYTE	"Brought to you by Siara. Goodbye!", 0
spacing			BYTE	"   ", 0
numComp			DWORD	?
prevComp		DWORD	?
nextComp		DWORD	?
numTerms		DWORD	47 DUP(0)
temp			DWORD	?


.code
main PROC

; (insert executable instructions here)

; Introduction
	call	introduction

; Get valid data from user
	call	getData

; Display and calculate composite numbers
	call	printComposite

;Say goodbye and exit
	call	goodbye


	exit	; exit to operating system
main ENDP

; (insert additional procedures here)

;----------------------------------------------------------------------------------
; introduction
;
; Introduces the program, programmer, and provides initial instructions to user
; Receives: No parameters
; Returns: No values, prints information to screen
;----------------------------------------------------------------------------------
introduction PROC
	mov		edx, OFFSET progIntro
	call	WriteString
	call	CrLf
	mov		edx, OFFSET myIntro
	call	WriteString
	call	CrLf
	mov		edx, OFFSET userInstr
	call	WriteString
	call	CrLf
	call	CrLf
	ret
introduction ENDP

;---------------------------------------------------------------------------------
; getData
;
; Gets the number of composite numbers the user would like to see printed
;
; Receives: No parameters
; Returns: EAX = numComp
;---------------------------------------------------------------------------------
getData PROC
getNum:
	mov		edx, OFFSET userPrompt
	call	WriteString
	call	ReadInt
	;validate user data
	call	validateNum
	mov		eax, numComp
	mov		ebx, 0
	cmp		eax, ebx
	jle		getNum
	ret
getData ENDP

;---------------------------------------------------------------------------------
; validateNum
;
; Validates input from user is between 1 and 400
; Receives: EAX = numComp, the number to be validated
; Returns: EAX = numComp if valid, 0 if not valid
;---------------------------------------------------------------------------------
validateNum PROC
	mov		numComp, eax
	mov		eax, numComp
	cmp		eax, UPPER_LIMIT
	jg		invalidNum
	mov		ebx, 0
	cmp		eax, ebx
	jle		invalidNum
	ret
invalidNum:
	mov		edx, OFFSET invalidInput
	call	WriteString
	call	CrLf
	mov		eax, 0
	mov		numComp, eax
	mov		eax, numComp
	ret
validateNum ENDP

;---------------------------------------------------------------------------------
; printComposite
;
; Calls function to find next composite number in series and prints all
; composite numbers up to amount specified by user
; Receives: ECX = numComp
; Returns: Nothing, prints values to screen
;---------------------------------------------------------------------------------
printComposite PROC
	mov		eax, 3
	mov		nextComp, eax
	mov		ecx, numComp
getComp:	
	mov		prevComp, eax
	mov		eax, prevComp
	call	findComposite
	call	WriteDec
format:	
	mov		edx, OFFSET spacing
	call	WriteString
	mov		ebx, numTerms
	inc		ebx
	mov		numTerms, ebx
	cmp		numTerms, PER_LINE
	jne		toTheLoop
	call	CrLf
	mov		numTerms, 0
toTheLoop:
	loop	getComp
	ret

printComposite ENDP

;---------------------------------------------------------------------------------
; findComposite
;
; Finds next composite number following a previous value.
; Receives: EAX = prevComp
; Returns: EAX = nextComp
;---------------------------------------------------------------------------------
findComposite PROC USES ecx
	; Increment previous composite number to test if next value is composite
	mov		eax, prevComp
ontoNextNum:
	inc		eax
	mov		nextComp, eax
	; Check if number is even. If even, then value is composite.
isEven:
	mov		edx, 0
	mov		ebx, 2
	div		ebx
	mov		temp, eax
	cmp		edx, 0
	je		printNum
	; If not even, use the quotient of dividing value by 2 as loop counter
	mov		ecx, temp
isComp:
	mov		eax, nextComp
	cmp		ecx, 2					; Once loop counter reaches 2, unnecessary to keep going
	je		ontoNextNum
	mov		edx, 0
	div		ecx
	cmp		edx, 0
	je		printNum
	loop	isComp

printNum:
	mov		eax, nextComp
	ret
findComposite ENDP

;---------------------------------------------------------------------------------
; goodbye
;
; Lets user know program has finished running and says goodbye.
; Receives: No parameters
; Returns: Nothing
;---------------------------------------------------------------------------------
goodbye PROC
	call	CrLf
	call	CrLf
	mov		edx, OFFSET goodbyeMessage
	call	WriteString
	call	CrLf
	call	CrLf
	ret
goodbye ENDP

END main
