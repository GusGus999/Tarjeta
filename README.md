# Validador de números de tarjeta en Haskell



**Qué hace, paso a paso:**

1. Muestra un mensaje pidiendo el número de tarjeta.
2. Lee lo que el usuario escribe. Se recibe como **texto**, no como número.
3. Quita los espacios del texto, para aceptar entradas como `4539 5787 6362 8`.
4. Comprueba que el texto contenga **solo dígitos** y que tenga exactamente **16 caracteres**, que es la longitud estándar de las tarjetas más comunes (Visa, Mastercard, etc.).
5. Convierte cada caracter en un número entero y arma una lista de dígitos.
6. Aplica el **algoritmo de Luhn** sobre esa lista.
7. Imprime `Tarjeta valida` o `Tarjeta no valida`.

**Características del programa:**

- Está escrito en Haskell, un lenguaje funcional.
- La parte principal del algoritmo se resuelve con **recursividad**, **ajuste de patrones** y **guardas**.
- Acepta espacios entre grupos de dígitos (por ejemplo `4539 5787 6362 8`).
- Rechaza entradas con letras, símbolos o que no tengan exactamente 16 dígitos.


## Algoritmo de Luhn

### Qué es

El algoritmo de Luhn fue creado por Hans Peter Luhn, ingeniero de IBM, en 1954. Es una fórmula de suma de comprobación que se usa para detectar **errores de captura** en identificadores numéricos, como:

- Números de tarjetas de crédito y débito.
- Números IMEI de teléfonos celulares.
- Otros números de identificación.

### Idea principal

El **último dígito** de una tarjeta es un **dígito verificador**: no es un número cualquiera, sino que se calcula a partir de todos los demás dígitos. Al aplicar el algoritmo sobre el número completo, el resultado debe cerrar en un múltiplo de 10. Si alguien se equivoca al escribir un dígito, el resultado deja de cerrar y el error se detecta.

### Pasos

1. Se recorre el número de **derecha a izquierda**.
2. El primer dígito (el último de la tarjeta) **se deja igual**.
3. El segundo dígito **se duplica**.
4. El tercero se deja igual, el cuarto se duplica, y así se va alternando.
5. Si al duplicar un dígito el resultado es **mayor que 9**, se le **resta 9**.
6. Se **suman** todos los dígitos que resultaron.
7. Si el total es **múltiplo de 10**, el número es **válido**. Si no, es inválido.

### Por qué se resta 9

Cuando un dígito duplicado pasa de 9, el resultado tiene dos cifras. El algoritmo original pide sumar esas dos cifras. Por ejemplo, 7 × 2 = 14, y 1 + 4 = 5. Restar 9 da el mismo resultado: 14 − 9 = 5. Es un atajo más fácil de programar.

| Dígito | Doble | Resultado final |
|---|---|---|
| 5 | 10 | 10 − 9 = **1** |
| 6 | 12 | 12 − 9 = **3** |
| 7 | 14 | 14 − 9 = **5** |
| 8 | 16 | 16 − 9 = **7** |
| 9 | 18 | 18 − 9 = **9** |

### Qué errores detecta

- Un dígito mal escrito (siempre lo detecta).
- Dos dígitos vecinos intercambiados, por ejemplo `43` en lugar de `34` (casi siempre).

### Ejemplo completo: `4539 5787 6362 8`

**Paso 1.** Se quitan los espacios: `4539578763628` (13 dígitos).

**Paso 2.** Se voltea el número para empezar por la derecha:

```
8 2 6 3 6 7 8 7 5 9 3 5 4
```

**Paso 3.** Se alterna entre dejar igual y duplicar:

