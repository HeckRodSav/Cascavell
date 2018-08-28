#ifndef STACK_CASCAVELL
#define STACK_CASCAVELL

#define STACK_MAXSIZE 10

struct stack{
    const int maxSize;
    int stk[STACK_MAXSIZE];
    int size;
};

typedef struct stack Stack;

int stack_push(Stack *s, int num);
int stack_pop(Stack *s);
int stack_top(Stack *s);
int stack_size(Stack *s);
int stack_isEmpty(Stack *s);
int stack_isFull(Stack *s);


#endif