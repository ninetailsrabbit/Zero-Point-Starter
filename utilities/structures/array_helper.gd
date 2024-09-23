class_name ArrayHelper

	
## Flatten any array with n dimensions recursively
static func flatten(array: Array):
	var result := []
	
	for i in array.size():
		if typeof(array[i]) >= TYPE_ARRAY:
			result.append_array(flatten(array[i]))
		else:
			result.append(array[i])

	return result


static func pick_random_values(array: Array, items_to_pick: int = 1, duplicates: bool = true) -> Array:
	var result := []
	var target = flatten(array.duplicate())
	target.shuffle()
	
	items_to_pick = min(target.size(), items_to_pick)
	
	for i in range(items_to_pick):
		var item = target.pick_random()
		result.append(item)

		if not duplicates:
			target.erase(item)
		
	return result
	

static func remove_duplicates(array: Array) -> Array:
	var cleaned_array := []
	
	for element in array:
		if not cleaned_array.has(element):
			cleaned_array.append(element)
		
	return cleaned_array
	
	
static func remove_falsy_values(array: Array) -> Array:
	var cleaned_array := []
	
	for element in array:
		if element:
			cleaned_array.append(element)
		
	return cleaned_array
	
	
static func middle_element(array: Array):
	if array.size() > 2:
		return array[floor(array.size() / 2.0)]
		
	return null
	

## To detect if a contains elements of b
static func intersects(a: Array, b: Array) -> bool:
	for e: Variant in a:
		if b.has(e):
			return true
			
	return false


static func chunk(array: Array, size: int):
	var result = []
	var i = 0
	var j = -1
	
	for element in array:
		if i % size == 0:
			result.push_back([])
			j += 1
			
		result[j].push_back(element)
		i += 1
		
	return result