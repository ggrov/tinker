signature FULL_GOAL_TYP_SHARING = 
sig
  structure Link : LINK_SHARING
  structure Class : CLASS_SHARING
end

signature FULL_GOAL_TYP = 
sig
  include BASIC_GOALTYPE
  structure Link : LINK
  structure Class : CLASS
  sharing Class.Sharing.GoalTypData = Link.Sharing.GoalTypData
   
  val get_name : T -> G.name
  val get_link : T -> Link.T
  val get_facts: T -> Class.T list
  val get_gclass : T -> Class.T

  val set_name : G.name -> T -> T
  val set_link : Link.T -> T -> T
  val set_facts : Class.T list -> T -> T
  val set_gclass: Class.T -> T -> T

  structure FullSharing : FULL_GOAL_TYP_SHARING
    sharing FullSharing.Link = Link.Sharing
    sharing FullSharing.Class = Class.Sharing

end;
