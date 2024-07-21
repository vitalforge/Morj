---
title: Classes
sidebar_position: 2
---

# Classes
```morj
class MyClass { /*...*/ }
```

# Getters and Setters
```morj {8}
class MyClass {
	privateField = 11
	
	firstPublicField: Int = 32	
		get = (v) -> v
		set = (field, v) ->  field.setValue(v)
	// The same can be written shorter:
	pub secondPublicField: Int = 32
}
```

```morj {5}
class MyClass {
	// You can omit the field type if it has an initial value
	firstReadOnlyField = 16; get
	// The same can be written shorter:
	pub final secondReadOnlyField = 16
}

```


# Constructors
```morj
class MyClass {
	field: String

	constructor(prop: String = "Default Value" ) {
		this.field = prop;
	}
}
```
The same can be written shorter:
```morj {1}
class MyClass(field: String)
```