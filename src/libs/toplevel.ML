fun maybef f NONE = NONE
  | maybef f (SOME x) = SOME (f x);