| Posición | Dígito | Acción | Cálculo | Resultado |
|---|---|---|---|---|
| 1 | 8 | igual | 8 | 8 |
| 2 | 2 | duplicar | 2 × 2 = 4 | 4 |
| 3 | 6 | igual | 6 | 6 |
| 4 | 3 | duplicar | 3 × 2 = 6 | 6 |
| 5 | 6 | igual | 6 | 6 |
| 6 | 7 | duplicar | 7 × 2 = 14, 14 − 9 | 5 |
| 7 | 8 | igual | 8 | 8 |
| 8 | 7 | duplicar | 7 × 2 = 14, 14 − 9 | 5 |
| 9 | 5 | igual | 5 | 5 |
| 10 | 9 | duplicar | 9 × 2 = 18, 18 − 9 | 9 |
| 11 | 3 | igual | 3 | 3 |
| 12 | 5 | duplicar | 5 × 2 = 10, 10 − 9 | 1 |
| 13 | 4 | igual | 4 | 4 |

**Paso 4.** Se suman los resultados:

```
8 + 4 + 6 + 6 + 6 + 5 + 8 + 5 + 5 + 9 + 3 + 1 + 4 = 70
```

**Paso 5.** Se comprueba si el total es múltiplo de 10:

```
70 ÷ 10 = 7, residuo 0   →   múltiplo de 10   →   VÁLIDA
```

### Ejemplo con un número inválido: `4539 5787 6362 9`

Solo cambia el último dígito, de 8 a 9. Ese dígito queda en la posición 1, donde se deja igual, así que aporta 9 en lugar de 8. El total pasa a ser **71**:

```
71 ÷ 10 = 7, residuo 1   →   no es múltiplo de 10   →   NO VÁLIDA
```

---

## Explicación de cada función

El programa tiene cuatro funciones: `duplica`, `sumaLuhn`, `esValida` y `main`.

| Función | Firma | Qué hace |
|---|---|---|
| `duplica` | `Int -> Int` | Duplica un dígito y resta 9 si pasa de 9. |
| `sumaLuhn` | `[Int] -> Bool -> Int` | Recorre los dígitos de forma recursiva y devuelve la suma de Luhn. |
| `esValida` | `[Int] -> Bool` | Voltea la lista, calcula la suma y revisa si es múltiplo de 10. |
| `main` | `IO ()` | Lee la entrada, quita espacios, verifica que sean exactamente 16 dígitos y muestra el resultado. |

### `import Data.Char (isDigit, digitToInt)`

Importa dos funciones del módulo `Data.Char`:

- `isDigit`: recibe un caracter y devuelve `True` si es un dígito. Por ejemplo, `isDigit '7'` da `True` y `isDigit 'a'` da `False`.
- `digitToInt`: convierte un caracter dígito en el número entero correspondiente. Por ejemplo, `digitToInt '7'` da `7`.

Son necesarias porque la entrada llega como texto y para hacer la suma se necesitan números.

---

### `duplica`

```haskell
duplica :: Int -> Int
duplica d
  | d * 2 > 9 = d * 2 - 9
  | otherwise = d * 2
```

**Qué recibe:** un dígito `d` (un entero del 0 al 9).

**Qué devuelve:** el doble del dígito. Si el doble es mayor que 9, devuelve el doble menos 9.

**Cómo funciona:**

- Usa **guardas** (las barras `|`). Haskell las revisa de arriba hacia abajo y ejecuta la primera cuya condición dé `True`.
- La primera guarda pregunta si `d * 2 > 9`. Si es así, devuelve `d * 2 - 9`.
- La segunda guarda, `otherwise`, significa "en cualquier otro caso" y siempre se cumple. Devuelve `d * 2`.

**Ejemplos:**

| Llamada | Cálculo | Guarda que se cumple | Resultado |
|---|---|---|---|
| `duplica 3` | 3 × 2 = 6, 6 > 9 es falso | `otherwise` | `6` |
| `duplica 4` | 4 × 2 = 8, 8 > 9 es falso | `otherwise` | `8` |
| `duplica 7` | 7 × 2 = 14, 14 > 9 es verdadero | la primera | `14 - 9 = 5` |
| `duplica 9` | 9 × 2 = 18, 18 > 9 es verdadero | la primera | `18 - 9 = 9` |

