{
  neovim,
  ripgrep,
  vimPlugins,
}:
neovim.override {
  vimAlias = true;
  viAlias = true;
  withNodeJs = true;
  configure = {
    customRC = ''
      packloadall
      packadd termdebug
      " TextEdit might fail if hidden is not set.
      set hidden

      " Clipboard should work with X selections/clipboard
      set clipboard+=unnamedplus

      " for a sane search feature
      set ignorecase
      set smartcase
      nnoremap <nowait><silent> <C-C> :noh<CR>

      " Some servers have issues with backup files, see #649.
      set nobackup
      set nowritebackup

      " sane search
      set ignorecase
      set smartcase

      " Give more space for displaying messages.
      set cmdheight=2

      " Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
      " delays and poor user experience.
      set updatetime=300

      " Don't pass messages to |ins-completion-menu|.
      set shortmess+=c

      " Always show the signcolumn, otherwise it would shift the text each time
      " diagnostics appear/become resolved.
      set signcolumn=yes

      set termguicolors
      set diffopt=vertical,filler
      " colorscheme base16-classic-light
      colorscheme PaperColor
      let g:airline_theme='base16_default_dark'
      " hack, but all the other stuff didn't work
      autocmd VimEnter * AirlineTheme base16_default_dark
      set list
      set listchars=tab:>-
      set expandtab
      set shiftwidth=2
      set softtabstop=2
      set tabstop=2

      " denite configuration
      call denite#custom#var('file/rec', 'command', ['${ripgrep}/bin/rg', '--files', '--glob', '!.git'])

      call denite#custom#var('grep', 'command', ['${ripgrep}/bin/rg'])
      call denite#custom#var('grep', 'default_opts',
      \ ['-i', '--vimgrep', '--no-heading'])
      call denite#custom#var('grep', 'recursive_opts', [])
      call denite#custom#var('grep', 'pattern_opt', ['--regexp'])
      call denite#custom#var('grep', 'separator', ['--'])
      call denite#custom#var('grep', 'final_opts', [])
      call denite#custom#option('default', 'prompt', 'λ')


      nmap <leader>p :Denite -start-filter file/rec<CR>
      nmap <leader>b :Denite buffer<CR>
      nnoremap <leader>g :Denite grep<CR>
      nnoremap <leader>/ :DeniteCursorWord grep<CR>

      augroup mygroup2
      autocmd!
      autocmd FileType denite nnoremap <silent><buffer><expr> <CR>  denite#do_map('do_action')
      autocmd FileType denite nnoremap <silent><buffer><expr> d     denite#do_map('do_action', 'delete')
      autocmd FileType denite nnoremap <silent><buffer><expr> p     denite#do_map('do_action', 'preview')
      autocmd FileType denite nnoremap <silent><buffer><expr> <C-v> denite#do_map('do_action', 'vsplit')
      autocmd FileType denite nnoremap <silent><buffer><expr> <C-x> denite#do_map('do_action', 'split')
      autocmd FileType denite nnoremap <silent><buffer><expr> <Esc> denite#do_map('quit')
      autocmd FileType denite nnoremap <silent><buffer><expr> i     denite#do_map('open_filter_buffer')
      autocmd FileType denite nnoremap <silent><buffer><expr> <Space> denite#do_map('toggle_select').'j'
      autocmd FileType denite-filter imap <silent><buffer> <Esc> <Plug>(denite_filter_quit)
      augroup END

      " 1 - true
      " 0 - false
      let g:enable_treefmt = 1

      function CallTreeFmt()
        silent !clear
        if g:enable_treefmt && executable('treefmt')
          let command = 'treefmt --quiet --stdin ' . expand('%')
          let formatted_content = systemlist(command, getbufline("%",0,"$"))
          if v:shell_error ==? 0
            let cursor_pos = getcurpos()
            execute '%!' . command
            call setpos('.', cursor_pos)
          else
            echom ("Failed to format buffer: " . expand("%"))
          endif
        endif
      endfunction

      augroup mygroup3
      autocmd!
      autocmd BufWritePre * :call CallTreeFmt()
      augroup END

      set makeprg=cabal\ build\ --disable-optimization
      " mark undefined, error in error color
      syntax keyword indivError undefined error
      highlight link indivError Error
      augroup mygroup4
      autocmd!
      autocmd FileType haskell syntax keyword indivError undefined error
      augroup END

      """"""""""""""""""""""""""""""""""""""""""""""""
      " COC Config
      """"""""""""""""""""""""""""""""""""""""""""""""

      " Trigger completion on Ctrl+Space
      inoremap <silent><expr> <c-space> coc#refresh()

      " Use <CR> to confirm completion
      inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<CR>"

      " Set the coc-config
      call coc#config('languageserver', {
              \  "haskell": {
              \    "command": "haskell-language-server",
              \    "args": ["--lsp"],
              \    "rootPatterns": [ "*.cabal", ],
              \    "filetypes": [ "hs", "lhs", "haskell" ],
              \  },
              \  "nix": {
              \    "command": "rnix-lsp",
              \    "filetypes": [ "nix" ],
              \  },
              \  "erlang": {
              \    "command": "erlang_ls",
              \    "rootPatterns": [ "rebar.config", ],
              \    "filetypes": [ "erlang" ],
              \  },
              \})
      call coc#config('coc.preferences.currentFunctionSymbolAutoUpdate', 'true')
      call coc#config('rust-analyzer', {
              \ "server": {"path":  "rust-analyzer"},
              \ "checkOnSave": {"command": "clippy"},
              \ "updates": {"checkOnStartup": 'false' }
              \})

      nmap <leader>1 :call coc#config('diagnostic.messageTarget', 'echo')<CR>
      nmap <leader>2 :call coc#config('diagnostic.messageTarget', 'float')<CR>

      " Use `[g` and `]g` to navigate diagnostics
      nmap <silent> [g <Plug>(coc-diagnostic-prev)
      nmap <silent> ]g <Plug>(coc-diagnostic-next)

      " GoTo code navigation.
      nmap <silent> gd <Plug>(coc-definition)
      nmap <silent> gy <Plug>(coc-type-definition)
      nmap <silent> gi <Plug>(coc-implementation)
      nmap <silent> gr <Plug>(coc-references)
      nmap <silent> gc <Plug>(coc-declaration)

      " Use K to show documentation in preview window.
      nnoremap <silent> K :call <SID>show_documentation()<CR>

      function! s:show_documentation()
        if (index(['vim','help'], &filetype) >= 0)
          execute 'h '.expand('<cword>')
        else
          call CocAction('doHover')
        endif
      endfunction

      " Highlight the symbol and its references when holding the cursor.
      autocmd CursorHold * silent call CocActionAsync('highlight')

      " Symbol renaming.
      nmap <leader>rn <Plug>(coc-rename)

      " Formatting selected code.
      xmap <leader>f  <Plug>(coc-format-selected)
      nmap <leader>f  <Plug>(coc-format-selected)

      augroup mygroup
        autocmd!
        " Setup formatexpr specified filetype(s).
        autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
        " Update signature help on jump placeholder.
        autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
      augroup end

      " Applying codeAction to the selected region.
      " Example: `<leader>aap` for current paragraph
      xmap <leader>a  <Plug>(coc-codeaction-selected)
      nmap <leader>a  <Plug>(coc-codeaction-selected)

      " Remap keys for applying codeAction to the current line.
      nmap <leader>aa  <Plug>(coc-codeaction)
      nmap <leader>ac  <Plug>(coc-codeaction-cursor)
      " Apply AutoFix to problem on the current line.
      nmap <leader>qf  <Plug>(coc-fix-current)

      " Introduce function text object
      " NOTE: Requires 'textDocument.documentSymbol' support from the language server.
      xmap if <Plug>(coc-funcobj-i)
      xmap af <Plug>(coc-funcobj-a)
      omap if <Plug>(coc-funcobj-i)
      omap af <Plug>(coc-funcobj-a)

      " Use <TAB> for selections ranges.
      " NOTE: Requires 'textDocument/selectionRange' support from the language server.
      " coc-tsserver, coc-python are the examples of servers that support it.
      nmap <silent> <TAB> <Plug>(coc-range-select)
      xmap <silent> <TAB> <Plug>(coc-range-select)

      " Add `:Format` command to format current buffer.
      command! -nargs=0 Format :call CocAction('format')

      " Add `:Fold` command to fold current buffer.
      command! -nargs=? Fold :call     CocAction('fold', <f-args>)

      " Add `:OR` command for organize imports of the current buffer.
      command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

      " Add (Neo)Vim's native statusline support.
      " NOTE: Please see `:h coc-status` for integrations with external plugins that
      " provide custom statusline: lightline.vim, vim-airline.
      " set statusline^=%{coc#status()}%{get(b:,'coc_current_function',''')}
      " set statusline+=%F

      function! CocCurrentFunction()
        return get(b:,'coc_current_function',''')
      endfunction

      function! CocExtensionStatus()
        return get(g:,'coc_status',''')
      endfunction

      " Mappings using CoCList:
      " Show all diagnostics.
      nnoremap <silent> <space>E  :<C-u>CocList diagnostics<cr>

      " Manage extensions.
      nnoremap <silent> <space>A  :<C-u>CocList extensions<cr>

      " Show commands.
      nnoremap <silent> <space>c  :<C-u>CocList commands<cr>

      " Find symbol of current document.
      nnoremap <silent> <space>o  :<C-u>CocList outline<cr>

      " Search workspace symbols.
      nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>

      " Do default action for next item.
      nnoremap <silent> <space>j  :<C-u>CocNext<CR>

      " Do default action for previous item.
      nnoremap <silent> <space>k  :<C-u>CocPrev<CR>

      " prev error
      nnoremap <silent> <space>a  <Plug>(coc-diagnostic-prev-error)

      " next error
      nnoremap <silent> <space>e  <Plug>(coc-diagnostic-next-error)

      " Resume latest coc list.
      nnoremap <silent> <space>p  :<C-u>CocListResume<CR>

      " Toggle Inlay Hints
      nnoremap <silent> <space>i :CocCommand document.toggleInlayHint<CR>
    '';
    packages.myVimPackage = {
      # see examples below how to use custom packages
      start = with vimPlugins; [
        fugitive
        vim-nix
        vim-airline
        vim-airline-themes
        coc-nvim
        coc-rust-analyzer
        coc-clangd
        coc-eslint
        coc-tsserver
        coc-prettier
        coc-diagnostic
        coc-toml
        coc-html
        coc-go
        denite
        denite-nvim
        denite-extra
        papercolor-theme
        vim-json
        vim-yaml
        multiple-cursors
        base16-vim
        vimspector
      ];
      # If a vim plugin has a dependency that is not explicitly listed in
      # opt that dependency will always be added to start to avoid confusion.
      opt = [];
    };
  };
}
