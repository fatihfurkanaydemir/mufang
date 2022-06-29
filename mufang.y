%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

extern int yylineno;

typedef enum {
	T_UNDEFINED, T_INT = 1000, T_DOUBLE = 1001, T_STR = 1002
} VarNodeType;

typedef enum {
	O_ADD, O_SUB, O_DIV, O_MUL, O_MOD,
	O_IS_EQ, O_IS_NOT_EQ, O_IS_GREATER, O_IS_LESS, O_IS_GRATEREQ, O_IS_LESSEQ,
	O_AND, O_OR, O_MINUS, O_NOT
} Operator;

typedef enum { 
	NT_LIT, NT_ID, NT_OPR
} NodeType;

struct VarNode {
	char* id;
	char* value;
	VarNodeType type;
	struct VarNode* next;
};
typedef struct VarNode VarNode;


typedef struct st_OprNode {
    int operator;                   
    int numOperands;               
    struct st_Node* operands[3];
} OprNode;

typedef struct st_FuncNode {
	char* id;
	struct st_Node* statements;
	struct st_FuncNode* next;
} FuncNode;

typedef struct st_Node {
    NodeType type;
		int exec;

    union {
        VarNode varNode;
        OprNode oprNode; 
    };
} Node;

void yyerror (const char *s);
void printerr(const char* s, const char* detail);
char* enumToStr(int type);
int yylex();

int yydebug=0;

VarNode* Identifiers = NULL;
FuncNode* Functions = NULL;

void updateVarNodeVal(char* id, char* val);
void updateFuncNode(char* id, Node* statements);

char* getVarNodeVal(char* id);
VarNodeType getVarNodeType(char* id);
VarNodeType getValType(char* val);

char* getRealVal(char* val);
char* getOpResult(char* var1, char* var2, Operator op);
char* getUnaryOpResult(char* var, Operator op);

char* dResToVal(double res);
char* iResToVal(int res, int isBool);
char* sResToVal(char* res);

Node* tertiaryOp(int opr, Node* n1, Node* n2, Node* n3);
Node* binaryOp(int opr, Node* n1, Node* n2);
Node* unaryOp(int opr, Node* n1);
Node* identifier(char* id);
Node* literal(char* val);

char* execute(Node* node);
%}

%define parse.error verbose
%define parse.lac full

%union {char* identifier; char* literal; struct st_Node* node;}

%token IF
%token ELSE
%token FUNCTION
%token WHILE
%token PRINT
%token FPRINT
%token FREAD
%token IS_EQUAL
%token NOT_EQUALS
%token PARANTHESIS_OPEN
%token PARANTHESIS_CLOSE
%token CURLY_OPEN
%token CURLY_CLOSE 
%token LESS_THAN_OR_EQUALS
%token GREATER_THAN_OR_EQUALS
%token FUNC_CALL

%token <literal> LITERAL
%token <identifier> IDENTIFIER

%type <node> statement statements exp logic_exp term assignment_exp

%right '='
%left '|'
%left '&'
%left IS_EQUAL NOT_EQUALS
%left '<' '>' LESS_THAN_OR_EQUALS GREATER_THAN_OR_EQUALS
%left '+' '-'
%left '*' '/' '%'
%left FUNC_CALL

%start program

%%

program : statements { execute($1); };

statements : statement						{ $$ = $1; }
				 	 | statement statements { $$ = binaryOp('#', $1, $2); }
					 ;

