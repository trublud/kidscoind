#!/bin/bash

TOPDIR=${TOPDIR:-$(git rev-parse --show-toplevel)}
SRCDIR=${SRCDIR:-$TOPDIR/src}
MANDIR=${MANDIR:-$TOPDIR/doc/man}

KIDSCOIND=${KIDSCOIND:-$SRCDIR/kidscoind}
KIDSCOINCLI=${KIDSCOINCLI:-$SRCDIR/kidscoin-cli}
KIDSCOINTX=${KIDSCOINTX:-$SRCDIR/kidscoin-tx}
KIDSCOINQT=${KIDSCOINQT:-$SRCDIR/qt/kidscoin-qt}

[ ! -x $KIDSCOIND ] && echo "$KIDSCOIND not found or not executable." && exit 1

# The autodetected version git tag can screw up manpage output a little bit
KDCVER=($($KIDSCOINCLI --version | head -n1 | awk -F'[ -]' '{ print $6, $7 }'))

# Create a footer file with copyright content.
# This gets autodetected fine for bitcoind if --version-string is not set,
# but has different outcomes for bitcoin-qt and bitcoin-cli.
echo "[COPYRIGHT]" > footer.h2m
$KIDSCOIND --version | sed -n '1!p' >> footer.h2m

for cmd in $KIDSCOIND $KIDSCOINCLI $KIDSCOINTX $KIDSCOINQT; do
  cmdname="${cmd##*/}"
  help2man -N --version-string=${KDCVER[0]} --include=footer.h2m -o ${MANDIR}/${cmdname}.1 ${cmd}
  sed -i "s/\\\-${KDCVER[1]}//g" ${MANDIR}/${cmdname}.1
done

rm -f footer.h2m
