enum FlipendoResult {
  Success,
  Failure
};

.FlipendoResult(vector normal) flipendo;

.float cube_moving;
.entity current_dest;
.string initial_dest;

enumflags FlipendoSwitchSpawnflags {
  FLIPENDO_SWITCH_AXIS_X
};

enum FlipendoButtonState {
  Initial,
  Moving,
  Pressed
};

string FLIPENDO_CUBE_MOVE = "puzzle/flipendo_block_move_2.wav"; 
string FLIPENDO_SWITCH_FLIP = "puzzle/flipendo_switch_2.wav"; 

void () hoqwarts_flipendo_dest = {
  if (SUB_Inhibit ()) {
    return;
  }

  self.classname = "hoqwarts_flipendo_dest";
};

void () hoqwarts_flipendo_after_move = { 
  self.cube_moving = FALSE;
};

vector (entity current_dest, vector normal, float size) hoqwarts_get_flipendo_dest = {
  vector inverted = -normal;

  if (inverted == '1 0 0' || inverted == '-1 0 0' || inverted == '0 1 0' || inverted == '0 -1 0') {
    return (inverted * size) + current_dest.origin;
  }

  return current_dest.origin;
};

FlipendoResult (vector normal) hoqwarts_flipendo_cube_cast = {
  if (self.cube_moving) {
    return FlipendoResult::Failure;
  }

  if (normal_z != 0) {
    dprint("Hit flipendo cube on top/bottom face -> NOP\n");
    return FlipendoResult::Failure;
  }

  // We can't use self.size.x here because for reason it's 2x too big
  vector target_pos = hoqwarts_get_flipendo_dest(self.current_dest, normal, self.t_width);

  if (target_pos == self.current_dest.origin) {
    return FlipendoResult::Success;
  }

  entity dest = find(world, classname, "hoqwarts_flipendo_dest");

  while (dest) {
    if (dest.origin == target_pos) {
      self.cube_moving = TRUE;
      self.current_dest = dest;
      SUB_CalcMove(dest.origin, 150, hoqwarts_flipendo_after_move);
      return FlipendoResult::Success;
    }

    dest = find(dest, classname, "hoqwarts_flipendo_dest");
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

void () hoqwarts_func_flipendo_link_dest = {
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

	self.solid = SOLID_BSP;
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_PUSH;
	self.classname = "hoqwarts_flipendo_cube";
  setmodel(self, self.model);
	setorigin(self, self.origin);

  self.think = hoqwarts_func_flipendo_link_dest;
  self.nextthink = time + 0.1;

  self.flipendo = hoqwarts_flipendo_cube_cast;
  self.cube_moving = FALSE;
};

void () hoqwarts_func_flipendo_switch_done = {
  self.state = FlipendoButtonState::Pressed;
  SUB_UseTargets();
};

FlipendoResult (vector normal) hoqwarts_func_flipendo_switch_cast = {
  if (self.state == FlipendoButtonState::Pressed) {
    return FlipendoResult::Failure;
  }

  self.state = FlipendoButtonState::Moving;

  sound(self, CHAN_VOICE, FLIPENDO_SWITCH_FLIP, 1, ATTN_NORM);
  vector rotation_vector = self.spawnflags & FLIPENDO_SWITCH_AXIS_X ? '180 0 0' : '0 180 0';
  SUB_CalcAngleMove(rotation_vector, 240, hoqwarts_func_flipendo_switch_done);

  return FlipendoResult::Success;
};

void () hoqwarts_func_flipendo_switch = {
  if (SUB_Inhibit()) {
    return;
  }

  self.state = FlipendoButtonState::Initial;
  precache_sound(FLIPENDO_SWITCH_FLIP);

  self.movetype = MOVETYPE_PUSH;
	self.solid = SOLID_BSP;
	setmodel(self, self.model);
  setorigin(self, self.origin);

  self.flipendo = hoqwarts_func_flipendo_switch_cast;
};