statement : exp {  $$ = $1; }
					| PRINT PARANTHESIS_OPEN exp PARANTHESIS_CLOSE		{ $$ = unaryOp(PRINT, $3); }
					| WHILE PARANTHESIS_OPEN logic_exp PARANTHESIS_CLOSE statement { $$ = binaryOp(WHILE, $3, $5); }
					| WHILE PARANTHESIS_OPEN logic_exp PARANTHESIS_CLOSE CURLY_OPEN statements CURLY_CLOSE { $$ = binaryOp(WHILE, $3, $6); }
					| IF PARANTHESIS_OPEN exp PARANTHESIS_CLOSE statement { $$ = binaryOp(IF, $3, $5); }
					| IF PARANTHESIS_OPEN exp PARANTHESIS_CLOSE CURLY_OPEN statements CURLY_CLOSE { $$ = binaryOp(IF, $3, $6); }
					| IF PARANTHESIS_OPEN exp PARANTHESIS_CLOSE statement ELSE statement { $$ = tertiaryOp(IF, $3, $5, $7); }
					| IF PARANTHESIS_OPEN exp PARANTHESIS_CLOSE CURLY_OPEN statements CURLY_CLOSE ELSE CURLY_OPEN statements CURLY_CLOSE { $$ = tertiaryOp(IF, $3, $6, $10); }
					| FUNCTION IDENTIFIER CURLY_OPEN statements CURLY_CLOSE { updateFuncNode(execute(literal($2)), $4); $$ = NULL; }
					| IDENTIFIER FUNC_CALL { $$ = unaryOp('@', literal($1)); }
					| FPRINT PARANTHESIS_OPEN LITERAL ',' exp PARANTHESIS_CLOSE		{ $$ = binaryOp(FPRINT, literal($3), $5); }
    		  ;

exp : term {$$ = $1;}
		| logic_exp {$$ = $1;} 
		| assignment_exp {$$ = $1;} 
		| FREAD PARANTHESIS_OPEN LITERAL PARANTHESIS_CLOSE		{ $$ = unaryOp(FREAD, literal($3)); }
		;

assignment_exp : IDENTIFIER '=' exp { $$ = binaryOp('=', identifier($1), $3);  }
					 		 ;

term : term '+' term { $$ = binaryOp(O_ADD, $1, $3); }
		 | term '-' term { $$ = binaryOp(O_SUB, $1, $3); }
     | term '*' term { $$ = binaryOp(O_MUL, $1, $3); }
     | term '/' term { $$ = binaryOp(O_DIV, $1, $3); }
		 | term '%' term { $$ = binaryOp(O_MOD, $1, $3); }
     | '-' LITERAL { $$ = unaryOp(O_MINUS, literal($2)); }
     | '-' IDENTIFIER { $$ = unaryOp(O_MINUS, identifier($2)); }
     | PARANTHESIS_OPEN exp PARANTHESIS_CLOSE { $$ = $2; }
		 | logic_exp { $$ = $1; }
		 | LITERAL { $$ = literal($1); }
		 | IDENTIFIER { $$ = identifier($1); }
 		 ;

logic_exp : term IS_EQUAL term { $$ = binaryOp(O_IS_EQ, $1, $3); }
		 			| term NOT_EQUALS term { $$ = binaryOp(O_IS_NOT_EQ, $1, $3); }
		 			| term '&' term { $$ = binaryOp(O_AND, $1, $3); }
		 			| term '|' term { $$ = binaryOp(O_OR, $1, $3); }
		 			| term '>' term { $$ = binaryOp(O_IS_GREATER, $1, $3); }
		 			| term '<' term { $$ = binaryOp(O_IS_LESS, $1, $3); }
		 			| term GREATER_THAN_OR_EQUALS term { $$ = binaryOp(O_IS_GRATEREQ, $1, $3); }
		 			| term LESS_THAN_OR_EQUALS term { $$ = binaryOp(O_IS_LESSEQ, $1, $3); }
		 			| '!' term { $$ = unaryOp(O_NOT, $2); }
					;
%%

