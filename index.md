---
layout: default
title: Tinker
---

### PSGraph
****
Proof-strategy graphs (PSGraphs) is a formalism that represents proof strategies as graphs, where tactics appear on nodes in a graph, and are connected by ‘piping’ them together. To prove a goal in such strategies, the goal is wrapped in a particular graph node, called goal node, and put in one of the input pipes of the graph. The tactic at the end of this pipe, will then consume this goal node, apply the tactic to the goal, and send any (wrapped) sub-goals to the output pipes. Properties of the pipes ensure that only the right ‘type’ of goals are accepted. 

 <center><img src="images/example.png"  title=" Some goal-nodes (depicted as circles) making their way through a PSGraph" width="600" ></center>



### Tinker
The Tinker tool, which is a first implementation of PSGraphs. It adopts a generic theorem prover independent framework. We have currently connected it to both Isabelle and ProofPower. It is important to note that this is an extension of these provers. Users of these systems will still use the existing interface, with an additional graphical interface to step through the evaluation of a PSGraph. 

****
 <center><img src="images/tinker-isa-i.png" title="Tinker GUI with Isabelle" width="600" ></center>


### Publications
********
{% include publications.html %}


### Talks
********

{% include talks.html %}
