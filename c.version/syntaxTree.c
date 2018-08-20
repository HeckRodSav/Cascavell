#define MAXCHILDREN 4

typedef enum {Int, Double, Char, Bool} typeOfReturn;

typedef struct{
    functionNode *children[MAXCHILDREN];

    int intRetValue;
    double doubleRetValue;
    char charRetValue;
    bool boolRetValue;

} functionNode;