void updateVarNodeVal(char* id, char* val) {
	VarNode* node = Identifiers;
	if(node == NULL) {
		Identifiers = (VarNode*)malloc(sizeof(VarNode));
		Identifiers->id = (char*)malloc(strlen(id) + 1);
		strcpy(Identifiers->id, id);
		Identifiers->value = val;
		Identifiers->next = NULL;
		return;
	}

	while(node != NULL) {
		if(strcmp(node->id, id) == 0) {
			node->value = val;
			return;
		}
		node = node->next;
	}	

	VarNode* newVarNode;
	newVarNode = (VarNode*)malloc(sizeof(VarNode));
	newVarNode->id = (char*)malloc(strlen(id) + 1);
	strcpy(newVarNode->id, id);
	newVarNode->value = val;
	newVarNode->next = Identifiers;

	Identifiers = newVarNode;
}

char* getVarNodeVal(char* id) {
	VarNode* node = Identifiers;
	while(node != NULL) {
		if(strcmp(node->id, id) == 0) 
			return node->value;
		node=node->next;
	}	

	printerr("Variable not defined!", id);
	exit(EXIT_FAILURE);
}

VarNodeType getVarNodeType(char* id) {
	VarNode* node = Identifiers;
	while(node != NULL) {
		if(strcmp(node->id, id) == 0) 
			return node->type;
		node=node->next;
	}	

	printerr("Variable not defined!", id);
	exit(EXIT_FAILURE);
}

VarNodeType getValType(char* val) {
	switch(val[strlen(val) - 1]) 
	{
		case 'I': return T_INT;
		case 'D': return T_DOUBLE;
		case 'S': return T_STR;
	}
}

char* getRealVal(char* val) {
	char* value = (char*)malloc(strlen(val) + 1);
	strncpy(value, val, strlen(val) - 1);
	return value;
}

void updateFuncNode(char* id, Node* statements) {
	FuncNode* node = Functions;
	if(node == NULL) {
		Functions = (FuncNode*)malloc(sizeof(FuncNode));
		Functions->id = (char*)malloc(strlen(id) + 1);
		strcpy(Functions->id, id);
		Functions->statements = statements;
		Functions->next = NULL;

		return;
	}

	while(node != NULL) {
		if(strcmp(node->id, id) == 0) {
			node->statements = statements;
			return;
		}
		node = node->next;
	}	

	FuncNode* newFuncNode;
	newFuncNode = (FuncNode*)malloc(sizeof(FuncNode));
	newFuncNode->id = (char*)malloc(strlen(id) + 1);
	strcpy(newFuncNode->id, id);
	newFuncNode->statements = statements;
	newFuncNode->next = Functions;

	Functions = newFuncNode;
}

Node* getFuncNodeStatements(char* id) {
	FuncNode* node = Functions;
	while(node != NULL) {
		if(strcmp(node->id, id) == 0) 
			return node->statements;
		node=node->next;
	}	

	printerr("Function not defined!", id);
	exit(EXIT_FAILURE);
}

