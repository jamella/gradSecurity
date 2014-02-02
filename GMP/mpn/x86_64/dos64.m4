divert(-1)
dnl  Copyright 2011-2013 Free Software Foundation, Inc.

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

define(`HOST_DOS64')


dnl  On DOS64 we always generate position-independent-code
dnl

define(`PIC')


define(`LEA',`
	lea	$1(%rip), $2
')


dnl  Usage: CALL(funcname)
dnl
dnl  Simply override the definition in x86_64-defs.m4.

define(`CALL',`call	GSYM_PREFIX`'$1')


dnl  Usage: JUMPTABSECT

define(`JUMPTABSECT', `RODATA')


dnl  Usage: JMPENT(targlabel,tablabel)

define(`JMPENT', `.long	$1-$2')


dnl  Usage: FUNC_ENTRY(nregparmas)
dnl  Usage: FUNC_EXIT()

dnl  FUNC_ENTRY and FUNC_EXIT provide an easy path for adoption of standard
dnl  ABI assembly to the DOS64 ABI.

define(`FUNC_ENTRY',
	`push	%rdi
	push	%rsi
	mov	%rcx, %rdi
ifelse(eval($1>=2),1,`dnl
	mov	%rdx, %rsi
ifelse(eval($1>=3),1,`dnl
	mov	%r8, %rdx
ifelse(eval($1>=4),1,`dnl
	mov	%r9, %rcx
')')')')

define(`FUNC_EXIT',
	`pop	%rsi
	pop	%rdi')


dnl  Target ABI macros.  For DOS64 we override the defaults.

define(`IFDOS',   `$1')
define(`IFSTD',   `')
define(`IFELF',   `')


dnl  Usage: PROTECT(symbol)
dnl
dnl  Used for private GMP symbols that should never be overridden by users.
dnl  This can save reloc entries and improve shlib sharing as well as
dnl  application startup times

define(`PROTECT',  `')


divert`'dnl