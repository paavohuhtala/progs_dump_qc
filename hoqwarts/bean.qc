
string PICKUP_BEAN_SOUND = "item/pickup11.wav";
float NUMBER_OF_BEAN_SKINS = 7;

void () hoqwarts_item_bean_touch = {
  if (other.classname != "player") {
    return;
  }

  sound(self, CHAN_VOICE, PICKUP_BEAN_SOUND, 1, ATTN_NORM);
  particle(self.origin, '0 0 1', 15, 16);
  remove(self);
};

void () hoqwarts_item_bean = {
  if (SUB_Inhibit()) {
    return;
  }

  precache_sound(PICKUP_BEAN_SOUND);
  precache_model("progs/bean.mdl");

  self.solid = SOLID_TRIGGER;
  setsize(self, '-16 -16 0', '16 16 32');
  setmodel(self, "progs/bean.mdl");
  setorigin(self, self.origin);
  self.skin = random() * NUMBER_OF_BEAN_SKINS;

  self.touch = hoqwarts_item_bean_touch;
};