---

### `sumaLuhn`

```haskell
sumaLuhn :: [Int] -> Bool -> Int
sumaLuhn [] _ = 0
sumaLuhn (x:xs) duplicar
  | duplicar == True  = duplica x + sumaLuhn xs False
  | duplicar == False = x + sumaLuhn xs True
```

Es la función principal del algoritmo. Es **recursiva**: se llama a sí misma con un problema más pequeño en cada paso.

**Qué recibe (dos valores, en este orden):**

1. Una **lista de enteros** (`[Int]`): los dígitos que faltan por procesar.
2. Un **booleano** (`Bool`), llamado `duplicar`: indica si al primer dígito de la lista le toca duplicarse. `True` significa "duplícalo" y `False` significa "déjalo igual".

**Qué devuelve:** un entero (`Int`) con la suma de Luhn de la lista recibida.

**Cómo está definida: dos casos con ajuste de patrones**

Haskell compara los valores recibidos con cada ecuación, de arriba hacia abajo, y usa la primera que coincide.

**Caso 1: `sumaLuhn [] _ = 0`**

- El patrón `[]` coincide solo con la **lista vacía**.
- El guion bajo `_` coincide con cualquier valor; aquí no importa si `duplicar` es `True` o `False`, porque ya no hay dígitos.
- Devuelve `0`, porque la suma de ningún dígito es cero.
- Es el **caso base**: no se llama a sí misma, así que la recursión se detiene. Sin él, la función no sabría cuándo parar.

**Caso 2: `sumaLuhn (x:xs) duplicar`**

- El patrón `(x:xs)` coincide con una lista de **al menos un elemento** y la separa en dos partes: `x` es el primer dígito y `xs` es el resto de la lista.
- `duplicar` recibe el valor booleano.
- Aquí se usan dos guardas:
  - `duplicar == True`: duplica el dígito con `duplica x`, le suma lo que devuelva `sumaLuhn xs False` y manda `False` a la siguiente llamada.
  - `duplicar == False`: deja el dígito igual (`x`), le suma lo que devuelva `sumaLuhn xs True` y manda `True` a la siguiente llamada.

**Cómo se alterna:** cada llamada le manda a la siguiente el valor contrario del que recibió. Así los dígitos van quedando igual, duplicados, igual, duplicados...

**Cómo se arma la suma:** no hay ninguna variable que guarde el total. La suma se construye al regresar de la recursión. Primero las llamadas bajan hasta la lista vacía, dejando sumas pendientes. Cuando el caso base devuelve `0`, cada llamada anterior recibe el número de la siguiente y le suma su dígito.

**Ejemplo: `sumaLuhn [8,2,6] False`**

*Bajada (se dejan sumas pendientes):*

| Llamada | Lista | `duplicar` | Patrón y guarda | Resultado parcial |
|---|---|---|---|---|
| 1 | `[8,2,6]` | `False` | `(x:xs)`, `x = 8`, guarda `False` | `8 + sumaLuhn [2,6] True` |
| 2 | `[2,6]` | `True` | `(x:xs)`, `x = 2`, guarda `True` | `duplica 2 + sumaLuhn [6] False` = `4 + ...` |
| 3 | `[6]` | `False` | `(x:xs)`, `x = 6`, guarda `False` | `6 + sumaLuhn [] True` |
| 4 | `[]` | `True` | patrón `[]` | `0` |

*Regreso (se completan las sumas):*

```
Llamada 4 devuelve 0
Llamada 3 devuelve 6 + 0  = 6
Llamada 2 devuelve 4 + 6  = 10
Llamada 1 devuelve 8 + 10 = 18
```

Expresión completa: `8 + (4 + (6 + 0)) = 18`.

---

### `esValida`

```haskell
esValida :: [Int] -> Bool
esValida digitos = mod total 10 == 0
  where total = sumaLuhn (reverse digitos) False
```

