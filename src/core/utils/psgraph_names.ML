
  structure V = struct open SStrName; val default_name = mk "Va"; end (* vertices *)
  structure E = struct open SStrName; val default_name = mk "Ea"; end (* edges *)
  structure G = struct open SStrName; val default_name = mk "Ga"; end;(* goal type *)

  structure SStrTab = NameTable(structure Dom = SStrName)
  structure VTab = SStrTab
  structure ETab = SStrTab

  structure EVFn : NAME_FUNCTION
      where type dom = E.name
        and type DomSet.T = E.NSet.T
        and type cod = V.name
        and type CodSet.T = V.NSet.T



