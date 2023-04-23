%{
#define MAX_LINE_LENGTH 256
#define HT_LENGTH 10
#define LIST(s) strcat(buf,s)
#define tokenDel(t) {LIST(t); printf("<%s>\n",t);} 
#define tokenKeyword(t) {LIST(t); printf("<%s>\n", uppercase(t));} 
#define tokenOperator(t) {LIST(t); printf("<%s>\n", t);} 
#define tokenIdent(t) {LIST(t); printf("<identifier:%s>\n", t);} 
#define tokenNum(t) {LIST(t); printf("<num:%s>\n", t);}
#include<stdio.h>
#include<string.h>
#include<ctype.h>

struct ArrString {
    char** strList;
    size_t capacity;
    size_t size;
};

struct ArrString arr;
char* uppercase(char* s);
int linenum = 1;
char buf[MAX_LINE_LENGTH];
void create();
int lookup(char* s);
int insert(char* s);
void dump();
%}

DIGITS [0-9]+
LETTER [a-zA-Z]
ID {LETTER}({LETTER}|{DIGITS})*

%Start com multiCom string stringOne stringTwo stringThree
%%


\% {
	LIST(yytext);
	BEGIN com;}
	
<com>.* {
	LIST(yytext); 
	BEGIN 0;}
	
<multiCom>.*\%\} {
	char* lastline = yytext;
	lastline[strlen(lastline)-2] = '%';
	lastline[strlen(lastline)-1] = '}';
	LIST(lastline);
	BEGIN 0; }
	
<multiCom>.* {
	LIST(yytext);
	BEGIN multiCom; }

\{\% {
	LIST(yytext);
	BEGIN multiCom; }

<stringOne>\"\" {
	LIST(yytext);
	printf("\"");
	BEGIN string; }
	
<stringOne>\" {
	LIST(yytext);
	printf(">\n");
	BEGIN 0; }

\" {
	LIST(yytext);
	printf("<string:");
	BEGIN string; }
	
<string>[^\"]*/\" {
	LIST(yytext);
	printf("%s", yytext);
	BEGIN stringOne; }
	

{DIGITS}(\.{DIGITS})? {
	// printf("digit\n");
	tokenNum(yytext); } 

\.|\,|\:|\;|\(|\)|\[|\]|\{|\} {
	// printf("delimiter");
	tokenDel(yytext);}

\+|-|\*|\/|mod|:=|<|<=|>=|>|=|not=|and|or|not {
	// printf("operator");
	tokenOperator(yytext);}
	
array|begin|bool|char|const|decreasing|default|do|else|end|exit|false|for|function|get|if|int|loop|of|put|procedure|real|result|return|skip|string|then|true|var|when|then {
	// printf("keyword");
	tokenKeyword(yytext); }
	
{ID} {
	// printf("id\n");
	tokenIdent(yytext);
	int idIndex = lookup(yytext);
	if(idIndex == -1) {
		idIndex = insert(yytext);
		if(idIndex == -1) {
			printf("Fail to insert new identifier.");
		}
	}
	printf("index: %d\n", idIndex); } 
   

\n {
	LIST(yytext);
	printf("%d: %s", linenum, buf);
	linenum++; 
	buf[0] = '\0';}


[ \t]* {LIST(yytext);}


%%

char* append(char* s, char c) {
	size_t size = strlen(s);
	char* newStr = malloc(size + 2);
	strcpy(newStr, s);
	newStr[size] = c;
	newStr[size + 1] = '\0';
	
	return newStr;
}

char* uppercase(char* s) {
	size_t size = strlen(s);
	char* newStr = malloc(size+1);
	for(int i = 0; i < (int) size; i++) {
		newStr[i] = toupper(s[i]);
	}
	newStr[size] = '\0';
	
	return newStr;
}

void create() {
	// initiate hashtable
	arr.capacity = 10;
    	arr.size = 0;
	arr.strList = malloc(arr.capacity * sizeof(char*));
	if(arr.strList == NULL) {
        printf("Unable to allocate memory :(\n");
        return;
    }
}

int lookup(char* s) {
	for(int i = 0; i < arr.size; i++) {
		if(strcmp(arr.strList[i], s) == 0) {
			return i;
		}
	}
	
	return -1;
}

int insert(char* s) {
	if(arr.size == arr.capacity) {
        arr.capacity *= 2;
        arr.strList = realloc(arr.strList, arr.capacity * sizeof(char*));

        if(arr.strList == NULL) {
            printf("Unable to reallocate memory :(\n");
            return -1;
        }
    }
	arr.strList[arr.size] = malloc(strlen(s) + 1);
	strcpy(arr.strList[arr.size], s);
	arr.size++;
	
	return arr.size - 1;
}

void dump() {
	printf("\nSymbol Table:\n");
	for(int i = 0; i < arr.size; i++) {
		printf("%d %s\n", i, arr.strList[i]);
	}
	printf("Dumping all identifiers..\n");
	free(arr.strList);
}


int yywrap(void){
	return 1;
}

int main(int argc, char** argv)
{
	// Initiate symbol table
	// create();
	
	// The function that starts the analysis
	// yylex();
	
	// Dump symbol table
	// dump();
	
	if (argc > 0) {
        yyin = fopen(argv[1], "r");
    } else {
        yyin = stdin;
    }
    
    create();
	yylex();
	dump();
	
	return 0;
}
