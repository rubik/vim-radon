" complexity.vim
" Gary Bernhardt (http://blog.extracheese.org)
"
" This will add cyclomatic complexity annotations to your source code. It is
" no longer wrong (as previous versions were!)

if !has('signs')
    finish
endif
if !has('python')
    finish
endif

if exists("g:loaded_complexity") || &cp
  finish
endif

function! s:ClearSigns()
   sign unplace *
endfunction

function! s:ToggleComplexity()
    if exists("g:complexity_is_displaying") && g:complexity_is_displaying
        call s:ClearSigns()
        let g:complexity_is_displaying = 0
    else
        call s:ShowComplexity()
    endif
endfunction

python << endpython
import vim
import os
import ast
import collections

Function = collections.namedtuple('Function', ['name', 'lineno', 'col_offset',
                                               'endline', 'is_method',
                                               'classname', 'clojures',
                                               'complexity'])

def code2ast(source):
    try:
        source = source.encode('utf-8')
    except UnicodeDecodeError:
        pass
    return ast.parse(source)


class ComplexityVisitor(ast.NodeVisitor):

    def __init__(self, to_method=False, off=True, no_assert=False):
        self.off = off
        self.complexity = 1 if off else 0
        self.blocks = []
        self.classes = []
        self.to_method = to_method
        self.no_assert = no_assert
        self._max_line = float('-inf')

    @classmethod
    def from_ast(cls, ast_node, **kwargs):
        visitor = cls(**kwargs)
        visitor.visit(ast_node)
        return visitor

    @staticmethod
    def get_name(obj):
        return obj.__class__.__name__

    @property
    def max_line(self):
        return self._max_line

    @max_line.setter
    def max_line(self, value):
        if value > self._max_line:
            self._max_line = value

    def generic_visit(self, node):
        name = self.get_name(node)
        if hasattr(node, 'lineno'):
            self.max_line = node.lineno
        if name in ('Try', 'TryExcept'):
            self.complexity += len(node.handlers) + len(node.orelse)
        elif name == 'BoolOp':
            self.complexity += len(node.values) - 1
        elif name in ('Lambda', 'With', 'If', 'IfExp'):
            self.complexity += 1
        elif name in ('For', 'While'):
            self.complexity += bool(node.orelse) + 1
        elif name == 'comprehension':
            self.complexity += len(node.ifs) + 1

        super(ComplexityVisitor, self).generic_visit(node)

    def visit_Assert(self, node):
        self.complexity += not self.no_assert

    def visit_FunctionDef(self, node):
        clojures = []
        body_complexity = 1
        for child in node.body:
            visitor = ComplexityVisitor(off=False, no_assert=self.no_assert)
            visitor.visit(child)
            clojures.extend(visitor.blocks)
            body_complexity += visitor.complexity
            for func in visitor.blocks:
                body_complexity += func.complexity
            body_complexity -= len(visitor.blocks)

        func = Function(node.name, node.lineno, node.col_offset,
                        max(node.lineno, visitor.max_line), self.to_method,
                        None, clojures, body_complexity)
        self.blocks.append(func)

    def visit_ClassDef(self, node):
        methods = []
        for child in node.body:
            visitor = ComplexityVisitor(True, off=False,
                                        no_assert=self.no_assert)
            visitor.visit(child)
            methods.extend(visitor.blocks)
        self.blocks.extend(methods)


def complexity_name(complexity):
    if complexity > 10:
        return 'high_complexity'
    elif complexity > 5:
        return 'medium_complexity'
    else:
        return 'low_complexity'


def show_complexity():
    current_file = vim.current.buffer.name
    try:
        blocks = visit(current_file)
    except (IndentationError, SyntaxError):
        return

    old_complexities = get_old_complexities(current_file)
    new_complexities = compute_new_complexities(blocks)
    line_changes = compute_line_changes(old_complexities, new_complexities)
    update_line_markers(line_changes)


def visit(filename=None, code=None):
    if filename is not None:
        if os.path.exists(filename):
            with open(filename) as fobj:
                code = fobj.read()
        else:
            code = ''
    return sorted(ComplexityVisitor.from_ast(code2ast(code)).blocks,
                  key=lambda b: b.lineno)


def get_old_complexities(current_file):
    lines = list_current_signs(current_file)

    old_complexities = {}
    for line in lines:
        if '=' not in line:
            continue

        tokens = line.split()
        variables = dict(token.split('=') for token in tokens)
        line = int(variables['line'])
        complexity = variables['name']
        old_complexities[line] = complexity

    return old_complexities


def list_current_signs(current_file):
    vim.command('redir => s:complexity_sign_list')
    vim.command('silent sign place file=%s' % current_file)
    vim.command('redir END')

    sign_list = vim.eval('s:complexity_sign_list')
    lines = [line.strip() for line in sign_list.split('\n')]
    return lines


def compute_line_changes(cached_complexities, new_blocks):
    changes = {}
    for line, complexity in new_blocks.iteritems():
        if complexity != cached_complexities.get(line, None):
            changes[line] = complexity

    return changes


def compute_new_complexities(blocks):
    new_blocks = {}
    for block in blocks:
        for line in range(block.lineno, block.endline + 1):
            new_blocks[line] = complexity_name(block.complexity)
    return new_blocks


def update_line_markers(line_changes):
    filename = vim.current.buffer.name
    for line, complexity in line_changes.iteritems():
        vim.command(':sign unplace %i' % line)
        vim.command(':sign place %i line=%i name=%s file=%s' %
                    (line, line, complexity, filename))
endpython

function! s:ShowComplexity()
    python << END
show_complexity()
END
    let g:complexity_is_displaying = 1
    " no idea why it is needed to update colors each time
    " to actually see the colors
    hi low_complexity guifg=#004400 guibg=#004400 ctermfg=2 ctermbg=2
    hi medium_complexity guifg=#bbbb00 guibg=#bbbb00 ctermfg=3 ctermbg=3
    hi high_complexity guifg=#ff2222 guibg=#ff2222 ctermfg=1 ctermbg=1
endfunction

hi SignColumn guifg=fg guibg=bg
hi low_complexity guifg=#004400 guibg=#004400 ctermfg=2 ctermbg=2
hi medium_complexity guifg=#bbbb00 guibg=#bbbb00 ctermfg=3 ctermbg=3
hi high_complexity guifg=#ff2222 guibg=#ff2222 ctermfg=1 ctermbg=1
sign define low_complexity text=XX texthl=low_complexity
sign define medium_complexity text=XX texthl=medium_complexity
sign define high_complexity text=XX texthl=high_complexity

if exists("g:complexity_always_on") && g:complexity_always_on
    autocmd! BufReadPost,BufWritePost,FileReadPost,FileWritePost *.py call s:ShowComplexity()
    call s:ShowComplexity()
endif

command! Complexity  call s:ToggleComplexity()
