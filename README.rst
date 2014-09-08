A Vim plugin to show cyclomatic complexity of Python code.

This script borrows heavily from Gary Bernhardt's Vim plugin **pycomplexity**,
but the Python code that takes care of the analysis has been rewritten to use
`Radon <https://github.com/rubik/radon>`_.

.. image:: https://cloud.githubusercontent.com/assets/238549/4182865/e4dfe7fc-3734-11e4-8132-1f1412a5e434.png
   :alt: Cyclomatic complexity of some PyLint code
   :align: center

The cyclomatic complexity of some PyLint code.

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

Commands
--------

Currently there is only one command, `Radon`, that will toggle the signs
showing/hiding the complexity results.

Configuration variables
-----------------------

**radon_always_on**

By default, the code will not be analyzed until that behavior is toggled with
the `Radon` command. If this option is set to a truthy value, the code will be
always analyzed (when a file is read or saved).
