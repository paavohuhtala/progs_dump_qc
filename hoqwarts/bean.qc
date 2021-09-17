
string PICKUP_BEAN_SOUND = "item/pickup11.wav";

void () hoqwarts_item_bean_touch = {
  if (other.classname != "player") {
    return;
  }

  sound(self, CHAN_VOICE, PICKUP_BEAN_SOUND, 1, ATTN_NORM);
  remove(self);
};

void () hoqwarts_item_bean = {
  if (SUB_Inhibit()) {
    return;
  }

  self.solid = SOLID_TRIGGER;
  setsize(self, '-16 -16 0', '16 16 32');
  setmodel(self, "progs/bean.mdl");
  setorigin(self, self.origin);
  self.touch = hoqwarts_item_bean_touch;
  precache_sound(PICKUP_BEAN_SOUND);
};
