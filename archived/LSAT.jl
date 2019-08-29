# LSAC JUNE 2007 Form 8LSN75
# https://www.lsac.org/sites/default/files/legacy/docs/default-source/jd-docs/sampleptjune.pdf

# Question 1

#A company employee generates a series of five-digit product
#codes in accordance with the following rules:
#The codes use the digits 0, 1, 2, 3, and 4, and no others.
Ω,℧ = ABparse(["a, b, c, d, e  ∈  0:4"]); Ω[℧]

#Each digit occurs exactly once in any code.
Ω,℧ = ABparse("{{i}} != {{!i}}", Ω,℧); Ω[℧]

#The second digit has a value exactly twice that of the
#first digit.
Ω,℧ = ABparse("b == a*2", Ω,℧); Ω[℧]

#The value of the third digit is less than the value of the
#fifth digit
Ω,℧ = ABparse("c < e", Ω,℧); Ω[℧]

#1. If the last digit of an acceptable product code is 1, it
#must be true that the
Ω1,℧1 = ABparse("e == 1 ==> a==2", Ω,℧); Ω1[℧1]
#(A) first digit is 2
Ω1,℧1 = ABparse("e == 1 ==> b==0", Ω,℧); Ω1[℧1]
#(B) second digit is 0
Ω1,℧1 = ABparse("e == 1 ==> c==3", Ω,℧); Ω1[℧1]
#(C) third digit is 3
Ω1,℧1 = ABparse("d == 1 ==> d==4", Ω,℧); Ω1[℧1]
#(D) fourth digit is 4
Ω1,℧1 = ABparse("d == 1 ==> d==0", Ω,℧); Ω1[℧1]
#(E) fourth digit is 0

#2. Which one of the following must be true about any
#acceptable product code?
range(Ω, ℧)
Ω[℧]

#(A) The digit 1 appears in some position before the
#digit 2.
Ω2,℧2 = ABparse("{{i}} == 1 &&& {{>i}} == 2 {{1}}", Ω,℧); Ω2[℧2]

#(B) The digit 1 appears in some position before the
#digit 3.
Ω2,℧2 = ABparse("{{i}} == 1 &&& {{>i}} == 3 {{1}}", Ω,℧); Ω2[℧2]

#(C) The digit 2 appears in some position before the
#digit 3.
Ω2,℧2 = ABparse("{{i}} == 2 &&& {{>i}} == 3 {{1}}", Ω,℧); Ω2[℧2]

#(D) The digit 3 appears in some position before the
#digit 0.
Ω2,℧2 = ABparse("{{i}} == 0 &&& {{>i}} == 3 {{1}}", Ω,℧); Ω2[℧2]

#(E) The digit 4 appears in some position before the
#digit 3.
Ω2,℧2 = ABparse("{{i}} == 4 &&& {{>i}} == 3 {{1}}", Ω,℧); Ω2[℧2]

#3. If the third digit of an acceptable product code is not 0,
#which one of the following must be true?

Ω3,℧3 = ABparse("c != 0", Ω,℧); Ω3[℧3]
range(Ω3,℧3)

#(A) The second digit of the product code is 2.
#(B) The third digit of the product code is 3.
#(C) The fourth digit of the product code is 0.
#(D) The fifth digit of the product code is 3. <true>
#(E) The fifth digit of the product code is 1.

Ω[℧]

#4. Any of the following pairs could be the third and
#fourth digits, respectively, of an acceptable product
#code, EXCEPT:
# (A) 0, 1
ABparse(["c == 0", "d == 1"], Ω=Ω,℧=℧)
# (B) 0, 3
ABparse(["c == 0", "d == 3"], Ω=Ω,℧=℧)
#(C) 1, 0
ABparse(["c == 1", "d == 0"], Ω=Ω,℧=℧)
#(D) 3, 0
ABparse(["c == 3", "d == 0"], Ω=Ω,℧=℧)
#(E) 3, 4
ABparse(["c == 3", "d == 4"], Ω=Ω,℧=℧) # zero feasible outcomes

Ω[℧]

#5. Which one of the following must be true about any
#acceptable product code?
#(A) There is exactly one digit between the digit 0
#and the digit 1.
ABparse(["{{i}} == 1|0 <=> {{i+2}} == 1|0"], Ω=Ω,℧=℧) # zero feasible outcomes

#(B) There is exactly one digit between the digit 1
#and the digit 2.
ABparse(["{{i}} == 1|2 <=> {{i+2}} == 1|2"], Ω=Ω,℧=℧) # zero feasible outcomes

#(C) There are at most two digits between the digit 1 ??? Not working
#and the digit 3.
ABparse(["{{i}} == 1|3 <=> {{i+3}} == 1|3 |||| {{i}} == 1|3 <=> {{i+4}} == 1|3"], Ω=Ω,℧=℧) # zero feasible outcomes

ABparse("{{i}} != {{i+1}}", Ω,℧) # zero feasible outcomes

(D) There are at most two digits between the digit 2
and the digit 3.
ABparse(["{{i}} == 2|3 <==> {{i+3}} == 2|3"], Ω=Ω,℧=℧) # zero feasible outcomes

(E) There are at most two digits between the digit 2
and the digit 4.
ABparse(["""{{i}} == 2|4 <==> {{i+3}} == 2|4 ||||
            {{i}} == 2|4 <==> {{i+2}} == 2|4 ||||
            {{i}} == 2|4 <==> {{i+1}} == 2|4 """], Ω=Ω,℧=℧) # zero feasible outcomes

Ω[℧]
