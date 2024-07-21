---
title: Interfaces
sidebar_position: 3
---

# Interfaces
```morj
interface MyInterface {
	foo()
	fooWithDefaultBody() {
		// body
	}
}
```

# Implementing interfaces
```morj
class InterfaceImpl : MyInterface {
	override foo() {
		// Body
	}
}
```







<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
# Methods
```morj
myMethod(param: ParamType = DefaultValue): ReturnType {
	return ReturnType(param)
}
```
If a method does not need a body, it can be written in a much simpler way:
```morj {3}
myMethod(param: ParamType = DefaultValue): ReturnType = ReturnType(param)
# Or a little shorter
myMethod(param: ParamType = DefaultValue) = ReturnType(param)
```

