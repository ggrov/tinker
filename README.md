Installation
============


Downloading and Installing Isabelle
-----------------------------------

Go to 

 http://www.cl.cam.ac.uk/research/hvg/isabelle/download.html

and install Isabelle2012


Downloading and Installing required Libraries 
---------------------------------------------

Go to the installation directory of Isabelle. On a Mac this is

    cd /Applications/Isabelle-2012.app/Isabelle/

go to the contrib directory:

    cd contrib 

Then get the isaplib library (requires git)

    git clone git://github.com/Quantomatic/isaplib.git

Next, get the quantomatic library (requires git)

    git clone git://github.com/Quantomatic/quantomatic.git
    cd quantomatic
    git checkout scala-frontend
    git pull


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

- To draw graphs go to the installation directory of Quantomatic (in contrib)
    cd scala
    sbt run
    select the  [3] quanto.gui.GraphEditor option

- To execution a graph (e.g. the intro tactic from ITP'13)
    - got into the psgraph/src/examples/ITP13 directory
    - load the file intro.thy [you need to set the path there]

- Interactive GUI     
    - In Eclipse, right click on the org.ai4fm.psgraph.ui project, select Run As -> Run Configurations...
      and run it as an Eclipse Application (you have to make sure that `all workspace and enabled plugins'
      is selected in the plug-ins tab to ensure that the Eclipse/Isabelle plug-in is launched).
    - Make sure that the PPlan and Graph views are visible (in the PPlan) directory), as well as the Prover
      Output view in the Isabelle directory. 
    - You can start Isabelle from the External Tool button, selection the `External Tool Configuration..' option.
      Select Isabelle, give the path to the installation, select HOL as logic and run it 
       (which should cause Isabelle to start)
    - Using the GUI
       - to enter the interactive proof command, apply the interactive_proof_strategy method
       - To connect to it in the GUI press the `connect to Isabelle' (middle) button in
         the Graph view
       - This will load a Graph -- and the current proof is shows in the PPlan view
       - use the arrows to navigate, and press the (middle) terminate button
         to exit this view