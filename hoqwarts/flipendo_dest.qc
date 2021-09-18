.float depth;

enumflags FlipendoDestSpawnflags {
  FLIPENDO_DEST_TRAP
};

void () hoqwarts_flipendo_dest = {
  if (SUB_Inhibit ()) {
    return;
  }

  self.classname = "hoqwarts_flipendo_dest";
  self.solid = SOLID_TRIGGER;
  setorigin(self, self.origin);
};
