module IntCode(load, run) where
import qualified Data.Map as M
load :: String -> M.Map Int Int
run :: M.Map Int Int -> Int -> Int -> [Int] -> (M.Map Int Int, [Int])
load str = M.fromList $ zip [0..] $ read $ '[' : str ++ "]"
run m at base input
  | opc == 99 = (m, [])
  | opc == 1 = dyadic (+)
  | opc == 2 = dyadic (*)
  | opc == 3 = run (put leftMode opd1 $ head input) (at + 2) base (tail input)
  | opc == 4 = let (m',o') = run m (at + 2) base input in (m', left : o')
  | opc == 5 = branch (/= 0)
  | opc == 6 = branch (== 0)
  | opc == 7 = dyadic $ truth (<)
  | opc == 8 = dyadic $ truth (==)
  | opc == 9 = run m (at + 2) (base + left) input
  where op = m M.! at
        (modes,opc) = op `divMod` 100
        load addr = M.findWithDefault 0 addr m
        [opd1, opd2, opd3] = [ load $ at + j | j <- [1..3] ]
        (modes', leftMode) = modes `divMod` 10
        (toMode, rightMode) = modes' `divMod` 10
        get 0 opd = load opd
        get 1 opd = opd
        get 2 opd = load $ base + opd
        left = get leftMode opd1
        right = get rightMode opd2
        put 0 addr val = M.insert addr val m
        put 2 addr val = M.insert (base+addr) val m
        dyadic f = run (put toMode opd3 $ f left right) (at + 4) base input
        truth f x y = if f x y then 1 else 0
        branch f = run m (if f left then right else at + 3) base input
