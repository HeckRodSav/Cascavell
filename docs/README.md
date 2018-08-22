Cascavell
======

Cascavell é um conceito de linguagem de programação baseada em C que usa espaços para definir blocos de código. Desenvolvida utilizando o YACC/Bison e o flex.

<p align="center">
  <img alt="Logo Cascavell" src="https://raw.githubusercontent.com/HeckRodSav/Cascavell/master/docs/Cascavell_Logo.png" width="500px">
</p>

---


Sobre
------

Cascavell é um conceito de linguagem de programação desenvolvido como projeto final da disciplina de Compiladores, no curso de Bacharelado em Ciência da Computação na Universidade Federal do ABC.

A proposta da linguagem é utilizar a indentação como delimitadores de blocos de código e omitir os '**;**', característicos da linguagem C. Trata-se de uma implementação da linguagem C com menos recursos, inspirada pela linguagem Python.

A extensão dos arquivos da linguagem é **.cll**.

Neste repositório se encontram as especificações do analisador léxico e sintático para a linguagem Cascavell.

### Símbolos e palavras reservadas

A linguagem conta com operadores bit-a-bit, operadores lógicos e operadores aritméticos. Os operadores tem sua precedência definida baseados na linguagem C:

|Símbolo|Descrição|Símbolo|Descrição|
|:-----:|:--------|:-----:|:--------|
|==|Comparação lógica de igualdade|%|Resto da divisão de inteiros|
|!=|Comparação lógica de desigualdade|\||Ou lógico bit-a-bit|
|<=|Comparação lógica|&|E lógico bit-a-bit|
|>=|Comparação lógica|,|separador|
|=|Atribuição|:|Separador de if-else do operador ternário|
|<|Comparação lógica|?|Operador ternário|
|>|Comparação lógica|!|Negação lógica|
|+|Soma (real ou inteiro)|(|Abre parênteses|
|-|Subtração (real ou inteiro)|)|Fecha parênteses|
|*|Multiplicação (real ou inteiro)|[|Abre colchete|
|/|Divisão (real ou inteiro)|]|Fecha colchete|
|^|XOR lógico bit-a-bit|{|Abre chave|
|~|Negação lógica bit-a-bit|}|Fecha chave|


|Nível de precedência|Operador|Grupo|Descrição|
|:------------------:|:------:|:---:|:--------|
| 1  | ( )  | Lógico | Precedencia preferencial |
| 2  | !    | Lógico | Negação lógica |
| 2  | ~    | Bit-a-bit | Negação bit-a-bit |
| 3  | *    | Aritmético | Multiplicação |
| 3  | /    | Aritmético | Divisão |
| 3  | %    | Aritmético | Resto da divisão |
| 4  | +    | Aritmético | Soma |
| 4  | -    | Aritmético | Subtração |
| 5  | >=   | Lógico | Relação de ordem |
| 5  | <=   | Lógico | Relação de ordem |
| 5  | >    | Lógico | Relação de ordem |
| 5  | <    | Lógico | Relação de ordem |
| 6  | !=   | Lógico | Comparação de desigualdade |
| 6  | ==   | Lógico | Comparação de igualdade |
| 7  | &    | Bit-a-bit | AND bit-a-bit |
| 8  | ^    | Bit-a-bit | XOR bit-a-bit |
| 9  | \|   | Bit-a-bit | OR bit-a-bit |
| 10 | &&   | Lógico | AND lógico |
| 11 | \|\| | Lógico | OR lógico |
| 12 | ?:   | Aritmético | Operador de atribuição condicional (ternário) |
| 13 | =    | Aritmético | Atribuição |
| 14 | ,    | | |

Onde o nível de precedência vai de 1 a 14, 1 sendo a maior precedência possível.

As palavras reservadas são utilizadas para definir tipos de variáveis e funções e realizar controle do fluxo do programa:

|Palavra reservada|Descrição|
|:---------------:|:--------|
|void|Tipo de variável/retorno nulo|
|int|Tipo de variável numérica inteira|
|double|Tipo de variável numérica real|
|char|Tipo de variável caractere|
|bool|Tipo de variável lógica booleana|
|if|Controle de fluxo condicional que executa o bloco indentado abaixo caso a condição seja verdadeira|
|else|Controle de fluxo condicional que executa o bloco indentado caso o if que o antecede tenha sido falso|
|while|Laço de repetição que executa o bloco indentado enquanto a condição for verdadeira|
|return|Instrução de retorno de valor para uma função|
|end|Delimitador de fim de bloco indentado|

### Sintáxe da linguagem

A linguagem requer o uso de parênteses caso precise de aninhamento de operadores ternários.

Funções devem ter uma linha em branco entre suas definições.

---

  
Instalação e Uso
------

### Pré-requisitos

Para que seja possível compilar os analisadores é preciso ter o flex e o bison/YACC instalados. Para instalar:

```console
$ sudo apt-get update
$ sudo apt-get install flex
$ sudo apt-get install bison
```

Para executar o compilador é necessário um compilador de C.

### Executando os analisadores

Para executar os analisadores, entre na pasta da versão desejada:

```console
$ cd c.version
```

ou 

```console
$ cd cpp.version
```

e digite:

```console
$ make full
```

Esse comando utilizará o flex e o bison para gerar os analisadores, criará a versão executável e automaticamente irá acessar a pasta _exemplos_, gerando um arquivo log para cada um dos códigos de exemplo da linguagem.

---