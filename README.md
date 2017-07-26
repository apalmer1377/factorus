# Factorus: automated refactoring in Vim

Factorus is a Vim plugin for automated refactoring. It provides 
renaming of methods and classes, encapsulation of variables, 
and even method extraction, with a few very intutitive commands.

## Features

The following table shows which features Factorus supports for
which languages:

|              |Add  Parameter|Encapsulate Variable|Extract Method(Automated)|Extract Method (Manual)|Rename  Argument|Rename Class|Rename Method |Rename Field|
|:------------:|:------------:|:------------------:|:-----------------------:|:---------------------:|:--------------:|:----------:|:------------:|:----------:|
|     Java     |   &#10003;   |      &#10003;      |         &#10003;        |        &#10003;       |    &#10003;    |  &#10003;  |   &#10003;   |  &#10003;  |
|    Python    |   &#10003;   |         N/A        |         &#10003;        |        &#10003;       |    &#10003;    |  &#10003;  |   &#10003;   |     N/A    |
|      C       |   &#10003;   |         N/A        |         &#10003;        |        &#10003;       |    &#10003;    |    N/A     |   &#10003;   |  &#10003;  |

Additionally, for C/C++, Factorus supports the following refactorings:

|              |Rename Type|Rename Macro|Rename Namespace|
|:------------:|:---------:|:----------:|:--------------:|
|      C       |  &#10003; |  &#10003;  |      N/A       |

Factorus also has commands for reverting changes and rebuilding projects, for stability and sanity testing.

## Examples

### Rename Class
![renameClass](https://raw.githubusercontent.com/apalmer1377/factorus/language-upgrade/media/renameclass.gif)

### Rename Field
![renameField](https://raw.githubusercontent.com/apalmer1377/factorus/language-upgrade/media/renamefield.gif)

### Rename Method
![renameMethod](https://raw.githubusercontent.com/apalmer1377/factorus/language-upgrade/media/renamemethod.gif)

### Rename Arg
![renameArg](https://raw.githubusercontent.com/apalmer1377/factorus/language-upgrade/media/renamearg.gif)

### Add Parameter
![addParam](https://raw.githubusercontent.com/apalmer1377/factorus/language-upgrade/media/addparam.gif)

### Encapsulate Field
![encapsulateField](https://raw.githubusercontent.com/apalmer1377/factorus/language-upgrade/media/encapsulate.gif)

### Extract Method
Factorus provides two functions for method extraction.  The first, FExtractMethod, automatically finds a block
of code that can be safely extracted:

![extractMethod](https://raw.githubusercontent.com/apalmer1377/factorus/language-upgrade/media/extract.gif)

If you prefer to manually extract a block of code, however, FManualExtract allows you to do that:

![manualExtractMethod](https://raw.githubusercontent.com/apalmer1377/factorus/language-upgrade/media/manualextract.gif)

## Installation

There are many ways to install Factorus. You can:

+ Use a plugin manager like [pathogen](https://github.com/tpope/vim-pathogen) or [vim-plug](https://github.com/junegunn/vim-plug) (Recommended), 
+ Clone the repository into your `'runtimepath'`, or
+ Download the tar file from [vim.org](http://www.vim.org/) and extract it into your `'runtimepath'`.

## Dependencies

[Vim 7.0](http://www.vim.org/)
