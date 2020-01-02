"Override python-mode's indentation settings
function! overrides#pymode(...)
	setlocal softtabstop=4
	setlocal tabstop=4
	setlocal shiftwidth=4
	setlocal expandtab
endfunction

function! overrides#javascript(...)
	setlocal softtabstop=2
	setlocal tabstop=2
	setlocal shiftwidth=2
	setlocal expandtab
endfunction
