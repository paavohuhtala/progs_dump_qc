.float cube_moving;
.entity current_dest;
.string initial_dest;

string FLIPENDO_CUBE_MOVE = "puzzle/flipendo_block_move_2.wav"; 
string FLIPENDO_CUBE_TRAP = "puzzle/floor_button_push.wav";

void () hoqwarts_flipendo_cube_finally = {
  self.cube_moving = FALSE;

  entity old_self = self;
  self = self.current_dest;
  SUB_UseTargets();
  self = old_self;
};

void () hoqwarts_flipendo_after_trap_move = {
  hoqwarts_flipendo_cube_finally();
};

void () hoqwarts_flipendo_after_move = {
  if (self.current_dest.spawnflags & FlipendoDestSpawnflags::FLIPENDO_DEST_TRAP) {
    vector new_origin = self.current_dest.origin;
    new_origin.z -= self.current_dest.depth;
    sound(self, CHAN_VOICE, FLIPENDO_CUBE_TRAP, 1, ATTN_NORM);
    SUB_CalcMove(new_origin, 90, hoqwarts_flipendo_cube_finally);
  }
  else {
    hoqwarts_flipendo_cube_finally();
  }
};

vector (entity current_dest, vector normal, float size) hoqwarts_get_flipendo_dest = {
  vector inverted = -normal;

  if (inverted == '1 0 0' || inverted == '-1 0 0' || inverted == '0 1 0' || inverted == '0 -1 0') {
    return (inverted * size) + current_dest.origin;
  }

  return current_dest.origin;
};

FlipendoResult (vector normal) hoqwarts_flipendo_cube_cast = {
  if (self.cube_moving || self.current_dest.spawnflags & FlipendoDestSpawnflags::FLIPENDO_DEST_TRAP) {
    return FlipendoResult::Failure;
  }

  if (normal_z != 0) {
    return FlipendoResult::Failure;
  }

  // We can't use self.size.x here because for reason it's 2x too big
  vector target_pos = hoqwarts_get_flipendo_dest(self.current_dest, normal, self.t_width);

  if (target_pos == self.current_dest.origin) {
    return FlipendoResult::Success;
  }

  // The other origin is always within 2*t_width of current origin
  // (it's actually even closer because Pythagoras theorem but we don't care)
  entity dest = findradius(self.origin, self.t_width * 2);
  
  while (dest) {
    if (dest.classname == "hoqwarts_flipendo_dest" && dest.origin == target_pos) {
      self.cube_moving = TRUE;
      self.current_dest = dest;
      sound(self, CHAN_VOICE, FLIPENDO_CUBE_MOVE, 1, ATTN_NORM);
      SUB_CalcMove(dest.origin, 150, hoqwarts_flipendo_after_move);
      return FlipendoResult::Success;
    }

    dest = dest.chain;
  }
  return FlipendoResult::Success;
};

entity (vector location) hoqwarts_find_flipendo_dest = {
  entity dest = find(world, classname, "hoqwarts_flipendo_dest");

  while (dest) {
    dest = find(dest, classname, "hoqwarts_flipendo_dest");

    if (dest.origin == location) {
      return dest;
    }
  }

  return world;
}

void () hoqwarts_func_flipendo_cube_link_dest = {
  self.current_dest = find(world, targetname, self.initial_dest);

  if (!self.current_dest || self.current_dest == world) {
    objerror(strcat("Couldn't find target ", self.initial_dest));
  }

  self.think = SUB_Null;
};

void () hoqwarts_func_flipendo_cube = {
  if (SUB_Inhibit()) {
		return;
	}

  if (!self.initial_dest) {
    objerror("hoqwarts_func_flipendo without initial_dest");
    return;
  }

  if (self.size.x != self.size.y) {
    objerror("hoqwarts_func_flipendo_cube with non-square size");
    return;
  }

  precache_sound(FLIPENDO_CUBE_MOVE);
  precache_sound(FLIPENDO_CUBE_TRAP);

	self.solid = SOLID_BSP;
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_PUSH;
	self.classname = "hoqwarts_flipendo_cube";
  setmodel(self, self.model);
	setorigin(self, self.origin);

  self.think = hoqwarts_func_flipendo_cube_link_dest;
  self.nextthink = time + 0.1;

  self.flipendo = hoqwarts_flipendo_cube_cast;
  self.cube_moving = FALSE;
};