**Qué recibe:** la lista de dígitos del número, en el orden en que se escribió.

**Qué devuelve:** `True` si el número es válido y `False` si no lo es.

**Cómo funciona:**

1. `reverse digitos` voltea la lista, porque el algoritmo empieza por el dígito de la derecha.
2. Llama a `sumaLuhn` con la lista volteada y con `False` como valor inicial de `duplicar`. Es `False` porque el primer dígito (el último de la tarjeta) se deja igual.
3. El resultado de `sumaLuhn` se guarda en el nombre `total`. La palabra `where` indica "`total` se calcula así".
4. `mod total 10` da el residuo de dividir `total` entre 10.
5. `== 0` compara ese residuo con 0. Si es 0, el total es múltiplo de 10 y la función devuelve `True`.

**Nota sobre el orden:** aunque la línea de `mod total 10 == 0` está escrita antes que la de `where`, Haskell primero calcula `total` y después hace la comparación.

**Ejemplo con `[4,5,3,9,5,7,8,7,6,3,6,2,8]`:**

| Paso | Operación | Valor |
|---|---|---|
| 1 | `reverse digitos` | `[8,2,6,3,6,7,8,7,5,9,3,5,4]` |
| 2 | `sumaLuhn` de esa lista con `False` | `70` |
| 3 | `mod 70 10` | `0` |
| 4 | `0 == 0` | `True` |

---

### `main`

```haskell
main :: IO ()
main = do
  putStrLn "Ingresa el numero de tarjeta:"
  entrada <- getLine
  let numero = filter (/= ' ') entrada
  if not (all isDigit numero) || length numero /= 16
    then putStrLn "Entrada no valida: usa solo 16 digitos"
    else if esValida (map digitToInt numero)
      then putStrLn "Tarjeta valida"
      else putStrLn "Tarjeta no valida"
```

Es el punto de entrada del programa. El bloque `do` ejecuta los pasos en orden.

| Línea | Qué hace |
|---|---|
| `putStrLn "Ingresa el numero de tarjeta:"` | Muestra el mensaje en pantalla. |
| `entrada <- getLine` | Espera a que el usuario escriba y presione Enter. Guarda lo escrito como texto en `entrada`. |
| `let numero = filter (/= ' ') entrada` | Crea `numero` quitando los espacios de `entrada`. `filter` conserva solo los caracteres distintos de espacio. |
| `if not (all isDigit numero) \|\| length numero /= 16` | Revisa dos condiciones unidas por `\|\|` ("o"): que haya algún caracter que no sea dígito, o que la longitud no sea exactamente 16. Si alguna es cierta, la entrada es incorrecta. |
| `then putStrLn "Entrada no valida: usa solo 16 digitos"` | Si la entrada es incorrecta, muestra el aviso. |
| `else if esValida (map digitToInt numero)` | Si la entrada es correcta, convierte cada caracter en número con `map digitToInt` y llama a `esValida`. |
| `then putStrLn "Tarjeta valida"` | Si `esValida` devuelve `True`. |
| `else putStrLn "Tarjeta no valida"` | Si `esValida` devuelve `False`. |

**Ejemplo con `4539 5787 6362 8`:**

```
entrada = "4539 5787 6362 8"
numero  = "4539578763628"
```

> **Nota:** `"4539578763628"` tiene 13 caracteres, por lo que **no pasaría** la validación `length numero /= 16`. Para probar este ejemplo, el número debe tener exactamente 16 dígitos (sin espacios), por ejemplo `4111111111111111`.

---

## Corrida detallada con una tarjeta válida

Esta sección muestra exactamente cómo evalúa el programa la entrada `4111111111111111`, paso a paso, función por función.

---

### Paso 1 — `main` muestra el mensaje y lee la entrada

