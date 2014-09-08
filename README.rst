A Vim plugin to show cyclomatic complexity of Python code.

This script borrows heavily from Gary Bernhardt's Vim plugin **pycomplexity**,
but the Python code that takes care of the analysis has been rewritten to use
`Radon <https://github.com/rubik/radon>`_.

----

**Table of Contents**

.. contents::
   :local:
   :depth: 2
   :backlinks: none


Installation
------------

Using Pathogen
++++++++++++++

Just make sure you have the following lines in your `.vimrc`:

.. code-block:: vim

    call pathogen#infect()
    syntax enable
    filetype plugin indent on

And then install `vim-radon` as any other Pathogen plugin.

Using Vundle
++++++++++++

Check that you have the following lines (in this order) in your `.vimrc`:

.. code-block:: vim

    set nocompatible
    filetype off

    set rtp+=$HOME/.vim/bundle/vundle/
    call vundle#rc

    " let Vundle manage Vundle, required
    Bundle 'gmarik/vundle'

    Bundle 'rubik/vim-radon'

    syntax enable
    filetype plugin indent on

Then run `:BundleInstall` and you're ready to go.

From a zip file
+++++++++++++++

1. Download the latest zip from Githu
2. Extract the archive into `~/.vim`::

    unzip -od ~/.vim/ ARCHIVE.zip

   This should create the file `~/.vim/ftplugin/python/radon.vim`.

You can update the plugin using the same steps.

Configuration variables
-----------------------

This is the full list of configuration variables available, with example
settings and default values. Use these in your vimrc to control the default
behavior.

Indenting
+++++++++

**dg_indent_keep_current**

By default, the indent function matches the indent of the previous line if it
doesn't find a reason to indent or outdent. To change this behavior so it
instead keeps the current indent of the cursor, use

    let dg_indent_keep_current = 1

*Default*: ``unlet dg_indent_keep_current``
