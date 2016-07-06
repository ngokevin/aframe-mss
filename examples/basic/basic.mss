red {
  material {
    color: #393E51;
  }
}

white {
  material {
    color: #E9E6C9;
  }
}

blue {
  material {
    color: #566683;
  }
}

box {
  geometry {
    primitive: box;
  }
}

sphere {
  geometry {
    primitive: sphere;
  }
}

sky {
  geometry {
    primitive: sphere;
    radius: 5000;
    segmentsHeight: 20;
    segmentsWidth: 64;
  }
  material {
    shader: flat;
  }
  scale: -1 1 1;
}

left {
  position: -1 0 0;
}

right {
  position: 1 0 0;
}

hidden {
  visible: false;
}
