{-# LANGUAGE Rank2Types #-}
{-# LANGUAGE OverloadedStrings #-}
module Main where

import Network.Wai
import Network.HTTP.Types (status200)
import Network.Wai.Handler.Warp (run)
import Control.Exception (try)
import Data.Either (isLeft,isRight)
import Data.Maybe (fromMaybe)
import Data.ByteString (ByteString)
import Data.Text (Text)
import Data.Text.Encoding (encodeUtf8)
import qualified Data.Map as Map
import qualified Data.Map.Strict as M

app :: Application
app req = do
  let ps = pathInfo req
      k = if null ps then "" else ps !! 0
      h = M.fromList [("","http://hello.world.com"), ("hi","http://hi.there.io")]
      r = case M.lookup k h of
            Just r' -> r'
            Nothing -> encodeUtf8 k
  return $ responseLBS status200 [("Content-Type", "text/plain"), ("Location", r)] ""

main = run 8080 app
