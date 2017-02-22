---
layout: page
title: Refactoring Aspect-Oriented Software
permalink: /shimon/thesis/
---

### Shimon Rura's Undergraduate Thesis (May 2003)

This is really old now, but a few people have downloaded or referenced this work over the years, so I'm trying to preserve this content at this URL.

#### Abstract

This thesis extends the state of the art in refactoring to Aspect-Oriented Programming. Refactorings are specific code transformations that improve the design of existing code without changing its observable behavior. Aspect-Oriented Programming (AOP) offers a new approach to software design by encapsulating crosscutting concerns. The novel contributions of this thesis are a recasting of existing refactorings to preserve program behavior in aspect-oriented code, and several new refactorings that can improve the design of code by deploying AOP techniques. The refactorings are described in reference to AspectJ, an AOP extension of Java, and are amenable to partial or full automation.

It is necessary to reevaluate existing OO refactorings because the constructs of AOP programming languages significantly affect what changes can be meaning-preserving. To this end, new preconditions and steps are introduced to about 20 fundamental refactorings (from Opdyke, 1992) such as renaming a class and inlining a method. These extended refactorings can form the basis for an AOP-aware refactoring tool.

About thirty new AOP-specific refactorings are proposed. These refactorings include both fundamental refactorings and more complex refactorings built from these that address specific design problems. For example, a simple refactoring possible in AOP is to move the definition of a method from within a class to an aspect. A more complex refactoring that includes this is moving all code responsible for implementing a particular interface into an aspect. The focus is primarily on accomplishing the desired changes once the involved program parts are identified. These new refactorings can form the basis for a truly AOP-focused refactoring tool. 

#### Downloads

* **The Thesis, "Refactoring Aspect-Oriented Software",** final version (May 23, 2003)

  This is the full thesis, in its final version as printed and delivered to the library.

  * [Full screen-optimized (hyperlinked) PDF, 577K](download/shimon-rura-refactoring-aop-final-hyperlinked.pdf)
  * [Full PDF for printing, 478K](download/shimon-rura-refactoring-aop-final.pdf)

&nbsp;

* **AspectJ Parser**

  This is a parser for AspectJ 1.0 written with JavaCC. It is far from perfect; see the [README](download/README.parser.txt).

  * [Download .tar.gz, 84K](download/AspectJParser.tar.gz)


 
