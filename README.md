# Validador de números de tarjeta en Haskell



**Qué hace, paso a paso:**

1. Muestra un mensaje pidiendo el número de tarjeta.
2. Lee lo que el usuario escribe. Se recibe como **texto**, no como número.
3. Quita los espacios del texto, para aceptar entradas como `4539 5787 6362 8`.
4. Comprueba que el texto contenga **solo dígitos** y que tenga entre **13 y 19 caracteres**, que es el rango de longitudes de las tarjetas reales.
5. Convierte cada caracter en un número entero y arma una lista de dígitos.
6. Aplica el **algoritmo de Luhn** sobre esa lista.
7. Imprime `Tarjeta valida` o `Tarjeta no valida`.

**Características del programa:**

- Está escrito en Haskell, un lenguaje funcional.
- La parte principal del algoritmo se resuelve con **recursividad**, **ajuste de patrones** y **guardas**.
- Acepta espacios entre grupos de dígitos.
- Rechaza entradas con letras, símbolos o con una longitud fuera de rango.


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
| `main` | `IO ()` | Lee la entrada, la limpia, la revisa y muestra el resultado. |

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
  if not (all isDigit numero) || length numero < 13 || length numero > 19
    then putStrLn "Entrada no valida: usa solo digitos (13 a 19)"
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
| `if not (all isDigit numero) \|\| length numero < 13 \|\| length numero > 19` | Revisa tres condiciones unidas por `\|\|` ("o"): que haya algún caracter que no sea dígito, que tenga menos de 13 caracteres o que tenga más de 19. Si alguna es cierta, la entrada es incorrecta. |
| `then putStrLn "Entrada no valida..."` | Si la entrada es incorrecta, muestra el aviso. |
| `else if esValida (map digitToInt numero)` | Si la entrada es correcta, convierte cada caracter en número con `map digitToInt` y llama a `esValida`. |
| `then putStrLn "Tarjeta valida"` | Si `esValida` devuelve `True`. |
| `else putStrLn "Tarjeta no valida"` | Si `esValida` devuelve `False`. |

**Ejemplo con `4539 5787 6362 8`:**

```
entrada = "4539 5787 6362 8"
numero  = "4539578763628"
map digitToInt numero = [4,5,3,9,5,7,8,7,6,3,6,2,8]
```

---

## Flujo completo del programa

**Quién llama a quién:**

```
main
 ├─ getLine ................. lee la entrada
 ├─ filter .................. quita los espacios
 ├─ (revisa dígitos y longitud)
 ├─ map digitToInt .......... convierte texto en números
 └─ esValida
      ├─ reverse ............ voltea la lista
      ├─ sumaLuhn ........... suma recursiva
      │    └─ duplica ....... cuando toca duplicar un dígito
      └─ mod total 10 == 0 .. decide True o False
 └─ putStrLn ................ muestra el resultado
```

**Cómo se transforma el dato, con la entrada `4539 5787 6362 8`:**

```
"4539 5787 6362 8"                  lo que escribe el usuario
   ↓ filter (/= ' ')
"4539578763628"                     sin espacios
   ↓ map digitToInt
[4,5,3,9,5,7,8,7,6,3,6,2,8]         lista de números
   ↓ reverse
[8,2,6,3,6,7,8,7,5,9,3,5,4]         lista volteada
   ↓ sumaLuhn (14 llamadas)
[8,4,6,6,6,5,8,5,5,9,3,1,4]         lo que aporta cada dígito
   ↓ suma al regresar la recursión
70                                  total
   ↓ mod 70 10 == 0
True
   ↓
"Tarjeta valida"                    salida
```

**Las 14 llamadas de `sumaLuhn` con este ejemplo:**

| Llamada | Dígito | `duplicar` | Acción | Aporta |
|---|---|---|---|---|
| 1 | 8 | `False` | igual | 8 |
| 2 | 2 | `True` | `duplica 2` | 4 |
| 3 | 6 | `False` | igual | 6 |
| 4 | 3 | `True` | `duplica 3` | 6 |
| 5 | 6 | `False` | igual | 6 |
| 6 | 7 | `True` | `duplica 7` (14 − 9) | 5 |
| 7 | 8 | `False` | igual | 8 |
| 8 | 7 | `True` | `duplica 7` (14 − 9) | 5 |
| 9 | 5 | `False` | igual | 5 |
| 10 | 9 | `True` | `duplica 9` (18 − 9) | 9 |
| 11 | 3 | `False` | igual | 3 |
| 12 | 5 | `True` | `duplica 5` (10 − 9) | 1 |
| 13 | 4 | `False` | igual | 4 |
| 14 | (lista vacía) | | caso base | 0 |

Al regresar, las sumas pendientes se completan:

```
8 + (4 + (6 + (6 + (6 + (5 + (8 + (5 + (5 + (9 + (3 + (1 + (4 + 0))))))))))))  =  70
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

| Entrada | Salida |
|---|---|
| `4539 5787 6362 8` | `Tarjeta valida` |
| `4111111111111111` | `Tarjeta valida` |
| `4111111111111112` | `Tarjeta no valida` |
| `abc` | `Entrada no valida: usa solo digitos (13 a 19)` |
| `123` | `Entrada no valida: usa solo digitos (13 a 19)` |

Ejemplo de ejecución:

```
Ingresa el numero de tarjeta:
4539 5787 6362 8
Tarjeta valida
```

