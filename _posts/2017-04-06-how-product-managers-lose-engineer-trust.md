---
layout: post
title:  "How Product Managers Lose the Trust of Engineers"
#date:   2017-04-06 11:00:00 -0400
categories: blog
excerpt_separator: <!--more-->
---

As a product manager, your job is to help your company take advantage of a
market opportunity. You can almost split the job in half: the outside half,
about understanding the market, and the internal half, about enabling your
team. This post is about the internal half of the job, and how I've seen
things go haywire with one of the most important groups: the engineers.

I started my career as a software engineer, so I naturally empathize with
this group. But since I switched to product management a few years ago, I'm
also acutely aware of the challenges engineers can pose. There's a natural
tension between PMs-- who always want more things faster-- and engineers who
are on the hook to build and maintain systems. You can't solve this tension;
it's inherent to the responsibilities and cultures of these roles. So your
best bet is to negotiate it from a position of mutual trust and respect.

**But what if you just want to blow up that trust and respect, like a giant torpedo from outer space?** Here are some destructive tricks that I've seen work!
<!--more-->


### 1. Lie about how successful we're all gonna be

Let's face it: the median PM is about 0.00001% as good as Steve Jobs. But thinks he's about 10% as good.

The reason this pitfall is so tempting is partly because many PMs rely on it personally. Sure most new products fail, and most startups fail. But they don't know *me* and *my product.* We're unstoppable.

If you have this deep belief, this faith that you will ultimately succeed: **nurture it.** Do not tone down your ambitions and pick easier problems. Rather, accept that on the way to your big wins you will have setbacks and grinds. You will painstakingly build and ship things that turn out to be dead ends. Good product management help you get right faster, but it's still through an iterative process, which means **your big wins come through a lot of small steps.**

On the other hand, if you say "here's a sketch of the new app, once you build these three screens I'm confident 100k people will download, we don't need no marketing plan"... well, you're setting everyone up for disappointment. Either they're already jaded enough to tune out that hyperoptimism, or they will be in two weeks.

### 2. Try to substitute micromanagement for vision

Lots of the work of a PM is just good follow-up: documenting decisions, resolving conflict, fighting fires. But a great PM will do all of this in the context of a vision that excites and motivates the whole team. This doesn't have to be a vision *you created,* but it is your responsibility to understand it and make sure everyone on your team gets it too.

That doesn't mean every coder has to understand the nuances of buyer motivation. But your goal is to promulgate a vision that everyone can get behind, not just in a grand inspiration sense, but in a way that shapes their daily decisions. For engineers, the product vision is often the first and broadest guide to knowing which stuff needs to built out to Advanced Super Scalable Polished Quality and which stuff can kinda be glued together. If you find yourself needing to micromanage these sorts of technical tradeoffs, maybe the real problem is they don't get the vision.

### 3. Don't listen

You're an exceptionally qualified, smart, successful person. That's why you're managing this product, right? Well, everyone you work with *also* knows they're smart and well-qualified, and a bunch of them are *pretty darn convinced* the company would be a lot more successful if it just listened to them. They have deep expertise. Often they are right.

You're the personification of the company's direction, at least for this product -- so *you should listen to them.* Just like listening to users, this can be very revealing. If everyone in the company says that we've only maintained feature X because the founder has an inexplicable obsession with it even though nobody uses it, they're probably right.

Also like users, the people you work with will want conflicting things. Some engineers will hate the database layer, others think it's the coolest part of the whole product. You can't please everyone, but you *can* listen to everyone. When you need to scale beyond just face-to-face conversations, simple things like a transparent way for colleagues to submit ideas can work well. The critical ingredient is feedback. So give everyone a way to file issues for whatever they care about, set an expectation for how often they'll be reviewed by the product team, and make sure they get notified (even if the notification is "sorry we've got bigger fish to fry"). And when an oft-requested feature does ship, thank everyone who asked for it by name.


### 4. Indulge bad work (including by engineers)

Have consistent, high standards for what level of work is acceptable. It's easy to say but harder to follow through, and you have to follow this one through.

This is one area where management and parenting have some common ground. Like all humans, engineers don't always live up to their own standards. We rely on our peers to value and demand good work, even when we ourselves are lazy. But if our laziness is always accommodated, we'll get used to it, and won't bother pushing to do our best.

