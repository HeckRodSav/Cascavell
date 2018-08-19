#define MAXSIZE 5

struct stack{

    int stk[MAXSIZE];
    int top;
};

typedef struct stack STACK;

STACK columnsStack;

void push (int num){

    if (columnsStack.top == (MAXSIZE - 1)){
        return;
    }
    else{
        columnsStack.top = columnsStack.top + 1;
        columnsStack.stk[columnsStack.top] = num;
    }

    return;
}

int pop (){

    if (columnsStack.top == - 1){

        return (columnsStack.top);
    }
    else{

        int num = columnsStack.stk[columnsStack.top];
        columnsStack.top = columnsStack.top - 1;

        return num;
    }
}

int top(){

    if (columnsStack.top == - 1){

        return (columnsStack.top);
    }
    else{

        return columnsStack.stk[columnsStack.top];
    }
}