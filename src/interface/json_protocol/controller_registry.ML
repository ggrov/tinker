signature JSON_CONTROLLER_REGISTRY =
sig
  (*
    dispatch takes:
       ((controller, module, function), JSON input)
    and returns:
       JSON output
  *)
  val dispatch : (string * string * string) * Json.json -> Json.json
end

structure JsonControllerRegistry (*: JSON_CONTROLLER_REGISTRY*) =
struct

open JsonControllerUtil

val mtab0 = Symtab.make [("JsonSocket", (CModPsgraph.ftab, "Utility functions"))]
val ctab = Symtab.make [("PSGraphCtrl", mtab0)]

fun dispatch ((controller, module, function), json_input) =
let
  val mtab = case Symtab.lookup ctab controller of SOME x => x
                | NONE => raise user_exn ("Controller not found: " ^ controller)
  val modl = case Symtab.lookup mtab module of SOME x => x
             | NONE => raise user_exn ("Module not found: " ^ module)
  val func = case Symtab.lookup (fst modl) function of SOME x => x
             | NONE => raise user_exn ("Function not found: " ^ module ^ "." ^ function)
in (fst func) json_input
end

end