char* getOpResult(char* var1, char* var2, Operator op) {
	VarNodeType tvar1 = getValType(var1);
	VarNodeType tvar2 = getValType(var2);
	char* val1 = getRealVal(var1);
	char* val2 = getRealVal(var2);

	switch(op) {
		case O_ADD:
		{
			if((tvar1 == T_INT && tvar2 == T_DOUBLE) ||
				 (tvar1 == T_DOUBLE && tvar2 == T_INT) ||
				 (tvar1 == T_DOUBLE && tvar2 == T_DOUBLE)) 
			{
				double res = strtod(val1, NULL) + strtod(val2, NULL);
				return dResToVal(res);
			}
				 
			else if(tvar1 == T_INT && tvar2 == T_INT) 
			{
				int res = (int)strtod(val1, NULL) + (int)strtod(val2, NULL);
				return iResToVal(res, 0);
			}

			else if(tvar1 == T_STR && tvar2 == T_STR) 
			{
				char* res = (char*)malloc(strlen(val1) + strlen(val2) + 1);
				strcat(res, val1);
				strcat(res, val2);
				return sResToVal(res);
			}

			else if(tvar1 == T_STR && tvar2 == T_INT) 
			{
				char* val2Str = getRealVal(iResToVal((int)strtod(val2, NULL), 0));
				char* res = (char*)malloc(strlen(val1) + strlen(val2Str) + 1);
				strcat(res, val1);
				strcat(res, val2Str);
				return sResToVal(res);
			}

			else if(tvar1 == T_INT && tvar2 == T_STR) 
			{
				char* val1Str = getRealVal(iResToVal((int)strtod(val1, NULL), 0));
				char* res = (char*)malloc(strlen(val2) + strlen(val1Str) + 1);
				strcat(res, val1Str);
				strcat(res, val2);
				return sResToVal(res);
			}

			else if(tvar1 == T_DOUBLE && tvar2 == T_STR) 
			{
				char* val1Str = getRealVal(dResToVal(strtod(val1, NULL)));
				char* res = (char*)malloc(strlen(val2) + strlen(val1Str) + 1);
				strcat(res, val1Str);
				strcat(res, val2);
				return sResToVal(res);
			}

			else if(tvar1 == T_STR && tvar2 == T_DOUBLE) 
			{
				char* val2Str = getRealVal(dResToVal(strtod(val2, NULL)));
				char* res = (char*)malloc(strlen(val1) + strlen(val2Str) + 1);
				strcat(res, val1);
				strcat(res, val2Str);
				return sResToVal(res);
			}
		}
		case O_SUB:
		{
			if((tvar1 == T_INT && tvar2 == T_DOUBLE) ||
				 (tvar1 == T_DOUBLE && tvar2 == T_INT) ||
				 (tvar1 == T_DOUBLE && tvar2 == T_DOUBLE)) 
			{
				double res = strtod(val1, NULL) - strtod(val2, NULL);
				return dResToVal(res);
			}
				 
			else if(tvar1 == T_INT && tvar2 == T_INT) 
			{
				int res = (int)strtod(val1, NULL) - (int)strtod(val2, NULL);
				return iResToVal(res, 0);
			}
		}
		case O_MUL:
		{
			if((tvar1 == T_INT && tvar2 == T_DOUBLE) ||
				 (tvar1 == T_DOUBLE && tvar2 == T_INT) ||
				 (tvar1 == T_DOUBLE && tvar2 == T_DOUBLE)) 
			{
				double res = strtod(val1, NULL) * strtod(val2, NULL);
				return dResToVal(res);
			}
				 
			else if(tvar1 == T_INT && tvar2 == T_INT) 
			{
				int res = (int)strtod(val1, NULL) * (int)strtod(val2, NULL);
				return iResToVal(res, 0);
			}
		}
		case O_DIV:
		{
			if((tvar1 == T_INT && tvar2 == T_DOUBLE) ||
				 (tvar1 == T_DOUBLE && tvar2 == T_INT) ||
				 (tvar1 == T_DOUBLE && tvar2 == T_DOUBLE)) 
			{
				if(strtod(val2, NULL) == 0) {
					printerr("Division by zero!", "");
					exit(EXIT_FAILURE);
				}
				double res = strtod(val1, NULL) / strtod(val2, NULL);
				return dResToVal(res);
			}
				 
			else if(tvar1 == T_INT && tvar2 == T_INT) 
			{
				if((int)strtod(val2, NULL) == 0) {
					printerr("Division by zero!", "");
					exit(EXIT_FAILURE);
				}

				int res = (int)strtod(val1, NULL) / (int)strtod(val2, NULL);
				return iResToVal(res, 0);
			}
		}
		case O_MOD:
		{
			if(tvar1 == T_INT && tvar2 == T_INT) 
			{
				if((int)strtod(val2, NULL) == 0) {
					printerr("Division by zero!", var2);
					exit(EXIT_FAILURE);
				}

				int res = (int)strtod(val1, NULL) % (int)strtod(val2, NULL);
				return iResToVal(res, 0);
			}
			else 
			{
				char error[100];
				error[99] = '\0';
				sprintf(error, "Unsupported operator: %s", enumToStr(op));

				char detail[100];
				detail[99] = '\0';
				sprintf(detail, "for types: %s and %s", enumToStr(tvar1), enumToStr(tvar2));

				printerr(error, detail);
				exit(EXIT_FAILURE);
			}
		}
		case O_IS_EQ:
		{
			if((tvar1 == T_INT && tvar2 == T_DOUBLE) ||
				 (tvar1 == T_DOUBLE && tvar2 == T_INT) ||
				 (tvar1 == T_DOUBLE && tvar2 == T_DOUBLE) ||
				 (tvar1 == T_INT && tvar2 == T_INT)) 
			{
				return iResToVal(strcmp(val1, val2) == 0, 1);
			}

			else if(tvar1 == T_STR && tvar2 == T_STR) 
			{
				return iResToVal(strcmp(val1, val2) == 0, 1);
			}
		}
		case O_IS_NOT_EQ:
		{
			if((tvar1 == T_INT && tvar2 == T_DOUBLE) ||
				 (tvar1 == T_DOUBLE && tvar2 == T_INT) ||
				 (tvar1 == T_DOUBLE && tvar2 == T_DOUBLE) ||
				 (tvar1 == T_INT && tvar2 == T_INT)) 
			{
				return iResToVal(strcmp(val1, val2) != 0, 1);
			}

			else if(tvar1 == T_STR && tvar2 == T_STR) 
			{
				return iResToVal(strcmp(val1, val2) != 0, 1);
			}
		}
		case O_IS_GREATER:
		{
			if((tvar1 == T_INT && tvar2 == T_DOUBLE) ||
				 (tvar1 == T_DOUBLE && tvar2 == T_INT) ||
				 (tvar1 == T_DOUBLE && tvar2 == T_DOUBLE) ||
				 (tvar1 == T_INT && tvar2 == T_INT)) 
			{
				return iResToVal(strtod(val1, NULL) > strtod(val2, NULL), 1);
			}
		}
		case O_IS_GRATEREQ:
		{
			if((tvar1 == T_INT && tvar2 == T_DOUBLE) ||
				 (tvar1 == T_DOUBLE && tvar2 == T_INT) ||
				 (tvar1 == T_DOUBLE && tvar2 == T_DOUBLE) ||
				 (tvar1 == T_INT && tvar2 == T_INT)) 
			{
				return iResToVal(strtod(val1, NULL) >= strtod(val2, NULL), 1);
			}
		}
		case O_IS_LESS:
		{
			if((tvar1 == T_INT && tvar2 == T_DOUBLE) ||
				 (tvar1 == T_DOUBLE && tvar2 == T_INT) ||
				 (tvar1 == T_DOUBLE && tvar2 == T_DOUBLE) ||
				 (tvar1 == T_INT && tvar2 == T_INT)) 
			{
				return iResToVal(strtod(val1, NULL) < strtod(val2, NULL), 1);
			}
		}
		case O_IS_LESSEQ:
		{
			if((tvar1 == T_INT && tvar2 == T_DOUBLE) ||
				 (tvar1 == T_DOUBLE && tvar2 == T_INT) ||
				 (tvar1 == T_DOUBLE && tvar2 == T_DOUBLE) ||
				 (tvar1 == T_INT && tvar2 == T_INT)) 
			{
				return iResToVal(strtod(val1, NULL) <= strtod(val2, NULL), 1);
			}
		}
		case O_AND:
		{
			if(tvar1 == T_INT && tvar2 == T_INT) 
			{
				return iResToVal((int)strtod(val1, NULL) && (int)strtod(val2, NULL), 1);
			}
		}
		case O_OR:
		{
			if(tvar1 == T_INT && tvar2 == T_INT) 
			{
				return iResToVal((int)strtod(val1, NULL) || (int)strtod(val2, NULL), 1);
			}
		}
	}

	char error[100];
	error[99] = '\0';
	sprintf(error, "Unsupported operator: %s", enumToStr(op));

	char detail[100];
	detail[99] = '\0';
	sprintf(detail, "for types: %s and %s", enumToStr(tvar1), enumToStr(tvar2));

	printerr(error, detail);
	exit(EXIT_FAILURE);
}

