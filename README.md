# better-bash-vi-mode

simple shell script I use to emulate bash's vi-mode motions for yanking (`y`), cutting (`d`)
and pasting (`p`) to system clipboard

leverages bash's readline options (see `man bash` sections 'READLINE' and 'bind')

could be used as a starting point for defining other custom actions supporting
vi(m) motions

- use specified buffer for clipboard actions e.g. system clipboard via `xclip` while
still allowing motions (including numeric arguments) e.g. `y2w`: yank current + next word
- changes behaviour of `w` when used for cutting, yanking and pasting:
apply action to _whole_ word, no matter where the cursor was placed inside the word

**Note** I wrote this as a somewhat quick & dirty fix for personal use and shared it
in case someone found this usefull when facing the clipboard buffer problem.

So feel free to try this out or use the idea. If you're having trouble with this
you may open an issue or create a pull request if you have added any features etc.


## currently supported motions

| `w` | whole word |
| `0` | beginning of line |
| `ß` | end of line |
| `b` | beginning of word |
| `e` | end of line |
| `h` | left |
| `l` | right |
| `yy` `dd` etc. |  whole line |

numeric arguments can also be used (including negative numeric args although the
sign may not be used), may only affect motions such as `w`, `h`
Example: `d3l`

## Installation

source `brl-actions.sh` inside the corresponding `~/.bashrc` file and
use bash's `bind -m [mode] -x [binding]` function to bind any of the functions from
the file to a key of your choice (see 'bind' in `man bash`)

make sure to put the file named `brl-motions.sh` in the same directory as it is
sourced from the other file
