# Mufang

Project Members: Fatih Furkan Aydemir, Murat Eş

# Syntax

## Tokens & Regexs

```
REGEX				   <--> TOKEN

if  				   <--> IF
else   				   <--> ELSE
function   			   <--> FUNCTION
while   			   <--> WHILE
print   			   <--> PRINT
fprint   			   <--> FPRINT
fread   			   <--> FREAD
==   				   <--> IS_EQUAL
!=   				   <--> NOT_EQUALS
(   				   <--> PARANTHESIS_OPEN
)   				   <--> PARANTHESIS_CLOSE
{   				   <--> CURLY_OPEN
}   				   <--> CURLY_CLOSE
<=   				   <--> LESS_THAN_OR_EQUALS
>=   				   <--> GREATER_THAN_OR_EQUALS
() 				   <--> FUNC_CALL
[_a-zA-Z][_a-zA-Z0-9]* 		   <--> IDENTIFIER

LITERALS
true|false             --> boolean literal <--> LITERAL
[-+]?[0-9]+ 	       --> integer literal <--> LITERAL
[-+]?[0-9]+[\.]?[0-9]+ --> double literal  <--> LITERAL
true|false 	       --> string literal  <--> LITERAL
```

## BNF

```
<program> : <statements>
```

```
<statements> : <statement> | <statement> <statements>
```

```
<statement> : <exp>
			| PRINT PARANTHESIS_OPEN <exp> PARANTHESIS_CLOSE
			| WHILE PARANTHESIS_OPEN <logic_exp> PARANTHESIS_CLOSE <statement>
			| WHILE PARANTHESIS_OPEN <logic_exp> PARANTHESIS_CLOSE CURLY_OPEN <statements> CURLY_CLOSE
			| IF PARANTHESIS_OPEN <exp> PARANTHESIS_CLOSE <statement>
			| IF PARANTHESIS_OPEN <exp> PARANTHESIS_CLOSE CURLY_OPEN <statements> CURLY_CLOSE
			| IF PARANTHESIS_OPEN <exp> PARANTHESIS_CLOSE <statement> ELSE <statement>
		        | IF PARANTHESIS_OPEN <exp> PARANTHESIS_CLOSE CURLY_OPEN <statement> CURLY_CLOSE ELSE CURLY_OPEN <statements> CURLY_CLOSE
			| FUNCTION IDENTIFIER CURLY_OPEN <statements> CURLY_CLOSE
			| IDENTIFIER FUNC_CALL
			| FPRINT PARANTHESIS_OPEN LITERAL ',' <exp> PARANTHESIS_CLOSE
```

```
<exp> : <term>
	  | <logic_exp>
	  | <assignment_exp>
	  | FREAD PARANTHESIS_OPEN LITERAL PARANTHESIS_CLOSE
```

```
<assignment_exp> : IDENTIFIER '=' <exp>
```

```
<term> : <term> '+' <term>
	   | <term> '-' <term>
	   | <term> '\*' <term>
	   | <term> '/' <term>
	   | <term> '%' <term>
	   | '-' LITERAL
	   | '-' IDENTIFIER
	   | PARANTHESIS_OPEN <term> PARANTHESIS_CLOSE
	   | <logic_exp>
	   | LITERAL
	   | IDENTIFIER
```

```
<logic_exp> : <term> IS_EQUAL <term>
		    | <term> NOT_EQUALS <term>
		    | <term> '&' <term>
		    | <term> '|' <term>
		    | <term> '>' <term>
		    | <term> '<' <term>
		    | <term> GREATER_THAN_OR_EQUALS <term>
		    | <term> LESS_THAN_OR_EQUALS <term>
		    | '!' <term>
```

## Explanations about the language

- You can run your program by running the makefile and giving example program as input:

  ```
  make
  ./mufang < example.mf
  ```

---

