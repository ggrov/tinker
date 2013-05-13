
structure GTData : GT_DATA = GTDataFun (IsaPrf);
structure Class : CLASS = ClassFun (GTData);
structure Link : LINK = LinkFun(Class);
