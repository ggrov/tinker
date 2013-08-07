Installation
============


Downloading and Installing Isabelle
-----------------------------------

This code is designed to run on Isabelle2013. Get it [here](http://www.cl.cam.ac.uk/research/hvg/Isabelle/installation.html).


Downloading and Installing required Libraries 
---------------------------------------------

Go to the installation directory of Isabelle. On a Mac this is

    cd /Applications/Isabelle2013.app/Isabelle/

Go to the contrib directory:

    cd contrib 

Grab the isaplib and quantomatic libraries with:

    git clone -b master git://github.com/Quantomatic/isaplib.git
    git clone -b ps-graph git://github.com/Quantomatic/quantomatic.git


Downloading and Installing the Proof Strategy language
-------------------------------------------------------

    git clone -b lpar13 https://github.com/ggrov/psgraph.git


Downloading and Installing GUI
---------------------------------------------------
If you wish to use GUI in the interactive proof session, you'll need the Scala Build Tool ([SBT](http://www.scala-sbt.org/release/docs/Getting-Started/Setup.html)).


Usage
=====
To demonstrate the usage, go into the psgraph/src/examples/LAPR13 directory and load the file intro.thy from Isabelle 2013. Please set the path of the Proof Strategy language accordingly.


Automated proof session with Proof Strategy language in Isabelle
----------------------------------------------------------------
To run the proof strategy (e.g. the intro tactic from LPAR'13) in the automated mode 

Uncomment the line

	apply (psgraph intro)


Interactive proof session with Proof Strategy language in Isabelle and GUI
---------------------------------------------------------------------------

To use the interactive GUI, go to the installation directory of Quantomatic (in contrib) and run:
    
    cd scala
    sbt run
    # select the option for quanto.gui.GraphEditor
    
please note that Internet is required to fetch dependent libraries when it runs at the first time.
    
    
- Run in the interactive mode:

	1. In Isabelle 2013, uncomment the following line to setup an interactive session:

			apply(psgraph (interactive) intro)
		
	  If you got an error message in Isabelle 2013, i.e. 
	  		
	  		exception SysErr (Address already in use, SOME EADDRINUSE) raised
	  
	  it means the previous interactive session was closed unexpectedly. You'll need to re-start Isabelle 2013. 
	  
	2. In the GUI, click the button 'Connect' to display the graph. The buttons 'Next' and 'Backtracking' are now available to execute the graph.
	
	3. To end the current interactive session, click 'Finish' in the GUI.



- There is a special ‘current’ mode, where the graph which is currently open in GUI is used. To run this mode:
	
	1. In Isabelle 2013, uncomment the following line to setup an interactive session:

			apply(psgraph (current))
	
	2. In GUI, open the file intro.psgraph, then click the button 'Connect' to display the graph. The buttons 'Next' and 'Backtracking' are now available to execute the graph.
	
	3. To end the current interactive session, click 'Finish' in the GUI.