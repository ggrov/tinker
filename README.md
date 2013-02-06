Installation
============


Downloading and Installing Isabelle
-----------------------------------

This code is designed to run on Isabelle2012. Get it [here](http://www.cl.cam.ac.uk/research/hvg/isabelle/download.html).


Downloading and Installing required Libraries 
---------------------------------------------

Go to the installation directory of Isabelle. On a Mac this is

    cd /Applications/Isabelle-2012.app/Isabelle/

go to the contrib directory:

    cd contrib 

Grab the isaplib and quantomatic libraries with:

    git clone -b ps-graphs git://github.com/Quantomatic/isaplib.git
    git clone -b ps-graphs git://github.com/Quantomatic/quantomatic.git

If you wish to use the graph drawing GUI, you'll need the Scala Build Tool ([SBT](http://www.scala-sbt.org/release/docs/Getting-Started/Setup.html)).


Downloading and Installing the Proof Strategy language
-------------------------------------------------------

    git clone https://github.com/ggrov/psgraph.git


Downloading and Installing GUI and Isabelle Eclipse
---------------------------------------------------

To use the interactive GUI we recommend using Isabelle/Eclipse, and 
Eclipse Juno. Use the 'Update Manager' in Eclipse. Firstly, you can 
install Isabelle/Eclipse from [here](http://www.ai4fm.org/isabelle-eclipse/updates/latest/).

Next, you need the [zest](https://hudson.eclipse.org/hudson/job/gef-zest-nightly/lastSuccessfulBuild/artifact/targetPlatform/) library to view the graph. You will most likely need the 
latest version, which you can get from the following site:

Then add the org.ai4fm.psgraph.ui project in the GUI directory of psgraph (the proof strategy language)
to a project (detail below on how to run it)


Usage
=====

Graph Drawing Tool
------------------

To draw graphs go to the installation directory of Quantomatic (in contrib) and run:
    
    cd scala
    sbt run
    # select the option for quanto.gui.GraphEditor

To execute a graph (e.g. the intro tactic from ITP'13), go into the psgraph/src/examples/ITP13 directory and load the file intro.thy (you need to set the path there).

Interactive GUI
---------------

To get the interactive GUI running in Eclipse/Isabelle, follow these steps.

1. In Eclipse, right click on the org.ai4fm.psgraph.ui project, select Run As -> Run Configurations...
and run it as an Eclipse Application (you have to make sure that `all workspace and enabled plugins'
is selected in the plug-ins tab to ensure that the Eclipse/Isabelle plug-in is launched).

2. Make sure that the PPlan and Graph views are visible (in the PPlan) directory), as well as the Prover
Output view in the Isabelle directory.

3. Start Isabelle by clicking the External Tool button and selecting the `External Tool Configuration..'. Select Isabelle, give the path to the installation, select HOL as logic and run it (which should cause Isabelle to start).


To enter the interactive proof command, apply the interactive_proof_strategy
method. To connect to it in the GUI press the `connect to Isabelle' (middle)
button in the Graph view. This will load a Graph and the current proof is
shown in the PPlan view. Use the arrows to navigate, and press the (middle)
terminate button to exit this view.
