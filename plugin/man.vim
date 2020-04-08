" Vim plugin for using Vim as manpager.
" Maintainer: Baltazár Radics <baltazar.radics@gmail.com>
" Last Change: 2020 Mar 12

command! -nargs=0 MANPAGER call man#pager()
command! -nargs=* -count=0 Man call man#man(<q-mods>, <count>, <q-args>)
set keywordprg=:Man

" vim: set sw=2 ts=2 noet:
