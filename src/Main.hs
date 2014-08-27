{-# LANGUAGE Rank2Types,OverloadedStrings,ScopedTypeVariables #-}
module Main where

import Blaze.ByteString.Builder (fromByteString)
import Data.ByteString.Char8 (pack)
import Data.Text (unpack)
import Network.HTTP.Types (status200,status301,status302)
import Network.Wai (Application,pathInfo)
import Network.Wai.Handler.Warp (run,defaultSettings)
import Pipes.Wai (Application,Flush(..),producerRequestBody,responseProducer,requestBody,rawPathInfo)
import Pipes -- ((>->),yield)
import Pipes.HTTP --(parseUrl,withManager,withHTTP)
import qualified Pipes.Prelude as P
import qualified Data.Map as M
import Data.Yaml.Etc.Config (Redirect(..),redirs,yaml)

main :: IO ()
main = run 8080 $ \req res -> do
         yml <- yaml "/etc/redir.yml"
         let rmap = M.fromList $ map (\r->(src r,(dst r, statusCode r))) $ redirs yml
             ps = pathInfo req
             k = if ps == [] then "url" else unpack $ head ps
             key = "http://" ++ k
             (url, status) = case M.lookup (key) rmap of
                               Just pair -> pair
                               Nothing -> ("-[default]-", 0)
         req' <- parseUrl url
         let p = do
               withHTTP req' $ \res' ->
                   responseBody res' >-> P.map (Chunk . fromByteString)
               yield Flush
         res (responseProducer status200 [("Content-Type","text/plain")] p)

main' :: IO ()
main' = do
  yml <- yaml "/etc/redir.yml"
  run 8080 $ app $ redirs yml

app :: [Redirect] -> Application
app rs req res = do
  let rmap = M.fromList $ map (\r->(src r,(dst r, statusCode r))) rs
      ps = pathInfo req
      k = if ps == [] then "url" else unpack $ head ps
      key = "http://" ++ k
      (url, status) = case M.lookup (key) rmap of
                        Just pair -> pair
                        Nothing -> ("-[default]-", 0)
  res $ responseProducer status200 [("Content-Type","text/plain"),("Location",pack url)] $ yield Flush
