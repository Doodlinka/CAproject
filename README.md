# Олешко Дар'я, КН, 5 група, Варіант 3

Possible optimisations:

- use a different DS (trie of some kind?) for efficient updating? but keep this list (at least the ids) cuz i'll have to iterate over it?
- use a heap of not maximum size, malloc if more is needed. allocate all strings (\n-terminated) and nodes on that heap
- replace ints with shorts?
- make the data point store sum and count, if it's practical to divide them all later

TODO: specify these

- which symbols exactly can be part of the id
- can the id be an empty string
