# Neoindent

Simple indentation text object and indentation movements.

Customize key maps like this:

```lua
{ "niilohlin/neoindent",
  config = function()
    require("neoindent").setup({
      up = "[i",
      down = "]i",
      object = "ii",
    })
  end,
}
```
