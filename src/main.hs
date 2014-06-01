{-# LANGUAGE OverloadedStrings #-}
module Main where

import Network.Wai
import Network.HTTP.Types (status200)
import Network.Wai.Handler.Warp (run)
import Data.Maybe (fromMaybe)
import qualified Data.Map as Map
import qualified Data.Map.Strict as M

app _ = do
  let h = M.fromList [("/","Hello, World?"),("/hi","Hi, there.")]
      r = case M.lookup "/hi" h of
            Just r' -> r'
            Nothing -> "Lions! Tigers! And bears! Oh, my!"
  return $ responseLBS status200 [("Content-Type", "text/plain")] r

main = run 8080 app
 
