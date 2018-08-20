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

---

  
Instalação e Uso
------

### Pré-requisitos

Para que seja possível compilar os analisadores é preciso ter o flex e o bison/YACC instalados. Para instalar:

<pre>$ sudo apt-get update
$ sudo apt-get install flex
$ sudo apt-get install bison</pre>

Para executar o compilador é necessário um compilador de C.

### Executando os analisadores

Para executar os analisadores, entre na pasta da versão desejada:
<pre>$ cd c.version</pre>

ou 

<pre>$ cd cpp.version</pre>

e digite:

<pre>$ make full</pre>

Esse comando utilizará o flex e o bison para gerar os analisadores, criará a versão executável e automaticamente irá acessar a pasta _exemplos_, gerando um arquivo log para cada um dos códigos de exemplo da linguagem.

---