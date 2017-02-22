Parser for AspectJ 1.0
^^^^^^^^^^^^^^^^^^^^^^

This software is distributed under the terms of the GNU General Public
License, version 2, or any later version at your option.  You can view this
license at: http://www.gnu.org/copyleft/gpl.html.

WARNING: this is not an official parser.  In fact, it has one MAJOR GLARING
PROBLEM:
      When using the * operator, for example to multiply two integers, you
      must separate the * from the operands by whitespace.  This is because
      any string containing a * along with any letters or digits is assumed
      by the tokenizer to be an identifier pattern.

In addition, this parser treats the following as reserved words:
   after around aspect before declare dominates issingleton percflow
   percflowbelow pertarget perthis pointcut privileged proceed returning
   thisJoinPoint thisJoinPointStaticPart thisEnclosingJoinPointStaticPart
   throwing

Run 'make' to compile.  Requires the JavaCC parser generator, available
from:
http://webgain.com/products/java_cc/

To run:

java AspectJParser <source files>

- or - from the jar file:

java -jar AspectJParser.jar <source files>

The parser will attempt to parse each file and output success or failure
messages, as well as specific error messages.  These messages are generated
by JavaCC and generally say that a particular token was found where a number
of different ones were expected.  For more detail, uncomment the line that
says "DEBUG_PARSER = true;" near the beginning of aspectj1_0.jj and
recompile.

If you have any questions or believe you have found a bug or incompleteness
in the parser, please don't hesitate to contact me.

Shimon Rura, 27 Jan 2003
shimon@rura.org