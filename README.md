# Factorus: automated refactoring in Vim

Factorus is a Vim plugin for automated refactoring. It provides 
renaming of methods and classes, encapsulation of variables, 
and even method extraction, with a few very intutitive commands.

## Features

The following table shows which features Factorus supports for
which languages:

|              | Add Parameter|Encapsulate Variable|Extract Method|Rename Argument|Rename Class|Rename Method |Rename Field|
|:------------:|:------------:|:------------------:|:------------:|:-------------:|:----------:|:------------:|:----------:|
|     Java     |   %#10003;   |      %#10003;      |   %#10003;   |    %#10003;   |  %#10003;  |   %#10003;   |  %#10003;  |
|    Python    |   %#10003;   |      %#10007;      |   %#10007;   |    %#10003;   |  %#10003;  |   %#10003;   |  %#10007;  |


## Installation

Use a plugin manager like [pathogen](https://github.com/tpope/vim-pathogen) or [vim-plug](https://github.com/junegunn/vim-plug), or just clone the repository into your `'runtimepath'`. 

## Dependencies

[Vim 8.0](http://www.vim.org/)