```
putStrLn "Ingresa el numero de tarjeta:"
→ imprime en pantalla: Ingresa el numero de tarjeta:

entrada <- getLine
→ el usuario escribe: 4111111111111111
→ entrada = "4111111111111111"
```

---

### Paso 2 — `filter` quita los espacios

```haskell
let numero = filter (/= ' ') entrada
```

```
filter (/= ' ') "4111111111111111"
→ no hay espacios, la cadena no cambia
→ numero = "4111111111111111"
```

---

### Paso 3 — Validación de la entrada

```haskell
if not (all isDigit numero) || length numero /= 16
```

Se evalúan las dos condiciones:

| Condición | Evaluación | Resultado |
|---|---|---|
| `all isDigit "4111111111111111"` | todos son dígitos | `True` |
| `not True` | niega el resultado | `False` |
| `length "4111111111111111" /= 16` | tiene 16, 16 ≠ 16 es falso | `False` |
| `False \|\| False` | ninguna condición se cumple | `False` |

El `if` da `False` → **la entrada es válida**, se pasa al `else`.

---

### Paso 4 — `map digitToInt` convierte el texto en lista de números

```haskell
map digitToInt "4111111111111111"
```

Aplica `digitToInt` a cada caracter:

```
'4' → 4
'1' → 1
'1' → 1
'1' → 1
'1' → 1
'1' → 1
'1' → 1
'1' → 1
'1' → 1
'1' → 1
'1' → 1
'1' → 1
'1' → 1
'1' → 1
'1' → 1
'1' → 1
```

```
resultado: [4,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
```

---

### Paso 5 — `esValida` recibe la lista y llama a `reverse`

```haskell
esValida [4,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
```

Dentro de `esValida`:

```haskell
where total = sumaLuhn (reverse digitos) False
```

```
reverse [4,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
→ [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,4]
```

El `4` queda al final porque era el primer dígito escrito. El primer dígito de la lista volteada (el `1` de la derecha de la tarjeta) se deja igual (`duplicar = False`).

---

### Paso 6 — `sumaLuhn` baja por recursión

Se llama: `sumaLuhn [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,4] False`

Cada llamada separa el primer elemento con el patrón `(x:xs)` y decide si duplicar o dejar igual:

**Bajada (se acumulan sumas pendientes, aún no se calculan):**

| Llamada | `x` | `xs` (resto) | `duplicar` | Guarda activa | Expresión pendiente |
|---|---|---|---|---|---|
| 1 | `1` | `[1,1,1,1,1,1,1,1,1,1,1,1,1,1,4]` | `False` | `duplicar == False` | `1 + sumaLuhn [1,1,1,1,1,1,1,1,1,1,1,1,1,1,4] True` |
| 2 | `1` | `[1,1,1,1,1,1,1,1,1,1,1,1,1,4]` | `True` | `duplicar == True` | `duplica 1 + sumaLuhn [1,1,1,1,1,1,1,1,1,1,1,1,1,4] False` |
| 3 | `1` | `[1,1,1,1,1,1,1,1,1,1,1,1,4]` | `False` | `duplicar == False` | `1 + sumaLuhn [1,1,1,1,1,1,1,1,1,1,1,1,4] True` |
| 4 | `1` | `[1,1,1,1,1,1,1,1,1,1,1,4]` | `True` | `duplicar == True` | `duplica 1 + sumaLuhn [1,1,1,1,1,1,1,1,1,1,1,4] False` |
| 5 | `1` | `[1,1,1,1,1,1,1,1,1,1,4]` | `False` | `duplicar == False` | `1 + sumaLuhn [1,1,1,1,1,1,1,1,1,1,4] True` |
| 6 | `1` | `[1,1,1,1,1,1,1,1,1,4]` | `True` | `duplicar == True` | `duplica 1 + sumaLuhn [1,1,1,1,1,1,1,1,1,4] False` |
| 7 | `1` | `[1,1,1,1,1,1,1,1,4]` | `False` | `duplicar == False` | `1 + sumaLuhn [1,1,1,1,1,1,1,1,4] True` |
| 8 | `1` | `[1,1,1,1,1,1,1,4]` | `True` | `duplicar == True` | `duplica 1 + sumaLuhn [1,1,1,1,1,1,1,4] False` |
| 9 | `1` | `[1,1,1,1,1,1,4]` | `False` | `duplicar == False` | `1 + sumaLuhn [1,1,1,1,1,1,4] True` |
| 10 | `1` | `[1,1,1,1,1,4]` | `True` | `duplicar == True` | `duplica 1 + sumaLuhn [1,1,1,1,1,4] False` |
| 11 | `1` | `[1,1,1,1,4]` | `False` | `duplicar == False` | `1 + sumaLuhn [1,1,1,1,4] True` |
| 12 | `1` | `[1,1,1,4]` | `True` | `duplicar == True` | `duplica 1 + sumaLuhn [1,1,1,4] False` |
| 13 | `1` | `[1,1,4]` | `False` | `duplicar == False` | `1 + sumaLuhn [1,1,4] True` |
| 14 | `1` | `[1,4]` | `True` | `duplicar == True` | `duplica 1 + sumaLuhn [1,4] False` |
| 15 | `1` | `[4]` | `False` | `duplicar == False` | `1 + sumaLuhn [4] True` |
| 16 | `4` | `[]` | `True` | `duplicar == True` | `duplica 4 + sumaLuhn [] False` |
| 17 | `[]` | — | `False` | patrón `[]` | `0` ← **caso base, termina la bajada** |