char* getUnaryOpResult(char* var, Operator op) {
	VarNodeType tvar = getValType(var);
	char* val = getRealVal(var);

	switch(op)
	{
		case O_MINUS:
		{
			if(tvar == T_INT) 
			{
				return iResToVal(-(int)strtod(val, NULL), 0);
			}
			else if(tvar == T_DOUBLE) 
			{
				return dResToVal(-strtod(val, NULL));
			}
		}
		case O_NOT:
		{
			if(tvar == T_INT) 
			{
				return iResToVal(!(int)strtod(val, NULL), 1);
			}
		}
	}

	char error[100];
	error[99] = '\0';
	sprintf(error, "Unsupported operator: %s", enumToStr(op));

	char detail[100];
	detail[99] = '\0';
	sprintf(detail, "for type: %s", enumToStr(tvar));

	printerr(error, detail);
	exit(EXIT_FAILURE);
}

char* dResToVal(double res) {
	char* tmp = (char*)malloc(sizeof(char) * (20 + 1));
	sprintf(tmp, "%f", res);
	strcat(tmp, "D");

	char* result = (char*)malloc(strlen(tmp) + 1);
	strcpy(result, tmp);

	free(tmp);
	return result;
}

char* iResToVal(int res, int isBool) {
	if(isBool) {
		if(res > 0) return "1I";
		else return "0I";
	}

	char* tmp = (char*)malloc(sizeof(char) * (20 + 1));
	sprintf(tmp, "%d", res);
	strcat(tmp, "I");

	char* result = (char*)malloc(strlen(tmp) + 1);
	strcpy(result, tmp);

	free(tmp);
	return result;
}