- ## General Features:

  - Mufang is a general purpose and simple programming language which was designed to teach programming to children. So it's purpose to be simple and it consists of fundamental statements and expressions like a loop, if-else, printing and arithmetic operations.
  - There are three variable types in the language: integer, double and string.
  - There are true and false boolean literals but these are converted to integers 1 and 0 respectively at runtime.
  - Variable types are determined by type inference so programmer doesn't have to specify the type of variable.
  - Language is dynamically typed so you can assign any type to any variable at any time.
  - With print function you can output any expression you like.
  - For iteration and repeated actions, Mufang has a while loop which keeps working as long as the given condition is held.
  - Mufang has if-else statement for conditionally running statements.
  - Functions can be defined with the function keyword. Functions does not have parameters and returns for simplicity for children.
  - Since all variable are global, there is no scopes. Statements can be grouped with curly braces { } in if-else, while and functions to run them together.
  - Mufang has arithmetic and logic operators like +, -, \*, <, >, !=, == etc. Full list below.
  - Operators has type checking so operators can only be applied to specific opreand types. You can add a string and an integer like "str" + 5 and you obtain "str5" string. But you can't subtract from strings like "str" - 5, this will cause an error.
  - Mufang has simple file I/O with two functions: fread, fwrite. fread reads the full content of a given file and fread writes the given expression to a file. Examples below.
  - File extension is .mf
  - You can define single line comments with double slashes. // this is a comment.
  - Assignment is an expression so a = b = 3 is a valid assignment and both a and b gets value 3.
  - Variable names can be more than one character, there is no character limit.

---

- ## Variable Types:

  - integer
    ```
    intvar = 5
    ```
  - double
    ```
    doublevar = 12.5;
    ```
  - string
    ```
    stringvar = "Hello";
    ```

---

- ## Language Keywords:

  - > if
  - > else
  - > while
  - > function

---

- ## Predefined Functions:

  - > fprint
  - > fread
  - > print

---

