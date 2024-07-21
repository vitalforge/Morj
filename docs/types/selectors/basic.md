---
title: Basic
sidebar_position: 1
---

```morj
# Selectors are created in the same way as in Minecraft
whiteSheeps = @e[type=sheep, nbt={Color:0b}]
```

# Additional selector designs

:::tip
*You can combine these and the order doesn't matter*
```morj {1}
flyingPigs = @e:pig'withWings
# The same can be written in native form
flyingPigs = @e[type=pig, tag=withWings]
```
:::