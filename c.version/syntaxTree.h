#ifndef SYNTAX_TREE_CASCAVELL
#define SYNTAX_TREE_CASCAVELL

#include <stdlib.h>
#include <stdio.h>

#define SUBNODES 3

extern FILE* yyout;
extern int yylineno;

typedef enum {_Statement, _Expression, _Declaration} nodeClass;
typedef enum {_If, _Else, _While, _Assign, _Return} StatementFamily;
typedef enum {_Logic, _Equation} ExpressionFamily;
typedef enum {_Variable, _Function} DeclarationFamily;

typedef struct treeNode{
    nodeClass family;
    union{
        StatementFamily statement;
        ExpressionFamily expression;
        DeclarationFamily declaration;
    } member;
    struct treeNode * subNode[SUBNODES];
} TreeNode;

TreeNode* newGenericNode();

TreeNode* newStatementNode(StatementFamily memberType);
TreeNode* newExpressionNode(ExpressionFamily  memberType);
TreeNode* newDeclarationNode(DeclarationFamily  memberType);

#endif