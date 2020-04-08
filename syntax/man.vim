" Vim syntax file
" Language: Man page
" Maintainer: Baltazár Radics <baltazar.radics@gmail.com>
" Last Change: 2020 Apr 08

" quit when a syntax file was already loaded
if exists("b:current_syntax")
	finish
endif

" Get the CTRL-H syntax to handle backspaced text
runtime! syntax/ctrlh.vim

syn case ignore
syn match manReference       '\f\+([1-9][a-z]*)'
syn match manTitle           '\%^.*$' display
syn match manFooter          '^.*\%$' display 
syn match manSectionHeading  '^[a-z][a-z -]*[a-z]$'
syn match manSubHeading      '^\s\{3\}[a-z][a-z -]*[a-z]$'
syn match manOptionDesc      '[ 	[|]\zs[+-][a-z0-9-]\+'
syn match manLongOptionDesc  '[ 	[|]\zs--[a-z0-9-]\S*'

if bufname() =~ '^.*([23].*)$'
	syntax include @c $VIMRUNTIME/syntax/c.vim
	syn match manCFuncDefinition  display '\<\h\w*\>\s*('me=e-1 contained
	syn region manSynopsis start='^SYNOPSIS'hs=s+8 end='^\u\+\s*$'me=e-12 keepend contains=manSectionHeading,@c,manCFuncDefinition
endif

" Define the default highlighting.
" Only when an item doesn't have highlighting yet

hi def link manTitle           Title
hi def link manFooter          manTitle
hi def link manSectionHeading  Statement
hi def link manOptionDesc      Constant
hi def link manLongOptionDesc  Constant
hi def link manReference       PreProc
hi def link manSubHeading      Function
hi def link manCFuncDefinition Function
hi def manUnderline            cterm=underline gui=underline
hi def manBold                 cterm=bold gui=bold      

let b:current_syntax = "man"

" vim: ts=2 sw=0 noet
