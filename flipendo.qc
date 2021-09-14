
.float cube_moving;
.entity current_dest;
.string initial_dest;

float FLIPENDO_DEST_X_PLUS = 1;
float FLIPENDO_DEST_X_MINUS = 2;
float FLIPENDO_DEST_Y_PLUS = 4;
float FLIPENDO_DEST_Y_MINUS = 8;

void () hoqwarts_flipendo_dest = {
  if (SUB_Inhibit ()) {
    return;
  }

  self.classname = "hoqwarts_flipendo_dest";
};

void () hoqwarts_flipendo_after_move = { 
  self.cube_moving = FALSE;
};

vector (entity current_dest, vector normal) hoqwarts_get_flipendo_dest = {
  local vector inverted = -normal;

  if (inverted == '1 0 0' && current_dest.spawnflags & FLIPENDO_DEST_X_PLUS) {
    return current_dest.origin + '64 0 0';
  }
  else if (inverted == '-1 0 0' && current_dest.spawnflags & FLIPENDO_DEST_X_MINUS) {
    return current_dest.origin + '-64 0 0';
  }
  else if (inverted == '0 1 0' && current_dest.spawnflags & FLIPENDO_DEST_Y_PLUS) {
    return current_dest.origin + '0 64 0';
  }
  else if (inverted == '0 -1 0' && current_dest.spawnflags & FLIPENDO_DEST_Y_MINUS) {
    return current_dest.origin + '0 -64 0';
  }
  else {
    return current_dest.origin;
  }
};

void (entity this, vector normal) hoqwarts_flipendo_cast = {
  if (this.cube_moving) {
    return;
  }

  local vector target_pos = hoqwarts_get_flipendo_dest(this.current_dest, normal);

  if (target_pos == this.current_dest.origin) {
    return;
  }

  local entity dest = find(world, classname, "hoqwarts_flipendo_dest");

  while (dest) {
    if (dest.origin == target_pos) {
      this.cube_moving = TRUE;
      this.current_dest = dest;
      SUB_CalcMoveEnt(this, dest.origin, 150, hoqwarts_flipendo_after_move);
      return;
    }

    dest = find(dest, classname, "hoqwarts_flipendo_dest");
  }

};

entity (vector location) hoqwarts_find_flipendo_dest = {
  local entity dest = find(world, classname, "hoqwarts_flipendo_dest");

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

void () hoqwarts_func_flipendo = {
  if (SUB_Inhibit()) {
		return;
	}

  if (!self.initial_dest) {
    objerror("hoqwarts_func_flipendo without initial_dest");
    return;
  }

	self.solid = SOLID_BSP;
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_PUSH;
	self.classname = "hoqwarts_flipendo_cube";
  setmodel(self, self.model);
	setorigin(self, self.origin);

  self.think = hoqwarts_func_flipendo_link_dest;
  self.nextthink = time + 0.1;

  self.cube_moving = FALSE;
};

