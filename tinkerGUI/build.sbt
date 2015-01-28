name := "tinkerGUI"

version := "0.1"

scalaVersion := "2.10.0"

scalacOptions ++= Seq("-feature", "-language:implicitConversions")

//seq(com.github.retronym.SbtOneJar.oneJarSettings: _*)

resolvers += "Typesafe Repository" at "http://repo.typesafe.com/typesafe/releases/"
 
libraryDependencies += "com.typesafe.akka" %% "akka-actor" % "2.1.1" withSources() withJavadoc()

libraryDependencies += "com.fasterxml.jackson.core" % "jackson-core" % "2.1.2"

libraryDependencies += "com.fasterxml.jackson.module" % "jackson-module-scala" % "2.1.2"

libraryDependencies += "org.scalatest" % "scalatest_2.10" % "2.0.M5b" % "test"

//libraryDependencies += "org.scalatest" %% "scalatest" % "2.0.M5" % "test"

libraryDependencies += "org.scala-lang" % "scala-swing" % "2.10.0"

//EclipseKeys.withSource := true

//exportJars := true


unmanagedSourceDirectories in Compile += baseDirectory.value / "tinker_library"

scalacOptions ++= Seq("-unchecked", "-deprecation")

mainClass in (Compile, run) := Some("tinkerGUI.views.MainGUI")
//mainClass := Some("tinkerGUI.views.MainGUI")