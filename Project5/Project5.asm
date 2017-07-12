TITLE Program Template     (template.asm)

; Author: Siara Leininger
; Email: leinings@oregonstate.edu	
; Course / Project ID : CS 271 / Section 400                 Date: 11/16/2016
; Description: This program will introduce itself and the programmer. It will then get a request from the user, an
;				integer between 10 & 200. It will generate that amount of random integers between 100-999 and store
;				them in consecutive elements in an array. It will display the unsorted integers to the user, 10 integers
;				per line. After then sorting the list in descending order, it will calculate and display the median value
;				and display the sorted list to the user, 10 numbers per line.

INCLUDE Irvine32.inc

; (insert constant definitions here)
USER_MIN	=	10
USER_MAX	=	200
RANDOM_MIN	=	100
RANDOM_MAX	=	999
PER_LINE	=	10

.data

; (insert variable definitions here)
progIntro		BYTE	"Sorting Random Integers", 0
myIntro			BYTE	"By: Siara Leininger", 0
progDesc		BYTE	"This program will generate random numbers between 100 & 999, show you the original list, sort the list, and calculate the median value. Then it will show you the sorted list.", 0
userInstr		BYTE	"Please enter how many random numbers you would like generated. You may choose a number between 10 - 200.", 0
userPrompt		BYTE	"Enter how many numbers you would like me to generate: ", 0
invalidInput	BYTE	"Invalid input. Please make sure your number is in the range 10-200.", 0
unsorted		BYTE	"The unsorted values are: ", 0
median			BYTE	"The median value of this list is: ", 0
sorted			BYTE	"The sorted values are: ", 0
spacing			BYTE	"     ", 0
punc			BYTE	".", 0
goodbyeMessage	BYTE	"Thank you. Goodbye!", 0
request			DWORD	?
array			DWORD	USER_MAX DUP(?)

.code
main PROC

; (insert executable instructions here)
	
	call	Randomize
; Introduction
	push	OFFSET progIntro
	push	OFFSET myIntro
	push	OFFSET progDesc
	call	introduction

; Get user input
	push	OFFSET request
	call	getData
	call	CrLf

; Fill array
	push	request
	push	OFFSET array
	call	fillArray

; Display unsorted array
	push	OFFSET array
	push	request
	push	OFFSET unsorted
	call	displayList

; Sort array
	push	OFFSET array
	push	request
	call	sortList

; Get and display median
	push	OFFSET array
	push	request
	call	displayMedian

; Display sorted list
	push	OFFSET array
	push	request
	push	OFFSET sorted
	call	displayList

; Say goodbye to user
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

;---------------------------------------------------------------------------------
; getData
;
; Gets the number of values user would like to see in array
;
; Receives: ESI = request offset
; Returns: ESI = request
;---------------------------------------------------------------------------------
getData PROC
	push	ebp
	mov		ebp, esp
	pushad

getNum:
	mov		ebx, [ebp+8]
	mov		edx, OFFSET userPrompt
	call	WriteString
	call	ReadInt
	mov		[ebx], eax

	;validate user data
	call	validateNum
	mov		ebx, 0
	cmp		eax, ebx
	je		getNum

	popad
	pop		ebp
	ret		4								; pushed 4 bytes onto stack before call
getData ENDP

;---------------------------------------------------------------------------------
; validateNum
;
; Validates input from user is between 10 and 200
; Receives: EAX = the number to be validated
; Returns: EAX = original value if valid, 0 if not valid
;---------------------------------------------------------------------------------
validateNum PROC 
	cmp		eax, USER_MAX
	jg		invalidNum
	cmp		eax, USER_MIN
	jl		invalidNum
	ret
invalidNum:
	mov		edx, OFFSET invalidInput
	call	WriteString
	call	CrLf
	mov		eax, 0
	ret
validateNum ENDP

;---------------------------------------------------------------------------------
; fillArray
;
; Fills array of specified elements with random values
; Receives: ESI = array offset, ECX = number of elements to be in array
; Returns: ESI = The filled array offset
;---------------------------------------------------------------------------------
fillArray PROC
	; Code borrowed from Lecture 18
	push	ebp
	mov		ebp, esp
	pushad

	mov		ecx, [ebp+12]					; loop counter is user request
	mov		esi, [ebp+8]					; address of array