---

### Paso 7 — `duplica` se evalúa en cada llamada que toca duplicar

Las llamadas con `duplicar == True` son: 2, 4, 6, 8, 10, 12, 14, 16.

| Llamada | Dígito | `duplica d` | `d * 2 > 9`? | Resultado |
|---|---|---|---|---|
| 2 | `1` | `1 * 2 = 2` | No | `2` |
| 4 | `1` | `1 * 2 = 2` | No | `2` |
| 6 | `1` | `1 * 2 = 2` | No | `2` |
| 8 | `1` | `1 * 2 = 2` | No | `2` |
| 10 | `1` | `1 * 2 = 2` | No | `2` |
| 12 | `1` | `1 * 2 = 2` | No | `2` |
| 14 | `1` | `1 * 2 = 2` | No | `2` |
| 16 | `4` | `4 * 2 = 8` | No | `8` |

---

### Paso 8 — `sumaLuhn` sube y completa las sumas

Al llegar al caso base, Haskell regresa completando cada suma pendiente de abajo hacia arriba:

```
Llamada 17 devuelve  0
Llamada 16 devuelve  8 + 0  =  8       (duplica 4 = 8)
Llamada 15 devuelve  1 + 8  =  9       (x = 1, igual)
Llamada 14 devuelve  2 + 9  = 11       (duplica 1 = 2)
Llamada 13 devuelve  1 + 11 = 12       (x = 1, igual)
Llamada 12 devuelve  2 + 12 = 14       (duplica 1 = 2)
Llamada 11 devuelve  1 + 14 = 15       (x = 1, igual)
Llamada 10 devuelve  2 + 15 = 17       (duplica 1 = 2)
Llamada  9 devuelve  1 + 17 = 18       (x = 1, igual)
Llamada  8 devuelve  2 + 18 = 20       (duplica 1 = 2)  ← nótese: aquí el 5 del primero
Llamada  7 devuelve  1 + 20 = 21       (x = 1, igual)
Llamada  6 devuelve  2 + 21 = 23       (duplica 1 = 2)
Llamada  5 devuelve  1 + 23 = 24       (x = 1, igual)
Llamada  4 devuelve  2 + 24 = 26       (duplica 1 = 2)
Llamada  3 devuelve  1 + 26 = 27       (x = 1, igual)
Llamada  2 devuelve  2 + 27 = 29       (duplica 1 = 2)
Llamada  1 devuelve  1 + 29 = 30       (x = 1, igual)
```

