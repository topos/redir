{-# LANGUAGE Rank2Types #-}
{-# LANGUAGE OverloadedStrings #-}
module Main where

import Network.Wai
import Network.Wai.Handler.Warp (run)
import Data.ByteString (ByteString)
import qualified Data.ByteString.Lazy as L
import Data.Enumerator (consume, Iteratee)
import Blaze.ByteString.Builder (fromLazyByteString)

main :: IO ()
main = putStrLn "http://localhost:3000/" >> run "Webkit Sample" app

app :: Application
app req = case pathInfo req of
    "/post/" -> do
        bss <- consume
        postResponse $ L.fromChunks bss
    _ -> indexResponse

indexResponse :: Iteratee ByteString IO Response
indexResponse = return $ ResponseFile
    status200
    [("Content-Type" , "text/html")]
    "index.html"

postResponse :: L.ByteString -> Iteratee ByteString IO Response
postResponse lbs = return $ ResponseBuilder
    status200
    [("Content-Type", "text/plain")]
    (fromLazyByteString lbs)

-- import Network.Wai
-- import Network.HTTP.Types (status200)
-- import Network.Wai.Handler.Warp (run)
-- import Data.Maybe (fromMaybe)
-- import qualified Data.Map as Map
-- import qualified Data.Map.Strict as M

-- app _ = do
--   let h = M.fromList [("/","Hello, World?"),("/hi","Hi, there.")]
--       r = case M.lookup "/hi" h of
--             Just r' -> r'
--             Nothing -> "Lions! Tigers! And bears! Oh, my!"
--   return $ responseLBS status200 [("Content-Type", "text/plain")] r

-- main = run 8080 app

