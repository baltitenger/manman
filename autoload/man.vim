" Vim plugin for using Vim as manpager.
" Maintainer: Baltazár Radics <baltazar.radics@gmail.com>
" Last Change: 2020 Mar 12

let s:cpo_save = &cpo
set cpo-=C

let s:sect_arg = ''
let s:where_arg = '-w'
try
	if !has('win32') && $OSTYPE !~ 'cygwin\|linux' && system('uname -s') =~ 'SunOS' && system('uname -r') =~ '^5'
		let s:sect_arg = '-s'
		let s:where_arg = '-l'
	endif
catch /E145:/
	" Ignore the error in restricted mode
endtry


function man#pager() abort
	if len($MAN_PN) " reading a man page
		execute 'silent file' $MAN_PN
		call man#format()
	elseif match(getline(1), '^Help on .*:$') == 0
		execute 'silent file' getline(1)
		normal Go
		call man#format()
	endif
endfunction

function man#man(mods, sect, page = '') abort
	if a:page != ''
		let str = a:page
	elseif !a:sect && &ft == 'man'
		let str = expand('<cWORD>')
	else
		let str = expand('<cword>')
	endif
	let page = substitute(str, '^(\?\([^(]\+\).*$', '\1', '')
	if a:sect
		let sect = a:sect
	else
		let sect = substitute(str, '^(\?[^(]\+\%((\([^)]*\))\)\?.*$', '\1', '')
	endif

	let name = page..'('..sect..')'
	if !bufexists(name)
		let sect = man#where(page, sect)
		if sect == ''
			echo 'No manual entry for '..page..'.'
			return
		endif
		let name = page..'('..sect..')'
	endif

	if a:mods != '' " use mods if given
		let pos = [bufnr('%'), line('.'), col('.')]
		let open_cmd = a:mods..' new'
	else " try to find existing man buffer
		let firstwin = winnr()
		while &filetype != 'man'
			normal! W
			if winnr() == firstwin
				break
			endif
		endwhile
		let pos = [bufnr('%'), line('.'), col('.')]
		if &filetype == 'man'
			let open_cmd = 'edit'
		elseif exists('g:ft_man_open_mode')
			let open_cmd =  g:ft_man_open_mode..' new'
		else
			let open_cmd = 'new'
		endif
	endif
	execute 'silent' open_cmd name

	call settagstack(win_getid(), {'items': [{
	\		'bufnr': bufnr('%'),
	\		'from': pos,
	\		'tagname': name,
	\	}]}, 'a')

	if line('$') == 1
		silent execute 'read !MANWIDTH='..winwidth(0)..' MAN_KEEP_FORMATTING=1 man '..man#cmd_arg(page, sect)
		normal! ggdd
		call man#format()
	endif
endfunction

function man#format()
	call man#ctrlh()
	nnoremap <silent> <buffer> <nowait> q :lclose<CR>:q<CR>
	setlocal buftype=nofile noswapfile nobuflisted ft=man
	setlocal bufhidden=hide nomodifiable nomodified
	setlocal keywordprg=:Man iskeyword+=(,)
endfunction

function man#cmd_arg(page, sect = '')
	if a:sect == ''
		return a:page
	else
		return s:sect_arg..' '..a:sect..' '..a:page
	endif
endfunc

function man#where(page, sect = '') abort
	let path = system('man '..s:where_arg..' '..man#cmd_arg(a:page, a:sect))
	if v:shell_error
		if a:sect == '' || (exists('g:ft_man_no_sect_fallback') && g:ft_man_no_sect_fallback)
			return ''
		endif
		let path = system('man '..s:where_arg..' '..man#cmd_arg(a:page))
		if v:shell_error
			return ''
		endif
	endif
	return substitute(path, '^/.*/\M'..a:page..'\m\.\([^.]*\)\%(\..*\)\?$', '\1', '')
endfunction

" parses man's ^H sequences to highlight groups and deletes them
function man#ctrlh() abort
	call clearmatches()
	let lc = line('$')
	let l = 1
	call prop_type_add('manUnderline', #{ bufnr: bufnr(), highlight: 'manUnderline', combine: v:true })
	call prop_type_add('manBold', #{ bufnr: bufnr(), highlight: 'manBold', combine: v:true })
	while l <= lc
		let processed = 0
		while 1
			let [m, start, end] = matchstrpos(getline(l), '\%(_.\%(\%(_.\)\|\s\)*\)\|\%(\(.\)\1\%(\%(\(.\)\2\)\|\s\)*\)', processed)
			if start == -1
				break
			endif
			if m[matchend(m, '^\%(__\)*')] == '_'
				call prop_add(l, start+1, #{ end_col: end+1, type: 'manUnderline' })
			else
				call prop_add(l, start+1, #{ end_col: end+1, type: 'manBold' })
			endif
			let processed = end
		endwhile
		let l = l + 1
	endwhile
	silent! keepjumps keeppatterns %s/.//ge
	silent! keepjumps normal gg
endfunction

let &cpo = s:cpo_save
unlet s:cpo_save

" vim: set sw=2 ts=2 noet:
