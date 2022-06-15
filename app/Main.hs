module Main where

import Haikunator

main :: IO ()
main = haikunateM defaultHaikuGeneratorConfig >>= print
