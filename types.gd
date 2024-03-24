class_name Types

class NumericRange:
   var lower: float = 0.0
   var upper: float = 1.0
   
   func _init(lower_bound: float = 0.0, upper_bound: float = 1.0):
      self.lower = lower_bound
      self.upper = upper_bound
      
   func contains(value: float, bound_inclusive: bool = true):
      if bound_inclusive:
         return value <= upper and value >= lower
      else:
         return value < upper and value > lower
