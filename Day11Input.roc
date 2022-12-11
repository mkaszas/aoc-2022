interface Day11Input
    exposes [input]
    imports []

# I'm too lazy to write a parser for this...
input = [
    { items: [66, 79], operation: \old -> old * 11, divCheck: 7, next: \pred -> if pred then 6 else 7, inspected: 0 },
    { items: [84, 94, 94, 81, 98, 75], operation: \old -> old * 17, divCheck: 13, next: \pred -> if pred then 5 else 2, inspected: 0 },
    { items: [85, 79, 59, 64, 79, 95, 67], operation: \old -> old + 8, divCheck: 5, next: \pred -> if pred then 4 else 5, inspected: 0 },
    { items: [70], operation: \old -> old + 3, divCheck: 19, next: \pred -> if pred then 6 else 0, inspected: 0 },
    { items: [57, 69, 78, 78], operation: \old -> old + 4, divCheck: 2, next: \pred -> if pred then 0 else 3, inspected: 0 },
    { items: [65, 92, 60, 74, 72], operation: \old -> old + 7, divCheck: 11, next: \pred -> if pred then 3 else 4, inspected: 0 },
    { items: [77, 91, 91], operation: \old -> old * old, divCheck: 17, next: \pred -> if pred then 1 else 7, inspected: 0 },
    { items: [76, 58, 57, 55, 67, 77, 54, 99], operation: \old -> old + 6, divCheck: 3, next: \pred -> if pred then 2 else 1, inspected: 0 },
]
