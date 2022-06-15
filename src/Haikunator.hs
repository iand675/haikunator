{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}
module Haikunator
  ( HaikuSlug(..)
  , HaikuGeneratorConfig(..)
  , haikunate
  , haikunateM
  , formatSlug
  , formatSlug'
  , defaultHaikuGeneratorConfig
  , variantCount
  ) where

import Control.Monad.IO.Class
import GHC.Generics
import Data.Foldable
import Data.Hashable
import Data.Int
import Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Text.IO as T
import Data.Vector (Vector)
import qualified Data.Vector as V
import Paths_haikunator
import System.Random
import System.IO.Unsafe
import Text.Printf

data HaikuSlug = 
  HaikuSlug 
    { adjective :: !Text
    , noun :: !Text
    , number :: !Int64
    , _numberOfDigits :: !Int
    } deriving (Generic, Eq, Ord)

instance Hashable HaikuSlug

instance Show HaikuSlug where
  show = T.unpack . formatSlug

data HaikuGeneratorConfig = 
  HaikuGeneratorConfig 
    { adjectives :: !(Vector Text)
    , nouns :: !(Vector Text)
    , numberOfDigits :: !Int
    } deriving (Generic, Show, Eq, Ord)

haikunate :: RandomGen g => HaikuGeneratorConfig -> g -> (HaikuSlug, g)
haikunate conf g =
  let (adjIx, g') = uniformR (0, length (adjectives conf) - 1) g
      (nounIx, g'') = uniformR (0, length (nouns conf) - 1) g'
      (number, g''') = uniformR (0, 10 ^ (numberOfDigits conf) - 1) g''
  in 
    ( HaikuSlug 
        (adjectives conf V.! adjIx) 
        (nouns conf V.! nounIx) 
        number 
        (numberOfDigits conf)
    , g'''
    )

haikunateM :: MonadIO m => HaikuGeneratorConfig -> m HaikuSlug
haikunateM conf = getStdRandom (haikunate conf)

formatSlug :: HaikuSlug -> Text
formatSlug = formatSlug' "-"

formatSlug' :: Text -> HaikuSlug -> Text
formatSlug' separator haiku = T.concat
  (
    [ adjective haiku
    , separator
    , noun haiku
    ]
    ++ if _numberOfDigits haiku == 0 
    then [] 
    else 
      [ separator
      , T.pack $ 
        printf 
          ("%" ++ show (_numberOfDigits haiku) ++ "d") 
          (number haiku)
      ]
  )

defaultHaikuGeneratorConfig :: HaikuGeneratorConfig
defaultHaikuGeneratorConfig = unsafePerformIO $ do
  adjectives <- fmap T.lines . T.readFile =<< getDataFileName "adjectives"
  nouns <- fmap T.lines . T.readFile =<< getDataFileName "nouns"
  pure $ HaikuGeneratorConfig
    { adjectives = V.fromList adjectives
    , nouns = V.fromList nouns
    , numberOfDigits = 4
    }
{-# NOINLINE defaultHaikuGeneratorConfig #-}

variantCount :: HaikuGeneratorConfig -> Int
variantCount conf = length (adjectives conf) * length (nouns conf) * 10 ^ (numberOfDigits conf)