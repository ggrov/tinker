structure GTData : GT_DATA = GTDataFun (IsaTerm);
structure Class : CLASS = ClassFun (GTData);
structure Link : LINK = LinkFun(Class);
