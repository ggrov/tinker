Tinker - A graph based proof strategy language
============
Project Web Page - http://ggrov.github.io/tinker/

Installation
============

Downloading and Installing Isabelle
-----------------------------------

To use PSGraph with Isabelle, you first need to download and install Isabelle 2013. 

Details of how to do this can be found [here](http://www.cl.cam.ac.uk/research/hvg/Isabelle/installation.html).


Downloading and Installing required Libraries 
---------------------------------------------

You then need to install some required libraries. First you need to find the 
installation directory of Isabelle. On a Mac this is typically

    cd /Applications/Isabelle2013.app/Isabelle/

Then go to the contrib directory:

    cd contrib 

and grab the isaplib and quantomatic libraries either over https:

    git clone -b master  https://github.com/Quantomatic/isaplib
    git clone -b ps-graph https://github.com/Quantomatic/quantomatic
    
OR over ssh:

    git clone -b master git://github.com/Quantomatic/isaplib.git
    git clone -b ps-graph git://github.com/Quantomatic/quantomatic.git

Note that this assumed that you have `git` installed.

Downloading and Installing PSGraph
-------------------------------------------------------

You can then download the `psgraph` tool in any folder you like with either

    git clone https://github.com/ggrov/psgraph

OR 

    git clone git://github.com/ggrov/psgraph.git

Installing the GUI
---------------------------------------------------
If you wish to use GUI in the interactive proof session, you'll need the 
 - Scala Build Tool ([0.12.4](http://www.scala-sbt.org/release/docs/Getting-Started/Setup.html)) and;
 - Graphviz [here](http://www.graphviz.org/Download.php)
 
 Note that this assumed that you have java 6 or above installed.


Usage
=====

The `src/examples/LPAR13` directory of the `psgraph` installation contains a set of example. To
illustrate open the `example.thy` file in Isabelle 2013 (using the Isabelle/PIDE interface). 

Automated proof session
----------------------------------------------------------------
You can run the psgraph method in the automated mode with the command: 

	apply (psgraph <name of the psgraph>)
	
This is illustrate under `Example 1` in the `example.thy` file with the asm graph:
 
	apply (psgraph asm)


Interactive proof session with the GUI
---------------------------------------------------------------------------

To use the interactive GUI, go to the `contrib` directory of your Isabelle installation and execute
the following commands:
    
    cd quantomatic/scala
    sbt run
    
You will then be given a set of options. Here, choose the option for `quanto.gui.GraphEditor`.
Please note that you may need an internet in order to fetch dependent libraries when you run
`sbt` for the first time.
    
Then return to the Isabelle GUI, go to `Example 2` of the `example.thy` theory file and uncomment
the following line

    apply(psgraph (interactive) conj_impI)
    
This will open a socket connection to the GUI. This is currently very fragile and if it gets reloaded
again (e.g. by making any changes to the `example.thy` theory file in Isabelle) it may fail with the 
error

     exception SysErr (Address already in use, SOME EADDRINUSE) raised
     
This means that the previous interactive session was closed unexpectedly. You'll need to re-start Isabelle 2013, and
do this again.

After applying this command go the PSGraph GUI and click the `Connect` button to display the graph. 
The buttons `Next`, which applies a single evaluation step, and 'Backtrack', which backtracks the last step,
are now available to execute the graph. 

To end the current interactive session, click the `Finish` button in the GUI, and return to the Isabelle GUI. Here,
you can see that the sub-goal status has been updated with the result from the evaluation.

There is also a special `current` mode, where the graph which is currently open in GUI is used. `Example 3` of the
same file illustrates this. Here, uncomment the following line to setup an interactive session:

     apply(psgraph (current))
	
In the PSGraph GUI, open the file `example_current.psgraph` (in the same directory as the Isabelle theory file), 
and click the `Connect` button. You can then interact with the GUI as described above.

More examples
---------------------------------------------------------------------------

- The `intro.psgraph` (graph) and `intro.thy` (Isabelle theory file using graph) files in the same directory illustrates the intro tactic.
- The `eval_rippling/rippling.thy` file contains a set of examples for the rippling strategy.


