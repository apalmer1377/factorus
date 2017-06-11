" =============================================================================
" File: factorus.vim
" Description: Vim plugin for refactoring
"
" =============================================================================


command! -nargs=0 Factorus              call line('.')
command! -nargs=1 FactorusClass         call factorus#refactorClass(<f-args>)
command! -nargs=0 FactorusCurrentTag    call factorus#gotoTag(0)
command! -nargs=1 FactorusMethod        call factorus#refactorMethod(<f-args>)
command! -nargs=1 FactorusField         call factorus#refactorField(<f-args>) 
command! -nargs=0 FactorusGetSet        call factorus#encapsulateField()
