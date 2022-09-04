# Deltarune Loader

A Deltarune save loader library for Kristal.

## Usage

With the library installed, run `DeltaruneLoader.load(filter)` early in your mod:

```lua
function Mod:init()
  -- Loads all Deltarune saves from Chapter 2
  DeltaruneLoader.load({chapter = 2})
end
```

The `filter` argument can be specified to load only the saves needed, rather than load all deltarune saves. It has the following options:
- `chapter`: The Deltarune chapter to load the saves from.
- `slot`: Which save file slot to load.
- `completed`: Whether to only load completion saves or not.

After loading, run either `DeltaruneLoader.getSave(chapter, slot)` or `DeltaruneLoader.getCompletion(chapter, slot)` to get the save data:

```lua
function Mod:load(data, new_file, slot)
  if not new_file then return end

  -- Get the Deltarune Chapter 2 completion save from the current save slot
  local save = DeltaruneLoader.getCompletion(2, slot)
  
  if save then
    -- Use the Deltarune save name
    self.save_name = save.name
    -- Print whether you've beaten Jevil
    print("Beaten up a clown: " .. tostring(save.beat_jevil))
  end
end
```

This returns a [`DeltaruneSave`](scripts/globals/DeltaruneSave.lua) instance (there are a lot of variables; check the source for a full list!)
