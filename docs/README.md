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

A linguagem conta com operadores bit-a-bit, operadores lógicos e operadores aritméticos:

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