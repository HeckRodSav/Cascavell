#include "syntaxTree.h"

TreeNode* newGenericNode()
{
    TreeNode * t = (TreeNode *) malloc(sizeof(TreeNode));
    if (t == NULL) fprintf(yyout, "Out of memory error at line %d\n", yylineno);
    else 
    {
        int i;
        for (i=0; i<SUBNODES; i++) t -> subNode[i] = NULL;
    }
    return t;
}

TreeNode* newStatementNode(StatementFamily memberType)
{
    TreeNode * tmp = newGenericNode();
    tmp -> family = _Statement;
    tmp -> member.statement =  memberType;
}

TreeNode* newExpressionNode(ExpressionFamily  memberType)
{
    TreeNode * tmp = newGenericNode();
    tmp -> family = _Expression;
    tmp -> member.expression =  memberType;
}

TreeNode* newDeclarationNode(DeclarationFamily  memberType)
{
    TreeNode * tmp = newGenericNode();
    tmp -> family = _Declaration;
    tmp -> member.declaration =  memberType;
}
