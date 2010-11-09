#!/bin/bash

# Constants
REMOVETRAILINGSLASH="sed -e 's,\(.\)/$,\1,'"

# Arguments: ./command GREP SRC TARGET -dontprune
GREPFOR=$(test -z "$1" && echo ".*" || echo "$1")
SRCDIR=$(test -z "$2" && echo "." || (echo "$2" | sed -e 's,\(.\)/$,\1,'))
TARDIR=$(test -z "$3" && echo "_TEMP_GREPSCHEMA_OUTPUT" || (echo "$3" | sed -e 's,\(.\)/$,\1,'))
$(test -z "$4")
DONTPRUNEEMPTY=$?

#echo GREPFOR: "$GREPFOR"
#echo SRCDIR: "$SRCDIR"
#echo TARDIR: "$TARDIR"
#echo PRUNE: "$DONTPRUNEEMPTY"

FINDDIRCOMMAND="find $SRCDIR -type d"
FINDFILECOMMAND="find $SRCDIR -type f"

#echo FINDDIRS: "$FINDDIRCOMMAND"
#echo FINDFILES: "$FINDFILECOMMAND"

# first create the dirs
for i in $($FINDDIRCOMMAND 2> /dev/null); do
	mkdir -p "${i/$SRCDIR/$TARDIR}"
done

# next pipe results to the files
for i in $($FINDFILECOMMAND 2> /dev/null); do
	TARFILE="${i/$SRCDIR/$TARDIR}"
	grep "$GREPFOR" "$i" > "$TARFILE"
	if [ "$DONTPRUNEEMPTY" -eq 0 ]; then
		if [ ! -s "$TARFILE" ]; then # empty file
			rm "$TARFILE"
		fi
	fi
done

if [ "$DONTPRUNEEMPTY" -eq 0 ]; then
	find "$TARDIR" -depth -type d -empty -exec rmdir {} \;
fi
