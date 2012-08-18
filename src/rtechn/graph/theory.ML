structure RTechn_Theory = GraphicalTheory(
   structure OParam = OParam
   structure VComponentData = OVComponentData
   structure EComponentData = EComponentData);

structure RTechn_Controller = Controller(RTechn_Theory);