char* sResToVal(char* res) {
	char* result = (char*)malloc(strlen(res) + 2);
	strcat(result, res);
	strcat(result, "S");

	return result;
}

Node* tertiaryOp(int opr, Node* n1, Node* n2, Node* n3) {
  Node* node;
	node = (Node*)malloc(sizeof(Node));

	node->type = NT_OPR;

	node->oprNode.operands[0] = n1;
	node->oprNode.operands[1] = n2;
	node->oprNode.operands[2] = n3;

	node->oprNode.operator = opr;
	node->oprNode.numOperands = 3;

	node->exec = 1;
  return node;
}

Node* binaryOp(int opr, Node* n1, Node* n2) {
  Node* node;
	node = (Node*)malloc(sizeof(Node));

	node->type = NT_OPR;

	node->oprNode.operands[0] = n1;
	node->oprNode.operands[1] = n2;

	node->oprNode.operator = opr;
	node->oprNode.numOperands = 2;

	node->exec = 1;
  return node;
}

Node* unaryOp(int opr, Node* n1) {
	Node* node;
	node = (Node*)malloc(sizeof(Node));

	node->type = NT_OPR;

	node->oprNode.operands[0] = n1;

	node->oprNode.operator = opr;
	node->oprNode.numOperands = 1;
	
	node->exec = 1;
  return node;
}

Node* identifier(char* id) {
	Node* node;
	node = (Node*)malloc(sizeof(Node));

	node->type = NT_ID;

	node->varNode.id = (char*)malloc(strlen(id) + 1);
	strcpy(node->varNode.id, id);

	node->exec = 1;
  return node;
}

Node* literal(char* val) {
	Node* node;
	node = (Node*)malloc(sizeof(Node));

	node->type = NT_LIT;

	node->varNode.value = (char*)malloc(strlen(val) + 1);
	strcpy(node->varNode.value, val);

	node->exec = 1;
  return node;
}

