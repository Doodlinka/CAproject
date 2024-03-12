# Олешко Дар'я, КН, 5 група, Варіант 3

- Прочитати з stdin N рядків до появи EOF (максимум 10000 рядків).
- Рядки розділяються АБО послідовністю байтів 0x0D та 0x0A (CR LF), або одним символом - 0x0D чи 0x0A.
- Кожен рядок це пара "key value" (розділяються пробілом), де ключ - це текстовий ідентифікатор макс 16 символів (будь-які символи окрім white space chars - пробілу чи переводу на новий рядок), а значення - це десяткове ціле знакове число в діапазоні [-10000, 10000].
- Провести групування: заповнити два масиви (або масив структур з 2х значень) для зберігання пари key та average , які будуть включати лише унікальні значення key а average - це средне значення, обраховане для всіх value, що відповідають конкретному значенню key.
- Відсортувати алгоритмом bubble sort за average, та вивести в stdout  значення key від більших до менших (average desc), кожен key окремим рядком.
- Якщо merge sort - буде додатковий бал

Possible optimisations:

- use a different DS (trie of some kind?) for efficient updating? but keep this list (at least the ids) cuz i'll have to iterate over it?
- use a heap of not maximum size, malloc if more is needed. allocate all strings (\n-terminated) and nodes on that heap
- replace ints with shorts?
- make the data point store sum and count, if it's practical to divide them all later

TODO: specify these

- which symbols exactly can be part of the id
- can the id be an empty string
