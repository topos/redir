{-# LANGUAGE Rank2Types, OverloadedStrings, ScopedTypeVariables #-}
module Main where

import Control.Exception (try)
import Control.Monad (forever, unless)
import Data.ByteString.Char8 (pack)
import Data.Maybe (fromMaybe)
import Data.ByteString (ByteString)
import Data.Text (Text,unpack)
import Data.Text.Encoding (encodeUtf8)
import Network.Wai (Application,pathInfo,responseLBS,responseStream)
import Network.HTTP.Types (status200,status301,status302)
import Network.Wai.Handler.Warp (run)
import Blaze.ByteString.Builder (fromByteString)
import qualified Data.Map as M
import qualified Data.Yaml.Etc.Config as C
import Arg

main :: IO ()
main = run 8080 app

app :: Application
app req res = do
  y <- C.yaml "/etc/redir.yml"
  let pi = pathInfo req
      k = if pi == [] then
              "url"
          else
              unpack $ head pi
      rs = C.redirs y
      m = M.fromList $ map (\r->(C.src r,(C.dst r, C.statusCode r))) rs
      key = "http://" ++ k
      (url, status) = case M.lookup (key) m of
                        Just pair -> pair
                        Nothing -> ("-[default]-", 0)
  res $ if status == 202 
        then responseStream status200 [("Content-Type", "image/png"), ("Content-Disposition", "inline; filename=\"pix.png\"")] $
                 \sendChunk flush -> forever $ do
                                       sendChunk $ fromByteString $ pack url
                                       flush
        else responseLBS status200 [("Content-Type", "text/plain"), ("Location", pack url)] $
                 "<body>/</body>"
