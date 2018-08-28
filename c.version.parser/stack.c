#include "stack.h"

int stack_push(Stack *s, int num)
{
    if (s->size == STACK_MAXSIZE) return 0;
    (s->stk)[(s->size)++] = num;
    return 1;
}

int stack_pop(Stack *s)
{
    if ((s->size) == 0) return 0;
    // int num = (s->stk)[(s->head)];
    (s->size)--;
    return 1;
}

int stack_top(Stack *s)
{
    if ((s->size) == 0) return -1;
    return (s->stk)[(s->size)-1];
}

int stack_size(Stack *s)
{
    return s->size;
}

int stack_isEmpty(Stack *s)
{
    return s->size == 0;
}

int stack_isFull(Stack *s)
{
    return s->size == STACK_MAXSIZE;
}

