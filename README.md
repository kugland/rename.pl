rename.pl(1) -- rename files using Perl expressions
===================================================

## SYNOPSIS

`rename.pl` [options] [files]

## DESCRIPTION

This script allows renaming files using Perl code, such as regular expression replaces
(`s/old/new/`), character translation (`y/abc/ABC/`), or any other valid code that alters `$_`.

It also supports conversion of different charsets to UTF-8, Unicode normalization, and other types
of operation.

## OPTIONS

  * `-v` | `--verbose`:
    Be verbose (repeat for more).

  * `-q` | `--quiet`:
    Be quiet.

  * `--apply`:
    Apply changes. (Without this, no file will be renamed.)

  * `-f` | `--force`:
    Force overwrite of existing files.

  * `--ignore-fail`:
    Ignore failure to rename.

  * `--basename`:
    Modifies only the last element of the path.

  * `-h` | `--help`:
    Show help text.

  * `-V` | `--version`:
    Show version.

### Operations:

  * `-e` EXPR | `--expr`=EXPR:
    Perl expression that operates on `\$_`.

  * `--from-charset`=CHARSET:
    Convert names from CHARSET to UTF-8 (e.g. "iso-8859-1").

  * `--unicode-normalize`=FORM:
    Unicode normalization form (C, D, KC or KD).

  * `--collapse-whitespace`:
    Collapse whitespace characters.

  * `--strip-diacritics`:
    Strip diacritics.

  * `--unidecode`:
    Apply unidecode function (requires `Text::Unidecode`).

## EXAMPLES

None of these examples will actually rename anything. To apply changes, add `--apply` to the end
of the command.

    Change prefix "old" to "new" for old*.png:

        rename.pl -ve 's,^old,^new,g' old*.png

    Convert lowercase to uppercase in file names, but preserve case of extension:

        rename.pl -ve 'y/a-z/A-Z/; s,\.PNG$,.png,g' *.png

    Rename *.png to 000.png, 001.png, 002.png, ...

        rename.pl -ve '$_ = sprintf("%03d.png", $i++)' *.png

    Convert lowercase to uppercase in file names, preserving directory names:

        rename.pl --basename -ve 'y/a-z/A-Z/;' */*.png

    Convert charset from ISO-8859-1 to UTF-8:

        rename.pl -v --from-charset=iso-8859-1 *.png

    Compose diacriticals in file names (useful for files copied from OS X):

        rename.pl -v --normalize=KC *.png

    Decompose diacriticals in file names (useful for files copied to OS X):

        rename.pl -v --normalize=KD *.png

## NOTES

rename.pl always assumes both your filesystem and your command line to use UTF-8.

## COPYRIGHT

rename.pl is Copyright (C) 2021 André Kugland <kugland@gmail.com>.


[SYNOPSIS]: #SYNOPSIS "SYNOPSIS"
[DESCRIPTION]: #DESCRIPTION "DESCRIPTION"
[OPTIONS]: #OPTIONS "OPTIONS"
[EXAMPLES]: #EXAMPLES "EXAMPLES"
[NOTES]: #NOTES "NOTES"
[COPYRIGHT]: #COPYRIGHT "COPYRIGHT"


[rename.pl(1)]: rename.pl.1.html