When you're managing a team with multiple different skillsets, it can be hard to know when you're seeing bad work. So the best thing you can do here is make sure that each functional team has its own standard bearers. People who can evaluate the work others are doing as it happens, and make sure that the codebase or design or product roadmap is something to be proud of.

On the other hand, suppose you have an engineer who often does lousy work. The other engineers know this (because they're completing his features and fixing his bugs). If you treat that assclown the same way you treat any other engineer, you're sending them all the message that you don't appreciate the difference.

### 5. Refuse to prioritize

There are more good ideas than there is time to execute them. Therefore:

* Any work you choose to do will displace other work you could be doing instead.
* Just because some work will generate more value than it costs doesn't mean you should do it.
* You should do something when it has the best benefit-to-cost ratio of all the things you could do.

These things should be obvious. An engineer can work on one thing at a time. A team of *N* engineers can work on *N or fewer* things at a time.

Yet so many product leaders think they can just identify 500 things that seem worth doing and then blame the engineers when only 15 get done, and it's the wrong 15. That's like an investment advisor saying "here are a bunch of investment options, I think some of them will go up in value" but not telling you how to balance your nest egg among the options. *This means the job isn't done.*

Prioritizing can be hard for a PM to do, because we don't always know what a feature is truly worth, or even how much work it will take to build. But the fact is your team will always work through things in some order. You can choose whether that order is something you determine, or if you'd prefer it be shaped by the whims, preferences, competing interruptions, and gripping Hacker News articles of the day.

### 6. Take credit

Credit can motivate people. As a locus of communication in the organization, a PM has a lot of capability to distribute credit. And even to create credit, by explaining the great work your team does. You can and should capture some of this credit for yourself, as it is one way you develop your career and increase your influence. Plus it feels good.

But don't overdo it. And this isn't just about what you put in slide decks or announce in meetings; you can cross a line by giving yourself a goofy nickname ("product overlord") or failing to include the right colleagues in meetings.

As one of the more visible leaders on a product, you'll already get a lot of credit for its success (and blame for failures). Don't hoard it; credit is not a scarce commodity! Help those who do good work. Maybe it means they'll be more likely to rise in the org, in which case you've nurtured a relationship that could help you again someday. And when a team feels recognized for their work, they'll be happier and perform better.

### 7. Always expect firm deadlines

Accountability is a core value of high performing organizations. If you need a routine change to some part of your product's layout or content, it should ship efficiently in a predictable amount of time.

But much of the work in a software product is novel to your team. Designing and building a feature can expose complexity that wasn't foreseen. This is the nature of making software; an organization where this never happens isn't taking enough risk.

This is one of the most dangerous areas for PMs who don't have a technical background, because [it can be hard to tell the difference between trivial and impossible](https://xkcd.com/1425/). But there is a difference. Blindness to that means at best that you'll fail to recognize great work, and at worst that you'll be known as a clueless dupe with crazy ridiculous expectations.

This is also a major weapon available to the engineering side. If you don't want to do something, just say it's impossible. This can be a powerful vector for laziness and obstruction, just as it is in government. Avoiding that is one important benefit of having technical smarts at the very top levels of your organization.

### Be good. Don't be bad.

In an organization full of people who are (1) smart and (2) always learning, it's hard to know everything all the time. Most of the fails listed above boil down to this:

#### *Don't pretend to be certain when you're not; engage everyone in building knowledge.*

Building good products is about assembling the right knowledge and making it operational. Helping engineers prioritize, get the right resources, and understand real-world performance can turn them into your greatest allies. Drown them in politics, unproven ideas, or other distractions, and you'll soon have the mutiny you deserve.
<!-- ### other ideas -->

<!-- * Don't listen  -->
<!-- * Be in denial about conflicting goals -->
<!-- * Indulge bad work (including by engineers) -->
<!-- * Refuse to prioritize -->
<!-- * Change the requirements at the wrong times -->
<!-- * Don't include engineers in deadline setting -->
<!-- * Hoard information -->
<!-- * Take credit -->
<!-- * Complain about your bosses -->
<!-- * Assume engineers don't care about users -->
<!-- * Block work on tech debt -->
<!-- *  -->
