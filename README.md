# Factorus: automated refactoring in Vim

Factorus is a Vim plugin for automated refactoring. It provides 
renaming of methods and classes, encapsulation of variables, 
and even method extraction, with a few very intutitive commands.

## Features

The following table shows which features Factorus supports for
which languages:

|              |Add  Parameter|Encapsulate Variable|Extract Method|Rename  Argument|Rename Class|Rename Method |Rename Field|
|:------------:|:------------:|:------------------:|:------------:|:-------------: |:----------:|:------------:|:----------:|
|     Java     |   &#10003;   |      &#10003;      |   &#10003;   |    &#10003;    |  &#10003;  |   &#10003;   |  &#10003;  |
|    Python    |   &#10003;   |         N/A        |   &#10003;   |    &#10003;    |  &#10003;  |   &#10003;   |     N/A    |
|      C       |   &#10003;   |         N/A        |   &#10003;   |    &#10003;    |    N/A     |   &#10003;   |  &#10003;  |  

Additionally, for C/C++, Factorus supports the following refactorings:

|              |Rename Type|Rename Macro|Rename Namespace|
|:------------:|:---------:|:----------:|:--------------:|
|      C       |  &#10003; |  &#10003;  |      N/A       |

Factorus also has commands for reverting changes and rebuilding projects, for stability and sanity testing.

## Installation

There are many ways to install Factorus. You can:

+ Use a plugin manager like [pathogen](https://github.com/tpope/vim-pathogen) or [vim-plug](https://github.com/junegunn/vim-plug) (Recommended), 
+ Clone the repository into your `'runtimepath'`, or
+ Download the tar file from [vim.org](http://www.vim.org/) and extract it into your `'runtimepath'`.

## Dependencies

[Vim 7.0](http://www.vim.org/)