; Borrowed code from Exercise Solutions in Lecture 20
fillRandom:
	mov		eax, RANDOM_MAX
	sub		eax, RANDOM_MIN
	inc		eax
	call	RandomRange
	add		eax, RANDOM_MIN
	mov		[esi], eax
	add		esi, 4
	loop	fillRandom

	popad
	pop		ebp
	ret		8								; pushed 8 bytes onto stack before call
fillArray ENDP

;---------------------------------------------------------------------------------
; displayList
; 
; Iterates through each element in an array and displays element to console.
; Receives: ESI = array offset, ECX = length of array, EDX = Array title
; Returns: Nothing
;---------------------------------------------------------------------------------
displayList PROC
	; Code borrowed from Lecture 18
	push	ebp
	mov		ebp, esp
	pushad
	
	mov		esi, [ebp+16]					; Move address of array into esi
	mov		ecx, [ebp+12]					; Move length of array into ecx for counter
	mov		edx, [ebp+8]					; Move title of array into edx to display
	mov		ebx, 0

	call	WriteString						; Display the name of the array for user
	call	CrLf

; Borrowed code from page 150 in Irvine text
showNum:
	mov		eax, [esi]
	call	WriteDec
	mov		edx, OFFSET spacing
	call	WriteString
	add		esi, TYPE DWORD

format:
	inc		ebx
	cmp		ebx, PER_LINE
	jne		toTheLoop
	call	CrLf
	mov		ebx, 0
toTheLoop:	
	loop	showNum

	; More formatting
	call	CrLf
	call	CrLf

	popad
	pop		ebp
	ret		12
displayList ENDP

;---------------------------------------------------------------------------------
;sortList
;
; Sorts array of integers in descending order using bubble sort
; Receives: ESI = array offset, ECX = length of array
; Returns: ESI = sorted array offset
;---------------------------------------------------------------------------------
sortList PROC 
	; Borrowed code from page 375 of Irvine text
	push	ebp
	mov		ebp, esp
	pushad
	mov		ecx, [ebp+8]
	dec		ecx							; Decrement count to account for array indexing

L1:
	push	ecx							; Save outer loop count
	mov		esi, [ebp+12]				; First value in array
L2:
	mov		eax, [esi]					; Array value
	cmp		[esi+4], eax				; Compare two values to determine next action
	jl		L3							; Descending order, so no action if [esi] >= [esi+4]
	xchg	eax, [esi+4]				; Otherwise, exchange the elements
	mov		[esi], eax
L3:
	add		esi, 4						; Move pointers
	loop	L2							; Inner Loop

	pop		ecx							; Outer loop count
	loop	L1							; Repeat if not zero
L4:
	popad
	pop		ebp
	ret		8							; Pushed 8 bytes onto stack before calling
sortList ENDP

;---------------------------------------------------------------------------------
; displayMedian
;
; Finds and displays the median value in an array for the user
; Receives: ESI = array offset, ECX = length of array
; Returns: EAX = median value of array
;---------------------------------------------------------------------------------
displayMedian PROC
	push	ebp
	mov		ebp, esp
	pushad

	mov		esi, [ebp+12]
	mov		ecx, [ebp+8]
	mov		edx, 0			

	mov		eax, ecx
	mov		ebx, 2
	div		ebx
	cmp		edx, 0
	je		evenElements				; If the remainder is 0, then there is an even number of elements
	mov		edx, eax
	mov		eax, [esi+(4*edx)]			; Finds value of median using half of array length as index point
	jmp		printMedian

evenElements:
	mov		edx, eax
	mov		eax, [esi+(4*edx)]			; Finds upper median value using half array length as index point
	dec		edx	
	add		eax, [esi+(4*edx)]			; Finds lower median value
	mov		edx, 0
	div		ebx							; Divides by 2 to find average of both values

printMedian:
	mov		edx, OFFSET median
	call	WriteString
	call	WriteDec
	mov		edx, OFFSET punc
	call	WriteString
	call	CrLf
	call	CrLf

	popad
	pop		ebp
	ret		8
displayMedian ENDP

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
