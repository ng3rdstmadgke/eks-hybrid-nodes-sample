let mapleader = "\<Space>"

if has('vim_starting')
  " Vim のエンコーディングを utf-8 に
  set encoding=utf-8
  scriptencoding utf-8

  " 利用可能な場合は true color を有効化する
  if !has('gui_running') && exists('&termguicolors') && $COLORTERM ==# 'truecolor'
    set termguicolors       " use truecolor in term
  endif
endif
syntax on                              " シンタックスハイライトを有効にする
set autoindent                         " 自動インデント
set hlsearch                           " 検索結果をハイライト表示
" === === === 基本設定 === === ===
set t_Co=256                           " カラーを256色に対応させる
set showmatch                          " 対応括弧をハイライト表示
set statusline=%F%m%r%h%w\%=[TYPE=%Y]\[FORMAT=%{&ff}]\[ENC=%{&fileencoding}]\[LOW=%l/%L]
set laststatus=2                       " ステータス行を常に表示
set softtabstop=2                      " tab キーを押した時に挿入されるスペース量
set expandtab                          " タブ文字をスペースに変換
set tabstop=2                          " タブ文字の幅
set shiftwidth=2                       " 自動インデント幅
set list                               " 不可視文字を表示するという宣言
set listchars=tab:»_,trail:-           " 表示する不可視文字を定義 : tab=タブ, trail=行末スペース
set nu                                 " 行数表示
set cursorline                         " カーソルラインを表示する
set isk+=-                             " w の選択で「-」も1単語に含める
set noswapfile                         " スワップファイルを作らない
set splitright                         " vsplitしたときに右側に開く
set splitbelow                         " splitしたときに下側に開く
" set paste                            " paste時のインデントずれ防止(括弧の補完が効かなくなる)

" --- 検索関連 ---
set ignorecase                         " 検索時に大文字と小文字を区別しない
set smartcase                          " 検索句に大文字が入っているときは大文字小文字を区別する(ignorecaseと一緒に使う)
set incsearch                          " インクリメンタルサーチを行う

" --- 移動関連 ---
set nowrap                             " 画面端で行を折り返さない
set scrolloff=8                        " 上下8行の視界を確保
set sidescroll=1                       " 左右スクロールは一文字づつ行う

" === === === カーソル移動 === === ===
" 表示行で移動する
" gj : 下, gk : 上
nnoremap gj j
nnoremap gk k
nnoremap j gj
nnoremap k gk
nnoremap <C-j> 5j
nnoremap <C-k> 5k
nnoremap <C-l> 5l
nnoremap <C-h> 5h
" インサートモード時の移動
inoremap <C-j> <DOWN>
inoremap <C-k> <UP>
inoremap <C-l> <RIGHT>
inoremap <C-h> <LEFT>

" === === === タブ・画面操作関連 === === ===
let g:netrw_liststyle = 3              " netrwは常にtree view
let g:netrw_altv = 1                   " netrwで'v'でファイルを開くときは右側に開く。
let g:netrw_auto = 1                   " netrwで'o'でファイルを開くときは下側に開く。
" 移動
nnoremap <Leader>j <C-w>j
nnoremap <Leader>k <C-w>k
nnoremap <Leader>l <C-w>l
nnoremap <Leader>h <C-w>h
" 画面を移動
nnoremap <Leader>J <C-w>J
nnoremap <Leader>K <C-w>K
nnoremap <Leader>L <C-w>L
nnoremap <Leader>H <C-w>H
" 画面サイズを調整
" > : 横に大きく, < : 横に小さく, + : 縦に大きく, - : 縦に小さく
nnoremap > <C-w>>
nnoremap < <C-w><
nnoremap + <C-w>+
nnoremap - <C-w>-
" 画面の大きさを揃える
nnoremap <Leader>= <C-w>=
" 画面を縦に分割してブラウジングを開始
" <Leader>d : 縦分割&右(:Ve!でも可), <Leader>s : 横分割&下(:Heでも可), <Leader>t : 新しいタブ(:Teでも可)
nnoremap <silent> <Leader>s :<C-u>Hexplore<CR>
nnoremap <silent> <Leader>d :<C-u>Vexplore!<CR>
nnoremap <silent> <Leader>t :<C-u>Texplore<CR>
" 画面を横に分割する ss : 横に分割(:spでも可), sv : 縦に分割(:vsでも可)
"nnoremap <Leader>s :<C-u>split<CR>
"nnoremap <Leader>v :<C-u>vsplit<CR>
" タブを左右に移動
nnoremap <Leader>n gt
nnoremap <Leader>p gT
" タブを左右に入れ替え
nnoremap <silent> <Leader>> :<C-u>tabm +1<CR>
nnoremap <silent> <Leader>< :<C-u>tabm -1<CR>
" 現在のペインをタブに移動する
nnoremap <Leader>a <C-w>T

" === === === コーディング関連 === === ===
" ,l でphpの構文チェックができる
nmap ,l :call PHPLint()<CR>
function! PHPLint()
    let result = system( &ft . ' -l ' . bufname(""))
    echo result
endfunction

" %でhtmlの開始タグと閉じタグの間を移動できるようになる
set nocompatible
filetype plugin on
runtime macros/matchit.vim

" {}を折りたたむ
nnoremap { f{v%kzf
" ()を折りたたむ
nnoremap ( f(v%kzf
" htmlタグを折りたたむ
nnoremap <silent> H :<C-u>normal v%kzf<CR>
" 括弧の補完
inoremap {{ {}<Left><CR><UP><ESC><S-a>
" 定義元にジャンプする(yum で ctags をインストールして、プロジェクトのルートで ctags -R を実行しておく必要がある)
nnoremap <silent> # :vsp<CR><C-w>l:exe("tjump ".expand('<cword>'))<CR>
" 括弧の補完 (<S-?> は Shift 押しながら ? を表す)
inoremap {{ {}<Left><CR><UP><ESC><S-a>
" vimgrep, grep の後ろに自動的に | cw を付加する
autocmd QuickFixCmdPost *grep* cwindow

" === === === その他 === === ===
nnoremap * *N
" M<KEY> : マークを付ける
nnoremap M m
" m<KEY> : マークにジャンプする
nnoremap m `
" sのキーマッピングを解除
nnoremap s <Nop>
" 単語をヤンク
nnoremap sy yiw
" 単語を選択してヤンク専用レジスタの値に置換
nnoremap sp viw"0p
" 保存
nnoremap <silent> <Leader>w :w<CR>
" 終了
nnoremap <silent> <Leader>q :q<CR>
" 保存せずに終了
nnoremap <silent> <Leader>o :qa!<CR>


" java.vim, javaid.vim, html.vim による javaのシンタックス
let java_highlight_all=1
let java_highlight_functions=1
let java_highlight_debug=1
