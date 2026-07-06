" Autoload compatibility shim for Neovim v0.12+ spell system.
" This file restores the legacy spellfile#WritableSpellDir() function
" for backward compatibility with Vim script plugins like psliwka/vim-dirtytalk.

function! spellfile#WritableSpellDir() abort
  let l:dir = stdpath('data') . '/site/spell'
  if !isdirectory(l:dir)
    call mkdir(l:dir, 'p')
  endif
  return l:dir
endfunction
