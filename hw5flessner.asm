TITLE Homework 5     (hw5flessner.asm)

; Author: Jonathan Flessner
; HW 5 CS 271        Date: 2-March-2014
; Description: Store random numbers in an array, sort and find median.
; Only strings used as global variables.
; Stack frame used for passing other variables.

INCLUDE Irvine32.inc

MIN = 10
MAX = 200
LO = 100
HI = 999

.data

intro 		BYTE 	"Hi! Welcome to the 5th HW of CS271. Your programmer is Jonathan Flessner.", 0
explain  	BYTE 	"This program will generate random numbers, sort them and find the median.", 0
getRange 	BYTE 	"Enter in how many numbers you want to generate [10-200]: ", 0
request  	DWORD 	?
errorMsg 	BYTE 	"Sorry, that number is out of range.", 0
randArr  	DWORD 	MAX DUP(?) ;random number array with size of MAX
printNoSort BYTE	"Here is your unsorted array:", 0
printSort 	BYTE 	"Here is the sorted array: ", 0
printMed	BYTE	"The median value in the array is ", 0

.code
main PROC

	;introduce program(mer)		
	call introduction

	;get data from user
	push OFFSET request
	call getData

	;generate array
	push OFFSET randArr
	push request
	call fillArray

	;print unsorted array
	push OFFSET randArr
	push request
	call displayList

	;sort array with bubble sort
	push OFFSET randArr
	push request
	call sortList

	;print sorted array
	push OFFSET randArr
	push request
	call displayList

	;find and print median
	push OFFSET randArr
	push request
	call median

	exit	; exit to operating system
main ENDP

;introduces program(mer).
introduction PROC

	;basic intro
	mov edx, OFFSET intro
	call WriteString
	call CrLf

	;explains program
	mov edx, OFFSET explain
	call WriteString
	call CrLf

	ret
introduction ENDP

;gets the data from the user
getData PROC
	push ebp
	mov ebp, esp

;get number from user
getNumber:
	mov edx, OFFSET getRange
	call WriteString
	call ReadInt
	cmp eax, MIN
	jl invalid
	cmp eax, MAX
	jg invalid
	mov ebx, [ebp + 8]	;mov @request to ebx
	mov [ebx], eax 		;mov user input to address in ebx
	call CrLf
	pop ebp
	ret 4 				;reset stack

invalid:
	mov edx, OFFSET errorMsg
	call WriteString
	call CrLf
	jmp getNumber

getData ENDP

;fills array with request number of random numbers
fillArray PROC
	push ebp
	mov ebp, esp
	mov ecx, [ebp + 8] 	;mov value of request to ecx
	mov edi, [ebp + 12]	;mov address of start of array to esi

	;seed for RandomRange - called once
	call Randomize

	;code from Lecture 20 - Paulson, OSU
	randomFill:
		mov eax, HI 
		sub eax, LO 
		inc eax 			;RandomRange produces random int from 0 to n-1
		call RandomRange	;this code allows for a random int from lo to hi
		add eax, LO
		mov [edi], eax
		add edi, 4
		loop randomFill

	mov edx, OFFSET printNoSort
	call WriteString
	call CrLf

	pop ebp
	ret 8
fillArray ENDP

;sorts list from largest to smallest, uses bubble sort
sortList PROC
	push ebp
	mov ebp, esp
	mov ecx, [ebp + 8]		;value of request
	mov esi, [ebp + 12] 	;address of randArr[0]
	dec ecx					;lower count by one

;the following bubble sort is adapted from the textbook page 352 (Irving, Kip. Assembly Language for x86 Processors. 6th Ed.)
	outerLoop:
		push ecx				;save outer loop count
		mov esi, [ebp + 12]		;esi set to address of randArr[0]
	sorting:
		mov eax, [esi]			;get value of randArr
		cmp [esi + 4], eax 		
		jl noSwap				;no swap needed
		call swap 				;go to swap procedure
		
	noSwap:
		add esi, 4
		loop sorting

		pop ecx
		loop outerLoop

	mov edx, OFFSET printSort
	call WriteString
	call CrLf

	pop ebp
	ret 8
sortList ENDP

;swaps values for bubble sort
swap PROC
	;swaps the values in question
	xchg eax, [esi + 4]	;exchanges contents
	mov [esi], eax 		;finishes the swap
	ret 
swap ENDP

;finds median value in array
median PROC
	push ebp
	mov ebp, esp
	mov ecx, [ebp + 8]	;value of request
	mov esi, [ebp + 12]	;@randArr

	;test if request is even or odd
	mov eax, ecx
	mov ebx, 2
	cdq
	div ebx 		;div request / 2
	cmp edx, 0
	je evenCount 	;if no remainder, request is even
;if odd, then the middle number is the median
oddCount:
	mov ebx, 4
	mul ebx					;put in eax: (request / 2) * 4
	mov eax, [esi + eax]	;median in eax
	mov edx, OFFSET printMed
	call WriteString
	call WriteDec
	call CrLf
	call CrLf
	jmp endMedian
;if even, take the two middle nums and average
evenCount:
	mov ebx, 4
	mul ebx
	mov edx, [esi + eax] 	;first value in edx
	sub eax, 4
	mov ebx, [esi + eax]
	mov eax, ebx 			;second value in eax
	add eax, edx			;total of both values in eax
	mov ebx, 2 				
	cdq
	div ebx 				;eax holds unrounded median
	cmp edx, 0 				
	je noAdd 				;if divided evenly, no need to round
	inc eax 				;add one for rounding up from .5
noAdd:
	mov edx, OFFSET printMed
	call WriteString
	call WriteDec
	call CrLf
	call CrLf

endMedian:
	pop ebp
	ret 8
median ENDP

;prints the array
displayList PROC
	push ebp
	mov ebp, esp
	mov ecx, [ebp + 8] 	;holds request
	mov edi, [ebp + 12] ;address of start of array

printArray:
	mov eax, [edi]
	call WriteDec 	;print number
	add edi, 4 		;go to next number
	mov eax, tab 	
	call WriteChar 	;print a tab
	loop printArray ;continue loop for each number

	call CrLf
	pop ebp
	ret 8
displayList ENDP

END main
