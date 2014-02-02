dnl  SPARC v9-2011 simulation support.

dnl  Contributed to the GNU project by Torbjörn Granlund.

dnl  Copyright 2013 Free Software Foundation, Inc.

dnl  This file is part of the GNU MP Library.

dnl  The GNU MP Library is free software; you can redistribute it and/or modify
dnl  it under the terms of the GNU Lesser General Public License as published
dnl  by the Free Software Foundation; either version 3 of the License, or (at
dnl  your option) any later version.

dnl  The GNU MP Library is distributed in the hope that it will be useful, but
dnl  WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
dnl  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
dnl  License for more details.

dnl  You should have received a copy of the GNU Lesser General Public License
dnl  along with the GNU MP Library.  If not, see https://www.gnu.org/licenses/.


dnl Usage addxccc(r1,r2,r3, t1)
dnl  64-bit add with carry-in and carry-out
dnl  FIXME: Register g2 must not be destination

define(`addxccc',`dnl
	add	%sp, -512, %sp
	stx	%g2, [%sp+2047+256+16]
	mov	0, %g2
	movcs	%xcc, -1, %g2
	addcc	%g2, 1, %g0
	addccc	$1, $2, $3
	ldx	[%sp+2047+256+16], %g2
	sub	%sp, -512, %sp
')


dnl Usage addxc(r1,r2,r3, t1,t2)
dnl  64-bit add with carry-in

define(`addxc',`dnl
	bcc	%xcc, 1f
	 add	$1, $2, $3
	add	$3, 1, $3
1:
')


dnl Usage umulxhi(r1,r2,r3)
dnl  64-bit multiply returning upper 64 bits
dnl  Calls __gmpn_umulh using a non-standard calling convention

define(`umulxhi',`dnl
	add	%sp, -512, %sp
	stx	$1, [%sp+2047+256]
	stx	$2, [%sp+2047+256+8]
	stx	%o7, [%sp+2047+256+16]
	call	__gmpn_umulh
	 nop
	ldx	[%sp+2047+256+16], %o7
	ldx	[%sp+2047+256], $3
	sub	%sp, -512, %sp
')
dnl Usage lzcnt(r1,r2)
dnl  Plain count leading zeros
dnl  Calls __gmpn_lzcnt using a non-standard calling convention

define(`lzcnt',`dnl
	add	%sp, -512, %sp
	stx	%o7, [%sp+2047+256+16]
	call	__gmpn_lzcnt
	 stx	$1, [%sp+2047+256]
	ldx	[%sp+2047+256+16], %o7
	ldx	[%sp+2047+256], $2
	sub	%sp, -512, %sp
')