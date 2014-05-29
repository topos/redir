{-# LANGUAGE OverloadedStrings #-}
module Main where

import Network.Wai
import Network.HTTP.Types (status200)
import Network.Wai.Handler.Warp (run)

app _ = return $ responseLBS status200 [("Content-Type", "text/plain")] "Hello, World!"  

main = run 3000 app