**Expresión completa construida:**
```
1 + (2 + (1 + (2 + (1 + (2 + (1 + (2 + (1 + (2 + (1 + (2 + (1 + (2 + (1 + (8 + 0))))))))))))))))
= 30
```

> **Nota:** `sumaLuhn` devuelve `30`, no `20`. El valor `20` que aparecía antes era un error; la suma real de Luhn para `4111111111111111` es **30**.

---

### Paso 9 — `esValida` comprueba si es múltiplo de 10

```haskell
mod total 10 == 0
```

```
total = 30
mod 30 10 = 0
0 == 0  →  True
```

`esValida` devuelve `True`.

---

### Paso 10 — `main` imprime el resultado

```haskell
else if esValida (map digitToInt numero)
  then putStrLn "Tarjeta valida"
```

`esValida` devolvió `True` → se ejecuta el `then`:

```
Tarjeta valida
```

---

### Resumen visual de la corrida completa

```
Entrada del usuario
  "4111111111111111"
       │
       ▼ filter (/= ' ')
  "4111111111111111"   ← sin cambio
       │
       ▼ validación: all isDigit → True, length == 16 → True
       OK
       │
       ▼ map digitToInt
  [4,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
       │
       ▼ reverse (dentro de esValida)
  [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,4]
       │
       ▼ sumaLuhn ... False
         Pos  1: 1 igual     →  1
         Pos  2: 1 duplica   →  2
         Pos  3: 1 igual     →  1
         Pos  4: 1 duplica   →  2
         Pos  5: 1 igual     →  1
         Pos  6: 1 duplica   →  2
         Pos  7: 1 igual     →  1
         Pos  8: 1 duplica   →  2
         Pos  9: 1 igual     →  1
         Pos 10: 1 duplica   →  2
         Pos 11: 1 igual     →  1
         Pos 12: 1 duplica   →  2
         Pos 13: 1 igual     →  1
         Pos 14: 1 duplica   →  2
         Pos 15: 1 igual     →  1
         Pos 16: 4 duplica   →  8
         caso base           →  0
       │
       ▼ suma total al regresar
       30
       │
       ▼ mod 30 10 == 0
       True
       │
       ▼
  "Tarjeta valida"
```

---

## Requisitos

- [GHC](https://www.haskell.org/ghc/) (compilador de Haskell) instalado. Se puede obtener con [GHCup](https://www.haskell.org/ghcup/).

## Cómo ejecutarlo

Guarda el código en un archivo llamado `tarjeta.hs`.

**Con GHCi (intérprete):**

```
ghci tarjeta.hs
```

Luego escribe:

```
main
```

**Compilando:**

```
ghc tarjeta.hs
.\tarjeta.exe
```

> **Nota:** no funciona en [play.haskell.org](https://play.haskell.org), porque ese sitio no permite entrada por teclado y `getLine` marca el error `end of file`. Ahí se puede probar dejando el número fijo dentro de `main`.

## Ejemplos de uso

| Entrada | Dígitos (sin espacios) | Salida |
|---|---|---|
| `4111111111111111` | 16 | `Tarjeta valida` |
| `4111111111111112` | 16 | `Tarjeta no valida` |
| `5500005555555559` | 16 | `Tarjeta valida` |
| `4539 5787 6362 8` | 13 | `Entrada no valida: usa solo 16 digitos` |
| `abc` | — | `Entrada no valida: usa solo 16 digitos` |
| `123` | 3 | `Entrada no valida: usa solo 16 digitos` |

Ejemplo de ejecución:

```
Ingresa el numero de tarjeta:
4111111111111111
Tarjeta valida
```

```
Ingresa el numero de tarjeta:
4111111111111112
Tarjeta no valida
```

```
Ingresa el numero de tarjeta:
abc
Entrada no valida: usa solo 16 digitos
```

