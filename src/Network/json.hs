{-# LANGUAGE OverloadedStrings #-}
module Network.Json where

import Network.Wai (pathInfo,responseBuilder,responseLBS)
import Network.Wai.Handler.Warp
import Network.HTTP.Types (status200)
import Network.HTTP.Types.Header (hContentType)
import Blaze.ByteString.Builder (copyByteString)
import Blaze.ByteString.Builder.ByteString (fromLazyByteString)
import Data.Monoid (mconcat)
import Data.Aeson (encode)
 
defmain = do
  let port = 3000
  putStrLn $ "listening on port " ++ show port
  run port app
 
app req = return $ case pathInfo req of
                     ["hello"] -> hello
                     ["j",x] -> get x
                     _ -> home
 
hello = responseBuilder status200 [(hContentType,"text/plain")] 
        $ mconcat $ map copyByteString ["hello, world."]

content = [1,2,3] :: [Int]
home = responseBuilder status200 [(hContentType, "application/json")]
       $ fromLazyByteString $ encode content

get x = responseBuilder status200 [(hContentType,"application/json")]
       $ fromLazyByteString $ encode [x]

--index = responseBuilder status200 [(hContentType,"text/html")] $ mconcat $ map copyByteString
--      ["<p>Hello, World!</p>","<p><a href='/yay'>yay</a></p>"]
