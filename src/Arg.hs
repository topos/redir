{-# LANGUAGE TemplateHaskell #-}
module Arg (args
           ,ip
           ,port
           ,redirectFile
           ,help
           ,usage
           ,printUsage
           ,Options(..)) where

import System.Console.GetOpt
import System.Environment (getArgs, getProgName)
import Control.Lens

data Options = Options{_ip :: String
                      ,_port :: Int
                      ,_redirectFile :: String
                      ,_help :: Bool} 
               deriving Show
defaultOptions = Options{_ip="127.0.0.1"
                        ,_port=8080
                        ,_redirectFile="./etc/redirect.yaml"
                        ,_help=False}
makeLenses ''Options

options :: [OptDescr (Options -> Options)]
options = [Option ['i'] ["ip"]
           (ReqArg (\i opts -> opts{_ip=i}) "ip")
           "ip"
          ,Option ['p'] ["port"]
           (ReqArg (\p opts -> opts{_port=(read p)}) "port")
           "port"
          ,Option ['r'] ["redirectFile"]
           (ReqArg (\r opts -> opts{_redirectFile=r}) "redirectFile")
           "redirectFile"
          ,Option ['h'] ["help"]
           (NoArg (\opts -> opts{_help=True}))
           "help"]

cmd :: IO String
cmd = getProgName

args :: IO Options
args = do
  args <- getArgs
  case getOpt RequireOrder options args of
    (opts, [], []) -> return (foldl (flip id) defaultOptions opts)
    (_, _, errs) -> do
      usage' <- usage
      ioError (userError $ concat errs ++ usage')

usage :: IO String
usage = do
  cmd' <- cmd
  let header = "usage: " ++ cmd' ++ " [options...]"
  return $ usageInfo header options

printUsage :: IO ()
printUsage = do
  usage <- usage
  putStr usage