char* execute(Node* node) {
	if(node == NULL) return NULL;
	if(node->exec != 1) return NULL;

	switch(node->type)
	{
		case NT_ID: return getVarNodeVal(node->varNode.id);
		case NT_LIT: return node->varNode.value;
		case NT_OPR:
		{
			switch(node->oprNode.operator)
			{
				case '=': updateVarNodeVal(node->oprNode.operands[0]->varNode.id, execute(node->oprNode.operands[1])); 
					return getVarNodeVal(node->oprNode.operands[0]->varNode.id);
				
				case O_ADD: case O_SUB: case O_DIV: case O_MUL: case O_MOD:
				case O_IS_EQ: case O_IS_NOT_EQ: case O_IS_GREATER: case O_IS_LESS:
				case O_IS_LESSEQ: case O_IS_GRATEREQ: case O_AND: case O_OR:
					return getOpResult(execute(node->oprNode.operands[0]), execute(node->oprNode.operands[1]), node->oprNode.operator);

				case O_MINUS: case O_NOT:
					return getUnaryOpResult(execute(node->oprNode.operands[0]), node->oprNode.operator);

				case PRINT:
					printf("%s\n", getRealVal(execute(node->oprNode.operands[0])));
					return NULL;

				case '#':
					execute(node->oprNode.operands[0]);
					return execute(node->oprNode.operands[1]);

				case IF:
				{
					int condition;
					condition = (int)strtod(execute(node->oprNode.operands[0]), NULL);
					if(node->oprNode.numOperands == 2)
					{
						if(condition)
							execute(node->oprNode.operands[1]);
					}
					else if(node->oprNode.numOperands == 3)
					{
						if(condition)
							execute(node->oprNode.operands[1]);
						else
							execute(node->oprNode.operands[2]);
					}

					return NULL;
				}

				case WHILE:
				{
					int running; 
					running = (int)strtod(execute(node->oprNode.operands[0]), NULL);
					while(running) {
						running = (int)strtod(execute(node->oprNode.operands[0]), NULL);
						execute(node->oprNode.operands[1]);
					}
					return NULL;
				}

				case FREAD:
				{
					char* result = (char*)malloc(4096 * sizeof(char));
					char* buffer = (char*)malloc(1024 * sizeof(char));
					char* fileName = getRealVal(execute(node->oprNode.operands[0]));
					FILE* file = fopen (fileName, "r");

					if(!file) {
						printerr("File not found", fileName);
						exit(EXIT_FAILURE);
					}

					char c;
					int i = 0;
					while(fgets(buffer, 1024, file))
					{
						strcat(result, buffer);
					}

					fclose(file);
					return sResToVal(strdup(result));
				}

				case FPRINT:
				{
					char* fileName = getRealVal(execute(node->oprNode.operands[0]));
					char* outStr = getRealVal(execute(node->oprNode.operands[1]));
					FILE* file = fopen (fileName, "w");
					fputs(outStr, file);
					return "1I";
				}

				case '@':
				{
					Node* statements = getFuncNodeStatements(execute(node->oprNode.operands[0]));
					statements->exec = 1;
					execute(statements);
				}
			}
		}
	}
}

void yyerror (const char *s) {
	fprintf (stderr, "%s on line %d\n", s, yylineno);
} 

void printerr(const char* s, const char* detail) {
	fprintf (stderr, "%s : %s\n", s, detail);
}

char* enumToStr(int type) {
	switch(type)
	{
		case O_ADD: return "+";
		case O_SUB: case O_MINUS: return "-";
		case O_DIV: return "/";
		case O_MUL: return "*";
		case O_MOD: return "%";
		case O_IS_EQ: return "==";
		case O_IS_NOT_EQ: return "!=";
		case O_IS_GREATER: return ">";
		case O_IS_LESS: return "<";
		case O_IS_GRATEREQ: return ">=";
		case O_IS_LESSEQ: return "<=";
		case O_AND: return "&";
		case O_OR: return "|";
		case O_NOT: return "!";
		case T_DOUBLE: return "double";
		case T_INT: return "integer";
		case T_STR: return "string";
	}
}

int main (void) {
	return yyparse();
}


