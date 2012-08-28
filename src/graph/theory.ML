structure Strategy_Theory = GraphicalTheory(
  structure OParam = Strategy_OGraphParam
  structure VComponentData = Strategy_OVertexComponentData
  structure EComponentData = Strategy_EdgeComponentData
);

structure Strategy_Controller = Controller(Strategy_Theory);
