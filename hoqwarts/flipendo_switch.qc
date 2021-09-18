
string FLIPENDO_SWITCH_FLIP = "puzzle/flipendo_switch_2.wav"; 

enumflags FlipendoSwitchSpawnflags {
  FLIPENDO_SWITCH_AXIS_X
};

enum FlipendSwitchState {
  Initial,
  Moving,
  Pressed
};

void () hoqwarts_func_flipendo_switch_done = {
  self.state = FlipendSwitchState::Pressed;
  SUB_UseTargets();
};

FlipendoResult (vector normal) hoqwarts_func_flipendo_switch_cast = {
  if (self.state == FlipendSwitchState::Pressed) {
    return FlipendoResult::Failure;
  }

  self.state = FlipendSwitchState::Moving;

  sound(self, CHAN_VOICE, FLIPENDO_SWITCH_FLIP, 1, ATTN_NORM);
  vector rotation_vector = self.spawnflags & FLIPENDO_SWITCH_AXIS_X ? '180 0 0' : '0 180 0';
  SUB_CalcAngleMove(rotation_vector, 240, hoqwarts_func_flipendo_switch_done);

  return FlipendoResult::Success;
};

void () hoqwarts_func_flipendo_switch = {
  if (SUB_Inhibit()) {
    return;
  }

  self.state = FlipendSwitchState::Initial;
  precache_sound(FLIPENDO_SWITCH_FLIP);

  self.movetype = MOVETYPE_PUSH;
	self.solid = SOLID_BSP;
	setmodel(self, self.model);
  setorigin(self, self.origin);

  self.flipendo = hoqwarts_func_flipendo_switch_cast;
};