- ## Operators:

  - > **!** &nbsp;&nbsp;&nbsp;&nbsp;   <----> &nbsp;&nbsp;&nbsp;&nbsp; `logical not`
  - > **\+** &nbsp;&nbsp;&nbsp;&nbsp;  <----> &nbsp;&nbsp;&nbsp;&nbsp; `addition`
  - > **\-** &nbsp;&nbsp;&nbsp;&nbsp;  <----> &nbsp;&nbsp;&nbsp;&nbsp; `subtraction`
  - > **\*** &nbsp;&nbsp;&nbsp;&nbsp;  <----> &nbsp;&nbsp;&nbsp;&nbsp; `multiplication`
  - > **/** &nbsp;&nbsp;&nbsp;&nbsp;   <----> &nbsp;&nbsp;&nbsp;&nbsp; `division`
  - > **%** &nbsp;&nbsp;&nbsp;&nbsp;   <----> &nbsp;&nbsp;&nbsp;&nbsp; `modulo`
  - > **==** &nbsp;&nbsp;&nbsp;&nbsp;  <----> &nbsp;&nbsp;&nbsp;&nbsp; `is equal`
  - > **!=** &nbsp;&nbsp;&nbsp;&nbsp;  <----> &nbsp;&nbsp;&nbsp;&nbsp; `not equals`
  - > **&** &nbsp;&nbsp;&nbsp;&nbsp;   <----> &nbsp;&nbsp;&nbsp;&nbsp; `logical and`
  - > **|** &nbsp;&nbsp;&nbsp;&nbsp;   <----> &nbsp;&nbsp;&nbsp;&nbsp; `logical or`
  - > **<** &nbsp;&nbsp;&nbsp;&nbsp;   <----> &nbsp;&nbsp;&nbsp;&nbsp; `less than`
  - > **\>** &nbsp;&nbsp;&nbsp;&nbsp;  <----> &nbsp;&nbsp;&nbsp;&nbsp; `greater than`
  - > **<=** &nbsp;&nbsp;&nbsp;&nbsp;  <----> &nbsp;&nbsp;&nbsp;&nbsp; `less than or equals`
  - > **\>=** &nbsp;&nbsp;&nbsp;&nbsp; <----> &nbsp;&nbsp;&nbsp;&nbsp; `greater than or equals`
  - > **( )** &nbsp;&nbsp;&nbsp;&nbsp; <----> &nbsp;&nbsp;&nbsp;&nbsp; `function call`

- ## Operator Precedence (lower to higher from top to bottom)
  - > **=**
  - > **|**
  - > **== &nbsp; !=**
  - > **\< &nbsp; \> &nbsp; \<= &nbsp; \>=**
  - > **\- &nbsp; \+**
  - > **\* &nbsp; / &nbsp; %**
  - > **( )**

---

- ## Other features:

  - **You can define comments with //**
    - Example:
      ```
      // This is a comment
      ```
  - **if and else are used for condition checks**

    - Example:

      ```
      if(condition) {
        statements
      }
      ```

    - Example:

      ```
      if(condition)
        statement

      ```

    - Example:

      ```
      if(condition)
        statement

      else
        statement

      ```

    - Example:
      ```
      if(condition) {
        statements
      }
      else {
        statements
      }
      ```

  - **while is used for loops**

    - Example:

      ```
      while(condition)
        statement
      ```

    - Example:

      ```
      while(condition) {
        statements
      }
      ```

  - **function keyword is used to define a function**

    - Example:

      ```
      function myFunc {
        statements
      }

      myFunc() // to call the function
      ```

  - **print function to print expressions**

    - Example:

      ```
      name = "Hello world!"
      print(name)

      // outputs: Hello world!
      ```

  - **fprint, fread are used for file io**

    - Example:

      ```
      content = fread("filename.txt")
      print(content)

      // outputs file content
      ```

    - Example:

      ```
      content = "This will be outputted to file"
      fprint("filename.txt", content)

      // filename.txt created and filled
      ```

# Example Programs And Outputs

- ## example_fundamentals.mf

```
iVar = 5
dVar = 16.34
sVar = "Hello World!"

print(iVar)
print(dVar)
print(sVar)

print(iVar + dVar)
print(dVar + sVar)

sum = sVar + " - " + dVar + " - " + iVar
print(sum)

print(dVar / iVar)
print(5 % 3)
print((15 + 22.5) / 3.2)

print(10 / 2 == 5)
print(3 <= 2)
print(3 <= 3)

longVariableName = "This variable name is long"
print(longVariableName)
```
![image](https://user-images.githubusercontent.com/31140894/169670844-a0dbfb90-e8e6-488e-b7f9-2210e46559ec.png)


- ## example_loop_ifelse.mf

```
val1 = 3
val2 = 3

print("-----------------------------")
while(val1 > 0) {
  while(val2 > 0) {
    print(val2 - val1)
    val2 = val2 - 1
  }
  val1 = val1 - 1
  val2 = 4
}

print("-----------------------------")
val3 = 50
while(val3 > 0)
{
  if(val3 % 3 == 0 & val3 % 5 == 0)
    print(val3)

  val3 = val3 - 1
}
print("-----------------------------")

val3 = 100
while(val3 > 0)
{
  if(val3 % 20 == 0 | val3 % 14 == 0)
    print(val3)

  val3 = val3 - 1
}
print("-----------------------------")

cond1 = 3 > 2 == 1
if(cond1)
  print("3 is bigger than 2")
print("-----------------------------")

cond2 = 4.5 > 15
if(cond2) {
  print("4.5 is bigger than 15")
}
else {
  print("4.5 is less than 15")
}
```
![image](https://user-images.githubusercontent.com/31140894/169670861-769f9981-52c6-4f0e-b286-51b737106a77.png)

- ## example_functions.mf

```
val = 150

function printMultOf15 {
  while(val > 0)
  {
    if(val % 15 == 0)
      print(val)

    val = val - 1
  }
}

function sayHello5Times {
  print("Hello")
  print("Hello")
  print("Hello")
  print("Hello")
  print("Hello")
}

a = 5
b = 15

if(15 > 5) {
  val = val + 15 * 3
  print("val set to: " + val)
}

printMultOf15()
print("--------------------------")
sayHello5Times()
```
![image](https://user-images.githubusercontent.com/31140894/169670887-7e5ad4f1-faff-4cc1-aac7-7618b84995b5.png)

- ## example_fileops.mf

```
fileContent = fread("file.txt")
print("Content: " + fileContent)

var = 5
while(var > 0) {
  fileContent = fileContent + var
  var = var - 1
}

fprint("out.txt", fileContent)
print(fileContent + " is written to out.txt")
```
![image](https://user-images.githubusercontent.com/31140894/169670914-10152969-9ac9-4604-92bf-5002b2a82600.png)
![image](https://user-images.githubusercontent.com/31140894/169670943-a365a8a5-58f0-4126-9b8e-8b42604c0199.png)
