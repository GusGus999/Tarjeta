import Data.Char (isDigit, digitToInt)

duplica :: Int -> Int
duplica d
  | d * 2 > 9 = d * 2 - 9
  | otherwise = d * 2

sumaLuhn :: [Int] -> Bool -> Int
sumaLuhn [] _ = 0
sumaLuhn (x:xs) duplicar
  | duplicar == True  = duplica x + sumaLuhn xs False
  | duplicar == False = x + sumaLuhn xs True

esValida :: [Int] -> Bool
esValida digitos = mod total 10 == 0
  where total = sumaLuhn (reverse digitos) False

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