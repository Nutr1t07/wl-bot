{-# LANGUAGE OverloadedStrings #-}
module Web.CoolQ where

import Control.Lens
import Type.Telegram.Update as TG
import Type.CoolQ.User         as CQ
import Type.Config
import Data.Telegram
import Network.Wreq
import Data.Aeson
import Data.ByteString.Lazy
import Control.Concurrent
import Control.Concurrent.Lock
import Control.Exception.Base
import Utils.Logging

fwdTGtoQQ :: Lock -> String -> Update -> GroupMap -> IO (Maybe ThreadId)
fwdTGtoQQ lock cqServer tgUpdate grpMaps =
  case cqReq of
    Null -> pure Nothing
    _ -> Just <$> postCqRequest lock cqServer "send_group_msg" cqReq
  where cqReq = transTgGrpUpdate grpMaps tgUpdate

postCqRequest :: Lock -> String -> String -> Value -> IO ThreadId
postCqRequest = ((.).(.).(.).(.)) forkIO postCqRequestSync

postCqRequestSync :: Lock -> String -> String -> Value -> IO ()
postCqRequestSync lock cqServer method jsonContent = do
  acquire lock
  try $ post target jsonContent :: IO (Either SomeException (Response ByteString))
  release lock
    where
      target = cqServer ++ "/" ++ method